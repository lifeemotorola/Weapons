#!/data/data/com.termux/files/usr/bin/bash

#====================================================================
#  SYSTEM GUARDIAN - Termux Plugin v2.0
#  A powerful system monitor, security auditor & productivity toolkit
#====================================================================

# ── Colors & Styling ──────────────────────────────────────────────
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly MAGENTA='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly WHITE='\033[1;37m'
readonly GRAY='\033[0;90m'
readonly BOLD='\033[1m'
readonly DIM='\033[2m'
readonly UNDERLINE='\033[4m'
readonly BLINK='\033[5m'
readonly RESET='\033[0m'
readonly BG_RED='\033[41m'
readonly BG_GREEN='\033[42m'
readonly BG_BLUE='\033[44m'
readonly BG_YELLOW='\033[43m'

# ── Configuration ─────────────────────────────────────────────────
PLUGIN_NAME="System Guardian"
PLUGIN_VERSION="2.0.0"
PLUGIN_DIR="$HOME/.system-guardian"
LOG_DIR="$PLUGIN_DIR/logs"
REPORT_DIR="$PLUGIN_DIR/reports"
SNAPSHOT_DIR="$PLUGIN_DIR/snapshots"
CONFIG_FILE="$PLUGIN_DIR/config.conf"
HISTORY_FILE="$PLUGIN_DIR/command_history.log"
ALERT_THRESHOLD_CPU=80
ALERT_THRESHOLD_MEM=85
ALERT_THRESHOLD_DISK=90
REFRESH_RATE=2

# ── Initialization ────────────────────────────────────────────────
init_plugin() {
    mkdir -p "$LOG_DIR" "$REPORT_DIR" "$SNAPSHOT_DIR" 2>/dev/null

    if [[ ! -f "$CONFIG_FILE" ]]; then
        cat > "$CONFIG_FILE" << 'CONF'
# System Guardian Configuration
ALERT_THRESHOLD_CPU=80
ALERT_THRESHOLD_MEM=85
ALERT_THRESHOLD_DISK=90
REFRESH_RATE=2
ENABLE_LOGGING=true
ENABLE_NOTIFICATIONS=true
AUTO_CLEANUP_DAYS=30
CONF
    fi

    source "$CONFIG_FILE" 2>/dev/null
}

# ── Utility Functions ─────────────────────────────────────────────
log_action() {
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] $1" >> "$HISTORY_FILE"
}

print_line() {
    local char="${1:-─}"
    printf '%*s\n' "${COLUMNS:-60}" '' | tr ' ' "$char"
}

