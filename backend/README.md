# BNPL Backend API

Buy Now Pay Later - Backend API built with NestJS, TypeScript, and MySQL.

## 🚀 Features

- ✅ **Phone-based Authentication** with OTP verification
- ✅ **JWT Authentication** with Passport
- ✅ **User Management** with civil ID capture
- ✅ **Payment System** with installment support
- ✅ **Rewards Points** (1 JOD = 1 point, 100 points = 1 JOD discount)
- ✅ **Free Postponement** (10 days, once per month)
- ✅ **Stores & Products** management
- ✅ **Notifications** system
- ✅ **Swagger API Documentation**
- ✅ **TypeORM** with MySQL
- ✅ **Docker** support

## 📋 Requirements

- Node.js >= 18.x
- MySQL >= 8.0
- Docker & Docker Compose (optional)

## 🛠️ Installation

### Option 1: Docker (Recommended)

```bash
# Clone the repository
git clone <repository-url>
cd backend

# Start services
docker-compose up -d

# View logs
docker-compose logs -f app

# Stop services
docker-compose down
```

The API will be available at:
- **API**: http://localhost:3000
- **Swagger Docs**: http://localhost:3000/api/docs

### Option 2: Local Development

```bash
# Install dependencies
npm install

# ملف .env جاهز بالفعل مع الإعدادات الافتراضية
# يمكنك تعديله إذا احتجت (اختياري)
# nano .env

# Start MySQL (if not using Docker)
# Then run migrations (if any)
npm run migration:run

# Start development server
npm run start:dev
```

## 📚 API Documentation

Once the server is running, visit:

**Swagger UI**: http://localhost:3000/api/docs

## 🔑 Authentication Flow

### 1. Check Phone Number
```bash
POST /api/v1/auth/check-phone
Content-Type: application/json

{
  "phone": "+962799999999"
}
```

### 2. Send OTP
```bash
POST /api/v1/auth/send-otp
Content-Type: application/json

{
  "phone": "+962799999999"
}
```

### 3. Verify OTP
```bash
POST /api/v1/auth/verify-otp
Content-Type: application/json

{
  "phone": "+962799999999",
  "code": "123456"
}
```

### 4. Create Account (for new users)
```bash
POST /api/v1/auth/create-account
Content-Type: application/json

{
  "phone": "+962799999999",
  "fullName": "أحمد محمد",
  "civilIdNumber": "2991234567",
  "dateOfBirth": "1990-01-01",
  "address": "Amman, Jordan",
  "monthlyIncome": 1500.00,
  "employer": "Tech Company",
  "civilIdFront": "data:image/jpeg;base64,...",
  "civilIdBack": "data:image/jpeg;base64,...",
  "email": "ahmad@example.com"
}
```

### 5. Use JWT Token

All authenticated requests require the JWT token:

```bash
GET /api/v1/auth/profile
Authorization: Bearer <your-jwt-token>
```

## 📖 API Endpoints

### Authentication
- `POST /api/v1/auth/check-phone` - Check if phone exists
- `POST /api/v1/auth/send-otp` - Send OTP code
- `POST /api/v1/auth/verify-otp` - Verify OTP code
- `POST /api/v1/auth/create-account` - Create new account
- `GET /api/v1/auth/profile` - Get user profile

### Users
- `GET /api/v1/users/me` - Get current user
- `PUT /api/v1/users/profile` - Update profile

### Payments
- `GET /api/v1/payments` - Get all payments
- `GET /api/v1/payments/pending` - Get pending payments
- `GET /api/v1/payments/history` - Get payment history
- `GET /api/v1/payments/:id` - Get payment by ID
- `POST /api/v1/payments/:id/pay` - Process payment
- `PUT /api/v1/payments/:id/extend` - Extend due date

### Rewards
- `GET /api/v1/rewards/points` - Get current points
- `GET /api/v1/rewards/history` - Get points history
- `POST /api/v1/rewards/redeem` - Redeem points

### Postponements
- `GET /api/v1/postponements/can-postpone` - Check if can postpone
- `POST /api/v1/postponements/postpone-free` - Free postponement
- `GET /api/v1/postponements/history` - Get postponement history

### Stores
- `GET /api/v1/stores` - Get all stores
- `GET /api/v1/stores/deals` - Get stores with deals
- `GET /api/v1/stores/search` - Search stores
- `GET /api/v1/stores/:id` - Get store by ID

### Products
- `GET /api/v1/products/store/:storeId` - Get products by store
- `GET /api/v1/products/search` - Search products
- `GET /api/v1/products/:id` - Get product by ID

