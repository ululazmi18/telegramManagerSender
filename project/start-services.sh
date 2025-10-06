#!/bin/bash
# Script untuk menjalankan semua services di Termux

echo "🚀 Starting Telegram App Services..."
echo ""

# Check if Redis is running
echo "📡 Checking Redis..."
if ! redis-cli ping > /dev/null 2>&1; then
    echo "❌ Redis tidak berjalan. Memulai Redis..."
    redis-server --daemonize yes --ignore-warnings ARM64-COW-BUG
    sleep 2
    if redis-cli ping > /dev/null 2>&1; then
        echo "✅ Redis started successfully"
    else
        echo "❌ Failed to start Redis"
        exit 1
    fi
else
    echo "✅ Redis sudah berjalan"
fi

echo ""

# Get the directory where the script is located
SCRIPT_DIR="$(pwd)"

# Start Python Service
echo "🐍 Starting Python Service..."
cd "$SCRIPT_DIR/python-service"

# Check which Python command is available
if command -v python3 &> /dev/null; then
    PYTHON_CMD="python3"
elif command -v python &> /dev/null; then
    PYTHON_CMD="python"
else
    echo "❌ Python not found!"
    exit 1
fi

$PYTHON_CMD app.py > "$SCRIPT_DIR/logs/python-service.log" 2>&1 &
PYTHON_PID=$!
echo "✅ Python Service started (PID: $PYTHON_PID)"

# Wait a bit for Python service to start
sleep 3

# Start Node.js Backend
echo "🟢 Starting Node.js Backend..."
cd "$SCRIPT_DIR/backend"
node server.js > "$SCRIPT_DIR/logs/nodejs-backend.log" 2>&1 &
NODE_PID=$!
echo "✅ Node.js Backend started (PID: $NODE_PID)"

# Wait a bit for services to fully start
sleep 3

echo ""
echo "🔍 Verifying services..."
echo ""

# Test Python Service
if curl -s http://localhost:8000/health > /dev/null; then
    echo "✅ Python Service (port 8000): RUNNING"
else
    echo "❌ Python Service (port 8000): NOT RESPONDING"
fi

# Test Node.js Backend
if curl -s http://localhost:3000/health > /dev/null; then
    echo "✅ Node.js Backend (port 3000): RUNNING"
else
    echo "❌ Node.js Backend (port 3000): NOT RESPONDING"
fi

echo ""
echo "📝 Process IDs:"
echo "   Python Service: $PYTHON_PID"
echo "   Node.js Backend: $NODE_PID"
echo ""
echo "📋 Logs tersimpan di:"
echo "   Python: $SCRIPT_DIR/logs/python-service.log"
echo "   Node.js: $SCRIPT_DIR/logs/nodejs-backend.log"
echo ""
echo "🛑 Untuk menghentikan services, jalankan: ./stop-services.sh"
echo "   Atau kill manual: kill $PYTHON_PID $NODE_PID"
