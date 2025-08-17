# Feature: Test Strategy Implementation

## Objective
Implement comprehensive testing strategy with make commands, unit tests, E2E tests, and CI integration to ensure all testing goes through the Makefile (Docker-first approach).

## Plan / Todo
- [x] Consolidate AI directives into core .mdc files
- [x] Add testing infrastructure configurations (Jest, pytest, Playwright)
- [x] Implement unit tests for core services (scheduler, workers, API, AI)
- [x] Add UI pages and E2E tests (plans, runs)
- [x] Update Makefile and CI with test commands
- [x] Update documentation and package dependencies
- [x] Add BRANCH.md validation to prevent merge with branch files
- [x] Remove root package.json (everything must be driven by make)
- [x] Complete Docker-first architecture and test infrastructure
- [x] Implement optimized CI strategy (path-based testing + P2P)
- [x] Fix CI workflows to match testing strategy (remove obsolete ci.yml, fix ci-global, add P2P)
- [x] Complete P2P integration workflows (workers-api, ui-api, scheduler-workers)
- [x] Consolidate all CI workflows into single ci.yml with conditional jobs and dependencies
- [x] Fix context access issues and commit CI consolidation
- [x] Update testing strategy documentation
- [x] Commit documentation updates
- [x] Add push trigger support to CI workflow for testing validation
- [x] Fix CI workflow linter errors and commit fixes
- [x] Add .github/workflows/ci.yml to all job conditions
- [x] Fix test-ui-api conflict between Vitest and Playwright
- [x] Add test:integration script to scheduler package
- [x] Fix test-scheduler-api (Script `test:integration` ajouté mais test échoue encore)
- [x] Fix test-scheduler-workers (Script `test.integration.scheduler-workers-api` manquant dans Makefile)
- [x] Fix test-scheduler-ai (Script `test.integration.ai` manquant dans scheduler package)
- [x] Fix test-workers-ai (Script `test:integration:ai` manquant dans workers package)
- [ ] Fix test-workers-api (Dépendant des tests scheduler, échoue à cause des échecs précédents)

## Commits & Progress
- [x] **Commit 1** (4ac4bfb): Consolidate AI directives into core .mdc files
- [x] **Commit 2** (9c98adf): Add testing infrastructure configurations
- [x] **Commit 3** (273fbc7): Implement unit tests for core services
- [x] **Commit 4** (2e8a329): Add UI pages and E2E tests
- [x] **Commit 5** (24dfec3): Update Makefile and CI with test commands
- [x] **Commit 6** (1f0206f): Update documentation and package dependencies
- [x] **Commit 7** (0c01c66): Add BRANCH.md validation to prevent merge with branch files
- [x] **Commit 8** (3998943): Enforce make-first architecture and clean node_modules
- [x] **Commit 9** (e966e38): Move tsconfig.base.json to packages/config for Docker-first architecture
- [x] **Commit 10** (ce75764): Complete Docker-first architecture and test infrastructure
- [x] **Commit 11** (48f2bc0): Fix test-ui-api conflict between Vitest and Playwright
- [x] **Commit 12** (11d57fc): Add test:integration script to scheduler package
- [x] **Commit 13** (72f37ab): Fix test-scheduler-api configuration issues
- [x] **Commit 14** (bd5569c): Fix test-scheduler-workers missing script and tests
- [x] **Commit 15** (c34e090): Fix test-scheduler-ai missing script and integration tests
- [x] **Commit 16** (33ea20b): Fix test-workers-ai migration to Vitest and integration tests

## Status
- **Progress**: 21/22 tasks completed (95%)
- **Current**: test-workers-ai script ajouté, 5 tests d'intégration passent
- **Next**: Fix test-workers-api (Dépendant des tests scheduler)

## Notes
- All commits follow atomic commit guidelines (max 10-15 files per commit)
- Testing infrastructure is in place and working locally
- Make commands are defined and tested locally
- Documentation is updated to reflect current state
- test-ui-api now passes with separate Dockerfile for E2E tests
- test-scheduler-api script added and working in CI
- test-scheduler-workers script added and working locally (4 tests pass)
- test-scheduler-ai script added and working locally (5 tests pass)
- test-workers-ai script added and working locally (5 tests pass)

## Remaining Tests to Fix (Based on CI Failures)
1. **test-workers-api** : Dépendant des tests scheduler, échoue à cause des échecs précédents

## Next Steps
1. **Fix test-workers-api** : Ensure it works after all scheduler tests pass
2. **Validate all tests** : Ensure all tests pass in CI
