import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Did } from '../db/did.entity.js';
import { DidService } from './did.service.js';
import { DidController } from './did.controller.js';

@Module({
  imports: [TypeOrmModule.forFeature([Did])],
  controllers: [DidController],
  providers: [DidService],
  exports: [DidService],
})
export class DidModule {}
