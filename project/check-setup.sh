#!/bin/bash
# Script untuk mengecek setup dan dependencies

echo "🔍 Checking Telegram App Setup"
echo "======================================================"
echo ""

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Check system packages
echo "📦 Checking System Packages..."
echo ""

command -v python >/dev/null 2>&1 && echo "✅ Python: $(python --version)" || echo "❌ Python: NOT INSTALLED"
command -v node >/dev/null 2>&1 && echo "✅ Node.js: $(node --version)" || echo "❌ Node.js: NOT INSTALLED"
command -v npm >/dev/null 2>&1 && echo "✅ npm: $(npm --version)" || echo "❌ npm: NOT INSTALLED"
command -v redis-server >/dev/null 2>&1 && echo "✅ Redis: $(redis-server --version | head -n1)" || echo "❌ Redis: NOT INSTALLED"
command -v git >/dev/null 2>&1 && echo "✅ Git: $(git --version)" || echo "❌ Git: NOT INSTALLED"

echo ""

# Check Python dependencies
echo "🐍 Checking Python Dependencies..."
echo ""

python -c "import fastapi" 2>/dev/null && echo "✅ FastAPI installed" || echo "❌ FastAPI NOT installed"
python -c "import uvicorn" 2>/dev/null && echo "✅ Uvicorn installed" || echo "❌ Uvicorn NOT installed"
python -c "import pyrogram" 2>/dev/null && echo "✅ Pyrogram installed" || echo "❌ Pyrogram NOT installed"
python -c "import tgcrypto" 2>/dev/null && echo "✅ TgCrypto installed" || echo "⚠️  TgCrypto NOT installed (optional)"

echo ""

# Check Node.js dependencies
echo "🟢 Checking Node.js Dependencies..."
echo ""

cd "$SCRIPT_DIR/backend"
if [ -d "node_modules" ]; then
    echo "✅ node_modules directory exists"
    
    [ -d "node_modules/express" ] && echo "✅ Express installed" || echo "❌ Express NOT installed"
    [ -d "node_modules/bullmq" ] && echo "✅ BullMQ installed" || echo "❌ BullMQ NOT installed"
    [ -d "node_modules/ioredis" ] && echo "✅ IORedis installed" || echo "❌ IORedis NOT installed"
    [ -d "node_modules/sqlite3" ] && echo "✅ SQLite3 installed" || echo "❌ SQLite3 NOT installed"
    [ -d "node_modules/axios" ] && echo "✅ Axios installed" || echo "❌ Axios NOT installed"
else
    echo "❌ node_modules NOT found. Run: cd backend && npm install"
fi

echo ""

# Check directories
echo "📁 Checking Directories..."
echo ""

cd "$SCRIPT_DIR"
[ -d "db" ] && echo "✅ db/ directory exists" || echo "⚠️  db/ directory NOT found (will be created automatically)"
[ -d "logs" ] && echo "✅ logs/ directory exists" || echo "⚠️  logs/ directory NOT found (will be created automatically)"
[ -d "backend" ] && echo "✅ backend/ directory exists" || echo "❌ backend/ directory NOT found"
[ -d "python-service" ] && echo "✅ python-service/ directory exists" || echo "❌ python-service/ directory NOT found"

echo ""

# Check configuration files
echo "⚙️  Checking Configuration Files..."
echo ""

[ -f ".env" ] && echo "✅ .env file exists" || echo "❌ .env file NOT found. Copy from .env.example"
[ -f ".env.example" ] && echo "✅ .env.example exists" || echo "⚠️  .env.example NOT found"
[ -f "backend/package.json" ] && echo "✅ backend/package.json exists" || echo "❌ backend/package.json NOT found"
[ -f "python-service/requirements.txt" ] && echo "✅ python-service/requirements.txt exists" || echo "❌ python-service/requirements.txt NOT found"

echo ""

# Check if Redis is running
echo "🔴 Checking Redis Status..."
echo ""

if redis-cli ping >/dev/null 2>&1; then
    echo "✅ Redis is RUNNING"
else
    echo "❌ Redis is NOT running. Start with: redis-server --daemonize yes"
fi

echo ""

# Check if services are running
echo "🚀 Checking Services Status..."
echo ""

if curl -s http://localhost:8000/health >/dev/null 2>&1; then
    echo "✅ Python Service (port 8000): RUNNING"
else
    echo "❌ Python Service (port 8000): NOT RUNNING"
fi

if curl -s http://localhost:3000/health >/dev/null 2>&1; then
    echo "✅ Node.js Backend (port 3000): RUNNING"
else
    echo "❌ Node.js Backend (port 3000): NOT RUNNING"
fi

echo ""
echo "======================================================"
echo "✅ Setup Check Complete!"
echo "======================================================"
echo ""

# Summary and recommendations
echo "📋 Recommendations:"
echo ""

if ! command -v python >/dev/null 2>&1 || ! command -v node >/dev/null 2>&1; then
    echo "⚠️  Install missing system packages with:"
    echo "   ./install-dependencies.sh"
    echo ""
fi

if [ ! -f ".env" ]; then
    echo "⚠️  Create .env file:"
    echo "   cp .env.example .env"
    echo "   nano .env  # Edit and add your Telegram API credentials"
    echo ""
fi

if ! python -c "import pyrogram" 2>/dev/null; then
    echo "⚠️  Install Python dependencies:"
    echo "   cd python-service && pip install -r requirements.txt"
    echo ""
fi

if [ ! -d "backend/node_modules" ]; then
    echo "⚠️  Install Node.js dependencies:"
    echo "   cd backend && npm install"
    echo ""
fi

if ! redis-cli ping >/dev/null 2>&1; then
    echo "⚠️  Start Redis:"
    echo "   redis-server --daemonize yes"
    echo ""
fi

if ! curl -s http://localhost:8000/health >/dev/null 2>&1 || ! curl -s http://localhost:3000/health >/dev/null 2>&1; then
    echo "⚠️  Start services:"
    echo "   ./start-services.sh"
    echo ""
fi

echo "📖 For more information, read:"
echo "   README.md or SETUP_TERMUX.md"
echo ""
