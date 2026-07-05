#!/bin/bash

# ==========================================
# NEXUS.SH - A Termux Surprise Plugin
# ==========================================

# Colors for terminal output
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

clear
echo -e "${CYAN}Initializing Project NEXUS...${NC}"
termux-vibrate -d 200
sleep 1

# Fake boot sequence for aesthetics
for i in {1..3}; do
    echo -e "${YELLOW}[*] Bypassing mainframe security... module $i${NC}"
    sleep 0.4
done

echo -e "${GREEN}[✔] Access Granted.${NC}"
sleep 1

# 1. Text to Speech Greeting
USER=$(whoami)
GREETING="Welcome back to Termux, commander."
termux-tts-speak "$GREETING"
echo -e "\n${CYAN}>>> $GREETING <<<${NC}"

# 2. Battery Status Check
echo -e "\n${YELLOW}Checking life support (Battery)...${NC}"
BATTERY_JSON=$(termux-battery-status)
BATTERY_PCT=$(echo "$BATTERY_JSON" | jq '.percentage')
BATTERY_STATUS=$(echo "$BATTERY_JSON" | jq -r '.status')

echo -e "Battery is at ${GREEN}${BATTERY_PCT}%${NC} and is currently ${GREEN}${BATTERY_STATUS}${NC}."

if [ "$BATTERY_PCT" -lt 20 ]; then
    termux-tts-speak "Warning. Battery is critically low."
fi
sleep 1

# 3. Security Check (The Surprise)
echo -e "\n${RED}Running visual authentication...${NC}"
termux-tts-speak "Taking security photograph. Please smile."
sleep 2

# Takes a photo with the front camera (camera 1) and saves it
PHOTO_NAME="auth_snap_$(date +%s).jpg"
termux-camera-photo -c 1 "$PHOTO_NAME" &> /dev/null

if [ -f "$PHOTO_NAME" ]; then
    echo -e "${GREEN}[✔] Authentication successful. Photo saved to: $PHOTO_NAME${NC}"
    termux-vibrate -d 100
else
    echo -e "${RED}[✖] Camera access failed. Did you grant permissions?${NC}"
fi

# 4. Fetching Daily Intel (Programming Joke)
echo -e "\n${CYAN}Fetching daily intel...${NC}"
JOKE=$(curl -s "https://v2.jokeapi.dev/joke/Programming?type=single" | jq -r '.joke')

echo -e "\n${YELLOW}--- Daily Data ---${NC}"
echo -e "$JOKE"
echo -e "${YELLOW}------------------${NC}"

# Read joke out loud (Uncomment the line below if you want your phone to read the joke)
# termux-tts-speak "$JOKE"

echo -e "\n${GREEN}NEXUS sequence complete. Have a productive day!${NC}\n"
