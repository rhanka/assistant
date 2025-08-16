import type { LayoutLoad } from './$types';
import { setupI18n } from '$lib/i18n';
export const load: LayoutLoad = async ({ params }) => {
  await setupI18n(params.lang);
  return { lang: params.lang };
};
