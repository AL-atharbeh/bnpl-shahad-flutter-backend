const jsonServer = require('json-server');
const cors = require('cors');
const morgan = require('morgan');

const server = jsonServer.create();
const router = jsonServer.router('db.json');
const middlewares = jsonServer.defaults();

// إعدادات الـ server
const PORT = process.env.PORT || 3000;

// Middleware
server.use(cors());
server.use(morgan('combined'));
server.use(middlewares);
server.use(jsonServer.bodyParser);

// إضافة custom routes
server.get('/api/v1/stores', (req, res) => {
  const stores = router.db.get('stores').value();
  res.json({
    success: true,
    data: stores
  });
});

server.get('/api/v1/stores/:id', (req, res) => {
  const store = router.db.get('stores').find({ id: parseInt(req.params.id) }).value();
  if (store) {
    res.json({
      success: true,
      data: store
    });
  } else {
    res.status(404).json({
      success: false,
      error: {
        code: 'NOT_FOUND',
        message: 'المتجر غير موجود'
      }
    });
  }
});

server.get('/api/v1/stores/:storeId/products', (req, res) => {
  const products = router.db.get('products')
    .filter({ storeId: parseInt(req.params.storeId) })
    .value();
  res.json({
    success: true,
    data: products
  });
});

server.get('/api/v1/products/:id', (req, res) => {
  const product = router.db.get('products').find({ id: req.params.id }).value();
  if (product) {
    res.json({
      success: true,
      data: product
    });
  } else {
    res.status(404).json({
      success: false,
      error: {
        code: 'NOT_FOUND',
        message: 'المنتج غير موجود'
      }
    });
  }
});

server.get('/api/v1/notifications', (req, res) => {
  const notifications = router.db.get('notifications').value();
  res.json({
    success: true,
    data: notifications
  });
});

server.put('/api/v1/notifications/:id/read', (req, res) => {
  const notification = router.db.get('notifications')
    .find({ id: parseInt(req.params.id) })
    .assign({ isRead: true })
    .write();
  
  res.json({
    success: true,
    data: notification
  });
});

// Store Integration Endpoints
server.post('/api/v1/stores/integration/request', (req, res) => {
  const { storeName, website, contactEmail, contactPhone, supportedCountries, supportedCurrencies, estimatedMonthlyOrders, averageOrderValue } = req.body;
  
  const requestId = `integration_request_${Date.now()}`;
  
  res.status(201).json({
    success: true,
    data: {
      requestId: requestId,
      status: 'pending',
      estimatedReviewTime: '5-7 business days',
      nextSteps: [
        'سيتم مراجعة طلبك',
        'سيتم التواصل معك عبر البريد الإلكتروني',
        'سيتم إرسال اتفاقية الشراكة'
      ]
    }
  });
});

server.get('/api/v1/stores/integration/status/:requestId', (req, res) => {
  const { requestId } = req.params;
  
  // Mock status check
  res.json({
    success: true,
    data: {
      requestId: requestId,
      status: 'under_review',
      submittedAt: '2024-01-20T10:30:00Z',
      estimatedCompletion: '2024-01-27T10:30:00Z',
      currentStep: 'مراجعة الطلب',
      nextStep: 'التواصل مع المتجر'
    }
  });
});

