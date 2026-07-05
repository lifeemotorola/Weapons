#!/data/data/com.termux/files/usr/bin/bash

#============================================================================
#  CYBER SECURITY FULL COURSE IN TERMUX
#  Author: CyberSec Academy
#  Version: 3.0
#  Description: Comprehensive cybersecurity course with theory + practicals
#============================================================================

# ========================= COLORS & FORMATTING =========================
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
MAGENTA='\033[1;35m'
CYAN='\033[1;36m'
WHITE='\033[1;37m'
ORANGE='\033[0;33m'
BOLD='\033[1m'
DIM='\033[2m'
UNDERLINE='\033[4m'
BLINK='\033[5m'
REVERSE='\033[7m'
RESET='\033[0m'
BG_RED='\033[41m'
BG_GREEN='\033[42m'
BG_BLUE='\033[44m'
BG_CYAN='\033[46m'

# ========================= GLOBAL VARIABLES =========================
COURSE_DIR="$HOME/CyberSecCourse"
LABS_DIR="$COURSE_DIR/labs"
NOTES_DIR="$COURSE_DIR/notes"
TOOLS_DIR="$COURSE_DIR/tools"
SCRIPTS_DIR="$COURSE_DIR/scripts"
WORDLISTS_DIR="$COURSE_DIR/wordlists"
LOG_FILE="$COURSE_DIR/course_progress.log"
PROGRESS_FILE="$COURSE_DIR/.progress"
VERSION="3.0"

# ========================= UTILITY FUNCTIONS =========================

setup_directories() {
    mkdir -p "$COURSE_DIR" "$LABS_DIR" "$NOTES_DIR" "$TOOLS_DIR" "$SCRIPTS_DIR" "$WORDLISTS_DIR"
    touch "$LOG_FILE"
    [[ ! -f "$PROGRESS_FILE" ]] && echo "0" > "$PROGRESS_FILE"
}

log_progress() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

get_progress() {
    cat "$PROGRESS_FILE" 2>/dev/null || echo "0"
}

update_progress() {
    local current=$(get_progress)
    local new_progress=$((current + 1))
    echo "$new_progress" > "$PROGRESS_FILE"
}

clear_screen() {
    clear
}

press_continue() {
    echo ""
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "${CYAN}  Press [ENTER] to continue...${RESET}"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    read -r
}

print_header() {
    clear_screen
    echo -e "${RED}"
    echo "╔══════════════════════════════════════════════════════════════════╗"
    echo "║                                                                ║"
    echo "║     ██████╗██╗   ██╗██████╗ ███████╗██████╗                   ║"
    echo "║    ██╔════╝╚██╗ ██╔╝██╔══██╗██╔════╝██╔══██╗                  ║"
    echo "║    ██║      ╚████╔╝ ██████╔╝█████╗  ██████╔╝                  ║"
    echo "║    ██║       ╚██╔╝  ██╔══██╗██╔══╝  ██╔══██╗                  ║"
    echo "║    ╚██████╗   ██║   ██████╔╝███████╗██║  ██║                   ║"
    echo "║     ╚═════╝   ╚═╝   ╚═════╝ ╚══════╝╚═╝  ╚═╝                 ║"
    echo "║                                                                ║"
    echo "║    ███████╗███████╗ ██████╗██╗   ██╗██████╗ ██╗████████╗██╗   ║"
    echo "║    ██╔════╝██╔════╝██╔════╝██║   ██║██╔══██╗██║╚══██╔══╝╚██╗  ║"
    echo "║    ███████╗█████╗  ██║     ██║   ██║██████╔╝██║   ██║    ╚██╗ ║"
    echo "║    ╚════██║██╔══╝  ██║     ██║   ██║██╔══██╗██║   ██║    ██╔╝ ║"
    echo "║    ███████║███████╗╚██████╗╚██████╔╝██║  ██║██║   ██║   ██╔╝  ║"
    echo "║    ╚══════╝╚══════╝ ╚═════╝ ╚═════╝ ╚═╝  ╚═╝╚═╝   ╚═╝   ╚═╝   ║"
    echo "║                                                                ║"
    echo "║          ████████╗███████╗██████╗ ███╗   ███╗██╗   ██╗██╗  ██╗ ║"
    echo "║          ╚══██╔══╝██╔════╝██╔══██╗████╗ ████║██║   ██║╚██╗██╔╝ ║"
    echo "║             ██║   █████╗  ██████╔╝██╔████╔██║██║   ██║ ╚███╔╝  ║"
    echo "║             ██║   ██╔══╝  ██╔══██╗██║╚██╔╝██║██║   ██║ ██╔██╗  ║"
    echo "║             ██║   ███████╗██║  ██║██║ ╚═╝ ██║╚██████╔╝██╔╝ ██╗ ║"
    echo "║             ╚═╝   ╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝ ╚═════╝╚═╝  ╚═╝ ║"
    echo "║                                                                ║"
    echo "║            ${WHITE}[ FULL CYBERSECURITY COURSE v${VERSION} ]${RED}              ║"
    echo "║            ${CYAN}[ Educational Purposes Only ]${RED}                    ║"
    echo "╚══════════════════════════════════════════════════════════════════╝"
    echo -e "${RESET}"
}

print_section_header() {
    local title="$1"
    local module="$2"
    clear_screen
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════════╗${RESET}"
    echo -e "${CYAN}║${WHITE}  MODULE ${module}: ${title}${CYAN}$(printf '%*s' $((52 - ${#title} - ${#module})) '')║${RESET}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════════╝${RESET}"
    echo ""
}

print_sub_header() {
    local title="$1"
    echo ""
    echo -e "${GREEN}┌──────────────────────────────────────────────────────────────┐${RESET}"
    echo -e "${GREEN}│${WHITE}  ► ${title}${GREEN}$(printf '%*s' $((56 - ${#title})) '')│${RESET}"
    echo -e "${GREEN}└──────────────────────────────────────────────────────────────┘${RESET}"
    echo ""
}

print_topic() {
    echo -e "${YELLOW}  ◆ $1${RESET}"
}

print_info() {
    echo -e "${WHITE}    $1${RESET}"
}

print_command() {
    echo -e "${GREEN}    \$ ${CYAN}$1${RESET}"
}

print_warning() {
    echo -e "${RED}    ⚠ WARNING: $1${RESET}"
}

print_note() {
    echo -e "${MAGENTA}    📝 NOTE: $1${RESET}"
}

print_example() {
    echo -e "${BLUE}    📋 EXAMPLE: $1${RESET}"
}

print_code_block() {
    echo -e "${DIM}    ┌─────────────────────────────────────────────────────┐${RESET}"
    while IFS= read -r line; do
        echo -e "${DIM}    │${CYAN} $line${DIM}$(printf '%*s' $((53 - ${#line})) '')│${RESET}"
    done <<< "$1"
    echo -e "${DIM}    └─────────────────────────────────────────────────────┘${RESET}"
}

quiz_question() {
    local question="$1"
    local option_a="$2"
    local option_b="$3"
    local option_c="$4"
    local option_d="$5"
    local correct="$6"
    local explanation="$7"

    echo ""
    echo -e "${YELLOW}╔══════════════════════════════════════════════════════════╗${RESET}"
    echo -e "${YELLOW}║${WHITE}  QUIZ QUESTION${YELLOW}                                         ║${RESET}"
    echo -e "${YELLOW}╠══════════════════════════════════════════════════════════╣${RESET}"
    echo -e "${YELLOW}║${RESET} ${question}"
    echo -e "${YELLOW}║${RESET}"
    echo -e "${YELLOW}║${GREEN}  A) ${WHITE}${option_a}${RESET}"
    echo -e "${YELLOW}║${GREEN}  B) ${WHITE}${option_b}${RESET}"
    echo -e "${YELLOW}║${GREEN}  C) ${WHITE}${option_c}${RESET}"
    echo -e "${YELLOW}║${GREEN}  D) ${WHITE}${option_d}${RESET}"
    echo -e "${YELLOW}╚══════════════════════════════════════════════════════════╝${RESET}"

    echo -ne "${CYAN}  Your answer (A/B/C/D): ${RESET}"
    read -r answer
    answer=$(echo "$answer" | tr '[:lower:]' '[:upper:]')

    if [[ "$answer" == "$correct" ]]; then
        echo -e "${GREEN}  ✓ CORRECT! ${explanation}${RESET}"
    else
        echo -e "${RED}  ✗ INCORRECT. The correct answer is ${correct}.${RESET}"
        echo -e "${YELLOW}  ${explanation}${RESET}"
    fi
    echo ""
}

# ========================= INSTALLATION MODULE =========================

install_dependencies() {
    print_section_header "ENVIRONMENT SETUP" "0"

    echo -e "${CYAN}  Setting up your CyberSec learning environment...${RESET}"
    echo ""

    echo -e "${YELLOW}  [1/8] Updating package repositories...${RESET}"
    pkg update -y 2>/dev/null
    pkg upgrade -y 2>/dev/null

    echo -e "${YELLOW}  [2/8] Installing core utilities...${RESET}"
    pkg install -y coreutils curl wget git openssl 2>/dev/null

    echo -e "${YELLOW}  [3/8] Installing network tools...${RESET}"
    pkg install -y nmap net-tools dnsutils whois traceroute 2>/dev/null

    echo -e "${YELLOW}  [4/8] Installing Python environment...${RESET}"
    pkg install -y python python-pip 2>/dev/null
    pip install requests scapy pycryptodome 2>/dev/null

    echo -e "${YELLOW}  [5/8] Installing development tools...${RESET}"
    pkg install -y clang make vim nano 2>/dev/null

    echo -e "${YELLOW}  [6/8] Installing crypto tools...${RESET}"
    pkg install -y gnupg hashcat john 2>/dev/null

    echo -e "${YELLOW}  [7/8] Installing web tools...${RESET}"
    pkg install -y php ruby perl 2>/dev/null

    echo -e "${YELLOW}  [8/8] Installing additional tools...${RESET}"
    pkg install -y hydra sqlmap nikto tcpdump 2>/dev/null

    echo ""
    echo -e "${GREEN}  ✓ Environment setup complete!${RESET}"

    setup_directories
    log_progress "Environment setup completed"
    press_continue
}

# ========================= MODULE 1: FUNDAMENTALS =========================

