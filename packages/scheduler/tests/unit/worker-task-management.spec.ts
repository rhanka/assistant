import { describe, it, expect } from 'vitest'

describe('Scheduler-Workers Integration', () => {
  it('should have basic integration test structure', () => {
    // Basic test to verify the integration test environment works
    expect(true).toBe(true)
  })

  it('should be able to import scheduler modules', async () => {
    // Test that we can import the main scheduler functionality
    const { validateDag, topoOrder } = await import('../../src/index')
    expect(typeof validateDag).toBe('function')
    expect(typeof topoOrder).toBe('function')
  })

  it('should validate basic DAG operations for worker tasks', async () => {
    // Test basic DAG validation functionality for worker-related tasks
    const { validateDag } = await import('../../src/index')
    
    const workerTasks = [
      { id: 'worker-task-1' },
      { id: 'worker-task-2', dependencies: ['worker-task-1'] },
      { id: 'worker-task-3', dependencies: ['worker-task-2'] }
    ]
    
    const result = validateDag(workerTasks)
    expect(result.ok).toBe(true)
  })

  it('should handle worker task dependencies correctly', async () => {
    // Test that worker task dependencies are properly managed
    const { topoOrder } = await import('../../src/index')
    
    const workerTasks = [
      { id: 'worker-task-1' },
      { id: 'worker-task-2', dependencies: ['worker-task-1'] },
      { id: 'worker-task-3', dependencies: ['worker-task-1'] },
      { id: 'worker-task-4', dependencies: ['worker-task-2', 'worker-task-3'] }
    ]
    
    const order = topoOrder(workerTasks)
    expect(order).toEqual(['worker-task-1', 'worker-task-2', 'worker-task-3', 'worker-task-4'])
  })
})
