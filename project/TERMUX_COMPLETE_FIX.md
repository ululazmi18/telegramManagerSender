# 🔧 Complete Fix untuk Termux - Solusi Semua Error

## 🔴 Masalah yang Terjadi

Anda mengalami beberapa error:
1. ❌ **node-gyp error**: `ModuleNotFoundError: No module named 'distutils'`
2. ❌ **Redis crash**: `ARM64-COW-BUG` kernel warning
3. ❌ **Python error**: `TypeError: ForwardRef._evaluate()` - Pydantic incompatible
4. ❌ **sqlite3 compile error**: Native module compilation failed
5. ❌ **msgpackr error**: No native build for Android ARM64

## ✅ Solusi Lengkap (Copy-Paste)

### Metode 1: Automated Fix Script (RECOMMENDED)

```bash
cd ~/project
./fix-termux-issues.sh
```

### Metode 2: Manual Step-by-Step

Jika script automated tidak work, ikuti langkah ini:

#### Step 1: Install Python setuptools

```bash
pip install --no-cache-dir setuptools
```

**Kenapa?** Node-gyp butuh `distutils` dari setuptools untuk compile native modules.

#### Step 2: Fix Redis

```bash
# Buat config file
cat > ~/redis.conf << 'EOF'
bind 127.0.0.1
port 6379
daemonize yes
ignore-warnings ARM64-COW-BUG
dir /data/data/com.termux/files/home/
EOF

# Stop Redis yang lama
redis-cli shutdown 2>/dev/null

# Start dengan config baru
redis-server ~/redis.conf

# Test
redis-cli ping
```

**Kenapa?** Kernel Android memiliki bug ARM64 copy-on-write yang Redis detect. Kita perlu ignore warning ini.

#### Step 3: Fix Python Dependencies

```bash
# Uninstall versi yang incompatible
pip uninstall -y fastapi uvicorn pydantic starlette

# Install versi yang compatible dengan Python 3.12
pip install --no-cache-dir \
  'fastapi==0.95.0' \
  'uvicorn==0.21.0' \
  'pydantic==1.10.7' \
  'pyrogram==2.0.106'
```

**Kenapa?** FastAPI 0.100.0 + Pydantic 1.10.13 incompatible dengan Python 3.12. Versi 0.95.0 + Pydantic 1.10.7 lebih stable.

#### Step 4: Fix Node.js Dependencies

```bash
cd ~/project/backend

# Clean install
rm -rf node_modules package-lock.json

# Install dependencies satu per satu (lebih aman)
npm install --no-optional express
npm install cors
npm install body-parser
npm install dotenv
npm install axios
npm install bullmq
npm install ioredis

# SQLite3 - try compile
npm install sqlite3 --build-from-source --ignore-scripts

# Jika gagal, pakai better-sqlite3
# npm install better-sqlite3 --build-from-source
```

**Kenapa?** Install satu per satu memastikan tidak ada dependency yang konflik. `--no-optional` skip optional dependencies yang sering gagal compile.

#### Step 5: Setup Environment

```bash
cd ~/project

# Copy .env jika belum ada
cp .env.example .env

# Edit dan isi credentials
nano .env
```

**Yang harus diisi:**
- `TELEGRAM_API_ID` - dari https://my.telegram.org
- `TELEGRAM_API_HASH` - dari https://my.telegram.org
- `JWT_SECRET` - string random

#### Step 6: Test Services

**Terminal 1 - Test Python:**
```bash
cd ~/project/python-service

# Test import
python -c "import fastapi; print('✅ FastAPI OK')"
python -c "import pyrogram; print('✅ Pyrogram OK')"

# Run service
python app.py
```

**Terminal 2 - Test Node.js:**
```bash
cd ~/project/backend

# Run service
node server.js
```

## 🎯 Expected Output

### Python Service (Port 8000)
```
INFO:     Started server process [12345]
INFO:     Waiting for application startup.
INFO:     Application startup complete.
INFO:     Uvicorn running on http://0.0.0.0:8000
```

### Node.js Backend (Port 3000)
```
Server is running on port 3000
```

## 🐛 Troubleshooting

### Jika Redis tetap crash:

```bash
# Cek status
redis-cli ping

# Jika error, kill semua process
pkill redis

# Start ulang dengan verbose
redis-server ~/redis.conf --loglevel verbose
```

### Jika Python masih error:

```bash
# Versi paling minimal (tanpa version pinning)
pip uninstall -y fastapi uvicorn pydantic
pip install fastapi uvicorn pyrogram

# Test
python -c "import fastapi; import uvicorn; import pyrogram; print('OK')"
```

### Jika Node.js sqlite3 gagal total:

Kita bisa gunakan alternative database atau skip sqlite3 native compilation.

**Option A: Better-sqlite3**
```bash
npm uninstall sqlite3
npm install better-sqlite3 --build-from-source
```

**Option B: SQL.js (Pure JavaScript, no compilation)**
```bash
npm uninstall sqlite3
npm install sql.js
```

### Jika msgpackr-extract error (non-critical):

```bash
# Msgpackr akan fallback ke pure JS version
# Aplikasi tetap jalan, hanya sedikit lebih lambat
# No action needed
```

## 📝 Quick Commands Cheatsheet

```bash
# Check installations
python -c "import fastapi, pyrogram, uvicorn; print('Python OK')"
redis-cli ping
node -v

# Check running services
curl http://localhost:8000/health  # Python
curl http://localhost:3000/health  # Node.js

# View logs
tail -f ~/project/python-service/telegram_service.log

# Restart Redis
redis-cli shutdown
redis-server ~/redis.conf

# Kill processes
pkill -f "python.*app.py"
pkill -f "node.*server.js"
```

## ✅ Verifikasi Sukses

Jalankan test ini:

```bash
# Test 1: Redis
redis-cli ping
# Expected: PONG

# Test 2: Python packages
python -c "from fastapi import FastAPI; print('✅ FastAPI OK')"
# Expected: ✅ FastAPI OK

# Test 3: Node modules
node -e "require('express'); console.log('✅ Express OK')"
# Expected: ✅ Express OK

# Test 4: Services
# Terminal 1
cd ~/project/python-service && python app.py &

# Terminal 2  
cd ~/project/backend && node server.js &

# Terminal 3
curl http://localhost:8000/health
curl http://localhost:3000/health
```

## 🔑 Key Takeaways

1. **Python 3.12** di Termux butuh versi FastAPI/Pydantic yang lebih lama
2. **Redis** butuh config khusus untuk ignore ARM64 kernel warning
3. **Native modules** (sqlite3, msgpackr) sering gagal - gunakan `--build-from-source` atau alternatives
4. **node-gyp** butuh `setuptools` dari pip
5. Install dependencies **satu per satu** lebih aman daripada sekaligus

## 📞 Jika Masih Error

1. Jalankan: `./fix-termux-issues.sh`
2. Screenshot error yang muncul
3. Check versi: `python --version`, `node --version`, `redis-server --version`
4. Coba install minimal versions tanpa version pinning

---

**Good luck!** 🚀
