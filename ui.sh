#!/usr/bin/env bash
# ==============================================================================
# Plugin Name: ui
# Description: An advanced TUI-based multi-tool and system manager for Termux.
# Author: Emmanuel suah
# Version: 1.0.0
# Requirements: termux-api, jq, curl, python (for server), bc
# ==============================================================================
# This script is strictly designed for the Termux environment on Android.
# It provides hardware control, system monitoring, network tools, backup
# management, and developer environment setup in a pure-bash TUI.
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. GLOBAL VARIABLES & SETTINGS
# ------------------------------------------------------------------------------
VERSION="1.0.0"
SCRIPT_NAME=$(basename "$0")
PREFIX_DIR=${PREFIX:-/data/data/com.termux/files/usr}
HOME_DIR=${HOME:-/data/data/com.termux/files/home}
BACKUP_DIR="$HOME_DIR/termux_backups"

# Colors (ANSI)
C_DEF="\e[0m"
C_BLK="\e[30m"
C_RED="\e[31m"
C_GRN="\e[32m"
C_YLW="\e[33m"
C_BLU="\e[34m"
C_MAG="\e[35m"
C_CYN="\e[36m"
C_WHT="\e[37m"

# Bold Colors
CB_RED="\e[1;31m"
CB_GRN="\e[1;32m"
CB_YLW="\e[1;33m"
CB_BLU="\e[1;34m"
CB_MAG="\e[1;35m"
CB_CYN="\e[1;36m"
CB_WHT="\e[1;37m"

# Backgrounds
BG_BLU="\e[44m"
BG_GRN="\e[42m"
BG_RED="\e[41m"

# UI Constants
TERMS_COLS=$(tput cols 2>/dev/null || echo 80)
TERMS_LINES=$(tput lines 2>/dev/null || echo 24)
MENU_WIDTH=$(( TERMS_COLS - 4 ))
if [ $MENU_WIDTH -gt 80 ]; then MENU_WIDTH=80; fi

# ------------------------------------------------------------------------------
# 2. TRAPS AND CLEANUP
# ------------------------------------------------------------------------------
cleanup() {
    tput cnorm # Show cursor
    echo -e "${C_DEF}"
    clear
    exit 0
}
trap cleanup SIGINT SIGTERM

# ------------------------------------------------------------------------------
# 3. UTILITY & UI FUNCTIONS
# ------------------------------------------------------------------------------

# Hide cursor
hide_cursor() { tput civis; }
# Show cursor
show_cursor() { tput cnorm; }

# Center text based on width
center_text() {
    local text="$1"
    local width="$2"
    local text_len=${#text}
    local padding=$(( (width - text_len) / 2 ))
    printf "%*s%s%*s" $padding "" "$text" $((width - text_len - padding)) ""
}

# Draw a horizontal line
draw_hline() {
    local width=$1
    local char=${2:-"-"}
    printf "%${width}s\n" | tr " " "$char"
}

# Spinner animation for background tasks
spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='|/-\'
    tput civis
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
    tput cnorm
}

# Prompt wait
wait_keypress() {
    echo -e "\n${CB_CYN}Press ANY KEY to return to the menu...${C_DEF}"
    read -n 1 -s -r
}

# Print header
print_header() {
    clear
    echo -e "${CB_BLU}$(draw_hline $MENU_WIDTH "=")${C_DEF}"
    echo -e "${BG_BLU}${CB_WHT}$(center_text "T E R M U X   O M N I   v$VERSION" $MENU_WIDTH)${C_DEF}"
    echo -e "${CB_BLU}$(draw_hline $MENU_WIDTH "=")${C_DEF}"
    echo ""
}

# Print menu item
print_menu_item() {
    local num=$1
    local text=$2
    echo -e "  ${CB_MAG}[${CB_WHT}$num${CB_MAG}]${C_DEF} ${CB_CYN}$text${C_DEF}"
}

