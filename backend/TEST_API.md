# 🧪 Test API Endpoints

## Quick Test Commands

### 1️⃣ Check API is Running

```bash
curl http://localhost:3000/api/v1
```

---

### 2️⃣ Authentication Flow Test

#### A. Check Phone

```bash
curl -X POST http://localhost:3000/api/v1/auth/check-phone \
  -H "Content-Type: application/json" \
  -d '{"phone": "+962799999999"}'
```

#### B. Send OTP

```bash
curl -X POST http://localhost:3000/api/v1/auth/send-otp \
  -H "Content-Type: application/json" \
  -d '{"phone": "+962799999999"}'
```

**⚠️ Check console logs for OTP code:**
```
📱 OTP for +962799999999: 123456
```

#### C. Verify OTP

```bash
curl -X POST http://localhost:3000/api/v1/auth/verify-otp \
  -H "Content-Type: application/json" \
  -d '{
    "phone": "+962799999999",
    "code": "123456"
  }'
```

#### D. Create Account (New User)

```bash
curl -X POST http://localhost:3000/api/v1/auth/create-account \
  -H "Content-Type: application/json" \
  -d '{
    "phone": "+962799999999",
    "fullName": "أحمد محمد الاختبار",
    "civilIdNumber": "2991234567",
    "dateOfBirth": "1990-01-01",
    "address": "Amman, Jordan",
    "monthlyIncome": 1500.00,
    "employer": "Test Company",
    "civilIdFront": "test_image_data_front",
    "civilIdBack": "test_image_data_back",
    "email": "test@example.com"
  }'
```

**📝 Save the returned `token`!**

---

### 3️⃣ Authenticated Requests

#### Set Your Token

```bash
# Replace with your actual token
export TOKEN="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

#### Get Profile

```bash
curl -X GET http://localhost:3000/api/v1/auth/profile \
  -H "Authorization: Bearer $TOKEN"
```

#### Get Current User

```bash
curl -X GET http://localhost:3000/api/v1/users/me \
  -H "Authorization: Bearer $TOKEN"
```

---

### 4️⃣ Payments

#### Get All Payments

```bash
curl -X GET http://localhost:3000/api/v1/payments \
  -H "Authorization: Bearer $TOKEN"
```

#### Get Pending Payments

```bash
curl -X GET http://localhost:3000/api/v1/payments/pending \
  -H "Authorization: Bearer $TOKEN"
```

#### Get Payment History

```bash
curl -X GET "http://localhost:3000/api/v1/payments/history?status=completed" \
  -H "Authorization: Bearer $TOKEN"
```

---

### 5️⃣ Rewards

#### Get Current Points

```bash
curl -X GET http://localhost:3000/api/v1/rewards/points \
  -H "Authorization: Bearer $TOKEN"
```

#### Get Points History

```bash
curl -X GET http://localhost:3000/api/v1/rewards/history \
  -H "Authorization: Bearer $TOKEN"
```

#### Redeem Points

```bash
curl -X POST http://localhost:3000/api/v1/rewards/redeem \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"points": 100}'
```

---

### 6️⃣ Postponements

#### Check If Can Postpone

```bash
curl -X GET http://localhost:3000/api/v1/postponements/can-postpone \
  -H "Authorization: Bearer $TOKEN"
```

#### Use Free Postponement

```bash
curl -X POST http://localhost:3000/api/v1/postponements/postpone-free \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "paymentId": 1,
    "merchantName": "Test Store",
    "amount": 100.00
  }'
```

#### Get Postponement History

```bash
curl -X GET http://localhost:3000/api/v1/postponements/history \
  -H "Authorization: Bearer $TOKEN"
```

---

### 7️⃣ Stores

#### Get All Stores

```bash
curl -X GET http://localhost:3000/api/v1/stores
```

#### Get Stores with Deals

```bash
curl -X GET http://localhost:3000/api/v1/stores/deals
```

#### Search Stores

```bash
curl -X GET "http://localhost:3000/api/v1/stores/search?q=shein"
```

#### Get Store by ID

```bash
curl -X GET http://localhost:3000/api/v1/stores/1
```

---

### 8️⃣ Products

#### Get Products by Store

```bash
curl -X GET http://localhost:3000/api/v1/products/store/1
```

#### Search Products

```bash
curl -X GET "http://localhost:3000/api/v1/products/search?q=shirt"
```

#### Get Product by ID

```bash
curl -X GET http://localhost:3000/api/v1/products/1
```

---

### 9️⃣ Notifications

#### Get All Notifications

```bash
curl -X GET http://localhost:3000/api/v1/notifications \
  -H "Authorization: Bearer $TOKEN"
