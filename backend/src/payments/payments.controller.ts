import {
  Controller,
  Get,
  Post,
  Put,
  Param,
  Body,
  Query,
  UseGuards,
  Request,
  Res,
  HttpException,
  HttpStatus,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth, ApiQuery } from '@nestjs/swagger';
import { PaymentsService } from './payments.service';
import { MyFatoorahService } from './myfatoorah.service';
import { PostponementsService } from '../postponements/postponements.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { UsersService } from '../users/users.service';

@ApiTags('payments')
@Controller('payments')
export class PaymentsController {
  constructor(
    private readonly paymentsService: PaymentsService,
    private readonly myFatoorahService: MyFatoorahService,
    private readonly postponementsService: PostponementsService,
    private readonly usersService: UsersService,
  ) { }

  @Get()
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Get all user payments with installment info' })
  @ApiQuery({ name: 'installmentNumber', required: false, description: 'Filter by installment number (e.g., 1, 2, 3, 4)' })
  @ApiQuery({ name: 'installmentsCount', required: false, description: 'Filter by total installments count (e.g., 4)' })
  async getAllPayments(
    @Request() req,
    @Query('installmentNumber') installmentNumber?: string,
    @Query('installmentsCount') installmentsCount?: string,
  ) {
    let payments = await this.paymentsService.getUserPayments(req.user.id);

    // Apply installment filters if provided
    if (installmentNumber || installmentsCount) {
      const installmentNum = installmentNumber ? parseInt(installmentNumber, 10) : undefined;
      const installmentsCnt = installmentsCount ? parseInt(installmentsCount, 10) : undefined;

      payments = payments.filter(p => {
        if (installmentNum !== undefined && p.installmentNumber !== installmentNum) {
          return false;
        }
        if (installmentsCnt !== undefined && p.installmentsCount !== installmentsCnt) {
          return false;
        }
        return true;
      });
    }

    // Format payments with installment info
    const formattedPayments = payments.map(p => this.paymentsService.formatPaymentResponse(p));

    return {
      success: true,
      data: formattedPayments,
      filters: {
        installmentNumber: installmentNumber ? parseInt(installmentNumber, 10) : undefined,
        installmentsCount: installmentsCount ? parseInt(installmentsCount, 10) : undefined,
      },
    };
  }

  @Get('pending')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Get pending payments with installment filters' })
  @ApiQuery({ name: 'installmentNumber', required: false, description: 'Filter by installment number (e.g., 1, 2, 3, 4)' })
  @ApiQuery({ name: 'installmentsCount', required: false, description: 'Filter by total installments count (e.g., 4)' })
  async getPendingPayments(
    @Request() req,
    @Query('installmentNumber') installmentNumber?: string,
    @Query('installmentsCount') installmentsCount?: string,
  ) {
    // Check if user is authenticated
    if (!req.user || !req.user.id) {
      throw new Error('User not authenticated');
    }

    const installmentNum = installmentNumber ? parseInt(installmentNumber, 10) : undefined;
    const installmentsCnt = installmentsCount ? parseInt(installmentsCount, 10) : undefined;

    const payments = await this.paymentsService.getPendingPayments(
      req.user.id,
      installmentNum,
      installmentsCnt,
    );

    console.log(`[PaymentsController] Returning ${payments.length} pending payments for user ${req.user.id}`);
    if (installmentNum !== undefined || installmentsCnt !== undefined) {
      console.log(`  Filters: installmentNumber=${installmentNum}, installmentsCount=${installmentsCnt}`);
    }

    // Format payments with installment info
    const formattedPayments = payments.map(p => this.paymentsService.formatPaymentResponse(p));

    // Get user's freePostponeUsed status directly from database (not from payment.user relation)
    // This ensures we always get the latest value, not cached data
    const user = await this.usersService.findById(req.user.id);
    const freePostponeUsed = user?.freePostponeUsed || false;

    console.log(`[PaymentsController] User ${req.user.id} freePostponeUsed: ${freePostponeUsed} (from database)`);

    return {
      success: true,
      data: formattedPayments,
      filters: {
        installmentNumber: installmentNum,
        installmentsCount: installmentsCnt,
      },
      user: {
        freePostponeUsed,
      },
    };
  }