print_header() {
    local title="$1"
    local width=${COLUMNS:-60}
    local padding=$(( (width - ${#title} - 4) / 2 ))

    echo ""
    echo -e "${CYAN}$(print_line '═')${RESET}"
    printf "${CYAN}║${RESET}%*s ${BOLD}${WHITE}%s${RESET} %*s${CYAN}║${RESET}\n" \
        "$padding" "" "$title" "$padding" ""
    echo -e "${CYAN}$(print_line '═')${RESET}"
}

print_section() {
    echo ""
    echo -e "${BLUE}┌──${BOLD} $1 ${RESET}${BLUE}$(printf '─%.0s' $(seq 1 $((${COLUMNS:-60} - ${#1} - 6))))┐${RESET}"
}

print_section_end() {
    echo -e "${BLUE}└$(printf '─%.0s' $(seq 1 $((${COLUMNS:-60} - 2))))┘${RESET}"
}

print_kv() {
    local key="$1"
    local value="$2"
    local color="${3:-$WHITE}"
    printf "  ${GRAY}%-20s${RESET} ${color}%s${RESET}\n" "$key:" "$value"
}

progress_bar() {
    local percent=$1
    local width=${2:-30}
    local filled=$(( percent * width / 100 ))
    local empty=$(( width - filled ))
    local color

    if (( percent >= 90 )); then
        color=$RED
    elif (( percent >= 70 )); then
        color=$YELLOW
    else
        color=$GREEN
    fi

    printf "${color}["
    printf '█%.0s' $(seq 1 $filled) 2>/dev/null
    printf '░%.0s' $(seq 1 $empty) 2>/dev/null
    printf "] %3d%%${RESET}" "$percent"
}

spinner() {
    local pid=$1
    local msg="${2:-Processing...}"
    local spin='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    local i=0

    while kill -0 "$pid" 2>/dev/null; do
        printf "\r  ${CYAN}${spin:i++%${#spin}:1}${RESET} ${msg}"
        sleep 0.1
    done
    printf "\r  ${GREEN}✓${RESET} ${msg}\n"
}

notify() {
    local msg="$1"
    local urgency="${2:-normal}"

    if command -v termux-notification &>/dev/null && [[ "$ENABLE_NOTIFICATIONS" == "true" ]]; then
        termux-notification --title "System Guardian" --content "$msg" \
            --priority "$urgency" --id "sysguard" 2>/dev/null
    fi
}

confirm() {
    local msg="$1"
    echo -ne "  ${YELLOW}⚠ ${msg} [y/N]:${RESET} "
    read -r response
    [[ "$response" =~ ^[Yy]$ ]]
}

# ── ASCII Art Banner ──────────────────────────────────────────────
show_banner() {
    clear
    echo -e "${CYAN}"
    cat << 'BANNER'
   ╔═══════════════════════════════════════════════════╗
   ║                                                   ║
   ║   ███████╗██╗   ██╗███████╗████████╗███████╗███╗  ║
   ║   ██╔════╝╚██╗ ██╔╝██╔════╝╚══██╔══╝██╔════╝██║  ║
   ║   ███████╗ ╚████╔╝ ███████╗   ██║   █████╗  ██║  ║
   ║   ╚════██║  ╚██╔╝  ╚════██║   ██║   ██╔══╝  ██║  ║
   ║   ███████║   ██║   ███████║   ██║   ███████╗██║  ║
   ║   ╚══════╝   ╚═╝   ╚══════╝   ╚═╝   ╚══════╝╚═╝  ║
   ║                                                   ║
   ║      ██████╗ ██╗   ██╗ █████╗ ██████╗ ██████╗    ║
   ║     ██╔════╝ ██║   ██║██╔══██╗██╔══██╗██╔══██╗   ║
   ║     ██║  ███╗██║   ██║███████║██████╔╝██║  ██║   ║
   ║     ██║   ██║██║   ██║██╔══██║██╔══██╗██║  ██║   ║
   ║     ╚██████╔╝╚██████╔╝██║  ██║██║  ██║██████╔╝   ║
   ║      ╚═════╝  ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚═════╝    ║
   ║                                                   ║
   ╚═══════════════════════════════════════════════════╝
BANNER
    echo -e "${RESET}"
    echo -e "        ${DIM}Version ${PLUGIN_VERSION} │ Termux Plugin${RESET}"
    echo -e "        ${DIM}$(date '+%A, %B %d, %Y │ %H:%M:%S')${RESET}"
    echo ""
}

# ═══════════════════════════════════════════════════════════════════
# MODULE 1: SYSTEM DASHBOARD
# ═══════════════════════════════════════════════════════════════════
system_dashboard() {
    log_action "Opened System Dashboard"

    while true; do
        clear
        print_header "⚡ LIVE SYSTEM DASHBOARD"

        # ── Device Info ───────────────────────────────────────────
        print_section "📱 Device Information"
        print_kv "Device" "$(getprop ro.product.model 2>/dev/null || echo 'Unknown')"
        print_kv "Android" "$(getprop ro.build.version.release 2>/dev/null || echo 'N/A')"
        print_kv "Kernel" "$(uname -r)"
        print_kv "Architecture" "$(uname -m)"
        print_kv "Hostname" "$(hostname 2>/dev/null || echo 'localhost')"
        print_kv "Uptime" "$(uptime -p 2>/dev/null || uptime | sed 's/.*up //' | sed 's/,.*load.*//')"
        print_section_end

        # ── CPU Info ──────────────────────────────────────────────
        print_section "🔥 CPU Status"
        local cpu_cores
        cpu_cores=$(nproc 2>/dev/null || grep -c processor /proc/cpuinfo 2>/dev/null || echo "?")

        local cpu_usage=0
        if [[ -f /proc/stat ]]; then
            local cpu_line
            cpu_line=$(head -1 /proc/stat)
            local user nice system idle iowait irq softirq
            read -r _ user nice system idle iowait irq softirq <<< "$cpu_line"
            local total=$((user + nice + system + idle + iowait + irq + softirq))
            local active=$((total - idle))
            if (( total > 0 )); then
                cpu_usage=$((active * 100 / total))
            fi
        fi

        print_kv "Cores" "$cpu_cores"
        printf "  ${GRAY}%-20s${RESET} " "Usage:"
        progress_bar "$cpu_usage"
        echo ""

        # CPU frequency
        if [[ -f /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq ]]; then
            local freq
            freq=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq 2>/dev/null)
            if [[ -n "$freq" ]]; then
                print_kv "Frequency" "$(echo "scale=2; $freq/1000000" | bc 2>/dev/null || echo "$((freq/1000)) MHz") GHz"
            fi
        fi

        # CPU temperature
        local temp=""
        for zone in /sys/class/thermal/thermal_zone*/temp; do
            if [[ -f "$zone" ]]; then
                local t
                t=$(cat "$zone" 2>/dev/null)
                if [[ -n "$t" ]] && (( t > 0 )); then
                    temp=$(echo "scale=1; $t/1000" | bc 2>/dev/null || echo "$((t/1000))")
                    break
                fi
            fi
        done
        if [[ -n "$temp" ]]; then
            local temp_color=$GREEN
            local temp_int=${temp%.*}
            (( temp_int > 50 )) && temp_color=$YELLOW
            (( temp_int > 70 )) && temp_color=$RED
            print_kv "Temperature" "${temp_color}${temp}°C${RESET}"
        fi
        print_section_end

        # ── Memory Info ───────────────────────────────────────────
        print_section "💾 Memory Status"
        if [[ -f /proc/meminfo ]]; then
            local mem_total mem_avail mem_used mem_percent
            mem_total=$(grep MemTotal /proc/meminfo | awk '{print $2}')
            mem_avail=$(grep MemAvailable /proc/meminfo | awk '{print $2}')
            mem_used=$((mem_total - mem_avail))
            mem_percent=$((mem_used * 100 / mem_total))

            print_kv "Total" "$(echo "scale=1; $mem_total/1048576" | bc 2>/dev/null || echo "$((mem_total/1024)) MB") GB"
            print_kv "Used" "$(echo "scale=1; $mem_used/1048576" | bc 2>/dev/null || echo "$((mem_used/1024)) MB") GB"
            print_kv "Available" "$(echo "scale=1; $mem_avail/1048576" | bc 2>/dev/null || echo "$((mem_avail/1024)) MB") GB"
            printf "  ${GRAY}%-20s${RESET} " "Usage:"
            progress_bar "$mem_percent"
            echo ""

            if (( mem_percent >= ALERT_THRESHOLD_MEM )); then
                echo -e "  ${BG_RED}${WHITE} ⚠ MEMORY CRITICALLY HIGH! ${RESET}"
            fi

            # Swap
            local swap_total
            swap_total=$(grep SwapTotal /proc/meminfo | awk '{print $2}')
            if (( swap_total > 0 )); then
                local swap_free swap_used swap_percent
                swap_free=$(grep SwapFree /proc/meminfo | awk '{print $2}')
                swap_used=$((swap_total - swap_free))
                swap_percent=$((swap_used * 100 / swap_total))
                printf "  ${GRAY}%-20s${RESET} " "Swap:"
                progress_bar "$swap_percent"
                echo ""
            fi
        fi
        print_section_end

        # ── Storage Info ──────────────────────────────────────────
        print_section "📂 Storage Status"
        while IFS= read -r line; do
            local fs mount size used avail percent
            read -r fs size used avail percent mount <<< "$line"
            percent=${percent%\%}
            printf "  ${GRAY}%-15s${RESET} " "$mount"
            progress_bar "$percent" 20
            printf " ${DIM}(%s/%s)${RESET}\n" "$used" "$size"

            if (( percent >= ALERT_THRESHOLD_DISK )); then
                echo -e "  ${RED}  ⚠ Storage critically low on $mount${RESET}"
            fi
        done < <(df -h 2>/dev/null | grep -E '^/dev|^tmpfs' | head -5)
        print_section_end

        # ── Network Info ──────────────────────────────────────────
        print_section "🌐 Network Status"
        local interfaces
        interfaces=$(ip -brief addr show 2>/dev/null | grep -v "^lo" | head -5)
        if [[ -n "$interfaces" ]]; then
            while IFS= read -r line; do
                local iface status ip
                read -r iface status ip <<< "$line"
                local status_color=$RED
                [[ "$status" == "UP" ]] && status_color=$GREEN
                print_kv "$iface" "${status_color}$status${RESET} ${ip%/*}"
            done <<< "$interfaces"
        fi

        # External IP (cached for 5 minutes)
        local ext_ip_cache="$PLUGIN_DIR/.ext_ip_cache"
        if [[ ! -f "$ext_ip_cache" ]] || [[ $(find "$ext_ip_cache" -mmin +5 2>/dev/null) ]]; then
            local ext_ip
            ext_ip=$(curl -s --connect-timeout 3 ifconfig.me 2>/dev/null || echo "Unavailable")
            echo "$ext_ip" > "$ext_ip_cache"
        fi
        print_kv "External IP" "$(cat "$ext_ip_cache" 2>/dev/null || echo 'Unavailable')"
        print_section_end

        # ── Top Processes ─────────────────────────────────────────
        print_section "⚙ Top Processes (by memory)"
        printf "  ${UNDERLINE}${GRAY}%-8s %-6s %-6s %s${RESET}\n" "PID" "%MEM" "%CPU" "COMMAND"
        ps aux 2>/dev/null | sort -k4 -rn | head -5 | while IFS= read -r line; do
            local pid pmem pcpu cmd
            read -r _ pid pcpu pmem _ _ _ _ _ _ cmd <<< "$line"
            cmd=$(basename "$cmd" 2>/dev/null || echo "$cmd")
            printf "  ${WHITE}%-8s${RESET} ${YELLOW}%-6s${RESET} ${CYAN}%-6s${RESET} %s\n" \
                "$pid" "$pmem" "$pcpu" "${cmd:0:30}"
        done
        print_section_end

        # ── Battery Info ──────────────────────────────────────────
        if command -v termux-battery-status &>/dev/null; then
            print_section "🔋 Battery"
            local battery_json
            battery_json=$(termux-battery-status 2>/dev/null)
            if [[ -n "$battery_json" ]]; then
                local bat_percent bat_status bat_temp
                bat_percent=$(echo "$battery_json" | grep -o '"percentage": [0-9]*' | grep -o '[0-9]*')
                bat_status=$(echo "$battery_json" | grep -o '"status": "[^"]*"' | cut -d'"' -f4)
                bat_temp=$(echo "$battery_json" | grep -o '"temperature": [0-9.]*' | grep -o '[0-9.]*')

                if [[ -n "$bat_percent" ]]; then
                    printf "  ${GRAY}%-20s${RESET} " "Level:"
                    progress_bar "$bat_percent"
                    echo ""
                    print_kv "Status" "$bat_status"
                    [[ -n "$bat_temp" ]] && print_kv "Temperature" "${bat_temp}°C"
                fi
            fi
            print_section_end
        fi

        echo ""
        echo -e "  ${DIM}Auto-refreshing every ${REFRESH_RATE}s │ Press ${WHITE}Ctrl+C${DIM} to exit${RESET}"

        sleep "$REFRESH_RATE"
    done
}

# ═══════════════════════════════════════════════════════════════════
# MODULE 2: SECURITY AUDITOR
# ═══════════════════════════════════════════════════════════════════
security_audit() {
    log_action "Ran Security Audit"
    clear
    print_header "🛡️  SECURITY AUDIT"

    local score=100
    local issues=0
    local warnings=0
    local timestamp
    timestamp=$(date '+%Y%m%d_%H%M%S')
    local report_file="$REPORT_DIR/security_audit_${timestamp}.txt"

    echo "Security Audit Report - $(date)" > "$report_file"
    echo "$(print_line '=')" >> "$report_file"

    # Check 1: World-readable sensitive files
    print_section "🔍 File Permission Audit"
    echo ""
    echo -e "  ${CYAN}Scanning for insecure file permissions...${RESET}"

    local insecure_files=0
    while IFS= read -r file; do
        if [[ -f "$file" ]]; then
            local perms
            perms=$(stat -c '%a' "$file" 2>/dev/null)
            if [[ "$perms" =~ [67][0-9][0-9] ]] || [[ "$perms" == "777" ]]; then
                echo -e "  ${RED}✗${RESET} ${file} ${DIM}(${perms})${RESET}"
                ((insecure_files++))
                echo "CRITICAL: Insecure permissions on $file ($perms)" >> "$report_file"
            fi
        fi
    done < <(find "$HOME" -maxdepth 2 -name "*.key" -o -name "*.pem" -o -name "*.conf" \
             -o -name ".env" -o -name "*.secret" -o -name "id_rsa" -o -name "*.password" 2>/dev/null)

    if (( insecure_files == 0 )); then
        echo -e "  ${GREEN}✓ No insecure sensitive files found${RESET}"
    else
        echo -e "  ${RED}⚠ Found $insecure_files files with insecure permissions${RESET}"
        score=$((score - insecure_files * 5))
        ((issues += insecure_files))
    fi
    print_section_end

    # Check 2: SSH Configuration
    print_section "🔐 SSH Security"
    echo ""
    local ssh_dir="$HOME/.ssh"
    if [[ -d "$ssh_dir" ]]; then
        # Check .ssh directory permissions
        local ssh_perms
        ssh_perms=$(stat -c '%a' "$ssh_dir" 2>/dev/null)
        if [[ "$ssh_perms" == "700" ]]; then
            echo -e "  ${GREEN}✓ .ssh directory permissions correct (700)${RESET}"
        else
            echo -e "  ${RED}✗ .ssh directory permissions: $ssh_perms (should be 700)${RESET}"
            score=$((score - 10))
            ((issues++))
        fi

        # Check for password-less keys
        if [[ -f "$ssh_dir/id_rsa" ]]; then
            if grep -q "ENCRYPTED" "$ssh_dir/id_rsa" 2>/dev/null; then
                echo -e "  ${GREEN}✓ SSH private key is encrypted${RESET}"
            else
                echo -e "  ${YELLOW}⚠ SSH private key may not be passphrase-protected${RESET}"
                score=$((score - 5))
                ((warnings++))
            fi
        fi

        # Check authorized_keys
        if [[ -f "$ssh_dir/authorized_keys" ]]; then
            local key_count
            key_count=$(wc -l < "$ssh_dir/authorized_keys")
            echo -e "  ${CYAN}ℹ $key_count authorized key(s) found${RESET}"
        fi
    else
        echo -e "  ${GRAY}ℹ No .ssh directory found${RESET}"
    fi
    print_section_end

    # Check 3: Exposed Services
    print_section "🌐 Network Exposure"
    echo ""
    echo -e "  ${CYAN}Scanning for listening services...${RESET}"

    local listening_services=0
    while IFS= read -r line; do
        if [[ -n "$line" ]]; then
            local proto local_addr state
            read -r proto _ _ local_addr _ state _ <<< "$line"
            if [[ "$state" == "LISTEN" ]] || [[ "$proto" == "udp" ]]; then
                local port
                port=$(echo "$local_addr" | rev | cut -d: -f1 | rev)
                local bind_addr
                bind_addr=$(echo "$local_addr" | rev | cut -d: -f2- | rev)

                local risk_color=$GREEN
                local risk_label="LOW"
                if [[ "$bind_addr" == "0.0.0.0" ]] || [[ "$bind_addr" == "*" ]] || [[ "$bind_addr" == "::" ]]; then
                    risk_color=$RED
                    risk_label="HIGH"
                    ((issues++))
                    score=$((score - 5))
                fi

                echo -e "  ${risk_color}●${RESET} Port ${WHITE}$port${RESET} ($proto) → $bind_addr ${risk_color}[$risk_label]${RESET}"
                ((listening_services++))
            fi
        fi
    done < <(ss -tlnp 2>/dev/null || netstat -tlnp 2>/dev/null)

    if (( listening_services == 0 )); then
        echo -e "  ${GREEN}✓ No listening services detected${RESET}"
    else
        echo -e "\n  ${CYAN}ℹ Found $listening_services listening service(s)${RESET}"
    fi
    print_section_end

    # Check 4: Package Security
    print_section "📦 Package Security"
    echo ""

    # Check for outdated packages
    local outdated=0
    if command -v apt &>/dev/null; then
        outdated=$(apt list --upgradable 2>/dev/null | grep -c "upgradable" || echo 0)
        if (( outdated > 0 )); then
            echo -e "  ${YELLOW}⚠ $outdated package(s) need updating${RESET}"
            score=$((score - 3))
            ((warnings++))
        else
            echo -e "  ${GREEN}✓ All packages are up to date${RESET}"
        fi
    fi

    # Check for known vulnerable packages
    local risky_packages=("telnet" "ftp" "rsh")
    for pkg in "${risky_packages[@]}"; do
        if command -v "$pkg" &>/dev/null; then
            echo -e "  ${YELLOW}⚠ Insecure package installed: $pkg${RESET}"
            score=$((score - 3))
            ((warnings++))
        fi
    done
    print_section_end

    # Check 5: File System Audit
    print_section "📁 File System Audit"
    echo ""

    # World-writable directories
    local ww_dirs
    ww_dirs=$(find "$HOME" -maxdepth 3 -type d -perm -o+w 2>/dev/null | wc -l)
    if (( ww_dirs > 0 )); then
        echo -e "  ${YELLOW}⚠ $ww_dirs world-writable directories found${RESET}"
        score=$((score - 2))
        ((warnings++))
    else
        echo -e "  ${GREEN}✓ No world-writable directories${RESET}"
    fi

    # SUID files
    local suid_files
    suid_files=$(find "$PREFIX" -perm -4000 2>/dev/null | wc -l)
    echo -e "  ${CYAN}ℹ $suid_files SUID files in \$PREFIX${RESET}"

    # Large files (potential data dumps)
    local large_files
    large_files=$(find "$HOME" -maxdepth 3 -size +100M -type f 2>/dev/null | wc -l)
    if (( large_files > 0 )); then
        echo -e "  ${YELLOW}ℹ $large_files files larger than 100MB${RESET}"
    fi

    # History files with sensitive data
    for hist_file in "$HOME/.bash_history" "$HOME/.zsh_history" "$HOME/.python_history"; do
        if [[ -f "$hist_file" ]]; then
            local sensitive_cmds
            sensitive_cmds=$(grep -ciE 'password|passwd|token|secret|api.key|authorization' "$hist_file" 2>/dev/null || echo 0)
            if (( sensitive_cmds > 0 )); then
                echo -e "  ${RED}⚠ $sensitive_cmds potential secrets in $(basename "$hist_file")${RESET}"
                score=$((score - 5))
                ((issues++))
            fi
        fi
    done
    print_section_end

    # Check 6: Environment Variables
    print_section "🔑 Environment Variable Audit"
    echo ""
    local env_secrets=0
    while IFS='=' read -r key value; do
        if [[ "$key" =~ (PASSWORD|SECRET|TOKEN|API_KEY|PRIVATE) ]] && [[ -n "$value" ]]; then
            local masked_value="${value:0:3}***${value: -2}"
            echo -e "  ${YELLOW}⚠ Sensitive env var: ${WHITE}$key${RESET}=${DIM}$masked_value${RESET}"
            ((env_secrets++))
            ((warnings++))
        fi
    done < <(env 2>/dev/null)

    if (( env_secrets == 0 )); then
        echo -e "  ${GREEN}✓ No sensitive environment variables exposed${RESET}"
    fi
    print_section_end

    # ── Final Score ───────────────────────────────────────────────
    (( score < 0 )) && score=0

    echo ""
    print_section "📊 Security Score"
    echo ""

    local grade grade_color
    if (( score >= 90 )); then
        grade="A+" ; grade_color=$GREEN
    elif (( score >= 80 )); then
        grade="A"  ; grade_color=$GREEN
    elif (( score >= 70 )); then
        grade="B"  ; grade_color=$YELLOW
    elif (( score >= 60 )); then
        grade="C"  ; grade_color=$YELLOW
    elif (( score >= 50 )); then
        grade="D"  ; grade_color=$RED
    else
        grade="F"  ; grade_color=$RED
    fi

    printf "  ${BOLD}${grade_color}"
    printf '  ╔══════════════════════╗\n'
    printf '  ║   SCORE: %3d/100     ║\n' "$score"
    printf '  ║   GRADE: %-2s          ║\n' "$grade"
    printf '  ╚══════════════════════╝\n'
    printf "${RESET}\n"

    echo -e "  ${RED}Critical Issues: $issues${RESET}"
    echo -e "  ${YELLOW}Warnings: $warnings${RESET}"
    echo ""

    # Save report
    {
        echo ""
        echo "SCORE: $score/100 (Grade: $grade)"
        echo "Critical Issues: $issues"
        echo "Warnings: $warnings"
    } >> "$report_file"

    echo -e "  ${DIM}Report saved: $report_file${RESET}"
    print_section_end

    notify "Security Audit Complete: $score/100 (Grade: $grade)"

    echo ""
    echo -ne "  ${DIM}Press Enter to continue...${RESET}"
    read -r
}

# ═══════════════════════════════════════════════════════════════════
# MODULE 3: NETWORK ANALYZER
# ═══════════════════════════════════════════════════════════════════
network_analyzer() {
    log_action "Opened Network Analyzer"
    clear
    print_header "🌐 NETWORK ANALYZER"

    echo -e "\n  ${BOLD}Select analysis:${RESET}\n"
    echo -e "  ${CYAN}[1]${RESET} Connection Monitor"
    echo -e "  ${CYAN}[2]${RESET} DNS Lookup Tool"
    echo -e "  ${CYAN}[3]${RESET} Port Scanner"
    echo -e "  ${CYAN}[4]${RESET} Speed Test (basic)"
    echo -e "  ${CYAN}[5]${RESET} WiFi Information"
    echo -e "  ${CYAN}[6]${RESET} Traceroute"
    echo -e "  ${CYAN}[7]${RESET} HTTP Header Inspector"
    echo -e "  ${CYAN}[0]${RESET} Back"
    echo ""
    echo -ne "  ${WHITE}Choice: ${RESET}"
    read -r net_choice

    case $net_choice in
        1) connection_monitor ;;
        2) dns_lookup ;;
        3) port_scanner ;;
        4) speed_test ;;
        5) wifi_info ;;
        6) traceroute_tool ;;
        7) http_inspector ;;
        0) return ;;
        *) echo -e "  ${RED}Invalid choice${RESET}"; sleep 1 ;;
    esac
}

