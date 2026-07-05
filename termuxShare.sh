#!/bin/bash
# termux-share-dir.sh
# Purpose: Instantly share the current directory over the local network.

# Check if python is installed
if ! command -v python &> /dev/null; then
    echo "[!] Python is not installed. Run: pkg install python"
    exit 1
fi

# Get the local WLAN IP address on Android
IP_ADDR=$(ifconfig wlan0 | grep 'inet ' | awk '{print $2}')
PORT=8080

if [ -z "$IP_ADDR" ]; then
    echo "[!] Could not detect Wi-Fi connection."
    exit 1
fi

echo "=========================================="
echo "📂 Sharing directory: $(pwd)"
echo "🔗 Access it on another device via:"
echo "👉 http://$IP_ADDR:$PORT"
echo "=========================================="
echo "Press CTRL+C to stop sharing."

# Start the python HTTP server
python -m http.server $PORT
