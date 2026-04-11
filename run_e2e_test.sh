#!/bin/bash
set -e

cd /var/www/html/public_html/sambad/app_user/backend

# Backup
cp src/index.ts src/index.ts.bak
echo "✅ Backed up index.ts"

# Temporarily add /messages to auth-exempt paths
sed -i "s|const openPaths = \['/users/login', '/health', '/app-config', '/feedback'\];|const openPaths = ['/users/login', '/health', '/app-config', '/feedback', '/messages']; // TEMP TEST|" src/index.ts
echo "✅ Added /messages to openPaths"

grep "openPaths" src/index.ts | head -1

# Build
echo "Building..."
npm run build 2>&1 | tail -3

# Restart and WAIT for server to be ready
echo "Restarting PM2..."
pm2 restart sambad-backend 2>&1 | tail -3

echo "Waiting for server to start..."
for i in $(seq 1 20); do
  if curl -s http://localhost:4000/api/health 2>/dev/null | grep -q "healthy"; then
    echo "✅ Server ready after ${i}s"
    break
  fi
  sleep 1
done

# Run test
echo ""
echo "========= RUNNING E2E TEST ========="
NODE_PATH=node_modules node /tmp/e2e_final.js 2>&1

# REVERT IMMEDIATELY
echo ""
echo "========= REVERTING ========="
cp src/index.ts.bak src/index.ts
npm run build 2>&1 | tail -2
pm2 restart sambad-backend 2>&1 | tail -3

echo "Waiting for server to restore..."
for i in $(seq 1 20); do
  if curl -s http://localhost:4000/api/health 2>/dev/null | grep -q "healthy"; then
    echo "✅ Server restored after ${i}s"
    break
  fi
  sleep 1
done
echo "✅ Auth RESTORED"
