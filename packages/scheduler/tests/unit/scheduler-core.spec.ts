import { describe, it, expect } from 'vitest'

describe('Scheduler-API Integration', () => {
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

  it('should validate basic DAG operations', async () => {
    // Test basic DAG validation functionality
    const { validateDag } = await import('../../src/index')
    
    const validTasks = [
      { id: 'A' },
      { id: 'B', dependencies: ['A'] }
    ]
    
    const result = validateDag(validTasks)
    expect(result.ok).toBe(true)
  })
})
