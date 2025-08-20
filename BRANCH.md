# Feature: Security Testing Strategy (Unified Security + Vulnerability Management)

## Objective
Implement a comprehensive, unified security testing strategy with intelligent parsing, vulnerability management, and robust error handling. The system includes SAST (Semgrep), SCA (Trivy), Container (Trivy), and IaC (Trivy) scans with structured output parsing and compliance checking against an accepted vulnerability register.

## Plan / Todo
- [x] Design acceptance (this document)
- [x] Update rules (.mdc)
  - [x] Align `security.mdc` with CI pipeline (deps gating in Dockerfiles, Snyk/Trivy scans, categories) — succinct CI, refers to `testing.mdc`
  - [x] Align `testing.mdc` with updated CI dependencies/order, DAG, frameworks, and targets naming
- [x] Makefile targets (no breaking changes)
  - [x] Build targets per service with image tagging `build.<service>` and `build.all`
  - [x] Push targets per service `push.<service>` and `push.all` (GHCR)
  - [x] Adapt `up` to optionally depend on build (e.g., `UP_REQUIRES_BUILD=true make up`) except for dev-only services (e.g., Svelte dev)
    - [x] Security scan targets:
    - [x] `test.security.sast.<service>` (Semgrep SAST on source code)
    - [x] `test.security.sca.<service>` (Trivy SCA on manifests; runs after `build.<service>`)
    - [x] `test.security.iac-infra` (Trivy on compose/k8s)
    - [x] `test.security.container.<service>` / `.all` (Trivy on built images)
    - [x] Aggregates: `test.security`, `test.security.sast`, `test.security.sca`, `test.security.container`, `test.security.iac`
- [x] Dockerfiles (minimal)
  - [x] Node services: add `npm audit --audit-level=high` in base and production stages
  - [x] AI (Python): evaluate `pip-audit --strict`; if not feasible now, document Snyk-only
- [x] GitHub Actions (`.github/workflows/ci.yml`)
  - [x] Add build job (matrix over services) → tag/push images to GHCR
  - [x] Unit jobs: `needs: build-images` (tests logic unchanged)
  - [x] Security jobs (matrix): Semgrep SAST + Trivy SCA/IaC/Container (parallel)
  - [x] Integration jobs: depend on relevant unit jobs (unchanged semantics)
- [x] Docs and validation
  - [x] Update README snippets if needed
  - [x] Run `make check` and fix guide consistency
- [ ] **Node.js Alpine Migration**: Migrate TypeScript services to Alpine-based images
  - [x] Migrate Dockerfiles to `node:24-alpine3.22`
  - [x] Update Make procedures for `package-lock.json` management
  - [x] Validate builds and security scans
  - [ ] Hardening: Add non-root USER directives to Dockerfiles
  - [ ] Update vulnerability register after hardening

## Commits & Progress
- [x] docs(rules): align testing & security MDC with CI DAG and add BRANCH plan - 184aefe
- [x] build(make): add build/push targets (`build.<svc>`, `push.<svc>`, `.all`) — no behavior change - 9ca533c
- [x] build(make): improve GHCR config with env vars (GHCR_OWNER, GHCR_PROJECT, GHCR_REGISTRY) - 9ca533c
- [x] build(make): add security targets — `test.security.scan.*`, `test.security.container.*` - 4fd18f8
- [x] build(security): implement SAST scanning (Semgrep on source code) - 0664279
- [x] build(security): implement SCA scanning (Trivy on manifests/dependencies) - 699d151
- [x] build(security): implement IaC scanning (Trivy on docker-compose.yml and k8s/) - f85e0ed
- [x] build(security): implement container scanning (Trivy on built images) - fae9a87
- [x] build(docker-api): gate deps with `npm audit --audit-level=high` (base + prod) - ad1d05d
- [x] build(docker-ui): gate deps with `npm audit --audit-level=high` (base + prod) - ad1d05d
- [x] build(docker-workers): gate deps with `npm audit --audit-level=high` (base + prod) - ad1d05d
- [x] build(docker-scheduler): gate deps with `npm audit --audit-level=high` (base + prod) - ad1d05d
- [x] build(docker-ai): add `pip-audit --strict` or defer (document reliance on Snyk) - ad1d05d
- [x] fix(docker-ai): update FastAPI to 0.116.0 to fix starlette vulnerabilities - 83da66f
- [x] ci(build-api): add build-api job with production target and artifacts - cd76946
- [x] ci(unit-api): remove dependency on build-api (runs in parallel) - cd76946
- [x] makefile: remove GHCR tagging and push targets (cleanup) - 11b222a
- [x] makefile: add save/load targets for API service - 32e1b2a
- [x] makefile: update build.api to target production - cd76946
- [x] ci(build-scheduler): add build-scheduler job with production target and artifacts - b665103
- [x] makefile: add save/load targets for scheduler service - b665103
- [x] makefile: update build.scheduler to target production - b665103
- [x] docs(security): add security test exit criteria to security.mdc - 8729dad
- [x] ci(build-workers): add build-workers job with production target and artifacts - 70cb91e
- [x] ci(build-ui): add build-ui job with production target and artifacts - 0f95f37
- [x] ci(build-ai): add build-ai job with production target and artifacts - 9be7f91
- [x] ci(unit): update unit test dependencies (no logic change inside tests)
  - [x] ci(unit-api): remove dependency on build-api (runs in parallel) - cd76946
  - [x] ci(unit-scheduler): remove dependency on build-scheduler (runs in parallel) - b665103
  - [x] ci(unit-workers): remove dependency on build-workers (runs in parallel) - 70cb91e
  - [x] ci(unit-ui): remove dependency on build-ui (runs in parallel) - 0f95f37
  - [x] ci(unit-ai): add dependency on build-ai (uses same image) - 9be7f91
