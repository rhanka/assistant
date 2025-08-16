import { Module } from '@nestjs/common';
import { GraphQLModule } from '@nestjs/graphql';
import { ApolloDriver, ApolloDriverConfig } from '@nestjs/apollo';
import { join } from 'node:path';
import { HealthController } from './health.controller.js';
import { PlanModule } from '../plan/plan.module.js';
import { PrismaService } from '../prisma/prisma.service.js';

@Module({
  imports: [
    GraphQLModule.forRoot<ApolloDriverConfig>({
      driver: ApolloDriver,
      autoSchemaFile: join(process.cwd(), 'dist/schema.gql')
    }),
    PlanModule
  ],
  controllers: [HealthController],
  providers: [PrismaService]
})
export class AppModule {}