### Notifications
- `GET /api/v1/notifications` - Get all notifications
- `PUT /api/v1/notifications/:id/read` - Mark as read
- `PUT /api/v1/notifications/read-all` - Mark all as read
- `DELETE /api/v1/notifications/:id` - Delete notification

## 🧪 Testing

```bash
# Unit tests
npm run test

# E2E tests
npm run test:e2e

# Test coverage
npm run test:cov
```

## 🔧 Environment Variables

```env
# Application
NODE_ENV=development
PORT=3000
API_PREFIX=api/v1

# Database
DB_HOST=localhost
DB_PORT=3306
DB_USERNAME=bnpl_user
DB_PASSWORD=bnpl_password
DB_DATABASE=bnpl_db

# JWT
JWT_SECRET=your-super-secret-jwt-key
JWT_EXPIRES_IN=7d

# AWS (for production)
AWS_REGION=us-east-1
AWS_ACCESS_KEY_ID=your-access-key
AWS_SECRET_ACCESS_KEY=your-secret-key
AWS_S3_BUCKET=bnpl-uploads
AWS_SNS_SENDER_ID=BNPL

# OTP
OTP_EXPIRY_MINUTES=5
OTP_LENGTH=6

# Application
DEFAULT_COUNTRY=JO
DEFAULT_CURRENCY=JOD
COMMISSION_RATE=2.5
```

## 📦 Database Schema

### Users
- User profile and authentication
- Civil ID storage
- Phone verification status

### Payments
- Payment transactions
- Installment tracking
- Due dates and extensions

### Stores & Products
- Store information
- Product catalog
- Deals and offers

### Rewards
- Points earned from payments
- Points redemption history

### Postponements
- Free monthly postponements
- Postponement history

### Notifications
- User notifications
- Read/unread status

## 🚢 Deployment

### AWS Deployment

1. **Setup RDS MySQL**
```bash
aws rds create-db-instance \
  --db-instance-identifier bnpl-mysql \
  --db-instance-class db.t3.micro \
  --engine mysql \
  --master-username admin \
  --master-user-password <password> \
  --allocated-storage 20
```

2. **Build Docker Image**
```bash
docker build -t bnpl-backend .
```

3. **Push to ECR**
```bash
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <account>.dkr.ecr.us-east-1.amazonaws.com
docker tag bnpl-backend:latest <account>.dkr.ecr.us-east-1.amazonaws.com/bnpl-backend:latest
docker push <account>.dkr.ecr.us-east-1.amazonaws.com/bnpl-backend:latest
```

4. **Deploy to ECS/EC2**

## 📝 Scripts

```bash
# Development
npm run start:dev       # Start development server with watch
npm run start:debug     # Start with debug mode

# Build
npm run build           # Build for production

# Production
npm run start:prod      # Run production build

# Database
npm run typeorm         # Run TypeORM CLI
npm run migration:generate  # Generate migration
npm run migration:run   # Run migrations
npm run migration:revert    # Revert last migration

# Linting
npm run lint            # Run ESLint
npm run format          # Format code with Prettier
```

## 🏗️ Project Structure

```
backend/
├── src/
│   ├── auth/                 # Authentication module
│   │   ├── dto/             # Data Transfer Objects
│   │   ├── strategies/      # Passport strategies
│   │   ├── guards/          # Auth guards
│   │   ├── auth.controller.ts
│   │   ├── auth.service.ts
│   │   ├── auth.module.ts
│   │   └── otp.service.ts
│   │
│   ├── users/               # Users module
│   │   ├── entities/
│   │   ├── users.controller.ts
│   │   ├── users.service.ts
│   │   └── users.module.ts
│   │
│   ├── payments/            # Payments module
│   ├── stores/              # Stores module
│   ├── products/            # Products module
│   ├── rewards/             # Rewards module
│   ├── postponements/       # Postponements module
│   ├── notifications/       # Notifications module
│   │
│   ├── config/              # Configuration files
│   ├── app.module.ts        # Root module
│   └── main.ts              # Application entry point
│
├── test/                    # Tests
├── .env.example             # Environment variables template
├── docker-compose.yml       # Docker Compose configuration
├── Dockerfile               # Docker image
├── nest-cli.json            # NestJS CLI configuration
├── package.json             # Dependencies
├── tsconfig.json            # TypeScript configuration
└── README.md                # This file
```

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License.

## 📧 Support

For support, email support@bnpl.com or open an issue on GitHub.

---

Built with ❤️ using NestJS, TypeScript, and MySQL

