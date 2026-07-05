#!/data/data/com.termux/files/usr/bin/bash

# ============================================================
# Advanced Termux Tools Manager v2.0
# Author: Emmanuel suah
# Description: Interactive tool guide for Termux with
#              categories, usage times, and purposes
# ============================================================

# --- Colors ---
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
RESET='\033[0m'

# --- Symbols ---
CHECK="✅"
CROSS="❌"
ARROW="➤"
STAR="⭐"
TOOL="🔧"
SHIELD="🛡️"
GLOBE="🌐"
FILE="📁"
CODE="💻"
WARN="⚠️"
INFO="ℹ️"
CLOCK="🕐"
TARGET="🎯"
BOOK="📖"
PACKAGE="📦"
SEARCH="🔍"
LOCK="🔒"
FIRE="🔥"
LIGHTNING="⚡"
GEAR="⚙️"

# --- Variables ---
LOGFILE="$HOME/termux_tools.log"
INSTALLED_CACHE="/tmp/installed_tools_cache"
VERSION="2.0"

# ============================================================
# UTILITY FUNCTIONS
# ============================================================

log_action() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOGFILE"
}

clear_screen() {
    clear
}

press_enter() {
    echo ""
    echo -e "${DIM}Press Enter to continue...${RESET}"
    read -r
}

# Check if a tool is installed
check_installed() {
    local tool="$1"
    if command -v "$tool" &>/dev/null || dpkg -l "$tool" &>/dev/null 2>&1 || pip show "$tool" &>/dev/null 2>&1; then
        echo -e "${GREEN}${CHECK} Installed${RESET}"
        return 0
    else
        echo -e "${RED}${CROSS} Not Installed${RESET}"
        return 1
    fi
}

# Progress bar animation
progress_bar() {
    local duration=${1:-3}
    local width=40
    for ((i=0; i<=width; i++)); do
        local percent=$((i * 100 / width))
        local filled=$i
        local empty=$((width - i))
        printf "\r${CYAN}  ["
        printf "%0.s█" $(seq 1 $filled) 2>/dev/null
        printf "%0.s░" $(seq 1 $empty) 2>/dev/null
        printf "] %d%%${RESET}" $percent
        sleep "$(echo "$duration / $width" | bc -l 2>/dev/null || echo "0.05")"
    done
    echo ""
}