module_1() {
    print_section_header "CYBERSECURITY FUNDAMENTALS" "1"
    echo -e "${WHITE}  This module covers the foundational concepts of cybersecurity.${RESET}"
    echo ""
    echo -e "${CYAN}  Lessons:${RESET}"
    echo -e "${WHITE}  1. What is Cybersecurity?${RESET}"
    echo -e "${WHITE}  2. CIA Triad${RESET}"
    echo -e "${WHITE}  3. Types of Threats & Attacks${RESET}"
    echo -e "${WHITE}  4. Security Domains${RESET}"
    echo -e "${WHITE}  5. Cyber Kill Chain${RESET}"
    echo -e "${WHITE}  6. MITRE ATT&CK Framework${RESET}"
    echo -e "${WHITE}  7. Career Paths in Cybersecurity${RESET}"
    echo -e "${WHITE}  8. Legal & Ethical Considerations${RESET}"
    echo -e "${WHITE}  9. Module Quiz${RESET}"
    echo -e "${WHITE}  0. Back to Main Menu${RESET}"
    echo ""
    echo -ne "${CYAN}  Select lesson [0-9]: ${RESET}"
    read -r lesson

    case $lesson in
        1) module_1_lesson_1 ;;
        2) module_1_lesson_2 ;;
        3) module_1_lesson_3 ;;
        4) module_1_lesson_4 ;;
        5) module_1_lesson_5 ;;
        6) module_1_lesson_6 ;;
        7) module_1_lesson_7 ;;
        8) module_1_lesson_8 ;;
        9) module_1_quiz ;;
        0) return ;;
        *) echo -e "${RED}  Invalid option${RESET}"; sleep 1; module_1 ;;
    esac
    module_1
}

module_1_lesson_1() {
    print_section_header "WHAT IS CYBERSECURITY?" "1.1"

    print_sub_header "Definition"
    print_info "Cybersecurity is the practice of protecting systems, networks,"
    print_info "programs, and data from digital attacks, unauthorized access,"
    print_info "damage, or theft."
    echo ""

    print_sub_header "Why Cybersecurity Matters"
    print_topic "Data Protection"
    print_info "Personal data, financial info, intellectual property"
    print_info "are all targets for cybercriminals."
    echo ""
    print_topic "Financial Impact"
    print_info "Average cost of a data breach: \$4.45 million (2023)"
    print_info "Cybercrime costs predicted: \$10.5 trillion by 2025"
    echo ""
    print_topic "National Security"
    print_info "Critical infrastructure (power grids, water systems)"
    print_info "Government systems and military operations"
    echo ""
    print_topic "Privacy"
    print_info "GDPR, HIPAA, CCPA - regulations protecting personal data"
    print_info "Individual right to privacy in the digital age"
    echo ""

    print_sub_header "Key Terminology"
    print_topic "Asset         - Anything of value (data, hardware, software)"
    print_topic "Vulnerability - Weakness that can be exploited"
    print_topic "Threat        - Potential cause of unwanted incident"
    print_topic "Risk          - Probability of threat exploiting vulnerability"
    print_topic "Exploit       - Code/technique that takes advantage of vulnerability"
    print_topic "Payload       - The malicious code delivered by an exploit"
    print_topic "Zero-Day      - Unknown vulnerability with no patch available"
    print_topic "Attack Vector - Path or means by which attacker gains access"
    print_topic "Attack Surface- Sum of all possible attack vectors"

    # Save notes
    cat > "$NOTES_DIR/module1_lesson1_notes.txt" << 'NOTES'
MODULE 1 - LESSON 1: WHAT IS CYBERSECURITY?
=============================================

Definition:
- Practice of protecting systems, networks, programs, and data
- Defending against digital attacks, unauthorized access, damage, theft

Key Terminology:
- Asset: Anything of value
- Vulnerability: Weakness that can be exploited
- Threat: Potential cause of unwanted incident
- Risk: Probability × Impact
- Exploit: Code taking advantage of vulnerability
- Payload: Malicious code delivered by exploit
- Zero-Day: Unknown vulnerability, no patch
- Attack Vector: Path attacker uses
- Attack Surface: All possible attack vectors

Why It Matters:
- Average breach cost: $4.45M
- Cybercrime predicted: $10.5T by 2025
NOTES

    echo -e "${GREEN}  📝 Notes saved to: $NOTES_DIR/module1_lesson1_notes.txt${RESET}"
    log_progress "Completed Module 1 Lesson 1"
    update_progress
    press_continue
}

module_1_lesson_2() {
    print_section_header "THE CIA TRIAD" "1.2"

    print_sub_header "Confidentiality"
    print_info "Ensuring information is accessible only to authorized parties."
    echo ""
    print_topic "Controls for Confidentiality:"
    print_info "• Encryption (AES, RSA, etc.)"
    print_info "• Access Control Lists (ACLs)"
    print_info "• Authentication mechanisms"
    print_info "• Data classification"
    print_info "• Physical security"
    echo ""
    print_example "Encrypting a file with OpenSSL:"
    print_command "openssl enc -aes-256-cbc -salt -in secret.txt -out secret.enc"
    echo ""

    print_sub_header "Integrity"
    print_info "Ensuring data is accurate, consistent, and unaltered."
    echo ""
    print_topic "Controls for Integrity:"
    print_info "• Hashing (MD5, SHA-256, SHA-512)"
    print_info "• Digital signatures"
    print_info "• Version control"
    print_info "• Checksums"
    print_info "• Input validation"
    echo ""
    print_example "Creating a SHA-256 hash:"
    print_command "echo 'Hello World' | sha256sum"
    echo ""
    print_info "Practical demonstration:"
    echo "Hello World" | sha256sum 2>/dev/null
    echo ""

    print_sub_header "Availability"
    print_info "Ensuring systems and data are accessible when needed."
    echo ""
    print_topic "Controls for Availability:"
    print_info "• Redundancy (RAID, clusters)"
    print_info "• Load balancing"
    print_info "• Backup & disaster recovery"
    print_info "• DDoS protection"
    print_info "• Failover systems"
    echo ""

    print_sub_header "Extended Models"
    print_topic "Parkerian Hexad (adds 3 more):"
    print_info "• Possession/Control"
    print_info "• Authenticity"
    print_info "• Utility"
    echo ""
    print_topic "DAD Triad (opposite of CIA):"
    print_info "• Disclosure (vs Confidentiality)"
    print_info "• Alteration (vs Integrity)"
    print_info "• Denial (vs Availability)"

    # Practical lab
    print_sub_header "🔬 PRACTICAL LAB: CIA in Action"
    echo ""
    print_info "Let's demonstrate each element:"
    echo ""

    # Confidentiality demo
    echo -e "${CYAN}  --- Confidentiality Demo ---${RESET}"
    echo "This is a secret message" > /tmp/cia_demo.txt
    openssl enc -aes-256-cbc -salt -in /tmp/cia_demo.txt -out /tmp/cia_demo.enc -k "password123" 2>/dev/null
    echo -e "${WHITE}    Original: $(cat /tmp/cia_demo.txt)${RESET}"
    echo -e "${WHITE}    Encrypted: $(xxd /tmp/cia_demo.enc 2>/dev/null | head -2)${RESET}"
    echo ""

    # Integrity demo
    echo -e "${CYAN}  --- Integrity Demo ---${RESET}"
    HASH1=$(echo "Original data" | sha256sum | awk '{print $1}')
    HASH2=$(echo "Modified data" | sha256sum | awk '{print $1}')
    echo -e "${WHITE}    Hash of 'Original data': ${GREEN}${HASH1:0:32}...${RESET}"
    echo -e "${WHITE}    Hash of 'Modified data': ${RED}${HASH2:0:32}...${RESET}"
    echo -e "${WHITE}    Even a small change produces completely different hash!${RESET}"
    echo ""

    # Cleanup
    rm -f /tmp/cia_demo.txt /tmp/cia_demo.enc

    log_progress "Completed Module 1 Lesson 2"
    update_progress
    press_continue
}

module_1_lesson_3() {
    print_section_header "TYPES OF THREATS & ATTACKS" "1.3"

    print_sub_header "Threat Actors"
    print_topic "1. Script Kiddies"
    print_info "   Low skill, use pre-made tools, motivated by curiosity/fun"
    echo ""
    print_topic "2. Hacktivists"
    print_info "   Politically motivated, target organizations for causes"
    print_info "   Example: Anonymous"
    echo ""
    print_topic "3. Cybercriminals"
    print_info "   Financially motivated, organized crime groups"
    print_info "   Ransomware, fraud, identity theft"
    echo ""
    print_topic "4. Nation-State Actors (APTs)"
    print_info "   Government-sponsored, highly sophisticated"
    print_info "   Examples: APT28 (Russia), APT41 (China), Lazarus (N. Korea)"
    echo ""
    print_topic "5. Insider Threats"
    print_info "   Current or former employees, contractors"
    print_info "   Can be malicious or negligent"
    echo ""

    print_sub_header "Types of Attacks"
    echo ""
    print_topic "A. Social Engineering"
    print_info "   • Phishing - Fraudulent emails/websites"
    print_info "   • Spear Phishing - Targeted phishing"
    print_info "   • Whaling - Targeting executives"
    print_info "   • Vishing - Voice phishing"
    print_info "   • Smishing - SMS phishing"
    print_info "   • Pretexting - Creating false scenarios"
    print_info "   • Baiting - Offering something enticing"
    print_info "   • Tailgating - Following authorized person"
    echo ""

    print_topic "B. Malware"
    print_info "   • Virus - Attaches to files, needs user action"
    print_info "   • Worm - Self-replicating, no user action needed"
    print_info "   • Trojan - Disguised as legitimate software"
    print_info "   • Ransomware - Encrypts files, demands payment"
    print_info "   • Spyware - Monitors user activity"
    print_info "   • Adware - Displays unwanted advertisements"
    print_info "   • Rootkit - Hides deep in OS, difficult to detect"
    print_info "   • Keylogger - Records keystrokes"
    print_info "   • Fileless Malware - Lives in memory only"
    echo ""

    print_topic "C. Network Attacks"
    print_info "   • DoS/DDoS - Flood target with traffic"
    print_info "   • Man-in-the-Middle (MitM) - Intercept communications"
    print_info "   • ARP Spoofing - Manipulate ARP tables"
    print_info "   • DNS Spoofing - Redirect DNS queries"
    print_info "   • Packet Sniffing - Capture network traffic"
    echo ""

    print_topic "D. Web Application Attacks"
    print_info "   • SQL Injection - Manipulate database queries"
    print_info "   • XSS (Cross-Site Scripting) - Inject scripts"
    print_info "   • CSRF (Cross-Site Request Forgery)"
    print_info "   • Directory Traversal"
    print_info "   • File Inclusion (LFI/RFI)"
    print_info "   • Command Injection"
    echo ""

    print_topic "E. Password Attacks"
    print_info "   • Brute Force - Try all combinations"
    print_info "   • Dictionary Attack - Use wordlist"
    print_info "   • Rainbow Table - Precomputed hashes"
    print_info "   • Credential Stuffing - Reuse leaked credentials"
    print_info "   • Password Spraying - Few passwords, many accounts"

    log_progress "Completed Module 1 Lesson 3"
    update_progress
    press_continue
}

