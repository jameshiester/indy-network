import { Controller, Get } from '@nestjs/common';
import type { IndyVdrPool } from '@hyperledger/indy-vdr-nodejs'
import { PoolCreate } from '@hyperledger/indy-vdr-nodejs'
import { LedgerService } from './ledger.service.js';

@Controller('ledger')
export class LedgerController {
  private readonly pool: IndyVdrPool
  constructor(private readonly ledgerService: LedgerService) {
    this.pool = new PoolCreate({ parameters: { transactions_path: process.env.GENESIS_TXN_PATH } })
  }

  @Get('status')
  async getStatus() {
    const txns = await this.pool.transactions
    console.log()
    return this.ledgerService.getStatus();
  }
}


