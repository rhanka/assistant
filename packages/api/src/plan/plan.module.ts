import { Module } from '@nestjs/common';
import { PlanResolver } from './plan.resolver.js';
import { PrismaService } from '../prisma/prisma.service.js';
import { SchedulerAdapterService } from './scheduler-adapter.service.js';

@Module({
  providers: [PlanResolver, PrismaService, SchedulerAdapterService]
})
export class PlanModule {}