module_1_lesson_4() {
    print_section_header "SECURITY DOMAINS" "1.4"

    print_sub_header "The 8 CISSP Domains"
    echo ""
    print_topic "1. Security & Risk Management"
    print_info "   Governance, compliance, risk assessment, policies"
    print_info "   Legal/regulatory issues, business continuity"
    echo ""
    print_topic "2. Asset Security"
    print_info "   Data classification, ownership, retention"
    print_info "   Privacy protection, secure handling"
    echo ""
    print_topic "3. Security Architecture & Engineering"
    print_info "   Security models, design principles"
    print_info "   Cryptography, physical security"
    echo ""
    print_topic "4. Communication & Network Security"
    print_info "   Network architecture, protocols, components"
    print_info "   Secure communication channels"
    echo ""
    print_topic "5. Identity & Access Management (IAM)"
    print_info "   Authentication, authorization, accountability"
    print_info "   Identity provisioning, SSO, MFA"
    echo ""
    print_topic "6. Security Assessment & Testing"
    print_info "   Vulnerability assessment, penetration testing"
    print_info "   Log reviews, code review, audits"
    echo ""
    print_topic "7. Security Operations"
    print_info "   Incident response, disaster recovery"
    print_info "   Monitoring, logging, investigations"
    echo ""
    print_topic "8. Software Development Security"
    print_info "   SDLC, secure coding, code review"
    print_info "   Software testing, DevSecOps"
    echo ""

    print_sub_header "Defense in Depth"
    print_info "Multiple layers of security controls:"
    echo ""
    print_info "  ┌─────────────────────────────────────┐"
    print_info "  │         Physical Security            │  ← Outermost"
    print_info "  │  ┌──────────────────────────────┐   │"
    print_info "  │  │     Network Security          │   │"
    print_info "  │  │  ┌────────────────────────┐  │   │"
    print_info "  │  │  │   Host Security         │  │   │"
    print_info "  │  │  │  ┌──────────────────┐  │  │   │"
    print_info "  │  │  │  │ Application Sec.  │  │  │   │"
    print_info "  │  │  │  │  ┌────────────┐  │  │  │   │"
    print_info "  │  │  │  │  │ Data Sec.  │  │  │  │   │  ← Innermost"
    print_info "  │  │  │  │  └────────────┘  │  │  │   │"
    print_info "  │  │  │  └──────────────────┘  │  │   │"
    print_info "  │  │  └────────────────────────┘  │   │"
    print_info "  │  └──────────────────────────────┘   │"
    print_info "  └─────────────────────────────────────┘"

    log_progress "Completed Module 1 Lesson 4"
    update_progress
    press_continue
}

module_1_lesson_5() {
    print_section_header "CYBER KILL CHAIN" "1.5"

    print_sub_header "Lockheed Martin Cyber Kill Chain"
    print_info "A framework describing stages of a cyber attack:"
    echo ""
    print_topic "Phase 1: RECONNAISSANCE"
    print_info "   Attacker gathers information about the target"
    print_info "   OSINT, scanning, social engineering research"
    print_info "   Defense: Minimize public information exposure"
    echo ""
    print_topic "Phase 2: WEAPONIZATION"
    print_info "   Creating malicious payload (exploit + backdoor)"
    print_info "   Crafting phishing emails, malicious documents"
    print_info "   Defense: Threat intelligence, sandbox analysis"
    echo ""
    print_topic "Phase 3: DELIVERY"
    print_info "   Transmitting weapon to target (email, web, USB)"
    print_info "   Defense: Email filtering, web proxy, user training"
    echo ""
    print_topic "Phase 4: EXPLOITATION"
    print_info "   Triggering the exploit (vulnerability execution)"
    print_info "   Defense: Patching, HIPS, DEP, ASLR"
    echo ""
    print_topic "Phase 5: INSTALLATION"
    print_info "   Installing malware on target system"
    print_info "   Defense: Endpoint detection, application whitelisting"
    echo ""
    print_topic "Phase 6: COMMAND & CONTROL (C2)"
    print_info "   Establishing communication channel to attacker"
    print_info "   Defense: Firewall, IDS/IPS, network monitoring"
    echo ""
    print_topic "Phase 7: ACTIONS ON OBJECTIVES"
    print_info "   Achieving the goal (data theft, destruction, etc.)"
    print_info "   Defense: DLP, data encryption, audit logging"
    echo ""

    print_sub_header "Visual Representation"
    echo -e "${CYAN}"
    echo "  RECON → WEAPONIZE → DELIVER → EXPLOIT → INSTALL → C2 → ACTION"
    echo "    ↑                                                        ↓"
    echo "    └────────── DEFENSE AT EVERY STAGE ──────────────────────┘"
    echo -e "${RESET}"

    log_progress "Completed Module 1 Lesson 5"
    update_progress
    press_continue
}

module_1_lesson_6() {
    print_section_header "MITRE ATT&CK FRAMEWORK" "1.6"

    print_sub_header "Overview"
    print_info "MITRE ATT&CK (Adversarial Tactics, Techniques, and Common Knowledge)"
    print_info "is a globally-accessible knowledge base of adversary tactics and"
    print_info "techniques based on real-world observations."
    echo ""

    print_sub_header "14 Tactics (Enterprise)"
    print_topic "1.  Reconnaissance       - Gathering information"
    print_topic "2.  Resource Development  - Establishing resources"
    print_topic "3.  Initial Access        - Getting into the network"
    print_topic "4.  Execution             - Running malicious code"
    print_topic "5.  Persistence           - Maintaining access"
    print_topic "6.  Privilege Escalation  - Gaining higher permissions"
    print_topic "7.  Defense Evasion       - Avoiding detection"
    print_topic "8.  Credential Access     - Stealing credentials"
    print_topic "9.  Discovery             - Understanding the environment"
    print_topic "10. Lateral Movement      - Moving through the network"
    print_topic "11. Collection            - Gathering target data"
    print_topic "12. Command and Control   - Communicating with attacker"
    print_topic "13. Exfiltration          - Stealing data"
    print_topic "14. Impact                - Manipulation/destruction"
    echo ""

    print_sub_header "How to Use ATT&CK"
    print_info "• Threat Intelligence - Map adversary behaviors"
    print_info "• Detection & Analytics - Build detection rules"
    print_info "• Assessment & Engineering - Evaluate security gaps"
    print_info "• Red Teaming - Simulate adversary techniques"
    echo ""
    print_note "Visit: https://attack.mitre.org for the full matrix"

    log_progress "Completed Module 1 Lesson 6"
    update_progress
    press_continue
}

module_1_lesson_7() {
    print_section_header "CAREER PATHS IN CYBERSECURITY" "1.7"

    print_sub_header "Offensive Security (Red Team)"
    print_topic "Penetration Tester"
    print_info "   Test systems for vulnerabilities"
    print_info "   Certifications: OSCP, CEH, GPEN"
    print_info "   Salary: \$80K - \$150K+"
    echo ""
    print_topic "Red Team Operator"
    print_info "   Simulate real-world attacks"
    print_info "   Certifications: OSCP, CRTO, GXPN"
    print_info "   Salary: \$100K - \$180K+"
    echo ""
    print_topic "Bug Bounty Hunter"
    print_info "   Find vulnerabilities in programs"
    print_info "   Platforms: HackerOne, Bugcrowd"
    print_info "   Income: Variable, top hunters earn \$500K+"
    echo ""

    print_sub_header "Defensive Security (Blue Team)"
    print_topic "SOC Analyst (Tier 1/2/3)"
    print_info "   Monitor and respond to security events"
    print_info "   Certifications: Security+, CySA+, GCIH"
    print_info "   Salary: \$50K - \$120K+"
    echo ""
    print_topic "Incident Responder"
    print_info "   Handle security breaches"
    print_info "   Certifications: GCIH, GCFA, ECIH"
    print_info "   Salary: \$80K - \$140K+"
    echo ""
    print_topic "Threat Hunter"
    print_info "   Proactively search for threats"
    print_info "   Certifications: GCTI, OSTH"
    print_info "   Salary: \$90K - \$160K+"
    echo ""

    print_sub_header "Other Paths"
    print_topic "Security Architect    - Design secure systems"
    print_topic "CISO                 - Chief Information Security Officer"
    print_topic "Malware Analyst      - Reverse engineer malware"
    print_topic "Digital Forensics    - Investigate cybercrimes"
    print_topic "GRC Analyst          - Governance, Risk, Compliance"
    print_topic "Cloud Security       - Secure cloud environments"
    print_topic "AppSec Engineer      - Application security"
    print_topic "DevSecOps            - Security in development pipeline"

    log_progress "Completed Module 1 Lesson 7"
    update_progress
    press_continue
}

module_1_lesson_8() {
    print_section_header "LEGAL & ETHICAL CONSIDERATIONS" "1.8"

    print_sub_header "Legal Frameworks"
    print_topic "Computer Fraud and Abuse Act (CFAA) - USA"
    print_info "   Unauthorized access to computer systems is federal crime"
    echo ""
    print_topic "GDPR - European Union"
    print_info "   Data protection and privacy regulation"
    print_info "   Fines up to €20M or 4% of annual revenue"
    echo ""
    print_topic "Information Technology Act - India"
    print_info "   Sections 43, 65, 66 cover cybercrimes"
    echo ""
    print_topic "Computer Misuse Act - UK"
    print_info "   Unauthorized access, modification of data"
    echo ""

    print_sub_header "Ethical Hacking Rules"
    print_warning "ALWAYS get written permission before testing"
    echo ""
    print_topic "1. Authorization"
    print_info "   Written permission (scope, timeline, methods)"
    echo ""
    print_topic "2. Scope"
    print_info "   Only test what you're authorized to test"
    echo ""
    print_topic "3. Reporting"
    print_info "   Report all findings to the client"
    echo ""
    print_topic "4. Responsible Disclosure"
    print_info "   Give vendors time to patch before public disclosure"
    echo ""
    print_topic "5. Do No Harm"
    print_info "   Minimize impact, don't destroy data"
    echo ""

    print_sub_header "Types of Hackers"
    print_topic "White Hat  - Ethical hackers, authorized testing"
    print_topic "Black Hat  - Malicious hackers, unauthorized access"
    print_topic "Grey Hat   - Sometimes unauthorized but not malicious"
    print_topic "Red Hat    - Target black hat hackers aggressively"
    print_topic "Green Hat  - New to hacking, learning"
    print_topic "Blue Hat   - Invited external testers"
    echo ""

    print_warning "This course is for EDUCATIONAL PURPOSES ONLY"
    print_warning "Always practice on systems you own or have permission to test"
    print_warning "Unauthorized hacking is ILLEGAL and can result in prison"

    log_progress "Completed Module 1 Lesson 8"
    update_progress
    press_continue
}

