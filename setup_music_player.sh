#!/data/data/com.termux/files/usr/bin/bash

# ============================================
# Termux Music Player - Setup Script
# ============================================

echo "╔══════════════════════════════════════════╗"
echo "║   Advanced Music Player - Setup          ║"
echo "╚══════════════════════════════════════════╝"
echo ""

# Request storage permission
echo "[*] Requesting storage access..."
termux-setup-storage
sleep 3

# Install required packages
echo "[*] Installing required packages..."
pkg update -y
pkg install -y mpv jq termux-api bc coreutils findutils grep sed ncurses-utils

echo ""
echo "[✓] Setup complete! Run: bash music_player.sh"
