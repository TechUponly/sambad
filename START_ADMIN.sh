#!/bin/bash

echo "🚀 Starting Sambad Admin Dashboard..."
echo ""

# Kill existing processes
echo "📋 Cleaning up existing processes..."
lsof -ti:4000 | xargs kill -9 2>/dev/null
pkill -f "flutter.*sambad_admin" 2>/dev/null
sleep 1

# Start backend
echo "🔧 Starting backend server..."
cd "$(dirname "$0")/app_user/backend"
npm run dev > /tmp/sambad-backend.log 2>&1 &
BACKEND_PID=$!
echo "   Backend PID: $BACKEND_PID"

# Wait for backend
echo "⏳ Waiting for backend to start..."
sleep 5

# Check backend
if curl -s http://localhost:4000/ > /dev/null 2>&1; then
    echo "✅ Backend is running on http://localhost:4000"
else
    echo "⚠️  Backend may still be starting..."
    echo "   Check logs: tail -f /tmp/sambad-backend.log"
fi

# Create admin user if needed
echo ""
echo "👤 Checking admin user..."
if ! npx ts-node scripts/create-admin.ts admin admin123 admin@sambad.com superadmin 2>/dev/null; then
    echo "   Admin user may already exist (this is OK)"
fi

# Start Flutter app
echo ""
echo "📱 Starting Flutter admin dashboard..."
cd "$(dirname "$0")/sambad_admin/frontend"
flutter run -d chrome --web-port=8080 > /tmp/flutter-admin.log 2>&1 &
FLUTTER_PID=$!
echo "   Flutter PID: $FLUTTER_PID"

echo ""
echo "✅ All services starting!"
echo ""
echo "📊 Access points:"
echo "   - Flutter Dashboard: http://localhost:8080 (will open automatically)"
echo "   - HTML Dashboard: http://localhost:4000/admin-dashboard/admin-dashboard.html"
echo "   - Backend API: http://localhost:4000/api/admin"
echo ""
echo "🔐 Login credentials:"
echo "   Username: admin"
echo "   Password: admin123"
echo ""
echo "📝 Logs:"
echo "   Backend: tail -f /tmp/sambad-backend.log"
echo "   Flutter: tail -f /tmp/flutter-admin.log"
echo ""
echo "Press Ctrl+C to stop all services"

# Keep script running
wait
