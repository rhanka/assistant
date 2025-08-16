import fs from 'node:fs';
import path from 'node:path';

function loadJSON(p: string) {
  return JSON.parse(fs.readFileSync(p, 'utf8'));
}
const base = path.resolve(process.cwd(), '../../packages/ui/src/lib/i18n');
const en = loadJSON(path.join(base, 'en', 'common.json'));
const fr = loadJSON(path.join(base, 'fr', 'common.json'));

const enKeys = new Set(Object.keys(en));
const frKeys = new Set(Object.keys(fr));
const missingInFr = [...enKeys].filter(k => !frKeys.has(k));
const missingInEn = [...frKeys].filter(k => !enKeys.has(k));

if (missingInFr.length || missingInEn.length) {
  console.error('i18n key mismatch:');
  if (missingInFr.length) console.error('- Missing in fr:', missingInFr.join(', '));
  if (missingInEn.length) console.error('- Missing in en:', missingInEn.join(', '));
  process.exit(1);
} else {
  console.log('i18n keys OK (en == fr)');
}
