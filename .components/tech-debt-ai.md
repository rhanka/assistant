# AI Service Technical Debt

## AI Stack (packages/ai)
| Component | Current | Latest | EOL | Breaking Change | Priority | Notes |
|-----------|---------|--------|-----|-----------------|----------|-------|
| fastapi | 0.116.0 | 0.116.1 | no | no | 1d | Patch update available |
| pytest | 8.2.0 | 8.4.1 | no | no | 1w | Minor version updates available |

## Python Runtime
| Component | Current | Latest | EOL | Breaking Change | Priority | Notes |
|-----------|---------|--------|-----|-----------------|----------|-------|
| python | 3.11.13 | 3.13.7 | no | unknown | 1m | Major version - test compatibility - 3.14 is in .0 |

## Base Images (OS)
| Component | Current | Latest | EOL | Breaking Change | Priority | Notes |
|-----------|---------|--------|-----|-----------------|----------|-------|
| debian | bookworm | alpine:3.22 | no | unknown | 1m | Major version - migrate to alpine, until deeplearning services required |

---

**Priority Levels**: 1d (critical), 1w (high), 1m (medium), 1y (low/deprecated)  
**EOL**: End of Life - version no longer supported

## ⚠️ Breaking Changes Identified
- **Python**: 3.11.13 → 3.13.7 (Major version - test compatibility)
- **Pytest**: 8.2.0 → 8.4.1 (Minor version - test compatibility)

## 🔍 Breaking Change Assessment Required
Before updating these components:
1. **Python 3.13**: Check for deprecated features and syntax changes
2. **FastAPI updates**: Review for breaking changes in API endpoints and middleware
3. **Test thoroughly**: Run all AI tests after major version updates
4. **Update incrementally**: Consider updating one major component at a time

**Last Security Audit**: `make test.security.sca-ai` (automatic)  
**Last Version Audit**: 2024-01-15 (manual) - Updated with real data  
**Next Version Audit**: 2024-01-22 (manual)

## Audit Commands
```bash
# AI-specific component audit
make audit.components.ai

# AI-specific security audit
make test.security.sca-ai
```
