# TODO (Now / Next / Later)

Note: Always read `.cursor/rules/MASTER.mdc` first, then `README.md`, then this file

## Now
- [x] AI directives : ensure that all .md and .mdc enable a proper development lifecycle (PR: boot/ai-directives)
- [x] Makefile: apply architecture (e.g dev in docker, python or npm run or npx for db migration must be in docker if local or kube if in production env) (PR: feat/makefile-architecture)
- [x] API: GraphQL schema (Plan/Task/Step) + REST /health + OpenAPI (PR: feat/api-graphql-schema)
- [x] Test: Write down test strategy in .mdc; implement test in Make then GitHub Actions
- [x] Scheduler: compile Plan → DAG and enqueue jobs (PR: feat/scheduler-plan-dag-execution)
- [x] Enable Task to be themselves (Sub)-Plans and Plan to be categorized by Project or Activity (PR: feat/task-subplans-plan-categorization)
- [x] Makefile: add an option and instruction to enable interactive/non-interactive switch (db.init, logs.*, etc) (PR: feat/makefile-interactive-switch)
- [ ] Add security in testing strategy : updates .mdc files - include partial or full scope coverage (e.g no critical or high vulnerability unless contextual usage is logged and has a further mitigation in Now or Next)
- [ ] **Dockerfile Hardening**: Add non-root USER directives to all Dockerfiles
- [ ] Makefile: add an option to trace SLOC of project based on `cloc --not-match-f='package.*json|tsconfig.json' .`
- [ ] Workers: job "sync:github" (issues + Projects v2) scaffold
- [ ] UI: SvelteKit layout with /en and /fr, i18n switching
- [ ] Scripts: db:init db:migrate db:reset (packages/scripts)

## Next
- [ ] AI: FastAPI stub /summarize
- [ ] UI: Add views to chat interactively with a Plan or Task or Project/Activity (instruct a new Plan etc) and a view to have status of Projects/Activity with their Plan and Sub-Plan and Task (hierarchically)
- [ ] Add (in packages/integrations) a Chrome plugin to interact with tabs and UI/API
- [ ] Add (in packages/integrations) a Cursor AI plugin to take control remote on Cursor AI chat on an existing Cursor AI session on a laptop and interact through UI/API

## Later
- [ ] Data import (CSV/JSON) for Plans/Tasks

## Note on Status
**IMPORTANT**: Only features with merged PRs are marked as [x]. 
Features marked as [ ] are planned but not yet developed.
Check Git history with `git log --oneline --grep="feat:"` to verify actual development status.

## Update Guidelines for TODO.md

### Marking Feature as Complete [x]
- ✅ **REQUIRED**: Feature must have merged PR with conventional commit
- ✅ **VERIFY**: Check Git history with `git log --oneline --grep="feat:"`
- ✅ **FORMAT**: `[x] Description (PR: type/name)`
- ✅ **REFERENCE**: Include PR reference for traceability

### Adding New Feature to Now
- ✅ **SCOPE**: Feature aligns with current release scope
- ✅ **PRIORITY**: Feature is next logical step
- ✅ **FORMAT**: `[ ] Description (planned)`
- ✅ **MOVE**: Move from Next/Later when starting development

### Moving Features Between Sections
- **Now → Next**: Feature started but not yet complete
- **Next → Now**: Feature development beginning
- **Later → Next**: Feature prioritized for next iteration
- **Now → Complete**: Feature merged and verified

### Update Workflow
1. **Feature started** → Move from Next/Later to Now
2. **Before merge** → Update TODO.md and RELEASE.md with feature status
3. **Feature merged** → Verify PR reference and commit hash are correct
4. **New feature planned** → Add to appropriate section
5. **Before commit** → Verify status reflects Git reality

### Git Verification Commands
```bash
# Check recent feature commits
git log --oneline --since="1 month ago" | grep -E "(feat|fix|boot)"

# Verify specific feature status
git log --oneline --grep="feat:"

# Check PR merge commits
git log --oneline --grep="Merge pull request"

# Verify feature files changed
git show --name-only <commit-hash>
```

### Quality Gates
- **Before marking [x]**: PR must be merged and feature must work
- **Before adding to Now**: Feature must be actively developed
- **Before moving sections**: Verify current status in Git
- **Consistency check**: Run `make check` to validate guides
