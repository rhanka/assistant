import { Resolver, Query, Mutation, Args, ResolveField, Parent } from '@nestjs/graphql';
import { Plan, PlanMethodology, PlanStatus, Task, TaskStatus, Step, StepStatus, TaskType } from './plan.model.js';
import { CreatePlanInput, CreateTaskInput, CreateStepInput, UpdatePlanInput, UpdateTaskInput, UpdateStepInput } from './dto/index.js';
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
      status: p.status as PlanStatus,
      objective: p.objective || undefined,
      tasks: (p.tasks || []).map((t) => ({
        id: t.id,
        title: t.title,
        type: t.type as TaskType,
        status: t.status as TaskStatus,
        assignee: t.assignee || undefined,
        labels: t.labels || [],
        estimate: t.estimate || undefined,
        dueDate: t.dueDate || undefined,
        dependencies: t.dependencies || [],
        linksGithubIssue: t.linksGithubIssue || undefined,
        linksGithubPR: t.linksGithubPR || undefined,
        createdAt: t.createdAt,
        updatedAt: t.updatedAt
      } as Task)),
      createdAt: p.createdAt,
      updatedAt: p.updatedAt
    }));
  }

  @Mutation(() => Plan)
  async createPlan(@Args('input') input: CreatePlanInput): Promise<Plan> {
    const created = await this.prisma.plan.create({
      data: { title: input.title, methodology: input.methodology, status: 'DRAFT', objective: input.objective ?? null }
    });
    return { 
      id: created.id, 
      title: created.title, 
      methodology: created.methodology as PlanMethodology, 
      status: created.status as PlanStatus, 
      objective: created.objective ?? undefined, 
      tasks: [],
      createdAt: created.createdAt,
      updatedAt: created.updatedAt
    };
  }

  @Mutation(() => Task)
  async createTask(@Args('input') input: CreateTaskInput): Promise<Task> {
    const created = await this.prisma.task.create({
      data: {
        title: input.title,
        planId: input.planId,
        type: input.type,
        status: input.status || 'TODO',
        assignee: input.assignee,
        labels: input.labels || [],
        estimate: input.estimate,
        dueDate: input.dueDate,
        dependencies: input.dependencies || [],
        linksGithubIssue: input.linksGithubIssue,
        linksGithubPR: input.linksGithubPR
      }
    });
    return {
      id: created.id,
      title: created.title,
      type: created.type as TaskType,
      status: created.status as TaskStatus,
      assignee: created.assignee || undefined,
      labels: created.labels || [],
      estimate: created.estimate || undefined,
      dueDate: created.dueDate || undefined,
      dependencies: created.dependencies || [],
      linksGithubIssue: created.linksGithubIssue || undefined,
      linksGithubPR: created.linksGithubPR || undefined,
      createdAt: created.createdAt,
      updatedAt: created.updatedAt
    };
  }

  @Mutation(() => Task)
  async updateTask(@Args('id') id: string, @Args('input') input: UpdateTaskInput): Promise<Task> {
    const updated = await this.prisma.task.update({
      where: { id },
      data: {
        title: input.title,
        planId: input.planId,
        type: input.type,
        status: input.status,
        assignee: input.assignee,
        labels: input.labels,
        estimate: input.estimate,
        dueDate: input.dueDate,
        dependencies: input.dependencies,
        linksGithubIssue: input.linksGithubIssue,
        linksGithubPR: input.linksGithubPR
      }
    });
    return {
      id: updated.id,
      title: updated.title,
      type: updated.type as TaskType,
      status: updated.status as TaskStatus,
      assignee: updated.assignee || undefined,
      labels: updated.labels || [],
      estimate: updated.estimate || undefined,
      dueDate: updated.dueDate || undefined,
      dependencies: updated.dependencies || [],
      linksGithubIssue: updated.linksGithubIssue || undefined,
      linksGithubPR: updated.linksGithubPR || undefined,
      createdAt: updated.createdAt,
      updatedAt: updated.updatedAt
    };
  }

  @Mutation(() => Boolean)
  async deleteTask(@Args('id') id: string): Promise<boolean> {
    await this.prisma.task.delete({ where: { id } });
    return true;
  }
}