server.post('/api/v1/stores/integration/activate', (req, res) => {
  const { storeId, integrationData } = req.body;
  
  // Mock activation
  const newIntegration = {
    id: Date.now(),
    storeId: storeId,
    storeName: integrationData.storeName,
    integrationStatus: 'active',
    integrationType: 'payment_gateway',
    supportedCountries: integrationData.supportedCountries,
    supportedCurrencies: integrationData.supportedCurrencies,
    commissionRate: 2.5,
    minOrderAmount: 50,
    maxOrderAmount: 5000,
    paymentMethods: ['credit_card', 'debit_card', 'bank_transfer'],
    webhookUrl: `${integrationData.website}/webhooks/bnpl`,
    apiCredentials: {
      merchantId: `${integrationData.storeName.toLowerCase()}_merchant_${Date.now()}`,
      apiKey: `${integrationData.storeName.toLowerCase()}_api_key_${Date.now()}`,
      webhookSecret: `${integrationData.storeName.toLowerCase()}_webhook_secret_${Date.now()}`
    },
    features: {
      supportsInstallments: true,
      supportsImmediatePayment: true,
      supportsDeferredPayment: false,
      autoApproval: true
    },
    agreement: {
      signedAt: new Date().toISOString(),
      validUntil: new Date(Date.now() + 365 * 24 * 60 * 60 * 1000).toISOString(),
      terms: `https://bnpl.com/terms/${integrationData.storeName.toLowerCase()}`,
      commissionStructure: 'percentage'
    }
  };
  
  router.db.get('store_integrations').push(newIntegration).write();
  
  res.status(201).json({
    success: true,
    data: newIntegration
  });
});

server.get('/api/v1/stores/integration/list', (req, res) => {
  const integrations = router.db.get('store_integrations').value();
  
  const summary = integrations.map(integration => ({
    id: integration.id,
    storeName: integration.storeName,
    integrationStatus: integration.integrationStatus,
    supportedCountries: integration.supportedCountries,
    supportedCurrencies: integration.supportedCurrencies,
    commissionRate: integration.commissionRate,
    totalTransactions: Math.floor(Math.random() * 2000) + 500, // Mock data
    totalVolume: Math.floor(Math.random() * 300000) + 100000 // Mock data
  }));
  
  res.json({
    success: true,
    data: summary
  });
});

server.put('/api/v1/stores/integration/:storeId/settings', (req, res) => {
  const { storeId } = req.params;
  const updates = req.body;
  
  const integration = router.db.get('store_integrations')
    .find({ storeId: parseInt(storeId) })
    .assign(updates)
    .write();
  
  if (integration) {
    res.json({
      success: true,
      data: integration
    });
  } else {
    res.status(404).json({
      success: false,
      error: {
        code: 'NOT_FOUND',
        message: 'التكامل مع المتجر غير موجود'
      }
    });
  }
});

server.post('/api/v1/stores/integration/:storeId/webhook', (req, res) => {
  const { storeId } = req.params;
  const webhookData = req.body;
  
  // Mock webhook processing
  console.log(`Webhook received from store ${storeId}:`, webhookData);
  
  res.json({
    success: true,
    message: 'Webhook processed successfully'
  });
});

// Payment Integration Endpoints
server.post('/api/v1/payment/session/create', (req, res) => {
  const { storeId, orderId, amount, currency, items, userCountry, userCurrency } = req.body;
  
  // Check if store supports BNPL in user's country
  const storeIntegration = router.db.get('store_integrations')
    .find({ storeId: parseInt(storeId) })
    .value();
  
  if (!storeIntegration) {
    return res.status(400).json({
      success: false,
      error: {
        code: 'STORE_NOT_INTEGRATED',
        message: 'المتجر غير متكامل مع BNPL'
      }
    });
  }
  
  if (!storeIntegration.supportedCountries.includes(userCountry)) {
    return res.status(400).json({
      success: false,
      error: {
        code: 'COUNTRY_NOT_SUPPORTED',
        message: 'BNPL غير متاح في بلدك'
      }
    });
  }
  
  const sessionId = `payment_session_${Date.now()}`;
  const expiresAt = new Date(Date.now() + 60 * 60 * 1000); // 1 hour from now
  
  const paymentSession = {
    id: sessionId,
    storeId: parseInt(storeId),
    storeName: storeIntegration.storeName,
    userId: 1, // Mock user ID
    orderId: orderId,
    amount: amount,
    currency: currency,
    items: items,
    paymentMethod: 'bnpl_immediate',
    status: 'pending',
    createdAt: new Date().toISOString(),
    expiresAt: expiresAt.toISOString(),
    redirectUrl: `https://bnpl.com/payment/confirm/${sessionId}`,
    webhookUrl: `${storeIntegration.webhookUrl}/payment_${sessionId}`
  };
  
  router.db.get('payment_sessions').push(paymentSession).write();
  
  res.status(201).json({
    success: true,
    data: {
      sessionId: sessionId,
      redirectUrl: paymentSession.redirectUrl,
      expiresAt: paymentSession.expiresAt,
      supportedPaymentMethods: [
        {
          type: 'bnpl_immediate',
          name: 'BNPL الدفع الفوري',
          description: 'ادفع الآن واحصل على خصم 5%'
        }
      ]
    }
  });
});

