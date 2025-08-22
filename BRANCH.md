# Feature: Stack Upgrade

## Objective
Perform initial stack upgrade for all services to latest stable versions, focusing on critical components with breaking changes assessment.

## Plan / Todo
- [x] **Alpine 3.22 & DB upgrades**: Update PostgreSQL and Redis to use Alpine 3.22 base images and upgrade to latest versions
- [x] **Vitest 3.x Migration**: Update all Node.js services from 1.0.0 to 3.2.4 (UI, API, Scheduler, Workers) - breaking changes assessment required
- [x] **Vite 7.x Migration**: Update UI service from 5.3.0 to 7.1.3 - build configuration and plugin compatibility to validate
- [x] **NestJS 11.x Migration**: Update API service from 10.0.0 to 11.1.6 - decorator and module changes to implement
- [x] **Docker add dev target**: Make working dev target
- [x] **Apollo Server 5.x Migration**: Update API service from 4.12.2 to 5.0.0 - GraphQL schema and resolver compatibility to validate
- [ ] **Python 3.13 Migration**: Update AI service from 3.11.13 to 3.13.7 - syntax and feature compatibility to validate
- [ ] **Tech-debt files update**: Update all .components/tech-debt-<service>.md files with new versions and breaking change assessments
- [ ] **Testing strategy completion**: Ensure all tests pass after upgrades (see testing.mdc requirements)
- [ ] **Github CI execution check**: Verify CI/CD pipeline works with new versions

## Notes
- The upgrade to Apollo Server v5 is currently blocked. The latest version of `@nestjs/apollo` (`v12.1.0`) is not yet compatible with Apollo Server v5 and causes runtime errors. This task will be revisited once the NestJS ecosystem officially supports it.

## Commits & Progress
- [x] **Commit 1** (be669f0): Task 1 completed.
- [ ] **Commit 2**: Task 2 in progress.

## Status
- **Progress**: 1/2 tasks completed
- **Current**: Completed Task 1
- **Next**: Documenting the Apollo v5 upgrade blocker.

## Current Status
✅ **Alpine 3.22 & DB upgrades**: Completed and pushed to PR #13
✅ **Vitest 3.x Migration**: All services completed and tested locally (UI, API, Scheduler, Workers)
✅ **Vite 7.x Migration**: UI completed and tested locally
✅ **NestJS 11.x Migration**: API completed and tested locally
✅ **Apollo Server 5.x Migration**: API completed and tested locally - **ISSUE RESOLVED**
✅ **Docker Architecture Restructuring**: All Dockerfiles restructured with dev/prod stages
✅ **Makefile Modernization**: All build/test targets updated to use docker compose + BUILD_TARGET
✅ **CI Workflow Updates**: CI modified to use BUILD_TARGET=prod for production builds
✅ **Security Targets**: All save/load/security targets properly configured and tested
🔄 **CI Status**: Ready for push and CI validation
⏳ **Next**: Python 3.13 Migration (AI service)

## Breaking Changes Assessment
- Vitest 3.x: Major breaking changes expected, requires test configuration updates
- Vite 7.x: Build configuration changes, plugin compatibility validation needed
- NestJS 11.x: Decorator and module changes, GraphQL schema updates required
- Apollo Server 5.x: GraphQL resolver compatibility, schema validation needed
- Python 3.13: Syntax changes, feature compatibility validation required

## Risk Assessment
- **High Risk**: Multiple major version upgrades simultaneously
- **Mitigation**: Upgrade one service at a time, comprehensive testing between each
- **Rollback Plan**: Keep previous versions in git history, use Docker tags for rollback