- [x] test(unit): fix unit test regression - ensure tests use correct Docker targets
  - [x] test(unit-scheduler): fix test.unit.scheduler to use Dockerfile test target - b665103
  - [x] test(unit-api): fix test.unit.api to use Dockerfile test target - cd76946
  - [x] test(unit-ui): fix test.unit.ui to use Dockerfile test target - 0f95f37
  - [x] test(unit-workers): fix test.unit.workers to use Dockerfile test target - 70cb91e
  - [x] test(unit-ai): test.unit.ai already correct (uses docker compose) - 9be7f91
- [x] test(api-harmonization): harmonize API test structure with other services - c088476
  - [x] test(api-structure): create tests/unit/ and tests/integration/ directories - c088476
  - [x] test(api-move): move tests from src/ to dedicated directories - c088476
  - [x] test(api-config): remove vitest.config.ts (use default config) - c088476
  - [x] test(api-dockerfile): update Dockerfile to copy tests/ directory - c088476
  - [x] test(api-package): add test:integration script to package.json - c088476
  - [x] test(api-p2p): create P2P integration tests for API ↔ Scheduler and API ↔ Workers - c088476
- [x] ci(security): add security scan jobs per service (parallel with unit tests) - 965ca7e
  - [x] ci(security-api): add security job for API (SAST + SCA + Container) - 965ca7e
  - [x] ci(security-scheduler): add security job for Scheduler (SAST + SCA + Container) - 965ca7e
  - [x] ci(security-workers): add security job for Workers (SAST + SCA + Container) - 965ca7e
  - [x] ci(security-ui): add security job for UI (SAST + SCA + Container) - 965ca7e
  - [x] ci(security-ai): add security job for AI (SAST + SCA + Container) - 965ca7e
  - [x] ci(security-global): add global security job (IaC scanning only) - 965ca7e
- [x] ci(integration): ensure DAG explicit (depends on corresponding unit jobs) - 965ca7e
  - [x] ci(integration-scheduler-api): update to depend on test-scheduler-unit + test-api-unit - 965ca7e
  - [x] ci(integration-scheduler-workers): update to depend on test-scheduler-unit + test-workers-unit + test-api-unit - 965ca7e
  - [x] ci(integration-workers-api): update to depend on test-workers-unit + test-api-unit - 965ca7e
  - [x] ci(integration-ui-api): update to depend on test-ui-unit + test-api-unit - 965ca7e
  - [x] ci(integration-scheduler-ai): update to depend on test-scheduler-unit + test-ai-unit - 965ca7e
  - [x] ci(integration-workers-ai): update to depend on test-workers-unit + test-ai-unit - 965ca7e
- [x] ci(integration): fix service deployment strategy for integration tests - eb0b321
  - [x] ci(integration): replace `make up` with `make up.<service>` to start required services - eb0b321
  - [x] ci(integration): ensure services are running before executing integration tests - eb0b321
- [x] docs(integration): clarify integration test strategy (mock vs real services) - 55d7114
- [x] test(reclassify): move mock tests from integration to unit directories - 08f55d6
  - [x] test(reclassify-scheduler): move scheduler mock tests to unit - 08f55d6
  - [x] test(reclassify-workers): move workers mock tests to unit - 08f55d6
- [x] test(scripts): add missing integration test scripts to package.json
  - [x] test(scripts-api): add test:integration to API package.json - c088476
  - [x] test(scripts-ui): add test:integration to UI package.json - 0f95f37
