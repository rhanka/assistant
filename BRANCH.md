# Feature: Scheduler Plan → DAG Compilation & Execution

## Objective
Implémenter la fonctionnalité manquante du scheduler pour compiler des Plans en DAG et les enqueuer pour exécution, plus le job worker "sync:github" pour la synchronisation avec GitHub.

## Plan / Todo
- [ ] **Task 1**: Ajouter endpoint API `/compile` pour compiler Plan → DAG
- [ ] **Task 2**: Ajouter endpoint API `/execute` pour exécuter un plan (dry-run + preview)
- [ ] **Task 3**: Implémenter job worker "sync:github" pour issues + Projects v2
- [ ] **Task 4**: Ajouter tests d'intégration pour scheduler-API
- [ ] **Task 5**: Ajouter tests d'intégration pour workers-API
- [ ] **Task 6**: Mettre à jour TODO.md et RELEASE.md

## Commits & Progress
- [x] **Commit 1**: Task 1 - Endpoint API /compile ✅
- [x] **Commit 2**: Task 2 - Endpoint API /execute ✅
- [ ] **Commit 3**: Task 3 - Job worker sync:github
- [ ] **Commit 4**: Task 4 - Tests d'intégration scheduler-API
- [ ] **Commit 5**: Task 5 - Tests d'intégration workers-API
- [ ] **Commit 6**: Task 6 - Mise à jour documentation

## Status
- **Progress**: 2/6 tasks completed
- **Current**: Endpoints API /compile et /execute fonctionnent parfaitement
- **Next**: Implémenter job worker "sync:github" pour issues + Projects v2
