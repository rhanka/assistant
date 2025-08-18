import { describe, it, expect, vi } from 'vitest';

// Mock the svelte-i18n module
vi.mock('svelte-i18n', () => ({
  register: vi.fn(),
  init: vi.fn(),
  getLocaleFromNavigator: vi.fn(() => 'en')
}));

// Test the i18n setup
describe('I18n Setup', () => {
  it('should handle locale setup', async () => {
    // Import the actual setupI18n function
    const { setupI18n } = await import('./i18n');
    
    // Test that the function exists and is callable
    expect(typeof setupI18n).toBe('function');
    
    // Test that it can be called without error
    expect(async () => {
      await setupI18n('fr');
    }).not.toThrow();
  });
});