  @Get('history')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Get payment history with filters including installments' })
  @ApiQuery({ name: 'startDate', required: false })
  @ApiQuery({ name: 'endDate', required: false })
  @ApiQuery({ name: 'status', required: false })
  @ApiQuery({ name: 'installmentNumber', required: false, description: 'Filter by installment number (e.g., 1, 2, 3, 4)' })
  @ApiQuery({ name: 'installmentsCount', required: false, description: 'Filter by total installments count (e.g., 4)' })
  async getPaymentHistory(
    @Request() req,
    @Query('startDate') startDate?: string,
    @Query('endDate') endDate?: string,
    @Query('status') status?: string,
    @Query('installmentNumber') installmentNumber?: string,
    @Query('installmentsCount') installmentsCount?: string,
  ) {
    const installmentNum = installmentNumber ? parseInt(installmentNumber, 10) : undefined;
    const installmentsCnt = installmentsCount ? parseInt(installmentsCount, 10) : undefined;

    const payments = await this.paymentsService.getPaymentHistory(
      req.user.id,
      startDate,
      endDate,
      status,
      installmentNum,
      installmentsCnt,
    );

    // Format payments with installment info
    const formattedPayments = payments.map(p => this.paymentsService.formatPaymentResponse(p));

    return {
      success: true,
      data: formattedPayments,
      filters: {
        startDate,
        endDate,
        status,
        installmentNumber: installmentNum,
        installmentsCount: installmentsCnt,
      },
    };
  }

