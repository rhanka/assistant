import { Module } from '@nestjs/common';
import { PlanResolver } from './plan.resolver.js';
import { PrismaService } from '../prisma/prisma.service.js';

@Module({
  providers: [PlanResolver, PrismaService]
})
export class PlanModule {}
