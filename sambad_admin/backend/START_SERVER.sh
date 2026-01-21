#!/bin/bash

# Sambad Admin Backend Startup Script
cd /Users/shamrai/Desktop/sambad/sambad_admin/backend

echo "🚀 Starting Sambad Admin Backend..."
echo ""

# Kill any existing processes on port 5050
echo "Cleaning up existing processes..."
lsof -ti:5050 | xargs kill -9 2>/dev/null
killall -9 node 2>/dev/null
sleep 2

# Set environment variables
export ADMIN_DB_USER=postgres
export ADMIN_DB_PASSWORD=changeme
export ADMIN_DB_NAME=sambad_admin
export ADMIN_JWT_SECRET=test-secret-123
export USER_BACKEND_URL=http://localhost:4000/api
export ADMIN_PORT=5050

echo "Environment configured:"
echo "  Database: $ADMIN_DB_NAME"
echo "  Port: $ADMIN_PORT"
echo ""

# Check database connection first
echo "Checking database connection..."
psql -U postgres -d sambad_admin -c "SELECT 1;" > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "✅ Database connection OK"
else
    echo "❌ Database connection failed!"
    echo "   Make sure PostgreSQL is running and credentials are correct"
    exit 1
fi

echo ""
echo "Starting server..."
echo ""

# Start the server (foreground so we can see output)
npx ts-node src/index.ts
