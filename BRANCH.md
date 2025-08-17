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
    - [ ] `test.security.scan.deps.<service>` (Snyk manifests; runs after `build.<service>`)
    - [ ] `test.security.scan.code` (Snyk Code)
    - [ ] `test.security.scan.iac` (Snyk IaC on compose/k8s)
    - [ ] `test.security.container.snyk.<service>` / `.all`
    - [ ] `test.security.container.trivy.<service>` / `.all`
  - [ ] Aggregates: `test.security`, `test.security.scan`, `test.security.container`
- [ ] Dockerfiles (minimal)
  - [ ] Node services: add `npm audit --audit-level=high` in base and production stages
  - [ ] AI (Python): evaluate `pip-audit --strict`; if not feasible now, document Snyk-only
- [ ] GitHub Actions (`.github/workflows/ci.yml`)
  - [ ] Add build job (matrix over services) → tag/push images to GHCR
  - [ ] Unit jobs: `needs: build-images` (tests logic unchanged)
  - [ ] Security jobs (matrix): Snyk Code/Deps/IaC + Snyk Container + Trivy (parallel)
  - [ ] Integration jobs: depend on relevant unit jobs (unchanged semantics)
- [ ] Docs and validation
  - [ ] Update README snippets if needed
  - [ ] Run `make check` and fix guide consistency

## Commits & Progress
- [x] docs(rules): align testing & security MDC with CI DAG and add BRANCH plan
- [x] build(make): add build/push targets (`build.<svc>`, `push.<svc>`, `.all`) — no behavior change
- [x] build(make): improve GHCR config with env vars (GHCR_OWNER, GHCR_PROJECT, GHCR_REGISTRY)
- [ ] build(make): add security targets (naming only) — `test.security.scan.*`, `test.security.container.*`
- [ ] build(docker-api): gate deps with `npm audit --audit-level=high` (base + prod)
- [ ] build(docker-ui): gate deps with `npm audit --audit-level=high` (base + prod)
- [ ] build(docker-workers): gate deps with `npm audit --audit-level=high` (base + prod)
- [ ] build(docker-scheduler): gate deps with `npm audit --audit-level=high` (base + prod)
- [ ] build(docker-ai): add `pip-audit --strict` or defer (document reliance on Snyk)
- [ ] ci(build): add build-images job (matrix), tag/push to GHCR
- [ ] ci(unit): add `needs: build-images` (no logic change inside tests)
- [ ] ci(security): add Snyk (code/deps/iac/container) + Trivy image jobs (parallel)
- [ ] ci(integration): ensure DAG explicit (depends on corresponding unit jobs)
- [ ] docs(readme): reflect new build/push/security commands
- [ ] ci: run `make check` and fix guide consistency

## Status
- Progress: 3/15 tasks completed
- Current: Build/push targets implemented and working with env vars
- Next: Add security targets (naming only), then implement Dockerfile dependency gating
