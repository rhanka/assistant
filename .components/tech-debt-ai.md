# AI Service Technical Debt

## AI Stack (packages/ai)
| Component | Current | Latest | EOL | Breaking Change | Priority | Notes |
|-----------|---------|--------|-----|-----------------|----------|-------|
| fastapi | 0.116.0 | 0.116.1 | no | no | 1d | Patch update available |
| pytest | 8.2.0 | 8.4.1 | no | no | 1w | Minor version updates available |

## Python Runtime
| Component | Current | Latest | EOL | Breaking Change | Priority | Notes |
|-----------|---------|--------|-----|-----------------|----------|-------|
| python | 3.13.7 | 3.13.7 | no | no | none | Current version is latest |

## Base Images (OS)
| Component | Current | Latest | EOL | Breaking Change | Priority | Notes |
|-----------|---------|--------|-----|-----------------|----------|-------|
| alpine | 3.22 | 3.22 | no | no | none | ✅ Migrated from debian bookworm - tested and working |

---

**Priority Levels**: 1d (critical), 1w (high), 1m (medium), 1y (low/deprecated)  
**EOL**: End of Life - version no longer supported

## ⚠️ Breaking Changes Identified
- **Python**: ✅ 3.11.13 → 3.13.7 (Completed - tested and working)
- **Base OS**: ✅ debian bookworm → alpine 3.22 (Completed - tested and working)
- **Pytest**: 8.2.0 → 8.4.1 (Minor version - test compatibility)

## 🔍 Breaking Change Assessment Required
Before updating these components:
1. **FastAPI updates**: Review for breaking changes in API endpoints and middleware
2. **Test thoroughly**: Run all AI tests after major version updates
3. **Update incrementally**: Consider updating one major component at a time

**Last Security Audit**: `make test.security.sca-ai` (automatic)  
**Last Version Audit**: 2024-12-19 (manual) - ✅ Python 3.13.7 + Alpine 3.22 migration completed  
**Next Version Audit**: 2024-12-26 (manual)

## Audit Commands
```bash
# AI-specific component audit
make audit.components.ai

# AI-specific security audit
make test.security.sca-ai
```
