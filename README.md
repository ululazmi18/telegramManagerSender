# Telegram Campaign Manager

Aplikasi untuk mengelola kampanye pesan Telegram dengan antarmuka web di Termux.

## Setup Cepat

```bash
chmod +x setup.sh
bash setup.sh
```

Script akan install semua dependencies dan setup Redis.
- Otomatis gunakan Pydantic v2 (Python 3.12 compatible)
- Fallback ke Flask jika FastAPI gagal install

## Menjalankan Service

**⚠️ PENTING: Jalankan Redis terlebih dahulu!**

Buka 4 terminal terpisah, masuk ke folder project, lalu jalankan **BERURUTAN**:

**Terminal 1 - Redis**
```bash
chmod +x start-redis.sh
bash start-redis.sh
```
Tunggu tampil "Ready to accept connections"

**Terminal 2 - Python Service**
```bash
chmod +x start-python.sh
bash start-python.sh
```

**Terminal 3 - Backend**
```bash
chmod +x start-backend.sh
bash start-backend.sh
```

**Terminal 4 - Frontend**
```bash
chmod +x start-frontend.sh
bash start-frontend.sh
```

## Teknologi

- React.js + Bootstrap
- Node.js + Express
- FastAPI/Flask + Pyrogram
- SQLite + Redis + BullMQ
# telegramManagerSender
