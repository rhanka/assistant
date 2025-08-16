<script lang="ts">
  import { t } from 'svelte-i18n';
  export let data: { lang: 'en' | 'fr' };
  const other = data.lang === 'en' ? 'fr' : 'en';
</script>

<nav style="display:flex; gap:1rem; padding:1rem; border-bottom:1px solid #eee;">
  <a href="/{data.lang}/">{ $t('nav.home') }</a>
  <a href="/{data.lang}/plans">{ $t('nav.plans') }</a>
  <a href="/{data.lang}/runs">{ $t('nav.runs') }</a>
  <div style="margin-left:auto;">
    <a href="/{other}/">{ $t('lang.switch') }</a>
  </div>
</nav>
<slot />