# ------------------------------------------------------------------------------
# 4. DEPENDENCY MANAGEMENT
# ------------------------------------------------------------------------------
check_dependencies() {
    local deps=("termux-api" "jq" "curl" "python" "bc" "tar")
    local missing=()

    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            missing+=("$dep")
        fi
    done

    if [ ${#missing[@]} -ne 0 ]; then
        print_header
        echo -e "${CB_RED}Missing Dependencies Detected!${C_DEF}"
        echo -e "The following packages are required but not installed:"
        for m in "${missing[@]}"; do
            echo -e "  - ${CB_YLW}$m${C_DEF}"
        done
        echo -e "\n${CB_CYN}Would you like to install them now? (y/n)${C_DEF}"
        read -n 1 -r ans
        echo ""
        if [[ "$ans" == "y" || "$ans" == "Y" ]]; then
            echo -e "${CB_GRN}Updating repositories and installing...${C_DEF}"
            pkg update -y
            for m in "${missing[@]}"; do
                pkg install "$m" -y
            done
            echo -e "${CB_GRN}Installation complete! Restarting...${C_DEF}"
            sleep 2
            exec "$0"
        else
            echo -e "${CB_RED}Dependencies are required for Termux-Omni to run. Exiting.${C_DEF}"
            exit 1
        fi
    fi
}

# ------------------------------------------------------------------------------
# 5. MODULE: SYSTEM DASHBOARD
# ------------------------------------------------------------------------------
module_system_dashboard() {
    print_header
    echo -e "${CB_WHT}--- System & Termux Information ---${C_DEF}\n"

    # OS Info
    local os_arch=$(uname -m)
    local os_kernel=$(uname -r)
    local android_ver=$(getprop ro.build.version.release 2>/dev/null || echo "Unknown")
    local device_model=$(getprop ro.product.model 2>/dev/null || echo "Unknown")

    # Storage Info
    local storage_total=$(df -h $HOME_DIR | awk 'NR==2 {print $2}')
    local storage_used=$(df -h $HOME_DIR | awk 'NR==2 {print $3}')
    local storage_avail=$(df -h $HOME_DIR | awk 'NR==2 {print $4}')
    local storage_percent=$(df -h $HOME_DIR | awk 'NR==2 {print $5}')

    # Memory Info (Requires parsing /proc/meminfo)
    local mem_total=$(grep MemTotal /proc/meminfo | awk '{print $2}')
    local mem_free=$(grep MemFree /proc/meminfo | awk '{print $2}')
    local mem_buffers=$(grep Buffers /proc/meminfo | awk '{print $2}')
    local mem_cached=$(grep "^Cached" /proc/meminfo | awk '{print $2}')
    
    local mem_total_mb=$((mem_total / 1024))
    local mem_free_calc=$((mem_free + mem_buffers + mem_cached))
    local mem_used_mb=$(((mem_total - mem_free_calc) / 1024))
    
    # Termux Info
    local termux_ver=$(pkg show termux-tools | grep Version | awk '{print $2}')
    local shell_type=$(basename "$SHELL")

    echo -e "${CB_YLW}Device OS:${C_DEF}    Android $android_ver ($device_model)"
    echo -e "${CB_YLW}Architecture:${C_DEF} $os_arch"
    echo -e "${CB_YLW}Kernel:${C_DEF}       $os_kernel"
    echo -e "${CB_YLW}Termux Ver:${C_DEF}   $termux_ver"
    echo -e "${CB_YLW}Shell:${C_DEF}        $shell_type"
    echo -e "${CB_BLU}$(draw_hline $MENU_WIDTH "-")${C_DEF}"
    echo -e "${CB_YLW}Storage (App):${C_DEF} $storage_used used out of $storage_total (${CB_RED}$storage_percent${C_DEF})"
    echo -e "${CB_YLW}Available:${C_DEF}     $storage_avail"
    echo -e "${CB_BLU}$(draw_hline $MENU_WIDTH "-")${C_DEF}"
    echo -e "${CB_YLW}RAM Total:${C_DEF}     ${mem_total_mb} MB"
    echo -e "${CB_YLW}RAM Used:${C_DEF}      ${mem_used_mb} MB"
    
    wait_keypress
}

# ------------------------------------------------------------------------------
# 6. MODULE: TERMUX API & DEVICE CONTROL
# ------------------------------------------------------------------------------
module_device_control() {
    while true; do
        print_header
        echo -e "${CB_WHT}--- Hardware & Device Control ---${C_DEF}\n"
        
        print_menu_item "1" "Battery Status"
        print_menu_item "2" "Toggle Flashlight (Torch)"
        print_menu_item "3" "Vibrate Device"
        print_menu_item "4" "Read Clipboard (Text-To-Speech)"
        print_menu_item "5" "Get Device Location"
        print_menu_item "6" "Take a Photo (Background)"
        print_menu_item "0" "Return to Main Menu"
        
        echo -e "\n${CB_YLW}Select an option:${C_DEF} \c"
        read -n 1 -r opt
        echo ""

        case $opt in
            1)
                echo -e "\n${CB_CYN}Fetching Battery Info...${C_DEF}"
                local bat_json=$(termux-battery-status)
                local percentage=$(echo "$bat_json" | jq -r '.percentage')
                local health=$(echo "$bat_json" | jq -r '.health')
                local status=$(echo "$bat_json" | jq -r '.status')
                local temp=$(echo "$bat_json" | jq -r '.temperature')
                echo -e "${CB_GRN}Percentage: ${percentage}%${C_DEF}"
                echo -e "${CB_GRN}Status:     ${status}${C_DEF}"
                echo -e "${CB_GRN}Health:     ${health}${C_DEF}"
                echo -e "${CB_GRN}Temp:       ${temp}°C${C_DEF}"
                wait_keypress
                ;;
            2)
                echo -e "\n${CB_CYN}Select Torch State (on/off):${C_DEF} \c"
                read -r t_state
                if [[ "$t_state" == "on" || "$t_state" == "off" ]]; then
                    termux-torch "$t_state"
                    echo -e "${CB_GRN}Torch turned $t_state.${C_DEF}"
                else
                    echo -e "${CB_RED}Invalid input.${C_DEF}"
                fi
                sleep 1
                ;;
            3)
                echo -e "\n${CB_CYN}Vibrating...${C_DEF}"
                termux-vibrate -d 1000 -f
                sleep 1
                ;;
            4)
                echo -e "\n${CB_CYN}Fetching clipboard content...${C_DEF}"
                local clip=$(termux-clipboard-get)
                if [ -z "$clip" ]; then
                    echo -e "${CB_RED}Clipboard is empty.${C_DEF}"
                else
                    echo -e "${CB_GRN}Reading aloud: ${C_DEF}$clip"
                    termux-tts-speak "$clip"
                fi
                wait_keypress
                ;;
            5)
                echo -e "\n${CB_CYN}Requesting GPS Location (This may take a moment)...${C_DEF}"
                # Run in background and show spinner
                termux-location -p network -r once > /tmp/loc.json &
                spinner $!
                local lat=$(cat /tmp/loc.json | jq -r '.latitude' 2>/dev/null)
                local lon=$(cat /tmp/loc.json | jq -r '.longitude' 2>/dev/null)
                if [[ "$lat" == "null" || -z "$lat" ]]; then
                    echo -e "\n${CB_RED}Failed to get location. Ensure Location services are ON and Termux has permission.${C_DEF}"
                else
                    echo -e "\n${CB_GRN}Latitude:  $lat${C_DEF}"
                    echo -e "${CB_GRN}Longitude: $lon${C_DEF}"
                    echo -e "${CB_BLU}Google Maps: https://www.google.com/maps/search/?api=1&query=$lat,$lon${C_DEF}"
                fi
                rm -f /tmp/loc.json
                wait_keypress
                ;;
            6)
                echo -e "\n${CB_CYN}Taking photo using main camera...${C_DEF}"
                local filename="$HOME_DIR/omni_photo_$(date +%s).jpg"
                termux-camera-photo -c 0 "$filename" &
                spinner $!
                echo -e "\n${CB_GRN}Saved to: $filename${C_DEF}"
                wait_keypress
                ;;
            0) break ;;
            *) echo -e "${CB_RED}Invalid Option.${C_DEF}"; sleep 1 ;;
        esac
    done
}

