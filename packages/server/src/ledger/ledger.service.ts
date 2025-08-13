import { GetTransactionResponse, IndyVdrPool, GetTransactionRequest, PoolCreate } from '@hyperledger/indy-vdr-nodejs';
import { Injectable, Logger } from '@nestjs/common';
import { Cron, CronExpression } from '@nestjs/schedule';
import { PointerService } from 'src/pointer/pointer.service.js';

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

  async syncLedger(ledger: number) {
    const latest = await this.pointerService.getLatest(ledger);
    let complete = false;
    while (!complete) {
      try {
        this.logger.debug(`Syncing ledger ${ledger} from ${latest}`);
        const request = new GetTransactionRequest({ ledgerType: ledger, seqNo: latest + 1 })
        const response: GetTransactionResponse = await this.pool.submitRequest(request)
        this.logger.debug(response.result.seqNo)
        if(response.result.seqNo === undefined){
          await this.pointerService.setLatest(ledger, latest);
          complete = true;
        }
      } catch (error) {
        this.logger.error(error);
        complete = true;
      }
    }

  }

  @Cron(process.env.CRON_EXPRESSION || CronExpression.EVERY_MINUTE)
  async handleCron() {
    await Promise.all([
      this.syncLedger(0),
      this.syncLedger(1),
      this.syncLedger(2)
    ])
  }
}


