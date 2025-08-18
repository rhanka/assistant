# Feature: Security Testing Strategy (Snyk/Trivy + CI build gating)

## Objective
Introduce a coherent, minimal-impact security testing strategy leveraging Snyk and Trivy, with dependency vulnerability gating at Docker build time, reusable images in CI, and parallelized security/unit flows.

## Plan / Todo
- [ ] Design acceptance (this document)
- [ ] Update rules (.mdc)
  - [x] Align `security.mdc` with CI pipeline (deps gating in Dockerfiles, Snyk/Trivy scans, categories) — succinct CI, refers to `testing.mdc`
  - [x] Align `testing.mdc` with updated CI dependencies/order, DAG, frameworks, and targets naming
- [ ] Makefile targets (no breaking changes)
  - [ ] Build targets per service with image tagging `build.<service>` and `build.all`
  - [ ] Push targets per service `push.<service>` and `push.all` (GHCR)
  - [ ] Adapt `up` to optionally depend on build (e.g., `UP_REQUIRES_BUILD=true make up`) except for dev-only services (e.g., Svelte dev)
    - [ ] Security scan targets:
    - [ ] `test.security.scan.deps.<service>` (Trivy SCA on manifests; runs after `build.<service>`)
    - [ ] `test.security.scan.code` (Semgrep SAST on source code)
    - [ ] `test.security.scan.iac` (Trivy on compose/k8s)
    - [ ] `test.security.container.<service>` / `.all` (Trivy on built images)
    - [ ] Aggregates: `test.security`, `test.security.scan`, `test.security.container`
- [ ] Dockerfiles (minimal)
  - [ ] Node services: add `npm audit --audit-level=high` in base and production stages
  - [ ] AI (Python): evaluate `pip-audit --strict`; if not feasible now, document Snyk-only
- [ ] GitHub Actions (`.github/workflows/ci.yml`)
  - [ ] Add build job (matrix over services) → tag/push images to GHCR
  - [ ] Unit jobs: `needs: build-images` (tests logic unchanged)
  - [ ] Security jobs (matrix): Semgrep SAST + Trivy SCA/IaC/Container (parallel)
  - [ ] Integration jobs: depend on relevant unit jobs (unchanged semantics)
- [ ] Docs and validation
  - [ ] Update README snippets if needed
  - [ ] Run `make check` and fix guide consistency

## Commits & Progress
- [x] docs(rules): align testing & security MDC with CI DAG and add BRANCH plan
- [x] build(make): add build/push targets (`build.<svc>`, `push.<svc>`, `.all`) — no behavior change
- [x] build(make): improve GHCR config with env vars (GHCR_OWNER, GHCR_PROJECT, GHCR_REGISTRY)
- [x] build(make): add security targets — `test.security.scan.*`, `test.security.container.*`
- [x] build(security): implement SAST scanning (Semgrep on source code) - 0664279
- [x] build(security): implement SCA scanning (Trivy on manifests/dependencies) - cb211d4
- [x] build(security): implement IaC scanning (Trivy on docker-compose.yml and k8s/) - f85e0ed
- [x] build(security): implement container scanning (Trivy on built images) - fae9a87
- [x] build(docker-api): gate deps with `npm audit --audit-level=high` (base + prod)
- [x] build(docker-ui): gate deps with `npm audit --audit-level=high` (base + prod)
- [x] build(docker-workers): gate deps with `npm audit --audit-level=high` (base + prod)
- [x] build(docker-scheduler): gate deps with `npm audit --audit-level=high` (base + prod)
- [x] build(docker-ai): add `pip-audit --strict` or defer (document reliance on Snyk)
- [x] **Commit 11** (0a5fa71): Fix AI Dockerfile - update FastAPI to 0.116.0 to fix starlette vulnerabilities
- [x] ci(build-api): add build-api job with production target and artifacts - fa6beff
- [x] ci(unit-api): remove dependency on build-api (runs in parallel) - 24156ff
- [x] makefile: remove GHCR tagging and push targets (cleanup) - 11b222a
- [x] makefile: add save/load targets for API service - 32e1b2a
- [x] makefile: update build.api to target production - fa6beff
- [x] ci(build-scheduler): add build-scheduler job with production target and artifacts - b665103
- [x] makefile: add save/load targets for scheduler service - b665103
- [x] makefile: update build.scheduler to target production - b665103
- [x] docs(security): add security test exit criteria to security.mdc - [current commit]
- [x] ci(build-workers): add build-workers job with production target and artifacts
- [ ] ci(build-ui): add build-ui job with production target and artifacts
- [ ] ci(build-ai): add build-ai job with production target and artifacts
- [ ] ci(unit): update unit test dependencies (no logic change inside tests)
  - [ ] ci(unit-api): remove dependency on build-api (runs in parallel)
  - [ ] ci(unit-scheduler): add dependency on build-scheduler
  - [ ] ci(unit-workers): add dependency on build-workers
  - [ ] ci(unit-ui): add dependency on build-ui
  - [ ] ci(unit-ai): add dependency on build-ai
- [ ] ci(security): add security scan jobs per service (parallel with unit tests)
  - [ ] ci(security-api): add security job for API (SAST + SCA + Container)
  - [ ] ci(security-scheduler): add security job for Scheduler (SAST + SCA + Container)
  - [ ] ci(security-workers): add security job for Workers (SAST + SCA + Container)
  - [ ] ci(security-ui): add security job for UI (SAST + SCA + Container)
  - [ ] ci(security-ai): add security job for AI (SAST + SCA + Container)
  - [ ] ci(security-global): add global security job (IaC scanning only)
- [ ] ci(integration): ensure DAG explicit (depends on corresponding unit jobs)
  - [ ] ci(integration-scheduler-api): update to depend on test-scheduler-unit + test-api-unit
  - [ ] ci(integration-scheduler-workers): update to depend on test-scheduler-unit + test-workers-unit + test-api-unit
  - [ ] ci(integration-workers-api): update to depend on test-workers-unit + test-api-unit
  - [ ] ci(integration-ui-api): update to depend on test-ui-unit + test-api-unit
  - [ ] ci(integration-scheduler-ai): update to depend on test-scheduler-unit + test-ai-unit
  - [ ] ci(integration-workers-ai): update to depend on test-workers-unit + test-ai-unit
- [ ] makefile: add save/load targets for all services
  - [ ] makefile(save-scheduler): add save.scheduler target
  - [x] makefile(save-workers): add save.workers target
  - [ ] makefile(save-ui): add save.ui target
  - [ ] makefile(save-ai): add save.ai target
  - [ ] makefile(load-scheduler): add load.scheduler target
  - [x] makefile(load-workers): add load.workers target
  - [ ] makefile(load-ui): add load.ui target
  - [ ] makefile(load-ai): add load.ai target
- [ ] makefile: update build targets to target production for all services
  - [ ] makefile(build-scheduler): update build.scheduler to target production
  - [x] makefile(build-workers): update build.workers to target production
  - [ ] makefile(build-ui): update build.ui to target production
  - [ ] makefile(build-ai): update build.ai to target production
- [ ] docs(readme): reflect new build/push/security commands
- [ ] ci: run `make check` and fix guide consistency

## Status
- Progress: 28/45 tasks completed
- Current: Workers service CI workflow implemented and working with artifacts
- Next: Implement CI build jobs for remaining services (ui, ai)
