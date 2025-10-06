#!/bin/bash
# Install all potentially missing Node.js dependencies

echo "📦 Installing missing Node.js dependencies..."
cd ~/project/backend

# Core dependencies
npm install express cors body-parser dotenv axios

# Job queue
npm install bullmq ioredis

# Database (sql.js already installed)
echo "✅ sql.js already installed"

# File upload & utilities
npm install multer uuid

# Auth (if needed)
npm install bcrypt jsonwebtoken

# Others
npm install fs-extra

echo ""
echo "✅ All dependencies installed!"
echo ""
echo "Now try: node server.js"
