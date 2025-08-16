import { InputType, Field, Float } from '@nestjs/graphql';
import { StepStatus } from '../plan.model.js';

@InputType()
export class CreateStepInput {
  @Field() title!: string;
  @Field() taskId!: string;
  @Field({ nullable: true }) description?: string;
  @Field(() => StepStatus, { nullable: true }) status?: StepStatus;
  @Field({ nullable: true }) assignee?: string;
  @Field(() => Float, { nullable: true }) estimate?: number;
  @Field({ nullable: true }) dueDate?: Date;
  @Field(() => [String], { nullable: true }) dependencies?: string[];
}
