#!/data/data/com.termux/files/usr/bin/bash

#============================================================================
# Advanced Bluetooth & WiFi Toolkit for Termux
# Version: 3.1 (Fixed Input)
#============================================================================

# ========================= CONFIGURATION =========================
VERSION="3.1"
LOG_DIR="$HOME/nettool_logs"
SCAN_RESULTS="$LOG_DIR/scan_results"
BT_RESULTS="$LOG_DIR/bt_results"
WORDLIST_DIR="$LOG_DIR/wordlists"
CAPTURE_DIR="$LOG_DIR/captures"
REPORT_DIR="$LOG_DIR/reports"
TEMP_DIR="$LOG_DIR/.temp"

# Colors
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
MAGENTA='\033[1;35m'
CYAN='\033[1;36m'
WHITE='\033[1;37m'
ORANGE='\033[38;5;208m'
PINK='\033[38;5;205m'
GRAY='\033[1;90m'
NC='\033[0m'
BOLD='\033[1m'
DIM='\033[2m'

# Symbols
CHECK="[+]"
CROSS="[-]"
ARROW=">>>"
BULLET="*"
STAR="*"
WARNING="[!]"
INFO="[i]"

# Global variable for user input
USER_INPUT=""
IS_ROOT=false

# ========================= INITIALIZATION =========================

init_directories() {
    mkdir -p "$LOG_DIR" "$SCAN_RESULTS" "$BT_RESULTS" "$WORDLIST_DIR" \
             "$CAPTURE_DIR" "$REPORT_DIR" "$TEMP_DIR" 2>/dev/null
}

check_root() {
    if [ "$(id -u)" -eq 0 ]; then
        ROOT_STATUS="${GREEN}${CHECK} Root${NC}"
        IS_ROOT=true
    else
        ROOT_STATUS="${YELLOW}${CROSS} No Root${NC}"
        IS_ROOT=false
    fi
}

# ========================= FIXED INPUT FUNCTION =========================

get_input() {
    local prompt_text="$1"
    USER_INPUT=""
    echo -ne "  ${CYAN}${ARROW} ${WHITE}${prompt_text}: ${GREEN}"
    read -r USER_INPUT
    echo -ne "${NC}"
}

pause_screen() {
    echo ""
    echo -ne "  ${CYAN}${ARROW} Press Enter to continue...${NC}"
    read -r
}

# ========================= UI COMPONENTS =========================

print_banner() {
    clear
    echo ""
    echo -e "${CYAN}    ============================================================${NC}"
    echo -e "${CYAN}    ||${WHITE}  _   _ _____ _____ _____ ___   ___  _     ${CYAN}              ||${NC}"
    echo -e "${CYAN}    ||${WHITE} | \ | | ____|_   _|_   _/ _ \ / _ \| |    ${CYAN}             ||${NC}"
    echo -e "${CYAN}    ||${WHITE} |  \| |  _|   | |   | || | | | | | | |    ${CYAN}             ||${NC}"
    echo -e "${CYAN}    ||${WHITE} | |\  | |___  | |   | || |_| | |_| | |___ ${CYAN}             ||${NC}"
    echo -e "${CYAN}    ||${WHITE} |_| \_|_____| |_|   |_| \___/ \___/|_____|${CYAN}             ||${NC}"
    echo -e "${CYAN}    ||${NC}                                                        ${CYAN}||${NC}"
    echo -e "${CYAN}    ||${NC}   ${WHITE}Advanced Bluetooth & WiFi Toolkit ${CYAN}v${VERSION}${NC}              ${CYAN}||${NC}"
    echo -e "${CYAN}    ||${NC}   ${GRAY}Status: ${ROOT_STATUS} ${GRAY}| Platform: ${CYAN}Termux${NC}                ${CYAN}||${NC}"
    echo -e "${CYAN}    ============================================================${NC}"
    echo ""
}

print_separator() {
    echo -e "  ${GRAY}------------------------------------------------------------${NC}"
}

print_header() {
    local title="$1"
    echo ""
    echo -e "  ${CYAN}============================================================${NC}"
    echo -e "  ${CYAN}||  ${WHITE}${BOLD}${title}${NC}"
    echo -e "  ${CYAN}============================================================${NC}"
    echo ""
}

print_menu_item() {
    local num="$1"
    local text="$2"
    printf "  ${CYAN}[${WHITE}%02d${CYAN}]${NC} ${WHITE}%s${NC}\n" "$num" "$text"
}

print_success() {
    echo -e "  ${GREEN}${CHECK} $1${NC}"
}

print_error() {
    echo -e "  ${RED}${CROSS} $1${NC}"
}

print_warning() {
    echo -e "  ${YELLOW}${WARNING} $1${NC}"
}

print_info() {
    echo -e "  ${CYAN}${INFO} $1${NC}"
}

loading_animation() {
    local text="$1"
    local duration="${2:-3}"
    echo -ne "  ${CYAN}[....] ${WHITE}${text}${NC}"
    sleep "$duration"
    echo -e "\r  ${GREEN}[DONE] ${WHITE}${text}${NC}"
}

# ========================= DEPENDENCY INSTALLER =========================

install_dependencies() {
    print_header "Installing Dependencies"
    
    local deps=(
        "termux-api" "tsu" "wireless-tools" "iw" "net-tools"
        "nmap" "curl" "wget" "python" "macchanger" "tcpdump"
        "dnsutils" "traceroute" "whois" "openssl" "jq" "bc"
    )
    
    echo -e "  ${WHITE}Updating package lists...${NC}"
    pkg update -y 2>/dev/null
    echo ""
    
    local total=${#deps[@]}
    local current=0
    
    for dep in "${deps[@]}"; do
        ((current++))
        echo -ne "  ${CYAN}[${current}/${total}]${NC} Installing ${WHITE}${dep}${NC}... "
        if pkg install -y "$dep" &>/dev/null; then
            echo -e "${GREEN}OK${NC}"
        else
            echo -e "${YELLOW}SKIP${NC}"
        fi
    done
    
    echo ""
    print_success "Dependencies installation completed!"
    print_warning "Make sure Termux:API app is installed from F-Droid"
    print_warning "Grant Location + Bluetooth permissions to Termux & Termux:API"
    pause_screen
}

# ========================= WIFI FUNCTIONS =========================

wifi_scan() {
    print_header "WiFi Network Scanner"
    loading_animation "Scanning nearby WiFi networks" 3
    
    local timestamp=$(date +"%Y%m%d_%H%M%S")
    local outfile="$SCAN_RESULTS/wifi_scan_${timestamp}.txt"
    local scan_data
    scan_data=$(termux-wifi-scaninfo 2>/dev/null)
    
    if [ -n "$scan_data" ] && echo "$scan_data" | jq -e '.' &>/dev/null; then
        local count
        count=$(echo "$scan_data" | jq '. | length')
        
        echo ""
        echo -e "  ${GREEN}${CHECK} Found ${WHITE}${count}${GREEN} networks${NC}"
        echo ""
        printf "  ${CYAN}%-4s %-28s %-19s %-6s %-5s %-12s${NC}\n" \
            "##" "SSID" "BSSID" "dBm" "Chan" "Security"
        print_separator
        
        local i=0
        while [ "$i" -lt "$count" ]; do
            local ssid bssid level freq caps channel security sig_color
            ssid=$(echo "$scan_data" | jq -r ".[$i].ssid // \"[Hidden]\"")
            bssid=$(echo "$scan_data" | jq -r ".[$i].bssid // \"N/A\"")
            level=$(echo "$scan_data" | jq -r ".[$i].level // \"N/A\"")
            freq=$(echo "$scan_data" | jq -r ".[$i].frequency // 0")
            caps=$(echo "$scan_data" | jq -r ".[$i].capabilities // \"Open\"")
            
            # Calculate channel
            if [ "$freq" -ge 2412 ] 2>/dev/null && [ "$freq" -le 2484 ] 2>/dev/null; then
                channel=$(( (freq - 2407) / 5 ))
            elif [ "$freq" -ge 5170 ] 2>/dev/null && [ "$freq" -le 5825 ] 2>/dev/null; then
                channel=$(( (freq - 5000) / 5 ))
            else
                channel="?"
            fi
            
            # Signal color
            if [ "$level" -ge -50 ] 2>/dev/null; then
                sig_color="${GREEN}"
            elif [ "$level" -ge -70 ] 2>/dev/null; then
                sig_color="${YELLOW}"
            else
                sig_color="${RED}"
            fi
            
            # Security
            if echo "$caps" | grep -qi "WPA3"; then
                security="${RED}WPA3${NC}"
            elif echo "$caps" | grep -qi "WPA2"; then
                security="${ORANGE}WPA2${NC}"
            elif echo "$caps" | grep -qi "WPA"; then
                security="${YELLOW}WPA${NC}"
            elif echo "$caps" | grep -qi "WEP"; then
                security="${MAGENTA}WEP${NC}"
            else
                security="${GREEN}OPEN${NC}"
            fi
            
            printf "  ${WHITE}%-4s${NC} %-28s %-19s ${sig_color}%-6s${NC} %-5s %-12b\n" \
                "$((i+1))" "${ssid:0:26}" "$bssid" "$level" "$channel" "$security"
            
            i=$((i + 1))
        done
        
        print_separator
        echo "$scan_data" | jq '.' > "$outfile"
        echo ""
        print_success "Results saved to: ${outfile}"
    else
        print_error "WiFi scan failed."
        print_info "Make sure:"
        echo -e "    ${WHITE}1. WiFi is turned ON${NC}"
        echo -e "    ${WHITE}2. Termux:API app is installed${NC}"
        echo -e "    ${WHITE}3. Location permission is granted${NC}"
    fi
    
    pause_screen
}

wifi_connection_info() {
    print_header "Current WiFi Connection Info"
    loading_animation "Gathering connection details" 2
    
    local conn_data
    conn_data=$(termux-wifi-connectioninfo 2>/dev/null)
    
    if [ -n "$conn_data" ] && echo "$conn_data" | jq -e '.' &>/dev/null; then
        local ssid bssid ip link_speed rssi freq mac supstate
        ssid=$(echo "$conn_data" | jq -r '.ssid // "N/A"')
        bssid=$(echo "$conn_data" | jq -r '.bssid // "N/A"')
        ip=$(echo "$conn_data" | jq -r '.ip // "N/A"')
        link_speed=$(echo "$conn_data" | jq -r '.link_speed_mbps // "N/A"')
        rssi=$(echo "$conn_data" | jq -r '.rssi // "N/A"')
        freq=$(echo "$conn_data" | jq -r '.frequency_mhz // "N/A"')
        mac=$(echo "$conn_data" | jq -r '.mac_address // "N/A"')
        supstate=$(echo "$conn_data" | jq -r '.supplicant_state // "N/A"')
        
        # Signal quality
        local sig_quality sig_color
        if [ "$rssi" != "N/A" ] && [ "$rssi" -ge -50 ] 2>/dev/null; then
            sig_quality="Excellent ||||||||"
            sig_color="${GREEN}"
        elif [ "$rssi" != "N/A" ] && [ "$rssi" -ge -60 ] 2>/dev/null; then
            sig_quality="Good     |||||||"
            sig_color="${GREEN}"
        elif [ "$rssi" != "N/A" ] && [ "$rssi" -ge -70 ] 2>/dev/null; then
            sig_quality="Fair     |||||"
            sig_color="${YELLOW}"
        elif [ "$rssi" != "N/A" ] && [ "$rssi" -ge -80 ] 2>/dev/null; then
            sig_quality="Weak     |||"
            sig_color="${ORANGE}"
        else
            sig_quality="Very Weak |"
            sig_color="${RED}"
        fi
        
        echo -e "  ${GRAY}Network Name  :${NC} ${WHITE}${ssid}${NC}"
        echo -e "  ${GRAY}BSSID         :${NC} ${WHITE}${bssid}${NC}"
        echo -e "  ${GRAY}IP Address    :${NC} ${GREEN}${ip}${NC}"
        echo -e "  ${GRAY}MAC Address   :${NC} ${WHITE}${mac}${NC}"
        echo -e "  ${GRAY}Link Speed    :${NC} ${WHITE}${link_speed} Mbps${NC}"
        echo -e "  ${GRAY}Frequency     :${NC} ${WHITE}${freq} MHz${NC}"
        echo -e "  ${GRAY}RSSI          :${NC} ${sig_color}${rssi} dBm${NC}"
        echo -e "  ${GRAY}Signal Quality:${NC} ${sig_color}${sig_quality}${NC}"
        echo -e "  ${GRAY}State         :${NC} ${GREEN}${supstate}${NC}"
        
        print_separator
        echo -e "  ${WHITE}${BOLD}Extended Info${NC}"
        print_separator
        
        local gateway dns subnet public_ip
        gateway=$(ip route 2>/dev/null | grep default | awk '{print $3}' | head -1)
        dns=$(getprop net.dns1 2>/dev/null || echo "N/A")
        subnet=$(ip addr show wlan0 2>/dev/null | grep "inet " | awk '{print $2}')
        public_ip=$(curl -s --max-time 5 ifconfig.me 2>/dev/null || echo "N/A")
        
        echo -e "  ${GRAY}Gateway       :${NC} ${WHITE}${gateway:-N/A}${NC}"
        echo -e "  ${GRAY}DNS Server    :${NC} ${WHITE}${dns}${NC}"
        echo -e "  ${GRAY}Subnet        :${NC} ${WHITE}${subnet:-N/A}${NC}"
        echo -e "  ${GRAY}Public IP     :${NC} ${YELLOW}${public_ip}${NC}"
    else
        print_error "Not connected to WiFi or Termux:API not available."
    fi
    
    pause_screen
}

wifi_toggle() {
    print_header "WiFi Toggle"
    
    echo -e "  ${CYAN}[1]${NC} ${WHITE}Enable WiFi${NC}"
    echo -e "  ${CYAN}[2]${NC} ${WHITE}Disable WiFi${NC}"
    echo ""
    
    get_input "Choice"
    
    case $USER_INPUT in
        1)
            loading_animation "Enabling WiFi" 2
            termux-wifi-enable true 2>/dev/null
            print_success "WiFi enabled"
            ;;
        2)
            loading_animation "Disabling WiFi" 2
            termux-wifi-enable false 2>/dev/null
            print_success "WiFi disabled"
            ;;
        *)
            print_error "Invalid choice"
            ;;
    esac
    sleep 1
}

