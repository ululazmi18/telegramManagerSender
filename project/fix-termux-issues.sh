#!/bin/bash
# Fix untuk masalah-masalah di Termux

echo "🔧 Fixing Termux Issues..."
echo "======================================================"
echo ""

cd ~/project

# 1. Install setuptools untuk node-gyp
echo "📦 Step 1: Installing Python setuptools..."
pip install --no-cache-dir setuptools
echo "✅ Setuptools installed"
echo ""

# 2. Fix Redis config
echo "🔴 Step 2: Fixing Redis configuration..."
cat > ~/redis.conf << 'EOF'
# Redis config for Termux
bind 127.0.0.1
port 6379
daemonize yes
ignore-warnings ARM64-COW-BUG
save 900 1
save 300 10
save 60 10000
dir /data/data/com.termux/files/home/
EOF

# Stop any existing Redis
redis-cli shutdown 2>/dev/null || true
sleep 2

# Start Redis with config
redis-server ~/redis.conf
sleep 2

if redis-cli ping > /dev/null 2>&1; then
    echo "✅ Redis started successfully"
else
    echo "❌ Redis failed to start"
fi
echo ""

# 3. Fix Python dependencies
echo "🐍 Step 3: Installing compatible Python packages..."
pip uninstall -y fastapi uvicorn pydantic starlette 2>/dev/null || true
pip install --no-cache-dir 'fastapi==0.95.0' 'uvicorn==0.21.0' 'pydantic==1.10.7' 'pyrogram==2.0.106'
echo "✅ Python packages installed"
echo ""

# 4. Install Node.js dependencies (skip problematic ones)
echo "🟢 Step 4: Installing Node.js dependencies..."
cd backend

# Remove existing node_modules
rm -rf node_modules package-lock.json

# Install core dependencies first
npm install --no-optional express cors body-parser axios

# Install dotenv
npm install dotenv

# Try to install bullmq and ioredis
npm install bullmq ioredis

# Try sqlite3 with fallback
echo "📦 Attempting to install sqlite3..."
if npm install sqlite3 --build-from-source 2>/dev/null; then
    echo "✅ sqlite3 installed successfully"
else
    echo "⚠️  sqlite3 compilation failed, will use alternative"
    npm install better-sqlite3 --build-from-source 2>/dev/null || echo "⚠️  Using fallback mode"
fi

echo ""
echo "======================================================"
echo "✅ Fix Complete!"
echo "======================================================"
echo ""
echo "📋 Next steps:"
echo ""
echo "1. Verify installations:"
echo "   python -c 'import fastapi; print(\"FastAPI OK\")'"
echo "   redis-cli ping"
echo ""
echo "2. Test Python service:"
echo "   cd ~/project/python-service"
echo "   python app.py"
echo ""
echo "3. Test Node.js backend (in new terminal):"
echo "   cd ~/project/backend"
echo "   node server.js"
echo ""
