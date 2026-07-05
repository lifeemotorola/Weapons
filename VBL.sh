#!/data/data/com.termux/files/usr/bin/bash

#===============================================================================
#  ADVANCED SYSTEM STRESS TEST TOOL FOR TERMUX
#  Version: 2.0
#  Author: System Admin
#  Description: Comprehensive system stress testing with real-time monitoring
#===============================================================================

# Colors and Formatting
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
ORANGE='\033[0;33m'
NC='\033[0m' # No Color
BOLD='\033[1m'
DIM='\033[2m'
BLINK='\033[5m'

# Unicode symbols
CHECK="✓"
CROSS="✗"
ARROW="➤"
STAR="★"
GEAR="⚙"
FIRE="🔥"
CPU_ICON="🖥"
MEM_ICON="💾"
DISK_ICON="💿"
NET_ICON="🌐"
TEMP_ICON="🌡"

# Configuration
LOG_DIR="$HOME/stress_test_logs"
REPORT_FILE="$LOG_DIR/stress_report_$(date +%Y%m%d_%H%M%S).txt"
TEMP_DIR="/data/data/com.termux/files/usr/tmp/stress_test"

# Test Results Storage
declare -A TEST_RESULTS
declare -A TEST_SCORES

#===============================================================================
# UTILITY FUNCTIONS
#===============================================================================

setup_environment() {
    mkdir -p "$LOG_DIR" "$TEMP_DIR"
    
    # Check and install required packages
    local packages=("bc" "coreutils" "procps" "net-tools" "curl")
    
    for pkg in "${packages[@]}"; do
        if ! command -v "$pkg" &> /dev/null; then
            echo -e "${YELLOW}Installing $pkg...${NC}"
            pkg install -y "$pkg" 2>/dev/null
        fi
    done
}

cleanup() {
    rm -rf "$TEMP_DIR"
    # Kill any background processes we started
    jobs -p | xargs -r kill 2>/dev/null
}

trap cleanup EXIT