wifi_signal_monitor() {
    print_header "WiFi Signal Monitor (Live)"
    echo -e "  ${YELLOW}${WARNING} Press Ctrl+C to stop monitoring${NC}"
    echo ""
    
    printf "  ${CYAN}%-6s %-16s %-8s %-8s %-30s${NC}\n" \
        "Time" "SSID" "RSSI" "Speed" "Signal"
    print_separator
    
    trap 'echo ""; print_success "Monitoring stopped"; return' INT
    
    while true; do
        local data ssid rssi speed time_now
        data=$(termux-wifi-connectioninfo 2>/dev/null)
        
        if [ -n "$data" ]; then
            ssid=$(echo "$data" | jq -r '.ssid // "N/A"' | cut -c1-14)
            rssi=$(echo "$data" | jq -r '.rssi // 0')
            speed=$(echo "$data" | jq -r '.link_speed_mbps // 0')
            time_now=$(date +"%H:%M")
            
            local bar_length sig_color bar empty
            bar_length=$(( (rssi + 100) * 25 / 60 ))
            [ "$bar_length" -lt 0 ] && bar_length=0
            [ "$bar_length" -gt 25 ] && bar_length=25
            
            if [ "$rssi" -ge -50 ] 2>/dev/null; then
                sig_color="${GREEN}"
            elif [ "$rssi" -ge -70 ] 2>/dev/null; then
                sig_color="${YELLOW}"
            else
                sig_color="${RED}"
            fi
            
            bar=$(printf "%${bar_length}s" | tr ' ' '#')
            empty=$(printf "%$((25-bar_length))s" | tr ' ' '-')
            
            printf "  ${WHITE}%-6s${NC} %-16s ${sig_color}%-8s${NC} %-8s ${sig_color}%s${GRAY}%s${NC}\n" \
                "$time_now" "$ssid" "${rssi}dBm" "${speed}M" "$bar" "$empty"
        fi
        sleep 2
    done
    
    trap - INT
}

wifi_network_analyzer() {
    print_header "Network Analyzer"
    loading_animation "Analyzing network" 3
    
    local ip_addr gateway
    ip_addr=$(ip addr show wlan0 2>/dev/null | grep "inet " | awk '{print $2}' | cut -d/ -f1)
    gateway=$(ip route 2>/dev/null | grep default | awk '{print $3}' | head -1)
    
    if [ -z "$ip_addr" ]; then
        print_error "No WiFi connection detected"
        pause_screen
        return
    fi
    
    local subnet dns1 dns2
    subnet=$(ip addr show wlan0 2>/dev/null | grep "inet " | awk '{print $2}')
    dns1=$(getprop net.dns1 2>/dev/null)
    dns2=$(getprop net.dns2 2>/dev/null)
    
    echo -e "  ${WHITE}${BOLD}Network Information${NC}"
    print_separator
    echo -e "  ${GRAY}Interface   :${NC} ${WHITE}wlan0${NC}"
    echo -e "  ${GRAY}IP Address  :${NC} ${GREEN}${ip_addr}${NC}"
    echo -e "  ${GRAY}Subnet      :${NC} ${WHITE}${subnet}${NC}"
    echo -e "  ${GRAY}Gateway     :${NC} ${WHITE}${gateway}${NC}"
    echo -e "  ${GRAY}DNS1        :${NC} ${WHITE}${dns1:-N/A}${NC}"
    echo -e "  ${GRAY}DNS2        :${NC} ${WHITE}${dns2:-N/A}${NC}"
    
    echo ""
    echo -e "  ${WHITE}${BOLD}Connectivity Tests${NC}"
    print_separator
    
    # Gateway ping
    echo -ne "  ${GRAY}Gateway Ping  :${NC} "
    local gw_ping
    gw_ping=$(ping -c 3 -W 2 "$gateway" 2>/dev/null | tail -1 | awk '{print $4}' | cut -d/ -f2)
    if [ -n "$gw_ping" ]; then
        echo -e "${GREEN}${gw_ping}ms${NC}"
    else
        echo -e "${RED}Failed${NC}"
    fi
    
    # Internet
    echo -ne "  ${GRAY}Internet Ping :${NC} "
    local inet_ping
    inet_ping=$(ping -c 3 -W 3 8.8.8.8 2>/dev/null | tail -1 | awk '{print $4}' | cut -d/ -f2)
    if [ -n "$inet_ping" ]; then
        echo -e "${GREEN}${inet_ping}ms${NC}"
    else
        echo -e "${RED}No Internet${NC}"
    fi
    
    # DNS
    echo -ne "  ${GRAY}DNS Resolution:${NC} "
    if nslookup google.com &>/dev/null; then
        echo -e "${GREEN}Working${NC}"
    else
        echo -e "${RED}Failed${NC}"
    fi
    
    # Speed
    echo -ne "  ${GRAY}Download Test :${NC} "
    local speed_test
    speed_test=$(curl -s -o /dev/null -w '%{speed_download}' --max-time 10 \
                 "http://speedtest.tele2.net/1MB.zip" 2>/dev/null)
    if [ -n "$speed_test" ] && [ "$speed_test" != "0.000" ]; then
        local speed_mbps
        speed_mbps=$(echo "scale=2; $speed_test / 125000" | bc 2>/dev/null || echo "N/A")
        echo -e "${GREEN}~${speed_mbps} Mbps${NC}"
    else
        echo -e "${YELLOW}Skipped${NC}"
    fi
    
    pause_screen
}