connection_monitor() {
    clear
    print_header "📡 ACTIVE CONNECTIONS"
    echo ""

    echo -e "  ${BOLD}${UNDERLINE}Proto  Local Address          Foreign Address        State${RESET}"

    local tcp_count=0
    local udp_count=0
    local established=0

    while IFS= read -r line; do
        if [[ "$line" =~ ^tcp ]]; then
            ((tcp_count++))
            [[ "$line" =~ ESTABLISHED ]] && ((established++))
            local state_color=$GRAY
            [[ "$line" =~ ESTABLISHED ]] && state_color=$GREEN
            [[ "$line" =~ CLOSE_WAIT ]] && state_color=$YELLOW
            [[ "$line" =~ TIME_WAIT ]] && state_color=$YELLOW
            echo -e "  ${state_color}${line}${RESET}"
        elif [[ "$line" =~ ^udp ]]; then
            ((udp_count++))
            echo -e "  ${BLUE}${line}${RESET}"
        fi
    done < <(ss -tunp 2>/dev/null || netstat -tunp 2>/dev/null)

    echo ""
    print_section "📊 Summary"
    print_kv "TCP Connections" "$tcp_count"
    print_kv "UDP Connections" "$udp_count"
    print_kv "Established" "$established"
    print_section_end

    echo ""
    echo -ne "  ${DIM}Press Enter to continue...${RESET}"
    read -r
}

dns_lookup() {
    clear
    print_header "🔍 DNS LOOKUP"
    echo ""
    echo -ne "  ${WHITE}Enter domain: ${RESET}"
    read -r domain

    if [[ -z "$domain" ]]; then
        echo -e "  ${RED}No domain specified${RESET}"
        sleep 1
        return
    fi

    echo ""
    print_section "Results for: $domain"

    for type in A AAAA MX NS TXT CNAME SOA; do
        local result
        result=$(nslookup -type="$type" "$domain" 2>/dev/null | grep -A5 "answer:" || \
                 dig +short "$type" "$domain" 2>/dev/null || \
                 host -t "$type" "$domain" 2>/dev/null)
        if [[ -n "$result" ]]; then
            echo -e "\n  ${CYAN}$type Records:${RESET}"
            echo "$result" | head -5 | while IFS= read -r line; do
                echo -e "    ${WHITE}$line${RESET}"
            done
        fi
    done

    # WHOIS (if available)
    if command -v whois &>/dev/null; then
        echo -e "\n  ${CYAN}WHOIS Info:${RESET}"
        whois "$domain" 2>/dev/null | grep -iE "registrar|creation|expiry|name server" | head -8 | while IFS= read -r line; do
            echo -e "    ${DIM}$line${RESET}"
        done
    fi
    print_section_end

    echo ""
    echo -ne "  ${DIM}Press Enter to continue...${RESET}"
    read -r
}

port_scanner() {
    clear
    print_header "🎯 PORT SCANNER"
    echo ""
    echo -ne "  ${WHITE}Target host [127.0.0.1]: ${RESET}"
    read -r target
    target=${target:-127.0.0.1}

    echo -ne "  ${WHITE}Port range [1-1024]: ${RESET}"
    read -r range
    range=${range:-1-1024}

    local start_port end_port
    start_port=$(echo "$range" | cut -d'-' -f1)
    end_port=$(echo "$range" | cut -d'-' -f2)

    echo ""
    echo -e "  ${CYAN}Scanning $target:$start_port-$end_port...${RESET}"
    echo ""

    local open_ports=0
    local total_ports=$((end_port - start_port + 1))
    local scanned=0

    printf "  ${BOLD}${UNDERLINE}%-8s %-12s %s${RESET}\n" "PORT" "STATE" "SERVICE"

    for ((port=start_port; port<=end_port; port++)); do
        ((scanned++))

        # Progress indicator every 100 ports
        if (( scanned % 100 == 0 )); then
            local pct=$((scanned * 100 / total_ports))
            printf "\r  ${DIM}Progress: %d%%${RESET}" "$pct"
        fi

        (echo >/dev/tcp/"$target"/"$port") 2>/dev/null && {
            ((open_ports++))
            local service="unknown"
            case $port in
                21) service="ftp" ;;
                22) service="ssh" ;;
                23) service="telnet" ;;
                25) service="smtp" ;;
                53) service="dns" ;;
                80) service="http" ;;
                110) service="pop3" ;;
                143) service="imap" ;;
                443) service="https" ;;
                993) service="imaps" ;;
                995) service="pop3s" ;;
                3306) service="mysql" ;;
                5432) service="postgresql" ;;
                6379) service="redis" ;;
                8080) service="http-proxy" ;;
                8443) service="https-alt" ;;
                27017) service="mongodb" ;;
            esac
            printf "\r  ${GREEN}%-8s${RESET} ${GREEN}%-12s${RESET} %s\n" "$port" "OPEN" "$service"
        }
    done

    printf "\r%-60s\r" ""
    echo ""
    echo -e "  ${CYAN}Scan complete: $open_ports open port(s) found out of $total_ports scanned${RESET}"

    echo ""
    echo -ne "  ${DIM}Press Enter to continue...${RESET}"
    read -r
}

speed_test() {
    clear
    print_header "⚡ NETWORK SPEED TEST"
    echo ""
    echo -e "  ${CYAN}Testing download speed...${RESET}"

    local test_url="http://speedtest.tele2.net/10MB.zip"
    local temp_file
    temp_file=$(mktemp)

    local start_time
    start_time=$(date +%s%N)

    if curl -s -o "$temp_file" --max-time 30 "$test_url" 2>/dev/null; then
        local end_time
        end_time=$(date +%s%N)
        local duration=$(( (end_time - start_time) / 1000000 ))  # ms
        local file_size
        file_size=$(stat -c%s "$temp_file" 2>/dev/null || wc -c < "$temp_file")

        local speed_bps=$(( file_size * 8 * 1000 / duration ))
        local speed_mbps
        speed_mbps=$(echo "scale=2; $speed_bps / 1048576" | bc 2>/dev/null || echo "$((speed_bps / 1048576))")

        echo ""
        echo -e "  ${GREEN}╔═══════════════════════════╗${RESET}"
        echo -e "  ${GREEN}║  Download: ${WHITE}${BOLD}${speed_mbps} Mbps${RESET}${GREEN}     ║${RESET}"
        echo -e "  ${GREEN}║  Size: ${WHITE}${file_size} bytes${RESET}${GREEN}        ║${RESET}"
        echo -e "  ${GREEN}║  Time: ${WHITE}${duration}ms${RESET}${GREEN}              ║${RESET}"
        echo -e "  ${GREEN}╚═══════════════════════════╝${RESET}"
    else
        echo -e "  ${RED}Speed test failed. Check your connection.${RESET}"
    fi

    rm -f "$temp_file"

    # Latency test
    echo ""
    echo -e "  ${CYAN}Testing latency...${RESET}"
    echo ""

    for host in "8.8.8.8" "1.1.1.1" "google.com"; do
        local ping_result
        ping_result=$(ping -c 3 -W 5 "$host" 2>/dev/null | tail -1)
        if [[ -n "$ping_result" ]]; then
            local avg
            avg=$(echo "$ping_result" | cut -d'/' -f5)
            local lat_color=$GREEN
            local avg_int=${avg%.*}
            (( avg_int > 50 )) && lat_color=$YELLOW
            (( avg_int > 100 )) && lat_color=$RED
            printf "  ${GRAY}%-15s${RESET} ${lat_color}%s ms${RESET}\n" "$host" "$avg"
        else
            printf "  ${GRAY}%-15s${RESET} ${RED}unreachable${RESET}\n" "$host"
        fi
    done

    echo ""
    echo -ne "  ${DIM}Press Enter to continue...${RESET}"
    read -r
}

wifi_info() {
    clear
    print_header "📶 NETWORK INFORMATION"
    echo ""

    print_section "Interface Details"
    ip addr show 2>/dev/null | while IFS= read -r line; do
        if [[ "$line" =~ ^[0-9] ]]; then
            echo -e "\n  ${BOLD}${CYAN}${line}${RESET}"
        elif [[ "$line" =~ inet ]]; then
            echo -e "  ${WHITE}  ${line}${RESET}"
        fi
    done
    print_section_end

    print_section "Routing Table"
    ip route show 2>/dev/null | head -10 | while IFS= read -r line; do
        echo -e "  ${WHITE}$line${RESET}"
    done
    print_section_end

    print_section "DNS Configuration"
    if [[ -f "$PREFIX/etc/resolv.conf" ]]; then
        cat "$PREFIX/etc/resolv.conf" 2>/dev/null | while IFS= read -r line; do
            echo -e "  ${WHITE}$line${RESET}"
        done
    fi
    # Also check prop
    getprop net.dns1 2>/dev/null | while IFS= read -r line; do
        [[ -n "$line" ]] && echo -e "  ${WHITE}DNS1: $line${RESET}"
    done
    print_section_end

    echo ""
    echo -ne "  ${DIM}Press Enter to continue...${RESET}"
    read -r
}

