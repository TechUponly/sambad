#!/bin/bash

# Start backend with proper error handling
cd "$(dirname "$0")"

echo "🚀 Starting Sambad Backend Server..."
echo ""

# Check if port 4000 is already in use
if lsof -i :4000 > /dev/null 2>&1; then
    echo "⚠️  Port 4000 is already in use. Stopping existing process..."
    lsof -ti :4000 | xargs kill -9 2>/dev/null
    sleep 2
fi

# Check if node_modules exists
if [ ! -d "node_modules" ]; then
    echo "📦 Installing dependencies..."
    npm install
fi

# Start the server
echo "✅ Starting backend on port 4000..."
echo ""
npm run dev
