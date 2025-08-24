import { createWriteStream } from 'node:fs';
import { mkdir } from 'node:fs/promises';
import { dirname } from 'node:path';
import { pipeline } from 'node:stream/promises';
import 'reflect-metadata';

import { GetObjectCommand, S3Client } from '@aws-sdk/client-s3';
import { NestFactory } from '@nestjs/core';

import { AppModule } from './app.module';

async function bootstrap() {
  // Download genesis file from S3 to local path if S3 envs are provided
  const genesisPath = process.env.GENESIS_TXN_PATH || '/app/genesis.txn';
  const s3Bucket = process.env.GENESIS_S3_BUCKET;
  const s3Key = process.env.GENESIS_S3_KEY;
  if (genesisPath && s3Bucket && s3Key) {
    try {
      const s3 = new S3Client({
        region: process.env.AWS_REGION || 'us-east-1',
      });
      const cmd = new GetObjectCommand({ Bucket: s3Bucket, Key: s3Key });
      const res = await s3.send(cmd);
      const body = res.Body as unknown as NodeJS.ReadableStream;
      await mkdir(dirname(genesisPath), { recursive: true });
      await pipeline(body, createWriteStream(genesisPath));
    } catch (error) {
      console.error('Failed to download genesis from S3:', error);
    }
  }

  const app = await NestFactory.create(AppModule);
  const port = process.env.PORT ? Number(process.env.PORT) : 8080;
  await app.listen(port);

  console.log(`API listening on http://localhost:${port}`);
}

// eslint-disable-next-line @typescript-eslint/no-floating-promises
bootstrap();
