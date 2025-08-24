import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';

import { NodeHistory } from './node-history.entity';
import { Node } from './node.entity';
import { Pointer } from './pointer.entity';

const {
  DB_PORT = 5432,
  DB_HOST,
  DB_USERNAME = 'postgres',
  DB_PASSWORD,
  DB_DATABASE = 'postgres',
  DB_SCHEMA,
  DB_TYPE = 'postgres',
} = process.env;

@Module({
  imports: [
    TypeOrmModule.forRoot({
      autoLoadEntities: true,
      type: DB_TYPE as 'postgres',
      host: DB_HOST,
      port: Number(DB_PORT),
      username: DB_USERNAME,
      password: DB_PASSWORD,
      database: DB_DATABASE,
      schema: DB_SCHEMA,
      synchronize: true,
      ssl: {
        rejectUnauthorized: false,
      },
    }),
    TypeOrmModule.forFeature([Pointer, Node, NodeHistory]),
  ],
  exports: [TypeOrmModule],
})
export class DBModule {}
