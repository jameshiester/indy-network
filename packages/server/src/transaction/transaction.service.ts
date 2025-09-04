import { Injectable, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { IBaseSearchOptions, ITransaction } from 'model';
import { Repository } from 'typeorm';

import { Transaction } from '../db/transaction.entity';
import { findAndCount } from '../db/utils';

@Injectable()
export class TransactionService {
  private readonly logger = new Logger(TransactionService.name);

  constructor(
    @InjectRepository(Transaction)
    private readonly transactionRepository: Repository<Transaction>,
  ) {}

  async upsertTransaction(
    transactionData: Omit<ITransaction, 'createdAt' | 'updatedAt'>,
  ): Promise<Transaction> {
    const result = await this.transactionRepository.save(transactionData);
    return result;
  }

  async getTransaction(
    id: number,
    ledger: number,
  ): Promise<Transaction | null> {
    this.logger.debug(`Getting transaction ${id} from ledger ${ledger}`);

    try {
      const transaction = await this.transactionRepository.findOne({
        where: { id, ledger },
      });

      return transaction;
    } catch (error) {
      this.logger.error(
        `Failed to get transaction ${id} from ledger ${ledger}: ${(error as { message: string }).message}`,
      );
      throw error;
    }
  }

  search(options: IBaseSearchOptions<ITransaction>) {
    return findAndCount(this.transactionRepository, options);
  }

  async getTransactionsByLedger(
    ledger: number,
    limit?: number,
  ): Promise<Transaction[]> {
    this.logger.debug(`Getting transactions for ledger ${ledger}`);

    try {
      const query = this.transactionRepository
        .createQueryBuilder('transaction')
        .where('transaction.ledger = :ledger', { ledger })
        .orderBy('transaction.id', 'DESC');

      if (limit) {
        query.limit(limit);
      }

      const transactions = await query.getMany();
      return transactions;
    } catch (error) {
      this.logger.error(
        `Failed to get transactions for ledger ${ledger}: ${(error as { message: string }).message}`,
      );
      throw error;
    }
  }
}
