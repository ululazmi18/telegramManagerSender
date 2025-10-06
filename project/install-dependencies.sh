#!/bin/bash
# Script untuk menginstal semua dependencies yang dibutuhkan di Termux

echo "📦 Installing Dependencies for Telegram App in Termux"
echo "======================================================"
echo ""

# Update packages
echo "🔄 Updating Termux packages..."
pkg update -y && pkg upgrade -y

echo ""
echo "📥 Installing system packages..."
pkg install -y python nodejs-lts git redis clang make curl

echo ""
echo "🔧 Installing node-gyp globally..."
npm install -g node-gyp
echo "✅ node-gyp installed"

echo ""
echo "✅ System packages installed"
echo ""

# Get the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Install Python dependencies
echo "🐍 Installing Python dependencies..."
cd "$SCRIPT_DIR/python-service"
if [ -f "requirements.txt" ]; then
    pip install -r requirements.txt
    echo "✅ Python dependencies installed"
else
    echo "⚠️  requirements.txt not found, installing manually..."
    pip install fastapi uvicorn pyrogram tgcrypto
fi

echo ""

# Install Node.js dependencies
echo "🟢 Installing Node.js dependencies..."
cd "$SCRIPT_DIR/backend"
if [ -f "package.json" ]; then
    npm install
    echo "✅ Node.js dependencies installed"
else
    echo "⚠️  package.json not found, installing manually..."
    npm install express cors body-parser dotenv sql.js bullmq ioredis axios multer uuid
fi

echo ""

# Create necessary directories
echo "📁 Creating necessary directories..."
cd "$SCRIPT_DIR"
mkdir -p db
mkdir -p logs
echo "✅ Directories created"

echo ""

# Check if .env exists
if [ ! -f "$SCRIPT_DIR/.env" ]; then
    echo "⚠️  File .env tidak ditemukan!"
    if [ -f "$SCRIPT_DIR/.env.example" ]; then
        echo "📝 Membuat .env dari .env.example..."
        cp "$SCRIPT_DIR/.env.example" "$SCRIPT_DIR/.env"
        echo "✅ File .env dibuat.
    else
        echo "❌ File .env.example juga tidak ditemukan!"
    fi
else
    echo "✅ File .env sudah ada"
fi

echo ""
echo "======================================================"
echo "✅ Installation Complete!"
echo "======================================================"
echo ""
echo "📋 Langkah selanjutnya - Jalankan setiap service:"
echo ""
echo "1. Start Redis:"
echo "   redis-server --daemonize yes --ignore-warnings ARM64-COW-BUG"
echo ""
echo "2. Start Python Service (Terminal 1):"
echo "   cd python-service && python3 app.py"
echo ""
echo "3. Start Node.js Backend (Terminal 2):"
echo "   cd backend && node server.js"
echo ""