#!/data/data/com.termux/files/usr/bin/bash

# ================================================
#     ETHGUIDE.SH - Ethical Hacking Roadmap
#     For Termux - Step by Step Learning Path
# ================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

clear
echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     ETHGUIDE - Ethical Hacking Assistant  ║${NC}"
echo -e "${BLUE}║               For Termux                   ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${RED}⚠️  WARNING: FOR EDUCATIONAL PURPOSES ONLY${NC}"
echo -e "${YELLOW}Only use on systems you own or have explicit permission to test.${NC}"
echo -e "Unauthorized hacking is illegal.\n"

current_phase=0

show_next() {
    echo -e "\n${PURPLE}→ Next Recommended Phase: ${YELLOW}$1${NC}\n"
}

while true; do
    echo -e "${GREEN}Current Progress: Phase $current_phase/8${NC}"
    echo "────────────────────────────────────"
    echo "1. Phase 1  → Setup & Update Termux"
    echo "2. Phase 2  → Information Gathering (Recon)"
    echo "3. Phase 3  → Scanning & Enumeration"
    echo "4. Phase 4  → Vulnerability Analysis"
    echo "5. Phase 5  → Exploitation"
    echo "6. Phase 6  → Post-Exploitation"
    echo "7. Phase 7  → Covering Tracks"
    echo "8. Phase 8  → Reporting"
    echo "9. Install Common Hacking Tools"
    echo "0. Exit"
    echo "────────────────────────────────────"
    read -p "Select phase you want to do now: " choice

    case $choice in
        1)
            echo -e "\n${GREEN}=== [PHASE 1] Setup & Update Termux ===${NC}\n"
            echo "Commands to run:"
            echo -e "${YELLOW}pkg update -y && pkg upgrade -y${NC}"
            echo -e "${YELLOW}pkg install git python python2 ruby nodejs ffmpeg curl wget -y${NC}"
            echo -e "${YELLOW}termux-setup-storage${NC}"
            echo ""
            echo "After this phase is complete, you should install hacking tools."
            current_phase=1
            show_next "Phase 9 (Install Tools) → Then Phase 2"
            ;;

        2)
            echo -e "\n${GREEN}=== [PHASE 2] Reconnaissance (OSINT) ===${NC}\n"
            echo "Recommended Tools: whois, nslookup, theHarvester, recon-ng, amass, subfinder"
            echo ""
            echo "Examples:"
            echo -e "${YELLOW}whois target.com${NC}"
            echo -e "${YELLOW}nmap -sS -Pn target.com${NC}"
            echo -e "${YELLOW}python3 theHarvester.py -d target.com -b all${NC}"
            echo ""
            current_phase=2
            show_next "Phase 3 - Scanning & Enumeration"
            ;;

        3)
            echo -e "\n${GREEN}=== [PHASE 3] Scanning & Enumeration ===${NC}\n"
            echo "Commands:"
            echo -e "${YELLOW}nmap -sC -sV -A target.com${NC}"
            echo -e "${YELLOW}nmap -sV --script vuln target.com${NC}"
            echo -e "${YELLOW}dirsearch -u https://target.com${NC}"
            echo ""
            echo "Also try: nikto, gobuster, ffuf"
            current_phase=3
            show_next "Phase 4 - Vulnerability Analysis"
            ;;

        4)
            echo -e "\n${GREEN}=== [PHASE 4] Vulnerability Analysis ===${NC}\n"
            echo "Tools: sqlmap, nikto, nuclei, OWASP ZAP (via browser)"
            echo ""
            echo "Example:"
            echo -e "${YELLOW}sqlmap -u \"https://target.com/login.php?id=1\" --batch --risk=3${NC}"
            echo -e "${YELLOW}nuclei -u https://target.com${NC}"
            current_phase=4
            show_next "Phase 5 - Exploitation"
            ;;

        5)
            echo -e "\n${GREEN}=== [PHASE 5] Exploitation ===${NC}\n"
            echo "Popular Tools in Termux:"
            echo "- Metasploit Framework (msfconsole)"
            echo "- sqlmap"
            echo "- commix"
            echo "- zphisher (Social Engineering)"
            echo ""
            echo -e "${YELLOW}msfconsole${NC} → Then use appropriate exploit"
            current_phase=5
            show_next "Phase 6 - Post-Exploitation"
            ;;

        6)
            echo -e "\n${GREEN}=== [PHASE 6] Post-Exploitation ===${NC}\n"
            echo "Actions usually include:"
            echo "• Privilege escalation"
            echo "• Data exfiltration"
            echo "• Installing backdoors"
            echo "• Maintaining persistent access"
            echo ""
            echo "In Termux: Use Metasploit post modules"
            current_phase=6
            show_next "Phase 7 - Covering Tracks"
            ;;

        7)
            echo -e "\n${GREEN}=== [PHASE 7] Covering Tracks ===${NC}\n"
            echo "Techniques:"
            echo "• Clear logs"
            echo "• Delete uploaded files"
            echo "• Modify timestamps"
            echo "• Use anti-forensic tools"
            current_phase=7
            show_next "Phase 8 - Reporting"
            ;;

        8)
            echo -e "\n${GREEN}=== [PHASE 8] Reporting ===${NC}\n"
            echo "Create a professional report including:"
            echo "• Executive Summary"
            echo "• Scope"
            echo "• Vulnerabilities found (with screenshots)"
            echo "• Risk ratings (CVSS)"
            echo "• Recommendations"
            current_phase=8
            echo -e "${GREEN}Congratulations! You completed the full methodology.${NC}"
            ;;

        9)
            echo -e "\n${GREEN}=== Installing Common Ethical Hacking Tools ===${NC}\n"
            echo "This may take time..."
            echo ""
            echo -e "${YELLOW}Installing nmap, metasploit, sqlmap, hydra, nikto...${NC}"
            pkg install nmap metasploit sqlmap hydra nikto curl -y
            echo -e "\n${GREEN}Basic tools installed!${NC}"
            echo "For more tools (zphisher, OSINT tools, etc.), run: git clone [repo]"
            current_phase=1
            show_next "Phase 2 - Reconnaissance"
            ;;

        0)
            echo -e "${BLUE}Goodbye! Stay ethical.${NC}"
            exit 0
            ;;

        *)
            echo -e "${RED}Invalid option!${NC}"
            ;;
    esac

    echo -e "${BLUE}────────────────────────────────────${NC}"
    read -p "Press ENTER to return to menu..."
    clear
done