module_1_quiz() {
    print_section_header "MODULE 1 QUIZ" "1"
    echo ""

    quiz_question \
        "What does CIA stand for in cybersecurity?" \
        "Central Intelligence Agency" \
        "Confidentiality, Integrity, Availability" \
        "Cyber Intelligence Analysis" \
        "Computer Information Assurance" \
        "B" \
        "CIA Triad is the foundational security model."

    quiz_question \
        "Which type of malware self-replicates without user action?" \
        "Virus" \
        "Trojan" \
        "Worm" \
        "Adware" \
        "C" \
        "Worms can self-replicate and spread across networks."

    quiz_question \
        "What is the first phase of the Cyber Kill Chain?" \
        "Weaponization" \
        "Delivery" \
        "Exploitation" \
        "Reconnaissance" \
        "D" \
        "Reconnaissance is always the first step - gathering information."

    quiz_question \
        "An attacker who is politically motivated is called?" \
        "Script Kiddie" \
        "Hacktivist" \
        "Nation-State Actor" \
        "Insider Threat" \
        "B" \
        "Hacktivists are driven by political or social causes."

    quiz_question \
        "SQL Injection is what type of attack?" \
        "Network Attack" \
        "Physical Attack" \
        "Web Application Attack" \
        "Social Engineering" \
        "C" \
        "SQL Injection targets web application databases."

    log_progress "Completed Module 1 Quiz"
    press_continue
}

# ========================= MODULE 2: LINUX & NETWORKING =========================

module_2() {
    print_section_header "LINUX & NETWORKING FUNDAMENTALS" "2"
    echo -e "${WHITE}  Essential Linux and networking skills for cybersecurity.${RESET}"
    echo ""
    echo -e "${CYAN}  Lessons:${RESET}"
    echo -e "${WHITE}  1. Linux Command Line Essentials${RESET}"
    echo -e "${WHITE}  2. File System & Permissions${RESET}"
    echo -e "${WHITE}  3. Users & Process Management${RESET}"
    echo -e "${WHITE}  4. Bash Scripting for Security${RESET}"
    echo -e "${WHITE}  5. Networking Fundamentals (OSI/TCP-IP)${RESET}"
    echo -e "${WHITE}  6. Common Protocols Deep Dive${RESET}"
    echo -e "${WHITE}  7. Network Commands & Tools${RESET}"
    echo -e "${WHITE}  8. Packet Analysis Basics${RESET}"
    echo -e "${WHITE}  9. Module Quiz${RESET}"
    echo -e "${WHITE}  0. Back to Main Menu${RESET}"
    echo ""
    echo -ne "${CYAN}  Select lesson [0-9]: ${RESET}"
    read -r lesson

    case $lesson in
        1) module_2_lesson_1 ;;
        2) module_2_lesson_2 ;;
        3) module_2_lesson_3 ;;
        4) module_2_lesson_4 ;;
        5) module_2_lesson_5 ;;
        6) module_2_lesson_6 ;;
        7) module_2_lesson_7 ;;
        8) module_2_lesson_8 ;;
        9) module_2_quiz ;;
        0) return ;;
        *) echo -e "${RED}  Invalid option${RESET}"; sleep 1; module_2 ;;
    esac
    module_2
}

module_2_lesson_1() {
    print_section_header "LINUX COMMAND LINE ESSENTIALS" "2.1"

    print_sub_header "Navigation Commands"
    print_command "pwd                    # Print working directory"
    print_command "ls -la                 # List all files with details"
    print_command "cd /path/to/dir        # Change directory"
    print_command "cd ..                  # Go up one directory"
    print_command "cd ~                   # Go to home directory"
    echo ""

    print_sub_header "File Operations"
    print_command "touch file.txt         # Create empty file"
    print_command "cat file.txt           # Display file content"
    print_command "head -n 20 file.txt    # First 20 lines"
    print_command "tail -n 20 file.txt    # Last 20 lines"
    print_command "cp source dest         # Copy file"
    print_command "mv source dest         # Move/rename file"
    print_command "rm file.txt            # Delete file"
    print_command "rm -rf directory/      # Delete directory recursively"
    print_command "mkdir new_dir          # Create directory"
    print_command "find / -name '*.txt'   # Find files"
    print_command "locate filename        # Locate file (fast)"
    echo ""

    print_sub_header "Text Processing"
    print_command "grep 'pattern' file    # Search for pattern"
    print_command "grep -r 'pattern' dir  # Recursive search"
    print_command "grep -i 'pattern' file # Case insensitive"
    print_command "sed 's/old/new/g' file # Replace text"
    print_command "awk '{print \$1}' file  # Print first column"
    print_command "sort file.txt          # Sort lines"
    print_command "uniq                   # Remove duplicates"
    print_command "wc -l file.txt         # Count lines"
    print_command "cut -d':' -f1 file     # Cut by delimiter"
    echo ""

    print_sub_header "Piping & Redirection"
    print_command "command1 | command2    # Pipe output"
    print_command "command > file         # Redirect output (overwrite)"
    print_command "command >> file        # Redirect output (append)"
    print_command "command 2> errors.log  # Redirect errors"
    print_command "command &> all.log     # Redirect all output"
    print_command "command < input.txt    # Input from file"
    echo ""

    print_sub_header "🔬 PRACTICAL LAB"
    echo -e "${CYAN}  Try these commands now:${RESET}"
    echo ""
    print_command "echo 'Hello CyberSec!' > $LABS_DIR/test.txt"
    echo "Hello CyberSec!" > "$LABS_DIR/test.txt"
    print_command "cat $LABS_DIR/test.txt"
    cat "$LABS_DIR/test.txt"
    echo ""
    print_command "echo 'Line 2' >> $LABS_DIR/test.txt"
    echo "Line 2" >> "$LABS_DIR/test.txt"
    print_command "wc -l $LABS_DIR/test.txt"
    wc -l "$LABS_DIR/test.txt"
    echo ""
    print_command "echo 'password123' | sha256sum"
    echo "password123" | sha256sum

    log_progress "Completed Module 2 Lesson 1"
    update_progress
    press_continue
}

module_2_lesson_2() {
    print_section_header "FILE SYSTEM & PERMISSIONS" "2.2"

    print_sub_header "Linux File System Hierarchy"
    print_info "  /           Root directory"
    print_info "  ├── bin/    Essential binaries"
    print_info "  ├── etc/    Configuration files"
    print_info "  ├── home/   User home directories"
    print_info "  ├── var/    Variable data (logs, etc.)"
    print_info "  ├── tmp/    Temporary files"
    print_info "  ├── usr/    User programs"
    print_info "  ├── opt/    Optional software"
    print_info "  ├── dev/    Device files"
    print_info "  ├── proc/   Process information"
    print_info "  └── root/   Root user's home"
    echo ""

    print_sub_header "File Permissions"
    print_info "Permission Structure: rwxrwxrwx"
    print_info "                      ^^^───── Owner"
    print_info "                         ^^^── Group"
    print_info "                            ^^^─ Others"
    echo ""
    print_info "  r = Read    (4)"
    print_info "  w = Write   (2)"
    print_info "  x = Execute (1)"
    echo ""
    print_topic "Common Permission Values:"
    print_info "  777 = rwxrwxrwx (everyone can do everything)"
    print_info "  755 = rwxr-xr-x (owner full, others read+execute)"
    print_info "  644 = rw-r--r-- (owner read/write, others read)"
    print_info "  600 = rw------- (only owner can read/write)"
    print_info "  400 = r-------- (only owner can read)"
    echo ""

    print_sub_header "Permission Commands"
    print_command "chmod 755 file.sh      # Set permissions numerically"
    print_command "chmod +x file.sh       # Add execute permission"
    print_command "chmod u+w file.txt     # Add write for user"
    print_command "chmod go-r file.txt    # Remove read for group/others"
    print_command "chown user:group file  # Change ownership"
    echo ""

    print_sub_header "Special Permissions"
    print_topic "SUID (Set User ID) - 4xxx"
    print_info "   File executes with owner's privileges"
    print_command "chmod 4755 file         # Set SUID"
    print_command "find / -perm -4000 2>/dev/null  # Find SUID files"
    echo ""
    print_topic "SGID (Set Group ID) - 2xxx"
    print_info "   File executes with group's privileges"
    echo ""
    print_topic "Sticky Bit - 1xxx"
    print_info "   Only owner can delete files in directory"
    echo ""

    print_sub_header "🔬 PRACTICAL LAB: Security-Relevant Files"
    print_info "Important files for security:"
    print_command "ls -la /etc/passwd     # User accounts"
    ls -la "$PREFIX/etc/passwd" 2>/dev/null || echo "    (File location varies in Termux)"
    echo ""
    print_info "  /etc/passwd  - User account information"
    print_info "  /etc/shadow  - Encrypted passwords (root only)"
    print_info "  /etc/group   - Group information"
    print_info "  /var/log/    - System logs"

    log_progress "Completed Module 2 Lesson 2"
    update_progress
    press_continue
}

module_2_lesson_3() {
    print_section_header "USERS & PROCESS MANAGEMENT" "2.3"

    print_sub_header "User Management"
    print_command "whoami                 # Current user"
    echo "    $(whoami)"
    print_command "id                     # User ID and groups"
    echo "    $(id 2>/dev/null)"
    print_command "w                      # Who is logged in"
    print_command "last                   # Login history"
    echo ""

    print_sub_header "Process Management"
    print_command "ps aux                 # All running processes"
    print_command "ps aux | grep nginx    # Find specific process"
    print_command "top                    # Real-time process monitor"
    print_command "htop                   # Better process monitor"
    print_command "kill PID               # Kill process by PID"
    print_command "kill -9 PID            # Force kill process"
    print_command "killall processname    # Kill by name"
    print_command "bg                     # Send to background"
    print_command "fg                     # Bring to foreground"
    print_command "jobs                   # List background jobs"
    print_command "nohup command &        # Run even after logout"
    echo ""

    print_sub_header "System Information"
    print_command "uname -a               # System information"
    echo "    $(uname -a)"
    echo ""
    print_command "hostname               # System hostname"
    echo "    $(hostname 2>/dev/null || echo 'localhost')"
    echo ""
    print_command "uptime                 # System uptime"
    echo "    $(uptime 2>/dev/null)"
    echo ""
    print_command "df -h                  # Disk usage"
    print_command "free -m                # Memory usage"
    print_command "env                    # Environment variables"
    echo ""

    print_sub_header "Cron Jobs (Scheduled Tasks)"
    print_command "crontab -l             # List cron jobs"
    print_command "crontab -e             # Edit cron jobs"
    echo ""
    print_info "Cron Format: MIN HOUR DAY MONTH DAYOFWEEK COMMAND"
    print_example "0 2 * * * /path/script.sh  # Run at 2:00 AM daily"
    print_example "*/5 * * * * /path/check.sh # Run every 5 minutes"
    echo ""
    print_note "Attackers often use cron jobs for persistence!"

    log_progress "Completed Module 2 Lesson 3"
    update_progress
    press_continue
}

