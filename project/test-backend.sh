#!/bin/bash
# Test if backend can run

echo "🧪 Testing Node.js Backend..."
cd ~/project/backend

# Try to run backend
timeout 5 node server.js 2>&1 | head -n 20

if [ $? -eq 124 ]; then
    echo ""
    echo "✅ Backend started successfully (timeout reached = good sign)"
    pkill -f "node.*server.js"
elif [ $? -eq 0 ]; then
    echo ""
    echo "✅ Backend started successfully"
else
    echo ""
    echo "❌ Backend failed to start"
    echo ""
    echo "Solution: Install sql.js (pure JS, no compilation)"
    echo "Run: npm install sql.js"
fi