traceroute_tool() {
    clear
    print_header "🗺️  TRACEROUTE"
    echo ""
    echo -ne "  ${WHITE}Target host: ${RESET}"
    read -r target

    if [[ -z "$target" ]]; then
        echo -e "  ${RED}No target specified${RESET}"
        sleep 1
        return
    fi

    echo ""
    echo -e "  ${CYAN}Tracing route to ${WHITE}$target${CYAN}...${RESET}"
    echo ""

    if command -v traceroute &>/dev/null; then
        traceroute -m 20 "$target" 2>/dev/null | while IFS= read -r line; do
            if [[ "$line" =~ \*\ \*\ \* ]]; then
                echo -e "  ${RED}$line${RESET}"
            else
                echo -e "  ${GREEN}$line${RESET}"
            fi
        done
    elif command -v tracepath &>/dev/null; then
        tracepath "$target" 2>/dev/null | while IFS= read -r line; do
            echo -e "  ${WHITE}$line${RESET}"
        done
    else
        # Manual traceroute using ping
        echo -e "  ${YELLOW}traceroute not installed. Using ping-based trace...${RESET}"
        echo ""
        for ((ttl=1; ttl<=20; ttl++)); do
            local result
            result=$(ping -c 1 -W 2 -t "$ttl" "$target" 2>&1)
            local hop_ip
            hop_ip=$(echo "$result" | grep -oE 'from [^ ]+' | head -1 | cut -d' ' -f2 | tr -d ':')
            local rtt
            rtt=$(echo "$result" | grep -oE 'time=[0-9.]+' | head -1 | cut -d'=' -f2)

            if [[ -n "$hop_ip" ]]; then
                printf "  ${WHITE}%2d  %-30s  %s ms${RESET}\n" "$ttl" "$hop_ip" "${rtt:-*}"
                [[ "$hop_ip" == *"$target"* ]] && break
                # Check if we reached destination
                echo "$result" | grep -q "bytes from" && echo "$result" | grep -qv "Time to live exceeded" && break
            else
                printf "  ${RED}%2d  *  *  *${RESET}\n" "$ttl"
            fi
        done
    fi

    echo ""
    echo -ne "  ${DIM}Press Enter to continue...${RESET}"
    read -r
}

http_inspector() {
    clear
    print_header "🔍 HTTP HEADER INSPECTOR"
    echo ""
    echo -ne "  ${WHITE}URL: ${RESET}"
    read -r url

    if [[ -z "$url" ]]; then
        echo -e "  ${RED}No URL specified${RESET}"
        sleep 1
        return
    fi

    # Add protocol if missing
    [[ "$url" != http* ]] && url="https://$url"

    echo ""
    echo -e "  ${CYAN}Inspecting ${WHITE}$url${CYAN}...${RESET}"
    echo ""

    print_section "Response Headers"
    curl -sI -L --max-time 10 "$url" 2>/dev/null | while IFS= read -r line; do
        line=$(echo "$line" | tr -d '\r')
        if [[ "$line" =~ ^HTTP ]]; then
            echo -e "  ${GREEN}${BOLD}$line${RESET}"
        elif [[ "$line" =~ ^[Ss]ecurity ]] || [[ "$line" =~ ^[Ss]trict ]] || \
             [[ "$line" =~ ^[Xx]-[Ff]rame ]] || [[ "$line" =~ ^[Xx]-[Cc]ontent ]]; then
            echo -e "  ${GREEN}$line${RESET}"
        elif [[ "$line" =~ ^[Ss]erver ]]; then
            echo -e "  ${YELLOW}$line${RESET}"
        else
            echo -e "  ${WHITE}$line${RESET}"
        fi
    done
    print_section_end

    # Security header analysis
    print_section "🛡️ Security Header Analysis"
    echo ""

    local headers
    headers=$(curl -sI -L --max-time 10 "$url" 2>/dev/null)

    local security_headers=(
        "Strict-Transport-Security"
        "X-Content-Type-Options"
        "X-Frame-Options"
        "Content-Security-Policy"
        "X-XSS-Protection"
        "Referrer-Policy"
        "Permissions-Policy"
    )

    for header in "${security_headers[@]}"; do
        if echo "$headers" | grep -qi "$header"; then
            echo -e "  ${GREEN}✓${RESET} $header"
        else
            echo -e "  ${RED}✗${RESET} $header ${DIM}(missing)${RESET}"
        fi
    done
    print_section_end

    echo ""
    echo -ne "  ${DIM}Press Enter to continue...${RESET}"
    read -r
}

# ═══════════════════════════════════════════════════════════════════
# MODULE 4: PROCESS MANAGER
# ═══════════════════════════════════════════════════════════════════
process_manager() {
    log_action "Opened Process Manager"

    while true; do
        clear
        print_header "⚙️  PROCESS MANAGER"
        echo ""

        printf "  ${BOLD}${UNDERLINE}%-8s %-6s %-6s %-8s %-8s %s${RESET}\n" \
            "PID" "%CPU" "%MEM" "VSZ" "RSS" "COMMAND"

        local proc_count=0
        while IFS= read -r line; do
            ((proc_count++))
            local user pid cpu mem vsz rss tty stat start time cmd
            read -r user pid cpu mem vsz rss tty stat start time cmd <<< "$line"

            local cpu_color=$GREEN
            local cpu_int=${cpu%.*}
            (( cpu_int > 50 )) && cpu_color=$YELLOW
            (( cpu_int > 80 )) && cpu_color=$RED

            cmd=$(basename "$cmd" 2>/dev/null || echo "$cmd")
            printf "  ${WHITE}%-8s${RESET} ${cpu_color}%-6s${RESET} ${CYAN}%-6s${RESET} %-8s %-8s %s\n" \
                "$pid" "$cpu" "$mem" "$vsz" "$rss" "${cmd:0:25}"
        done < <(ps aux 2>/dev/null | sort -k3 -rn | head -20)

        echo ""
        echo -e "  ${DIM}Total processes: $proc_count${RESET}"
        echo ""
        echo -e "  ${CYAN}[k]${RESET} Kill process  ${CYAN}[s]${RESET} Send signal  ${CYAN}[r]${RESET} Refresh  ${CYAN}[0]${RESET} Back"
        echo ""
        echo -ne "  ${WHITE}Action: ${RESET}"

        read -r -t "$REFRESH_RATE" action || continue

        case $action in
            k|K)
                echo -ne "  ${WHITE}PID to kill: ${RESET}"
                read -r kill_pid
                if [[ -n "$kill_pid" ]]; then
                    if confirm "Kill process $kill_pid?"; then
                        kill -9 "$kill_pid" 2>/dev/null && \
                            echo -e "  ${GREEN}Process $kill_pid killed${RESET}" || \
                            echo -e "  ${RED}Failed to kill process $kill_pid${RESET}"
                        sleep 1
                    fi
                fi
                ;;
            s|S)
                echo -ne "  ${WHITE}PID: ${RESET}"
                read -r sig_pid
                echo -ne "  ${WHITE}Signal (TERM/HUP/USR1/etc): ${RESET}"
                read -r signal
                if [[ -n "$sig_pid" ]] && [[ -n "$signal" ]]; then
                    kill -s "$signal" "$sig_pid" 2>/dev/null && \
                        echo -e "  ${GREEN}Signal $signal sent to $sig_pid${RESET}" || \
                        echo -e "  ${RED}Failed to send signal${RESET}"
                    sleep 1
                fi
                ;;
            0) return ;;
        esac
    done
}

# ═══════════════════════════════════════════════════════════════════
# MODULE 5: SYSTEM SNAPSHOT & COMPARISON
# ═══════════════════════════════════════════════════════════════════
system_snapshot() {
    log_action "System Snapshot"
    clear
    print_header "📸 SYSTEM SNAPSHOT"
    echo ""

    echo -e "  ${CYAN}[1]${RESET} Take new snapshot"
    echo -e "  ${CYAN}[2]${RESET} Compare snapshots"
    echo -e "  ${CYAN}[3]${RESET} List snapshots"
    echo -e "  ${CYAN}[4]${RESET} Delete snapshots"
    echo -e "  ${CYAN}[0]${RESET} Back"
    echo ""
    echo -ne "  ${WHITE}Choice: ${RESET}"
    read -r snap_choice

    case $snap_choice in
        1) take_snapshot ;;
        2) compare_snapshots ;;
        3) list_snapshots ;;
        4) delete_snapshots ;;
        0) return ;;
    esac
}

take_snapshot() {
    local timestamp
    timestamp=$(date '+%Y%m%d_%H%M%S')
    local snap_file="$SNAPSHOT_DIR/snapshot_${timestamp}.dat"

    echo ""
    echo -e "  ${CYAN}Taking system snapshot...${RESET}"

    {
        echo "=== SNAPSHOT: $timestamp ==="
        echo ""

        echo "--- PACKAGES ---"
        dpkg -l 2>/dev/null | grep '^ii' | awk '{print $2, $3}'
        echo ""

        echo "--- PROCESSES ---"
        ps aux 2>/dev/null
        echo ""

        echo "--- NETWORK ---"
        ip addr show 2>/dev/null
        echo ""
        ss -tlnp 2>/dev/null
        echo ""

        echo "--- STORAGE ---"
        df -h 2>/dev/null
        echo ""

        echo "--- ENVIRONMENT ---"
        env | sort
        echo ""

        echo "--- INSTALLED COMMANDS ---"
        ls "$PREFIX/bin/" 2>/dev/null | sort
        echo ""

        echo "--- CRONTABS ---"
        crontab -l 2>/dev/null
        echo ""

        echo "--- HOME DIRECTORY ---"
        find "$HOME" -maxdepth 3 -type f 2>/dev/null | sort | head -500

    } > "$snap_file"

    local snap_size
    snap_size=$(du -h "$snap_file" | cut -f1)
    echo -e "  ${GREEN}✓ Snapshot saved: $snap_file ($snap_size)${RESET}"

    echo ""
    echo -ne "  ${DIM}Press Enter to continue...${RESET}"
    read -r
}

compare_snapshots() {
    local snapshots
    mapfile -t snapshots < <(ls -1 "$SNAPSHOT_DIR"/snapshot_*.dat 2>/dev/null | sort)

    if (( ${#snapshots[@]} < 2 )); then
        echo -e "  ${RED}Need at least 2 snapshots to compare${RESET}"
        sleep 2
        return
    fi

    echo ""
    echo -e "  ${BOLD}Available snapshots:${RESET}"
    for i in "${!snapshots[@]}"; do
        local name
        name=$(basename "${snapshots[$i]}")
        local date_part
        date_part=$(echo "$name" | grep -oE '[0-9]{8}_[0-9]{6}')
        echo -e "  ${CYAN}[$((i+1))]${RESET} $date_part"
    done

    echo ""
    echo -ne "  ${WHITE}First snapshot number: ${RESET}"
    read -r first
    echo -ne "  ${WHITE}Second snapshot number: ${RESET}"
    read -r second

    first=$((first - 1))
    second=$((second - 1))

    if [[ -f "${snapshots[$first]}" ]] && [[ -f "${snapshots[$second]}" ]]; then
        echo ""
        echo -e "  ${CYAN}Comparing snapshots...${RESET}"
        echo ""

        # Package diff
        local pkg_added pkg_removed
        pkg_added=$(diff <(grep -A9999 "PACKAGES" "${snapshots[$first]}" | grep -B9999 "PROCESSES" | grep -v "^---" | grep -v "^==") \
                         <(grep -A9999 "PACKAGES" "${snapshots[$second]}" | grep -B9999 "PROCESSES" | grep -v "^---" | grep -v "^==") 2>/dev/null | grep "^>" | wc -l)
        pkg_removed=$(diff <(grep -A9999 "PACKAGES" "${snapshots[$first]}" | grep -B9999 "PROCESSES" | grep -v "^---" | grep -v "^==") \
                           <(grep -A9999 "PACKAGES" "${snapshots[$second]}" | grep -B9999 "PROCESSES" | grep -v "^---" | grep -v "^==") 2>/dev/null | grep "^<" | wc -l)

        echo -e "  ${GREEN}+${pkg_added} packages added${RESET}"
        echo -e "  ${RED}-${pkg_removed} packages removed${RESET}"

        # Show full diff
        echo ""
        diff --color=always "${snapshots[$first]}" "${snapshots[$second]}" 2>/dev/null | head -50
    else
        echo -e "  ${RED}Invalid snapshot selection${RESET}"
    fi

    echo ""
    echo -ne "  ${DIM}Press Enter to continue...${RESET}"
    read -r
}

list_snapshots() {
    echo ""
    print_section "📋 Saved Snapshots"
    echo ""

    local count=0
    for snap in "$SNAPSHOT_DIR"/snapshot_*.dat; do
        if [[ -f "$snap" ]]; then
            ((count++))
            local name size date_mod
            name=$(basename "$snap")
            size=$(du -h "$snap" | cut -f1)
            date_mod=$(stat -c '%y' "$snap" 2>/dev/null | cut -d'.' -f1)
            echo -e "  ${WHITE}$name${RESET} ${DIM}($size, $date_mod)${RESET}"
        fi
    done

    if (( count == 0 )); then
        echo -e "  ${GRAY}No snapshots found${RESET}"
    else
        echo -e "\n  ${DIM}Total: $count snapshot(s)${RESET}"
    fi
    print_section_end

    echo ""
    echo -ne "  ${DIM}Press Enter to continue...${RESET}"
    read -r
}

delete_snapshots() {
    local count
    count=$(ls -1 "$SNAPSHOT_DIR"/snapshot_*.dat 2>/dev/null | wc -l)

    if (( count == 0 )); then
        echo -e "  ${GRAY}No snapshots to delete${RESET}"
        sleep 1
        return
    fi

    if confirm "Delete all $count snapshot(s)?"; then
        rm -f "$SNAPSHOT_DIR"/snapshot_*.dat
        echo -e "  ${GREEN}✓ All snapshots deleted${RESET}"
    fi
    sleep 1
}

# ═══════════════════════════════════════════════════════════════════
# MODULE 6: TOOLKIT (Productivity Utilities)
# ═══════════════════════════════════════════════════════════════════
toolkit() {
    log_action "Opened Toolkit"
    clear
    print_header "🧰 PRODUCTIVITY TOOLKIT"
    echo ""

    echo -e "  ${CYAN}[1]${RESET}  Quick Backup (home directory)"
    echo -e "  ${CYAN}[2]${RESET}  File Finder (advanced)"
    echo -e "  ${CYAN}[3]${RESET}  Disk Space Analyzer"
    echo -e "  ${CYAN}[4]${RESET}  Batch File Renamer"
    echo -e "  ${CYAN}[5]${RESET}  Text File Statistics"
    echo -e "  ${CYAN}[6]${RESET}  Password Generator"
    echo -e "  ${CYAN}[7]${RESET}  Base64 Encoder/Decoder"
    echo -e "  ${CYAN}[8]${RESET}  Hash Calculator"
    echo -e "  ${CYAN}[9]${RESET}  JSON Formatter"
    echo -e "  ${CYAN}[10]${RESET} QR Code Generator"
    echo -e "  ${CYAN}[11]${RESET} Clipboard Manager"
    echo -e "  ${CYAN}[12]${RESET} System Cleaner"
    echo -e "  ${CYAN}[0]${RESET}  Back"
    echo ""
    echo -ne "  ${WHITE}Choice: ${RESET}"
    read -r tool_choice

    case $tool_choice in
        1) quick_backup ;;
        2) file_finder ;;
        3) disk_analyzer ;;
        4) batch_renamer ;;
        5) text_stats ;;
        6) password_generator ;;
        7) base64_tool ;;
        8) hash_calculator ;;
        9) json_formatter ;;
        10) qr_generator ;;
        11) clipboard_manager ;;
        12) system_cleaner ;;
        0) return ;;
        *) echo -e "  ${RED}Invalid choice${RESET}"; sleep 1 ;;
    esac
}

