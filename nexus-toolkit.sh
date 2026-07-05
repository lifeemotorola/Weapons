#!/data/data/com.termux/files/usr/bin/bash

# ╔══════════════════════════════════════════════════════════════════╗
# ║              NEXUS-TOOLKIT v4.0 - ULTRA EDITION                  ║
# ║          Advanced Termux Plugin Suite by NexusForge              ║
# ║                    [ NEVER SEEN BEFORE ]                         ║
# ╚══════════════════════════════════════════════════════════════════╝

# ========================= CONFIGURATION ==========================
VERSION="4.0.0"
TOOLKIT_DIR="$HOME/.nexus-toolkit"
LOG_DIR="$TOOLKIT_DIR/logs"
CONFIG_DIR="$TOOLKIT_DIR/config"
CACHE_DIR="$TOOLKIT_DIR/cache"
PLUGIN_DIR="$TOOLKIT_DIR/plugins"
DB_DIR="$TOOLKIT_DIR/database"
BACKUP_DIR="$TOOLKIT_DIR/backups"
THEME_FILE="$CONFIG_DIR/theme.conf"
SESSION_FILE="$TOOLKIT_DIR/.session"
PID_FILE="$TOOLKIT_DIR/.daemon.pid"

# ========================= COLOR ENGINE ===========================
setup_colors() {
    R='\033[1;31m'    # Red
    G='\033[1;32m'    # Green
    B='\033[1;34m'    # Blue
    Y='\033[1;33m'    # Yellow
    C='\033[1;36m'    # Cyan
    M='\033[1;35m'    # Magenta
    W='\033[1;37m'    # White
    BK='\033[1;30m'   # Black
    N='\033[0m'       # Reset
    BG_R='\033[41m'   # BG Red
    BG_G='\033[42m'   # BG Green
    BG_B='\033[44m'   # BG Blue
    BG_Y='\033[43m'   # BG Yellow
    BG_M='\033[45m'   # BG Magenta
    BG_C='\033[46m'   # BG Cyan
    BG_W='\033[47m'   # BG White
    DIM='\033[2m'
    BOLD='\033[1m'
    ITALIC='\033[3m'
    UNDER='\033[4m'
    BLINK='\033[5m'
    STRIKE='\033[9m'
}
setup_colors

# ========================= UNICODE ICONS ==========================
ICON_SKULL="💀"
ICON_FIRE="🔥"
ICON_BOLT="⚡"
ICON_SHIELD="🛡️"
ICON_LOCK="🔒"
ICON_UNLOCK="🔓"
ICON_GEAR="⚙️"
ICON_CHECK="✅"
ICON_CROSS="❌"
ICON_WARN="⚠️"
ICON_INFO="ℹ️"
ICON_STAR="⭐"
ICON_ROCKET="🚀"
ICON_NET="🌐"
ICON_FOLDER="📁"
ICON_FILE="📄"
ICON_CLOCK="🕐"
ICON_CHART="📊"
ICON_KEY="🔑"
ICON_EYE="👁️"
ICON_SNAKE="🐍"
ICON_GHOST="👻"
ICON_DIAMOND="💎"
ICON_PULSE="💓"
ICON_ATOM="⚛️"
ICON_DNA="🧬"
ICON_BRAIN="🧠"
ICON_SATELLITE="🛰️"
ICON_SPIDER="🕷️"
ICON_TERMINAL="💻"
ICON_PACKAGE="📦"
ICON_TOOLS="🔧"
ICON_SEARCH="🔍"
ICON_WAVE="🌊"
ICON_MATRIX="🟩"

# ========================= INIT SYSTEM ============================
init_toolkit() {
    mkdir -p "$TOOLKIT_DIR" "$LOG_DIR" "$CONFIG_DIR" "$CACHE_DIR" \
             "$PLUGIN_DIR" "$DB_DIR" "$BACKUP_DIR" \
             "$TOOLKIT_DIR/reports" "$TOOLKIT_DIR/exports" \
             "$TOOLKIT_DIR/snapshots" "$TOOLKIT_DIR/quarantine"

    # Session tracking
    echo "SESSION_START=$(date +%s)" > "$SESSION_FILE"
    echo "SESSION_ID=$(cat /dev/urandom | tr -dc 'a-f0-9' | head -c 16)" >> "$SESSION_FILE"

    # Default config
    if [ ! -f "$CONFIG_DIR/nexus.conf" ]; then
        cat > "$CONFIG_DIR/nexus.conf" << 'CONF'
ANIMATION_SPEED=0.03
THEME=cyberpunk
AUTO_UPDATE=true
LOG_LEVEL=INFO
MAX_THREADS=4
ENCRYPTION_ALGO=AES-256
DAEMON_PORT=8745
NOTIFY_SOUND=true
AUTO_BACKUP=true
TELEMETRY=false
CONF
    fi
    source "$CONFIG_DIR/nexus.conf" 2>/dev/null
}

# ========================= ANIMATION ENGINE =======================
typewriter() {
    local text="$1"
    local speed="${2:-0.02}"
    for ((i=0; i<${#text}; i++)); do
        printf "%s" "${text:$i:1}"
        sleep "$speed"
    done
    echo ""
}

matrix_rain() {
    local duration="${1:-5}"
    local cols=$(tput cols)
    local end=$((SECONDS + duration))
    local chars="アイウエオカキクケコサシスセソタチツテトナニヌネノハヒフヘホマミムメモヤユヨラリルレロワヲン0123456789ABCDEF"
    
    tput civis
    while [ $SECONDS -lt $end ]; do
        local col=$((RANDOM % cols))
        local char="${chars:$((RANDOM % ${#chars})):1}"
        local color=$((RANDOM % 2))
        if [ $color -eq 0 ]; then
            printf "\033[%d;%dH${G}%s${N}" $((RANDOM % 24 + 1)) $col "$char"
        else
            printf "\033[%d;%dH${DIM}${G}%s${N}" $((RANDOM % 24 + 1)) $col "$char"
        fi
        sleep 0.01
    done
    tput cnorm
    clear
}

cyber_loader() {
    local text="$1"
    local duration="${2:-3}"
    local frames=("⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏")
    local end=$((SECONDS + duration))
    local i=0
    
    tput civis
    while [ $SECONDS -lt $end ]; do
        printf "\r  ${C}${frames[$i]}${N} ${W}${text}${N} ${DIM}[${G}"
        for ((j=0; j<$((RANDOM%20+5)); j++)); do printf "█"; done
        printf "${BK}"
        for ((j=0; j<$((20-j)); j++)); do printf "░"; done
        printf "${N}${DIM}]${N}"
        i=$(( (i+1) % ${#frames[@]} ))
        sleep 0.08
    done
    printf "\r  ${G}✓${N} ${W}${text}${N} ${DIM}[${G}████████████████████${N}${DIM}]${N} ${G}Complete${N}\n"
    tput cnorm
}

progress_bar() {
    local current=$1
    local total=$2
    local text="${3:-Processing}"
    local width=40
    local percent=$((current * 100 / total))
    local filled=$((current * width / total))
    local empty=$((width - filled))
    
    printf "\r  ${C}▶${N} ${W}${text}${N} ${DIM}[${N}"
    
    for ((i=0; i<filled; i++)); do
        if [ $percent -lt 30 ]; then printf "${R}█${N}"
        elif [ $percent -lt 70 ]; then printf "${Y}█${N}"
        else printf "${G}█${N}"; fi
    done
    for ((i=0; i<empty; i++)); do printf "${BK}░${N}"; done
    
    printf "${DIM}]${N} ${W}${percent}%%${N} "
}

pulse_text() {
    local text="$1"
    local colors=("$R" "$Y" "$G" "$C" "$B" "$M")
    for ((i=0; i<3; i++)); do
        for color in "${colors[@]}"; do
            printf "\r  ${color}${text}${N}"
            sleep 0.05
        done
    done
    printf "\r  ${G}${text}${N}\n"
}

glitch_text() {
    local text="$1"
    local glitch_chars="!@#$%^&*()_+-=[]{}|;:,.<>?"
    for ((iter=0; iter<5; iter++)); do
        local output=""
        for ((i=0; i<${#text}; i++)); do
            if [ $((RANDOM % 3)) -eq 0 ]; then
                output+="${R}${glitch_chars:$((RANDOM % ${#glitch_chars})):1}${N}"
            else
                output+="${text:$i:1}"
            fi
        done
        printf "\r  ${output}"
        sleep 0.1
    done
    printf "\r  ${C}${text}${N}\n"
}

# ========================= RESPONSIVE UI ENGINE ===================
get_terminal_size() {
    TERM_COLS=$(tput cols 2>/dev/null || echo 80)
    TERM_ROWS=$(tput lines 2>/dev/null || echo 24)
}

draw_box() {
    local title="$1"
    local width=$((TERM_COLS - 4))
    [ $width -gt 100 ] && width=100
    [ $width -lt 40 ] && width=40
    
    local title_len=${#title}
    local padding=$(( (width - title_len - 2) / 2 ))
    
    printf "  ${C}╔"
    printf '═%.0s' $(seq 1 $width)
    printf "╗${N}\n"
    
    printf "  ${C}║${N}"
    printf ' %.0s' $(seq 1 $padding)
    printf "${BOLD}${W}${title}${N}"
    printf ' %.0s' $(seq 1 $((width - padding - title_len)))
    printf "${C}║${N}\n"
    
    printf "  ${C}╠"
    printf '═%.0s' $(seq 1 $width)
    printf "╣${N}\n"
}

draw_box_end() {
    local width=$((TERM_COLS - 4))
    [ $width -gt 100 ] && width=100
    [ $width -lt 40 ] && width=40
    
    printf "  ${C}╚"
    printf '═%.0s' $(seq 1 $width)
    printf "╝${N}\n"
}

draw_separator() {
    local width=$((TERM_COLS - 4))
    [ $width -gt 100 ] && width=100
    [ $width -lt 40 ] && width=40
    
    printf "  ${C}╟"
    printf '─%.0s' $(seq 1 $width)
    printf "╢${N}\n"
}

menu_item() {
    local num="$1"
    local icon="$2"
    local text="$3"
    local desc="$4"
    local width=$((TERM_COLS - 4))
    [ $width -gt 100 ] && width=100
    [ $width -lt 40 ] && width=40
    
    local content=" ${Y}[${W}${num}${Y}]${N} ${icon} ${BOLD}${W}${text}${N}"
    local content_stripped=" [${num}] ${icon} ${text}"
    local remaining=$((width - ${#content_stripped} - ${#desc} - 3))
    
    printf "  ${C}║${N}${content}"
    if [ $remaining -gt 0 ] && [ -n "$desc" ]; then
        printf ' %.0s' $(seq 1 $remaining)
        printf "${DIM}${desc}${N}"
    fi
    local total_content_len=$((${#content_stripped} + ${#desc} + (remaining > 0 ? remaining : 0)))
    local pad=$((width - total_content_len - 1))
    [ $pad -gt 0 ] && printf ' %.0s' $(seq 1 $pad)
    printf " ${C}║${N}\n"
}

status_line() {
    local icon="$1"
    local label="$2"
    local value="$3"
    local color="${4:-$G}"
    printf "  ${C}║${N}  ${icon} ${DIM}${label}:${N} ${color}${value}${N}\n"
}

# ========================= BANNER ENGINE ==========================
show_banner() {
    clear
    get_terminal_size
    
    local banner_color="$C"
    
    echo ""
    echo -e "  ${banner_color}███╗   ██╗${R}███████╗${Y}██╗  ██╗${G}██╗   ██╗${B}███████╗${N}"
    echo -e "  ${banner_color}████╗  ██║${R}██╔════╝${Y}╚██╗██╔╝${G}██║   ██║${B}██╔════╝${N}"
    echo -e "  ${banner_color}██╔██╗ ██║${R}█████╗  ${Y} ╚███╔╝ ${G}██║   ██║${B}███████╗${N}"
    echo -e "  ${banner_color}██║╚██╗██║${R}██╔══╝  ${Y} ██╔██╗ ${G}██║   ██║${B}╚════██║${N}"
    echo -e "  ${banner_color}██║ ╚████║${R}███████╗${Y}██╔╝ ██╗${G}╚██████╔╝${B}███████║${N}"
    echo -e "  ${banner_color}╚═╝  ╚═══╝${R}╚══════╝${Y}╚═╝  ╚═╝${G} ╚═════╝ ${B}╚══════╝${N}"
    echo ""
    echo -e "  ${DIM}${C}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${N}"
    echo -e "  ${ICON_DIAMOND} ${BOLD}${W}NEXUS TOOLKIT${N} ${DIM}v${VERSION}${N} ${DIM}│${N} ${ICON_TERMINAL} ${DIM}Advanced Termux Suite${N}"
    echo -e "  ${DIM}${C}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${N}"
    echo ""
}

# ========================= SYSTEM DASHBOARD =======================
system_dashboard() {
    clear
    show_banner
    
    local cpu_cores=$(nproc 2>/dev/null || echo "N/A")
    local mem_total=$(free -h 2>/dev/null | awk '/Mem:/{print $2}' || echo "N/A")
    local mem_used=$(free -h 2>/dev/null | awk '/Mem:/{print $3}' || echo "N/A")
    local mem_percent=$(free 2>/dev/null | awk '/Mem:/{printf "%.0f", $3/$2*100}' || echo "0")
    local disk_total=$(df -h "$HOME" 2>/dev/null | awk 'NR==2{print $2}' || echo "N/A")
    local disk_used=$(df -h "$HOME" 2>/dev/null | awk 'NR==2{print $3}' || echo "N/A")
    local disk_percent=$(df "$HOME" 2>/dev/null | awk 'NR==2{print $5}' | tr -d '%' || echo "0")
    local uptime_val=$(uptime -p 2>/dev/null || uptime | awk '{print $3,$4}' || echo "N/A")
    local hostname_val=$(hostname 2>/dev/null || echo "termux")
    local kernel_val=$(uname -r 2>/dev/null || echo "N/A")
    local arch_val=$(uname -m 2>/dev/null || echo "N/A")
    local android_ver=$(getprop ro.build.version.release 2>/dev/null || echo "N/A")
    local battery_level=$(termux-battery-status 2>/dev/null | grep percentage | grep -o '[0-9]*' || echo "N/A")
    local ip_local=$(ip addr show wlan0 2>/dev/null | grep 'inet ' | awk '{print $2}' | cut -d/ -f1 || echo "N/A")
    local net_iface=$(ip route 2>/dev/null | grep default | awk '{print $5}' | head -1 || echo "N/A")
    
    draw_box "${ICON_CHART} SYSTEM DASHBOARD"
    
    echo -e "  ${C}║${N}"
    echo -e "  ${C}║${N}  ${ICON_BRAIN} ${BOLD}${W}SYSTEM INFORMATION${N}"
    echo -e "  ${C}║${N}  ${DIM}─────────────────────${N}"
    status_line "$ICON_TERMINAL" "Hostname" "$hostname_val"
    status_line "$ICON_GEAR" "Kernel" "$kernel_val"
    status_line "$ICON_ATOM" "Architecture" "$arch_val"
    status_line "📱" "Android" "$android_ver"
    status_line "$ICON_CLOCK" "Uptime" "$uptime_val"
    
    echo -e "  ${C}║${N}"
    echo -e "  ${C}║${N}  ${ICON_CHART} ${BOLD}${W}RESOURCE USAGE${N}"
    echo -e "  ${C}║${N}  ${DIM}─────────────────────${N}"
    
    # CPU
    status_line "$ICON_BOLT" "CPU Cores" "$cpu_cores"
    
    # Memory bar
    local mem_bar_width=30
    local mem_filled=$((mem_percent * mem_bar_width / 100))
    local mem_empty=$((mem_bar_width - mem_filled))
    local mem_color="$G"
    [ $mem_percent -gt 60 ] && mem_color="$Y"
    [ $mem_percent -gt 85 ] && mem_color="$R"
    
    printf "  ${C}║${N}  ${ICON_DNA} ${DIM}Memory:${N}  ${mem_color}${mem_used}${N}/${mem_total} ${DIM}[${N}"
    for ((i=0;i<mem_filled;i++)); do printf "${mem_color}█${N}"; done
    for ((i=0;i<mem_empty;i++)); do printf "${BK}░${N}"; done
    printf "${DIM}]${N} ${mem_color}${mem_percent}%%${N}\n"
    
    # Disk bar
    local disk_bar_width=30
    local disk_filled=$((disk_percent * disk_bar_width / 100))
    local disk_empty=$((disk_bar_width - disk_filled))
    local disk_color="$G"
    [ $disk_percent -gt 60 ] && disk_color="$Y"
    [ $disk_percent -gt 85 ] && disk_color="$R"
    
    printf "  ${C}║${N}  ${ICON_FOLDER} ${DIM}Disk:${N}    ${disk_color}${disk_used}${N}/${disk_total} ${DIM}[${N}"
    for ((i=0;i<disk_filled;i++)); do printf "${disk_color}█${N}"; done
    for ((i=0;i<disk_empty;i++)); do printf "${BK}░${N}"; done
    printf "${DIM}]${N} ${disk_color}${disk_percent}%%${N}\n"
    
    # Battery
    if [ "$battery_level" != "N/A" ]; then
        local bat_bar_width=30
        local bat_filled=$((battery_level * bat_bar_width / 100))
        local bat_empty=$((bat_bar_width - bat_filled))
        local bat_color="$G"
        [ $battery_level -lt 50 ] && bat_color="$Y"
        [ $battery_level -lt 20 ] && bat_color="$R"
        
        printf "  ${C}║${N}  🔋 ${DIM}Battery:${N} ${bat_color}${battery_level}%%${N}      ${DIM}[${N}"
        for ((i=0;i<bat_filled;i++)); do printf "${bat_color}█${N}"; done
        for ((i=0;i<bat_empty;i++)); do printf "${BK}░${N}"; done
        printf "${DIM}]${N}\n"
    fi
    
    echo -e "  ${C}║${N}"
    echo -e "  ${C}║${N}  ${ICON_NET} ${BOLD}${W}NETWORK${N}"
    echo -e "  ${C}║${N}  ${DIM}─────────────────────${N}"
    status_line "$ICON_NET" "Interface" "$net_iface"
    status_line "$ICON_SATELLITE" "Local IP" "$ip_local"
    echo -e "  ${C}║${N}"
    
    draw_box_end
    
    echo ""
    echo -e "  ${DIM}Press ${W}[ENTER]${DIM} to return...${N}"
    read
}

# ========================= TOOL 1: PHANTOM SCANNER =================
phantom_scanner() {
    clear
    show_banner
    draw_box "${ICON_SPIDER} PHANTOM SCANNER - Deep Network Reconnaissance"
    echo -e "  ${C}║${N}"
    echo -e "  ${C}║${N}  ${ICON_WARN} ${Y}Advanced network topology & service discovery${N}"
    echo -e "  ${C}║${N}"
    draw_box_end
    echo ""
    
    echo -ne "  ${ICON_NET} ${W}Enter target IP/Range: ${C}"
    read target
    echo -e "${N}"
    
    if [ -z "$target" ]; then
        echo -e "  ${ICON_CROSS} ${R}No target specified!${N}"
        sleep 2
        return
    fi
    
    local scan_id=$(cat /dev/urandom | tr -dc 'A-F0-9' | head -c 8)
    local report_file="$TOOLKIT_DIR/reports/phantom_${scan_id}_$(date +%Y%m%d_%H%M%S).txt"
    
    echo -e "  ${ICON_SEARCH} ${W}Scan ID: ${C}${scan_id}${N}"
    echo -e "  ${ICON_FILE} ${W}Report:  ${DIM}${report_file}${N}"
    echo ""
    
    {
        echo "═══════════════════════════════════════════════════"
        echo " PHANTOM SCANNER REPORT"
        echo " Scan ID: $scan_id"
        echo " Target: $target"
        echo " Date: $(date)"
        echo "═══════════════════════════════════════════════════"
        echo ""
    } > "$report_file"
    
    # Phase 1: Host Discovery
    glitch_text "PHASE 1: HOST DISCOVERY"
    sleep 0.5
    
    local alive_hosts=0
    if command -v ping &>/dev/null; then
        echo -e "  ${DIM}Sending ICMP probes...${N}"
        if ping -c 1 -W 2 "$target" &>/dev/null; then
            echo -e "  ${ICON_CHECK} ${G}Host ${W}${target}${G} is ALIVE${N}"
            alive_hosts=1
            echo "  [+] Host $target - ALIVE (ICMP)" >> "$report_file"
        else
            echo -e "  ${ICON_WARN} ${Y}Host may be filtering ICMP${N}"
            echo "  [!] Host $target - ICMP filtered" >> "$report_file"
        fi
    fi
    echo ""
    
    # Phase 2: Port Scanning
    glitch_text "PHASE 2: PORT RECONNAISSANCE"
    sleep 0.5
    
    local common_ports=(21 22 23 25 53 80 110 111 135 139 143 443 445 993 995 1723 3306 3389 5432 5900 8080 8443 8888 9090 27017)
    local open_ports=()
    local total_ports=${#common_ports[@]}
    local scanned=0
    
    echo "" >> "$report_file"
    echo "  PORT SCAN RESULTS:" >> "$report_file"
    echo "  ─────────────────" >> "$report_file"
    
    for port in "${common_ports[@]}"; do
        scanned=$((scanned + 1))
        progress_bar $scanned $total_ports "Scanning ports"
        
        (echo >/dev/tcp/"$target"/"$port") 2>/dev/null
        if [ $? -eq 0 ]; then
            open_ports+=($port)
            
            # Service detection
            local service="unknown"
            case $port in
                21) service="FTP";;
                22) service="SSH";;
                23) service="Telnet";;
                25) service="SMTP";;
                53) service="DNS";;
                80) service="HTTP";;
                110) service="POP3";;
                111) service="RPCBind";;
                135) service="MSRPC";;
                139) service="NetBIOS";;
                143) service="IMAP";;
                443) service="HTTPS";;
                445) service="SMB";;
                993) service="IMAPS";;
                995) service="POP3S";;
                1723) service="PPTP";;
                3306) service="MySQL";;
                3389) service="RDP";;
                5432) service="PostgreSQL";;
                5900) service="VNC";;
                8080) service="HTTP-Proxy";;
                8443) service="HTTPS-Alt";;
                8888) service="HTTP-Alt";;
                9090) service="WebConsole";;
                27017) service="MongoDB";;
            esac
            
            echo "  [OPEN] $port/tcp  ->  $service" >> "$report_file"
        fi
        sleep 0.05
    done
    
    echo ""
    echo ""
    
    # Results
    if [ ${#open_ports[@]} -gt 0 ]; then
        echo -e "  ${ICON_FIRE} ${G}Found ${W}${#open_ports[@]}${G} open ports:${N}"
        echo ""
        printf "  ${C}%-8s %-10s %-20s${N}\n" "PORT" "STATE" "SERVICE"
        echo -e "  ${DIM}──────── ────────── ────────────────────${N}"
        
        for port in "${open_ports[@]}"; do
            local service="unknown"
            case $port in
                21) service="FTP";;
                22) service="SSH";;
                23) service="Telnet";;
                25) service="SMTP";;
                53) service="DNS";;
                80) service="HTTP";;
                110) service="POP3";;
                143) service="IMAP";;
                443) service="HTTPS";;
                445) service="SMB";;
                3306) service="MySQL";;
                3389) service="RDP";;
                5432) service="PostgreSQL";;
                5900) service="VNC";;
                8080) service="HTTP-Proxy";;
                8443) service="HTTPS-Alt";;
                27017) service="MongoDB";;
                *) service="unknown";;
            esac
            printf "  ${W}%-8s${N} ${G}%-10s${N} ${Y}%-20s${N}\n" "$port" "open" "$service"
        done
    else
        echo -e "  ${ICON_WARN} ${Y}No open ports found in common range${N}"
    fi
    
    # Phase 3: Banner Grabbing
    echo ""
    glitch_text "PHASE 3: SERVICE FINGERPRINTING"
    sleep 0.5
    
    echo "" >> "$report_file"
    echo "  BANNER GRAB RESULTS:" >> "$report_file"
    echo "  ────────────────────" >> "$report_file"
    
    for port in "${open_ports[@]}"; do
        local banner=$(echo "" | timeout 3 nc "$target" "$port" 2>/dev/null | head -1)
        if [ -n "$banner" ]; then
            echo -e "  ${ICON_EYE} ${W}Port ${C}${port}${W}: ${DIM}${banner}${N}"
            echo "  Port $port: $banner" >> "$report_file"
        fi
    done
    
    # Phase 4: HTTP Analysis (if port 80 or 443 is open)
    for port in "${open_ports[@]}"; do
        if [ "$port" = "80" ] || [ "$port" = "443" ]; then
            echo ""
            glitch_text "PHASE 4: HTTP ANALYSIS"
            sleep 0.5
            
            local proto="http"
            [ "$port" = "443" ] && proto="https"
            
            if command -v curl &>/dev/null; then
                local http_code=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 "${proto}://${target}" 2>/dev/null)
                local server_header=$(curl -s -I --max-time 5 "${proto}://${target}" 2>/dev/null | grep -i "server:" | head -1)
                local content_type=$(curl -s -I --max-time 5 "${proto}://${target}" 2>/dev/null | grep -i "content-type:" | head -1)
                local title=$(curl -s --max-time 5 "${proto}://${target}" 2>/dev/null | grep -o '<title>[^<]*</title>' | head -1 | sed 's/<[^>]*>//g')
                
                echo -e "  ${ICON_NET} ${W}HTTP Status: ${C}${http_code}${N}"
                [ -n "$server_header" ] && echo -e "  ${ICON_GEAR} ${W}${server_header}${N}"
                [ -n "$title" ] && echo -e "  ${ICON_FILE} ${W}Title: ${Y}${title}${N}"
                
                echo "" >> "$report_file"
                echo "  HTTP ANALYSIS:" >> "$report_file"
                echo "  Status: $http_code" >> "$report_file"
                echo "  $server_header" >> "$report_file"
                echo "  Title: $title" >> "$report_file"
            fi
            break
        fi
    done
    
    # Summary
    echo ""
    {
        echo ""
        echo "═══════════════════════════════════════════════════"
        echo " SCAN COMPLETE"
        echo " Open Ports: ${#open_ports[@]}"
        echo " Duration: ~$SECONDS seconds"
        echo "═══════════════════════════════════════════════════"
    } >> "$report_file"
    
    echo -e "  ${ICON_CHECK} ${G}Report saved: ${DIM}${report_file}${N}"
    echo ""
    echo -e "  ${DIM}Press ${W}[ENTER]${DIM} to return...${N}"
    read
}