```

#### Mark as Read

```bash
curl -X PUT http://localhost:3000/api/v1/notifications/1/read \
  -H "Authorization: Bearer $TOKEN"
```

#### Mark All as Read

```bash
curl -X PUT http://localhost:3000/api/v1/notifications/read-all \
  -H "Authorization: Bearer $TOKEN"
```

#### Delete Notification

```bash
curl -X DELETE http://localhost:3000/api/v1/notifications/1 \
  -H "Authorization: Bearer $TOKEN"
```

---

## 🎯 Test Scenarios

### Scenario 1: New User Registration

```bash
# 1. Check phone (should return not exists)
curl -X POST http://localhost:3000/api/v1/auth/check-phone \
  -H "Content-Type: application/json" \
  -d '{"phone": "+962788888888"}'

# 2. Send OTP
curl -X POST http://localhost:3000/api/v1/auth/send-otp \
  -H "Content-Type: application/json" \
  -d '{"phone": "+962788888888"}'

# 3. Get OTP from console logs
# 4. Verify OTP (should return requiresProfileCompletion: true)
curl -X POST http://localhost:3000/api/v1/auth/verify-otp \
  -H "Content-Type: application/json" \
  -d '{"phone": "+962788888888", "code": "123456"}'

# 5. Create account with profile
curl -X POST http://localhost:3000/api/v1/auth/create-account \
  -H "Content-Type: application/json" \
  -d '{
    "phone": "+962788888888",
    "fullName": "محمد أحمد",
    "civilIdNumber": "2881234567",
    "dateOfBirth": "1988-05-15",
    "address": "Irbid, Jordan",
    "monthlyIncome": 2000.00,
    "employer": "Bank",
    "civilIdFront": "test_front",
    "civilIdBack": "test_back"
  }'

# 6. Save token and use it!
```

### Scenario 2: Existing User Login

```bash
# 1. Check phone (should return exists: true)
curl -X POST http://localhost:3000/api/v1/auth/check-phone \
  -H "Content-Type: application/json" \
  -d '{"phone": "+962799999999"}'

# 2. Send OTP
curl -X POST http://localhost:3000/api/v1/auth/send-otp \
  -H "Content-Type: application/json" \
  -d '{"phone": "+962799999999"}'

# 3. Verify OTP (should return token directly)
curl -X POST http://localhost:3000/api/v1/auth/verify-otp \
  -H "Content-Type: application/json" \
  -d '{"phone": "+962799999999", "code": "123456"}'
```

---

## 🔍 Debugging Tips

### View Logs

```bash
# All logs
docker-compose logs -f

# Only app logs
docker-compose logs -f app

# Only MySQL logs
docker-compose logs -f mysql
```

### Connect to MySQL

```bash
docker-compose exec mysql mysql -ubnpl_user -pbnpl_password bnpl_db

# Then run SQL:
SHOW TABLES;
SELECT * FROM users;
SELECT * FROM otp_codes ORDER BY created_at DESC LIMIT 5;
```

### Restart Services

```bash
# Restart app only
docker-compose restart app

# Restart all
docker-compose restart

# Rebuild and restart
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

---

## ✅ Expected Responses

### Successful OTP Send

```json
{
  "success": true,
  "message": "تم إرسال رمز التحقق",
  "data": {
    "phone": "+962799999999",
    "expiresIn": "5 minutes"
  }
}
```

### Successful Account Creation

```json
{
  "success": true,
  "message": "تم إنشاء الحساب بنجاح",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "user": {
      "id": 1,
      "name": "أحمد محمد",
      "phone": "+962799999999",
      "isPhoneVerified": true,
      "country": "JO",
      "currency": "JOD"
    }
  }
}
```

### Error Response

```json
{
  "success": false,
  "statusCode": 400,
  "message": "رمز التحقق غير صحيح",
  "error": "Bad Request"
}
```

---

## 🎉 All Tests Passing?

If all commands work, your backend is **100% ready**! 🚀

Next steps:
1. ✅ Connect Flutter app
2. ✅ Add seed data
3. ✅ Deploy to AWS

---

Happy Testing! 🧪

