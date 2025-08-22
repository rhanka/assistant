# Scheduler Service Technical Debt

## Scheduler Stack (packages/scheduler)
| Component | Current | Latest | EOL | Breaking Change | Priority | Notes |
|-----------|---------|--------|-----|-----------------|----------|-------|
| bullmq | 5.7.0 | 5.58.0 | no | no | 1w | Minor version updates available |
| typescript | 5.5.4 | 5.5.4 | no | no | none | Current version is latest |
| vitest | 3.2.4 | 3.2.4 | no | no | none | ✅ Current version is latest - migration completed |

## Base Images
| Component | Current | Latest | EOL | Breaking Change | Priority | Notes |
|-----------|---------|--------|-----|-----------------|----------|-------|
| node | 24.6.0 | 24.6.0 | no | no | none | LTS version |
| alpine | 3.22.1 | 3.22.1 | no | no | none | ✅ Current version is latest - migration completed |

---

**Priority Levels**: 1d (critical), 1w (high), 1m (medium), 1y (low/deprecated)  
**EOL**: End of Life - version no longer supported

## ⚠️ Breaking Changes Identified
- **Vitest**: ✅ 1.0.0 → 3.2.4 (Completed - tested and working)

## 🔍 Breaking Change Assessment Required
Before updating these components:
1. **BullMQ updates**: Review for breaking changes in job queue API
2. **TypeScript updates**: Check for new features and breaking changes
3. **Test thoroughly**: Run all scheduler tests after major version updates
4. **Update incrementally**: Consider updating one major component at a time

**Last Security Audit**: `make test.security.sca-scheduler` (automatic)  
**Last Version Audit**: 2024-12-19 (manual) - ✅ Vitest 3.2.4 migration completed  
**Next Version Audit**: 2024-12-26 (manual)

## Audit Commands
```bash
# Scheduler-specific component audit
make audit.components.scheduler

# Scheduler-specific security audit
make test.security.sca-scheduler
```