wifi_device_scanner() {
    print_header "Network Device Scanner"
    
    local gateway subnet
    gateway=$(ip route 2>/dev/null | grep default | awk '{print $3}' | head -1)
    
    if [ -z "$gateway" ]; then
        print_error "No network connection detected"
        pause_screen
        return
    fi
    
    subnet="${gateway%.*}.0/24"
    echo -e "  ${WHITE}Network: ${CYAN}${subnet}${NC}"
    echo ""
    echo -e "  ${CYAN}[1]${NC} Quick Ping Scan"
    echo -e "  ${CYAN}[2]${NC} ARP Table"
    echo -e "  ${CYAN}[3]${NC} Nmap Discovery"
    echo -e "  ${CYAN}[4]${NC} Nmap Deep Scan (Slow)"
    echo ""
    
    get_input "Choice"
    
    local timestamp
    timestamp=$(date +"%Y%m%d_%H%M%S")
    
    case $USER_INPUT in
        1)
            loading_animation "Running quick ping scan on ${subnet}" 2
            echo ""
            local network="${gateway%.*}"
            
            local i=1
            while [ "$i" -le 254 ]; do
                ping -c 1 -W 1 "${network}.${i}" &>/dev/null &
                i=$((i + 1))
            done
            wait
            
            printf "\n  ${CYAN}%-4s %-18s %-19s %-10s${NC}\n" "##" "IP Address" "MAC Address" "Status"
            print_separator
            
            local count=0
            ip neigh show 2>/dev/null | grep -v "FAILED" | sort -t. -k4 -n | while IFS= read -r line; do
                local dev_ip dev_mac dev_state
                dev_ip=$(echo "$line" | awk '{print $1}')
                dev_mac=$(echo "$line" | awk '{print $5}')
                dev_state=$(echo "$line" | awk '{print $NF}')
                
                if [ "$dev_state" = "REACHABLE" ] || [ "$dev_state" = "STALE" ]; then
                    count=$((count + 1))
                    local state_color="${GREEN}"
                    [ "$dev_state" = "STALE" ] && state_color="${YELLOW}"
                    
                    printf "  ${WHITE}%-4s${NC} %-18s %-19s ${state_color}%-10s${NC}\n" \
                        "$count" "$dev_ip" "${dev_mac:---}" "$dev_state"
                fi
            done
            print_separator
            ;;
        2)
            loading_animation "Reading ARP table" 2
            echo ""
            ip neigh show 2>/dev/null | while IFS= read -r line; do
                echo -e "  ${CYAN}${BULLET}${NC} $line"
            done
            ;;
        3)
            if command -v nmap &>/dev/null; then
                loading_animation "Running Nmap discovery scan" 2
                echo ""
                nmap -sn "$subnet" 2>/dev/null | while IFS= read -r line; do
                    if echo "$line" | grep -q "Nmap scan report"; then
                        echo -e "  ${GREEN}${BULLET} $line${NC}"
                    elif echo "$line" | grep -q "MAC Address"; then
                        echo -e "    ${GRAY}$line${NC}"
                    elif echo "$line" | grep -q "Host is up"; then
                        echo -e "    ${CYAN}$line${NC}"
                    fi
                done
            else
                print_error "Nmap not installed. Run installer first."
            fi
            ;;
        4)
            if command -v nmap &>/dev/null; then
                local outfile="$SCAN_RESULTS/deep_scan_${timestamp}.txt"
                loading_animation "Running deep scan (this will take a while)" 2
                echo ""
                nmap -sV -T4 "$subnet" 2>/dev/null | tee "$outfile" | while IFS= read -r line; do
                    if echo "$line" | grep -q "open"; then
                        echo -e "    ${GREEN}$line${NC}"
                    elif echo "$line" | grep -q "Nmap scan report"; then
                        echo -e "\n  ${WHITE}${BOLD}$line${NC}"
                    else
                        echo -e "    ${GRAY}$line${NC}"
                    fi
                done
                echo ""
                print_success "Saved to: ${outfile}"
            else
                print_error "Nmap not installed."
            fi
            ;;
        *)
            print_error "Invalid choice"
            ;;
    esac
    
    pause_screen
}

wifi_port_scanner() {
    print_header "Port Scanner"
    
    get_input "Target IP or hostname"
    local target="$USER_INPUT"
    
    if [ -z "$target" ]; then
        print_error "No target specified"
        pause_screen
        return
    fi
    
    echo ""
    echo -e "  ${CYAN}[1]${NC} Top 100 Ports (Fast)"
    echo -e "  ${CYAN}[2]${NC} Top 1000 Ports"
    echo -e "  ${CYAN}[3]${NC} All 65535 Ports (Slow)"
    echo -e "  ${CYAN}[4]${NC} Custom Port Range"
    echo -e "  ${CYAN}[5]${NC} Service Version Detection"
    echo ""
    
    get_input "Choice"
    local choice="$USER_INPUT"
    
    local timestamp
    timestamp=$(date +"%Y%m%d_%H%M%S")
    local outfile="$SCAN_RESULTS/port_scan_${target}_${timestamp}.txt"
    
    echo ""
    
    if ! command -v nmap &>/dev/null; then
        print_warning "Nmap not installed. Using basic scanner."
        echo ""
        basic_port_scan "$target"
        pause_screen
        return
    fi
    
    case $choice in
        1)
            loading_animation "Scanning top 100 ports on ${target}" 2
            nmap -T4 --top-ports 100 "$target" 2>/dev/null | tee "$outfile" | \
                while IFS= read -r line; do colorize_nmap "$line"; done
            ;;
        2)
            loading_animation "Scanning top 1000 ports on ${target}" 2
            nmap -T4 "$target" 2>/dev/null | tee "$outfile" | \
                while IFS= read -r line; do colorize_nmap "$line"; done
            ;;
        3)
            loading_animation "Scanning ALL ports on ${target} (be patient)" 2
            nmap -T4 -p- "$target" 2>/dev/null | tee "$outfile" | \
                while IFS= read -r line; do colorize_nmap "$line"; done
            ;;
        4)
            get_input "Port range (e.g. 1-1000 or 80,443,8080)"
            local range="$USER_INPUT"
            loading_animation "Scanning ports ${range} on ${target}" 2
            nmap -T4 -p "$range" "$target" 2>/dev/null | tee "$outfile" | \
                while IFS= read -r line; do colorize_nmap "$line"; done
            ;;
        5)
            loading_animation "Running service detection on ${target}" 2
            nmap -sV -T4 "$target" 2>/dev/null | tee "$outfile" | \
                while IFS= read -r line; do colorize_nmap "$line"; done
            ;;
        *)
            print_error "Invalid choice"
            ;;
    esac
    
    if [ -f "$outfile" ]; then
        echo ""
        print_success "Results saved to: ${outfile}"
    fi
    
    pause_screen
}

colorize_nmap() {
    local line="$1"
    if echo "$line" | grep -q "open"; then
        echo -e "  ${GREEN}$line${NC}"
    elif echo "$line" | grep -q "closed"; then
        echo -e "  ${RED}$line${NC}"
    elif echo "$line" | grep -q "filtered"; then
        echo -e "  ${YELLOW}$line${NC}"
    elif echo "$line" | grep -q "Nmap scan report"; then
        echo -e "\n  ${WHITE}${BOLD}$line${NC}"
    else
        echo -e "  ${GRAY}$line${NC}"
    fi
}

basic_port_scan() {
    local target="$1"
    local ports="21 22 23 25 53 80 110 143 443 993 995 3306 3389 5432 8080 8443"
    
    printf "  ${CYAN}%-8s %-16s %-10s${NC}\n" "Port" "Service" "Status"
    print_separator
    
    for port in $ports; do
        local service
        case $port in
            21) service="FTP" ;; 22) service="SSH" ;; 23) service="Telnet" ;;
            25) service="SMTP" ;; 53) service="DNS" ;; 80) service="HTTP" ;;
            110) service="POP3" ;; 143) service="IMAP" ;; 443) service="HTTPS" ;;
            993) service="IMAPS" ;; 995) service="POP3S" ;; 3306) service="MySQL" ;;
            3389) service="RDP" ;; 5432) service="PostgreSQL" ;; 8080) service="HTTP-Alt" ;;
            8443) service="HTTPS-Alt" ;; *) service="Unknown" ;;
        esac
        
        (echo >/dev/tcp/"$target"/"$port" 2>/dev/null) &>/dev/null
        if [ $? -eq 0 ]; then
            printf "  ${WHITE}%-8s${NC} %-16s ${GREEN}%-10s${NC}\n" "$port" "$service" "OPEN"
        fi
    done
    print_separator
}

wifi_speed_test() {
    print_header "WiFi Speed Test"
    
    echo -e "  ${CYAN}[1]${NC} Download Test (1MB)"
    echo -e "  ${CYAN}[2]${NC} Download Test (10MB)"
    echo -e "  ${CYAN}[3]${NC} Latency Test"
    echo -e "  ${CYAN}[4]${NC} Full Test (All)"
    echo ""
    
    get_input "Choice"
    local choice="$USER_INPUT"
    
    echo ""
    
    run_download() {
        local size=$1 url
        case $size in
            1) url="http://speedtest.tele2.net/1MB.zip" ;;
            10) url="http://speedtest.tele2.net/10MB.zip" ;;
        esac
        
        echo -ne "  ${CYAN}${ARROW}${NC} Downloading ${size}MB test file... "
        local result
        result=$(curl -s -o /dev/null -w '%{speed_download} %{time_total}' \
                 --max-time 30 "$url" 2>/dev/null)
        local speed time_taken
        speed=$(echo "$result" | awk '{print $1}')
        time_taken=$(echo "$result" | awk '{print $2}')
        
        if [ -n "$speed" ] && [ "$speed" != "0.000" ]; then
            local speed_mbps
            speed_mbps=$(echo "scale=2; $speed / 125000" | bc 2>/dev/null || echo "?")
            echo -e "${GREEN}${speed_mbps} Mbps${NC} (${time_taken}s)"
        else
            echo -e "${RED}Failed${NC}"
        fi
    }
    
    run_latency() {
        local targets="8.8.8.8 1.1.1.1 208.67.222.222"
        printf "\n  ${CYAN}%-20s %-10s %-10s %-10s${NC}\n" "Target" "Min" "Avg" "Max"
        print_separator
        
        for t in $targets; do
            local ping_result stats p_min p_avg p_max
            ping_result=$(ping -c 5 -W 3 "$t" 2>/dev/null | tail -1)
            if echo "$ping_result" | grep -q "min/avg/max"; then
                stats=$(echo "$ping_result" | awk -F'=' '{print $2}' | awk -F'/' '{print $1, $2, $3}')
                p_min=$(echo "$stats" | awk '{print $1}')
                p_avg=$(echo "$stats" | awk '{print $2}')
                p_max=$(echo "$stats" | awk '{print $3}')
                printf "  %-20s ${GREEN}%-10s${NC} ${YELLOW}%-10s${NC} ${RED}%-10s${NC}\n" \
                    "$t" "${p_min}ms" "${p_avg}ms" "${p_max}ms"
            else
                printf "  %-20s ${RED}%-10s %-10s %-10s${NC}\n" "$t" "Failed" "Failed" "Failed"
            fi
        done
        print_separator
    }
    
    case $choice in
        1) run_download 1 ;;
        2) run_download 10 ;;
        3) run_latency ;;
        4) run_download 1; run_download 10; run_latency ;;
        *) print_error "Invalid choice" ;;
    esac
    
    pause_screen
}

