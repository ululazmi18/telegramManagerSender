#!/bin/bash
BASEDIR="$(cd "$(dirname "$0")" && pwd)"
cd "$BASEDIR/python-service"
# Aktifkan virtual environment jika ada
if [ -d "venv" ]; then
    . "venv/bin/activate"
else
    echo "⚠️  Virtualenv tidak ditemukan di $BASEDIR/python-service/venv. Jalankan 'bash setup.sh' terlebih dahulu."
fi
python app.py