module_2_lesson_4() {
    print_section_header "BASH SCRIPTING FOR SECURITY" "2.4"

    print_sub_header "Bash Scripting Basics"

    # Create example scripts
    print_topic "Script 1: Port Scanner"
    cat > "$SCRIPTS_DIR/port_scanner.sh" << 'SCRIPT'
#!/bin/bash
# Simple Port Scanner
# Usage: ./port_scanner.sh <target_ip> <start_port> <end_port>

TARGET=$1
START=${2:-1}
END=${3:-1024}

if [ -z "$TARGET" ]; then
    echo "Usage: $0 <target_ip> [start_port] [end_port]"
    exit 1
fi

echo "===================================="
echo " Simple Port Scanner"
echo " Target: $TARGET"
echo " Ports: $START - $END"
echo " Started: $(date)"
echo "===================================="

for port in $(seq $START $END); do
    (echo >/dev/tcp/$TARGET/$port) 2>/dev/null && \
        echo "[OPEN] Port $port is open"
done

echo "===================================="
echo " Scan completed: $(date)"
echo "===================================="
SCRIPT
    chmod +x "$SCRIPTS_DIR/port_scanner.sh"
    print_info "Saved to: $SCRIPTS_DIR/port_scanner.sh"
    echo ""
    print_code_block "$(cat $SCRIPTS_DIR/port_scanner.sh)"
    echo ""

    print_topic "Script 2: Log Analyzer"
    cat > "$SCRIPTS_DIR/log_analyzer.sh" << 'SCRIPT'
#!/bin/bash
# Security Log Analyzer
# Analyzes auth logs for suspicious activity

LOG_FILE="${1:-/var/log/auth.log}"
OUTPUT="security_report_$(date +%Y%m%d).txt"

echo "===============================" > $OUTPUT
echo " Security Log Analysis Report" >> $OUTPUT
echo " Date: $(date)" >> $OUTPUT
echo " Log: $LOG_FILE" >> $OUTPUT
echo "===============================" >> $OUTPUT

if [ ! -f "$LOG_FILE" ]; then
    echo "Log file not found. Creating sample analysis..."

    # Create sample log for demonstration
    cat > /tmp/sample_auth.log << 'EOF'
Jan 15 10:23:45 server sshd[1234]: Failed password for root from 192.168.1.100
Jan 15 10:23:46 server sshd[1235]: Failed password for root from 192.168.1.100
Jan 15 10:23:47 server sshd[1236]: Failed password for admin from 192.168.1.100
Jan 15 10:24:00 server sshd[1237]: Accepted password for user1 from 10.0.0.5
Jan 15 10:25:00 server sshd[1238]: Failed password for root from 10.0.0.99
Jan 15 10:25:01 server sshd[1239]: Failed password for root from 10.0.0.99
Jan 15 10:25:02 server sshd[1240]: Failed password for root from 10.0.0.99
Jan 15 10:25:03 server sshd[1241]: Failed password for root from 10.0.0.99
Jan 15 10:25:04 server sshd[1242]: Failed password for root from 10.0.0.99
EOF
    LOG_FILE="/tmp/sample_auth.log"
fi

echo "" >> $OUTPUT
echo "[+] Failed Login Attempts:" >> $OUTPUT
grep -c "Failed password" $LOG_FILE >> $OUTPUT

echo "" >> $OUTPUT
echo "[+] Successful Logins:" >> $OUTPUT
grep -c "Accepted" $LOG_FILE >> $OUTPUT

echo "" >> $OUTPUT
echo "[+] Top Attacking IPs:" >> $OUTPUT
grep "Failed password" $LOG_FILE | \
    grep -oE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | \
    sort | uniq -c | sort -rn | head -10 >> $OUTPUT

echo "" >> $OUTPUT
echo "[+] Targeted Usernames:" >> $OUTPUT
grep "Failed password" $LOG_FILE | \
    awk '{for(i=1;i<=NF;i++) if ($i=="for") print $(i+1)}' | \
    sort | uniq -c | sort -rn >> $OUTPUT

cat $OUTPUT
echo ""
echo "Report saved to: $OUTPUT"
SCRIPT
    chmod +x "$SCRIPTS_DIR/log_analyzer.sh"
    print_info "Saved to: $SCRIPTS_DIR/log_analyzer.sh"
    echo ""

    print_topic "Script 3: Password Generator"
    cat > "$SCRIPTS_DIR/password_gen.sh" << 'SCRIPT'
#!/bin/bash
# Secure Password Generator

LENGTH=${1:-16}
COUNT=${2:-5}

echo "================================"
echo " Secure Password Generator"
echo " Length: $LENGTH characters"
echo " Count: $COUNT passwords"
echo "================================"

for i in $(seq 1 $COUNT); do
    # Method 1: Using /dev/urandom
    PASS=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9!@#$%^&*()_+-=' | head -c $LENGTH)
    echo " [$i] $PASS"
done

echo ""
echo " Password Strength Check:"
echo " - Length >= 12: Strong"
echo " - Mixed case + numbers + symbols: Very Strong"
echo "================================"
SCRIPT
    chmod +x "$SCRIPTS_DIR/password_gen.sh"
    print_info "Saved to: $SCRIPTS_DIR/password_gen.sh"
    echo ""

    print_topic "Script 4: Network Monitor"
    cat > "$SCRIPTS_DIR/network_monitor.sh" << 'SCRIPT'
#!/bin/bash
# Simple Network Connection Monitor

echo "================================"
echo " Network Connection Monitor"
echo " Time: $(date)"
echo "================================"

echo ""
echo "[+] Active Network Interfaces:"
ifconfig 2>/dev/null || ip addr 2>/dev/null
echo ""

echo "[+] Current Connections:"
netstat -tuln 2>/dev/null || ss -tuln 2>/dev/null
echo ""

echo "[+] DNS Resolution Test:"
for domain in google.com github.com; do
    IP=$(nslookup $domain 2>/dev/null | grep "Address" | tail -1)
    echo "  $domain -> $IP"
done
echo ""

echo "[+] Routing Table:"
route -n 2>/dev/null || ip route 2>/dev/null
echo ""

echo "================================"
echo " Monitor completed"
echo "================================"
SCRIPT
    chmod +x "$SCRIPTS_DIR/network_monitor.sh"
    print_info "Saved to: $SCRIPTS_DIR/network_monitor.sh"
    echo ""

    print_sub_header "Bash Scripting Concepts"
    print_topic "Variables"
    print_code_block 'NAME="CyberSec"
echo $NAME
RESULT=$(command)  # Command substitution'
    echo ""

    print_topic "Conditionals"
    print_code_block 'if [ condition ]; then
    # commands
elif [ condition ]; then
    # commands
else
    # commands
fi'
    echo ""

    print_topic "Loops"
    print_code_block 'for i in $(seq 1 10); do
    echo $i
done

while [ condition ]; do
    # commands
done'
    echo ""

    print_topic "Functions"
    print_code_block 'scan_port() {
    local host=$1
    local port=$2
    (echo >/dev/tcp/$host/$port) 2>/dev/null
    return $?
}'

    log_progress "Completed Module 2 Lesson 4"
    update_progress
    press_continue
}

module_2_lesson_5() {
    print_section_header "NETWORKING FUNDAMENTALS (OSI/TCP-IP)" "2.5"

    print_sub_header "OSI Model (7 Layers)"
    echo -e "${CYAN}"
    echo "  ┌──────────────────────────────────────────────────┐"
    echo "  │ Layer 7 │ Application  │ HTTP, FTP, SSH, DNS     │"
    echo "  ├─────────┼──────────────┼─────────────────────────┤"
    echo "  │ Layer 6 │ Presentation │ SSL/TLS, JPEG, ASCII    │"
    echo "  ├─────────┼──────────────┼─────────────────────────┤"
    echo "  │ Layer 5 │ Session      │ NetBIOS, RPC            │"
    echo "  ├─────────┼──────────────┼─────────────────────────┤"
    echo "  │ Layer 4 │ Transport    │ TCP, UDP                │"
    echo "  ├─────────┼──────────────┼─────────────────────────┤"
    echo "  │ Layer 3 │ Network      │ IP, ICMP, ARP           │"
    echo "  ├─────────┼──────────────┼─────────────────────────┤"
    echo "  │ Layer 2 │ Data Link    │ Ethernet, MAC, Switch   │"
    echo "  ├─────────┼──────────────┼─────────────────────────┤"
    echo "  │ Layer 1 │ Physical     │ Cables, Hubs, Signals   │"
    echo "  └──────────────────────────────────────────────────┘"
    echo -e "${RESET}"
    echo ""

    print_info "Mnemonic: Please Do Not Throw Sausage Pizza Away"
    print_info "         (Physical → Application)"
    echo ""

    print_sub_header "TCP/IP Model (4 Layers)"
    echo -e "${CYAN}"
    echo "  ┌────────────────────┬──────────────────────────┐"
    echo "  │ Application        │ HTTP, FTP, SSH, DNS      │"
    echo "  ├────────────────────┼──────────────────────────┤"
    echo "  │ Transport          │ TCP, UDP                 │"
    echo "  ├────────────────────┼──────────────────────────┤"
    echo "  │ Internet           │ IP, ICMP, ARP            │"
    echo "  ├────────────────────┼──────────────────────────┤"
    echo "  │ Network Access     │ Ethernet, WiFi           │"
    echo "  └────────────────────┴──────────────────────────┘"
    echo -e "${RESET}"
    echo ""

    print_sub_header "TCP vs UDP"
    echo -e "${CYAN}"
    echo "  ┌─────────────────────┬─────────────────────────┐"
    echo "  │       TCP           │         UDP              │"
    echo "  ├─────────────────────┼─────────────────────────┤"
    echo "  │ Connection-oriented │ Connectionless           │"
    echo "  │ Reliable            │ Unreliable               │"
    echo "  │ Ordered delivery    │ No ordering              │"
    echo "  │ Error checking      │ Minimal checking         │"
    echo "  │ Flow control        │ No flow control          │"
    echo "  │ Slower              │ Faster                   │"
    echo "  │ HTTP, SSH, FTP      │ DNS, DHCP, VoIP          │"
    echo "  └─────────────────────┴─────────────────────────┘"
    echo -e "${RESET}"
    echo ""

    print_sub_header "TCP Three-Way Handshake"
    echo -e "${CYAN}"
    echo "  Client                          Server"
    echo "    │                               │"
    echo "    │──── SYN (seq=x) ──────────►  │"
    echo "    │                               │"
    echo "    │◄── SYN-ACK (seq=y,ack=x+1)── │"
    echo "    │                               │"
    echo "    │──── ACK (ack=y+1) ─────────► │"
    echo "    │                               │"
    echo "    │══════ Connection Open ════════│"
    echo -e "${RESET}"
    echo ""

    print_sub_header "IP Addressing"
    print_topic "IPv4 Address Classes"
    print_info "  Class A: 1.0.0.0   - 126.255.255.255  (/8)"
    print_info "  Class B: 128.0.0.0 - 191.255.255.255  (/16)"
    print_info "  Class C: 192.0.0.0 - 223.255.255.255  (/24)"
    echo ""
    print_topic "Private IP Ranges"
    print_info "  10.0.0.0/8      (Class A)"
    print_info "  172.16.0.0/12   (Class B)"
    print_info "  192.168.0.0/16  (Class C)"
    echo ""
    print_topic "Subnet Mask"
    print_info "  /24 = 255.255.255.0   (256 IPs, 254 usable)"
    print_info "  /16 = 255.255.0.0     (65,536 IPs)"
    print_info "  /8  = 255.0.0.0       (16,777,216 IPs)"

    log_progress "Completed Module 2 Lesson 5"
    update_progress
    press_continue
}

