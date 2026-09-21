import {
  Controller,
  Get,
  Headers,
  UnauthorizedException,
  Logger,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiExcludeEndpoint } from '@nestjs/swagger';
import { AutoPaymentScheduler } from './auto-payment.scheduler';

/**
 * Serverless functions do not stay alive, so the in-process @Cron job never
 * fires on Vercel. Vercel Cron calls this endpoint instead, on the schedule
 * declared in vercel.json.
 */
@ApiTags('cron')
@Controller('cron')
export class CronController {
  private readonly logger = new Logger(CronController.name);

  constructor(private readonly autoPaymentScheduler: AutoPaymentScheduler) {}

  @Get('auto-payments')
  @ApiExcludeEndpoint()
  @ApiOperation({ summary: 'Runs the daily auto-payment batch' })
  async runAutoPayments(@Headers('authorization') authorization?: string) {
    const secret = process.env.CRON_SECRET;

    if (!secret) {
      this.logger.error('CRON_SECRET is not set - refusing to run');
      throw new UnauthorizedException();
    }

    if (authorization !== `Bearer ${secret}`) {
      this.logger.warn('Rejected an auto-payment run with a bad secret');
      throw new UnauthorizedException();
    }

    await this.autoPaymentScheduler.handleDailyPayments();
    return { ok: true, ranAt: new Date().toISOString() };
  }
}
