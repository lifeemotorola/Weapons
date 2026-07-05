#!/bin/bash
# ============================================
# Simple Finger Detector Tool for Termux
# Fixed & Improved Version
# ============================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

clear
echo -e "${CYAN}"
echo "╔════════════════════════════════════╗"
echo "║     FINGER DETECTOR TOOL v1.0      ║"
echo "║        Fixed For Termux            ║"
echo "╚════════════════════════════════════╝"
echo -e "${NC}"

# Check Dependencies
echo -e "${YELLOW}[*] Checking Dependencies...${NC}"

if ! command -v curl &> /dev/null; then
    echo -e "${RED}[-] curl not found. Installing...${NC}"
    pkg install curl -y
else
    echo -e "${GREEN}[+] curl is installed${NC}"
fi

if ! command -v wget &> /dev/null; then
    echo -e "${RED}[-] wget not found. Installing...${NC}"
    pkg install wget -y
else
    echo -e "${GREEN}[+] wget is installed${NC}"
fi

echo ""

# Input Target
echo -e "${CYAN}[?] Enter Target URL (without http/https):${NC}"
read -p "    Target: " target

# Validate Input
if [ -z "$target" ]; then
    echo -e "${RED}[-] Error: No target entered. Exiting...${NC}"
    exit 1
fi

echo ""
echo -e "${YELLOW}[*] Starting Scan on: $target${NC}"
echo "----------------------------------------"

# HTTP Headers Fingerprinting
echo -e "${CYAN}[1] Grabbing HTTP Headers...${NC}"
headers=$(curl -I -s --max-time 10 "http://$target" 2>/dev/null)

if [ -z "$headers" ]; then
    echo -e "${RED}[-] Could not reach target. Trying HTTPS...${NC}"
    headers=$(curl -I -s --max-time 10 "https://$target" 2>/dev/null)
fi

if [ -z "$headers" ]; then
    echo -e "${RED}[-] Target is unreachable. Check URL and try again.${NC}"
    exit 1
fi

echo -e "${GREEN}$headers${NC}"
echo "----------------------------------------"

# Server Detection
echo -e "${CYAN}[2] Detecting Server...${NC}"
server=$(echo "$headers" | grep -i "Server:" | awk '{print $2}')
if [ -z "$server" ]; then
    echo -e "${RED}[-] Server: Not Disclosed${NC}"
else
    echo -e "${GREEN}[+] Server: $server${NC}"
fi

# Powered By Detection
echo -e "${CYAN}[3] Detecting Powered By...${NC}"
powered=$(echo "$headers" | grep -i "X-Powered-By:" | awk '{print $2}')
if [ -z "$powered" ]; then
    echo -e "${RED}[-] X-Powered-By: Not Disclosed${NC}"
else
    echo -e "${GREEN}[+] X-Powered-By: $powered${NC}"
fi

echo "----------------------------------------"

# CMS Detection
echo -e "${CYAN}[4] Detecting CMS...${NC}"
body=$(curl -s --max-time 10 "http://$target" 2>/dev/null)

if echo "$body" | grep -qi "wp-content"; then
    echo -e "${GREEN}[+] CMS Detected: WordPress${NC}"
elif echo "$body" | grep -qi "joomla"; then
    echo -e "${GREEN}[+] CMS Detected: Joomla${NC}"
elif echo "$body" | grep -qi "drupal"; then
    echo -e "${GREEN}[+] CMS Detected: Drupal${NC}"
elif echo "$body" | grep -qi "shopify"; then
    echo -e "${GREEN}[+] CMS Detected: Shopify${NC}"
elif echo "$body" | grep -qi "wix.com"; then
    echo -e "${GREEN}[+] CMS Detected: Wix${NC}"
elif echo "$body" | grep -qi "squarespace"; then
    echo -e "${GREEN}[+] CMS Detected: Squarespace${NC}"
elif echo "$body" | grep -qi "magento"; then
    echo -e "${GREEN}[+] CMS Detected: Magento${NC}"
else
    echo -e "${RED}[-] CMS: Not Detected or Custom Built${NC}"
fi

echo "----------------------------------------"

# IP Address Lookup
echo -e "${CYAN}[5] Resolving IP Address...${NC}"
ip=$(curl -s --max-time 10 "https://api.hackertarget.com/hostsearch/?q=$target" 2>/dev/null | head -1 | cut -d',' -f2)

if [ -z "$ip" ]; then
    ip=$(ping -c 1 "$target" 2>/dev/null | grep -oP '\(\K[0-9.]+')
fi

if [ -z "$ip" ]; then
    echo -e "${RED}[-] Could not resolve IP Address${NC}"
else
    echo -e "${GREEN}[+] IP Address: $ip${NC}"
fi

echo "----------------------------------------"

# Cloudflare Detection
echo -e "${CYAN}[6] Checking Cloudflare Protection...${NC}"
if echo "$headers" | grep -qi "cloudflare"; then
    echo -e "${YELLOW}[!] Cloudflare Protection: DETECTED${NC}"
else
    echo -e "${GREEN}[+] Cloudflare Protection: NOT Detected${NC}"
fi

echo "----------------------------------------"

# robots.txt Check
echo -e "${CYAN}[7] Checking robots.txt...${NC}"
robots=$(curl -s --max-time 10 "http://$target/robots.txt" 2>/dev/null)
if [ -z "$robots" ]; then
    echo -e "${RED}[-] robots.txt: Not Found${NC}"
else
    echo -e "${GREEN}[+] robots.txt Found:${NC}"
    echo -e "${GREEN}$robots${NC}"
fi

echo "----------------------------------------"

# Sitemap Check
echo -e "${CYAN}[8] Checking sitemap.xml...${NC}"
sitemap=$(curl -s --max-time 10 -o /dev/null -w "%{http_code}" "http://$target/sitemap.xml")
if [ "$sitemap" == "200" ]; then
    echo -e "${GREEN}[+] sitemap.xml: Found (HTTP 200)${NC}"
else
    echo -e "${RED}[-] sitemap.xml: Not Found (HTTP $sitemap)${NC}"
fi

echo "----------------------------------------"

# Open Ports Check
echo -e "${CYAN}[9] Checking Common Open Ports...${NC}"
if command -v nmap &> /dev/null; then
    nmap -F --open "$target" 2>/dev/null | grep "open"
else
    echo -e "${YELLOW}[!] nmap not installed. Installing...${NC}"
    pkg install nmap -y
    nmap -F --open "$target" 2>/dev/null | grep "open"
fi

echo "----------------------------------------"

# Done
echo ""
echo -e "${GREEN}╔════════════════════════════════════╗${NC}"
echo -e "${GREEN}║        Scan Complete!               ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════╝${NC}"
echo ""
