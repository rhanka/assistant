import { Field, InputType } from '@nestjs/graphql';

@InputType()
export class ExecutePlanInput {
  @Field()
  planId!: string;
  
  @Field({ defaultValue: true })
  dryRun!: boolean;
}