wifi_mac_changer() {
    print_header "MAC Address Changer"
    
    if ! $IS_ROOT; then
        print_error "Root access required for MAC address changes"
        pause_screen
        return
    fi
    
    local current_mac
    current_mac=$(ip link show wlan0 2>/dev/null | grep ether | awk '{print $2}')
    echo -e "  ${GRAY}Current MAC:${NC} ${WHITE}${current_mac}${NC}"
    echo ""
    echo -e "  ${CYAN}[1]${NC} Set Random MAC"
    echo -e "  ${CYAN}[2]${NC} Set Custom MAC"
    echo -e "  ${CYAN}[3]${NC} Restore Original MAC"
    echo -e "  ${CYAN}[4]${NC} Set Vendor MAC (Apple/Samsung/Google)"
    echo ""
    
    get_input "Choice"
    local choice="$USER_INPUT"
    
    change_mac() {
        local new_mac=$1
        su -c "ip link set wlan0 down" 2>/dev/null
        su -c "ip link set wlan0 address $new_mac" 2>/dev/null
        su -c "ip link set wlan0 up" 2>/dev/null
        
        local verify_mac
        verify_mac=$(ip link show wlan0 2>/dev/null | grep ether | awk '{print $2}')
        if [ "$verify_mac" = "$new_mac" ]; then
            print_success "MAC changed to: ${new_mac}"
        else
            print_error "MAC change failed (verify: ${verify_mac})"
        fi
    }
    
    case $choice in
        1)
            local rand_mac
            rand_mac=$(printf '02:%02x:%02x:%02x:%02x:%02x' \
                $((RANDOM%256)) $((RANDOM%256)) $((RANDOM%256)) \
                $((RANDOM%256)) $((RANDOM%256)))
            loading_animation "Changing MAC address" 2
            change_mac "$rand_mac"
            ;;
        2)
            get_input "Enter MAC (XX:XX:XX:XX:XX:XX)"
            local custom_mac="$USER_INPUT"
            if echo "$custom_mac" | grep -qE '^([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}$'; then
                loading_animation "Changing MAC address" 2
                change_mac "$custom_mac"
            else
                print_error "Invalid MAC format. Use: XX:XX:XX:XX:XX:XX"
            fi
            ;;
        3)
            loading_animation "Restoring original MAC" 2
            if command -v macchanger &>/dev/null; then
                su -c "ip link set wlan0 down && macchanger -p wlan0 && ip link set wlan0 up" 2>/dev/null
                print_success "Original MAC restored"
            else
                print_error "macchanger not installed (pkg install macchanger)"
            fi
            ;;
        4)
            echo ""
            echo -e "  ${CYAN}[1]${NC} Apple      ${CYAN}[2]${NC} Samsung    ${CYAN}[3]${NC} Google"
            echo -e "  ${CYAN}[4]${NC} Intel      ${CYAN}[5]${NC} Cisco"
            echo ""
            get_input "Vendor"
            local vendor_prefix
            case $USER_INPUT in
                1) vendor_prefix="F4:5C:89" ;; 2) vendor_prefix="A8:7C:01" ;;
                3) vendor_prefix="3C:5A:B4" ;; 4) vendor_prefix="DC:53:60" ;;
                5) vendor_prefix="00:26:0B" ;; *) vendor_prefix="02:00:00" ;;
            esac
            local vendor_mac
            vendor_mac=$(printf '%s:%02x:%02x:%02x' "$vendor_prefix" \
                $((RANDOM%256)) $((RANDOM%256)) $((RANDOM%256)))
            loading_animation "Applying vendor MAC" 2
            change_mac "$vendor_mac"
            ;;
        *)
            print_error "Invalid choice"
            ;;
    esac
    
    pause_screen
}

wifi_saved_networks() {
    print_header "Saved WiFi Networks & Passwords"
    
    if ! $IS_ROOT; then
        print_error "Root access required to view saved passwords"
        print_info "Without root, only basic info is available"
        pause_screen
        return
    fi
    
    loading_animation "Reading saved networks" 2
    
    local wpa_conf="/data/misc/wifi/WifiConfigStore.xml"
    local wpa_conf2="/data/misc/wifi/wpa_supplicant.conf"
    
    if su -c "test -f $wpa_conf" 2>/dev/null; then
        echo ""
        printf "  ${CYAN}%-4s %-28s %-26s${NC}\n" "##" "SSID" "Password"
        print_separator
        
        local count=0
        local ssid="" psk=""
        su -c "cat $wpa_conf" 2>/dev/null | while IFS= read -r line; do
            if echo "$line" | grep -q 'name="SSID"'; then
                ssid=$(echo "$line" | grep -oP '(?<=">)[^<]+' | tr -d '"')
            elif echo "$line" | grep -q 'name="PreSharedKey"'; then
                psk=$(echo "$line" | grep -oP '(?<=">)[^<]+' | tr -d '"')
                count=$((count + 1))
                printf "  ${WHITE}%-4s${NC} %-28s ${YELLOW}%-26s${NC}\n" \
                    "$count" "${ssid:-Unknown}" "${psk:-[None/Enterprise]}"
                ssid=""
                psk=""
            fi
        done
        print_separator
    elif su -c "test -f $wpa_conf2" 2>/dev/null; then
        echo ""
        su -c "cat $wpa_conf2" 2>/dev/null | grep -E "ssid|psk" | while IFS= read -r line; do
            echo -e "  ${WHITE}$line${NC}"
        done
    else
        print_warning "Could not locate WiFi configuration file"
        print_info "This may not work on Android 10+ due to restrictions"
    fi
    
    pause_screen
}

wifi_packet_capture() {
    print_header "Packet Capture"
    
    if ! $IS_ROOT; then
        print_error "Root access required for packet capture"
        pause_screen
        return
    fi
    
    if ! command -v tcpdump &>/dev/null; then
        print_error "tcpdump not installed (pkg install tcpdump)"
        pause_screen
        return
    fi
    
    echo -e "  ${CYAN}[1]${NC} Capture All Traffic"
    echo -e "  ${CYAN}[2]${NC} Capture HTTP Traffic"
    echo -e "  ${CYAN}[3]${NC} Capture DNS Traffic"
    echo -e "  ${CYAN}[4]${NC} Capture ARP Traffic"
    echo -e "  ${CYAN}[5]${NC} Capture Specific Host"
    echo -e "  ${CYAN}[6]${NC} Save to PCAP File"
    echo ""
    
    get_input "Choice"
    local choice="$USER_INPUT"
    
    echo ""
    echo -e "  ${YELLOW}${WARNING} Press Ctrl+C to stop capture${NC}"
    echo ""
    
    trap 'echo ""; print_success "Capture stopped"; return' INT
    
    case $choice in
        1) su -c "tcpdump -i wlan0 -n -c 100 2>/dev/null" ;;
        2) su -c "tcpdump -i wlan0 -n -A 'port 80 or port 443' -c 50 2>/dev/null" ;;
        3) su -c "tcpdump -i wlan0 -n 'port 53' -c 50 2>/dev/null" ;;
        4) su -c "tcpdump -i wlan0 -n arp -c 30 2>/dev/null" ;;
        5)
            get_input "Target IP"
            local host="$USER_INPUT"
            su -c "tcpdump -i wlan0 -n host $host -c 50 2>/dev/null"
            ;;
        6)
            local timestamp pcap_file
            timestamp=$(date +"%Y%m%d_%H%M%S")
            pcap_file="$CAPTURE_DIR/capture_${timestamp}.pcap"
            
            get_input "Duration in seconds (0=manual stop)"
            local dur="$USER_INPUT"
            
            if [ "$dur" -gt 0 ] 2>/dev/null; then
                su -c "timeout $dur tcpdump -i wlan0 -w $pcap_file 2>/dev/null"
            else
                su -c "tcpdump -i wlan0 -w $pcap_file 2>/dev/null"
            fi
            echo ""
            print_success "Capture saved to: ${pcap_file}"
            ;;
        *) print_error "Invalid choice" ;;
    esac
    
    trap - INT
    pause_screen
}

