import { readFile } from 'fs/promises';

import {
  Injectable,
  InternalServerErrorException,
  Logger,
  NotFoundException,
} from '@nestjs/common';
import { Cron, CronExpression } from '@nestjs/schedule';
import {
  INode,
  INodeHistory,
  IValidatorInfo,
  IndyTransactionType,
  LedgerType,
} from 'model';

import { DidService } from '../did/did.service.js';
import { transactionResponseToDidAdapter } from '../did/utils.js';
import { NodeHistoryService } from '../node/node-history.service.js';
import { NodeService } from '../node/node.service.js';
import { PointerService } from '../pointer/pointer.service.js';
import { TransactionService } from '../transaction/transaction.service.js';
import { transactionResponseToTransactionAdapter } from '../transaction/utils.js';
import { GetTransactionResponse } from './types.js';

@Injectable()
export class LedgerService {
  private readonly logger = new Logger(LedgerService.name);

  constructor(
    private readonly pointerService: PointerService,
    private readonly nodeService: NodeService,
    private readonly transactionService: TransactionService,
    private readonly didService: DidService,
    private readonly nodeHistoryService: NodeHistoryService,
  ) {}

  async getGenesisTransactionsText(): Promise<string> {
    const genesisFilePath = process.env.GENESIS_TXN_PATH;
    if (!genesisFilePath) {
      this.logger.error('Environment variable GENESIS_TXN_PATH is not set.');
      throw new InternalServerErrorException('GENESIS_TXN_PATH is not set');
    }
    try {
      const fileContent = await readFile(genesisFilePath, {
        encoding: 'utf-8',
      });
      return fileContent;
    } catch (error) {
      const err = error as {
        code: string;
        message: string;
      };
      if (err?.code === 'ENOENT') {
        this.logger.error(`Genesis file not found at path: ${genesisFilePath}`);
        throw new NotFoundException('Genesis transactions file not found');
      }
      this.logger.error(
        `Failed to read genesis file: ${err?.message ?? error}`,
      );
      throw new InternalServerErrorException(
        'Failed to read genesis transactions file',
      );
    }
  }

  async syncLedger(ledger: number) {
    const startFromBeginning = process.env.START_FROM_BEGINNING === 'true';
    let latest = startFromBeginning
      ? 0
      : await this.pointerService.getLatest(ledger);
    let complete = false;
    this.logger.debug(`Syncing ledger ${ledger} from ${latest}`);
    while (!complete) {
      try {
        const response = await this.fetchTransactionFromMonitor(
          ledger,
          latest + 1,
        );

        if (response.seqNo === undefined) {
          this.logger.debug(
            `Syncing ledger ${ledger} complete. Last synced txn: ${latest}`,
          );
          complete = true;
        } else {
          // Transform and save the transaction
          const transactionData = transactionResponseToTransactionAdapter(
            ledger as LedgerType,
            response.seqNo,
            response,
          );
          await this.transactionService.upsertTransaction(transactionData);

          if (transactionData.transactionType === IndyTransactionType.NYM) {
            const didData = transactionResponseToDidAdapter(response);
            await this.didService.upsertDid(didData);
          }

          await this.pointerService.setLatest(ledger, response.seqNo);
          latest = response.seqNo;
          this.logger.debug(
            `Txn ${response.seqNo} synced from ledger ${ledger}`,
          );
        }
      } catch (error) {
        const err = error as {
          message: string;
        };
        this.logger.error(`Error syncing ledger ${ledger}: ${err.message}`);
        complete = true;
      }
    }
  }

  private async callMonitorApi<T>(
    endpoint: string,
    options?: {
      headers?: Record<string, string>;
      method?: string;
    },
  ): Promise<T> {
    const monitorHost = process.env.MONITOR_HOST || 'localhost';
    const monitorPort = process.env.MONITOR_PORT || '8080';
    const networkName = process.env.INDY_NETWORK_NAME || 'default';

    const baseUrl = `http://${monitorHost}:${monitorPort}/networks/${networkName}`;
    const url = `${baseUrl}${endpoint}`;

    const requestOptions: RequestInit = {
      method: options?.method || 'GET',
      headers: {
        'Content-Type': 'application/json',
        ...options?.headers,
      },
    };

    // Add seed header if available
    const seed = process.env.SEED;
    if (seed) {
      requestOptions.headers = {
        ...requestOptions.headers,
        seed,
      };
    }

    this.logger.debug(`Calling monitor API: ${url}`);

    const response = await fetch(url, requestOptions);

    if (!response.ok) {
      throw new Error(
        `Monitor API request failed: ${response.status} ${response.statusText} - ${url}`,
      );
    }

    return (await response.json()) as T;
  }

