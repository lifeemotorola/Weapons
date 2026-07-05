#!/data/data/com.termux/files/usr/bin/bash

#================================================================
#  ADVANCED RADAR DETECTOR & SCANNER FOR TERMUX
#  Real-time WiFi & Server Detection System
#  File: radar_scanner.sh
#  Usage: bash radar_scanner.sh
#================================================================

# ======================== CONFIGURATION ========================
SCAN_INTERVAL=2
MAX_HISTORY=100
LOG_FILE="$HOME/radar_scan.log"
CSV_FILE="$HOME/radar_results.csv"
PING_TIMEOUT=1
PORT_SCAN_TIMEOUT=1
RADAR_RADIUS=12
COMMON_PORTS=(21 22 23 25 53 80 110 143 443 445 993 995 3306 3389 5432 5900 8080 8443 8888)

# ======================== COLORS ========================
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
MAGENTA='\033[1;35m'
CYAN='\033[1;36m'
WHITE='\033[1;37m'
DIM='\033[2m'
BOLD='\033[1m'
BLINK='\033[5m'
NC='\033[0m'
BG_RED='\033[41m'
BG_GREEN='\033[42m'
BG_BLUE='\033[44m'
BG_BLACK='\033[40m'

# ======================== GLOBAL VARIABLES ========================
declare -A DETECTED_HOSTS
declare -A HOST_NAMES
declare -A HOST_MAC
declare -A HOST_PORTS
declare -A HOST_STATUS
declare -A HOST_FIRST_SEEN
declare -A HOST_LAST_SEEN
declare -A HOST_SIGNAL
declare -A WIFI_NETWORKS
SCAN_COUNT=0
TOTAL_FOUND=0
ACTIVE_HOSTS=0
CURRENT_IP=""
GATEWAY=""
SUBNET=""
INTERFACE=""
START_TIME=""
SCAN_MODE="full"  # full, quick, stealth, deep

# ======================== DEPENDENCY CHECK ========================
check_dependencies() {
    local missing=()
    local deps=("iw" "ip" "ping" "nmap" "arp" "grep" "awk" "sed" "curl" "nc")
    
    echo -e "${CYAN}${BOLD}[*] Checking dependencies...${NC}"
    
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &>/dev/null; then
            missing+=("$dep")
        fi
    done
    
    if [ ${#missing[@]} -gt 0 ]; then
        echo -e "${YELLOW}[!] Missing packages detected. Installing...${NC}"
        pkg update -y 2>/dev/null
        for pkg_name in "${missing[@]}"; do
            case "$pkg_name" in
                "iw") pkg install -y iw 2>/dev/null || true ;;
                "ip") pkg install -y iproute2 2>/dev/null || true ;;
                "nmap") pkg install -y nmap 2>/dev/null || true ;;
                "arp") pkg install -y net-tools 2>/dev/null || true ;;
                "curl") pkg install -y curl 2>/dev/null || true ;;
                "nc") pkg install -y nmap-ncat 2>/dev/null || true ;;
                *) pkg install -y "$pkg_name" 2>/dev/null || true ;;
            esac
        done
        # Install termux-tools for termux-wifi-scaninfo
        pkg install -y termux-tools termux-api 2>/dev/null || true
    fi
    
    echo -e "${GREEN}[✓] Dependency check complete${NC}"
}

# ======================== NETWORK INFO ========================
get_network_info() {
    # Get primary interface
    INTERFACE=$(ip route 2>/dev/null | grep default | awk '{print $5}' | head -1)
    [ -z "$INTERFACE" ] && INTERFACE="wlan0"
    
    # Get current IP
    CURRENT_IP=$(ip addr show "$INTERFACE" 2>/dev/null | grep 'inet ' | awk '{print $2}' | cut -d'/' -f1 | head -1)
    [ -z "$CURRENT_IP" ] && CURRENT_IP=$(ifconfig "$INTERFACE" 2>/dev/null | grep 'inet ' | awk '{print $2}')
    
    # Get gateway
    GATEWAY=$(ip route 2>/dev/null | grep default | awk '{print $3}' | head -1)
    
    # Get subnet
    if [ -n "$CURRENT_IP" ]; then
        SUBNET=$(echo "$CURRENT_IP" | cut -d'.' -f1-3)
    fi
    
    # Get MAC address
    LOCAL_MAC=$(ip link show "$INTERFACE" 2>/dev/null | grep ether | awk '{print $2}')
}

