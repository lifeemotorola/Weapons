#!/data/data/com.termux/files/usr/bin/bash

#==============================================================================
# SS7 EDUCATIONAL LESSON FOR TERMUX
# File: ss7_lesson.sh
# Purpose: Educational overview of SS7 protocol architecture
# Usage: chmod +x ss7_lesson.sh && ./ss7_lesson.sh
#
# DISCLAIMER: FOR EDUCATIONAL/ACADEMIC PURPOSES ONLY.
# Unauthorized access to telecom networks is a criminal offense.
#==============================================================================

# --- Colors and Formatting ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
WHITE='\033[1;37m'
BOLD='\033[1m'
UNDERLINE='\033[4m'
NC='\033[0m' # No Color

# --- Helper Functions ---
clear_screen() {
    clear
}

press_continue() {
    echo ""
    echo -e "${YELLOW}Press [ENTER] to continue...${NC}"
    read -r
}

print_header() {
    local title="$1"
    local width=60
    local pad=$(( (width - ${#title}) / 2 ))
    echo ""
    echo -e "${CYAN}$(printf '═%.0s' $(seq 1 $width))${NC}"
    echo -e "${CYAN}║${WHITE}$(printf ' %.0s' $(seq 1 $pad))${BOLD}${title}$(printf ' %.0s' $(seq 1 $((width - pad - ${#title} - 2))))${NC}${CYAN}║${NC}"
    echo -e "${CYAN}$(printf '═%.0s' $(seq 1 $width))${NC}"
    echo ""
}

print_subheader() {
    echo ""
    echo -e "${GREEN}━━━ ${BOLD}$1${NC} ${GREEN}━━━${NC}"
    echo ""
}

print_diagram_box() {
    local text="$1"
    local color="${2:-$WHITE}"
    local len=${#text}
    local border_len=$((len + 4))
    echo -e "${color}  ┌$(printf '─%.0s' $(seq 1 $border_len))┐${NC}"
    echo -e "${color}  │  ${text}  │${NC}"
    echo -e "${color}  └$(printf '─%.0s' $(seq 1 $border_len))┘${NC}"
}

print_note() {
    echo -e "${YELLOW}  📝 NOTE: ${NC}$1"
}

print_warning() {
    echo -e "${RED}  ⚠️  WARNING: ${NC}$1"
}

print_info() {
    echo -e "${BLUE}  ℹ️  ${NC}$1"
}

quiz_question() {
    local question="$1"
    local correct="$2"
    local opt_a="$3"
    local opt_b="$4"
    local opt_c="$5"
    local opt_d="$6"
    local explanation="$7"

    echo ""
    echo -e "${MAGENTA}${BOLD}  QUIZ: ${NC}${WHITE}$question${NC}"
    echo ""
    echo -e "    ${CYAN}A)${NC} $opt_a"
    echo -e "    ${CYAN}B)${NC} $opt_b"
    echo -e "    ${CYAN}C)${NC} $opt_c"
    echo -e "    ${CYAN}D)${NC} $opt_d"
    echo ""
    echo -ne "  ${YELLOW}Your answer (A/B/C/D): ${NC}"
    read -r answer
    answer=$(echo "$answer" | tr '[:lower:]' '[:upper:]')

    if [[ "$answer" == "$correct" ]]; then
        echo -e "  ${GREEN}✅ CORRECT!${NC}"
    else
        echo -e "  ${RED}❌ INCORRECT. The correct answer is: ${correct}${NC}"
    fi
    echo -e "  ${BLUE}Explanation: ${NC}$explanation"
    echo ""
}

# --- Progress Tracking ---
TOTAL_LESSONS=10
CURRENT_LESSON=0
QUIZ_SCORE=0
QUIZ_TOTAL=0

show_progress() {
    local pct=$(( (CURRENT_LESSON * 100) / TOTAL_LESSONS ))
    local filled=$(( pct / 5 ))
    local empty=$(( 20 - filled ))
    echo -ne "  ${CYAN}Progress: [${GREEN}"
    printf '█%.0s' $(seq 1 $filled 2>/dev/null)
    echo -ne "${WHITE}"
    printf '░%.0s' $(seq 1 $empty 2>/dev/null)
    echo -e "${CYAN}] ${pct}% (${CURRENT_LESSON}/${TOTAL_LESSONS})${NC}"
}

#==============================================================================
# LESSON 0: WELCOME & DISCLAIMER
#==============================================================================
lesson_welcome() {
    clear_screen
    print_header "SS7 EDUCATIONAL COURSE"

    echo -e "${WHITE}  Welcome to the SS7 (Signaling System No. 7) Educational Course${NC}"
    echo ""
    echo -e "  This interactive lesson covers:"
    echo ""
    echo -e "  ${CYAN}  1.${NC}  What is SS7?"
    echo -e "  ${CYAN}  2.${NC}  History and Evolution"
    echo -e "  ${CYAN}  3.${NC}  SS7 Protocol Stack (OSI Mapping)"
    echo -e "  ${CYAN}  4.${NC}  SS7 Network Architecture"
    echo -e "  ${CYAN}  5.${NC}  Message Transfer Part (MTP)"
    echo -e "  ${CYAN}  6.${NC}  SCCP - Signaling Connection Control Part"
    echo -e "  ${CYAN}  7.${NC}  TCAP & MAP - Application Layers"
    echo -e "  ${CYAN}  8.${NC}  ISUP - ISDN User Part"
    echo -e "  ${CYAN}  9.${NC}  SS7 Security Vulnerabilities (Theory)"
    echo -e "  ${CYAN} 10.${NC}  Modern Alternatives & Diameter Protocol"
    echo ""

    echo -e "${RED}${BOLD}  ╔══════════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}${BOLD}  ║           LEGAL DISCLAIMER & WARNING                ║${NC}"
    echo -e "${RED}${BOLD}  ╠══════════════════════════════════════════════════════╣${NC}"
    echo -e "${RED}  ║  This material is STRICTLY for educational purposes  ║${NC}"
    echo -e "${RED}  ║  Unauthorized access to SS7 networks is a FELONY    ║${NC}"
    echo -e "${RED}  ║  Violations carry PRISON sentences worldwide        ║${NC}"
    echo -e "${RED}  ║  This course teaches THEORY only - no attack tools  ║${NC}"
    echo -e "${RED}  ║  Always follow applicable laws and regulations      ║${NC}"
    echo -e "${RED}${BOLD}  ╚══════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -ne "  ${YELLOW}Do you understand and agree? (yes/no): ${NC}"
    read -r agree
    if [[ "$agree" != "yes" ]]; then
        echo -e "  ${RED}You must agree to continue. Exiting.${NC}"
        exit 0
    fi
    press_continue
}

#==============================================================================
# LESSON 1: WHAT IS SS7?
#==============================================================================
lesson_1_what_is_ss7() {
    CURRENT_LESSON=1
    clear_screen
    print_header "LESSON 1: WHAT IS SS7?"
    show_progress
    echo ""

    echo -e "${WHITE}  SS7 (Signaling System No. 7) is a set of telephony signaling${NC}"
    echo -e "${WHITE}  protocols developed in the 1970s-1980s used to:${NC}"
    echo ""
    echo -e "  ${GREEN}•${NC} Set up and tear down telephone calls"
    echo -e "  ${GREEN}•${NC} Provide caller ID, call forwarding, SMS delivery"
    echo -e "  ${GREEN}•${NC} Enable number portability"
    echo -e "  ${GREEN}•${NC} Manage mobile subscriber roaming"
    echo -e "  ${GREEN}•${NC} Handle billing and toll-free number routing"
    echo -e "  ${GREEN}•${NC} Support wireless services (2G/3G authentication)"
    echo ""

    print_subheader "Key Concept: Out-of-Band Signaling"

    echo -e "  ${WHITE}Before SS7, signaling was 'in-band' — control signals traveled${NC}"
    echo -e "  ${WHITE}on the same channel as voice. SS7 uses a SEPARATE network${NC}"
    echo -e "  ${WHITE}for signaling, called 'out-of-band' signaling.${NC}"
    echo ""

    echo -e "  ${CYAN}In-Band (Old):${NC}"
    echo -e "    ┌──────────┐    Voice + Signals    ┌──────────┐"
    echo -e "    │ Phone A  │ ═══════════════════>  │ Phone B  │"
    echo -e "    └──────────┘    (Same Channel)     └──────────┘"
    echo ""
    echo -e "  ${GREEN}Out-of-Band (SS7):${NC}"
    echo -e "    ┌──────────┐     Voice Only        ┌──────────┐"
    echo -e "    │ Phone A  │ ═══════════════════>  │ Phone B  │"
    echo -e "    └──────────┘                       └──────────┘"
    echo -e "         │                                   │"
    echo -e "         │         ┌───────────┐             │"
    echo -e "         └────────>│  SS7 STP  │<────────────┘"
    echo -e "         Signals   │ (Separate)│   Signals"
    echo -e "                   └───────────┘"
    echo ""

    print_note "SS7 is still used by most telecom operators worldwide today."
    print_info "ITU-T defines SS7 internationally; ANSI defines the US variant."

    press_continue

    # Quiz
    clear_screen
    print_header "LESSON 1: QUIZ"
    quiz_question \
        "What type of signaling does SS7 use?" \
        "B" \
        "In-band signaling" \
        "Out-of-band signaling" \
        "Broadband signaling" \
        "Baseband signaling" \
        "SS7 uses out-of-band signaling, meaning control signals travel on a separate network from voice data."

    QUIZ_TOTAL=$((QUIZ_TOTAL + 1))
    [[ "$answer" == "B" ]] && QUIZ_SCORE=$((QUIZ_SCORE + 1))

    press_continue
}

#==============================================================================
# LESSON 2: HISTORY AND EVOLUTION
#==============================================================================
lesson_2_history() {
    CURRENT_LESSON=2
    clear_screen
    print_header "LESSON 2: HISTORY & EVOLUTION OF SS7"
    show_progress
    echo ""

    echo -e "${WHITE}  Timeline of Telephony Signaling:${NC}"
    echo ""
    echo -e "  ${CYAN}1876${NC}  ─── Alexander Graham Bell invents the telephone"
    echo -e "  ${CYAN}    │${NC}"
    echo -e "  ${CYAN}1890s${NC} ─── Manual switchboard operators"
    echo -e "  ${CYAN}    │${NC}"
    echo -e "  ${CYAN}1920s${NC} ─── Automatic electromechanical switches"
    echo -e "  ${CYAN}    │${NC}"
    echo -e "  ${CYAN}1960s${NC} ─── ${YELLOW}SS5${NC}: In-band multi-frequency signaling"
    echo -e "  ${CYAN}    │${NC}       (Vulnerable to 'blue box' phreaking)"
    echo -e "  ${CYAN}    │${NC}"
    echo -e "  ${CYAN}1975${NC}  ─── ${YELLOW}SS6${NC}: First out-of-band signaling (analog)"
    echo -e "  ${CYAN}    │${NC}"
    echo -e "  ${CYAN}1980${NC}  ─── ${GREEN}SS7${NC}: Digital out-of-band signaling defined"
    echo -e "  ${CYAN}    │${NC}       by CCITT (now ITU-T)"
    echo -e "  ${CYAN}    │${NC}"
    echo -e "  ${CYAN}1990s${NC} ─── SS7 deployed globally, enables GSM roaming"
    echo -e "  ${CYAN}    │${NC}"
    echo -e "  ${CYAN}2000s${NC} ─── ${YELLOW}SIGTRAN${NC}: SS7 over IP (adaptation layers)"
    echo -e "  ${CYAN}    │${NC}"
    echo -e "  ${CYAN}2010s${NC} ─── ${GREEN}Diameter${NC}: Replacement for 4G/LTE networks"
    echo -e "  ${CYAN}    │${NC}"
    echo -e "  ${CYAN}2020s${NC} ─── ${GREEN}5G HTTP/2${NC}: Service-based architecture"
    echo ""

    print_subheader "Why Was SS7 Created?"

    echo -e "  ${WHITE}1. Phreaking:${NC} In-band signaling (SS5) could be exploited"
    echo -e "     by generating tones (e.g., 2600 Hz) to make free calls."
    echo -e "     Famous case: 'Captain Crunch' (John Draper) used a toy"
    echo -e "     whistle from a cereal box to generate the exact tone."
    echo ""
    echo -e "  ${WHITE}2. Efficiency:${NC} Separate signaling network freed voice"
    echo -e "     channels and allowed faster call setup."
    echo ""
    echo -e "  ${WHITE}3. Features:${NC} Enabled advanced services like caller ID,"
    echo -e "     call waiting, 800 numbers, and later SMS & roaming."
    echo ""

    print_subheader "SS7 Variants Around the World"
    echo ""
    echo -e "  ┌──────────────────┬─────────────────────────────┐"
    echo -e "  │ ${BOLD}Region${NC}           │ ${BOLD}Standard${NC}                      │"
    echo -e "  ├──────────────────┼─────────────────────────────┤"
    echo -e "  │ International    │ ITU-T Q.700 series          │"
    echo -e "  │ North America    │ ANSI T1.110 series          │"
    echo -e "  │ Europe           │ ETSI ETS 300 series         │"
    echo -e "  │ China            │ China variant (GF 001-9001) │"
    echo -e "  │ Japan            │ TTC JT-Q700 series          │"
    echo -e "  └──────────────────┴─────────────────────────────┘"
    echo ""

    press_continue

    clear_screen
    print_header "LESSON 2: QUIZ"

    quiz_question \
        "What vulnerability in SS5 motivated the creation of SS7?" \
        "C" \
        "Buffer overflow attacks" \
        "DNS spoofing" \
        "In-band tone-based phreaking (e.g., 2600 Hz)" \
        "SQL injection" \
        "SS5 used in-band tones for signaling. Attackers could generate these tones to manipulate the phone network, making free calls."

    QUIZ_TOTAL=$((QUIZ_TOTAL + 1))
    [[ "$answer" == "C" ]] && QUIZ_SCORE=$((QUIZ_SCORE + 1))

    press_continue
}

#==============================================================================
# LESSON 3: SS7 PROTOCOL STACK
#==============================================================================
lesson_3_protocol_stack() {
    CURRENT_LESSON=3
    clear_screen
    print_header "LESSON 3: SS7 PROTOCOL STACK"
    show_progress
    echo ""

    echo -e "${WHITE}  The SS7 protocol stack maps roughly to the OSI model:${NC}"
    echo ""
    echo -e "  ${BOLD}OSI Layer        SS7 Protocol            Function${NC}"
    echo -e "  ${CYAN}─────────────────────────────────────────────────────────${NC}"
    echo ""
    echo -e "  ┌─────────────────────────────────────────────────────┐"
    echo -e "  │ ${MAGENTA}Layer 7${NC}  │ ${GREEN}MAP, CAP, INAP${NC}    │ Mobile/Intelligent  │"
    echo -e "  │ ${WHITE}Applic.${NC}  │ ${GREEN}(Applications)${NC}     │ Network Apps        │"
    echo -e "  ├─────────┼────────────────────┼─────────────────────┤"
    echo -e "  │ ${MAGENTA}Layer 7${NC}  │ ${GREEN}TCAP${NC}               │ Transaction         │"
    echo -e "  │ ${WHITE}Applic.${NC}  │ ${GREEN}(Transaction Cap)${NC}  │ Capabilities        │"
    echo -e "  ├─────────┼────────────────────┼─────────────────────┤"
    echo -e "  │ ${MAGENTA}Layer 7${NC}  │ ${YELLOW}ISUP${NC}               │ Call Control         │"
    echo -e "  │ ${WHITE}Applic.${NC}  │ ${YELLOW}(ISDN User Part)${NC}   │ Setup/Teardown      │"
    echo -e "  ├─────────┼────────────────────┼─────────────────────┤"
    echo -e "  │ ${MAGENTA}Layer 4${NC}  │ ${CYAN}SCCP${NC}               │ Routing &           │"
    echo -e "  │ ${WHITE}Transp.${NC}  │ ${CYAN}(Signaling Conn.)${NC}  │ Segmentation        │"
    echo -e "  ├─────────┼────────────────────┼─────────────────────┤"
    echo -e "  │ ${MAGENTA}Layer 3${NC}  │ ${BLUE}MTP Level 3${NC}        │ Network/Routing     │"
    echo -e "  │ ${WHITE}Network${NC}  │ ${BLUE}(Message Transfer)${NC} │ Message Routing     │"
    echo -e "  ├─────────┼────────────────────┼─────────────────────┤"
    echo -e "  │ ${MAGENTA}Layer 2${NC}  │ ${BLUE}MTP Level 2${NC}        │ Data Link           │"
    echo -e "  │ ${WHITE}DataLink${NC} │ ${BLUE}(Signaling Link)${NC}   │ Error Detection     │"
    echo -e "  ├─────────┼────────────────────┼─────────────────────┤"
    echo -e "  │ ${MAGENTA}Layer 1${NC}  │ ${BLUE}MTP Level 1${NC}        │ Physical            │"
    echo -e "  │ ${WHITE}Physical${NC} │ ${BLUE}(Signaling Data)${NC}   │ DS0/E1/T1 Links     │"
    echo -e "  └─────────┴────────────────────┴─────────────────────┘"
    echo ""

    print_subheader "Protocol Relationships"
    echo ""
    echo -e "                    ┌───────┐  ┌───────┐  ┌────────┐"
    echo -e "                    │${GREEN} MAP   ${NC}│  │${GREEN} INAP  ${NC}│  │${GREEN}  CAP   ${NC}│"
    echo -e "                    └───┬───┘  └───┬───┘  └───┬────┘"
    echo -e "                        │          │          │"
    echo -e "                        └──────────┼──────────┘"
    echo -e "                                   │"
    echo -e "                    ┌──────────────┴──────────────┐"
    echo -e "                    │         ${GREEN}TCAP${NC}                 │"
    echo -e "                    └──────────────┬──────────────┘"
    echo -e "         ┌─────────────────────────┼───────────────┐"
    echo -e "         │                         │               │"
    echo -e "    ┌────┴────┐            ┌───────┴──────┐        │"
    echo -e "    │  ${YELLOW}ISUP${NC}   │            │    ${CYAN}SCCP${NC}      │        │"
    echo -e "    └────┬────┘            └───────┬──────┘        │"
    echo -e "         │                         │               │"
    echo -e "         └─────────────────────────┼───────────────┘"
    echo -e "                                   │"
    echo -e "                    ┌──────────────┴──────────────┐"
    echo -e "                    │       ${BLUE}MTP Level 3${NC}           │"
    echo -e "                    ├─────────────────────────────┤"
    echo -e "                    │       ${BLUE}MTP Level 2${NC}           │"
    echo -e "                    ├─────────────────────────────┤"
    echo -e "                    │       ${BLUE}MTP Level 1${NC}           │"
    echo -e "                    └─────────────────────────────┘"
    echo ""

    print_note "ISUP can use MTP3 directly, while MAP/INAP require SCCP+TCAP."

    press_continue

    clear_screen
    print_header "LESSON 3: QUIZ"

    quiz_question \
        "Which SS7 layer handles transaction capabilities for MAP?" \
        "A" \
        "TCAP (Transaction Capabilities Application Part)" \
        "SCCP (Signaling Connection Control Part)" \
        "MTP Level 3" \
        "ISUP (ISDN User Part)" \
        "TCAP provides the transaction framework that MAP uses to exchange messages between network elements."

    QUIZ_TOTAL=$((QUIZ_TOTAL + 1))
    [[ "$answer" == "A" ]] && QUIZ_SCORE=$((QUIZ_SCORE + 1))

    press_continue
}

#==============================================================================
# LESSON 4: SS7 NETWORK ARCHITECTURE
#==============================================================================
lesson_4_architecture() {
    CURRENT_LESSON=4
    clear_screen
    print_header "LESSON 4: SS7 NETWORK ARCHITECTURE"
    show_progress
    echo ""

    print_subheader "SS7 Network Elements"

    echo -e "  ${BOLD}${GREEN}SSP${NC} - Service Switching Point"
    echo -e "      Telephone switches that originate/terminate calls"
    echo -e "      Generate SS7 messages to set up voice circuits"
    echo ""
    echo -e "  ${BOLD}${GREEN}STP${NC} - Signal Transfer Point"
    echo -e "      Routers of the SS7 network"
    echo -e "      Route signaling messages between network nodes"
    echo -e "      Typically deployed in mated pairs (redundancy)"
    echo ""
    echo -e "  ${BOLD}${GREEN}SCP${NC} - Service Control Point"
    echo -e "      Databases that provide advanced services"
    echo -e "      Toll-free number lookups, Local Number Portability"
    echo -e "      HLR (Home Location Register) for mobile networks"
    echo ""

    print_subheader "SS7 Network Topology"
    echo ""
    echo -e "        ┌─────┐                         ┌─────┐"
    echo -e "        │${GREEN} SCP ${NC}│                         │${GREEN} SCP ${NC}│"
    echo -e "        │(HLR)│                         │(VLR)│"
    echo -e "        └──┬──┘                         └──┬──┘"
    echo -e "           │                               │"
    echo -e "           │        ┌─────┐  ┌─────┐      │"
    echo -e "           ├────────┤${CYAN} STP ${NC}├──┤${CYAN} STP ${NC}├──────┤"
    echo -e "           │        │(A)  │  │(B)  │      │"
    echo -e "           │        └──┬──┘  └──┬──┘      │"
    echo -e "           │           │  ╲  ╱  │         │"
    echo -e "           │           │   ╲╱   │         │"
    echo -e "           │           │   ╱╲   │         │"
    echo -e "           │           │  ╱  ╲  │         │"
    echo -e "           │        ┌──┴──┐  ┌──┴──┐      │"
    echo -e "           ├────────┤${CYAN} STP ${NC}├──┤${CYAN} STP ${NC}├──────┤"
    echo -e "           │        │(C)  │  │(D)  │      │"
    echo -e "           │        └──┬──┘  └──┬──┘      │"
    echo -e "           │           │        │         │"
    echo -e "        ┌──┴──┐     ┌──┴──┐  ┌──┴──┐  ┌──┴──┐"
    echo -e "        │${YELLOW} SSP ${NC}│     │${YELLOW} SSP ${NC}│  │${YELLOW} SSP ${NC}│  │${YELLOW} SSP ${NC}│"
    echo -e "        │(CO) │     │(MSC)│  │(CO) │  │(MSC)│"
    echo -e "        └─────┘     └─────┘  └─────┘  └─────┘"
    echo ""
    echo -e "        ${WHITE}CO = Central Office    MSC = Mobile Switching Center${NC}"
    echo ""

    print_subheader "Point Codes"
    echo ""
    echo -e "  ${WHITE}Every SS7 node has a unique address called a ${BOLD}Point Code${NC}:"
    echo ""
    echo -e "  ${CYAN}ANSI (North America):${NC}  Network-Cluster-Member"
    echo -e "                         (8 bits - 8 bits - 8 bits)"
    echo -e "                         Example: ${GREEN}247-035-012${NC}"
    echo ""
    echo -e "  ${CYAN}ITU-T (International):${NC} Zone-Area-SP Identifier"
    echo -e "                         (3 bits - 8 bits - 3 bits)"
    echo -e "                         Example: ${GREEN}2-125-3${NC}"
    echo ""

    print_subheader "Link Types"
    echo ""
    echo -e "  ┌──────────┬──────────────────────────────────────────┐"
    echo -e "  │ ${BOLD}Type${NC}     │ ${BOLD}Description${NC}                              │"
    echo -e "  ├──────────┼──────────────────────────────────────────┤"
    echo -e "  │ A-Link   │ SSP <──> STP (Access link)              │"
    echo -e "  │ B-Link   │ STP <──> STP same level (Bridge)        │"
    echo -e "  │ C-Link   │ Mated STP pair (Cross link)             │"
    echo -e "  │ D-Link   │ STP <──> STP different level (Diagonal) │"
    echo -e "  │ E-Link   │ SSP <──> alternate STP (Extended)       │"
    echo -e "  │ F-Link   │ SSP <──> SSP directly (Fully assoc.)    │"
    echo -e "  └──────────┴──────────────────────────────────────────┘"
    echo ""

    press_continue

    clear_screen
    print_header "LESSON 4: QUIZ"

    quiz_question \
        "What is the function of an STP (Signal Transfer Point)?" \
        "B" \
        "To originate and terminate phone calls" \
        "To route SS7 signaling messages between nodes" \
        "To store subscriber data" \
        "To convert analog signals to digital" \
        "STPs are essentially the routers of the SS7 network. They receive signaling messages and forward them toward their destination."

    QUIZ_TOTAL=$((QUIZ_TOTAL + 1))
    [[ "$answer" == "B" ]] && QUIZ_SCORE=$((QUIZ_SCORE + 1))

    press_continue
}

#==============================================================================
# LESSON 5: MTP - MESSAGE TRANSFER PART
#==============================================================================
lesson_5_mtp() {
    CURRENT_LESSON=5
    clear_screen
    print_header "LESSON 5: MTP - MESSAGE TRANSFER PART"
    show_progress
    echo ""

    echo -e "${WHITE}  MTP is the foundation of SS7, handling reliable message${NC}"
    echo -e "${WHITE}  delivery across the signaling network.${NC}"
    echo ""

    print_subheader "MTP Level 1 (Physical Layer)"
    echo ""
    echo -e "  ${GREEN}•${NC} Defines the physical and electrical characteristics"
    echo -e "  ${GREEN}•${NC} Signaling data links:"
    echo -e "    - DS0: 56/64 kbps (North America)"
    echo -e "    - E1:  2.048 Mbps (International)"
    echo -e "    - T1:  1.544 Mbps (North America)"
    echo -e "  ${GREEN}•${NC} Digital signaling over dedicated timeslots"
    echo ""

    print_subheader "MTP Level 2 (Data Link Layer)"
    echo ""
    echo -e "  ${GREEN}•${NC} Ensures reliable transmission between two directly"
    echo -e "    connected signaling points"
    echo -e "  ${GREEN}•${NC} Functions:"
    echo -e "    - Frame delimiting (flags)"
    echo -e "    - Error detection (CRC-16)"
    echo -e "    - Error correction (retransmission)"
    echo -e "    - Flow control"
    echo -e "    - Sequence numbering"
    echo ""

    echo -e "  ${CYAN}MTP2 Signal Unit Format:${NC}"
    echo ""
    echo -e "  ┌──────┬────┬────┬──────────┬─────┬─────┬──────┐"
    echo -e "  │ Flag │ BSN│FSN │   LI     │ SIO │ SIF │ CRC  │"
    echo -e "  │ 8bit │8bit│8bit│ 6/2 bits │8bit │var. │16bit │"
    echo -e "  └──────┴────┴────┴──────────┴─────┴─────┴──────┘"
    echo ""
    echo -e "  ${WHITE}BSN${NC} = Backward Sequence Number (acknowledgment)"
    echo -e "  ${WHITE}FSN${NC} = Forward Sequence Number"
    echo -e "  ${WHITE}LI${NC}  = Length Indicator"
    echo -e "  ${WHITE}SIO${NC} = Service Information Octet"
    echo -e "  ${WHITE}SIF${NC} = Signaling Information Field (payload)"
    echo ""

    echo -e "  ${CYAN}Three types of Signal Units:${NC}"
    echo ""
    echo -e "  ┌──────────────────────────────────────────────────┐"
    echo -e "  │ ${BOLD}FISU${NC} - Fill-In Signal Unit        (LI = 0)       │"
    echo -e "  │        Sent when no data; keeps link alive       │"
    echo -e "  ├──────────────────────────────────────────────────┤"
    echo -e "  │ ${BOLD}LSSU${NC} - Link Status Signal Unit    (LI = 1 or 2)  │"
    echo -e "  │        Link alignment and status                 │"
    echo -e "  ├──────────────────────────────────────────────────┤"
    echo -e "  │ ${BOLD}MSU${NC}  - Message Signal Unit         (LI > 2)      │"
    echo -e "  │        Carries actual signaling data (payload)   │"
    echo -e "  └──────────────────────────────────────────────────┘"
    echo ""

    press_continue
    clear_screen
    print_header "LESSON 5: MTP LEVEL 3 (NETWORK LAYER)"
    echo ""

    print_subheader "MTP Level 3 (Network Layer)"
    echo ""
    echo -e "  ${GREEN}•${NC} ${BOLD}Signaling Message Handling (SMH):${NC}"
    echo -e "    - Message routing (based on DPC - Destination Point Code)"
    echo -e "    - Message discrimination (is this message for me?)"
    echo -e "    - Message distribution (which user part gets it?)"
    echo ""
    echo -e "  ${GREEN}•${NC} ${BOLD}Signaling Network Management (SNM):${NC}"
    echo -e "    - Link management"
    echo -e "    - Route management"
    echo -e "    - Traffic management"
    echo ""

    echo -e "  ${CYAN}MTP3 Routing Label (ANSI):${NC}"
    echo ""
    echo -e "  ┌──────────────┬──────────────┬──────────┐"
    echo -e "  │     DPC      │     OPC      │   SLS    │"
    echo -e "  │  24 bits     │   24 bits    │  8 bits  │"
    echo -e "  │ (Dest Point  │ (Orig Point  │(Link     │"
    echo -e "  │   Code)      │   Code)      │ Select)  │"
    echo -e "  └──────────────┴──────────────┴──────────┘"
    echo ""
    echo -e "  ${WHITE}DPC${NC} = Where the message is going"
    echo -e "  ${WHITE}OPC${NC} = Where the message came from"
    echo -e "  ${WHITE}SLS${NC} = Used for load balancing across links"
    echo ""

    press_continue

    clear_screen
    print_header "LESSON 5: QUIZ"

    quiz_question \
        "What type of Signal Unit keeps the link alive when there is no data?" \
        "A" \
        "FISU (Fill-In Signal Unit)" \
        "LSSU (Link Status Signal Unit)" \
        "MSU (Message Signal Unit)" \
        "TSU (Timing Signal Unit)" \
        "FISUs are continuously sent on an idle link to maintain synchronization and provide acknowledgments."

    QUIZ_TOTAL=$((QUIZ_TOTAL + 1))
    [[ "$answer" == "A" ]] && QUIZ_SCORE=$((QUIZ_SCORE + 1))

    press_continue
}

#==============================================================================
# LESSON 6: SCCP
#==============================================================================
lesson_6_sccp() {
    CURRENT_LESSON=6
    clear_screen
    print_header "LESSON 6: SCCP - SIGNALING CONNECTION CONTROL PART"
    show_progress
    echo ""

    echo -e "${WHITE}  SCCP provides enhanced routing and addressing above MTP3.${NC}"
    echo -e "${WHITE}  While MTP3 routes by Point Code only, SCCP adds:${NC}"
    echo ""
    echo -e "  ${GREEN}•${NC} ${BOLD}Global Title (GT) addressing${NC}"
    echo -e "    - Uses phone numbers (E.164) or other identifiers"
    echo -e "    - Enables routing without knowing the destination Point Code"
    echo ""
    echo -e "  ${GREEN}•${NC} ${BOLD}Subsystem Number (SSN)${NC}"
    echo -e "    - Identifies the application at the destination"
    echo -e "    - Like a port number in TCP/IP"
    echo ""
    echo -e "  ${GREEN}•${NC} ${BOLD}Connection-oriented and connectionless services${NC}"
    echo ""

    print_subheader "SCCP Address Format"
    echo ""
    echo -e "  ┌─────────────────────────────────────────────────┐"
    echo -e "  │              SCCP Called Party Address           │"
    echo -e "  ├──────────────┬──────────────┬───────────────────┤"
    echo -e "  │ Address      │ Subsystem    │ Global Title      │"
    echo -e "  │ Indicator    │ Number (SSN) │ (Phone Number)    │"
    echo -e "  └──────────────┴──────────────┴───────────────────┘"
    echo ""

    print_subheader "Common Subsystem Numbers (SSN)"
    echo ""
    echo -e "  ┌──────┬────────────────────────────────────────┐"
    echo -e "  │ ${BOLD}SSN${NC}  │ ${BOLD}Application${NC}                            │"
    echo -e "  ├──────┼────────────────────────────────────────┤"
    echo -e "  │  0   │ SSN not known/not used                 │"
    echo -e "  │  1   │ SCCP Management (SCMG)                 │"
    echo -e "  │  6   │ HLR (Home Location Register)           │"
    echo -e "  │  7   │ VLR (Visitor Location Register)        │"
    echo -e "  │  8   │ MSC (Mobile Switching Center)           │"
    echo -e "  │  9   │ EIR (Equipment Identity Register)      │"
    echo -e "  │  10  │ AuC (Authentication Center)            │"
    echo -e "  │  145 │ MAP (for CAMEL Phase 1)                │"
    echo -e "  │  146 │ MAP (for CAMEL Phase 2)                │"
    echo -e "  │  249 │ PCAP (Positioning Calculation)         │"
    echo -e "  │  250 │ BSC (Base Station Controller)          │"
    echo -e "  └──────┴────────────────────────────────────────┘"
    echo ""

    print_subheader "Global Title Translation (GTT)"
    echo ""
    echo -e "  ${WHITE}When a message has a Global Title (phone number) instead${NC}"
    echo -e "  ${WHITE}of a Point Code, the STP performs ${BOLD}Global Title Translation:${NC}"
    echo ""
    echo -e "  1. SSP sends message with GT = +1-800-555-1234"
    echo -e "  2. STP receives message"
    echo -e "  3. STP looks up GT in translation table"
    echo -e "  4. STP finds: GT +1-800-555-1234 → PC 247-035-012, SSN 6"
    echo -e "  5. STP routes message to that Point Code"
    echo ""
    echo -e "     ┌─────┐   GT: +18005551234    ┌─────┐  PC: 247-035-012  ┌─────┐"
    echo -e "     │ SSP │ ─────────────────────> │ STP │ ────────────────> │ SCP │"
    echo -e "     └─────┘   (Phone Number)       └─────┘  (Translated)    │(HLR)│"
    echo -e "                                    (GTT)                     └─────┘"
    echo ""

    print_subheader "SCCP Service Classes"
    echo ""
    echo -e "  ${CYAN}Class 0:${NC} Basic connectionless (unordered)"
    echo -e "  ${CYAN}Class 1:${NC} Sequenced connectionless (ordered)"
    echo -e "  ${CYAN}Class 2:${NC} Basic connection-oriented"
    echo -e "  ${CYAN}Class 3:${NC} Flow control connection-oriented"
    echo ""
    print_note "Most SS7 applications (MAP, CAP) use SCCP Class 0."

    press_continue

    clear_screen
    print_header "LESSON 6: QUIZ"

    quiz_question \
        "What does Global Title Translation (GTT) do?" \
        "D" \
        "Converts voice to digital signals" \
        "Encrypts SS7 messages" \
        "Assigns phone numbers to subscribers" \
        "Converts phone numbers to Point Codes for routing" \
        "GTT translates a Global Title (like a phone number) into a destination Point Code and Subsystem Number for proper routing."

    QUIZ_TOTAL=$((QUIZ_TOTAL + 1))
    [[ "$answer" == "D" ]] && QUIZ_SCORE=$((QUIZ_SCORE + 1))

    press_continue
}

#==============================================================================
# LESSON 7: TCAP AND MAP
#==============================================================================
lesson_7_tcap_map() {
    CURRENT_LESSON=7
    clear_screen
    print_header "LESSON 7: TCAP & MAP - APPLICATION LAYERS"
    show_progress
    echo ""

    print_subheader "TCAP - Transaction Capabilities Application Part"
    echo ""
    echo -e "${WHITE}  TCAP provides a framework for invoking remote operations${NC}"
    echo -e "${WHITE}  (like a remote procedure call mechanism for telecoms).${NC}"
    echo ""
    echo -e "  ${BOLD}TCAP Components:${NC}"
    echo ""
    echo -e "  ${GREEN}•${NC} ${BOLD}Transaction Portion:${NC}"
    echo -e "    - Manages dialogues between nodes"
    echo -e "    - Transaction IDs (OTID, DTID)"
    echo -e "    - Message types: Begin, Continue, End, Abort"
    echo ""
    echo -e "  ${GREEN}•${NC} ${BOLD}Component Portion:${NC}"
    echo -e "    - Contains the actual operations"
    echo -e "    - Invoke, Return Result, Return Error, Reject"
    echo ""

    echo -e "  ${CYAN}TCAP Dialogue Flow:${NC}"
    echo ""
    echo -e "     Node A                                   Node B"
    echo -e "       │                                        │"
    echo -e "       │──── ${GREEN}TC-BEGIN${NC} (OTID=1234) ──────────>│"
    echo -e "       │     [Invoke: SendRoutingInfo]          │"
    echo -e "       │                                        │"
    echo -e "       │<─── ${GREEN}TC-END${NC} (DTID=1234) ─────────────│"
    echo -e "       │     [Return Result: MSISDN, IMSI]      │"
    echo -e "       │                                        │"
    echo ""

    print_subheader "MAP - Mobile Application Part"
    echo ""
    echo -e "${WHITE}  MAP is the most important SS7 application protocol for${NC}"
    echo -e "${WHITE}  GSM/UMTS mobile networks. It runs on top of TCAP.${NC}"
    echo ""
    echo -e "  ${BOLD}MAP Operations Categories:${NC}"
    echo ""
    echo -e "  ┌───────────────────────────────────────────────────────┐"
    echo -e "  │ ${BOLD}Category${NC}             │ ${BOLD}Example Operations${NC}              │"
    echo -e "  ├──────────────────────┼────────────────────────────────┤"
    echo -e "  │ Location Management  │ UpdateLocation                 │"
    echo -e "  │                      │ CancelLocation                 │"
    echo -e "  │                      │ SendRoutingInfo                │"
    echo -e "  ├──────────────────────┼────────────────────────────────┤"
    echo -e "  │ Subscriber Mgmt     │ InsertSubscriberData            │"
    echo -e "  │                      │ DeleteSubscriberData           │"
    echo -e "  ├──────────────────────┼────────────────────────────────┤"
    echo -e "  │ Fault Recovery       │ Reset                          │"
    echo -e "  │                      │ RestoreData                    │"
    echo -e "  ├──────────────────────┼────────────────────────────────┤"
    echo -e "  │ Authentication       │ SendAuthenticationInfo         │"
    echo -e "  │                      │ AuthenticationFailureReport    │"
    echo -e "  ├──────────────────────┼────────────────────────────────┤"
    echo -e "  │ SMS                  │ SendRoutingInfoForSM           │"
    echo -e "  │                      │ ForwardSM / MO-ForwardSM      │"
    echo -e "  │                      │ ReportSM-DeliveryStatus        │"
    echo -e "  ├──────────────────────┼────────────────────────────────┤"
    echo -e "  │ Supplementary Svc    │ RegisterSS, ActivateSS        │"
    echo -e "  │                      │ InterrogateSS, EraseSS        │"
    echo -e "  └──────────────────────┴────────────────────────────────┘"
    echo ""

    print_subheader "MAP Message Flow: Mobile Originated Call"
    echo ""
    echo -e "    ${YELLOW}Caller${NC}        ${CYAN}MSC/VLR${NC}           ${GREEN}HLR${NC}           ${CYAN}GMSC${NC}"
    echo -e "      │            │               │              │"
    echo -e "      │──SETUP────>│               │              │"
    echo -e "      │            │──SendRoutingInfo────────────>│"
    echo -e "      │            │               │<─ProvideRoamingNo─│"
    echo -e "      │            │               │──RoamingNo──>│"
    echo -e "      │            │<──RoutingInfo────────────────│"
    echo -e "      │            │               │              │"
    echo -e "      │            │═══════════════════Voice═════>│"
    echo -e "      │            │               │              │"
    echo ""

    press_continue

    clear_screen
    print_header "LESSON 7: QUIZ"

    quiz_question \
        "Which MAP operation is used to find where to route a call to a mobile subscriber?" \
        "C" \
        "UpdateLocation" \
        "InsertSubscriberData" \
        "SendRoutingInfo (SRI)" \
        "ForwardSM" \
        "SendRoutingInfo (SRI) queries the HLR to get routing information for delivering a call to a mobile subscriber."

    QUIZ_TOTAL=$((QUIZ_TOTAL + 1))
    [[ "$answer" == "C" ]] && QUIZ_SCORE=$((QUIZ_SCORE + 1))

    press_continue
}

#==============================================================================
# LESSON 8: ISUP
#==============================================================================
lesson_8_isup() {
    CURRENT_LESSON=8
    clear_screen
    print_header "LESSON 8: ISUP - ISDN USER PART"
    show_progress
    echo ""

    echo -e "${WHITE}  ISUP handles the setup, management, and teardown of${NC}"
    echo -e "${WHITE}  voice circuits (trunks) between telephone exchanges.${NC}"
    echo ""

    print_subheader "Key ISUP Messages"
    echo ""
    echo -e "  ┌───────┬─────────────────────────────────────────────────┐"
    echo -e "  │ ${BOLD}Abbr${NC}  │ ${BOLD}Message & Description${NC}                           │"
    echo -e "  ├───────┼─────────────────────────────────────────────────┤"
    echo -e "  │ ${GREEN}IAM${NC}   │ Initial Address Message                          │"
    echo -e "  │       │ First message sent to initiate a call           │"
    echo -e "  │       │ Contains: Called/Calling number, CIC            │"
    echo -e "  ├───────┼─────────────────────────────────────────────────┤"
    echo -e "  │ ${GREEN}ACM${NC}   │ Address Complete Message                         │"
    echo -e "  │       │ Called party is being alerted (ringing)         │"
    echo -e "  ├───────┼─────────────────────────────────────────────────┤"
    echo -e "  │ ${GREEN}ANM${NC}   │ Answer Message                                   │"
    echo -e "  │       │ Called party has answered - start billing       │"
    echo -e "  ├───────┼─────────────────────────────────────────────────┤"
    echo -e "  │ ${RED}REL${NC}   │ Release Message                                  │"
    echo -e "  │       │ Request to disconnect the call                  │"
    echo -e "  ├───────┼─────────────────────────────────────────────────┤"
    echo -e "  │ ${RED}RLC${NC}   │ Release Complete                                 │"
    echo -e "  │       │ Confirms circuit has been released              │"
    echo -e "  ├───────┼─────────────────────────────────────────────────┤"
    echo -e "  │ ${CYAN}SAM${NC}   │ Subsequent Address Message                       │"
    echo -e "  │       │ Additional dialed digits (overlap dialing)      │"
    echo -e "  ├───────┼─────────────────────────────────────────────────┤"
    echo -e "  │ ${CYAN}CPG${NC}   │ Call Progress                                    │"
    echo -e "  │       │ In-call status updates                          │"
    echo -e "  └───────┴─────────────────────────────────────────────────┘"
    echo ""

    print_subheader "ISUP Call Flow: Basic Call Setup"
    echo ""
    echo -e "    Calling SSP              Transit STP           Called SSP"
    echo -e "        │                        │                      │"
    echo -e "        │────── ${GREEN}IAM${NC} ────────────>│──── ${GREEN}IAM${NC} ───────────>│"
    echo -e "        │  (CIC=42, Called#)      │                     │"
    echo -e "        │                         │                     │ Ring!"
    echo -e "        │<───── ${GREEN}ACM${NC} ────────────│<─── ${GREEN}ACM${NC} ────────────│"
    echo -e "        │  (Ringing)              │                     │"
    echo -e "        │                         │                     │ Pickup!"
    echo -e "        │<───── ${GREEN}ANM${NC} ────────────│<─── ${GREEN}ANM${NC} ────────────│"
    echo -e "        │  (Billing starts)       │                     │"
    echo -e "        │                         │                     │"
    echo -e "        │═══════════════ ${WHITE}VOICE PATH${NC} ══════════════│"
    echo -e "        │                         │                     │"
    echo -e "        │────── ${RED}REL${NC} ────────────>│──── ${RED}REL${NC} ───────────>│"
    echo -e "        │  (Hangup)               │                     │"
    echo -e "        │<───── ${RED}RLC${NC} ────────────│<─── ${RED}RLC${NC} ────────────│"
    echo -e "        │  (Circuit free)         │                     │"
    echo ""

    print_subheader "CIC - Circuit Identification Code"
    echo ""
    echo -e "  ${WHITE}The CIC identifies which specific voice circuit (timeslot)${NC}"
    echo -e "  ${WHITE}on a trunk group is used for the call.${NC}"
    echo ""
    echo -e "  ${CYAN}Example:${NC} A T1 trunk has 24 channels → CIC 1-24"
    echo -e "           An E1 trunk has 32 channels → CIC 1-32"
    echo ""

    press_continue

    clear_screen
    print_header "LESSON 8: QUIZ"

    quiz_question \
        "Which ISUP message indicates the called party has answered?" \
        "B" \
        "ACM (Address Complete Message)" \
        "ANM (Answer Message)" \
        "IAM (Initial Address Message)" \
        "CPG (Call Progress)" \
        "ANM (Answer Message) indicates the called party has picked up the phone. This is when billing typically starts."

    QUIZ_TOTAL=$((QUIZ_TOTAL + 1))
    [[ "$answer" == "B" ]] && QUIZ_SCORE=$((QUIZ_SCORE + 1))

    press_continue
}

#==============================================================================
# LESSON 9: SS7 SECURITY VULNERABILITIES (THEORY)
#==============================================================================
lesson_9_security() {
    CURRENT_LESSON=9
    clear_screen
    print_header "LESSON 9: SS7 SECURITY VULNERABILITIES"
    show_progress
    echo ""

    print_warning "This section is PURELY THEORETICAL for defensive understanding."
    print_warning "Exploiting SS7 vulnerabilities is a SERIOUS CRIME."
    echo ""

    print_subheader "Why is SS7 Vulnerable?"
    echo ""
    echo -e "  ${WHITE}SS7 was designed in the 1970s-80s with a fundamental${NC}"
    echo -e "  ${WHITE}trust assumption: ${RED}only trusted telecom operators${NC}"
    echo -e "  ${WHITE}would have access to the signaling network.${NC}"
    echo ""
    echo -e "  ${BOLD}Core Problem:${NC} ${RED}No authentication, no encryption${NC}"
    echo ""
    echo -e "  ┌──────────────────────────────────────────────────────┐"
    echo -e "  │ ${BOLD}Design Assumption${NC}         │ ${BOLD}Modern Reality${NC}            │"
    echo -e "  ├──────────────────────────┼───────────────────────────┤"
    echo -e "  │ Closed, trusted network  │ Interconnected globally   │"
    echo -e "  │ Few operators            │ Thousands of operators    │"
    echo -e "  │ Physical access only     │ SS7-over-IP (SIGTRAN)    │"
    echo -e "  │ Trusted actors only      │ Varied trust levels       │"
    echo -e "  │ No need for auth/crypto  │ Exploitable by insiders   │"
    echo -e "  └──────────────────────────┴───────────────────────────┘"
    echo ""

    print_subheader "Known Vulnerability Categories (Theoretical)"
    echo ""
    echo -e "  ${CYAN}1. Location Tracking:${NC}"
    echo -e "     ${WHITE}MAP operations like SendRoutingInfo (SRI) and${NC}"
    echo -e "     ${WHITE}ProvideSubscriberInfo (PSI) can reveal:${NC}"
    echo -e "     - Which cell tower a subscriber is connected to"
    echo -e "     - The serving MSC/VLR address"
    echo -e "     - Approximate geographic location"
    echo ""
    echo -e "     ${CYAN}Flow:${NC}"
    echo -e "     Attacker ──SRI(MSISDN)──> HLR ──returns──> IMSI + MSC address"
    echo -e "     Attacker ──PSI(IMSI)───> VLR ──returns──> Cell ID + Location"
    echo ""

    echo -e "  ${CYAN}2. Call/SMS Interception (Theoretical):${NC}"
    echo -e "     ${WHITE}UpdateLocation can re-register a subscriber to${NC}"
    echo -e "     ${WHITE}an attacker-controlled MSC address, causing the${NC}"
    echo -e "     ${WHITE}network to route calls/SMS through the attacker.${NC}"
    echo ""

    echo -e "  ${CYAN}3. Denial of Service:${NC}"
    echo -e "     ${WHITE}CancelLocation or DeleteSubscriberData can${NC}"
    echo -e "     ${WHITE}theoretically deregister subscribers from the network.${NC}"
    echo ""

    echo -e "  ${CYAN}4. Fraud:${NC}"
    echo -e "     ${WHITE}Manipulation of call routing to redirect calls${NC}"
    echo -e "     ${WHITE}to premium-rate numbers or bypass billing.${NC}"
    echo ""

    press_continue
    clear_screen
    print_header "LESSON 9: DEFENSES & MITIGATIONS"
    echo ""

    print_subheader "How Operators Defend Against SS7 Attacks"
    echo ""
    echo -e "  ${GREEN}1. SS7 Firewalls:${NC}"
    echo -e "     - Filter and inspect SS7 messages"
    echo -e "     - Block suspicious operations from unexpected sources"
    echo -e "     - Enforce policies on which operations are allowed"
    echo -e "     - Vendors: Cellusys, Mobileum, HAUD, Positive Tech"
    echo ""
    echo -e "  ${GREEN}2. SMS Home Routing:${NC}"
    echo -e "     - SMS messages are routed through home SMSC"
    echo -e "     - Prevents SRI-for-SM information disclosure"
    echo ""
    echo -e "  ${GREEN}3. Signaling Monitoring:${NC}"
    echo -e "     - Real-time detection of anomalous patterns"
    echo -e "     - Alerting on suspicious MAP operations"
    echo ""
    echo -e "  ${GREEN}4. Category-Based Filtering:${NC}"
    echo -e "     - Classify operations as Cat 1 (normal), Cat 2 (sensitive)"
    echo -e "     - Apply strict filtering on Cat 2+ operations"
    echo -e "     - GSMA IR.82 / FS.11 / FS.07 recommendations"
    echo ""
    echo -e "  ${GREEN}5. Network Segmentation:${NC}"
    echo -e "     - Limit which nodes can send which messages"
    echo -e "     - Validate OPC (Originating Point Code)"
    echo ""
    echo -e "  ${GREEN}6. Migration to Diameter (4G) and HTTP/2 (5G):${NC}"
    echo -e "     - Modern protocols have built-in security features"
    echo -e "     - TLS encryption, mutual authentication"
    echo -e "     - But new vulnerabilities exist in Diameter too"
    echo ""

    print_subheader "GSMA Security Recommendations"
    echo ""
    echo -e "  ┌────────────┬───────────────────────────────────────────┐"
    echo -e "  │ ${BOLD}Document${NC}   │ ${BOLD}Description${NC}                                 │"
    echo -e "  ├────────────┼───────────────────────────────────────────┤"
    echo -e "  │ FS.07      │ SS7 & SIGTRAN Security                   │"
    echo -e "  │ FS.11      │ SS7 Interconnect Security Guidelines     │"
    echo -e "  │ IR.82      │ SS7 Security Categories & Filtering      │"
    echo -e "  │ FS.19      │ Diameter Security                        │"
    echo -e "  │ IR.88      │ Diameter Roaming Security                │"
    echo -e "  └────────────┴───────────────────────────────────────────┘"
    echo ""

    press_continue

    clear_screen
    print_header "LESSON 9: QUIZ"

    quiz_question \
        "What is the FUNDAMENTAL security weakness of SS7?" \
        "C" \
        "It uses weak encryption (DES)" \
        "It has buffer overflow vulnerabilities" \
        "It was designed without authentication or encryption" \
        "It uses deprecated hash functions (MD5)" \
        "SS7 was designed in an era when only trusted telecom operators had access. It has NO built-in authentication or encryption, relying entirely on network-level trust."

    QUIZ_TOTAL=$((QUIZ_TOTAL + 1))
    [[ "$answer" == "C" ]] && QUIZ_SCORE=$((QUIZ_SCORE + 1))

    press_continue
}

#==============================================================================
# LESSON 10: MODERN ALTERNATIVES
#==============================================================================
lesson_10_modern() {
    CURRENT_LESSON=10
    clear_screen
    print_header "LESSON 10: MODERN ALTERNATIVES TO SS7"
    show_progress
    echo ""

    print_subheader "SIGTRAN - SS7 over IP"
    echo ""
    echo -e "${WHITE}  SIGTRAN adapts SS7 protocols to run over IP networks.${NC}"
    echo ""
    echo -e "  ┌─────────────────────────────────────────────────────┐"
    echo -e "  │  ${BOLD}SS7 Layer${NC}        │  ${BOLD}SIGTRAN Adaptation${NC}             │"
    echo -e "  ├──────────────────┼──────────────────────────────────┤"
    echo -e "  │  MTP3            │  M3UA (MTP3 User Adaptation)    │"
    echo -e "  │  MTP2            │  M2UA (MTP2 User Adaptation)    │"
    echo -e "  │  SCCP            │  SUA (SCCP User Adaptation)     │"
    echo -e "  │  ISUP            │  IUA (ISDN User Adaptation)     │"
    echo -e "  │  Transport       │  SCTP (Stream Control TP)       │"
    echo -e "  │  Network         │  IP                             │"
    echo -e "  └──────────────────┴──────────────────────────────────┘"
    echo ""
    echo -e "  ${CYAN}SIGTRAN Stack:${NC}"
    echo ""
    echo -e "  ┌──────────────────┐"
    echo -e "  │ MAP/ISUP/etc.    │ ← SS7 User Parts (unchanged)"
    echo -e "  ├──────────────────┤"
    echo -e "  │ M3UA/SUA         │ ← Adaptation Layer"
    echo -e "  ├──────────────────┤"
    echo -e "  │ SCTP             │ ← Reliable Transport (replaces MTP2)"
    echo -e "  ├──────────────────┤"
    echo -e "  │ IP               │ ← Network Layer"
    echo -e "  └──────────────────┘"
    echo ""

    print_subheader "Diameter Protocol (4G/LTE)"
    echo ""
    echo -e "${WHITE}  Diameter is the signaling protocol for 4G/LTE networks,${NC}"
    echo -e "${WHITE}  designed as a successor to SS7/MAP.${NC}"
    echo ""
    echo -e "  ${GREEN}Improvements over SS7:${NC}"
    echo -e "  ${GREEN}•${NC} Built-in TLS/IPsec support"
    echo -e "  ${GREEN}•${NC} Peer-based (not hierarchical)"
    echo -e "  ${GREEN}•${NC} AVP (Attribute-Value Pair) based - extensible"
    echo -e "  ${GREEN}•${NC} TCP/SCTP transport"
    echo -e "  ${GREEN}•${NC} Better error handling"
    echo ""
    echo -e "  ${CYAN}SS7 → Diameter Mapping:${NC}"
    echo ""
    echo -e "  ┌────────────────┬────────────────────┬─────────────┐"
    echo -e "  │ ${BOLD}SS7${NC}            │ ${BOLD}Diameter${NC}             │ ${BOLD}Interface${NC}   │"
    echo -e "  ├────────────────┼────────────────────┼─────────────┤"
    echo -e "  │ MAP (HLR)      │ HSS (Home Sub Svr) │ S6a, S6d    │"
    echo -e "  │ MAP (Auth)     │ Diameter EAP/AKA   │ SWx         │"
    echo -e "  │ CAP (Charging) │ Diameter Ro/Rf     │ Gy, Gz      │"
    echo -e "  │ ISUP           │ SIP/SDP (IMS)      │ Mx, Mw      │"
    echo -e "  └────────────────┴────────────────────┴─────────────┘"
    echo ""

    print_subheader "5G Service-Based Architecture"
    echo ""
    echo -e "  ${WHITE}5G replaces both SS7 and Diameter with:${NC}"
    echo -e "  ${GREEN}•${NC} HTTP/2 based signaling"
    echo -e "  ${GREEN}•${NC} RESTful APIs (JSON)"
    echo -e "  ${GREEN}•${NC} Service-Based Architecture (SBA)"
    echo -e "  ${GREEN}•${NC} TLS 1.3 mandatory"
    echo -e "  ${GREEN}•${NC} OAuth 2.0 for authorization"
    echo -e "  ${GREEN}•${NC} SEPP (Security Edge Protection Proxy) for roaming"
    echo ""

    echo -e "  ${CYAN}Evolution Summary:${NC}"
    echo ""
    echo -e "    ${RED}2G/3G${NC}          ${YELLOW}4G/LTE${NC}           ${GREEN}5G NR${NC}"
    echo -e "  ┌─────────┐   ┌──────────┐    ┌───────────┐"
    echo -e "  │  SS7    │──>│ Diameter  │──> │ HTTP/2    │"
    echo -e "  │  MAP    │   │ S6a/S6d   │    │ RESTful   │"
    echo -e "  │  (No    │   │ (TLS     │    │ (TLS 1.3  │"
    echo -e "  │  Auth)  │   │  option) │    │  OAuth2)  │"
    echo -e "  └─────────┘   └──────────┘    └───────────┘"
    echo -e "  No Security    Better Security  Best Security"
    echo ""

    press_continue

    clear_screen
    print_header "LESSON 10: QUIZ"

    quiz_question \
        "What transport protocol does SIGTRAN use instead of MTP?" \
        "B" \
        "TCP only" \
        "SCTP (Stream Control Transmission Protocol)" \
        "UDP" \
        "HTTP/2" \
        "SIGTRAN uses SCTP, which provides multi-streaming, multi-homing, and ordered/unordered delivery - features specifically designed for signaling transport."

    QUIZ_TOTAL=$((QUIZ_TOTAL + 1))
    [[ "$answer" == "B" ]] && QUIZ_SCORE=$((QUIZ_SCORE + 1))

    press_continue
}

#==============================================================================
# FINAL SUMMARY AND SCORE
#==============================================================================
lesson_final() {
    clear_screen
    print_header "COURSE COMPLETE: SS7 EDUCATION"
    echo ""

    echo -e "  ${GREEN}${BOLD}Congratulations! You've completed the SS7 course.${NC}"
    echo ""

    print_subheader "What You Learned"
    echo ""
    echo -e "  ${GREEN}✓${NC} SS7 fundamentals and out-of-band signaling"
    echo -e "  ${GREEN}✓${NC} History from SS5 phreaking to SS7"
    echo -e "  ${GREEN}✓${NC} Protocol stack: MTP, SCCP, TCAP, MAP, ISUP"
    echo -e "  ${GREEN}✓${NC} Network architecture: SSP, STP, SCP"
    echo -e "  ${GREEN}✓${NC} Point Codes and Global Title Translation"
    echo -e "  ${GREEN}✓${NC} Signal Unit types (FISU, LSSU, MSU)"
    echo -e "  ${GREEN}✓${NC} SCCP addressing and Subsystem Numbers"
    echo -e "  ${GREEN}✓${NC} TCAP transaction management"
    echo -e "  ${GREEN}✓${NC} MAP operations for mobile networks"
    echo -e "  ${GREEN}✓${NC} ISUP call setup and teardown"
    echo -e "  ${GREEN}✓${NC} Security vulnerabilities and defenses"
    echo -e "  ${GREEN}✓${NC} Evolution: SIGTRAN, Diameter, 5G HTTP/2"
    echo ""

    print_subheader "Quiz Results"
    echo ""
    local pct=0
    if [[ $QUIZ_TOTAL -gt 0 ]]; then
        pct=$(( (QUIZ_SCORE * 100) / QUIZ_TOTAL ))
    fi

    echo -e "  Score: ${BOLD}${QUIZ_SCORE}/${QUIZ_TOTAL}${NC} (${pct}%)"
    echo ""

    if [[ $pct -ge 90 ]]; then
        echo -e "  ${GREEN}${BOLD}  ★★★ EXCELLENT! ★★★${NC}"
        echo -e "  ${GREEN}  You have a strong understanding of SS7!${NC}"
    elif [[ $pct -ge 70 ]]; then
        echo -e "  ${CYAN}${BOLD}  ★★ GOOD JOB! ★★${NC}"
        echo -e "  ${CYAN}  Solid understanding with room to grow.${NC}"
    elif [[ $pct -ge 50 ]]; then
        echo -e "  ${YELLOW}${BOLD}  ★ FAIR ★${NC}"
        echo -e "  ${YELLOW}  Consider reviewing the lessons again.${NC}"
    else
        echo -e "  ${RED}  NEEDS IMPROVEMENT${NC}"
        echo -e "  ${RED}  Run the course again for better understanding.${NC}"
    fi

    echo ""
    print_subheader "Further Reading"
    echo ""
    echo -e "  ${CYAN}•${NC} ITU-T Q.700 Series - SS7 Protocol Specifications"
    echo -e "  ${CYAN}•${NC} 3GPP TS 29.002 - MAP Protocol Specification"
    echo -e "  ${CYAN}•${NC} 3GPP TS 29.272 - Diameter S6a/S6d Interface"
    echo -e "  ${CYAN}•${NC} GSMA FS.07 - SS7 & SIGTRAN Security"
    echo -e "  ${CYAN}•${NC} GSMA FS.11 - SS7 Interconnect Security"
    echo -e "  ${CYAN}•${NC} RFC 4666 - M3UA (MTP3 User Adaptation Layer)"
    echo -e "  ${CYAN}•${NC} RFC 4960 - SCTP (Stream Control Transmission Protocol)"
    echo -e "  ${CYAN}•${NC} RFC 6733 - Diameter Base Protocol"
    echo ""

    print_warning "Remember: Knowledge of SS7 should only be used for"
    print_warning "legitimate purposes: network defense, academic study,"
    print_warning "and authorized security assessments."
    echo ""
    echo -e "  ${WHITE}Thank you for taking this course!${NC}"
    echo ""
}

#==============================================================================
# MAIN MENU
#==============================================================================
main_menu() {
    while true; do
        clear_screen
        print_header "SS7 EDUCATIONAL COURSE - MAIN MENU"
        echo ""
        echo -e "  ${CYAN} 0.${NC}  Welcome & Disclaimer"
        echo -e "  ${CYAN} 1.${NC}  What is SS7?"
        echo -e "  ${CYAN} 2.${NC}  History & Evolution"
        echo -e "  ${CYAN} 3.${NC}  SS7 Protocol Stack (OSI Mapping)"
        echo -e "  ${CYAN} 4.${NC}  SS7 Network Architecture"
        echo -e "  ${CYAN} 5.${NC}  MTP - Message Transfer Part"
        echo -e "  ${CYAN} 6.${NC}  SCCP - Signaling Connection Control Part"
        echo -e "  ${CYAN} 7.${NC}  TCAP & MAP - Application Layers"
        echo -e "  ${CYAN} 8.${NC}  ISUP - ISDN User Part"
        echo -e "  ${CYAN} 9.${NC}  SS7 Security Vulnerabilities (Theory)"
        echo -e "  ${CYAN}10.${NC}  Modern Alternatives (Diameter, 5G)"
        echo ""
        echo -e "  ${GREEN} A.${NC}  Run ALL lessons sequentially"
        echo -e "  ${RED} Q.${NC}  Quit"
        echo ""
        echo -ne "  ${YELLOW}Select a lesson (0-10, A, or Q): ${NC}"
        read -r choice

        case "$choice" in
            0)  lesson_welcome ;;
            1)  lesson_1_what_is_ss7 ;;
            2)  lesson_2_history ;;
            3)  lesson_3_protocol_stack ;;
            4)  lesson_4_architecture ;;
            5)  lesson_5_mtp ;;
            6)  lesson_6_sccp ;;
            7)  lesson_7_tcap_map ;;
            8)  lesson_8_isup ;;
            9)  lesson_9_security ;;
            10) lesson_10_modern ;;
            [Aa])
                lesson_welcome
                lesson_1_what_is_ss7
                lesson_2_history
                lesson_3_protocol_stack
                lesson_4_architecture
                lesson_5_mtp
                lesson_6_sccp
                lesson_7_tcap_map
                lesson_8_isup
                lesson_9_security
                lesson_10_modern
                lesson_final
                press_continue
                ;;
            [Qq])
                echo ""
                echo -e "  ${GREEN}Thank you for studying SS7! Goodbye.${NC}"
                echo ""
                exit 0
                ;;
            *)
                echo -e "  ${RED}Invalid selection. Please try again.${NC}"
                sleep 1
                ;;
        esac
    done
}

#==============================================================================
# ENTRY POINT
#==============================================================================
main() {
    # Check terminal capabilities
    if [[ -z "$TERM" ]]; then
        export TERM=xterm-256color
    fi

    # Start the course
    main_menu
}

main "$@"
