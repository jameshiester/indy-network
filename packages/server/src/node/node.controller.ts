import { Body, Controller, Get, Param, Post } from '@nestjs/common';
import { IBaseSearchOptions, INode } from 'model';

import { NodeService } from './node.service';

@Controller('nodes')
export class NodeController {
  constructor(private readonly nodeService: NodeService) {}

  @Post('search')
  searchNodes(@Body() body: IBaseSearchOptions<INode>) {
    const { order = { name: 'ASC' }, ...options } = body;
    return this.nodeService.search({ ...options, order });
  }

  @Get(':id')
  async getNode(@Param('id') id: string) {
    return await this.nodeService.getNode(id);
  }
}