wifi_dns_tools() {
    print_header "DNS Tools"
    
    echo -e "  ${CYAN}[1]${NC} DNS Lookup"
    echo -e "  ${CYAN}[2]${NC} Reverse DNS Lookup"
    echo -e "  ${CYAN}[3]${NC} WHOIS Lookup"
    echo -e "  ${CYAN}[4]${NC} Traceroute"
    echo -e "  ${CYAN}[5]${NC} Change DNS Server"
    echo ""
    
    get_input "Choice"
    local choice="$USER_INPUT"
    
    echo ""
    
    case $choice in
        1)
            get_input "Domain name"
            local domain="$USER_INPUT"
            loading_animation "Resolving ${domain}" 2
            echo ""
            for type in A AAAA MX NS TXT CNAME; do
                local result
                result=$(nslookup -type="$type" "$domain" 2>/dev/null | grep -E "address|mail|nameserver|text|canonical" | head -3)
                if [ -n "$result" ]; then
                    echo -e "  ${CYAN}${type}:${NC}"
                    echo "$result" | while IFS= read -r l; do
                        echo -e "    ${WHITE}$l${NC}"
                    done
                fi
            done
            ;;
        2)
            get_input "IP address"
            local ip="$USER_INPUT"
            loading_animation "Reverse lookup on ${ip}" 2
            echo ""
            nslookup "$ip" 2>/dev/null | while IFS= read -r l; do
                echo -e "  ${GRAY}$l${NC}"
            done
            ;;
        3)
            get_input "Domain or IP"
            local target="$USER_INPUT"
            loading_animation "WHOIS lookup on ${target}" 2
            echo ""
            if command -v whois &>/dev/null; then
                whois "$target" 2>/dev/null | head -40 | while IFS= read -r l; do
                    if echo "$l" | grep -qi "registrar\|creation\|expir\|nameserver\|org\|country"; then
                        echo -e "  ${GREEN}$l${NC}"
                    else
                        echo -e "  ${GRAY}$l${NC}"
                    fi
                done
            else
                print_error "whois not installed (pkg install whois)"
            fi
            ;;
        4)
            get_input "Target host"
            local host="$USER_INPUT"
            loading_animation "Traceroute to ${host}" 2
            echo ""
            if command -v traceroute &>/dev/null; then
                traceroute -m 20 "$host" 2>/dev/null | while IFS= read -r l; do
                    if echo "$l" | grep -q "\*"; then
                        echo -e "  ${YELLOW}$l${NC}"
                    else
                        echo -e "  ${GREEN}$l${NC}"
                    fi
                done
            else
                print_error "traceroute not installed (pkg install traceroute)"
            fi
            ;;
        5)
            echo -e "  ${CYAN}[1]${NC} Google      (8.8.8.8)"
            echo -e "  ${CYAN}[2]${NC} Cloudflare  (1.1.1.1)"
            echo -e "  ${CYAN}[3]${NC} OpenDNS     (208.67.222.222)"
            echo -e "  ${CYAN}[4]${NC} Quad9       (9.9.9.9)"
            echo -e "  ${CYAN}[5]${NC} Custom"
            echo ""
            get_input "Choice"
            local dns_ip
            case $USER_INPUT in
                1) dns_ip="8.8.8.8" ;; 2) dns_ip="1.1.1.1" ;;
                3) dns_ip="208.67.222.222" ;; 4) dns_ip="9.9.9.9" ;;
                5) get_input "DNS IP"; dns_ip="$USER_INPUT" ;;
            esac
            if [ -n "$dns_ip" ]; then
                echo "nameserver $dns_ip" > "$PREFIX/etc/resolv.conf" 2>/dev/null
                print_success "DNS changed to: ${dns_ip}"
            fi
            ;;
        *) print_error "Invalid choice" ;;
    esac
    
    pause_screen
}

wifi_arp_detector() {
    print_header "ARP Spoof Detector"
    loading_animation "Analyzing ARP table" 3
    
    local gateway gateway_mac
    gateway=$(ip route 2>/dev/null | grep default | awk '{print $3}' | head -1)
    gateway_mac=$(ip neigh show "$gateway" 2>/dev/null | awk '{print $5}')
    
    echo -e "  ${GRAY}Gateway IP  :${NC} ${WHITE}${gateway:-N/A}${NC}"
    echo -e "  ${GRAY}Gateway MAC :${NC} ${WHITE}${gateway_mac:-N/A}${NC}"
    echo ""
    
    echo -e "  ${WHITE}${BOLD}Checking for duplicate MACs...${NC}"
    echo ""
    
    local duplicates
    duplicates=$(ip neigh show 2>/dev/null | awk '{print $5}' | sort | uniq -d)
    
    if [ -n "$duplicates" ]; then
        echo -e "  ${RED}${WARNING} POTENTIAL ARP SPOOFING DETECTED!${NC}"
        echo ""
        echo "$duplicates" | while IFS= read -r mac; do
            echo -e "  ${RED}${CROSS} Duplicate MAC: ${WHITE}${mac}${NC}"
            ip neigh show 2>/dev/null | grep "$mac" | while IFS= read -r entry; do
                echo -e "    ${YELLOW}-> ${entry}${NC}"
            done
        done
    else
        print_success "No duplicate MAC addresses found - Network appears clean"
    fi
    
    echo ""
    echo -e "  ${WHITE}Start continuous monitoring? (y/n)${NC}"
    get_input "Choice"
    
    if [ "$USER_INPUT" = "y" ] || [ "$USER_INPUT" = "Y" ]; then
        echo ""
        echo -e "  ${YELLOW}${WARNING} Monitoring... Press Ctrl+C to stop${NC}"
        echo ""
        
        trap 'echo ""; print_success "Monitoring stopped"; return' INT
        
        local prev_mac="$gateway_mac"
        while true; do
            local current_mac
            current_mac=$(ip neigh show "$gateway" 2>/dev/null | awk '{print $5}')
            if [ "$current_mac" != "$prev_mac" ] && [ -n "$current_mac" ]; then
                echo -e "  ${RED}${WARNING} MAC CHANGE! ${WHITE}${prev_mac} -> ${current_mac}${NC}"
                termux-notification --title "ARP Spoof Alert!" \
                    --content "Gateway MAC changed: $prev_mac -> $current_mac" 2>/dev/null
                prev_mac="$current_mac"
            else
                echo -ne "\r  ${GREEN}${CHECK} MAC stable: ${WHITE}${current_mac}${NC} $(date +%H:%M:%S)   "
            fi
            sleep 3
        done
        
        trap - INT
    fi
    
    pause_screen
}

wifi_network_toolkit() {
    print_header "Network Toolkit"
    
    echo -e "  ${CYAN}[1]${NC} HTTP Headers Check"
    echo -e "  ${CYAN}[2]${NC} SSL Certificate Info"
    echo -e "  ${CYAN}[3]${NC} Website Availability Check"
    echo -e "  ${CYAN}[4]${NC} Network Interfaces"
    echo -e "  ${CYAN}[5]${NC} Routing Table"
    echo -e "  ${CYAN}[6]${NC} Active Connections"
    echo -e "  ${CYAN}[7]${NC} Bandwidth Monitor (Live)"
    echo ""
    
    get_input "Choice"
    local choice="$USER_INPUT"
    
    echo ""
    
    case $choice in
        1)
            get_input "URL (e.g. https://google.com)"
            local url="$USER_INPUT"
            loading_animation "Fetching HTTP headers" 2
            echo ""
            curl -sI --max-time 10 "$url" 2>/dev/null | while IFS= read -r l; do
                if echo "$l" | grep -qi "^HTTP"; then
                    echo -e "  ${GREEN}$l${NC}"
                elif echo "$l" | grep -qi "server\|x-powered"; then
                    echo -e "  ${YELLOW}$l${NC}"
                else
                    echo -e "  ${GRAY}$l${NC}"
                fi
            done
            ;;
        2)
            get_input "Domain (e.g. google.com)"
            local domain="$USER_INPUT"
            loading_animation "Checking SSL certificate" 2
            echo ""
            echo | openssl s_client -connect "${domain}:443" -servername "$domain" 2>/dev/null | \
                openssl x509 -noout -issuer -subject -dates -fingerprint 2>/dev/null | \
                while IFS= read -r l; do
                    echo -e "  ${GREEN}$l${NC}"
                done
            ;;
        3)
            get_input "URLs (space-separated)"
            local sites="$USER_INPUT"
            echo ""
            for site in $sites; do
                echo -ne "  ${WHITE}${site}: ${NC}"
                local code time_taken
                code=$(curl -sI -o /dev/null -w '%{http_code}' --max-time 10 "$site" 2>/dev/null)
                time_taken=$(curl -s -o /dev/null -w '%{time_total}' --max-time 10 "$site" 2>/dev/null)
                
                case $code in
                    200) echo -e "${GREEN}UP (${code}) - ${time_taken}s${NC}" ;;
                    301|302) echo -e "${YELLOW}REDIRECT (${code}) - ${time_taken}s${NC}" ;;
                    000) echo -e "${RED}DOWN - Timeout${NC}" ;;
                    *) echo -e "${RED}ERROR (${code}) - ${time_taken}s${NC}" ;;
                esac
            done
            ;;
        4)
            echo -e "  ${WHITE}${BOLD}Network Interfaces:${NC}"
            echo ""
            ip addr show 2>/dev/null | while IFS= read -r l; do
                if echo "$l" | grep -q "^[0-9]"; then
                    echo -e "\n  ${GREEN}${BOLD}$l${NC}"
                elif echo "$l" | grep -q "inet "; then
                    echo -e "  ${CYAN}  $l${NC}"
                elif echo "$l" | grep -q "ether"; then
                    echo -e "  ${YELLOW}  $l${NC}"
                else
                    echo -e "  ${GRAY}  $l${NC}"
                fi
            done
            ;;
        5)
            echo -e "  ${WHITE}${BOLD}Routing Table:${NC}"
            echo ""
            ip route show 2>/dev/null | while IFS= read -r l; do
                if echo "$l" | grep -q "default"; then
                    echo -e "  ${GREEN}$l${NC}"
                else
                    echo -e "  ${GRAY}$l${NC}"
                fi
            done
            ;;
        6)
            echo -e "  ${WHITE}${BOLD}Active Connections:${NC}"
            echo ""
            netstat -tn 2>/dev/null | head -30 | while IFS= read -r l; do
                if echo "$l" | grep -q "ESTABLISHED"; then
                    echo -e "  ${GREEN}$l${NC}"
                elif echo "$l" | grep -q "LISTEN"; then
                    echo -e "  ${CYAN}$l${NC}"
                else
                    echo -e "  ${GRAY}$l${NC}"
                fi
            done
            
            echo ""
            echo -e "  ${WHITE}Connection summary:${NC}"
            netstat -tn 2>/dev/null | awk 'NR>2 {print $6}' | sort | uniq -c | sort -rn | \
                while read -r cnt st; do
                    printf "    ${WHITE}%-15s${NC} ${CYAN}%4s${NC}\n" "$st" "$cnt"
                done
            ;;
        7)
            echo -e "  ${YELLOW}${WARNING} Press Ctrl+C to stop${NC}"
            echo ""
            
            trap 'echo ""; print_success "Stopped"; return' INT
            
            local prev_rx prev_tx
            prev_rx=$(cat /sys/class/net/wlan0/statistics/rx_bytes 2>/dev/null || echo "0")
            prev_tx=$(cat /sys/class/net/wlan0/statistics/tx_bytes 2>/dev/null || echo "0")
            
            while true; do
                sleep 1
                local curr_rx curr_tx rx_rate tx_rate
                curr_rx=$(cat /sys/class/net/wlan0/statistics/rx_bytes 2>/dev/null || echo "0")
                curr_tx=$(cat /sys/class/net/wlan0/statistics/tx_bytes 2>/dev/null || echo "0")
                
                rx_rate=$(( (curr_rx - prev_rx) / 1024 ))
                tx_rate=$(( (curr_tx - prev_tx) / 1024 ))
                
                printf "\r  ${GREEN}DOWN: %6d KB/s${NC} | ${RED}UP: %6d KB/s${NC}   " "$rx_rate" "$tx_rate"
                
                prev_rx=$curr_rx
                prev_tx=$curr_tx
            done
            trap - INT
            ;;
        *) print_error "Invalid choice" ;;
    esac
    
    pause_screen
}

