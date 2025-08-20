import { Module } from '@nestjs/common';
import { DBModule } from '../db/db.module';
import { NodeService } from './node.service';

@Module({
  imports: [DBModule],
  providers: [NodeService],
  exports: [NodeService],
})
export class NodeModule {}
