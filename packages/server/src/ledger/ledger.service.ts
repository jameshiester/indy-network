import { GetTransactionResponse, IndyVdrPool, GetTransactionRequest, PoolCreate, GetValidatorInfoAction, GetValidatorInfoResponse } from '@hyperledger/indy-vdr-nodejs';
import { Injectable, Logger, InternalServerErrorException, NotFoundException } from '@nestjs/common';
import { Cron, CronExpression } from '@nestjs/schedule';
import { PointerService } from '../pointer/pointer.service.js';
import { readFile } from 'fs/promises';
import { Key, KeyAlgorithm } from '@openwallet-foundation/askar-nodejs';

@Injectable()
export class LedgerService {
  private readonly logger = new Logger(LedgerService.name);
  private readonly pool: IndyVdrPool;

  constructor(private readonly pointerService: PointerService) {
    this.pool = new PoolCreate({ parameters: { transactions_path: process.env.GENESIS_TXN_PATH } })
  }

  getStatus() {
    return { status: 'ledger-ok' };
  }

  async getGenesisTransactionsText(): Promise<string> {
    const genesisFilePath = process.env.GENESIS_TXN_PATH;
    if (!genesisFilePath) {
      this.logger.error('Environment variable GENESIS_TXN_PATH is not set.');
      throw new InternalServerErrorException('GENESIS_TXN_PATH is not set');
    }
    try {
      const fileContent = await readFile(genesisFilePath, { encoding: 'utf-8' });
      return fileContent;
    } catch (error: any) {
      if (error?.code === 'ENOENT') {
        this.logger.error(`Genesis file not found at path: ${genesisFilePath}`);
        throw new NotFoundException('Genesis transactions file not found');
      }
      this.logger.error(`Failed to read genesis file: ${error?.message ?? error}`);
      throw new InternalServerErrorException('Failed to read genesis transactions file');
    }
  }

  async syncLedger(ledger: number) {
    let latest = await this.pointerService.getLatest(ledger);
    let complete = false;
    this.logger.debug(`Syncing ledger ${ledger} from ${latest}`);
    while (!complete) {
      try {
        const request = new GetTransactionRequest({ ledgerType: ledger, seqNo: latest + 1 })
        const response: GetTransactionResponse = await this.pool.submitRequest(request)

        if (response.result.seqNo === undefined) {
          this.logger.debug(`Syncing ledger ${ledger} complete. Last synced txn: ${latest}`)
          complete = true;
        } else {
          await this.pointerService.setLatest(ledger, response.result.seqNo);
          latest = response.result.seqNo;
          this.logger.debug(`Txn ${response.result.seqNo} synced from ledger ${ledger}`)
        }

      } catch (error) {
        this.logger.error(error);
        complete = true;
      }
    }
  }

  private async getMonitorInfo(monitorHost: string, monitorPort: string, networkName: string, headers: Record<string, string>) {
    const url = `http://${monitorHost}:${monitorPort}/networks`;
    // const url = `http://${monitorHost}:${monitorPort}/networks/${networkName}`;
    this.logger.debug(`Making request to: ${url}`);

    try {
      const response = await fetch(url, {
        headers
      });

      if (!response.ok) {
        this.logger.error(`Monitor request failed with status: ${response.status} ${response.statusText}`);
        throw new Error(`Monitor request failed with status: ${response.status} ${response.statusText}`);
      }

      const responseData = await response.json();
      this.logger.debug(`Monitor response: ${JSON.stringify(responseData)}`);

      return responseData;
    } catch (error) {
      this.logger.error(`Failed to get monitor info: ${error.message}`);
      this.logger.error(`Monitor error details:`, {
        name: error.name,
        stack: error.stack,
        cause: error.cause,
        url: url,
        headers: headers
      });
    }
  }

  private async getNodeInfo(monitorHost: string, monitorPort: string, networkName: string, headers: Record<string, string>) {
    const url = `http://${monitorHost}:${monitorPort}/networks/${networkName}/node1`;
    this.logger.debug(`Making node request to: ${url}`);

    try {
      const nodeResponse = await fetch(url, { headers });

      if (!nodeResponse.ok) {
        this.logger.error(`Node request failed with status: ${nodeResponse.status} ${nodeResponse.statusText}`);
        throw new Error(`Node request failed with status: ${nodeResponse.status} ${nodeResponse.statusText}`);
      }

      const nodeResponseData = await nodeResponse.json();
      this.logger.debug(`Node response: ${JSON.stringify(nodeResponseData)}`);

      return nodeResponseData;
    } catch (error) {
      this.logger.error(`Failed to get node info: ${error.message}`);
      this.logger.error(`Node error details:`, {
        name: error.name,
        stack: error.stack,
        cause: error.cause,
        url: url,
        headers: headers
      });
    }
  }

  async getValidatorInfo() {
    this.logger.debug(`Syncing validator info`);

    try {
      const monitorHost = process.env.MONITOR_HOST || 'localhost';
      const monitorPort = process.env.MONITOR_PORT || '8080';
      const networkName = process.env.INDY_NETWORK_NAME || 'default';
      const seed = process.env.SEED;
      const headers: Record<string, string> = {};
      if (seed) {
        headers['seed'] = seed;
      }

      const monitorData = await this.getMonitorInfo(monitorHost, monitorPort, networkName, headers);
      const nodeData = await this.getNodeInfo(monitorHost, monitorPort, networkName, headers);

      return monitorData;
    } catch (error) {
      this.logger.error(`Failed to get validator info from monitor: ${error.message}`);
      throw error;
    }
  }

  async getValidatorInfoSigned() {
    try {
      const did = process.env.DID;
      this.logger.log(`Getting validator info for DID: ${did}`);
      const request = new GetValidatorInfoAction({ submitterDid: did });
      const seed = Uint8Array.from(Buffer.from(process.env.SEED));
      const key = Key.fromSeed({ algorithm: KeyAlgorithm.Ed25519, seed });
      const signature = key.signMessage({ message: Buffer.from(request.signatureInput, 'utf8') });
      this.logger.log(signature);
      request.setSignature({ signature: signature });
      const response: GetValidatorInfoResponse = await this.pool.submitRequest(request)
      this.logger.log(response);
    } catch (error) {
      this.logger.error(`Failed to get validator info: ${error.message}`);
      throw error;
    }
  }


  @Cron(process.env.CRON_EXPRESSION || CronExpression.EVERY_MINUTE)
  async syncLedgers() {
    await Promise.all([
      this.syncLedger(0),
      this.syncLedger(1),
      this.syncLedger(2)
    ])
  }

  @Cron(process.env.CRON_EXPRESSION || CronExpression.EVERY_MINUTE)
  async syncStatus() {
    // await this.getValidatorInfo();
    await this.getValidatorInfoSigned();
  }
}


