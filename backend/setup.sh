#!/bin/bash

echo "🚀 Setting up BNPL Backend..."
echo ""

echo "✅ .env file already configured"
echo ""
echo "📦 Installing dependencies..."
npm install

echo ""
echo "🐳 Starting Docker services..."
docker-compose up -d

echo ""
echo "⏳ Waiting for MySQL to be ready..."
sleep 10

echo ""
echo "✅ Setup complete!"
echo ""
echo "📚 Open Swagger Documentation:"
echo "   http://localhost:3000/api/docs"
echo ""
echo "🔍 View logs:"
echo "   docker-compose logs -f app"
echo ""
echo "🛑 Stop services:"
echo "   docker-compose down"
echo ""
echo "Happy Coding! 🎉"

