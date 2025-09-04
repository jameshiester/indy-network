import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { IBaseSearchOptions, INodeHistory } from 'model';
import { Repository } from 'typeorm';

import { NodeHistory } from '../db/node-history.entity';
import { findAndCount } from '../db/utils';

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

  search(options: IBaseSearchOptions<INodeHistory>) {
    return findAndCount(this.nodeHistoryRepository, options);
  }
}
