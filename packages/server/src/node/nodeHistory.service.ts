import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { NodeHistory } from '../db/nodeHistory.entity';
import { INodeHistory } from 'model';

@Injectable()
export class NodeHistoryService {
  constructor(
    @InjectRepository(NodeHistory)
    private nodeHistoryRepository: Repository<NodeHistory>,
  ) {}

  async upsertNodeHistory(
    nodeHistory: Omit<INodeHistory, 'createdAt' | 'updatedAt'>,
  ): Promise<INodeHistory> {
    const result = await this.nodeHistoryRepository.save(nodeHistory);
    return result;
  }
}
