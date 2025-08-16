import { createIssue } from '@repo/integrations-github';

export async function syncIssue(params: { title: string; body?: string }) {
  const title = params.title;
  const body = params.body ?? 'Created by workers sync';
  await createIssue({ title, body, labels: ['assistant'] });
}
