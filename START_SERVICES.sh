#!/bin/bash

# Master script to start all services for Sambad WebSocket Sync
# This ensures everything is running in the correct order

echo "🚀 Starting Sambad Services for WebSocket Sync"
echo "================================================"
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to check if port is in use
check_port() {
    local port=$1
    if lsof -i :$port > /dev/null 2>&1; then
        return 0  # Port is in use
    else
        return 1  # Port is free
    fi
}

# Function to kill process on port
kill_port() {
    local port=$1
    echo -e "${YELLOW}⚠️  Port $port is in use. Stopping existing process...${NC}"
    lsof -ti :$port | xargs kill -9 2>/dev/null
    sleep 2
}

# Step 1: Start Backend (Port 4000)
echo "1️⃣  Starting Backend Server (Port 4000)..."
if check_port 4000; then
    kill_port 4000
fi

cd /Users/shamrai/Desktop/sambad/app_user/backend

# Check if dependencies are installed
if [ ! -d "node_modules" ]; then
    echo -e "${YELLOW}📦 Installing dependencies...${NC}"
    npm install
fi

# Start backend in background
echo -e "${GREEN}✅ Starting backend server...${NC}"
npm run dev > /tmp/backend_startup.log 2>&1 &
BACKEND_PID=$!

echo "   Backend PID: $BACKEND_PID"
echo "   Logs: tail -f /tmp/backend_startup.log"

# Wait for backend to start
echo "   Waiting for backend to initialize..."
for i in {1..20}; do
    if check_port 4000; then
        break
    fi
    echo "   Attempt $i/20: Waiting for backend..."
    sleep 2
done

# Verify backend is running
if check_port 4000; then
    echo -e "${GREEN}   ✅ Backend is running on port 4000${NC}"
    
    # Test health endpoint
    if curl -s http://localhost:4000/ > /dev/null 2>&1; then
        echo -e "${GREEN}   ✅ Backend is responding${NC}"
    else
        echo -e "${RED}   ⚠️  Backend started but not responding${NC}"
    fi
else
    echo -e "${RED}   ❌ Backend failed to start${NC}"
    echo "   Check logs: tail -20 /tmp/backend_startup.log"
    exit 1
fi

echo ""

# Step 2: Check Dashboard (Port 8080)
echo "2️⃣  Checking Dashboard (Port 8080)..."
if check_port 8080; then
    echo -e "${GREEN}   ✅ Dashboard is already running on port 8080${NC}"
    echo "   → Access at: http://localhost:8080"
else
    echo -e "${YELLOW}   ⚠️  Dashboard is not running${NC}"
    echo "   To start dashboard:"
    echo "   cd /Users/shamrai/Desktop/sambad/sambad_admin/frontend"
    echo "   flutter run -d chrome --web-port=8080"
fi

echo ""

# Step 3: Summary
echo "================================================"
echo "📊 Service Status"
echo "================================================"
echo ""

if check_port 4000; then
    echo -e "${GREEN}✅ Backend: Running on port 4000${NC}"
    echo "   → Health: http://localhost:4000/"
    echo "   → WebSocket: ws://localhost:4000/ws"
else
    echo -e "${RED}❌ Backend: Not running${NC}"
fi

if check_port 8080; then
    echo -e "${GREEN}✅ Dashboard: Running on port 8080${NC}"
    echo "   → Access: http://localhost:8080"
else
    echo -e "${YELLOW}⚠️  Dashboard: Not running${NC}"
fi

echo ""

# Step 4: Instructions
echo "================================================"
echo "💡 Next Steps"
echo "================================================"
echo ""
echo "1. Open Dashboard: http://localhost:8080"
echo "2. Login: 7718811069 / Taksh@060921"
echo "3. Open Browser Console (F12)"
echo "4. Look for: '🔌 Connecting to WebSocket: ws://localhost:4000/ws'"
echo "5. From Android app: Add a contact or send a message"
echo "6. Dashboard should update immediately in 'Recent Activity'"
echo ""
echo "🔍 To monitor backend logs:"
echo "   tail -f /tmp/backend_startup.log"
echo ""
echo "🔍 To check system status:"
echo "   ./check_sync_status.sh"
echo ""
