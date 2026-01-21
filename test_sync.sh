#!/bin/bash

echo "🧪 Testing WebSocket Sync - Contact Addition"
echo "=============================================="
echo ""

# Start backend if not running
if ! lsof -i :4000 > /dev/null 2>&1; then
    echo "⚠️  Backend not running. Starting it..."
    cd /Users/shamrai/Desktop/sambad/app_user/backend
    npm run dev > /tmp/backend_test.log 2>&1 &
    BACKEND_PID=$!
    echo "   Started backend (PID: $BACKEND_PID)"
    echo "   Waiting for backend to start..."
    sleep 10
else
    echo "✅ Backend is already running"
fi

# Check if backend is responding
echo ""
echo "1️⃣  Checking Backend..."
if curl -s http://localhost:4000/ > /dev/null 2>&1; then
    echo "   ✅ Backend is responding"
else
    echo "   ❌ Backend is not responding"
    echo "   Check logs: tail -f /tmp/backend_test.log"
    exit 1
fi

# Step 1: Get or create two test users
echo ""
echo "2️⃣  Setting up test users..."
USER1_RESPONSE=$(curl -s -X POST http://localhost:4000/api/users/login \
  -H "Content-Type: application/json" \
  -d '{"mobileNumber": "9999999999", "countryCode": "+91"}')

USER1_ID=$(echo $USER1_RESPONSE | grep -o '"id":"[^"]*' | head -1 | cut -d'"' -f4)
echo "   User 1 ID: $USER1_ID"

USER2_RESPONSE=$(curl -s -X POST http://localhost:4000/api/users/login \
  -H "Content-Type: application/json" \
  -d '{"mobileNumber": "8888888888", "countryCode": "+91"}')

USER2_ID=$(echo $USER2_RESPONSE | grep -o '"id":"[^"]*' | head -1 | cut -d'"' -f4)
echo "   User 2 ID: $USER2_ID"

if [ -z "$USER1_ID" ] || [ -z "$USER2_ID" ]; then
    echo "   ❌ Failed to create users"
    exit 1
fi

# Step 2: Add contact (this should trigger WebSocket event)
echo ""
echo "3️⃣  Adding contact (User 1 → User 2)..."
CONTACT_RESPONSE=$(curl -s -X POST http://localhost:4000/api/contacts \
  -H "Content-Type: application/json" \
  -d "{\"userId\": \"$USER1_ID\", \"contactUserId\": \"$USER2_ID\"}")

CONTACT_ID=$(echo $CONTACT_RESPONSE | grep -o '"id":"[^"]*' | head -1 | cut -d'"' -f4)
if [ -n "$CONTACT_ID" ]; then
    echo "   ✅ Contact added successfully! ID: $CONTACT_ID"
    echo "   📡 This should have triggered a WebSocket event: 'contact_added'"
else
    echo "   ❌ Failed to add contact"
    echo "   Response: $CONTACT_RESPONSE"
fi

# Step 3: Check if contact appears in admin API
echo ""
echo "4️⃣  Checking Admin API for the contact..."
sleep 2  # Wait a moment for DB sync

# We need auth token for admin API, but let's check public contacts endpoint
CONTACTS_LIST=$(curl -s http://localhost:4000/api/contacts)
CONTACT_COUNT=$(echo $CONTACTS_LIST | grep -o '"id"' | wc -l | tr -d ' ')
echo "   Found $CONTACT_COUNT contact(s) in database"

if echo $CONTACTS_LIST | grep -q "$CONTACT_ID"; then
    echo "   ✅ Contact is in database!"
else
    echo "   ⚠️  Contact may not be in database yet"
fi

# Step 4: Summary
echo ""
echo "=============================================="
echo "📊 Test Summary"
echo "=============================================="
echo "✅ Backend is running"
echo "✅ Test users created"
if [ -n "$CONTACT_ID" ]; then
    echo "✅ Contact added (ID: $CONTACT_ID)"
    echo ""
    echo "💡 WebSocket Event:"
    echo "   - Event type: 'contact_added'"
    echo "   - Should be broadcast to all connected admin dashboards"
    echo "   - Check browser console for WebSocket messages"
fi
echo ""
echo "🔍 Next Steps:"
echo "   1. Open admin dashboard: http://localhost:8080"
echo "   2. Open browser console (F12)"
echo "   3. Look for: '📨 WebSocket message received: contact_added'"
echo "   4. Check 'Recent Activity' section - should show the new contact"
echo ""
