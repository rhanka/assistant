import { openAgentsPage } from '@repo/integrations-cursor';

export async function openAgents({ dryRun = true }: { dryRun?: boolean }) {
  if (dryRun) {
    console.log('[dry-run] Would open Cursor Agents page.');
    return;
  }
  await openAgentsPage();
}