server.post('/api/v1/payment/session/:sessionId/process', (req, res) => {
  const { sessionId } = req.params;
  const { paymentMethod, userCardToken, installmentPlan } = req.body;
  
  const paymentSession = router.db.get('payment_sessions')
    .find({ id: sessionId })
    .value();
  
  if (!paymentSession) {
    return res.status(404).json({
      success: false,
      error: {
        code: 'SESSION_NOT_FOUND',
        message: 'جلسة الدفع غير موجودة'
      }
    });
  }
  
  if (paymentSession.status !== 'pending') {
    return res.status(400).json({
      success: false,
      error: {
        code: 'SESSION_EXPIRED',
        message: 'جلسة الدفع منتهية الصلاحية'
      }
    });
  }
  
  // Mock payment processing
  const transactionId = `transaction_${Date.now()}`;
  const commission = paymentSession.amount * 0.025; // 2.5% commission
  const storeAmount = paymentSession.amount - commission;
  
  const transaction = {
    id: transactionId,
    paymentSessionId: sessionId,
    storeId: paymentSession.storeId,
    userId: paymentSession.userId,
    orderId: paymentSession.orderId,
    amount: paymentSession.amount,
    currency: paymentSession.currency,
    paymentMethod: paymentMethod,
    status: 'completed',
    storePaymentStatus: 'paid',
    userPaymentStatus: 'charged',
    commission: commission,
    storeAmount: storeAmount,
    transactionId: `bnpl_txn_${Date.now()}`,
    storeTransactionId: `${paymentSession.storeName.toLowerCase()}_txn_${Date.now()}`,
    userTransactionId: `user_txn_${Date.now()}`,
    createdAt: new Date().toISOString(),
    completedAt: new Date().toISOString()
  };
  
  // Update payment session status
  router.db.get('payment_sessions')
    .find({ id: sessionId })
    .assign({ status: 'completed' })
    .write();
  
  // Add transaction
  router.db.get('payment_transactions').push(transaction).write();
  
  res.json({
    success: true,
    data: {
      transactionId: transactionId,
      status: 'completed',
      amount: paymentSession.amount,
      commission: commission,
      storeAmount: storeAmount,
      redirectUrl: `https://${paymentSession.storeName.toLowerCase()}.com/order/success?orderId=${paymentSession.orderId}`
    }
  });
});

server.get('/api/v1/payment/transaction/:transactionId', (req, res) => {
  const { transactionId } = req.params;
  
  const transaction = router.db.get('payment_transactions')
    .find({ id: transactionId })
    .value();
  
  if (transaction) {
    res.json({
      success: true,
      data: transaction
    });
  } else {
    res.status(404).json({
      success: false,
      error: {
        code: 'NOT_FOUND',
        message: 'المعاملة غير موجودة'
      }
    });
  }
});

// ==================== AUTHENTICATION ENDPOINTS ====================

