import { Field, InputType } from '@nestjs/graphql';

@InputType()
export class CompilePlanInput {
  @Field()
  planId!: string;
}
