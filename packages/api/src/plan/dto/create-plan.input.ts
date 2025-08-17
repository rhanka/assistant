import { InputType, Field } from '@nestjs/graphql';
import { PlanMethodology, PlanCategory } from '../plan.model.js';

@InputType()
export class CreatePlanInput {
  @Field() title!: string;
  @Field(() => PlanMethodology) methodology!: PlanMethodology;
  @Field(() => PlanCategory) category!: PlanCategory;
  @Field({ nullable: true }) project?: string;
  @Field({ nullable: true }) activity?: string;
  @Field({ nullable: true }) objective?: string;
}
