import { execSync } from 'node:child_process';
import fs from 'node:fs';

try {
  const log = execSync('git log --pretty=format:"%s" $(git describe --tags --abbrev=0)..HEAD').toString();
  const lines = log.split('\n').filter(Boolean);
  const notes = ['# Changelog (since last tag)', ''];
  for (const l of lines) notes.push('- ' + l);
  fs.writeFileSync('CHANGELOG.generated.md', notes.join('\n'));
  console.log('CHANGELOG.generated.md written');
} catch (e) {
  console.warn('Could not prepare release notes:', e.message || e);
}
