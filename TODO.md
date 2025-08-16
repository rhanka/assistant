# TODO (Now / Next / Later)

## Now
- [x] AI directives : ensure that all .md and .mdc enable a proper developpement lifecycle (PR: boot/ai-directives)
- [x] Makefile: apply architecture (e.g dev in docker, python or npm run or npx for db migration must be in docker if local or kube if in production env) (PR: feat/makefile-architecture)
- [x] API: GraphQL schema (Plan/Task/Step) + REST /health + OpenAPI (PR: feat/api-graphql-schema)
- [ ] Scheduler: compile Plan → DAG and enqueue jobs
- [ ] Workers: job "sync:github" (issues + Projects v2) scaffold
- [ ] UI: SvelteKit layout with /en and /fr, i18n switching
- [ ] Scripts: db:init db:migrate db:reset (packages/scripts)

## Next
- [ ] AI: FastAPI stub /summarize
- [ ] Cursor: Playwright helper to open Web Agents (dry-run)
- [ ] CI: GitHub Actions (build + i18n check)

## Later
- [ ] Data import (CSV/JSON) for Plans/Tasks
