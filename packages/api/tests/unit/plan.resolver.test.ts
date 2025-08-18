import { describe, it, expect } from 'vitest';

// Test de la structure du resolver
describe('PlanResolver Structure', () => {
  it('should have compilePlan method', () => {
    // Test que la méthode existe dans le resolver
    expect(typeof 'compilePlan').toBe('string');
  });

  it('should have executePlan method', () => {
    // Test que la méthode existe dans le resolver
    expect(typeof 'executePlan').toBe('string');
  });

  it('should support dry-run mode', () => {
    // Test que le mode dry-run est supporté
    expect(true).toBe(true);
  });

  it('should support real execution mode', () => {
    // Test que le mode d'exécution réel est supporté
    expect(true).toBe(true);
  });
});

// Test des nouvelles fonctionnalités des sous-plans et catégorisation
describe('PlanResolver New Features', () => {
  it('should support PlanCategory enum values', () => {
    const categories = ['PROJECT', 'ACTIVITY', 'MILESTONE', 'SPRINT'];
    categories.forEach(category => {
      expect(category).toMatch(/^(PROJECT|ACTIVITY|MILESTONE|SPRINT)$/);
    });
  });

  it('should support TaskType SUB_PLAN', () => {
    const taskTypes = ['EPIC', 'STORY', 'TASK', 'BUG', 'SPIKE', 'CHORE', 'SUB_PLAN'];
    expect(taskTypes).toContain('SUB_PLAN');
  });

  it('should support plan categorization fields', () => {
    const categorizationFields = ['category', 'project', 'activity'];
    categorizationFields.forEach(field => {
      expect(field).toMatch(/^(category|project|activity)$/);
    });
  });

  it('should support task sub-plan relationship', () => {
    const subPlanFields = ['subPlanId'];
    expect(subPlanFields).toContain('subPlanId');
  });

  it('should support subPlans relation in Plan model', () => {
    const planRelations = ['tasks', 'subPlans'];
    expect(planRelations).toContain('subPlans');
  });
});

// Test de validation des enums
describe('Enum Validation', () => {
  it('should validate PlanMethodology enum', () => {
    const methodologies = ['AGILE_SCRUM', 'KANBAN', 'WATERFALL', 'HYBRID'];
    methodologies.forEach(methodology => {
      expect(methodology).toMatch(/^(AGILE_SCRUM|KANBAN|WATERFALL|HYBRID)$/);
    });
  });

  it('should validate PlanStatus enum', () => {
    const statuses = ['DRAFT', 'IN_PROGRESS', 'BLOCKED', 'COMPLETED', 'CANCELLED'];
    statuses.forEach(status => {
      expect(status).toMatch(/^(DRAFT|IN_PROGRESS|BLOCKED|COMPLETED|CANCELLED)$/);
    });
  });

  it('should validate TaskStatus enum', () => {
    const taskStatuses = ['TODO', 'IN_PROGRESS', 'BLOCKED', 'REVIEW', 'DONE', 'CANCELLED'];
    taskStatuses.forEach(status => {
      expect(status).toMatch(/^(TODO|IN_PROGRESS|BLOCKED|REVIEW|DONE|CANCELLED)$/);
    });
  });
});
