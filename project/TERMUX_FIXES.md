# 🔧 Perbaikan untuk Termux

Panduan fix masalah umum di Termux.

## ⚠️ Path Direktori

Proyek ini ada di: `~/project` (bukan `~/termux`)

Update semua command dengan path yang benar:

```bash
# Correct path
cd ~/project

# Bukan:
# cd ~/termux
```

## 🐍 Install Python Dependencies di Termux

### Masalah Umum

Banyak Python package butuh kompilasi C/Rust yang tidak berfungsi baik di Termux.

### ✅ Solusi: Gunakan Versi Kompatibel

**Metode 1: Install dari requirements.txt**

```bash
cd ~/project/python-service
pip install --no-cache-dir -r requirements.txt
```

**Metode 2: Install Manual (Lebih Aman)**

```bash
# Install satu per satu dengan versi yang tested
pip install --no-cache-dir 'fastapi==0.100.0'
pip install --no-cache-dir 'uvicorn==0.23.0'
pip install --no-cache-dir 'pydantic==1.10.13'
pip install --no-cache-dir 'pyrogram==2.0.106'
```

**Metode 3: Versi Latest (Risiko Lebih Tinggi)**

```bash
pip install --no-cache-dir fastapi uvicorn pyrogram
```

### TgCrypto (Opsional)

TgCrypto sering gagal compile di Termux. Pyrogram bisa berjalan tanpanya, tapi lebih lambat.

**Jika ingin mencoba install:**
```bash
# Install build tools dulu
pkg install -y clang python-cryptography

# Coba install
pip install --no-cache-dir tgcrypto
```

**Jika gagal:** Skip saja, aplikasi tetap berjalan.

## 🟢 Install Node.js Dependencies

Node.js packages biasanya tidak ada masalah di Termux:

```bash
cd ~/project/backend
npm install
```

## 🔴 Redis di Termux

```bash
# Install
pkg install redis

# Start
redis-server --daemonize yes

# Check
redis-cli ping

# Stop
redis-cli shutdown
```

## 📂 Struktur Path yang Benar

```
~/project/                      # ← Base directory Anda
├── backend/
│   ├── server.js
│   └── package.json
├── python-service/
│   ├── app.py
│   └── requirements.txt
├── start-services.sh
└── .env
```

## 🚀 Menjalankan Services

```bash
cd ~/project

# Method 1: Manual (RECOMMENDED untuk debugging)
# Terminal 1
redis-server --daemonize yes

# Terminal 2
cd python-service
python app.py

# Terminal 3
cd backend
node server.js
```

## 🔍 Cek Instalasi

```bash
# Cek Python packages
python -c "import fastapi; print('FastAPI OK')"
python -c "import pyrogram; print('Pyrogram OK')"
python -c "import uvicorn; print('Uvicorn OK')"

# Cek Node modules
cd backend
npm list express
npm list bullmq
```

## ⚡ Quick Fix Commands

```bash
# Reinstall Python deps (clean)
pip uninstall -y fastapi uvicorn pydantic pyrogram
pip install --no-cache-dir 'fastapi==0.100.0' 'uvicorn==0.23.0' 'pydantic==1.10.13' 'pyrogram==2.0.106'

# Reinstall Node deps (clean)
cd ~/project/backend
rm -rf node_modules package-lock.json
npm install

# Reset Redis
redis-cli shutdown
redis-server --daemonize yes
```

## 🐛 Debug Errors

### Error: "No module named 'fastapi'"
```bash
pip install fastapi
python -c "import fastapi; print(fastapi.__version__)"
```

### Error: "Rust not found"
Gunakan versi Python package yang tidak butuh Rust:
```bash
pip install 'pydantic==1.10.13'  # Bukan 2.x
```

### Error: "Can't connect to Redis"
```bash
redis-cli ping
# Jika gagal:
redis-server --daemonize yes
```

### Error: Port already in use
```bash
# Cek port
lsof -i :8000
lsof -i :3000

# Kill process
kill <PID>
```

## 📝 Environment Setup

```bash
# Copy .env
cd ~/project
cp .env.example .env

# Edit dengan credentials Anda
nano .env
```

Yang perlu diubah:
- `TELEGRAM_API_ID` (dari https://my.telegram.org)
- `TELEGRAM_API_HASH` (dari https://my.telegram.org)
- `JWT_SECRET` (string random)

## ✅ Verifikasi Setup

```bash
# Test Python service
cd ~/project/python-service
python -c "from app import app; print('✅ Python app OK')"

# Test services running
curl http://localhost:8000/health  # Python
curl http://localhost:3000/health  # Node.js
```

---

**Tips:** Di Termux, selalu gunakan `--no-cache-dir` saat pip install untuk hindari masalah cache.
