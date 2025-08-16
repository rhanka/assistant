import { Test, TestingModule } from '@nestjs/testing';
import { PlanResolver } from './plan.resolver';
import { PlanService } from './plan.service';

describe('PlanResolver', () => {
  let resolver: PlanResolver;
  let service: PlanService;

  const mockPlanService = {
    create: jest.fn(),
    findAll: jest.fn(),
    findOne: jest.fn(),
    update: jest.fn(),
    remove: jest.fn(),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        PlanResolver,
        {
          provide: PlanService,
          useValue: mockPlanService,
        },
      ],
    }).compile();

    resolver = module.get<PlanResolver>(PlanResolver);
    service = module.get<PlanService>(PlanService);
  });

  it('should be defined', () => {
    expect(resolver).toBeDefined();
  });

  describe('createPlan', () => {
    it('should create a new plan', async () => {
      const createPlanInput = {
        title: 'Test Plan',
        description: 'A test plan',
      };

      const expectedPlan = {
        id: '1',
        ...createPlanInput,
        createdAt: new Date(),
        updatedAt: new Date(),
      };

      mockPlanService.create.mockResolvedValue(expectedPlan);

      const result = await resolver.createPlan(createPlanInput);

      expect(service.create).toHaveBeenCalledWith(createPlanInput);
      expect(result).toEqual(expectedPlan);
    });
  });

  describe('findAll', () => {
    it('should return an array of plans', async () => {
      const expectedPlans = [
        {
          id: '1',
          title: 'Plan 1',
          description: 'Description 1',
          createdAt: new Date(),
          updatedAt: new Date(),
        },
        {
          id: '2',
          title: 'Plan 2',
          description: 'Description 2',
          createdAt: new Date(),
          updatedAt: new Date(),
        },
      ];

      mockPlanService.findAll.mockResolvedValue(expectedPlans);

      const result = await resolver.findAll();

      expect(service.findAll).toHaveBeenCalled();
      expect(result).toEqual(expectedPlans);
    });
  });

  describe('findOne', () => {
    it('should return a single plan', async () => {
      const planId = '1';
      const expectedPlan = {
        id: planId,
        title: 'Test Plan',
        description: 'A test plan',
        createdAt: new Date(),
        updatedAt: new Date(),
      };

      mockPlanService.findOne.mockResolvedValue(expectedPlan);

      const result = await resolver.findOne(planId);

      expect(service.findOne).toHaveBeenCalledWith(planId);
      expect(result).toEqual(expectedPlan);
    });
  });
});