  @Get('mock-payment')
  @ApiOperation({ summary: 'Mock payment page for testing' })
  async mockPaymentPage(
    @Query('invoiceId') invoiceId: string,
    @Query('amount') amount: string,
    @Query('currency') currency: string,
    @Query('customerRef') customerRef: string,
    @Res() res,
  ) {
    console.log('🔍 mockPaymentPage called with:', { invoiceId, amount, currency, customerRef });

    const html = `
<!DOCTYPE html>
<html dir="rtl" lang="ar">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>صفحة الدفع التجريبية</title>
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body {
      font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
      min-height: 100vh;
      display: flex;
      align-items: center;
      justify-content: center;
      padding: 20px;
    }
    .container {
      background: white;
      border-radius: 20px;
      box-shadow: 0 20px 60px rgba(0,0,0,0.3);
      max-width: 400px;
      width: 100%;
      padding: 40px;
      text-align: center;
    }
    .logo {
      width: 80px;
      height: 80px;
      background: linear-gradient(135deg, #10B981, #059669);
      border-radius: 50%;
      margin: 0 auto 20px;
      display: flex;
      align-items: center;
      justify-content: center;
      font-size: 40px;
    }
    h1 {
      color: #1a1a1a;
      font-size: 24px;
      margin-bottom: 10px;
    }
    .subtitle {
      color: #757575;
      font-size: 14px;
      margin-bottom: 30px;
    }
    .amount {
      font-size: 48px;
      font-weight: bold;
      color: #10B981;
      margin: 20px 0;
    }
    .info {
      background: #f5f7fa;
      border-radius: 12px;
      padding: 20px;
      margin: 20px 0;
      text-align: right;
    }
    .info-row {
      display: flex;
      justify-content: space-between;
      margin: 10px 0;
      font-size: 14px;
    }
    .info-label {
      color: #757575;
    }
    .info-value {
      color: #1a1a1a;
      font-weight: 600;
    }
    .buttons {
      display: flex;
      gap: 12px;
      margin-top: 30px;
    }
    button {
      flex: 1;
      padding: 16px;
      border: none;
      border-radius: 12px;
      font-size: 16px;
      font-weight: bold;
      cursor: pointer;
      transition: all 0.3s;
    }
    .btn-success {
      background: #10B981;
      color: white;
    }
    .btn-success:hover {
      background: #059669;
      transform: translateY(-2px);
      box-shadow: 0 10px 20px rgba(16, 185, 129, 0.3);
    }
    .btn-cancel {
      background: #E53935;
      color: white;
    }
    .btn-cancel:hover {
      background: #C62828;
      transform: translateY(-2px);
      box-shadow: 0 10px 20px rgba(229, 57, 53, 0.3);
    }
    .note {
      margin-top: 20px;
      padding: 12px;
      background: #FFF3CD;
      border-radius: 8px;
      font-size: 13px;
      color: #856404;
    }
  </style>
</head>
<body>
  <div class="container">
    <div class="logo">💳</div>
    <h1>صفحة الدفع التجريبية</h1>
    <p class="subtitle">Mock Payment Gateway</p>
    
    <div class="amount">${amount} ${currency}</div>
    
    <div class="info">
      <div class="info-row">
        <span class="info-label">رقم الفاتورة:</span>
        <span class="info-value">#${invoiceId}</span>
      </div>
      <div class="info-row">
        <span class="info-label">المرجع:</span>
        <span class="info-value">${customerRef}</span>
      </div>
    </div>
    
    <div class="note">
      ⚠️ هذه صفحة دفع تجريبية للاختبار فقط
    </div>
    
    <div class="buttons">
      <button class="btn-success" onclick="handleSuccess()">
        ✅ دفع ناجح
      </button>
      <button class="btn-cancel" onclick="handleCancel()">
        ❌ إلغاء
      </button>
    </div>
  </div>
  
  <script>
    function handleSuccess() {
      window.location.href = '/api/v1/payments/callback/success?paymentId=${invoiceId}&Id=${invoiceId}';
    }
    
    function handleCancel() {
      window.location.href = '/api/v1/payments/callback/error?paymentId=${invoiceId}&Id=${invoiceId}';
    }
  </script>
</body>
</html>
    `;

    res.type('text/html');
    res.send(html);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get payment by ID with installment info' })
  async getPayment(@Param('id') id: number) {
    const payment = await this.paymentsService.getPaymentById(id);
    const formattedPayment = this.paymentsService.formatPaymentResponse(payment);
    return {
      success: true,
      data: formattedPayment,
    };
  }

  @Get('order/:orderId')
  @ApiOperation({ summary: 'Get all payments for an order (all installments)' })
  async getPaymentsByOrderId(@Param('orderId') orderId: string, @Request() req) {
    const payments = await this.paymentsService.getPaymentsByOrderId(orderId, req.user.id);
    const formattedPayments = payments.map(p => this.paymentsService.formatPaymentResponse(p));
    return {
      success: true,
      data: formattedPayments,
    };
  }

  @Post(':id/pay')
  @ApiOperation({ summary: 'Process payment' })
  async processPayment(@Param('id') id: number) {
    const payment = await this.paymentsService.processPayment(id);
    return {
      success: true,
      message: 'تم الدفع بنجاح',
      data: payment,
    };
  }

  @Put(':id/extend')
  @ApiOperation({ summary: 'Extend payment due date' })
  async extendDueDate(
    @Param('id') id: number,
    @Body('extensionDays') extensionDays: number,
  ) {
    const payment = await this.paymentsService.extendDueDate(id, extensionDays);
    return {
      success: true,
      message: 'تم تمديد موعد الدفع بنجاح',
      data: payment,
    };
  }

  @Post(':id/postpone')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Postpone payment for free (30 days, once per user)' })
  async postponePayment(
    @Param('id') id: number,
    @Body('daysToPostpone') daysToPostpone: number,
    @Request() req,
  ) {
    const userId = req.user.id;

    // Get payment details for postponement record
    const payment = await this.paymentsService.getPaymentById(id);
    const merchantName = payment.store?.nameAr || payment.store?.name || 'متجر';
    const amount = parseFloat(payment.amount.toString());

    // Use PostponementsService.postponeForFree for user-level tracking
    const postponement = await this.postponementsService.postponeForFree(
      userId,
      id,
      merchantName,
      amount,
    );

    return {
      success: true,
      message: `تم تأجيل الدفعة بنجاح لمدة 30 يوم`,
      data: {
        postponement,
        payment: await this.paymentsService.getPaymentById(id),
      },
    };
  }

  @Post('initiate')
  @ApiOperation({ summary: 'Initiate MyFatoorah payment' })
  async initiatePayment(
    @Body('amount') amount: number,
    @Body('currency') currency: string = 'JOD',
    @Request() req,
  ) {
    const result = await this.myFatoorahService.executePayment({
      amount,
      currency,
      customerName: req.user.name || 'Customer',
      customerEmail: req.user.email || 'customer@example.com',
      customerPhone: req.user.phone || '+962790000000',
      customerReference: `test_${Date.now()}`,
    });
    return {
      success: true,
      data: result,
    };
  }

  @Get('callback/success')
  @ApiOperation({ summary: 'Handle MyFatoorah success callback' })
  async handleSuccessCallback(
    @Query('paymentId') paymentId: string,
    @Query('Id') id: string,
  ) {
    const actualPaymentId = paymentId || id;
    console.log(`✅ Payment success callback received: ${actualPaymentId}`);

    try {
      // Verify payment
      const isVerified = await this.myFatoorahService.verifyPayment(actualPaymentId);

      if (isVerified) {
        // Get customer reference (session ID)
        const customerRef = await this.myFatoorahService.getCustomerReference(actualPaymentId);

        console.log(`✅ Payment verified for session: ${customerRef}`);

        // TODO: Update first installment status to 'completed'
        // This will be done in the next step

        return {
          success: true,
          message: 'Payment verified successfully',
          paymentId: actualPaymentId,
          customerReference: customerRef,
        };
      } else {
        console.warn(`⚠️ Payment verification failed: ${actualPaymentId}`);
        return {
          success: false,
          message: 'Payment verification failed',
        };
      }
    } catch (error) {
      console.error('❌ Error in success callback:', error);
      return {
        success: false,
        message: error.message,
      };
    }
  }

  @Get('callback/error')
  @ApiOperation({ summary: 'Handle MyFatoorah error callback' })
  async handleErrorCallback(
    @Query('paymentId') paymentId: string,
    @Query('Id') id: string,
  ) {
    const actualPaymentId = paymentId || id;
    console.log(`❌ Payment error callback received: ${actualPaymentId}`);

    return {
      success: false,
      message: 'Payment failed or cancelled',
      paymentId: actualPaymentId,
    };
  }

  // Admin endpoints
  @Get('admin/stats')
  @ApiOperation({ summary: 'Get payments statistics for admin' })
  async getAdminStats() {
    return this.paymentsService.getAdminStats();
  }

  @Get('admin/all')
  @ApiOperation({ summary: 'Get all payments for admin' })
  async getAllPaymentsForAdmin(@Query() query: any) {
    const { page = 1, limit = 10, status, userId, storeId, startDate, endDate } = query;
    return this.paymentsService.getAllPaymentsForAdmin({
      page: parseInt(page),
      limit: parseInt(limit),
      status,
      userId: userId ? parseInt(userId) : undefined,
      storeId: storeId ? parseInt(storeId) : undefined,
      startDate,
      endDate,
    });
  }

  @Get('admin/upcoming')
  @ApiOperation({ summary: 'Get upcoming payments timeline' })
  async getUpcomingPayments() {
    return this.paymentsService.getUpcomingPayments();
  }

  @Post('admin/:id/collect')
  @ApiOperation({ summary: 'Manually mark payment as collected for bank' })
  async manualCollect(@Param('id') id: number) {
    return this.paymentsService.manualCollect(id);
  }

  @Post('admin/:id/send-reminder')
  @ApiOperation({ summary: 'Send payment reminder to customer' })
  async sendReminder(@Param('id') id: number) {
    return this.paymentsService.sendReminder(id);
  }
}

