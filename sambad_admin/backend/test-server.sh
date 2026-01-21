#!/bin/bash
cd /Users/shamrai/Desktop/sambad/sambad_admin/backend

export ADMIN_DB_USER=postgres
export ADMIN_DB_PASSWORD=changeme
export ADMIN_DB_NAME=sambad_admin
export ADMIN_JWT_SECRET=test-secret-123
export USER_BACKEND_URL=http://localhost:4000/api
export ADMIN_PORT=5050

echo "Starting server..."
npx ts-node src/index.ts 2>&1 &
SERVER_PID=$!
sleep 3

echo "Testing health endpoint..."
curl -s http://localhost:5050/ || echo "Health check failed"

echo ""
echo "Testing login..."
LOGIN_RESPONSE=$(curl -s -X POST http://localhost:5050/login \
  -H "Content-Type: application/json" \
  -d '{"username":"testadmin","password":"TestAdmin123!"}')

echo "$LOGIN_RESPONSE" | head -5

if echo "$LOGIN_RESPONSE" | grep -q "token"; then
  TOKEN=$(echo "$LOGIN_RESPONSE" | grep -o '"token":"[^"]*"' | cut -d'"' -f4)
  echo ""
  echo "Token received, testing protected endpoint..."
  curl -s http://localhost:5050/analytics -H "Authorization: Bearer $TOKEN" | head -10
else
  echo "Login failed!"
fi

kill $SERVER_PID 2>/dev/null