# Loading animation
loading_animation() {
    local msg="${1:-Loading}"
    local pid=$!
    local spinchars='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    local i=0
    while kill -0 $pid 2>/dev/null; do
        local char="${spinchars:$i:1}"
        printf "\r${CYAN}  ${char} ${msg}...${RESET}"
        i=$(( (i + 1) % ${#spinchars} ))
        sleep 0.1
    done
    printf "\r${GREEN}  ${CHECK} ${msg}... Done!${RESET}\n"
}

# Banner
show_banner() {
    clear_screen
    echo -e "${CYAN}"
    cat << 'BANNER'
    ╔══════════════════════════════════════════════════════════════╗
    ║                                                              ║
    ║   ████████╗███████╗██████╗ ███╗   ███╗██╗   ██╗██╗  ██╗    ║
    ║   ╚══██╔══╝██╔════╝██╔══██╗████╗ ████║██║   ██║╚██╗██╔╝    ║
    ║      ██║   █████╗  ██████╔╝██╔████╔██║██║   ██║ ╚███╔╝     ║
    ║      ██║   ██╔══╝  ██╔══██╗██║╚██╔╝██║██║   ██║ ██╔██╗     ║
    ║      ██║   ███████╗██║  ██║██║ ╚═╝ ██║╚██████╔╝██╔╝ ██╗    ║
    ║      ╚═╝   ╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝ ╚═════╝╚═╝  ╚═╝    ║
    ║                                                              ║
    ║        ⚡ ADVANCED TOOLS MANAGER v2.0 ⚡                     ║
    ║                                                              ║
    ╚══════════════════════════════════════════════════════════════╝
BANNER
    echo -e "${RESET}"
    echo -e "${DIM}${WHITE}    Your Complete Guide to Termux Tools - When, Why & How${RESET}"
    echo -e "${DIM}${WHITE}    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo ""
}

# Separator
separator() {
    echo -e "${CYAN}  ══════════════════════════════════════════════════════════${RESET}"
}

# Section header
section_header() {
    echo ""
    echo -e "${YELLOW}  ┌──────────────────────────────────────────────────────┐${RESET}"
    echo -e "${YELLOW}  │  ${WHITE}${BOLD}$1${RESET}${YELLOW}$(printf '%*s' $((52 - ${#1})) '')│${RESET}"
    echo -e "${YELLOW}  └──────────────────────────────────────────────────────┘${RESET}"
    echo ""
}

# Tool display card
show_tool_card() {
    local name="$1"
    local category="$2"
    local install_cmd="$3"
    local when_to_use="$4"
    local purpose="$5"
    local usage_example="$6"
    local difficulty="$7"
    local status

    status=$(check_installed "$name")

    echo -e "${BLUE}  ┌─────────────────────────────────────────────────────────┐${RESET}"
    echo -e "${BLUE}  │ ${TOOL} ${WHITE}${BOLD}${name^^}${RESET}${BLUE}$(printf '%*s' $((49 - ${#name})) '')│${RESET}"
    echo -e "${BLUE}  ├─────────────────────────────────────────────────────────┤${RESET}"
    echo -e "${BLUE}  │${RESET} ${GEAR} Category    : ${MAGENTA}${category}${RESET}"
    echo -e "${BLUE}  │${RESET} ${PACKAGE} Status      : ${status}"
    echo -e "${BLUE}  │${RESET} ${LIGHTNING} Difficulty  : ${difficulty}"
    echo -e "${BLUE}  │${RESET} ${CLOCK} When to Use : ${YELLOW}${when_to_use}${RESET}"
    echo -e "${BLUE}  │${RESET} ${TARGET} Purpose     : ${GREEN}${purpose}${RESET}"
    echo -e "${BLUE}  │${RESET} ${BOOK} Install     : ${CYAN}${install_cmd}${RESET}"
    echo -e "${BLUE}  │${RESET} ${CODE} Usage       : ${WHITE}${usage_example}${RESET}"
    echo -e "${BLUE}  └─────────────────────────────────────────────────────────┘${RESET}"
    echo ""
}

# Difficulty display
diff_beginner() {
    echo -e "${GREEN}★☆☆☆☆ Beginner${RESET}"
}
diff_easy() {
    echo -e "${GREEN}★★☆☆☆ Easy${RESET}"
}
diff_medium() {
    echo -e "${YELLOW}★★★☆☆ Medium${RESET}"
}
diff_hard() {
    echo -e "${ORANGE}★★★★☆ Hard${RESET}"
}
diff_expert() {
    echo -e "${RED}★★★★★ Expert${RESET}"
}

# ============================================================
# TOOL CATEGORIES
# ============================================================

# --- 1. NETWORK ANALYSIS TOOLS ---
network_tools() {
    show_banner
    section_header "${GLOBE} NETWORK ANALYSIS & SCANNING TOOLS"

    show_tool_card \
        "nmap" \
        "Network Scanner" \
        "pkg install nmap" \
        "Network auditing, port scanning, host discovery" \
        "Scan networks to find open ports, services, OS detection, vulnerability assessment" \
        "nmap -sV -sC <target_ip>" \
        "$(diff_medium)"

    show_tool_card \
        "netcat" \
        "Network Utility" \
        "pkg install netcat-openbsd" \
        "When you need raw TCP/UDP connections, port scanning, file transfer" \
        "Swiss army knife for networking - chat, file transfer, port scanning, reverse shells" \
        "nc -lvp 4444 | nc <ip> <port>" \
        "$(diff_medium)"

    show_tool_card \
        "traceroute" \
        "Network Diagnostics" \
        "pkg install traceroute" \
        "When checking network path, diagnosing routing issues" \
        "Trace packet route to destination, identify network hops and latency" \
        "traceroute google.com" \
        "$(diff_beginner)"

    show_tool_card \
        "whois" \
        "Domain Lookup" \
        "pkg install whois" \
        "When researching domain ownership and registration details" \
        "Query domain registration info, find owner, registrar, creation date" \
        "whois example.com" \
        "$(diff_beginner)"

    show_tool_card \
        "dnsutils" \
        "DNS Query" \
        "pkg install dnsutils" \
        "When troubleshooting DNS, looking up domain records" \
        "DNS lookup tools (dig, nslookup, host) for querying DNS records" \
        "dig example.com ANY | nslookup example.com" \
        "$(diff_easy)"

    show_tool_card \
        "curl" \
        "Data Transfer" \
        "pkg install curl" \
        "When downloading files, testing APIs, sending HTTP requests" \
        "Transfer data via URLs, API testing, file download, header inspection" \
        "curl -I https://example.com | curl -X POST -d 'data' URL" \
        "$(diff_easy)"

    show_tool_card \
        "wget" \
        "File Downloader" \
        "pkg install wget" \
        "When downloading files, mirroring websites, batch downloads" \
        "Non-interactive file downloader, supports recursive download, resume" \
        "wget -r -np https://example.com" \
        "$(diff_beginner)"

    show_tool_card \
        "tcpdump" \
        "Packet Analyzer" \
        "pkg install tcpdump" \
        "When capturing and analyzing network traffic in real-time" \
        "Capture network packets, analyze traffic, debug network issues" \
        "tcpdump -i wlan0 -w capture.pcap" \
        "$(diff_hard)"

    show_tool_card \
        "ipcalc" \
        "IP Calculator" \
        "pkg install ipcalc" \
        "When calculating subnet masks, network ranges, IP info" \
        "Calculate IP network information, subnets, broadcast addresses" \
        "ipcalc 192.168.1.0/24" \
        "$(diff_beginner)"

    show_tool_card \
        "net-tools" \
        "Network Config" \
        "pkg install net-tools" \
        "When checking network interfaces, routing tables" \
        "Classic networking commands (ifconfig, netstat, route, arp)" \
        "ifconfig | netstat -tuln" \
        "$(diff_easy)"

    show_tool_card \
        "aria2" \
        "Download Manager" \
        "pkg install aria2" \
        "When downloading large files, multi-source downloads, torrents" \
        "Multi-protocol download utility with resume, parallel connections" \
        "aria2c -x 16 -s 16 <url>" \
        "$(diff_easy)"

    show_tool_card \
        "socat" \
        "Multipurpose Relay" \
        "pkg install socat" \
        "When establishing bidirectional data streams, port forwarding" \
        "Advanced netcat - relay, proxy, port forwarding, SSL tunnels" \
        "socat TCP-LISTEN:8080,fork TCP:target:80" \
        "$(diff_hard)"

    press_enter
}

# --- 2. SECURITY & PENTESTING TOOLS ---
security_tools() {
    show_banner
    section_header "${SHIELD} SECURITY & PENETRATION TESTING TOOLS"

    show_tool_card \
        "hydra" \
        "Password Cracker" \
        "pkg install hydra" \
        "When testing login security, password strength assessment" \
        "Online password brute-force tool for SSH, FTP, HTTP, and 50+ protocols" \
        "hydra -l admin -P wordlist.txt ssh://target" \
        "$(diff_hard)"

    show_tool_card \
        "john" \
        "Hash Cracker" \
        "pkg install john" \
        "When cracking password hashes, testing hash security" \
        "John the Ripper - crack password hashes (MD5, SHA, NTLM, etc.)" \
        "john --wordlist=rockyou.txt hashes.txt" \
        "$(diff_hard)"

    show_tool_card \
        "hashcat" \
        "Advanced Hash Cracker" \
        "pkg install hashcat" \
        "When GPU-accelerated hash cracking is needed" \
        "World's fastest password recovery tool, supports 300+ hash types" \
        "hashcat -m 0 -a 0 hash.txt wordlist.txt" \
        "$(diff_expert)"

    show_tool_card \
        "sqlmap" \
        "SQL Injection" \
        "pip install sqlmap" \
        "When testing web apps for SQL injection vulnerabilities" \
        "Automated SQL injection detection and exploitation tool" \
        "sqlmap -u 'http://target/page?id=1' --dbs" \
        "$(diff_hard)"

    show_tool_card \
        "nikto" \
        "Web Scanner" \
        "pkg install nikto" \
        "When scanning web servers for known vulnerabilities" \
        "Web server scanner - finds dangerous files, outdated software, misconfigs" \
        "nikto -h http://target" \
        "$(diff_medium)"

    show_tool_card \
        "metasploit" \
        "Exploitation Framework" \
        "pkg install unstable-repo && pkg install metasploit" \
        "When performing penetration tests, exploit development" \
        "World's most used penetration testing framework with 2000+ exploits" \
        "msfconsole -> use exploit/... -> set RHOST -> run" \
        "$(diff_expert)"

    show_tool_card \
        "aircrack-ng" \
        "WiFi Security" \
        "pkg install aircrack-ng" \
        "When testing WiFi network security (requires root)" \
        "WiFi security audit - capture handshakes, crack WPA/WPA2 keys" \
        "aircrack-ng -w wordlist.txt capture.cap" \
        "$(diff_expert)"

    show_tool_card \
        "openssl" \
        "Cryptography" \
        "pkg install openssl-tool" \
        "When encrypting files, generating certificates, testing SSL" \
        "SSL/TLS toolkit - encryption, certificates, hashing, key generation" \
        "openssl enc -aes-256-cbc -in file -out file.enc" \
        "$(diff_medium)"

    show_tool_card \
        "crunch" \
        "Wordlist Generator" \
        "pkg install crunch" \
        "When generating custom wordlists for password testing" \
        "Generate custom wordlists with specific patterns and character sets" \
        "crunch 8 12 abcdef123 -o wordlist.txt" \
        "$(diff_medium)"

    show_tool_card \
        "gobuster" \
        "Directory Bruteforcer" \
        "pkg install gobuster" \
        "When finding hidden directories and files on web servers" \
        "Brute-force URIs, DNS subdomains, virtual hostnames, S3 buckets" \
        "gobuster dir -u http://target -w wordlist.txt" \
        "$(diff_medium)"

    show_tool_card \
        "sslscan" \
        "SSL/TLS Analyzer" \
        "pkg install sslscan" \
        "When testing SSL/TLS configuration of servers" \
        "Query SSL/TLS services, find weak ciphers, expired certificates" \
        "sslscan example.com" \
        "$(diff_easy)"

    press_enter
}

# --- 3. PROGRAMMING & DEVELOPMENT TOOLS ---
programming_tools() {
    show_banner
    section_header "${CODE} PROGRAMMING & DEVELOPMENT TOOLS"

    show_tool_card \
        "python" \
        "Programming Language" \
        "pkg install python" \
        "When scripting, automation, web dev, data science, AI/ML" \
        "Versatile programming language - scripts, web apps, automation, tools" \
        "python script.py | python -c 'print(\"Hello\")'" \
        "$(diff_easy)"

    show_tool_card \
        "nodejs" \
        "JavaScript Runtime" \
        "pkg install nodejs" \
        "When building web servers, APIs, full-stack JavaScript apps" \
        "Server-side JavaScript runtime - web servers, APIs, real-time apps" \
        "node app.js | npm init | npm install express" \
        "$(diff_easy)"

    show_tool_card \
        "ruby" \
        "Programming Language" \
        "pkg install ruby" \
        "When scripting, web dev (Rails), security tools development" \
        "Dynamic language - web development, scripting, many security tools" \
        "ruby script.rb | irb (interactive)" \
        "$(diff_easy)"

    show_tool_card \
        "golang" \
        "Programming Language" \
        "pkg install golang" \
        "When building high-performance tools, compiled binaries" \
        "Fast, compiled language - system tools, web services, CLI tools" \
        "go build main.go | go run main.go" \
        "$(diff_medium)"

    show_tool_card \
        "clang" \
        "C/C++ Compiler" \
        "pkg install clang" \
        "When compiling C/C++ programs, system-level programming" \
        "C/C++/Objective-C compiler - compile native programs and tools" \
        "clang -o program program.c | clang++ -o prog prog.cpp" \
        "$(diff_medium)"

    show_tool_card \
        "rust" \
        "Programming Language" \
        "pkg install rust" \
        "When building safe, concurrent, high-performance software" \
        "Systems programming language focused on safety and performance" \
        "rustc main.rs | cargo build" \
        "$(diff_hard)"

    show_tool_card \
        "php" \
        "Web Language" \
        "pkg install php" \
        "When developing web applications, server-side scripting" \
        "Server-side scripting for web development, CMS, web apps" \
        "php -S localhost:8080 | php script.php" \
        "$(diff_easy)"

    show_tool_card \
        "perl" \
        "Scripting Language" \
        "pkg install perl" \
        "When text processing, regex operations, system admin scripts" \
        "Powerful text processing, regex master, system administration" \
        "perl -e 'print \"Hello\\n\"' | perl script.pl" \
        "$(diff_medium)"

    show_tool_card \
        "lua" \
        "Scripting Language" \
        "pkg install lua54" \
        "When lightweight scripting, game development, embedding" \
        "Lightweight embeddable scripting language - games, configs, scripts" \
        "lua script.lua" \
        "$(diff_easy)"

    show_tool_card \
        "git" \
        "Version Control" \
        "pkg install git" \
        "ALWAYS - for code versioning, collaboration, cloning repos" \
        "Version control system - track changes, collaborate, manage code" \
        "git clone <url> | git add . && git commit -m 'msg' && git push" \
        "$(diff_easy)"

    show_tool_card \
        "cmake" \
        "Build System" \
        "pkg install cmake" \
        "When building C/C++ projects with complex dependencies" \
        "Cross-platform build system generator for C/C++ projects" \
        "cmake . && make" \
        "$(diff_medium)"

    press_enter
}

# --- 4. TEXT EDITORS & FILE MANAGEMENT ---
editor_tools() {
    show_banner
    section_header "${FILE} TEXT EDITORS & FILE MANAGEMENT TOOLS"

    show_tool_card \
        "vim" \
        "Text Editor" \
        "pkg install vim" \
        "When editing files, coding, configuration - power users" \
        "Advanced modal text editor - efficient coding, scripting, configs" \
        "vim file.txt | vim +PlugInstall (with vim-plug)" \
        "$(diff_medium)"

    show_tool_card \
        "nano" \
        "Text Editor" \
        "pkg install nano" \
        "When quick file editing needed, beginners' editor" \
        "Simple, user-friendly text editor - quick edits, configs" \
        "nano file.txt (Ctrl+X to save and exit)" \
        "$(diff_beginner)"

    show_tool_card \
        "neovim" \
        "Modern Text Editor" \
        "pkg install neovim" \
        "When you want modernized Vim with better plugin ecosystem" \
        "Hyperextensible Vim-fork - modern editor with LSP, Lua plugins" \
        "nvim file.txt" \
        "$(diff_medium)"

    show_tool_card \
        "micro" \
        "Modern Terminal Editor" \
        "pkg install micro" \
        "When you want a modern, intuitive terminal editor" \
        "Modern terminal editor with mouse support, syntax highlighting" \
        "micro file.txt" \
        "$(diff_beginner)"

    show_tool_card \
        "tree" \
        "Directory Viewer" \
        "pkg install tree" \
        "When visualizing directory structures" \
        "Display directory tree structure in a visual format" \
        "tree -L 3 -a /path/to/dir" \
        "$(diff_beginner)"

    show_tool_card \
        "ranger" \
        "File Manager" \
        "pip install ranger-fm" \
        "When browsing files with VI-like keybindings in terminal" \
        "Console file manager with VI keybindings, preview, bookmarks" \
        "ranger" \
        "$(diff_easy)"

    show_tool_card \
        "mc" \
        "File Manager" \
        "pkg install mc" \
        "When you need a dual-pane file manager in terminal" \
        "Midnight Commander - visual file manager, FTP client, editor" \
        "mc" \
        "$(diff_easy)"

    show_tool_card \
        "tmux" \
        "Terminal Multiplexer" \
        "pkg install tmux" \
        "When running multiple terminal sessions, persistent sessions" \
        "Terminal multiplexer - split panes, multiple windows, session persistence" \
        "tmux new -s work | tmux attach -t work" \
        "$(diff_medium)"

    show_tool_card \
        "screen" \
        "Terminal Multiplexer" \
        "pkg install screen" \
        "When you need persistent terminal sessions that survive disconnects" \
        "Terminal multiplexer - persistent sessions, detach/reattach" \
        "screen -S mysession | screen -r mysession" \
        "$(diff_easy)"

    show_tool_card \
        "bat" \
        "Enhanced Cat" \
        "pkg install bat" \
        "When viewing files with syntax highlighting and line numbers" \
        "Cat clone with syntax highlighting, git integration, paging" \
        "bat file.py | bat --theme=Dracula file.js" \
        "$(diff_beginner)"

    show_tool_card \
        "fzf" \
        "Fuzzy Finder" \
        "pkg install fzf" \
        "When searching files, history, processes interactively" \
        "Command-line fuzzy finder - search files, history, processes" \
        "fzf | vim \$(fzf) | history | fzf" \
        "$(diff_easy)"

    show_tool_card \
        "zip" \
        "Compression" \
        "pkg install zip unzip" \
        "When compressing/extracting ZIP archives" \
        "ZIP compression and extraction utility" \
        "zip -r archive.zip folder/ | unzip archive.zip" \
        "$(diff_beginner)"

    show_tool_card \
        "tar" \
        "Archiver" \
        "pkg install tar" \
        "When creating/extracting tar archives (tar.gz, tar.bz2)" \
        "Archive utility - bundle files, commonly used with gzip/bzip2" \
        "tar -czf archive.tar.gz folder/ | tar -xzf archive.tar.gz" \
        "$(diff_beginner)"

    press_enter
}

# --- 5. INFORMATION GATHERING & OSINT ---
osint_tools() {
    show_banner
    section_header "${SEARCH} INFORMATION GATHERING & OSINT TOOLS"

    show_tool_card \
        "theHarvester" \
        "OSINT Recon" \
        "pip install theHarvester" \
        "When gathering emails, subdomains, IPs from public sources" \
        "Gather emails, subdomains, hosts, employee names from public sources" \
        "theHarvester -d target.com -b google" \
        "$(diff_medium)"

    show_tool_card \
        "subfinder" \
        "Subdomain Finder" \
        "go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest" \
        "When enumerating subdomains of a target domain" \
        "Fast passive subdomain enumeration using multiple sources" \
        "subfinder -d target.com -o subdomains.txt" \
        "$(diff_easy)"

    show_tool_card \
        "httpx" \
        "HTTP Prober" \
        "go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest" \
        "When probing HTTP servers, finding alive hosts, tech stack" \
        "Fast HTTP toolkit - probe alive hosts, status codes, tech detection" \
        "cat urls.txt | httpx -status-code -title" \
        "$(diff_medium)"

    show_tool_card \
        "amass" \
        "Subdomain Enum" \
        "go install -v github.com/owasp-amass/amass/v4/...@master" \
        "When comprehensive subdomain enumeration is needed" \
        "In-depth DNS enumeration, attack surface mapping, OSINT" \
        "amass enum -d target.com -o results.txt" \
        "$(diff_hard)"

    show_tool_card \
        "exiftool" \
        "Metadata Reader" \
        "pkg install exiftool" \
        "When reading/writing metadata from images, documents, media" \
        "Read and write metadata in images, audio, video, PDF files" \
        "exiftool image.jpg | exiftool -all= image.jpg (strip meta)" \
        "$(diff_easy)"

    show_tool_card \
        "binwalk" \
        "Firmware Analyzer" \
        "pip install binwalk" \
        "When analyzing firmware, embedded files, binary data" \
        "Firmware analysis tool - find embedded files, file systems, signatures" \
        "binwalk -e firmware.bin" \
        "$(diff_hard)"

    show_tool_card \
        "sherlock" \
        "Username OSINT" \
        "pip install sherlock-project" \
        "When searching for usernames across social media platforms" \
        "Hunt usernames across 400+ social networks simultaneously" \
        "sherlock username" \
        "$(diff_beginner)"

    show_tool_card \
        "shodan" \
        "IoT Search Engine" \
        "pip install shodan" \
        "When searching for internet-connected devices and services" \
        "Search engine for IoT - find devices, servers, cameras, databases" \
        "shodan search 'apache' | shodan host <ip>" \
        "$(diff_medium)"

    show_tool_card \
        "waybackurls" \
        "Archive URLs" \
        "go install github.com/tomnomnom/waybackurls@latest" \
        "When finding old/archived URLs of a target website" \
        "Fetch URLs from Wayback Machine for historical analysis" \
        "echo target.com | waybackurls > urls.txt" \
        "$(diff_easy)"

    press_enter
}

# --- 6. SYSTEM UTILITIES ---
system_tools() {
    show_banner
    section_header "${GEAR} SYSTEM & UTILITY TOOLS"

    show_tool_card \
        "htop" \
        "Process Monitor" \
        "pkg install htop" \
        "When monitoring system processes, CPU, memory usage" \
        "Interactive process viewer - monitor CPU, RAM, processes in real-time" \
        "htop" \
        "$(diff_beginner)"

    show_tool_card \
        "neofetch" \
        "System Info" \
        "pkg install neofetch" \
        "When displaying system information in a stylish way" \
        "Display system info with ASCII art - OS, kernel, CPU, memory" \
        "neofetch" \
        "$(diff_beginner)"

    show_tool_card \
        "cmatrix" \
        "Terminal Fun" \
        "pkg install cmatrix" \
        "When you want Matrix-style falling characters in terminal" \
        "Matrix digital rain effect in terminal - aesthetic/fun tool" \
        "cmatrix -b -C green" \
        "$(diff_beginner)"

    show_tool_card \
        "figlet" \
        "ASCII Art Text" \
        "pkg install figlet" \
        "When creating ASCII art banners and text displays" \
        "Generate large ASCII art text banners from plain text" \
        "figlet 'Hello World' | figlet -f slant 'Text'" \
        "$(diff_beginner)"

    show_tool_card \
        "toilet" \
        "Colored ASCII Art" \
        "pkg install toilet" \
        "When creating colorful ASCII art text banners" \
        "Like figlet but with color support and more fonts" \
        "toilet --metal 'Hello' | toilet -f mono12 -F metal 'Text'" \
        "$(diff_beginner)"

    show_tool_card \
        "jq" \
        "JSON Processor" \
        "pkg install jq" \
        "When parsing, filtering, transforming JSON data" \
        "Command-line JSON processor - parse APIs, filter data, format JSON" \
        "curl api.example.com | jq '.data[] | .name'" \
        "$(diff_medium)"

    show_tool_card \
        "bc" \
        "Calculator" \
        "pkg install bc" \
        "When performing mathematical calculations in terminal" \
        "Arbitrary precision calculator language for terminal math" \
        "echo '2^10' | bc | echo 'scale=10; 22/7' | bc" \
        "$(diff_beginner)"

    show_tool_card \
        "coreutils" \
        "Core Utilities" \
        "pkg install coreutils" \
        "ALWAYS - essential GNU core utilities for Termux" \
        "Essential GNU utilities (ls, cp, mv, chmod, chown, etc.)" \
        "ls -la | cp -r | chmod 755 | chown user:group" \
        "$(diff_beginner)"

    show_tool_card \
        "proot" \
        "Root Emulator" \
        "pkg install proot" \
        "When running commands that need fake root environment" \
        "Emulate root environment without actual root access" \
        "proot -0 command | termux-chroot" \
        "$(diff_medium)"

    show_tool_card \
        "proot-distro" \
        "Linux Distros" \
        "pkg install proot-distro" \
        "When installing full Linux distros (Ubuntu, Kali, Arch)" \
        "Install and manage Linux distributions inside Termux" \
        "proot-distro install ubuntu | proot-distro login ubuntu" \
        "$(diff_easy)"

    show_tool_card \
        "cronie" \
        "Task Scheduler" \
        "pkg install cronie" \
        "When scheduling automated tasks to run at specific times" \
        "Cron daemon for scheduling recurring tasks and automation" \
        "crontab -e (add: */5 * * * * /path/to/script.sh)" \
        "$(diff_medium)"

    show_tool_card \
        "termux-api" \
        "Android API" \
        "pkg install termux-api" \
        "When accessing Android hardware features from terminal" \
        "Access Android APIs - camera, GPS, sensors, SMS, notifications" \
        "termux-battery-status | termux-camera-photo pic.jpg" \
        "$(diff_easy)"

    press_enter
}

# --- 7. DATABASE TOOLS ---
database_tools() {
    show_banner
    section_header "${LOCK} DATABASE TOOLS"

    show_tool_card \
        "sqlite" \
        "SQLite Database" \
        "pkg install sqlite" \
        "When creating/managing lightweight local databases" \
        "Self-contained, serverless SQL database engine" \
        "sqlite3 mydb.db 'CREATE TABLE users(id INT, name TEXT);'" \
        "$(diff_easy)"

    show_tool_card \
        "mariadb" \
        "MySQL Database" \
        "pkg install mariadb" \
        "When running MySQL-compatible database server" \
        "MySQL-compatible relational database management system" \
        "mysqld_safe & | mysql -u root -p" \
        "$(diff_medium)"

    show_tool_card \
        "postgresql" \
        "PostgreSQL" \
        "pkg install postgresql" \
        "When running advanced relational database with extensions" \
        "Advanced open-source relational database with JSON, GIS support" \
        "pg_ctl -D \$PREFIX/var/lib/postgresql start | psql" \
        "$(diff_medium)"

    show_tool_card \
        "redis" \
        "In-Memory Store" \
        "pkg install redis" \
        "When caching, session storage, message queuing is needed" \
        "In-memory data structure store - cache, message broker, database" \
        "redis-server & | redis-cli SET key value" \
        "$(diff_medium)"

    show_tool_card \
        "mongodb" \
        "NoSQL Database" \
        "pip install pymongo (client)" \
        "When working with flexible, document-based data storage" \
        "Document-oriented NoSQL database for flexible data models" \
        "mongosh | db.collection.find()" \
        "$(diff_medium)"

    press_enter
}

# --- 8. MEDIA & MULTIMEDIA TOOLS ---
media_tools() {
    show_banner
    section_header "${STAR} MEDIA & MULTIMEDIA TOOLS"

    show_tool_card \
        "ffmpeg" \
        "Media Converter" \
        "pkg install ffmpeg" \
        "When converting, recording, or streaming audio/video" \
        "Universal media converter - convert, compress, stream audio/video" \
        "ffmpeg -i input.mp4 -c:v libx264 output.mp4" \
        "$(diff_medium)"

    show_tool_card \
        "imagemagick" \
        "Image Processing" \
        "pkg install imagemagick" \
        "When batch processing, converting, editing images" \
        "Image manipulation tool - resize, convert, compose, edit images" \
        "convert input.png -resize 50% output.png" \
        "$(diff_medium)"

    show_tool_card \
        "youtube-dl" \
        "Video Downloader" \
        "pip install yt-dlp" \
        "When downloading videos from YouTube and other sites" \
        "Download videos from YouTube, Vimeo, and 1000+ sites" \
        "yt-dlp -f best 'https://youtube.com/watch?v=ID'" \
        "$(diff_beginner)"

    show_tool_card \
        "mpv" \
        "Media Player" \
        "pkg install mpv" \
        "When playing audio/video files in terminal" \
        "Versatile command-line media player for audio and video" \
        "mpv video.mp4 | mpv --no-video music.mp3" \
        "$(diff_beginner)"

    show_tool_card \
        "sox" \
        "Audio Processing" \
        "pkg install sox" \
        "When processing, editing, analyzing audio files" \
        "Swiss army knife for audio - convert, apply effects, analyze" \
        "sox input.wav output.mp3 | sox input.wav -n spectrogram" \
        "$(diff_medium)"

    press_enter
}

# --- 9. WEB DEVELOPMENT TOOLS ---
webdev_tools() {
    show_banner
    section_header "${GLOBE} WEB DEVELOPMENT TOOLS"

    show_tool_card \
        "apache2" \
        "Web Server" \
        "pkg install apache2" \
        "When hosting websites, testing web apps locally" \
        "Popular web server - host static/dynamic websites" \
        "apachectl start (serves from \$PREFIX/share/apache2/default-site/htdocs)" \
        "$(diff_easy)"

    show_tool_card \
        "nginx" \
        "Web Server" \
        "pkg install nginx" \
        "When high-performance web serving, reverse proxy needed" \
        "High-performance web server, reverse proxy, load balancer" \
        "nginx | nginx -s reload | nginx -s stop" \
        "$(diff_medium)"

    show_tool_card \
        "php" \
        "PHP Server" \
        "pkg install php" \
        "When running PHP web applications and scripts" \
        "Built-in PHP development server for testing" \
        "php -S localhost:8080 -t /path/to/webroot" \
        "$(diff_easy)"

    show_tool_card \
        "hugo" \
        "Static Site Generator" \
        "pkg install hugo" \
        "When building fast, modern static websites and blogs" \
        "Fast static site generator - blogs, portfolios, documentation" \
        "hugo new site mysite | hugo server -D" \
        "$(diff_medium)"

    show_tool_card \
        "sass" \
        "CSS Preprocessor" \
        "npm install -g sass" \
        "When writing maintainable CSS with variables and nesting" \
        "CSS preprocessor with variables, mixins, nesting, inheritance" \
        "sass input.scss output.css --watch" \
        "$(diff_easy)"

    show_tool_card \
        "typescript" \
        "Typed JavaScript" \
        "npm install -g typescript" \
        "When building type-safe JavaScript applications" \
        "Typed superset of JavaScript that compiles to plain JS" \
        "tsc app.ts | tsc --init" \
        "$(diff_medium)"

    press_enter
}

# --- 10. AUTOMATION & SCRIPTING TOOLS ---
automation_tools() {
    show_banner
    section_header "${LIGHTNING} AUTOMATION & SCRIPTING TOOLS"

    show_tool_card \
        "expect" \
        "Interactive Automation" \
        "pkg install expect" \
        "When automating interactive programs (SSH, FTP, telnet)" \
        "Automate interactive applications - auto-login, auto-response" \
        "expect -c 'spawn ssh user@host; expect password; send pass\\r'" \
        "$(diff_medium)"

    show_tool_card \
        "parallel" \
        "Parallel Execution" \
        "pkg install parallel" \
        "When running multiple commands/jobs simultaneously" \
        "Execute jobs in parallel - speed up batch processing" \
        "cat urls.txt | parallel -j10 wget {}" \
        "$(diff_medium)"

    show_tool_card \
        "make" \
        "Build Automation" \
        "pkg install make" \
        "When automating compilation and build processes" \
        "Build automation tool - define rules, dependencies, actions" \
        "make | make install | make clean" \
        "$(diff_medium)"

    show_tool_card \
        "sed" \
        "Stream Editor" \
        "pkg install sed" \
        "When batch text replacement, transformation in files" \
        "Stream editor for filtering and transforming text" \
        "sed -i 's/old/new/g' file.txt" \
        "$(diff_medium)"

    show_tool_card \
        "awk" \
        "Text Processing" \
        "pkg install gawk" \
        "When processing structured text data, generating reports" \
        "Pattern scanning and processing language for structured text" \
        "awk '{print \$1, \$3}' file.txt | awk -F: '{print \$1}' /etc/passwd" \
        "$(diff_medium)"

    show_tool_card \
        "grep" \
        "Text Search" \
        "pkg install grep" \
        "When searching text patterns in files and output" \
        "Search text using patterns/regex in files and streams" \
        "grep -rn 'pattern' . | grep -E 'regex' file" \
        "$(diff_beginner)"

    show_tool_card \
        "ripgrep" \
        "Fast Search" \
        "pkg install ripgrep" \
        "When fast recursive text searching is needed (faster grep)" \
        "Blazingly fast grep alternative with smart defaults" \
        "rg 'pattern' . | rg -t py 'import'" \
        "$(diff_beginner)"

    press_enter
}

# ============================================================
# QUICK REFERENCE GUIDE
# ============================================================

quick_reference() {
    show_banner
    section_header "${FIRE} QUICK REFERENCE - TOOL SELECTION GUIDE"

    echo -e "${WHITE}${BOLD}  ┌─────────────────────────────────────────────────────────────┐${RESET}"
    echo -e "${WHITE}${BOLD}  │         ${STAR} WHEN TO USE WHICH TOOL - QUICK GUIDE ${STAR}           │${RESET}"
    echo -e "${WHITE}${BOLD}  └─────────────────────────────────────────────────────────────┘${RESET}"
    echo ""

    echo -e "${YELLOW}  ${ARROW} I want to scan a network:${RESET}"
    echo -e "     ${GREEN}nmap${RESET} (port scan) → ${GREEN}netcat${RESET} (connect) → ${GREEN}tcpdump${RESET} (capture)"
    echo ""

    echo -e "${YELLOW}  ${ARROW} I want to test website security:${RESET}"
    echo -e "     ${GREEN}nikto${RESET} (scan) → ${GREEN}gobuster${RESET} (dirs) → ${GREEN}sqlmap${RESET} (SQLi) → ${GREEN}burpsuite${RESET}"
    echo ""

    echo -e "${YELLOW}  ${ARROW} I want to crack passwords:${RESET}"
    echo -e "     ${GREEN}crunch${RESET} (wordlist) → ${GREEN}hydra${RESET} (online) → ${GREEN}john${RESET} (offline) → ${GREEN}hashcat${RESET}"
    echo ""

    echo -e "${YELLOW}  ${ARROW} I want to gather information:${RESET}"
    echo -e "     ${GREEN}whois${RESET} → ${GREEN}dig${RESET} → ${GREEN}theHarvester${RESET} → ${GREEN}sherlock${RESET} → ${GREEN}subfinder${RESET}"
    echo ""

    echo -e "${YELLOW}  ${ARROW} I want to write code:${RESET}"
    echo -e "     ${GREEN}vim/nano${RESET} (editor) → ${GREEN}python/node${RESET} (language) → ${GREEN}git${RESET} (version control)"
    echo ""

    echo -e "${YELLOW}  ${ARROW} I want to download files:${RESET}"
    echo -e "     ${GREEN}wget${RESET} (simple) → ${GREEN}curl${RESET} (APIs) → ${GREEN}aria2${RESET} (fast) → ${GREEN}yt-dlp${RESET} (videos)"
    echo ""

    echo -e "${YELLOW}  ${ARROW} I want to manage files:${RESET}"
    echo -e "     ${GREEN}ranger/mc${RESET} (browse) → ${GREEN}tree${RESET} (view) → ${GREEN}tar/zip${RESET} (compress)"
    echo ""

    echo -e "${YELLOW}  ${ARROW} I want to process text:${RESET}"
    echo -e "     ${GREEN}grep${RESET} (search) → ${GREEN}sed${RESET} (replace) → ${GREEN}awk${RESET} (process) → ${GREEN}jq${RESET} (JSON)"
    echo ""

    echo -e "${YELLOW}  ${ARROW} I want to monitor system:${RESET}"
    echo -e "     ${GREEN}htop${RESET} (processes) → ${GREEN}neofetch${RESET} (info) → ${GREEN}termux-api${RESET} (Android)"
    echo ""

    echo -e "${YELLOW}  ${ARROW} I want to set up a server:${RESET}"
    echo -e "     ${GREEN}apache2/nginx${RESET} (web) → ${GREEN}mariadb${RESET} (database) → ${GREEN}php/node${RESET} (backend)"
    echo ""

    echo -e "${YELLOW}  ${ARROW} I want to install Linux distro:${RESET}"
    echo -e "     ${GREEN}proot-distro${RESET} → install ubuntu/kali/arch → ${GREEN}proot-distro login${RESET}"
    echo ""

    echo -e "${YELLOW}  ${ARROW} I want to process media:${RESET}"
    echo -e "     ${GREEN}ffmpeg${RESET} (video) → ${GREEN}imagemagick${RESET} (images) → ${GREEN}sox${RESET} (audio)"
    echo ""

    separator
    press_enter
}

# ============================================================
# INSTALL ALL ESSENTIAL TOOLS
# ============================================================

install_essentials() {
    show_banner
    section_header "${PACKAGE} INSTALL ESSENTIAL TOOLS"

    echo -e "${YELLOW}  This will install the most commonly needed tools.${RESET}"
    echo -e "${YELLOW}  Estimated time: 5-15 minutes depending on connection.${RESET}"
    echo ""

    local essentials=(
        "git" "python" "nodejs" "ruby" "vim" "nano"
        "nmap" "curl" "wget" "htop" "tree" "tmux"
        "openssh" "net-tools" "dnsutils" "whois"
        "jq" "bat" "fzf" "zip" "unzip" "tar"
        "neofetch" "figlet" "bc" "coreutils" "grep"
        "sed" "gawk" "make" "clang" "cmake"
    )

    echo -e "${CYAN}  Tools to install:${RESET}"
    echo ""
    local count=0
    for tool in "${essentials[@]}"; do
        count=$((count + 1))
        printf "  ${WHITE}%2d.${RESET} %-15s" "$count" "$tool"
        if [ $((count % 4)) -eq 0 ]; then
            echo ""
        fi
    done
    echo ""
    echo ""

    echo -e "${RED}  ${WARN} This requires internet connection and storage space.${RESET}"
    echo ""
    echo -ne "${YELLOW}  Proceed with installation? (y/n): ${RESET}"
    read -r confirm

    if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
        echo ""
        echo -e "${CYAN}  Updating package repositories...${RESET}"
        pkg update -y 2>&1 | tail -1
        echo ""

        local installed=0
        local failed=0

        for tool in "${essentials[@]}"; do
            echo -ne "${CYAN}  Installing ${WHITE}${tool}${CYAN}... ${RESET}"
            if pkg install -y "$tool" &>/dev/null; then
                echo -e "${GREEN}${CHECK} Done${RESET}"
                installed=$((installed + 1))
            else
                echo -e "${RED}${CROSS} Failed${RESET}"
                failed=$((failed + 1))
            fi
        done

        echo ""
        separator
        echo -e "${GREEN}  ${CHECK} Successfully installed: ${installed} tools${RESET}"
        echo -e "${RED}  ${CROSS} Failed: ${failed} tools${RESET}"
        separator
        log_action "Installed $installed essential tools, $failed failed"
    else
        echo -e "${YELLOW}  Installation cancelled.${RESET}"
    fi

    press_enter
}

# ============================================================
# SEARCH TOOL
# ============================================================

search_tool() {
    show_banner
    section_header "${SEARCH} SEARCH FOR A TOOL"

    echo -ne "${YELLOW}  Enter tool name or keyword: ${RESET}"
    read -r search_term

    if [ -z "$search_term" ]; then
        echo -e "${RED}  No search term entered.${RESET}"
        press_enter
        return
    fi

    echo ""
    echo -e "${CYAN}  Searching for '${search_term}'...${RESET}"
    echo ""

    # Tool database (name|category|install|when|purpose)
    local -a TOOL_DB=(
        "nmap|Network Scanner|pkg install nmap|Network scanning & port discovery|Scan networks, find open ports, detect services and OS"
        "hydra|Password Cracker|pkg install hydra|Testing login security|Brute-force passwords for SSH, FTP, HTTP, 50+ protocols"
        "python|Programming|pkg install python|Scripting & automation|General-purpose programming, scripting, web dev, AI/ML"
        "nodejs|Programming|pkg install nodejs|Web development & APIs|Server-side JavaScript for web servers and APIs"
        "vim|Text Editor|pkg install vim|Editing files & coding|Advanced modal text editor for power users"
        "nano|Text Editor|pkg install nano|Quick file editing|Simple beginner-friendly text editor"
        "git|Version Control|pkg install git|Code management|Track code changes, collaborate, manage repositories"
        "curl|Data Transfer|pkg install curl|API testing & downloads|Transfer data via URLs, test APIs, inspect headers"
        "wget|Downloader|pkg install wget|File downloads|Non-interactive file downloader with resume support"
        "tmux|Multiplexer|pkg install tmux|Multiple terminal sessions|Split panes, multiple windows, persistent sessions"
        "htop|System Monitor|pkg install htop|Process monitoring|Interactive process viewer with CPU and RAM stats"
        "ffmpeg|Media|pkg install ffmpeg|Audio/video conversion|Convert, compress, and stream multimedia files"
        "sqlmap|SQL Injection|pip install sqlmap|Web security testing|Automated SQL injection detection and exploitation"
        "nikto|Web Scanner|pkg install nikto|Web server scanning|Find vulnerabilities, misconfigs in web servers"
        "john|Hash Cracker|pkg install john|Hash cracking|Crack password hashes (MD5, SHA, NTLM, etc.)"
        "metasploit|Exploitation|pkg install metasploit|Penetration testing|Complete pentesting framework with 2000+ exploits"
        "sherlock|OSINT|pip install sherlock-project|Username search|Find usernames across 400+ social networks"
        "netcat|Networking|pkg install netcat-openbsd|Raw connections|TCP/UDP connections, port scanning, file transfer"
        "gobuster|Dir Bruteforce|pkg install gobuster|Hidden directory finding|Brute-force URIs, DNS subdomains, vhosts"
        "openssl|Cryptography|pkg install openssl-tool|Encryption & SSL|Encrypt files, generate certs, test SSL/TLS"
        "tree|File Viewer|pkg install tree|Directory visualization|Display directory structure as a tree"
        "jq|JSON Tool|pkg install jq|JSON processing|Parse, filter, and transform JSON data"
        "bat|File Viewer|pkg install bat|File viewing with highlighting|Cat alternative with syntax highlighting"
        "neofetch|System Info|pkg install neofetch|System information|Display system info with ASCII art"
        "crunch|Wordlist Gen|pkg install crunch|Creating wordlists|Generate custom wordlists with patterns"
        "aircrack-ng|WiFi Security|pkg install aircrack-ng|WiFi testing (root)|Capture handshakes, crack WPA/WPA2 keys"
        "proot-distro|Linux Distro|pkg install proot-distro|Installing Linux distros|Run Ubuntu, Kali, Arch in Termux"
        "ruby|Programming|pkg install ruby|Scripting & web dev|Dynamic language for web dev and security tools"
        "golang|Programming|pkg install golang|High-performance tools|Compiled language for fast CLI tools"
        "sqlite|Database|pkg install sqlite|Local databases|Lightweight serverless SQL database"
        "mariadb|Database|pkg install mariadb|MySQL database|MySQL-compatible database server"
        "nginx|Web Server|pkg install nginx|Web hosting & proxy|High-performance web server and reverse proxy"
        "aria2|Downloader|pkg install aria2|Fast multi-source downloads|Multi-protocol download utility"
        "imagemagick|Image Tool|pkg install imagemagick|Image processing|Resize, convert, compose, edit images"
        "yt-dlp|Video Downloader|pip install yt-dlp|Video downloads|Download from YouTube and 1000+ sites"
        "ripgrep|Search|pkg install ripgrep|Fast text search|Blazingly fast recursive text search"
        "fzf|Finder|pkg install fzf|Interactive search|Fuzzy finder for files, history, processes"
        "ranger|File Manager|pip install ranger-fm|File browsing|Console file manager with VI keybindings"
        "redis|Cache/DB|pkg install redis|Caching & messaging|In-memory data store and message broker"
        "hashcat|Hash Cracker|pkg install hashcat|Advanced hash cracking|GPU-accelerated password recovery"
        "socat|Network Relay|pkg install socat|Port forwarding & relays|Advanced netcat with SSL and proxy support"
        "sslscan|SSL Test|pkg install sslscan|SSL/TLS testing|Check SSL configuration and weak ciphers"
        "exiftool|Metadata|pkg install exiftool|Reading file metadata|Extract metadata from images and documents"
        "expect|Automation|pkg install expect|Interactive automation|Automate interactive programs like SSH"
        "parallel|Parallel Exec|pkg install parallel|Batch processing|Run multiple commands simultaneously"
        "termux-api|Android API|pkg install termux-api|Android features|Access camera, GPS, sensors, SMS from terminal"
        "clang|Compiler|pkg install clang|C/C++ compilation|Compile C and C++ programs"
        "rust|Programming|pkg install rust|Systems programming|Safe, concurrent systems programming language"
        "php|Web Language|pkg install php|Web development|Server-side scripting for web applications"
        "perl|Scripting|pkg install perl|Text processing|Powerful text processing and system admin"
        "neovim|Editor|pkg install neovim|Modern code editing|Modernized Vim with LSP and Lua plugins"
        "micro|Editor|pkg install micro|Easy terminal editing|Modern terminal editor with mouse support"
        "mc|File Manager|pkg install mc|Dual-pane file management|Midnight Commander visual file manager"
        "screen|Multiplexer|pkg install screen|Persistent sessions|Terminal multiplexer for persistent sessions"
        "figlet|ASCII Art|pkg install figlet|Text banners|Generate large ASCII art text"
        "toilet|ASCII Art|pkg install toilet|Colored text banners|Colorful ASCII art text generator"
        "traceroute|Network|pkg install traceroute|Route tracing|Trace packet path to destination"
        "whois|Domain Info|pkg install whois|Domain lookup|Query domain registration information"
        "dnsutils|DNS|pkg install dnsutils|DNS queries|DNS lookup tools (dig, nslookup, host)"
        "tcpdump|Packet Capture|pkg install tcpdump|Traffic analysis|Capture and analyze network packets"
        "ipcalc|IP Calculator|pkg install ipcalc|Subnet calculation|Calculate IP network information"
        "binwalk|Firmware|pip install binwalk|Binary analysis|Analyze firmware and embedded files"
        "subfinder|Subdomain|go install subfinder|Subdomain enumeration|Fast passive subdomain discovery"
    )

    local found=0
    search_lower=$(echo "$search_term" | tr '[:upper:]' '[:lower:]')

    for entry in "${TOOL_DB[@]}"; do
        entry_lower=$(echo "$entry" | tr '[:upper:]' '[:lower:]')
        if echo "$entry_lower" | grep -q "$search_lower"; then
            IFS='|' read -r name category install when purpose <<< "$entry"
            found=$((found + 1))

            local status
            status=$(check_installed "$name")

            echo -e "${BLUE}  ┌───────────────────────────────────────────────────┐${RESET}"
            echo -e "${BLUE}  │ ${TOOL} ${WHITE}${BOLD}${name^^}${RESET}"
            echo -e "${BLUE}  │${RESET} ${GEAR} Category : ${MAGENTA}${category}${RESET}"
            echo -e "${BLUE}  │${RESET} ${PACKAGE} Status   : ${status}"
            echo -e "${BLUE}  │${RESET} ${CLOCK} When     : ${YELLOW}${when}${RESET}"
            echo -e "${BLUE}  │${RESET} ${TARGET} Purpose  : ${GREEN}${purpose}${RESET}"
            echo -e "${BLUE}  │${RESET} ${BOOK} Install  : ${CYAN}${install}${RESET}"
            echo -e "${BLUE}  └───────────────────────────────────────────────────┘${RESET}"
            echo ""
        fi
    done

    if [ $found -eq 0 ]; then
        echo -e "${RED}  ${CROSS} No tools found matching '${search_term}'${RESET}"
        echo -e "${DIM}  Try searching with different keywords.${RESET}"
    else
        echo -e "${GREEN}  ${CHECK} Found ${found} tool(s) matching '${search_term}'${RESET}"
    fi

    press_enter
}

# ============================================================
# SYSTEM HEALTH CHECK
# ============================================================

system_health() {
    show_banner
    section_header "${GEAR} SYSTEM HEALTH CHECK"

    echo -e "${CYAN}  Analyzing your Termux setup...${RESET}"
    echo ""

    # Storage info
    echo -e "${WHITE}${BOLD}  📊 Storage Information:${RESET}"
    echo -e "${DIM}  ────────────────────────────────${RESET}"
    df -h "$HOME" 2>/dev/null | tail -1 | awk '{
        printf "  Used: \033[1;33m%s\033[0m / Total: \033[1;32m%s\033[0m (Available: \033[1;36m%s\033[0m)\n", $3, $2, $4
    }'
    echo ""

    # Package count
    echo -e "${WHITE}${BOLD}  📦 Installed Packages:${RESET}"
    echo -e "${DIM}  ────────────────────────────────${RESET}"
    local pkg_count
    pkg_count=$(dpkg --list 2>/dev/null | grep '^ii' | wc -l)
    echo -e "  Total packages: ${GREEN}${pkg_count}${RESET}"
    echo ""

    # Check essential tools
    echo -e "${WHITE}${BOLD}  🔧 Essential Tools Status:${RESET}"
    echo -e "${DIM}  ────────────────────────────────${RESET}"

    local check_tools=("git" "python" "node" "vim" "nano" "curl" "wget" "nmap" "ssh" "tmux" "htop" "jq" "make" "clang" "ruby" "php" "go")

    for tool in "${check_tools[@]}"; do
        local stat
        if command -v "$tool" &>/dev/null; then
            local ver
            ver=$($tool --version 2>/dev/null | head -1 | cut -c1-40)
            printf "  ${GREEN}${CHECK}${RESET} %-12s ${DIM}%s${RESET}\n" "$tool" "$ver"
        else
            printf "  ${RED}${CROSS}${RESET} %-12s ${DIM}Not installed${RESET}\n" "$tool"
        fi
    done

    echo ""

    # Python packages
    echo -e "${WHITE}${BOLD}  🐍 Python Packages:${RESET}"
    echo -e "${DIM}  ────────────────────────────────${RESET}"
    if command -v pip &>/dev/null; then
        local pip_count
        pip_count=$(pip list 2>/dev/null | wc -l)
        echo -e "  Python packages: ${GREEN}${pip_count}${RESET}"
    else
        echo -e "  ${RED}pip not installed${RESET}"
    fi
    echo ""

    # Node packages
    echo -e "${WHITE}${BOLD}  📗 Node.js Global Packages:${RESET}"
    echo -e "${DIM}  ────────────────────────────────${RESET}"
    if command -v npm &>/dev/null; then
        local npm_count
        npm_count=$(npm list -g --depth=0 2>/dev/null | wc -l)
        echo -e "  Global npm packages: ${GREEN}${npm_count}${RESET}"
    else
        echo -e "  ${RED}npm not installed${RESET}"
    fi
    echo ""

    # Termux API
    echo -e "${WHITE}${BOLD}  📱 Termux API Status:${RESET}"
    echo -e "${DIM}  ────────────────────────────────${RESET}"
    if command -v termux-battery-status &>/dev/null; then
        echo -e "  ${GREEN}${CHECK} Termux API is available${RESET}"
        echo -e "  Battery: $(termux-battery-status 2>/dev/null | jq -r '.percentage' 2>/dev/null || echo 'N/A')%"
    else
        echo -e "  ${RED}${CROSS} Termux API not installed (pkg install termux-api)${RESET}"
    fi

    echo ""
    separator

    press_enter
}

# ============================================================
# CUSTOM TOOL INSTALLER
# ============================================================

custom_installer() {
    show_banner
    section_header "${PACKAGE} CUSTOM TOOL INSTALLER"

    echo -e "${YELLOW}  Choose a tool category to install:${RESET}"
    echo ""
    echo -e "  ${CYAN}1)${RESET} Network Tools Bundle (nmap, netcat, whois, dnsutils, curl, wget)"
    echo -e "  ${CYAN}2)${RESET} Security Tools Bundle (hydra, john, sqlmap, nikto, gobuster)"
    echo -e "  ${CYAN}3)${RESET} Developer Tools Bundle (python, nodejs, git, vim, tmux, make)"
    echo -e "  ${CYAN}4)${RESET} OSINT Tools Bundle (sherlock, theHarvester, exiftool, whois)"
    echo -e "  ${CYAN}5)${RESET} Media Tools Bundle (ffmpeg, imagemagick, yt-dlp, mpv)"
    echo -e "  ${CYAN}6)${RESET} Database Bundle (sqlite, mariadb, postgresql, redis)"
    echo -e "  ${CYAN}7)${RESET} Full Arsenal (ALL essential tools - takes time)"
    echo -e "  ${CYAN}8)${RESET} Custom - Enter tool name manually"
    echo -e "  ${RED}0)${RESET} Back to main menu"
    echo ""
    echo -ne "${YELLOW}  Select option: ${RESET}"
    read -r choice

    local tools=()

    case $choice in
        1) tools=("nmap" "netcat-openbsd" "whois" "dnsutils" "curl" "wget" "traceroute" "net-tools" "ipcalc" "aria2" "socat" "tcpdump") ;;
        2) tools=("hydra" "john" "nikto" "gobuster" "openssl-tool" "crunch" "sslscan" "nmap" "aircrack-ng") ;;
        3) tools=("python" "nodejs" "git" "vim" "neovim" "tmux" "make" "clang" "cmake" "ruby" "golang" "rust") ;;
        4) tools=("whois" "dnsutils" "exiftool" "nmap" "curl") ;;
        5) tools=("ffmpeg" "imagemagick" "mpv" "sox") ;;
        6) tools=("sqlite" "mariadb" "postgresql" "redis") ;;
        7) tools=("nmap" "netcat-openbsd" "hydra" "john" "nikto" "python" "nodejs" "git" "vim" "nano" "tmux" "curl" "wget" "htop" "tree" "openssh" "net-tools" "dnsutils" "whois" "jq" "bat" "fzf" "ffmpeg" "imagemagick" "zip" "unzip" "neofetch" "figlet" "make" "clang" "ruby" "golang" "sqlite" "aria2" "openssl-tool" "crunch" "gobuster" "exiftool" "ripgrep" "bc" "coreutils" "proot-distro") ;;
        8)
            echo -ne "${YELLOW}  Enter tool name (pkg name): ${RESET}"
            read -r custom_tool
            if [ -n "$custom_tool" ]; then
                tools=("$custom_tool")
            fi
            ;;
        0) return ;;
        *) echo -e "${RED}  Invalid option.${RESET}"; press_enter; return ;;
    esac

    if [ ${#tools[@]} -eq 0 ]; then
        echo -e "${RED}  No tools selected.${RESET}"
        press_enter
        return
    fi

    echo ""
    echo -e "${CYAN}  Installing ${#tools[@]} tool(s)...${RESET}"
    echo ""

    pkg update -y &>/dev/null

    local installed=0
    local failed=0
    local already=0

    for tool in "${tools[@]}"; do
        if command -v "$tool" &>/dev/null || dpkg -l "$tool" &>/dev/null 2>&1; then
            echo -e "  ${YELLOW}⏩${RESET} ${tool} - Already installed"
            already=$((already + 1))
        else
            echo -ne "  ${CYAN}📥${RESET} Installing ${WHITE}${tool}${RESET}... "
            if pkg install -y "$tool" &>/dev/null; then
                echo -e "${GREEN}${CHECK} Success${RESET}"
                installed=$((installed + 1))
            else
                echo -e "${RED}${CROSS} Failed${RESET}"
                failed=$((failed + 1))
            fi
        fi
    done

    echo ""
    separator
    echo -e "${GREEN}  ✅ Newly installed: ${installed}${RESET}"
    echo -e "${YELLOW}  ⏩ Already present: ${already}${RESET}"
    echo -e "${RED}  ❌ Failed: ${failed}${RESET}"
    separator

    log_action "Bundle install: $installed new, $already existing, $failed failed"
    press_enter
}

# ============================================================
# CHEAT SHEET
# ============================================================

cheat_sheet() {
    show_banner
    section_header "${BOOK} TERMUX CHEAT SHEET"

    echo -e "${WHITE}${BOLD}  ┌─────────────────────────────────────────────────────────┐${RESET}"
    echo -e "${WHITE}${BOLD}  │           ${FIRE} ESSENTIAL TERMUX COMMANDS ${FIRE}                 │${RESET}"
    echo -e "${WHITE}${BOLD}  └─────────────────────────────────────────────────────────┘${RESET}"
    echo ""

    echo -e "${YELLOW}  📦 Package Management:${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────${RESET}"
    echo -e "  ${GREEN}pkg update && pkg upgrade${RESET}  - Update everything"
    echo -e "  ${GREEN}pkg install <package>${RESET}      - Install a package"
    echo -e "  ${GREEN}pkg uninstall <package>${RESET}    - Remove a package"
    echo -e "  ${GREEN}pkg search <keyword>${RESET}       - Search for packages"
    echo -e "  ${GREEN}pkg list-installed${RESET}         - List installed packages"
    echo -e "  ${GREEN}apt list --upgradeable${RESET}     - Check for updates"
    echo ""

    echo -e "${YELLOW}  📁 File System:${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────${RESET}"
    echo -e "  ${GREEN}termux-setup-storage${RESET}       - Access phone storage"
    echo -e "  ${GREEN}cd ~/storage/shared${RESET}        - Go to internal storage"
    echo -e "  ${GREEN}cd ~/storage/dcim${RESET}          - Go to camera folder"
    echo -e "  ${GREEN}cd ~/storage/downloads${RESET}     - Go to downloads"
    echo -e "  ${GREEN}ls -la${RESET}                     - List files with details"
    echo -e "  ${GREEN}du -sh *${RESET}                   - Check folder sizes"
    echo ""

    echo -e "${YELLOW}  ⚡ Shortcuts & Tips:${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────${RESET}"
    echo -e "  ${GREEN}Ctrl+C${RESET}                     - Stop running command"
    echo -e "  ${GREEN}Ctrl+D${RESET}                     - Exit current session"
    echo -e "  ${GREEN}Ctrl+L${RESET}                     - Clear screen"
    echo -e "  ${GREEN}Ctrl+Z${RESET}                     - Suspend process"
    echo -e "  ${GREEN}Tab${RESET}                        - Auto-complete"
    echo -e "  ${GREEN}Vol Up + Q${RESET}                 - Extra keys (ESC)"
    echo -e "  ${GREEN}Vol Down + key${RESET}             - Special characters"
    echo ""

    echo -e "${YELLOW}  🔒 SSH & Remote:${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────${RESET}"
    echo -e "  ${GREEN}sshd${RESET}                       - Start SSH server"
    echo -e "  ${GREEN}ssh user@host${RESET}              - Connect via SSH"
    echo -e "  ${GREEN}scp file user@host:path${RESET}    - Copy files via SSH"
    echo -e "  ${GREEN}passwd${RESET}                     - Set/change password"
    echo -e "  ${GREEN}whoami${RESET}                     - Show current user"
    echo ""

    echo -e "${YELLOW}  🐧 Linux Distros in Termux:${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────${RESET}"
    echo -e "  ${GREEN}proot-distro list${RESET}          - List available distros"
    echo -e "  ${GREEN}proot-distro install ubuntu${RESET} - Install Ubuntu"
    echo -e "  ${GREEN}proot-distro login ubuntu${RESET}  - Login to Ubuntu"
    echo -e "  ${GREEN}proot-distro remove ubuntu${RESET} - Remove Ubuntu"
    echo ""

    echo -e "${YELLOW}  🛠️ Useful One-Liners:${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────${RESET}"
    echo -e "  ${GREEN}python -m http.server 8080${RESET} - Quick web server"
    echo -e "  ${GREEN}ip addr show wlan0${RESET}         - Show IP address"
    echo -e "  ${GREEN}find . -name '*.py'${RESET}        - Find Python files"
    echo -e "  ${GREEN}history | grep 'keyword'${RESET}   - Search command history"
    echo -e "  ${GREEN}watch -n 1 'command'${RESET}       - Repeat command every 1s"

    press_enter
}

# ============================================================
# MAIN MENU
# ============================================================

main_menu() {
    while true; do
        show_banner

        echo -e "${WHITE}${BOLD}  ┌─────────────────────────────────────────────────────────┐${RESET}"
        echo -e "${WHITE}${BOLD}  │              ${STAR} MAIN MENU ${STAR}                              │${RESET}"
        echo -e "${WHITE}${BOLD}  └─────────────────────────────────────────────────────────┘${RESET}"
        echo ""

        echo -e "  ${CYAN}${BOLD} TOOL CATEGORIES:${RESET}"
        echo -e "  ${DIM}─────────────────────────────────────────────${RESET}"
        echo -e "  ${GREEN} [1]${RESET}  ${GLOBE}  Network Analysis & Scanning Tools"
        echo -e "  ${GREEN} [2]${RESET}  ${SHIELD}  Security & Penetration Testing Tools"
        echo -e "  ${GREEN} [3]${RESET}  ${CODE}  Programming & Development Tools"
        echo -e "  ${GREEN} [4]${RESET}  ${FILE}  Text Editors & File Management"
        echo -e "  ${GREEN} [5]${RESET}  ${SEARCH}  Information Gathering & OSINT"
        echo -e "  ${GREEN} [6]${RESET}  ${GEAR}  System & Utility Tools"
        echo -e "  ${GREEN} [7]${RESET}  ${LOCK}  Database Tools"
        echo -e "  ${GREEN} [8]${RESET}  ${STAR}  Media & Multimedia Tools"
        echo -e "  ${GREEN} [9]${RESET}  ${GLOBE}  Web Development Tools"
        echo -e "  ${GREEN}[10]${RESET}  ${LIGHTNING}  Automation & Scripting Tools"
        echo ""
        echo -e "  ${CYAN}${BOLD} FEATURES:${RESET}"
        echo -e "  ${DIM}─────────────────────────────────────────────${RESET}"
        echo -e "  ${YELLOW}[11]${RESET}  ${FIRE}  Quick Reference Guide"
        echo -e "  ${YELLOW}[12]${RESET}  ${SEARCH}  Search for a Tool"
        echo -e "  ${YELLOW}[13]${RESET}  ${PACKAGE}  Install Tool Bundles"
        echo -e "  ${YELLOW}[14]${RESET}  ${PACKAGE}  Install All Essentials"
        echo -e "  ${YELLOW}[15]${RESET}  ${GEAR}  System Health Check"
        echo -e "  ${YELLOW}[16]${RESET}  ${BOOK}  Termux Cheat Sheet"
        echo ""
        echo -e "  ${RED} [0]${RESET}  ❌  Exit"
        echo ""
        separator
        echo -ne "${YELLOW}  ${ARROW} Select an option [0-16]: ${RESET}"
        read -r option

        case $option in
            1)  network_tools ;;
            2)  security_tools ;;
            3)  programming_tools ;;
            4)  editor_tools ;;
            5)  osint_tools ;;
            6)  system_tools ;;
            7)  database_tools ;;
            8)  media_tools ;;
            9)  webdev_tools ;;
            10) automation_tools ;;
            11) quick_reference ;;
            12) search_tool ;;
            13) custom_installer ;;
            14) install_essentials ;;
            15) system_health ;;
            16) cheat_sheet ;;
            0)
                clear_screen
                echo ""
                echo -e "${CYAN}"
                figlet "Goodbye!" 2>/dev/null || echo -e "${BOLD}    GOODBYE!${RESET}"
                echo -e "${RESET}"
                echo -e "${GREEN}  Thank you for using Termux Advanced Tools Manager v${VERSION}${RESET}"
                echo -e "${DIM}  Stay curious. Stay secure. Keep learning.${RESET}"
                echo ""
                log_action "Session ended"
                exit 0
                ;;
            *)
                echo -e "${RED}  ${CROSS} Invalid option! Please choose 0-16.${RESET}"
                sleep 1
                ;;
        esac
    done
}

# ============================================================
# ENTRY POINT
# ============================================================

# Check if running in Termux
if [ ! -d "/data/data/com.termux" ] && [ -z "$TERMUX_VERSION" ]; then
    echo -e "${YELLOW}${WARN} Warning: This script is designed for Termux.${RESET}"
    echo -e "${YELLOW}  Some features may not work in other environments.${RESET}"
    echo -ne "${YELLOW}  Continue anyway? (y/n): ${RESET}"
    read -r cont
    if [[ "$cont" != "y" && "$cont" != "Y" ]]; then
        exit 1
    fi
fi

# Log session start
log_action "Session started - Termux Tools Manager v${VERSION}"

# Start the application
main_menu