- [x] make(integration): update Make targets to use up.<service>/down.<service>
  - [x] make(integration): update all integration test targets - eb0b321
- [x] test(integration): implement real P2P integration tests
  - [x] test(integration-scheduler-api): real scheduler-API communication - 08f55d6
  - [x] test(integration-scheduler-workers): real scheduler-workers-API flow - 08f55d6
  - [x] test(integration-workers-api): real workers-API communication - 08f55d6
  - [x] test(integration-ui-api): real UI-API communication - 0f95f37
  - [x] test(integration-scheduler-ai): real scheduler-AI communication - 9be7f91
  - [x] test(integration-workers-ai): real workers-AI communication - 9be7f91
- [x] makefile: add save/load targets for all services
  - [x] makefile(save-scheduler): add save.scheduler target - b665103
  - [x] makefile(save-workers): add save.workers target - 70cb91e
  - [x] makefile(save-ui): add save.ui target - 0f95f37
  - [x] makefile(save-ai): add save.ai target - 9be7f91
  - [x] makefile(load-scheduler): add load.scheduler target - b665103
  - [x] makefile(load-workers): add load.workers target - 70cb91e
  - [x] makefile(load-ui): add load.ui target - 0f95f37
  - [x] makefile(load-ai): add load.ai target - 9be7f91
- [x] makefile: update build targets to target production for all services
  - [x] makefile(build-scheduler): update build.scheduler to target production - b665103
  - [x] makefile(build-workers): update build.workers to target production - 70cb91e
  - [x] makefile(build-ui): update build.ui to target production - 0f95f37
  - [x] makefile(build.ai): update build.ai to target production - 9be7f91
- [x] docs(readme): reflect new build/push/security commands
- [x] ci: run `make check` and fix guide consistency
- [x] **Commit b42eda6**: feat: implement unified security testing strategy with vulnerability management
- [x] **Commit 864c31d**: feat: migration vers Node.js 24 Alpine et hardening des Dockerfiles

## Security Testing Strategy Implementation
- [x] **Unified Security Testing Target**: Implement `test.security.%` with intelligent parsing - b42eda6
  - [x] Single wildcard target that parses `$*` into `SCAN_TYPE` and `SERVICE`
  - [x] Supports SAST, SCA, Container, and IaC scan types
  - [x] Automatic directory creation (`.security/`)
  - [x] Robust error handling with `|| exit 1`
- [x] **Security Parser Script**: Implement `security-parser.sh` - b42eda6
  - [x] Parses Semgrep JSON output into structured YAML
  - [x] Extracts CVE, CWE, OWASP categories
  - [x] Generates unique IDs with full file path slugs
  - [x] Includes code context (3 lines before/after)
- [x] **Security Compliance Script**: Implement `security-compliance.sh` - b42eda6
  - [x] Checks parsed findings against `vulnerability-register.yaml`
  - [x] Prevents PR blocking for accepted vulnerabilities
  - [x] Ensures traceability of security debt
- [x] **Vulnerability Management**: Create structured vulnerability register - b42eda6
  - [x] YAML-based register with categories (false_positive, accepted_risk, planned_mitigation, technical_debt)
  - [x] Unique IDs for each finding
  - [x] Full file paths and line numbers
  - [x] Risk assessment and fix goals
- [x] **CI Security Jobs**: Split security jobs for optimal performance - b42eda6
  - [x] `security-code-<service>`: SAST + SCA + IaC (parallel, no build dependency)
  - [x] `security-container-<service>`: Container scans (after build dependency)
  - [x] `security-ai`: Unified approach (SAST + SCA + Container, depends on build)
  - [x] `security-iac`: Global infrastructure scanning
- [x] **Security Tools Installation**: Add `install.security.tools` Make target - b42eda6
  - [x] Installs `jq` and `yq` if not present
  - [x] Integrated in all CI security jobs
  - [x] Ensures tools availability before scans

## Node.js Alpine Migration Implementation
- [x] **Dockerfile Migration**: Update all TypeScript services to `node:24-alpine3.22` - 864c31d
  - [x] API service: Migrated to Alpine, build successful, security scans pass
  - [x] Workers service: Migrated to Alpine, build successful, security scans pass
  - [x] Scheduler service: Migrated to Alpine, build successful, security scans pass
  - [x] UI service: Migrated to Alpine, build successful, security scans pass
- [x] **Package Lock Management**: Fix Make procedures for `package-lock.json` updates - 864c31d
  - [x] Update `update.*.lock` targets to use `node:24-alpine3.22`
  - [x] Validate all services can update dependencies via Docker
