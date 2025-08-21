# Workers Service Technical Debt

## Backend Stack (packages/workers)
| Component | Current | Latest | EOL | Breaking Change | Priority | Notes |
|-----------|---------|--------|-----|-----------------|----------|-------|
| bullmq | 5.7.0 | 5.58.0 | no | no | 1w | Minor version updates available |
| typescript | 5.5.4 | 5.9.2 | no | no | 1w | Minor version updates available |
| @types/node | 20.14.10 | 20.14.10 | no | no | none | Current version is latest |

## Automation & Testing
| Component | Current | Latest | EOL | Breaking Change | Priority | Notes |
|-----------|---------|--------|-----|-----------------|----------|-------|
| vitest | 1.0.0 | 3.2.4 | no | **YES** | 1w | Major version update - breaking changes likely |
| playwright | 1.40.0 | 1.41.0 | no | no | 1m | Minor version update |

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
1. **BullMQ updates**: Check for breaking changes in job processing and worker management
2. **Playwright updates**: Review for breaking changes in browser automation and testing
3. **TypeScript updates**: Review for new language features and breaking changes
4. **Vitest 3.x**: Check changelog for breaking changes in test configuration and API
5. **Test thoroughly**: Run all worker tests after updates
6. **Update incrementally**: Consider updating one component at a time

**Last Security Audit**: `make test.security.sca-workers` (automatic)  
**Last Version Audit**: 2024-01-15 (manual) - Updated with real data  
**Next Version Audit**: 2024-01-22 (manual)

## Audit Commands
```bash
# Workers-specific component audit
make audit.components.workers

# Workers-specific security audit
make test.security.sca-workers
```
