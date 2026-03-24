#!/bin/bash

# Script لتشغيل BNPL Backend باستخدام Docker

echo "🚀 Starting BNPL Backend with Docker..."
echo ""

# الانتقال إلى مجلد backend
cd "$(dirname "$0")"

# التحقق من وجود Docker
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker Desktop first."
    exit 1
fi

# التحقق من وجود docker-compose
if ! command -v docker-compose &> /dev/null; then
    echo "❌ docker-compose is not installed. Please install Docker Desktop first."
    exit 1
fi

echo "✅ Docker is installed"
echo ""

# إيقاف الـ containers القديمة (إن وجدت)
echo "🛑 Stopping old containers..."
docker-compose down 2>/dev/null

# بناء وإطلاق الـ containers
echo "🏗️  Building and starting containers..."
docker-compose up -d --build

# انتظار قليل حتى تبدأ الخدمات
echo "⏳ Waiting for services to start..."
sleep 5

# التحقق من حالة الخدمات
echo ""
echo "📊 Checking services status..."
docker-compose ps

# التحقق من Backend
echo ""
echo "🔍 Checking Backend API..."
sleep 3

if curl -s http://localhost:3000 > /dev/null; then
    echo "✅ Backend is running on http://localhost:3000"
    echo "✅ Swagger Docs: http://localhost:3000/api/docs"
else
    echo "⚠️  Backend might still be starting. Please wait a moment and check:"
    echo "   http://localhost:3000"
fi

# التحقق من MySQL
echo ""
echo "🔍 Checking MySQL..."
if docker exec bnpl-mysql mysqladmin ping -h localhost --silent 2>/dev/null; then
    echo "✅ MySQL is running"
else
    echo "⚠️  MySQL might still be starting. Please wait a moment."
fi

# التحقق من phpMyAdmin
echo ""
echo "🔍 Checking phpMyAdmin..."
if curl -s http://localhost:8080 > /dev/null; then
    echo "✅ phpMyAdmin is running on http://localhost:8080"
else
    echo "⚠️  phpMyAdmin might still be starting. Please wait a moment."
fi

echo ""
echo "📝 Useful commands:"
echo "   View logs:        docker-compose logs -f app"
echo "   Stop services:    docker-compose down"
echo "   Restart backend:  docker-compose restart app"
echo "   Seed database:    docker exec -it bnpl-backend npm run seed"
echo ""
echo "🎉 Done! Services are starting..."
echo ""

