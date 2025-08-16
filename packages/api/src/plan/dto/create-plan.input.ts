import { InputType, Field } from '@nestjs/graphql';
import { PlanMethodology } from '../plan.model.js';

@InputType()
export class CreatePlanInput {
  @Field() title!: string;
  @Field(() => PlanMethodology) methodology!: PlanMethodology;
  @Field({ nullable: true }) objective?: string;
}
