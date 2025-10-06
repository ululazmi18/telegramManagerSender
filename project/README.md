# Telegram App - Panduan Setup Termux

Aplikasi untuk mengelola Telegram menggunakan Python (Pyrogram) dan Node.js Backend.

## 🚀 Quick Start

### Langkah 1: Install Dependencies

```bash
cd ~/project
chmod +x ./install-dependencies.sh
./install-dependencies.sh
```

Script ini akan menginstal:

- Python, Node.js, Redis, Git, dan tools lainnya
- Dependencies Python (FastAPI, Pyrogram, dll)
- Dependencies Node.js (Express, BullMQ, dll)
- Membuat direktori yang dibutuhkan

### Langkah 2: Konfigurasi Environment

Edit file `.env` dan isi kredensial Telegram API Anda:

```bash
nano .env
```

**PENTING**: Ganti nilai berikut:

- `TELEGRAM_API_ID` - Dapatkan dari https://my.telegram.org
- `TELEGRAM_API_HASH` - Dapatkan dari https://my.telegram.org
- `JWT_SECRET` - Ganti dengan string random yang aman

### Langkah 3: Jalankan Services

Jalankan setiap service secara terpisah:

**1. Start Redis (jalankan sekali):**
```bash
redis-server --daemonize yes --ignore-warnings ARM64-COW-BUG
```

**2. Start Python Service (Terminal 1):**
```bash
cd python-service
python3 app.py
```

**3. Start Node.js Backend (Terminal 2):**
```bash
cd backend
node server.js
```

### Langkah 4: Stop Services

Untuk menghentikan services:
- Tekan `Ctrl+C` di setiap terminal
- Atau kill manual: `pkill -f "python3 app.py"` dan `pkill -f "node server.js"`
- Stop Redis: `redis-cli shutdown`

## 📂 Struktur Aplikasi

```
~/termux/
├── backend/                    # Node.js Backend
│   ├── server.js              # Main server
│   ├── db.js                  # Database setup
│   ├── queue.js               # Job queue (BullMQ)
│   └── package.json           # Node.js dependencies
├── python-service/            # Python Pyrogram Service
│   ├── app.py                 # FastAPI app
│   └── requirements.txt       # Python dependencies
├── db/                        # SQLite database
├── logs/                      # Log files
├── .env                       # Environment variables
├── install-dependencies.sh    # Script instalasi
└── SETUP_TERMUX.md           # Panduan lengkap
```

## 🔧 Services

### Python Service (Port 8000)

- Framework: FastAPI
- Library: Pyrogram (Telegram MTProto API)
- Fungsi: Handle operasi Telegram (auth, send message, dll)

### Node.js Backend (Port 3000)

- Framework: Express
- Database: SQLite3
- Job Queue: BullMQ + Redis
- Fungsi: API endpoints, job management, database operations

### Redis (Port 6379)

- Digunakan untuk job queue (BullMQ)
- Harus running sebelum start backend

## 🔗 API Endpoints

### Python Service (http://localhost:8000)

- `GET /health` - Health check
- `POST /export_session` - Export session Telegram
- `POST /complete_auth` - Complete authentication
- `POST /send_message` - Send message/comment
- `GET /get_me` - Get user info
- `GET /get_chat` - Get chat info
- Dan lainnya...

### Node.js Backend (http://localhost:3000)

- `GET /health` - Health check
- `GET /api/sessions` - Manage sessions
- `GET /api/projects` - Manage projects
- `GET /api/channels` - Manage channels
- Dan lainnya...

## 📖 Dokumentasi Lengkap

Baca [SETUP_TERMUX.md](SETUP_TERMUX.md) untuk:

- Penjelasan detail setiap langkah
- Troubleshooting
- Tips & tricks
- Menjalankan dengan tmux/screen
- Dan lainnya

## ⚙️ Manual Setup

Jika prefer manual setup:

### 1. Install Packages

```bash
pkg update && pkg upgrade -y
pkg install -y python nodejs-lts git redis clang make
```

### 2. Install Python Dependencies

```bash
cd python-service
pip install -r requirements.txt
```

### 3. Install Node.js Dependencies

```bash
cd backend
npm install
```

### 4. Start Services

```bash
# Terminal 1 - Start Redis
redis-server --daemonize yes --ignore-warnings ARM64-COW-BUG

# Terminal 2 - Python Service
cd python-service
python3 app.py

# Terminal 3 - Node.js Backend
cd backend
node server.js
```

## 🐛 Troubleshooting

### Redis tidak berjalan

```bash
redis-server --daemonize yes --ignore-warnings ARM64-COW-BUG
redis-cli ping  # Seharusnya return PONG
```

**Note**: Flag `--ignore-warnings ARM64-COW-BUG` diperlukan untuk Termux di Android (ARM64) karena kernel bug. Flag ini aman digunakan untuk development.

### Port sudah digunakan

```bash
# Cek proses yang menggunakan port
lsof -i :3000
lsof -i :8000

# Kill proses jika perlu
kill <PID>
```

### Error permission

```bash
chmod +x *.sh
```

### Melihat logs

```bash
# Python service
tail -f logs/python-service.log
tail -f python-service/telegram_service.log

# Node.js backend
tail -f logs/nodejs-backend.log
```

## 📞 Mendapatkan Telegram API Credentials

1. Buka https://my.telegram.org
2. Login dengan nomor telepon
3. Klik "API development tools"
4. Isi form aplikasi (jika pertama kali)
5. Copy `api_id` dan `api_hash`
6. Paste ke file `.env`

## 💡 Tips

### Menjalankan di Background dengan tmux
```bash
# Install tmux jika belum ada
pkg install tmux

# Start Redis
redis-server --daemonize yes --ignore-warnings ARM64-COW-BUG

# Buat session untuk Python
tmux new-session -d -s python "cd python-service && python3 app.py"

# Buat session untuk Node.js
tmux new-session -d -s nodejs "cd backend && node server.js"

# Lihat session yang berjalan
tmux ls

# Attach ke session (untuk melihat log)
tmux attach -t python
tmux attach -t nodejs

# Detach dari session: tekan Ctrl+B lalu D
```

### Tips Lainnya
- Backup database secara berkala (`db/telegram_app.db`)
- Monitor logs untuk debugging: `tail -f python-service/telegram_service.log`
- Pastikan Redis selalu running sebelum start backend

## 📝 Notes

- Python service menggunakan port **8000**
- Node.js backend menggunakan port **3000**
- Redis menggunakan port **6379**
- Database SQLite tersimpan di `db/telegram_app.db`

## 🔒 Keamanan

- Jangan commit file `.env` ke git
- Ganti `JWT_SECRET` dengan value yang aman
- Simpan API credentials dengan aman
- Jangan share session strings

---

**Happy Coding!** 🎉

Untuk pertanyaan atau masalah, cek dokumentasi lengkap di [SETUP_TERMUX.md](SETUP_TERMUX.md)
