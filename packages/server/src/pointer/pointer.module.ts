import { Module } from '@nestjs/common';
import { PointerService } from './pointer.service';
import { DBModule } from '../db/db.module';

@Module({
  imports: [DBModule],
  providers: [PointerService],
  exports: [PointerService],
})
export class PointerModule {}