// 1. User Registration
server.post('/api/v1/auth/register', (req, res) => {
  const { name, email, phone, password, country = 'JO', currency = 'JOD' } = req.body;
  
  // Validation
  if (!name || !email || !phone || !password) {
    return res.status(400).json({
      success: false,
      message: 'جميع الحقول مطلوبة',
      error: 'MISSING_REQUIRED_FIELDS'
    });
  }
  
  // Check if user already exists
  const existingUser = router.db.get('users').find({ 
    $or: [{ email }, { phone }] 
  }).value();
  
  if (existingUser) {
    return res.status(409).json({
      success: false,
      message: 'المستخدم موجود بالفعل',
      error: 'USER_ALREADY_EXISTS'
    });
  }
  
  // Create new user
  const newUser = {
    id: Date.now(),
    name,
    email,
    phone,
    password, // In real app, hash this password
    avatar: null,
    createdAt: new Date().toISOString(),
    isEmailVerified: false,
    isPhoneVerified: false,
    country,
    currency,
    role: 'user'
  };
  
  router.db.get('users').push(newUser).write();
  
  // Generate OTP for phone verification
  const otpCode = Math.floor(1000 + Math.random() * 9000).toString();
  const otpRecord = {
    id: `otp_${Date.now()}`,
    phone,
    code: otpCode,
    createdAt: new Date().toISOString(),
    expiresAt: new Date(Date.now() + 5 * 60 * 1000).toISOString(), // 5 minutes
    isUsed: false
  };
  
  router.db.get('otp_codes').push(otpRecord).write();
  
  // In real app, send SMS with OTP
  console.log(`OTP for ${phone}: ${otpCode}`);
  
  res.status(201).json({
    success: true,
    message: 'تم إنشاء الحساب بنجاح',
    data: {
      user: {
        id: newUser.id,
        name: newUser.name,
        email: newUser.email,
        phone: newUser.phone,
        isEmailVerified: newUser.isEmailVerified,
        isPhoneVerified: newUser.isPhoneVerified
      },
      requiresVerification: true
    }
  });
});

// 2. User Login
server.post('/api/v1/auth/login', (req, res) => {
  const { phone, password } = req.body;
  
  // Validation
  if (!phone || !password) {
    return res.status(400).json({
      success: false,
      message: 'رقم الهاتف وكلمة المرور مطلوبان',
      error: 'MISSING_CREDENTIALS'
    });
  }
  
  // Find user
  const user = router.db.get('users').find({ phone }).value();
  
  if (!user) {
    return res.status(401).json({
      success: false,
      message: 'بيانات الدخول غير صحيحة',
      error: 'INVALID_CREDENTIALS'
    });
  }
  
  // In real app, verify password hash
  if (user.password !== password) {
    return res.status(401).json({
      success: false,
      message: 'بيانات الدخول غير صحيحة',
      error: 'INVALID_CREDENTIALS'
    });
  }
  
  // Generate JWT token (in real app)
  const token = `jwt_token_${user.id}_${Date.now()}`;
  
  res.json({
    success: true,
    message: 'تم تسجيل الدخول بنجاح',
    data: {
      user: {
        id: user.id,
        name: user.name,
        email: user.email,
        phone: user.phone,
        avatar: user.avatar,
        isEmailVerified: user.isEmailVerified,
        isPhoneVerified: user.isPhoneVerified,
        country: user.country,
        currency: user.currency,
        role: user.role
      },
      token,
      expiresIn: '7d'
    }
  });
});

// 3. Send OTP for phone verification
server.post('/api/v1/auth/send-otp', (req, res) => {
  const { phone } = req.body;
  
  if (!phone) {
    return res.status(400).json({
      success: false,
      message: 'رقم الهاتف مطلوب',
      error: 'MISSING_PHONE'
    });
  }
  
  // Generate OTP
  const otpCode = Math.floor(1000 + Math.random() * 9000).toString();
  const otpRecord = {
    id: `otp_${Date.now()}`,
    phone,
    code: otpCode,
    createdAt: new Date().toISOString(),
    expiresAt: new Date(Date.now() + 5 * 60 * 1000).toISOString(),
    isUsed: false
  };
  
  // Remove old OTPs for this phone
  router.db.get('otp_codes').remove({ phone }).write();
  router.db.get('otp_codes').push(otpRecord).write();
  
  // In real app, send SMS
  console.log(`OTP sent to ${phone}: ${otpCode}`);
  
  res.json({
    success: true,
    message: 'تم إرسال رمز التحقق',
    data: {
      phone,
      expiresIn: '5 minutes'
    }
  });
});

