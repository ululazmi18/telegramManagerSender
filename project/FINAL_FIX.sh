#!/bin/bash
# Final fix untuk Python 3.12 compatibility

echo "🔧 Final Fix - Python 3.12 Compatible Setup"
echo "======================================================"

cd ~/project

# Option 1: Try even older versions
echo "Option 1: Installing older compatible versions..."
pip uninstall -y fastapi uvicorn pydantic starlette 2>/dev/null || true

# These versions are known to work with Python 3.12
pip install --no-cache-dir \
  'pydantic==1.10.2' \
  'fastapi==0.88.0' \
  'uvicorn==0.20.0' \
  'pyrogram==2.0.106'

echo ""
echo "Testing import..."
if python -c "from fastapi import FastAPI; print('✅ FastAPI OK')" 2>/dev/null; then
    echo "✅ Option 1 SUCCESS!"
    FASTAPI_OK=1
else
    echo "❌ Option 1 failed, trying Option 2..."
    
    # Option 2: Use latest versions (may work better with Python 3.12)
    pip uninstall -y fastapi uvicorn pydantic 2>/dev/null || true
    pip install --no-cache-dir fastapi uvicorn pyrogram
    
    if python -c "from fastapi import FastAPI; print('✅ FastAPI OK')" 2>/dev/null; then
        echo "✅ Option 2 SUCCESS!"
        FASTAPI_OK=1
    else
        echo "❌ Both options failed"
        echo "⚠️  Will use Flask as alternative"
        FASTAPI_OK=0
    fi
fi

echo ""
echo "======================================================"

# Fix SQLite3 for Node.js
echo "Fixing SQLite3..."
cd backend

# Try better-sqlite3 as alternative
npm uninstall sqlite3 2>/dev/null || true
echo "Installing better-sqlite3..."
npm install better-sqlite3 --build-from-source 2>/dev/null && echo "✅ better-sqlite3 installed" || {
    echo "⚠️  better-sqlite3 also failed"
    echo "Installing sql.js (pure JavaScript, no compilation)..."
    npm install sql.js
}

cd ..

echo ""
echo "======================================================"
if [ "$FASTAPI_OK" = "1" ]; then
    echo "✅ Setup complete! Try running services now."
else
    echo "⚠️  FastAPI installation failed."
    echo "Alternative: Use Flask instead"
    echo "Run: pip install flask flask-cors"
fi
echo "======================================================"
