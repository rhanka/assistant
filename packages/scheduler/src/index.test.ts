import { validateDag, topoOrder, enqueuePlan, Plan, TaskNode } from './index';

describe('Scheduler', () => {
  describe('validateDag', () => {
    it('should validate a valid DAG', () => {
      const tasks: TaskNode[] = [
        { id: 'A' },
        { id: 'B', dependencies: ['A'] },
        { id: 'C', dependencies: ['B'] }
      ];
      
      const result = validateDag(tasks);
      expect(result.ok).toBe(true);
    });

    it('should detect cycles in DAG', () => {
      const tasks: TaskNode[] = [
        { id: 'A', dependencies: ['C'] },
        { id: 'B', dependencies: ['A'] },
        { id: 'C', dependencies: ['B'] }
      ];
      
      const result = validateDag(tasks);
      expect(result.ok).toBe(false);
      expect(result.message).toContain('Cycle');
    });

    it('should handle empty dependencies', () => {
      const tasks: TaskNode[] = [
        { id: 'A' },
        { id: 'B' }
      ];
      
      const result = validateDag(tasks);
      expect(result.ok).toBe(true);
    });
  });

  describe('topoOrder', () => {
    it('should return correct topological order', () => {
      const tasks: TaskNode[] = [
        { id: 'A' },
        { id: 'B', dependencies: ['A'] },
        { id: 'C', dependencies: ['A'] },
        { id: 'D', dependencies: ['B', 'C'] }
      ];
      
      const order = topoOrder(tasks);
      expect(order).toEqual(['A', 'B', 'C', 'D']);
    });

    it('should throw error on cycle', () => {
      const tasks: TaskNode[] = [
        { id: 'A', dependencies: ['B'] },
        { id: 'B', dependencies: ['A'] }
      ];
      
      expect(() => topoOrder(tasks)).toThrow('Cycle detected');
    });
  });

  describe('enqueuePlan', () => {
    it('should enqueue tasks in correct order', async () => {
      const plan: Plan = {
        id: 'test-plan',
        title: 'Test Plan',
        tasks: [
          { id: 'A' },
          { id: 'B', dependencies: ['A'] },
          { id: 'C', dependencies: ['B'] }
        ]
      };

      // Mock Redis connection for testing
      const mockQueue = {
        add: jest.fn(),
        close: jest.fn()
      };

      // Mock BullMQ Queue constructor
      jest.doMock('bullmq', () => ({
        Queue: jest.fn().mockImplementation(() => mockQueue)
      }));

      await enqueuePlan(plan);
      
      expect(mockQueue.add).toHaveBeenCalledTimes(3);
      expect(mockQueue.close).toHaveBeenCalled();
    });
  });
});
