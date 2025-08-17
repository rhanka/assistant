import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service.js';
import { Task, TaskType, TaskStatus, StepStatus } from './plan.model.js';

// Types internes du scheduler (évitent les conflits Prisma/GraphQL)
interface TaskNode {
  id: string;
  dependencies?: string[];
}

interface Plan {
  id: string;
  title: string;
  tasks: TaskNode[];
}

// Fonctions du scheduler
function validateDag(tasks: TaskNode[]): { ok: boolean; message?: string } {
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

function topoOrder(tasks: TaskNode[]): string[] {
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

async function enqueuePlan(plan: Plan, queueName = 'jobs-sync-github', redisUrl = process.env.REDIS_URL || 'redis://localhost:6379') {
  // TODO: Implémenter la vraie enqueue avec BullMQ
  // Pour l'instant, simulons l'enqueue
  console.log(`Enqueuing plan ${plan.id} with ${plan.tasks.length} tasks`);
  console.log(`Queue: ${queueName}, Redis: ${redisUrl}`);
  
  const order = topoOrder(plan.tasks);
  for (const id of order) {
    console.log(`Enqueuing task ${id} from plan ${plan.id}`);
  }
  
  return Promise.resolve();
}

@Injectable()
export class SchedulerAdapterService {
  constructor(private prisma: PrismaService) {}

  async compilePlan(planId: string) {
    // Récupérer le plan avec ses tâches depuis la base de données
    const plan = await this.prisma.plan.findUnique({
      where: { id: planId },
      include: { tasks: true }
    });

    if (!plan) {
      throw new Error(`Plan with id ${planId} not found`);
    }

    // Convertir les tâches au format attendu par le scheduler
    const tasks = plan.tasks.map(task => ({
      id: task.id,
      dependencies: task.dependencies || []
    }));

    // Valider le DAG
    const dagValidation = validateDag(tasks);
    
    // Calculer l'ordre topologique si le DAG est valide
    let topologicalOrder: string[] = [];
    if (dagValidation.ok) {
      try {
        topologicalOrder = topoOrder(tasks);
      } catch (error) {
        dagValidation.ok = false;
        dagValidation.message = `Topological ordering failed: ${error instanceof Error ? error.message : 'Unknown error'}`;
      }
    }

    // Calculer le plan d'exécution
    const executionPlan = {
      totalTasks: tasks.length,
      estimatedDuration: this.estimateDuration(plan.tasks),
      criticalPath: this.calculateCriticalPath(tasks, topologicalOrder)
    };

    // Convertir en types GraphQL
    const graphqlTasks: Task[] = plan.tasks.map(task => ({
      id: task.id,
      title: task.title,
      type: task.type as TaskType || undefined,
      status: task.status as TaskStatus,
      assignee: task.assignee || undefined,
      labels: task.labels || [],
      estimate: task.estimate || undefined,
      dueDate: task.dueDate || undefined,
      dependencies: task.dependencies || [],
      linksGithubIssue: task.linksGithubIssue || undefined,
      linksGithubPR: task.linksGithubPR || undefined,
      createdAt: task.createdAt,
      updatedAt: task.updatedAt
    }));

    return {
      planId: plan.id,
      tasks: graphqlTasks,
      dag: {
        isValid: dagValidation.ok,
        message: dagValidation.message,
        topologicalOrder
      },
      executionPlan
    };
  }

  async executePlan(planId: string, dryRun: boolean = true) {
    // Compiler le plan d'abord
    const compileResult = await this.compilePlan(planId);
    
    if (!compileResult.dag.isValid) {
      throw new Error(`Cannot execute invalid plan: ${compileResult.dag.message}`);
    }

    const executionId = `exec_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
    
    if (dryRun) {
      // Mode dry-run : simuler l'exécution sans enqueuer de vrais jobs
      const dryRunResults = compileResult.tasks.map(task => ({
        taskId: task.id,
        action: 'sync:github',
        estimatedDuration: this.estimateTaskDuration(task),
        dependencies: task.dependencies || []
      }));

      return {
        planId,
        executionId,
        status: 'dry-run',
        tasksEnqueued: 0,
        dryRunResults
      };
    } else {
      // Mode réel : enqueuer les jobs dans BullMQ
      try {
        await enqueuePlan({
          id: planId,
          title: compileResult.tasks[0]?.title || 'Unknown Plan',
          tasks: compileResult.tasks.map(t => ({ id: t.id, dependencies: t.dependencies || [] }))
        });

        return {
          planId,
          executionId,
          status: 'executing',
          tasksEnqueued: compileResult.tasks.length,
          estimatedCompletion: this.calculateEstimatedCompletion(compileResult.executionPlan.estimatedDuration || 0)
        };
      } catch (error) {
        throw new Error(`Failed to enqueue plan: ${error instanceof Error ? error.message : 'Unknown error'}`);
      }
    }
  }

  private estimateDuration(tasks: any[]): number {
    // Estimation simple basée sur les tâches avec estimate
    const tasksWithEstimate = tasks.filter(t => t.estimate);
    if (tasksWithEstimate.length === 0) return 0;
    
    return tasksWithEstimate.reduce((sum, task) => sum + (task.estimate || 0), 0);
  }

  private estimateTaskDuration(task: Task): number {
    // Estimation par défaut si pas d'estimate
    return task.estimate || 1; // 1 heure par défaut
  }

  private calculateCriticalPath(tasks: any[], topologicalOrder: string[]): string[] {
    // Calcul simple du chemin critique basé sur l'ordre topologique
    if (topologicalOrder.length === 0) return [];
    
    // Pour l'instant, retourner l'ordre topologique comme chemin critique
    // TODO: Implémenter un vrai calcul de chemin critique avec Floyd-Warshall
    return topologicalOrder;
  }

  private calculateEstimatedCompletion(estimatedDuration: number): Date {
    if (!estimatedDuration) return new Date(Date.now() + 24 * 60 * 60 * 1000); // +24h par défaut
    
    const completionTime = Date.now() + (estimatedDuration * 60 * 60 * 1000); // Convertir heures en millisecondes
    return new Date(completionTime);
  }
}