# ========================= TOOL 2: NEURAL CRYPT ===================
neural_crypt() {
    clear
    show_banner
    draw_box "${ICON_LOCK} NEURAL CRYPT - Quantum-Grade Encryption Engine"
    echo -e "  ${C}║${N}"
    echo -e "  ${C}║${N}  ${ICON_SHIELD} ${W}Multi-layer encryption with custom algorithms${N}"
    echo -e "  ${C}║${N}"
    menu_item "1" "$ICON_LOCK" "Encrypt File" "AES-256 + custom layers"
    menu_item "2" "$ICON_UNLOCK" "Decrypt File" "Reverse process"
    menu_item "3" "$ICON_KEY" "Encrypt Text" "Real-time text encryption"
    menu_item "4" "$ICON_UNLOCK" "Decrypt Text" "Reverse text encryption"
    menu_item "5" "$ICON_DNA" "Generate Key Pair" "RSA-4096 equivalent"
    menu_item "6" "$ICON_SHIELD" "Hash Generator" "Multi-algorithm hashing"
    menu_item "7" "$ICON_EYE" "Steganography" "Hide data in images"
    menu_item "8" "🔐" "Password Vault" "Encrypted password manager"
    menu_item "0" "$ICON_CROSS" "Back" ""
    echo -e "  ${C}║${N}"
    draw_box_end
    
    echo ""
    echo -ne "  ${ICON_BOLT} ${W}Select option: ${C}"
    read nc_choice
    echo -e "${N}"
    
    case $nc_choice in
        1) # Encrypt file
            echo -ne "  ${ICON_FILE} ${W}File path: ${C}"
            read filepath
            echo -e "${N}"
            
            if [ ! -f "$filepath" ]; then
                echo -e "  ${ICON_CROSS} ${R}File not found!${N}"
                sleep 2
                return
            fi
            
            echo -ne "  ${ICON_KEY} ${W}Encryption password: ${C}"
            read -s enc_pass
            echo ""
            echo -ne "  ${ICON_KEY} ${W}Confirm password: ${C}"
            read -s enc_pass2
            echo ""
            echo -e "${N}"
            
            if [ "$enc_pass" != "$enc_pass2" ]; then
                echo -e "  ${ICON_CROSS} ${R}Passwords don't match!${N}"
                sleep 2
                return
            fi
            
            local outfile="${filepath}.nexus"
            
            cyber_loader "Generating encryption matrix" 1
            cyber_loader "Applying quantum scramble layer" 1
            cyber_loader "Encrypting with AES-256-CBC" 2
            
            if command -v openssl &>/dev/null; then
                openssl enc -aes-256-cbc -salt -pbkdf2 -iter 100000 \
                    -in "$filepath" -out "$outfile" -pass pass:"$enc_pass" 2>/dev/null
                
                if [ $? -eq 0 ]; then
                    # Add custom header
                    local temp_file=$(mktemp)
                    echo "NEXUS_CRYPT_v4" > "$temp_file"
                    echo "ALG=AES-256-CBC-PBKDF2" >> "$temp_file"
                    echo "TIME=$(date +%s)" >> "$temp_file"
                    echo "HASH=$(sha256sum "$filepath" | cut -d' ' -f1)" >> "$temp_file"
                    echo "---DATA---" >> "$temp_file"
                    cat "$outfile" >> "$temp_file"
                    mv "$temp_file" "$outfile"
                    
                    local orig_size=$(stat -f%z "$filepath" 2>/dev/null || stat -c%s "$filepath" 2>/dev/null || echo "?")
                    local enc_size=$(stat -f%z "$outfile" 2>/dev/null || stat -c%s "$outfile" 2>/dev/null || echo "?")
                    
                    echo ""
                    echo -e "  ${ICON_CHECK} ${G}Encryption successful!${N}"
                    echo -e "  ${ICON_FILE} ${W}Output: ${C}${outfile}${N}"
                    echo -e "  ${ICON_CHART} ${DIM}Original: ${orig_size} bytes → Encrypted: ${enc_size} bytes${N}"
                    
                    echo "$(date) | ENCRYPT | $filepath -> $outfile" >> "$LOG_DIR/crypt.log"
                else
                    echo -e "  ${ICON_CROSS} ${R}Encryption failed!${N}"
                fi
            else
                echo -e "  ${ICON_WARN} ${Y}OpenSSL not found. Installing...${N}"
                pkg install openssl-tool -y 2>/dev/null
                echo -e "  ${ICON_INFO} ${W}Please retry after installation.${N}"
            fi
            ;;
            
        2) # Decrypt file
            echo -ne "  ${ICON_FILE} ${W}Encrypted file path (.nexus): ${C}"
            read filepath
            echo -e "${N}"
            
            if [ ! -f "$filepath" ]; then
                echo -e "  ${ICON_CROSS} ${R}File not found!${N}"
                sleep 2
                return
            fi
            
            echo -ne "  ${ICON_KEY} ${W}Decryption password: ${C}"
            read -s dec_pass
            echo ""
            echo -e "${N}"
            
            local outfile="${filepath%.nexus}"
            [ "$outfile" = "$filepath" ] && outfile="${filepath}.decrypted"
            
            cyber_loader "Verifying encryption header" 1
            cyber_loader "Decrypting layers" 2
            
            # Strip custom header
            local data_start=$(grep -n "---DATA---" "$filepath" 2>/dev/null | cut -d: -f1)
            if [ -n "$data_start" ]; then
                local temp_enc=$(mktemp)
                tail -n +$((data_start + 1)) "$filepath" > "$temp_enc"
                
                openssl enc -aes-256-cbc -d -salt -pbkdf2 -iter 100000 \
                    -in "$temp_enc" -out "$outfile" -pass pass:"$dec_pass" 2>/dev/null
                
                if [ $? -eq 0 ]; then
                    echo -e "  ${ICON_CHECK} ${G}Decryption successful!${N}"
                    echo -e "  ${ICON_FILE} ${W}Output: ${C}${outfile}${N}"
                else
                    echo -e "  ${ICON_CROSS} ${R}Decryption failed! Wrong password?${N}"
                fi
                rm -f "$temp_enc"
            else
                # Try direct decryption
                openssl enc -aes-256-cbc -d -salt -pbkdf2 -iter 100000 \
                    -in "$filepath" -out "$outfile" -pass pass:"$dec_pass" 2>/dev/null
                
                if [ $? -eq 0 ]; then
                    echo -e "  ${ICON_CHECK} ${G}Decryption successful!${N}"
                    echo -e "  ${ICON_FILE} ${W}Output: ${C}${outfile}${N}"
                else
                    echo -e "  ${ICON_CROSS} ${R}Decryption failed!${N}"
                fi
            fi
            ;;
            
        3) # Encrypt text
            echo -ne "  ${ICON_FILE} ${W}Enter text to encrypt: ${C}"
            read plain_text
            echo -ne "  ${ICON_KEY} ${W}Password: ${C}"
            read -s text_pass
            echo ""
            echo -e "${N}"
            
            cyber_loader "Encrypting" 1
            
            local encrypted=$(echo "$plain_text" | openssl enc -aes-256-cbc -a -salt -pbkdf2 -iter 100000 -pass pass:"$text_pass" 2>/dev/null)
            
            if [ -n "$encrypted" ]; then
                echo -e "  ${ICON_CHECK} ${G}Encrypted text:${N}"
                echo ""
                echo -e "  ${Y}${encrypted}${N}"
                echo ""
                echo "$encrypted" | termux-clipboard-set 2>/dev/null && \
                    echo -e "  ${ICON_INFO} ${DIM}Copied to clipboard${N}"
            else
                echo -e "  ${ICON_CROSS} ${R}Encryption failed!${N}"
            fi
            ;;
            
        4) # Decrypt text
            echo -ne "  ${ICON_FILE} ${W}Enter encrypted text: ${C}"
            read cipher_text
            echo -ne "  ${ICON_KEY} ${W}Password: ${C}"
            read -s text_pass
            echo ""
            echo -e "${N}"
            
            cyber_loader "Decrypting" 1
            
            local decrypted=$(echo "$cipher_text" | openssl enc -aes-256-cbc -a -d -salt -pbkdf2 -iter 100000 -pass pass:"$text_pass" 2>/dev/null)
            
            if [ -n "$decrypted" ]; then
                echo -e "  ${ICON_CHECK} ${G}Decrypted text:${N}"
                echo ""
                echo -e "  ${W}${decrypted}${N}"
            else
                echo -e "  ${ICON_CROSS} ${R}Decryption failed!${N}"
            fi
            ;;
            
        5) # Generate keys
            local key_id=$(cat /dev/urandom | tr -dc 'A-F0-9' | head -c 8)
            local key_dir="$TOOLKIT_DIR/keys"
            mkdir -p "$key_dir"
            
            cyber_loader "Generating prime numbers" 2
            cyber_loader "Computing key pair" 2
            
            if command -v openssl &>/dev/null; then
                openssl genrsa -out "$key_dir/nexus_${key_id}_private.pem" 4096 2>/dev/null
                openssl rsa -in "$key_dir/nexus_${key_id}_private.pem" -pubout \
                    -out "$key_dir/nexus_${key_id}_public.pem" 2>/dev/null
                
                echo -e "  ${ICON_CHECK} ${G}Key pair generated!${N}"
                echo -e "  ${ICON_KEY} ${W}Private: ${DIM}${key_dir}/nexus_${key_id}_private.pem${N}"
                echo -e "  ${ICON_KEY} ${W}Public:  ${DIM}${key_dir}/nexus_${key_id}_public.pem${N}"
                echo -e "  ${ICON_WARN} ${Y}Keep your private key safe!${N}"
            fi
            ;;
            
        6) # Hash generator
            echo -ne "  ${ICON_FILE} ${W}Enter text or file path: ${C}"
            read hash_input
            echo -e "${N}"
            
            cyber_loader "Computing hashes" 2
            
            echo -e "  ${ICON_DNA} ${BOLD}${W}HASH RESULTS:${N}"
            echo -e "  ${DIM}──────────────────────────────────────${N}"
            
            if [ -f "$hash_input" ]; then
                echo -e "  ${W}MD5:    ${C}$(md5sum "$hash_input" 2>/dev/null | cut -d' ' -f1 || echo 'N/A')${N}"
                echo -e "  ${W}SHA1:   ${C}$(sha1sum "$hash_input" 2>/dev/null | cut -d' ' -f1 || echo 'N/A')${N}"
                echo -e "  ${W}SHA256: ${C}$(sha256sum "$hash_input" 2>/dev/null | cut -d' ' -f1 || echo 'N/A')${N}"
                echo -e "  ${W}SHA512: ${C}$(sha512sum "$hash_input" 2>/dev/null | cut -d' ' -f1 || echo 'N/A')${N}"
            else
                echo -e "  ${W}MD5:    ${C}$(echo -n "$hash_input" | md5sum | cut -d' ' -f1)${N}"
                echo -e "  ${W}SHA1:   ${C}$(echo -n "$hash_input" | sha1sum | cut -d' ' -f1)${N}"
                echo -e "  ${W}SHA256: ${C}$(echo -n "$hash_input" | sha256sum | cut -d' ' -f1)${N}"
                echo -e "  ${W}SHA512: ${C}$(echo -n "$hash_input" | sha512sum | cut -d' ' -f1)${N}"
            fi
            ;;
            
        8) # Password vault
            password_vault
            return
            ;;
            
        0) return ;;
    esac
    
    echo ""
    echo -e "  ${DIM}Press ${W}[ENTER]${DIM} to return...${N}"
    read
}

