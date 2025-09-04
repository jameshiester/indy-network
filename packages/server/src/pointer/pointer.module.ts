import { Module } from '@nestjs/common';

import { DBModule } from '../db/db.module';

import { PointerService } from './pointer.service';

@Module({
  imports: [DBModule],
  providers: [PointerService],
  exports: [PointerService],
})
export class PointerModule {}
