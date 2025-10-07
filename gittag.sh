#!/bin/bash

# Script untuk membuat tag versi dan langsung melakukan push tag.

# Minta input versi tag
read -p "Masukkan versi tag baru (misal: v1.0.0): " tag_version

# Cek kalau versi tag kosong
if [ -z "$tag_version" ]
then
  echo "⚠️  Versi tag tidak boleh kosong."
  exit 1
fi

# Tanya apakah ini untuk rilis (membutuhkan tag anotasi)
read -p "Apakah tag ini untuk RILIS dan butuh pesan (y/N)? [N]: " is_release

# Ubah input menjadi huruf kecil
is_release=${is_release,,}

# --- Proses Tagging ---

# Default: Tag Ringan (Lightweight Tag)
TAG_COMMAND="git tag"
TAG_TYPE="Ringan (Lightweight)"

if [[ "$is_release" == "y" ]]; then
  
  # Jika Ya, buat Tag Anotasi
  TAG_TYPE="Anotasi (Annotated)"
  
  # Minta input pesan tag
  read -p "Masukkan pesan tag (misal: Rilis stabil pertama): " tag_message
  
  # Cek kalau pesan tag kosong
  if [ -z "$tag_message" ]
  then
    echo "⚠️  Pesan tag tidak boleh kosong untuk tag Anotasi."
    exit 1
  fi
  
  # Set perintah untuk Tag Anotasi
  TAG_COMMAND="git tag -a -m \"$tag_message\""
fi

# 1. Buat tag
echo "🏷️  Membuat tag $TAG_TYPE: $tag_version"

# Eksekusi perintah tag yang telah disiapkan
eval $TAG_COMMAND "$tag_version"

# Cek status pembuatan tag
if [ $? -ne 0 ]; then
  echo "❌ Error saat membuat tag. Pastikan tag belum ada."
  exit 1
fi

# 2. Push tag ke remote
echo "🚀 Mengirim tag '$tag_version' ke remote..."
git push origin "$tag_version"

# Cek status push
if [ $? -ne 0 ]; then
  echo "❌ Error saat push tag. Mungkin Anda perlu memastikan remote 'origin' sudah terhubung."
  exit 1
fi

echo "✅ Tag '$tag_version' ($TAG_TYPE) berhasil dibuat dan didorong (pushed) ke remote."