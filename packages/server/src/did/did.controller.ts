import { Body, Controller, Get, Param, Post } from '@nestjs/common';
import { IBaseSearchOptions, IDid } from 'model';

import { DidService } from './did.service';

@Controller('dids')
export class DidController {
  constructor(private readonly didService: DidService) {}

  @Post('search')
  search(@Body() body: IBaseSearchOptions<IDid>) {
    const { order = { transactionId: 'ASC' }, ...options } =
      body || ({} as IBaseSearchOptions<IDid>);
    return this.didService.search({ ...options, order });
  }

  @Get(':id')
  async getDid(@Param('id') id: string) {
    return await this.didService.getDid(id);
  }
}
