import { Worker, Queue } from 'bullmq';
import { syncIssue } from './jobs/syncGithub.js';
import { openAgents } from './jobs/cursorOpenAgents.js';

const redisUrl = process.env.REDIS_URL || 'redis://localhost:6379';

// Queue to produce demo jobs locally
const queue = new Queue('jobs:sync-github', { connection: { url: redisUrl } });

new Worker('jobs:sync-github', async (job) => {
  if (job.name === 'run-task') {
    // Example: sync an issue per task (idempotent)
    await syncIssue({ title: `Task ${job.data.taskId} from plan ${job.data.planId}` });
  } else if (job.name === 'cursor:open') {
    await openAgents({ dryRun: true });
  }
}, { connection: { url: redisUrl } });

console.log('Workers running. Queues: jobs:sync-github');
