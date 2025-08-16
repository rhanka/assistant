import { InputType, Field, PartialType } from '@nestjs/graphql';
import { CreateStepInput } from './create-step.input.js';

@InputType()
export class UpdateStepInput extends PartialType(CreateStepInput) {
  @Field({ nullable: true }) taskId?: string;
}
