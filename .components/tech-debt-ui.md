# UI Service Technical Debt

## Frontend Stack (packages/ui)
| Component | Current | Latest | EOL | Breaking Change | Priority | Notes |
|-----------|---------|--------|-----|-----------------|----------|-------|
| svelte | 5.0.0 | 5.38.2 | no | no | 1w | Minor version updates available |
-| sveltekit | 2.5.0 | 2.36.1 | no | no | 1w | Minor version updates available |
| svelte-i18n | 4.0.1 | 4.0.1 | no | no | none | Current version is latest |
| vite | 7.1.3 | 7.1.3 | no | no | none | ✅ Current version is latest - migration completed |
| vitest | 3.2.4 | 3.2.4 | no | no | none | ✅ Current version is latest - migration completed |
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
- **Svelte**: ✅ 4.x → 5.0.0 (Completed - tested and working)
- **Vite**: ✅ 5.x → 7.1.3 (Completed - tested and working)
- **Vitest**: ✅ 1.0.0 → 3.2.4 (Completed - tested and working)

## 🔍 Breaking Change Assessment Required
Before updating these components:
1. **Svelte updates**: Review for breaking changes in component API and syntax
2. **Vite updates**: Check build configuration and plugin compatibility
3. **Test thoroughly**: Run all UI tests after major version updates
4. **Update incrementally**: Consider updating one major component at a time

**Last Security Audit**: `make test.security.sca-ui` (automatic)  
**Last Version Audit**: 2024-12-19 (manual) - ✅ Svelte 5.0.0 + Vite 7.1.3 + Vitest 3.2.4 migrations completed  
**Next Version Audit**: 2024-12-26 (manual)

## Audit Commands
```bash
# UI-specific component audit
make audit.components.ui

# UI-specific security audit
make test.security.sca-ui
```
