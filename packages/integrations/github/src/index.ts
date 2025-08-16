import fetch from 'node-fetch';

const token = process.env.GITHUB_TOKEN || '';
const owner = process.env.GITHUB_OWNER || '';
const repo = process.env.GITHUB_REPO || '';

export async function createIssue({ title, body, labels = [] }: { title: string; body?: string; labels?: string[] }) {
  if (!token || !owner || !repo) {
    console.warn('Missing GITHUB_TOKEN/OWNER/REPO; skipping createIssue');
    return;
  }
  const res = await fetch(`https://api.github.com/repos/${owner}/${repo}/issues`, {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${token}`,
      'Accept': 'application/vnd.github+json',
      'X-GitHub-Api-Version': '2022-11-28',
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({ title, body: body ?? '', labels })
  });
  if (!res.ok) {
    const t = await res.text();
    throw new Error(`GitHub createIssue failed: ${res.status} ${t}`);
  }
  const data = await res.json();
  console.log('Issue created:', data.html_url);
  return data;
}
