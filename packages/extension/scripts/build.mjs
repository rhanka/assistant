import { execSync } from 'node:child_process';
import { mkdirSync, cpSync, rmSync } from 'node:fs';
import { resolve } from 'node:path';

const root = resolve(new URL('.', import.meta.url).pathname, '..');
const pkg = resolve(root);
const dist = resolve(pkg, 'dist');
rmSync(dist, { recursive: true, force: true });
mkdirSync(dist, { recursive: true });

// Compile TS -> JS (out next to sources; we'll copy only needed files)
execSync('npx tsc -p tsconfig.json', { stdio: 'inherit', cwd: pkg });

// Copy runtime assets
cpSync(resolve(pkg, 'manifest.json'), resolve(dist, 'manifest.json'));
cpSync(resolve(pkg, 'src', 'offscreen.html'), resolve(dist, 'offscreen.html'));
cpSync(resolve(pkg, 'src', 'manager.html'), resolve(dist, 'manager.html'));

// Copy compiled JS from src to dist (flat copy preserves names)
const files = ['sw.js', 'offscreen.js', 'manager.js', 'cs.js'];
for (const f of files) {
  cpSync(resolve(pkg, 'src', f), resolve(dist, f));
}

// Tip: Load the extension from the `packages/extension/dist/` directory.
