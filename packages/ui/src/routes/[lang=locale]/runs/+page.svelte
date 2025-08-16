<script lang="ts">
  import { t } from 'svelte-i18n';
  export let data: { lang: 'en' | 'fr' };
  
  let runs = [
    { id: '1', planId: '1', status: 'running', progress: 60, taskCount: 3, completedTasks: 2 }
  ];
</script>

<div style="padding: 1rem;">
  <h1>{ $t('runs.title') }</h1>
  
  <div>
    <h3>{ $t('runs.active') }</h3>
    {#each runs as run}
      <div style="border: 1px solid #eee; padding: 1rem; margin-bottom: 1rem; border-radius: 4px;">
        <h4>{ $t('runs.run') } #{run.id}</h4>
        <p>{ $t('runs.plan') }: {run.planId}</p>
        <p>{ $t('runs.status') }: {run.status}</p>
        <p>{ $t('runs.progress') }: {run.progress}%</p>
        <p>{ $t('runs.tasks') }: {run.completedTasks}/{run.taskCount}</p>
        
        <div style="background: #f0f0f0; height: 20px; border-radius: 10px; overflow: hidden;">
          <div style="background: #007bff; height: 100%; width: {run.progress}%; transition: width 0.3s;"></div>
        </div>
      </div>
    {/each}
  </div>
</div>
