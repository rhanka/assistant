import { Controller, Get } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service.js';

@Controller('health')
export class HealthController {
  constructor(private prisma: PrismaService) {}

  @Get()
  async ok() { 
    return { 
      ok: true,
      timestamp: new Date().toISOString(),
      uptime: process.uptime()
    }; 
  }

  @Get('db')
  async dbHealth() {
    try {
      await this.prisma.$queryRaw`SELECT 1`;
      return { ok: true, database: 'connected' };
    } catch (error) {
      const errorMessage = error instanceof Error ? error.message : String(error);
      return { ok: false, database: 'disconnected', error: errorMessage };
    }
  }

  @Get('full')
  async fullHealth() {
    const dbHealth = await this.dbHealth();
    return {
      ok: dbHealth.ok,
      timestamp: new Date().toISOString(),
      uptime: process.uptime(),
      database: dbHealth.database,
      environment: process.env.NODE_ENV || 'development',
      version: process.env.npm_package_version || 'unknown'
    };
  }
}
