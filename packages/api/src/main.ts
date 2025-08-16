import 'reflect-metadata';
import { NestFactory } from '@nestjs/core';
import { AppModule } from './modules/app.module.js';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  
  // TODO: Configure Swagger/OpenAPI when @nestjs/swagger is installed
  // const config = new DocumentBuilder()
  //   .setTitle('Assistant API')
  //   .setDescription('API for managing plans, tasks, and steps')
  //   .setVersion('1.0')
  //   .addTag('plans', 'Plan management operations')
  //   .addTag('tasks', 'Task management operations')
  //   .addTag('health', 'Health check endpoints')
  //   .build();
  
  // const document = SwaggerModule.createDocument(app, config);
  // SwaggerModule.setup('api', app, document);
  
  const port = Number(process.env.API_PORT || 3001);
  await app.listen(port);
  console.log(`API listening on http://localhost:${port}`);
  console.log(`Swagger documentation will be available at http://localhost:${port}/api`);
}
bootstrap();
