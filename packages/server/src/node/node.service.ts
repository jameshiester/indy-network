import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Node } from '../db/node.entity';
import { INode } from 'model';

@Injectable()
export class NodeService {
  constructor(
    @InjectRepository(Node)
    private nodeRepository: Repository<Node>,
  ) {}

  async getNode(name: string): Promise<Node | undefined> {
    const node = await this.nodeRepository.findOne({ where: { name } });
    if (!node) {
      return undefined;
    }
    return node;
  }

  async upsertNode(
    node: Omit<INode, 'createdAt' | 'updatedAt'>,
  ): Promise<INode> {
    const result = await this.nodeRepository.save(node);
    return result;
  }
}
