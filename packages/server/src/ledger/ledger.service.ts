import { GetTransactionResponse, IndyVdrPool, GetTransactionRequest, PoolCreate, GetValidatorInfoAction, GetValidatorInfoResponse } from '@hyperledger/indy-vdr-nodejs';
import { Injectable, Logger, InternalServerErrorException, NotFoundException } from '@nestjs/common';
import { Cron, CronExpression } from '@nestjs/schedule';
import { Key, KeyAlgorithm } from "@openwallet-foundation/askar-nodejs";
import { PointerService } from '../pointer/pointer.service.js';
import { readFile } from 'fs/promises';

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
        
        if(response.result.seqNo === undefined){
          this.logger.debug(`Syncing ledger ${ledger} complete. Last synced txn: ${latest}`)
          complete = true;
        }else {
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

  async getValidatorInfo() {
    this.logger.debug(`Syncing validator info`);
      try {
        const request = new GetValidatorInfoAction({submitterDid: process.env.VALIDATOR_DID });
        const seed = Uint8Array.from(Buffer.from(process.env.VALIDATOR_SEED));
        const key = Key.fromSeed({ algorithm: KeyAlgorithm.Bls12381G1, seed });
        const signature = key.signMessage({message: Buffer.from(request.signatureInput, 'utf8')});
        request.setSignature({signature: signature});
        // request.setEndorser({endorser: process.env.VALIDATOR_DID});
        const response: GetValidatorInfoResponse = await this.pool.submitAction(request)
        console.log(response);
      } catch (error) {
        this.logger.error(error);
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
    const status = await this.pool.status;
    console.log(status);
    await this.getValidatorInfo();
  }
}