  private async fetchNodeInfoFromMonitor(
    node: string,
  ): Promise<IValidatorInfo> {
    const nodeResponseDataArray = await this.callMonitorApi<
      Array<IValidatorInfo>
    >(`/${node}`);
    return nodeResponseDataArray[0];
  }

  private async fetchTransactionFromMonitor(
    ledger: number,
    seqNo: number,
  ): Promise<GetTransactionResponse> {
    return await this.callMonitorApi<GetTransactionResponse>(
      `/ledger/${ledger}/transactions/${seqNo}`,
    );
  }

  private async fetchVerifiersFromMonitor() {
    return await this.callMonitorApi<Record<string, unknown>>(
      '/pool/verifiers',
    );
  }

  private transformValidatorInfoToNode(
    nodeName: string,
    validatorInfo: IValidatorInfo,
  ): Omit<INode, 'createdAt' | 'updatedAt'> {
    return {
      name: nodeName,
      active: validatorInfo?.status?.ok === true,
      value: validatorInfo,
      indyVersion: validatorInfo?.status?.software?.['indy-node'],
      did: validatorInfo?.response?.result?.data['Node_info']?.did,
      verkey: validatorInfo?.response?.result?.data['Node_info']?.verkey,
      uptimeSeconds:
        validatorInfo?.response?.result?.data['Node_info']?.Metrics?.uptime,
    };
  }

  private transformValidatorInfoToNodeHistory(
    nodeName: string,
    validatorInfo: IValidatorInfo,
  ): Omit<INodeHistory, 'createdAt' | 'updatedAt'> {
    return {
      name: nodeName,
      timestamp: validatorInfo?.status?.timestamp
        ? new Date(Number(validatorInfo?.status?.timestamp))
        : undefined,
      indyVersion: validatorInfo?.status?.software?.['indy-node'],
      readThroughput:
        validatorInfo?.response.result.data.Node_info.Metrics[
          'average-per-second'
        ]['read-transactions'],
      writeThroughput:
        validatorInfo?.response.result.data.Node_info.Metrics[
          'average-per-second'
        ]['write-transactions'],
      reachableNodesCount:
        validatorInfo?.response.result.data.Pool_info.Reachable_nodes_count,
      unreachableNodesCount:
        validatorInfo?.response.result.data.Pool_info.Unreachable_nodes_count,
      active: validatorInfo?.status?.ok === true,
    };
  }

  async getValidatorInfo(node: string) {
    this.logger.debug(`Syncing validator info for node ${node}`);
    try {
      const validatorInfo = await this.fetchNodeInfoFromMonitor(node);

      const nodeData = this.transformValidatorInfoToNode(node, validatorInfo);
      await this.nodeService.upsertNode(nodeData);
      const nodeHistory = this.transformValidatorInfoToNodeHistory(
        node,
        validatorInfo,
      );
      await this.nodeHistoryService.upsertNodeHistory(nodeHistory);
    } catch (error) {
      this.logger.error(
        `Failed to get node info: ${(error as { message: string }).message}`,
      );
    }
  }

  @Cron(process.env.CRON_EXPRESSION || CronExpression.EVERY_MINUTE)
  async syncLedgers() {
    await Promise.all([
      this.syncLedger(0),
      this.syncLedger(1),
      this.syncLedger(2),
    ]);
  }

  @Cron(process.env.CRON_EXPRESSION || CronExpression.EVERY_MINUTE)
  async syncStatus() {
    const verifiers = await this.fetchVerifiersFromMonitor();
    this.logger.log(`Verifiers: ${JSON.stringify(verifiers)}`);
    const nodes = Object.keys(verifiers);
    await Promise.all(nodes.map((node) => this.getValidatorInfo(node)));
  }
}
