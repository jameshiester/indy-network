import { Body, Controller, Post } from '@nestjs/common';
import { IBaseSearchOptions, ITransaction } from 'model';

import { TransactionService } from './transaction.service';

@Controller('transactions')
export class TransactionController {
  constructor(private readonly transactionService: TransactionService) {}

  @Post('search')
  search(@Body() options: IBaseSearchOptions<ITransaction>) {
    return this.transactionService.search(options);
  }
}
