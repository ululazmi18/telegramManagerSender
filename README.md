# Telegram Campaign Manager

Aplikasi untuk mengelola kampanye pesan Telegram dengan antarmuka web di Termux.

## Setup Cepat

```bash
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
bash start-redis.sh
```
Tunggu tampil "Ready to accept connections"

**Terminal 2 - Python Service**
```bash
bash start-python.sh
```

**Terminal 3 - Backend**
```bash
bash start-backend.sh
```

**Terminal 4 - Frontend**
```bash
bash start-frontend.sh
```

## Akses Aplikasi Web

Setelah semua service berjalan, buka aplikasi di browser:

**Akses Lokal (di HP Termux):**

```
http://localhost:3001
```

****Akses Jaringan Lokal** dalam LAN/Wi-Fi yang sama):**

Untuk cek IP Termux, jalankan:

```bash
ip addr show wlan0 | grep 'inet ' | awk '{print $2}' | cut -d/ -f1
```

```
http://[IP_TERMUX]:3001
```

Contoh: `http://192.168.1.5:3001`

## Teknologi

- React.js + Bootstrap
- Node.js + Express
- FastAPI/Flask + Pyrogram
- SQLite + Redis + BullMQ
# telegramManagerSender