quick_backup() {
    clear
    print_header "💾 QUICK BACKUP"
    echo ""

    local timestamp
    timestamp=$(date '+%Y%m%d_%H%M%S')
    local backup_file="$HOME/backup_${timestamp}.tar.gz"

    echo -e "  ${CYAN}What to backup:${RESET}"
    echo -e "  ${CYAN}[1]${RESET} Home directory (excluding caches)"
    echo -e "  ${CYAN}[2]${RESET} Termux configuration"
    echo -e "  ${CYAN}[3]${RESET} Custom path"
    echo ""
    echo -ne "  ${WHITE}Choice: ${RESET}"
    read -r backup_choice

    local source_path exclude_opts

    case $backup_choice in
        1)
            source_path="$HOME"
            exclude_opts="--exclude='.cache' --exclude='*.tmp' --exclude='backup_*.tar.gz' --exclude='.system-guardian/snapshots'"
            ;;
        2)
            source_path="$PREFIX/etc"
            exclude_opts=""
            ;;
        3)
            echo -ne "  ${WHITE}Path to backup: ${RESET}"
            read -r source_path
            exclude_opts=""
            ;;
        *)
            echo -e "  ${RED}Invalid choice${RESET}"
            sleep 1
            return
            ;;
    esac

    if [[ ! -e "$source_path" ]]; then
        echo -e "  ${RED}Path does not exist: $source_path${RESET}"
        sleep 2
        return
    fi

    echo ""
    echo -e "  ${CYAN}Creating backup...${RESET}"

    (
        eval tar czf "$backup_file" "$exclude_opts" -C "$(dirname "$source_path")" "$(basename "$source_path")" 2>/dev/null
    ) &
    spinner $! "Compressing files..."

    if [[ -f "$backup_file" ]]; then
        local backup_size
        backup_size=$(du -h "$backup_file" | cut -f1)
        echo -e "  ${GREEN}✓ Backup created: $backup_file ($backup_size)${RESET}"

        # Generate checksum
        local checksum
        checksum=$(sha256sum "$backup_file" 2>/dev/null | cut -d' ' -f1)
        echo -e "  ${DIM}SHA256: ${checksum:0:16}...${RESET}"
    else
        echo -e "  ${RED}✗ Backup failed${RESET}"
    fi

    echo ""
    echo -ne "  ${DIM}Press Enter to continue...${RESET}"
    read -r
}

file_finder() {
    clear
    print_header "🔍 ADVANCED FILE FINDER"
    echo ""

    echo -ne "  ${WHITE}Search directory [~]: ${RESET}"
    read -r search_dir
    search_dir=${search_dir:-$HOME}

    echo -ne "  ${WHITE}Search pattern: ${RESET}"
    read -r pattern

    echo -e "\n  ${CYAN}Filter by:${RESET}"
    echo -e "  ${CYAN}[1]${RESET} Name only"
    echo -e "  ${CYAN}[2]${RESET} Content (grep)"
    echo -e "  ${CYAN}[3]${RESET} Size (larger than)"
    echo -e "  ${CYAN}[4]${RESET} Modified (last N days)"
    echo -ne "  ${WHITE}Filter: ${RESET}"
    read -r filter

    echo ""
    echo -e "  ${CYAN}Searching...${RESET}"
    echo ""

    case $filter in
        1)
            find "$search_dir" -maxdepth 5 -iname "*$pattern*" 2>/dev/null | head -50 | while IFS= read -r f; do
                local size
                size=$(du -h "$f" 2>/dev/null | cut -f1)
                echo -e "  ${WHITE}$f${RESET} ${DIM}($size)${RESET}"
            done
            ;;
        2)
            grep -rl --include="*.txt" --include="*.sh" --include="*.py" --include="*.js" \
                --include="*.conf" --include="*.cfg" --include="*.json" --include="*.xml" \
                "$pattern" "$search_dir" 2>/dev/null | head -30 | while IFS= read -r f; do
                local matches
                matches=$(grep -c "$pattern" "$f" 2>/dev/null)
                echo -e "  ${WHITE}$f${RESET} ${DIM}($matches matches)${RESET}"
            done
            ;;
        3)
            echo -ne "  ${WHITE}Minimum size (e.g., 10M): ${RESET}"
            read -r min_size
            find "$search_dir" -maxdepth 5 -size "+${min_size}" -iname "*$pattern*" 2>/dev/null | head -30 | while IFS= read -r f; do
                local size
                size=$(du -h "$f" 2>/dev/null | cut -f1)
                echo -e "  ${WHITE}$f${RESET} ${DIM}($size)${RESET}"
            done
            ;;
        4)
            echo -ne "  ${WHITE}Modified in last N days: ${RESET}"
            read -r days
            find "$search_dir" -maxdepth 5 -mtime "-${days}" -iname "*$pattern*" 2>/dev/null | head -30 | while IFS= read -r f; do
                local mod_time
                mod_time=$(stat -c '%y' "$f" 2>/dev/null | cut -d'.' -f1)
                echo -e "  ${WHITE}$f${RESET} ${DIM}($mod_time)${RESET}"
            done
            ;;
    esac

    echo ""
    echo -ne "  ${DIM}Press Enter to continue...${RESET}"
    read -r
}

disk_analyzer() {
    clear
    print_header "📊 DISK SPACE ANALYZER"
    echo ""

    echo -ne "  ${WHITE}Directory to analyze [~]: ${RESET}"
    read -r analyze_dir
    analyze_dir=${analyze_dir:-$HOME}

    echo ""
    echo -e "  ${CYAN}Analyzing $analyze_dir...${RESET}"
    echo ""

    print_section "Top 15 Largest Directories"
    echo ""
    printf "  ${BOLD}${UNDERLINE}%-10s %s${RESET}\n" "SIZE" "DIRECTORY"

    du -sh "$analyze_dir"/*/ 2>/dev/null | sort -rh | head -15 | while IFS=$'\t' read -r size dir; do
        local bar_len
        local size_num
        size_num=$(echo "$size" | grep -oE '[0-9.]+')
        local size_unit
        size_unit=$(echo "$size" | grep -oE '[KMGT]')

        case $size_unit in
            T) bar_len=30 ;;
            G) bar_len=$(echo "$size_num * 3" | bc 2>/dev/null | cut -d. -f1 || echo 15) ;;
            M) bar_len=$(echo "$size_num / 50" | bc 2>/dev/null | cut -d. -f1 || echo 5) ;;
            K) bar_len=1 ;;
            *) bar_len=1 ;;
        esac
        (( bar_len > 30 )) && bar_len=30
        (( bar_len < 1 )) && bar_len=1

        local bar
        bar=$(printf '█%.0s' $(seq 1 "$bar_len"))
        dir=$(basename "$dir")
        printf "  ${WHITE}%-10s${RESET} ${CYAN}%-30s${RESET} ${GREEN}%s${RESET}\n" "$size" "${dir:0:30}" "$bar"
    done
    print_section_end

    print_section "File Type Distribution"
    echo ""
    printf "  ${BOLD}${UNDERLINE}%-8s %-10s %s${RESET}\n" "COUNT" "SIZE" "TYPE"

    find "$analyze_dir" -maxdepth 3 -type f 2>/dev/null | \
        sed 's/.*\.//' | sort | uniq -c | sort -rn | head -10 | \
        while read -r count ext; do
            local total_size
            total_size=$(find "$analyze_dir" -maxdepth 3 -name "*.$ext" -exec du -ch {} + 2>/dev/null | tail -1 | cut -f1)
            printf "  ${WHITE}%-8s${RESET} ${CYAN}%-10s${RESET} .%s\n" "$count" "${total_size:-0}" "$ext"
        done
    print_section_end

    echo ""
    echo -ne "  ${DIM}Press Enter to continue...${RESET}"
    read -r
}

batch_renamer() {
    clear
    print_header "📝 BATCH FILE RENAMER"
    echo ""

    echo -ne "  ${WHITE}Directory: ${RESET}"
    read -r rename_dir

    if [[ ! -d "$rename_dir" ]]; then
        echo -e "  ${RED}Directory not found${RESET}"
        sleep 1
        return
    fi

    echo -e "\n  ${CYAN}Rename operations:${RESET}"
    echo -e "  ${CYAN}[1]${RESET} Add prefix"
    echo -e "  ${CYAN}[2]${RESET} Add suffix"
    echo -e "  ${CYAN}[3]${RESET} Replace text"
    echo -e "  ${CYAN}[4]${RESET} Sequential numbering"
    echo -e "  ${CYAN}[5]${RESET} Lowercase all"
    echo -e "  ${CYAN}[6]${RESET} Uppercase all"
    echo ""
    echo -ne "  ${WHITE}Operation: ${RESET}"
    read -r op

    local preview_count=0

    echo -e "\n  ${YELLOW}Preview of changes:${RESET}\n"

    case $op in
        1)
            echo -ne "  ${WHITE}Prefix: ${RESET}"
            read -r prefix
            for f in "$rename_dir"/*; do
                [[ -f "$f" ]] || continue
                local base
                base=$(basename "$f")
                echo -e "  ${DIM}$base${RESET} → ${WHITE}${prefix}${base}${RESET}"
                ((preview_count++))
            done
            ;;
        2)
            echo -ne "  ${WHITE}Suffix (before extension): ${RESET}"
            read -r suffix
            for f in "$rename_dir"/*; do
                [[ -f "$f" ]] || continue
                local base ext name
                base=$(basename "$f")
                ext="${base##*.}"
                name="${base%.*}"
                echo -e "  ${DIM}$base${RESET} → ${WHITE}${name}${suffix}.${ext}${RESET}"
                ((preview_count++))
            done
            ;;
        3)
            echo -ne "  ${WHITE}Find text: ${RESET}"
            read -r find_text
            echo -ne "  ${WHITE}Replace with: ${RESET}"
            read -r replace_text
            for f in "$rename_dir"/*; do
                [[ -f "$f" ]] || continue
                local base new_name
                base=$(basename "$f")
                new_name="${base//$find_text/$replace_text}"
                if [[ "$base" != "$new_name" ]]; then
                    echo -e "  ${DIM}$base${RESET} → ${WHITE}$new_name${RESET}"
                    ((preview_count++))
                fi
            done
            ;;
        4)
            echo -ne "  ${WHITE}Base name: ${RESET}"
            read -r base_name
            local num=1
            for f in "$rename_dir"/*; do
                [[ -f "$f" ]] || continue
                local base ext
                base=$(basename "$f")
                ext="${base##*.}"
                printf "  ${DIM}%s${RESET} → ${WHITE}%s_%03d.%s${RESET}\n" "$base" "$base_name" "$num" "$ext"
                ((num++))
                ((preview_count++))
            done
            ;;
        5)
            for f in "$rename_dir"/*; do
                [[ -f "$f" ]] || continue
                local base lower
                base=$(basename "$f")
                lower=$(echo "$base" | tr '[:upper:]' '[:lower:]')
                if [[ "$base" != "$lower" ]]; then
                    echo -e "  ${DIM}$base${RESET} → ${WHITE}$lower${RESET}"
                    ((preview_count++))
                fi
            done
            ;;
        6)
            for f in "$rename_dir"/*; do
                [[ -f "$f" ]] || continue
                local base upper
                base=$(basename "$f")
                upper=$(echo "$base" | tr '[:lower:]' '[:upper:]')
                if [[ "$base" != "$upper" ]]; then
                    echo -e "  ${DIM}$base${RESET} → ${WHITE}$upper${RESET}"
                    ((preview_count++))
                fi
            done
            ;;
    esac

    echo ""
    echo -e "  ${CYAN}$preview_count file(s) will be renamed${RESET}"

    if (( preview_count > 0 )) && confirm "Apply changes?"; then
        case $op in
            1) for f in "$rename_dir"/*; do [[ -f "$f" ]] && mv "$f" "$rename_dir/${prefix}$(basename "$f")"; done ;;
            2) for f in "$rename_dir"/*; do
                   [[ -f "$f" ]] || continue
                   local b="${f##*/}" e="${f##*.}" n="${b%.*}"
                   mv "$f" "$rename_dir/${n}${suffix}.${e}"
               done ;;
            3) for f in "$rename_dir"/*; do
                   [[ -f "$f" ]] || continue
                   local b="${f##*/}" nn="${b//$find_text/$replace_text}"
                   [[ "$b" != "$nn" ]] && mv "$f" "$rename_dir/$nn"
               done ;;
            5) for f in "$rename_dir"/*; do
                   [[ -f "$f" ]] || continue
                   local b="${f##*/}" l=$(echo "${f##*/}" | tr '[:upper:]' '[:lower:]')
                   [[ "$b" != "$l" ]] && mv "$f" "$rename_dir/$l"
               done ;;
            6) for f in "$rename_dir"/*; do
                   [[ -f "$f" ]] || continue
                   local b="${f##*/}" u=$(echo "${f##*/}" | tr '[:lower:]' '[:upper:]')
                   [[ "$b" != "$u" ]] && mv "$f" "$rename_dir/$u"
               done ;;
        esac
        echo -e "  ${GREEN}✓ Files renamed successfully${RESET}"
    fi

    echo ""
    echo -ne "  ${DIM}Press Enter to continue...${RESET}"
    read -r
}

