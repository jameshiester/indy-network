import { Module } from '@nestjs/common';
import { DBModule } from '../db/db.module';
import { NodeService } from './node.service';
import { NodeHistoryService } from './nodeHistory.service';

@Module({
  imports: [DBModule],
  providers: [NodeService, NodeHistoryService],
  exports: [NodeService, NodeHistoryService],
})
export class NodeModule {}
