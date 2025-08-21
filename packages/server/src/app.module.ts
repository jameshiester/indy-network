import { Module } from '@nestjs/common';
import { ScheduleModule } from '@nestjs/schedule';
import { HealthModule } from './health/health.module';
import { LedgerModule } from './ledger/ledger.module';
import { DBModule } from './db/db.module';
import { TransactionModule } from './transaction/transaction.module.js';
import { DidModule } from './did/did.module.js';

@Module({
  imports: [
    HealthModule,
    LedgerModule,
    TransactionModule,
    DidModule,
    ScheduleModule.forRoot(),
    DBModule,
  ],
})
export class AppModule {}
