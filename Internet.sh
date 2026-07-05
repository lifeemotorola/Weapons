#!/data/data/com.termux/files/usr/bin/bash

#==============================================================================
#  HOW THE INTERNET WORKS - FULL INTERACTIVE COURSE
#  Platform: Termux (Android)
#  Author: Emmanuel suah
#  Description: A comprehensive, hands-on course covering all aspects of
#               how the internet works, from physical infrastructure to
#               application protocols.
#==============================================================================

# --- Color Definitions ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
BOLD='\033[1m'
DIM='\033[2m'
UNDERLINE='\033[4m'
BLINK='\033[5m'
REVERSE='\033[7m'
RESET='\033[0m'
BG_BLUE='\033[44m'
BG_GREEN='\033[42m'
BG_RED='\033[41m'
BG_YELLOW='\033[43m'
BG_MAGENTA='\033[45m'
BG_CYAN='\033[46m'

# --- Global Variables ---
CURRENT_MODULE=0
TOTAL_MODULES=12
SCORE=0
TOTAL_QUESTIONS=0
PROGRESS_FILE="$HOME/.internet_course_progress"
LOG_FILE="$HOME/.internet_course_log"

# --- Utility Functions ---

clear_screen() {
    clear
    echo ""
}

press_continue() {
    echo ""
    echo -e "${DIM}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "${YELLOW}  ▶ Press [Enter] to continue...${RESET}"
    read -r
}

press_continue_msg() {
    echo ""
    echo -e "${DIM}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "${YELLOW}  ▶ $1${RESET}"
    read -r
}

print_header() {
    clear_screen
    local title="$1"
    local subtitle="$2"
    local width=60
    echo -e "${CYAN}${BOLD}"
    echo "  ╔══════════════════════════════════════════════════════════╗"
    printf "  ║%-58s║\n" ""
    printf "  ║  %-56s║\n" "$title"
    if [ -n "$subtitle" ]; then
        printf "  ║  %-56s║\n" "$subtitle"
    fi
    printf "  ║%-58s║\n" ""
    echo "  ╚══════════════════════════════════════════════════════════╝"
    echo -e "${RESET}"
}

print_section() {
    echo ""
    echo -e "${GREEN}${BOLD}  ┌──────────────────────────────────────────────────────┐${RESET}"
    echo -e "${GREEN}${BOLD}  │  📖 $1${RESET}"
    echo -e "${GREEN}${BOLD}  └──────────────────────────────────────────────────────┘${RESET}"
    echo ""
}

print_subsection() {
    echo ""
    echo -e "${MAGENTA}${BOLD}  ▸ $1${RESET}"
    echo -e "${MAGENTA}  ─────────────────────────────────────${RESET}"
    echo ""
}

print_info() {
    echo -e "${WHITE}  $1${RESET}"
}

print_highlight() {
    echo -e "${YELLOW}${BOLD}  ★ $1${RESET}"
}

print_example() {
    echo -e "${CYAN}  💡 Example: $1${RESET}"
}

print_warning() {
    echo -e "${RED}${BOLD}  ⚠  $1${RESET}"
}

print_success() {
    echo -e "${GREEN}${BOLD}  ✔  $1${RESET}"
}

print_diagram() {
    echo -e "${DIM}$1${RESET}"
}

print_code() {
    echo -e "${BG_BLUE}${WHITE}  $ $1  ${RESET}"
}

print_note() {
    echo -e "${BLUE}  📝 Note: $1${RESET}"
}

print_definition() {
    echo -e "${YELLOW}  📚 $1:${RESET}"
    echo -e "${WHITE}     $2${RESET}"
}

progress_bar() {
    local current=$1
    local total=$2
    local width=40
    local percentage=$((current * 100 / total))
    local filled=$((current * width / total))
    local empty=$((width - filled))

    printf "  ${CYAN}["
    printf "%${filled}s" | tr ' ' '█'
    printf "%${empty}s" | tr ' ' '░'
    printf "] %d%% (%d/%d)${RESET}\n" "$percentage" "$current" "$total"
}

save_progress() {
    echo "$CURRENT_MODULE:$SCORE:$TOTAL_QUESTIONS" > "$PROGRESS_FILE"
}

load_progress() {
    if [ -f "$PROGRESS_FILE" ]; then
        IFS=':' read -r CURRENT_MODULE SCORE TOTAL_QUESTIONS < "$PROGRESS_FILE"
    fi
}

run_quiz() {
    local question="$1"
    local option_a="$2"
    local option_b="$3"
    local option_c="$4"
    local option_d="$5"
    local correct="$6"
    local explanation="$7"

    TOTAL_QUESTIONS=$((TOTAL_QUESTIONS + 1))

    echo ""
    echo -e "${BG_MAGENTA}${WHITE}${BOLD}  📝 QUIZ TIME  ${RESET}"
    echo ""
    echo -e "${WHITE}${BOLD}  $question${RESET}"
    echo ""
    echo -e "${CYAN}    A) $option_a${RESET}"
    echo -e "${CYAN}    B) $option_b${RESET}"
    echo -e "${CYAN}    C) $option_c${RESET}"
    echo -e "${CYAN}    D) $option_d${RESET}"
    echo ""

    local answer=""
    while [[ ! "$answer" =~ ^[AaBbCcDd]$ ]]; do
        echo -ne "${YELLOW}  Your answer (A/B/C/D): ${RESET}"
        read -r answer
    done

    answer=$(echo "$answer" | tr '[:lower:]' '[:upper:]')

    if [ "$answer" = "$correct" ]; then
        SCORE=$((SCORE + 1))
        echo ""
        print_success "CORRECT! 🎉"
    else
        echo ""
        echo -e "${RED}${BOLD}  ✘ INCORRECT. The correct answer is: $correct${RESET}"
    fi

    echo -e "${BLUE}  💡 Explanation: $explanation${RESET}"
    echo ""
    echo -e "${DIM}  Score: $SCORE/$TOTAL_QUESTIONS${RESET}"
    press_continue
}

run_true_false() {
    local question="$1"
    local correct="$2"
    local explanation="$3"

    TOTAL_QUESTIONS=$((TOTAL_QUESTIONS + 1))

    echo ""
    echo -e "${BG_MAGENTA}${WHITE}${BOLD}  📝 TRUE or FALSE  ${RESET}"
    echo ""
    echo -e "${WHITE}${BOLD}  $question${RESET}"
    echo ""

    local answer=""
    while [[ ! "$answer" =~ ^[TtFf]$ ]]; do
        echo -ne "${YELLOW}  Your answer (T/F): ${RESET}"
        read -r answer
    done

    answer=$(echo "$answer" | tr '[:lower:]' '[:upper:]')

    if [ "$answer" = "$correct" ]; then
        SCORE=$((SCORE + 1))
        echo ""
        print_success "CORRECT! 🎉"
    else
        echo ""
        echo -e "${RED}${BOLD}  ✘ INCORRECT. The correct answer is: $correct${RESET}"
    fi

    echo -e "${BLUE}  💡 $explanation${RESET}"
    echo ""
    echo -e "${DIM}  Score: $SCORE/$TOTAL_QUESTIONS${RESET}"
    press_continue
}

run_hands_on() {
    local title="$1"
    local description="$2"
    local command="$3"
    local explanation="$4"

    echo ""
    echo -e "${BG_GREEN}${WHITE}${BOLD}  🔧 HANDS-ON LAB: $title  ${RESET}"
    echo ""
    echo -e "${WHITE}  $description${RESET}"
    echo ""
    echo -e "${YELLOW}  Command to run:${RESET}"
    print_code "$command"
    echo ""
    echo -ne "${CYAN}  Would you like to run this command? (y/n): ${RESET}"
    read -r run_it

    if [[ "$run_it" =~ ^[Yy]$ ]]; then
        echo ""
        echo -e "${DIM}  ─── Output ────────────────────────────────────────${RESET}"
        eval "$command" 2>&1 | head -50 | sed 's/^/  /'
        echo -e "${DIM}  ──────────────────────────────────────────────────${RESET}"
    fi

    echo ""
    echo -e "${BLUE}  📝 $explanation${RESET}"
    press_continue
}