# ------------------------------------------------------------------------------
# 7. MODULE: NETWORK TOOLS
# ------------------------------------------------------------------------------
module_network_tools() {
    while true; do
        print_header
        echo -e "${CB_WHT}--- Network Utilities ---${C_DEF}\n"
        
        print_menu_item "1" "Show Local IP Address"
        print_menu_item "2" "Show Public IP Address"
        print_menu_item "3" "Ping a Host"
        print_menu_item "4" "Scan Local Network (ARP)"
        print_menu_item "0" "Return to Main Menu"
        
        echo -e "\n${CB_YLW}Select an option:${C_DEF} \c"
        read -n 1 -r opt
        echo ""

        case $opt in
            1)
                local ip=$(ifconfig wlan0 2>/dev/null | grep 'inet ' | awk '{print $2}')
                if [ -z "$ip" ]; then
                    ip=$(ifconfig 2>/dev/null | grep 'inet ' | grep -v '127.0.0.1' | awk '{print $2}' | head -n 1)
                fi
                echo -e "\n${CB_GRN}Local IP (wlan0): ${C_DEF}$ip"
                wait_keypress
                ;;
            2)
                echo -e "\n${CB_CYN}Fetching Public IP...${C_DEF}"
                local pub_ip=$(curl -s -4 ifconfig.me)
                echo -e "${CB_GRN}Public IP: ${C_DEF}$pub_ip"
                wait_keypress
                ;;
            3)
                echo -e "\n${CB_CYN}Enter domain or IP to ping (e.g., google.com):${C_DEF} \c"
                read -r host
                if [ -n "$host" ]; then
                    ping -c 4 "$host"
                fi
                wait_keypress
                ;;
            4)
                echo -e "\n${CB_CYN}ARP Cache (Devices interacted with on LAN):${C_DEF}"
                arp -a || ip neigh
                wait_keypress
                ;;
            0) break ;;
            *) echo -e "${CB_RED}Invalid Option.${C_DEF}"; sleep 1 ;;
        esac
    done
}

