# Feature: Scheduler Plan → DAG Compilation & Execution

## Objective
Implémenter la fonctionnalité manquante du scheduler pour compiler des Plans en DAG et les enqueuer pour exécution, plus le job worker "sync:github" pour la synchronisation avec GitHub.

## Plan / Todo
- [x] **Task 1**: Ajouter endpoint API `/compile` pour compiler Plan → DAG
- [x] **Task 2**: Ajouter endpoint API `/execute` pour exécuter un plan (dry-run + preview)
- [x] **Task 3**: Implémenter job worker "sync:github" pour issues + Projects v2
- [x] **Task 4**: Ajouter tests d'intégration pour scheduler-API
- [x] **Task 5**: Ajouter tests d'intégration pour workers-API
- [x] **Task 6**: Mettre à jour TODO.md et RELEASE.md

## Commits & Progress
- [x] **Commit 1** (822235f): Règles d'architecture Docker-first et workflow
- [x] **Commit 2** (211a5e2): Infrastructure Docker et Makefile
- [x] **Commit 3** (d5981b8): DTOs et modèles GraphQL pour scheduler
- [x] **Commit 4** (b46a7e4): Service scheduler et intégration GraphQL
- [x] **Commit 5** (da08a2c): Documentation et suivi
- [x] **Commit 6**: Tests unitaires et d'intégration complets
- [x] **Commit 7**: Stratégie de test complétée et vérification API

## Status
- **Progress**: 7/7 commits completed, 6/6 tasks completed
- **Current**: ✅ Stratégie de test complétée - 23 tests passent, API fonctionne
- **Next**: Push vers GitHub et vérification CI

## Stratégie de Test Complétée ✅
- **Tests unitaires** : 23 tests qui passent
  - Tests des fonctions utilitaires du scheduler (validateDag, topoOrder)
  - Tests de structure du resolver (méthodes compilePlan, executePlan)
  - Tests d'intégration de l'API (types GraphQL, fonctionnalités)
- **Tests d'intégration** : Vérification complète
  - L'API se construit sans erreur
  - L'API démarre correctement
  - Le schéma GraphQL est chargé avec tous les nouveaux types
  - Les mutations GraphQL fonctionnent
  - Le SchedulerAdapterService est correctement injecté et fonctionne
- **Tests de fonctionnalité** : Vérification du scheduler
  - Validation DAG fonctionne
  - Tri topologique fonctionne
  - Mode dry-run fonctionne
  - Gestion d'erreur fonctionne

## Prêt pour le Check CI ✅
- Tous les tests passent localement
- L'API fonctionne et peut être testée
- GraphQL mutations fonctionnent
- Prêt pour la vérification GitHub Actions
