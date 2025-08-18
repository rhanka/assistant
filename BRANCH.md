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
- [ ] ci(build): add build-images job (matrix), tag/push to GHCR
- [ ] ci(unit): add `needs: build-images` (no logic change inside tests)
- [ ] ci(security): add Snyk (code/deps/iac/container) + Trivy image jobs (parallel)
- [ ] ci(integration): ensure DAG explicit (depends on corresponding unit jobs)
- [ ] docs(readme): reflect new build/push/security commands
- [ ] ci: run `make check` and fix guide consistency

## Status
- Progress: 15/22 tasks completed
- Current: All Dockerfiles now have dependency vulnerability gating implemented and working
- Next: Implement CI build-images job and update GitHub Actions workflow
