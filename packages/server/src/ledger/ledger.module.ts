import { Module } from '@nestjs/common';
import { LedgerController } from './ledger.controller.js';
import { LedgerService } from './ledger.service.js';
import { PointerModule } from '../pointer/pointer.module.js';
import { NodeModule } from '../node/node.module.js';

@Module({
  imports: [PointerModule, NodeModule],
  controllers: [LedgerController],
  providers: [LedgerService],
  exports: [LedgerService],
})
export class LedgerModule {}