# ========================= PASSWORD VAULT =========================
password_vault() {
    local vault_file="$DB_DIR/vault.enc"
    local vault_temp="$CACHE_DIR/.vault_temp"
    
    clear
    show_banner
    draw_box "${ICON_KEY} NEXUS PASSWORD VAULT"
    echo -e "  ${C}║${N}"
    menu_item "1" "➕" "Add Entry" "Store new credentials"
    menu_item "2" "$ICON_SEARCH" "Search Entries" "Find stored passwords"
    menu_item "3" "$ICON_EYE" "List All" "View all entries"
    menu_item "4" "🎲" "Password Generator" "Create strong passwords"
    menu_item "5" "🗑️" "Delete Entry" "Remove credentials"
    menu_item "0" "$ICON_CROSS" "Back" ""
    echo -e "  ${C}║${N}"
    draw_box_end
    
    echo ""
    echo -ne "  ${ICON_BOLT} ${W}Select: ${C}"
    read vault_choice
    echo -e "${N}"
    
    case $vault_choice in
        1) # Add entry
            echo -ne "  ${W}Master password: ${C}"
            read -s master_pass
            echo ""
            echo -ne "  ${W}Service name: ${C}"
            read service_name
            echo -ne "  ${W}Username: ${C}"
            read username
            echo -ne "  ${W}Password (leave empty to generate): ${C}"
            read -s password
            echo ""
            
            if [ -z "$password" ]; then
                password=$(cat /dev/urandom | tr -dc 'A-Za-z0-9!@#$%^&*()_+-=' | head -c 24)
                echo -e "  ${ICON_CHECK} ${G}Generated: ${Y}${password}${N}"
            fi
            
            local entry="$(date +%Y-%m-%d_%H:%M)|${service_name}|${username}|${password}"
            
            # Decrypt existing, append, re-encrypt
            if [ -f "$vault_file" ]; then
                openssl enc -aes-256-cbc -d -a -salt -pbkdf2 -iter 100000 \
                    -in "$vault_file" -pass pass:"$master_pass" > "$vault_temp" 2>/dev/null
            fi
            
            echo "$entry" >> "$vault_temp"
            
            openssl enc -aes-256-cbc -a -salt -pbkdf2 -iter 100000 \
                -in "$vault_temp" -out "$vault_file" -pass pass:"$master_pass" 2>/dev/null
            
            rm -f "$vault_temp"
            
            echo -e "  ${ICON_CHECK} ${G}Entry saved securely!${N}"
            ;;
            
        3) # List all
            echo -ne "  ${W}Master password: ${C}"
            read -s master_pass
            echo ""
            echo ""
            
            if [ -f "$vault_file" ]; then
                local decrypted=$(openssl enc -aes-256-cbc -d -a -salt -pbkdf2 -iter 100000 \
                    -in "$vault_file" -pass pass:"$master_pass" 2>/dev/null)
                
                if [ -n "$decrypted" ]; then
                    printf "  ${C}%-12s %-20s %-20s %-25s${N}\n" "DATE" "SERVICE" "USERNAME" "PASSWORD"
                    echo -e "  ${DIM}──────────── ──────────────────── ──────────────────── ─────────────────────────${N}"
                    
                    echo "$decrypted" | while IFS='|' read -r date service user pass; do
                        printf "  ${DIM}%-12s${N} ${W}%-20s${N} ${C}%-20s${N} ${Y}%-25s${N}\n" "$date" "$service" "$user" "$pass"
                    done
                else
                    echo -e "  ${ICON_CROSS} ${R}Wrong master password!${N}"
                fi
            else
                echo -e "  ${ICON_INFO} ${Y}Vault is empty.${N}"
            fi
            ;;
            
        4) # Password generator
            echo -ne "  ${W}Password length (default 20): ${C}"
            read pass_len
            [ -z "$pass_len" ] && pass_len=20
            
            echo ""
            echo -e "  ${ICON_KEY} ${BOLD}${W}Generated Passwords:${N}"
            echo -e "  ${DIM}──────────────────────────────${N}"
            
            for i in $(seq 1 5); do
                local gen_pass=$(cat /dev/urandom | tr -dc 'A-Za-z0-9!@#$%^&*()_+-=[]{}|;:,.<>?' | head -c "$pass_len")
                local strength=0
                echo "$gen_pass" | grep -q '[a-z]' && strength=$((strength+1))
                echo "$gen_pass" | grep -q '[A-Z]' && strength=$((strength+1))
                echo "$gen_pass" | grep -q '[0-9]' && strength=$((strength+1))
                echo "$gen_pass" | grep -q '[^a-zA-Z0-9]' && strength=$((strength+1))
                
                local str_label="${R}Weak"
                [ $strength -ge 2 ] && str_label="${Y}Fair"
                [ $strength -ge 3 ] && str_label="${G}Strong"
                [ $strength -ge 4 ] && str_label="${G}${BOLD}Very Strong"
                
                echo -e "  ${DIM}${i}.${N} ${C}${gen_pass}${N}  ${DIM}[${N}${str_label}${N}${DIM}]${N}"
            done
            ;;
    esac
    
    echo ""
    echo -e "  ${DIM}Press ${W}[ENTER]${DIM} to return...${N}"
    read
}

