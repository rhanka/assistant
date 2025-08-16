import fs from 'node:fs';
import path from 'node:path';

function loadJSON(p: string) {
  return JSON.parse(fs.readFileSync(p, 'utf8'));
}

function findI18nKeys(content: string): string[] {
  const regex = /\$t\(['"`]([^'"`]+)['"`]\)/g;
  const keys: string[] = [];
  let match;
  
  while ((match = regex.exec(content)) !== null) {
    keys.push(match[1]);
  }
  
  return keys;
}

function scanSvelteFiles(dir: string): string[] {
  const keys: string[] = [];
  
  function scan(currentDir: string) {
    const files = fs.readdirSync(currentDir);
    
    for (const file of files) {
      const fullPath = path.join(currentDir, file);
      const stat = fs.statSync(fullPath);
      
      if (stat.isDirectory()) {
        scan(fullPath);
      } else if (file.endsWith('.svelte')) {
        const content = fs.readFileSync(fullPath, 'utf8');
        keys.push(...findI18nKeys(content));
      }
    }
  }
  
  scan(dir);
  return keys;
}

const base = path.resolve(process.cwd(), '../../packages/ui/src');
const en = loadJSON(path.join(base, 'lib/i18n/en/common.json'));
const fr = loadJSON(path.join(base, 'fr/common.json'));

const definedKeys = new Set(Object.keys(en));
const usedKeys = new Set(scanSvelteFiles(base));

const unusedKeys = [...definedKeys].filter(k => !usedKeys.has(k));
const missingKeys = [...usedKeys].filter(k => !definedKeys.has(k));

console.log('i18n Coverage Check:');
console.log(`- Defined keys: ${definedKeys.size}`);
console.log(`- Used keys: ${usedKeys.size}`);

if (unusedKeys.length) {
  console.warn(`- Unused keys: ${unusedKeys.join(', ')}`);
}

if (missingKeys.length) {
  console.error(`- Missing keys: ${missingKeys.join(', ')}`);
  process.exit(1);
}

if (unusedKeys.length === 0 && missingKeys.length === 0) {
  console.log('✅ All i18n keys are properly used');
} else if (unusedKeys.length > 0 && missingKeys.length === 0) {
  console.log('⚠️  Some keys are unused but all used keys are defined');
} else {
  console.log('❌ i18n coverage issues found');
}