check_dependencies() {
    local deps=("curl" "ping" "nslookup" "traceroute" "openssl" "nmap" "whois" "dig")
    local missing=()

    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &>/dev/null; then
            missing+=("$dep")
        fi
    done

    if [ ${#missing[@]} -gt 0 ]; then
        echo -e "${YELLOW}  Some optional tools are not installed:${RESET}"
        echo -e "${YELLOW}  ${missing[*]}${RESET}"
        echo ""
        echo -e "${WHITE}  Install them for the best experience:${RESET}"
        echo -e "${CYAN}  pkg install ${missing[*]}${RESET}"
        echo ""
        echo -ne "${GREEN}  Install missing packages now? (y/n): ${RESET}"
        read -r install_choice
        if [[ "$install_choice" =~ ^[Yy]$ ]]; then
            pkg install -y "${missing[@]}" 2>/dev/null
        fi
    fi
}

#==============================================================================
#  MODULE 0: WELCOME & INTRODUCTION
#==============================================================================
module_0_welcome() {
    clear_screen
    echo -e "${CYAN}${BOLD}"
    cat << 'BANNER'

    ╔═══════════════════════════════════════════════════════╗
    ║                                                       ║
    ║   🌐  HOW THE INTERNET WORKS  🌐                     ║
    ║                                                       ║
    ║   A Complete Interactive Course                        ║
    ║   Built for Termux on Android                         ║
    ║                                                       ║
    ║   ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀                      ║
    ║                                                       ║
    ║   📡 12 Comprehensive Modules                         ║
    ║   🔧 Hands-on Labs with Real Commands                 ║
    ║   📝 Quizzes After Every Section                      ║
    ║   📊 Progress Tracking                                ║
    ║                                                       ║
    ╚═══════════════════════════════════════════════════════╝

BANNER
    echo -e "${RESET}"

    echo -e "${WHITE}${BOLD}  COURSE CURRICULUM:${RESET}"
    echo ""
    echo -e "${GREEN}   Module  1: ${WHITE}Physical Infrastructure - Cables & Hardware${RESET}"
    echo -e "${GREEN}   Module  2: ${WHITE}Binary, Bits & Data Transmission${RESET}"
    echo -e "${GREEN}   Module  3: ${WHITE}IP Addresses & Subnetting${RESET}"
    echo -e "${GREEN}   Module  4: ${WHITE}The OSI Model & TCP/IP Stack${RESET}"
    echo -e "${GREEN}   Module  5: ${WHITE}DNS - The Internet's Phone Book${RESET}"
    echo -e "${GREEN}   Module  6: ${WHITE}TCP, UDP & Packet Switching${RESET}"
    echo -e "${GREEN}   Module  7: ${WHITE}HTTP, HTTPS & Web Communication${RESET}"
    echo -e "${GREEN}   Module  8: ${WHITE}Routing & How Data Finds Its Way${RESET}"
    echo -e "${GREEN}   Module  9: ${WHITE}Encryption, TLS & Security${RESET}"
    echo -e "${GREEN}   Module 10: ${WHITE}Email, FTP & Other Protocols${RESET}"
    echo -e "${GREEN}   Module 11: ${WHITE}CDNs, Caching & Performance${RESET}"
    echo -e "${GREEN}   Module 12: ${WHITE}Modern Internet - APIs, WebSockets & Cloud${RESET}"
    echo ""

    echo -e "${YELLOW}  Checking system dependencies...${RESET}"
    check_dependencies

    press_continue_msg "Press [Enter] to begin your journey into the Internet..."
}

#==============================================================================
#  MODULE 1: PHYSICAL INFRASTRUCTURE
#==============================================================================
module_1_physical_infrastructure() {
    print_header "MODULE 1: PHYSICAL INFRASTRUCTURE" "Cables, Signals & the Hardware of the Internet"

    echo -e "${WHITE}  Before we understand protocols and software, we must${RESET}"
    echo -e "${WHITE}  understand what the internet PHYSICALLY is.${RESET}"
    echo ""
    echo -e "${YELLOW}${BOLD}  The internet is a global network of interconnected${RESET}"
    echo -e "${YELLOW}${BOLD}  computers communicating through physical media.${RESET}"

    press_continue

    # --- Section 1.1: Submarine Cables ---
    print_header "MODULE 1.1: SUBMARINE CABLES" "The Backbone of Global Internet"

    print_section "Undersea Fiber Optic Cables"

    print_info "Over 99% of intercontinental data travels through"
    print_info "submarine cables laid on the ocean floor."
    echo ""
    print_info "Key Facts:"
    echo -e "${CYAN}  • Over 550+ active submarine cables worldwide${RESET}"
    echo -e "${CYAN}  • Total length exceeds 1.4 million kilometers${RESET}"
    echo -e "${CYAN}  • Each cable contains multiple fiber pairs${RESET}"
    echo -e "${CYAN}  • A single fiber can carry 400+ Gbps${RESET}"
    echo -e "${CYAN}  • Cables are only ~17mm thick (garden hose size)${RESET}"
    echo ""

    print_diagram "
    ${CYAN}  Cross-section of a Submarine Cable:
    ${DIM}  ┌──────────────────────────────────────────┐
    │  ╭───────────────────────────────────╮     │
    │  │  ╭────────────────────────────╮   │     │
    │  │  │  ╭─────────────────────╮   │   │     │
    │  │  │  │  ╭──────────────╮   │   │   │     │
    │  │  │  │  │ OPTICAL FIBER│   │   │   │     │
    │  │  │  │  ╰──────────────╯   │   │   │     │
    │  │  │  │  Jelly Filling      │   │   │     │
    │  │  │  ╰─────────────────────╯   │   │     │
    │  │  │  Steel Wire Strength Member│   │     │
    │  │  ╰────────────────────────────╯   │     │
    │  │  Copper/Aluminum Power Conductor  │     │
    │  ╰───────────────────────────────────╯     │
    │  Polyethylene Outer Sheath                 │
    └──────────────────────────────────────────┘${RESET}"

    press_continue

    # --- Section 1.2: Types of Connections ---
    print_header "MODULE 1.2: TYPES OF PHYSICAL CONNECTIONS" ""

    print_section "Connection Types Compared"

    print_diagram "
    ${CYAN}╔══════════════════╦═══════════════╦═══════════════════════╗
    ║ Type             ║ Speed         ║ How It Works          ║
    ╠══════════════════╬═══════════════╬═══════════════════════╣
    ║ Fiber Optic      ║ 100+ Gbps    ║ Light through glass   ║
    ║ Ethernet (Cat6)  ║ 10 Gbps      ║ Electricity in copper ║
    ║ Coaxial Cable    ║ 1 Gbps       ║ Electrical signals    ║
    ║ DSL              ║ 100 Mbps     ║ Phone line signals    ║
    ║ WiFi 6           ║ 9.6 Gbps     ║ Radio waves           ║
    ║ 5G Cellular      ║ 20 Gbps      ║ Millimeter waves      ║
    ║ Satellite        ║ 500 Mbps     ║ Microwave to orbit    ║
    ╚══════════════════╩═══════════════╩═══════════════════════╝${RESET}"

    echo ""
    print_subsection "Fiber Optic Cables"
    print_info "Use pulses of light (photons) through thin glass strands."
    print_info "Light bounces internally (total internal reflection)."
    print_info "Two types:"
    echo -e "${CYAN}    • Single-mode: Long distance, one light path${RESET}"
    echo -e "${CYAN}    • Multi-mode:  Short distance, multiple light paths${RESET}"

    print_diagram "
    ${DIM}  Single-mode Fiber:
      ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
      →→→→→→→→→→→→→→→→→→→→→→→→→→→→→→→→→→→→→  (one path)
      ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

      Multi-mode Fiber:
      ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
      →  →  →  →  →  →  →  →  →  →  →  →
        ↗  ↘  ↗  ↘  ↗  ↘  ↗  ↘  ↗  ↘       (multiple paths)
      →→  →→  →→  →→  →→  →→  →→  →→
      ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"

    press_continue

    # --- Section 1.3: Network Hardware ---
    print_header "MODULE 1.3: NETWORK HARDWARE" "Devices That Build the Internet"

    print_section "Key Network Devices"

    print_definition "Modem (Modulator-Demodulator)" \
        "Converts digital signals to analog and vice versa"
    echo ""
    print_definition "Router" \
        "Forwards data packets between networks, makes routing decisions"
    echo ""
    print_definition "Switch" \
        "Connects devices within a LAN, forwards based on MAC addresses"
    echo ""
    print_definition "Hub" \
        "Simple device that broadcasts data to all ports (obsolete)"
    echo ""
    print_definition "Access Point (AP)" \
        "Provides wireless connectivity to a wired network"
    echo ""
    print_definition "Firewall" \
        "Monitors and filters network traffic based on security rules"
    echo ""

    print_diagram "
    ${CYAN}  Your Home Network:

      📱 Phone ──┐
      💻 Laptop ─┤                    🌐 Internet
      🖥  PC ────┼── [WiFi Router] ── [Modem] ── [ISP] ──── ☁
      🖨  Print ─┤        │
      📺 TV ─────┘        │
                      [Firewall]${RESET}"

    press_continue

    # --- Section 1.4: Internet Hierarchy ---
    print_header "MODULE 1.4: INTERNET HIERARCHY" "How Networks Connect to Networks"

    print_section "The Three Tiers of ISPs"

    print_diagram "
    ${CYAN}
                    ╔═══════════════════╗
                    ║  TIER 1 ISPs      ║
                    ║  (Global Backbone)║
                    ║  AT&T, NTT, Telia ║
                    ╚════════╤══════════╝
                             │
                ┌────────────┼────────────┐
                │            │            │
         ╔══════╧═════╗ ╔════╧═════╗ ╔════╧══════╗
         ║  TIER 2    ║ ║ TIER 2   ║ ║ TIER 2    ║
         ║  Regional  ║ ║ Regional ║ ║ Regional  ║
         ╚══════╤═════╝ ╚════╤═════╝ ╚════╤══════╝
                │            │            │
            ┌───┴───┐    ┌───┴───┐    ┌───┴───┐
            │Tier 3 │    │Tier 3 │    │Tier 3 │
            │ Local │    │ Local │    │ Local │
            │  ISP  │    │  ISP  │    │  ISP  │
            └───┬───┘    └───┬───┘    └───┬───┘
                │            │            │
              Homes       Offices     Mobile Users${RESET}"

    echo ""
    print_info "Tier 1: Own global fiber networks. Peer with each other freely."
    print_info "Tier 2: Regional networks. Pay Tier 1 for global access."
    print_info "Tier 3: Local ISPs. Pay Tier 2 for connectivity."
    echo ""

    print_definition "Internet Exchange Point (IXP)" \
        "Physical location where networks meet to exchange traffic directly"
    print_info "  IXPs reduce costs and latency by enabling direct peering."
    print_info "  Examples: DE-CIX (Frankfurt), LINX (London), AMS-IX (Amsterdam)"

    press_continue

    # --- Section 1.5: Data Centers ---
    print_header "MODULE 1.5: DATA CENTERS" "Where the Internet Lives"

    print_section "Inside a Data Center"

    print_info "Data centers house thousands of servers that:"
    echo -e "${CYAN}    • Store websites, apps, databases${RESET}"
    echo -e "${CYAN}    • Process requests from users worldwide${RESET}"
    echo -e "${CYAN}    • Require massive cooling systems${RESET}"
    echo -e "${CYAN}    • Have redundant power supplies (UPS + generators)${RESET}"
    echo -e "${CYAN}    • Use 1-3% of global electricity${RESET}"
    echo ""

    print_diagram "
    ${DIM}  Data Center Layout:
    ┌────────────────────────────────────────────────┐
    │  ┌──────┐  ┌──────┐  ┌──────┐  ┌──────┐     │
    │  │Server│  │Server│  │Server│  │Server│     │
    │  │ Rack │  │ Rack │  │ Rack │  │ Rack │     │
    │  │ ░░░░ │  │ ░░░░ │  │ ░░░░ │  │ ░░░░ │     │
    │  │ ░░░░ │  │ ░░░░ │  │ ░░░░ │  │ ░░░░ │     │
    │  │ ░░░░ │  │ ░░░░ │  │ ░░░░ │  │ ░░░░ │     │
    │  └──────┘  └──────┘  └──────┘  └──────┘     │
    │        ← Cold Aisle →    ← Hot Aisle →       │
    │  ┌─────────────────────────────────────────┐  │
    │  │    🔌 Power Distribution Unit (PDU)     │  │
    │  └─────────────────────────────────────────┘  │
    │  ┌─────────────────┐  ┌────────────────────┐  │
    │  │  ❄️  Cooling     │  │  🔋 UPS/Generator  │  │
    │  └─────────────────┘  └────────────────────┘  │
    └────────────────────────────────────────────────┘${RESET}"

    press_continue

    # --- Hands-on Lab ---
    print_header "MODULE 1: HANDS-ON LABS" "Explore Your Physical Connection"

    run_hands_on \
        "Check Your Network Interface" \
        "See all network interfaces on your device." \
        "ip addr show 2>/dev/null || ifconfig 2>/dev/null" \
        "This shows your device's network interfaces (WiFi, cellular, loopback)."

    run_hands_on \
        "Check Your WiFi Connection" \
        "View wireless connection details." \
        "ip link show 2>/dev/null | grep -E 'wlan|state'" \
        "wlan0 is typically your WiFi interface."

    # --- Quiz ---
    print_header "MODULE 1: QUIZ" "Test Your Knowledge"

    run_quiz \
        "What percentage of intercontinental data travels via submarine cables?" \
        "About 50%" \
        "About 75%" \
        "Over 99%" \
        "About 25%" \
        "C" \
        "Submarine fiber optic cables carry over 99% of intercontinental data. Satellites handle very little."

    run_quiz \
        "Which physical medium offers the highest speed?" \
        "Coaxial cable" \
        "Fiber optic cable" \
        "Ethernet Cat6" \
        "Copper telephone wire" \
        "B" \
        "Fiber optic uses light pulses and can achieve 100+ Gbps over long distances."

    run_quiz \
        "What is a Tier 1 ISP?" \
        "A local internet provider for homes" \
        "A company that makes routers" \
        "A global backbone network that peers freely with others" \
        "A WiFi hotspot provider" \
        "C" \
        "Tier 1 ISPs own global networks and don't pay anyone for transit - they peer freely with other Tier 1s."

    run_true_false \
        "A router operates by forwarding data packets between different networks." \
        "T" \
        "Routers make forwarding decisions based on destination IP addresses to route packets between networks."

    run_true_false \
        "WiFi signals travel through fiber optic cables." \
        "F" \
        "WiFi uses radio waves transmitted through the air. Fiber optic uses light through glass strands."
}

#==============================================================================
#  MODULE 2: BINARY, BITS & DATA TRANSMISSION
#==============================================================================
module_2_binary_data() {
    print_header "MODULE 2: BINARY, BITS & DATA TRANSMISSION" "How Computers Represent and Send Data"

    print_section "Everything Is Binary"

    print_info "Computers only understand two states: ON (1) and OFF (0)."
    print_info "Every piece of data - text, images, video, websites -"
    print_info "is converted into sequences of 1s and 0s."
    echo ""

    print_definition "Bit (Binary Digit)" "The smallest unit of data: 0 or 1"
    print_definition "Byte" "8 bits grouped together (e.g., 01001000)"
    print_definition "Nibble" "4 bits (half a byte)"
    echo ""

    print_diagram "
    ${CYAN}  Data Size Reference:
    ╔═════════════╦═══════════════╦════════════════════════╗
    ║ Unit        ║ Size          ║ Real-world Example     ║
    ╠═════════════╬═══════════════╬════════════════════════╣
    ║ Bit         ║ 1 or 0       ║ A yes/no answer        ║
    ║ Byte        ║ 8 bits       ║ A single character     ║
    ║ Kilobyte    ║ 1,024 bytes  ║ A short email          ║
    ║ Megabyte    ║ 1,024 KB     ║ A music file (MP3)     ║
    ║ Gigabyte    ║ 1,024 MB     ║ A movie (720p)         ║
    ║ Terabyte    ║ 1,024 GB     ║ 500 hours of video     ║
    ║ Petabyte    ║ 1,024 TB     ║ Google daily searches  ║
    ╚═════════════╩═══════════════╩════════════════════════╝${RESET}"

    press_continue

    # --- Section 2.2: ASCII & Character Encoding ---
    print_header "MODULE 2.2: CHARACTER ENCODING" "How Text Becomes Numbers"

    print_section "ASCII Encoding"

    print_info "ASCII maps characters to numbers (0-127)."
    print_info "Each character = 1 byte (7 bits used + 1 parity bit)"
    echo ""

    print_diagram "
    ${CYAN}  ASCII Table (Selected):
    ╔══════════╦═══════╦══════════╦══════════════════╗
    ║ Char     ║ Dec   ║ Hex      ║ Binary           ║
    ╠══════════╬═══════╬══════════╬══════════════════╣
    ║ A        ║ 65    ║ 41       ║ 01000001         ║
    ║ B        ║ 66    ║ 42       ║ 01000010         ║
    ║ Z        ║ 90    ║ 5A       ║ 01011010         ║
    ║ a        ║ 97    ║ 61       ║ 01100001         ║
    ║ 0        ║ 48    ║ 30       ║ 00110000         ║
    ║ Space    ║ 32    ║ 20       ║ 00100000         ║
    ║ !        ║ 33    ║ 21       ║ 00100001         ║
    ╚══════════╩═══════╩══════════╩══════════════════╝${RESET}"

    echo ""
    print_example "'Hi' in binary: 01001000 01101001"
    print_info "H=72(01001000), i=105(01101001)"
    echo ""

    print_subsection "Unicode & UTF-8"
    print_info "ASCII only covers 128 characters (English)."
    print_info "Unicode supports 149,000+ characters from ALL languages."
    print_info "UTF-8 is the dominant encoding on the web (98%+)."
    echo -e "${CYAN}    • 1 byte for ASCII characters (backward compatible)${RESET}"
    echo -e "${CYAN}    • 2-4 bytes for other characters${RESET}"
    echo -e "${CYAN}    • Emojis are Unicode: 😀 = U+1F600 = 4 bytes${RESET}"

    press_continue

    # --- Section 2.3: Bandwidth & Throughput ---
    print_header "MODULE 2.3: BANDWIDTH & THROUGHPUT" "Measuring Data Transfer Speed"

    print_section "Speed Measurements"

    print_definition "Bandwidth" \
        "Maximum data transfer capacity of a connection (theoretical max)"
    print_definition "Throughput" \
        "Actual data transfer rate achieved in practice"
    print_definition "Latency" \
        "Time delay for data to travel from source to destination"
    print_definition "Jitter" \
        "Variation in latency over time"
    echo ""

    print_warning "ISPs advertise bandwidth, but throughput is always lower!"
    echo ""

    print_diagram "
    ${CYAN}  Bits vs Bytes in Speed:
    ┌─────────────────────────────────────────────────┐
    │  ISP says: \"100 Mbps\" (Megabits per second)     │
    │                                                  │
    │  Actual download speed:                          │
    │  100 Mbps ÷ 8 = 12.5 MB/s (Megabytes/second)   │
    │                                                  │
    │  Note: b = bit, B = Byte                         │
    │  8 bits = 1 byte                                 │
    │                                                  │
    │  So \"100 Mbps\" ≠ \"100 MB/s\"                     │
    └─────────────────────────────────────────────────┘${RESET}"

    echo ""
    print_info "Common speed units:"
    echo -e "${CYAN}    • bps  = bits per second${RESET}"
    echo -e "${CYAN}    • Kbps = 1,000 bps${RESET}"
    echo -e "${CYAN}    • Mbps = 1,000,000 bps${RESET}"
    echo -e "${CYAN}    • Gbps = 1,000,000,000 bps${RESET}"

    press_continue

    # --- Section 2.4: How Data Is Transmitted ---
    print_header "MODULE 2.4: SIGNAL TRANSMISSION" "Converting Bits to Physical Signals"

    print_section "Methods of Encoding Bits"

    print_info "Bits must be converted to physical signals for transmission:"
    echo ""

    echo -e "${YELLOW}  1. Electrical Signals (Copper Wire):${RESET}"
    print_info "     High voltage = 1, Low voltage = 0"
    print_diagram "
    ${DIM}     Voltage
      5V ┤  ┌──┐     ┌──┐  ┌──┐
         │  │  │     │  │  │  │
      0V ┤──┘  └─────┘  └──┘  └──
         └─────────────────────────→ Time
     Bits:  1  0  0  0  1  0  1  0${RESET}"

    echo ""
    echo -e "${YELLOW}  2. Light Pulses (Fiber Optic):${RESET}"
    print_info "     Light ON = 1, Light OFF = 0"
    print_diagram "
    ${DIM}     Light
      ON ┤  ●●●●     ●●●●  ●●●●
         │
     OFF ┤      ●●●●●     ●●
         └─────────────────────────→ Time
     Bits:  1  0  0  0  1  0  1  0${RESET}"

    echo ""
    echo -e "${YELLOW}  3. Radio Waves (WiFi/Cellular):${RESET}"
    print_info "     Different frequencies/amplitudes encode 1s and 0s"

    press_continue

    # --- Hands-on Labs ---
    print_header "MODULE 2: HANDS-ON LABS" "Binary & Data in Practice"

    run_hands_on \
        "Convert Text to Binary" \
        "Convert the word 'Hello' to binary representation." \
        "echo -n 'Hello' | xxd -b | head -5" \
        "xxd -b shows the binary representation of each character."

    run_hands_on \
        "Check Your Network Speed" \
        "Measure download speed with curl." \
        "curl -o /dev/null -w 'Speed: %{speed_download} bytes/sec\nTime: %{time_total}s\nSize: %{size_download} bytes\n' -s https://www.google.com" \
        "This downloads google.com and reports the speed and time."

    run_hands_on \
        "See Text as Hex and ASCII" \
        "View hexadecimal encoding of text." \
        "echo 'Internet' | xxd | head -5" \
        "xxd shows hex (base-16) representation. Each pair of hex digits = 1 byte."

    # --- Quiz ---
    print_header "MODULE 2: QUIZ" "Test Your Knowledge"

    run_quiz \
        "How many bits are in 1 byte?" \
        "4" \
        "8" \
        "16" \
        "32" \
        "B" \
        "1 byte = 8 bits. This is a fundamental unit in computing."

    run_quiz \
        "If your ISP gives you 200 Mbps, what is the max download speed in MB/s?" \
        "200 MB/s" \
        "25 MB/s" \
        "100 MB/s" \
        "1600 MB/s" \
        "B" \
        "200 Mbps ÷ 8 bits per byte = 25 MB/s. Remember: b=bit, B=byte."

    run_quiz \
        "What does ASCII stand for?" \
        "American Standard Code for Internet Interchange" \
        "American Standard Code for Information Interchange" \
        "Automated System Code for Information Interchange" \
        "American Secure Code for Internet Integration" \
        "B" \
        "ASCII = American Standard Code for Information Interchange, created in 1963."

    run_true_false \
        "UTF-8 can represent characters from any language in the world." \
        "T" \
        "UTF-8 supports the full Unicode standard with 149,000+ characters from all writing systems."
}

#==============================================================================
#  MODULE 3: IP ADDRESSES & SUBNETTING
#==============================================================================
module_3_ip_addresses() {
    print_header "MODULE 3: IP ADDRESSES & SUBNETTING" "The Addressing System of the Internet"

    print_section "What Is an IP Address?"

    print_info "Every device on the internet needs a unique address."
    print_info "IP (Internet Protocol) addresses serve as these addresses."
    print_info "Think of them like postal addresses for computers."
    echo ""

    print_definition "IP Address" \
        "A numerical label assigned to each device on a network"

    press_continue

    # --- Section 3.1: IPv4 ---
    print_header "MODULE 3.1: IPv4 ADDRESSES" "The Classic Internet Address"

    print_section "IPv4 Structure"

    print_info "IPv4 uses 32 bits, written as 4 decimal numbers (octets)."
    echo ""

    print_diagram "
    ${CYAN}  IPv4 Address Example: 192.168.1.100

    Decimal:    192    .    168    .     1     .    100
                 │          │          │          │
    Binary:  11000000  10101000  00000001  01100100
             ├─8 bits─┤├─8 bits─┤├─8 bits─┤├─8 bits─┤
             └──────────── 32 bits total ────────────┘

    Total possible addresses: 2^32 = 4,294,967,296 (~4.3 billion)${RESET}"

    echo ""
    print_warning "4.3 billion is NOT enough for 8+ billion people!"
    print_info "This is why IPv6 was created and NAT is widely used."

    press_continue

    # --- IPv4 Classes ---
    print_header "MODULE 3.1b: IPv4 ADDRESS CLASSES" ""

    print_diagram "
    ${CYAN}╔═══════╦═════════════════════╦══════════════════╦════════════╗
    ║ Class ║ Range               ║ Default Mask     ║ Use        ║
    ╠═══════╬═════════════════════╬══════════════════╬════════════╣
    ║ A     ║ 1.0.0.0-126.x.x.x  ║ 255.0.0.0 (/8)  ║ Large nets ║
    ║ B     ║ 128.0.0.0-191.x.x  ║ 255.255.0.0(/16) ║ Medium nets║
    ║ C     ║ 192.0.0.0-223.x.x  ║ 255.255.255.0/24 ║ Small nets ║
    ║ D     ║ 224.0.0.0-239.x.x  ║ N/A              ║ Multicast  ║
    ║ E     ║ 240.0.0.0-255.x.x  ║ N/A              ║ Reserved   ║
    ╚═══════╩═════════════════════╩══════════════════╩════════════╝${RESET}"

    echo ""
    print_subsection "Private IP Address Ranges (RFC 1918)"
    print_info "These addresses are NOT routable on the public internet:"
    echo ""
    echo -e "${CYAN}    • 10.0.0.0     - 10.255.255.255   (Class A: /8)${RESET}"
    echo -e "${CYAN}    • 172.16.0.0   - 172.31.255.255   (Class B: /12)${RESET}"
    echo -e "${CYAN}    • 192.168.0.0  - 192.168.255.255  (Class C: /16)${RESET}"
    echo ""
    print_info "Special addresses:"
    echo -e "${CYAN}    • 127.0.0.1    - Localhost (your own device)${RESET}"
    echo -e "${CYAN}    • 0.0.0.0      - All interfaces / default route${RESET}"
    echo -e "${CYAN}    • 255.255.255.255 - Broadcast to all${RESET}"

    press_continue

    # --- Section 3.2: IPv6 ---
    print_header "MODULE 3.2: IPv6 ADDRESSES" "The Future of Internet Addressing"

    print_section "Why IPv6?"

    print_info "IPv4 has ~4.3 billion addresses - not enough!"
    print_info "IPv6 uses 128 bits = 340 undecillion addresses."
    echo ""

    print_diagram "
    ${CYAN}  IPv6 Address Example:
    2001:0db8:85a3:0000:0000:8a2e:0370:7334

    Structure: 8 groups of 4 hexadecimal digits
    Separated by colons (:)
    Each group = 16 bits
    Total = 128 bits

    Shorthand rules:
    • Leading zeros can be dropped:
      2001:db8:85a3:0:0:8a2e:370:7334

    • Consecutive zero groups replaced with ::
      2001:db8:85a3::8a2e:370:7334

    Total addresses: 2^128 = 340,282,366,920,938,463,
                     463,374,607,431,768,211,456
    (That's 340 trillion trillion trillion)${RESET}"

    press_continue

    # --- Section 3.3: Subnetting ---
    print_header "MODULE 3.3: SUBNETTING" "Dividing Networks into Sub-Networks"

    print_section "Understanding Subnet Masks"

    print_info "A subnet mask divides an IP into NETWORK and HOST portions."
    echo ""

    print_diagram "
    ${CYAN}  IP Address:    192.168.1.100
    Subnet Mask:   255.255.255.0

    In Binary:
    IP:   11000000.10101000.00000001.01100100
    Mask: 11111111.11111111.11111111.00000000
          ├─── Network Part ────────┤├─Host─┤

    Network Address: 192.168.1.0   (all host bits = 0)
    Broadcast:       192.168.1.255 (all host bits = 1)
    Usable Range:    192.168.1.1 - 192.168.1.254
    Total Hosts:     254 (2^8 - 2)${RESET}"

    echo ""
    print_subsection "CIDR Notation"
    print_info "Instead of writing 255.255.255.0, we write /24"
    print_info "The number after / = how many bits are the network portion."
    echo ""
    echo -e "${CYAN}    /8  = 255.0.0.0       = 16,777,214 hosts${RESET}"
    echo -e "${CYAN}    /16 = 255.255.0.0     = 65,534 hosts${RESET}"
    echo -e "${CYAN}    /24 = 255.255.255.0   = 254 hosts${RESET}"
    echo -e "${CYAN}    /28 = 255.255.255.240 = 14 hosts${RESET}"
    echo -e "${CYAN}    /32 = 255.255.255.255 = 1 host (single address)${RESET}"

    press_continue

    # --- Section 3.4: NAT ---
    print_header "MODULE 3.4: NAT (Network Address Translation)" "Sharing One Public IP Among Many Devices"

    print_section "How NAT Works"

    print_info "NAT allows multiple devices to share one public IP address."
    print_info "Your router performs NAT for your home network."
    echo ""

    print_diagram "
    ${CYAN}  NAT in Action:

    Private Network              Router (NAT)           Internet
    ┌──────────────┐          ┌──────────────┐
    │ 192.168.1.10 │──┐       │              │      ┌──────────┐
    │   (Phone)    │  │       │ Private:     │      │          │
    ├──────────────┤  ├──────▶│ 192.168.1.1  │─────▶│  Google  │
    │ 192.168.1.11 │──┤       │              │      │ 142.x.x  │
    │   (Laptop)   │  │       │ Public:      │      │          │
    ├──────────────┤  │       │ 203.0.113.5  │      └──────────┘
    │ 192.168.1.12 │──┘       │              │
    │   (TV)       │          └──────────────┘
    └──────────────┘
                         All devices appear as
                         203.0.113.5 to the internet${RESET}"

    echo ""
    print_info "NAT is why we haven't completely run out of IPv4 addresses."

    press_continue

    # --- Hands-on Labs ---
    print_header "MODULE 3: HANDS-ON LABS" "IP Addresses in Practice"

    run_hands_on \
        "Find Your IP Addresses" \
        "View all IP addresses assigned to your device." \
        "ip addr show 2>/dev/null | grep 'inet ' || ifconfig 2>/dev/null | grep 'inet '" \
        "You'll see private IPs (192.168.x.x or 10.x.x.x) for local interfaces."

    run_hands_on \
        "Find Your Public IP" \
        "See what IP address the internet sees you as." \
        "curl -s ifconfig.me 2>/dev/null || curl -s icanhazip.com 2>/dev/null" \
        "This is your public IP - the one your ISP assigned to your router."

    run_hands_on \
        "Check IPv6 Support" \
        "See if your device has IPv6 connectivity." \
        "ip -6 addr show 2>/dev/null | grep 'inet6' | head -5" \
        "fe80:: addresses are link-local. Global addresses start with 2xxx or 3xxx."

    # --- Quiz ---
    print_header "MODULE 3: QUIZ" "Test Your Knowledge"

    run_quiz \
        "How many bits make up an IPv4 address?" \
        "16" \
        "64" \
        "32" \
        "128" \
        "C" \
        "IPv4 uses 32 bits, written as 4 octets (e.g., 192.168.1.1)."

    run_quiz \
        "Which of these is a private IP address?" \
        "8.8.8.8" \
        "192.168.1.1" \
        "142.250.80.46" \
        "1.1.1.1" \
        "B" \
        "192.168.x.x is a private range (RFC 1918). The others are public addresses."

    run_quiz \
        "What does NAT do?" \
        "Speeds up internet connection" \
        "Encrypts all network traffic" \
        "Translates private IPs to a shared public IP" \
        "Assigns domain names to IPs" \
        "C" \
        "NAT translates private addresses to a public address, allowing many devices to share one public IP."

    run_quiz \
        "What does /24 mean in CIDR notation?" \
        "24 devices can connect" \
        "24 bits for the network portion, 8 for hosts" \
        "24 subnets available" \
        "24 megabits speed" \
        "B" \
        "/24 means 24 bits are the network portion, leaving 8 bits for host addresses (254 usable hosts)."

    run_true_false \
        "127.0.0.1 is the loopback address that refers to your own device." \
        "T" \
        "127.0.0.1 (localhost) always refers to the current device. Traffic to it never leaves the machine."
}

#==============================================================================
#  MODULE 4: THE OSI MODEL & TCP/IP STACK
#==============================================================================
module_4_osi_model() {
    print_header "MODULE 4: THE OSI MODEL & TCP/IP STACK" "Understanding Network Layers"

    print_section "Why Do We Need Layers?"

    print_info "Networking is complex. Layers break it into manageable pieces."
    print_info "Each layer has a specific job and talks to layers above/below."
    print_info "This is called 'abstraction' - each layer doesn't need to know"
    print_info "the details of other layers."

    press_continue

    # --- Section 4.1: OSI 7 Layers ---
    print_header "MODULE 4.1: THE OSI MODEL" "7 Layers of Network Communication"

    print_section "OSI (Open Systems Interconnection) Model"

    print_diagram "
    ${CYAN}
    ╔════╦══════════════════╦════════════════════╦══════════════════╗
    ║ #  ║ Layer            ║ Function           ║ Examples         ║
    ╠════╬══════════════════╬════════════════════╬══════════════════╣
    ║ 7  ║ Application      ║ User interface     ║ HTTP,FTP,SMTP    ║
    ║    ║                  ║ & app protocols    ║ DNS,SSH          ║
    ╠════╬══════════════════╬════════════════════╬══════════════════╣
    ║ 6  ║ Presentation     ║ Data formatting,   ║ SSL/TLS,JPEG,    ║
    ║    ║                  ║ encryption,compress║ ASCII,MPEG       ║
    ╠════╬══════════════════╬════════════════════╬══════════════════╣
    ║ 5  ║ Session          ║ Manage connections ║ NetBIOS,RPC,     ║
    ║    ║                  ║ (open/close)       ║ PPTP             ║
    ╠════╬══════════════════╬════════════════════╬══════════════════╣
    ║ 4  ║ Transport        ║ Reliable delivery, ║ TCP,UDP          ║
    ║    ║                  ║ flow control       ║                  ║
    ╠════╬══════════════════╬════════════════════╬══════════════════╣
    ║ 3  ║ Network          ║ Routing & logical  ║ IP,ICMP,         ║
    ║    ║                  ║ addressing         ║ IPSec,OSPF       ║
    ╠════╬══════════════════╬════════════════════╬══════════════════╣
    ║ 2  ║ Data Link        ║ Frame delivery,    ║ Ethernet,WiFi,   ║
    ║    ║                  ║ MAC addressing     ║ PPP,ARP          ║
    ╠════╬══════════════════╬════════════════════╬══════════════════╣
    ║ 1  ║ Physical         ║ Raw bit stream     ║ Cables,Hubs,     ║
    ║    ║                  ║ transmission       ║ Radio signals    ║
    ╚════╩══════════════════╩════════════════════╩══════════════════╝

    Memory aid: \"All People Seem To Need Data Processing\"
                (from Layer 7 down to Layer 1)${RESET}"

    press_continue

    # --- Section 4.2: Data Flow Through Layers ---
    print_header "MODULE 4.2: DATA ENCAPSULATION" "How Data Moves Through Layers"

    print_section "Encapsulation Process"

    print_info "As data moves DOWN through layers, each layer WRAPS it"
    print_info "with its own header (and sometimes trailer)."
    echo ""

    print_diagram "
    ${CYAN}  Sending Data (Encapsulation):

    Layer 7-5:  [          DATA           ]
                         ↓ Add header
    Layer 4:    [TCP Hdr][     DATA        ]  ← Segment
                         ↓ Add header
    Layer 3:    [IP Hdr][TCP][   DATA      ]  ← Packet
                         ↓ Add header + trailer
    Layer 2:    [Frame Hdr][IP][TCP][DATA][FCS]  ← Frame
                         ↓ Convert to signals
    Layer 1:    10110010110101001010110...     ← Bits


    Receiving Data (De-encapsulation):

    Layer 1:    10110010110101001010110...     ← Bits
                         ↓ Reassemble
    Layer 2:    [Frame Hdr][IP][TCP][DATA][FCS]  ← Check FCS
                         ↓ Strip frame header
    Layer 3:    [IP Hdr][TCP][   DATA      ]  ← Check destination
                         ↓ Strip IP header
    Layer 4:    [TCP Hdr][     DATA        ]  ← Check port
                         ↓ Strip TCP header
    Layer 7-5:  [          DATA           ]  ← Delivered!${RESET}"

    press_continue

    # --- Section 4.3: TCP/IP Model ---
    print_header "MODULE 4.3: THE TCP/IP MODEL" "The Practical Internet Model"

    print_section "TCP/IP vs OSI"

    print_info "The TCP/IP model is what the internet actually uses."
    print_info "It has 4 layers instead of 7."
    echo ""

    print_diagram "
    ${CYAN}
    OSI Model               TCP/IP Model
    ┌──────────────────┐    ┌──────────────────────┐
    │  7. Application  │    │                      │
    ├──────────────────┤    │  4. Application      │
    │  6. Presentation │    │     (HTTP,FTP,DNS,    │
    ├──────────────────┤    │      SMTP,SSH)        │
    │  5. Session      │    │                      │
    ├──────────────────┤    ├──────────────────────┤
    │  4. Transport    │    │  3. Transport        │
    │                  │    │     (TCP, UDP)        │
    ├──────────────────┤    ├──────────────────────┤
    │  3. Network      │    │  2. Internet         │
    │                  │    │     (IP, ICMP, ARP)  │
    ├──────────────────┤    ├──────────────────────┤
    │  2. Data Link    │    │  1. Network Access   │
    ├──────────────────┤    │     (Ethernet, WiFi, │
    │  1. Physical     │    │      Fiber, DSL)     │
    └──────────────────┘    └──────────────────────┘${RESET}"

    echo ""
    print_highlight "The TCP/IP model combines OSI layers 5-7 into one Application layer"
    print_highlight "and OSI layers 1-2 into one Network Access layer."

    press_continue

    # --- Section 4.4: How Each Layer Works ---
    print_header "MODULE 4.4: LAYER-BY-LAYER WALKTHROUGH" "What Happens When You Visit a Website"

    print_section "Example: Visiting www.google.com"

    print_info "Let's trace what happens at each layer:"
    echo ""

    echo -e "${YELLOW}  Layer 4 - Application:${RESET}"
    print_info "  Browser creates HTTP GET request"
    print_info "  \"GET / HTTP/1.1\\nHost: www.google.com\""
    echo ""

    echo -e "${YELLOW}  Layer 3 - Transport (TCP):${RESET}"
    print_info "  Adds source port (e.g., 54321) & destination port (443)"
    print_info "  Establishes connection via 3-way handshake"
    print_info "  Breaks data into segments if needed"
    echo ""

    echo -e "${YELLOW}  Layer 2 - Internet (IP):${RESET}"
    print_info "  Adds source IP (your address) & destination IP (Google's)"
    print_info "  Determines routing path"
    echo ""

    echo -e "${YELLOW}  Layer 1 - Network Access:${RESET}"
    print_info "  Adds MAC addresses for local network hop"
    print_info "  Converts to electrical/light/radio signals"
    print_info "  Sends over physical medium"

    press_continue

    # --- Quiz ---
    print_header "MODULE 4: QUIZ" "Test Your Knowledge"

    run_quiz \
        "How many layers does the OSI model have?" \
        "4" \
        "5" \
        "7" \
        "3" \
        "C" \
        "The OSI model has 7 layers: Physical, Data Link, Network, Transport, Session, Presentation, Application."

    run_quiz \
        "Which layer is responsible for IP addressing and routing?" \
        "Transport Layer" \
        "Data Link Layer" \
        "Network Layer" \
        "Application Layer" \
        "C" \
        "The Network Layer (Layer 3) handles logical addressing (IP) and routing between networks."

    run_quiz \
        "What is the process of adding headers to data at each layer called?" \
        "Encryption" \
        "Encapsulation" \
        "Compression" \
        "Segmentation" \
        "B" \
        "Encapsulation wraps data with layer-specific headers as it moves down the stack."

    run_quiz \
        "In the TCP/IP model, which layer combines OSI layers 5, 6, and 7?" \
        "Transport" \
        "Internet" \
        "Application" \
        "Network Access" \
        "C" \
        "The TCP/IP Application layer combines Session, Presentation, and Application from OSI."

    run_true_false \
        "The TCP/IP model is the theoretical model, while OSI is what the internet actually uses." \
        "F" \
        "It's the opposite. OSI is the theoretical reference model. TCP/IP is what the internet actually uses."
}

#==============================================================================
#  MODULE 5: DNS - THE INTERNET'S PHONE BOOK
#==============================================================================
module_5_dns() {
    print_header "MODULE 5: DNS" "The Domain Name System - Internet's Phone Book"

    print_section "Why DNS Exists"

    print_info "Humans remember names (google.com), not numbers (142.250.80.46)."
    print_info "DNS translates domain names to IP addresses."
    echo ""
    print_example "google.com → 142.250.80.46"
    print_example "facebook.com → 157.240.1.35"
    echo ""

    print_definition "DNS (Domain Name System)" \
        "A distributed, hierarchical system that translates domain names to IP addresses"

    press_continue

    # --- Section 5.1: Domain Name Structure ---
    print_header "MODULE 5.1: DOMAIN NAME STRUCTURE" "Anatomy of a URL"

    print_section "Parts of a Domain Name"

    print_diagram "
    ${CYAN}
      https://www.mail.google.com:443/inbox?page=1#top
      │       │    │    │      │   │   │      │     │
      │       │    │    │      │   │   │      │     └─ Fragment
      │       │    │    │      │   │   │      └─ Query String
      │       │    │    │      │   │   └─ Path
      │       │    │    │      │   └─ Port
      │       │    │    │      └─ TLD (Top-Level Domain)
      │       │    │    └─ Second-Level Domain (SLD)
      │       │    └─ Subdomain
      │       └─ Subdomain (www)
      └─ Protocol/Scheme

    Domain Hierarchy (read right to left):
    ┌────┐   ┌────────┐   ┌──────┐   ┌─────┐
    │ .  │ ← │  com   │ ← │google│ ← │ www │
    │Root│   │  TLD   │   │  SLD │   │ Sub │
    └────┘   └────────┘   └──────┘   └─────┘${RESET}"

    echo ""
    print_subsection "Top-Level Domains (TLDs)"
    echo -e "${CYAN}    Generic TLDs:  .com .org .net .edu .gov .info .io${RESET}"
    echo -e "${CYAN}    Country TLDs:  .us .uk .jp .de .br .in .au${RESET}"
    echo -e "${CYAN}    New TLDs:      .app .dev .cloud .ai .xyz${RESET}"

    press_continue

    # --- Section 5.2: DNS Resolution Process ---
    print_header "MODULE 5.2: DNS RESOLUTION" "How a Domain Name Becomes an IP Address"

    print_section "The DNS Lookup Journey"

    print_diagram "
    ${CYAN}
    You type: www.google.com in your browser

    Step 1: Browser Cache
    ┌──────────┐
    │ Browser  │──→ \"Do I have it cached?\" → Yes? Use it!
    └──────────┘                            → No? Continue...

    Step 2: OS Cache
    ┌──────────┐
    │ OS Cache │──→ \"Is it in /etc/hosts?\" → Yes? Use it!
    │ & hosts  │                            → No? Continue...
    └──────────┘

    Step 3: Recursive Resolver (ISP's DNS server)
    ┌──────────┐       ┌──────────────────┐
    │  Your    │──────→│ ISP's Recursive  │
    │  Device  │       │ DNS Resolver     │
    └──────────┘       └────────┬─────────┘
                                │
    Step 4: Root Server         │ \"Where is .com?\"
                       ┌────────▼─────────┐
                       │  Root DNS Server  │
                       │  (13 clusters)    │
                       └────────┬─────────┘
                                │ \"Ask a]93.184.216.34\"
    Step 5: TLD Server          │
                       ┌────────▼─────────┐
                       │  .com TLD Server  │
                       │                   │
                       └────────┬─────────┘
                                │ \"Ask ns1.google.com\"
    Step 6: Authoritative       │
                       ┌────────▼─────────┐
                       │ Google's DNS      │
                       │ (Authoritative)   │
                       └────────┬─────────┘
                                │ \"142.250.80.46\"
                       ┌────────▼─────────┐
                       │ Answer returned   │
                       │ to your browser!  │
                       └──────────────────┘${RESET}"

    press_continue

    # --- Section 5.3: DNS Record Types ---
    print_header "MODULE 5.3: DNS RECORD TYPES" "Different Types of DNS Information"

    print_section "Common DNS Records"

    print_diagram "
    ${CYAN}╔══════════╦═══════════════════════════════════════════════╗
    ║ Record   ║ Purpose                                       ║
    ╠══════════╬═══════════════════════════════════════════════╣
    ║ A        ║ Maps domain to IPv4 address                   ║
    ║          ║ google.com → 142.250.80.46                    ║
    ╠══════════╬═══════════════════════════════════════════════╣
    ║ AAAA     ║ Maps domain to IPv6 address                   ║
    ║          ║ google.com → 2607:f8b0:4004:800::200e         ║
    ╠══════════╬═══════════════════════════════════════════════╣
    ║ CNAME    ║ Alias - points to another domain              ║
    ║          ║ www.example.com → example.com                 ║
    ╠══════════╬═══════════════════════════════════════════════╣
    ║ MX       ║ Mail server for the domain                    ║
    ║          ║ gmail.com → gmail-smtp-in.l.google.com        ║
    ╠══════════╬═══════════════════════════════════════════════╣
    ║ NS       ║ Name server for the domain                    ║
    ║          ║ google.com → ns1.google.com                   ║
    ╠══════════╬═══════════════════════════════════════════════╣
    ║ TXT      ║ Arbitrary text (verification, SPF, etc.)      ║
    ╠══════════╬═══════════════════════════════════════════════╣
    ║ SOA      ║ Start of Authority - zone information         ║
    ╠══════════╬═══════════════════════════════════════════════╣
    ║ PTR      ║ Reverse lookup - IP to domain                 ║
    ╚══════════╩═══════════════════════════════════════════════╝${RESET}"

    press_continue

    # --- Section 5.4: DNS Caching & TTL ---
    print_header "MODULE 5.4: DNS CACHING" "Making DNS Faster"

    print_section "TTL (Time To Live)"

    print_info "DNS responses are cached at multiple levels to speed things up."
    print_info "TTL tells caches how long to keep a record (in seconds)."
    echo ""

    print_diagram "
    ${CYAN}  Caching Hierarchy:
    ┌──────────────┐
    │ Browser Cache│  TTL: Seconds to minutes
    └──────┬───────┘
           ↓
    ┌──────────────┐
    │ OS DNS Cache │  TTL: Minutes
    └──────┬───────┘
           ↓
    ┌──────────────┐
    │ Router Cache │  TTL: Minutes to hours
    └──────┬───────┘
           ↓
    ┌──────────────┐
    │ ISP Resolver │  TTL: Hours to days
    │    Cache     │  (respects the authoritative TTL)
    └──────────────┘${RESET}"

    echo ""
    print_info "Typical TTL values:"
    echo -e "${CYAN}    • 300 seconds (5 min) - Dynamic content${RESET}"
    echo -e "${CYAN}    • 3600 seconds (1 hour) - Standard${RESET}"
    echo -e "${CYAN}    • 86400 seconds (24 hours) - Static content${RESET}"

    press_continue

    # --- Hands-on Labs ---
    print_header "MODULE 5: HANDS-ON LABS" "DNS in Practice"

    run_hands_on \
        "DNS Lookup with nslookup" \
        "Resolve a domain name to its IP address." \
        "nslookup google.com 2>/dev/null || host google.com 2>/dev/null || dig google.com +short 2>/dev/null" \
        "This queries DNS servers to find google.com's IP address."

    run_hands_on \
        "Detailed DNS Query with dig" \
        "See the full DNS resolution with timing." \
        "dig google.com 2>/dev/null || nslookup -type=A google.com 2>/dev/null" \
        "dig shows the query, answer, authority, and timing information."

    run_hands_on \
        "Check MX Records (Mail Servers)" \
        "Find which servers handle email for a domain." \
        "dig MX gmail.com +short 2>/dev/null || nslookup -type=MX gmail.com 2>/dev/null" \
        "MX records show the mail servers and their priority numbers."

    run_hands_on \
        "Reverse DNS Lookup" \
        "Find the domain name for an IP address." \
        "dig -x 8.8.8.8 +short 2>/dev/null || nslookup 8.8.8.8 2>/dev/null" \
        "8.8.8.8 should resolve to dns.google - Google's public DNS."

    # --- Quiz ---
    print_header "MODULE 5: QUIZ" "Test Your Knowledge"

    run_quiz \
        "What does DNS stand for?" \
        "Digital Network System" \
        "Domain Name System" \
        "Data Network Service" \
        "Dynamic Naming Standard" \
        "B" \
        "DNS = Domain Name System. It translates human-readable domain names to IP addresses."

    run_quiz \
        "Which DNS record type maps a domain to an IPv4 address?" \
        "MX" \
        "CNAME" \
        "A" \
        "NS" \
        "C" \
        "The 'A' record (Address record) maps a domain name to an IPv4 address."

    run_quiz \
        "How many root DNS server clusters exist worldwide?" \
        "1" \
        "7" \
        "13" \
        "100" \
        "C" \
        "There are 13 root server clusters (A through M), operated by 12 different organizations."

    run_quiz \
        "What does TTL control in DNS?" \
        "How fast the query travels" \
        "How long a cached DNS record remains valid" \
        "How many hops a packet can make" \
        "The timeout for DNS connections" \
        "B" \
        "TTL (Time To Live) tells caches how many seconds to keep a DNS record before re-querying."

    run_true_false \
        "A CNAME record points a domain name to an IP address." \
        "F" \
        "A CNAME record points a domain name to ANOTHER domain name (an alias). The A record points to an IP."
}

#==============================================================================
#  MODULE 6: TCP, UDP & PACKET SWITCHING
#==============================================================================
module_6_tcp_udp() {
    print_header "MODULE 6: TCP, UDP & PACKET SWITCHING" "How Data Is Delivered Reliably"

    print_section "Packet Switching - The Core Concept"

    print_info "The internet uses PACKET SWITCHING, not circuit switching."
    print_info "Data is broken into small packets that travel independently."
    echo ""

    print_diagram "
    ${CYAN}  Circuit Switching (Old Phone Network):
    ┌────┐ ══════════════════════════════ ┌────┐
    │ A  │  Dedicated path, always open  │ B  │
    └────┘ ══════════════════════════════ └────┘
    (wastes bandwidth when not talking)

    Packet Switching (The Internet):
    ┌────┐                                ┌────┐
    │ A  │──→[P1]──→[R1]──→[R3]──→[P1]──→│ B  │
    └────┘──→[P2]──→[R2]──→[R4]──→[P3]──→└────┘
           ──→[P3]──→[R1]──→[R5]──→[P2]──→
    (packets take different paths, reassembled at destination)${RESET}"

    echo ""
    print_highlight "Packets can take DIFFERENT routes and arrive OUT OF ORDER!"
    print_highlight "TCP's job is to reassemble them correctly."

    press_continue

    # --- Section 6.1: Anatomy of a Packet ---
    print_header "MODULE 6.1: ANATOMY OF A PACKET" ""

    print_section "IP Packet Structure"

    print_diagram "
    ${CYAN}
    ┌─────────────────────────────────────────────────────────┐
    │                    IP HEADER (20 bytes)                  │
    ├─────────┬─────────┬─────────────────┬───────────────────┤
    │ Version │ Header  │ Type of Service │  Total Length      │
    │ (4 bits)│ Len(4b) │   (8 bits)      │   (16 bits)       │
    ├─────────┴─────────┼─────────────────┼───────────────────┤
    │  Identification    │ Flags (3b)      │ Fragment Offset   │
    │    (16 bits)       │                 │   (13 bits)       │
    ├────────────────────┼─────────────────┼───────────────────┤
    │  TTL (8 bits)      │ Protocol (8b)   │ Header Checksum   │
    │                    │ 6=TCP,17=UDP    │   (16 bits)       │
    ├────────────────────┴─────────────────┴───────────────────┤
    │              Source IP Address (32 bits)                  │
    ├──────────────────────────────────────────────────────────┤
    │           Destination IP Address (32 bits)               │
    ├──────────────────────────────────────────────────────────┤
    │                     DATA (payload)                       │
    │               (TCP/UDP segment goes here)                │
    └──────────────────────────────────────────────────────────┘${RESET}"

    press_continue

    # --- Section 6.2: TCP ---
    print_header "MODULE 6.2: TCP (Transmission Control Protocol)" "Reliable, Ordered Delivery"

    print_section "TCP Features"

    print_info "TCP provides:"
    echo -e "${CYAN}    ✓ Reliable delivery (retransmits lost packets)${RESET}"
    echo -e "${CYAN}    ✓ Ordered delivery (reassembles in correct order)${RESET}"
    echo -e "${CYAN}    ✓ Error checking (checksums)${RESET}"
    echo -e "${CYAN}    ✓ Flow control (prevents overwhelming receiver)${RESET}"
    echo -e "${CYAN}    ✓ Congestion control (prevents overwhelming network)${RESET}"
    echo ""

    print_subsection "The TCP 3-Way Handshake"
    print_info "Before data transfer, TCP establishes a connection:"

    print_diagram "
    ${CYAN}
      Client                              Server
        │                                    │
        │  ──── SYN (seq=100) ──────────→   │  Step 1: Client says
        │                                    │  \"I want to connect\"
        │                                    │
        │  ←── SYN-ACK (seq=300,ack=101) ── │  Step 2: Server says
        │                                    │  \"OK, I acknowledge\"
        │                                    │
        │  ──── ACK (ack=301) ──────────→   │  Step 3: Client says
        │                                    │  \"Great, let's go!\"
        │                                    │
        │  ═══ Connection Established ═══    │
        │                                    │
        │  ←──── Data Transfer ────────→     │
        │                                    │
        │  ──── FIN ────────────────────→    │  Closing:
        │  ←─── ACK ───────────────────     │  4-way handshake
        │  ←─── FIN ───────────────────     │  to terminate
        │  ──── ACK ────────────────────→    │
        │                                    │${RESET}"

    press_continue

    # --- TCP Sequence Numbers ---
    print_header "MODULE 6.2b: TCP RELIABILITY" "How TCP Ensures Data Integrity"

    print_section "Sequence Numbers & Acknowledgments"

    print_diagram "
    ${CYAN}
      Sender                                Receiver
        │                                      │
        │  ──── Seq=1, Data[bytes 1-100] ──→  │
        │  ──── Seq=101, Data[101-200] ────→  │
        │                                      │
        │  ←──── ACK=201 (got up to 200) ──── │
        │                                      │
        │  ──── Seq=201, Data[201-300] ────→  │
        │  ──── Seq=301, Data[301-400] ────→  │  ← LOST!
        │                                      │
        │  ←──── ACK=301 (missing 301+) ───── │
        │                                      │
        │  ──── Seq=301, Data[301-400] ────→  │  ← Retransmit!
        │                                      │
        │  ←──── ACK=401 (all good!) ──────── │${RESET}"

    echo ""
    print_info "TCP uses sliding windows for flow control:"
    print_info "The receiver advertises how much data it can buffer."
    print_info "This prevents the sender from overwhelming the receiver."

    press_continue

    # --- Section 6.3: UDP ---
    print_header "MODULE 6.3: UDP (User Datagram Protocol)" "Fast, Connectionless Delivery"

    print_section "UDP Features"

    print_info "UDP provides:"
    echo -e "${CYAN}    ✓ Fast delivery (no connection setup)${RESET}"
    echo -e "${CYAN}    ✓ Low overhead (small 8-byte header)${RESET}"
    echo -e "${CYAN}    ✗ NO reliability (packets may be lost)${RESET}"
    echo -e "${CYAN}    ✗ NO ordering (packets may arrive out of order)${RESET}"
    echo -e "${CYAN}    ✗ NO flow control${RESET}"
    echo ""

    print_info "UDP is \"fire and forget\" - send and hope it arrives!"
    echo ""

    print_diagram "
    ${CYAN}
      UDP Header (only 8 bytes!):
    ┌─────────────────────┬─────────────────────┐
    │ Source Port (16 bits)│ Dest Port (16 bits)  │
    ├─────────────────────┼─────────────────────┤
    │ Length (16 bits)     │ Checksum (16 bits)   │
    ├─────────────────────┴─────────────────────┤
    │              DATA (payload)                │
    └───────────────────────────────────────────┘

    vs TCP Header: 20 bytes minimum (much more overhead)${RESET}"

    press_continue

    # --- TCP vs UDP Comparison ---
    print_header "MODULE 6.4: TCP vs UDP" "Choosing the Right Protocol"

    print_diagram "
    ${CYAN}╔════════════════╦═══════════════════╦═══════════════════╗
    ║ Feature        ║ TCP               ║ UDP               ║
    ╠════════════════╬═══════════════════╬═══════════════════╣
    ║ Connection     ║ Connection-based  ║ Connectionless    ║
    ║ Reliability    ║ Guaranteed        ║ Not guaranteed    ║
    ║ Ordering       ║ In-order delivery ║ No ordering       ║
    ║ Speed          ║ Slower            ║ Faster            ║
    ║ Header Size    ║ 20-60 bytes       ║ 8 bytes           ║
    ║ Flow Control   ║ Yes               ║ No                ║
    ║ Error Recovery ║ Retransmission    ║ None              ║
    ╠════════════════╬═══════════════════╬═══════════════════╣
    ║ Used For:      ║ Web (HTTP/HTTPS)  ║ Video streaming   ║
    ║                ║ Email (SMTP)      ║ Online gaming     ║
    ║                ║ File transfer     ║ Voice/Video calls ║
    ║                ║ SSH               ║ DNS queries       ║
    ║                ║ Database queries  ║ IoT sensors       ║
    ╚════════════════╩═══════════════════╩═══════════════════╝${RESET}"

    press_continue

    # --- Section 6.5: Ports ---
    print_header "MODULE 6.5: PORT NUMBERS" "Directing Traffic to the Right Application"

    print_section "What Are Ports?"

    print_info "A port is a 16-bit number (0-65535) that identifies a"
    print_info "specific application or service on a device."
    echo ""
    print_example "IP address = apartment building, Port = apartment number"
    echo ""

    print_diagram "
    ${CYAN}  Common Port Numbers:
    ╔══════════╦════════════════════════════════════════╗
    ║ Port     ║ Service                                ║
    ╠══════════╬════════════════════════════════════════╣
    ║ 20, 21   ║ FTP (File Transfer Protocol)           ║
    ║ 22       ║ SSH (Secure Shell)                     ║
    ║ 23       ║ Telnet                                 ║
    ║ 25       ║ SMTP (Email sending)                   ║
    ║ 53       ║ DNS                                    ║
    ║ 80       ║ HTTP (Web traffic)                     ║
    ║ 110      ║ POP3 (Email receiving)                 ║
    ║ 143      ║ IMAP (Email)                           ║
    ║ 443      ║ HTTPS (Secure web traffic)             ║
    ║ 993      ║ IMAPS (Secure IMAP)                    ║
    ║ 3306     ║ MySQL Database                         ║
    ║ 5432     ║ PostgreSQL Database                    ║
    ║ 8080     ║ HTTP Alternate                         ║
    ╚══════════╩════════════════════════════════════════╝

    Port Ranges:
    • 0-1023:     Well-known ports (require root/admin)
    • 1024-49151: Registered ports (applications)
    • 49152-65535: Dynamic/Ephemeral ports (temporary)${RESET}"

    press_continue

    # --- Hands-on Labs ---
    print_header "MODULE 6: HANDS-ON LABS" "TCP/UDP in Practice"

    run_hands_on \
        "Test TCP Connection" \
        "Check if a TCP port is open on a remote server." \
        "echo 'Testing connection...' && (echo > /dev/tcp/google.com/443) 2>/dev/null && echo 'Port 443 is OPEN' || echo 'Port 443 is closed/filtered'" \
        "This tests if TCP port 443 (HTTPS) is open on google.com."

    run_hands_on \
        "See Active Network Connections" \
        "View all current TCP/UDP connections on your device." \
        "ss -tuln 2>/dev/null || netstat -tuln 2>/dev/null | head -20" \
        "This shows listening ports and active connections with protocol info."

    # --- Quiz ---
    print_header "MODULE 6: QUIZ" "Test Your Knowledge"

    run_quiz \
        "What is the TCP 3-way handshake sequence?" \
        "ACK → SYN → SYN-ACK" \
        "SYN → SYN-ACK → ACK" \
        "SYN → ACK → SYN-ACK" \
        "FIN → ACK → FIN-ACK" \
        "B" \
        "TCP connects with: SYN (client) → SYN-ACK (server) → ACK (client)."

    run_quiz \
        "Which protocol would you use for live video streaming?" \
        "TCP" \
        "UDP" \
        "FTP" \
        "SMTP" \
        "B" \
        "UDP is preferred for streaming because speed matters more than perfect delivery. A few lost frames are acceptable."

    run_quiz \
        "What port does HTTPS use by default?" \
        "80" \
        "8080" \
        "443" \
        "22" \
        "C" \
        "HTTPS uses port 443 by default. HTTP uses port 80."

    run_true_false \
        "UDP guarantees that packets arrive in the correct order." \
        "F" \
        "UDP provides NO ordering guarantee. Packets may arrive out of order, and it's up to the application to handle this."
}

#==============================================================================
#  MODULE 7: HTTP, HTTPS & WEB COMMUNICATION
#==============================================================================
module_7_http() {
    print_header "MODULE 7: HTTP & HTTPS" "The Language of the Web"

    print_section "What Is HTTP?"

    print_definition "HTTP (HyperText Transfer Protocol)" \
        "The protocol used for transferring web pages and resources"
    echo ""
    print_info "HTTP is a request-response protocol:"
    print_info "The client (browser) sends a REQUEST."
    print_info "The server sends back a RESPONSE."
    echo ""
    print_info "HTTP is stateless - each request is independent."
    print_info "(Cookies and sessions add state on top of HTTP.)"

    press_continue

    # --- Section 7.1: HTTP Methods ---
    print_header "MODULE 7.1: HTTP METHODS" "Types of Requests"

    print_section "HTTP Request Methods"

    print_diagram "
    ${CYAN}╔══════════╦════════════════════════════════════════════════╗
    ║ Method   ║ Purpose                                        ║
    ╠══════════╬════════════════════════════════════════════════╣
    ║ GET      ║ Retrieve a resource (web page, image, etc.)    ║
    ║          ║ Should not modify server data                  ║
    ╠══════════╬════════════════════════════════════════════════╣
    ║ POST     ║ Submit data to the server (forms, uploads)     ║
    ║          ║ Creates new resources                          ║
    ╠══════════╬════════════════════════════════════════════════╣
    ║ PUT      ║ Update/replace an entire resource              ║
    ╠══════════╬════════════════════════════════════════════════╣
    ║ PATCH    ║ Partially update a resource                    ║
    ╠══════════╬════════════════════════════════════════════════╣
    ║ DELETE   ║ Remove a resource                              ║
    ╠══════════╬════════════════════════════════════════════════╣
    ║ HEAD     ║ Like GET but returns only headers (no body)    ║
    ╠══════════╬════════════════════════════════════════════════╣
    ║ OPTIONS  ║ Discover allowed methods for a resource        ║
    ╚══════════╩════════════════════════════════════════════════╝${RESET}"

    press_continue

    # --- Section 7.2: HTTP Request/Response ---
    print_header "MODULE 7.2: HTTP REQUEST & RESPONSE" "The Conversation Format"

    print_section "HTTP Request Format"

    print_diagram "
    ${CYAN}  ┌─── HTTP Request ─────────────────────────────────────┐
    │                                                       │
    │  GET /search?q=hello HTTP/1.1        ← Request Line   │
    │  Host: www.google.com                ← Required Header │
    │  User-Agent: Mozilla/5.0             ← Browser Info    │
    │  Accept: text/html                   ← Accepted Types  │
    │  Accept-Language: en-US              ← Language Pref    │
    │  Connection: keep-alive              ← Keep Connected   │
    │  Cookie: session=abc123              ← Cookies          │
    │                                      ← Empty Line       │
    │  (optional body for POST/PUT)        ← Body            │
    │                                                       │
    └───────────────────────────────────────────────────────┘${RESET}"

    echo ""

    print_section "HTTP Response Format"

    print_diagram "
    ${CYAN}  ┌─── HTTP Response ────────────────────────────────────┐
    │                                                       │
    │  HTTP/1.1 200 OK                     ← Status Line     │
    │  Date: Mon, 01 Jan 2024 12:00:00     ← Timestamp      │
    │  Content-Type: text/html; utf-8      ← Content Info    │
    │  Content-Length: 5432                 ← Size in bytes   │
    │  Server: gws                         ← Server Software │
    │  Set-Cookie: id=abc; Path=/          ← Set Cookie      │
    │  Cache-Control: max-age=3600         ← Caching Rules   │
    │                                      ← Empty Line       │
    │  <!DOCTYPE html>                     ← Response Body   │
    │  <html>                              │                 │
    │    <head><title>Google</title></head> │                 │
    │    <body>...</body>                   │                 │
    │  </html>                             │                 │
    │                                                       │
    └───────────────────────────────────────────────────────┘${RESET}"

    press_continue

    # --- Section 7.3: Status Codes ---
    print_header "MODULE 7.3: HTTP STATUS CODES" "Server Response Indicators"

    print_section "Status Code Categories"

    print_diagram "
    ${CYAN}╔═══════╦═══════════════╦══════════════════════════════════╗
    ║ Code  ║ Category      ║ Meaning                          ║
    ╠═══════╬═══════════════╬══════════════════════════════════╣
    ║ 1xx   ║ Informational ║ Request received, processing      ║
    ╠═══════╬═══════════════╬══════════════════════════════════╣
    ║ 2xx   ║ Success       ║ Request successfully processed    ║
    ║ 200   ║               ║ OK - Standard success             ║
    ║ 201   ║               ║ Created - Resource created        ║
    ║ 204   ║               ║ No Content - Success, empty body  ║
    ╠═══════╬═══════════════╬══════════════════════════════════╣
    ║ 3xx   ║ Redirection   ║ Further action needed             ║
    ║ 301   ║               ║ Moved Permanently                 ║
    ║ 302   ║               ║ Found (Temporary Redirect)        ║
    ║ 304   ║               ║ Not Modified (use cache)          ║
    ╠═══════╬═══════════════╬══════════════════════════════════╣
    ║ 4xx   ║ Client Error  ║ Problem with the request          ║
    ║ 400   ║               ║ Bad Request                       ║
    ║ 401   ║               ║ Unauthorized (need login)         ║
    ║ 403   ║               ║ Forbidden (not allowed)           ║
    ║ 404   ║               ║ Not Found (page doesn't exist)    ║
    ║ 429   ║               ║ Too Many Requests (rate limit)    ║
    ╠═══════╬═══════════════╬══════════════════════════════════╣
    ║ 5xx   ║ Server Error  ║ Server failed to fulfill request  ║
    ║ 500   ║               ║ Internal Server Error             ║
    ║ 502   ║               ║ Bad Gateway                       ║
    ║ 503   ║               ║ Service Unavailable               ║
    ║ 504   ║               ║ Gateway Timeout                   ║
    ╚═══════╩═══════════════╩══════════════════════════════════╝${RESET}"

    press_continue

    # --- Section 7.4: HTTPS ---
    print_header "MODULE 7.4: HTTPS" "Secure HTTP Communication"

    print_section "HTTP vs HTTPS"

    print_info "HTTPS = HTTP + TLS (Transport Layer Security)"
    print_info "All data is encrypted between client and server."
    echo ""

    print_diagram "
    ${CYAN}  HTTP (Insecure):
    ┌────────┐    Plain text data     ┌────────┐
    │ Client │ ←───────────────────→  │ Server │
    └────────┘  Anyone can read it!   └────────┘
                  🔓 Password: abc123
                  (visible to attackers)

    HTTPS (Secure):
    ┌────────┐    Encrypted data      ┌────────┐
    │ Client │ ←───────────────────→  │ Server │
    └────────┘  🔒 Only endpoints    └────────┘
                  can read it!
                  x#j@k!9&mP2...
                  (gibberish to attackers)${RESET}"

    echo ""
    print_info "HTTPS provides:"
    echo -e "${GREEN}    🔒 Encryption - Data cannot be read by eavesdroppers${RESET}"
    echo -e "${GREEN}    ✅ Authentication - Proves the server is who it claims${RESET}"
    echo -e "${GREEN}    🛡  Integrity - Data cannot be tampered with in transit${RESET}"

    press_continue

    # --- Section 7.5: HTTP Versions ---
    print_header "MODULE 7.5: HTTP VERSIONS" "Evolution of HTTP"

    print_diagram "
    ${CYAN}
    HTTP/1.0 (1996):
    • One request per connection
    • Close connection after each response
    • Very inefficient

    HTTP/1.1 (1997):
    • Keep-alive connections (reuse connections)
    • Chunked transfer encoding
    • Host header (virtual hosting)
    • Still one request at a time per connection

    HTTP/2 (2015):
    • Multiplexing (multiple requests on one connection)
    • Binary protocol (not text)
    • Header compression (HPACK)
    • Server push (send resources before client asks)
    • Stream prioritization

    HTTP/3 (2022):
    • Uses QUIC (built on UDP instead of TCP!)
    • Faster connection establishment
    • Better performance on unreliable networks
    • Built-in encryption
    • Eliminates head-of-line blocking${RESET}"

    press_continue

    # --- Hands-on Labs ---
    print_header "MODULE 7: HANDS-ON LABS" "HTTP in Practice"

    run_hands_on \
        "Make an HTTP Request with curl" \
        "Send a GET request and see the response headers." \
        "curl -I https://www.google.com 2>/dev/null | head -20" \
        "The -I flag shows only response headers (HEAD request)."

    run_hands_on \
        "See Full HTTP Request/Response" \
        "Verbose output showing the complete HTTP conversation." \
        "curl -v https://example.com 2>&1 | head -40" \
        "Lines starting with > are sent (request), < are received (response)."

    run_hands_on \
        "Check HTTP Status Code" \
        "Get just the status code from a request." \
        "curl -o /dev/null -s -w 'Status Code: %{http_code}\nResponse Time: %{time_total}s\nProtocol: %{scheme}\n' https://www.google.com" \
        "This shows the HTTP status code, time, and protocol used."

    run_hands_on \
        "Test a 404 Error" \
        "Request a page that doesn't exist." \
        "curl -o /dev/null -s -w 'Status: %{http_code}\n' https://www.google.com/this-page-does-not-exist-12345" \
        "You should get a 404 Not Found status code."

    # --- Quiz ---
    print_header "MODULE 7: QUIZ" "Test Your Knowledge"

    run_quiz \
        "What HTTP status code means 'Not Found'?" \
        "200" \
        "301" \
        "404" \
        "500" \
        "C" \
        "404 Not Found means the requested resource doesn't exist on the server."

    run_quiz \
        "Which HTTP method is used to submit form data?" \
        "GET" \
        "POST" \
        "DELETE" \
        "HEAD" \
        "B" \
        "POST is used to submit data (forms, uploads). GET retrieves data."

    run_quiz \
        "What does the S in HTTPS stand for?" \
        "Standard" \
        "System" \
        "Secure" \
        "Server" \
        "C" \
        "HTTPS = HyperText Transfer Protocol Secure. It uses TLS for encryption."

    run_quiz \
        "What major improvement did HTTP/2 introduce?" \
        "Encryption" \
        "Multiplexing - multiple requests on one connection" \
        "JSON support" \
        "Cookie support" \
        "B" \
        "HTTP/2's key feature is multiplexing, allowing multiple requests/responses simultaneously over one connection."
}

#==============================================================================
#  MODULE 8: ROUTING
#==============================================================================
module_8_routing() {
    print_header "MODULE 8: ROUTING" "How Data Finds Its Way Across the Internet"

    print_section "What Is Routing?"

    print_info "Routing is the process of selecting the best path for"
    print_info "data packets to travel from source to destination."
    print_info "Routers examine each packet's destination IP and forward"
    print_info "it toward the next hop on the best available path."

    press_continue

    # --- Section 8.1: How Routing Works ---
    print_header "MODULE 8.1: ROUTING FUNDAMENTALS" ""

    print_section "Routing Table"

    print_info "Every router maintains a routing table - a map of known"
    print_info "networks and how to reach them."
    echo ""

    print_diagram "
    ${CYAN}  Example Routing Table:
    ╔══════════════════╦════════════════╦═══════════╦═════════╗
    ║ Destination      ║ Gateway        ║ Interface ║ Metric  ║
    ╠══════════════════╬════════════════╬═══════════╬═════════╣
    ║ 192.168.1.0/24   ║ 0.0.0.0        ║ eth0      ║ 0       ║
    ║ 10.0.0.0/8       ║ 192.168.1.1    ║ eth0      ║ 10      ║
    ║ 172.16.0.0/16    ║ 192.168.1.254  ║ eth0      ║ 20      ║
    ║ 0.0.0.0/0        ║ 192.168.1.1    ║ eth0      ║ 100     ║
    ╚══════════════════╩════════════════╩═══════════╩═════════╝

    • Destination: Network address to match against
    • Gateway: Next router to forward to
    • Interface: Physical port to send through
    • Metric: Cost/priority (lower = preferred)
    • 0.0.0.0/0: Default route (catch-all)${RESET}"

    press_continue

    # --- Section 8.2: Routing Diagram ---
    print_header "MODULE 8.2: ROUTING IN ACTION" "A Packet's Journey"

    print_diagram "
    ${CYAN}
    Your Phone          Your Router          ISP Router
    192.168.1.50        192.168.1.1          10.0.0.1
    ┌──────┐            ┌──────┐             ┌──────┐
    │      │──Packet──→ │      │──Packet──→  │      │
    │ 📱   │            │  📡  │             │  🏢  │
    └──────┘            └──────┘             └──┬───┘
                                                │
                        Regional Router         │
                        172.16.0.1              │
                        ┌──────┐               │
                        │      │←──Packet──────┘
                        │  🌐  │
                        └──┬───┘
                           │
        Internet Backbone  │      Destination's ISP
        (Tier 1)           │      ┌──────┐
        ┌──────┐           │      │      │
        │      │←──────────┘ ──→  │  🏢  │
        │  🌍  │                  └──┬───┘
        └──────┘                     │
                                     │
                              Google's Server
                              142.250.80.46
                              ┌──────┐
                              │      │
                              │  🖥   │
                              └──────┘

    Each router makes an independent forwarding decision
    based on its own routing table!${RESET}"

    press_continue

    # --- Section 8.3: Routing Protocols ---
    print_header "MODULE 8.3: ROUTING PROTOCOLS" "How Routers Learn Routes"

    print_section "Interior vs Exterior Routing"

    print_info "Routing protocols are divided into two categories:"
    echo ""
    echo -e "${YELLOW}  Interior Gateway Protocols (IGP) - Within an organization:${RESET}"
    echo -e "${CYAN}    • RIP  - Simple, distance-based (hop count)${RESET}"
    echo -e "${CYAN}    • OSPF - Complex, uses link state & cost metrics${RESET}"
    echo -e "${CYAN}    • EIGRP - Cisco proprietary, hybrid approach${RESET}"
    echo -e "${CYAN}    • IS-IS - Similar to OSPF, used by large ISPs${RESET}"
    echo ""
    echo -e "${YELLOW}  Exterior Gateway Protocol (EGP) - Between organizations:${RESET}"
    echo -e "${CYAN}    • BGP (Border Gateway Protocol) - THE routing protocol${RESET}"
    echo -e "${CYAN}      of the internet. Connects all autonomous systems.${RESET}"
    echo ""

    print_highlight "BGP is the 'glue' that holds the internet together!"
    print_info "Every ISP, tech company, and organization uses BGP to"
    print_info "announce their networks and learn about others."

    press_continue

    # --- Section 8.4: Traceroute ---
    print_header "MODULE 8.4: TRACEROUTE" "Mapping the Path of Packets"

    print_section "How Traceroute Works"

    print_info "Traceroute sends packets with increasing TTL values."
    print_info "Each router decrements TTL by 1. When TTL reaches 0,"
    print_info "the router sends back an ICMP 'Time Exceeded' message."
    echo ""

    print_diagram "
    ${CYAN}  Traceroute Mechanism:

    Packet 1: TTL=1
    [You] ──→ [Router 1] ──✗ TTL expired! Router 1 replies.

    Packet 2: TTL=2
    [You] ──→ [Router 1] ──→ [Router 2] ──✗ TTL expired!

    Packet 3: TTL=3
    [You] ──→ [Router 1] ──→ [Router 2] ──→ [Router 3] ──✗

    Packet N: TTL=N
    [You] ──→ ... ──→ [Destination] ──→ Reply received!

    Result: You discover every router hop along the path!${RESET}"

    press_continue

    # --- Hands-on Labs ---
    print_header "MODULE 8: HANDS-ON LABS" "Routing in Practice"

    run_hands_on \
        "View Your Routing Table" \
        "See the routing table on your device." \
        "ip route show 2>/dev/null || route -n 2>/dev/null" \
        "The default route (0.0.0.0/0) is your gateway - usually your WiFi router."

    run_hands_on \
        "Traceroute to Google" \
        "Map the path packets take to reach Google." \
        "traceroute -m 15 google.com 2>/dev/null || tracepath google.com 2>/dev/null | head -20" \
        "Each line is a router hop. Stars (***) mean the router didn't respond."

    run_hands_on \
        "Ping Test - Measure Latency" \
        "Send ICMP echo requests to measure round-trip time." \
        "ping -c 5 google.com 2>/dev/null || ping -c 5 8.8.8.8 2>/dev/null" \
        "The time values show round-trip latency in milliseconds."

    # --- Quiz ---
    print_header "MODULE 8: QUIZ" "Test Your Knowledge"

    run_quiz \
        "What does BGP stand for?" \
        "Basic Gateway Protocol" \
        "Border Gateway Protocol" \
        "Binary Graph Protocol" \
        "Bandwidth Generation Protocol" \
        "B" \
        "BGP (Border Gateway Protocol) is the routing protocol that connects autonomous systems across the internet."

    run_quiz \
        "What does TTL do in routing?" \
        "Encrypts the packet" \
        "Limits how many hops a packet can make before being discarded" \
        "Speeds up the packet" \
        "Assigns a priority level" \
        "B" \
        "TTL (Time To Live) is decremented at each hop. When it reaches 0, the packet is discarded. This prevents infinite routing loops."

    run_true_false \
        "Every router along a packet's path makes its own independent forwarding decision." \
        "T" \
        "Each router independently examines the destination IP and consults its own routing table to decide the next hop."
}

#==============================================================================
#  MODULE 9: ENCRYPTION, TLS & SECURITY
#==============================================================================
module_9_security() {
    print_header "MODULE 9: ENCRYPTION, TLS & SECURITY" "Keeping Data Safe on the Internet"

    print_section "Why Security Matters"

    print_info "Without encryption, anyone on the network path can:"
    echo -e "${RED}    • Read your passwords and messages${RESET}"
    echo -e "${RED}    • Steal your credit card numbers${RESET}"
    echo -e "${RED}    • Modify data in transit${RESET}"
    echo -e "${RED}    • Impersonate websites${RESET}"

    press_continue

    # --- Section 9.1: Types of Encryption ---
    print_header "MODULE 9.1: TYPES OF ENCRYPTION" ""

    print_section "Symmetric vs Asymmetric Encryption"

    print_diagram "
    ${CYAN}  SYMMETRIC ENCRYPTION (Same Key):

    ┌────────┐   Same Key🔑   ┌────────┐
    │ Sender │ ──────────────→│Receiver│
    └───┬────┘                └───┬────┘
        │                         │
    \"Hello\" ──→ 🔑 ──→ \"x#j@k\" ──→ 🔑 ──→ \"Hello\"
    (plaintext)    (ciphertext)      (plaintext)

    • Examples: AES-256, ChaCha20
    • Fast, efficient
    • Problem: How to share the key securely?


    ASYMMETRIC ENCRYPTION (Key Pair):

    ┌────────┐                    ┌────────┐
    │ Sender │                    │Receiver│
    └───┬────┘                    └───┬────┘
        │                             │
        │  Receiver's PUBLIC Key 🔓   │
        │  (shared openly)            │
        │         │                   │
    \"Hello\" ──→ 🔓 ──→ \"x#j@k\" ──→ 🔐 ──→ \"Hello\"
                          Only the PRIVATE key 🔐
                          can decrypt it!

    • Examples: RSA, ECC, Ed25519
    • Slower but solves key exchange problem
    • Public key encrypts, Private key decrypts${RESET}"

    press_continue

    # --- Section 9.2: TLS Handshake ---
    print_header "MODULE 9.2: TLS HANDSHAKE" "How HTTPS Connections Are Established"

    print_section "TLS 1.3 Handshake (Simplified)"

    print_diagram "
    ${CYAN}
    Browser                                    Server
       │                                          │
       │  1. CLIENT HELLO                         │
       │  ─ Supported TLS versions                │
       │  ─ Supported cipher suites               │
       │  ─ Client random number                  │
       │  ─ Key share (for key exchange)           │
       │ ────────────────────────────────────────→ │
       │                                          │
       │  2. SERVER HELLO                         │
       │  ─ Chosen TLS version                    │
       │  ─ Chosen cipher suite                   │
       │  ─ Server random number                  │
       │  ─ Key share                             │
       │  ─ Certificate (proving identity) 📜      │
       │  ─ Certificate Verify (signature)        │
       │  ─ Finished                              │
       │ ←──────────────────────────────────────── │
       │                                          │
       │  3. Browser verifies certificate 🔍       │
       │  ─ Is it signed by trusted CA?           │
       │  ─ Is the domain name correct?           │
       │  ─ Has it expired?                       │
       │                                          │
       │  4. FINISHED                             │
       │  ─ Both sides derive session key 🔑       │
       │ ────────────────────────────────────────→ │
       │                                          │
       │  ═══ Encrypted Communication ═══ 🔒      │
       │ ←══════════════════════════════════════→  │${RESET}"

    press_continue

    # --- Section 9.3: Certificates ---
    print_header "MODULE 9.3: SSL/TLS CERTIFICATES" "Proving Website Identity"

    print_section "Certificate Chain of Trust"

    print_info "Digital certificates prove a website is legitimate."
    print_info "They're issued by trusted Certificate Authorities (CAs)."
    echo ""

    print_diagram "
    ${CYAN}
    Chain of Trust:

    ┌─────────────────────────┐
    │   ROOT CA Certificate   │  Pre-installed in your
    │   (e.g., DigiCert)      │  browser/OS (trusted)
    └────────────┬────────────┘
                 │ signs
    ┌────────────▼────────────┐
    │  Intermediate CA Cert   │
    │  (e.g., DigiCert SHA2) │
    └────────────┬────────────┘
                 │ signs
    ┌────────────▼────────────┐
    │  Website Certificate    │
    │  (e.g., *.google.com)  │
    │                         │
    │  Contains:              │
    │  • Domain name          │
    │  • Public key           │
    │  • Issuer name          │
    │  • Validity dates       │
    │  • Digital signature    │
    └─────────────────────────┘${RESET}"

    echo ""
    print_info "Popular Certificate Authorities:"
    echo -e "${CYAN}    • Let's Encrypt (free, automated)${RESET}"
    echo -e "${CYAN}    • DigiCert, Sectigo, GlobalSign${RESET}"
    echo -e "${CYAN}    • Google Trust Services${RESET}"

    press_continue

    # --- Section 9.4: Common Attacks ---
    print_header "MODULE 9.4: COMMON NETWORK ATTACKS" "Threats to Internet Security"

    print_section "Attack Types"

    print_definition "Man-in-the-Middle (MITM)" \
        "Attacker intercepts communication between two parties"
    echo ""
    print_definition "DNS Spoofing/Poisoning" \
        "Attacker corrupts DNS cache to redirect users to fake sites"
    echo ""
    print_definition "DDoS (Distributed Denial of Service)" \
        "Overwhelm a server with massive traffic from many sources"
    echo ""
    print_definition "Phishing" \
        "Fake websites/emails that trick users into revealing credentials"
    echo ""
    print_definition "SQL Injection" \
        "Inserting malicious code through input fields to access databases"
    echo ""
    print_definition "Cross-Site Scripting (XSS)" \
        "Injecting malicious scripts into web pages viewed by others"

    press_continue

    # --- Hands-on Labs ---
    print_header "MODULE 9: HANDS-ON LABS" "Security in Practice"

    run_hands_on \
        "Inspect SSL Certificate" \
        "View the TLS certificate details for a website." \
        "echo | openssl s_client -connect google.com:443 -servername google.com 2>/dev/null | openssl x509 -noout -subject -issuer -dates 2>/dev/null" \
        "This shows the certificate's subject (domain), issuer (CA), and validity dates."

    run_hands_on \
        "Check TLS Version" \
        "See which TLS version a site supports." \
        "curl -v --tlsv1.3 https://www.google.com 2>&1 | grep -i 'ssl\\|tls\\|protocol' | head -5" \
        "Modern sites should support TLS 1.3 for the best security."

    run_hands_on \
        "Test SSL/TLS Ciphers" \
        "See the cipher suite negotiated with a server." \
        "echo | openssl s_client -connect google.com:443 2>/dev/null | grep 'Cipher'" \
        "The cipher suite determines the encryption algorithm used."

    # --- Quiz ---
    print_header "MODULE 9: QUIZ" "Test Your Knowledge"

    run_quiz \
        "What type of encryption uses the same key for encryption and decryption?" \
        "Asymmetric" \
        "Symmetric" \
        "Hashing" \
        "Public key" \
        "B" \
        "Symmetric encryption uses ONE shared key for both encrypting and decrypting."

    run_quiz \
        "What does a TLS certificate prove?" \
        "The server's speed" \
        "The website's identity and enables encryption" \
        "The user's identity" \
        "The ISP's reliability" \
        "B" \
        "TLS certificates verify the server's identity (you're really talking to google.com) and provide the public key for encryption."

    run_quiz \
        "Which organization provides free TLS certificates?" \
        "Google" \
        "Microsoft" \
        "Let's Encrypt" \
        "Amazon" \
        "C" \
        "Let's Encrypt is a free, automated CA that has issued billions of certificates."

    run_true_false \
        "HTTPS prevents all types of cyber attacks." \
        "F" \
        "HTTPS protects data in transit but doesn't prevent phishing, server-side attacks, malware, or social engineering."
}

#==============================================================================
#  MODULE 10: EMAIL, FTP & OTHER PROTOCOLS
#==============================================================================
module_10_protocols() {
    print_header "MODULE 10: EMAIL, FTP & OTHER PROTOCOLS" "Beyond the Web"

    print_section "The Internet Is More Than Websites"

    print_info "HTTP/HTTPS is just one of many internet protocols."
    print_info "Let's explore the others that power the internet."

    press_continue

    # --- Section 10.1: Email ---
    print_header "MODULE 10.1: HOW EMAIL WORKS" "The Journey of an Email"

    print_section "Email Protocols"

    print_diagram "
    ${CYAN}
    Sending an Email:

    ┌───────────┐    SMTP     ┌───────────┐    SMTP     ┌───────────┐
    │  You      │ ──────────→ │  Your     │ ──────────→ │ Recipient │
    │  (Gmail)  │  Port 587   │  Mail     │  Port 25    │  Mail     │
    │           │  (submit)   │  Server   │             │  Server   │
    └───────────┘             └───────────┘             └─────┬─────┘
                                                              │
    Receiving an Email:                                       │
                                                              ↓
    ┌───────────┐  IMAP/POP3  ┌───────────┐             ┌─────┴─────┐
    │ Recipient │ ←────────── │ Recipient │             │  Mailbox  │
    │  (Phone)  │  Port 993   │  Mail     │ ←────────── │  Storage  │
    │           │  (IMAPS)    │  Server   │             │           │
    └───────────┘             └───────────┘             └───────────┘${RESET}"

    echo ""
    print_subsection "Email Protocol Summary"
    echo -e "${CYAN}    SMTP (Simple Mail Transfer Protocol):${RESET}"
    print_info "    Used for SENDING email. Port 25 (relay), 587 (submit)"
    echo ""
    echo -e "${CYAN}    IMAP (Internet Message Access Protocol):${RESET}"
    print_info "    Used for READING email. Keeps mail on server. Port 993"
    echo ""
    echo -e "${CYAN}    POP3 (Post Office Protocol v3):${RESET}"
    print_info "    Used for READING email. Downloads & deletes from server. Port 995"

    press_continue

    # --- Section 10.2: Other Protocols ---
    print_header "MODULE 10.2: OTHER IMPORTANT PROTOCOLS" ""

    print_section "Protocol Reference"

    print_diagram "
    ${CYAN}╔════════════╦══════╦═══════════════════════════════════════╗
    ║ Protocol   ║ Port ║ Purpose                               ║
    ╠════════════╬══════╬═══════════════════════════════════════╣
    ║ SSH        ║ 22   ║ Secure remote terminal access          ║
    ║ FTP        ║ 21   ║ File transfer (legacy, insecure)       ║
    ║ SFTP       ║ 22   ║ Secure file transfer (over SSH)        ║
    ║ DHCP       ║ 67/68║ Automatic IP address assignment        ║
    ║ NTP        ║ 123  ║ Network Time Protocol (clock sync)     ║
    ║ SNMP       ║ 161  ║ Network device monitoring              ║
    ║ LDAP       ║ 389  ║ Directory services (user lookups)      ║
    ║ RDP        ║ 3389 ║ Remote Desktop (Windows)               ║
    ║ SIP        ║ 5060 ║ Voice/Video call signaling             ║
    ║ MQTT       ║ 1883 ║ IoT messaging protocol                 ║
    ║ WebSocket  ║ 80/443║ Full-duplex web communication         ║
    ╚════════════╩══════╩═══════════════════════════════════════╝${RESET}"

    press_continue

    # --- Section 10.3: DHCP ---
    print_header "MODULE 10.3: DHCP" "Automatic IP Address Assignment"

    print_section "How Your Device Gets an IP Address"

    print_diagram "
    ${CYAN}
    DHCP Process (DORA):

    Your Device                           DHCP Server (Router)
        │                                        │
        │  1. DISCOVER (broadcast)               │
        │  \"I need an IP address!\"               │
        │ ──────────────────────────────────────→ │
        │                                        │
        │  2. OFFER                               │
        │  \"How about 192.168.1.50?\"             │
        │ ←────────────────────────────────────── │
        │                                        │
        │  3. REQUEST                             │
        │  \"Yes, I'll take 192.168.1.50!\"        │
        │ ──────────────────────────────────────→ │
        │                                        │
        │  4. ACKNOWLEDGE                         │
        │  \"It's yours for 24 hours!\"            │
        │ ←────────────────────────────────────── │
        │                                        │
        │  DHCP also provides:                    │
        │  • Subnet mask: 255.255.255.0          │
        │  • Default gateway: 192.168.1.1        │
        │  • DNS servers: 8.8.8.8, 8.8.4.4      │
        │  • Lease time: 86400 seconds           │${RESET}"

    press_continue

    # --- Section 10.4: ARP ---
    print_header "MODULE 10.4: ARP" "Address Resolution Protocol"

    print_section "Mapping IP Addresses to MAC Addresses"

    print_info "ARP converts IP addresses to MAC (hardware) addresses"
    print_info "within a local network."
    echo ""

    print_diagram "
    ${CYAN}
    Your Device:  \"I need to send to 192.168.1.1, but what's its MAC?\"

    ┌──────────┐  ARP Request (broadcast)     ┌──────────┐
    │ Your PC  │ ──────────────────────────→   │  Router  │
    │          │  \"Who has 192.168.1.1?\"      │          │
    │ MAC: AA  │                               │ MAC: BB  │
    │ IP: .50  │  ARP Reply (unicast)          │ IP: .1   │
    │          │ ←──────────────────────────    │          │
    │          │  \"192.168.1.1 is at MAC BB\"  │          │
    └──────────┘                               └──────────┘

    Your device stores this in its ARP cache for future use.${RESET}"

    press_continue

    # --- Hands-on Labs ---
    print_header "MODULE 10: HANDS-ON LABS" "Protocols in Practice"

    run_hands_on \
        "SSH Connection Test" \
        "Check if SSH port is open on a host." \
        "echo 'Testing SSH port...' && timeout 3 bash -c 'echo > /dev/tcp/github.com/22' 2>/dev/null && echo 'SSH port 22 is OPEN on github.com' || echo 'Cannot reach SSH on github.com'" \
        "SSH (port 22) is used for secure remote access to servers."

    run_hands_on \
        "Check Your ARP Cache" \
        "See the ARP table mapping IPs to MAC addresses." \
        "ip neigh show 2>/dev/null || arp -a 2>/dev/null | head -10" \
        "This shows IP-to-MAC address mappings for devices on your local network."

    # --- Quiz ---
    print_header "MODULE 10: QUIZ" "Test Your Knowledge"

    run_quiz \
        "Which protocol is used to SEND email?" \
        "POP3" \
        "IMAP" \
        "SMTP" \
        "HTTP" \
        "C" \
        "SMTP (Simple Mail Transfer Protocol) is used for sending email between servers."

    run_quiz \
        "What does DHCP provide to devices?" \
        "Website content" \
        "Automatic IP address, subnet mask, gateway, and DNS" \
        "Encryption keys" \
        "File storage" \
        "B" \
        "DHCP automatically configures network settings so you don't have to set them manually."

    run_quiz \
        "What does ARP resolve?" \
        "Domain names to IP addresses" \
        "IP addresses to MAC addresses" \
        "Ports to services" \
        "URLs to file paths" \
        "B" \
        "ARP (Address Resolution Protocol) maps IP addresses to physical MAC addresses on a local network."
}

#==============================================================================
#  MODULE 11: CDNs, CACHING & PERFORMANCE
#==============================================================================
module_11_cdn_performance() {
    print_header "MODULE 11: CDNs, CACHING & PERFORMANCE" "Making the Internet Fast"

    print_section "The Speed Problem"

    print_info "Light travels at ~200,000 km/s through fiber."
    print_info "New York to Tokyo = ~10,000 km = ~50ms one way."
    print_info "That means ~100ms minimum round-trip time."
    print_info "Users expect pages to load in under 2 seconds!"

    press_continue

    # --- Section 11.1: CDNs ---
    print_header "MODULE 11.1: CONTENT DELIVERY NETWORKS" "Bringing Content Closer to Users"

    print_section "What Is a CDN?"

    print_definition "CDN (Content Delivery Network)" \
        "A geographically distributed network of servers that caches content close to users"
    echo ""

    print_diagram "
    ${CYAN}
    WITHOUT CDN:
    ┌──────────┐                              ┌──────────┐
    │ User in  │ ─────── 15,000 km ──────────→│ Server   │
    │ Tokyo    │         (150ms RTT)           │ New York │
    └──────────┘                              └──────────┘
                    Slow! Every request travels far.

    WITH CDN:
    ┌──────────┐     ┌──────────────┐         ┌──────────┐
    │ User in  │ ──→ │ CDN Edge     │         │ Origin   │
    │ Tokyo    │     │ Server Tokyo │         │ Server   │
    └──────────┘     └──────┬───────┘         │ New York │
                   500 km   │                  └──────────┘
                   (5ms!)   │
                            │ Cache miss? Fetch from origin
                            └─────────────────────────────→

    Major CDN Providers:
    • Cloudflare  (300+ cities)
    • AWS CloudFront
    • Akamai      (4,100+ locations)
    • Fastly
    • Google Cloud CDN${RESET}"

    echo ""
    print_info "CDNs cache: Images, CSS, JavaScript, Videos, API responses"
    print_info "CDNs also provide: DDoS protection, WAF, load balancing"

    press_continue

    # --- Section 11.2: Caching ---
    print_header "MODULE 11.2: CACHING LAYERS" "Multiple Levels of Speed"

    print_section "The Caching Hierarchy"

    print_diagram "
    ${CYAN}
    Request: GET /image.jpg

    Level 1: Browser Cache (RAM/Disk)
    ┌──────────────┐
    │ 🖥 Browser    │  Cache-Control: max-age=3600
    │ Have it?     │──→ YES: Use cached version (instant!)
    │              │──→ NO: Go to next level ↓
    └──────────────┘

    Level 2: OS/System Cache
    ┌──────────────┐
    │ 💻 OS Cache   │  DNS cache, connection pool
    │ Have it?     │──→ YES: Return cached (microseconds)
    │              │──→ NO: Go to next level ↓
    └──────────────┘

    Level 3: CDN Edge Cache
    ┌──────────────┐
    │ 🌐 CDN Edge   │  Closest geographic server
    │ Have it?     │──→ YES: Return cached (5-20ms)
    │              │──→ NO: Go to next level ↓
    └──────────────┘

    Level 4: Reverse Proxy/Load Balancer
    ┌──────────────┐
    │ ⚖️ Proxy      │  Nginx, Varnish, HAProxy
    │ Have it?     │──→ YES: Return cached (20-50ms)
    │              │──→ NO: Go to next level ↓
    └──────────────┘

    Level 5: Application Cache
    ┌──────────────┐
    │ 📦 App Cache  │  Redis, Memcached
    │ Have it?     │──→ YES: Return cached (1-5ms)
    │              │──→ NO: Query database ↓
    └──────────────┘

    Level 6: Database
    ┌──────────────┐
    │ 🗃 Database   │  The source of truth
    │              │──→ Query and return (10-100ms)
    └──────────────┘${RESET}"

    press_continue

    # --- Section 11.3: HTTP Caching Headers ---
    print_header "MODULE 11.3: HTTP CACHING HEADERS" ""

    print_section "Cache-Control Header"

    print_diagram "
    ${CYAN}╔══════════════════════════╦════════════════════════════════╗
    ║ Directive                ║ Meaning                        ║
    ╠══════════════════════════╬════════════════════════════════╣
    ║ max-age=3600             ║ Cache for 3600 seconds (1 hr)  ║
    ║ no-cache                 ║ Must revalidate before using   ║
    ║ no-store                 ║ Never cache (sensitive data)   ║
    ║ public                   ║ Any cache can store it         ║
    ║ private                  ║ Only browser cache (not CDN)   ║
    ║ must-revalidate          ║ Check with server when expired ║
    ║ immutable                ║ Never changes (cache forever)  ║
    ╚══════════════════════════╩════════════════════════════════╝

    Example Response Headers:
    Cache-Control: public, max-age=31536000, immutable
    (Cache for 1 year, it never changes - used for versioned assets)

    Cache-Control: no-store
    (Never cache - used for banking/personal data)${RESET}"

    press_continue

    # --- Section 11.4: Load Balancing ---
    print_header "MODULE 11.4: LOAD BALANCING" "Distributing Traffic Across Servers"

    print_section "Load Balancing Strategies"

    print_diagram "
    ${CYAN}
                          ┌──────────────┐
                          │    Client    │
                          └──────┬───────┘
                                 │
                          ┌──────▼───────┐
                          │    Load      │
                          │   Balancer   │
                          └──┬───┬───┬──┘
                             │   │   │
                    ┌────────┘   │   └────────┐
                    │            │            │
              ┌─────▼────┐ ┌────▼─────┐ ┌────▼─────┐
              │ Server 1 │ │ Server 2 │ │ Server 3 │
              │ (33%)    │ │ (33%)    │ │ (33%)    │
              └──────────┘ └──────────┘ └──────────┘

    Algorithms:
    • Round Robin: Rotate through servers equally
    • Least Connections: Send to least busy server
    • IP Hash: Same client always goes to same server
    • Weighted: Some servers get more traffic
    • Geographic: Send to nearest server${RESET}"

    press_continue

    # --- Hands-on Labs ---
    print_header "MODULE 11: HANDS-ON LABS" "Performance in Practice"

    run_hands_on \
        "Check Cache Headers" \
        "See the caching headers returned by a website." \
        "curl -sI https://www.google.com | grep -iE 'cache|age|expires|etag'" \
        "These headers tell browsers how long to cache the response."

    run_hands_on \
        "Measure Website Load Time" \
        "Profile the connection and download time." \
        "curl -o /dev/null -s -w 'DNS Lookup:  %{time_namelookup}s\nTCP Connect: %{time_connect}s\nTLS Setup:   %{time_appconnect}s\nFirst Byte:  %{time_starttransfer}s\nTotal Time:  %{time_total}s\nDownload:    %{size_download} bytes\n' https://www.google.com" \
        "This breaks down each phase of the connection."

    # --- Quiz ---
    print_header "MODULE 11: QUIZ" "Test Your Knowledge"

    run_quiz \
        "What is the primary purpose of a CDN?" \
        "Encrypt data" \
        "Cache content geographically close to users for faster delivery" \
        "Block hackers" \
        "Store databases" \
        "B" \
        "CDNs distribute cached content to edge servers near users, reducing latency."

    run_quiz \
        "What does 'Cache-Control: no-store' mean?" \
        "Cache for a short time" \
        "Only cache in the browser" \
        "Never cache this response" \
        "Cache permanently" \
        "C" \
        "no-store means the response should never be cached - used for sensitive data like banking pages."

    run_true_false \
        "A load balancer distributes incoming traffic across multiple servers." \
        "T" \
        "Load balancers distribute traffic to prevent any single server from being overwhelmed."
}

#==============================================================================
#  MODULE 12: MODERN INTERNET - APIs, WebSockets & Cloud
#==============================================================================
module_12_modern_internet() {
    print_header "MODULE 12: THE MODERN INTERNET" "APIs, WebSockets, Cloud & Beyond"

    print_section "The Internet Has Evolved"

    print_info "The modern internet is far more than static web pages."
    print_info "It's a platform for real-time apps, cloud computing,"
    print_info "IoT devices, AI services, and more."

    press_continue

    # --- Section 12.1: APIs ---
    print_header "MODULE 12.1: APIs" "Application Programming Interfaces"

    print_section "What Is an API?"

    print_definition "API" \
        "A set of rules allowing programs to communicate with each other"
    echo ""

    print_info "APIs allow different applications to share data and features."
    print_info "Most modern APIs use REST over HTTP."
    echo ""

    print_diagram "
    ${CYAN}
    REST API Example:

    Mobile App ──→ HTTP Request ──→ Server ──→ Database
                                      │
    GET /api/users/42                  │
    Authorization: Bearer token123     │
                                      ↓
                                 Process Request
                                      │
    Mobile App ←── HTTP Response ←── Server
                                      │
    HTTP/1.1 200 OK                   │
    Content-Type: application/json     │
    {                                  │
      \"id\": 42,                       │
      \"name\": \"John Doe\",             │
      \"email\": \"john@example.com\"     │
    }                                  │

    Common REST Patterns:
    GET    /api/users        → List all users
    GET    /api/users/42     → Get user #42
    POST   /api/users        → Create new user
    PUT    /api/users/42     → Update user #42
    DELETE /api/users/42     → Delete user #42${RESET}"

    press_continue

    # --- Section 12.2: WebSockets ---
    print_header "MODULE 12.2: WebSockets" "Real-Time Bidirectional Communication"

    print_section "HTTP vs WebSocket"

    print_diagram "
    ${CYAN}
    HTTP: Request-Response (Half-Duplex)
    ┌────────┐                    ┌────────┐
    │ Client │ ── Request ──────→ │ Server │
    │        │ ←── Response ───── │        │
    │        │ ── Request ──────→ │        │
    │        │ ←── Response ───── │        │
    └────────┘                    └────────┘
    Client must always initiate. Server can't push data.

    WebSocket: Full-Duplex Persistent Connection
    ┌────────┐                    ┌────────┐
    │ Client │ ── HTTP Upgrade ─→ │ Server │
    │        │ ←── 101 Switching ─│        │
    │        │                    │        │
    │        │ ←── Server Push ── │        │
    │        │ ── Client Send ──→ │        │
    │        │ ←── Server Push ── │        │
    │        │ ←── Server Push ── │        │
    │        │ ── Client Send ──→ │        │
    └────────┘                    └────────┘
    Both sides can send data anytime!

    Used for: Chat apps, live sports scores, stock tickers,
              online gaming, collaborative editing${RESET}"

    press_continue

    # --- Section 12.3: Cloud Computing ---
    print_header "MODULE 12.3: CLOUD COMPUTING" "The Infrastructure Behind Modern Apps"

    print_section "Cloud Service Models"

    print_diagram "
    ${CYAN}
    ╔═══════════════════════════════════════════════════════╗
    ║              Cloud Service Models                     ║
    ╠═══════════════════════════════════════════════════════╣
    ║                                                       ║
    ║  On-Premises    IaaS          PaaS          SaaS     ║
    ║  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────┐ ║
    ║  │ App      │  │ App      │  │ App      │  │ ☁    │ ║
    ║  │ Data     │  │ Data     │  │ Data     │  │ All  │ ║
    ║  │ Runtime  │  │ Runtime  │  │ ☁ Cloud  │  │Managed║ ║
    ║  │ OS       │  │ OS       │  │  manages │  │ by   │ ║
    ║  │ Network  │  │ ☁ Cloud  │  │  these   │  │Cloud │ ║
    ║  │ Storage  │  │  manages │  │          │  │      │ ║
    ║  │ Servers  │  │  these   │  │          │  │      │ ║
    ║  └──────────┘  └──────────┘  └──────────┘  └──────┘ ║
    ║  You manage    You manage    You manage    You just  ║
    ║  everything    apps & data   just the app  use it    ║
    ║                                                       ║
    ║  Example:      AWS EC2       Heroku       Gmail      ║
    ║  Your server   DigitalOcean  Google App   Dropbox    ║
    ║                Azure VMs     Engine       Salesforce ║
    ╚═══════════════════════════════════════════════════════╝${RESET}"

    press_continue

    # --- Section 12.4: How Modern Web Apps Work ---
    print_header "MODULE 12.4: MODERN WEB ARCHITECTURE" "Putting It All Together"

    print_section "Full Stack Request Flow"

    print_diagram "
    ${CYAN}
    User types: https://app.example.com

    ┌──────────┐
    │ 📱 User   │
    │  Browser  │
    └────┬─────┘
         │ DNS Lookup → CDN DNS (Route 53, Cloudflare)
         │              → Closest edge server
         ↓
    ┌──────────┐
    │ 🌐 CDN    │  Serve static assets (JS, CSS, images)
    │  Edge    │  from cache if possible
    └────┬─────┘
         │ Cache miss? Forward to origin
         ↓
    ┌──────────┐
    │ ⚖️ Load   │  Distribute across server instances
    │ Balancer │  (Nginx, ALB, HAProxy)
    └────┬─────┘
         │
    ┌────▼─────┐    ┌──────────┐    ┌──────────┐
    │ 🖥 Web    │──→│ 📦 Cache  │──→│ 🗃 Database│
    │ Server   │   │ (Redis)  │   │ (PostgreSQL)
    │ (Node.js)│←──│          │←──│           │
    │          │   └──────────┘   └──────────┘
    └────┬─────┘
         │         ┌──────────┐
         ├────────→│ 📨 Queue  │ (RabbitMQ, Kafka)
         │         └────┬─────┘
         │              ↓
         │         ┌──────────┐
         │         │ ⚙️ Worker  │ (Background jobs)
         │         └──────────┘
         │
         ↓
    ┌──────────┐
    │ 📊 Monitor│ (Prometheus, Grafana, DataDog)
    │ & Logs   │
    └──────────┘${RESET}"

    press_continue

    # --- Section 12.5: Emerging Technologies ---
    print_header "MODULE 12.5: THE FUTURE OF THE INTERNET" ""

    print_section "Emerging Technologies"

    echo -e "${YELLOW}  🔮 HTTP/3 & QUIC:${RESET}"
    print_info "     Built on UDP. Faster connections, better on mobile."
    echo ""
    echo -e "${YELLOW}  🌐 Edge Computing:${RESET}"
    print_info "     Run code at CDN edge nodes, closer to users."
    print_info "     Examples: Cloudflare Workers, AWS Lambda@Edge"
    echo ""
    echo -e "${YELLOW}  🔗 Web3 & Decentralization:${RESET}"
    print_info "     Blockchain-based apps, IPFS, decentralized DNS"
    echo ""
    echo -e "${YELLOW}  🤖 AI at the Edge:${RESET}"
    print_info "     Machine learning inference on edge devices"
    echo ""
    echo -e "${YELLOW}  📡 Starlink & LEO Satellites:${RESET}"
    print_info "     Low Earth Orbit satellites for global internet (~20ms latency)"
    echo ""
    echo -e "${YELLOW}  🏠 IoT (Internet of Things):${RESET}"
    print_info "     Billions of connected devices: sensors, cameras, appliances"
    print_info "     Protocols: MQTT, CoAP, Zigbee, Matter"
    echo ""
    echo -e "${YELLOW}  🔒 Zero Trust Security:${RESET}"
    print_info "     Never trust, always verify. Every request is authenticated."

    press_continue

    # --- Hands-on Labs ---
    print_header "MODULE 12: HANDS-ON LABS" "Modern Internet in Practice"

    run_hands_on \
        "Call a REST API" \
        "Fetch data from a public REST API." \
        "curl -s 'https://httpbin.org/get' 2>/dev/null | head -20" \
        "httpbin.org is a test API that echoes back your request information."

    run_hands_on \
        "POST Data to an API" \
        "Send JSON data to an API endpoint." \
        "curl -s -X POST 'https://httpbin.org/post' -H 'Content-Type: application/json' -d '{\"name\":\"student\",\"course\":\"internet\"}' 2>/dev/null | head -25" \
        "This sends a POST request with JSON body, simulating form submission."

    run_hands_on \
        "Check HTTP/2 Support" \
        "See if a website supports HTTP/2 or HTTP/3." \
        "curl -sI --http2 https://www.google.com 2>/dev/null | head -5" \
        "Look for 'HTTP/2' in the response to confirm HTTP/2 support."

    # --- Quiz ---
    print_header "MODULE 12: QUIZ" "Test Your Knowledge"

    run_quiz \
        "What is a REST API?" \
        "A type of database" \
        "An interface for programs to communicate using HTTP methods" \
        "A programming language" \
        "A type of server" \
        "B" \
        "REST APIs use HTTP methods (GET, POST, PUT, DELETE) to allow programs to communicate and exchange data."

    run_quiz \
        "What advantage does WebSocket have over HTTP?" \
        "Better encryption" \
        "Full-duplex bidirectional communication" \
        "Faster DNS resolution" \
        "Better compression" \
        "B" \
        "WebSockets provide full-duplex communication, meaning both client and server can send data at any time without request-response pattern."

    run_quiz \
        "In cloud computing, what is SaaS?" \
        "The user manages everything" \
        "The user manages only the app" \
        "The cloud manages everything; user just uses the software" \
        "The user manages the OS and runtime" \
        "C" \
        "SaaS (Software as a Service) means the entire application is managed by the provider. Examples: Gmail, Dropbox, Salesforce."
}

#==============================================================================
#  FINAL EXAM
#==============================================================================
final_exam() {
    print_header "🎓 FINAL EXAM" "Test Everything You've Learned"

    echo -e "${WHITE}  This final exam covers all 12 modules.${RESET}"
    echo -e "${WHITE}  Let's see how much you've learned!${RESET}"
    echo ""
    echo -e "${YELLOW}  Previous score: $SCORE/$TOTAL_QUESTIONS${RESET}"

    press_continue

    run_quiz \
        "What physical medium carries 99% of intercontinental internet traffic?" \
        "Satellites" \
        "Submarine fiber optic cables" \
        "Radio waves" \
        "Copper telephone lines" \
        "B" \
        "Submarine fiber optic cables laid on the ocean floor carry over 99% of intercontinental data."

    run_quiz \
        "How many bytes does the character 'A' occupy in ASCII?" \
        "1 byte" \
        "2 bytes" \
        "4 bytes" \
        "8 bytes" \
        "A" \
        "In ASCII, each character is exactly 1 byte (8 bits). 'A' = 65 = 01000001."

    run_quiz \
        "What is the main difference between IPv4 and IPv6?" \
        "IPv6 is faster" \
        "IPv6 uses 128-bit addresses vs IPv4's 32-bit" \
        "IPv6 doesn't use packets" \
        "IPv4 is more secure" \
        "B" \
        "IPv4 uses 32-bit addresses (~4.3 billion), IPv6 uses 128-bit addresses (virtually unlimited)."

    run_quiz \
        "Which OSI layer handles routing and IP addressing?" \
        "Layer 2 - Data Link" \
        "Layer 3 - Network" \
        "Layer 4 - Transport" \
        "Layer 7 - Application" \
        "B" \
        "The Network Layer (Layer 3) is responsible for logical addressing (IP) and routing between networks."

    run_quiz \
        "In DNS resolution, what does the recursive resolver do?" \
        "Stores all domain names" \
        "Queries other DNS servers on behalf of the client" \
        "Encrypts DNS queries" \
        "Assigns IP addresses to domains" \
        "B" \
        "The recursive resolver (usually your ISP's) does the work of querying root, TLD, and authoritative servers."

    run_quiz \
        "What guarantees does TCP provide that UDP does not?" \
        "Faster delivery" \
        "Reliable, ordered delivery with error checking" \
        "Smaller packet size" \
        "Lower latency" \
        "B" \
        "TCP guarantees reliability (retransmission), ordering (sequence numbers), and error checking (checksums)."

    run_quiz \
        "What HTTP status code range indicates server errors?" \
        "1xx" \
        "2xx" \
        "4xx" \
        "5xx" \
        "D" \
        "5xx codes indicate server errors (500 Internal Error, 502 Bad Gateway, 503 Unavailable)."

    run_quiz \
        "What protocol does HTTPS use for encryption?" \
        "SSH" \
        "IPSec" \
        "TLS (Transport Layer Security)" \
        "PGP" \
        "C" \
        "HTTPS = HTTP + TLS. TLS provides encryption, authentication, and integrity for web traffic."

    run_quiz \
        "What is the purpose of a CDN?" \
        "Create domain names" \
        "Cache content on servers geographically close to users" \
        "Encrypt all internet traffic" \
        "Route email messages" \
        "B" \
        "CDNs (Content Delivery Networks) cache content at edge locations worldwide to reduce latency."

    run_quiz \
        "What protocol is used for automatic IP address assignment?" \
        "DNS" \
        "DHCP" \
        "ARP" \
        "SMTP" \
        "B" \
        "DHCP (Dynamic Host Configuration Protocol) automatically assigns IP addresses and network settings."
}

#==============================================================================
#  COMPLETION SCREEN
#==============================================================================
course_completion() {
    clear_screen
    echo ""
    echo -e "${GREEN}${BOLD}"
    cat << 'COMPLETE'

    ╔═══════════════════════════════════════════════════════╗
    ║                                                       ║
    ║     🎓  CONGRATULATIONS!  🎓                          ║
    ║                                                       ║
    ║     You have completed the full course:                ║
    ║     "HOW THE INTERNET WORKS"                          ║
    ║                                                       ║
    ╚═══════════════════════════════════════════════════════╝

COMPLETE
    echo -e "${RESET}"

    local percentage=0
    if [ "$TOTAL_QUESTIONS" -gt 0 ]; then
        percentage=$((SCORE * 100 / TOTAL_QUESTIONS))
    fi

    echo -e "${WHITE}${BOLD}  📊 FINAL RESULTS:${RESET}"
    echo ""
    echo -e "${CYAN}  Total Questions Answered: $TOTAL_QUESTIONS${RESET}"
    echo -e "${CYAN}  Correct Answers:          $SCORE${RESET}"
    echo -e "${CYAN}  Score:                    $percentage%${RESET}"
    echo ""
    progress_bar "$SCORE" "$TOTAL_QUESTIONS"
    echo ""

    if [ "$percentage" -ge 90 ]; then
        echo -e "${GREEN}${BOLD}  🏆 OUTSTANDING! You're an Internet Expert!${RESET}"
    elif [ "$percentage" -ge 75 ]; then
        echo -e "${GREEN}  🌟 EXCELLENT! You have strong knowledge!${RESET}"
    elif [ "$percentage" -ge 60 ]; then
        echo -e "${YELLOW}  👍 GOOD! Consider reviewing some modules.${RESET}"
    else
        echo -e "${YELLOW}  📚 Keep learning! Re-run the course to improve.${RESET}"
    fi

    echo ""
    echo -e "${WHITE}${BOLD}  TOPICS MASTERED:${RESET}"
    echo -e "${GREEN}  ✔ Physical Infrastructure & Hardware${RESET}"
    echo -e "${GREEN}  ✔ Binary, Data & Encoding${RESET}"
    echo -e "${GREEN}  ✔ IP Addresses & Subnetting${RESET}"
    echo -e "${GREEN}  ✔ OSI Model & TCP/IP Stack${RESET}"
    echo -e "${GREEN}  ✔ DNS Resolution${RESET}"
    echo -e "${GREEN}  ✔ TCP, UDP & Packet Switching${RESET}"
    echo -e "${GREEN}  ✔ HTTP/HTTPS & Web Communication${RESET}"
    echo -e "${GREEN}  ✔ Routing & BGP${RESET}"
    echo -e "${GREEN}  ✔ Encryption & TLS Security${RESET}"
    echo -e "${GREEN}  ✔ Email & Other Protocols${RESET}"
    echo -e "${GREEN}  ✔ CDNs, Caching & Performance${RESET}"
    echo -e "${GREEN}  ✔ APIs, WebSockets & Cloud Computing${RESET}"
    echo ""

    echo -e "${DIM}  ─────────────────────────────────────────────────${RESET}"
    echo -e "${WHITE}  🔗 Continue Learning:${RESET}"
    echo -e "${CYAN}    • Cloudflare Learning Center${RESET}"
    echo -e "${CYAN}    • MDN Web Docs (developer.mozilla.org)${RESET}"
    echo -e "${CYAN}    • Computer Networking: A Top-Down Approach (book)${RESET}"
    echo -e "${CYAN}    • RFC documents (ietf.org)${RESET}"
    echo -e "${CYAN}    • Wireshark for packet analysis${RESET}"
    echo ""

    save_progress
}

#==============================================================================
#  MAIN MENU
#==============================================================================
main_menu() {
    while true; do
        print_header "HOW THE INTERNET WORKS" "Interactive Course - Main Menu"

        load_progress

        echo -e "${WHITE}  Course Progress:${RESET}"
        progress_bar "$CURRENT_MODULE" "$TOTAL_MODULES"
        echo ""
        if [ "$TOTAL_QUESTIONS" -gt 0 ]; then
            echo -e "${DIM}  Quiz Score: $SCORE/$TOTAL_QUESTIONS${RESET}"
        fi
        echo ""

        echo -e "${BOLD}  SELECT A MODULE:${RESET}"
        echo ""
        echo -e "${CYAN}   [0]  ${WHITE}Welcome & Introduction${RESET}"
        echo -e "${CYAN}   [1]  ${WHITE}Physical Infrastructure - Cables & Hardware${RESET}"
        echo -e "${CYAN}   [2]  ${WHITE}Binary, Bits & Data Transmission${RESET}"
        echo -e "${CYAN}   [3]  ${WHITE}IP Addresses & Subnetting${RESET}"
        echo -e "${CYAN}   [4]  ${WHITE}The OSI Model & TCP/IP Stack${RESET}"
        echo -e "${CYAN}   [5]  ${WHITE}DNS - The Internet's Phone Book${RESET}"
        echo -e "${CYAN}   [6]  ${WHITE}TCP, UDP & Packet Switching${RESET}"
        echo -e "${CYAN}   [7]  ${WHITE}HTTP, HTTPS & Web Communication${RESET}"
        echo -e "${CYAN}   [8]  ${WHITE}Routing & How Data Finds Its Way${RESET}"
        echo -e "${CYAN}   [9]  ${WHITE}Encryption, TLS & Security${RESET}"
        echo -e "${CYAN}  [10]  ${WHITE}Email, FTP & Other Protocols${RESET}"
        echo -e "${CYAN}  [11]  ${WHITE}CDNs, Caching & Performance${RESET}"
        echo -e "${CYAN}  [12]  ${WHITE}Modern Internet - APIs, WebSockets & Cloud${RESET}"
        echo ""
        echo -e "${GREEN}   [A]  ${WHITE}${BOLD}Run ALL modules sequentially${RESET}"
        echo -e "${YELLOW}   [F]  ${WHITE}${BOLD}Take the FINAL EXAM${RESET}"
        echo -e "${RED}   [R]  ${WHITE}Reset progress${RESET}"
        echo -e "${RED}   [Q]  ${WHITE}Quit${RESET}"
        echo ""
        echo -ne "${YELLOW}  Enter your choice: ${RESET}"
        read -r choice

        case "$choice" in
            0)
                module_0_welcome
                CURRENT_MODULE=1
                save_progress
                ;;
            1)
                module_1_physical_infrastructure
                [ "$CURRENT_MODULE" -lt 2 ] && CURRENT_MODULE=2
                save_progress
                ;;
            2)
                module_2_binary_data
                [ "$CURRENT_MODULE" -lt 3 ] && CURRENT_MODULE=3
                save_progress
                ;;
            3)
                module_3_ip_addresses
                [ "$CURRENT_MODULE" -lt 4 ] && CURRENT_MODULE=4
                save_progress
                ;;
            4)
                module_4_osi_model
                [ "$CURRENT_MODULE" -lt 5 ] && CURRENT_MODULE=5
                save_progress
                ;;
            5)
                module_5_dns
                [ "$CURRENT_MODULE" -lt 6 ] && CURRENT_MODULE=6
                save_progress
                ;;
            6)
                module_6_tcp_udp
                [ "$CURRENT_MODULE" -lt 7 ] && CURRENT_MODULE=7
                save_progress
                ;;
            7)
                module_7_http
                [ "$CURRENT_MODULE" -lt 8 ] && CURRENT_MODULE=8
                save_progress
                ;;
            8)
                module_8_routing
                [ "$CURRENT_MODULE" -lt 9 ] && CURRENT_MODULE=9
                save_progress
                ;;
            9)
                module_9_security
                [ "$CURRENT_MODULE" -lt 10 ] && CURRENT_MODULE=10
                save_progress
                ;;
            10)
                module_10_protocols
                [ "$CURRENT_MODULE" -lt 11 ] && CURRENT_MODULE=11
                save_progress
                ;;
            11)
                module_11_cdn_performance
                [ "$CURRENT_MODULE" -lt 12 ] && CURRENT_MODULE=12
                save_progress
                ;;
            12)
                module_12_modern_internet
                CURRENT_MODULE=12
                save_progress
                ;;
            [Aa])
                module_0_welcome
                module_1_physical_infrastructure
                module_2_binary_data
                module_3_ip_addresses
                module_4_osi_model
                module_5_dns
                module_6_tcp_udp
                module_7_http
                module_8_routing
                module_9_security
                module_10_protocols
                module_11_cdn_performance
                module_12_modern_internet
                final_exam
                CURRENT_MODULE=12
                save_progress
                course_completion
                press_continue
                ;;
            [Ff])
                final_exam
                save_progress
                course_completion
                press_continue
                ;;
            [Rr])
                CURRENT_MODULE=0
                SCORE=0
                TOTAL_QUESTIONS=0
                save_progress
                echo -e "${GREEN}  Progress reset!${RESET}"
                sleep 1
                ;;
            [Qq])
                save_progress
                clear_screen
                echo -e "${GREEN}${BOLD}"
                echo "  ╔═════════════════════════════════════════════╗"
                echo "  ║                                             ║"
                echo "  ║   Thanks for learning how the internet      ║"
                echo "  ║   works! Keep exploring! 🌐                 ║"
                echo "  ║                                             ║"
                echo "  ║   Score: $SCORE/$TOTAL_QUESTIONS                          ║"
                echo "  ║                                             ║"
                echo "  ╚═════════════════════════════════════════════╝"
                echo -e "${RESET}"
                exit 0
                ;;
            *)
                echo -e "${RED}  Invalid choice. Please try again.${RESET}"
                sleep 1
                ;;
        esac
    done
}

#==============================================================================
#  ENTRY POINT
#==============================================================================

# Handle script arguments
case "${1:-}" in
    --reset)
        rm -f "$PROGRESS_FILE"
        echo "Progress reset."
        exit 0
        ;;
    --help|-h)
        echo "Usage: $0 [option]"
        echo ""
        echo "Options:"
        echo "  --reset    Reset all progress"
        echo "  --help     Show this help message"
        echo ""
        echo "An interactive course on how the internet works."
        echo "Designed for Termux on Android."
        exit 0
        ;;
esac

# Start the course
main_menu