# ========================= TOOL 3: GHOST WATCHER ==================
ghost_watcher() {
    clear
    show_banner
    draw_box "${ICON_GHOST} GHOST WATCHER - Real-time System Monitor"
    echo -e "  ${C}║${N}"
    menu_item "1" "$ICON_CHART" "Live Process Monitor" "htop-style viewer"
    menu_item "2" "$ICON_NET" "Network Traffic Monitor" "Real-time bandwidth"
    menu_item "3" "$ICON_FOLDER" "File System Watcher" "Monitor file changes"
    menu_item "4" "📡" "Connection Tracker" "Active connections"
    menu_item "5" "$ICON_CLOCK" "Resource Logger" "Log system metrics"
    menu_item "6" "🔔" "Alert System" "Set resource alerts"
    menu_item "0" "$ICON_CROSS" "Back" ""
    echo -e "  ${C}║${N}"
    draw_box_end
    
    echo ""
    echo -ne "  ${ICON_BOLT} ${W}Select: ${C}"
    read gw_choice
    echo -e "${N}"
    
    case $gw_choice in
        1) # Live process monitor
            echo -e "  ${ICON_GHOST} ${W}Live Process Monitor ${DIM}(Ctrl+C to exit)${N}"
            echo ""
            
            trap "tput cnorm; return" INT
            tput civis
            
            while true; do
                tput cup 6 0
                echo -e "  ${C}┌──────────────────────────────────────────────────────────────────────┐${N}"
                echo -e "  ${C}│${N} ${BOLD}${W}PID      CPU%   MEM%   STATE   COMMAND${N}                               ${C}│${N}"
                echo -e "  ${C}├──────────────────────────────────────────────────────────────────────┤${N}"
                
                ps aux 2>/dev/null | sort -k3 -rn | head -15 | while read user pid cpu mem vsz rss tty stat start time cmd; do
                    local cpu_color="$G"
                    [ $(echo "$cpu > 50" | bc 2>/dev/null || echo 0) -eq 1 ] && cpu_color="$Y"
                    [ $(echo "$cpu > 80" | bc 2>/dev/null || echo 0) -eq 1 ] && cpu_color="$R"
                    
                    printf "  ${C}│${N} ${W}%-8s${N} ${cpu_color}%-6s${N} ${Y}%-6s${N} ${DIM}%-7s${N} ${C}%-30s${N} ${C}│${N}\n" \
                        "$pid" "$cpu" "$mem" "$stat" "$(echo $cmd | cut -c1-30)"
                done
                
                echo -e "  ${C}└──────────────────────────────────────────────────────────────────────┘${N}"
                
                # System summary
                local total_procs=$(ps aux 2>/dev/null | wc -l)
                local mem_info=$(free -h 2>/dev/null | awk '/Mem:/{printf "%s/%s (%s%%)", $3, $2, int($3/$2*100)}')
                local load_avg=$(cat /proc/loadavg 2>/dev/null | awk '{print $1, $2, $3}' || echo "N/A")
                
                echo ""
                echo -e "  ${ICON_CHART} ${DIM}Processes:${N} ${W}${total_procs}${N} ${DIM}│${N} ${ICON_DNA} ${DIM}Memory:${N} ${W}${mem_info}${N} ${DIM}│${N} ${ICON_BOLT} ${DIM}Load:${N} ${W}${load_avg}${N}"
                echo -e "  ${DIM}Last updated: $(date '+%H:%M:%S') │ Refresh: 2s │ Ctrl+C to exit${N}"
                
                sleep 2
            done
            tput cnorm
            ;;
            
        2) # Network traffic
            echo -e "  ${ICON_NET} ${W}Network Traffic Monitor ${DIM}(Ctrl+C to exit)${N}"
            echo ""
            
            local iface=$(ip route 2>/dev/null | grep default | awk '{print $5}' | head -1)
            [ -z "$iface" ] && iface="wlan0"
            
            trap "tput cnorm; return" INT
            tput civis
            
            local prev_rx=0
            local prev_tx=0
            
            while true; do
                local rx=$(cat /sys/class/net/$iface/statistics/rx_bytes 2>/dev/null || echo 0)
                local tx=$(cat /sys/class/net/$iface/statistics/tx_bytes 2>/dev/null || echo 0)
                
                local rx_speed=0
                local tx_speed=0
                
                if [ $prev_rx -gt 0 ]; then
                    rx_speed=$(( (rx - prev_rx) / 1024 ))
                    tx_speed=$(( (tx - prev_tx) / 1024 ))
                fi
                
                prev_rx=$rx
                prev_tx=$tx
                
                # Format bytes
                local rx_total=""
                local tx_total=""
                
                if [ $rx -gt 1073741824 ]; then
                    rx_total="$(echo "scale=2; $rx/1073741824" | bc 2>/dev/null || echo "$((rx/1073741824))") GB"
                elif [ $rx -gt 1048576 ]; then
                    rx_total="$(echo "scale=2; $rx/1048576" | bc 2>/dev/null || echo "$((rx/1048576))") MB"
                else
                    rx_total="$((rx/1024)) KB"
                fi
                
                if [ $tx -gt 1073741824 ]; then
                    tx_total="$(echo "scale=2; $tx/1073741824" | bc 2>/dev/null || echo "$((tx/1073741824))") GB"
                elif [ $tx -gt 1048576 ]; then
                    tx_total="$(echo "scale=2; $tx/1048576" | bc 2>/dev/null || echo "$((tx/1048576))") MB"
                else
                    tx_total="$((tx/1024)) KB"
                fi
                
                tput cup 6 0
                echo -e "  ${C}╔══════════════════════════════════════════╗${N}"
                echo -e "  ${C}║${N}  ${ICON_NET} ${BOLD}Interface: ${W}${iface}${N}                     ${C}║${N}"
                echo -e "  ${C}╠══════════════════════════════════════════╣${N}"
                echo -e "  ${C}║${N}                                          ${C}║${N}"
                printf "  ${C}║${N}  ${G}▼ Download:${N} ${W}%-10s${N} ${DIM}(${G}%d KB/s${N}${DIM})${N}   ${C}║${N}\n" "$rx_total" "$rx_speed"
                printf "  ${C}║${N}  ${R}▲ Upload:  ${N} ${W}%-10s${N} ${DIM}(${R}%d KB/s${N}${DIM})${N}   ${C}║${N}\n" "$tx_total" "$tx_speed"
                echo -e "  ${C}║${N}                                          ${C}║${N}"
                
                # Speed visualization
                local rx_bar=$((rx_speed / 10))
                [ $rx_bar -gt 30 ] && rx_bar=30
                local tx_bar=$((tx_speed / 10))
                [ $tx_bar -gt 30 ] && tx_bar=30
                
                printf "  ${C}║${N}  ${G}DL: ${N}"
                for ((b=0;b<rx_bar;b++)); do printf "${G}█${N}"; done
                for ((b=rx_bar;b<30;b++)); do printf "${BK}░${N}"; done
                printf "  ${C}║${N}\n"
                
                printf "  ${C}║${N}  ${R}UL: ${N}"
                for ((b=0;b<tx_bar;b++)); do printf "${R}█${N}"; done
                for ((b=tx_bar;b<30;b++)); do printf "${BK}░${N}"; done
                printf "  ${C}║${N}\n"
                
                echo -e "  ${C}║${N}                                          ${C}║${N}"
                echo -e "  ${C}╚══════════════════════════════════════════╝${N}"
                echo ""
                echo -e "  ${DIM}Refresh: 1s │ Ctrl+C to exit${N}"
                
                sleep 1
            done
            tput cnorm
            ;;
            
        3) # File system watcher
            echo -ne "  ${ICON_FOLDER} ${W}Directory to watch (default: \$HOME): ${C}"
            read watch_dir
            [ -z "$watch_dir" ] && watch_dir="$HOME"
            echo -e "${N}"
            
            echo -e "  ${ICON_EYE} ${W}Watching: ${C}${watch_dir}${N}"
            echo -e "  ${DIM}Press Ctrl+C to stop${N}"
            echo ""
            
            # Create initial snapshot
            local snap1=$(mktemp)
            local snap2=$(mktemp)
            find "$watch_dir" -maxdepth 2 -type f -printf '%T@ %p\n' 2>/dev/null | sort > "$snap1"
            
            trap "rm -f $snap1 $snap2; return" INT
            
            while true; do
                sleep 3
                find "$watch_dir" -maxdepth 2 -type f -printf '%T@ %p\n' 2>/dev/null | sort > "$snap2"
                
                # Compare snapshots
                local new_files=$(comm -13 "$snap1" "$snap2" 2>/dev/null)
                local deleted_files=$(comm -23 "$snap1" "$snap2" 2>/dev/null)
                
                if [ -n "$new_files" ]; then
                    echo "$new_files" | while read ts filepath; do
                        echo -e "  ${G}[+]${N} ${ICON_FILE} ${W}Modified/Created:${N} ${C}$(basename "$filepath")${N} ${DIM}$(date '+%H:%M:%S')${N}"
                    done
                fi
                
                if [ -n "$deleted_files" ]; then
                    echo "$deleted_files" | while read ts filepath; do
                        echo -e "  ${R}[-]${N} ${ICON_FILE} ${W}Removed:${N} ${R}$(basename "$filepath")${N} ${DIM}$(date '+%H:%M:%S')${N}"
                    done
                fi
                
                cp "$snap2" "$snap1"
            done
            ;;
            
        4) # Connection tracker
            echo -e "  ${ICON_SATELLITE} ${BOLD}${W}Active Network Connections${N}"
            echo -e "  ${DIM}══════════════════════════════════════════════════════${N}"
            echo ""
            
            if command -v ss &>/dev/null; then
                printf "  ${C}%-8s %-25s %-25s %-10s${N}\n" "PROTO" "LOCAL ADDRESS" "REMOTE ADDRESS" "STATE"
                echo -e "  ${DIM}──────── ───────────────────────── ───────────────────────── ──────────${N}"
                
                ss -tunapo 2>/dev/null | tail -n +2 | head -30 | while read proto recvq sendq local_addr remote_addr state rest; do
                    local state_color="$G"
                    case $state in
                        ESTAB*) state_color="$G";;
                        LISTEN*) state_color="$C";;
                        TIME-WAIT*|CLOSE*) state_color="$Y";;
                        SYN*) state_color="$R";;
                    esac
                    printf "  ${W}%-8s${N} ${DIM}%-25s${N} ${W}%-25s${N} ${state_color}%-10s${N}\n" \
                        "$proto" "$local_addr" "$remote_addr" "$state"
                done
            else
                cat /proc/net/tcp 2>/dev/null | tail -n +2 | head -20 | while read sl local rem st rest; do
                    local local_ip=$(printf "%d.%d.%d.%d" 0x${local:6:2} 0x${local:4:2} 0x${local:2:2} 0x${local:0:2} 2>/dev/null)
                    local local_port=$((16#${local:9:4}))
                    local rem_ip=$(printf "%d.%d.%d.%d" 0x${rem:6:2} 0x${rem:4:2} 0x${rem:2:2} 0x${rem:0:2} 2>/dev/null)
                    local rem_port=$((16#${rem:9:4}))
                    
                    printf "  ${W}tcp${N}     ${DIM}%-25s${N} ${W}%-25s${N}\n" "${local_ip}:${local_port}" "${rem_ip}:${rem_port}"
                done
            fi
            ;;
            
        5) # Resource logger
            local log_file="$LOG_DIR/resources_$(date +%Y%m%d_%H%M%S).csv"
            echo "Timestamp,CPU_Load,Mem_Used_MB,Mem_Total_MB,Mem_Percent,Disk_Used,Disk_Total,Disk_Percent" > "$log_file"
            
            echo -e "  ${ICON_CHART} ${W}Resource Logger Started${N}"
            echo -e "  ${ICON_FILE} ${DIM}Logging to: ${log_file}${N}"
            echo -e "  ${DIM}Press Ctrl+C to stop${N}"
            echo ""
            
            trap "echo ''; echo -e '  ${ICON_CHECK} ${G}Log saved: ${DIM}${log_file}${N}'; return" INT
            
            local count=0
            while true; do
                count=$((count + 1))
                local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
                local cpu_load=$(cat /proc/loadavg 2>/dev/null | awk '{print $1}')
                local mem_data=$(free -m 2>/dev/null | awk '/Mem:/{printf "%s,%s,%.0f", $3, $2, $3/$2*100}')
                local disk_data=$(df -m "$HOME" 2>/dev/null | awk 'NR==2{printf "%s,%s,%s", $3, $2, $5}')
                
                echo "${timestamp},${cpu_load},${mem_data},${disk_data}" >> "$log_file"
                
                local mem_pct=$(echo "$mem_data" | cut -d',' -f3)
                local disk_pct=$(echo "$disk_data" | cut -d',' -f3 | tr -d '%')
                
                printf "\r  ${DIM}[${W}%05d${DIM}]${N} ${ICON_CLOCK} %s ${DIM}│${N} CPU: ${C}%s${N} ${DIM}│${N} MEM: ${Y}%s%%${N} ${DIM}│${N} DISK: ${G}%s${N}" \
                    "$count" "$timestamp" "$cpu_load" "$mem_pct" "${disk_pct}%"
                
                sleep 5
            done
            ;;
    esac
    
    echo ""
    echo -e "  ${DIM}Press ${W}[ENTER]${DIM} to return...${N}"
    read
}

# ========================= TOOL 4: VENOM SPIDER ===================
venom_spider() {
    clear
    show_banner
    draw_box "${ICON_SPIDER} VENOM SPIDER - Advanced Web Analyzer"
    echo -e "  ${C}║${N}"
    menu_item "1" "$ICON_NET" "Deep URL Analyzer" "Full website analysis"
    menu_item "2" "$ICON_SEARCH" "Directory Buster" "Find hidden paths"
    menu_item "3" "$ICON_DNA" "Technology Detector" "Identify web stack"
    menu_item "4" "$ICON_SHIELD" "Header Inspector" "Security header analysis"
    menu_item "5" "🔗" "Link Extractor" "Extract all links"
    menu_item "6" "📧" "Email Harvester" "Find email addresses"
    menu_item "7" "📸" "Screenshot Capture" "Webpage screenshot"
    menu_item "8" "🗺️" "Subdomain Finder" "Enumerate subdomains"
    menu_item "0" "$ICON_CROSS" "Back" ""
    echo -e "  ${C}║${N}"
    draw_box_end
    
    echo ""
    echo -ne "  ${ICON_BOLT} ${W}Select: ${C}"
    read vs_choice
    echo -e "${N}"
    
    case $vs_choice in
        1) # Deep URL analyzer
            echo -ne "  ${ICON_NET} ${W}Enter URL: ${C}"
            read url
            echo -e "${N}"
            
            [ -z "$url" ] && return
            [[ ! "$url" =~ ^https?:// ]] && url="http://$url"
            
            local report="$TOOLKIT_DIR/reports/spider_$(date +%Y%m%d_%H%M%S).txt"
            
            cyber_loader "Connecting to target" 1
            cyber_loader "Analyzing response" 2
            cyber_loader "Processing data" 1
            
            echo -e "  ${ICON_SPIDER} ${BOLD}${W}ANALYSIS RESULTS${N}"
            echo -e "  ${DIM}════════════════════════════════════════${N}"
            
            if command -v curl &>/dev/null; then
                # Response info
                local response=$(curl -sIL --max-time 10 -w "\n%{http_code}\n%{time_total}\n%{size_download}\n%{redirect_url}\n%{ssl_verify_result}\n%{content_type}" "$url" 2>/dev/null)
                local headers=$(curl -sI --max-time 10 "$url" 2>/dev/null)
                local http_code=$(echo "$response" | tail -6 | head -1)
                local time_total=$(echo "$response" | tail -5 | head -1)
                local size=$(echo "$response" | tail -4 | head -1)
                local redirect=$(echo "$response" | tail -3 | head -1)
                local ssl_result=$(echo "$response" | tail -2 | head -1)
                local content_type=$(echo "$response" | tail -1)
                
                # Status with color
                local status_color="$G"
                [ "${http_code:0:1}" = "3" ] && status_color="$Y"
                [ "${http_code:0:1}" = "4" ] && status_color="$R"
                [ "${http_code:0:1}" = "5" ] && status_color="$R"
                
                echo ""
                echo -e "  ${ICON_NET} ${W}URL:${N}           ${C}${url}${N}"
                echo -e "  ${ICON_CHART} ${W}Status:${N}        ${status_color}${http_code}${N}"
                echo -e "  ${ICON_CLOCK} ${W}Response:${N}      ${W}${time_total}s${N}"
                echo -e "  ${ICON_FILE} ${W}Content-Type:${N}  ${DIM}${content_type}${N}"
                [ -n "$redirect" ] && echo -e "  ${ICON_BOLT} ${W}Redirect:${N}      ${Y}${redirect}${N}"
                
                # Server info
                local server=$(echo "$headers" | grep -i "^server:" | cut -d: -f2- | tr -d '\r')
                local powered=$(echo "$headers" | grep -i "^x-powered-by:" | cut -d: -f2- | tr -d '\r')
                
                echo ""
                echo -e "  ${ICON_GEAR} ${BOLD}${W}SERVER INFO${N}"
                echo -e "  ${DIM}─────────────────────${N}"
                [ -n "$server" ] && echo -e "  ${W}Server:${N}      ${C}${server}${N}"
                [ -n "$powered" ] && echo -e "  ${W}Powered By:${N}  ${Y}${powered}${N}"
                
                # Security headers
                echo ""
                echo -e "  ${ICON_SHIELD} ${BOLD}${W}SECURITY HEADERS${N}"
                echo -e "  ${DIM}─────────────────────${N}"
                
                check_header() {
                    local header_name="$1"
                    local display_name="$2"
                    local value=$(echo "$headers" | grep -i "^${header_name}:" | cut -d: -f2- | tr -d '\r')
                    if [ -n "$value" ]; then
                        echo -e "  ${ICON_CHECK} ${G}${display_name}:${N}${DIM}${value}${N}"
                    else
                        echo -e "  ${ICON_CROSS} ${R}${display_name}: Missing${N}"
                    fi
                }
                
                check_header "strict-transport-security" "HSTS"
                check_header "content-security-policy" "CSP"
                check_header "x-frame-options" "X-Frame-Options"
                check_header "x-content-type-options" "X-Content-Type"
                check_header "x-xss-protection" "X-XSS-Protection"
                check_header "referrer-policy" "Referrer-Policy"
                check_header "permissions-policy" "Permissions-Policy"
                
                # DNS lookup
                echo ""
                echo -e "  ${ICON_SATELLITE} ${BOLD}${W}DNS INFO${N}"
                echo -e "  ${DIM}─────────────────────${N}"
                
                local domain=$(echo "$url" | awk -F/ '{print $3}')
                if command -v nslookup &>/dev/null; then
                    local ip=$(nslookup "$domain" 2>/dev/null | grep "Address:" | tail -1 | awk '{print $2}')
                    echo -e "  ${W}Domain:${N}  ${C}${domain}${N}"
                    echo -e "  ${W}IP:${N}      ${C}${ip}${N}"
                elif command -v host &>/dev/null; then
                    local ip=$(host "$domain" 2>/dev/null | grep "has address" | head -1 | awk '{print $4}')
                    echo -e "  ${W}Domain:${N}  ${C}${domain}${N}"
                    echo -e "  ${W}IP:${N}      ${C}${ip}${N}"
                fi
                
                # SSL check
                if [[ "$url" =~ ^https ]]; then
                    echo ""
                    echo -e "  ${ICON_LOCK} ${BOLD}${W}SSL/TLS INFO${N}"
                    echo -e "  ${DIM}─────────────────────${N}"
                    
                    local ssl_info=$(echo | openssl s_client -connect "${domain}:443" -servername "$domain" 2>/dev/null)
                    local ssl_subject=$(echo "$ssl_info" | openssl x509 -noout -subject 2>/dev/null | sed 's/subject=//')
                    local ssl_issuer=$(echo "$ssl_info" | openssl x509 -noout -issuer 2>/dev/null | sed 's/issuer=//')
                    local ssl_dates=$(echo "$ssl_info" | openssl x509 -noout -dates 2>/dev/null)
                    local ssl_expire=$(echo "$ssl_dates" | grep "notAfter" | cut -d= -f2)
                    
                    [ -n "$ssl_subject" ] && echo -e "  ${W}Subject:${N} ${DIM}${ssl_subject}${N}"
                    [ -n "$ssl_issuer" ] && echo -e "  ${W}Issuer:${N}  ${DIM}${ssl_issuer}${N}"
                    [ -n "$ssl_expire" ] && echo -e "  ${W}Expires:${N} ${Y}${ssl_expire}${N}"
                fi
                
                # Save report
                {
                    echo "VENOM SPIDER REPORT"
                    echo "==================="
                    echo "URL: $url"
                    echo "Date: $(date)"
                    echo ""
                    echo "HTTP Status: $http_code"
                    echo "Response Time: ${time_total}s"
                    echo "Server: $server"
                    echo ""
                    echo "FULL HEADERS:"
                    echo "$headers"
                } > "$report"
                
                echo ""
                echo -e "  ${ICON_FILE} ${DIM}Report: ${report}${N}"
            else
                echo -e "  ${ICON_CROSS} ${R}curl not found! Run: pkg install curl${N}"
            fi
            ;;
            
        2) # Directory buster
            echo -ne "  ${ICON_NET} ${W}Enter base URL: ${C}"
            read base_url
            echo -e "${N}"
            
            [ -z "$base_url" ] && return
            [[ ! "$base_url" =~ ^https?:// ]] && base_url="http://$base_url"
            base_url="${base_url%/}"
            
            local wordlist=(
                "admin" "login" "wp-admin" "administrator" "dashboard"
                "api" "api/v1" "api/v2" "graphql" "swagger"
                "config" "configuration" "settings" "setup" "install"
                "backup" "backups" "db" "database" "sql"
                "upload" "uploads" "files" "media" "images"
                "wp-content" "wp-includes" "wp-login.php" "xmlrpc.php"
                "robots.txt" "sitemap.xml" ".env" ".git" ".htaccess"
                "server-status" "server-info" "phpinfo.php" "info.php"
                "test" "testing" "staging" "dev" "debug"
                "console" "panel" "cpanel" "phpmyadmin" "adminer"
                "user" "users" "account" "accounts" "profile"
                "docs" "documentation" "help" "support" "faq"
                "static" "assets" "css" "js" "fonts"
                "node_modules" "vendor" "packages" "bower_components"
                ".well-known" "security.txt" "humans.txt" "manifest.json"
                "feed" "rss" "atom" "blog" "news"
                "cgi-bin" "bin" "scripts" "shell" "cmd"
                "tmp" "temp" "cache" "log" "logs"
            )
            
            local total=${#wordlist[@]}
            local found=0
            local scanned=0
            
            echo -e "  ${ICON_SEARCH} ${W}Busting ${C}${total}${W} paths on ${C}${base_url}${N}"
            echo ""
            
            for path in "${wordlist[@]}"; do
                scanned=$((scanned + 1))
                progress_bar $scanned $total "Scanning directories"
                
                local code=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 "${base_url}/${path}" 2>/dev/null)
                
                if [ "$code" != "404" ] && [ "$code" != "000" ]; then
                    found=$((found + 1))
                    local code_color="$G"
                    [ "${code:0:1}" = "3" ] && code_color="$Y"
                    [ "${code:0:1}" = "4" ] && code_color="$R"
                    [ "${code:0:1}" = "5" ] && code_color="$M"
                    
                    echo ""
                    echo -e "  ${ICON_CHECK} ${code_color}[${code}]${N} ${W}${base_url}/${C}${path}${N}"
                fi
            done
            
            echo ""
            echo ""
            echo -e "  ${ICON_CHART} ${W}Results: ${G}${found}${W} found / ${C}${total}${W} tested${N}"
            ;;
            
        5) # Link extractor
            echo -ne "  ${ICON_NET} ${W}Enter URL: ${C}"
            read url
            echo -e "${N}"
            
            [ -z "$url" ] && return
            [[ ! "$url" =~ ^https?:// ]] && url="http://$url"
            
            cyber_loader "Fetching page content" 2
            cyber_loader "Extracting links" 1
            
            local page_content=$(curl -sL --max-time 15 "$url" 2>/dev/null)
            
            echo -e "  ${ICON_SPIDER} ${BOLD}${W}EXTRACTED LINKS${N}"
            echo -e "  ${DIM}════════════════════════════════════════${N}"
            echo ""
            
            # Extract href links
            local links=$(echo "$page_content" | grep -oP 'href=["'"'"']\K[^"'"'"']+' | sort -u)
            local internal=0
            local external=0
            
            local domain=$(echo "$url" | awk -F/ '{print $3}')
            
            echo -e "  ${G}🔗 Internal Links:${N}"
            echo "$links" | while read link; do
                if [[ "$link" =~ ^/ ]] || [[ "$link" =~ $domain ]]; then
                    echo -e "    ${DIM}→${N} ${C}${link}${N}"
                    internal=$((internal+1))
                fi
            done
            
            echo ""
            echo -e "  ${Y}🌐 External Links:${N}"
            echo "$links" | while read link; do
                if [[ "$link" =~ ^https?:// ]] && [[ ! "$link" =~ $domain ]]; then
                    echo -e "    ${DIM}→${N} ${Y}${link}${N}"
                    external=$((external+1))
                fi
            done
            
            local total_links=$(echo "$links" | wc -l)
            echo ""
            echo -e "  ${ICON_CHART} ${W}Total links found: ${C}${total_links}${N}"
            ;;
            
        6) # Email harvester
            echo -ne "  ${ICON_NET} ${W}Enter URL: ${C}"
            read url
            echo -e "${N}"
            
            [ -z "$url" ] && return
            [[ ! "$url" =~ ^https?:// ]] && url="http://$url"
            
            cyber_loader "Scanning for email addresses" 3
            
            local page=$(curl -sL --max-time 15 "$url" 2>/dev/null)
            local emails=$(echo "$page" | grep -oP '[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}' | sort -u)
            
            echo -e "  ${ICON_SPIDER} ${BOLD}${W}HARVESTED EMAILS${N}"
            echo -e "  ${DIM}════════════════════════════════════════${N}"
            echo ""
            
            if [ -n "$emails" ]; then
                local count=0
                echo "$emails" | while read email; do
                    count=$((count+1))
                    echo -e "  ${ICON_CHECK} ${C}${email}${N}"
                done
                echo ""
                echo -e "  ${ICON_CHART} ${W}Total: ${G}$(echo "$emails" | wc -l)${W} email(s) found${N}"
            else
                echo -e "  ${ICON_INFO} ${Y}No email addresses found on this page.${N}"
            fi
            ;;
            
        8) # Subdomain finder
            echo -ne "  ${ICON_NET} ${W}Enter domain (e.g., example.com): ${C}"
            read domain
            echo -e "${N}"
            
            [ -z "$domain" ] && return
            
            local subdomains=(
                "www" "mail" "ftp" "smtp" "pop" "ns1" "ns2" "dns"
                "webmail" "admin" "portal" "api" "dev" "staging"
                "test" "blog" "shop" "store" "m" "mobile"
                "app" "cdn" "media" "img" "images" "static"
                "vpn" "remote" "gateway" "proxy" "ssh"
                "db" "database" "sql" "mysql" "mongo"
                "git" "svn" "jenkins" "ci" "deploy"
                "monitor" "status" "health" "docs" "help"
                "forum" "community" "support" "crm" "erp"
                "intranet" "internal" "corp" "office" "hr"
                "sso" "auth" "login" "accounts" "id"
                "cloud" "aws" "azure" "gcp" "s3"
                "backup" "archive" "old" "new" "beta"
                "sandbox" "demo" "preview" "stage" "uat"
            )
            
            local total=${#subdomains[@]}
            local found=0
            local found_list=""
            
            echo -e "  ${ICON_SEARCH} ${W}Checking ${C}${total}${W} subdomains for ${C}${domain}${N}"
            echo ""
            
            for sub in "${subdomains[@]}"; do
                found=$((found))
                progress_bar $((++scanned)) $total "Enumerating subdomains"
                
                local full="${sub}.${domain}"
                local result=$(host "$full" 2>/dev/null | grep "has address" | head -1)
                
                if [ -n "$result" ]; then
                    local ip=$(echo "$result" | awk '{print $4}')
                    found=$((found+1))
                    echo ""
                    echo -e "  ${ICON_CHECK} ${G}${full}${N} → ${C}${ip}${N}"
                    found_list="${found_list}${full} -> ${ip}\n"
                fi
            done
            
            echo ""
            echo ""
            echo -e "  ${ICON_CHART} ${W}Found ${G}${found}${W} subdomains out of ${C}${total}${W} checked${N}"
            
            if [ $found -gt 0 ]; then
                local sub_report="$TOOLKIT_DIR/reports/subdomains_${domain}_$(date +%Y%m%d).txt"
                echo -e "$found_list" > "$sub_report"
                echo -e "  ${ICON_FILE} ${DIM}Saved to: ${sub_report}${N}"
            fi
            ;;
    esac
    
    echo ""
    echo -e "  ${DIM}Press ${W}[ENTER]${DIM} to return...${N}"
    read
}

# ========================= TOOL 5: SHADOW FORGE ===================
shadow_forge() {
    clear
    show_banner
    draw_box "${ICON_FIRE} SHADOW FORGE - Payload & Script Generator"
    echo -e "  ${C}║${N}"
    menu_item "1" "🐍" "Python Script Generator" "Custom Python scripts"
    menu_item "2" "$ICON_TERMINAL" "Bash Script Forge" "Advanced bash scripts"
    menu_item "3" "🌐" "HTML/JS Payload Crafter" "Web payloads"
    menu_item "4" "📱" "Termux Automation" "Auto-task scripts"
    menu_item "5" "🔧" "One-liner Generator" "Powerful one-liners"
    menu_item "6" "📋" "Template Library" "Pre-built templates"
    menu_item "0" "$ICON_CROSS" "Back" ""
    echo -e "  ${C}║${N}"
    draw_box_end
    
    echo ""
    echo -ne "  ${ICON_BOLT} ${W}Select: ${C}"
    read sf_choice
    echo -e "${N}"
    
    case $sf_choice in
        1) # Python script generator
            clear
            show_banner
            echo -e "  ${M}🐍 ${BOLD}${W}PYTHON SCRIPT GENERATOR${N}"
            echo ""
            echo -e "  ${Y}[1]${N} Port Scanner"
            echo -e "  ${Y}[2]${N} File Organizer"
            echo -e "  ${Y}[3]${N} Web Scraper"
            echo -e "  ${Y}[4]${N} Password Generator"
            echo -e "  ${Y}[5]${N} System Info Collector"
            echo -e "  ${Y}[6]${N} Log Analyzer"
            echo ""
            echo -ne "  ${W}Choose template: ${C}"
            read py_choice
            echo -e "${N}"
            
            local py_file="$TOOLKIT_DIR/exports/nexus_$(date +%s).py"
            
            case $py_choice in
                1)
                    cat > "$py_file" << 'PYEOF'
#!/usr/bin/env python3
"""
NEXUS Port Scanner - Generated by Shadow Forge
Multi-threaded, fast, and efficient
"""

import socket
import threading
import sys
import time
from datetime import datetime
from concurrent.futures import ThreadPoolExecutor, as_completed

class NexusScanner:
    def __init__(self, target, port_range=(1, 1024), threads=100):
        self.target = target
        self.port_range = port_range
        self.threads = threads
        self.open_ports = []
        self.lock = threading.Lock()
        self.scanned = 0
        self.total = port_range[1] - port_range[0] + 1
    
    def scan_port(self, port):
        try:
            sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            sock.settimeout(1)
            result = sock.connect_ex((self.target, port))
            sock.close()
            
            with self.lock:
                self.scanned += 1
            
            if result == 0:
                try:
                    service = socket.getservbyport(port)
                except:
                    service = "unknown"
                
                with self.lock:
                    self.open_ports.append((port, service))
                    print(f"  \033[1;32m[OPEN]\033[0m Port {port}/tcp -> {service}")
                return True
        except Exception:
            pass
        return False
    
    def run(self):
        print(f"\n  \033[1;36m{'='*50}\033[0m")
        print(f"  \033[1;37mNEXUS PORT SCANNER\033[0m")
        print(f"  \033[1;36m{'='*50}\033[0m")
        print(f"  Target: \033[1;33m{self.target}\033[0m")
        print(f"  Range:  \033[1;33m{self.port_range[0]}-{self.port_range[1]}\033[0m")
        print(f"  Threads: \033[1;33m{self.threads}\033[0m")
        print(f"  Started: \033[1;33m{datetime.now()}\033[0m")
        print(f"  \033[1;36m{'='*50}\033[0m\n")
        
        start_time = time.time()
        
        with ThreadPoolExecutor(max_workers=self.threads) as executor:
            futures = {executor.submit(self.scan_port, port): port 
                      for port in range(self.port_range[0], self.port_range[1]+1)}
            
            for future in as_completed(futures):
                future.result()
        
        elapsed = time.time() - start_time
        
        print(f"\n  \033[1;36m{'='*50}\033[0m")
        print(f"  \033[1;32mScan Complete!\033[0m")
        print(f"  Open Ports: \033[1;33m{len(self.open_ports)}\033[0m")
        print(f"  Time: \033[1;33m{elapsed:.2f}s\033[0m")
        print(f"  \033[1;36m{'='*50}\033[0m")

if __name__ == "__main__":
    target = input("  Enter target IP: ") if len(sys.argv) < 2 else sys.argv[1]
    scanner = NexusScanner(target, (1, 1024), 200)
    scanner.run()
PYEOF
                    ;;
                2)
                    cat > "$py_file" << 'PYEOF'
#!/usr/bin/env python3
"""
NEXUS File Organizer - Generated by Shadow Forge
Automatically organizes files by type, date, or size
"""

import os
import shutil
from pathlib import Path
from datetime import datetime
import hashlib

CATEGORIES = {
    'Images': ['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.svg', '.webp', '.ico', '.tiff'],
    'Videos': ['.mp4', '.avi', '.mkv', '.mov', '.wmv', '.flv', '.webm', '.m4v'],
    'Audio': ['.mp3', '.wav', '.flac', '.aac', '.ogg', '.wma', '.m4a'],
    'Documents': ['.pdf', '.doc', '.docx', '.xls', '.xlsx', '.ppt', '.pptx', '.txt', '.rtf', '.odt'],
    'Archives': ['.zip', '.rar', '.7z', '.tar', '.gz', '.bz2', '.xz'],
    'Code': ['.py', '.js', '.html', '.css', '.java', '.cpp', '.c', '.h', '.sh', '.rb', '.go', '.rs'],
    'Data': ['.json', '.xml', '.csv', '.yaml', '.yml', '.sql', '.db', '.sqlite'],
    'Executables': ['.exe', '.msi', '.deb', '.apk', '.dmg', '.AppImage'],
    'Fonts': ['.ttf', '.otf', '.woff', '.woff2', '.eot'],
}

class FileOrganizer:
    def __init__(self, source_dir):
        self.source = Path(source_dir)
        self.stats = {'moved': 0, 'skipped': 0, 'errors': 0}
    
    def get_category(self, ext):
        for category, extensions in CATEGORIES.items():
            if ext.lower() in extensions:
                return category
        return 'Others'
    
    def organize(self):
        print(f"\n  Organizing: {self.source}")
        print(f"  {'='*40}")
        
        for item in self.source.iterdir():
            if item.is_file() and item.name != os.path.basename(__file__):
                category = self.get_category(item.suffix)
                dest_dir = self.source / category
                dest_dir.mkdir(exist_ok=True)
                
                try:
                    dest = dest_dir / item.name
                    if dest.exists():
                        stem = item.stem
                        suffix = item.suffix
                        counter = 1
                        while dest.exists():
                            dest = dest_dir / f"{stem}_{counter}{suffix}"
                            counter += 1
                    
                    shutil.move(str(item), str(dest))
                    print(f"  ✓ {item.name} -> {category}/")
                    self.stats['moved'] += 1
                except Exception as e:
                    print(f"  ✗ Error: {item.name}: {e}")
                    self.stats['errors'] += 1
        
        print(f"\n  {'='*40}")
        print(f"  Moved: {self.stats['moved']} | Errors: {self.stats['errors']}")

if __name__ == "__main__":
    path = input("  Enter directory path (or . for current): ").strip() or "."
    organizer = FileOrganizer(path)
    organizer.organize()
PYEOF
                    ;;
                    
                5)
                    cat > "$py_file" << 'PYEOF'
#!/usr/bin/env python3
"""
NEXUS System Info Collector - Generated by Shadow Forge
"""

import os
import platform
import socket
import subprocess
import json
from datetime import datetime

class SystemCollector:
    def __init__(self):
        self.data = {}
    
    def collect_all(self):
        self.data['timestamp'] = datetime.now().isoformat()
        self.data['platform'] = {
            'system': platform.system(),
            'release': platform.release(),
            'version': platform.version(),
            'machine': platform.machine(),
            'processor': platform.processor(),
            'python': platform.python_version(),
        }
        self.data['hostname'] = socket.gethostname()
        
        try:
            self.data['cpu_count'] = os.cpu_count()
        except: pass
        
        try:
            with open('/proc/meminfo') as f:
                for line in f:
                    if 'MemTotal' in line:
                        self.data['memory_total'] = line.split()[1] + ' kB'
                    if 'MemAvailable' in line:
                        self.data['memory_available'] = line.split()[1] + ' kB'
        except: pass
        
        try:
            result = subprocess.run(['df', '-h', '/'], capture_output=True, text=True)
            self.data['disk'] = result.stdout
        except: pass
        
        try:
            s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
            s.connect(("8.8.8.8", 80))
            self.data['local_ip'] = s.getsockname()[0]
            s.close()
        except: pass
        
        self.data['env_vars'] = dict(os.environ)
        
        return self.data
    
    def display(self):
        data = self.collect_all()
        print("\n" + "="*50)
        print("  NEXUS SYSTEM INFO REPORT")
        print("="*50)
        
        for key, value in data.items():
            if key == 'env_vars':
                continue
            if isinstance(value, dict):
                print(f"\n  [{key.upper()}]")
                for k, v in value.items():
                    print(f"    {k}: {v}")
            else:
                print(f"  {key}: {value}")
        
        # Save JSON
        report_file = f"sysinfo_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
        with open(report_file, 'w') as f:
            json.dump(data, f, indent=2, default=str)
        print(f"\n  Report saved: {report_file}")

if __name__ == "__main__":
    collector = SystemCollector()
    collector.display()
PYEOF
                    ;;
            esac
            
            if [ -f "$py_file" ]; then
                chmod +x "$py_file"
                echo -e "  ${ICON_CHECK} ${G}Script generated!${N}"
                echo -e "  ${ICON_FILE} ${W}Path: ${C}${py_file}${N}"
                echo -e "  ${ICON_ROCKET} ${DIM}Run with: python3 ${py_file}${N}"
            fi
            ;;
            
        4) # Termux automation
            clear
            show_banner
            echo -e "  ${ICON_GEAR} ${BOLD}${W}TERMUX AUTOMATION GENERATOR${N}"
            echo ""
            echo -e "  ${Y}[1]${N} Auto System Maintenance"
            echo -e "  ${Y}[2]${N} Scheduled Backup Script"
            echo -e "  ${Y}[3]${N} Battery Monitor & Alert"
            echo -e "  ${Y}[4]${N} WiFi Auto-Connect"
            echo -e "  ${Y}[5]${N} Storage Cleaner"
            echo ""
            echo -ne "  ${W}Choose: ${C}"
            read auto_choice
            echo -e "${N}"
            
            local auto_file="$TOOLKIT_DIR/exports/auto_$(date +%s).sh"
            
            case $auto_choice in
                1)
                    cat > "$auto_file" << 'AUTOEOF'
#!/data/data/com.termux/files/usr/bin/bash
# NEXUS Auto System Maintenance
# Run periodically with cron or termux-job-scheduler

LOG="$HOME/.nexus-toolkit/logs/maintenance_$(date +%Y%m%d).log"
mkdir -p "$(dirname "$LOG")"

echo "=== Maintenance Started: $(date) ===" >> "$LOG"

# Update packages
echo "[*] Updating packages..." >> "$LOG"
apt update -y >> "$LOG" 2>&1
apt upgrade -y >> "$LOG" 2>&1

# Clean package cache
echo "[*] Cleaning package cache..." >> "$LOG"
apt autoclean -y >> "$LOG" 2>&1
apt autoremove -y >> "$LOG" 2>&1

# Clean temp files
echo "[*] Cleaning temp files..." >> "$LOG"
find /tmp -type f -mtime +7 -delete 2>/dev/null
find "$HOME" -name "*.tmp" -mtime +3 -delete 2>/dev/null
find "$HOME" -name "*.log" -size +50M -exec truncate -s 10M {} \; 2>/dev/null

# Clean old logs
echo "[*] Rotating logs..." >> "$LOG"
find "$HOME/.nexus-toolkit/logs" -name "*.log" -mtime +30 -delete 2>/dev/null

# Check disk space
DISK_USAGE=$(df -h "$HOME" | awk 'NR==2{print $5}' | tr -d '%')
if [ "$DISK_USAGE" -gt 90 ]; then
    echo "[ALERT] Disk usage at ${DISK_USAGE}%!" >> "$LOG"
    termux-notification --title "⚠️ Disk Space Alert" \
        --content "Storage at ${DISK_USAGE}% capacity!" 2>/dev/null
fi

# Check memory
MEM_USAGE=$(free | awk '/Mem:/{printf "%.0f", $3/$2*100}')
echo "[*] Memory usage: ${MEM_USAGE}%" >> "$LOG"

echo "=== Maintenance Complete: $(date) ===" >> "$LOG"
echo "" >> "$LOG"

termux-notification --title "✅ Maintenance Complete" \
    --content "Disk: ${DISK_USAGE}% | Mem: ${MEM_USAGE}%" 2>/dev/null
AUTOEOF
                    ;;
                    
                3)
                    cat > "$auto_file" << 'AUTOEOF'
#!/data/data/com.termux/files/usr/bin/bash
# NEXUS Battery Monitor & Alert
# Monitors battery and sends notifications

ALERT_LOW=20
ALERT_CRITICAL=10
CHECK_INTERVAL=300  # 5 minutes
LOG="$HOME/.nexus-toolkit/logs/battery.log"

echo "Battery Monitor Started: $(date)"

while true; do
    BAT_JSON=$(termux-battery-status 2>/dev/null)
    
    if [ -n "$BAT_JSON" ]; then
        LEVEL=$(echo "$BAT_JSON" | grep -o '"percentage":[0-9]*' | grep -o '[0-9]*')
        STATUS=$(echo "$BAT_JSON" | grep -o '"status":"[^"]*"' | cut -d'"' -f4)
        TEMP=$(echo "$BAT_JSON" | grep -o '"temperature":[0-9.]*' | grep -o '[0-9.]*')
        
        echo "$(date '+%H:%M:%S') | Level: ${LEVEL}% | Status: ${STATUS} | Temp: ${TEMP}°C" >> "$LOG"
        
        if [ "$LEVEL" -le "$ALERT_CRITICAL" ] && [ "$STATUS" != "CHARGING" ]; then
            termux-notification --title "🔴 CRITICAL BATTERY" \
                --content "Battery at ${LEVEL}%! Charge immediately!" \
                --priority high 2>/dev/null
            termux-vibrate -d 1000 2>/dev/null
            termux-tts-speak "Critical battery level at ${LEVEL} percent" 2>/dev/null
            
        elif [ "$LEVEL" -le "$ALERT_LOW" ] && [ "$STATUS" != "CHARGING" ]; then
            termux-notification --title "⚠️ Low Battery" \
                --content "Battery at ${LEVEL}%. Consider charging." 2>/dev/null
        fi
        
        if [ "$LEVEL" -eq 100 ] && [ "$STATUS" = "CHARGING" ]; then
            termux-notification --title "✅ Fully Charged" \
                --content "Battery at 100%. You can unplug now." 2>/dev/null
        fi
        
        # Temperature alert
        if [ "$(echo "$TEMP > 45" | bc 2>/dev/null)" = "1" ]; then
            termux-notification --title "🌡️ Overheating!" \
                --content "Battery temp: ${TEMP}°C - Let device cool down!" \
                --priority high 2>/dev/null
        fi
    fi
    
    sleep $CHECK_INTERVAL
done
AUTOEOF
                    ;;
                    
                5)
                    cat > "$auto_file" << 'AUTOEOF'
#!/data/data/com.termux/files/usr/bin/bash
# NEXUS Smart Storage Cleaner

R='\033[1;31m'
G='\033[1;32m'
Y='\033[1;33m'
C='\033[1;36m'
W='\033[1;37m'
N='\033[0m'
DIM='\033[2m'

echo -e "\n  ${C}╔════════════════════════════════════╗${N}"
echo -e "  ${C}║${N}  🧹 ${W}NEXUS STORAGE CLEANER${N}          ${C}║${N}"
echo -e "  ${C}╚════════════════════════════════════╝${N}\n"

FREED=0

# Function to get size in KB
get_size() {
    du -sk "$1" 2>/dev/null | cut -f1
}

clean_category() {
    local name="$1"
    local path="$2"
    local pattern="$3"
    
    if [ -d "$path" ]; then
        local before=$(get_size "$path")
        find "$path" -name "$pattern" -type f -delete 2>/dev/null
        local after=$(get_size "$path")
        local saved=$(( (before - after) ))
        [ $saved -gt 0 ] && FREED=$((FREED + saved))
        echo -e "  ${G}✓${N} ${W}${name}:${N} ${Y}${saved} KB freed${N}"
    fi
}

# Check initial space
BEFORE=$(df -k "$HOME" | awk 'NR==2{print $4}')

echo -e "  ${W}Scanning for cleanable files...${N}\n"

# Clean various caches
clean_category "APT Cache" "$PREFIX/var/cache/apt" "*.deb"
clean_category "Python Cache" "$HOME" "__pycache__"
clean_category "Thumbnail Cache" "$HOME" ".thumbnails"
clean_category "Temp Files" "/tmp" "*"
clean_category "Log Files (>30d)" "$HOME" "*.log"

# Find large files
echo -e "\n  ${C}📊 Large files (>50MB):${N}"
find "$HOME" -type f -size +50M 2>/dev/null | head -10 | while read f; do
    SIZE=$(du -sh "$f" 2>/dev/null | cut -f1)
    echo -e "    ${Y}${SIZE}${N}\t${DIM}${f}${N}"
done

# Find duplicate files (by size+name)
echo -e "\n  ${C}📋 Potential duplicates:${N}"
find "$HOME" -type f -not -path "*/\.*" 2>/dev/null | \
    xargs md5sum 2>/dev/null | sort | uniq -w32 -d | head -5 | while read hash file; do
    echo -e "    ${R}DUP${N} ${DIM}${file}${N}"
done

# Results
AFTER=$(df -k "$HOME" | awk 'NR==2{print $4}')
TOTAL_FREED=$(( AFTER - BEFORE ))

echo -e "\n  ${C}════════════════════════════════════${N}"
echo -e "  ${G}✅ Cleaning complete!${N}"
echo -e "  ${W}Space freed: ${G}~${FREED} KB${N}"
echo -e "  ${W}Available:   ${C}$(df -h "$HOME" | awk 'NR==2{print $4}')${N}"
echo -e "  ${C}════════════════════════════════════${N}\n"
AUTOEOF
                    ;;
            esac
            
            if [ -f "$auto_file" ]; then
                chmod +x "$auto_file"
                echo -e "  ${ICON_CHECK} ${G}Automation script generated!${N}"
                echo -e "  ${ICON_FILE} ${W}Path: ${C}${auto_file}${N}"
                echo -e "  ${ICON_ROCKET} ${DIM}Run with: bash ${auto_file}${N}"
            fi
            ;;
            
        5) # One-liner generator
            clear
            show_banner
            echo -e "  ${ICON_BOLT} ${BOLD}${W}POWERFUL ONE-LINERS${N}"
            echo -e "  ${DIM}══════════════════════════════════════${N}"
            echo ""
            
            echo -e "  ${Y}[Network]${N}"
            echo -e "  ${DIM}1.${N} ${C}curl -s ifconfig.me${N} ${DIM}# Public IP${N}"
            echo -e "  ${DIM}2.${N} ${C}ss -tunapl | awk 'NR>1{print \$5}' | cut -d: -f2 | sort -un${N} ${DIM}# Open ports${N}"
            echo -e "  ${DIM}3.${N} ${C}arp -a 2>/dev/null || ip neigh show${N} ${DIM}# Local devices${N}"
            echo ""
            
            echo -e "  ${Y}[Files]${N}"
            echo -e "  ${DIM}4.${N} ${C}find . -type f -name '*.log' -exec wc -l {} + | sort -rn | head${N} ${DIM}# Largest logs${N}"
            echo -e "  ${DIM}5.${N} ${C}find . -type f -printf '%s %p\n' | sort -rn | head -20${N} ${DIM}# Largest files${N}"
            echo -e "  ${DIM}6.${N} ${C}find . -type f -mmin -60${N} ${DIM}# Files modified in last hour${N}"
            echo -e "  ${DIM}7.${N} ${C}find . -empty -type f -delete${N} ${DIM}# Delete empty files${N}"
            echo ""
            
            echo -e "  ${Y}[System]${N}"
            echo -e "  ${DIM}8.${N} ${C}ps aux | sort -k3 -rn | head -10${N} ${DIM}# Top CPU processes${N}"
            echo -e "  ${DIM}9.${N} ${C}watch -n1 'cat /proc/meminfo | head -5'${N} ${DIM}# Live memory${N}"
            echo -e "  ${DIM}10.${N} ${C}history | awk '{print \$2}' | sort | uniq -c | sort -rn | head${N} ${DIM}# Most used commands${N}"
            echo ""
            
            echo -e "  ${Y}[Security]${N}"
            echo -e "  ${DIM}11.${N} ${C}openssl rand -base64 32${N} ${DIM}# Random password${N}"
            echo -e "  ${DIM}12.${N} ${C}find / -perm -4000 2>/dev/null${N} ${DIM}# SUID files${N}"
            echo -e "  ${DIM}13.${N} ${C}last -a | head -20${N} ${DIM}# Login history${N}"
            echo ""
            
            echo -e "  ${Y}[Text Processing]${N}"
            echo -e "  ${DIM}14.${N} ${C}cat file | tr '[:upper:]' '[:lower:]' | tr -cs '[:alpha:]' '\n' | sort | uniq -c | sort -rn | head${N} ${DIM}# Word freq${N}"
            echo -e "  ${DIM}15.${N} ${C}awk '!seen[\$0]++' file${N} ${DIM}# Remove duplicates (keep order)${N}"
            ;;
    esac
    
    echo ""
    echo -e "  ${DIM}Press ${W}[ENTER]${DIM} to return...${N}"
    read
}

