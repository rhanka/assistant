# API Service Technical Debt

## Backend Stack (packages/api)
| Component | Current | Latest | EOL | Breaking Change | Priority | Notes |
|-----------|---------|--------|-----|-----------------|----------|-------|
| nestjs | 11.1.6 | 11.1.6 | no | no | none | ✅ Current version is latest - migration completed |
| prisma | 6.0.0 | 6.14.0 | no | no | 1w | Minor version updates available |
| bullmq | 5.7.0 | 5.58.0 | no | no | 1w | Minor version updates available |
| graphql | 16.11.0 | 16.11.0 | no | no | none | Current version is latest |
| apollo-server | 4.12.2 | 5.0.0 | no | **YES** | 1m | ⚠️ Major version update blocked - @nestjs/apollo v13.0.0 not compatible |
| vitest | 3.2.4 | 3.2.4 | no | no | none | ✅ Current version is latest - migration completed |
| rxjs | 7.8.1 | 7.8.1 | no | no | none | Current version is latest |

## Base Images
| Component | Current | Latest | EOL | Breaking Change | Priority | Notes |
|-----------|---------|--------|-----|-----------------|----------|-------|
| node | 24.6.0 | 24.6.0 | no | no | none | LTS version |
| alpine | 3.22.1 | 3.22.1 | no | no | none | ✅ Current version is latest - migration completed |

---

**Priority Levels**: 1d (critical), 1w (high), 1m (medium), 1y (low/deprecated)  
**EOL**: End of Life - version no longer supported

## ⚠️ Breaking Changes Identified
- **NestJS**: ✅ 10.0.0 → 11.1.6 (Completed - tested and working)
- **Apollo Server**: ⚠️ 4.12.2 → 5.0.0 (BLOCKED - @nestjs/apollo compatibility issue)
- **Vitest**: ✅ 1.0.0 → 3.2.4 (Completed - tested and working)

## 🔍 Breaking Change Assessment Required
Before updating these components:
1. **Apollo Server 5.x**: Wait for @nestjs/apollo v13+ compatibility or downgrade strategy
2. **FastAPI updates**: Review for breaking changes in API endpoints and middleware
3. **Test thoroughly**: Run all API tests after major version updates
4. **Update incrementally**: Consider updating one major component at a time

**Last Security Audit**: `make test.security.sca-api` (automatic)  
**Last Version Audit**: 2024-12-19 (manual) - ✅ NestJS 11.1.6 + Vitest 3.2.4 migrations completed  
**Next Version Audit**: 2024-12-26 (manual)

## Audit Commands
```bash
# API-specific component audit
make audit.components.api

# API-specific security audit
make test.security.sca-api
```
