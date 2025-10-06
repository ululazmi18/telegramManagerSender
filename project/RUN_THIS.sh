#!/bin/bash
# Complete setup script - Copy paste semua command ini ke terminal

echo "🚀 Termux Complete Setup & Fix"
echo "======================================================"
echo ""

# Pindah ke project directory
cd ~/project || { echo "❌ Directory ~/project tidak ada"; exit 1; }

echo "Step 1/8: Installing Python setuptools..."
pip install --no-cache-dir setuptools

echo ""
echo "Step 2/8: Configuring Redis..."
cat > ~/redis.conf << 'EOF'
bind 127.0.0.1
port 6379
daemonize yes
ignore-warnings ARM64-COW-BUG
dir /data/data/com.termux/files/home/
EOF

redis-cli shutdown 2>/dev/null || true
sleep 1
redis-server ~/redis.conf
sleep 2

if redis-cli ping > /dev/null 2>&1; then
    echo "✅ Redis running"
else
    echo "❌ Redis failed"
fi

echo ""
echo "Step 3/8: Cleaning old Python packages..."
pip uninstall -y fastapi uvicorn pydantic starlette 2>/dev/null || true

echo ""
echo "Step 4/8: Installing Python packages (compatible versions)..."
pip install --no-cache-dir 'fastapi==0.95.0' 'uvicorn==0.21.0' 'pydantic==1.10.7' 'pyrogram==2.0.106'

echo ""
echo "Step 5/8: Testing Python imports..."
python -c "import fastapi; print('✅ FastAPI imported')"
python -c "import pyrogram; print('✅ Pyrogram imported')"

echo ""
echo "Step 6/8: Cleaning Node.js modules..."
cd backend
rm -rf node_modules package-lock.json

echo ""
echo "Step 7/8: Installing Node.js packages (this may take a while)..."
npm install --no-optional express cors body-parser dotenv axios bullmq ioredis

echo ""
echo "Step 8/8: Attempting sqlite3 installation..."
npm install sqlite3 --build-from-source 2>/dev/null && echo "✅ sqlite3 installed" || echo "⚠️  sqlite3 failed (app may still work)"

cd ..

echo ""
echo "======================================================"
echo "✅ Setup Complete!"
echo "======================================================"
echo ""
echo "📋 Next: Run the services"
echo ""
echo "Terminal 1 (Python Service):"
echo "  cd ~/project/python-service"
echo "  python app.py"
echo ""
echo "Terminal 2 (Node.js Backend):"
echo "  cd ~/project/backend"
echo "  node server.js"
echo ""
echo "Verify:"
echo "  curl http://localhost:8000/health"
echo "  curl http://localhost:3000/health"
echo ""