# ========================= TOOL 6: CHRONO VAULT ===================
chrono_vault() {
    clear
    show_banner
    draw_box "${ICON_CLOCK} CHRONO VAULT - Smart Backup Engine"
    echo -e "  ${C}║${N}"
    menu_item "1" "💾" "Full System Backup" "Backup entire Termux"
    menu_item "2" "$ICON_FOLDER" "Selective Backup" "Choose directories"
    menu_item "3" "⏪" "Restore Backup" "Restore from archive"
    menu_item "4" "📋" "List Backups" "View all backups"
    menu_item "5" "🔄" "Auto-Backup Setup" "Schedule backups"
    menu_item "6" "☁️" "Cloud Sync" "Sync to remote"
    menu_item "0" "$ICON_CROSS" "Back" ""
    echo -e "  ${C}║${N}"
    draw_box_end
    
    echo ""
    echo -ne "  ${ICON_BOLT} ${W}Select: ${C}"
    read cv_choice
    echo -e "${N}"
    
    case $cv_choice in
        1) # Full backup
            local backup_name="nexus_full_$(date +%Y%m%d_%H%M%S)"
            local backup_file="$BACKUP_DIR/${backup_name}.tar.gz"
            
            echo -e "  ${ICON_WARN} ${Y}This will backup your entire home directory.${N}"
            echo -ne "  ${W}Continue? (y/n): ${C}"
            read confirm
            echo -e "${N}"
            
            [ "$confirm" != "y" ] && return
            
            echo -e "  ${ICON_FOLDER} ${W}Calculating size...${N}"
            local total_size=$(du -sh "$HOME" 2>/dev/null | cut -f1)
            echo -e "  ${ICON_CHART} ${W}Total size: ${C}${total_size}${N}"
            echo ""
            
            cyber_loader "Compressing files" 3
            
            tar czf "$backup_file" \
                --exclude="$BACKUP_DIR" \
                --exclude=".cache" \
                --exclude="node_modules" \
                --exclude=".npm" \
                -C "$HOME" . 2>/dev/null
            
            if [ $? -eq 0 ]; then
                local backup_size=$(du -sh "$backup_file" | cut -f1)
                
                # Generate checksum
                local checksum=$(sha256sum "$backup_file" | cut -d' ' -f1)
                echo "$checksum" > "${backup_file}.sha256"
                
                # Backup metadata
                cat > "${backup_file}.meta" << META
