import { Field, ID, ObjectType, registerEnumType } from '@nestjs/graphql';

export enum PlanMethodology { AGILE_SCRUM='AGILE_SCRUM', KANBAN='KANBAN', WATERFALL='WATERFALL', HYBRID='HYBRID' }
export enum PlanStatus { DRAFT='DRAFT', IN_PROGRESS='IN_PROGRESS', BLOCKED='BLOCKED', COMPLETED='COMPLETED', CANCELLED='CANCELLED' }
export enum TaskType { EPIC='EPIC', STORY='STORY', TASK='TASK', BUG='BUG', SPIKE='SPIKE', CHORE='CHORE' }
export enum TaskStatus { TODO='TODO', IN_PROGRESS='IN_PROGRESS', BLOCKED='BLOCKED', REVIEW='REVIEW', DONE='DONE', CANCELLED='CANCELLED' }

registerEnumType(PlanMethodology, { name: 'PlanMethodology' });
registerEnumType(PlanStatus, { name: 'PlanStatus' });
registerEnumType(TaskType, { name: 'TaskType' });
registerEnumType(TaskStatus, { name: 'TaskStatus' });

@ObjectType()
export class Task {
  @Field(() => ID) id!: string;
  @Field() title!: string;
  @Field(() => TaskType, { nullable: true }) type?: TaskType;
  @Field(() => TaskStatus) status!: TaskStatus;
  @Field({ nullable: true }) assignee?: string;
}

@ObjectType()
export class Plan {
  @Field(() => ID) id!: string;
  @Field() title!: string;
  @Field(() => PlanMethodology) methodology!: PlanMethodology;
  @Field(() => PlanStatus) status!: PlanStatus;
  @Field({ nullable: true }) objective?: string;
  @Field(() => [Task]) tasks!: Task[];
}