text_stats() {
    clear
    print_header "📄 TEXT FILE STATISTICS"
    echo ""

    echo -ne "  ${WHITE}File path: ${RESET}"
    read -r filepath

    if [[ ! -f "$filepath" ]]; then
        echo -e "  ${RED}File not found${RESET}"
        sleep 1
        return
    fi

    echo ""
    print_section "Statistics for: $(basename "$filepath")"
    echo ""

    local lines words chars bytes
    lines=$(wc -l < "$filepath")
    words=$(wc -w < "$filepath")
    chars=$(wc -m < "$filepath")
    bytes=$(wc -c < "$filepath")

    print_kv "Lines" "$lines"
    print_kv "Words" "$words"
    print_kv "Characters" "$chars"
    print_kv "Bytes" "$bytes"
    print_kv "File Size" "$(du -h "$filepath" | cut -f1)"

    local blank_lines
    blank_lines=$(grep -c '^$' "$filepath")
    print_kv "Blank Lines" "$blank_lines"

    local avg_line_len=0
    (( lines > 0 )) && avg_line_len=$((chars / lines))
    print_kv "Avg Line Length" "$avg_line_len chars"

    local longest_line
    longest_line=$(awk '{ if (length > max) max = length } END { print max }' "$filepath")
    print_kv "Longest Line" "$longest_line chars"

    echo ""
    echo -e "  ${BOLD}Top 10 Most Frequent Words:${RESET}"
    tr -cs '[:alpha:]' '\n' < "$filepath" | tr '[:upper:]' '[:lower:]' | sort | uniq -c | sort -rn | head -10 | \
        while read -r count word; do
            printf "    ${WHITE}%-20s${RESET} ${CYAN}%s${RESET}\n" "$word" "$count"
        done
    print_section_end

    echo ""
    echo -ne "  ${DIM}Press Enter to continue...${RESET}"
    read -r
}

password_generator() {
    clear
    print_header "🔐 PASSWORD GENERATOR"
    echo ""

    echo -ne "  ${WHITE}Password length [16]: ${RESET}"
    read -r pw_length
    pw_length=${pw_length:-16}

    echo -ne "  ${WHITE}Number of passwords [5]: ${RESET}"
    read -r pw_count
    pw_count=${pw_count:-5}

    echo -ne "  ${WHITE}Include symbols? [Y/n]: ${RESET}"
    read -r include_symbols
    include_symbols=${include_symbols:-Y}

    echo ""
    print_section "Generated Passwords"
    echo ""

    local charset='A-Za-z0-9'
    [[ "$include_symbols" =~ ^[Yy] ]] && charset='A-Za-z0-9!@#$%^&*()_+-=[]{}|;:,.<>?'

    for ((i=1; i<=pw_count; i++)); do
        local password
        password=$(tr -dc "$charset" < /dev/urandom 2>/dev/null | head -c "$pw_length")

        # Password strength indicator
        local strength=0
        [[ "$password" =~ [a-z] ]] && ((strength++))
        [[ "$password" =~ [A-Z] ]] && ((strength++))
        [[ "$password" =~ [0-9] ]] && ((strength++))
        [[ "$password" =~ [^a-zA-Z0-9] ]] && ((strength++))
        (( pw_length >= 12 )) && ((strength++))

        local strength_label strength_color
        case $strength in
            5) strength_label="EXCELLENT" ; strength_color=$GREEN ;;
            4) strength_label="STRONG"    ; strength_color=$GREEN ;;
            3) strength_label="GOOD"      ; strength_color=$YELLOW ;;
            2) strength_label="FAIR"      ; strength_color=$YELLOW ;;
            *) strength_label="WEAK"      ; strength_color=$RED ;;
        esac

        printf "  ${WHITE}%2d.${RESET} ${BOLD}%s${RESET}  ${strength_color}[%s]${RESET}\n" "$i" "$password" "$strength_label"
    done

    # Also generate passphrases
    echo ""
    echo -e "  ${BOLD}Passphrase alternatives:${RESET}"
    local wordlist=("correct" "horse" "battery" "staple" "quantum" "nebula" "phoenix" "crystal"
                    "thunder" "mystic" "shadow" "cipher" "aurora" "zenith" "vertex" "prism"
                    "cosmic" "stellar" "vortex" "matrix" "fusion" "plasma" "delta" "sigma"
                    "omega" "titan" "nova" "lunar" "solar" "blaze" "frost" "storm")

    for ((i=1; i<=3; i++)); do
        local passphrase=""
        for ((w=0; w<4; w++)); do
            local idx=$(( RANDOM % ${#wordlist[@]} ))
            passphrase+="${wordlist[$idx]}-"
        done
        passphrase="${passphrase%-}"
        local num=$(( RANDOM % 100 ))
        printf "  ${WHITE}%2d.${RESET} ${BOLD}%s%d${RESET}\n" "$i" "$passphrase" "$num"
    done

    print_section_end

    echo ""
    echo -ne "  ${DIM}Press Enter to continue...${RESET}"
    read -r
}

base64_tool() {
    clear
    print_header "🔄 BASE64 ENCODER/DECODER"
    echo ""

    echo -e "  ${CYAN}[1]${RESET} Encode text"
    echo -e "  ${CYAN}[2]${RESET} Decode text"
    echo -e "  ${CYAN}[3]${RESET} Encode file"
    echo -e "  ${CYAN}[4]${RESET} Decode file"
    echo ""
    echo -ne "  ${WHITE}Choice: ${RESET}"
    read -r b64_choice

    case $b64_choice in
        1)
            echo -ne "  ${WHITE}Text to encode: ${RESET}"
            read -r text
            echo ""
            echo -e "  ${GREEN}Result:${RESET}"
            echo "  $(echo -n "$text" | base64)"
            ;;
        2)
            echo -ne "  ${WHITE}Base64 to decode: ${RESET}"
            read -r encoded
            echo ""
            echo -e "  ${GREEN}Result:${RESET}"
            echo "  $(echo "$encoded" | base64 -d 2>/dev/null || echo "Invalid base64")"
            ;;
        3)
            echo -ne "  ${WHITE}File path: ${RESET}"
            read -r filepath
            if [[ -f "$filepath" ]]; then
                local output="${filepath}.b64"
                base64 "$filepath" > "$output"
                echo -e "  ${GREEN}Encoded to: $output${RESET}"
            else
                echo -e "  ${RED}File not found${RESET}"
            fi
            ;;
        4)
            echo -ne "  ${WHITE}Base64 file path: ${RESET}"
            read -r filepath
            if [[ -f "$filepath" ]]; then
                local output="${filepath%.b64}"
                [[ "$output" == "$filepath" ]] && output="${filepath}.decoded"
                base64 -d "$filepath" > "$output"
                echo -e "  ${GREEN}Decoded to: $output${RESET}"
            else
                echo -e "  ${RED}File not found${RESET}"
            fi
            ;;
    esac

    echo ""
    echo -ne "  ${DIM}Press Enter to continue...${RESET}"
    read -r
}

hash_calculator() {
    clear
    print_header "🧮 HASH CALCULATOR"
    echo ""

    echo -e "  ${CYAN}[1]${RESET} Hash text"
    echo -e "  ${CYAN}[2]${RESET} Hash file"
    echo ""
    echo -ne "  ${WHITE}Choice: ${RESET}"
    read -r hash_choice

    local input_data=""

    case $hash_choice in
        1)
            echo -ne "  ${WHITE}Text: ${RESET}"
            read -r input_data
            echo ""
            print_section "Hash Results"
            echo ""
            echo -e "  ${CYAN}MD5:${RESET}    $(echo -n "$input_data" | md5sum | cut -d' ' -f1)"
            echo -e "  ${CYAN}SHA1:${RESET}   $(echo -n "$input_data" | sha1sum | cut -d' ' -f1)"
            echo -e "  ${CYAN}SHA256:${RESET} $(echo -n "$input_data" | sha256sum | cut -d' ' -f1)"
            echo -e "  ${CYAN}SHA512:${RESET} $(echo -n "$input_data" | sha512sum | cut -d' ' -f1)"
            print_section_end
            ;;
        2)
            echo -ne "  ${WHITE}File path: ${RESET}"
            read -r filepath
            if [[ -f "$filepath" ]]; then
                echo ""
                print_section "Hash Results for: $(basename "$filepath")"
                echo ""
                echo -e "  ${CYAN}MD5:${RESET}    $(md5sum "$filepath" | cut -d' ' -f1)"
                echo -e "  ${CYAN}SHA1:${RESET}   $(sha1sum "$filepath" | cut -d' ' -f1)"
                echo -e "  ${CYAN}SHA256:${RESET} $(sha256sum "$filepath" | cut -d' ' -f1)"
                echo -e "  ${CYAN}SHA512:${RESET} $(sha512sum "$filepath" | cut -d' ' -f1)"
                print_section_end
            else
                echo -e "  ${RED}File not found${RESET}"
            fi
            ;;
    esac

    echo ""
    echo -ne "  ${DIM}Press Enter to continue...${RESET}"
    read -r
}

