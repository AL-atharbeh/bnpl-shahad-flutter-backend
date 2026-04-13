import { Controller, Get, Post, Body, UseGuards, Request, Param, Query, Res, HttpException, HttpStatus, Delete, Put } from '@nestjs/common';
import dayjs from 'dayjs';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { PostponementsService } from './postponements.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { StripeService } from '../payments/stripe.service';
import { PaymentsService } from '../payments/payments.service';

@ApiTags('postponements')
@Controller('postponements')
export class PostponementsController {
  constructor(
    private readonly postponementsService: PostponementsService,
    private readonly stripeService: StripeService,
    private readonly paymentsService: PaymentsService,
  ) { }

  @Get('can-postpone')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Check if user can use free postponement' })
  async canPostpone(@Request() req) {
    const canPostpone = await this.postponementsService.canPostponeForFree(
      req.user.id,
    );
    const daysRemaining = await this.postponementsService.getDaysUntilNextPostpone(
      req.user.id,
    );

    return {
      success: true,
      data: {
        canPostpone,
        daysUntilNext: daysRemaining,
      },
    };
  }

  @Post('postpone-free')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Use free monthly postponement (10 days)' })
  async postponeForFree(
    @Request() req,
    @Body('paymentId') paymentId: number,
    @Body('merchantName') merchantName: string,
    @Body('amount') amount: number,
  ) {
    const postponement = await this.postponementsService.postponeForFree(
      req.user.id,
      paymentId,
      merchantName,
      amount,
    );

    return {
      success: true,
      message: 'تم تأجيل القسط بنجاح لمدة 10 أيام',
      data: postponement,
    };
  }

  @Get('history')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Get postponement history' })
  async getHistory(@Request() req) {
    const history = await this.postponementsService.getPostponementHistory(
      req.user.id,
    );

    return {
      success: true,
      data: history,
    };
  }

  @Get('extension-options')
  @ApiOperation({ summary: 'Get all available paid extension options' })
  async getExtensionOptions() {
    const options = await this.postponementsService.getExtensionOptions();
    return {
      success: true,
      data: options,
    };
  }

  @Post(':paymentId/initiate-extension')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Initiate a paid extension for a specific payment' })
  async initiateExtension(
    @Request() req,
    @Param('paymentId') paymentId: number,
    @Body('optionId') optionId: number,
  ) {
    const initiationData = await this.postponementsService.initiatePaidExtension(
      req.user.id,
      paymentId,
      optionId,
    );

    const baseUrl = `${req.protocol}://${req.get('host')}`;
    
    // Create Stripe session
    const session = await this.stripeService.createCheckoutSession({
      amount: initiationData.fee,
      currency: 'USD', // Using USD for testing
      customerName: req.user.name || 'Customer',
      customerEmail: (req.user.phone || 'customer') + '@app.com',
      customerReference: `ext_${paymentId}_${initiationData.days}`,
      successUrl: `${baseUrl}/api/v1/postponements/stripe-callback/success?paymentId=${paymentId}&days=${initiationData.days}&fee=${initiationData.fee}&stripeSessionId={CHECKOUT_SESSION_ID}`,
      cancelUrl: `${baseUrl}/api/v1/payments/view-error`,
      productName: `تمديد موعد الدفع - ${initiationData.days} يوم`,
      metadata: {
        paymentId: paymentId.toString(),
        days: initiationData.days.toString(),
        type: 'extension',
      },
    });

    return {
      success: true,
      data: {
        url: session.url,
      },
    };
  }

  @Get('stripe-callback/success')
  @ApiOperation({ summary: 'Handle successful Stripe payment for extension' })
  async handleExtensionSuccess(
    @Query('paymentId') paymentId: string,
    @Query('days') days: string,
    @Query('fee') fee: string,
    @Query('stripeSessionId') stripeSessionId: string,
    @Res() res,
    @Request() req,
  ) {
    try {
      const isPaid = await this.stripeService.verifySession(stripeSessionId);

      if (isPaid) {
        const pId = parseInt(paymentId);
        const dCount = parseInt(days);
        const fAmount = parseFloat(fee);

        // Get payment details BEFORE extending to record original due date
        const payment = await this.paymentsService.getPaymentById(pId);
        const originalDueDate = payment.dueDate;
        const newDueDate = dayjs(originalDueDate).add(dCount, 'day').toDate();
        const merchantName = payment.store?.nameAr || payment.store?.name || 'متجر';

        // Apply the extension
        await this.paymentsService.extendDueDate(pId, dCount);
        await this.paymentsService.postponePayment(pId, dCount);
        
        // Record in history for Admin visibility
        await this.postponementsService.recordPostponement(
          payment.userId,
          pId,
          originalDueDate,
          newDueDate,
          dCount,
          false, // isFree = false
          merchantName,
          fAmount
        );

        const baseUrl = `${req.protocol}://${req.get('host')}`;
        return res.send(`
          <html>
            <head>
              <script>
                window.location.href = "${baseUrl}/api/v1/payments/view-success";
              </script>
            </head>
            <body>جاري التحويل...</body>
          </html>
        `);
      } else {
        const baseUrl = `${req.protocol}://${req.get('host')}`;
        return res.redirect(`${baseUrl}/api/v1/payments/view-error`);
      }
    } catch (error) {
      console.error('❌ Error in extension success callback:', error);
      const baseUrl = `${req.protocol}://${req.get('host')}`;
      return res.redirect(`${baseUrl}/api/v1/payments/view-error`);
    }
  }

  // Admin endpoints
  @Get('admin/stats')
  @ApiOperation({ summary: 'Get postponements statistics for admin' })
  async getAdminStats() {
    return this.postponementsService.getAdminStats();
  }

  @Get('admin/all')
  @ApiOperation({ summary: 'Get all postponements for admin' })
  async getAllPostponements(@Request() req) {
    const { page = 1, limit = 10, userId, paymentId, startDate, endDate } = req.query;
    return this.postponementsService.getAllPostponementsForAdmin({
      page: parseInt(page),
      limit: parseInt(limit),
      userId: userId ? parseInt(userId) : undefined,
      paymentId: paymentId ? parseInt(paymentId) : undefined,
      startDate,
      endDate,
    });
  }

  @Get('admin/chart-data')
  @ApiOperation({ summary: 'Get postponements chart data for admin' })
  async getChartData() {
    return this.postponementsService.getChartData();
  }

  @Post('admin/extension-options')
  @ApiOperation({ summary: 'Create a new extension option' })
  async createExtensionOption(@Body() data: any) {
    const option = await this.postponementsService.createExtensionOption(data);
    return {
      success: true,
      data: option,
    };
  }

  @Put('admin/extension-options/:id')
  @ApiOperation({ summary: 'Update an extension option' })
  async updateExtensionOption(@Param('id') id: string, @Body() data: any) {
    const option = await this.postponementsService.updateExtensionOption(parseInt(id), data);
    return {
      success: true,
      data: option,
    };
  }

  @Delete('admin/extension-options/:id')
  @ApiOperation({ summary: 'Delete an extension option' })
  async deleteExtensionOption(@Param('id') id: string) {
    await this.postponementsService.deleteExtensionOption(parseInt(id));
    return {
      success: true,
    };
  }
}

