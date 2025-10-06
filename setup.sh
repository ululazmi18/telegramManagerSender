#!/bin/bash
# Setup lengkap untuk Termux - Telegram Campaign Manager
# Otomatis handle Python 3.12 compatibility & fallback ke Flask jika perlu
# Jalankan: bash setup.sh

BASEDIR="$(cd "$(dirname "$0")" && pwd)"
cd "$BASEDIR"

echo "🚀 Setup Telegram Campaign Manager untuk Termux"
echo "================================================"

# 1. Install paket Termux yang diperlukan
echo ""
echo "📦 Step 1: Install Termux packages..."
pkg update -y & pkg upgrade -y
pkg install -y python nodejs-lts redis make clang openssh iproute2 net-tools curl tar bash gzip ldd wget which git

# 2. Install dependencies Python
echo ""
echo "🐍 Step 2: Install Python dependencies..."
cd "$BASEDIR/python-service"
pip install --upgrade pip

# Uninstall package lama yang conflict
echo "Cleaning old packages..."
pip uninstall -y fastapi uvicorn pydantic starlette 2>/dev/null || true

# Install Pydantic v2 yang kompatibel dengan Python 3.12
echo "Installing FastAPI + Pydantic v2..."
if pip install --no-cache-dir pydantic==2.5.0 fastapi==0.109.0 uvicorn==0.25.0 pyrogram==2.0.106; then
    if python -c "from fastapi import FastAPI" 2>/dev/null; then
        echo "✅ FastAPI installed successfully"
    else
        echo "⚠️ FastAPI import failed, switching to Flask..."
        pip uninstall -y fastapi uvicorn pydantic 2>/dev/null || true
        pip install --no-cache-dir flask flask-cors pyrogram==2.0.106
        if [ -f "app_flask.py" ]; then
            mv app.py app_fastapi_backup.py 2>/dev/null || true
            cp app_flask.py app.py
            echo "✅ Flask activated"
        fi
    fi
else
    echo "⚠️ FastAPI install failed, using Flask..."
    pip install --no-cache-dir flask flask-cors pyrogram==2.0.106
    if [ -f "app_flask.py" ]; then
        mv app.py app_fastapi_backup.py 2>/dev/null || true
        cp app_flask.py app.py
        echo "✅ Flask activated"
    fi
fi

# 3. Install dependencies Node.js Backend
echo ""
echo "🟢 Step 3: Install Node.js Backend dependencies..."
cd "$BASEDIR/backend"
npm install

# 4. Install dependencies Frontend
echo ""
echo "⚛️  Step 4: Install Frontend dependencies..."
cd "$BASEDIR/frontend"
npm install

# 5. Setup direktori
echo ""
echo "📁 Step 5: Setup directories..."
cd "$BASEDIR"
mkdir -p logs db uploads backend/uploads

# 6. Buat Redis config untuk Termux
echo ""
echo "💾 Step 6: Setup Redis config..."
cat > "$BASEDIR/redis.conf" <<EOF
# Redis config untuk Termux
port 6379
bind 127.0.0.1
daemonize no
ignore-warnings ARM64-COW-BUG
save ""
appendonly no
EOF
echo "✅ Redis config dibuat"

# 7. Copy .env jika belum ada
if [ ! -f "$BASEDIR/.env" ]; then
    if [ -f "$BASEDIR/.env.example" ]; then
        echo ""
        echo "📝 Copy .env.example ke .env"
        cp "$BASEDIR/.env.example" "$BASEDIR/.env"
        echo "⚠️  Edit .env dengan API keys Anda!"
    fi
fi

echo ""
echo "================================================"
echo "✅ Setup selesai!"
echo "================================================"
echo ""
echo "⚠️  PENTING: Jalankan Redis TERLEBIH DAHULU!"
echo ""
echo "📋 Buka 4 terminal terpisah dan jalankan (BERURUTAN):"
echo ""
echo "# Terminal 1 - Redis:"
echo "bash start-redis.sh"
echo ""
echo "# Terminal 2 - Python Service:"
echo "bash start-python.sh"
echo ""
echo "# Terminal 3 - Backend:"
echo "bash start-backend.sh"
echo ""
echo "# Terminal 4 - Frontend:"
echo "bash start-frontend.sh"
echo ""
echo "================================================"
