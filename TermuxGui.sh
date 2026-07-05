#!/data/data/com.termux/files/usr/bin/bash
# ============================================================
# Termux GUI Dashboard v2.0
# A full-featured terminal GUI platform for Termux
# File: Termuxgui.sh
# By: Emmanuel Suah
# ============================================================

# --- Colors & Styling ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# --- Configuration ---
VERSION="2.0"
AUTHOR="Termux Dashboard"
LOG_FILE="$HOME/.termux-dashboard.log"
CONFIG_DIR="$HOME/.config/termux-dashboard"
SCRIPTS_DIR="$CONFIG_DIR/scripts"
BOOKMARKS_FILE="$CONFIG_DIR/bookmarks.txt"

# --- Initialization ---
init_dashboard() {
    mkdir -p "$CONFIG_DIR" "$SCRIPTS_DIR"
    touch "$LOG_FILE" "$BOOKMARKS_FILE"

    # Check and install required packages
    local required_packages=("dialog" "curl" "wget" "nano" "git" "python" "nmap" "openssh" "tar" "zip" "unzip")
    local missing_packages=()

    for pkg in "${required_packages[@]}"; do
        if ! command -v "$pkg" &>/dev/null; then
            case "$pkg" in
                "dialog") missing_packages+=("dialog") ;;
                "nmap") ;; # Optional, skip
                "python") ;; # Optional, skip
                *) missing_packages+=("$pkg") ;;
            esac
        fi
    done

    if [ ${#missing_packages[@]} -gt 0 ]; then
        echo -e "${YELLOW}Installing required packages: ${missing_packages[*]}${NC}"
        pkg update -y &>/dev/null
        pkg install -y "${missing_packages[@]}" &>/dev/null
    fi

    # Ensure dialog is installed (critical dependency)
    if ! command -v dialog &>/dev/null; then
        echo -e "${RED}Installing dialog (required)...${NC}"
        pkg install -y dialog
        if ! command -v dialog &>/dev/null; then
            echo -e "${RED}ERROR: Failed to install dialog. Exiting.${NC}"
            exit 1
        fi
    fi
}

# --- Logging ---
log_action() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# --- Utility Functions ---
press_enter() {
    echo ""
    echo -e "${CYAN}Press Enter to continue...${NC}"
    read -r
}

show_banner() {
    clear
    echo -e "${CYAN}"
    echo "╔══════════════════════════════════════════════════════════╗"
    echo "║                                                          ║"
    echo "║           ████████╗███████╗██████╗ ███╗   ███╗           ║"
    echo "║           ╚══██╔══╝██╔════╝██╔══██╗████╗ ████║           ║"
    echo "║              ██║   █████╗  ██████╔╝██╔████╔██║           ║"
    echo "║              ██║   ██╔══╝  ██╔══██╗██║╚██╔╝██║           ║"
    echo "║              ██║   ███████╗██║  ██║██║ ╚═╝ ██║           ║"
    echo "║              ╚═╝   ╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝           ║"
    echo "║                                                          ║"
    echo "║              GUI DASHBOARD v${VERSION}                        ║"
    echo "║                                                          ║"
    echo "╚══════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# ============================================================
# MAIN DASHBOARD MENU
# ============================================================
main_menu() {
    while true; do
        local choice
        choice=$(dialog --clear --backtitle "Termux GUI Dashboard v${VERSION}" \
            --title "[ MAIN DASHBOARD ]" \
            --menu "Select a category:" 22 65 13 \
            "1"  "📦 Package Manager" \
            "2"  "📁 File Manager" \
            "3"  "🌐 Network Tools" \
            "4"  "💻 System Information" \
            "5"  "🔧 Development Tools" \
            "6"  "🔒 Security Tools" \
            "7"  "📥 Download Manager" \
            "8"  "📝 Text Editor" \
            "9"  "🐍 Python Tools" \
            "10" "⚙️  Termux Settings" \
            "11" "📊 Process Manager" \
            "12" "💾 Backup & Restore" \
            "13" "📋 View Logs" \
            "14" "⭐ Bookmarks" \
            "15" "🌐 Web Server Manager" \
            "Q"  "🚪 Exit Dashboard" \
            2>&1 >/dev/tty)

        case $choice in
            1) package_manager_menu ;;
            2) file_manager_menu ;;
            3) network_tools_menu ;;
            4) system_info_menu ;;
            5) dev_tools_menu ;;
            6) security_tools_menu ;;
            7) download_manager_menu ;;
            8) text_editor_menu ;;
            9) python_tools_menu ;;
            10) termux_settings_menu ;;
            11) process_manager_menu ;;
            12) backup_restore_menu ;;
            13) view_logs ;;
            "14") bookmarks_menu ;;
            "15") web_server_menu ;;
            Q|q|"") 
                dialog --yesno "Are you sure you want to exit?" 7 40
                if [ $? -eq 0 ]; then
                    clear
                    echo -e "${GREEN}Thanks for using Termux Dashboard!${NC}"
                    log_action "Dashboard closed"
                    exit 0
                fi
                ;;
        esac
    done
}

# ============================================================
# 1. PACKAGE MANAGER
# ============================================================
package_manager_menu() {
    while true; do
        local choice
        choice=$(dialog --clear --backtitle "Termux GUI Dashboard" \
            --title "[ PACKAGE MANAGER ]" \
            --menu "Select an action:" 20 60 10 \
            "1" "Update Package Lists" \
            "2" "Upgrade All Packages" \
            "3" "Install a Package" \
            "4" "Remove a Package" \
            "5" "Search for Package" \
            "6" "List Installed Packages" \
            "7" "Show Package Info" \
            "8" "Clean Package Cache" \
            "9" "Install Common Packages" \
            "B" "Back to Main Menu" \
            2>&1 >/dev/tty)

        case $choice in
            1)
                dialog --infobox "Updating package lists..." 5 40
                pkg update -y > /tmp/pkg_output.txt 2>&1
                dialog --title "Update Result" --textbox /tmp/pkg_output.txt 20 70
                log_action "Package lists updated"
                ;;
            2)
                dialog --infobox "Upgrading all packages..." 5 40
                pkg upgrade -y > /tmp/pkg_output.txt 2>&1
                dialog --title "Upgrade Result" --textbox /tmp/pkg_output.txt 20 70
                log_action "Packages upgraded"
                ;;
            3)
                local pkg_name
                pkg_name=$(dialog --inputbox "Enter package name to install:" 8 50 2>&1 >/dev/tty)
                if [ -n "$pkg_name" ]; then
                    dialog --infobox "Installing $pkg_name..." 5 40
                    pkg install -y "$pkg_name" > /tmp/pkg_output.txt 2>&1
                    dialog --title "Install Result" --textbox /tmp/pkg_output.txt 20 70
                    log_action "Installed package: $pkg_name"
                fi
                ;;
            4)
                local pkg_name
                pkg_name=$(dialog --inputbox "Enter package name to remove:" 8 50 2>&1 >/dev/tty)
                if [ -n "$pkg_name" ]; then
                    dialog --yesno "Remove $pkg_name?" 7 40
                    if [ $? -eq 0 ]; then
                        pkg uninstall -y "$pkg_name" > /tmp/pkg_output.txt 2>&1
                        dialog --title "Remove Result" --textbox /tmp/pkg_output.txt 20 70
                        log_action "Removed package: $pkg_name"
                    fi
                fi
                ;;
            5)
                local search_term
                search_term=$(dialog --inputbox "Enter search term:" 8 50 2>&1 >/dev/tty)
                if [ -n "$search_term" ]; then
                    pkg search "$search_term" > /tmp/pkg_output.txt 2>&1
                    dialog --title "Search Results for '$search_term'" --textbox /tmp/pkg_output.txt 20 70
                fi
                ;;
            6)
                pkg list-installed > /tmp/pkg_output.txt 2>&1
                dialog --title "Installed Packages" --textbox /tmp/pkg_output.txt 20 70
                ;;
            7)
                local pkg_name
                pkg_name=$(dialog --inputbox "Enter package name:" 8 50 2>&1 >/dev/tty)
                if [ -n "$pkg_name" ]; then
                    pkg show "$pkg_name" > /tmp/pkg_output.txt 2>&1
                    dialog --title "Package Info: $pkg_name" --textbox /tmp/pkg_output.txt 20 70
                fi
                ;;
            8)
                dialog --infobox "Cleaning package cache..." 5 40
                apt clean 2>/dev/null
                pkg clean 2>/dev/null
                sleep 1
                dialog --msgbox "Package cache cleaned!" 6 30
                log_action "Package cache cleaned"
                ;;
            9)
                local packages
                packages=$(dialog --checklist "Select packages to install:" 20 60 12 \
                    "git"       "Version Control System"    off \
                    "python"    "Python Programming"        off \
                    "nodejs"    "Node.js Runtime"           off \
                    "ruby"      "Ruby Programming"          off \
                    "golang"    "Go Programming"            off \
                    "rust"      "Rust Programming"          off \
                    "clang"     "C/C++ Compiler"            off \
                    "vim"       "Vi IMproved Editor"        off \
                    "nano"      "Nano Text Editor"          off \
                    "wget"      "Web Downloader"            off \
                    "curl"      "URL Transfer Tool"         off \
                    "openssh"   "SSH Client/Server"         off \
                    "nmap"      "Network Scanner"           off \
                    "htop"      "Process Viewer"            off \
                    "ffmpeg"    "Media Processing"          off \
                    "imagemagick" "Image Processing"        off \
                    2>&1 >/dev/tty)

                if [ -n "$packages" ]; then
                    # Remove quotes from checklist output
                    packages=$(echo "$packages" | tr -d '"')
                    dialog --infobox "Installing: $packages" 5 60
                    pkg install -y $packages > /tmp/pkg_output.txt 2>&1
                    dialog --title "Installation Result" --textbox /tmp/pkg_output.txt 20 70
                    log_action "Batch installed: $packages"
                fi
                ;;
            B|b|"") return ;;
        esac
    done
}