# ======================== WIFI SCANNER ========================
scan_wifi_networks() {
    local wifi_data=""
    
    # Method 1: termux-wifi-scaninfo (requires Termux:API)
    if command -v termux-wifi-scaninfo &>/dev/null; then
        wifi_data=$(termux-wifi-scaninfo 2>/dev/null)
        if [ -n "$wifi_data" ] && echo "$wifi_data" | grep -q "ssid"; then
            echo "$wifi_data" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    if isinstance(data, list):
        for net in data:
            ssid = net.get('ssid', 'Hidden')
            bssid = net.get('bssid', 'Unknown')
            level = net.get('level', -100)
            freq = net.get('frequency', 0)
            caps = net.get('capabilities', '')
            security = 'OPEN'
            if 'WPA2' in caps: security = 'WPA2'
            elif 'WPA' in caps: security = 'WPA'
            elif 'WEP' in caps: security = 'WEP'
            channel = 0
            if 2412 <= freq <= 2484:
                channel = (freq - 2407) // 5
            elif 5170 <= freq <= 5825:
                channel = (freq - 5000) // 5
            print(f'{ssid}|{bssid}|{level}|{freq}|{channel}|{security}')
except:
    pass
" 2>/dev/null
            return
        fi
    fi
    
    # Method 2: iw scan (requires root)
    if command -v iw &>/dev/null; then
        iw dev "$INTERFACE" scan 2>/dev/null | awk '
        BEGIN { ssid=""; bssid=""; signal=-100; freq=0; security="OPEN" }
        /^BSS/ { 
            if (bssid != "") {
                chan = 0
                if (freq >= 2412 && freq <= 2484) chan = (freq - 2407) / 5
                else if (freq >= 5170 && freq <= 5825) chan = (freq - 5000) / 5
                printf "%s|%s|%d|%d|%d|%s\n", ssid, bssid, signal, freq, chan, security
            }
            bssid=$2; gsub(/\(.*/, "", bssid); ssid="Hidden"; signal=-100; freq=0; security="OPEN"
        }
        /SSID:/ { ssid=$2 }
        /signal:/ { signal=$2 }
        /freq:/ { freq=$2 }
        /WPA/ { security="WPA2" }
        /WEP/ { security="WEP" }
        END {
            if (bssid != "") {
                chan = 0
                if (freq >= 2412 && freq <= 2484) chan = (freq - 2407) / 5
                else if (freq >= 5170 && freq <= 5825) chan = (freq - 5000) / 5
                printf "%s|%s|%d|%d|%d|%s\n", ssid, bssid, signal, freq, chan, security
            }
        }' 2>/dev/null
        return
    fi
    
    # Method 3: nmcli (if available)
    if command -v nmcli &>/dev/null; then
        nmcli -t -f SSID,BSSID,SIGNAL,FREQ,CHAN,SECURITY dev wifi list 2>/dev/null | \
        sed 's/\\:/COLONPLACEHOLDER/g' | \
        awk -F':' '{gsub(/COLONPLACEHOLDER/, ":", $0); print $1"|"$2"|"$3"|"$4"|"$5"|"$6}' 2>/dev/null
        return
    fi
}

# ======================== HOST DISCOVERY ========================
discover_hosts_ping() {
    local subnet="$1"
    local found=0
    
    for i in $(seq 1 254); do
        local target="${subnet}.${i}"
        [ "$target" = "$CURRENT_IP" ] && continue
        
        ping -c 1 -W "$PING_TIMEOUT" "$target" &>/dev/null &
        
        # Limit parallel pings
        if (( i % 50 == 0 )); then
            wait
        fi
    done
    wait
    
    # Collect results from ARP cache
    if command -v arp &>/dev/null; then
        arp -an 2>/dev/null | grep -v incomplete | while read -r line; do
            local ip=$(echo "$line" | grep -oP '\d+\.\d+\.\d+\.\d+')
            local mac=$(echo "$line" | grep -oP '([0-9a-f]{2}:){5}[0-9a-f]{2}')
            if [ -n "$ip" ] && [ -n "$mac" ]; then
                echo "${ip}|${mac}"
            fi
        done
    fi
    
    # Also check ip neigh
    ip neigh 2>/dev/null | grep -v FAILED | while read -r line; do
        local ip=$(echo "$line" | awk '{print $1}')
        local mac=$(echo "$line" | grep -oP '([0-9a-f]{2}:){5}[0-9a-f]{2}')
        local state=$(echo "$line" | awk '{print $NF}')
        if [ -n "$ip" ] && [ "$state" != "FAILED" ]; then
            [ -z "$mac" ] && mac="unknown"
            echo "${ip}|${mac}"
        fi
    done
}

discover_hosts_nmap() {
    local subnet="$1"
    
    if command -v nmap &>/dev/null; then
        nmap -sn -T4 "${subnet}.0/24" 2>/dev/null | awk '
        /Nmap scan report/ { ip=$5; gsub(/[()]/, "", ip) }
        /MAC Address/ { mac=$3; vendor=$4" "$5" "$6; gsub(/[()]/, "", vendor); print ip"|"mac"|"vendor }
        '
    fi
}

# ======================== PORT SCANNER ========================
scan_ports() {
    local target="$1"
    local open_ports=""
    
    for port in "${COMMON_PORTS[@]}"; do
        (echo >/dev/tcp/"$target"/"$port") 2>/dev/null && {
            open_ports+="${port},"
        } &
    done
    wait
    
    # Remove trailing comma
    echo "${open_ports%,}"
}

scan_ports_nc() {
    local target="$1"
    local open_ports=""
    
    if command -v nc &>/dev/null; then
        for port in "${COMMON_PORTS[@]}"; do
            nc -z -w "$PORT_SCAN_TIMEOUT" "$target" "$port" 2>/dev/null && {
                open_ports+="${port},"
            } &
        done
        wait
    fi
    
    echo "${open_ports%,}"
}

deep_port_scan() {
    local target="$1"
    
    if command -v nmap &>/dev/null; then
        nmap -sV -T4 --top-ports 100 "$target" 2>/dev/null | grep "open" | while read -r line; do
            local port=$(echo "$line" | awk '{print $1}')
            local service=$(echo "$line" | awk '{print $3}')
            local version=$(echo "$line" | awk '{for(i=4;i<=NF;i++) printf "%s ", $i}')
            echo "${port}|${service}|${version}"
        done
    fi
}

# ======================== SERVICE IDENTIFIER ========================
identify_service() {
    local port="$1"
    case "$port" in
        21) echo "FTP" ;;
        22) echo "SSH" ;;
        23) echo "Telnet" ;;
        25) echo "SMTP" ;;
        53) echo "DNS" ;;
        80) echo "HTTP" ;;
        110) echo "POP3" ;;
        143) echo "IMAP" ;;
        443) echo "HTTPS" ;;
        445) echo "SMB" ;;
        993) echo "IMAPS" ;;
        995) echo "POP3S" ;;
        3306) echo "MySQL" ;;
        3389) echo "RDP" ;;
        5432) echo "PostgreSQL" ;;
        5900) echo "VNC" ;;
        8080) echo "HTTP-Proxy" ;;
        8443) echo "HTTPS-Alt" ;;
        8888) echo "HTTP-Alt" ;;
        *) echo "Unknown" ;;
    esac
}

get_mac_vendor() {
    local mac="$1"
    local prefix=$(echo "$mac" | cut -d':' -f1-3 | tr '[:lower:]' '[:upper:]' | tr -d ':')
    
    case "${prefix:0:6}" in
        "F8E43B"|"3C7D0A"|"00E04C") echo "Apple" ;;
        "B4F1DA"|"FCF136"|"9C2EA1") echo "Samsung" ;;
        "DC85DE"|"5C3C27"|"7085C6") echo "AzureWave" ;;
        "00155D") echo "Microsoft" ;;
        "001A79"|"F0BF97") echo "Google" ;;
        "B827EB"|"DC2632"|"E45F01") echo "Raspberry Pi" ;;
        "000C29"|"005056") echo "VMware" ;;
        "080027") echo "VirtualBox" ;;
        "001E65"|"3C970E") echo "Intel" ;;
        "000347"|"F81A67") echo "Intel" ;;
        "2C549D"|"CC2DB7") echo "Xiaomi" ;;
        "AC233F") echo "Shenzhen" ;;
        "74DA88"|"E0ACCB") echo "TP-Link" ;;
        "C8D719"|"A45E60") echo "Cisco" ;;
        "B0BE76"|"0018E7") echo "Cisco" ;;
        "001DD8") echo "Microsoft" ;;
        "48E9F1"|"7CD566") echo "Nintendo" ;;
        *) echo "Unknown" ;;
    esac
}

