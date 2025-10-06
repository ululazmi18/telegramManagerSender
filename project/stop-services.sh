#!/bin/bash
# Script untuk menghentikan semua services

echo "🛑 Stopping Telegram App Services..."
echo ""

# Stop Python Service
echo "🐍 Stopping Python Service..."
pkill -f "python.*app.py"
if [ $? -eq 0 ]; then
    echo "✅ Python Service stopped"
else
    echo "ℹ️  Python Service mungkin tidak sedang berjalan"
fi

# Stop Node.js Backend
echo "🟢 Stopping Node.js Backend..."
pkill -f "node.*server.js"
if [ $? -eq 0 ]; then
    echo "✅ Node.js Backend stopped"
else
    echo "ℹ️  Node.js Backend mungkin tidak sedang berjalan"
fi

echo ""
echo "✅ Semua services telah dihentikan"
echo ""
echo "💡 Redis masih berjalan. Untuk menghentikan Redis:"
echo "   redis-cli shutdown"