- [x] **Vulnerability Register**: Update with SAST findings for Dockerfile hardening - 864c31d
  - [x] Document 15 SAST findings (missing USER directives) in vulnerability register
  - [x] All findings categorized as `planned_mitigation` with 1w timeline
  - [x] Compliance checking operational for all security scans
- [x] **Directives Update**: Enhance .mdc files for vulnerability register lifecycle - 864c31d
  - [x] Update `workflow.mdc` with vulnerability register maintenance procedures
  - [x] Update `security.mdc` with vulnerability register management rules
  - [x] Document post-mitigation cleanup and maintenance workflows

## Next Steps
- [x] **Integration Test Fix**: Resolve scheduler-api integration test failures - 243a74d
  - [x] Upgrade Prisma to 6.14.0 for better Alpine compatibility
  - [x] Fix Dockerfile Alpine compatibility by removing problematic PRISMA env vars
  - [x] Fix scheduler Dockerfile test stage to include devDependencies
  - [x] Update Makefile to properly start services for integration tests
  - [x] All integration tests now pass: scheduler-api, scheduler-workers, workers-api
- [ ] **Dockerfile Hardening**: Add non-root USER directives to all Dockerfiles
  - [ ] API Dockerfile: Add USER node directives for test and production stages
  - [ ] Workers Dockerfile: Add USER node directives for test, production, and default stages
  - [ ] Scheduler Dockerfile: Add USER node directives for test, production, and default stages
  - [ ] UI Dockerfile: Add USER node directives for test, production, and development stages
- [ ] **Vulnerability Register Update**: Remove resolved findings after hardening
  - [ ] Update vulnerability register metadata (last_updated timestamp)
  - [ ] Remove all USER-related findings altready successfully mitigated
  - [ ] Verify all security scans pass after hardening
- [ ] **Final Validation**: Ensure complete security compliance
  - [ ] Run all security scans to confirm no new findings
  - [ ] Validate CI pipeline passes with hardened Dockerfiles
  - [ ] Update documentation to reflect completed hardening

## Status
- **Progress**: 59/63 tasks completed
- **Current**: Integration tests fixed, Dockerfile hardening pending
- **Next**: Implement Dockerfile hardening, then final validation and merge

## Key Achievements for the Branch

### Security Testing Strategy Foundation
- ✅ **Unified Security Testing**: Implemented `test.security.%` with intelligent parsing and robust error handling
- ✅ **Comprehensive Coverage**: SAST (Semgrep), SCA (Trivy), Container (Trivy), and IaC (Trivy) scans operational
- ✅ **Vulnerability Management**: Structured YAML-based vulnerability register with compliance checking
- ✅ **CI Integration**: Security jobs split for optimal performance, integrated with GitHub Actions
- ✅ **Security Tools**: Automated installation of `jq` and `yq` for CI environments

### Infrastructure and Build System
- ✅ **Multi-stage Dockerfiles**: Production-optimized images with dependency gating (`npm audit --audit-level=high`)
- ✅ **Make Targets**: Unified build, security, and integration targets with proper dependencies
- ✅ **Package Management**: Docker-based dependency updates with `update.*.lock` procedures
- ✅ **Artifact Management**: Save/load targets for all services with production image targeting

### Testing and Integration
- ✅ **Unit Tests**: Harmonized test structure across all services with proper Docker targets
- ✅ **Integration Tests**: Real P2P communication tests between services (API ↔ Scheduler ↔ Workers ↔ UI)
- ✅ **Integration Test Fixes**: Resolved scheduler-api test failures with Prisma 6.14.0 upgrade
- ✅ **CI Pipeline**: Optimized DAG with parallel execution and proper job dependencies
- ✅ **Test Coverage**: Comprehensive coverage for API, Workers, Scheduler, UI, and AI services

### Node.js Alpine Migration
- ✅ **Base Image Security**: Migrated all TypeScript services from `node:20` (Debian) to `node:24-alpine3.22`
- ✅ **Vulnerability Elimination**: Eliminated HIGH/CRITICAL vulnerabilities from base images
- ✅ **Build Validation**: All services successfully build and pass security scans
- ✅ **Dependency Management**: Synchronized `package-lock.json` files across all services
- ✅ **Compliance Framework**: Operational vulnerability register with 15 documented findings

### Documentation and Governance
- ✅ **Security Rules**: Enhanced `.mdc` files with vulnerability register lifecycle management
- ✅ **Workflow Procedures**: Documented post-mitigation cleanup and maintenance workflows
- ✅ **Compliance Standards**: Established mandatory documentation and justification requirements
- ✅ **Risk Management**: Structured approach to vulnerability acceptance and mitigation planning

**Branch Status**: Ready for Dockerfile hardening phase, then final validation and merge! 🚀✨
