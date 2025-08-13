import { Module } from '@nestjs/common';
import { ScheduleModule } from '@nestjs/schedule';
import { HealthModule } from './health/health.module';
import { LedgerModule } from './ledger/ledger.module';
import { RootDBModule } from './db/db.module';

@Module({
  imports: [HealthModule, LedgerModule, ScheduleModule.forRoot(), RootDBModule],
})
export class AppModule {}