BACKUP_NAME=$backup_name
BACKUP_TYPE=full
BACKUP_DATE=$(date)
BACKUP_SIZE=$backup_size
ORIGINAL_SIZE=$total_size
CHECKSUM=$checksum
HOSTNAME=$(hostname 2>/dev/null)
META
                
                echo -e "  ${ICON_CHECK} ${G}Backup complete!${N}"
                echo -e "  ${ICON_FILE} ${W}File: ${C}${backup_file}${N}"
                echo -e "  ${ICON_CHART} ${W}Size: ${Y}${total_size} → ${G}${backup_size}${N}"
                echo -e "  ${ICON_SHIELD} ${DIM}SHA256: ${checksum:0:16}...${N}"
            else
                echo -e "  ${ICON_CROSS} ${R}Backup failed!${N}"
            fi
            ;;
            
        2) # Selective backup
            echo -e "  ${ICON_FOLDER} ${W}Enter directories to backup (space-separated):${N}"
            echo -ne "  ${C}"
            read -a dirs
            echo -e "${N}"
            
            if [ ${#dirs[@]} -eq 0 ]; then
                echo -e "  ${ICON_CROSS} ${R}No directories specified!${N}"
                sleep 2
                return
            fi
            
            local backup_name="nexus_sel_$(date +%Y%m%d_%H%M%S)"
            local backup_file="$BACKUP_DIR/${backup_name}.tar.gz"
            
            local valid_dirs=()
            for dir in "${dirs[@]}"; do
                if [ -d "$dir" ]; then
                    valid_dirs+=("$dir")
                    echo -e "  ${ICON_CHECK} ${G}Including: ${W}${dir}${N}"
                else
                    echo -e "  ${ICON_CROSS} ${R}Not found: ${W}${dir}${N}"
                fi
            done
            
            if [ ${#valid_dirs[@]} -eq 0 ]; then
                echo -e "  ${ICON_CROSS} ${R}No valid directories!${N}"
                sleep 2
                return
            fi
            
            echo ""
            cyber_loader "Creating selective backup" 2
            
            tar czf "$backup_file" "${valid_dirs[@]}" 2>/dev/null
            
            if [ $? -eq 0 ]; then
                local backup_size=$(du -sh "$backup_file" | cut -f1)
                echo -e "  ${ICON_CHECK} ${G}Selective backup complete!${N}"
                echo -e "  ${ICON_FILE} ${W}File: ${C}${backup_file}${N}"
                echo -e "  ${ICON_CHART} ${W}Size: ${G}${backup_size}${N}"
            fi
            ;;
            
        3) # Restore
            echo -e "  ${ICON_FOLDER} ${W}Available backups:${N}"
            echo ""
            
            local backups=($(ls -1 "$BACKUP_DIR"/*.tar.gz 2>/dev/null))
            
            if [ ${#backups[@]} -eq 0 ]; then
                echo -e "  ${ICON_INFO} ${Y}No backups found.${N}"
                sleep 2
                return
            fi
            
            for i in "${!backups[@]}"; do
                local bname=$(basename "${backups[$i]}")
                local bsize=$(du -sh "${backups[$i]}" | cut -f1)
                local bdate=$(stat -c %y "${backups[$i]}" 2>/dev/null | cut -d. -f1)
                echo -e "  ${Y}[$((i+1))]${N} ${W}${bname}${N} ${DIM}(${bsize}, ${bdate})${N}"
            done
            
            echo ""
            echo -ne "  ${W}Select backup number: ${C}"
            read backup_num
            echo -e "${N}"
            
            local idx=$((backup_num - 1))
            if [ $idx -ge 0 ] && [ $idx -lt ${#backups[@]} ]; then
                local selected="${backups[$idx]}"
                
                echo -e "  ${ICON_WARN} ${Y}This will restore files. Existing files may be overwritten.${N}"
                echo -ne "  ${W}Restore to (default: \$HOME): ${C}"
                read restore_path
                [ -z "$restore_path" ] && restore_path="$HOME"
                echo -e "${N}"
                
                # Verify checksum
                if [ -f "${selected}.sha256" ]; then
                    local stored_hash=$(cat "${selected}.sha256")
                    local current_hash=$(sha256sum "$selected" | cut -d' ' -f1)
                    
                    if [ "$stored_hash" = "$current_hash" ]; then
                        echo -e "  ${ICON_CHECK} ${G}Checksum verified!${N}"
                    else
                        echo -e "  ${ICON_CROSS} ${R}Checksum mismatch! Backup may be corrupted.${N}"
                        echo -ne "  ${W}Continue anyway? (y/n): ${C}"
                        read force
                        [ "$force" != "y" ] && return
                    fi
                fi
                
                cyber_loader "Restoring backup" 3
                
                tar xzf "$selected" -C "$restore_path" 2>/dev/null
                
                if [ $? -eq 0 ]; then
                    echo -e "  ${ICON_CHECK} ${G}Restore complete!${N}"
                    echo -e "  ${ICON_FOLDER} ${W}Restored to: ${C}${restore_path}${N}"
                else
                    echo -e "  ${ICON_CROSS} ${R}Restore failed!${N}"
                fi
            fi
            ;;
            
        4) # List backups
            echo -e "  ${ICON_FOLDER} ${BOLD}${W}BACKUP INVENTORY${N}"
            echo -e "  ${DIM}══════════════════════════════════════════════════════${N}"
            echo ""
            
            printf "  ${C}%-5s %-35s %-10s %-20s${N}\n" "#" "BACKUP NAME" "SIZE" "DATE"
            echo -e "  ${DIM}───── ─────────────────────────────────── ────────── ────────────────────${N}"
            
            local count=0
            local total_size=0
            
            for backup in "$BACKUP_DIR"/*.tar.gz; do
                [ ! -f "$backup" ] && continue
                count=$((count + 1))
                local bname=$(basename "$backup")
                local bsize=$(du -sh "$backup" | cut -f1)
                local bsize_k=$(du -sk "$backup" | cut -f1)
                local bdate=$(stat -c %y "$backup" 2>/dev/null | cut -d. -f1)
                total_size=$((total_size + bsize_k))
                
                local type_icon="💾"
                [[ "$bname" == *"full"* ]] && type_icon="📦"
                [[ "$bname" == *"sel"* ]] && type_icon="📁"
                
                printf "  ${W}%-5s${N} ${type_icon} ${DIM}%-33s${N} ${Y}%-10s${N} ${DIM}%-20s${N}\n" \
                    "$count" "$bname" "$bsize" "$bdate"
            done
            
            if [ $count -eq 0 ]; then
                echo -e "  ${ICON_INFO} ${Y}No backups found.${N}"
            else
                echo ""
                echo -e "  ${ICON_CHART} ${W}Total: ${C}${count}${W} backups, ${Y}$((total_size/1024)) MB${N}"
            fi
            ;;
    esac
    
    echo ""
    echo -e "  ${DIM}Press ${W}[ENTER]${DIM} to return...${N}"
    read
}

# ========================= TOOL 7: ZERO DAY PKG MANAGER ===========
pkg_manager() {
    clear
    show_banner
    draw_box "${ICON_PACKAGE} ZERO DAY - Advanced Package Manager"
    echo -e "  ${C}║${N}"
    menu_item "1" "📥" "Install Essentials" "All must-have packages"
    menu_item "2" "🐍" "Python Lab Setup" "Full Python environment"
    menu_item "3" "🌐" "Web Dev Setup" "Node, PHP, Apache stack"
    menu_item "4" "🔒" "Security Toolkit" "Pentesting tools"
    menu_item "5" "🎨" "CLI Powertools" "Terminal enhancement"
    menu_item "6" "📊" "Package Analytics" "Installed pkg analysis"
    menu_item "7" "🔄" "System Update" "Full system upgrade"
    menu_item "8" "🧹" "Package Cleanup" "Remove unused packages"
    menu_item "9" "📦" "Custom Install" "Install any package"
    menu_item "0" "$ICON_CROSS" "Back" ""
    echo -e "  ${C}║${N}"
    draw_box_end
    
    echo ""
    echo -ne "  ${ICON_BOLT} ${W}Select: ${C}"
    read pm_choice
    echo -e "${N}"
    
    install_packages() {
        local category="$1"
        shift
        local packages=("$@")
        local total=${#packages[@]}
        local installed=0
        local failed=0
        
        echo -e "  ${ICON_PACKAGE} ${W}Installing ${C}${category}${W} (${total} packages)${N}"
        echo ""
        
        for pkg in "${packages[@]}"; do
            installed=$((installed + 1))
            progress_bar $installed $total "Installing ${pkg}"
            
            if dpkg -l "$pkg" &>/dev/null 2>&1; then
                echo ""
                echo -e "  ${ICON_CHECK} ${DIM}${pkg} already installed${N}"
            else
                if apt install -y "$pkg" &>/dev/null 2>&1; then
                    echo ""
                    echo -e "  ${ICON_CHECK} ${G}${pkg} installed${N}"
                else
                    echo ""
                    echo -e "  ${ICON_CROSS} ${R}${pkg} failed${N}"
                    failed=$((failed + 1))
                fi
            fi
        done
        
        echo ""
        echo -e "  ${ICON_CHART} ${W}Results: ${G}$((total-failed))${W} success, ${R}${failed}${W} failed${N}"
    }
    
    case $pm_choice in
        1) # Essentials
            apt update -y &>/dev/null
            install_packages "Essentials" \
                "git" "curl" "wget" "openssh" "openssl-tool" "nano" "vim" \
                "htop" "tree" "zip" "unzip" "tar" "gzip" \
                "net-tools" "dnsutils" "nmap" "traceroute" \
                "bc" "jq" "ffmpeg" "imagemagick" "man" "which"
            ;;
            
        2) # Python
            apt update -y &>/dev/null
            install_packages "Python Lab" \
                "python" "python-pip" "python-dev" "clang" "libffi-dev"
            
            echo ""
            echo -e "  ${ICON_SNAKE} ${W}Installing Python packages...${N}"
            pip install --upgrade pip 2>/dev/null
            pip install requests beautifulsoup4 flask django scrapy \
                        numpy pandas matplotlib pillow cryptography \
                        paramiko pycryptodome colorama tqdm rich 2>/dev/null
            echo -e "  ${ICON_CHECK} ${G}Python environment ready!${N}"
            ;;
            
        3) # Web Dev
            apt update -y &>/dev/null
            install_packages "Web Dev" \
                "nodejs" "php" "apache2" "nginx" "ruby" \
                "sqlite" "postgresql" "mariadb"
            
            echo ""
            echo -e "  ${ICON_NET} ${W}Installing Node packages...${N}"
            npm install -g npm yarn nodemon express-generator \
                           create-react-app vue-cli http-server \
                           typescript ts-node 2>/dev/null
            echo -e "  ${ICON_CHECK} ${G}Web dev stack ready!${N}"
            ;;
            
        4) # Security
            apt update -y &>/dev/null
            install_packages "Security Toolkit" \
                "nmap" "hydra" "sqlmap" "john" "hashcat" \
                "aircrack-ng" "ettercap" "wireshark-cli" \
                "metasploit" "nikto" "dirb" "gobuster" \
                "tor" "proxychains-ng" "tcpdump" "netcat-openbsd"
            ;;
            
        5) # CLI powertools
            apt update -y &>/dev/null
            install_packages "CLI Powertools" \
                "zsh" "fish" "tmux" "screen" "neovim" \
                "ranger" "fzf" "bat" "exa" "ripgrep" \
                "fd" "tokei" "hyperfine" "procs" "bottom" \
                "neofetch" "figlet" "toilet" "cowsay" "lolcat" \
                "cmatrix" "sl" "fortune"
            ;;
            
        6) # Analytics
            echo -e "  ${ICON_CHART} ${BOLD}${W}PACKAGE ANALYTICS${N}"
            echo -e "  ${DIM}══════════════════════════════════════${N}"
            echo ""
            
            local total_pkg=$(dpkg -l 2>/dev/null | grep "^ii" | wc -l)
            local total_size=$(dpkg-query -W --showformat='${Installed-Size}\n' 2>/dev/null | awk '{s+=$1} END {print s}')
            
            echo -e "  ${ICON_PACKAGE} ${W}Total packages:${N} ${C}${total_pkg}${N}"
            echo -e "  ${ICON_FOLDER} ${W}Total size:${N}     ${Y}$((total_size/1024)) MB${N}"
            echo ""
            
            echo -e "  ${W}Top 15 largest packages:${N}"
            echo -e "  ${DIM}─────────────────────────────────────${N}"
            
            dpkg-query -W --showformat='${Installed-Size}\t${Package}\n' 2>/dev/null | \
                sort -rn | head -15 | while read size pkg; do
                local size_mb=$((size/1024))
                local bar_len=$((size/5000))
                [ $bar_len -gt 30 ] && bar_len=30
                
                printf "  ${W}%-25s${N} ${Y}%4dMB${N} ${DIM}[${G}" "$pkg" "$size_mb"
                for ((i=0;i<bar_len;i++)); do printf "█"; done
                printf "${N}${DIM}]${N}\n"
            done
            
            echo ""
            echo -e "  ${W}Recently installed:${N}"
            echo -e "  ${DIM}─────────────────────────────────────${N}"
            ls -lt /data/data/com.termux/files/usr/var/lib/dpkg/info/*.list 2>/dev/null | \
                head -10 | while read line; do
                local pkg=$(echo "$line" | awk '{print $NF}' | xargs basename | sed 's/.list$//')
                local date=$(echo "$line" | awk '{print $6, $7, $8}')
                echo -e "  ${DIM}${date}${N} ${C}${pkg}${N}"
            done
            ;;
            
        7) # Update
            echo -e "  ${ICON_GEAR} ${W}Full System Update${N}"
            echo ""
            
            cyber_loader "Updating repository lists" 2
            apt update -y 2>&1 | tail -3
            echo ""
            
            cyber_loader "Upgrading packages" 5
            apt upgrade -y 2>&1 | tail -5
            echo ""
            
            cyber_loader "Cleaning up" 1
            apt autoclean -y &>/dev/null
            apt autoremove -y &>/dev/null
            
            echo -e "  ${ICON_CHECK} ${G}System updated!${N}"
            ;;
            
        8) # Cleanup
            echo -e "  ${ICON_GEAR} ${W}Package Cleanup${N}"
            echo ""
            
            echo -e "  ${W}Orphaned packages:${N}"
            apt autoremove --dry-run 2>/dev/null | grep "^Remv" | while read line; do
                local pkg=$(echo "$line" | awk '{print $2}')
                echo -e "  ${DIM}  •${N} ${Y}${pkg}${N}"
            done
            
            echo ""
            echo -ne "  ${W}Remove orphaned packages? (y/n): ${C}"
            read confirm
            echo -e "${N}"
            
            if [ "$confirm" = "y" ]; then
                apt autoremove -y 2>/dev/null
                apt autoclean -y 2>/dev/null
                echo -e "  ${ICON_CHECK} ${G}Cleanup complete!${N}"
            fi
            ;;
            
        9) # Custom install
            echo -ne "  ${ICON_PACKAGE} ${W}Package name: ${C}"
            read pkg_name
            echo -e "${N}"
            
            if [ -n "$pkg_name" ]; then
                cyber_loader "Installing ${pkg_name}" 3
                apt install -y "$pkg_name" 2>&1 | tail -5
                
                if [ $? -eq 0 ]; then
                    echo -e "  ${ICON_CHECK} ${G}${pkg_name} installed!${N}"
                else
                    echo -e "  ${ICON_CROSS} ${R}Installation failed!${N}"
                fi
            fi
            ;;
    esac
    
    echo ""
    echo -e "  ${DIM}Press ${W}[ENTER]${DIM} to return...${N}"
    read
}

# ========================= TOOL 8: QUANTUM SHELL ==================
quantum_shell() {
    clear
    show_banner
    draw_box "${ICON_ATOM} QUANTUM SHELL - Enhanced Terminal"
    echo -e "  ${C}║${N}"
    menu_item "1" "🎨" "Shell Customizer" "Customize your prompt"
    menu_item "2" "⌨️" "Alias Manager" "Create/manage aliases"
    menu_item "3" "📜" "History Analytics" "Command usage stats"
    menu_item "4" "🔧" "Environment Setup" "Configure env variables"
    menu_item "5" "📁" "Bookmark Manager" "Quick directory access"
    menu_item "6" "⏰" "Task Scheduler" "Cron-like scheduling"
    menu_item "7" "📝" "Snippet Manager" "Save/run code snippets"
    menu_item "0" "$ICON_CROSS" "Back" ""
    echo -e "  ${C}║${N}"
    draw_box_end
    
    echo ""
    echo -ne "  ${ICON_BOLT} ${W}Select: ${C}"
    read qs_choice
    echo -e "${N}"
    
    case $qs_choice in
        1) # Shell customizer
            echo -e "  ${ICON_GEAR} ${BOLD}${W}SHELL CUSTOMIZER${N}"
            echo ""
            echo -e "  ${Y}[1]${N} Cyberpunk Theme"
            echo -e "  ${Y}[2]${N} Minimal Theme"
            echo -e "  ${Y}[3]${N} Powerline Theme"
            echo -e "  ${Y}[4]${N} Hacker Theme"
            echo -e "  ${Y}[5]${N} Custom Theme"
            echo ""
            echo -ne "  ${W}Choose theme: ${C}"
            read theme
            echo -e "${N}"
            
            local bashrc="$HOME/.bashrc"
            
            case $theme in
                1) # Cyberpunk
                    cat >> "$bashrc" << 'THEME'

# NEXUS Cyberpunk Theme
parse_git_branch() { git branch 2>/dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'; }
PS1='\[\033[1;36m\]╭─[\[\033[1;35m\]⚡\[\033[1;33m\]\u\[\033[1;36m\]@\[\033[1;32m\]\h\[\033[1;36m\]]-[\[\033[1;37m\]\w\[\033[1;36m\]]\[\033[1;33m\]$(parse_git_branch)\[\033[0m\]\n\[\033[1;36m\]╰─\[\033[1;31m\]λ\[\033[0m\] '
THEME
                    ;;
                2) # Minimal
                    cat >> "$bashrc" << 'THEME'

# NEXUS Minimal Theme
PS1='\[\033[1;32m\]→\[\033[0m\] \[\033[1;34m\]\W\[\033[0m\] \[\033[1;33m\]$\[\033[0m\] '
THEME
                    ;;
                3) # Powerline
                    cat >> "$bashrc" << 'THEME'

# NEXUS Powerline Theme
PS1='\[\033[48;5;236m\]\[\033[38;5;250m\] \u \[\033[48;5;31m\]\[\033[38;5;236m\]\[\033[38;5;15m\] \w \[\033[0m\]\[\033[38;5;31m\]\[\033[0m\] '
THEME
                    ;;
                4) # Hacker
                    cat >> "$bashrc" << 'THEME'

# NEXUS Hacker Theme  
PS1='\[\033[1;32m\]┌──[\[\033[1;31m\]💀\[\033[1;37m\]\u\[\033[1;32m\]]-[\[\033[1;33m\]\w\[\033[1;32m\]]\n└──╼\[\033[1;31m\]#\[\033[0m\] '
THEME
                    ;;
            esac
            
            echo -e "  ${ICON_CHECK} ${G}Theme applied! Restart terminal or run: source ~/.bashrc${N}"
            ;;
            
        2) # Alias manager
            local alias_file="$CONFIG_DIR/aliases.conf"
            touch "$alias_file"
            
            echo -e "  ${ICON_GEAR} ${BOLD}${W}ALIAS MANAGER${N}"
            echo ""
            echo -e "  ${Y}[1]${N} Add alias"
            echo -e "  ${Y}[2]${N} List aliases"
            echo -e "  ${Y}[3]${N} Remove alias"
            echo -e "  ${Y}[4]${N} Load preset aliases"
            echo ""
            echo -ne "  ${W}Choose: ${C}"
            read alias_opt
            echo -e "${N}"
            
            case $alias_opt in
                1)
                    echo -ne "  ${W}Alias name: ${C}"
                    read aname
                    echo -ne "  ${W}Command: ${C}"
                    read acmd
                    echo "alias ${aname}='${acmd}'" >> "$alias_file"
                    echo "alias ${aname}='${acmd}'" >> "$HOME/.bashrc"
                    echo -e "  ${ICON_CHECK} ${G}Alias '${aname}' created!${N}"
                    ;;
                2)
                    echo -e "  ${W}Current aliases:${N}"
                    echo ""
                    cat "$alias_file" 2>/dev/null | while read line; do
                        echo -e "  ${C}${line}${N}"
                    done
                    ;;
                4)
                    cat >> "$alias_file" << 'ALIASES'
alias ll='ls -lah --color=auto'
alias la='ls -A --color=auto'
alias ..='cd ..'
alias ...='cd ../..'
alias gs='git status'
alias ga='git add .'
alias gc='git commit -m'
alias gp='git push'
alias gl='git log --oneline -10'
alias py='python3'
alias pip='pip3'
alias cls='clear'
alias h='history'
alias myip='curl -s ifconfig.me'
alias ports='ss -tunapl'
alias mem='free -h'
alias dsk='df -h'
alias cpu='cat /proc/loadavg'
alias weather='curl -s wttr.in/?format=3'
alias speedtest='curl -s https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py | python3'
ALIASES
                    cat "$alias_file" >> "$HOME/.bashrc"
                    echo -e "  ${ICON_CHECK} ${G}Preset aliases loaded!${N}"
                    ;;
            esac
            ;;
            
        3) # History analytics
            echo -e "  ${ICON_CHART} ${BOLD}${W}COMMAND HISTORY ANALYTICS${N}"
            echo -e "  ${DIM}══════════════════════════════════════${N}"
            echo ""
            
            local total_cmds=$(wc -l < "$HOME/.bash_history" 2>/dev/null || echo 0)
            local unique_cmds=$(sort "$HOME/.bash_history" 2>/dev/null | uniq | wc -l || echo 0)
            
            echo -e "  ${ICON_CHART} ${W}Total commands:${N}  ${C}${total_cmds}${N}"
            echo -e "  ${ICON_CHART} ${W}Unique commands:${N} ${C}${unique_cmds}${N}"
            echo ""
            
            echo -e "  ${W}Top 20 most used commands:${N}"
            echo -e "  ${DIM}──────────────────────────────${N}"
            
            cat "$HOME/.bash_history" 2>/dev/null | \
                awk '{print $1}' | sort | uniq -c | sort -rn | head -20 | \
                while read count cmd; do
                    local bar_len=$((count / 5))
                    [ $bar_len -gt 25 ] && bar_len=25
                    
                    printf "  ${W}%5d${N} ${C}%-20s${N} ${DIM}[${G}" "$count" "$cmd"
                    for ((i=0;i<bar_len;i++)); do printf "█"; done
                    printf "${N}${DIM}]${N}\n"
                done
            
            echo ""
            echo -e "  ${W}Command categories:${N}"
            echo -e "  ${DIM}──────────────────────────────${N}"
            
            local git_cmds=$(grep -c "^git " "$HOME/.bash_history" 2>/dev/null || echo 0)
            local cd_cmds=$(grep -c "^cd " "$HOME/.bash_history" 2>/dev/null || echo 0)
            local apt_cmds=$(grep -c "^apt\|^pkg " "$HOME/.bash_history" 2>/dev/null || echo 0)
            local python_cmds=$(grep -c "^python\|^pip " "$HOME/.bash_history" 2>/dev/null || echo 0)
            
            echo -e "  ${C}Git:${N}    ${W}${git_cmds}${N}"
            echo -e "  ${C}Nav:${N}    ${W}${cd_cmds}${N}"
            echo -e "  ${C}Pkgs:${N}   ${W}${apt_cmds}${N}"
            echo -e "  ${C}Python:${N} ${W}${python_cmds}${N}"
            ;;
            
        5) # Bookmark manager
            local bookmark_file="$CONFIG_DIR/bookmarks.conf"
            touch "$bookmark_file"
            
            echo -e "  ${ICON_FOLDER} ${BOLD}${W}DIRECTORY BOOKMARKS${N}"
            echo ""
            echo -e "  ${Y}[1]${N} Add bookmark"
            echo -e "  ${Y}[2]${N} List bookmarks"
            echo -e "  ${Y}[3]${N} Go to bookmark"
            echo -e "  ${Y}[4]${N} Remove bookmark"
            echo ""
            echo -ne "  ${W}Choose: ${C}"
            read bm_opt
            echo -e "${N}"
            
            case $bm_opt in
                1)
                    echo -ne "  ${W}Bookmark name: ${C}"
                    read bm_name
                    echo -ne "  ${W}Path (default: current): ${C}"
                    read bm_path
                    [ -z "$bm_path" ] && bm_path="$(pwd)"
                    echo "${bm_name}|${bm_path}" >> "$bookmark_file"
                    
                    # Create bash function
                    echo "# Nexus bookmark: $bm_name" >> "$HOME/.bashrc"
                    echo "alias goto_${bm_name}='cd ${bm_path}'" >> "$HOME/.bashrc"
                    
                    echo -e "  ${ICON_CHECK} ${G}Bookmark '${bm_name}' saved!${N}"
                    echo -e "  ${DIM}Use: goto_${bm_name}${N}"
                    ;;
                2)
                    echo -e "  ${W}Saved bookmarks:${N}"
                    echo ""
                    cat "$bookmark_file" 2>/dev/null | while IFS='|' read name path; do
                        if [ -d "$path" ]; then
                            echo -e "  ${ICON_CHECK} ${C}${name}${N} → ${DIM}${path}${N}"
                        else
                            echo -e "  ${ICON_CROSS} ${R}${name}${N} → ${DIM}${path} (not found)${N}"
                        fi
                    done
                    ;;
            esac
            ;;
            
        7) # Snippet manager
            local snippet_dir="$CONFIG_DIR/snippets"
            mkdir -p "$snippet_dir"
            
            echo -e "  ${ICON_FILE} ${BOLD}${W}CODE SNIPPET MANAGER${N}"
            echo ""
            echo -e "  ${Y}[1]${N} Save new snippet"
            echo -e "  ${Y}[2]${N} List snippets"
            echo -e "  ${Y}[3]${N} Run snippet"
            echo -e "  ${Y}[4]${N} View snippet"
            echo ""
            echo -ne "  ${W}Choose: ${C}"
            read snip_opt
            echo -e "${N}"
            
            case $snip_opt in
                1)
                    echo -ne "  ${W}Snippet name: ${C}"
                    read snip_name
                    echo -ne "  ${W}Language (bash/python/etc): ${C}"
                    read snip_lang
                    echo -e "  ${W}Enter code (end with EOF on new line):${N}"
                    
                    local snip_file="$snippet_dir/${snip_name}.${snip_lang}"
                    local snip_code=""
                    while IFS= read -r line; do
                        [ "$line" = "EOF" ] && break
                        snip_code+="$line"$'\n'
                    done
                    
                    echo "$snip_code" > "$snip_file"
                    chmod +x "$snip_file"
                    echo -e "  ${ICON_CHECK} ${G}Snippet saved: ${snip_name}${N}"
                    ;;
                2)
                    echo -e "  ${W}Saved snippets:${N}"
                    echo ""
                    ls -1 "$snippet_dir" 2>/dev/null | while read snip; do
                        local size=$(wc -l < "$snippet_dir/$snip")
                        echo -e "  ${ICON_FILE} ${C}${snip}${N} ${DIM}(${size} lines)${N}"
                    done
                    ;;
                3)
                    echo -ne "  ${W}Snippet name: ${C}"
                    read snip_name
                    local found=$(find "$snippet_dir" -name "${snip_name}*" | head -1)
                    if [ -n "$found" ]; then
                        local ext="${found##*.}"
                        echo -e "  ${ICON_ROCKET} ${W}Running: ${C}${snip_name}${N}"
                        echo ""
                        case $ext in
                            bash|sh) bash "$found" ;;
                            python|py) python3 "$found" ;;
                            js) node "$found" ;;
                            *) bash "$found" ;;
                        esac
                    else
                        echo -e "  ${ICON_CROSS} ${R}Snippet not found!${N}"
                    fi
                    ;;
            esac
            ;;
    esac
    
    echo ""
    echo -e "  ${DIM}Press ${W}[ENTER]${DIM} to return...${N}"
    read
}

# ========================= TOOL 9: MATRIX MODE ====================
matrix_mode() {
    clear
    echo -e "${G}"
    
    local cols=$(tput cols)
    local rows=$(tput lines)
    local chars="アイウエオカキクケコサシスセソタチツテトナニヌネノハヒフヘホマミムメモヤユヨラリルレロワヲン0123456789ABCDEFabcdef!@#$%^&*"
    
    # Initialize column positions
    declare -a positions
    declare -a speeds
    for ((i=0; i<cols; i++)); do
        positions[$i]=$((RANDOM % rows))
        speeds[$i]=$((RANDOM % 3 + 1))
    done
    
    tput civis
    trap "tput cnorm; clear; return" INT
    
    while true; do
        for ((i=0; i<cols; i+=2)); do
            local pos=${positions[$i]}
            local speed=${speeds[$i]}
            local char="${chars:$((RANDOM % ${#chars})):1}"
            
            # Draw bright head
            printf "\033[%d;%dH\033[1;37m%s" $pos $i "$char"
            
            # Draw green trail
            local trail_pos=$(( (pos - 1 + rows) % rows ))
            local trail_char="${chars:$((RANDOM % ${#chars})):1}"
            printf "\033[%d;%dH\033[1;32m%s" $trail_pos $i "$trail_char"
            
            # Dim old character
            local dim_pos=$(( (pos - 5 + rows) % rows ))
            local dim_char="${chars:$((RANDOM % ${#chars})):1}"
            printf "\033[%d;%dH\033[2;32m%s" $dim_pos $i "$dim_char"
            
            # Clear far trail
            local clear_pos=$(( (pos - 15 + rows) % rows ))
            printf "\033[%d;%dH " $clear_pos $i
            
            # Update position
            positions[$i]=$(( (pos + speed) % rows ))
            
            # Random reset
            if [ $((RANDOM % 100)) -lt 2 ]; then
                positions[$i]=0
                speeds[$i]=$((RANDOM % 3 + 1))
            fi
        done
        
        sleep 0.03
    done
    
    tput cnorm
    echo -e "${N}"
}

# ========================= TOOL 10: NEXUS INTEL ====================
nexus_intel() {
    clear
    show_banner
    draw_box "${ICON_BRAIN} NEXUS INTEL - Information Gathering"
    echo -e "  ${C}║${N}"
    menu_item "1" "🌐" "IP Geolocation" "Locate any IP address"
    menu_item "2" "🔍" "WHOIS Lookup" "Domain information"
    menu_item "3" "📡" "DNS Recon" "Full DNS enumeration"
    menu_item "4" "🌍" "My Public Info" "Your internet footprint"
    menu_item "5" "📊" "Website Technologies" "Detect CMS/Frameworks"
    menu_item "6" "🔗" "URL Expander" "Reveal shortened URLs"
    menu_item "7" "📧" "Email Validator" "Verify email addresses"
    menu_item "8" "🏢" "ASN Lookup" "Network owner info"
    menu_item "0" "$ICON_CROSS" "Back" ""
    echo -e "  ${C}║${N}"
    draw_box_end
    
    echo ""
    echo -ne "  ${ICON_BOLT} ${W}Select: ${C}"
    read ni_choice
    echo -e "${N}"
    
    case $ni_choice in
        1) # IP Geolocation
            echo -ne "  ${ICON_NET} ${W}Enter IP address: ${C}"
            read ip_addr
            echo -e "${N}"
            
            [ -z "$ip_addr" ] && ip_addr=$(curl -s ifconfig.me 2>/dev/null)
            
            cyber_loader "Querying geolocation databases" 2
            
            local geo_data=$(curl -s "http://ip-api.com/json/${ip_addr}?fields=status,message,continent,country,countryCode,region,regionName,city,zip,lat,lon,timezone,isp,org,as,query" 2>/dev/null)
            
            if echo "$geo_data" | grep -q '"status":"success"'; then
                echo -e "  ${ICON_NET} ${BOLD}${W}IP GEOLOCATION RESULTS${N}"
                echo -e "  ${DIM}══════════════════════════════════════${N}"
                echo ""
                
                local country=$(echo "$geo_data" | grep -o '"country":"[^"]*"' | cut -d'"' -f4)
                local region=$(echo "$geo_data" | grep -o '"regionName":"[^"]*"' | cut -d'"' -f4)
                local city=$(echo "$geo_data" | grep -o '"city":"[^"]*"' | cut -d'"' -f4)
                local zip=$(echo "$geo_data" | grep -o '"zip":"[^"]*"' | cut -d'"' -f4)
                local lat=$(echo "$geo_data" | grep -o '"lat":[0-9.-]*' | cut -d: -f2)
                local lon=$(echo "$geo_data" | grep -o '"lon":[0-9.-]*' | cut -d: -f2)
                local tz=$(echo "$geo_data" | grep -o '"timezone":"[^"]*"' | cut -d'"' -f4)
                local isp=$(echo "$geo_data" | grep -o '"isp":"[^"]*"' | cut -d'"' -f4)
                local org=$(echo "$geo_data" | grep -o '"org":"[^"]*"' | cut -d'"' -f4)
                local asn=$(echo "$geo_data" | grep -o '"as":"[^"]*"' | cut -d'"' -f4)
                
                echo -e "  ${ICON_NET} ${W}IP Address:${N}  ${C}${ip_addr}${N}"
                echo -e "  🌍 ${W}Country:${N}    ${C}${country}${N}"
                echo -e "  🏙️ ${W}Region:${N}     ${C}${region}${N}"
                echo -e "  🏘️ ${W}City:${N}       ${C}${city}${N}"
                echo -e "  📮 ${W}ZIP:${N}        ${C}${zip}${N}"
                echo -e "  📍 ${W}Latitude:${N}   ${C}${lat}${N}"
                echo -e "  📍 ${W}Longitude:${N}  ${C}${lon}${N}"
                echo -e "  ⏰ ${W}Timezone:${N}   ${C}${tz}${N}"
                echo -e "  🏢 ${W}ISP:${N}        ${C}${isp}${N}"
                echo -e "  🏛️ ${W}Org:${N}        ${C}${org}${N}"
                echo -e "  📡 ${W}ASN:${N}        ${C}${asn}${N}"
                echo ""
                echo -e "  🗺️ ${DIM}Map: https://www.google.com/maps/@${lat},${lon},12z${N}"
            else
                echo -e "  ${ICON_CROSS} ${R}Lookup failed!${N}"
            fi
            ;;
            
        2) # WHOIS
            echo -ne "  ${ICON_NET} ${W}Enter domain: ${C}"
            read domain
            echo -e "${N}"
            
            cyber_loader "Querying WHOIS databases" 2
            
            if command -v whois &>/dev/null; then
                echo -e "  ${ICON_SEARCH} ${BOLD}${W}WHOIS RESULTS${N}"
                echo -e "  ${DIM}══════════════════════════════════════${N}"
                echo ""
                whois "$domain" 2>/dev/null | grep -iE "domain name|registrar|creation|expir|name server|status|registrant" | head -20 | while read line; do
                    echo -e "  ${DIM}${line}${N}"
                done
            else
                # Use API fallback
                local whois_data=$(curl -s "https://whois.freeaiapi.xyz/?name=${domain}" 2>/dev/null)
                echo -e "  ${W}WHOIS Data:${N}"
                echo "$whois_data" | head -30
            fi
            ;;
            
        3) # DNS Recon
            echo -ne "  ${ICON_NET} ${W}Enter domain: ${C}"
            read domain
            echo -e "${N}"
            
            cyber_loader "Performing DNS reconnaissance" 2
            
            echo -e "  ${ICON_SATELLITE} ${BOLD}${W}DNS RECONNAISSANCE${N}"
            echo -e "  ${DIM}══════════════════════════════════════${N}"
            echo ""
            
            # A record
            echo -e "  ${C}[A Records]${N}"
            if command -v nslookup &>/dev/null; then
                nslookup "$domain" 2>/dev/null | grep "Address:" | tail -n +2 | while read line; do
                    echo -e "    ${W}${line}${N}"
                done
            elif command -v host &>/dev/null; then
                host -t A "$domain" 2>/dev/null | while read line; do
                    echo -e "    ${W}${line}${N}"
                done
            fi
            
            echo ""
            echo -e "  ${C}[MX Records]${N}"
            if command -v host &>/dev/null; then
                host -t MX "$domain" 2>/dev/null | while read line; do
                    echo -e "    ${W}${line}${N}"
                done
            elif command -v nslookup &>/dev/null; then
                nslookup -type=MX "$domain" 2>/dev/null | grep "mail exchanger" | while read line; do
                    echo -e "    ${W}${line}${N}"
                done
            fi
            
            echo ""
            echo -e "  ${C}[NS Records]${N}"
            if command -v host &>/dev/null; then
                host -t NS "$domain" 2>/dev/null | while read line; do
                    echo -e "    ${W}${line}${N}"
                done
            fi
            
            echo ""
            echo -e "  ${C}[TXT Records]${N}"
            if command -v host &>/dev/null; then
                host -t TXT "$domain" 2>/dev/null | while read line; do
                    echo -e "    ${DIM}${line}${N}"
                done
            fi
            ;;
            
        4) # My public info
            cyber_loader "Gathering your public information" 2
            
            echo -e "  ${ICON_EYE} ${BOLD}${W}YOUR INTERNET FOOTPRINT${N}"
            echo -e "  ${DIM}══════════════════════════════════════${N}"
            echo ""
            
            local my_ip=$(curl -s ifconfig.me 2>/dev/null)
            local my_geo=$(curl -s "http://ip-api.com/json/${my_ip}" 2>/dev/null)
            local my_dns=$(curl -s https://edns.ip-api.com/json 2>/dev/null)
            
            echo -e "  ${ICON_NET} ${W}Public IP:${N}    ${C}${my_ip}${N}"
            
            local my_country=$(echo "$my_geo" | grep -o '"country":"[^"]*"' | cut -d'"' -f4)
            local my_city=$(echo "$my_geo" | grep -o '"city":"[^"]*"' | cut -d'"' -f4)
            local my_isp=$(echo "$my_geo" | grep -o '"isp":"[^"]*"' | cut -d'"' -f4)
            
            echo -e "  🌍 ${W}Location:${N}    ${C}${my_city}, ${my_country}${N}"
            echo -e "  🏢 ${W}ISP:${N}         ${C}${my_isp}${N}"
            
            # Local info
            local local_ip=$(ip addr show wlan0 2>/dev/null | grep 'inet ' | awk '{print $2}' | cut -d/ -f1)
            local mac=$(ip link show wlan0 2>/dev/null | grep ether | awk '{print $2}')
            local hostname=$(hostname 2>/dev/null)
            
            echo -e "  🏠 ${W}Local IP:${N}    ${C}${local_ip}${N}"
            echo -e "  📱 ${W}MAC:${N}         ${C}${mac}${N}"
            echo -e "  💻 ${W}Hostname:${N}    ${C}${hostname}${N}"
            
            # User agent
            local ua=$(curl -s https://httpbin.org/user-agent 2>/dev/null | grep -o '"user-agent": "[^"]*"' | cut -d'"' -f4)
            echo -e "  🌐 ${W}User Agent:${N} ${DIM}${ua}${N}"
            ;;
            
        6) # URL Expander
            echo -ne "  ${W}Enter shortened URL: ${C}"
            read short_url
            echo -e "${N}"
            
            [ -z "$short_url" ] && return
            
            cyber_loader "Expanding URL" 1
            
            local expanded=$(curl -sIL -o /dev/null -w '%{url_effective}' "$short_url" 2>/dev/null)
            local chain=$(curl -sIL -w '%{url_effective}\n' "$short_url" 2>/dev/null | grep -i "^location:" | sed 's/location: //i')
            
            echo -e "  ${ICON_SEARCH} ${BOLD}${W}URL EXPANSION RESULTS${N}"
            echo -e "  ${DIM}══════════════════════════════════════${N}"
            echo ""
            echo -e "  ${W}Short:${N}    ${Y}${short_url}${N}"
            echo -e "  ${W}Final:${N}    ${G}${expanded}${N}"
            
            if [ -n "$chain" ]; then
                echo ""
                echo -e "  ${W}Redirect chain:${N}"
                local step=1
                echo "$chain" | while read url; do
                    echo -e "    ${DIM}${step}.${N} ${C}${url}${N}"
                    step=$((step+1))
                done
            fi
            ;;
    esac
    
    echo ""
    echo -e "  ${DIM}Press ${W}[ENTER]${DIM} to return...${N}"
    read
}

# ========================= SETTINGS ================================
settings_menu() {
    clear
    show_banner
    draw_box "${ICON_GEAR} NEXUS SETTINGS"
    echo -e "  ${C}║${N}"
    menu_item "1" "🎨" "Theme Settings" "Change appearance"
    menu_item "2" "📊" "View Logs" "System logs"
    menu_item "3" "🗑️" "Clear Cache" "Free up space"
    menu_item "4" "📋" "Export Config" "Backup settings"
    menu_item "5" "ℹ️" "About" "Toolkit info"
    menu_item "6" "🔄" "Reset Toolkit" "Factory reset"
    menu_item "0" "$ICON_CROSS" "Back" ""
    echo -e "  ${C}║${N}"
    draw_box_end
    
    echo ""
    echo -ne "  ${ICON_BOLT} ${W}Select: ${C}"
    read st_choice
    echo -e "${N}"
    
    case $st_choice in
        2) # View logs
            echo -e "  ${ICON_FILE} ${BOLD}${W}SYSTEM LOGS${N}"
            echo ""
            
            for log in "$LOG_DIR"/*.log; do
                [ ! -f "$log" ] && continue
                local size=$(du -sh "$log" | cut -f1)
                echo -e "  ${ICON_FILE} ${C}$(basename "$log")${N} ${DIM}(${size})${N}"
            done
            
            echo ""
            echo -ne "  ${W}View log (filename or 'all'): ${C}"
            read log_name
            echo -e "${N}"
            
            if [ "$log_name" = "all" ]; then
                for log in "$LOG_DIR"/*.log; do
                    [ ! -f "$log" ] && continue
                    echo -e "  ${Y}=== $(basename "$log") ===${N}"
                    tail -10 "$log"
                    echo ""
                done
            elif [ -f "$LOG_DIR/$log_name" ]; then
                less "$LOG_DIR/$log_name"
            fi
            ;;
            
        3) # Clear cache
            local cache_size=$(du -sh "$CACHE_DIR" 2>/dev/null | cut -f1)
            echo -e "  ${W}Cache size: ${Y}${cache_size}${N}"
            echo -ne "  ${W}Clear cache? (y/n): ${C}"
            read confirm
            echo -e "${N}"
            
            if [ "$confirm" = "y" ]; then
                rm -rf "$CACHE_DIR"/*
                echo -e "  ${ICON_CHECK} ${G}Cache cleared!${N}"
            fi
            ;;
            
        5) # About
            echo -e "  ${ICON_DIAMOND} ${BOLD}${W}NEXUS TOOLKIT${N}"
            echo -e "  ${DIM}══════════════════════════════════════${N}"
            echo ""
            echo -e "  ${W}Version:${N}     ${C}${VERSION}${N}"
            echo -e "  ${W}Author:${N}      ${C}NexusForge Labs${N}"
            echo -e "  ${W}License:${N}     ${C}MIT${N}"
            echo -e "  ${W}Platform:${N}    ${C}Termux (Android)${N}"
            echo ""
            echo -e "  ${W}Components:${N}"
            echo -e "  ${DIM}  • Phantom Scanner    - Network reconnaissance${N}"
            echo -e "  ${DIM}  • Neural Crypt       - Encryption engine${N}"
            echo -e "  ${DIM}  • Ghost Watcher      - System monitoring${N}"
            echo -e "  ${DIM}  • Venom Spider       - Web analysis${N}"
            echo -e "  ${DIM}  • Shadow Forge       - Script generator${N}"
            echo -e "  ${DIM}  • Chrono Vault       - Backup system${N}"
            echo -e "  ${DIM}  • Zero Day Pkg       - Package manager${N}"
            echo -e "  ${DIM}  • Quantum Shell      - Shell enhancement${N}"
            echo -e "  ${DIM}  • Nexus Intel         - OSINT gathering${N}"
            echo ""
            echo -e "  ${ICON_FIRE} ${Y}Built with passion for the Termux community${N}"
            ;;
            
        6) # Reset
            echo -e "  ${ICON_WARN} ${R}${BOLD}WARNING: This will delete all toolkit data!${N}"
            echo -ne "  ${W}Type 'RESET' to confirm: ${R}"
            read confirm
            echo -e "${N}"
            
            if [ "$confirm" = "RESET" ]; then
                rm -rf "$TOOLKIT_DIR"
                echo -e "  ${ICON_CHECK} ${G}Toolkit reset complete.${N}"
                echo -e "  ${DIM}Restart the toolkit to reinitialize.${N}"
                sleep 3
                exit 0
            fi
            ;;
    esac
    
    echo ""
    echo -e "  ${DIM}Press ${W}[ENTER]${DIM} to return...${N}"
    read
}

# ========================= MAIN MENU ==============================
main_menu() {
    while true; do
        clear
        show_banner
        get_terminal_size
        
        # Quick stats bar
        local mem_pct=$(free 2>/dev/null | awk '/Mem:/{printf "%.0f", $3/$2*100}' || echo "?")
        local disk_pct=$(df "$HOME" 2>/dev/null | awk 'NR==2{print $5}' || echo "?")
        local proc_count=$(ps aux 2>/dev/null | wc -l || echo "?")
        
        echo -e "  ${DIM}${ICON_PULSE} MEM: ${mem_pct}% │ ${ICON_FOLDER} DISK: ${disk_pct} │ ${ICON_GEAR} PROCS: ${proc_count} │ ${ICON_CLOCK} $(date '+%H:%M:%S')${N}"
        echo ""
        
        draw_box "${ICON_DIAMOND} NEXUS TOOLKIT - MAIN MENU"
        echo -e "  ${C}║${N}"
        
        menu_item "1"  "$ICON_CHART"    "System Dashboard"   "Real-time system overview"
        menu_item "2"  "$ICON_SPIDER"   "Phantom Scanner"    "Network reconnaissance"
        menu_item "3"  "$ICON_LOCK"     "Neural Crypt"       "Encryption engine"
        menu_item "4"  "$ICON_GHOST"    "Ghost Watcher"      "System monitoring"
        menu_item "5"  "$ICON_SPIDER"   "Venom Spider"       "Web analysis suite"
        menu_item "6"  "$ICON_FIRE"     "Shadow Forge"       "Script generator"
        menu_item "7"  "$ICON_CLOCK"    "Chrono Vault"       "Backup engine"
        menu_item "8"  "$ICON_PACKAGE"  "Zero Day PKG"       "Package manager+"
        menu_item "9"  "$ICON_ATOM"     "Quantum Shell"      "Shell enhancement"
        menu_item "10" "$ICON_BRAIN"    "Nexus Intel"        "Information gathering"
        
        draw_separator
        
        menu_item "11" "$ICON_MATRIX"   "Matrix Mode"        "Enter the Matrix"
        menu_item "12" "$ICON_GEAR"     "Settings"           "Configuration"
        menu_item "0"  "$ICON_CROSS"    "Exit"               "Goodbye!"
        
        echo -e "  ${C}║${N}"
        draw_box_end
        
        echo ""
        echo -ne "  ${ICON_BOLT} ${W}Select option: ${C}"
        read choice
        echo -e "${N}"
        
        case $choice in
            1)  system_dashboard ;;
            2)  phantom_scanner ;;
            3)  neural_crypt ;;
            4)  ghost_watcher ;;
            5)  venom_spider ;;
            6)  shadow_forge ;;
            7)  chrono_vault ;;
            8)  pkg_manager ;;
            9)  quantum_shell ;;
            10) nexus_intel ;;
            11) matrix_mode ;;
            12) settings_menu ;;
            0)
                clear
                echo ""
                echo -e "  ${C}╔════════════════════════════════════════╗${N}"
                echo -e "  ${C}║${N}                                        ${C}║${N}"
                echo -e "  ${C}║${N}   ${ICON_DIAMOND} ${BOLD}${W}Thank you for using NEXUS!${N}     ${C}║${N}"
                echo -e "  ${C}║${N}                                        ${C}║${N}"
                echo -e "  ${C}║${N}   ${DIM}Stay curious. Stay dangerous.${N}      ${C}║${N}"
                echo -e "  ${C}║${N}                                        ${C}║${N}"
                echo -e "  ${C}╚════════════════════════════════════════╝${N}"
                echo ""
                typewriter "  Shutting down NEXUS TOOLKIT..." 0.03
                sleep 1
                clear
                exit 0
                ;;
            *)
                echo -e "  ${ICON_WARN} ${Y}Invalid option!${N}"
                sleep 1
                ;;
        esac
    done
}

# ========================= STARTUP ================================
startup() {
    clear
    init_toolkit
    
    # Startup animation
    echo ""
    echo ""
    echo ""
    
    tput civis
    
    local frames=(
        "  ${BK}[                    ]  Initializing...${N}"
        "  ${R}[████                ]  Loading modules...${N}"
        "  ${Y}[████████            ]  Starting engines...${N}"
        "  ${C}[████████████        ]  Connecting systems...${N}"
        "  ${G}[████████████████    ]  Almost ready...${N}"
        "  ${G}[████████████████████]  Ready!${N}"
    )
    
    for frame in "${frames[@]}"; do
        printf "\r${frame}"
        sleep 0.3
    done
    
    tput cnorm
    sleep 0.5
    
    # Quick matrix flash
    matrix_rain 2
    
    # Launch main menu
    main_menu
}

# ========================= ENTRY POINT ============================
startup
