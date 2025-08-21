import { Controller, Get, Param, Query, Delete } from '@nestjs/common';
import { DidService } from './did.service.js';

const defaultLimit = 1000;

@Controller('dids')
export class DidController {
  constructor(private readonly didService: DidService) {}

  @Get()
  async getAllDids(@Query('limit') limit?: string) {
    const limitNumber = limit ? parseInt(limit, defaultLimit) : undefined;
    return await this.didService.searchDids(limitNumber);
  }

  @Get(':id')
  async getDid(@Param('id') id: string) {
    return await this.didService.getDid(id);
  }

  @Get('from/:from')
  async getDidsByFrom(
    @Param('from') from: string,
    @Query('limit') limit?: string,
  ) {
    const limitNumber = limit ? parseInt(limit, defaultLimit) : undefined;
    return await this.didService.getDidsByFrom(from, limitNumber);
  }
}
