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
import { BnplSessionsService } from '../bnpl-sessions/bnpl-sessions.service';
import { StripeService } from './stripe.service';

@ApiTags('payments')
@Controller('payments')
export class PaymentsController {
  constructor(
    private readonly paymentsService: PaymentsService,
    private readonly myFatoorahService: MyFatoorahService,
    private readonly postponementsService: PostponementsService,
    private readonly usersService: UsersService,
    private readonly bnplSessionsService: BnplSessionsService,
    private readonly stripeService: StripeService,
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
    @Query('nextOnly') nextOnly?: string,
  ) {
    // Check if user is authenticated
    if (!req.user || !req.user.id) {
      throw new Error('User not authenticated');
    }

    const installmentNum = installmentNumber ? parseInt(installmentNumber, 10) : undefined;
    const installmentsCnt = installmentsCount ? parseInt(installmentsCount, 10) : undefined;
    const isNextOnly = nextOnly === 'false' ? false : true;

    const payments = await this.paymentsService.getPendingPayments(
      req.user.id,
      installmentNum,
      installmentsCnt,
      isNextOnly,
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
  <title>إتمام الدفع</title>
  <link href="https://fonts.googleapis.com/css2?family=Cairo:wght@300;400;600;700&display=swap" rel="stylesheet">
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }

    @keyframes fadeIn {
      from { opacity: 0; }
      to { opacity: 1; }
    }

    @keyframes slideUp {
      from { opacity: 0; transform: translateY(30px); }
      to { opacity: 1; transform: translateY(0); }
    }

    @keyframes scaleIn {
      from { opacity: 0; transform: scale(0.8); }
      to { opacity: 1; transform: scale(1); }
    }

    @keyframes shimmer {
      0% { background-position: -200% center; }
      100% { background-position: 200% center; }
    }

    @keyframes float {
      0%, 100% { transform: translateY(0px); }
      50% { transform: translateY(-6px); }
    }

    @keyframes pulse-ring {
      0% { transform: scale(0.95); opacity: 0.5; }
      50% { transform: scale(1.05); opacity: 0.2; }
      100% { transform: scale(0.95); opacity: 0.5; }
    }

    body {
      font-family: 'Cairo', 'Segoe UI', Tahoma, sans-serif;
      background: #f8f9fb;
      min-height: 100vh;
      display: flex;
      align-items: center;
      justify-content: center;
      padding: 20px;
      animation: fadeIn 0.5s ease;
      position: relative;
      overflow: hidden;
    }

    /* Soft background decorations */
    body::before {
      content: '';
      position: fixed;
      top: -120px;
      left: -120px;
      width: 300px;
      height: 300px;
      background: radial-gradient(circle, rgba(16, 185, 129, 0.06) 0%, transparent 70%);
      border-radius: 50%;
      pointer-events: none;
    }

    body::after {
      content: '';
      position: fixed;
      bottom: -100px;
      right: -100px;
      width: 350px;
      height: 350px;
      background: radial-gradient(circle, rgba(59, 130, 246, 0.05) 0%, transparent 70%);
      border-radius: 50%;
      pointer-events: none;
    }

    .container {
      background: rgba(255, 255, 255, 0.95);
      backdrop-filter: blur(20px);
      -webkit-backdrop-filter: blur(20px);
      border-radius: 24px;
      border: 1px solid rgba(0, 0, 0, 0.04);
      box-shadow: 
        0 4px 24px rgba(0, 0, 0, 0.04),
        0 1px 2px rgba(0, 0, 0, 0.02);
      max-width: 420px;
      width: 100%;
      padding: 40px 32px;
      text-align: center;
      animation: slideUp 0.6s cubic-bezier(0.16, 1, 0.3, 1);
      position: relative;
    }

    .icon-wrapper {
      position: relative;
      width: 80px;
      height: 80px;
      margin: 0 auto 24px;
      animation: scaleIn 0.5s cubic-bezier(0.34, 1.56, 0.64, 1) 0.2s both;
    }

    .icon-wrapper::before {
      content: '';
      position: absolute;
      inset: -8px;
      border-radius: 50%;
      background: rgba(16, 185, 129, 0.08);
      animation: pulse-ring 3s ease-in-out infinite;
    }

    .icon-circle {
      width: 80px;
      height: 80px;
      background: linear-gradient(145deg, #ecfdf5, #d1fae5);
      border-radius: 50%;
      display: flex;
      align-items: center;
      justify-content: center;
      position: relative;
      z-index: 1;
    }

    .icon-circle svg {
      width: 36px;
      height: 36px;
      color: #10b981;
    }

    h1 {
      color: #111827;
      font-size: 22px;
      font-weight: 700;
      margin-bottom: 6px;
      animation: slideUp 0.6s cubic-bezier(0.16, 1, 0.3, 1) 0.15s both;
    }

    .subtitle {
      color: #9ca3af;
      font-size: 13px;
      font-weight: 400;
      margin-bottom: 28px;
      animation: slideUp 0.6s cubic-bezier(0.16, 1, 0.3, 1) 0.2s both;
    }

    .amount-section {
      padding: 24px 0;
      margin: 0 0 24px;
      border-top: 1px solid #f3f4f6;
      border-bottom: 1px solid #f3f4f6;
      animation: slideUp 0.6s cubic-bezier(0.16, 1, 0.3, 1) 0.25s both;
    }

    .amount-label {
      font-size: 13px;
      color: #9ca3af;
      margin-bottom: 8px;
      font-weight: 400;
    }

    .amount {
      font-size: 42px;
      font-weight: 700;
      color: #111827;
      letter-spacing: -1px;
      line-height: 1.1;
    }

    .amount .currency {
      font-size: 18px;
      color: #6b7280;
      font-weight: 600;
      margin-right: 4px;
    }

    .info {
      background: #fafbfc;
      border-radius: 16px;
      padding: 18px 20px;
      margin: 0 0 20px;
      text-align: right;
      border: 1px solid #f3f4f6;
      animation: slideUp 0.6s cubic-bezier(0.16, 1, 0.3, 1) 0.3s both;
    }

    .info-row {
      display: flex;
      justify-content: space-between;
      align-items: center;
      padding: 8px 0;
    }

    .info-row:not(:last-child) {
      border-bottom: 1px solid #f3f4f6;
    }

    .info-label {
      color: #9ca3af;
      font-size: 13px;
      font-weight: 400;
    }

    .info-value {
      color: #374151;
      font-weight: 600;
      font-size: 13px;
      direction: ltr;
    }

    .security-badge {
      display: inline-flex;
      align-items: center;
      gap: 6px;
      background: #f0fdf4;
      border: 1px solid #dcfce7;
      border-radius: 100px;
      padding: 8px 16px;
      font-size: 12px;
      color: #16a34a;
      font-weight: 500;
      margin-bottom: 24px;
      animation: slideUp 0.6s cubic-bezier(0.16, 1, 0.3, 1) 0.35s both;
    }

    .security-badge svg {
      width: 14px;
      height: 14px;
    }

    .buttons {
      display: flex;
      flex-direction: column;
      gap: 12px;
      animation: slideUp 0.6s cubic-bezier(0.16, 1, 0.3, 1) 0.4s both;
    }

    button {
      width: 100%;
      padding: 16px 24px;
      border: none;
      border-radius: 14px;
      font-size: 16px;
      font-family: 'Cairo', sans-serif;
      font-weight: 700;
      cursor: pointer;
      transition: all 0.3s cubic-bezier(0.16, 1, 0.3, 1);
      position: relative;
      overflow: hidden;
    }

    button::after {
      content: '';
      position: absolute;
      inset: 0;
      background: linear-gradient(
        90deg,
        transparent 0%,
        rgba(255, 255, 255, 0.1) 50%,
        transparent 100%
      );
      background-size: 200% 100%;
      opacity: 0;
      transition: opacity 0.3s;
    }

    button:hover::after {
      opacity: 1;
      animation: shimmer 1.5s infinite;
    }

    .btn-success {
      background: linear-gradient(135deg, #10b981 0%, #059669 100%);
      color: white;
      box-shadow: 0 4px 16px rgba(16, 185, 129, 0.2);
    }

    .btn-success:hover {
      transform: translateY(-2px);
      box-shadow: 0 8px 24px rgba(16, 185, 129, 0.3);
    }

    .btn-success:active {
      transform: translateY(0);
      box-shadow: 0 2px 8px rgba(16, 185, 129, 0.2);
    }

    .btn-cancel {
      background: white;
      color: #6b7280;
      border: 1.5px solid #e5e7eb;
    }

    .btn-cancel:hover {
      background: #fef2f2;
      color: #ef4444;
      border-color: #fecaca;
      transform: translateY(-1px);
      box-shadow: 0 4px 12px rgba(239, 68, 68, 0.08);
    }

    .btn-cancel:active {
      transform: translateY(0);
    }

    .footer-note {
      margin-top: 20px;
      font-size: 11px;
      color: #d1d5db;
      animation: slideUp 0.6s cubic-bezier(0.16, 1, 0.3, 1) 0.45s both;
    }

    /* Loading state */
    .loading-overlay {
      display: none;
      position: absolute;
      inset: 0;
      background: rgba(255, 255, 255, 0.92);
      backdrop-filter: blur(4px);
      border-radius: 24px;
      z-index: 10;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      gap: 16px;
    }

    .loading-overlay.active {
      display: flex;
    }

    .spinner {
      width: 40px;
      height: 40px;
      border: 3px solid #e5e7eb;
      border-top-color: #10b981;
      border-radius: 50%;
      animation: spin 0.8s linear infinite;
    }

    @keyframes spin {
      to { transform: rotate(360deg); }
    }

    .loading-text {
      color: #6b7280;
      font-size: 14px;
      font-weight: 500;
    }
  </style>
</head>
<body>
  <div class="container">
    <!-- Loading overlay -->
    <div class="loading-overlay" id="loadingOverlay">
      <div class="spinner"></div>
      <span class="loading-text">جاري معالجة الدفع...</span>
    </div>

    <!-- Icon -->
    <div class="icon-wrapper">
      <div class="icon-circle">
        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor">
          <path stroke-linecap="round" stroke-linejoin="round" d="M2.25 8.25h19.5M2.25 9h19.5m-16.5 5.25h6m-6 2.25h3m-3.75 3h15a2.25 2.25 0 002.25-2.25V6.75A2.25 2.25 0 0019.5 4.5h-15a2.25 2.25 0 00-2.25 2.25v10.5A2.25 2.25 0 004.5 19.5z" />
        </svg>
      </div>
    </div>

    <h1>إتمام الدفع</h1>
    <p class="subtitle">يرجى مراجعة تفاصيل الدفع وتأكيد العملية</p>

    <!-- Amount -->
    <div class="amount-section">
      <div class="amount-label">المبلغ المطلوب</div>
      <div class="amount">
        <span class="currency">${currency}</span>
        ${amount}
      </div>
    </div>

    <!-- Info -->
    <div class="info">
      <div class="info-row">
        <span class="info-label">رقم الفاتورة</span>
        <span class="info-value">#${invoiceId}</span>
      </div>
      <div class="info-row">
        <span class="info-label">المرجع</span>
        <span class="info-value">${customerRef}</span>
      </div>
    </div>

    <!-- Security badge -->
    <div class="security-badge">
      <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor">
        <path stroke-linecap="round" stroke-linejoin="round" d="M9 12.75L11.25 15 15 9.75m-3-7.036A11.959 11.959 0 013.598 6 11.99 11.99 0 003 9.749c0 5.592 3.824 10.29 9 11.623 5.176-1.332 9-6.03 9-11.622 0-1.31-.21-2.571-.598-3.751h-.152c-3.196 0-6.1-1.248-8.25-3.285z" />
      </svg>
      دفع آمن ومشفر
    </div>

    <!-- Buttons -->
    <div class="buttons">
      <button class="btn-success" onclick="handleSuccess()" id="payBtn">
        تأكيد الدفع
      </button>
      <button class="btn-cancel" onclick="handleCancel()" id="cancelBtn">
        إلغاء العملية
      </button>
    </div>

    <div class="footer-note">
      بيئة اختبار — لا يتم خصم أي مبالغ حقيقية
    </div>
  </div>

  <script>
    function handleSuccess() {
      document.getElementById('loadingOverlay').classList.add('active');
      document.getElementById('payBtn').disabled = true;
      document.getElementById('cancelBtn').disabled = true;
      setTimeout(function() {
        window.location.href = '/api/v1/payments/callback/success?paymentId=${invoiceId}&Id=${invoiceId}';
      }, 1200);
    }

    function handleCancel() {
      document.getElementById('cancelBtn').style.background = '#fef2f2';
      document.getElementById('cancelBtn').style.color = '#ef4444';
      setTimeout(function() {
        window.location.href = '/api/v1/payments/callback/error?paymentId=${invoiceId}&Id=${invoiceId}';
      }, 400);
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
    @Res() res,
    @Request() req,
  ) {
    const actualPaymentId = paymentId || id;
    console.log(`✅ Payment success callback received: ${actualPaymentId}`);

    try {
      // Verify payment
      const isVerified = await this.myFatoorahService.verifyPayment(actualPaymentId);

      if (isVerified) {
        // Get customer reference (session ID)
        const sessionId = await this.myFatoorahService.getCustomerReference(actualPaymentId);

        console.log(`✅ Payment verified for session: ${sessionId}`);

        // Update session and mark first installment as completed
        try {
          const session = await this.bnplSessionsService.getSessionEntity(sessionId);
          if (session && session.userId) {
            await this.bnplSessionsService.approveSession(sessionId, session.userId);
            console.log(`✅ Session ${sessionId} approved and first installment marked as completed`);
          } else {
            console.warn(`⚠️ Session ${sessionId} has no userId, cannot approve automatically`);
          }
        } catch (error) {
          console.error(`❌ Failed to approve session ${sessionId} after payment:`, error.message);
        }

        const baseUrl = req ? `${req.protocol}://${req.get('host')}` : 'https://enthusiastic-stillness-production-5dce.up.railway.app';
        return res.redirect(`${baseUrl}/api/v1/payments/success?sessionId=${sessionId}`);
      } else {
        console.warn(`⚠️ Payment verification failed: ${actualPaymentId}`);
        const baseUrl = req ? `${req.protocol}://${req.get('host')}` : 'https://enthusiastic-stillness-production-5dce.up.railway.app';
        return res.redirect(`${baseUrl}/api/v1/payments/error`);
      }
    } catch (error) {
      console.error('❌ Error in success callback:', error);
      const baseUrl = req ? `${req.protocol}://${req.get('host')}` : 'https://enthusiastic-stillness-production-5dce.up.railway.app';
      return res.redirect(`${baseUrl}/api/v1/payments/error`);
    }
  }

  @Post('stripe/create-checkout-session')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Create Stripe Checkout session for first installment' })
  async createStripeSession(
    @Body('amount') amount: number,
    @Body('sessionId') sessionId: string,
    @Body('currency') currency: string = 'JOD',
    @Request() req,
  ) {
    const successUrl = `${req.protocol}://${req.get('host')}/api/v1/payments/stripe/callback/success?sessionId=${sessionId}&stripeSessionId={CHECKOUT_SESSION_ID}`;
    const cancelUrl = `${req.protocol}://${req.get('host')}/api/v1/payments/stripe/callback/error?sessionId=${sessionId}`;

    const session = await this.stripeService.createCheckoutSession({
      amount,
      currency,
      customerName: req.user.name || 'Customer',
      customerEmail: req.user.email || 'customer@example.com',
      customerReference: sessionId,
      successUrl,
      cancelUrl,
    });

    return {
      success: true,
      data: {
        url: session.url,
        sessionId: session.id,
      },
    };
  }

  @Get('stripe/callback/success')
  @ApiOperation({ summary: 'Handle Stripe success callback' })
  async handleStripeSuccess(
    @Query('sessionId') sessionId: string,
    @Query('stripeSessionId') stripeSessionId: string,
    @Res() res,
    @Request() req,
  ) {
    console.log(`✅ Stripe success callback received for session: ${sessionId}`);

    try {
      const isPaid = await this.stripeService.verifySession(stripeSessionId);

      if (isPaid) {
        // Approve BNPL session
        try {
          const session = await this.bnplSessionsService.getSessionEntity(sessionId);
          if (session && session.userId) {
            await this.bnplSessionsService.approveSession(sessionId, session.userId);
            console.log(`✅ Session ${sessionId} approved via Stripe`);
          }
        } catch (error) {
          console.error(`❌ Failed to approve session ${sessionId} after Stripe payment:`, error.message);
        }

        // Redirect to new success page
        const baseUrl = req ? `${req.protocol}://${req.get('host')}` : 'https://enthusiastic-stillness-production-5dce.up.railway.app';
        return res.redirect(`${baseUrl}/api/v1/payments/success?sessionId=${sessionId}`);
      } else {
        const baseUrl = req ? `${req.protocol}://${req.get('host')}` : 'https://enthusiastic-stillness-production-5dce.up.railway.app';
        return res.redirect(`${baseUrl}/api/v1/payments/error?sessionId=${sessionId}`);
      }
    } catch (error) {
      console.error('❌ Error in Stripe success callback:', error);
      const baseUrl = req ? `${req.protocol}://${req.get('host')}` : 'https://enthusiastic-stillness-production-5dce.up.railway.app';
      return res.redirect(`${baseUrl}/api/v1/payments/error?sessionId=${sessionId}`);
    }
  }

  @Get('stripe/callback/error')
  @ApiOperation({ summary: 'Handle Stripe error callback' })
  async handleStripeError(
    @Query('sessionId') sessionId: string,
    @Res() res,
    @Request() req,
  ) {
    console.log(`❌ Stripe error callback received for session: ${sessionId}`);
    const baseUrl = req ? `${req.protocol}://${req.get('host')}` : 'https://enthusiastic-stillness-production-5dce.up.railway.app';
    return res.redirect(`${baseUrl}/api/v1/payments/error?sessionId=${sessionId}`);
  }

  @Get('success')
  @ApiOperation({ summary: 'Display payment success page' })
  async displaySuccessPage(@Query('sessionId') sessionId: string, @Res() res) {
    const html = `
<!DOCTYPE html>
<html dir="rtl" lang="ar">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>تم الدفع بنجاح</title>
  <link href="https://fonts.googleapis.com/css2?family=Cairo:wght@300;400;600;700&display=swap" rel="stylesheet">
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body { font-family: 'Cairo', sans-serif; background: #f8f9fb; min-height: 100vh; display: flex; align-items: center; justify-content: center; padding: 20px; }
    .container { background: white; border-radius: 24px; box-shadow: 0 4px 24px rgba(0,0,0,0.06); max-width: 400px; width: 100%; padding: 40px 32px; text-align: center; }
    .icon { width: 80px; height: 80px; background: #ecfdf5; color: #10b981; border-radius: 50%; display: flex; align-items: center; justify-content: center; margin: 0 auto 24px; }
    h1 { color: #111827; font-size: 24px; margin-bottom: 8px; }
    p { color: #6b7280; font-size: 14px; margin-bottom: 32px; }
    .btn { display: block; width: 100%; padding: 16px; background: #10b981; color: white; text-decoration: none; border-radius: 14px; font-weight: 700; transition: all 0.3s; }
    .btn:hover { background: #059669; transform: translateY(-2px); }
  </style>
</head>
<body>
  <div class="container">
    <div class="icon">
      <svg width="40" height="40" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path></svg>
    </div>
    <h1>تم الدفع بنجاح!</h1>
    <p>تم استلام الدفعة الأولى بنجاح وتفعيل طلبك. يمكنك الآن العودة للتطبيق لمتابعة أقساطك.</p>
    <a href="bnpl://success" class="btn">العودة للتطبيق</a>
  </div>
</body>
</html>`;
    res.type('text/html').send(html);
  }

  @Get('error')
  @ApiOperation({ summary: 'Display payment error page' })
  async displayErrorPage(@Query('sessionId') sessionId: string, @Res() res) {
    const html = `
<!DOCTYPE html>
<html dir="rtl" lang="ar">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>فشل الدفع</title>
  <link href="https://fonts.googleapis.com/css2?family=Cairo:wght@300;400;600;700&display=swap" rel="stylesheet">
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body { font-family: 'Cairo', sans-serif; background: #f8f9fb; min-height: 100vh; display: flex; align-items: center; justify-content: center; padding: 20px; }
    .container { background: white; border-radius: 24px; box-shadow: 0 4px 24px rgba(0,0,0,0.06); max-width: 400px; width: 100%; padding: 40px 32px; text-align: center; }
    .icon { width: 80px; height: 80px; background: #fef2f2; color: #ef4444; border-radius: 50%; display: flex; align-items: center; justify-content: center; margin: 0 auto 24px; }
    h1 { color: #111827; font-size: 24px; margin-bottom: 8px; }
    p { color: #6b7280; font-size: 14px; margin-bottom: 32px; }
    .btn { display: block; width: 100%; padding: 16px; background: #ef4444; color: white; text-decoration: none; border-radius: 14px; font-weight: 700; transition: all 0.3s; }
  </style>
</head>
<body>
  <div class="container">
    <div class="icon">
      <svg width="40" height="40" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path></svg>
    </div>
    <h1>عذراً، فشلت العملية</h1>
    <p>لم نتمكن من إتمام عملية الدفع. يرجى المحاولة مرة أخرى أو استخدام وسيلة دفع أخرى.</p>
    <a href="bnpl://error" class="btn">العودة للتطبيق</a>
  </div>
</body>
</html>`;
    res.type('text/html').send(html);
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

