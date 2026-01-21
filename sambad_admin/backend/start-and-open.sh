#!/bin/bash
cd /Users/shamrai/Desktop/sambad/sambad_admin/backend

# Kill any existing processes
killall -9 node 2>/dev/null
sleep 2

# Set environment variables
export ADMIN_DB_USER=postgres
export ADMIN_DB_PASSWORD=changeme
export ADMIN_DB_NAME=sambad_admin
export ADMIN_JWT_SECRET=test-secret-123
export USER_BACKEND_URL=http://localhost:4000/api
export ADMIN_PORT=5050

echo "Starting Sambad Admin Backend..."
echo "Environment configured:"
echo "  - Database: $ADMIN_DB_NAME"
echo "  - Port: $ADMIN_PORT"
echo ""

# Start server in background
npx ts-node src/index.ts > /tmp/admin-server.log 2>&1 &
SERVER_PID=$!

echo "Server starting (PID: $SERVER_PID)..."
echo "Waiting for server to be ready..."

# Wait for server to start
for i in {1..10}; do
    sleep 1
    if curl -s http://localhost:5050/ > /dev/null 2>&1; then
        echo "✅ Server is running!"
        echo ""
        echo "Opening Chrome..."
        open -a "Google Chrome" http://localhost:5050/ 2>/dev/null || open http://localhost:5050/
        echo ""
        echo "Dashboard URL: http://localhost:5050/"
        echo "Server logs: tail -f /tmp/admin-server.log"
        echo ""
        echo "To stop: kill $SERVER_PID"
        exit 0
    fi
done

echo "❌ Server failed to start"
echo "Check logs: cat /tmp/admin-server.log"
cat /tmp/admin-server.log
exit 1
