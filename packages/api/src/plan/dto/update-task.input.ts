import { InputType, Field, Float } from '@nestjs/graphql';
import { TaskType, TaskStatus } from '../plan.model.js';

@InputType()
export class UpdateTaskInput {
  @Field({ nullable: true }) title?: string;
  @Field({ nullable: true }) planId?: string;
  @Field(() => TaskType, { nullable: true }) type?: TaskType;
  @Field(() => TaskStatus, { nullable: true }) status?: TaskStatus;
  @Field({ nullable: true }) assignee?: string;
  @Field(() => [String], { nullable: true }) labels?: string[];
  @Field(() => Float, { nullable: true }) estimate?: number;
  @Field({ nullable: true }) dueDate?: Date;
  @Field(() => [String], { nullable: true }) dependencies?: string[];
  @Field({ nullable: true }) subPlanId?: string;
  @Field({ nullable: true }) linksGithubIssue?: string;
  @Field({ nullable: true }) linksGithubPR?: string;
}