json_formatter() {
    clear
    print_header "📋 JSON FORMATTER"
    echo ""

    echo -e "  ${CYAN}[1]${RESET} Format from input"
    echo -e "  ${CYAN}[2]${RESET} Format from file"
    echo -e "  ${CYAN}[3]${RESET} Format from URL"
    echo ""
    echo -ne "  ${WHITE}Choice: ${RESET}"
    read -r json_choice

    local json_data=""

    case $json_choice in
        1)
            echo -ne "  ${WHITE}JSON string: ${RESET}"
            read -r json_data
            ;;
        2)
            echo -ne "  ${WHITE}File path: ${RESET}"
            read -r filepath
            [[ -f "$filepath" ]] && json_data=$(cat "$filepath")
            ;;
        3)
            echo -ne "  ${WHITE}URL: ${RESET}"
            read -r url
            json_data=$(curl -s "$url" 2>/dev/null)
            ;;
    esac

    if [[ -n "$json_data" ]]; then
        echo ""
        if command -v python3 &>/dev/null; then
            echo "$json_data" | python3 -m json.tool 2>/dev/null && true || \
                echo -e "  ${RED}Invalid JSON${RESET}"
        elif command -v jq &>/dev/null; then
            echo "$json_data" | jq '.' 2>/dev/null || echo -e "  ${RED}Invalid JSON${RESET}"
        else
            echo -e "  ${YELLOW}Install python3 or jq for formatting: pkg install python jq${RESET}"
            echo ""
            echo "$json_data"
        fi
    else
        echo -e "  ${RED}No JSON data provided${RESET}"
    fi

    echo ""
    echo -ne "  ${DIM}Press Enter to continue...${RESET}"
    read -r
}

qr_generator() {
    clear
    print_header "📱 QR CODE GENERATOR"
    echo ""

    echo -ne "  ${WHITE}Text/URL to encode: ${RESET}"
    read -r qr_text

    if [[ -z "$qr_text" ]]; then
        echo -e "  ${RED}No text provided${RESET}"
        sleep 1
        return
    fi

    echo ""

    if command -v qrencode &>/dev/null; then
        qrencode -t ANSI256 "$qr_text" 2>/dev/null
    else
        # ASCII QR approximation using a web API
        echo -e "  ${YELLOW}For full QR support: pkg install libqrencode${RESET}"
        echo ""
        echo -e "  ${CYAN}Your text:${RESET} $qr_text"
        echo ""

        # Simple block pattern as visual placeholder
        local len=${#qr_text}
        local size=$(( len > 10 ? 10 : len + 4 ))

        echo -e "  ${WHITE}█████████████████████${RESET}"
        echo -e "  ${WHITE}█${RESET} ${BG_WHITE}                 ${RESET} ${WHITE}█${RESET}"
        echo -e "  ${WHITE}█${RESET}  ${WHITE}███   ███   ███${RESET}  ${WHITE}█${RESET}"
        echo -e "  ${WHITE}█${RESET}  ${WHITE}█ █   █ █   █ █${RESET}  ${WHITE}█${RESET}"
        echo -e "  ${WHITE}█${RESET}  ${WHITE}███   ███   ███${RESET}  ${WHITE}█${RESET}"
        echo -e "  ${WHITE}█${RESET}                   ${WHITE}█${RESET}"
        echo -e "  ${WHITE}█${RESET}  ${DIM}[Install qrencode]${RESET} ${WHITE}█${RESET}"
        echo -e "  ${WHITE}█${RESET}  ${DIM}[for actual QR  ]${RESET} ${WHITE}█${RESET}"
        echo -e "  ${WHITE}█${RESET}                   ${WHITE}█${RESET}"
        echo -e "  ${WHITE}█████████████████████${RESET}"
    fi

    echo ""
    echo -ne "  ${DIM}Press Enter to continue...${RESET}"
    read -r
}

clipboard_manager() {
    clear
    print_header "📋 CLIPBOARD MANAGER"
    echo ""

    if ! command -v termux-clipboard-get &>/dev/null; then
        echo -e "  ${YELLOW}Requires Termux:API. Install with:${RESET}"
        echo -e "  ${WHITE}pkg install termux-api${RESET}"
        echo ""
        echo -ne "  ${DIM}Press Enter to continue...${RESET}"
        read -r
        return
    fi

    echo -e "  ${CYAN}[1]${RESET} View clipboard"
    echo -e "  ${CYAN}[2]${RESET} Set clipboard"
    echo -e "  ${CYAN}[3]${RESET} Save clipboard to file"
    echo -e "  ${CYAN}[4]${RESET} Load file to clipboard"
    echo ""
    echo -ne "  ${WHITE}Choice: ${RESET}"
    read -r clip_choice

    case $clip_choice in
        1)
            echo ""
            echo -e "  ${CYAN}Current clipboard content:${RESET}"
            echo -e "  ${DIM}$(print_line '-')${RESET}"
            termux-clipboard-get 2>/dev/null
            echo -e "  ${DIM}$(print_line '-')${RESET}"
            ;;
        2)
            echo -ne "  ${WHITE}Text to copy: ${RESET}"
            read -r clip_text
            echo -n "$clip_text" | termux-clipboard-set 2>/dev/null
            echo -e "  ${GREEN}✓ Copied to clipboard${RESET}"
            ;;
        3)
            echo -ne "  ${WHITE}Save to file: ${RESET}"
            read -r clip_file
            termux-clipboard-get > "$clip_file" 2>/dev/null
            echo -e "  ${GREEN}✓ Clipboard saved to $clip_file${RESET}"
            ;;
        4)
            echo -ne "  ${WHITE}File to load: ${RESET}"
            read -r clip_file
            if [[ -f "$clip_file" ]]; then
                cat "$clip_file" | termux-clipboard-set 2>/dev/null
                echo -e "  ${GREEN}✓ File contents copied to clipboard${RESET}"
            else
                echo -e "  ${RED}File not found${RESET}"
            fi
            ;;
    esac

    echo ""
    echo -ne "  ${DIM}Press Enter to continue...${RESET}"
    read -r
}

system_cleaner() {
    clear
    print_header "🧹 SYSTEM CLEANER"
    echo ""

    echo -e "  ${CYAN}Analyzing cleanable items...${RESET}\n"

    local total_saved=0

    # APT cache
    local apt_cache_size
    apt_cache_size=$(du -sh "$PREFIX/var/cache/apt/archives/" 2>/dev/null | cut -f1)
    echo -e "  ${WHITE}APT cache:${RESET} $apt_cache_size"

    # Temp files
    local temp_size
    temp_size=$(find "$PREFIX/tmp" "$HOME/tmp" -type f 2>/dev/null | xargs du -ch 2>/dev/null | tail -1 | cut -f1)
    echo -e "  ${WHITE}Temp files:${RESET} ${temp_size:-0}"

    # Log files
    local log_size
    log_size=$(find "$HOME" -maxdepth 3 -name "*.log" -type f 2>/dev/null | xargs du -ch 2>/dev/null | tail -1 | cut -f1)
    echo -e "  ${WHITE}Log files:${RESET} ${log_size:-0}"

    # Thumbnail cache
    local thumb_size
    thumb_size=$(du -sh "$HOME/.thumbnails" 2>/dev/null | cut -f1)
    [[ -n "$thumb_size" ]] && echo -e "  ${WHITE}Thumbnails:${RESET} $thumb_size"

    # Python cache
    local pycache_size
    pycache_size=$(find "$HOME" -maxdepth 5 -name "__pycache__" -type d 2>/dev/null | xargs du -ch 2>/dev/null | tail -1 | cut -f1)
    [[ -n "$pycache_size" ]] && echo -e "  ${WHITE}Python cache:${RESET} $pycache_size"

    # Guardian old logs
    local guardian_log_size
    guardian_log_size=$(du -sh "$LOG_DIR" 2>/dev/null | cut -f1)
    echo -e "  ${WHITE}Guardian logs:${RESET} ${guardian_log_size:-0}"

    echo ""
    echo -e "  ${BOLD}Select cleanup actions:${RESET}\n"
    echo -e "  ${CYAN}[1]${RESET} Clean APT cache"
    echo -e "  ${CYAN}[2]${RESET} Clean temp files"
    echo -e "  ${CYAN}[3]${RESET} Clean old logs (>30 days)"
    echo -e "  ${CYAN}[4]${RESET} Clean Python caches"
    echo -e "  ${CYAN}[5]${RESET} Clean ALL"
    echo -e "  ${CYAN}[0]${RESET} Cancel"
    echo ""
    echo -ne "  ${WHITE}Choice: ${RESET}"
    read -r clean_choice

    case $clean_choice in
        1)
            apt clean 2>/dev/null
            echo -e "  ${GREEN}✓ APT cache cleaned${RESET}"
            ;;
        2)
            rm -rf "$PREFIX/tmp/"* "$HOME/tmp/"* 2>/dev/null
            echo -e "  ${GREEN}✓ Temp files cleaned${RESET}"
            ;;
        3)
            find "$HOME" -maxdepth 3 -name "*.log" -mtime +30 -delete 2>/dev/null
            find "$LOG_DIR" -name "*.log" -mtime +30 -delete 2>/dev/null
            echo -e "  ${GREEN}✓ Old logs cleaned${RESET}"
            ;;
        4)
            find "$HOME" -maxdepth 5 -name "__pycache__" -type d -exec rm -rf {} + 2>/dev/null
            find "$HOME" -maxdepth 5 -name "*.pyc" -delete 2>/dev/null
            echo -e "  ${GREEN}✓ Python caches cleaned${RESET}"
            ;;
        5)
            if confirm "Run full cleanup?"; then
                apt clean 2>/dev/null
                rm -rf "$PREFIX/tmp/"* "$HOME/tmp/"* 2>/dev/null
                find "$HOME" -maxdepth 3 -name "*.log" -mtime +30 -delete 2>/dev/null
                find "$HOME" -maxdepth 5 -name "__pycache__" -type d -exec rm -rf {} + 2>/dev/null
                find "$HOME" -maxdepth 5 -name "*.pyc" -delete 2>/dev/null
                echo -e "  ${GREEN}✓ Full cleanup complete${RESET}"
            fi
            ;;
        0) return ;;
    esac

    echo ""
    echo -ne "  ${DIM}Press Enter to continue...${RESET}"
    read -r
}

