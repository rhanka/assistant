export type PlanMethodology = 'agile-scrum'|'kanban'|'waterfall'|'hybrid';
export type TaskType = 'epic'|'story'|'task'|'bug'|'spike'|'chore';

export interface Step {
  id: string;
  action: string;
  params?: Record<string, unknown>;
  approvalRequired?: boolean;
}

export interface Task {
  id: string;
  title: string;
  type?: TaskType;
  status?: 'todo'|'in-progress'|'blocked'|'review'|'done'|'cancelled';
  assignee?: string;
  labels?: string[];
  estimate?: number;
  dueDate?: string;
  dependencies?: string[];
  steps?: Step[];
}

export interface Plan {
  id: string;
  title: string;
  objective?: string;
  owner?: string;
  methodology: PlanMethodology;
  status?: 'draft'|'in-progress'|'blocked'|'completed'|'cancelled';
  constraints?: Record<string, unknown>;
  customFields?: Record<string, unknown>;
  tasks: Task[];
}

export function validateDag(tasks: Task[]): { ok: boolean; message?: string } {
  const graph: Record<string, string[]> = {};
  for (const t of tasks) graph[t.id] = (t.dependencies ?? []).slice();
  const visiting = new Set<string>();
  const visited = new Set<string>();
  function dfs(n: string): boolean {
    if (visiting.has(n)) return false;
    if (visited.has(n)) return true;
    visiting.add(n);
    for (const m of graph[n] ?? []) {
      if (!dfs(m)) return false;
    }
    visiting.delete(n);
    visited.add(n);
    return true;
  }
  for (const t of tasks) {
    if (!dfs(t.id)) return { ok: false, message: `Cycle detected at ${t.id}` };
  }
  return { ok: true };
}