print_banner() {
    clear
    echo -e "${CYAN}"
    cat << "EOF"
    ╔═══════════════════════════════════════════════════════════════╗
    ║     █████╗ ██████╗ ██╗   ██╗ █████╗ ███╗   ██╗ ██████╗███████╗║
    ║    ██╔══██╗██╔══██╗██║   ██║██╔══██╗████╗  ██║██╔════╝██╔════╝║
    ║    ███████║██║  ██║██║   ██║███████║██╔██╗ ██║██║     █████╗  ║
    ║    ██╔══██║██║  ██║╚██╗ ██╔╝██╔══██║██║╚██╗██║██║     ██╔══╝  ║
    ║    ██║  ██║██████╔╝ ╚████╔╝ ██║  ██║██║ ╚████║╚██████╗███████╗║
    ║    ╚═╝  ╚═╝╚═════╝   ╚═══╝  ╚═╝  ╚═╝╚═╝  ╚═══╝ ╚═════╝╚══════╝║
    ║                                                               ║
    ║          ███████╗████████╗██████╗ ███████╗███████╗███████╗    ║
    ║          ██╔════╝╚══██╔══╝██╔══██╗██╔════╝██╔════╝██╔════╝    ║
    ║          ███████╗   ██║   ██████╔╝█████╗  ███████╗███████╗    ║
    ║          ╚════██║   ██║   ██╔══██╗██╔══╝  ╚════██║╚════██║    ║
    ║          ███████║   ██║   ██║  ██║███████╗███████║███████║    ║
    ║          ╚══════╝   ╚═╝   ╚═╝  ╚═╝╚══════╝╚══════╝╚══════╝    ║
    ║                       TESTING TOOL v2.0                       ║
    ╚═══════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

print_section() {
    local title="$1"
    local width=60
    local padding=$(( (width - ${#title} - 2) / 2 ))
    
    echo ""
    echo -e "${BLUE}╔$(printf '═%.0s' $(seq 1 $width))╗${NC}"
    echo -e "${BLUE}║${NC}$(printf ' %.0s' $(seq 1 $padding))${BOLD}${WHITE}$title${NC}$(printf ' %.0s' $(seq 1 $((width - padding - ${#title}))))${BLUE}║${NC}"
    echo -e "${BLUE}╚$(printf '═%.0s' $(seq 1 $width))╝${NC}"
    echo ""
}

progress_bar() {
    local current=$1
    local total=$2
    local width=40
    local percentage=$((current * 100 / total))
    local filled=$((current * width / total))
    local empty=$((width - filled))
    
    printf "\r${CYAN}["
    printf "%${filled}s" | tr ' ' '█'
    printf "%${empty}s" | tr ' ' '░'
    printf "] ${percentage}%% ${NC}"
}

spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " ${CYAN}[%c]${NC} " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

format_bytes() {
    local bytes=$1
    if [ $bytes -ge 1073741824 ]; then
        echo "$(echo "scale=2; $bytes/1073741824" | bc) GB"
    elif [ $bytes -ge 1048576 ]; then
        echo "$(echo "scale=2; $bytes/1048576" | bc) MB"
    elif [ $bytes -ge 1024 ]; then
        echo "$(echo "scale=2; $bytes/1024" | bc) KB"
    else
        echo "$bytes B"
    fi
}

format_time() {
    local seconds=$1
    local hours=$((seconds / 3600))
    local minutes=$(((seconds % 3600) / 60))
    local secs=$((seconds % 60))
    printf "%02d:%02d:%02d" $hours $minutes $secs
}

#===============================================================================
# SYSTEM INFORMATION GATHERING
#===============================================================================

get_system_info() {
    print_section "SYSTEM INFORMATION"
    
    echo -e "${CYAN}${GEAR} Gathering system information...${NC}\n"
    
    # Device Info
    echo -e "${BOLD}${WHITE}Device Information:${NC}"
    echo -e "  ${ARROW} ${GREEN}Model:${NC} $(getprop ro.product.model 2>/dev/null || echo 'Unknown')"
    echo -e "  ${ARROW} ${GREEN}Brand:${NC} $(getprop ro.product.brand 2>/dev/null || echo 'Unknown')"
    echo -e "  ${ARROW} ${GREEN}Android:${NC} $(getprop ro.build.version.release 2>/dev/null || echo 'Unknown')"
    echo -e "  ${ARROW} ${GREEN}SDK:${NC} $(getprop ro.build.version.sdk 2>/dev/null || echo 'Unknown')"
    echo ""
    
    # CPU Info
    echo -e "${BOLD}${WHITE}${CPU_ICON} CPU Information:${NC}"
    local cpu_cores=$(nproc 2>/dev/null || grep -c ^processor /proc/cpuinfo)
    local cpu_model=$(grep "model name" /proc/cpuinfo 2>/dev/null | head -1 | cut -d: -f2 | xargs)
    [ -z "$cpu_model" ] && cpu_model=$(grep "Hardware" /proc/cpuinfo 2>/dev/null | head -1 | cut -d: -f2 | xargs)
    
    echo -e "  ${ARROW} ${GREEN}Processor:${NC} ${cpu_model:-Unknown}"
    echo -e "  ${ARROW} ${GREEN}Cores:${NC} $cpu_cores"
    
    # CPU Frequencies
    if [ -d /sys/devices/system/cpu/cpu0/cpufreq ]; then
        local min_freq=$(cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_min_freq 2>/dev/null)
        local max_freq=$(cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq 2>/dev/null)
        local cur_freq=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq 2>/dev/null)
        
        [ -n "$min_freq" ] && echo -e "  ${ARROW} ${GREEN}Min Freq:${NC} $(echo "scale=2; $min_freq/1000000" | bc) GHz"
        [ -n "$max_freq" ] && echo -e "  ${ARROW} ${GREEN}Max Freq:${NC} $(echo "scale=2; $max_freq/1000000" | bc) GHz"
        [ -n "$cur_freq" ] && echo -e "  ${ARROW} ${GREEN}Current:${NC} $(echo "scale=2; $cur_freq/1000000" | bc) GHz"
    fi
    echo ""
    
    # Memory Info
    echo -e "${BOLD}${WHITE}${MEM_ICON} Memory Information:${NC}"
    local mem_total=$(grep MemTotal /proc/meminfo | awk '{print $2}')
    local mem_free=$(grep MemFree /proc/meminfo | awk '{print $2}')
    local mem_available=$(grep MemAvailable /proc/meminfo | awk '{print $2}')
    local mem_used=$((mem_total - mem_available))
    local mem_percent=$((mem_used * 100 / mem_total))
    
    echo -e "  ${ARROW} ${GREEN}Total:${NC} $(format_bytes $((mem_total * 1024)))"
    echo -e "  ${ARROW} ${GREEN}Used:${NC} $(format_bytes $((mem_used * 1024))) ($mem_percent%)"
    echo -e "  ${ARROW} ${GREEN}Available:${NC} $(format_bytes $((mem_available * 1024)))"
    echo ""
    
    # Storage Info
    echo -e "${BOLD}${WHITE}${DISK_ICON} Storage Information:${NC}"
    df -h "$HOME" 2>/dev/null | tail -1 | awk '{
        printf "  '"${ARROW}"' '"${GREEN}"'Total:'"${NC}"' %s\n", $2
        printf "  '"${ARROW}"' '"${GREEN}"'Used:'"${NC}"' %s (%s)\n", $3, $5
        printf "  '"${ARROW}"' '"${GREEN}"'Available:'"${NC}"' %s\n", $4
    }'
    echo ""
}

#===============================================================================
# CPU STRESS TEST
#===============================================================================

cpu_stress_test() {
    local duration=${1:-30}
    local intensity=${2:-100}
    
    print_section "CPU STRESS TEST ${FIRE}"
    
    echo -e "${YELLOW}${ARROW} Duration: ${duration}s | Intensity: ${intensity}%${NC}\n"
    
    local cpu_cores=$(nproc 2>/dev/null || echo 4)
    local workers=$((cpu_cores * intensity / 100))
    [ $workers -lt 1 ] && workers=1
    
    echo -e "${CYAN}Starting $workers CPU worker(s)...${NC}\n"
    
    # Start CPU stress workers
    local pids=()
    for ((i=0; i<workers; i++)); do
        (
            local end_time=$((SECONDS + duration))
            while [ $SECONDS -lt $end_time ]; do
                # Heavy mathematical operations
                echo "scale=1000; 4*a(1)" | bc -l > /dev/null 2>&1
            done
        ) &
        pids+=($!)
    done
    
    # Monitor progress
    local start_time=$SECONDS
    local readings=()
    
    while [ $((SECONDS - start_time)) -lt $duration ]; do
        local elapsed=$((SECONDS - start_time))
        progress_bar $elapsed $duration
        
        # Capture CPU usage
        local cpu_usage=$(top -bn1 2>/dev/null | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)
        [ -z "$cpu_usage" ] && cpu_usage=$(cat /proc/stat | head -1 | awk '{usage=($2+$4)*100/($2+$4+$5)} END {print usage}')
        
        readings+=("$cpu_usage")
        sleep 1
    done
    
    # Wait for workers to finish
    for pid in "${pids[@]}"; do
        wait $pid 2>/dev/null
    done
    
    echo -e "\n"
    
    # Calculate results
    local total=0
    local count=${#readings[@]}
    local max=0
    local min=100
    
    for reading in "${readings[@]}"; do
        reading=${reading:-0}
        total=$(echo "$total + $reading" | bc 2>/dev/null || echo $total)
        [ $(echo "$reading > $max" | bc 2>/dev/null) -eq 1 ] && max=$reading
        [ $(echo "$reading < $min" | bc 2>/dev/null) -eq 1 ] && min=$reading
    done
    
    local avg=$(echo "scale=2; $total / $count" | bc 2>/dev/null || echo "N/A")
    
    echo -e "${GREEN}${CHECK} CPU Stress Test Complete!${NC}\n"
    echo -e "${BOLD}Results:${NC}"
    echo -e "  ${ARROW} Average CPU Usage: ${YELLOW}${avg}%${NC}"
    echo -e "  ${ARROW} Peak CPU Usage: ${RED}${max}%${NC}"
    echo -e "  ${ARROW} Min CPU Usage: ${GREEN}${min}%${NC}"
    echo -e "  ${ARROW} Workers Used: ${CYAN}${workers}${NC}"
    
    # Score calculation (higher is better - means system handled load well)
    local score=$(echo "scale=0; (100 - $avg) * $workers / $cpu_cores + 50" | bc 2>/dev/null || echo 50)
    [ $score -gt 100 ] && score=100
    [ $score -lt 0 ] && score=0
    
    TEST_RESULTS["CPU"]="Avg: ${avg}% | Peak: ${max}%"
    TEST_SCORES["CPU"]=$score
    
    echo -e "\n  ${STAR} ${BOLD}CPU Score: ${PURPLE}${score}/100${NC}"
}

#===============================================================================
# MEMORY STRESS TEST
#===============================================================================

memory_stress_test() {
    local duration=${1:-30}
    local intensity=${2:-50}
    
    print_section "MEMORY STRESS TEST ${MEM_ICON}"
    
    echo -e "${YELLOW}${ARROW} Duration: ${duration}s | Intensity: ${intensity}%${NC}\n"
    
    # Get available memory
    local mem_available=$(grep MemAvailable /proc/meminfo | awk '{print $2}')
    local test_size=$((mem_available * intensity / 100))
    
    echo -e "${CYAN}Testing with $(format_bytes $((test_size * 1024))) of memory...${NC}\n"
    
    local start_time=$SECONDS
    local write_speeds=()
    local read_speeds=()
    
    # Create test file path
    local test_file="$TEMP_DIR/mem_test_$$"
    
    while [ $((SECONDS - start_time)) -lt $duration ]; do
        local elapsed=$((SECONDS - start_time))
        progress_bar $elapsed $duration
        
        # Memory write test (allocate and write)
        local write_start=$(date +%s%N)
        dd if=/dev/zero of="$test_file" bs=1M count=$((test_size / 1024)) 2>/dev/null
        local write_end=$(date +%s%N)
        local write_time=$(((write_end - write_start) / 1000000))
        [ $write_time -gt 0 ] && write_speeds+=($((test_size * 1000 / write_time)))
        
        # Memory read test
        local read_start=$(date +%s%N)
        dd if="$test_file" of=/dev/null bs=1M 2>/dev/null
        local read_end=$(date +%s%N)
        local read_time=$(((read_end - read_start) / 1000000))
        [ $read_time -gt 0 ] && read_speeds+=($((test_size * 1000 / read_time)))
        
        rm -f "$test_file"
        
        sleep 1
    done
    
    echo -e "\n"
    
    # Calculate averages
    local write_total=0
    local read_total=0
    
    for speed in "${write_speeds[@]}"; do
        write_total=$((write_total + speed))
    done
    
    for speed in "${read_speeds[@]}"; do
        read_total=$((read_total + speed))
    done
    
    local write_count=${#write_speeds[@]}
    local read_count=${#read_speeds[@]}
    
    [ $write_count -eq 0 ] && write_count=1
    [ $read_count -eq 0 ] && read_count=1
    
    local avg_write=$((write_total / write_count))
    local avg_read=$((read_total / read_count))
    
    echo -e "${GREEN}${CHECK} Memory Stress Test Complete!${NC}\n"
    echo -e "${BOLD}Results:${NC}"
    echo -e "  ${ARROW} Memory Tested: ${CYAN}$(format_bytes $((test_size * 1024)))${NC}"
    echo -e "  ${ARROW} Avg Write Speed: ${YELLOW}$(format_bytes $((avg_write * 1024)))/s${NC}"
    echo -e "  ${ARROW} Avg Read Speed: ${GREEN}$(format_bytes $((avg_read * 1024)))/s${NC}"
    
    # Score based on speed (normalize to 100)
    local score=$(echo "scale=0; ($avg_write + $avg_read) / 2000" | bc 2>/dev/null || echo 50)
    [ $score -gt 100 ] && score=100
    [ $score -lt 0 ] && score=0
    
    TEST_RESULTS["Memory"]="Write: $(format_bytes $((avg_write * 1024)))/s | Read: $(format_bytes $((avg_read * 1024)))/s"
    TEST_SCORES["Memory"]=$score
    
    echo -e "\n  ${STAR} ${BOLD}Memory Score: ${PURPLE}${score}/100${NC}"
}

#===============================================================================
# DISK I/O STRESS TEST
#===============================================================================

disk_stress_test() {
    local duration=${1:-30}
    local block_size=${2:-4096}
    
    print_section "DISK I/O STRESS TEST ${DISK_ICON}"
    
    echo -e "${YELLOW}${ARROW} Duration: ${duration}s | Block Size: $(format_bytes $block_size)${NC}\n"
    
    local test_file="$TEMP_DIR/disk_test_$$"
    local start_time=$SECONDS
    local operations=0
    local total_written=0
    local total_read=0
    
    echo -e "${CYAN}Running sequential and random I/O tests...${NC}\n"
    
    # Sequential write test
    echo -e "${WHITE}Sequential Write Test:${NC}"
    local seq_write_start=$(date +%s%N)
    dd if=/dev/zero of="$test_file" bs=$block_size count=10000 conv=fdatasync 2>/dev/null
    local seq_write_end=$(date +%s%N)
    local seq_write_time=$(((seq_write_end - seq_write_start) / 1000000))
    local seq_write_speed=$((block_size * 10000 * 1000 / seq_write_time / 1024))
    echo -e "  ${ARROW} Speed: ${GREEN}$(format_bytes $((seq_write_speed * 1024)))/s${NC}"
    
    # Sequential read test
    echo -e "${WHITE}Sequential Read Test:${NC}"
    local seq_read_start=$(date +%s%N)
    dd if="$test_file" of=/dev/null bs=$block_size 2>/dev/null
    local seq_read_end=$(date +%s%N)
    local seq_read_time=$(((seq_read_end - seq_read_start) / 1000000))
    local seq_read_speed=$((block_size * 10000 * 1000 / seq_read_time / 1024))
    echo -e "  ${ARROW} Speed: ${GREEN}$(format_bytes $((seq_read_speed * 1024)))/s${NC}"
    
    # Random I/O test
    echo -e "${WHITE}Random I/O Test:${NC}"
    local random_start=$(date +%s%N)
    local random_ops=0
    
    for ((i=0; i<1000; i++)); do
        local offset=$((RANDOM * RANDOM % (block_size * 10000)))
        dd if="$test_file" of=/dev/null bs=$block_size count=1 skip=$((offset / block_size)) 2>/dev/null
        ((random_ops++))
    done
    
    local random_end=$(date +%s%N)
    local random_time=$(((random_end - random_start) / 1000000))
    local iops=$((random_ops * 1000 / random_time))
    echo -e "  ${ARROW} IOPS: ${GREEN}${iops}${NC}"
    
    rm -f "$test_file"
    
    echo -e "\n${GREEN}${CHECK} Disk I/O Stress Test Complete!${NC}\n"
    echo -e "${BOLD}Summary:${NC}"
    echo -e "  ${ARROW} Sequential Write: ${YELLOW}$(format_bytes $((seq_write_speed * 1024)))/s${NC}"
    echo -e "  ${ARROW} Sequential Read: ${YELLOW}$(format_bytes $((seq_read_speed * 1024)))/s${NC}"
    echo -e "  ${ARROW} Random IOPS: ${CYAN}${iops}${NC}"
    
    # Score calculation
    local score=$(echo "scale=0; ($seq_write_speed + $seq_read_speed) / 200 + $iops / 10" | bc 2>/dev/null || echo 50)
    [ $score -gt 100 ] && score=100
    [ $score -lt 0 ] && score=0
    
    TEST_RESULTS["Disk"]="Seq W: $(format_bytes $((seq_write_speed * 1024)))/s | Seq R: $(format_bytes $((seq_read_speed * 1024)))/s | IOPS: $iops"
    TEST_SCORES["Disk"]=$score
    
    echo -e "\n  ${STAR} ${BOLD}Disk Score: ${PURPLE}${score}/100${NC}"
}

#===============================================================================
# NETWORK STRESS TEST
#===============================================================================

network_stress_test() {
    local duration=${1:-20}
    
    print_section "NETWORK STRESS TEST ${NET_ICON}"
    
    echo -e "${YELLOW}${ARROW} Duration: ${duration}s${NC}\n"
    
    # Test endpoints
    local endpoints=(
        "https://www.google.com"
        "https://www.cloudflare.com"
        "https://www.github.com"
    )
    
    local latencies=()
    local download_speeds=()
    
    echo -e "${CYAN}Testing network connectivity and speed...${NC}\n"
    
    # Latency test
    echo -e "${WHITE}Latency Test:${NC}"
    for endpoint in "${endpoints[@]}"; do
        local host=$(echo "$endpoint" | sed 's|https://||' | sed 's|/.*||')
        local latency=$(ping -c 3 "$host" 2>/dev/null | grep "avg" | awk -F'/' '{print $5}')
        
        if [ -n "$latency" ]; then
            echo -e "  ${ARROW} $host: ${GREEN}${latency}ms${NC}"
            latencies+=("$latency")
        else
            echo -e "  ${ARROW} $host: ${RED}Failed${NC}"
        fi
    done
    
    # Download speed test
    echo -e "\n${WHITE}Download Speed Test:${NC}"
    local test_urls=(
        "https://speed.cloudflare.com/__down?bytes=10000000"
        "https://proof.ovh.net/files/1Mb.dat"
    )
    
    for url in "${test_urls[@]}"; do
        local start_time=$(date +%s%N)
        local bytes=$(curl -s -o /dev/null -w '%{size_download}' --max-time 10 "$url" 2>/dev/null)
        local end_time=$(date +%s%N)
        
        if [ -n "$bytes" ] && [ "$bytes" -gt 0 ]; then
            local time_ms=$(((end_time - start_time) / 1000000))
            local speed=$((bytes * 1000 / time_ms))
            echo -e "  ${ARROW} Downloaded $(format_bytes $bytes) at ${GREEN}$(format_bytes $speed)/s${NC}"
            download_speeds+=("$speed")
        fi
    done
    
    echo -e "\n${GREEN}${CHECK} Network Stress Test Complete!${NC}\n"
    
    # Calculate averages
    local avg_latency=0
    local avg_speed=0
    
    if [ ${#latencies[@]} -gt 0 ]; then
        for lat in "${latencies[@]}"; do
            avg_latency=$(echo "$avg_latency + $lat" | bc)
        done
        avg_latency=$(echo "scale=2; $avg_latency / ${#latencies[@]}" | bc)
    fi
    
    if [ ${#download_speeds[@]} -gt 0 ]; then
        for spd in "${download_speeds[@]}"; do
            avg_speed=$((avg_speed + spd))
        done
        avg_speed=$((avg_speed / ${#download_speeds[@]}))
    fi
    
    echo -e "${BOLD}Summary:${NC}"
    echo -e "  ${ARROW} Average Latency: ${YELLOW}${avg_latency}ms${NC}"
    echo -e "  ${ARROW} Average Download: ${CYAN}$(format_bytes $avg_speed)/s${NC}"
    
    # Score calculation
    local latency_score=$(echo "scale=0; 100 - $avg_latency" | bc 2>/dev/null || echo 50)
    local speed_score=$((avg_speed / 10000))
    local score=$(((latency_score + speed_score) / 2))
    [ $score -gt 100 ] && score=100
    [ $score -lt 0 ] && score=0
    
    TEST_RESULTS["Network"]="Latency: ${avg_latency}ms | Download: $(format_bytes $avg_speed)/s"
    TEST_SCORES["Network"]=$score
    
    echo -e "\n  ${STAR} ${BOLD}Network Score: ${PURPLE}${score}/100${NC}"
}

#===============================================================================
# COMPREHENSIVE BENCHMARK
#===============================================================================

run_comprehensive_benchmark() {
    local duration=20
    
    print_section "COMPREHENSIVE BENCHMARK"
    
    echo -e "${CYAN}Running all benchmarks with ${duration}s each...${NC}\n"
    
    # Prime number calculation benchmark
    echo -e "${WHITE}1. Prime Number Calculation:${NC}"
    local prime_start=$(date +%s%N)
    local primes=0
    for ((n=2; n<=10000; n++)); do
        local is_prime=1
        for ((i=2; i*i<=n; i++)); do
            if ((n % i == 0)); then
                is_prime=0
                break
            fi
        done
        ((primes += is_prime))
    done
    local prime_end=$(date +%s%N)
    local prime_time=$(((prime_end - prime_start) / 1000000))
    echo -e "  ${ARROW} Found $primes primes in ${GREEN}${prime_time}ms${NC}"
    
    # Fibonacci benchmark
    echo -e "\n${WHITE}2. Fibonacci Sequence:${NC}"
    local fib_start=$(date +%s%N)
    local a=0 b=1
    for ((i=0; i<10000; i++)); do
        local temp=$((a + b))
        a=$b
        b=$temp
    done
    local fib_end=$(date +%s%N)
    local fib_time=$(((fib_end - fib_start) / 1000000))
    echo -e "  ${ARROW} Calculated 10000 iterations in ${GREEN}${fib_time}ms${NC}"
    
    # String operations benchmark
    echo -e "\n${WHITE}3. String Operations:${NC}"
    local str_start=$(date +%s%N)
    local test_string="This is a benchmark test string for Termux stress testing tool"
    for ((i=0; i<1000; i++)); do
        local upper=$(echo "$test_string" | tr '[:lower:]' '[:upper:]')
        local reversed=$(echo "$test_string" | rev)
        local length=${#test_string}
    done
    local str_end=$(date +%s%N)
    local str_time=$(((str_end - str_start) / 1000000))
    echo -e "  ${ARROW} 1000 operations in ${GREEN}${str_time}ms${NC}"
    
    # File operations benchmark
    echo -e "\n${WHITE}4. File Operations:${NC}"
    local file_start=$(date +%s%N)
    for ((i=0; i<100; i++)); do
        echo "Benchmark test data $i" > "$TEMP_DIR/bench_$i.txt"
    done
    for ((i=0; i<100; i++)); do
        cat "$TEMP_DIR/bench_$i.txt" > /dev/null
    done
    rm -f "$TEMP_DIR"/bench_*.txt
    local file_end=$(date +%s%N)
    local file_time=$(((file_end - file_start) / 1000000))
    echo -e "  ${ARROW} 200 file operations in ${GREEN}${file_time}ms${NC}"
    
    # Calculate overall benchmark score
    local benchmark_score=$(echo "scale=0; 100000 / ($prime_time + $fib_time + $str_time + $file_time) * 10" | bc 2>/dev/null || echo 50)
    [ $benchmark_score -gt 100 ] && benchmark_score=100
    [ $benchmark_score -lt 0 ] && benchmark_score=0
    
    TEST_RESULTS["Benchmark"]="Prime: ${prime_time}ms | Fib: ${fib_time}ms | String: ${str_time}ms | File: ${file_time}ms"
    TEST_SCORES["Benchmark"]=$benchmark_score
    
    echo -e "\n${GREEN}${CHECK} Comprehensive Benchmark Complete!${NC}"
    echo -e "\n  ${STAR} ${BOLD}Benchmark Score: ${PURPLE}${benchmark_score}/100${NC}"
}

#===============================================================================
# THERMAL MONITORING
#===============================================================================

thermal_test() {
    print_section "THERMAL MONITORING ${TEMP_ICON}"
    
    echo -e "${CYAN}Monitoring system temperatures...${NC}\n"
    
    local temp_paths=(
        "/sys/class/thermal/thermal_zone0/temp"
        "/sys/class/thermal/thermal_zone1/temp"
        "/sys/class/hwmon/hwmon0/temp1_input"
        "/sys/devices/virtual/thermal/thermal_zone0/temp"
    )
    
    local temps=()
    
    for path in "${temp_paths[@]}"; do
        if [ -r "$path" ]; then
            local temp=$(cat "$path" 2>/dev/null)
            if [ -n "$temp" ]; then
                # Convert millidegrees to degrees
                if [ $temp -gt 1000 ]; then
                    temp=$((temp / 1000))
                fi
                temps+=("$temp")
                
                local color="${GREEN}"
                [ $temp -gt 45 ] && color="${YELLOW}"
                [ $temp -gt 55 ] && color="${ORANGE}"
                [ $temp -gt 65 ] && color="${RED}"
                
                echo -e "  ${ARROW} Sensor $(basename $(dirname $path)): ${color}${temp}°C${NC}"
            fi
        fi
    done
    
    if [ ${#temps[@]} -eq 0 ]; then
        echo -e "  ${YELLOW}No thermal sensors accessible${NC}"
        TEST_RESULTS["Thermal"]="N/A"
        TEST_SCORES["Thermal"]=50
    else
        local max_temp=0
        for t in "${temps[@]}"; do
            [ $t -gt $max_temp ] && max_temp=$t
        done
        
        echo -e "\n${BOLD}Maximum Temperature: "
        if [ $max_temp -lt 45 ]; then
            echo -e "${GREEN}${max_temp}°C - Excellent${NC}"
        elif [ $max_temp -lt 55 ]; then
            echo -e "${YELLOW}${max_temp}°C - Normal${NC}"
        elif [ $max_temp -lt 65 ]; then
            echo -e "${ORANGE}${max_temp}°C - Warm${NC}"
        else
            echo -e "${RED}${max_temp}°C - Hot!${NC}"
        fi
        
        local score=$((100 - max_temp))
        [ $score -lt 0 ] && score=0
        [ $score -gt 100 ] && score=100
        
        TEST_RESULTS["Thermal"]="${max_temp}°C"
        TEST_SCORES["Thermal"]=$score
        
        echo -e "\n  ${STAR} ${BOLD}Thermal Score: ${PURPLE}${score}/100${NC}"
    fi
}

#===============================================================================
# GENERATE REPORT
#===============================================================================

generate_report() {
    print_section "TEST REPORT"
    
    local total_score=0
    local test_count=0
    
    echo -e "${BOLD}${WHITE}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}${WHITE}                    FINAL TEST RESULTS                      ${NC}"
    echo -e "${BOLD}${WHITE}═══════════════════════════════════════════════════════════${NC}\n"
    
    for test in CPU Memory Disk Network Benchmark Thermal; do
        if [ -n "${TEST_RESULTS[$test]}" ]; then
            local score=${TEST_SCORES[$test]}
            local color="${GREEN}"
            [ $score -lt 70 ] && color="${YELLOW}"
            [ $score -lt 50 ] && color="${ORANGE}"
            [ $score -lt 30 ] && color="${RED}"
            
            printf "${BOLD}%-12s${NC}: ${color}%3d/100${NC}  │  %s\n" "$test" "$score" "${TEST_RESULTS[$test]}"
            
            total_score=$((total_score + score))
            ((test_count++))
        fi
    done
    
    echo ""
    echo -e "${BOLD}${WHITE}═══════════════════════════════════════════════════════════${NC}"
    
    if [ $test_count -gt 0 ]; then
        local overall_score=$((total_score / test_count))
        local grade=""
        local grade_color=""
        
        if [ $overall_score -ge 90 ]; then
            grade="A+" grade_color="${GREEN}"
        elif [ $overall_score -ge 80 ]; then
            grade="A" grade_color="${GREEN}"
        elif [ $overall_score -ge 70 ]; then
            grade="B" grade_color="${CYAN}"
        elif [ $overall_score -ge 60 ]; then
            grade="C" grade_color="${YELLOW}"
        elif [ $overall_score -ge 50 ]; then
            grade="D" grade_color="${ORANGE}"
        else
            grade="F" grade_color="${RED}"
        fi
        
        echo -e "\n${BOLD}${WHITE}OVERALL SYSTEM SCORE: ${grade_color}${overall_score}/100 (Grade: ${grade})${NC}\n"
        
        # Visual score bar
        local bar_width=50
        local filled=$((overall_score * bar_width / 100))
        local empty=$((bar_width - filled))
        
        echo -ne "  ${CYAN}["
        printf "%${filled}s" | tr ' ' '█'
        printf "%${empty}s" | tr ' ' '░'
        echo -e "]${NC}\n"
        
        # Save report to file
        {
            echo "========================================"
            echo "  SYSTEM STRESS TEST REPORT"
            echo "  Date: $(date)"
            echo "  Device: $(getprop ro.product.model 2>/dev/null || echo 'Unknown')"
            echo "========================================"
            echo ""
            for test in CPU Memory Disk Network Benchmark Thermal; do
                if [ -n "${TEST_RESULTS[$test]}" ]; then
                    printf "%-12s: %3d/100  |  %s\n" "$test" "${TEST_SCORES[$test]}" "${TEST_RESULTS[$test]}"
                fi
            done
            echo ""
            echo "========================================"
            echo "OVERALL SCORE: ${overall_score}/100 (Grade: ${grade})"
            echo "========================================"
        } > "$REPORT_FILE"
        
        echo -e "${GREEN}${CHECK} Report saved to: ${CYAN}$REPORT_FILE${NC}"
    fi
}

#===============================================================================
# MAIN MENU
#===============================================================================

show_menu() {
    echo -e "\n${BOLD}${WHITE}SELECT TEST MODE:${NC}\n"
    echo -e "  ${CYAN}[1]${NC} ${ARROW} Quick Test (All tests, 15s each)"
    echo -e "  ${CYAN}[2]${NC} ${ARROW} Standard Test (All tests, 30s each)"
    echo -e "  ${CYAN}[3]${NC} ${ARROW} Extended Test (All tests, 60s each)"
    echo -e "  ${CYAN}[4]${NC} ${ARROW} CPU Stress Test Only"
    echo -e "  ${CYAN}[5]${NC} ${ARROW} Memory Stress Test Only"
    echo -e "  ${CYAN}[6]${NC} ${ARROW} Disk I/O Test Only"
    echo -e "  ${CYAN}[7]${NC} ${ARROW} Network Test Only"
    echo -e "  ${CYAN}[8]${NC} ${ARROW} Comprehensive Benchmark"
    echo -e "  ${CYAN}[9]${NC} ${ARROW} System Information Only"
    echo -e "  ${CYAN}[0]${NC} ${ARROW} Exit"
    echo ""
}

run_all_tests() {
    local duration=$1
    
    get_system_info
    read -p "Press Enter to continue..." -t 3
    
    cpu_stress_test $duration 100
    read -p "Press Enter to continue..." -t 3
    
    memory_stress_test $duration 50
    read -p "Press Enter to continue..." -t 3
    
    disk_stress_test $duration 4096
    read -p "Press Enter to continue..." -t 3
    
    network_stress_test $duration
    read -p "Press Enter to continue..." -t 3
    
    run_comprehensive_benchmark
    read -p "Press Enter to continue..." -t 3
    
    thermal_test
    
    generate_report
}

#===============================================================================
# MAIN EXECUTION
#===============================================================================

main() {
    setup_environment
    print_banner
    
    while true; do
        show_menu
        read -p "Enter your choice [0-9]: " choice
        
        case $choice in
            1)
                run_all_tests 15
                ;;
            2)
                run_all_tests 30
                ;;
            3)
                run_all_tests 60
                ;;
            4)
                read -p "Enter duration in seconds [30]: " dur
                dur=${dur:-30}
                cpu_stress_test $dur 100
                generate_report
                ;;
            5)
                read -p "Enter duration in seconds [30]: " dur
                dur=${dur:-30}
                memory_stress_test $dur 50
                generate_report
                ;;
            6)
                read -p "Enter duration in seconds [30]: " dur
                dur=${dur:-30}
                disk_stress_test $dur 4096
                generate_report
                ;;
            7)
                read -p "Enter duration in seconds [20]: " dur
                dur=${dur:-20}
                network_stress_test $dur
                generate_report
                ;;
            8)
                run_comprehensive_benchmark
                generate_report
                ;;
            9)
                get_system_info
                ;;
            0)
                echo -e "\n${GREEN}${CHECK} Thank you for using System Stress Test Tool!${NC}\n"
                exit 0
                ;;
            *)
                echo -e "${RED}${CROSS} Invalid option. Please try again.${NC}"
                ;;
        esac
        
        echo ""
        read -p "Press Enter to return to menu..."
    done
}

# Run main function
main "$@"
