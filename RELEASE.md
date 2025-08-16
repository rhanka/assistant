# Release 0.1.0 (MVP)

## Scope
- Monorepo skeleton with UI/API/Scheduler/Workers/AI
- GitHub & Cursor integrations (stubs)
- DB scripts (init/migrate/reset), CI check for i18n

## Checklist
- [ ] Smoke tests green (API/UI)
- [ ] DB migrations applied locally
- [ ] Release notes updated
- [ ] ⚠ approval for final tag

## Risks / Rollback
- Schema still evolving → `make db.reset` available
- Cursor: first login to Web Agents is manual
