import { Module } from '@nestjs/common';

import { DidModule } from '../did/did.module.js';
import { NodeModule } from '../node/node.module.js';
import { PointerModule } from '../pointer/pointer.module.js';
import { TransactionModule } from '../transaction/transaction.module.js';

import { LedgerController } from './ledger.controller.js';
import { LedgerService } from './ledger.service.js';

@Module({
  imports: [PointerModule, NodeModule, TransactionModule, DidModule],
  controllers: [LedgerController],
  providers: [LedgerService],
  exports: [LedgerService],
})
export class LedgerModule {}
