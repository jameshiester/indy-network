import { Module } from '@nestjs/common';
import { ScheduleModule } from '@nestjs/schedule';
import { HealthModule } from './health/health.module';
import { LedgerModule } from './ledger/ledger.module';

@Module({
  imports: [HealthModule, LedgerModule, ScheduleModule.forRoot()],
})
export class AppModule {}


