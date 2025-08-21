# Scheduler Service Technical Debt

## Backend Stack (packages/scheduler)
| Component | Current | Latest | EOL | Breaking Change | Priority | Notes |
|-----------|---------|--------|-----|-----------------|----------|-------|
| bullmq | 5.7.0 | 5.58.0 | no | no | 1w | Minor version updates available |
| typescript | 5.5.4 | 5.9.2 | no | no | 1w | Minor version updates available |
| vitest | 3.2.4 | 3.2.4 | no | no | none | ✅ Updated to latest stable version |
| @types/node | 20.14.10 | 20.14.10 | no | no | none | Current version is latest |

## Base Images
| Component | Current | Latest | EOL | Breaking Change | Priority | Notes |
|-----------|---------|--------|-----|-----------------|----------|-------|
| node | 24.6.0 | 24.6.0 | no | no | none | LTS version |
| alpine | 3.22.1 | 3.22.1 | no | no | none | Current version is latest |

---

**Priority Levels**: 1d (critical), 1w (high), 1m (medium), 1y (low/deprecated)  
**EOL**: End of Life - version no longer supported

## ⚠️ Breaking Changes Identified
- **Vitest**: 1.0.0 → 3.2.4 (Major version - breaking changes likely)

## 🔍 Breaking Change Assessment Required
Before updating these components:
1. **BullMQ updates**: Check for breaking changes in job processing and queue management
2. **TypeScript updates**: Review for new language features and breaking changes
3. **Vitest 3.x**: Check changelog for breaking changes in test configuration and API
4. **Test thoroughly**: Run all scheduler tests after updates
5. **Update incrementally**: Consider updating one component at a time

**Last Security Audit**: `make test.security.sca-scheduler` (automatic)  
**Last Version Audit**: 2024-12-19 (manual) - Updated with Vitest 3.2.4 upgrade  
**Next Version Audit**: 2024-12-26 (manual)

## Audit Commands
```bash
# Scheduler-specific component audit
make audit.components.scheduler

# Scheduler-specific security audit
make test.security.sca-scheduler
```