# ============================================================
# 2. FILE MANAGER
# ============================================================
file_manager_menu() {
    local current_dir="$HOME"

    while true; do
        local choice
        choice=$(dialog --clear --backtitle "Termux GUI Dashboard" \
            --title "[ FILE MANAGER - $current_dir ]" \
            --menu "Select an action:" 22 65 13 \
            "1"  "Browse Current Directory" \
            "2"  "Navigate to Directory" \
            "3"  "Create File" \
            "4"  "Create Directory" \
            "5"  "Delete File/Directory" \
            "6"  "Copy File" \
            "7"  "Move/Rename File" \
            "8"  "View File Content" \
            "9"  "File Permissions" \
            "10" "Search Files" \
            "11" "Disk Usage" \
            "12" "Compress Files (tar.gz)" \
            "13" "Extract Archive" \
            "B"  "Back to Main Menu" \
            2>&1 >/dev/tty)

        case $choice in
            1)
                ls -lahF --color=never "$current_dir" > /tmp/file_list.txt 2>&1
                echo "" >> /tmp/file_list.txt
                echo "--- Directory: $current_dir ---" >> /tmp/file_list.txt
                echo "Total files: $(ls -1 "$current_dir" 2>/dev/null | wc -l)" >> /tmp/file_list.txt
                dialog --title "Directory Listing: $current_dir" --textbox /tmp/file_list.txt 22 75
                ;;
            2)
                local new_dir
                new_dir=$(dialog --inputbox "Enter directory path:" 8 60 "$current_dir" 2>&1 >/dev/tty)
                if [ -n "$new_dir" ] && [ -d "$new_dir" ]; then
                    current_dir="$new_dir"
                    dialog --msgbox "Changed to: $current_dir" 6 50
                elif [ -n "$new_dir" ]; then
                    dialog --msgbox "Directory not found: $new_dir" 6 50
                fi
                ;;
            3)
                local filename
                filename=$(dialog --inputbox "Enter new file name:" 8 50 2>&1 >/dev/tty)
                if [ -n "$filename" ]; then
                    touch "$current_dir/$filename"
                    dialog --msgbox "File created: $current_dir/$filename" 6 50
                    log_action "Created file: $current_dir/$filename"
                fi
                ;;
            4)
                local dirname
                dirname=$(dialog --inputbox "Enter new directory name:" 8 50 2>&1 >/dev/tty)
                if [ -n "$dirname" ]; then
                    mkdir -p "$current_dir/$dirname"
                    dialog --msgbox "Directory created: $current_dir/$dirname" 6 60
                    log_action "Created directory: $current_dir/$dirname"
                fi
                ;;
            5)
                local target
                target=$(dialog --inputbox "Enter file/directory name to delete:" 8 55 2>&1 >/dev/tty)
                if [ -n "$target" ]; then
                    local full_path="$current_dir/$target"
                    if [ -e "$full_path" ]; then
                        dialog --yesno "Delete '$full_path'?\n\nThis cannot be undone!" 8 50
                        if [ $? -eq 0 ]; then
                            rm -rf "$full_path"
                            dialog --msgbox "Deleted: $full_path" 6 50
                            log_action "Deleted: $full_path"
                        fi
                    else
                        dialog --msgbox "Not found: $full_path" 6 50
                    fi
                fi
                ;;
            6)
                local src dst
                src=$(dialog --inputbox "Source file path:" 8 60 "$current_dir/" 2>&1 >/dev/tty)
                if [ -n "$src" ]; then
                    dst=$(dialog --inputbox "Destination path:" 8 60 "$current_dir/" 2>&1 >/dev/tty)
                    if [ -n "$dst" ]; then
                        cp -r "$src" "$dst" 2>/tmp/file_err.txt
                        if [ $? -eq 0 ]; then
                            dialog --msgbox "Copied successfully!" 6 30
                            log_action "Copied: $src -> $dst"
                        else
                            dialog --msgbox "Error: $(cat /tmp/file_err.txt)" 8 50
                        fi
                    fi
                fi
                ;;
            7)
                local src dst
                src=$(dialog --inputbox "Source path:" 8 60 "$current_dir/" 2>&1 >/dev/tty)
                if [ -n "$src" ]; then
                    dst=$(dialog --inputbox "Destination/New name:" 8 60 "$current_dir/" 2>&1 >/dev/tty)
                    if [ -n "$dst" ]; then
                        mv "$src" "$dst" 2>/tmp/file_err.txt
                        if [ $? -eq 0 ]; then
                            dialog --msgbox "Moved/Renamed successfully!" 6 35
                            log_action "Moved: $src -> $dst"
                        else
                            dialog --msgbox "Error: $(cat /tmp/file_err.txt)" 8 50
                        fi
                    fi
                fi
                ;;
            8)
                local filename
                filename=$(dialog --inputbox "Enter file name to view:" 8 55 2>&1 >/dev/tty)
                if [ -n "$filename" ]; then
                    local full_path="$current_dir/$filename"
                    if [ -f "$full_path" ]; then
                        dialog --title "File: $filename" --textbox "$full_path" 22 75
                    else
                        dialog --msgbox "File not found: $full_path" 6 50
                    fi
                fi
                ;;
            9)
                local filename
                filename=$(dialog --inputbox "Enter file name:" 8 50 2>&1 >/dev/tty)
                if [ -n "$filename" ]; then
                    local full_path="$current_dir/$filename"
                    if [ -e "$full_path" ]; then
                        local perms
                        perms=$(dialog --inputbox "Enter permissions (e.g., 755, 644):" 8 50 2>&1 >/dev/tty)
                        if [ -n "$perms" ]; then
                            chmod "$perms" "$full_path" 2>/tmp/file_err.txt
                            if [ $? -eq 0 ]; then
                                dialog --msgbox "Permissions changed to $perms" 6 40
                                log_action "chmod $perms: $full_path"
                            else
                                dialog --msgbox "Error: $(cat /tmp/file_err.txt)" 8 50
                            fi
                        fi
                    else
                        dialog --msgbox "Not found: $full_path" 6 50
                    fi
                fi
                ;;
            10)
                local search_term
                search_term=$(dialog --inputbox "Search for files (name pattern):" 8 55 2>&1 >/dev/tty)
                if [ -n "$search_term" ]; then
                    find "$current_dir" -name "*$search_term*" 2>/dev/null > /tmp/search_results.txt
                    local count
                    count=$(wc -l < /tmp/search_results.txt)
                    echo "" >> /tmp/search_results.txt
                    echo "--- Found $count results ---" >> /tmp/search_results.txt
                    dialog --title "Search Results for '$search_term'" --textbox /tmp/search_results.txt 20 70
                fi
                ;;
            11)
                du -sh "$current_dir"/* 2>/dev/null | sort -rh > /tmp/disk_usage.txt
                echo "" >> /tmp/disk_usage.txt
                echo "--- Total: $(du -sh "$current_dir" 2>/dev/null | cut -f1) ---" >> /tmp/disk_usage.txt
                dialog --title "Disk Usage: $current_dir" --textbox /tmp/disk_usage.txt 20 70
                ;;
            12)
                local src archive_name
                src=$(dialog --inputbox "File/Directory to compress:" 8 60 "$current_dir/" 2>&1 >/dev/tty)
                if [ -n "$src" ]; then
                    archive_name=$(dialog --inputbox "Archive name (without extension):" 8 50 "archive" 2>&1 >/dev/tty)
                    if [ -n "$archive_name" ]; then
                        dialog --infobox "Compressing..." 5 30
                        tar -czf "$current_dir/${archive_name}.tar.gz" -C "$(dirname "$src")" "$(basename "$src")" 2>/tmp/file_err.txt
                        if [ $? -eq 0 ]; then
                            dialog --msgbox "Created: ${archive_name}.tar.gz" 6 45
                            log_action "Compressed: $src -> ${archive_name}.tar.gz"
                        else
                            dialog --msgbox "Error: $(cat /tmp/file_err.txt)" 8 50
                        fi
                    fi
                fi
                ;;
            13)
                local archive
                archive=$(dialog --inputbox "Archive file path:" 8 60 "$current_dir/" 2>&1 >/dev/tty)
                if [ -n "$archive" ] && [ -f "$archive" ]; then
                    local dest
                    dest=$(dialog --inputbox "Extract to:" 8 60 "$current_dir/" 2>&1 >/dev/tty)
                    if [ -n "$dest" ]; then
                        mkdir -p "$dest"
                        dialog --infobox "Extracting..." 5 30
                        case "$archive" in
                            *.tar.gz|*.tgz) tar -xzf "$archive" -C "$dest" 2>/tmp/file_err.txt ;;
                            *.tar.bz2) tar -xjf "$archive" -C "$dest" 2>/tmp/file_err.txt ;;
                            *.tar) tar -xf "$archive" -C "$dest" 2>/tmp/file_err.txt ;;
                            *.zip) unzip -o "$archive" -d "$dest" 2>/tmp/file_err.txt ;;
                            *) echo "Unsupported format" > /tmp/file_err.txt; false ;;
                        esac
                        if [ $? -eq 0 ]; then
                            dialog --msgbox "Extracted to: $dest" 6 50
                            log_action "Extracted: $archive -> $dest"
                        else
                            dialog --msgbox "Error: $(cat /tmp/file_err.txt)" 8 50
                        fi
                    fi
                else
                    dialog --msgbox "Archive not found!" 6 30
                fi
                ;;
            B|b|"") return ;;
        esac
    done
}

# ============================================================
# 3. NETWORK TOOLS
# ============================================================
network_tools_menu() {
    while true; do
        local choice
        choice=$(dialog --clear --backtitle "Termux GUI Dashboard" \
            --title "[ NETWORK TOOLS ]" \
            --menu "Select a tool:" 22 60 13 \
            "1"  "Ping Host" \
            "2"  "DNS Lookup" \
            "3"  "Traceroute" \
            "4"  "Port Scanner (nmap)" \
            "5"  "My IP Address" \
            "6"  "Network Interfaces" \
            "7"  "WiFi Information" \
            "8"  "HTTP Headers" \
            "9"  "Speed Test" \
            "10" "Whois Lookup" \
            "11" "Open Connections" \
            "12" "Download Speed Test" \
            "B"  "Back to Main Menu" \
            2>&1 >/dev/tty)

        case $choice in
            1)
                local host
                host=$(dialog --inputbox "Enter host to ping:" 8 50 "google.com" 2>&1 >/dev/tty)
                if [ -n "$host" ]; then
                    dialog --infobox "Pinging $host..." 5 40
                    ping -c 5 "$host" > /tmp/net_output.txt 2>&1
                    dialog --title "Ping Results: $host" --textbox /tmp/net_output.txt 20 70
                    log_action "Pinged: $host"
                fi
                ;;
            2)
                local domain
                domain=$(dialog --inputbox "Enter domain for DNS lookup:" 8 50 "google.com" 2>&1 >/dev/tty)
                if [ -n "$domain" ]; then
                    {
                        echo "=== DNS Lookup: $domain ==="
                        echo ""
                        if command -v nslookup &>/dev/null; then
                            nslookup "$domain" 2>&1
                        elif command -v dig &>/dev/null; then
                            dig "$domain" 2>&1
                        elif command -v host &>/dev/null; then
                            host "$domain" 2>&1
                        else
                            echo "Resolving via getent..."
                            getent hosts "$domain" 2>&1
                        fi
                    } > /tmp/net_output.txt
                    dialog --title "DNS Lookup: $domain" --textbox /tmp/net_output.txt 20 70
                fi
                ;;
            3)
                local host
                host=$(dialog --inputbox "Enter host for traceroute:" 8 50 "google.com" 2>&1 >/dev/tty)
                if [ -n "$host" ]; then
                    dialog --infobox "Running traceroute to $host..." 5 45
                    if command -v traceroute &>/dev/null; then
                        traceroute "$host" > /tmp/net_output.txt 2>&1
                    else
                        tracepath "$host" > /tmp/net_output.txt 2>&1
                    fi
                    dialog --title "Traceroute: $host" --textbox /tmp/net_output.txt 22 75
                fi
                ;;
            4)
                if ! command -v nmap &>/dev/null; then
                    dialog --yesno "nmap is not installed. Install it?" 7 45
                    if [ $? -eq 0 ]; then
                        dialog --infobox "Installing nmap..." 5 30
                        pkg install -y nmap &>/dev/null
                    else
                        continue
                    fi
                fi
                local target
                target=$(dialog --inputbox "Enter target IP/Host:" 8 50 2>&1 >/dev/tty)
                if [ -n "$target" ]; then
                    local scan_type
                    scan_type=$(dialog --menu "Scan type:" 12 50 4 \
                        "1" "Quick Scan (Top 100 ports)" \
                        "2" "Full Port Scan" \
                        "3" "Service Detection" \
                        "4" "Custom Ports" \
                        2>&1 >/dev/tty)

                    dialog --infobox "Scanning $target..." 5 40
                    case $scan_type in
                        1) nmap --top-ports 100 "$target" > /tmp/net_output.txt 2>&1 ;;
                        2) nmap -p- "$target" > /tmp/net_output.txt 2>&1 ;;
                        3) nmap -sV "$target" > /tmp/net_output.txt 2>&1 ;;
                        4)
                            local ports
                            ports=$(dialog --inputbox "Enter ports (e.g., 80,443,8080):" 8 50 2>&1 >/dev/tty)
                            nmap -p "$ports" "$target" > /tmp/net_output.txt 2>&1
                            ;;
                    esac
                    dialog --title "Nmap Results: $target" --textbox /tmp/net_output.txt 22 75
                    log_action "Nmap scan: $target"
                fi
                ;;
            5)
                {
                    echo "=== IP Address Information ==="
                    echo ""
                    echo "--- Local IP ---"
                    ip addr show 2>/dev/null | grep "inet " | awk '{print $2}' || echo "N/A"
                    echo ""
                    echo "--- Public IP ---"
                    local pub_ip
                    pub_ip=$(curl -s --max-time 10 ifconfig.me 2>/dev/null || curl -s --max-time 10 icanhazip.com 2>/dev/null || echo "Could not determine")
                    echo "$pub_ip"
                    echo ""
                    echo "--- IP Geolocation ---"
                    curl -s --max-time 10 "ipinfo.io/$pub_ip" 2>/dev/null || echo "Could not fetch geolocation"
                } > /tmp/net_output.txt
                dialog --title "IP Address Info" --textbox /tmp/net_output.txt 22 70
                ;;
            6)
                {
                    echo "=== Network Interfaces ==="
                    echo ""
                    ip addr show 2>/dev/null || ifconfig 2>/dev/null || echo "No network tools available"
                } > /tmp/net_output.txt
                dialog --title "Network Interfaces" --textbox /tmp/net_output.txt 22 75
                ;;
            7)
                {
                    echo "=== WiFi Information ==="
                    echo ""
                    if command -v termux-wifi-connectioninfo &>/dev/null; then
                        termux-wifi-connectioninfo 2>&1
                    else
                        echo "Install termux-api package for WiFi info:"
                        echo "  pkg install termux-api"
                        echo ""
                        echo "Current network info:"
                        ip route 2>/dev/null
                    fi
                } > /tmp/net_output.txt
                dialog --title "WiFi Information" --textbox /tmp/net_output.txt 20 70
                ;;
            8)
                local url
                url=$(dialog --inputbox "Enter URL:" 8 60 "https://google.com" 2>&1 >/dev/tty)
                if [ -n "$url" ]; then
                    curl -sI --max-time 15 "$url" > /tmp/net_output.txt 2>&1
                    dialog --title "HTTP Headers: $url" --textbox /tmp/net_output.txt 20 70
                fi
                ;;
            9)
                dialog --infobox "Testing download speed...\nThis may take a moment." 6 45
                {
                    echo "=== Internet Speed Test ==="
                    echo ""
                    echo "Downloading 10MB test file..."
                    local start_time end_time duration size speed
                    start_time=$(date +%s%N)
                    curl -so /dev/null --max-time 30 "http://speedtest.tele2.net/10MB.zip" 2>&1
                    end_time=$(date +%s%N)
                    duration=$(( (end_time - start_time) / 1000000 ))
                    if [ "$duration" -gt 0 ]; then
                        speed=$(( 10 * 1000 * 8 / duration ))
                        echo "Duration: ${duration}ms"
                        echo "Speed: ~${speed} Mbps"
                    else
                        echo "Speed test failed or too fast to measure"
                    fi
                } > /tmp/net_output.txt
                dialog --title "Speed Test Results" --textbox /tmp/net_output.txt 15 55
                ;;
            10)
                local domain
                domain=$(dialog --inputbox "Enter domain for whois:" 8 50 2>&1 >/dev/tty)
                if [ -n "$domain" ]; then
                    if command -v whois &>/dev/null; then
                        whois "$domain" > /tmp/net_output.txt 2>&1
                    else
                        curl -s "https://whois.domaintools.com/$domain" > /tmp/net_output.txt 2>&1
                    fi
                    dialog --title "Whois: $domain" --textbox /tmp/net_output.txt 22 75
                fi
                ;;
            11)
                {
                    echo "=== Open Connections ==="
                    echo ""
                    if command -v ss &>/dev/null; then
                        ss -tuln 2>&1
                    elif command -v netstat &>/dev/null; then
                        netstat -tuln 2>&1
                    else
                        echo "No connection tools available"
                        echo "Install: pkg install net-tools"
                    fi
                } > /tmp/net_output.txt
                dialog --title "Open Connections" --textbox /tmp/net_output.txt 22 75
                ;;
            12)
                dialog --infobox "Testing download speed..." 5 40
                {
                    echo "=== Download Speed Test ==="
                    echo ""
                    for size in 1 5 10; do
                        echo "--- ${size}MB file ---"
                        curl -so /dev/null -w "Speed: %{speed_download} bytes/sec\nTime: %{time_total}s\n" \
                            --max-time 30 "http://speedtest.tele2.net/${size}MB.zip" 2>&1
                        echo ""
                    done
                } > /tmp/net_output.txt
                dialog --title "Download Speed Test" --textbox /tmp/net_output.txt 20 60
                ;;
            B|b|"") return ;;
        esac
    done
}

# ============================================================
# 4. SYSTEM INFORMATION
# ============================================================
system_info_menu() {
    while true; do
        local choice
        choice=$(dialog --clear --backtitle "Termux GUI Dashboard" \
            --title "[ SYSTEM INFORMATION ]" \
            --menu "Select info:" 20 60 10 \
            "1" "Full System Overview" \
            "2" "CPU Information" \
            "3" "Memory Usage" \
            "4" "Storage Information" \
            "5" "Battery Status" \
            "6" "Android Device Info" \
            "7" "Environment Variables" \
            "8" "Uptime & Load" \
            "9" "Kernel Information" \
            "B" "Back to Main Menu" \
            2>&1 >/dev/tty)

        case $choice in
            1)
                {
                    echo "╔══════════════════════════════════════╗"
                    echo "║       SYSTEM OVERVIEW                ║"
                    echo "╚══════════════════════════════════════╝"
                    echo ""
                    echo "USER:     $(whoami)"
                    echo "HOME:     $HOME"
                    echo "SHELL:    $SHELL"
                    echo "TERM:     $TERM"
                    echo "HOSTNAME: $(hostname 2>/dev/null || echo 'N/A')"
                    echo ""
                    echo "--- OS Info ---"
                    uname -a 2>/dev/null
                    echo ""
                    echo "--- CPU ---"
                    grep "model name" /proc/cpuinfo 2>/dev/null | head -1 | cut -d: -f2 || echo "N/A"
                    echo "Cores: $(nproc 2>/dev/null || grep -c processor /proc/cpuinfo 2>/dev/null || echo 'N/A')"
                    echo ""
                    echo "--- Memory ---"
                    free -h 2>/dev/null || cat /proc/meminfo 2>/dev/null | head -3
                    echo ""
                    echo "--- Storage ---"
                    df -h "$HOME" 2>/dev/null
                    echo ""
                    echo "--- Termux ---"
                    echo "PREFIX:  $PREFIX"
                    echo "Version: $(pkg --version 2>/dev/null | head -1 || echo 'N/A')"
                } > /tmp/sys_info.txt
                dialog --title "System Overview" --textbox /tmp/sys_info.txt 25 70
                ;;
            2)
                {
                    echo "=== CPU Information ==="
                    echo ""
                    cat /proc/cpuinfo 2>/dev/null || echo "CPU info not available"
                } > /tmp/sys_info.txt
                dialog --title "CPU Information" --textbox /tmp/sys_info.txt 22 75
                ;;
            3)
                {
                    echo "=== Memory Usage ==="
                    echo ""
                    free -h 2>/dev/null || echo "free command not available"
                    echo ""
                    echo "=== Detailed Memory Info ==="
                    echo ""
                    cat /proc/meminfo 2>/dev/null | head -20
                } > /tmp/sys_info.txt
                dialog --title "Memory Usage" --textbox /tmp/sys_info.txt 22 70
                ;;
            4)
                {
                    echo "=== Storage Information ==="
                    echo ""
                    df -h 2>/dev/null
                    echo ""
                    echo "=== Home Directory ==="
                    du -sh "$HOME" 2>/dev/null
                    echo ""
                    echo "=== Termux Prefix ==="
                    du -sh "$PREFIX" 2>/dev/null
                } > /tmp/sys_info.txt
                dialog --title "Storage Information" --textbox /tmp/sys_info.txt 22 70
                ;;
            5)
                {
                    echo "=== Battery Status ==="
                    echo ""
                    if command -v termux-battery-status &>/dev/null; then
                        termux-battery-status 2>&1
                    else
                        echo "Install termux-api for battery info:"
                        echo "  pkg install termux-api"
                        echo ""
                        echo "Attempting to read from sysfs..."
                        echo ""
                        for f in /sys/class/power_supply/battery/*; do
                            if [ -r "$f" ] && [ -f "$f" ]; then
                                echo "$(basename "$f"): $(cat "$f" 2>/dev/null)"
                            fi
                        done
                    fi
                } > /tmp/sys_info.txt
                dialog --title "Battery Status" --textbox /tmp/sys_info.txt 20 60
                ;;
            6)
                {
                    echo "=== Android Device Info ==="
                    echo ""
                    echo "Android Version: $(getprop ro.build.version.release 2>/dev/null || echo 'N/A')"
                    echo "SDK Level:       $(getprop ro.build.version.sdk 2>/dev/null || echo 'N/A')"
                    echo "Device Model:    $(getprop ro.product.model 2>/dev/null || echo 'N/A')"
                    echo "Manufacturer:    $(getprop ro.product.manufacturer 2>/dev/null || echo 'N/A')"
                    echo "Brand:           $(getprop ro.product.brand 2>/dev/null || echo 'N/A')"
                    echo "Board:           $(getprop ro.product.board 2>/dev/null || echo 'N/A')"
                    echo "Hardware:        $(getprop ro.hardware 2>/dev/null || echo 'N/A')"
                    echo "Architecture:    $(uname -m 2>/dev/null || echo 'N/A')"
                    echo "Build Number:    $(getprop ro.build.display.id 2>/dev/null || echo 'N/A')"
                    echo "Security Patch:  $(getprop ro.build.version.security_patch 2>/dev/null || echo 'N/A')"
                    echo "Fingerprint:     $(getprop ro.build.fingerprint 2>/dev/null || echo 'N/A')"
                } > /tmp/sys_info.txt
                dialog --title "Android Device Info" --textbox /tmp/sys_info.txt 20 70
                ;;
            7)
                env | sort > /tmp/sys_info.txt
                dialog --title "Environment Variables" --textbox /tmp/sys_info.txt 22 75
                ;;
            8)
                {
                    echo "=== Uptime & Load ==="
                    echo ""
                    uptime 2>/dev/null || echo "Uptime not available"
                    echo ""
                    echo "=== Load Average ==="
                    cat /proc/loadavg 2>/dev/null || echo "N/A"
                } > /tmp/sys_info.txt
                dialog --title "Uptime & Load" --textbox /tmp/sys_info.txt 12 60
                ;;
            9)
                {
                    echo "=== Kernel Information ==="
                    echo ""
                    echo "Kernel:  $(uname -r 2>/dev/null)"
                    echo "System:  $(uname -s 2>/dev/null)"
                    echo "Machine: $(uname -m 2>/dev/null)"
                    echo "Full:    $(uname -a 2>/dev/null)"
                    echo ""
                    echo "=== Kernel Version ==="
                    cat /proc/version 2>/dev/null || echo "N/A"
                } > /tmp/sys_info.txt
                dialog --title "Kernel Information" --textbox /tmp/sys_info.txt 15 75
                ;;
            B|b|"") return ;;
        esac
    done
}

# ============================================================
# 5. DEVELOPMENT TOOLS
# ============================================================
dev_tools_menu() {
    while true; do
        local choice
        choice=$(dialog --clear --backtitle "Termux GUI Dashboard" \
            --title "[ DEVELOPMENT TOOLS ]" \
            --menu "Select a tool:" 22 60 13 \
            "1"  "Git Manager" \
            "2"  "Python Console" \
            "3"  "Node.js Console" \
            "4"  "Run Shell Script" \
            "5"  "Create Shell Script" \
            "6"  "Compile C/C++ Code" \
            "7"  "Code Snippet Manager" \
            "8"  "JSON Formatter" \
            "9"  "Base64 Encode/Decode" \
            "10" "Hash Generator" \
            "11" "HTTP API Tester" \
            "12" "SSH Manager" \
            "B"  "Back to Main Menu" \
            2>&1 >/dev/tty)

        case $choice in
            1) git_manager ;;
            2)
                if command -v python &>/dev/null; then
                    dialog --msgbox "Starting Python console...\nType exit() to return." 7 45
                    clear
                    python
                else
                    dialog --yesno "Python not installed. Install?" 7 40
                    [ $? -eq 0 ] && pkg install -y python
                fi
                ;;
            3)
                if command -v node &>/dev/null; then
                    dialog --msgbox "Starting Node.js console...\nType .exit to return." 7 45
                    clear
                    node
                else
                    dialog --yesno "Node.js not installed. Install?" 7 40
                    [ $? -eq 0 ] && pkg install -y nodejs
                fi
                ;;
            4)
                local script
                script=$(dialog --inputbox "Enter script path:" 8 60 "$HOME/" 2>&1 >/dev/tty)
                if [ -n "$script" ] && [ -f "$script" ]; then
                    clear
                    echo -e "${GREEN}Running: $script${NC}"
                    echo "================================"
                    bash "$script"
                    echo "================================"
                    echo -e "${GREEN}Script finished.${NC}"
                    press_enter
                    log_action "Ran script: $script"
                else
                    dialog --msgbox "Script not found: $script" 6 50
                fi
                ;;
            5)
                local script_name
                script_name=$(dialog --inputbox "Script name (.sh):" 8 50 "my_script.sh" 2>&1 >/dev/tty)
                if [ -n "$script_name" ]; then
                    local script_path="$HOME/$script_name"
                    cat > "$script_path" << 'TEMPLATE'
#!/data/data/com.termux/files/usr/bin/bash
# Script created by Termux Dashboard
# Date: $(date)

echo "Hello from $0!"

# Your code here

TEMPLATE
                    chmod +x "$script_path"
                    dialog --yesno "Script created: $script_path\n\nOpen in editor?" 8 50
                    if [ $? -eq 0 ]; then
                        nano "$script_path" || vi "$script_path"
                    fi
                    log_action "Created script: $script_path"
                fi
                ;;
            6)
                if ! command -v clang &>/dev/null; then
                    dialog --yesno "clang not installed. Install?" 7 40
                    if [ $? -eq 0 ]; then
                        pkg install -y clang
                    else
                        continue
                    fi
                fi
                local src
                src=$(dialog --inputbox "Source file path (.c or .cpp):" 8 60 2>&1 >/dev/tty)
                if [ -n "$src" ] && [ -f "$src" ]; then
                    local output="${src%.*}"
                    dialog --infobox "Compiling $src..." 5 40
                    if [[ "$src" == *.cpp ]]; then
                        clang++ -o "$output" "$src" > /tmp/compile_output.txt 2>&1
                    else
                        clang -o "$output" "$src" > /tmp/compile_output.txt 2>&1
                    fi
                    if [ $? -eq 0 ]; then
                        dialog --yesno "Compilation successful!\nOutput: $output\n\nRun now?" 8 50
                        if [ $? -eq 0 ]; then
                            clear
                            "$output"
                            press_enter
                        fi
                    else
                        dialog --title "Compilation Errors" --textbox /tmp/compile_output.txt 20 70
                    fi
                else
                    dialog --msgbox "Source file not found!" 6 35
                fi
                ;;
            7)
                code_snippet_manager
                ;;
            8)
                local json_input
                json_input=$(dialog --inputbox "Enter JSON string or file path:" 8 60 2>&1 >/dev/tty)
                if [ -n "$json_input" ]; then
                    if [ -f "$json_input" ]; then
                        python -m json.tool "$json_input" > /tmp/json_output.txt 2>&1
                    else
                        echo "$json_input" | python -m json.tool > /tmp/json_output.txt 2>&1
                    fi
                    dialog --title "Formatted JSON" --textbox /tmp/json_output.txt 20 70
                fi
                ;;
            9)
                local b64_choice
                b64_choice=$(dialog --menu "Base64:" 10 40 2 \
                    "1" "Encode" \
                    "2" "Decode" \
                    2>&1 >/dev/tty)
                local input
                input=$(dialog --inputbox "Enter text:" 8 60 2>&1 >/dev/tty)
                if [ -n "$input" ]; then
                    local result
                    if [ "$b64_choice" = "1" ]; then
                        result=$(echo -n "$input" | base64)
                    else
                        result=$(echo -n "$input" | base64 -d 2>&1)
                    fi
                    dialog --msgbox "Result:\n\n$result" 10 60
                fi
                ;;
            10)
                local text
                text=$(dialog --inputbox "Enter text to hash:" 8 60 2>&1 >/dev/tty)
                if [ -n "$text" ]; then
                    {
                        echo "=== Hash Results ==="
                        echo ""
                        echo "MD5:    $(echo -n "$text" | md5sum | cut -d' ' -f1)"
                        echo ""
                        echo "SHA1:   $(echo -n "$text" | sha1sum | cut -d' ' -f1)"
                        echo ""
                        echo "SHA256: $(echo -n "$text" | sha256sum | cut -d' ' -f1)"
                        echo ""
                        echo "SHA512: $(echo -n "$text" | sha512sum | cut -d' ' -f1)"
                    } > /tmp/hash_output.txt
                    dialog --title "Hash Generator" --textbox /tmp/hash_output.txt 15 75
                fi
                ;;
            11)
                local method
                method=$(dialog --menu "HTTP Method:" 12 40 5 \
                    "GET"    "GET Request" \
                    "POST"   "POST Request" \
                    "PUT"    "PUT Request" \
                    "DELETE" "DELETE Request" \
                    "HEAD"   "HEAD Request" \
                    2>&1 >/dev/tty)
                if [ -n "$method" ]; then
                    local url
                    url=$(dialog --inputbox "Enter URL:" 8 60 "https://httpbin.org/get" 2>&1 >/dev/tty)
                    if [ -n "$url" ]; then
                        dialog --infobox "Sending $method request..." 5 40
                        if [ "$method" = "POST" ] || [ "$method" = "PUT" ]; then
                            local body
                            body=$(dialog --inputbox "Request body (JSON):" 8 60 '{"key":"value"}' 2>&1 >/dev/tty)
                            curl -s -X "$method" -H "Content-Type: application/json" -d "$body" "$url" > /tmp/api_output.txt 2>&1
                        else
                            curl -s -X "$method" "$url" > /tmp/api_output.txt 2>&1
                        fi
                        # Try to format JSON
                        if command -v python &>/dev/null; then
                            python -m json.tool /tmp/api_output.txt > /tmp/api_formatted.txt 2>/dev/null
                            if [ $? -eq 0 ]; then
                                cp /tmp/api_formatted.txt /tmp/api_output.txt
                            fi
                        fi
                        dialog --title "$method Response" --textbox /tmp/api_output.txt 22 75
                    fi
                fi
                ;;
            12) ssh_manager ;;
            B|b|"") return ;;
        esac
    done
}

# --- Git Manager Sub-menu ---
git_manager() {
    if ! command -v git &>/dev/null; then
        dialog --yesno "Git is not installed. Install?" 7 40
        if [ $? -eq 0 ]; then
            pkg install -y git
        else
            return
        fi
    fi

    while true; do
        local choice
        choice=$(dialog --clear --backtitle "Termux GUI Dashboard" \
            --title "[ GIT MANAGER ]" \
            --menu "Select action:" 18 55 9 \
            "1" "Clone Repository" \
            "2" "Initialize Repository" \
            "3" "Git Status" \
            "4" "Git Log" \
            "5" "Git Add & Commit" \
            "6" "Git Push" \
            "7" "Git Pull" \
            "8" "Git Config" \
            "B" "Back" \
            2>&1 >/dev/tty)

        case $choice in
            1)
                local repo_url
                repo_url=$(dialog --inputbox "Repository URL:" 8 65 2>&1 >/dev/tty)
                if [ -n "$repo_url" ]; then
                    local dest
                    dest=$(dialog --inputbox "Clone to directory:" 8 60 "$HOME/" 2>&1 >/dev/tty)
                    dialog --infobox "Cloning repository..." 5 40
                    git clone "$repo_url" "$dest" > /tmp/git_output.txt 2>&1
                    dialog --title "Clone Result" --textbox /tmp/git_output.txt 15 70
                    log_action "Git clone: $repo_url"
                fi
                ;;
            2)
                local dir
                dir=$(dialog --inputbox "Directory to initialize:" 8 55 "$(pwd)" 2>&1 >/dev/tty)
                if [ -n "$dir" ]; then
                    mkdir -p "$dir"
                    cd "$dir" && git init > /tmp/git_output.txt 2>&1
                    dialog --title "Git Init" --textbox /tmp/git_output.txt 10 60
                fi
                ;;
            3)
                local dir
                dir=$(dialog --inputbox "Repository directory:" 8 55 "$(pwd)" 2>&1 >/dev/tty)
                if [ -d "$dir" ]; then
                    cd "$dir" && git status > /tmp/git_output.txt 2>&1
                    dialog --title "Git Status" --textbox /tmp/git_output.txt 20 70
                fi
                ;;
            4)
                local dir
                dir=$(dialog --inputbox "Repository directory:" 8 55 "$(pwd)" 2>&1 >/dev/tty)
                if [ -d "$dir" ]; then
                    cd "$dir" && git log --oneline -20 > /tmp/git_output.txt 2>&1
                    dialog --title "Git Log (Last 20)" --textbox /tmp/git_output.txt 22 75
                fi
                ;;
            5)
                local dir
                dir=$(dialog --inputbox "Repository directory:" 8 55 "$(pwd)" 2>&1 >/dev/tty)
                if [ -d "$dir" ]; then
                    cd "$dir"
                    local msg
                    msg=$(dialog --inputbox "Commit message:" 8 55 2>&1 >/dev/tty)
                    if [ -n "$msg" ]; then
                        git add -A > /tmp/git_output.txt 2>&1
                        git commit -m "$msg" >> /tmp/git_output.txt 2>&1
                        dialog --title "Commit Result" --textbox /tmp/git_output.txt 15 70
                        log_action "Git commit: $msg"
                    fi
                fi
                ;;
            6)
                local dir
                dir=$(dialog --inputbox "Repository directory:" 8 55 "$(pwd)" 2>&1 >/dev/tty)
                if [ -d "$dir" ]; then
                    cd "$dir"
                    dialog --infobox "Pushing..." 5 30
                    git push > /tmp/git_output.txt 2>&1
                    dialog --title "Push Result" --textbox /tmp/git_output.txt 15 70
                fi
                ;;
            7)
                local dir
                dir=$(dialog --inputbox "Repository directory:" 8 55 "$(pwd)" 2>&1 >/dev/tty)
                if [ -d "$dir" ]; then
                    cd "$dir"
                    dialog --infobox "Pulling..." 5 30
                    git pull > /tmp/git_output.txt 2>&1
                    dialog --title "Pull Result" --textbox /tmp/git_output.txt 15 70
                fi
                ;;
            8)
                local name email
                name=$(dialog --inputbox "Your Name:" 8 50 "$(git config --global user.name 2>/dev/null)" 2>&1 >/dev/tty)
                email=$(dialog --inputbox "Your Email:" 8 50 "$(git config --global user.email 2>/dev/null)" 2>&1 >/dev/tty)
                if [ -n "$name" ]; then
                    git config --global user.name "$name"
                fi
                if [ -n "$email" ]; then
                    git config --global user.email "$email"
                fi
                dialog --msgbox "Git config updated!\n\nName: $name\nEmail: $email" 9 45
                ;;
            B|b|"") return ;;
        esac
    done
}

# --- Code Snippet Manager ---
code_snippet_manager() {
    local snippets_dir="$CONFIG_DIR/snippets"
    mkdir -p "$snippets_dir"

    while true; do
        local choice
        choice=$(dialog --menu "Code Snippets:" 12 50 4 \
            "1" "Save New Snippet" \
            "2" "View Snippets" \
            "3" "Delete Snippet" \
            "B" "Back" \
            2>&1 >/dev/tty)

        case $choice in
            1)
                local name
                name=$(dialog --inputbox "Snippet name:" 8 40 2>&1 >/dev/tty)
                if [ -n "$name" ]; then
                    local lang
                    lang=$(dialog --menu "Language:" 14 40 6 \
                        "bash" "Bash/Shell" \
                        "python" "Python" \
                        "javascript" "JavaScript" \
                        "c" "C" \
                        "cpp" "C++" \
                        "other" "Other" \
                        2>&1 >/dev/tty)
                    local content
                    content=$(dialog --inputbox "Code (or edit in nano after):" 10 65 2>&1 >/dev/tty)
                    echo "# Language: $lang" > "$snippets_dir/$name"
                    echo "# Created: $(date)" >> "$snippets_dir/$name"
                    echo "" >> "$snippets_dir/$name"
                    echo "$content" >> "$snippets_dir/$name"
                    dialog --yesno "Open in editor to add more?" 7 40
                    [ $? -eq 0 ] && nano "$snippets_dir/$name"
                    dialog --msgbox "Snippet saved!" 6 25
                fi
                ;;
            2)
                local snippets
                snippets=$(ls "$snippets_dir" 2>/dev/null)
                if [ -z "$snippets" ]; then
                    dialog --msgbox "No snippets saved." 6 30
                else
                    local snip
                    snip=$(dialog --menu "Select snippet:" 15 50 8 \
                        $(for s in $snippets; do echo "$s" "$s"; done) \
                        2>&1 >/dev/tty)
                    if [ -n "$snip" ] && [ -f "$snippets_dir/$snip" ]; then
                        dialog --title "Snippet: $snip" --textbox "$snippets_dir/$snip" 20 70
                    fi
                fi
                ;;
            3)
                local snippets
                snippets=$(ls "$snippets_dir" 2>/dev/null)
                if [ -z "$snippets" ]; then
                    dialog --msgbox "No snippets to delete." 6 35
                else
                    local snip
                    snip=$(dialog --menu "Delete which snippet?" 15 50 8 \
                        $(for s in $snippets; do echo "$s" "$s"; done) \
                        2>&1 >/dev/tty)
                    if [ -n "$snip" ]; then
                        dialog --yesno "Delete '$snip'?" 7 35
                        [ $? -eq 0 ] && rm "$snippets_dir/$snip"
                    fi
                fi
                ;;
            B|b|"") return ;;
        esac
    done
}

# --- SSH Manager ---
ssh_manager() {
    while true; do
        local choice
        choice=$(dialog --menu "SSH Manager:" 14 50 5 \
            "1" "Connect to SSH Server" \
            "2" "Generate SSH Key" \
            "3" "View Public Key" \
            "4" "Start SSH Server" \
            "B" "Back" \
            2>&1 >/dev/tty)

        case $choice in
            1)
                local user host port
                user=$(dialog --inputbox "Username:" 8 40 2>&1 >/dev/tty)
                host=$(dialog --inputbox "Host/IP:" 8 40 2>&1 >/dev/tty)
                port=$(dialog --inputbox "Port:" 8 40 "22" 2>&1 >/dev/tty)
                if [ -n "$user" ] && [ -n "$host" ]; then
                    clear
                    ssh -p "${port:-22}" "$user@$host"
                    press_enter
                fi
                ;;
            2)
                local keytype
                keytype=$(dialog --menu "Key type:" 10 40 3 \
                    "rsa" "RSA 4096-bit" \
                    "ed25519" "Ed25519 (recommended)" \
                    "ecdsa" "ECDSA" \
                    2>&1 >/dev/tty)
                if [ -n "$keytype" ]; then
                    clear
                    if [ "$keytype" = "rsa" ]; then
                        ssh-keygen -t rsa -b 4096
                    else
                        ssh-keygen -t "$keytype"
                    fi
                    press_enter
                    log_action "Generated SSH key: $keytype"
                fi
                ;;
            3)
                local key_file=""
                for f in "$HOME/.ssh/id_ed25519.pub" "$HOME/.ssh/id_rsa.pub" "$HOME/.ssh/id_ecdsa.pub"; do
                    [ -f "$f" ] && key_file="$f" && break
                done
                if [ -n "$key_file" ]; then
                    dialog --title "Public Key ($key_file)" --textbox "$key_file" 10 75
                else
                    dialog --msgbox "No SSH public key found.\nGenerate one first." 7 40
                fi
                ;;
            4)
                if command -v sshd &>/dev/null; then
                    sshd
                    dialog --msgbox "SSH server started on port 8022\n\nConnect: ssh user@<ip> -p 8022" 8 50
                    log_action "SSH server started"
                else
                    dialog --yesno "OpenSSH not installed. Install?" 7 40
                    [ $? -eq 0 ] && pkg install -y openssh
                fi
                ;;
            B|b|"") return ;;
        esac
    done
}

# ============================================================
# 6. SECURITY TOOLS
# ============================================================
security_tools_menu() {
    while true; do
        local choice
        choice=$(dialog --clear --backtitle "Termux GUI Dashboard" \
            --title "[ SECURITY TOOLS ]" \
            --menu "Select a tool:" 18 55 9 \
            "1" "Password Generator" \
            "2" "File Checksum Verifier" \
            "3" "Encrypt File (GPG)" \
            "4" "Decrypt File (GPG)" \
            "5" "SSL Certificate Check" \
            "6" "Permission Auditor" \
            "7" "Port Scanner (Simple)" \
            "8" "Security Checklist" \
            "B" "Back to Main Menu" \
            2>&1 >/dev/tty)

        case $choice in
            1)
                local length
                length=$(dialog --inputbox "Password length:" 8 40 "16" 2>&1 >/dev/tty)
                if [ -n "$length" ]; then
                    local pw_type
                    pw_type=$(dialog --menu "Password type:" 12 50 4 \
                        "1" "Alphanumeric + Symbols" \
                        "2" "Alphanumeric Only" \
                        "3" "Numbers Only" \
                        "4" "Hex Only" \
                        2>&1 >/dev/tty)
                    local passwords=""
                    for i in $(seq 1 5); do
                        case $pw_type in
                            1) pw=$(cat /dev/urandom | tr -dc 'A-Za-z0-9!@#$%^&*()_+-=' | head -c "$length") ;;
                            2) pw=$(cat /dev/urandom | tr -dc 'A-Za-z0-9' | head -c "$length") ;;
                            3) pw=$(cat /dev/urandom | tr -dc '0-9' | head -c "$length") ;;
                            4) pw=$(cat /dev/urandom | tr -dc 'a-f0-9' | head -c "$length") ;;
                        esac
                        passwords="$passwords\n$i: $pw"
                    done
                    dialog --msgbox "Generated Passwords ($length chars):\n$passwords" 12 65
                    log_action "Generated passwords"
                fi
                ;;
            2)
                local filepath
                filepath=$(dialog --inputbox "File path:" 8 60 2>&1 >/dev/tty)
                if [ -n "$filepath" ] && [ -f "$filepath" ]; then
                    {
                        echo "=== Checksums for: $filepath ==="
                        echo ""
                        echo "MD5:    $(md5sum "$filepath" | cut -d' ' -f1)"
                        echo ""
                        echo "SHA1:   $(sha1sum "$filepath" | cut -d' ' -f1)"
                        echo ""
                        echo "SHA256: $(sha256sum "$filepath" | cut -d' ' -f1)"
                    } > /tmp/checksum_output.txt
                    dialog --title "File Checksums" --textbox /tmp/checksum_output.txt 12 75
                else
                    dialog --msgbox "File not found!" 6 25
                fi
                ;;
            3)
                if ! command -v gpg &>/dev/null; then
                    dialog --yesno "gpg not installed. Install gnupg?" 7 40
                    [ $? -eq 0 ] && pkg install -y gnupg
                    continue
                fi
                local filepath
                filepath=$(dialog --inputbox "File to encrypt:" 8 60 2>&1 >/dev/tty)
                if [ -n "$filepath" ] && [ -f "$filepath" ]; then
                    clear
                    gpg -c "$filepath"
                    if [ $? -eq 0 ]; then
                        dialog --msgbox "File encrypted: ${filepath}.gpg" 6 50
                    else
                        dialog --msgbox "Encryption failed!" 6 30
                    fi
                fi
                ;;
            4)
                local filepath
                filepath=$(dialog --inputbox "File to decrypt (.gpg):" 8 60 2>&1 >/dev/tty)
                if [ -n "$filepath" ] && [ -f "$filepath" ]; then
                    clear
                    gpg -d "$filepath" > "${filepath%.gpg}" 2>/tmp/gpg_err.txt
                    if [ $? -eq 0 ]; then
                        dialog --msgbox "File decrypted: ${filepath%.gpg}" 6 50
                    else
                        dialog --msgbox "Decryption failed!\n$(cat /tmp/gpg_err.txt)" 8 50
                    fi
                fi
                ;;
            5)
                local domain
                domain=$(dialog --inputbox "Domain to check SSL:" 8 50 "google.com" 2>&1 >/dev/tty)
                if [ -n "$domain" ]; then
                    {
                        echo "=== SSL Certificate: $domain ==="
                        echo ""
                        echo | openssl s_client -connect "$domain:443" -servername "$domain" 2>/dev/null | openssl x509 -noout -text 2>/dev/null | head -30
                        echo ""
                        echo "=== Expiry ==="
                        echo | openssl s_client -connect "$domain:443" -servername "$domain" 2>/dev/null | openssl x509 -noout -dates 2>/dev/null
                    } > /tmp/ssl_output.txt
                    dialog --title "SSL Certificate: $domain" --textbox /tmp/ssl_output.txt 22 75
                fi
                ;;
            6)
                {
                    echo "=== Permission Audit: $HOME ==="
                    echo ""
                    echo "--- World-readable files ---"
                    find "$HOME" -maxdepth 2 -perm -o+r -type f 2>/dev/null | head -20
                    echo ""
                    echo "--- World-writable files ---"
                    find "$HOME" -maxdepth 2 -perm -o+w -type f 2>/dev/null | head -20
                    echo ""
                    echo "--- SUID files ---"
                    find "$PREFIX" -perm -4000 -type f 2>/dev/null | head -10
                    echo ""
                    echo "--- SSH Key Permissions ---"
                    ls -la "$HOME/.ssh/" 2>/dev/null || echo "No .ssh directory"
                } > /tmp/audit_output.txt
                dialog --title "Permission Audit" --textbox /tmp/audit_output.txt 22 75
                ;;
            7)
                local target
                target=$(dialog --inputbox "Target host:" 8 50 "127.0.0.1" 2>&1 >/dev/tty)
                if [ -n "$target" ]; then
                    local start_port end_port
                    start_port=$(dialog --inputbox "Start port:" 8 30 "1" 2>&1 >/dev/tty)
                    end_port=$(dialog --inputbox "End port:" 8 30 "1024" 2>&1 >/dev/tty)
                    dialog --infobox "Scanning $target:$start_port-$end_port...\nThis may take a while." 6 45

                    {
                        echo "=== Port Scan: $target ($start_port-$end_port) ==="
                        echo ""
                        for port in $(seq "$start_port" "$end_port"); do
                            (echo >/dev/tcp/"$target"/"$port") 2>/dev/null && echo "Port $port: OPEN"
                        done
                        echo ""
                        echo "--- Scan Complete ---"
                    } > /tmp/portscan_output.txt 2>/dev/null

                    dialog --title "Port Scan Results" --textbox /tmp/portscan_output.txt 20 50
                    log_action "Port scan: $target ($start_port-$end_port)"
                fi
                ;;
            8)
                {
                    echo "=== Termux Security Checklist ==="
                    echo ""

                    echo -n "[1] SSH keys exist: "
                    [ -d "$HOME/.ssh" ] && echo "YES ✓" || echo "NO ✗"

                    echo -n "[2] SSH key permissions: "
                    if [ -f "$HOME/.ssh/id_rsa" ]; then
                        local perm
                        perm=$(stat -c %a "$HOME/.ssh/id_rsa" 2>/dev/null)
                        [ "$perm" = "600" ] && echo "OK (600) ✓" || echo "WARNING ($perm) ✗"
                    else
                        echo "N/A"
                    fi

                    echo -n "[3] Password in .bashrc: "
                    grep -qi "password" "$HOME/.bashrc" 2>/dev/null && echo "WARNING ✗" || echo "CLEAN ✓"

                    echo -n "[4] Storage permission: "
                    [ -d "/sdcard" ] && echo "GRANTED" || echo "NOT GRANTED"

                    echo -n "[5] GPG installed: "
                    command -v gpg &>/dev/null && echo "YES ✓" || echo "NO ✗"

                    echo -n "[6] OpenSSH installed: "
                    command -v ssh &>/dev/null && echo "YES ✓" || echo "NO ✗"

                    echo ""
                    echo "=== Recommendations ==="
                    echo "• Use SSH keys instead of passwords"
                    echo "• Keep packages updated regularly"
                    echo "• Use GPG to encrypt sensitive files"
                    echo "• Set proper file permissions"
                } > /tmp/security_checklist.txt
                dialog --title "Security Checklist" --textbox /tmp/security_checklist.txt 25 60
                ;;
            B|b|"") return ;;
        esac
    done
}

# ============================================================
# 7. DOWNLOAD MANAGER
# ============================================================
download_manager_menu() {
    while true; do
        local choice
        choice=$(dialog --clear --backtitle "Termux GUI Dashboard" \
            --title "[ DOWNLOAD MANAGER ]" \
            --menu "Select option:" 16 55 7 \
            "1" "Download File (wget)" \
            "2" "Download File (curl)" \
            "3" "Resume Download" \
            "4" "Download YouTube Video" \
            "5" "Batch Download from File" \
            "6" "Download History" \
            "B" "Back to Main Menu" \
            2>&1 >/dev/tty)

        case $choice in
            1)
                local url dest
                url=$(dialog --inputbox "URL to download:" 8 65 2>&1 >/dev/tty)
                if [ -n "$url" ]; then
                    dest=$(dialog --inputbox "Save to directory:" 8 55 "$HOME/downloads" 2>&1 >/dev/tty)
                    mkdir -p "$dest"
                    clear
                    echo -e "${GREEN}Downloading: $url${NC}"
                    echo "Saving to: $dest"
                    echo "================================"
                    wget -P "$dest" "$url"
                    echo "================================"
                    echo -e "${GREEN}Download complete!${NC}"
                    press_enter
                    log_action "Downloaded (wget): $url"
                fi
                ;;
            2)
                local url filename
                url=$(dialog --inputbox "URL to download:" 8 65 2>&1 >/dev/tty)
                if [ -n "$url" ]; then
                    filename=$(dialog --inputbox "Save as filename:" 8 55 "$(basename "$url")" 2>&1 >/dev/tty)
                    local dest
                    dest=$(dialog --inputbox "Save to directory:" 8 55 "$HOME/downloads" 2>&1 >/dev/tty)
                    mkdir -p "$dest"
                    clear
                    echo -e "${GREEN}Downloading: $url${NC}"
                    curl -L -# -o "$dest/$filename" "$url"
                    echo -e "${GREEN}Saved to: $dest/$filename${NC}"
                    press_enter
                    log_action "Downloaded (curl): $url"
                fi
                ;;
            3)
                local url dest
                url=$(dialog --inputbox "URL to resume:" 8 65 2>&1 >/dev/tty)
                if [ -n "$url" ]; then
                    dest=$(dialog --inputbox "Save to directory:" 8 55 "$HOME/downloads" 2>&1 >/dev/tty)
                    mkdir -p "$dest"
                    clear
                    echo -e "${GREEN}Resuming download: $url${NC}"
                    wget -c -P "$dest" "$url"
                    press_enter
                fi
                ;;
            4)
                if ! command -v yt-dlp &>/dev/null && ! command -v youtube-dl &>/dev/null; then
                    dialog --yesno "yt-dlp not installed. Install with pip?" 7 50
                    if [ $? -eq 0 ]; then
                        pip install yt-dlp 2>/dev/null || pkg install -y yt-dlp 2>/dev/null
                    else
                        continue
                    fi
                fi
                local url
                url=$(dialog --inputbox "YouTube URL:" 8 65 2>&1 >/dev/tty)
                if [ -n "$url" ]; then
                    clear
                    echo -e "${GREEN}Downloading video...${NC}"
                    if command -v yt-dlp &>/dev/null; then
                        yt-dlp -o "$HOME/downloads/%(title)s.%(ext)s" "$url"
                    else
                        youtube-dl -o "$HOME/downloads/%(title)s.%(ext)s" "$url"
                    fi
                    press_enter
                    log_action "Downloaded video: $url"
                fi
                ;;
            5)
                local listfile
                listfile=$(dialog --inputbox "File with URLs (one per line):" 8 60 2>&1 >/dev/tty)
                if [ -n "$listfile" ] && [ -f "$listfile" ]; then
                    local dest
                    dest=$(dialog --inputbox "Save to directory:" 8 55 "$HOME/downloads" 2>&1 >/dev/tty)
                    mkdir -p "$dest"
                    clear
                    echo -e "${GREEN}Batch downloading...${NC}"
                    wget -P "$dest" -i "$listfile"
                    press_enter
                    log_action "Batch download from: $listfile"
                else
                    dialog --msgbox "File not found!" 6 25
                fi
                ;;
            6)
                grep "Downloaded" "$LOG_FILE" 2>/dev/null | tail -20 > /tmp/dl_history.txt
                if [ -s /tmp/dl_history.txt ]; then
                    dialog --title "Download History" --textbox /tmp/dl_history.txt 20 75
                else
                    dialog --msgbox "No download history." 6 30
                fi
                ;;
            B|b|"") return ;;
        esac
    done
}

# ============================================================
# 8. TEXT EDITOR
# ============================================================
text_editor_menu() {
    while true; do
        local choice
        choice=$(dialog --clear --backtitle "Termux GUI Dashboard" \
            --title "[ TEXT EDITOR ]" \
            --menu "Select option:" 14 50 5 \
            "1" "Open file in Nano" \
            "2" "Open file in Vim" \
            "3" "Create new file & edit" \
            "4" "Quick Note" \
            "B" "Back to Main Menu" \
            2>&1 >/dev/tty)

        case $choice in
            1)
                local filepath
                filepath=$(dialog --inputbox "File path:" 8 60 "$HOME/" 2>&1 >/dev/tty)
                if [ -n "$filepath" ]; then
                    nano "$filepath"
                fi
                ;;
            2)
                local filepath
                filepath=$(dialog --inputbox "File path:" 8 60 "$HOME/" 2>&1 >/dev/tty)
                if [ -n "$filepath" ]; then
                    if command -v vim &>/dev/null; then
                        vim "$filepath"
                    elif command -v vi &>/dev/null; then
                        vi "$filepath"
                    else
                        dialog --msgbox "Vim not installed. Install with: pkg install vim" 6 55
                    fi
                fi
                ;;
            3)
                local filepath
                filepath=$(dialog --inputbox "New file path:" 8 60 "$HOME/" 2>&1 >/dev/tty)
                if [ -n "$filepath" ]; then
                    touch "$filepath"
                    nano "$filepath"
                    log_action "Created and edited: $filepath"
                fi
                ;;
            4)
                local notes_dir="$CONFIG_DIR/notes"
                mkdir -p "$notes_dir"
                local note_name
                note_name="note_$(date +%Y%m%d_%H%M%S).txt"
                local content
                content=$(dialog --inputbox "Quick note:" 10 60 2>&1 >/dev/tty)
                if [ -n "$content" ]; then
                    echo "Date: $(date)" > "$notes_dir/$note_name"
                    echo "" >> "$notes_dir/$note_name"
                    echo "$content" >> "$notes_dir/$note_name"
                    dialog --msgbox "Note saved: $note_name" 6 40
                    log_action "Quick note saved"
                fi
                ;;
            B|b|"") return ;;
        esac
    done
}

# ============================================================
# 9. PYTHON TOOLS
# ============================================================
python_tools_menu() {
    if ! command -v python &>/dev/null; then
        dialog --yesno "Python is not installed. Install?" 7 40
        if [ $? -eq 0 ]; then
            dialog --infobox "Installing Python..." 5 35
            pkg install -y python
        else
            return
        fi
    fi

    while true; do
        local choice
        choice=$(dialog --clear --backtitle "Termux GUI Dashboard" \
            --title "[ PYTHON TOOLS ]" \
            --menu "Select option:" 18 55 9 \
            "1" "Python Interactive Shell" \
            "2" "Run Python Script" \
            "3" "Install pip Package" \
            "4" "List pip Packages" \
            "5" "Create Python Script" \
            "6" "Python Version Info" \
            "7" "Create Virtual Environment" \
            "8" "pip Upgrade All" \
            "B" "Back to Main Menu" \
            2>&1 >/dev/tty)

        case $choice in
            1)
                clear
                python
                ;;
            2)
                local script
                script=$(dialog --inputbox "Python script path:" 8 60 "$HOME/" 2>&1 >/dev/tty)
                if [ -n "$script" ] && [ -f "$script" ]; then
                    clear
                    echo -e "${GREEN}Running: $script${NC}"
                    echo "================================"
                    python "$script"
                    echo "================================"
                    press_enter
                    log_action "Ran Python script: $script"
                else
                    dialog --msgbox "Script not found!" 6 30
                fi
                ;;
            3)
                local pkg_name
                pkg_name=$(dialog --inputbox "pip package name:" 8 50 2>&1 >/dev/tty)
                if [ -n "$pkg_name" ]; then
                    dialog --infobox "Installing $pkg_name..." 5 40
                    pip install "$pkg_name" > /tmp/pip_output.txt 2>&1
                    dialog --title "pip Install Result" --textbox /tmp/pip_output.txt 20 70
                    log_action "pip install: $pkg_name"
                fi
                ;;
            4)
                pip list > /tmp/pip_output.txt 2>&1
                dialog --title "Installed pip Packages" --textbox /tmp/pip_output.txt 22 60
                ;;
            5)
                local script_name
                script_name=$(dialog --inputbox "Script name (.py):" 8 50 "script.py" 2>&1 >/dev/tty)
                if [ -n "$script_name" ]; then
                    local script_path="$HOME/$script_name"
                    cat > "$script_path" << 'PYTEMPLATE'
#!/usr/bin/env python3
"""
Script created by Termux Dashboard
"""

def main():
    print("Hello from Python!")
    # Your code here

if __name__ == "__main__":
    main()
PYTEMPLATE
                    chmod +x "$script_path"
                    dialog --yesno "Script created: $script_path\n\nEdit now?" 8 50
                    [ $? -eq 0 ] && nano "$script_path"
                    log_action "Created Python script: $script_path"
                fi
                ;;
            6)
                {
                    echo "=== Python Information ==="
                    echo ""
                    python --version 2>&1
                    echo ""
                    pip --version 2>&1
                    echo ""
                    echo "Path: $(which python)"
                    echo ""
                    echo "=== Installed Modules ==="
                    python -c "import sys; print(f'sys.path: {sys.path}')" 2>&1
                } > /tmp/py_info.txt
                dialog --title "Python Info" --textbox /tmp/py_info.txt 18 70
                ;;
            7)
                local venv_name
                venv_name=$(dialog --inputbox "Virtual environment name:" 8 50 "myenv" 2>&1 >/dev/tty)
                if [ -n "$venv_name" ]; then
                    dialog --infobox "Creating virtual environment..." 5 45
                    python -m venv "$HOME/$venv_name" > /tmp/venv_output.txt 2>&1
                    if [ $? -eq 0 ]; then
                        dialog --msgbox "Virtual environment created!\n\nActivate with:\nsource ~/$venv_name/bin/activate" 9 50
                    else
                        dialog --title "Error" --textbox /tmp/venv_output.txt 15 60
                    fi
                fi
                ;;
            8)
                dialog --infobox "Upgrading all pip packages..." 5 45
                pip list --outdated --format=freeze 2>/dev/null | grep -v '^\-e' | cut -d = -f 1 | xargs -n1 pip install -U > /tmp/pip_output.txt 2>&1
                dialog --title "Upgrade Result" --textbox /tmp/pip_output.txt 20 70
                ;;
            B|b|"") return ;;
        esac
    done
}

# ============================================================
# 10. TERMUX SETTINGS
# ============================================================
termux_settings_menu() {
    while true; do
        local choice
        choice=$(dialog --clear --backtitle "Termux GUI Dashboard" \
            --title "[ TERMUX SETTINGS ]" \
            --menu "Select option:" 20 60 11 \
            "1"  "Setup Storage Access" \
            "2"  "Change Color Scheme" \
            "3"  "Change Font" \
            "4"  "Edit bashrc" \
            "5"  "Edit Termux Properties" \
            "6"  "Set Extra Keys" \
            "7"  "Install Termux API" \
            "8"  "Setup External Storage" \
            "9"  "Termux Reload Settings" \
            "10" "Reset Termux" \
            "B"  "Back to Main Menu" \
            2>&1 >/dev/tty)

        case $choice in
            1)
                dialog --infobox "Setting up storage access..." 5 40
                termux-setup-storage
                sleep 2
                dialog --msgbox "Storage setup complete!\nAccess /sdcard from ~/storage/" 7 45
                log_action "Storage setup"
                ;;
            2)
                local colors_dir="$HOME/.termux"
                mkdir -p "$colors_dir"

                local color_scheme
                color_scheme=$(dialog --menu "Select color scheme:" 18 50 10 \
                    "1"  "Dracula" \
                    "2"  "Monokai" \
                    "3"  "Solarized Dark" \
                    "4"  "Solarized Light" \
                    "5"  "Gruvbox" \
                    "6"  "Nord" \
                    "7"  "One Dark" \
                    "8"  "Default (Reset)" \
                    2>&1 >/dev/tty)

                case $color_scheme in
                    1) cat > "$colors_dir/colors.properties" << 'EOF'
foreground=#F8F8F2
background=#282A36
cursor=#F8F8F2
color0=#000000
color1=#FF5555
color2=#50FA7B
color3=#F1FA8C
color4=#BD93F9
color5=#FF79C6
color6=#8BE9FD
color7=#BFBFBF
color8=#4D4D4D
color9=#FF6E67
color10=#5AF78E
color11=#F4F99D
color12=#CAA9FA
color13=#FF92D0
color14=#9AEDFE
color15=#E6E6E6
EOF
                        dialog --msgbox "Dracula theme applied!" 6 35 ;;
                    2) cat > "$colors_dir/colors.properties" << 'EOF'
foreground=#F8F8F2
background=#272822
cursor=#F8F8F0
color0=#272822
color1=#F92672
color2=#A6E22E
color3=#F4BF75
color4=#66D9EF
color5=#AE81FF
color6=#A1EFE4
color7=#F8F8F2
color8=#75715E
color9=#F92672
color10=#A6E22E
color11=#F4BF75
color12=#66D9EF
color13=#AE81FF
color14=#A1EFE4
color15=#F9F8F5
EOF
                        dialog --msgbox "Monokai theme applied!" 6 35 ;;
                    3) cat > "$colors_dir/colors.properties" << 'EOF'
foreground=#839496
background=#002B36
cursor=#93A1A1
color0=#073642
color1=#DC322F
color2=#859900
color3=#B58900
color4=#268BD2
color5=#D33682
color6=#2AA198
color7=#EEE8D5
color8=#002B36
color9=#CB4B16
color10=#586E75
color11=#657B83
color12=#839496
color13=#6C71C4
color14=#93A1A1
color15=#FDF6E3
EOF
                        dialog --msgbox "Solarized Dark theme applied!" 6 40 ;;
                    4) cat > "$colors_dir/colors.properties" << 'EOF'
foreground=#657B83
background=#FDF6E3
cursor=#586E75
color0=#073642
color1=#DC322F
color2=#859900
color3=#B58900
color4=#268BD2
color5=#D33682
color6=#2AA198
color7=#EEE8D5
color8=#002B36
color9=#CB4B16
color10=#586E75
color11=#657B83
color12=#839496
color13=#6C71C4
color14=#93A1A1
color15=#FDF6E3
EOF
                        dialog --msgbox "Solarized Light theme applied!" 6 40 ;;
                    5) cat > "$colors_dir/colors.properties" << 'EOF'
foreground=#EBDBB2
background=#282828
cursor=#EBDBB2
color0=#282828
color1=#CC241D
color2=#98971A
color3=#D79921
color4=#458588
color5=#B16286
color6=#689D6A
color7=#A89984
color8=#928374
color9=#FB4934
color10=#B8BB26
color11=#FABD2F
color12=#83A598
color13=#D3869B
color14=#8EC07C
color15=#EBDBB2
EOF
                        dialog --msgbox "Gruvbox theme applied!" 6 35 ;;
                    6) cat > "$colors_dir/colors.properties" << 'EOF'
foreground=#D8DEE9
background=#2E3440
cursor=#D8DEE9
color0=#3B4252
color1=#BF616A
color2=#A3BE8C
color3=#EBCB8B
color4=#81A1C1
color5=#B48EAD
color6=#88C0D0
color7=#E5E9F0
color8=#4C566A
color9=#BF616A
color10=#A3BE8C
color11=#EBCB8B
color12=#81A1C1
color13=#B48EAD
color14=#8BE9FD
color15=#ECEFF4
EOF
                        dialog --msgbox "Nord theme applied!" 6 30 ;;
                    7) cat > "$colors_dir/colors.properties" << 'EOF'
foreground=#ABB2BF
background=#282C34
cursor=#528BFF
color0=#282C34
color1=#E06C75
color2=#98C379
color3=#E5C07B
color4=#61AFEF
color5=#C678DD
color6=#56B6C2
color7=#ABB2BF
color8=#545862
color9=#E06C75
color10=#98C379
color11=#E5C07B
color12=#61AFEF
color13=#C678DD
color14=#56B6C2
color15=#C8CCD4
EOF
                        dialog --msgbox "One Dark theme applied!" 6 35 ;;
                    8)
                        rm -f "$colors_dir/colors.properties"
                        dialog --msgbox "Reset to default colors." 6 35 ;;
                esac
                termux-reload-settings 2>/dev/null
                ;;
            3)
                dialog --msgbox "To change font:\n\n1. Download a .ttf font file\n2. Copy to ~/.termux/font.ttf\n3. Run: termux-reload-settings\n\nOr install termux-styling:\npkg install termux-styling" 12 50
                ;;
            4)
                nano "$HOME/.bashrc"
                source "$HOME/.bashrc" 2>/dev/null
                ;;
            5)
                local props="$HOME/.termux/termux.properties"
                mkdir -p "$HOME/.termux"
                if [ ! -f "$props" ]; then
                    cat > "$props" << 'EOF'
# Termux Properties
# Extra keys row
extra-keys = [['ESC','/','-','HOME','UP','END','PGUP'],['TAB','CTRL','ALT','LEFT','DOWN','RIGHT','PGDN']]
# Bell
bell-character=vibrate
# Keyboard
enforce-char-based-input = true
EOF
                fi
                nano "$props"
                termux-reload-settings 2>/dev/null
                ;;
            6)
                local key_layout
                key_layout=$(dialog --menu "Select extra keys layout:" 14 55 5 \
                    "1" "Default (2 rows)" \
                    "2" "Developer (arrows + symbols)" \
                    "3" "Minimal (1 row)" \
                    "4" "Full (3 rows)" \
                    "5" "Custom" \
                    2>&1 >/dev/tty)

                local props="$HOME/.termux/termux.properties"
                mkdir -p "$HOME/.termux"

                case $key_layout in
                    1)
                        grep -v "^extra-keys" "$props" 2>/dev/null > /tmp/termux_props.tmp
                        echo "extra-keys = [['ESC','/','-','HOME','UP','END','PGUP'],['TAB','CTRL','ALT','LEFT','DOWN','RIGHT','PGDN']]" >> /tmp/termux_props.tmp
                        mv /tmp/termux_props.tmp "$props"
                        ;;
                    2)
                        grep -v "^extra-keys" "$props" 2>/dev/null > /tmp/termux_props.tmp
                        echo "extra-keys = [['ESC','|','/','-','_','UP','QUOTE'],['TAB','CTRL','ALT','LEFT','DOWN','RIGHT','ENTER']]" >> /tmp/termux_props.tmp
                        mv /tmp/termux_props.tmp "$props"
                        ;;
                    3)
                        grep -v "^extra-keys" "$props" 2>/dev/null > /tmp/termux_props.tmp
                        echo "extra-keys = [['ESC','TAB','CTRL','ALT','LEFT','RIGHT','ENTER']]" >> /tmp/termux_props.tmp
                        mv /tmp/termux_props.tmp "$props"
                        ;;
                    4)
                        grep -v "^extra-keys" "$props" 2>/dev/null > /tmp/termux_props.tmp
                        echo "extra-keys = [['ESC','/','{','}','[',']','UP','PGUP'],['TAB','CTRL','ALT','|','<','>','DOWN','PGDN'],['FN','HOME','&','*','=','+','LEFT','RIGHT']]" >> /tmp/termux_props.tmp
                        mv /tmp/termux_props.tmp "$props"
                        ;;
                    5)
                        nano "$props"
                        ;;
                esac
                termux-reload-settings 2>/dev/null
                dialog --msgbox "Extra keys updated!" 6 30
                ;;
            7)
                dialog --infobox "Installing Termux API..." 5 35
                pkg install -y termux-api > /tmp/pkg_output.txt 2>&1
                dialog --title "Install Result" --textbox /tmp/pkg_output.txt 15 60
                dialog --msgbox "Also install the Termux:API app from F-Droid!" 6 55
                ;;
            8)
                termux-setup-storage 2>/dev/null
                dialog --msgbox "External storage links:\n\n~/storage/shared - Internal\n~/storage/dcim - Camera\n~/storage/downloads - Downloads\n~/storage/music - Music\n~/storage/pictures - Pictures" 12 50
                ;;
            9)
                termux-reload-settings 2>/dev/null
                dialog --msgbox "Termux settings reloaded!" 6 35
                ;;
            10)
                dialog --yesno "⚠️ WARNING ⚠️\n\nThis will reset Termux configuration.\nYour data will NOT be deleted.\n\nContinue?" 10 45
                if [ $? -eq 0 ]; then
                    rm -f "$HOME/.termux/colors.properties"
                    rm -f "$HOME/.termux/font.ttf"
                    termux-reload-settings 2>/dev/null
                    dialog --msgbox "Settings reset to defaults." 6 35
                    log_action "Termux settings reset"
                fi
                ;;
            B|b|"") return ;;
        esac
    done
}

# ============================================================
# 11. PROCESS MANAGER
# ============================================================
process_manager_menu() {
    while true; do
        local choice
        choice=$(dialog --clear --backtitle "Termux GUI Dashboard" \
            --title "[ PROCESS MANAGER ]" \
            --menu "Select option:" 16 55 7 \
            "1" "View All Processes" \
            "2" "Interactive Process Viewer (htop)" \
            "3" "Kill Process by PID" \
            "4" "Kill Process by Name" \
            "5" "Top CPU Processes" \
            "6" "Top Memory Processes" \
            "B" "Back to Main Menu" \
            2>&1 >/dev/tty)

        case $choice in
            1)
                ps aux > /tmp/proc_output.txt 2>&1 || ps -ef > /tmp/proc_output.txt 2>&1
                dialog --title "All Processes" --textbox /tmp/proc_output.txt 22 80
                ;;
            2)
                if command -v htop &>/dev/null; then
                    htop
                else
                    dialog --yesno "htop not installed. Install?" 7 35
                    if [ $? -eq 0 ]; then
                        pkg install -y htop
                        htop
                    fi
                fi
                ;;
            3)
                local pid
                pid=$(dialog --inputbox "Enter PID to kill:" 8 40 2>&1 >/dev/tty)
                if [ -n "$pid" ]; then
                    dialog --yesno "Kill process $pid?" 7 30
                    if [ $? -eq 0 ]; then
                        kill "$pid" 2>/tmp/kill_err.txt
                        if [ $? -eq 0 ]; then
                            dialog --msgbox "Process $pid killed." 6 30
                        else
                            kill -9 "$pid" 2>/tmp/kill_err.txt
                            dialog --msgbox "Force killed $pid.\n$(cat /tmp/kill_err.txt)" 8 45
                        fi
                        log_action "Killed PID: $pid"
                    fi
                fi
                ;;
            4)
                local pname
                pname=$(dialog --inputbox "Process name:" 8 40 2>&1 >/dev/tty)
                if [ -n "$pname" ]; then
                    local pids
                    pids=$(pgrep -f "$pname" 2>/dev/null)
                    if [ -n "$pids" ]; then
                        dialog --yesno "Found processes:\n$pids\n\nKill all?" 10 40
                        if [ $? -eq 0 ]; then
                            pkill -f "$pname"
                            dialog --msgbox "Killed processes matching: $pname" 6 50
                            log_action "Killed processes: $pname"
                        fi
                    else
                        dialog --msgbox "No processes found matching: $pname" 6 50
                    fi
                fi
                ;;
            5)
                ps aux --sort=-%cpu 2>/dev/null | head -20 > /tmp/proc_output.txt || \
                    ps -eo pid,pcpu,pmem,comm --sort=-pcpu 2>/dev/null | head -20 > /tmp/proc_output.txt
                dialog --title "Top CPU Processes" --textbox /tmp/proc_output.txt 22 80
                ;;
            6)
                ps aux --sort=-%mem 2>/dev/null | head -20 > /tmp/proc_output.txt || \
                    ps -eo pid,pcpu,pmem,comm --sort=-pmem 2>/dev/null | head -20 > /tmp/proc_output.txt
                dialog --title "Top Memory Processes" --textbox /tmp/proc_output.txt 22 80
                ;;
            B|b|"") return ;;
        esac
    done
}

# ============================================================
# 12. BACKUP & RESTORE
# ============================================================
backup_restore_menu() {
    local backup_dir="$HOME/termux-backups"
    mkdir -p "$backup_dir"

    while true; do
        local choice
        choice=$(dialog --clear --backtitle "Termux GUI Dashboard" \
            --title "[ BACKUP & RESTORE ]" \
            --menu "Select option:" 16 55 7 \
            "1" "Backup Home Directory" \
            "2" "Backup Termux Packages List" \
            "3" "Backup Termux Config" \
            "4" "Restore from Backup" \
            "5" "Restore Packages from List" \
            "6" "List Backups" \
            "B" "Back to Main Menu" \
            2>&1 >/dev/tty)

        case $choice in
            1)
                local backup_name="home_backup_$(date +%Y%m%d_%H%M%S).tar.gz"
                dialog --infobox "Creating backup...\nThis may take a while." 6 40

                # Exclude the backup directory itself
                tar -czf "$backup_dir/$backup_name" \
                    --exclude="$backup_dir" \
                    --exclude=".cache" \
                    -C "$HOME" . > /tmp/backup_output.txt 2>&1

                if [ $? -eq 0 ]; then
                    local size
                    size=$(du -sh "$backup_dir/$backup_name" | cut -f1)
                    dialog --msgbox "Backup created!\n\nFile: $backup_name\nSize: $size\nPath: $backup_dir/" 9 55
                    log_action "Backup created: $backup_name ($size)"
                else
                    dialog --title "Backup Error" --textbox /tmp/backup_output.txt 15 60
                fi
                ;;
            2)
                local pkg_list="packages_$(date +%Y%m%d_%H%M%S).txt"
                pkg list-installed 2>/dev/null | cut -d/ -f1 > "$backup_dir/$pkg_list"
                local count
                count=$(wc -l < "$backup_dir/$pkg_list")
                dialog --msgbox "Package list saved!\n\nFile: $pkg_list\nPackages: $count" 8 45
                log_action "Package list backed up: $pkg_list"
                ;;
            3)
                local config_backup="config_backup_$(date +%Y%m%d_%H%M%S).tar.gz"
                tar -czf "$backup_dir/$config_backup" \
                    -C "$HOME" \
                    .bashrc .bash_profile .profile \
                    .termux/ \
                    .config/termux-dashboard/ \
                    .gitconfig \
                    .ssh/ \
                    2>/dev/null
                dialog --msgbox "Config backup created!\n\nFile: $config_backup" 7 50
                log_action "Config backed up: $config_backup"
                ;;
            4)
                local backups
                backups=$(ls "$backup_dir"/*.tar.gz 2>/dev/null)
                if [ -z "$backups" ]; then
                    dialog --msgbox "No backups found." 6 25
                    continue
                fi

                local menu_items=""
                local count=1
                for b in $backups; do
                    local bname
                    bname=$(basename "$b")
                    local bsize
                    bsize=$(du -sh "$b" | cut -f1)
                    menu_items="$menu_items $count $bname($bsize)"
                    count=$((count + 1))
                done

                local selection
                selection=$(dialog --menu "Select backup to restore:" 18 60 10 $menu_items 2>&1 >/dev/tty)

                if [ -n "$selection" ]; then
                    local backup_file
                    backup_file=$(ls "$backup_dir"/*.tar.gz 2>/dev/null | sed -n "${selection}p")
                    if [ -f "$backup_file" ]; then
                        dialog --yesno "Restore from:\n$(basename "$backup_file")\n\nThis may overwrite existing files!" 9 55
                        if [ $? -eq 0 ]; then
                            dialog --infobox "Restoring backup..." 5 30
                            tar -xzf "$backup_file" -C "$HOME" > /tmp/restore_output.txt 2>&1
                            dialog --msgbox "Restore complete!" 6 25
                            log_action "Restored: $(basename "$backup_file")"
                        fi
                    fi
                fi
                ;;
            5)
                local lists
                lists=$(ls "$backup_dir"/packages_*.txt 2>/dev/null)
                if [ -z "$lists" ]; then
                    dialog --msgbox "No package lists found." 6 30
                    continue
                fi

                local menu_items=""
                local count=1
                for l in $lists; do
                    menu_items="$menu_items $count $(basename "$l")"
                    count=$((count + 1))
                done

                local selection
                selection=$(dialog --menu "Select package list:" 15 55 8 $menu_items 2>&1 >/dev/tty)

                if [ -n "$selection" ]; then
                    local list_file
                    list_file=$(ls "$backup_dir"/packages_*.txt 2>/dev/null | sed -n "${selection}p")
                    if [ -f "$list_file" ]; then
                        dialog --yesno "Install all packages from:\n$(basename "$list_file")?" 8 50
                        if [ $? -eq 0 ]; then
                            dialog --infobox "Installing packages..." 5 35
                            while IFS= read -r pkg; do
                                pkg install -y "$pkg" &>/dev/null
                            done < "$list_file"
                            dialog --msgbox "Package restoration complete!" 6 40
                            log_action "Restored packages from: $(basename "$list_file")"
                        fi
                    fi
                fi
                ;;
            6)
                {
                    echo "=== Backups in $backup_dir ==="
                    echo ""
                    ls -lhS "$backup_dir" 2>/dev/null || echo "No backups found."
                    echo ""
                    echo "Total size: $(du -sh "$backup_dir" 2>/dev/null | cut -f1)"
                } > /tmp/backup_list.txt
                dialog --title "Backup List" --textbox /tmp/backup_list.txt 20 70
                ;;
            B|b|"") return ;;
        esac
    done
}

# ============================================================
# 13. VIEW LOGS
# ============================================================
view_logs() {
    while true; do
        local choice
        choice=$(dialog --menu "Log Viewer:" 12 45 4 \
            "1" "View Full Log" \
            "2" "View Last 50 Entries" \
            "3" "Clear Log" \
            "B" "Back" \
            2>&1 >/dev/tty)

        case $choice in
            1)
                if [ -s "$LOG_FILE" ]; then
                    dialog --title "Dashboard Log" --textbox "$LOG_FILE" 22 75
                else
                    dialog --msgbox "Log file is empty." 6 25
                fi
                ;;
            2)
                if [ -s "$LOG_FILE" ]; then
                    tail -50 "$LOG_FILE" > /tmp/log_tail.txt
                    dialog --title "Last 50 Log Entries" --textbox /tmp/log_tail.txt 22 75
                else
                    dialog --msgbox "Log file is empty." 6 25
                fi
                ;;
            3)
                dialog --yesno "Clear all logs?" 7 30
                if [ $? -eq 0 ]; then
                    > "$LOG_FILE"
                    dialog --msgbox "Logs cleared." 6 20
                fi
                ;;
            B|b|"") return ;;
        esac
    done
}

# ============================================================
# 14. BOOKMARKS
# ============================================================
bookmarks_menu() {
    while true; do
        local choice
        choice=$(dialog --clear --backtitle "Termux GUI Dashboard" \
            --title "[ BOOKMARKS ]" \
            --menu "Select an action:" 18 55 9 \
            "1" "Add New Bookmark" \
            "2" "List Bookmarks" \
            "3" "Run Bookmark" \
            "4" "Edit Bookmark" \
            "5" "Delete Bookmark" \
            "6" "Export Bookmarks" \
            "7" "Import Bookmarks" \
            "B" "Back to Main Menu" \
            2>&1 >/dev/tty)

        case $choice in
            1) add_bookmark_entry ;;
            2) list_bookmarks_entries ;;
            3) run_bookmark_entry ;;
            4) edit_bookmark_entry ;;
            5) delete_bookmark_entry ;;
            6) export_bookmarks ;;
            7) import_bookmarks ;;
            B|b|"") return ;;
        esac
    done
}

add_bookmark_entry() {
    local name
    name=$(dialog --inputbox "Enter bookmark name:" 8 50 2>&1 >/dev/tty)
    if [ -z "$name" ]; then
        dialog --msgbox "Bookmark name cannot be empty." 6 40
        return
    fi

    local command_str
    command_str=$(dialog --inputbox "Enter command/script path:" 8 60 2>&1 >/dev/tty)
    if [ -z "$command_str" ]; then
        dialog --msgbox "Command cannot be empty." 6 35
        return
    fi

    echo "$name|$command_str" >> "$BOOKMARKS_FILE"
    dialog --msgbox "Bookmark '$name' added." 6 35
    log_action "Added bookmark: $name"
}

list_bookmarks_entries() {
    if [ ! -s "$BOOKMARKS_FILE" ]; then
        dialog --msgbox "No bookmarks saved yet." 6 30
        return
    fi

    local bookmarks_display=""
    local i=1
    while IFS='|' read -r name command; do
        bookmarks_display+="$i. $name: $command\n"
        i=$((i + 1))
    done < "$BOOKMARKS_FILE"

    dialog --title "Saved Bookmarks" --textbox <(echo -e "$bookmarks_display") 20 70
}

run_bookmark_entry() {
    if [ ! -s "$BOOKMARKS_FILE" ]; then
        dialog --msgbox "No bookmarks to run." 6 30
        return
    fi

    local menu_items=""
    local i=1
    while IFS='|' read -r name command; do
        menu_items="$menu_items $i \"$name\""
        i=$((i + 1))
    done < "$BOOKMARKS_FILE"

    local selection
    selection=$(eval dialog --menu \"Select bookmark to run:\" 20 60 10 $menu_items 2>&1 >/dev/tty)

    if [ -n "$selection" ]; then
        local command_to_run
        command_to_run=$(awk -F'|' "NR==$selection {print \$2}" "$BOOKMARKS_FILE")
        dialog --infobox "Running: $command_to_run" 5 50
        clear
        echo -e "${GREEN}Running bookmark: ${command_to_run}${NC}"
        echo "========================================"
        eval "$command_to_run"
        echo "========================================"
        press_enter
        log_action "Ran bookmark: $command_to_run"
    fi
}

edit_bookmark_entry() {
    if [ ! -s "$BOOKMARKS_FILE" ]; then
        dialog --msgbox "No bookmarks to edit." 6 30
        return
    fi

    local menu_items=""
    local i=1
    while IFS='|' read -r name command; do
        menu_items="$menu_items $i \"$name\""
        i=$((i + 1))
    done < "$BOOKMARKS_FILE"

    local selection
    selection=$(eval dialog --menu \"Select bookmark to edit:\" 20 60 10 $menu_items 2>&1 >/dev/tty)

    if [ -n "$selection" ]; then
        local old_name old_command
        old_name=$(awk -F'|' "NR==$selection {print \$1}" "$BOOKMARKS_FILE")
        old_command=$(awk -F'|' "NR==$selection {print \$2}" "$BOOKMARKS_FILE")

        local new_name
        new_name=$(dialog --inputbox "Edit name for '$old_name':" 8 50 "$old_name" 2>&1 >/dev/tty)
        local new_command
        new_command=$(dialog --inputbox "Edit command for '$old_name':" 8 60 "$old_command" 2>&1 >/dev/tty)

        if [ -n "$new_name" ] && [ -n "$new_command" ]; then
            sed -i "${selection}s|.*|$new_name|$new_command|" "$BOOKMARKS_FILE"
            dialog --msgbox "Bookmark updated." 6 30
            log_action "Edited bookmark: $old_name -> $new_name"
        fi
    fi
}

delete_bookmark_entry() {
    if [ ! -s "$BOOKMARKS_FILE" ]; then
        dialog --msgbox "No bookmarks to delete." 6 30
        return
    fi

    local menu_items=""
    local i=1
    while IFS='|' read -r name command; do
        menu_items="$menu_items $i \"$name\""
        i=$((i + 1))
    done < "$BOOKMARKS_FILE"

    local selection
    selection=$(eval dialog --menu \"Select bookmark to delete:\" 20 60 10 $menu_items 2>&1 >/dev/tty)

    if [ -n "$selection" ]; then
        local bookmark_name
        bookmark_name=$(awk -F'|' "NR==$selection {print \$1}" "$BOOKMARKS_FILE")
        dialog --yesno "Are you sure you want to delete '$bookmark_name'?" 7 50
        if [ $? -eq 0 ]; then
            sed -i "${selection}d" "$BOOKMARKS_FILE"
            dialog --msgbox "Bookmark '$bookmark_name' deleted." 6 40
            log_action "Deleted bookmark: $bookmark_name"
        fi
    fi
}

export_bookmarks() {
    if [ ! -s "$BOOKMARKS_FILE" ]; then
        dialog --msgbox "No bookmarks to export." 6 30
        return
    fi

    local export_path
    export_path=$(dialog --inputbox "Enter export file path:" 8 60 "$HOME/bookmarks_export.txt" 2>&1 >/dev/tty)
    
    if [ -n "$export_path" ]; then
        cp "$BOOKMARKS_FILE" "$export_path"
        dialog --msgbox "Bookmarks exported to:\n$export_path" 7 55
        log_action "Exported bookmarks to $export_path"
    fi
}

import_bookmarks() {
    local import_path
    import_path=$(dialog --inputbox "Enter file path to import:" 8 60 "$HOME/bookmarks_export.txt" 2>&1 >/dev/tty)
    
    if [ -n "$import_path" ] && [ -f "$import_path" ]; then
        local mode
        mode=$(dialog --menu "Import Mode:" 10 45 2 \
            "1" "Append (Merge with existing)" \
            "2" "Overwrite (Replace current)" \
            2>&1 >/dev/tty)
            
        case $mode in
            1)
                cat "$import_path" >> "$BOOKMARKS_FILE"
                dialog --msgbox "Bookmarks merged successfully!" 6 40
                log_action "Imported bookmarks (Merge) from $import_path"
                ;;
            2)
                dialog --yesno "Are you sure you want to overwrite all existing bookmarks?\n\nThis will permanently delete your current list." 9 50
                if [ $? -eq 0 ]; then
                    cp "$import_path" "$BOOKMARKS_FILE"
                    dialog --msgbox "Bookmarks replaced successfully!" 6 40
                    log_action "Imported bookmarks (Overwrite) from $import_path"
                fi
                ;;
            *) return ;;
        esac
    elif [ -n "$import_path" ]; then
        dialog --msgbox "Error: File not found!" 6 30
    fi
}

# ============================================================
# 15. WEB SERVER MANAGER
# ============================================================
web_server_menu() {
    while true; do
        local status_py="${RED}Stopped${NC}"
        local status_php="${RED}Stopped${NC}"
        [ -f /tmp/web_server_py.pid ] && kill -0 $(cat /tmp/web_server_py.pid) 2>/dev/null && status_py="${GREEN}Running${NC}"
        [ -f /tmp/web_server_php.pid ] && kill -0 $(cat /tmp/web_server_php.pid) 2>/dev/null && status_php="${GREEN}Running${NC}"

        local choice
        choice=$(dialog --clear --backtitle "Termux GUI Dashboard" \
            --title "[ WEB SERVER MANAGER ]" \
            --menu "Manage local hosting:\nPython: $status_py | PHP: $status_php" 18 60 8 \
            "1" "Start Python Server (Port 8000)" \
            "2" "Start PHP Server (Port 8080)" \
            "3" "Stop Python Server" \
            "4" "Stop PHP Server" \
            "5" "View Server Logs" \
            "6" "Get Local Network URL" \
            "B" "Back to Main Menu" \
            2>&1 >/dev/tty)

        case $choice in
            1) start_simple_server "python" 8000 ;;
            2) start_simple_server "php" 8080 ;;
            3) stop_simple_server "py" ;;
            4) stop_simple_server "php" ;;
            5)
                if [ -s /tmp/web_server.log ]; then
                    clear
                    echo -e "${YELLOW}Web Server Logs:${NC}"
                    echo "========================================"
                    cat /tmp/web_server.log
                else
                    dialog --msgbox "No logs available." 6 30
                fi
                ;;
            6)
                local ip
                ip=$(ip addr show | grep "inet " | grep -v "127.0.0.1" | awk '{print $2}' | cut -d/ -f1 | head -n1)
                dialog --msgbox "Local URLs:\n\nPython: http://$ip:8000\nPHP:    http://$ip:8080" 10 50
                ;;
            B|b|"") return ;;
        esac
    done
}

start_simple_server() {
    local type=$1
    local port=$2
    local pid_file="/tmp/web_server_$type.pid"

    if [ -f "$pid_file" ] && kill -0 $(cat "$pid_file") 2>/dev/null; then
        dialog --msgbox "$type server is already running!" 6 40
        return
    fi

    if ! command -v "$type" &>/dev/null; then
        dialog --yesno "$type is not installed. Install it?" 7 45
        if [ $? -eq 0 ]; then
            pkg install -y "$type"
        else
            return
        fi
    fi

    local dir
    dir=$(dialog --inputbox "Enter directory to host:" 8 60 "$HOME" 2>&1 >/dev/tty)
    if [ -d "$dir" ]; then
        cd "$dir" || return
        if [ "$type" == "python" ]; then
            python -m http.server "$port" >> /tmp/web_server.log 2>&1 &
            echo $! > /tmp/web_server_py.pid
        else
            php -S 0.0.0.0:"$port" >> /tmp/web_server.log 2>&1 &
            echo $! > /tmp/web_server_php.pid
        fi
        dialog --msgbox "$type server started on port $port\nDirectory: $dir" 8 55
        log_action "Started $type server on port $port"
    else
        dialog --msgbox "Invalid directory!" 6 30
    fi
}

stop_simple_server() {
    local type=$1
    local pid_file="/tmp/web_server_$type.pid"
    if [ -f "$pid_file" ]; then
        local pid
        pid=$(cat "$pid_file")
        kill "$pid" 2>/dev/null
        rm -f "$pid_file"
        dialog --msgbox "Server stopped." 6 30
        log_action "Stopped $type server (PID $pid)"
    else
        dialog --msgbox "Server is not running." 6 30
    fi
}

# ============================================================
# CLEANUP
# ============================================================
cleanup() {
     # Remove temporary files that are still used for specific error messages or specific outputs
    rm -f /tmp/file_err.txt /tmp/compile_output.txt /tmp/kill_err.txt /tmp/venv_output.txt /tmp/gpg_err.txt
    # Remove web server logs and PIDs
    rm -f /tmp/web_server.log /tmp/web_server_py.pid /tmp/web_server_php.pid
    # Remove temporary files used for backup/restore operations
    rm -f /tmp/backup_output.txt /tmp/restore_output.txt
    # Remove temporary file for termux properties (used in settings menu)
    rm -f /tmp/termux_props.tmp
    rm -f /tmp/web_server_py.pid /tmp/web_server_php.pid
}

# ============================================================
# SIGNAL HANDLING
# ============================================================
trap cleanup EXIT
trap 'echo ""; echo "Use the menu to exit properly."; sleep 1' INT

# ============================================================
# MAIN EXECUTION
# ============================================================
init_dashboard
log_action "Dashboard started"
main_menu
