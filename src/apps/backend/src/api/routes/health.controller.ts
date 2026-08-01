import { Controller, Get } from '@nestjs/common';
import { PrismaService } from '@gitroom/nestjs-libraries/database/prisma/prisma.service';
import { ioRedis } from '@gitroom/nestjs-libraries/redis/redis.service';
import { TemporalService } from 'nestjs-temporal-core';
import { Connection } from '@temporalio/client';

@Controller('health')
export class HealthController {
  constructor(
    private readonly _prismaService: PrismaService,
    private readonly _temporalService: TemporalService,
  ) {}

  @Get()
  async check() {
    const checks: Record<string, string> = {};

    try {
      await this._prismaService.$queryRawUnsafe('SELECT 1');
      checks.database = 'ok';
    } catch {
      checks.database = 'error';
    }

    try {
      const pong = await ioRedis.ping();
      checks.redis = pong === 'PONG' ? 'ok' : 'error';
    } catch {
      checks.redis = 'error';
    }

    try {
      const connection = this._temporalService?.client?.getRawClient()
        ?.connection as Connection;
      await connection.operatorService.listSearchAttributes({
        namespace: process.env.TEMPORAL_NAMESPACE || 'default',
      });
      checks.temporal = 'ok';
    } catch {
      checks.temporal = 'error';
    }

    const status = Object.values(checks).every((v) => v === 'ok')
      ? 'ok'
      : 'degraded';

    return { status, ...checks };
  }
}