// 4. Verify OTP
server.post('/api/v1/auth/verify-otp', (req, res) => {
  const { phone, code } = req.body;
  
  if (!phone || !code) {
    return res.status(400).json({
      success: false,
      message: 'رقم الهاتف ورمز التحقق مطلوبان',
      error: 'MISSING_OTP_DATA'
    });
  }
  
  // Find OTP record
  const otpRecord = router.db.get('otp_codes').find({ 
    phone, 
    code, 
    isUsed: false 
  }).value();
  
  if (!otpRecord) {
    return res.status(400).json({
      success: false,
      message: 'رمز التحقق غير صحيح',
      error: 'INVALID_OTP'
    });
  }
  
  // Check if OTP is expired
  const now = new Date();
  const otpTime = new Date(otpRecord.createdAt);
  const diffInMinutes = (now - otpTime) / (1000 * 60);
  
  if (diffInMinutes > 5) {
    return res.status(400).json({
      success: false,
      message: 'رمز التحقق منتهي الصلاحية',
      error: 'OTP_EXPIRED'
    });
  }
  
  // Mark OTP as used
  router.db.get('otp_codes')
    .find({ id: otpRecord.id })
    .assign({ isUsed: true })
    .write();
  
  // Update user verification status
  router.db.get('users')
    .find({ phone })
    .assign({ isPhoneVerified: true })
    .write();
  
  res.json({
    success: true,
    message: 'تم التحقق من رقم الهاتف بنجاح',
    data: {
      phone,
      isVerified: true
    }
  });
});

// 5. Forgot Password
server.post('/api/v1/auth/forgot-password', (req, res) => {
  const { phone, email } = req.body;
  
  if (!phone && !email) {
    return res.status(400).json({
      success: false,
      message: 'رقم الهاتف أو البريد الإلكتروني مطلوب',
      error: 'MISSING_CONTACT_INFO'
    });
  }
  
  // Find user
  const user = router.db.get('users').find({ 
    $or: [
      phone ? { phone } : {},
      email ? { email } : {}
    ]
  }).value();
  
  if (!user) {
    return res.status(404).json({
      success: false,
      message: 'لم يتم العثور على المستخدم',
      error: 'USER_NOT_FOUND'
    });
  }
  
  // Generate reset token
  const resetToken = `reset_token_${Date.now()}`;
  const resetRecord = {
    token: resetToken,
    userId: user.id,
    phone: user.phone,
    email: user.email,
    createdAt: new Date().toISOString(),
    expiresAt: new Date(Date.now() + 60 * 60 * 1000).toISOString(), // 1 hour
    isUsed: false
  };
  
  router.db.get('password_reset_tokens').push(resetRecord).write();
  
  // In real app, send SMS or email
  if (phone) {
    console.log(`Password reset SMS sent to ${phone} with token: ${resetToken}`);
  }
  if (email) {
    console.log(`Password reset email sent to ${email} with token: ${resetToken}`);
  }
  
  res.json({
    success: true,
    message: phone ? 
      'تم إرسال رمز التحقق إلى رقم هاتفك' : 
      'تم إرسال رابط إعادة تعيين كلمة المرور إلى بريدك الإلكتروني',
    data: {
      contactInfo: phone || email,
      expiresIn: '1 hour'
    }
  });
});

