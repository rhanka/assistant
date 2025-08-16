import { register, init, getLocaleFromNavigator } from 'svelte-i18n';

register('en', () => import('./en/common.json'));
register('fr', () => import('./fr/common.json'));

export async function setupI18n(locale?: string) {
  const initial = locale || getLocaleFromNavigator() || 'en';
  await init({
    fallbackLocale: 'en',
    initialLocale: initial.split('-')[0] === 'fr' ? 'fr' : 'en'
  });
}