# ═══════════════════════════════════════════════════════════════════
# MODULE 7: CRON/AUTOMATION MANAGER
# ═══════════════════════════════════════════════════════════════════
automation_manager() {
    log_action "Opened Automation Manager"
    clear
    print_header "⏰ AUTOMATION MANAGER"
    echo ""

    echo -e "  ${CYAN}[1]${RESET} View scheduled tasks"
    echo -e "  ${CYAN}[2]${RESET} Add new scheduled task"
    echo -e "  ${CYAN}[3]${RESET} Remove scheduled task"
    echo -e "  ${CYAN}[4]${RESET} Quick schedules"
    echo -e "  ${CYAN}[5]${RESET} View automation log"
    echo -e "  ${CYAN}[0]${RESET} Back"
    echo ""
    echo -ne "  ${WHITE}Choice: ${RESET}"
    read -r auto_choice

    case $auto_choice in
        1)
            echo ""
            print_section "Current Crontab"
            echo ""
            local cron_output
            cron_output=$(crontab -l 2>/dev/null)
            if [[ -n "$cron_output" ]]; then
                echo "$cron_output" | while IFS= read -r line; do
                    if [[ "$line" =~ ^# ]]; then
                        echo -e "  ${DIM}$line${RESET}"
                    else
                        echo -e "  ${WHITE}$line${RESET}"
                    fi
                done
            else
                echo -e "  ${GRAY}No scheduled tasks${RESET}"
            fi
            print_section_end
            ;;
        2)
            echo ""
            echo -ne "  ${WHITE}Command to schedule: ${RESET}"
            read -r cmd
            echo -ne "  ${WHITE}Schedule (cron format, e.g., '0 * * * *'): ${RESET}"
            read -r schedule
            echo -ne "  ${WHITE}Description: ${RESET}"
            read -r description

            if [[ -n "$cmd" ]] && [[ -n "$schedule" ]]; then
                (crontab -l 2>/dev/null; echo "# $description"; echo "$schedule $cmd") | crontab -
                echo -e "  ${GREEN}✓ Task scheduled${RESET}"
            fi
            ;;
        4)
            echo ""
            echo -e "  ${BOLD}Quick Schedules:${RESET}"
            echo -e "  ${CYAN}[1]${RESET} Daily backup at midnight"
            echo -e "  ${CYAN}[2]${RESET} Hourly system snapshot"
            echo -e "  ${CYAN}[3]${RESET} Daily cleanup at 3 AM"
            echo -e "  ${CYAN}[4]${RESET} Weekly security audit"
            echo ""
            echo -ne "  ${WHITE}Choice: ${RESET}"
            read -r quick

            local script_path="$HOME/.system-guardian/system-guardian.sh"
            case $quick in
                1) (crontab -l 2>/dev/null; echo "# Daily backup"; echo "0 0 * * * cd $HOME && tar czf backup_\$(date +\%Y\%m\%d).tar.gz --exclude='.cache' .") | crontab - ;;
                2) (crontab -l 2>/dev/null; echo "# Hourly snapshot"; echo "0 * * * * bash $script_path --snapshot 2>/dev/null") | crontab - ;;
                3) (crontab -l 2>/dev/null; echo "# Daily cleanup"; echo "0 3 * * * apt clean && find $HOME -name '*.log' -mtime +30 -delete") | crontab - ;;
                4) (crontab -l 2>/dev/null; echo "# Weekly security audit"; echo "0 2 * * 0 bash $script_path --audit 2>/dev/null") | crontab - ;;
            esac
            echo -e "  ${GREEN}✓ Quick schedule added${RESET}"
            ;;
    esac

    echo ""
    echo -ne "  ${DIM}Press Enter to continue...${RESET}"
    read -r
}

# ═══════════════════════════════════════════════════════════════════
# MODULE 8: SETTINGS
# ═══════════════════════════════════════════════════════════════════
settings_menu() {
    clear
    print_header "⚙️  SETTINGS"
    echo ""

    print_section "Current Configuration"
    echo ""
    print_kv "CPU Alert" "${ALERT_THRESHOLD_CPU}%"
    print_kv "Memory Alert" "${ALERT_THRESHOLD_MEM}%"
    print_kv "Disk Alert" "${ALERT_THRESHOLD_DISK}%"
    print_kv "Refresh Rate" "${REFRESH_RATE}s"
    print_kv "Logging" "${ENABLE_LOGGING:-true}"
    print_kv "Notifications" "${ENABLE_NOTIFICATIONS:-true}"
    print_kv "Plugin Dir" "$PLUGIN_DIR"
    print_section_end

    echo ""
    echo -e "  ${CYAN}[1]${RESET} Change CPU alert threshold"
    echo -e "  ${CYAN}[2]${RESET} Change memory alert threshold"
    echo -e "  ${CYAN}[3]${RESET} Change disk alert threshold"
    echo -e "  ${CYAN}[4]${RESET} Change refresh rate"
    echo -e "  ${CYAN}[5]${RESET} Toggle logging"
    echo -e "  ${CYAN}[6]${RESET} Toggle notifications"
    echo -e "  ${CYAN}[7]${RESET} Reset to defaults"
    echo -e "  ${CYAN}[8]${RESET} View action history"
    echo -e "  ${CYAN}[9]${RESET} About"
    echo -e "  ${CYAN}[0]${RESET} Back"
    echo ""
    echo -ne "  ${WHITE}Choice: ${RESET}"
    read -r set_choice

    case $set_choice in
        1)
            echo -ne "  ${WHITE}New CPU threshold (0-100): ${RESET}"
            read -r val
            sed -i "s/ALERT_THRESHOLD_CPU=.*/ALERT_THRESHOLD_CPU=$val/" "$CONFIG_FILE"
            ALERT_THRESHOLD_CPU=$val
            echo -e "  ${GREEN}✓ Updated${RESET}"
            ;;
        2)
            echo -ne "  ${WHITE}New memory threshold (0-100): ${RESET}"
            read -r val
            sed -i "s/ALERT_THRESHOLD_MEM=.*/ALERT_THRESHOLD_MEM=$val/" "$CONFIG_FILE"
            ALERT_THRESHOLD_MEM=$val
            echo -e "  ${GREEN}✓ Updated${RESET}"
            ;;
        3)
            echo -ne "  ${WHITE}New disk threshold (0-100): ${RESET}"
            read -r val
            sed -i "s/ALERT_THRESHOLD_DISK=.*/ALERT_THRESHOLD_DISK=$val/" "$CONFIG_FILE"
            ALERT_THRESHOLD_DISK=$val
            echo -e "  ${GREEN}✓ Updated${RESET}"
            ;;
        4)
            echo -ne "  ${WHITE}New refresh rate (seconds): ${RESET}"
            read -r val
            sed -i "s/REFRESH_RATE=.*/REFRESH_RATE=$val/" "$CONFIG_FILE"
            REFRESH_RATE=$val
            echo -e "  ${GREEN}✓ Updated${RESET}"
            ;;
        5)
            if [[ "$ENABLE_LOGGING" == "true" ]]; then
                sed -i "s/ENABLE_LOGGING=.*/ENABLE_LOGGING=false/" "$CONFIG_FILE"
                ENABLE_LOGGING=false
            else
                sed -i "s/ENABLE_LOGGING=.*/ENABLE_LOGGING=true/" "$CONFIG_FILE"
                ENABLE_LOGGING=true
            fi
            echo -e "  ${GREEN}✓ Logging: $ENABLE_LOGGING${RESET}"
            ;;
        6)
            if [[ "$ENABLE_NOTIFICATIONS" == "true" ]]; then
                sed -i "s/ENABLE_NOTIFICATIONS=.*/ENABLE_NOTIFICATIONS=false/" "$CONFIG_FILE"
                ENABLE_NOTIFICATIONS=false
            else
                sed -i "s/ENABLE_NOTIFICATIONS=.*/ENABLE_NOTIFICATIONS=true/" "$CONFIG_FILE"
                ENABLE_NOTIFICATIONS=true
            fi
            echo -e "  ${GREEN}✓ Notifications: $ENABLE_NOTIFICATIONS${RESET}"
            ;;
        7)
            if confirm "Reset all settings to defaults?"; then
                cat > "$CONFIG_FILE" << 'CONF'
ALERT_THRESHOLD_CPU=80
ALERT_THRESHOLD_MEM=85
ALERT_THRESHOLD_DISK=90
REFRESH_RATE=2
ENABLE_LOGGING=true
ENABLE_NOTIFICATIONS=true
AUTO_CLEANUP_DAYS=30
CONF
                source "$CONFIG_FILE"
                echo -e "  ${GREEN}✓ Settings reset${RESET}"
            fi
            ;;
        8)
            echo ""
            print_section "Recent Actions"
            echo ""
            if [[ -f "$HISTORY_FILE" ]]; then
                tail -20 "$HISTORY_FILE" | while IFS= read -r line; do
                    echo -e "  ${DIM}$line${RESET}"
                done
            else
                echo -e "  ${GRAY}No history${RESET}"
            fi
            print_section_end
            ;;
        9)
            echo ""
            print_section "About System Guardian"
            echo ""
            echo -e "  ${BOLD}${PLUGIN_NAME}${RESET} v${PLUGIN_VERSION}"
            echo -e "  ${DIM}A comprehensive Termux system toolkit${RESET}"
            echo ""
            echo -e "  ${CYAN}Features:${RESET}"
            echo -e "    • Live system dashboard with CPU, RAM, disk monitoring"
            echo -e "    • Security auditing with scoring system"
            echo -e "    • Network analysis tools (port scan, DNS, speed test)"
            echo -e "    • Process manager with kill/signal support"
            echo -e "    • System snapshots and comparison"
            echo -e "    • 12+ productivity utilities"
            echo -e "    • Task automation via cron"
            echo -e "    • Configurable alerts and notifications"
            echo ""
            echo -e "  ${DIM}Built with ❤️  for the Termux community${RESET}"
            print_section_end
            ;;
        0) return ;;
    esac

    sleep 1
}

# ═══════════════════════════════════════════════════════════════════
# COMMAND LINE ARGUMENTS
# ═══════════════════════════════════════════════════════════════════
handle_args() {
    case "$1" in
        --dashboard|-d)
            init_plugin
            system_dashboard
            exit 0
            ;;
        --audit|-a)
            init_plugin
            security_audit
            exit 0
            ;;
        --snapshot|-s)
            init_plugin
            take_snapshot
            exit 0
            ;;
        --network|-n)
            init_plugin
            network_analyzer
            exit 0
            ;;
        --clean|-c)
            init_plugin
            system_cleaner
            exit 0
            ;;
        --help|-h)
            echo ""
            echo "  System Guardian v${PLUGIN_VERSION} - Termux System Toolkit"
            echo ""
            echo "  Usage: $(basename "$0") [OPTION]"
            echo ""
            echo "  Options:"
            echo "    -d, --dashboard    Launch live system dashboard"
            echo "    -a, --audit        Run security audit"
            echo "    -s, --snapshot     Take system snapshot"
            echo "    -n, --network      Open network analyzer"
            echo "    -c, --clean        Run system cleaner"
            echo "    -h, --help         Show this help"
            echo "    -v, --version      Show version"
            echo ""
            echo "  Run without arguments for interactive menu."
            echo ""
            exit 0
            ;;
        --version|-v)
            echo "System Guardian v${PLUGIN_VERSION}"
            exit 0
            ;;
    esac
}

# ═══════════════════════════════════════════════════════════════════
# MAIN MENU
# ═══════════════════════════════════════════════════════════════════
main_menu() {
    while true; do
        show_banner

        echo -e "  ${BOLD}${WHITE}Main Menu${RESET}\n"
        echo -e "  ${CYAN}[1]${RESET}  📊  System Dashboard      ${DIM}Live monitoring${RESET}"
        echo -e "  ${CYAN}[2]${RESET}  🛡️   Security Audit         ${DIM}Scan & score${RESET}"
        echo -e "  ${CYAN}[3]${RESET}  🌐  Network Analyzer       ${DIM}Scan, trace, test${RESET}"
        echo -e "  ${CYAN}[4]${RESET}  ⚙️   Process Manager        ${DIM}Monitor & control${RESET}"
        echo -e "  ${CYAN}[5]${RESET}  📸  System Snapshots       ${DIM}Capture & compare${RESET}"
        echo -e "  ${CYAN}[6]${RESET}  🧰  Toolkit                ${DIM}12+ utilities${RESET}"
        echo -e "  ${CYAN}[7]${RESET}  ⏰  Automation             ${DIM}Cron & scheduling${RESET}"
        echo -e "  ${CYAN}[8]${RESET}  ⚙️   Settings               ${DIM}Configure plugin${RESET}"
        echo ""
        echo -e "  ${RED}[0]${RESET}  🚪  Exit"
        echo ""

        print_line '─'
        echo -ne "  ${WHITE}${BOLD}❯${RESET} "
        read -r choice

        case $choice in
            1) system_dashboard ;;
            2) security_audit ;;
            3) network_analyzer ;;
            4) process_manager ;;
            5) system_snapshot ;;
            6) toolkit ;;
            7) automation_manager ;;
            8) settings_menu ;;
            0|q|Q)
                clear
                echo -e "\n  ${CYAN}Thanks for using ${BOLD}System Guardian${RESET}${CYAN}!${RESET}"
                echo -e "  ${DIM}Stay safe. Stay monitored. 🛡️${RESET}\n"
                exit 0
                ;;
            *)
                echo -e "  ${RED}Invalid option. Try again.${RESET}"
                sleep 0.5
                ;;
        esac
    done
}

# ═══════════════════════════════════════════════════════════════════
# ENTRY POINT
# ═══════════════════════════════════════════════════════════════════

# Handle CLI arguments
[[ $# -gt 0 ]] && handle_args "$1"

# Check if running in Termux
if [[ ! -d "$PREFIX" ]]; then
    echo "Warning: This plugin is designed for Termux but may work on other systems."
    PREFIX="/usr"
fi

# Initialize
init_plugin
log_action "Plugin started"

# Trap cleanup
trap 'echo -e "\n${RESET}"; exit 0' INT TERM

# Launch
main_menu
