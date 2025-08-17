# Feature: Makefile Interactive/Non-Interactive Switch

## Objective
Ajouter une option et des instructions dans le Makefile pour permettre de basculer entre mode interactif et non-interactif pour les commandes comme `db.init`, `logs.*`, etc.

## Plan / Todo
- [ ] Analyser les commandes Makefile qui nécessitent un switch interactif/non-interactif
- [ ] Implémenter la variable d'environnement `INTERACTIVE` avec valeur par défaut
- [ ] Modifier les commandes `db.init`, `logs.*` et autres pour supporter le switch
- [ ] Ajouter des instructions et exemples d'utilisation dans le Makefile
- [ ] Tester que les commandes fonctionnent en mode interactif et non-interactif
- [ ] Vérifier que la CI fonctionne toujours (mode non-interactif par défaut)

## Commits & Progress
- [x] **Commit 1** (216147c): Analyse et planification de l'implémentation
- [x] **Commit 2** (216147c): Implémentation du switch interactif/non-interactif
- [x] **Commit 3** (b663d82): Correction du mode non-interactif pour Prisma
- [x] **Commit 4**: Tests finaux et validation complète

## Status
- **Progress**: 4/4 tâches complétées
- **Current**: Tous les tests passent, fonctionnalité validée
- **Next**: Créer le PR et finaliser la fonctionnalité
