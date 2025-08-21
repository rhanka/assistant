# UI Service Technical Debt

## Frontend Stack (packages/ui)
| Component | Current | Latest | EOL | Breaking Change | Priority | Notes |
|-----------|---------|--------|-----|-----------------|----------|-------|
| svelte | 5.0.0 | 5.38.2 | no | no | 1w | Minor version updates available |
| sveltekit | 2.5.0 | 2.36.1 | no | no | 1w | Minor version updates available |
| vite | 5.3.0 | 7.1.3 | no | **YES** | 1m | Major version update - breaking changes likely |
| svelte-i18n | 4.0.1 | 4.0.1 | no | no | none | Current version is latest |
| typescript | 5.5.4 | 5.5.4 | no | no | none | Current version is latest |
| playwright | 1.40.0 | 1.40.0 | no | no | none | Current version is latest |

## Base Images
| Component | Current | Latest | EOL | Breaking Change | Priority | Notes |
|-----------|---------|--------|-----|-----------------|----------|-------|
| node | 24.6.0 | 24.6.0 | no | no | none | LTS version |
| alpine | 3.22.1 | 3.22.1 | no | no | none | Current version is latest |
| nginx | 1.29.0 | 1.29.0 | no | no | none | Current version is latest |

---

**Priority Levels**: 1d (critical), 1w (high), 1m (medium), 1y (low/deprecated)  
**EOL**: End of Life - version no longer supported

## ⚠️ Breaking Changes Identified
- **Vite**: 5.3.0 → 7.1.3 (Major version - test thoroughly)

## 🔍 Breaking Change Assessment Required
Before updating Vite:
1. **Vite 7.x**: Check changelog for breaking changes in build config, plugins, and API
2. **Test thoroughly**: Run all UI tests after major version update
3. **Update incrementally**: Consider updating one major component at a time

**Last Security Audit**: `make test.security.sca-ui` (automatic)  
**Last Version Audit**: 2024-01-15 (manual) - Updated with real data  
**Next Version Audit**: 2024-01-22 (manual)

## Audit Commands
```bash
# UI-specific component audit
make audit.components.ui

# UI-specific security audit
make test.security.sca-ui
```
