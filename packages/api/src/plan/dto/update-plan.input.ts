import { InputType, Field, PartialType } from '@nestjs/graphql';
import { CreatePlanInput } from './create-plan.input.js';

@InputType()
export class UpdatePlanInput extends PartialType(CreatePlanInput) {}
