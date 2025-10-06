# 🚀 Setup dan Instalasi untuk Termux

Panduan lengkap untuk setup dan menjalankan aplikasi Telegram di lingkungan Termux.

## 📋 Persyaratan

Pastikan Termux sudah terinstal di perangkat Android Anda.

## 1️⃣ Instalasi Paket Dasar

Jalankan perintah berikut satu per satu di terminal Termux:

```bash
# Update dan upgrade packages
pkg update && pkg upgrade -y

# Install paket-paket yang dibutuhkan
pkg install -y python nodejs-lts git redis clang make

# Verifikasi instalasi
python --version
node --version
npm --version
redis-server --version
```

## 2️⃣ Setup Python Dependencies

```bash
# Install pip (jika belum ada)
pkg install -y python-pip

# Masuk ke direktori python-service
cd ~/termux/python-service

# Install dependencies Python
pip install fastapi uvicorn pyrogram tgcrypto
```

### Dependencies Python yang dibutuhkan:
- `fastapi` - Web framework untuk API
- `uvicorn` - ASGI server untuk menjalankan FastAPI
- `pyrogram` - Library untuk Telegram API
- `tgcrypto` - Encryption library untuk Pyrogram (opsional tapi direkomendasikan untuk performa)

## 3️⃣ Setup Node.js Dependencies

```bash
# Masuk ke direktori backend
cd ~/termux/backend

# Install dependencies Node.js
npm install express cors body-parser dotenv sqlite3 bullmq ioredis axios
```

### Dependencies Node.js yang dibutuhkan:
- `express` - Web framework
- `cors` - CORS middleware
- `body-parser` - Body parsing middleware
- `dotenv` - Environment variables
- `sqlite3` - SQLite database driver
- `bullmq` - Job queue dengan Redis
- `ioredis` - Redis client untuk Node.js
- `axios` - HTTP client

## 4️⃣ Setup Environment Variables

```bash
# Kembali ke root directory
cd ~/termux

# Copy file .env.example menjadi .env
cp .env.example .env

# Edit file .env
nano .env
```

### Konfigurasi yang perlu diisi di file `.env`:

```env
# Database Configuration
DB_PATH=./db/telegram_app.db

# Redis Configuration
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_PASSWORD=

# Server Configuration
PORT=3000
NODE_ENV=development

# Python Service Configuration
PYTHON_SERVICE_URL=http://localhost:8000

# Telegram API Configuration
# Dapatkan dari https://my.telegram.org
TELEGRAM_API_ID=your_api_id_here
TELEGRAM_API_HASH=your_api_hash_here

# JWT Configuration
JWT_SECRET=your-super-secret-jwt-key-change-this-in-production
JWT_EXPIRES_IN=24h
```

**PENTING**: Ganti `TELEGRAM_API_ID` dan `TELEGRAM_API_HASH` dengan kredensial Anda dari https://my.telegram.org

## 5️⃣ Membuat Direktori Database

```bash
# Buat direktori untuk database
mkdir -p ~/termux/db

# Database akan dibuat otomatis saat aplikasi pertama kali dijalankan
```

## 6️⃣ Menjalankan Redis Server

Redis diperlukan untuk job queue (BullMQ).

```bash
# Jalankan Redis di background
redis-server --daemonize yes

# Verifikasi Redis berjalan
redis-cli ping
# Seharusnya menampilkan: PONG
```

### Untuk menghentikan Redis:
```bash
redis-cli shutdown
```

## 7️⃣ Menjalankan Aplikasi

Anda perlu menjalankan 2 service secara terpisah:

### Terminal 1 - Python Service (Port 8000)

```bash
cd ~/termux/python-service
python app.py
```

Atau dengan uvicorn secara eksplisit:
```bash
cd ~/termux/python-service
uvicorn app:app --host 0.0.0.0 --port 8000
```

### Terminal 2 - Node.js Backend (Port 3000)