# ========================= BLUETOOTH FUNCTIONS =========================

bt_scan() {
    print_header "Bluetooth Device Scanner"
    loading_animation "Scanning for Bluetooth devices" 4
    
    local timestamp scan_data
    timestamp=$(date +"%Y%m%d_%H%M%S")
    local outfile="$BT_RESULTS/bt_scan_${timestamp}.txt"
    
    scan_data=$(termux-bluetooth-scaninfo 2>/dev/null)
    
    if [ -n "$scan_data" ] && echo "$scan_data" | jq -e '.' &>/dev/null; then
        local count
        count=$(echo "$scan_data" | jq '. | length')
        
        echo ""
        echo -e "  ${GREEN}${CHECK} Found ${WHITE}${count}${GREEN} devices${NC}"
        echo ""
        printf "  ${BLUE}%-4s %-28s %-19s %-6s %-10s${NC}\n" \
            "##" "Device Name" "MAC Address" "RSSI" "Type"
        print_separator
        
        local i=0
        while [ "$i" -lt "$count" ]; do
            local name address rssi type sig_color
            name=$(echo "$scan_data" | jq -r ".[$i].name // \"Unknown\"")
            address=$(echo "$scan_data" | jq -r ".[$i].address // \"N/A\"")
            rssi=$(echo "$scan_data" | jq -r ".[$i].rssi // \"N/A\"")
            type=$(echo "$scan_data" | jq -r ".[$i].type // \"Unknown\"")
            
            if [ "$rssi" != "N/A" ] && [ "$rssi" -ge -50 ] 2>/dev/null; then
                sig_color="${GREEN}"
            elif [ "$rssi" != "N/A" ] && [ "$rssi" -ge -70 ] 2>/dev/null; then
                sig_color="${YELLOW}"
            else
                sig_color="${RED}"
            fi
            
            printf "  ${WHITE}%-4s${NC} %-28s %-19s ${sig_color}%-6s${NC} %-10s\n" \
                "$((i+1))" "${name:0:26}" "$address" "$rssi" "$type"
            
            i=$((i + 1))
        done
        
        print_separator
        echo "$scan_data" | jq '.' > "$outfile"
        print_success "Results saved to: ${outfile}"
    else
        print_error "Bluetooth scan failed."
        print_info "Make sure:"
        echo -e "    ${WHITE}1. Bluetooth is turned ON${NC}"
        echo -e "    ${WHITE}2. Termux:API app is installed${NC}"
        echo -e "    ${WHITE}3. Nearby Devices permission is granted${NC}"
        echo -e "    ${WHITE}4. Location permission is granted${NC}"
    fi
    
    pause_screen
}

bt_toggle() {
    print_header "Bluetooth Toggle"
    
    echo -e "  ${CYAN}[1]${NC} Enable Bluetooth"
    echo -e "  ${CYAN}[2]${NC} Disable Bluetooth"
    echo -e "  ${CYAN}[3]${NC} Check Status"
    echo ""
    
    get_input "Choice"
    
    case $USER_INPUT in
        1)
            loading_animation "Enabling Bluetooth" 2
            termux-bluetooth-enable true 2>/dev/null
            if $IS_ROOT; then
                su -c "svc bluetooth enable" 2>/dev/null
            fi
            print_success "Bluetooth enable command sent"
            ;;
        2)
            loading_animation "Disabling Bluetooth" 2
            termux-bluetooth-enable false 2>/dev/null
            if $IS_ROOT; then
                su -c "svc bluetooth disable" 2>/dev/null
            fi
            print_success "Bluetooth disable command sent"
            ;;
        3)
            loading_animation "Checking status" 1
            if $IS_ROOT; then
                local bt_status
                bt_status=$(su -c "settings get global bluetooth_on" 2>/dev/null)
                if [ "$bt_status" = "1" ]; then
                    echo -e "  ${GREEN}Bluetooth is: ENABLED${NC}"
                else
                    echo -e "  ${RED}Bluetooth is: DISABLED${NC}"
                fi
            else
                print_info "Root required for reliable status check"
            fi
            ;;
        *) print_error "Invalid choice" ;;
    esac
    sleep 1
}

bt_paired_devices() {
    print_header "Paired Bluetooth Devices"
    loading_animation "Retrieving paired devices" 2
    
    local paired_data
    paired_data=$(termux-bluetooth-paired 2>/dev/null)
    
    if [ -n "$paired_data" ] && echo "$paired_data" | jq -e '.' &>/dev/null; then
        local count
        count=$(echo "$paired_data" | jq '. | length')
        
        if [ "$count" -gt 0 ]; then
            echo -e "  ${GREEN}${CHECK} Found ${WHITE}${count}${GREEN} paired devices${NC}"
            echo ""
            printf "  ${BLUE}%-4s %-28s %-19s %-12s${NC}\n" "##" "Device Name" "MAC Address" "Type"
            print_separator
            
            local i=0
            while [ "$i" -lt "$count" ]; do
                local name address type
                name=$(echo "$paired_data" | jq -r ".[$i].name // \"Unknown\"")
                address=$(echo "$paired_data" | jq -r ".[$i].address // \"N/A\"")
                type=$(echo "$paired_data" | jq -r ".[$i].type // \"Unknown\"")
                
                printf "  ${WHITE}%-4s${NC} %-28s %-19s %-12s\n" \
                    "$((i+1))" "${name:0:26}" "$address" "$type"
                
                i=$((i + 1))
            done
            print_separator
        else
            print_info "No paired devices found"
        fi
    else
        print_error "Could not retrieve paired devices"
        print_info "Make sure Termux:API is installed and Bluetooth is enabled"
    fi
    
    pause_screen
}

bt_device_info() {
    print_header "Bluetooth Device Info"
    
    get_input "Device MAC address (XX:XX:XX:XX:XX:XX)"
    local mac="$USER_INPUT"
    
    if [ -z "$mac" ]; then
        print_error "No MAC address provided"
        pause_screen
        return
    fi
    
    loading_animation "Looking up device info" 3
    
    echo ""
    echo -e "  ${GRAY}MAC Address :${NC} ${WHITE}${mac}${NC}"
    
    local oui="${mac:0:8}"
    local vendor
    vendor=$(curl -s --max-time 5 "https://api.macvendors.com/${oui}" 2>/dev/null || echo "Unknown")
    echo -e "  ${GRAY}Vendor      :${NC} ${CYAN}${vendor}${NC}"
    
    local device_type="Unknown"
    case "${vendor,,}" in
        *apple*) device_type="Apple Device" ;; *samsung*) device_type="Samsung Device" ;;
        *google*) device_type="Google Device" ;; *huawei*) device_type="Huawei Device" ;;
        *xiaomi*) device_type="Xiaomi Device" ;; *sony*) device_type="Sony Device" ;;
        *intel*) device_type="Intel Chip" ;; *broadcom*) device_type="Broadcom Chip" ;;
    esac
    echo -e "  ${GRAY}Device Type :${NC} ${WHITE}${device_type}${NC}"
    
    if command -v hcitool &>/dev/null && $IS_ROOT; then
        local device_name
        device_name=$(su -c "hcitool name $mac" 2>/dev/null)
        if [ -n "$device_name" ]; then
            echo -e "  ${GRAY}Device Name :${NC} ${WHITE}${device_name}${NC}"
        fi
    fi
    
    pause_screen
}

bt_proximity_monitor() {
    print_header "Bluetooth Proximity Monitor"
    echo -e "  ${YELLOW}${WARNING} Press Ctrl+C to stop${NC}"
    echo ""
    
    trap 'echo ""; print_success "Monitoring stopped"; return' INT
    
    while true; do
        clear
        print_header "Bluetooth Proximity Monitor (Live)"
        echo -e "  ${WHITE}Time: $(date +"%H:%M:%S")${NC}"
        echo ""
        
        local scan_data
        scan_data=$(termux-bluetooth-scaninfo 2>/dev/null)
        
        if [ -n "$scan_data" ] && echo "$scan_data" | jq -e '.' &>/dev/null; then
            local count
            count=$(echo "$scan_data" | jq '. | length')
            
            local i=0
            while [ "$i" -lt "$count" ] && [ "$i" -lt 15 ]; do
                local name rssi bar_length sig_color bar empty
                name=$(echo "$scan_data" | jq -r ".[$i].name // \"Unknown\"" | cut -c1-20)
                rssi=$(echo "$scan_data" | jq -r ".[$i].rssi // -100")
                
                bar_length=$(( (rssi + 100) * 25 / 60 ))
                [ "$bar_length" -lt 0 ] && bar_length=0
                [ "$bar_length" -gt 25 ] && bar_length=25
                
                if [ "$rssi" -ge -50 ] 2>/dev/null; then sig_color="${GREEN}"
                elif [ "$rssi" -ge -70 ] 2>/dev/null; then sig_color="${YELLOW}"
                else sig_color="${RED}"; fi
                
                bar=$(printf "%${bar_length}s" | tr ' ' '#')
                empty=$(printf "%$((25-bar_length))s" | tr ' ' '-')
                
                printf "  ${WHITE}%-20s ${sig_color}%4ddBm %s${GRAY}%s${NC}\n" \
                    "$name" "$rssi" "$bar" "$empty"
                
                i=$((i + 1))
            done
        else
            echo -e "  ${YELLOW}Scanning...${NC}"
        fi
        
        sleep 4
    done
    
    trap - INT
}

bt_ble_scan() {
    print_header "BLE (Bluetooth Low Energy) Scanner"
    loading_animation "Scanning for BLE devices" 5
    
    local scan_data
    scan_data=$(termux-bluetooth-scaninfo 2>/dev/null)
    
    if [ -n "$scan_data" ] && echo "$scan_data" | jq -e '.' &>/dev/null; then
        echo ""
        echo "$scan_data" | jq -r '.[] | "\(.name // "Unknown")|\(.address)|\(.rssi // "N/A")|\(.type // "Unknown")"' 2>/dev/null | \
        while IFS='|' read -r name addr rssi type; do
            echo -e "  ${CYAN}${BULLET}${NC} ${WHITE}${name}${NC}"
            echo -e "    ${GRAY}Address:${NC} ${addr} ${GRAY}| RSSI:${NC} ${rssi}dBm ${GRAY}| Type:${NC} ${type}"
            print_separator
        done
    else
        print_error "BLE scan requires Termux:API with Bluetooth permissions"
    fi
    
    pause_screen
}

