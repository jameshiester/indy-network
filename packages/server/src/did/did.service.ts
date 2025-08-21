import { Injectable, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Did } from '../db/did.entity.js';
import { IDid } from 'model';

@Injectable()
export class DidService {
  private readonly logger = new Logger(DidService.name);

  constructor(
    @InjectRepository(Did)
    private readonly didRepository: Repository<Did>,
  ) {}

  async upsertDid(
    didData: Omit<IDid, 'createdAt' | 'updatedAt'>,
  ): Promise<Did> {
    const result = await this.didRepository.save(didData);
    return result;
  }

  async getDid(id: string): Promise<Did | undefined> {
    const did = await this.didRepository.findOneBy({ id });
    return did || undefined;
  }

  async getDidsByFrom(from: string, limit?: number): Promise<Did[]> {
    this.logger.debug(`Getting DIDs by from: ${from}`);

    try {
      const query = this.didRepository
        .createQueryBuilder('did')
        .where('did.from = :from', { from })
        .orderBy('did.createdAt', 'DESC');

      if (limit) {
        query.limit(limit);
      }

      const dids = await query.getMany();
      return dids;
    } catch (error) {
      this.logger.error(`Failed to get DIDs by from ${from}: ${error.message}`);
      throw error;
    }
  }

  async searchDids(limit?: number): Promise<Did[]> {
    const query = this.didRepository
      .createQueryBuilder('did')
      .orderBy('did.createdAt', 'DESC');

    if (limit) {
      query.limit(limit);
    }

    const dids = await query.getMany();
    return dids;
  }
}
