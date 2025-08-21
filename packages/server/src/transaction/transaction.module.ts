import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Transaction } from '../db/transaction.entity.js';
import { TransactionService } from './transaction.service.js';

@Module({
  imports: [TypeOrmModule.forFeature([Transaction])],
  providers: [TransactionService],
  exports: [TransactionService],
})
export class TransactionModule {}