signal_strength_to_bars() {
    local signal="$1"
    
    if [ "$signal" -ge -30 ]; then
        echo "█████ Excellent"
    elif [ "$signal" -ge -50 ]; then
        echo "████░ Very Good"
    elif [ "$signal" -ge -60 ]; then
        echo "███░░ Good"
    elif [ "$signal" -ge -70 ]; then
        echo "██░░░ Fair"
    elif [ "$signal" -ge -80 ]; then
        echo "█░░░░ Weak"
    else
        echo "░░░░░ Very Weak"
    fi
}

# ======================== DISPLAY FUNCTIONS ========================
clear_screen() {
    printf '\033[2J\033[H'
}

move_cursor() {
    printf '\033[%d;%dH' "$1" "$2"
}

draw_box() {
    local x=$1 y=$2 w=$3 h=$4 title="$5" color="$6"
    
    move_cursor $x $y
    echo -ne "${color}╔"
    printf '═%.0s' $(seq 1 $((w-2)))
    echo -ne "╗${NC}"
    
    if [ -n "$title" ]; then
        move_cursor $x $(( y + (w - ${#title} - 2) / 2 ))
        echo -ne "${color}╡ ${WHITE}${BOLD}${title}${NC} ${color}╞${NC}"
    fi
    
    for i in $(seq 1 $((h-2))); do
        move_cursor $((x+i)) $y
        echo -ne "${color}║${NC}"
        move_cursor $((x+i)) $((y+w-1))
        echo -ne "${color}║${NC}"
    done
    
    move_cursor $((x+h-1)) $y
    echo -ne "${color}╚"
    printf '═%.0s' $(seq 1 $((w-2)))
    echo -ne "╝${NC}"
}

# ======================== RADAR ANIMATION ========================
draw_radar() {
    local center_row=$1
    local center_col=$2
    local radius=$RADAR_RADIUS
    local angle=$3
    local active_count=$4
    
    # Draw radar circle
    for ((a = 0; a < 360; a += 10)); do
        local rad=$(echo "scale=4; $a * 3.14159265 / 180" | bc 2>/dev/null || echo "0")
        local px=$(echo "scale=0; $center_col + $radius * 2 * c($rad)" | bc -l 2>/dev/null || echo "$center_col")
        local py=$(echo "scale=0; $center_row + $radius * s($rad)" | bc -l 2>/dev/null || echo "$center_row")
        
        px=${px%.*}
        py=${py%.*}
        
        if [ "$px" -gt 0 ] && [ "$py" -gt 0 ] 2>/dev/null; then
            move_cursor "$py" "$px"
            echo -ne "${GREEN}·${NC}"
        fi
    done
    
    # Draw sweep line
    local sweep_rad=$(echo "scale=4; $angle * 3.14159265 / 180" | bc 2>/dev/null || echo "0")
    for ((r = 1; r <= radius; r++)); do
        local sx=$(echo "scale=0; $center_col + $r * 2 * c($sweep_rad)" | bc -l 2>/dev/null || echo "$center_col")
        local sy=$(echo "scale=0; $center_row + $r * s($sweep_rad)" | bc -l 2>/dev/null || echo "$center_row")
        
        sx=${sx%.*}
        sy=${sy%.*}
        
        if [ "$sx" -gt 0 ] && [ "$sy" -gt 0 ] 2>/dev/null; then
            move_cursor "$sy" "$sx"
            if [ $r -le $((radius/3)) ]; then
                echo -ne "${GREEN}${BOLD}█${NC}"
            elif [ $r -le $((2*radius/3)) ]; then
                echo -ne "${GREEN}▓${NC}"
            else
                echo -ne "${GREEN}░${NC}"
            fi
        fi
    done
    
    # Draw cross lines
    for ((r = -radius; r <= radius; r++)); do
        local hx=$((center_col + r * 2))
        if [ "$hx" -gt 0 ] 2>/dev/null; then
            move_cursor "$center_row" "$hx"
            echo -ne "${DIM}${GREEN}─${NC}"
        fi
    done
    for ((r = -radius; r <= radius; r++)); do
        local vy=$((center_row + r))
        if [ "$vy" -gt 0 ] 2>/dev/null; then
            move_cursor "$vy" "$center_col"
            echo -ne "${DIM}${GREEN}│${NC}"
        fi
    done
    
    # Draw center
    move_cursor "$center_row" "$center_col"
    echo -ne "${GREEN}${BOLD}⊕${NC}"
    
    # Draw rings
    for ring in $(echo "$radius/3" | bc) $(echo "2*$radius/3" | bc); do
        for ((a = 0; a < 360; a += 30)); do
            local rrad=$(echo "scale=4; $a * 3.14159265 / 180" | bc 2>/dev/null || echo "0")
            local rx=$(echo "scale=0; $center_col + $ring * 2 * c($rrad)" | bc -l 2>/dev/null || echo "$center_col")
            local ry=$(echo "scale=0; $center_row + $ring * s($rrad)" | bc -l 2>/dev/null || echo "$center_row")
            rx=${rx%.*}
            ry=${ry%.*}
            if [ "$rx" -gt 0 ] && [ "$ry" -gt 0 ] 2>/dev/null; then
                move_cursor "$ry" "$rx"
                echo -ne "${DIM}${GREEN}·${NC}"
            fi
        done
    done
    
    # Plot detected devices on radar
    local device_num=0
    for host in "${!DETECTED_HOSTS[@]}"; do
        device_num=$((device_num + 1))
        local dev_angle=$(( (device_num * 47 + ${host##*.} * 13) % 360 ))
        local dev_dist=$(( (${host##*.} % radius) + 2 ))
        
        local dev_rad=$(echo "scale=4; $dev_angle * 3.14159265 / 180" | bc 2>/dev/null || echo "0")
        local dx=$(echo "scale=0; $center_col + $dev_dist * 2 * c($dev_rad)" | bc -l 2>/dev/null || echo "$center_col")
        local dy=$(echo "scale=0; $center_row + $dev_dist * s($dev_rad)" | bc -l 2>/dev/null || echo "$center_row")
        dx=${dx%.*}
        dy=${dy%.*}
        
        if [ "$dx" -gt 0 ] && [ "$dy" -gt 0 ] 2>/dev/null; then
            move_cursor "$dy" "$dx"
            if [ "${HOST_STATUS[$host]}" = "up" ]; then
                echo -ne "${RED}${BOLD}◆${NC}"
            else
                echo -ne "${YELLOW}${DIM}◇${NC}"
            fi
        fi
    done
}

# ======================== SIMPLE RADAR (FALLBACK) ========================
draw_simple_radar() {
    local row=$1
    local col=$2
    local frame=$3
    local count=$4
    
    local frames=(
        "    ╭───────╮    "
        "  ╭─┤ SCAN  ├─╮  "
        "╭─┤ ◉ RADAR ◉ ├─╮"
        "│  ╰─┤     ├─╯  │"
        "╰────┤ $count ├────╯"
    )
    
    local spinner=('◐' '◓' '◑' '◒')
    local spin_char="${spinner[$((frame % 4))]}"
    
    move_cursor $row $col
    echo -ne "${GREEN}${BOLD}  ┌──────────────┐${NC}"
    move_cursor $((row+1)) $col
    echo -ne "${GREEN}${BOLD}  │ ${spin_char} SCANNING ${spin_char} │${NC}"
    move_cursor $((row+2)) $col
    echo -ne "${GREEN}${BOLD}  │  ${CYAN}Hosts: $(printf '%3d' $count)${GREEN}   │${NC}"
    move_cursor $((row+3)) $col
    echo -ne "${GREEN}${BOLD}  └──────────────┘${NC}"
}

# ======================== MAIN DISPLAY ========================
display_header() {
    local cols=$(tput cols 2>/dev/null || echo 80)
    
    echo -ne "${GREEN}${BOLD}"
    cat << 'BANNER'
  ██████╗  █████╗ ██████╗  █████╗ ██████╗ 
  ██╔══██╗██╔══██╗██╔══██╗██╔══██╗██╔══██╗
  ██████╔╝███████║██║  ██║███████║██████╔╝
  ██╔══██╗██╔══██║██║  ██║██╔══██║██╔══██╗
  ██║  ██║██║  ██║██████╔╝██║  ██║██║  ██║
  ╚═╝  ╚═╝╚═╝  ╚═╝╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝
BANNER
    echo -ne "${NC}"
    echo -e "${CYAN}${BOLD}  ══════════════════════════════════════════${NC}"
    echo -e "${WHITE}${BOLD}  Advanced Network Radar Scanner v3.0${NC}"
    echo -e "${DIM}  Real-time WiFi & Server Detection System${NC}"
    echo -e "${CYAN}${BOLD}  ══════════════════════════════════════════${NC}"
}

display_network_info() {
    echo ""
    echo -e "${BLUE}${BOLD}╔══════════════════ NETWORK INFO ══════════════════╗${NC}"
    echo -e "${BLUE}║${NC} ${WHITE}Interface  :${NC} ${CYAN}${INTERFACE:-N/A}${NC}"
    echo -e "${BLUE}║${NC} ${WHITE}Local IP   :${NC} ${CYAN}${CURRENT_IP:-N/A}${NC}"
    echo -e "${BLUE}║${NC} ${WHITE}Gateway    :${NC} ${CYAN}${GATEWAY:-N/A}${NC}"
    echo -e "${BLUE}║${NC} ${WHITE}Subnet     :${NC} ${CYAN}${SUBNET:-N/A}.0/24${NC}"
    echo -e "${BLUE}║${NC} ${WHITE}MAC Address:${NC} ${CYAN}${LOCAL_MAC:-N/A}${NC}"
    echo -e "${BLUE}║${NC} ${WHITE}Scan Mode  :${NC} ${YELLOW}${SCAN_MODE^^}${NC}"
    echo -e "${BLUE}║${NC} ${WHITE}Scan Count :${NC} ${GREEN}${SCAN_COUNT}${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════════════╝${NC}"
}

display_wifi_results() {
    local wifi_results="$1"
    
    if [ -z "$wifi_results" ]; then
        return
    fi
    
    echo ""
    echo -e "${MAGENTA}${BOLD}╔══════════════════ WiFi NETWORKS ══════════════════════════════════════════════════╗${NC}"
    echo -e "${MAGENTA}║${NC} ${BOLD}$(printf '%-25s' 'SSID') $(printf '%-19s' 'BSSID') $(printf '%-6s' 'dBm') $(printf '%-5s' 'CH') $(printf '%-8s' 'SEC') %-15s${NC} ${MAGENTA}║${NC}" "SIGNAL"
    echo -e "${MAGENTA}╠══════════════════════════════════════════════════════════════════════════════════════╣${NC}"
    
    local count=0
    while IFS='|' read -r ssid bssid level freq channel security; do
        [ -z "$ssid" ] && continue
        count=$((count + 1))
        [ $count -gt 20 ] && break
        
        # Color based on signal strength
        local sig_color="${RED}"
        level=${level:-"-100"}
        if [ "$level" -ge -50 ] 2>/dev/null; then
            sig_color="${GREEN}"
        elif [ "$level" -ge -70 ] 2>/dev/null; then
            sig_color="${YELLOW}"
        fi
        
        local bars=$(signal_strength_to_bars "$level" 2>/dev/null || echo "░░░░░")
        
        # Security color
        local sec_color="${GREEN}"
        case "$security" in
            *WPA2*) sec_color="${GREEN}" ;;
            *WPA*) sec_color="${YELLOW}" ;;
            *WEP*) sec_color="${RED}" ;;
            *OPEN*) sec_color="${RED}${BLINK}" ;;
        esac
        
        ssid="${ssid:0:24}"
        
        echo -e "${MAGENTA}║${NC} ${WHITE}$(printf '%-25s' "$ssid")${NC} ${DIM}$(printf '%-19s' "$bssid")${NC} ${sig_color}$(printf '%-6s' "${level}")${NC} $(printf '%-5s' "${channel}") ${sec_color}$(printf '%-8s' "$security")${NC} ${sig_color}${bars}${NC} ${MAGENTA}║${NC}"
        
    done <<< "$wifi_results"
    
    echo -e "${MAGENTA}╠══════════════════════════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${MAGENTA}║${NC} ${WHITE}Total WiFi Networks Found: ${GREEN}${BOLD}${count}${NC}                                                      ${MAGENTA}║${NC}"
    echo -e "${MAGENTA}╚══════════════════════════════════════════════════════════════════════════════════════╝${NC}"
}

display_hosts() {
    echo ""
    echo -e "${RED}${BOLD}╔══════════════════ DETECTED HOSTS ═══════════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}║${NC} ${BOLD}$(printf '%-4s' '#') $(printf '%-17s' 'IP ADDRESS') $(printf '%-19s' 'MAC ADDRESS') $(printf '%-10s' 'VENDOR') $(printf '%-8s' 'STATUS') $(printf '%-25s' 'OPEN PORTS')${NC} ${RED}║${NC}"
    echo -e "${RED}╠══════════════════════════════════════════════════════════════════════════════════════════════╣${NC}"
    
    local num=0
    ACTIVE_HOSTS=0
    
    # Sort hosts by IP
    local sorted_hosts=($(echo "${!DETECTED_HOSTS[@]}" | tr ' ' '\n' | sort -t. -k4 -n))
    
    for host in "${sorted_hosts[@]}"; do
        num=$((num + 1))
        local mac="${HOST_MAC[$host]:-unknown}"
        local vendor=$(get_mac_vendor "$mac")
        local status="${HOST_STATUS[$host]:-unknown}"
        local ports="${HOST_PORTS[$host]:-none}"
        
        local status_color="${RED}"
        local status_icon="✗"
        if [ "$status" = "up" ]; then
            status_color="${GREEN}"
            status_icon="✓"
            ACTIVE_HOSTS=$((ACTIVE_HOSTS + 1))
        fi
        
        # Format ports display
        local ports_display="none"
        if [ -n "$ports" ] && [ "$ports" != "none" ] && [ "$ports" != "" ]; then
            local port_list=""
            IFS=',' read -ra PORT_ARR <<< "$ports"
            for p in "${PORT_ARR[@]}"; do
                local svc=$(identify_service "$p")
                port_list+="${p}(${svc}),"
            done
            ports_display="${port_list%,}"
        fi
        ports_display="${ports_display:0:24}"
        
        # Highlight gateway
        local ip_color="${CYAN}"
        if [ "$host" = "$GATEWAY" ]; then
            ip_color="${YELLOW}${BOLD}"
            vendor="Gateway"
        fi
        
        echo -e "${RED}║${NC} $(printf '%-4s' "$num") ${ip_color}$(printf '%-17s' "$host")${NC} ${DIM}$(printf '%-19s' "$mac")${NC} $(printf '%-10s' "$vendor") ${status_color}$(printf '%-3s' "$status_icon") $(printf '%-4s' "$status")${NC} ${WHITE}$(printf '%-25s' "$ports_display")${NC} ${RED}║${NC}"
        
    done
    
    if [ $num -eq 0 ]; then
        echo -e "${RED}║${NC}   ${DIM}No hosts detected yet... Scanning...${NC}                                                      ${RED}║${NC}"
    fi
    
    echo -e "${RED}╠══════════════════════════════════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${RED}║${NC} ${WHITE}Active: ${GREEN}${BOLD}${ACTIVE_HOSTS}${NC} ${WHITE}| Total: ${CYAN}${BOLD}${num}${NC} ${WHITE}| Scan #${SCAN_COUNT} | Mode: ${YELLOW}${SCAN_MODE}${NC}                                       ${RED}║${NC}"
    echo -e "${RED}╚══════════════════════════════════════════════════════════════════════════════════════════════╝${NC}"
    
    TOTAL_FOUND=$num
}

display_services_summary() {
    echo ""
    echo -e "${YELLOW}${BOLD}╔══════════════════ SERVICES DETECTED ══════════════════╗${NC}"
    
    local service_counts=()
    declare -A svc_count
    
    for host in "${!HOST_PORTS[@]}"; do
        local ports="${HOST_PORTS[$host]}"
        [ -z "$ports" ] || [ "$ports" = "none" ] && continue
        IFS=',' read -ra PORT_ARR <<< "$ports"
        for p in "${PORT_ARR[@]}"; do
            local svc=$(identify_service "$p")
            svc_count[$svc]=$(( ${svc_count[$svc]:-0} + 1 ))
        done
    done
    
    if [ ${#svc_count[@]} -gt 0 ]; then
        for svc in "${!svc_count[@]}"; do
            local cnt=${svc_count[$svc]}
            local bar=""
            for ((b=0; b<cnt && b<20; b++)); do
                bar+="█"
            done
            echo -e "${YELLOW}║${NC} $(printf '%-12s' "$svc") ${GREEN}${bar}${NC} ${WHITE}(${cnt})${NC}"
        done
    else
        echo -e "${YELLOW}║${NC} ${DIM}No services detected yet...${NC}"
    fi
    
    echo -e "${YELLOW}╚════════════════════════════════════════════════════════╝${NC}"
}

display_live_activity() {
    local timestamp=$(date '+%H:%M:%S')
    echo ""
    echo -e "${CYAN}${BOLD}╔══════════════════ LIVE ACTIVITY LOG ══════════════════╗${NC}"
    
    # Show last 5 activities
    if [ -f "$LOG_FILE" ]; then
        tail -5 "$LOG_FILE" 2>/dev/null | while read -r line; do
            echo -e "${CYAN}║${NC} ${DIM}${line}${NC}"
        done
    fi
    
    echo -e "${CYAN}╚════════════════════════════════════════════════════════╝${NC}"
}

display_footer() {
    local uptime_secs=$(( $(date +%s) - ${START_TIME:-$(date +%s)} ))
    local uptime_min=$((uptime_secs / 60))
    local uptime_sec=$((uptime_secs % 60))
    
    echo ""
    echo -e "${DIM}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${WHITE}${BOLD} [Q]${NC}Quit  ${WHITE}${BOLD}[F]${NC}Full  ${WHITE}${BOLD}[K]${NC}Quick  ${WHITE}${BOLD}[S]${NC}Stealth  ${WHITE}${BOLD}[D]${NC}Deep  ${WHITE}${BOLD}[E]${NC}Export  ${WHITE}${BOLD}[R]${NC}Reset"
    echo -e "${DIM} Runtime: ${uptime_min}m ${uptime_sec}s | Log: ${LOG_FILE}${NC}"
    echo -e "${DIM}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# ======================== LOGGING ========================
log_event() {
    local message="$1"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[${timestamp}] ${message}" >> "$LOG_FILE"
}

export_results() {
    local timestamp=$(date '+%Y%m%d_%H%M%S')
    local export_file="$HOME/radar_export_${timestamp}.csv"
    
    echo "IP,MAC,Vendor,Status,Ports,First_Seen,Last_Seen" > "$export_file"
    
    for host in "${!DETECTED_HOSTS[@]}"; do
        local mac="${HOST_MAC[$host]:-unknown}"
        local vendor=$(get_mac_vendor "$mac")
        local status="${HOST_STATUS[$host]:-unknown}"
        local ports="${HOST_PORTS[$host]:-none}"
        local first="${HOST_FIRST_SEEN[$host]:-N/A}"
        local last="${HOST_LAST_SEEN[$host]:-N/A}"
        
        echo "${host},${mac},${vendor},${status},${ports},${first},${last}" >> "$export_file"
    done
    
    # Export WiFi data
    local wifi_export="$HOME/radar_wifi_${timestamp}.csv"
    echo "SSID,BSSID,Signal_dBm,Frequency,Channel,Security" > "$wifi_export"
    
    local wifi_data=$(scan_wifi_networks 2>/dev/null)
    if [ -n "$wifi_data" ]; then
        while IFS='|' read -r ssid bssid level freq channel security; do
            echo "${ssid},${bssid},${level},${freq},${channel},${security}" >> "$wifi_export"
        done <<< "$wifi_data"
    fi
    
    log_event "Results exported to ${export_file} and ${wifi_export}"
    echo -e "${GREEN}[✓] Results exported to:${NC}"
    echo -e "    ${CYAN}${export_file}${NC}"
    echo -e "    ${CYAN}${wifi_export}${NC}"
}

# ======================== SCAN FUNCTIONS ========================
run_scan_cycle() {
    local mode="$1"
    SCAN_COUNT=$((SCAN_COUNT + 1))
    local timestamp=$(date '+%H:%M:%S')
    
    log_event "Scan #${SCAN_COUNT} started (mode: ${mode})"
    
    if [ -z "$SUBNET" ]; then
        get_network_info
    fi
    
    [ -z "$SUBNET" ] && return
    
    # Host discovery
    case "$mode" in
        "quick")
            # Quick ping sweep
            local ping_results=$(discover_hosts_ping "$SUBNET" 2>/dev/null)
            ;;
        "stealth")
            # Slower, single host at a time
            for i in $(seq 1 254); do
                local target="${SUBNET}.${i}"
                [ "$target" = "$CURRENT_IP" ] && continue
                if ping -c 1 -W 1 "$target" &>/dev/null; then
                    local mac=$(arp -an "$target" 2>/dev/null | grep -oP '([0-9a-f]{2}:){5}[0-9a-f]{2}' || echo "unknown")
                    process_host "$target" "$mac" ""
                fi
                sleep 0.1
            done
            return
            ;;
        "deep")
            # Full nmap scan
            local nmap_results=$(discover_hosts_nmap "$SUBNET" 2>/dev/null)
            if [ -n "$nmap_results" ]; then
                while IFS='|' read -r ip mac vendor; do
                    [ -z "$ip" ] && continue
                    process_host "$ip" "$mac" "$vendor"
                    
                    # Deep port scan
                    local deep_ports=$(scan_ports "$ip" 2>/dev/null)
                    if [ -n "$deep_ports" ]; then
                        HOST_PORTS[$ip]="$deep_ports"
                    fi
                done <<< "$nmap_results"
            fi
            local ping_results=$(discover_hosts_ping "$SUBNET" 2>/dev/null)
            ;;
        *)
            # Full scan
            local ping_results=$(discover_hosts_ping "$SUBNET" 2>/dev/null)
            ;;
    esac
    
    # Process ping results
    if [ -n "$ping_results" ]; then
        while IFS='|' read -r ip mac; do
            [ -z "$ip" ] && continue
            process_host "$ip" "$mac" ""
        done <<< "$ping_results"
    fi
    
    # Also check ARP table directly
    if command -v arp &>/dev/null; then
        arp -an 2>/dev/null | while IFS= read -r line; do
            local ip=$(echo "$line" | grep -oP '\d+\.\d+\.\d+\.\d+')
            local mac=$(echo "$line" | grep -oP '([0-9a-f]{2}:){5}[0-9a-f]{2}')
            [ -z "$ip" ] && continue
            [[ "$ip" == "$SUBNET"* ]] || continue
            process_host "$ip" "${mac:-unknown}" ""
        done
    fi
    
    # ip neigh
    ip neigh 2>/dev/null | grep -v FAILED | while IFS= read -r line; do
        local ip=$(echo "$line" | awk '{print $1}')
        local mac=$(echo "$line" | grep -oP '([0-9a-f]{2}:){5}[0-9a-f]{2}')
        local state=$(echo "$line" | awk '{print $NF}')
        [ -z "$ip" ] && continue
        [[ "$ip" == *":"* ]] && continue  # skip IPv6
        [ "$state" = "FAILED" ] && continue
        process_host "$ip" "${mac:-unknown}" ""
    done
    
    # Port scan active hosts (limited for speed)
    if [ "$mode" != "quick" ]; then
        local scan_limit=10
        local scanned=0
        for host in "${!DETECTED_HOSTS[@]}"; do
            [ $scanned -ge $scan_limit ] && break
            if [ "${HOST_STATUS[$host]}" = "up" ]; then
                local ports=$(scan_ports "$host" 2>/dev/null)
                if [ -n "$ports" ]; then
                    HOST_PORTS[$host]="$ports"
                    log_event "Host ${host} - Open ports: ${ports}"
                fi
                scanned=$((scanned + 1))
            fi
        done
    fi
    
    # Check gateway specifically
    if [ -n "$GATEWAY" ]; then
        if ping -c 1 -W 1 "$GATEWAY" &>/dev/null; then
            local gw_mac=$(arp -an "$GATEWAY" 2>/dev/null | grep -oP '([0-9a-f]{2}:){5}[0-9a-f]{2}' || echo "unknown")
            process_host "$GATEWAY" "$gw_mac" "Gateway"
        fi
    fi
    
    log_event "Scan #${SCAN_COUNT} complete - Active: ${ACTIVE_HOSTS}, Total: ${TOTAL_FOUND}"
}

process_host() {
    local ip="$1"
    local mac="$2"
    local vendor="$3"
    local timestamp=$(date '+%H:%M:%S')
    
    [ -z "$ip" ] && return
    [ "$ip" = "$CURRENT_IP" ] && return
    
    if [ -z "${DETECTED_HOSTS[$ip]}" ]; then
        # New host
        DETECTED_HOSTS[$ip]=1
        HOST_FIRST_SEEN[$ip]="$timestamp"
        log_event "[NEW] Host discovered: ${ip} (MAC: ${mac})"
    fi
    
    HOST_MAC[$ip]="${mac:-unknown}"
    HOST_STATUS[$ip]="up"
    HOST_LAST_SEEN[$ip]="$timestamp"
    
    if [ -n "$vendor" ]; then
        HOST_NAMES[$ip]="$vendor"
    fi
}

# ======================== INTERACTIVE MENU ========================
show_menu() {
    clear_screen
    display_header
    echo ""
    echo -e "${WHITE}${BOLD}  ┌────────────────────────────────────────┐${NC}"
    echo -e "${WHITE}${BOLD}  │        SELECT SCAN MODE                │${NC}"
    echo -e "${WHITE}${BOLD}  ├────────────────────────────────────────┤${NC}"
    echo -e "${WHITE}${BOLD}  │                                        │${NC}"
    echo -e "${WHITE}${BOLD}  │  ${GREEN}[1]${WHITE} Full Scan     - Complete scan     │${NC}"
    echo -e "${WHITE}${BOLD}  │  ${CYAN}[2]${WHITE} Quick Scan    - Fast ping sweep   │${NC}"
    echo -e "${WHITE}${BOLD}  │  ${YELLOW}[3]${WHITE} Stealth Scan  - Low profile       │${NC}"
    echo -e "${WHITE}${BOLD}  │  ${RED}[4]${WHITE} Deep Scan     - Intensive scan    │${NC}"
    echo -e "${WHITE}${BOLD}  │  ${MAGENTA}[5]${WHITE} WiFi Only     - WiFi networks     │${NC}"
    echo -e "${WHITE}${BOLD}  │  ${BLUE}[6]${WHITE} Continuous    - Real-time monitor │${NC}"
    echo -e "${WHITE}${BOLD}  │  ${DIM}[7]${WHITE} Export Last   - Export results    │${NC}"
    echo -e "${WHITE}${BOLD}  │  ${DIM}[0]${WHITE} Exit                              │${NC}"
    echo -e "${WHITE}${BOLD}  │                                        │${NC}"
    echo -e "${WHITE}${BOLD}  └────────────────────────────────────────┘${NC}"
    echo ""
    echo -ne "${WHITE}${BOLD}  Select option [0-7]: ${NC}"
}

# ======================== SINGLE SCAN DISPLAY ========================
single_scan() {
    local mode="$1"
    
    clear_screen
    display_header
    echo ""
    echo -e "${GREEN}${BOLD}[*] Starting ${mode} scan...${NC}"
    echo ""
    
    get_network_info
    display_network_info
    
    echo ""
    echo -e "${YELLOW}[*] Scanning WiFi networks...${NC}"
    local wifi_results=$(scan_wifi_networks 2>/dev/null)
    display_wifi_results "$wifi_results"
    
    echo ""
    echo -e "${YELLOW}[*] Discovering hosts on ${SUBNET}.0/24 ...${NC}"
    
    # Progress animation
    (
        local chars='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
        while true; do
            for ((i=0; i<${#chars}; i++)); do
                echo -ne "\r${GREEN}  ${chars:$i:1} Scanning...${NC}"
                sleep 0.1
            done
        done
    ) &
    local anim_pid=$!
    
    run_scan_cycle "$mode"
    
    kill $anim_pid 2>/dev/null
    wait $anim_pid 2>/dev/null
    echo -ne "\r                     \r"
    
    display_hosts
    display_services_summary
    display_live_activity
    
    echo ""
    echo -e "${GREEN}${BOLD}[✓] Scan complete!${NC}"
    echo ""
    echo -ne "${WHITE}Press Enter to return to menu...${NC}"
    read -r
}

# ======================== CONTINUOUS MONITORING ========================
continuous_scan() {
    local sweep_angle=0
    local frame=0
    START_TIME=$(date +%s)
    
    # Setup key capture
    stty -echo -icanon min 0 time 0 2>/dev/null
    
    while true; do
        # Check for keypress
        local key=""
        read -rsn1 -t 0.1 key 2>/dev/null
        
        case "$key" in
            q|Q) break ;;
            f|F) SCAN_MODE="full" ;;
            k|K) SCAN_MODE="quick" ;;
            s|S) SCAN_MODE="stealth" ;;
            d|D) SCAN_MODE="deep" ;;
            e|E) export_results; sleep 2 ;;
            r|R) 
                DETECTED_HOSTS=()
                HOST_MAC=()
                HOST_PORTS=()
                HOST_STATUS=()
                HOST_FIRST_SEEN=()
                HOST_LAST_SEEN=()
                SCAN_COUNT=0
                > "$LOG_FILE"
                ;;
        esac
        
        clear_screen
        
        # Update network info periodically
        if (( frame % 5 == 0 )); then
            get_network_info
        fi
        
        display_header
        display_network_info
        
        # Run scan every N frames
        if (( frame % 3 == 0 )); then
            echo -e "\n${YELLOW}${BOLD}  ⟳ Scanning... (${SCAN_MODE} mode)${NC}"
            
            # WiFi scan every 5th cycle
            if (( SCAN_COUNT % 5 == 0 )) || [ $SCAN_COUNT -eq 0 ]; then
                local wifi_results=$(scan_wifi_networks 2>/dev/null)
                display_wifi_results "$wifi_results"
            fi
            
            run_scan_cycle "$SCAN_MODE"
        fi
        
        # Mark hosts that haven't been seen recently as potentially down
        local current_time=$(date +%s)
        for host in "${!DETECTED_HOSTS[@]}"; do
            if ! ping -c 1 -W 1 "$host" &>/dev/null 2>&1; then
                HOST_STATUS[$host]="down"
            fi
        done
        
        display_hosts
        display_services_summary
        
        # Radar animation
        echo ""
        local has_bc=$(command -v bc &>/dev/null && echo 1 || echo 0)
        if [ "$has_bc" = "1" ]; then
            local cols=$(tput cols 2>/dev/null || echo 80)
            if [ "$cols" -ge 60 ]; then
                draw_simple_radar 0 3 $frame $ACTIVE_HOSTS
            fi
        else
            draw_simple_radar 0 3 $frame $ACTIVE_HOSTS
        fi
        
        display_live_activity
        display_footer
        
        sweep_angle=$(( (sweep_angle + 15) % 360 ))
        frame=$((frame + 1))
        
        sleep "$SCAN_INTERVAL"
    done
    
    # Restore terminal
    stty echo icanon 2>/dev/null
}

# ======================== WiFi ONLY SCAN ========================
wifi_only_scan() {
    clear_screen
    display_header
    echo ""
    echo -e "${MAGENTA}${BOLD}[*] Scanning WiFi Networks...${NC}"
    echo ""
    
    # Animated scanning
    local chars='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    (
        for ((c=0; c<30; c++)); do
            local i=$((c % ${#chars}))
            echo -ne "\r  ${GREEN}${chars:$i:1}${NC} ${CYAN}Scanning for wireless networks...${NC}"
            sleep 0.1
        done
    ) &
    local anim_pid=$!
    
    local wifi_results=$(scan_wifi_networks 2>/dev/null)
    
    kill $anim_pid 2>/dev/null
    wait $anim_pid 2>/dev/null
    echo ""
    
    if [ -n "$wifi_results" ]; then
        display_wifi_results "$wifi_results"
        
        # Additional WiFi analysis
        echo ""
        echo -e "${CYAN}${BOLD}╔══════════════════ WiFi ANALYSIS ══════════════════╗${NC}"
        
        local total_nets=$(echo "$wifi_results" | wc -l)
        local open_nets=$(echo "$wifi_results" | grep -c "OPEN" 2>/dev/null || echo 0)
        local wpa2_nets=$(echo "$wifi_results" | grep -c "WPA2" 2>/dev/null || echo 0)
        local wpa_nets=$(echo "$wifi_results" | grep -c "WPA[^2]" 2>/dev/null || echo 0)
        local wep_nets=$(echo "$wifi_results" | grep -c "WEP" 2>/dev/null || echo 0)
        local hidden_nets=$(echo "$wifi_results" | grep -c "Hidden" 2>/dev/null || echo 0)
        
        # Channel distribution
        echo -e "${CYAN}║${NC} ${WHITE}Total Networks  :${NC} ${GREEN}${BOLD}${total_nets}${NC}"
        echo -e "${CYAN}║${NC} ${WHITE}WPA2 Protected  :${NC} ${GREEN}${wpa2_nets}${NC}"
        echo -e "${CYAN}║${NC} ${WHITE}WPA Protected   :${NC} ${YELLOW}${wpa_nets}${NC}"
        echo -e "${CYAN}║${NC} ${WHITE}WEP Protected   :${NC} ${RED}${wep_nets}${NC}"
        echo -e "${CYAN}║${NC} ${WHITE}Open Networks   :${NC} ${RED}${BOLD}${open_nets}${NC}"
        echo -e "${CYAN}║${NC} ${WHITE}Hidden Networks :${NC} ${YELLOW}${hidden_nets}${NC}"
        
        # Channel usage
        echo -e "${CYAN}╠════════════════════════════════════════════════════╣${NC}"
        echo -e "${CYAN}║${NC} ${WHITE}${BOLD}Channel Usage:${NC}"
        
        for ch in 1 2 3 4 5 6 7 8 9 10 11 36 40 44 48; do
            local ch_count=$(echo "$wifi_results" | awk -F'|' -v c="$ch" '$5 == c' | wc -l)
            if [ "$ch_count" -gt 0 ]; then
                local bar=""
                for ((b=0; b<ch_count; b++)); do bar+="█"; done
                echo -e "${CYAN}║${NC}   Ch $(printf '%3d' $ch): ${GREEN}${bar}${NC} (${ch_count})"
            fi
        done
        
        echo -e "${CYAN}╚════════════════════════════════════════════════════╝${NC}"
    else
        echo -e "${RED}[!] No WiFi networks found.${NC}"
        echo -e "${DIM}    Make sure WiFi is enabled and Termux:API is installed.${NC}"
        echo -e "${DIM}    Run: pkg install termux-api${NC}"
        echo -e "${DIM}    Also install Termux:API app from F-Droid/Play Store.${NC}"
    fi
    
    echo ""
    echo -ne "${WHITE}Press Enter to return to menu...${NC}"
    read -r
}

# ======================== CLEANUP ========================
cleanup() {
    stty echo icanon 2>/dev/null
    echo -e "\n${GREEN}${BOLD}[✓] Radar Scanner stopped.${NC}"
    echo -e "${DIM}Log saved to: ${LOG_FILE}${NC}"
    tput cnorm 2>/dev/null  # Show cursor
    exit 0
}

# ======================== STARTUP ANIMATION ========================
startup_animation() {
    clear_screen
    
    local frames=(
        "${GREEN}   ◯${NC}"
        "${GREEN}   ◉${NC}"
        "${GREEN}  ◉◯${NC}"
        "${GREEN} ◉◯◉${NC}"
        "${GREEN}◉◯◉◯${NC}"
    )
    
    echo ""
    echo ""
    for frame in "${frames[@]}"; do
        echo -ne "\r${frame}"
        sleep 0.15
    done
    
    echo ""
    echo -e "${GREEN}${BOLD}"
    
    local text="RADAR SCANNER INITIALIZING..."
    for ((i=0; i<${#text}; i++)); do
        echo -n "${text:$i:1}"
        sleep 0.02
    done
    echo -e "${NC}"
    
    sleep 0.5
    
    echo ""
    echo -e "${CYAN}  ▸ Loading modules...${NC}"
    sleep 0.2
    echo -e "${CYAN}  ▸ Checking network interfaces...${NC}"
    sleep 0.2
    echo -e "${CYAN}  ▸ Initializing scanner engine...${NC}"
    sleep 0.2
    echo -e "${CYAN}  ▸ Calibrating radar...${NC}"
    sleep 0.2
    echo -e "${GREEN}${BOLD}  ▸ System ready!${NC}"
    sleep 0.5
}

# ======================== MAIN ========================
main() {
    trap cleanup INT TERM
    tput civis 2>/dev/null  # Hide cursor
    
    # Initialize
    > "$LOG_FILE"
    START_TIME=$(date +%s)
    log_event "Radar Scanner started"
    
    startup_animation
    check_dependencies
    get_network_info
    
    while true; do
        show_menu
        read -r choice
        
        case "$choice" in
            1)
                SCAN_MODE="full"
                single_scan "full"
                ;;
            2)
                SCAN_MODE="quick"
                single_scan "quick"
                ;;
            3)
                SCAN_MODE="stealth"
                single_scan "stealth"
                ;;
            4)
                SCAN_MODE="deep"
                single_scan "deep"
                ;;
            5)
                wifi_only_scan
                ;;
            6)
                SCAN_MODE="full"
                continuous_scan
                ;;
            7)
                export_results
                sleep 2
                ;;
            0|q|Q)
                cleanup
                ;;
            *)
                echo -e "${RED}Invalid option!${NC}"
                sleep 1
                ;;
        esac
    done
}

# ======================== RUN ========================
main "$@"