// 6. Reset Password
server.post('/api/v1/auth/reset-password', (req, res) => {
  const { token, newPassword } = req.body;
  
  if (!token || !newPassword) {
    return res.status(400).json({
      success: false,
      message: 'رمز التحقق وكلمة المرور الجديدة مطلوبان',
      error: 'MISSING_RESET_DATA'
    });
  }
  
  // Find reset token
  const resetRecord = router.db.get('password_reset_tokens').find({ 
    token, 
    isUsed: false 
  }).value();
  
  if (!resetRecord) {
    return res.status(400).json({
      success: false,
      message: 'رمز التحقق غير صحيح',
      error: 'INVALID_RESET_TOKEN'
    });
  }
  
  // Check if token is expired
  const now = new Date();
  const tokenTime = new Date(resetRecord.expiresAt);
  if (now > tokenTime) {
    return res.status(400).json({
      success: false,
      message: 'رمز التحقق منتهي الصلاحية',
      error: 'RESET_TOKEN_EXPIRED'
    });
  }
  
  // Update user password
  router.db.get('users')
    .find({ id: resetRecord.userId })
    .assign({ password: newPassword })
    .write();
  
  // Mark token as used
  router.db.get('password_reset_tokens')
    .find({ token })
    .assign({ isUsed: true })
    .write();
  
  res.json({
    success: true,
    message: 'تم إعادة تعيين كلمة المرور بنجاح',
    data: {
      userId: resetRecord.userId
    }
  });
});

// 7. Get User Profile
server.get('/api/v1/auth/profile', (req, res) => {
  // In real app, get user from JWT token
  const userId = req.headers['user-id'] || 1;
  
  const user = router.db.get('users').find({ id: parseInt(userId) }).value();
  
  if (!user) {
    return res.status(404).json({
      success: false,
      message: 'لم يتم العثور على المستخدم',
      error: 'USER_NOT_FOUND'
    });
  }
  
  res.json({
    success: true,
    data: {
      user: {
        id: user.id,
        name: user.name,
        email: user.email,
        phone: user.phone,
        avatar: user.avatar,
        isEmailVerified: user.isEmailVerified,
        isPhoneVerified: user.isPhoneVerified,
        country: user.country,
        currency: user.currency,
        role: user.role,
        createdAt: user.createdAt
      }
    }
  });
});

// 8. Update User Profile
server.put('/api/v1/auth/profile', (req, res) => {
  const userId = req.headers['user-id'] || 1;
  const { name, email, avatar } = req.body;
  
  const user = router.db.get('users').find({ id: parseInt(userId) }).value();
  
  if (!user) {
    return res.status(404).json({
      success: false,
      message: 'لم يتم العثور على المستخدم',
      error: 'USER_NOT_FOUND'
    });
  }
  
  // Update user data
  const updates = {};
  if (name) updates.name = name;
  if (email) updates.email = email;
  if (avatar) updates.avatar = avatar;
  
  const updatedUser = router.db.get('users')
    .find({ id: parseInt(userId) })
    .assign(updates)
    .write();
  
  res.json({
    success: true,
    message: 'تم تحديث الملف الشخصي بنجاح',
    data: {
      user: {
        id: updatedUser.id,
        name: updatedUser.name,
        email: updatedUser.email,
        phone: updatedUser.phone,
        avatar: updatedUser.avatar,
        isEmailVerified: updatedUser.isEmailVerified,
        isPhoneVerified: updatedUser.isPhoneVerified,
        country: updatedUser.country,
        currency: updatedUser.currency,
        role: updatedUser.role
      }
    }
  });
});

// 9. Logout
server.post('/api/v1/auth/logout', (req, res) => {
  // In real app, invalidate JWT token
  res.json({
    success: true,
    message: 'تم تسجيل الخروج بنجاح'
  });
});

// ==================== PAYMENTS ENDPOINTS ====================

// 1. Get User Payments
server.get('/api/v1/payments', (req, res) => {
  const userId = req.headers['user-id'] || 1;
  
  const payments = router.db.get('payment_transactions')
    .filter({ userId: parseInt(userId) })
    .value();
  
  res.json({
    success: true,
    data: payments
  });
});

// 2. Get Pending Payments
server.get('/api/v1/payments/pending', (req, res) => {
  const userId = req.headers['user-id'] || 1;
  
  const pendingPayments = router.db.get('payment_transactions')
    .filter({ 
      userId: parseInt(userId),
      status: 'pending'
    })
    .value();
  
  res.json({
    success: true,
    data: pendingPayments
  });
});

