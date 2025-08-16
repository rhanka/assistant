import { Field, InputType } from '@nestjs/graphql';
import { TaskType, TaskStatus } from '../plan.model.js';

@InputType()
export class CreateTaskInput {
  @Field() planId!: string;
  @Field() title!: string;
  @Field(() => TaskType, { nullable: true }) type?: TaskType;
  @Field({ nullable: true }) assignee?: string;
  @Field(() => [String], { nullable: true }) labels?: string[];
  @Field({ nullable: true }) estimate?: number;
  @Field({ nullable: true }) dueDate?: Date;
  @Field(() => [String], { nullable: true }) dependencies?: string[];
}
