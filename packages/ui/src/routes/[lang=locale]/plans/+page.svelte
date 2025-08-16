<script lang="ts">
  import { t } from 'svelte-i18n';
  export let data: { lang: 'en' | 'fr' };
  
  let plans = [
    { id: '1', title: 'Sample Plan', status: 'active', taskCount: 3 }
  ];
  
  let newPlanTitle = '';
  
  function createPlan() {
    if (newPlanTitle.trim()) {
      plans = [...plans, {
        id: Date.now().toString(),
        title: newPlanTitle,
        status: 'draft',
        taskCount: 0
      }];
      newPlanTitle = '';
    }
  }
</script>

<div style="padding: 1rem;">
  <h1>{ $t('plans.title') }</h1>
  
  <div style="margin-bottom: 2rem;">
    <h3>{ $t('plans.create') }</h3>
    <div style="display: flex; gap: 1rem; align-items: center;">
      <input 
        type="text" 
        bind:value={newPlanTitle}
        placeholder={ $t('plans.titlePlaceholder') }
        style="flex: 1; padding: 0.5rem; border: 1px solid #ccc; border-radius: 4px;"
      />
      <button 
        on:click={createPlan}
        style="padding: 0.5rem 1rem; background: #007bff; color: white; border: none; border-radius: 4px; cursor: pointer;"
      >
        { $t('plans.createButton') }
      </button>
    </div>
  </div>
  
  <div>
    <h3>{ $t('plans.list') }</h3>
    {#each plans as plan}
      <div style="border: 1px solid #eee; padding: 1rem; margin-bottom: 1rem; border-radius: 4px;">
        <h4>{plan.title}</h4>
        <p>{ $t('plans.status') }: {plan.status}</p>
        <p>{ $t('plans.tasks') }: {plan.taskCount}</p>
      </div>
    {/each}
  </div>
</div>