module_2_lesson_6() {
    print_section_header "COMMON PROTOCOLS DEEP DIVE" "2.6"

    print_sub_header "Important Ports & Protocols"
    echo -e "${CYAN}"
    echo "  ┌──────┬───────────┬──────────────────────────────────┐"
    echo "  │ Port │ Protocol  │ Description                      │"
    echo "  ├──────┼───────────┼──────────────────────────────────┤"
    echo "  │  20  │ FTP-Data  │ File Transfer (Data)             │"
    echo "  │  21  │ FTP       │ File Transfer (Control)          │"
    echo "  │  22  │ SSH       │ Secure Shell                     │"
    echo "  │  23  │ Telnet    │ Unencrypted remote access        │"
    echo "  │  25  │ SMTP      │ Simple Mail Transfer             │"
    echo "  │  53  │ DNS       │ Domain Name System               │"
    echo "  │  67  │ DHCP      │ Dynamic Host Configuration       │"
    echo "  │  80  │ HTTP      │ Web Traffic (unencrypted)        │"
    echo "  │ 110  │ POP3      │ Post Office Protocol             │"
    echo "  │ 143  │ IMAP      │ Internet Message Access          │"
    echo "  │ 443  │ HTTPS     │ Secure Web Traffic               │"
    echo "  │ 445  │ SMB       │ Server Message Block             │"
    echo "  │ 993  │ IMAPS     │ Secure IMAP                      │"
    echo "  │ 995  │ POP3S     │ Secure POP3                      │"
    echo "  │ 1433 │ MSSQL     │ Microsoft SQL Server             │"
    echo "  │ 3306 │ MySQL     │ MySQL Database                   │"
    echo "  │ 3389 │ RDP       │ Remote Desktop Protocol          │"
    echo "  │ 5432 │ PostgreSQL│ PostgreSQL Database              │"
    echo "  │ 8080 │ HTTP-Alt  │ Alternative HTTP                 │"
    echo "  └──────┴───────────┴──────────────────────────────────┘"
    echo -e "${RESET}"
    echo ""

    print_sub_header "DNS (Domain Name System)"
    print_info "Translates domain names to IP addresses"
    echo ""
    print_topic "DNS Record Types:"
    print_info "  A      - Maps domain to IPv4 address"
    print_info "  AAAA   - Maps domain to IPv6 address"
    print_info "  CNAME  - Canonical name (alias)"
    print_info "  MX     - Mail exchange server"
    print_info "  NS     - Name server"
    print_info "  TXT    - Text records (SPF, DKIM, DMARC)"
    print_info "  SOA    - Start of Authority"
    print_info "  PTR    - Reverse lookup (IP to domain)"
    print_info "  SRV    - Service location"
    echo ""

    print_sub_header "HTTP/HTTPS"
    print_topic "HTTP Methods:"
    print_info "  GET    - Retrieve data"
    print_info "  POST   - Submit data"
    print_info "  PUT    - Update data"
    print_info "  DELETE - Remove data"
    print_info "  HEAD   - Get headers only"
    print_info "  OPTIONS- Get supported methods"
    print_info "  PATCH  - Partial update"
    echo ""
    print_topic "HTTP Status Codes:"
    print_info "  200 - OK"
    print_info "  301 - Moved Permanently"
    print_info "  302 - Found (Redirect)"
    print_info "  400 - Bad Request"
    print_info "  401 - Unauthorized"
    print_info "  403 - Forbidden"
    print_info "  404 - Not Found"
    print_info "  500 - Internal Server Error"
    print_info "  503 - Service Unavailable"

    log_progress "Completed Module 2 Lesson 6"
    update_progress
    press_continue
}

module_2_lesson_7() {
    print_section_header "NETWORK COMMANDS & TOOLS" "2.7"

    print_sub_header "Network Diagnostic Commands"
    echo ""
    print_topic "ifconfig / ip addr - Network Interface Info"
    print_command "ifconfig"
    ifconfig 2>/dev/null || ip addr 2>/dev/null | head -20
    echo ""

    print_topic "ping - Test Connectivity"
    print_command "ping -c 4 google.com"
    ping -c 2 google.com 2>/dev/null || echo "    ping may require root on some systems"
    echo ""

    print_topic "traceroute - Trace Network Path"
    print_command "traceroute google.com"
    print_info "Shows each hop between you and the destination"
    echo ""

    print_topic "nslookup / dig - DNS Queries"
    print_command "nslookup google.com"
    nslookup google.com 2>/dev/null | head -8
    echo ""
    print_command "dig google.com A"
    print_command "dig google.com MX"
    print_command "dig google.com TXT"
    print_command "dig google.com ANY"
    echo ""

    print_topic "whois - Domain Registration Info"
    print_command "whois example.com"
    print_info "Returns registrar, creation date, nameservers, etc."
    echo ""

    print_topic "netstat / ss - Network Statistics"
    print_command "netstat -tuln          # TCP/UDP listening ports"
    print_command "netstat -antp          # All connections with PID"
    print_command "ss -tuln              # Modern alternative"
    echo ""

    print_topic "curl - HTTP Requests"
    print_command "curl -I https://google.com        # Headers only"
    echo ""
    echo -e "${CYAN}  Live Demo:${RESET}"
    curl -sI https://google.com 2>/dev/null | head -8
    echo ""

    print_command "curl -v https://example.com       # Verbose output"
    print_command "curl -X POST -d 'data' url        # POST request"
    print_command "curl -o file.html url              # Download file"
    echo ""

    print_topic "wget - Download Files"
    print_command "wget https://example.com/file.txt"
    print_command "wget -r https://example.com/       # Recursive download"

    log_progress "Completed Module 2 Lesson 7"
    update_progress
    press_continue
}

module_2_lesson_8() {
    print_section_header "PACKET ANALYSIS BASICS" "2.8"

    print_sub_header "What is Packet Analysis?"
    print_info "Packet analysis (packet sniffing) is the process of capturing"
    print_info "and examining network traffic at the packet level."
    echo ""

    print_sub_header "TCPDump"
    print_topic "Basic Usage:"
    print_command "tcpdump -i any                 # Capture on all interfaces"
    print_command "tcpdump -i wlan0               # Specific interface"
    print_command "tcpdump -c 100                 # Capture 100 packets"
    print_command "tcpdump -w capture.pcap        # Write to file"
    print_command "tcpdump -r capture.pcap        # Read from file"
    echo ""
    print_topic "Filters:"
    print_command "tcpdump host 192.168.1.1       # Specific host"
    print_command "tcpdump port 80                # Specific port"
    print_command "tcpdump src 10.0.0.1           # Source IP"
    print_command "tcpdump dst port 443           # Destination port"
    print_command "tcpdump tcp                    # Only TCP"
    print_command "tcpdump 'tcp port 80 and host 10.0.0.1'"
    echo ""

    print_sub_header "Packet Structure"
    echo -e "${CYAN}"
    echo "  ┌──────────────────────────────────────┐"
    echo "  │       Ethernet Header (14 bytes)      │"
    echo "  │  Dest MAC | Src MAC | EtherType       │"
    echo "  ├──────────────────────────────────────┤"
    echo "  │       IP Header (20+ bytes)           │"
    echo "  │  Version | TTL | Protocol | Src/Dst IP │"
    echo "  ├──────────────────────────────────────┤"
    echo "  │       TCP/UDP Header                  │"
    echo "  │  Src Port | Dst Port | Seq/Ack | Flags│"
    echo "  ├──────────────────────────────────────┤"
    echo "  │       Application Data (Payload)      │"
    echo "  │  HTTP, DNS, FTP data, etc.            │"
    echo "  └──────────────────────────────────────┘"
    echo -e "${RESET}"
    echo ""

    print_sub_header "TCP Flags"
    print_info "  SYN (S) - Synchronize (start connection)"
    print_info "  ACK (A) - Acknowledge"
    print_info "  FIN (F) - Finish (end connection)"
    print_info "  RST (R) - Reset (abort connection)"
    print_info "  PSH (P) - Push (send data immediately)"
    print_info "  URG (U) - Urgent"
    echo ""

    print_sub_header "Analysis with Python (Scapy)"
    cat > "$SCRIPTS_DIR/packet_analyzer.py" << 'PYEOF'
#!/usr/bin/env python3
"""
Simple Packet Analyzer
Educational demonstration of packet analysis concepts
"""

import socket
import struct
import textwrap

def analyze_sample_packet():
    """Demonstrate packet analysis concepts"""

    print("=" * 50)
    print(" Packet Analysis Concepts")
    print("=" * 50)

    # Simulate analyzing a TCP packet
    print("\n[+] Sample TCP Packet Analysis:")
    print(f"    Ethernet Header:")
    print(f"      Destination MAC: AA:BB:CC:DD:EE:FF")
    print(f"      Source MAC:      11:22:33:44:55:66")
    print(f"      Protocol:        0x0800 (IPv4)")

    print(f"\n    IP Header:")
    print(f"      Version:         4")
    print(f"      Header Length:   20 bytes")
    print(f"      TTL:             64")
    print(f"      Protocol:        6 (TCP)")
    print(f"      Source IP:       192.168.1.100")
    print(f"      Destination IP:  93.184.216.34")

    print(f"\n    TCP Header:")
    print(f"      Source Port:     54321")
    print(f"      Destination Port:80")
    print(f"      Sequence Number: 1000")
    print(f"      Ack Number:      0")
    print(f"      Flags:           SYN")
    print(f"      Window Size:     65535")

    print(f"\n    This appears to be:")
    print(f"      A TCP SYN packet (connection initiation)")
    print(f"      From internal host to web server (port 80)")
    print(f"      Part of the TCP three-way handshake")

    print("\n" + "=" * 50)
    print(" Common patterns to look for:")
    print("=" * 50)
    print("  - Multiple SYN without ACK = SYN Flood attack")
    print("  - Sequential port connections = Port Scan")
    print("  - Large data to external IP = Data Exfiltration")
    print("  - DNS queries to unusual domains = C2 traffic")
    print("  - Unencrypted credentials = Password sniffing")

if __name__ == "__main__":
    analyze_sample_packet()
PYEOF
    chmod +x "$SCRIPTS_DIR/packet_analyzer.py"
    print_info "Script saved to: $SCRIPTS_DIR/packet_analyzer.py"
    python3 "$SCRIPTS_DIR/packet_analyzer.py" 2>/dev/null

    log_progress "Completed Module 2 Lesson 8"
    update_progress
    press_continue
}

