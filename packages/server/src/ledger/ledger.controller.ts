import { Controller, Get, Header } from '@nestjs/common';

import { LedgerService } from './ledger.service.js';

@Controller('ledger')
export class LedgerController {
  constructor(private readonly ledgerService: LedgerService) {}

  @Get('genesis')
  @Header('Content-Type', 'text/plain; charset=utf-8')
  getGenesis(): Promise<string> {
    return this.ledgerService.getGenesisTransactionsText();
  }
}
