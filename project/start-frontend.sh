#!/bin/bash
# Script untuk menjalankan frontend React

echo "🌐 Starting Telegram Campaign Manager Frontend..."
echo ""

cd ~/project/frontend

# Check if node_modules exists
if [ ! -d "node_modules" ]; then
    echo "📦 Installing frontend dependencies..."
    echo "⚠️  This may take several minutes..."
    npm install
    echo ""
fi

echo "🚀 Starting React development server on port 3001..."
echo ""
echo "🌐 Web interface will be available at:"
echo "   http://localhost:3001"
echo "   http://192.168.1.4:3001 (from other devices on network)"
echo ""
echo "⚠️  Press Ctrl+C to stop"
echo ""

PORT=3001 npm start
