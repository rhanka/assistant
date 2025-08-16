import { syncIssue, openAgents } from './jobs/index.js';

// Mock external dependencies
jest.mock('./jobs/syncGithub.js', () => ({
  syncIssue: jest.fn()
}));

jest.mock('./jobs/cursorOpenAgents.js', () => ({
  openAgents: jest.fn()
}));

describe('Workers', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  describe('GitHub Sync', () => {
    it('should sync GitHub issues', async () => {
      const mockSyncIssue = require('./jobs/syncGithub.js').syncIssue;
      mockSyncIssue.mockResolvedValue({ success: true, issueId: '123' });

      const result = await syncIssue({ title: 'Test Task' });
      
      expect(mockSyncIssue).toHaveBeenCalledWith({ title: 'Test Task' });
      expect(result).toEqual({ success: true, issueId: '123' });
    });

    it('should handle GitHub sync errors gracefully', async () => {
      const mockSyncIssue = require('./jobs/syncGithub.js').syncIssue;
      mockSyncIssue.mockRejectedValue(new Error('GitHub API error'));

      await expect(syncIssue({ title: 'Test Task' })).rejects.toThrow('GitHub API error');
    });
  });

  describe('Cursor Agents', () => {
    it('should open Cursor agents in dry-run mode', async () => {
      const mockOpenAgents = require('./jobs/cursorOpenAgents.js').openAgents;
      mockOpenAgents.mockResolvedValue({ success: true, agentsOpened: 2 });

      const result = await openAgents({ dryRun: true });
      
      expect(mockOpenAgents).toHaveBeenCalledWith({ dryRun: true });
      expect(result).toEqual({ success: true, agentsOpened: 2 });
    });

    it('should respect dry-run flag', async () => {
      const mockOpenAgents = require('./jobs/cursorOpenAgents.js').openAgents;
      mockOpenAgents.mockResolvedValue({ success: true, dryRun: true });

      await openAgents({ dryRun: true });
      
      expect(mockOpenAgents).toHaveBeenCalledWith({ dryRun: true });
    });
  });
});