bt_send_file() {
    print_header "Bluetooth File Transfer"
    
    get_input "File path to send"
    local file_path="$USER_INPUT"
    
    if [ ! -f "$file_path" ]; then
        print_error "File not found: ${file_path}"
        pause_screen
        return
    fi
    
    local file_size
    file_size=$(du -h "$file_path" 2>/dev/null | awk '{print $1}')
    echo -e "  ${GRAY}File:${NC} ${WHITE}$(basename "$file_path")${NC} (${file_size})"
    echo ""
    
    loading_animation "Opening share dialog" 2
    termux-share -a send "$file_path" 2>/dev/null
    print_success "Share dialog opened - select Bluetooth"
    
    pause_screen
}

# ========================= ADVANCED TOOLS =========================

network_dashboard() {
    print_header "Network Monitor Dashboard"
    echo -e "  ${YELLOW}${WARNING} Press Ctrl+C to exit${NC}"
    
    trap 'echo ""; print_success "Dashboard closed"; return' INT
    
    while true; do
        clear
        echo ""
        echo -e "  ${CYAN}============================================================${NC}"
        echo -e "  ${CYAN}||  ${WHITE}${BOLD}NETWORK MONITOR DASHBOARD${NC}  ${GRAY}$(date +"%Y-%m-%d %H:%M:%S")${NC}"
        echo -e "  ${CYAN}============================================================${NC}"
        
        # WiFi
        local wifi_data ssid rssi speed ip
        wifi_data=$(termux-wifi-connectioninfo 2>/dev/null)
        if [ -n "$wifi_data" ] && echo "$wifi_data" | jq -e '.' &>/dev/null; then
            ssid=$(echo "$wifi_data" | jq -r '.ssid // "N/A"')
            rssi=$(echo "$wifi_data" | jq -r '.rssi // "N/A"')
            speed=$(echo "$wifi_data" | jq -r '.link_speed_mbps // "N/A"')
            ip=$(echo "$wifi_data" | jq -r '.ip // "N/A"')
            echo -e "  ${GREEN}WiFi:${NC} ${WHITE}${ssid}${NC} | ${rssi}dBm | ${speed}Mbps | ${ip}"
        else
            echo -e "  ${RED}WiFi: Disconnected${NC}"
        fi
        
        print_separator
        
        # Traffic stats
        local rx_bytes tx_bytes rx_mb tx_mb
        rx_bytes=$(cat /sys/class/net/wlan0/statistics/rx_bytes 2>/dev/null || echo "0")
        tx_bytes=$(cat /sys/class/net/wlan0/statistics/tx_bytes 2>/dev/null || echo "0")
        rx_mb=$(echo "scale=1; $rx_bytes / 1048576" | bc 2>/dev/null || echo "0")
        tx_mb=$(echo "scale=1; $tx_bytes / 1048576" | bc 2>/dev/null || echo "0")
        echo -e "  ${GREEN}DOWN: ${rx_mb} MB${NC}  |  ${RED}UP: ${tx_mb} MB${NC}"
        
        print_separator
        
        # Connections
        local connections listening
        connections=$(netstat -tn 2>/dev/null | grep -c ESTABLISHED || echo "0")
        listening=$(netstat -tln 2>/dev/null | grep -c LISTEN || echo "0")
        echo -e "  Active: ${GREEN}${connections}${NC} | Listening: ${YELLOW}${listening}${NC}"
        
        print_separator
        
        # Ping tests
        local gateway
        gateway=$(ip route 2>/dev/null | grep default | awk '{print $3}' | head -1)
        if [ -n "$gateway" ]; then
            local gw_result inet_result
            gw_result=$(ping -c 1 -W 2 "$gateway" 2>/dev/null | grep "time=" | awk -F'time=' '{print $2}')
            inet_result=$(ping -c 1 -W 2 8.8.8.8 2>/dev/null | grep "time=" | awk -F'time=' '{print $2}')
            echo -e "  Gateway: ${WHITE}${gateway}${NC} (${GREEN}${gw_result:-timeout}${NC})"
            echo -ne "  Internet: "
            if [ -n "$inet_result" ]; then
                echo -e "${GREEN}${CHECK} ${inet_result}${NC}"
            else
                echo -e "${RED}${CROSS} Down${NC}"
            fi
        fi
        
        print_separator
        
        # Top connections
        echo -e "  ${WHITE}Top Connections:${NC}"
        netstat -tn 2>/dev/null | grep ESTABLISHED | awk '{print $5}' | cut -d: -f1 | \
            sort | uniq -c | sort -rn | head -5 | while read -r cnt target_ip; do
            echo -e "    ${GRAY}${cnt}x${NC} -> ${WHITE}${target_ip}${NC}"
        done
        
        echo -e "  ${CYAN}============================================================${NC}"
        
        sleep 5
    done
    
    trap - INT
}

security_audit() {
    print_header "Network Security Audit"
    
    local score=100
    local issues=0
    local timestamp
    timestamp=$(date +"%Y%m%d_%H%M%S")
    local report_file="$REPORT_DIR/audit_${timestamp}.txt"
    
    loading_animation "Running security tests" 3
    echo ""
    
    # Test 1
    echo -ne "  [1] WiFi Encryption......... "
    local wifi_info
    wifi_info=$(termux-wifi-connectioninfo 2>/dev/null)
    if [ -n "$wifi_info" ]; then
        echo -e "${GREEN}CONNECTED${NC}"
    else
        echo -e "${RED}NOT CONNECTED${NC}"
        score=$((score - 20))
        issues=$((issues + 1))
    fi
    
    # Test 2
    echo -ne "  [2] DNS Security............ "
    local dns
    dns=$(getprop net.dns1 2>/dev/null)
    if echo "$dns" | grep -qE "^(1\.1\.1\.|8\.8\.|9\.9\.|208\.67\.)"; then
        echo -e "${GREEN}PASS (Secure DNS: ${dns})${NC}"
    else
        echo -e "${YELLOW}WARN (Default DNS: ${dns:-unknown})${NC}"
        score=$((score - 5))
        issues=$((issues + 1))
    fi
    
    # Test 3
    echo -ne "  [3] Open Ports.............. "
    local open_ports
    open_ports=$(netstat -tln 2>/dev/null | grep -c LISTEN || echo "0")
    if [ "$open_ports" -le 3 ] 2>/dev/null; then
        echo -e "${GREEN}PASS (${open_ports} ports)${NC}"
    elif [ "$open_ports" -le 10 ] 2>/dev/null; then
        echo -e "${YELLOW}WARN (${open_ports} ports)${NC}"
        score=$((score - 10))
        issues=$((issues + 1))
    else
        echo -e "${RED}FAIL (${open_ports} ports)${NC}"
        score=$((score - 20))
        issues=$((issues + 1))
    fi
    
    # Test 4
    echo -ne "  [4] ARP Spoof Check......... "
    local arp_dupes
    arp_dupes=$(ip neigh show 2>/dev/null | awk '{print $5}' | sort | uniq -d | wc -l)
    if [ "$arp_dupes" -eq 0 ] 2>/dev/null; then
        echo -e "${GREEN}PASS (No duplicates)${NC}"
    else
        echo -e "${RED}FAIL (${arp_dupes} duplicates!)${NC}"
        score=$((score - 25))
        issues=$((issues + 1))
    fi
    
    # Test 5
    echo -ne "  [5] Internet Access......... "
    if ping -c 1 -W 3 8.8.8.8 &>/dev/null; then
        echo -e "${GREEN}PASS${NC}"
    else
        echo -e "${RED}FAIL${NC}"
        score=$((score - 10))
        issues=$((issues + 1))
    fi
    
    # Test 6
    echo -ne "  [6] Gateway Reachable....... "
    local gateway
    gateway=$(ip route 2>/dev/null | grep default | awk '{print $3}' | head -1)
    if [ -n "$gateway" ] && ping -c 1 -W 2 "$gateway" &>/dev/null; then
        echo -e "${GREEN}PASS (${gateway})${NC}"
    else
        echo -e "${RED}FAIL${NC}"
        score=$((score - 15))
        issues=$((issues + 1))
    fi
    
    # Test 7
    echo -ne "  [7] SSL/TLS Support......... "
    if curl -s --max-time 5 https://www.google.com &>/dev/null; then
        echo -e "${GREEN}PASS${NC}"
    else
        echo -e "${RED}FAIL${NC}"
        score=$((score - 10))
        issues=$((issues + 1))
    fi
    
    # Test 8
    echo -ne "  [8] DNS Resolution.......... "
    if nslookup google.com &>/dev/null; then
        echo -e "${GREEN}PASS${NC}"
    else
        echo -e "${RED}FAIL${NC}"
        score=$((score - 10))
        issues=$((issues + 1))
    fi
    
    # Score
    print_separator
    
    local score_color
    if [ "$score" -ge 80 ]; then score_color="${GREEN}"
    elif [ "$score" -ge 60 ]; then score_color="${YELLOW}"
    elif [ "$score" -ge 40 ]; then score_color="${ORANGE}"
    else score_color="${RED}"; fi
    
    local rating
    if [ "$score" -ge 90 ]; then rating="Excellent *****"
    elif [ "$score" -ge 80 ]; then rating="Good ****"
    elif [ "$score" -ge 60 ]; then rating="Fair ***"
    elif [ "$score" -ge 40 ]; then rating="Poor **"
    else rating="Critical *"; fi
    
    echo ""
    echo -e "  ${WHITE}Security Score: ${score_color}${BOLD}${score}/100${NC}"
    echo -e "  ${WHITE}Issues Found:  ${YELLOW}${issues}${NC}"
    echo -e "  ${WHITE}Rating:        ${score_color}${rating}${NC}"
    
    {
        echo "Security Audit Report - $(date)"
        echo "Score: ${score}/100"
        echo "Issues: ${issues}"
        echo "Rating: ${rating}"
    } > "$report_file"
    
    echo ""
    print_success "Report saved: ${report_file}"
    
    pause_screen
}

