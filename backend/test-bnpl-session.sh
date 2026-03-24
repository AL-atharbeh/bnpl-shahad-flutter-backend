#!/bin/bash

BASE_URL="http://localhost:3000/api/v1"

echo "🧪 Testing BNPL Sessions API"
echo "================================"
echo ""

echo "1️⃣ Creating a new BNPL session..."
echo ""

RESPONSE=$(curl -s -X POST "$BASE_URL/sessions/create" \
  -H "Content-Type: application/json" \
  -d '{
    "store_id": 1,
    "store_order_id": "ZARA-TEST-001",
    "total_amount": 400,
    "currency": "JOD",
    "installments_count": 4,
    "customer_phone": "+962791234567",
    "customer_email": "test@example.com",
    "customer_name": "Ahmad Ali",
    "items": [
      {
        "name": "T-Shirt",
        "quantity": 2,
        "price": 200
      },
      {
        "name": "Jeans",
        "quantity": 1,
        "price": 200
      }
    ]
  }')

echo "Response:"
echo "$RESPONSE" | jq '.'
echo ""

SESSION_ID=$(echo "$RESPONSE" | jq -r '.session_id')

if [ "$SESSION_ID" != "null" ] && [ -n "$SESSION_ID" ]; then
  echo "✅ Session created successfully!"
  echo "Session ID: $SESSION_ID"
  echo ""
  
  echo "2️⃣ Getting session details..."
  echo ""
  
  curl -s -X GET "$BASE_URL/sessions/$SESSION_ID" | jq '.'
  echo ""
  
  echo "================================"
  echo "✅ All tests completed!"
  echo ""
  echo "📱 To test in Flutter app, use this deep link:"
  echo "   bnpl://session?id=$SESSION_ID"
  echo ""
else
  echo "❌ Failed to create session"
fi
