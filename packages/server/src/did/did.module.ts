import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';

import { Did } from '../db/did.entity';

import { DidController } from './did.controller';
import { DidService } from './did.service';

@Module({
  imports: [TypeOrmModule.forFeature([Did])],
  controllers: [DidController],
  providers: [DidService],
  exports: [DidService],
})
export class DidModule {}