Buka terminal baru (swipe dari kiri di Termux, pilih "New Session"):

```bash
cd ~/termux/backend
node server.js
```

## 8️⃣ Verifikasi Aplikasi Berjalan

### Test Python Service:
```bash
curl http://localhost:8000/health
# Expected: {"status":"healthy","service":"python-pyrogram-service"}
```

### Test Node.js Backend:
```bash
curl http://localhost:3000/health
# Expected: {"status":"OK","service":"telegram-app-backend"}
```

## 📝 Struktur Direktori

```
~/termux/
├── backend/                  # Node.js backend service
│   ├── server.js            # Main server file
│   ├── db.js                # Database initialization
│   ├── queue.js             # Job queue management
│   └── routes/              # API routes
├── python-service/          # Python Pyrogram service
│   └── app.py               # FastAPI application
├── db/                      # SQLite database directory
│   └── telegram_app.db      # Database file (auto-created)
├── frontend/                # Frontend files (jika ada)
├── .env                     # Environment variables
└── .env.example             # Environment template
```

## 🔧 Tips dan Troubleshooting

### Jika Redis tidak berjalan:
```bash
# Pastikan Redis berjalan
redis-cli ping

# Jika tidak response, jalankan ulang Redis
redis-server --daemonize yes
```

### Jika port sudah digunakan:
```bash
# Cek proses yang menggunakan port
lsof -i :3000  # untuk backend
lsof -i :8000  # untuk python service

# Atau gunakan port lain dengan mengedit .env atau menjalankan dengan parameter berbeda
```

### Jika ada error "Permission Denied":
```bash
# Berikan permission pada file yang diperlukan
chmod +x ~/termux/backend/server.js
chmod +x ~/termux/python-service/app.py
```

### Log Files:
- Python service log: `~/termux/python-service/telegram_service.log`
- Node.js akan menampilkan log di terminal

## 🔄 Menjalankan di Background dengan tmux/screen

Untuk menjalankan service di background agar tidak perlu membuka banyak terminal:

### Install tmux:
```bash
pkg install -y tmux
```

### Jalankan services dengan tmux:
```bash
# Start tmux session untuk Python
tmux new -s python -d
tmux send-keys -t python "cd ~/termux/python-service && python app.py" C-m

# Start tmux session untuk Node.js
tmux new -s nodejs -d
tmux send-keys -t nodejs "cd ~/termux/backend && node server.js" C-m

# Lihat daftar session
tmux ls

# Attach ke session untuk melihat log
tmux attach -t python  # atau nodejs

# Detach dari session: tekan Ctrl+B lalu D
```

### Stop services:
```bash
# Kill tmux session
tmux kill-session -t python
tmux kill-session -t nodejs
```

## 🎯 Langkah Cepat (Quick Start)

Setelah semua terinstal, jalankan dalam urutan ini:

```bash
# 1. Start Redis
redis-server --daemonize yes

# 2. Start Python Service (di terminal 1 atau tmux)
cd ~/termux/python-service && python app.py &

# 3. Start Node.js Backend (di terminal 2 atau tmux)
cd ~/termux/backend && node server.js &

# 4. Verifikasi
curl http://localhost:8000/health
curl http://localhost:3000/health
```

## 📞 Mendapatkan Telegram API Credentials

1. Buka https://my.telegram.org
2. Login dengan nomor telepon Anda
3. Klik "API development tools"
4. Isi form (jika pertama kali):
   - App title: (nama aplikasi Anda)
   - Short name: (nama pendek)
   - Platform: (pilih sesuai)
5. Salin `api_id` dan `api_hash`
6. Masukkan ke file `.env`

## ✅ Selesai!

Aplikasi Anda sekarang siap digunakan. Akses API di:
- Python Service: http://localhost:8000
- Node.js Backend: http://localhost:3000

---

**Catatan**: Simpan file ini untuk referensi di masa depan.
