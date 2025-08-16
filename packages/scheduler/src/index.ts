import { Queue } from 'bullmq';

export type TaskNode = { id: string; dependencies?: string[] };
export type Plan = { id: string; title: string; tasks: TaskNode[] };

export function validateDag(tasks: TaskNode[]): { ok: boolean; message?: string } {
  const graph: Record<string, string[]> = {};
  tasks.forEach(t => graph[t.id] = [...(t.dependencies || [])]);
  const visiting = new Set<string>();
  const visited = new Set<string>();
  function dfs(n: string): boolean {
    if (visiting.has(n)) return false;
    if (visited.has(n)) return true;
    visiting.add(n);
    for (const m of graph[n] || []) if (!dfs(m)) return false;
    visiting.delete(n);
    visited.add(n);
    return true;
  }
  for (const t of tasks) if (!dfs(t.id)) return { ok: false, message: `Cycle at ${t.id}` };
  return { ok: true };
}

export function topoOrder(tasks: TaskNode[]): string[] {
  const indeg: Record<string, number> = {};
  const adj: Record<string, string[]> = {};
  for (const t of tasks) {
    indeg[t.id] = indeg[t.id] ?? 0;
    for (const d of (t.dependencies || [])) {
      adj[d] = adj[d] || [];
      adj[d].push(t.id);
      indeg[t.id] = (indeg[t.id] ?? 0) + 1;
    }
  }
  const q = Object.keys(indeg).filter(k => indeg[k] === 0);
  const order: string[] = [];
  while (q.length) {
    const n = q.shift()!;
    order.push(n);
    for (const m of (adj[n] || [])) {
      indeg[m] -= 1;
      if (indeg[m] === 0) q.push(m);
    }
  }
  if (order.length !== Object.keys(indeg).length) throw new Error('Cycle detected');
  return order;
}

export async function enqueuePlan(plan: Plan, queueName = 'jobs-sync-github', redisUrl = process.env.REDIS_URL || 'redis://localhost:6379') {
  const queue = new Queue(queueName, { connection: { url: redisUrl } });
  const order = topoOrder(plan.tasks);
  for (const id of order) {
    await queue.add('run-task', { planId: plan.id, taskId: id }, { removeOnComplete: 100, removeOnFail: 500 });
  }
  await queue.close();
}
