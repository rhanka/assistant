import { Field, ID, ObjectType, registerEnumType } from '@nestjs/graphql';

export enum PlanMethodology { AGILE_SCRUM='AGILE_SCRUM', KANBAN='KANBAN', WATERFALL='WATERFALL', HYBRID='HYBRID' }
export enum PlanStatus { DRAFT='DRAFT', IN_PROGRESS='IN_PROGRESS', BLOCKED='BLOCKED', COMPLETED='COMPLETED', CANCELLED='CANCELLED' }
export enum PlanCategory { PROJECT='PROJECT', ACTIVITY='ACTIVITY', MILESTONE='MILESTONE', SPRINT='SPRINT' }
export enum TaskType { EPIC='EPIC', STORY='STORY', TASK='TASK', BUG='BUG', SPIKE='SPIKE', CHORE='CHORE', SUB_PLAN='SUB_PLAN' }
export enum TaskStatus { TODO='TODO', IN_PROGRESS='IN_PROGRESS', BLOCKED='BLOCKED', REVIEW='REVIEW', DONE='DONE', CANCELLED='CANCELLED' }
export enum StepStatus { TODO='TODO', IN_PROGRESS='IN_PROGRESS', BLOCKED='BLOCKED', COMPLETED='COMPLETED' }

registerEnumType(PlanMethodology, { name: 'PlanMethodology' });
registerEnumType(PlanStatus, { name: 'PlanStatus' });
registerEnumType(PlanCategory, { name: 'PlanCategory' });
registerEnumType(TaskType, { name: 'TaskType' });
registerEnumType(TaskStatus, { name: 'TaskStatus' });
registerEnumType(StepStatus, { name: 'StepStatus' });

@ObjectType()
export class Task {
  @Field(() => ID) id!: string;
  @Field() title!: string;
  @Field(() => TaskType, { nullable: true }) type?: TaskType;
  @Field(() => TaskStatus) status!: TaskStatus;
  @Field({ nullable: true }) assignee?: string;
  @Field(() => [String], { nullable: true }) labels?: string[];
  @Field({ nullable: true }) estimate?: number;
  @Field({ nullable: true }) dueDate?: Date;
  @Field(() => [String], { nullable: true }) dependencies?: string[];
  @Field({ nullable: true }) subPlanId?: string;
  @Field({ nullable: true }) linksGithubIssue?: string;
  @Field({ nullable: true }) linksGithubPR?: string;
  @Field() createdAt!: Date;
  @Field() updatedAt!: Date;
}

@ObjectType()
export class Step {
  @Field(() => ID) id!: string;
  @Field() title!: string;
  @Field({ nullable: true }) description?: string;
  @Field(() => StepStatus) status!: StepStatus;
  @Field({ nullable: true }) assignee?: string;
  @Field({ nullable: true }) estimate?: number;
  @Field({ nullable: true }) dueDate?: Date;
  @Field(() => [String], { nullable: true }) dependencies?: string[];
  @Field() createdAt!: Date;
  @Field() updatedAt!: Date;
}

@ObjectType()
export class Plan {
  @Field(() => ID) id!: string;
  @Field() title!: string;
  @Field(() => PlanMethodology) methodology!: PlanMethodology;
  @Field(() => PlanCategory) category!: PlanCategory;
  @Field({ nullable: true }) project?: string;
  @Field({ nullable: true }) activity?: string;
  @Field(() => PlanStatus) status!: PlanStatus;
  @Field({ nullable: true }) objective?: string;
  @Field(() => [Task]) tasks!: Task[];
  @Field(() => [Task]) subPlans!: Task[];
  @Field() createdAt!: Date;
  @Field() updatedAt!: Date;
}

@ObjectType()
export class DagResult {
  @Field() isValid!: boolean;
  @Field({ nullable: true }) message?: string;
  @Field(() => [String]) topologicalOrder!: string[];
}

@ObjectType()
export class ExecutionPlan {
  @Field() totalTasks!: number;
  @Field({ nullable: true }) estimatedDuration?: number;
  @Field(() => [String], { nullable: true }) criticalPath?: string[];
}

@ObjectType()
export class CompileResult {
  @Field(() => ID) planId!: string;
  @Field(() => [Task]) tasks!: Task[];
  @Field(() => DagResult) dag!: DagResult;
  @Field(() => ExecutionPlan) executionPlan!: ExecutionPlan;
}

@ObjectType()
export class ExecuteResult {
  @Field(() => ID) planId!: string;
  @Field() executionId!: string;
  @Field() status!: string;
  @Field() tasksEnqueued!: number;
  @Field({ nullable: true }) estimatedCompletion?: Date;
  @Field(() => [DryRunResult], { nullable: true }) dryRunResults?: DryRunResult[];
}

@ObjectType()
export class DryRunResult {
  @Field() taskId!: string;
  @Field() action!: string;
  @Field() estimatedDuration!: number;
  @Field(() => [String]) dependencies!: string[];
}
