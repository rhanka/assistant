import 'reflect-metadata';
import { NestFactory } from '@nestjs/core';
import { AppModule } from './modules/app.module.js';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  const port = Number(process.env.API_PORT || 3001);
  await app.listen(port);
  console.log(`API listening on http://localhost:${port}`);
}
bootstrap();