// 3. Get Payment History
server.get('/api/v1/payments/history', (req, res) => {
  const userId = req.headers['user-id'] || 1;
  const { startDate, endDate, status } = req.query;
  
  let payments = router.db.get('payment_transactions')
    .filter({ userId: parseInt(userId) });
  
  if (status) {
    payments = payments.filter({ status });
  }
  
  if (startDate && endDate) {
    payments = payments.filter(payment => {
      const paymentDate = new Date(payment.createdAt);
      const start = new Date(startDate);
      const end = new Date(endDate);
      return paymentDate >= start && paymentDate <= end;
    });
  }
  
  res.json({
    success: true,
    data: payments.value()
  });
});

// 4. Extend Payment Due Date
server.post('/api/v1/payments/:paymentId/extend', (req, res) => {
  const { paymentId } = req.params;
  const { extensionDays } = req.body;
  
  const payment = router.db.get('payment_transactions')
    .find({ id: paymentId })
    .value();
  
  if (!payment) {
    return res.status(404).json({
      success: false,
      message: 'المعاملة غير موجودة',
      error: 'PAYMENT_NOT_FOUND'
    });
  }
  
  if (payment.status !== 'pending') {
    return res.status(400).json({
      success: false,
      message: 'لا يمكن تمديد موعد الدفع لهذه المعاملة',
      error: 'INVALID_PAYMENT_STATUS'
    });
  }
  
  // Update payment with new due date
  const newDueDate = new Date(payment.dueDate);
  newDueDate.setDate(newDueDate.getDate() + (extensionDays || 21));
  
  const updatedPayment = router.db.get('payment_transactions')
    .find({ id: paymentId })
    .assign({ 
      dueDate: newDueDate.toISOString(),
      extensionRequested: true,
      extensionDays: extensionDays || 21
    })
    .write();
  
  res.json({
    success: true,
    message: 'تم تمديد موعد الدفع بنجاح',
    data: updatedPayment
  });
});

// 5. Pay Amount
server.post('/api/v1/payments/:paymentId/pay', (req, res) => {
  const { paymentId } = req.params;
  const { amount, paymentMethod } = req.body;
  
  const payment = router.db.get('payment_transactions')
    .find({ id: paymentId })
    .value();
  
  if (!payment) {
    return res.status(404).json({
      success: false,
      message: 'المعاملة غير موجودة',
      error: 'PAYMENT_NOT_FOUND'
    });
  }
  
  if (payment.status !== 'pending') {
    return res.status(400).json({
      success: false,
      message: 'لا يمكن دفع هذه المعاملة',
      error: 'INVALID_PAYMENT_STATUS'
    });
  }
  
  // Update payment status
  const updatedPayment = router.db.get('payment_transactions')
    .find({ id: paymentId })
    .assign({ 
      status: 'completed',
      paidAmount: amount,
      paymentMethod,
      paidAt: new Date().toISOString()
    })
    .write();
  
  res.json({
    success: true,
    message: 'تم الدفع بنجاح',
    data: updatedPayment
  });
});

// ==================== HOME PAGE ENDPOINTS ====================

// 1. Get Home Page Data
server.get('/api/v1/home', (req, res) => {
  const userId = req.headers['user-id'] || 1;
  
  // Get pending payments
  const pendingPayments = router.db.get('payment_transactions')
    .filter({ 
      userId: parseInt(userId),
      status: 'pending'
    })
    .take(3)
    .value();
  
  // Get top stores
  const topStores = router.db.get('stores')
    .filter({ rating: { $gte: 4.0 } })
    .take(6)
    .value();
  
  // Get best offers
  const bestOffers = router.db.get('stores')
    .filter({ hasDeal: true })
    .take(4)
    .value();
  
  res.json({
    success: true,
    data: {
      pendingPayments,
      topStores,
      bestOffers,
      totalPendingAmount: pendingPayments.reduce((sum, payment) => sum + payment.amount, 0)
    }
  });
});

// ==================== NOTIFICATIONS ENDPOINTS ====================