# ------------------------------------------------------------------------------
# 8. MODULE: QUICK WEB SERVER (FILE SHARING)
# ------------------------------------------------------------------------------
module_web_server() {
    print_header
    echo -e "${CB_WHT}--- Quick HTTP File Server ---${C_DEF}\n"
    echo -e "This will start a Python HTTP server in your Termux home directory."
    echo -e "You can access your files from any device on the same Wi-Fi network."
    echo -e "${CB_BLU}$(draw_hline $MENU_WIDTH "-")${C_DEF}"
    
    echo -e "${CB_CYN}Enter port to use (Default 8080):${C_DEF} \c"
    read -r port
    port=${port:-8080}

    local ip=$(ifconfig wlan0 2>/dev/null | grep 'inet ' | awk '{print $2}')
    if [ -z "$ip" ]; then
        ip="127.0.0.1"
    fi

    echo -e "\n${CB_GRN}Starting server on http://$ip:$port${C_DEF}"
    echo -e "${CB_YLW}Press [CTRL+C] to stop the server and exit Termux-Omni.${C_DEF}"
    echo -e "${CB_BLU}$(draw_hline $MENU_WIDTH "-")${C_DEF}"
    
    cd "$HOME_DIR" || exit
    # Run server in foreground so user sees logs
    python -m http.server "$port"
    
    wait_keypress
}

