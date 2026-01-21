#!/bin/bash

echo "=========================================="
echo "🔍 Sambad WebSocket Sync Diagnostic Tool"
echo "=========================================="
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check 1: Backend Server Status
echo "1️⃣  Checking Backend Server (port 4000)..."
if lsof -i :4000 > /dev/null 2>&1; then
    echo -e "   ${GREEN}✅ Backend server is running on port 4000${NC}"
    BACKEND_RUNNING=true
else
    echo -e "   ${RED}❌ Backend server is NOT running on port 4000${NC}"
    echo -e "   ${YELLOW}   → Start it with: cd app_user/backend && npm run dev${NC}"
    BACKEND_RUNNING=false
fi
echo ""

# Check 2: HTTP Health Check
echo "2️⃣  Testing Backend HTTP Endpoint..."
if [ "$BACKEND_RUNNING" = true ]; then
    HTTP_RESPONSE=$(curl -s -w "\n%{http_code}" http://localhost:4000/ 2>/dev/null)
    HTTP_BODY=$(echo "$HTTP_RESPONSE" | head -n -1)
    HTTP_CODE=$(echo "$HTTP_RESPONSE" | tail -n 1)
    
    if [ "$HTTP_CODE" = "200" ]; then
        echo -e "   ${GREEN}✅ Backend HTTP endpoint is responding (200 OK)${NC}"
    else
        echo -e "   ${RED}❌ Backend HTTP endpoint returned: $HTTP_CODE${NC}"
    fi
else
    echo -e "   ${YELLOW}⚠️  Skipping (backend not running)${NC}"
fi
echo ""

# Check 3: WebSocket Endpoint (basic check)
echo "3️⃣  Checking WebSocket Endpoint (/ws)..."
if [ "$BACKEND_RUNNING" = true ]; then
    # Try to connect to WebSocket using curl (may not work, but shows if port is open)
    WS_CHECK=$(curl -s -I http://localhost:4000/ws 2>&1 | head -1)
    if echo "$WS_CHECK" | grep -q "HTTP\|Connection"; then
        echo -e "   ${GREEN}✅ WebSocket endpoint is accessible${NC}"
    else
        echo -e "   ${YELLOW}⚠️  WebSocket endpoint status unclear (this is normal for WS)${NC}"
    fi
else
    echo -e "   ${YELLOW}⚠️  Skipping (backend not running)${NC}"
fi
echo ""

# Check 4: Admin API Endpoints
echo "4️⃣  Testing Admin API Endpoints..."
if [ "$BACKEND_RUNNING" = true ]; then
    # Check analytics endpoint (may require auth, but we check if it responds)
    ANALYTICS_CHECK=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:4000/api/admin/analytics 2>/dev/null)
    if [ "$ANALYTICS_CHECK" = "401" ] || [ "$ANALYTICS_CHECK" = "200" ]; then
        echo -e "   ${GREEN}✅ Admin analytics endpoint is responding${NC}"
    else
        echo -e "   ${YELLOW}⚠️  Admin analytics endpoint returned: $ANALYTICS_CHECK${NC}"
    fi
    
    ACTIVITY_CHECK=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:4000/api/admin/activity 2>/dev/null)
    if [ "$ACTIVITY_CHECK" = "401" ] || [ "$ACTIVITY_CHECK" = "200" ]; then
        echo -e "   ${GREEN}✅ Admin activity endpoint is responding${NC}"
    else
        echo -e "   ${YELLOW}⚠️  Admin activity endpoint returned: $ACTIVITY_CHECK${NC}"
    fi
else
    echo -e "   ${YELLOW}⚠️  Skipping (backend not running)${NC}"
fi
echo ""

# Check 5: Database Connection (indirect check via API)
echo "5️⃣  Checking Database Connection..."
if [ "$BACKEND_RUNNING" = true ]; then
    # Try to get users list (will show if DB is connected)
    USERS_CHECK=$(curl -s http://localhost:4000/api/users 2>/dev/null)
    if echo "$USERS_CHECK" | grep -q "\[\]\|id\|username"; then
        echo -e "   ${GREEN}✅ Database appears to be connected${NC}"
        # Count users
        USER_COUNT=$(echo "$USERS_CHECK" | grep -o '"id"' | wc -l | tr -d ' ')
        echo "   → Found $USER_COUNT user(s) in database"
    else
        echo -e "   ${YELLOW}⚠️  Could not verify database connection${NC}"
    fi
else
    echo -e "   ${YELLOW}⚠️  Skipping (backend not running)${NC}"
fi
echo ""

# Check 6: Dashboard (Flutter Web)
echo "6️⃣  Checking Dashboard (Flutter Web on port 8080)..."
if lsof -i :8080 > /dev/null 2>&1; then
    echo -e "   ${GREEN}✅ Dashboard is running on port 8080${NC}"
    echo "   → Access at: http://localhost:8080"
else
    echo -e "   ${YELLOW}⚠️  Dashboard is NOT running on port 8080${NC}"
    echo -e "   ${YELLOW}   → Start it with: cd sambad_admin/frontend && flutter run -d chrome --web-port=8080${NC}"
fi
echo ""

# Check 7: Recent Activity Check
echo "7️⃣  Checking Recent Activity Data..."
if [ "$BACKEND_RUNNING" = true ]; then
    # Try to check contacts
    CONTACTS=$(curl -s http://localhost:4000/api/contacts 2>/dev/null)
    CONTACT_COUNT=$(echo "$CONTACTS" | grep -o '"id"' | wc -l | tr -d ' ')
    echo "   → Found $CONTACT_COUNT contact(s) in database"
    
    # Try to check messages
    MESSAGES=$(curl -s http://localhost:4000/api/messages 2>/dev/null)
    MESSAGE_COUNT=$(echo "$MESSAGES" | grep -o '"id"' | wc -l | tr -d ' ')
    echo "   → Found $MESSAGE_COUNT message(s) in database"
    
    if [ "$CONTACT_COUNT" -gt 0 ] || [ "$MESSAGE_COUNT" -gt 0 ]; then
        echo -e "   ${GREEN}✅ Database contains activity data${NC}"
    else
        echo -e "   ${YELLOW}⚠️  No activity data found (might be expected if nothing was synced yet)${NC}"
    fi
else
    echo -e "   ${YELLOW}⚠️  Skipping (backend not running)${NC}"
fi
echo ""

# Summary
echo "=========================================="
echo "📊 Summary"
echo "=========================================="
if [ "$BACKEND_RUNNING" = true ]; then
    echo -e "   ${GREEN}✅ Backend: Running${NC}"
else
    echo -e "   ${RED}❌ Backend: Not Running${NC}"
fi

if lsof -i :8080 > /dev/null 2>&1; then
    echo -e "   ${GREEN}✅ Dashboard: Running${NC}"
else
    echo -e "   ${RED}❌ Dashboard: Not Running${NC}"
fi
echo ""

echo "💡 Next Steps:"
if [ "$BACKEND_RUNNING" != true ]; then
    echo "   1. Start backend: cd app_user/backend && npm run dev"
fi
if ! lsof -i :8080 > /dev/null 2>&1; then
    echo "   2. Start dashboard: cd sambad_admin/frontend && flutter run -d chrome --web-port=8080"
fi
if [ "$BACKEND_RUNNING" = true ] && lsof -i :8080 > /dev/null 2>&1; then
    echo "   1. Open dashboard: http://localhost:8080"
    echo "   2. Login with: 7718811069 / Taksh@060921"
    echo "   3. Check browser console (F12) for WebSocket connection status"
    echo "   4. Add a contact or send a message from Android app to test real-time sync"
fi
echo ""
