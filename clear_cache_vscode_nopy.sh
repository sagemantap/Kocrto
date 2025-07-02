#!/bin/bash

echo "[*] Checking if VSCode is running..."
vscode_pid=$(pgrep -f "code")

if [ -z "$vscode_pid" ]; then
  echo "[!] VSCode is not running."
  exit 1
else
  echo "[*] VSCode is running (PID: $vscode_pid)"
fi

echo "[*] Simulating memory pressure using bash (no Python)..."

# Allocate temporary memory using bash arrays
mem_pressure() {
  local blocks=300  # Number of MB to allocate, adjust as needed
  for ((i=0; i<$blocks; i++)); do
    arr[i]=$(head -c 1048576 </dev/zero | tr '\0' 'x')
  done
}

# Run memory pressure in background for ~5 seconds
mem_pressure &
pid=$!
sleep 5
kill $pid >/dev/null 2>&1

echo "[*] Memory stress finished, some cache may be cleared by kernel."

# Optional: Clear zombie processes
echo "[*] Cleaning zombie (defunct) processes..."
ps -eo pid,stat,cmd | awk '$2 ~ /Z/ {print $1}' | while read zpid; do
  kill -9 "$zpid" 2>/dev/null
done

echo "[*] Done. VSCode remains running."
