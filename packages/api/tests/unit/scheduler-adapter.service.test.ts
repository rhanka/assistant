import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest';

// Test des fonctions utilitaires du scheduler
describe('Scheduler Utility Functions', () => {
  // Copier les fonctions du service pour les tester directement
  function validateDag(tasks: any[]): { ok: boolean; message?: string } {
    const visited = new Set<string>();
    const recStack = new Set<string>();
    
    function hasCycle(node: string): boolean {
      if (recStack.has(node)) return true;
      if (visited.has(node)) return false;
      
      visited.add(node);
      recStack.add(node);
      
      const task = tasks.find(t => t.id === node);
      if (task && task.dependencies) {
        for (const dep of task.dependencies) {
          if (hasCycle(dep)) return true;
        }
      }
      
      recStack.delete(node);
      return false;
    }
    
    for (const task of tasks) {
      if (hasCycle(task.id)) {
        return { ok: false, message: `Cycle detected involving task ${task.id}` };
      }
    }
    
    return { ok: true };
  }
  
  function topoOrder(tasks: any[]): string[] {
    const visited = new Set<string>();
    const order: string[] = [];
    
    function visit(node: string) {
      if (visited.has(node)) return;
      visited.add(node);
      
      const task = tasks.find(t => t.id === node);
      if (task && task.dependencies) {
        for (const dep of task.dependencies) {
          visit(dep);
        }
      }
      
      order.push(node);
    }
    
    for (const task of tasks) {
      visit(task.id);
    }
    
    return order;
  }

  describe('validateDag', () => {
    it('should validate a valid DAG', () => {
      const tasks = [
        { id: 'task-1', dependencies: [] },
        { id: 'task-2', dependencies: ['task-1'] },
        { id: 'task-3', dependencies: ['task-2'] }
      ];
      
      const result = validateDag(tasks);
      expect(result.ok).toBe(true);
    });

    it('should detect cycles in DAG', () => {
      const tasks = [
        { id: 'task-1', dependencies: ['task-2'] },
        { id: 'task-2', dependencies: ['task-1'] }
      ];
      
      const result = validateDag(tasks);
      expect(result.ok).toBe(false);
      expect(result.message).toContain('Cycle');
    });

    it('should handle empty task list', () => {
      const result = validateDag([]);
      expect(result.ok).toBe(true);
    });
  });

  describe('topoOrder', () => {
    it('should return correct topological order', () => {
      const tasks = [
        { id: 'task-1', dependencies: [] },
        { id: 'task-2', dependencies: ['task-1'] },
        { id: 'task-3', dependencies: ['task-2'] }
      ];
      
      const order = topoOrder(tasks);
      expect(order).toEqual(['task-1', 'task-2', 'task-3']);
    });

    it('should handle tasks with no dependencies', () => {
      const tasks = [
        { id: 'task-1', dependencies: [] },
        { id: 'task-2', dependencies: [] }
      ];
      
      const order = topoOrder(tasks);
      expect(order).toContain('task-1');
      expect(order).toContain('task-2');
    });

    it('should handle empty task list', () => {
      const order = topoOrder([]);
      expect(order).toEqual([]);
    });
  });
});