generate_report() {
    print_header "Generate Network Report"
    
    local timestamp
    timestamp=$(date +"%Y%m%d_%H%M%S")
    local report_file="$REPORT_DIR/report_${timestamp}.txt"
    
    loading_animation "Gathering information" 3
    
    {
        echo "=========================================="
        echo "     NETWORK REPORT - $(date)"
        echo "=========================================="
        echo ""
        
        echo "--- WiFi Connection ---"
        termux-wifi-connectioninfo 2>/dev/null | jq '.' 2>/dev/null
        echo ""
        
        echo "--- Network Interfaces ---"
        ip addr show 2>/dev/null
        echo ""
        
        echo "--- Routing Table ---"
        ip route show 2>/dev/null
        echo ""
        
        echo "--- ARP Table ---"
        ip neigh show 2>/dev/null
        echo ""
        
        echo "--- Active Connections ---"
        netstat -tn 2>/dev/null
        echo ""
        
        echo "--- Nearby WiFi Networks ---"
        termux-wifi-scaninfo 2>/dev/null | jq '.[].ssid' 2>/dev/null
        echo ""
        
        echo "=========================================="
        echo "     END OF REPORT"
        echo "=========================================="
    } > "$report_file"
    
    print_success "Report saved: ${report_file}"
    print_info "View with: cat ${report_file}"
    print_info "Copy to phone: cp ${report_file} /sdcard/"
    
    pause_screen
}

view_logs() {
    print_header "View Logs & Results"
    
    echo -e "  ${CYAN}[1]${NC} WiFi Scan Results"
    echo -e "  ${CYAN}[2]${NC} Bluetooth Scan Results"
    echo -e "  ${CYAN}[3]${NC} Packet Captures"
    echo -e "  ${CYAN}[4]${NC} Security Reports"
    echo -e "  ${CYAN}[5]${NC} Clear All Logs"
    echo ""
    
    get_input "Choice"
    
    echo ""
    
    case $USER_INPUT in
        1)
            echo -e "  ${WHITE}WiFi Results:${NC}"
            ls -lh "$SCAN_RESULTS"/ 2>/dev/null | tail -n +2 | while IFS= read -r l; do
                echo -e "  ${CYAN}${BULLET}${NC} $l"
            done
            [ "$(ls -A "$SCAN_RESULTS" 2>/dev/null)" ] || echo -e "  ${GRAY}(empty)${NC}"
            ;;
        2)
            echo -e "  ${WHITE}Bluetooth Results:${NC}"
            ls -lh "$BT_RESULTS"/ 2>/dev/null | tail -n +2 | while IFS= read -r l; do
                echo -e "  ${BLUE}${BULLET}${NC} $l"
            done
            [ "$(ls -A "$BT_RESULTS" 2>/dev/null)" ] || echo -e "  ${GRAY}(empty)${NC}"
            ;;
        3)
            echo -e "  ${WHITE}Captures:${NC}"
            ls -lh "$CAPTURE_DIR"/ 2>/dev/null | tail -n +2 | while IFS= read -r l; do
                echo -e "  ${YELLOW}${BULLET}${NC} $l"
            done
            [ "$(ls -A "$CAPTURE_DIR" 2>/dev/null)" ] || echo -e "  ${GRAY}(empty)${NC}"
            ;;
        4)
            echo -e "  ${WHITE}Reports:${NC}"
            ls -lh "$REPORT_DIR"/ 2>/dev/null | tail -n +2 | while IFS= read -r l; do
                echo -e "  ${RED}${BULLET}${NC} $l"
            done
            [ "$(ls -A "$REPORT_DIR" 2>/dev/null)" ] || echo -e "  ${GRAY}(empty)${NC}"
            ;;
        5)
            echo -e "  ${RED}${WARNING} This will delete ALL logs!${NC}"
            get_input "Type YES to confirm"
            if [ "$USER_INPUT" = "YES" ]; then
                rm -rf "${SCAN_RESULTS:?}"/* "${BT_RESULTS:?}"/* "${CAPTURE_DIR:?}"/* "${REPORT_DIR:?}"/* "${TEMP_DIR:?}"/* 2>/dev/null
                print_success "All logs cleared"
            else
                print_info "Cancelled"
            fi
            ;;
        *) print_error "Invalid choice" ;;
    esac
    
    pause_screen
}

# ========================= MENUS =========================

wifi_menu() {
    while true; do
        print_banner
        print_header "WiFi Tools Menu"
        
        print_menu_item 1  "Scan WiFi Networks"
        print_menu_item 2  "Connection Info"
        print_menu_item 3  "WiFi Enable/Disable"
        print_menu_item 4  "Signal Monitor (Live)"
        print_menu_item 5  "Network Analyzer"
        print_menu_item 6  "Device Scanner"
        print_menu_item 7  "Port Scanner"
        print_menu_item 8  "Speed Test"
        print_menu_item 9  "Packet Capture (Root)"
        print_menu_item 10 "DNS Tools"
        print_menu_item 11 "MAC Changer (Root)"
        print_menu_item 12 "Saved Passwords (Root)"
        print_menu_item 13 "ARP Spoof Detector"
        print_menu_item 14 "Network Toolkit"
        print_separator
        print_menu_item 0  "Back to Main Menu"
        echo ""
        
        get_input "Select option"
        
        case $USER_INPUT in
            1)  wifi_scan ;;
            2)  wifi_connection_info ;;
            3)  wifi_toggle ;;
            4)  wifi_signal_monitor ;;
            5)  wifi_network_analyzer ;;
            6)  wifi_device_scanner ;;
            7)  wifi_port_scanner ;;
            8)  wifi_speed_test ;;
            9)  wifi_packet_capture ;;
            10) wifi_dns_tools ;;
            11) wifi_mac_changer ;;
            12) wifi_saved_networks ;;
            13) wifi_arp_detector ;;
            14) wifi_network_toolkit ;;
            0)  return ;;
            *)  print_error "Invalid option"; sleep 1 ;;
        esac
    done
}

bluetooth_menu() {
    while true; do
        print_banner
        print_header "Bluetooth Tools Menu"
        
        print_menu_item 1 "Scan Bluetooth Devices"
        print_menu_item 2 "BLE (Low Energy) Scanner"
        print_menu_item 3 "Bluetooth Enable/Disable"
        print_menu_item 4 "Paired Devices"
        print_menu_item 5 "Device Information"
        print_menu_item 6 "Proximity Monitor (Live)"
        print_menu_item 7 "Send File via Bluetooth"
        print_separator
        print_menu_item 0 "Back to Main Menu"
        echo ""
        
        get_input "Select option"
        
        case $USER_INPUT in
            1) bt_scan ;;
            2) bt_ble_scan ;;
            3) bt_toggle ;;
            4) bt_paired_devices ;;
            5) bt_device_info ;;
            6) bt_proximity_monitor ;;
            7) bt_send_file ;;
            0) return ;;
            *) print_error "Invalid option"; sleep 1 ;;
        esac
    done
}

advanced_menu() {
    while true; do
        print_banner
        print_header "Advanced Tools"
        
        print_menu_item 1 "Network Monitor Dashboard"
        print_menu_item 2 "Security Audit"
        print_menu_item 3 "Generate Full Report"
        print_menu_item 4 "View Logs & Results"
        print_menu_item 5 "Install/Update Dependencies"
        print_separator
        print_menu_item 0 "Back to Main Menu"
        echo ""
        
        get_input "Select option"
        
        case $USER_INPUT in
            1) network_dashboard ;;
            2) security_audit ;;
            3) generate_report ;;
            4) view_logs ;;
            5) install_dependencies ;;
            0) return ;;
            *) print_error "Invalid option"; sleep 1 ;;
        esac
    done
}

# ========================= MAIN MENU =========================

main_menu() {
    init_directories
    check_root
    
    while true; do
        print_banner
        
        echo -e "  ${WHITE}${BOLD}MAIN MENU${NC}"
        echo ""
        print_menu_item 1 "WiFi Tools            [14 tools]"
        print_menu_item 2 "Bluetooth Tools       [7 tools]"
        print_menu_item 3 "Advanced Tools        [5 tools]"
        print_separator
        print_menu_item 4 "Quick WiFi Scan"
        print_menu_item 5 "Quick BT Scan"
        print_menu_item 6 "Network Dashboard"
        print_menu_item 7 "Install Dependencies"
        print_separator
        print_menu_item 0 "Exit"
        echo ""
        
        get_input "Select option"
        
        case $USER_INPUT in
            1) wifi_menu ;;
            2) bluetooth_menu ;;
            3) advanced_menu ;;
            4) wifi_scan ;;
            5) bt_scan ;;
            6) network_dashboard ;;
            7) install_dependencies ;;
            0)
                echo ""
                echo -e "  ${CYAN}Thanks for using NetTool! ${GREEN}Goodbye!${NC}"
                echo ""
                exit 0
                ;;
            *)
                print_error "Invalid option. Enter a number 0-7"
                sleep 1
                ;;
        esac
    done
}

# ========================= ENTRY POINT =========================

case "${1:-}" in
    --install|-i)   check_root; init_directories; install_dependencies; exit 0 ;;
    --wifi-scan|-ws) check_root; init_directories; wifi_scan; exit 0 ;;
    --bt-scan|-bs)  check_root; init_directories; bt_scan; exit 0 ;;
    --dashboard|-d) check_root; init_directories; network_dashboard; exit 0 ;;
    --audit|-a)     check_root; init_directories; security_audit; exit 0 ;;
    --help|-h)
        echo ""
        echo -e "  ${CYAN}NetTool v${VERSION}${NC}"
        echo ""
        echo -e "  ${WHITE}Usage:${NC} $0 [option]"
        echo ""
        echo -e "  ${GREEN}--install, -i${NC}      Install dependencies"
        echo -e "  ${GREEN}--wifi-scan, -ws${NC}   Quick WiFi scan"
        echo -e "  ${GREEN}--bt-scan, -bs${NC}     Quick Bluetooth scan"
        echo -e "  ${GREEN}--dashboard, -d${NC}    Network dashboard"
        echo -e "  ${GREEN}--audit, -a${NC}        Security audit"
        echo -e "  ${GREEN}--help, -h${NC}         Show help"
        echo ""
        exit 0
        ;;
    *)
        main_menu
        ;;
esac