module_2_quiz() {
    print_section_header "MODULE 2 QUIZ" "2"

    quiz_question \
        "How many layers does the OSI model have?" \
        "4" \
        "5" \
        "7" \
        "6" \
        "C" \
        "The OSI model has 7 layers: Physical to Application."

    quiz_question \
        "Which port does SSH use by default?" \
        "21" \
        "22" \
        "23" \
        "25" \
        "B" \
        "SSH uses port 22. FTP=21, Telnet=23, SMTP=25."

    quiz_question \
        "What does the command 'chmod 755 file' set?" \
        "Owner: rwx, Group: r-x, Others: r-x" \
        "Owner: rw-, Group: r--, Others: r--" \
        "Everyone: rwx" \
        "Owner: rwx, Group: rwx, Others: r--" \
        "A" \
        "7=rwx, 5=r-x. So 755 = rwxr-xr-x."

    quiz_question \
        "TCP three-way handshake sequence is?" \
        "ACK, SYN, SYN-ACK" \
        "SYN, ACK, SYN-ACK" \
        "SYN, SYN-ACK, ACK" \
        "FIN, FIN-ACK, ACK" \
        "C" \
        "TCP: SYN → SYN-ACK → ACK"

    quiz_question \
        "Which DNS record type maps a domain to an IPv4 address?" \
        "AAAA" \
        "CNAME" \
        "MX" \
        "A" \
        "D" \
        "A records map domain names to IPv4 addresses."

    log_progress "Completed Module 2 Quiz"
    press_continue
}

# ========================= MODULE 3: RECONNAISSANCE =========================

module_3() {
    print_section_header "RECONNAISSANCE & INFORMATION GATHERING" "3"
    echo -e "${WHITE}  Learn how to gather information about targets.${RESET}"
    echo ""
    echo -e "${CYAN}  Lessons:${RESET}"
    echo -e "${WHITE}  1. Passive Reconnaissance (OSINT)${RESET}"
    echo -e "${WHITE}  2. Active Reconnaissance${RESET}"
    echo -e "${WHITE}  3. DNS Enumeration${RESET}"
    echo -e "${WHITE}  4. WHOIS & Subdomain Discovery${RESET}"
    echo -e "${WHITE}  5. Google Dorking${RESET}"
    echo -e "${WHITE}  6. Nmap Deep Dive${RESET}"
    echo -e "${WHITE}  7. OSINT Tools & Frameworks${RESET}"
    echo -e "${WHITE}  8. Recon Automation Scripts${RESET}"
    echo -e "${WHITE}  9. Module Quiz${RESET}"
    echo -e "${WHITE}  0. Back to Main Menu${RESET}"
    echo ""
    echo -ne "${CYAN}  Select lesson [0-9]: ${RESET}"
    read -r lesson

    case $lesson in
        1) module_3_lesson_1 ;;
        2) module_3_lesson_2 ;;
        3) module_3_lesson_3 ;;
        4) module_3_lesson_4 ;;
        5) module_3_lesson_5 ;;
        6) module_3_lesson_6 ;;
        7) module_3_lesson_7 ;;
        8) module_3_lesson_8 ;;
        9) module_3_quiz ;;
        0) return ;;
        *) echo -e "${RED}  Invalid option${RESET}"; sleep 1; module_3 ;;
    esac
    module_3
}

module_3_lesson_1() {
    print_section_header "PASSIVE RECONNAISSANCE (OSINT)" "3.1"

    print_sub_header "What is Passive Recon?"
    print_info "Gathering information WITHOUT directly interacting with the target."
    print_info "The target has no way of knowing you are collecting information."
    echo ""

    print_sub_header "OSINT Sources"
    print_topic "1. Search Engines"
    print_info "   Google, Bing, DuckDuckGo, Shodan, Censys"
    echo ""
    print_topic "2. Social Media"
    print_info "   LinkedIn, Twitter/X, Facebook, Instagram"
    print_info "   Find employees, organizational structure"
    echo ""
    print_topic "3. Public Records"
    print_info "   WHOIS databases, DNS records, certificate logs"
    print_info "   SEC filings, court records, job postings"
    echo ""
    print_topic "4. Code Repositories"
    print_info "   GitHub, GitLab, Bitbucket"
    print_info "   Look for: API keys, credentials, internal URLs"
    echo ""
    print_topic "5. Cached/Archived Content"
    print_info "   Wayback Machine (web.archive.org)"
    print_info "   Google Cache, Cached pages"
    echo ""
    print_topic "6. Metadata"
    print_info "   Document metadata (author, software, creation date)"
    print_info "   Image EXIF data (GPS coordinates, camera model)"
    echo ""

    print_sub_header "OSINT Websites"
    print_info "  • shodan.io           - Internet-connected devices"
    print_info "  • censys.io           - Internet scan data"
    print_info "  • crt.sh              - Certificate transparency logs"
    print_info "  • hunter.io           - Email finder"
    print_info "  • haveibeenpwned.com  - Breach database"
    print_info "  • dnsdumpster.com     - DNS recon"
    print_info "  • builtwith.com       - Technology profiler"
    print_info "  • netcraft.com        - Website technology info"
    print_info "  • archive.org         - Wayback Machine"
    print_info "  • pastebin.com        - Paste sites"

    log_progress "Completed Module 3 Lesson 1"
    update_progress
    press_continue
}

module_3_lesson_2() {
    print_section_header "ACTIVE RECONNAISSANCE" "3.2"

    print_sub_header "What is Active Recon?"
    print_info "Directly interacting with the target system to gather information."
    print_warning "This can be detected by the target!"
    print_warning "Always have written authorization before active recon!"
    echo ""

    print_sub_header "Active Recon Techniques"
    print_topic "1. Port Scanning"
    print_info "   Discovering open ports and services"
    print_command "nmap -sV target_ip"
    echo ""

    print_topic "2. Service Enumeration"
    print_info "   Determining software versions and configurations"
    print_command "nmap -sV -sC target_ip"
    echo ""

    print_topic "3. OS Fingerprinting"
    print_info "   Identifying the target's operating system"
    print_command "nmap -O target_ip"
    echo ""

    print_topic "4. Web Application Discovery"
    print_info "   Finding web pages, directories, and files"
    print_command "dirb http://target_ip /usr/share/wordlists/dirb/common.txt"
    echo ""

    print_topic "5. Banner Grabbing"
    print_info "   Retrieving service banners for version info"
    print_command "nc -v target_ip 80"
    print_command "curl -I http://target_ip"
    echo ""

    print_topic "6. Network Mapping"
    print_info "   Discovering hosts on a network"
    print_command "nmap -sn 192.168.1.0/24   # Ping sweep"
    echo ""

    print_sub_header "🔬 PRACTICAL LAB: Banner Grabbing"
    echo -e "${CYAN}  Grabbing HTTP headers from a website:${RESET}"
    echo ""
    print_command "curl -sI https://example.com"
    curl -sI https://example.com 2>/dev/null | head -10
    echo ""
    print_info "Notice: Server header reveals web server software!"
    print_info "This is valuable information for an attacker."

    log_progress "Completed Module 3 Lesson 2"
    update_progress
    press_continue
}

module_3_lesson_3() {
    print_section_header "DNS ENUMERATION" "3.3"

    print_sub_header "DNS Enumeration Techniques"
    echo ""

    print_topic "1. Basic DNS Lookup"
    print_command "nslookup example.com"
    echo ""
    echo -e "${CYAN}  Live Demo:${RESET}"
    nslookup example.com 2>/dev/null | head -8
    echo ""

    print_topic "2. Specific Record Types"
    print_command "dig example.com A          # IPv4 address"
    print_command "dig example.com AAAA       # IPv6 address"
    print_command "dig example.com MX         # Mail servers"
    print_command "dig example.com NS         # Name servers"
    print_command "dig example.com TXT        # Text records"
    print_command "dig example.com SOA        # Authority"
    echo ""

    print_topic "3. Reverse DNS Lookup"
    print_command "dig -x 8.8.8.8            # IP to domain"
    print_command "nslookup 8.8.8.8"
    echo ""

    print_topic "4. DNS Zone Transfer"
    print_info "Zone transfers can reveal all DNS records for a domain"
    print_command "dig axfr @ns1.example.com example.com"
    print_warning "Most servers are configured to deny zone transfers"
    echo ""

    print_topic "5. Subdomain Brute Force"
    print_info "Discovering subdomains using wordlists"
    echo ""

    # Create a subdomain finder script
    cat > "$SCRIPTS_DIR/subdomain_finder.sh" << 'SCRIPT'
#!/bin/bash
# Simple Subdomain Finder
# Usage: ./subdomain_finder.sh <domain>

DOMAIN=$1
if [ -z "$DOMAIN" ]; then
    echo "Usage: $0 <domain>"
    exit 1
fi

WORDLIST=(www mail ftp admin blog dev staging api test app
          portal vpn ns1 ns2 mx smtp imap pop webmail
          shop store cdn assets static media files docs
          git jenkins ci cd monitor status wiki help
          support forum community dashboard panel cpanel
          backup db database mysql postgres redis)

echo "======================================"
echo " Subdomain Finder"
echo " Target: $DOMAIN"
echo " Wordlist: ${#WORDLIST[@]} entries"
echo " Started: $(date)"
echo "======================================"

FOUND=0
for sub in "${WORDLIST[@]}"; do
    RESULT=$(nslookup "$sub.$DOMAIN" 2>/dev/null | grep "Address" | tail -1 | grep -v "#")
    if [ -n "$RESULT" ]; then
        IP=$(echo "$RESULT" | awk '{print $2}')
        echo "[FOUND] $sub.$DOMAIN -> $IP"
        FOUND=$((FOUND + 1))
    fi
done

echo "======================================"
echo " Found $FOUND subdomains"
echo " Completed: $(date)"
echo "======================================"
SCRIPT
    chmod +x "$SCRIPTS_DIR/subdomain_finder.sh"
    print_info "Subdomain finder saved to: $SCRIPTS_DIR/subdomain_finder.sh"
    print_command "./subdomain_finder.sh example.com"

    log_progress "Completed Module 3 Lesson 3"
    update_progress
    press_continue
}