# ------------------------------------------------------------------------------
# 9. MODULE: BACKUP & RESTORE MANAGER
# ------------------------------------------------------------------------------
module_backup_manager() {
    mkdir -p "$BACKUP_DIR"
    
    while true; do
        print_header
        echo -e "${CB_WHT}--- Environment Backup Manager ---${C_DEF}\n"
        echo -e "Backup Directory: ${CB_GRN}$BACKUP_DIR${C_DEF}\n"
        
        print_menu_item "1" "Create Full Environment Backup (Home + Usr)"
        print_menu_item "2" "Create Home Directory Backup Only"
        print_menu_item "3" "List Existing Backups"
        print_menu_item "4" "Delete Old Backups"
        print_menu_item "0" "Return to Main Menu"
        
        echo -e "\n${CB_YLW}Select an option:${C_DEF} \c"
        read -n 1 -r opt
        echo ""

        case $opt in
            1)
                local timestamp=$(date +"%Y%m%d_%H%M%S")
                local b_name="termux_full_backup_$timestamp.tar.gz"
                echo -e "\n${CB_CYN}Creating Full Backup... This WILL take a while.${C_DEF}"
                echo -e "Compressing $PREFIX_DIR and $HOME_DIR..."
                
                # Execute tar in background
                tar -czf "$BACKUP_DIR/$b_name" -C /data/data/com.termux/files ./home ./usr 2>/dev/null &
                spinner $!
                
                echo -e "\n${CB_GRN}Full backup created successfully!${C_DEF}"
                echo -e "File: $BACKUP_DIR/$b_name"
                wait_keypress
                ;;
            2)
                local timestamp=$(date +"%Y%m%d_%H%M%S")
                local b_name="termux_home_backup_$timestamp.tar.gz"
                echo -e "\n${CB_CYN}Creating Home Backup...${C_DEF}"
                
                tar -czf "$BACKUP_DIR/$b_name" -C /data/data/com.termux/files ./home 2>/dev/null &
                spinner $!
                
                echo -e "\n${CB_GRN}Home backup created successfully!${C_DEF}"
                echo -e "File: $BACKUP_DIR/$b_name"
                wait_keypress
                ;;
            3)
                echo -e "\n${CB_CYN}Available Backups:${C_DEF}"
                ls -lh "$BACKUP_DIR" | grep ".tar.gz" | awk '{print $5, "\t", $9}'
                if [ $? -ne 0 ] || [ -z "$(ls -A $BACKUP_DIR)" ]; then
                     echo -e "${CB_RED}No backups found.${C_DEF}"
                fi
                wait_keypress
                ;;
            4)
                echo -e "\n${CB_RED}Are you sure you want to delete ALL backups? (y/n)${C_DEF} \c"
                read -n 1 -r conf
                if [[ "$conf" == "y" || "$conf" == "Y" ]]; then
                    rm -f "$BACKUP_DIR"/*.tar.gz
                    echo -e "\n${CB_GRN}All backups deleted.${C_DEF}"
                else
                    echo -e "\n${CB_YLW}Aborted.${C_DEF}"
                fi
                sleep 1
                ;;
            0) break ;;
            *) echo -e "${CB_RED}Invalid Option.${C_DEF}"; sleep 1 ;;
        esac
    done
}

# ------------------------------------------------------------------------------
# 10. MODULE: DEVELOPER STACK INSTALLER
# ------------------------------------------------------------------------------
module_dev_stacks() {
    while true; do
        print_header
        echo -e "${CB_WHT}--- Dev Stack 1-Click Installer ---${C_DEF}\n"
        
        print_menu_item "1" "Python Data Science (numpy, pandas, jupyter)"
        print_menu_item "2" "Node.js & Web Dev (nodejs, yarn, git)"
        print_menu_item "3" "C/C++ Build Environment (clang, make, cmake)"
        print_menu_item "4" "Cyber Security Basics (nmap, hydra, metasploit deps)"
        print_menu_item "0" "Return to Main Menu"
        
        echo -e "\n${CB_YLW}Select a stack to install:${C_DEF} \c"
        read -n 1 -r opt
        echo ""

        case $opt in
            1)
                echo -e "\n${CB_CYN}Installing Python Data Science Stack...${C_DEF}"
                pkg install python -y
                pip install numpy pandas jupyter &
                spinner $!
                echo -e "\n${CB_GRN}Installation Complete!${C_DEF}"
                wait_keypress
                ;;
            2)
                echo -e "\n${CB_CYN}Installing Node.js Stack...${C_DEF}"
                pkg install nodejs yarn git -y &
                spinner $!
                echo -e "\n${CB_GRN}Installation Complete!${C_DEF}"
                wait_keypress
                ;;
            3)
                echo -e "\n${CB_CYN}Installing C/C++ Environment...${C_DEF}"
                pkg install clang make cmake gdb -y &
                spinner $!
                echo -e "\n${CB_GRN}Installation Complete!${C_DEF}"
                wait_keypress
                ;;
            4)
                echo -e "\n${CB_CYN}Installing Security Basics...${C_DEF}"
                pkg install nmap hydra wget curl openssh -y &
                spinner $!
                echo -e "\n${CB_GRN}Installation Complete!${C_DEF}"
                wait_keypress
                ;;
            0) break ;;
            *) echo -e "${CB_RED}Invalid Option.${C_DEF}"; sleep 1 ;;
        esac
    done
}

# ------------------------------------------------------------------------------
# 11. MAIN MENU LOGIC
# ------------------------------------------------------------------------------
main_menu() {
    while true; do
        print_header
        
        echo -e "${CB_WHT}Welcome, ${CB_GRN}$(whoami)${CB_WHT}. Select an operation module:${C_DEF}\n"
        
        print_menu_item "1" "System & Termux Dashboard"
        print_menu_item "2" "Hardware & Device Control API"
        print_menu_item "3" "Network Utilities"
        print_menu_item "4" "Quick File Server (HTTP)"
        print_menu_item "5" "Environment Backup Manager"
        print_menu_item "6" "Dev Stacks 1-Click Installer"
        print_menu_item "A" "About Termux-Omni"
        print_menu_item "0" "Exit Plugin"
        
        echo -e "\n${CB_YLW}root@omni> ${C_DEF}\c"
        read -n 1 -r choice
        echo ""
        
        case $choice in
            1) module_system_dashboard ;;
            2) module_device_control ;;
            3) module_network_tools ;;
            4) module_web_server ;;
            5) module_backup_manager ;;
            6) module_dev_stacks ;;
            A|a) 
               print_header
               echo -e "${CB_CYN}About Termux-Omni${C_DEF}"
               echo -e "${CB_WHT}Version: $VERSION${C_DEF}"
               echo -e "An advanced multi-tool tailored to fully exploit Termux."
               echo -e "Created entirely in pure Bash with Termux-API integrations."
               echo -e "\nDisclaimer: Use backup tools at your own risk. Large backups"
               echo -e "may consume significant internal storage space."
               wait_keypress
               ;;
            0) 
               echo -e "${CB_GRN}Exiting Termux-Omni. Goodbye!${C_DEF}"
               break 
               ;;
            *) 
               echo -e "${CB_RED}Invalid option selected. Try again.${C_DEF}"
               sleep 1
               ;;
        esac
    done
}

# ------------------------------------------------------------------------------
# 12. INITIALIZATION & EXECUTION
# ------------------------------------------------------------------------------
# Clear screen and check things before starting
clear
hide_cursor
echo -e "${CB_BLU}Initializing Termux-Omni...${C_DEF}"
check_dependencies
show_cursor
main_menu
cleanup