// 1. Get All Notifications
server.get('/api/v1/notifications', (req, res) => {
  const userId = req.headers['user-id'] || 1;
  const { type, isRead } = req.query;
  
  let notifications = router.db.get('notifications')
    .filter({ userId: parseInt(userId) });
  
  if (type) {
    notifications = notifications.filter({ type });
  }
  
  if (isRead !== undefined) {
    notifications = notifications.filter({ isRead: isRead === 'true' });
  }
  
  res.json({
    success: true,
    data: notifications.value()
  });
});

// 2. Mark Notification as Read
server.put('/api/v1/notifications/:id/read', (req, res) => {
  const { id } = req.params;
  
  const notification = router.db.get('notifications')
    .find({ id: parseInt(id) })
    .assign({ isRead: true })
    .write();
  
  res.json({
    success: true,
    data: notification
  });
});

// 3. Mark All Notifications as Read
server.put('/api/v1/notifications/read-all', (req, res) => {
  const userId = req.headers['user-id'] || 1;
  
  router.db.get('notifications')
    .filter({ userId: parseInt(userId), isRead: false })
    .assign({ isRead: true })
    .write();
  
  res.json({
    success: true,
    message: 'تم تحديد جميع الإشعارات كمقروءة'
  });
});

// 4. Delete Notification
server.delete('/api/v1/notifications/:id', (req, res) => {
  const { id } = req.params;
  
  router.db.get('notifications')
    .remove({ id: parseInt(id) })
    .write();
  
  res.json({
    success: true,
    message: 'تم حذف الإشعار بنجاح'
  });
});

// ==================== SEARCH ENDPOINTS ====================

// 1. Search Stores
server.get('/api/v1/search/stores', (req, res) => {
  const { q, category, hasDeal } = req.query;
  
  let stores = router.db.get('stores');
  
  if (q) {
    stores = stores.filter(store => 
      store.name.toLowerCase().includes(q.toLowerCase()) ||
      store.description.toLowerCase().includes(q.toLowerCase())
    );
  }
  
  if (category) {
    stores = stores.filter({ category });
  }
  
  if (hasDeal !== undefined) {
    stores = stores.filter({ hasDeal: hasDeal === 'true' });
  }
  
  res.json({
    success: true,
    data: stores.value()
  });
});

// 2. Search Products
server.get('/api/v1/search/products', (req, res) => {
  const { q, storeId, category, minPrice, maxPrice } = req.query;
  
  let products = router.db.get('products');
  
  if (q) {
    products = products.filter(product => 
      product.name.toLowerCase().includes(q.toLowerCase()) ||
      product.description.toLowerCase().includes(q.toLowerCase())
    );
  }
  
  if (storeId) {
    products = products.filter({ storeId: parseInt(storeId) });
  }
  
  if (category) {
    products = products.filter({ category });
  }
  
  if (minPrice) {
    products = products.filter(product => product.price >= parseFloat(minPrice));
  }
  
  if (maxPrice) {
    products = products.filter(product => product.price <= parseFloat(maxPrice));
  }
  
  res.json({
    success: true,
    data: products.value()
  });
});

// ==================== OFFERS ENDPOINTS ====================

// 1. Get All Offers
server.get('/api/v1/offers', (req, res) => {
  const offers = router.db.get('stores')
    .filter({ hasDeal: true })
    .value();
  
  res.json({
    success: true,
    data: offers
  });
});

// 2. Get Featured Offers
server.get('/api/v1/offers/featured', (req, res) => {
  const featuredOffers = router.db.get('stores')
    .filter({ hasDeal: true })
    .filter({ rating: { $gte: 4.5 } })
    .take(6)
    .value();
  
  res.json({
    success: true,
    data: featuredOffers
  });
});

// استخدام json-server router للـ endpoints الأخرى
server.use('/api/v1', router);

// تشغيل الـ server
server.listen(PORT, () => {
  console.log(`🚀 Mock Server running on http://localhost:${PORT}`);
  console.log(`📚 API Documentation available at http://localhost:${PORT}/api/v1`);
  console.log(`🔧 JSON Server Admin available at http://localhost:${PORT}`);
});

module.exports = server;
