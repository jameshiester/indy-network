import { Module } from '@nestjs/common';

import { DidModule } from '../did/did.module';
import { NodeModule } from '../node/node.module';
import { PointerModule } from '../pointer/pointer.module';
import { TransactionModule } from '../transaction/transaction.module';

import { LedgerController } from './ledger.controller';
import { LedgerService } from './ledger.service';

@Module({
  imports: [PointerModule, NodeModule, TransactionModule, DidModule],
  controllers: [LedgerController],
  providers: [LedgerService],
  exports: [LedgerService],
})
export class LedgerModule {}
