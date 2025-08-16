import { Resolver, Query, Mutation, Args } from '@nestjs/graphql';
import { Plan, PlanMethodology, PlanStatus, Task, TaskStatus } from './plan.model.js';
import { CreatePlanInput } from './dto/create-plan.input.js';
import { PrismaService } from '../prisma/prisma.service.js';

@Resolver(() => Plan)
export class PlanResolver {
  constructor(private prisma: PrismaService) {}

  @Query(() => [Plan])
  async plans(): Promise<Plan[]> {
    const rows = await this.prisma.plan.findMany({ include: { tasks: true } });
    return rows.map((p) => ({
      id: p.id,
      title: p.title,
      methodology: p.methodology as PlanMethodology,
      status: p.status as any,
      objective: p.objective || undefined,
      tasks: (p.tasks || []).map((t) => ({
        id: t.id,
        title: t.title,
        status: t.status as TaskStatus
      } as Task))
    }));
  }

  @Mutation(() => Plan)
  async createPlan(@Args('input') input: CreatePlanInput): Promise<Plan> {
    const created = await this.prisma.plan.create({
      data: { title: input.title, methodology: input.methodology, status: 'DRAFT', objective: input.objective ?? null }
    });
    return { id: created.id, title: created.title, methodology: created.methodology as any, status: created.status as any, objective: created.objective ?? undefined, tasks: [] };
  }
}
