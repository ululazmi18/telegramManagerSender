# 📋 Quick Reference - Perintah Cepat

Panduan singkat perintah-perintah yang sering digunakan.

## 🚀 Setup Awal (Sekali Saja)

```bash
# 1. Install semua dependencies
./install-dependencies.sh

# 2. Edit konfigurasi
nano .env

# 3. Cek setup
./check-setup.sh
```

## ▶️ Menjalankan Aplikasi

```bash
# Cara termudah - jalankan semua sekaligus
./start-services.sh

# Atau manual satu per satu:
# Terminal 1
redis-server --daemonize yes

# Terminal 2
cd python-service && python app.py

# Terminal 3
cd backend && node server.js
```

## ⏹️ Menghentikan Aplikasi

```bash
# Stop semua services
./stop-services.sh

# Atau manual:
pkill -f "python.*app.py"
pkill -f "node.*server.js"
redis-cli shutdown  # Stop Redis juga
```

## 🔍 Cek Status

```bash
# Cek lengkap
./check-setup.sh

# Cek Redis
redis-cli ping

# Cek Python Service
curl http://localhost:8000/health

# Cek Node.js Backend
curl http://localhost:3000/health

# Cek proses yang berjalan
ps aux | grep python
ps aux | grep node
ps aux | grep redis
```

## 📝 Melihat Logs

```bash
# Log Python Service
tail -f logs/python-service.log
tail -f python-service/telegram_service.log

# Log Node.js Backend
tail -f logs/nodejs-backend.log

# Log Redis
redis-cli monitor
```

## 🔧 Troubleshooting Cepat

### Redis tidak bisa start
```bash
# Cek apakah sudah berjalan
redis-cli ping

# Start Redis
redis-server --daemonize yes

# Cek port
netstat -tulpn | grep 6379
```

### Port sudah digunakan
```bash
# Cek port 8000 (Python)
lsof -i :8000
netstat -tulpn | grep 8000

# Cek port 3000 (Node.js)
lsof -i :3000
netstat -tulpn | grep 3000

# Kill proses jika perlu
kill <PID>
# atau force kill
kill -9 <PID>
```

### Service tidak bisa start
```bash
# Cek error di log
tail -f logs/python-service.log
tail -f logs/nodejs-backend.log

# Test manual
cd python-service
python app.py  # Lihat error langsung

cd backend
node server.js  # Lihat error langsung
```

### Database error
```bash
# Backup database
cp db/telegram_app.db db/telegram_app.db.backup

# Reset database (HATI-HATI: akan hapus semua data!)
rm db/telegram_app.db
# Database akan dibuat ulang saat service start
```

## 📦 Update Dependencies

### Python
```bash
cd python-service
pip install --upgrade -r requirements.txt
```

### Node.js
```bash
cd backend
npm update
# atau
npm install
```

## 🔄 Restart Services

```bash
# Quick restart
./stop-services.sh && ./start-services.sh

# Restart individual service
pkill -f "python.*app.py"
cd python-service && python app.py &

pkill -f "node.*server.js"
cd backend && node server.js &
```

## 💾 Backup & Restore

### Backup
```bash
# Backup database
cp db/telegram_app.db ~/backup/telegram_app.db.$(date +%Y%m%d)

# Backup .env
cp .env ~/backup/.env.backup
```

### Restore
```bash
# Restore database
cp ~/backup/telegram_app.db.YYYYMMDD db/telegram_app.db

# Restart services
./stop-services.sh && ./start-services.sh
```

## 🧪 Testing API

### Test Python Service
```bash
# Health check
curl http://localhost:8000/health

# Get documentation (OpenAPI)
curl http://localhost:8000/docs
# Buka di browser: http://localhost:8000/docs
```

### Test Node.js Backend
```bash
# Health check
curl http://localhost:3000/health

# Test endpoints (contoh)
curl http://localhost:3000/api/sessions
curl http://localhost:3000/api/projects
```

## 🔑 Environment Variables

```bash
# Edit .env
nano .env

# Lihat isi (tanpa sensitive info)
cat .env | grep -v "API_HASH\|API_ID\|SECRET"

# Reload setelah edit .env - perlu restart services
./stop-services.sh && ./start-services.sh
```

## 📊 Monitoring

### Resource usage
```bash
# CPU & Memory
top
# atau
htop (jika terinstall)

# Disk usage
df -h

# Check folder size
du -sh *
```

### Network
```bash
# Check open ports
netstat -tulpn

# Check connections
netstat -an | grep ESTABLISHED
```

## 🎯 Shortcut Commands

Tambahkan ke `.bashrc` untuk shortcut:

```bash
# Edit .bashrc
nano ~/.bashrc

# Tambahkan:
alias tg-start='cd ~/termux && ./start-services.sh'
alias tg-stop='cd ~/termux && ./stop-services.sh'
alias tg-check='cd ~/termux && ./check-setup.sh'
alias tg-logs='cd ~/termux && tail -f logs/*.log'

# Reload .bashrc
source ~/.bashrc

# Sekarang bisa pakai:
tg-start   # Start services
tg-stop    # Stop services
tg-check   # Check status
tg-logs    # View logs
```

## 🆘 Emergency Commands

```bash
# Kill semua Python processes
pkill python

# Kill semua Node.js processes
pkill node

# Kill Redis
redis-cli shutdown

# Kill by port
fuser -k 8000/tcp  # Kill process di port 8000
fuser -k 3000/tcp  # Kill process di port 3000

# Restart Termux (last resort)
exit
# Buka Termux lagi
```

## 📞 Get Help

```bash
# Lihat README
cat README.md

# Lihat setup lengkap
cat SETUP_TERMUX.md

# Lihat referensi ini
cat QUICK_REFERENCE.md
```

---

**Simpan halaman ini untuk referensi cepat!** 📌
