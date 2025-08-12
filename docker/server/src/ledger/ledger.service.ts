import { GetTransactionResponse, IndyVdrPool, GetTransactionRequest, PoolCreate } from '@hyperledger/indy-vdr-nodejs';
import { Injectable, Logger } from '@nestjs/common';
import { Cron, CronExpression } from '@nestjs/schedule';

@Injectable()
export class LedgerService {
  private readonly logger = new Logger(LedgerService.name);
  private readonly pool: IndyVdrPool;

  constructor() {
    this.pool = new PoolCreate({ parameters: { transactions_path: process.env.GENESIS_TXN_PATH } })
  }

  getStatus() {
    return { status: 'ledger-ok' };
  }

  @Cron(process.env.CRON_EXPRESSION || CronExpression.EVERY_10_MINUTES)
  async handleCron() {
    const request = new GetTransactionRequest({ ledgerType: 1, seqNo: 1 })
    const response: GetTransactionResponse = await this.pool.submitRequest(request)
    this.logger.debug(response.result.seqNo)
  }
}


