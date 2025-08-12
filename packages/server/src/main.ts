import 'reflect-metadata';
import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { createWriteStream } from 'node:fs';
import { mkdir } from 'node:fs/promises';
import { pipeline } from 'node:stream/promises';
import { dirname } from 'node:path';
import { S3Client, GetObjectCommand } from '@aws-sdk/client-s3';

async function bootstrap() {
  // Download genesis file from S3 to local path if S3 envs are provided
  const genesisPath = process.env.GENESIS_TXN_PATH;
  const s3Bucket = process.env.GENESIS_S3_BUCKET;
  const s3Key = process.env.GENESIS_S3_KEY;
  if (genesisPath && s3Bucket && s3Key) {
    try {
      const s3 = new S3Client({region: process.env.AWS_REGION || 'us-east-1' });
      const cmd = new GetObjectCommand({ Bucket: s3Bucket, Key: s3Key });
      const res = await s3.send(cmd);
      const body = res.Body as unknown as NodeJS.ReadableStream;
      await mkdir(dirname(genesisPath), { recursive: true });
      await pipeline(body, createWriteStream(genesisPath));
    } catch (err) {
      // eslint-disable-next-line no-console
      console.error('Failed to download genesis from S3:', err);
    }
  }

  const app = await NestFactory.create(AppModule);
  const port = process.env.PORT ? Number(process.env.PORT) : 8080;
  await app.listen(port);
  // eslint-disable-next-line no-console
  console.log(`API listening on http://localhost:${port}`);
}

bootstrap();


