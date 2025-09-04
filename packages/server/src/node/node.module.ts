import { Module } from '@nestjs/common';

import { DBModule } from '../db/db.module';

import { NodeHistoryService } from './node-history.service';
import { NodeService } from './node.service';

@Module({
  imports: [DBModule],
  providers: [NodeService, NodeHistoryService],
  exports: [NodeService, NodeHistoryService],
})
export class NodeModule {}
