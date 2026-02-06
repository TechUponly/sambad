#!/bin/bash
cd "$(dirname "$0")"
echo "🚀 Starting Sambad Backend Server..."
echo "📍 Port: 4000"
echo "📁 Directory: $(pwd)"
echo ""
npx ts-node --transpile-only src/index.ts
