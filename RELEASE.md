# Release 0.1.0 (MVP)

## Scope (Planned)
- Monorepo skeleton with UI/API/Scheduler/Workers/AI
- GitHub & Cursor integrations (stubs)
- DB scripts (init/migrate/reset), CI check for i18n

## Features Developed & Merged ✅
- [x] AI directives consolidated (PR: boot/ai-directives, commit: fe22598)
- [x] Makefile architecture Docker-first (PR: feat/makefile-architecture, commit: 4a00567)
- [x] API GraphQL schema Plan/Task/Step (PR: feat/api-graphql-schema, commit: 192a012)
- [x] Scheduler: compile Plan → DAG and enqueue jobs (PR: feat/scheduler-plan-dag-execution, commit: 822235f)
- [x] Task Sub-Plans and Plan Categorization (PR: feat/task-subplans-plan-categorization, commit: pending)
- [x] Security Testing Strategy with Vulnerability Management (PR: feat/security-testing-strategy, commit: 0571404)
- [x] **Initial Stack Upgrade**: Alpine 3.22 + Python 3.13 + Node.js 24 + Vitest 3.x + Vite 7.x + NestJS 11.x (PR: feat/stack-upgrade-initial, commit: 13385c9)
- [x] **Makefile SLOC Metrics**: Project size analysis with cloc integration (PR: feat/makefile-sloc-metrics, commit: 8a80143)
  - **New commands**: `metrics.sloc`, `metrics.sloc.api`, `metrics.sloc.services`
  - **Features**: Automatic cloc installation, service breakdown, config file exclusions
  - **Current metrics**: 8,293 total SLOC, 1,492 TypeScript, 5,617 configuration
  - **Architecture**: Maintains Docker-first approach, cross-platform support

## Features In Progress 🔄
- [ ] Workers: job "sync:github" (issues + Projects v2) scaffold
- [ ] UI: SvelteKit layout with /en and /fr, i18n switching
- [ ] Scripts: db:init db:migrate db:reset (packages/scripts)
- [ ] Test strategy: .mdc + Make commands + GitHub Actions
- [ ] **Dockerfile Hardening**: Add non-root USER directives to all Dockerfiles

## Consolidation Completed ✅
- [x] Architecture directives consolidated (MASTER.mdc)
- [x] Workflow + conventions + maintenance (workflow.mdc)
- [x] Testing strategy + E2E + implementation (testing.mdc)
- [x] Architecture + UI + language policy (architecture.mdc)
- [x] Guide validation consistent (validate_guides.sh)
- [x] Security testing strategy + vulnerability management (security.mdc)

## Progress
- **Features developed & merged** : 5/8 (62.5%)
- **Features in progress** : 3/8 (37.5%)
- **System consolidation** : 6/6 (100%)
- **Ready for release** : ❌ (features not complete)

## Checklist
- [ ] All planned features completed and merged
- [ ] Smoke tests green (API/UI)
- [ ] DB migrations applied locally
- [ ] Release notes updated
- [ ] ⚠ approval for final tag

## Risks / Rollback
- Schema still evolving → `make db.reset` available
- Cursor: first login to Web Agents is manual
- **Major risk**: Only 37.5% of planned features are actually developed

## Update Guidelines for RELEASE.md

### Adding Validated Feature
- ✅ Feature completed + PR merged
- ✅ **VERIFY**: Check Git commit history with `git log --oneline --grep="feat:"`
- ✅ Add to "Features Developed & Merged" with PR reference AND commit hash
- ✅ Verify consistency with scope

### Adding Consolidation
- ✅ Consolidation completed + tests passing
- ✅ Add to "Consolidation" with details
- ✅ Verify global consistency

### Updating Scope
- ✅ New feature planned
- ✅ Add to "Scope" with priority
- ✅ Update checklist accordingly

### Update Workflow
1. **Feature development** → Update TODO.md and RELEASE.md BEFORE merge
2. **Feature merged** → Verify commit hash and PR reference are correct
3. **Consolidation done** → Update "Consolidation"  
4. **Scope changes** → Update "Scope" and "Checklist"
5. **Before release** → Verify all planned features are developed and merged
6. **After release** → Archive current, create next version

### Git Verification Commands
```bash
# Check recent feature commits
git log --oneline --since="1 month ago" | grep -E "(feat|fix|boot)"

# Verify specific feature
git show --name-only <commit-hash>

# Check all feature commits
git log --oneline --all | grep -E "(feat|fix|boot)"

# Verify PR merge commits
git log --oneline --grep="Merge pull request"
```