module_3_lesson_4() {
    print_section_header "WHOIS & SUBDOMAIN DISCOVERY" "3.4"

    print_sub_header "WHOIS Lookup"
    print_info "WHOIS provides domain registration information."
    echo ""
    print_command "whois example.com"
    echo ""
    echo -e "${CYAN}  Information typically found:${RESET}"
    print_info "  • Registrar name"
    print_info "  • Registration & expiry dates"
    print_info "  • Name servers"
    print_info "  • Registrant contact (if not privacy-protected)"
    print_info "  • Admin/Tech contacts"
    echo ""

    echo -e "${CYAN}  Live Demo:${RESET}"
    whois google.com 2>/dev/null | head -20 || echo "    whois command may need installation"
    echo ""

    print_sub_header "Certificate Transparency"
    print_info "SSL certificates are logged publicly. We can search them"
    print_info "to discover subdomains."
    echo ""
    print_command "curl -s 'https://crt.sh/?q=%.example.com&output=json' | python3 -m json.tool"
    echo ""

    cat > "$SCRIPTS_DIR/cert_subdomain.sh" << 'SCRIPT'
#!/bin/bash
# Certificate Transparency Subdomain Finder
# Usage: ./cert_subdomain.sh <domain>

DOMAIN=$1
if [ -z "$DOMAIN" ]; then
    echo "Usage: $0 <domain>"
    exit 1
fi

echo "======================================"
echo " Certificate Transparency Search"
echo " Domain: $DOMAIN"
echo "======================================"

curl -s "https://crt.sh/?q=%25.$DOMAIN&output=json" 2>/dev/null | \
    python3 -c "
import json, sys
try:
    data = json.load(sys.stdin)
    domains = set()
    for entry in data:
        name = entry.get('name_value', '')
        for d in name.split('\n'):
            if d.strip():
                domains.add(d.strip())
    for d in sorted(domains):
        print(f'  [+] {d}')
    print(f'\n  Total unique subdomains: {len(domains)}')
except:
    print('  Error parsing response or no results found')
" 2>/dev/null || echo "  Requires internet connection and python3"

echo "======================================"
SCRIPT
    chmod +x "$SCRIPTS_DIR/cert_subdomain.sh"
    print_info "Script saved: $SCRIPTS_DIR/cert_subdomain.sh"

    log_progress "Completed Module 3 Lesson 4"
    update_progress
    press_continue
}

module_3_lesson_5() {
    print_section_header "GOOGLE DORKING" "3.5"

    print_sub_header "What is Google Dorking?"
    print_info "Using advanced Google search operators to find sensitive"
    print_info "information exposed on the internet."
    echo ""

    print_sub_header "Google Dork Operators"
    echo ""
    print_topic "site: - Limit to specific domain"
    print_example "site:example.com"
    print_example "site:example.com login"
    echo ""
    print_topic "intitle: - Search in page title"
    print_example "intitle:\"index of\" password"
    print_example "intitle:\"admin panel\""
    echo ""
    print_topic "inurl: - Search in URL"
    print_example "inurl:admin"
    print_example "inurl:login.php"
    echo ""
    print_topic "filetype: - Specific file types"
    print_example "filetype:pdf site:example.com"
    print_example "filetype:sql \"password\""
    print_example "filetype:env DB_PASSWORD"
    echo ""
    print_topic "intext: - Search in page body"
    print_example "intext:\"sql syntax error\""
    print_example "intext:\"index of /\" \".git\""
    echo ""
    print_topic "cache: - Google cached version"
    print_example "cache:example.com"
    echo ""

    print_sub_header "Useful Google Dorks for Security"
    echo ""
    print_topic "Finding Login Pages:"
    print_info "  site:target.com inurl:login"
    print_info "  site:target.com inurl:admin"
    print_info "  site:target.com intitle:login"
    echo ""
    print_topic "Finding Sensitive Files:"
    print_info "  site:target.com filetype:pdf confidential"
    print_info "  site:target.com filetype:xls email"
    print_info "  site:target.com filetype:sql password"
    print_info "  site:target.com filetype:log"
    print_info "  site:target.com filetype:env"
    echo ""
    print_topic "Finding Exposed Directories:"
    print_info "  site:target.com intitle:\"index of\""
    print_info "  site:target.com intitle:\"index of\" .git"
    print_info "  site:target.com intitle:\"index of\" backup"
    echo ""
    print_topic "Finding Error Messages:"
    print_info "  site:target.com \"sql syntax error\""
    print_info "  site:target.com \"mysql_fetch_array()\""
    print_info "  site:target.com \"Warning: include()\""
    echo ""
    print_topic "Finding Cameras & IoT:"
    print_info "  inurl:view/view.shtml"
    print_info "  intitle:\"Live View\" inurl:axis"
    echo ""
    print_note "Google Dorking Database: exploit-db.com/google-hacking-database"
    print_warning "Only dork targets you have permission to test!"

    log_progress "Completed Module 3 Lesson 5"
    update_progress
    press_continue
}

module_3_lesson_6() {
    print_section_header "NMAP DEEP DIVE" "3.6"

    print_sub_header "Nmap Scan Types"
    echo ""
    print_topic "Host Discovery"
    print_command "nmap -sn 192.168.1.0/24        # Ping sweep"
    print_command "nmap -sn -PS22,80 target        # TCP SYN ping"
    print_command "nmap -sn -PA80 target            # TCP ACK ping"
    print_command "nmap -sn -PU target              # UDP ping"
    echo ""

    print_topic "Port Scanning"
    print_command "nmap -sS target                  # TCP SYN (stealth)"
    print_command "nmap -sT target                  # TCP Connect"
    print_command "nmap -sU target                  # UDP scan"
    print_command "nmap -sA target                  # ACK scan"
    print_command "nmap -sW target                  # Window scan"
    print_command "nmap -sN target                  # NULL scan"
    print_command "nmap -sF target                  # FIN scan"
    print_command "nmap -sX target                  # Xmas scan"
    echo ""

    print_topic "Port Ranges"
    print_command "nmap -p 80 target                # Single port"
    print_command "nmap -p 1-1000 target            # Port range"
    print_command "nmap -p- target                  # All 65535 ports"
    print_command "nmap -p 80,443,8080 target       # Specific ports"
    print_command "nmap --top-ports 100 target      # Top 100 ports"
    echo ""

    print_topic "Service & Version Detection"
    print_command "nmap -sV target                  # Version detection"
    print_command "nmap -sV --version-intensity 5 target"
    print_command "nmap -O target                   # OS detection"
    print_command "nmap -A target                   # Aggressive (OS+ver+script+trace)"
    echo ""

    print_topic "NSE Scripts"
    print_command "nmap -sC target                  # Default scripts"
    print_command "nmap --script=vuln target         # Vulnerability scripts"
    print_command "nmap --script=http-enum target    # HTTP enumeration"
    print_command "nmap --script=smb-vuln* target    # SMB vulnerabilities"
    print_command "nmap --script=ssl-heartbleed target"
    echo ""

    print_topic "Output Formats"
    print_command "nmap -oN output.txt target       # Normal output"
    print_command "nmap -oX output.xml target       # XML output"
    print_command "nmap -oG output.grep target      # Grepable output"
    print_command "nmap -oA output target            # All formats"
    echo ""

    print_topic "Evasion & Performance"
    print_command "nmap -T0 target                  # Paranoid (IDS evasion)"
    print_command "nmap -T1 target                  # Sneaky"
    print_command "nmap -T4 target                  # Aggressive (fast)"
    print_command "nmap -D RND:10 target            # Decoy scan"
    print_command "nmap -f target                   # Fragment packets"
    print_command "nmap --source-port 53 target     # Spoof source port"
    echo ""

    print_sub_header "Practical Scan Examples"
    print_topic "Quick Scan:"
    print_command "nmap -sV -sC -T4 -p- target"
    echo ""
    print_topic "Stealth Scan:"
    print_command "nmap -sS -sV -T2 -f --data-length 200 target"
    echo ""
    print_topic "Full Audit:"
    print_command "nmap -sS -sV -sC -O -A -p- -oA full_scan target"

    log_progress "Completed Module 3 Lesson 6"
    update_progress
    press_continue
}

module_3_lesson_7() {
    print_section_header "OSINT TOOLS & FRAMEWORKS" "3.7"

    print_sub_header "theHarvester"
    print_info "Gather emails, subdomains, hosts, employee names"
    print_command "pip install theHarvester"
    print_command "theHarvester -d example.com -b google,bing,linkedin"
    echo ""

    print_sub_header "Sherlock"
    print_info "Find usernames across social networks"
    print_command "pip install sherlock-project"
    print_command "sherlock username"
    echo ""

    print_sub_header "Recon-ng"
    print_info "Full-featured reconnaissance framework"
    print_command "pip install recon-ng"
    echo ""

    print_sub_header "Maltego"
    print_info "Visual link analysis for OSINT (GUI-based)"
    print_info "Used for mapping relationships between entities"
    echo ""

    print_sub_header "SpiderFoot"
    print_info "Automated OSINT collection"
    print_command "pip install spiderfoot"
    echo ""

    print_sub_header "Custom OSINT Script"
    cat > "$SCRIPTS_DIR/osint_recon.sh" << 'SCRIPT'
#!/bin/bash
# OSINT Reconnaissance Script
# Usage: ./osint_recon.sh <domain>

DOMAIN=$1
OUTPUT_DIR="recon_$DOMAIN"

if [ -z "$DOMAIN" ]; then
    echo "Usage: $0 <domain>"
    exit 1
fi

mkdir -p "$OUTPUT_DIR"

echo "╔══════════════════════════════════════╗"
echo "║       OSINT RECON FRAMEWORK          ║"
echo "║       Target: $DOMAIN"
echo "╚══════════════════════════════════════╝"

echo ""
echo "[*] Step 1: WHOIS Lookup"
echo "=============================="
whois $DOMAIN > "$OUTPUT_DIR/whois.txt" 2>/dev/null
echo "Saved to $OUTPUT_DIR/whois.txt"

echo ""
echo "[*] Step 2: DNS Records"
echo "=============================="
echo "--- A Records ---" > "$OUTPUT_DIR/dns.txt"
dig $DOMAIN A +short >> "$OUTPUT_DIR/dns.txt" 2>/dev/null
echo "--- MX Records ---" >> "$OUTPUT_DIR/dns.txt"
dig $DOMAIN MX +short >> "$OUTPUT_DIR/dns.txt" 2>/dev/null
echo "--- NS Records ---" >> "$OUTPUT_DIR/dns.txt"
dig $DOMAIN NS +short >> "$OUTPUT_DIR/dns.txt" 2>/dev/null
echo "--- TXT Records ---" >> "$OUTPUT_DIR/dns.txt"
dig $DOMAIN TXT +short >> "$OUTPUT_DIR/dns.txt" 2>/dev/null
cat "$OUTPUT_DIR/dns.txt"

echo ""
echo "[*] Step 3: Subdomain Enumeration"
echo "=============================="
SUBS=(www mail ftp admin blog dev staging api test app portal
      vpn webmail shop cdn assets git jenkins wiki dashboard)
for sub in "${SUBS[@]}"; do
    IP=$(dig +short $sub.$DOMAIN 2>/dev/null | head -1)
    if [ -n "$IP" ]; then
        echo "[+] $sub.$DOMAIN -> $IP"
        echo "$sub.$DOMAIN -> $IP" >> "$OUTPUT_DIR/subdomains.txt"
    fi
done

echo ""
echo "[*] Step 4: HTTP Headers"
echo "=============================="
curl -sI "https://$DOMAIN" > 
