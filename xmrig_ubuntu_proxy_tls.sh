#!/bin/bash

### === SETUP === ###
WORKDIR="$HOME/.xmrig_proxy"
mkdir -p "$WORKDIR" && cd "$WORKDIR"

ARCH=$(uname -m)
if [[ "$ARCH" != "x86_64" ]]; then
  echo "Hanya mendukung x86_64 (Ubuntu PC)"
  exit 1
fi

# === Download XMRig jika belum ada ===
if [ ! -f "./xmrig" ]; then
  echo "[*] Mengunduh XMRig..."
  curl -L -o xmrig.tar.gz https://github.com/xmrig/xmrig/releases/download/v6.21.0/xmrig-6.21.0-linux-x64.tar.gz
  tar -xf xmrig.tar.gz --strip-components=1
  rm xmrig.tar.gz
  chmod +x xmrig
fi

# === Konfigurasi USER ===
WALLET="85MLqXJjpZEUPjo9UFtWQ1C5zs3NDx7gJTRVkLefoviXbNN6CyDLKbBc3a1SdS7saaXPoPrxyTxybAnyJjYXKcFBKCJSbDp"  # Ganti wallet kamu di sini
PROXY="127.0.0.1:9050"    # SOCKS5 proxy, misalnya lewat Tor: 9050 atau SSH tunnel: 1080
USE_PROXY=1               # 1=aktifkan proxy, 0=nonaktif

# === Buat config.json ===
cat > config.json <<EOF
{
  "autosave": true,
  "cpu": {
    "enabled": true,
    "priority": null,
    "max-threads-hint": 0.7,   // BATASI 70% CPU
    "asm": true
  },
  "pools": [
    {
      "url": "159.65.167.171:443",
      "user": "$WALLET",
      "pass": "ubuntu",
      "keepalive": true,
      "tls": true",
      "socks5": $( [ "$USE_PROXY" -eq 1 ] && echo "\"$PROXY\"" || echo "null" )
    }
  ]
}
EOF

# === Jalankan Loop Anti-Dismiss ===
while true; do
  echo "[*] Menjalankan XMRig + TLS + $( [ "$USE_PROXY" -eq 1 ] && echo "SOCKS5 Proxy" || echo "No Proxy" )"
  ./xmrig --config=config.json >> miner.log 2>&1
  echo "[!] XMRig berhenti. Restart dalam 5 detik..."
  sleep 5
done
