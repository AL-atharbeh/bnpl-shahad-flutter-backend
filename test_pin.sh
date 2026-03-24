#!/bin/bash

# 🔐 سكريبت اختبار PIN السريع
# Usage: ./test_pin.sh YOUR_JWT_TOKEN

set -e

BASE_URL="http://localhost:3000/api/v1"
TOKEN="${1:-}"

if [ -z "$TOKEN" ]; then
    echo "❌ خطأ: يجب توفير JWT Token"
    echo "Usage: ./test_pin.sh YOUR_JWT_TOKEN"
    echo ""
    echo "للحصول على Token:"
    echo "1. سجل دخول في Flutter App"
    echo "2. افتح DevTools → Network"
    echo "3. ابحث عن request يحتوي على Authorization header"
    exit 1
fi

echo "🔐 اختبار PIN Security Features"
echo "================================"
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test 1: Get Security Settings
echo "📋 Test 1: الحصول على Security Settings"
echo "----------------------------------------"
RESPONSE=$(curl -s -X GET "${BASE_URL}/security/settings" \
  -H "Authorization: Bearer ${TOKEN}" \
  -H "Content-Type: application/json")

echo "$RESPONSE" | jq '.' 2>/dev/null || echo "$RESPONSE"
echo ""

# Test 2: Set PIN
echo "🔑 Test 2: تعيين PIN (1234)"
echo "----------------------------------------"
RESPONSE=$(curl -s -X POST "${BASE_URL}/security/pin" \
  -H "Authorization: Bearer ${TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{"pin": "1234"}')

echo "$RESPONSE" | jq '.' 2>/dev/null || echo "$RESPONSE"
echo ""

# Wait a bit
sleep 1

# Test 3: Verify PIN (correct)
echo "✅ Test 3: التحقق من PIN (صحيح: 1234)"
echo "----------------------------------------"
RESPONSE=$(curl -s -X POST "${BASE_URL}/security/pin/verify" \
  -H "Authorization: Bearer ${TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{"pin": "1234"}')

echo "$RESPONSE" | jq '.' 2>/dev/null || echo "$RESPONSE"
IS_VALID=$(echo "$RESPONSE" | jq -r '.data.isValid' 2>/dev/null || echo "unknown")

if [ "$IS_VALID" = "true" ]; then
    echo -e "${GREEN}✅ PIN صحيح!${NC}"
else
    echo -e "${RED}❌ PIN غير صحيح${NC}"
fi
echo ""

# Test 4: Verify PIN (wrong)
echo "❌ Test 4: التحقق من PIN (خاطئ: 9999)"
echo "----------------------------------------"
RESPONSE=$(curl -s -X POST "${BASE_URL}/security/pin/verify" \
  -H "Authorization: Bearer ${TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{"pin": "9999"}')

echo "$RESPONSE" | jq '.' 2>/dev/null || echo "$RESPONSE"
IS_VALID=$(echo "$RESPONSE" | jq -r '.data.isValid' 2>/dev/null || echo "unknown")

if [ "$IS_VALID" = "false" ]; then
    echo -e "${GREEN}✅ PIN خاطئ (كما هو متوقع)${NC}"
else
    echo -e "${RED}❌ خطأ: PIN خاطئ يجب أن يرجع false${NC}"
fi
echo ""

# Test 5: Get Settings Again
echo "📋 Test 5: الحصول على Settings مرة أخرى"
echo "----------------------------------------"
RESPONSE=$(curl -s -X GET "${BASE_URL}/security/settings" \
  -H "Authorization: Bearer ${TOKEN}" \
  -H "Content-Type: application/json")

echo "$RESPONSE" | jq '.' 2>/dev/null || echo "$RESPONSE"
PIN_ENABLED=$(echo "$RESPONSE" | jq -r '.data.pinEnabled' 2>/dev/null || echo "unknown")

if [ "$PIN_ENABLED" = "true" ]; then
    echo -e "${GREEN}✅ PIN مفعل في Settings${NC}"
else
    echo -e "${RED}❌ PIN غير مفعل في Settings${NC}"
fi
echo ""

echo "================================"
echo "✅ انتهى الاختبار!"
echo ""
echo "💡 ملاحظات:"
echo "   - تحقق من قاعدة البيانات: SELECT * FROM user_security_settings;"
echo "   - تحقق من Flutter App: يجب أن يظهر 'مفعل'"
echo ""

