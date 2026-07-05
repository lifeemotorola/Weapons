#!/data/data/com.termux/files/usr/bin/bash

#============================================================================
# ADVANCED OSINT TOOLKIT FOR TERMUX
# Version: 3.0
# Author: Emmanuel suah
# Description: Comprehensive Open Source Intelligence Gathering Tool
# Legal: For authorized security testing and research purposes only
#============================================================================

#----------------------------
# COLOR DEFINITIONS
#----------------------------
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
MAGENTA='\033[1;35m'
CYAN='\033[1;36m'
WHITE='\033[1;37m'
ORANGE='\033[0;33m'
GRAY='\033[0;37m'
BOLD='\033[1m'
DIM='\033[2m'
UNDERLINE='\033[4m'
BLINK='\033[5m'
RESET='\033[0m'
BG_RED='\033[41m'
BG_GREEN='\033[42m'
BG_BLUE='\033[44m'

#----------------------------
# GLOBAL VARIABLES
#----------------------------
VERSION="3.0"
TOOL_NAME="OSINT-X"
OUTPUT_DIR="$HOME/osint_results"
LOG_FILE="$OUTPUT_DIR/osint_log_$(date +%Y%m%d_%H%M%S).log"
TEMP_DIR="$OUTPUT_DIR/temp"
REPORT_DIR="$OUTPUT_DIR/reports"
EXPORT_DIR="$OUTPUT_DIR/exports"
USER_AGENT="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
TIMEOUT=15
MAX_RETRIES=3

#----------------------------
# API KEYS (Configure these)
#----------------------------
SHODAN_API_KEY=""
VIRUSTOTAL_API_KEY=""
HUNTER_API_KEY=""
SECURITYTRAILS_API_KEY=""
IPINFO_TOKEN=""
ABUSEIPDB_API_KEY=""
HAVEIBEENPWNED_API_KEY=""
FULLCONTACT_API_KEY=""
NUMVERIFY_API_KEY=""
GOOGLE_API_KEY=""
GOOGLE_CX=""
CENSYS_API_ID=""
CENSYS_API_SECRET=""

#----------------------------
# DIRECTORY SETUP
#----------------------------
setup_directories() {
    mkdir -p "$OUTPUT_DIR" "$TEMP_DIR" "$REPORT_DIR" "$EXPORT_DIR" 2>/dev/null
    mkdir -p "$OUTPUT_DIR/domains" "$OUTPUT_DIR/ips" "$OUTPUT_DIR/emails" \
             "$OUTPUT_DIR/usernames" "$OUTPUT_DIR/phones" "$OUTPUT_DIR/images" \
             "$OUTPUT_DIR/social" "$OUTPUT_DIR/network" "$OUTPUT_DIR/web" 2>/dev/null
}

#----------------------------
# LOGGING
#----------------------------
log() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $message" >> "$LOG_FILE" 2>/dev/null
}

log_info() { log "INFO" "$1"; }
log_warn() { log "WARN" "$1"; }
log_error() { log "ERROR" "$1"; }
log_success() { log "SUCCESS" "$1"; }

#----------------------------
# UTILITY FUNCTIONS
#----------------------------
print_banner() {
    clear
    echo -e "${CYAN}"
    cat << 'BANNER'
   ╔══════════════════════════════════════════════════════════════╗
   ║                                                              ║
   ║    ██████╗ ███████╗██╗███╗   ██╗████████╗    ██╗  ██╗       ║
   ║   ██╔═══██╗██╔════╝██║████╗  ██║╚══██╔══╝    ╚██╗██╔╝       ║
   ║   ██║   ██║███████╗██║██╔██╗ ██║   ██║        ╚███╔╝        ║
   ║   ██║   ██║╚════██║██║██║╚██╗██║   ██║        ██╔██╗        ║
   ║   ╚██████╔╝███████║██║██║ ╚████║   ██║       ██╔╝ ██╗       ║
   ║    ╚═════╝ ╚══════╝╚═╝╚═╝  ╚═══╝   ╚═╝       ╚═╝  ╚═╝       ║
   ║                                                              ║
   ║         Advanced OSINT Intelligence Framework                ║
   ╚══════════════════════════════════════════════════════════════╝
BANNER
    echo -e "${RESET}"
    echo -e "   ${GRAY}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "   ${WHITE}Version:${GREEN} $VERSION ${WHITE}| Platform:${GREEN} Termux ${WHITE}| Output:${GREEN} $OUTPUT_DIR${RESET}"
    echo -e "   ${GRAY}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo ""
}

print_section() {
    echo ""
    echo -e "  ${CYAN}╔═══════════════════════════════════════════════════════╗${RESET}"
    echo -e "  ${CYAN}║${WHITE}  $1${CYAN}$(printf '%*s' $((54 - ${#1})) '')║${RESET}"
    echo -e "  ${CYAN}╚═══════════════════════════════════════════════════════╝${RESET}"
    echo ""
}

print_result() {
    local label="$1"
    local value="$2"
    if [ -n "$value" ] && [ "$value" != "null" ] && [ "$value" != "N/A" ]; then
        echo -e "  ${GREEN}[+]${WHITE} ${label}: ${CYAN}${value}${RESET}"
    else
        echo -e "  ${YELLOW}[-]${WHITE} ${label}: ${DIM}Not found${RESET}"
    fi
}

print_info() {
    echo -e "  ${BLUE}[*]${WHITE} $1${RESET}"
}

print_success() {
    echo -e "  ${GREEN}[✓]${WHITE} $1${RESET}"
}

print_warning() {
    echo -e "  ${YELLOW}[!]${WHITE} $1${RESET}"
}

print_error() {
    echo -e "  ${RED}[✗]${WHITE} $1${RESET}"
}

print_progress() {
    echo -ne "  ${MAGENTA}[⟳]${WHITE} $1...\r${RESET}"
}

spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf "  ${MAGENTA}[%c]${WHITE} Processing...${RESET}\r" "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
    done
    printf "                                          \r"
}

validate_ip() {
    local ip=$1
    if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        return 0
    fi
    return 1
}

validate_email() {
    local email=$1
    if [[ $email =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
        return 0
    fi
    return 1
}

validate_domain() {
    local domain=$1
    if [[ $domain =~ ^[a-zA-Z0-9]([a-zA-Z0-9-]*[a-zA-Z0-9])?(\.[a-zA-Z0-9]([a-zA-Z0-9-]*[a-zA-Z0-9])?)*\.[a-zA-Z]{2,}$ ]]; then
        return 0
    fi
    return 1
}

validate_url() {
    local url=$1
    if [[ $url =~ ^https?:// ]]; then
        return 0
    fi
    return 1
}

safe_curl() {
    local url="$1"
    shift
    curl -s -L --max-time "$TIMEOUT" --retry "$MAX_RETRIES" \
         -H "User-Agent: $USER_AGENT" "$@" "$url" 2>/dev/null
}

json_extract() {
    local json="$1"
    local key="$2"
    echo "$json" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    keys = '$key'.split('.')
    for k in keys:
        if isinstance(data, list):
            data = data[int(k)]
        else:
            data = data[k]
    print(data)
except:
    print('N/A')
" 2>/dev/null
}

save_results() {
    local filename="$1"
    local content="$2"
    local dir="$3"
    echo "$content" > "${dir}/${filename}" 2>/dev/null
    log_info "Results saved to ${dir}/${filename}"
}

check_dependency() {
    if ! command -v "$1" &>/dev/null; then
        return 1
    fi
    return 0
}

separator() {
    echo -e "  ${GRAY}─────────────────────────────────────────────────────────${RESET}"
}

#----------------------------
# INSTALLATION CHECK
#----------------------------
check_and_install_deps() {
    print_section "DEPENDENCY CHECK"
    
    local deps=("curl" "wget" "nmap" "python3" "dig" "whois" "traceroute" 
                "jq" "git" "openssl" "nslookup" "host" "nikto" "hydra"
                "sqlmap" "whatweb" "dnsutils" "net-tools" "figlet" "toilet")
    
    local pip_deps=("requests" "shodan" "beautifulsoup4" "dnspython" 
                    "python-whois" "phonenumbers" "tweepy" "Pillow"
                    "exifread" "colorama" "censys")
    
    local missing=()
    
    for dep in "${deps[@]}"; do
        if check_dependency "$dep"; then
            echo -e "  ${GREEN}[✓]${WHITE} $dep ${GREEN}installed${RESET}"
        else
            echo -e "  ${RED}[✗]${WHITE} $dep ${RED}missing${RESET}"
            missing+=("$dep")
        fi
    done
    
    if [ ${#missing[@]} -gt 0 ]; then
        echo ""
        print_warning "Installing missing dependencies..."
        pkg update -y &>/dev/null
        for dep in "${missing[@]}"; do
            print_progress "Installing $dep"
            pkg install -y "$dep" &>/dev/null 2>&1
            if check_dependency "$dep"; then
                print_success "$dep installed successfully"
            else
                print_warning "$dep could not be installed (may need manual setup)"
            fi
        done
    fi
    
    echo ""
    print_info "Checking Python modules..."
    for pdep in "${pip_deps[@]}"; do
        if python3 -c "import ${pdep//-/_}" 2>/dev/null; then
            echo -e "  ${GREEN}[✓]${WHITE} $pdep ${GREEN}available${RESET}"
        else
            print_progress "Installing $pdep"
            pip install "$pdep" &>/dev/null 2>&1
        fi
    done
    
    print_success "Dependency check complete"
    sleep 1
}

#============================================================================
# MODULE 1: DOMAIN INTELLIGENCE
#============================================================================
domain_recon() {
    print_section "DOMAIN INTELLIGENCE"
    echo -ne "  ${WHITE}Enter target domain: ${CYAN}"
    read -r target_domain
    echo -e "${RESET}"
    
    if ! validate_domain "$target_domain"; then
        print_error "Invalid domain format"
        return 1
    fi
    
    local result_file="$OUTPUT_DIR/domains/${target_domain}_$(date +%Y%m%d_%H%M%S).txt"
    log_info "Starting domain recon for: $target_domain"
    
    echo "========================================" > "$result_file"
    echo "DOMAIN INTELLIGENCE REPORT" >> "$result_file"
    echo "Target: $target_domain" >> "$result_file"
    echo "Date: $(date)" >> "$result_file"
    echo "========================================" >> "$result_file"
    
    # 1. WHOIS Lookup
    separator
    print_info "WHOIS Information"
    separator
    if check_dependency "whois"; then
        local whois_data=$(whois "$target_domain" 2>/dev/null)
        if [ -n "$whois_data" ]; then
            local registrar=$(echo "$whois_data" | grep -i "registrar:" | head -1 | cut -d: -f2- | xargs)
            local creation=$(echo "$whois_data" | grep -i "creation date\|created" | head -1 | cut -d: -f2- | xargs)
            local expiry=$(echo "$whois_data" | grep -i "expir" | head -1 | cut -d: -f2- | xargs)
            local nameservers=$(echo "$whois_data" | grep -i "name server" | cut -d: -f2- | xargs | tr ' ' ', ')
            local registrant_org=$(echo "$whois_data" | grep -i "registrant organization" | head -1 | cut -d: -f2- | xargs)
            local registrant_country=$(echo "$whois_data" | grep -i "registrant country" | head -1 | cut -d: -f2- | xargs)
            local dnssec=$(echo "$whois_data" | grep -i "dnssec" | head -1 | cut -d: -f2- | xargs)
            local status=$(echo "$whois_data" | grep -i "domain status" | head -1 | cut -d: -f2- | xargs)
            
            print_result "Registrar" "$registrar"
            print_result "Created" "$creation"
            print_result "Expires" "$expiry"
            print_result "Name Servers" "$nameservers"
            print_result "Organization" "$registrant_org"
            print_result "Country" "$registrant_country"
            print_result "DNSSEC" "$dnssec"
            print_result "Status" "$status"
            
            echo -e "\n[WHOIS]\n$whois_data" >> "$result_file"
        fi
    fi
    
    # 2. DNS Records
    separator
    print_info "DNS Records"
    separator
    
    local record_types=("A" "AAAA" "MX" "NS" "TXT" "CNAME" "SOA" "SRV" "CAA" "PTR")
    for rtype in "${record_types[@]}"; do
        local records=$(dig +short "$target_domain" "$rtype" 2>/dev/null)
        if [ -n "$records" ]; then
            print_result "$rtype Record" "$(echo $records | head -3)"
            echo "[$rtype] $records" >> "$result_file"
        fi
    done
    
    # 3. Subdomain Enumeration
    separator
    print_info "Subdomain Enumeration"
    separator
    
    local subdomains=()
    
    # Method 1: crt.sh Certificate Transparency
    print_progress "Querying Certificate Transparency logs"
    local crt_data=$(safe_curl "https://crt.sh/?q=%.${target_domain}&output=json")
    if [ -n "$crt_data" ]; then
        local crt_subs=$(echo "$crt_data" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    subs = set()
    for entry in data:
        name = entry.get('name_value', '')
        for s in name.split('\n'):
            s = s.strip().lower()
            if s and '*' not in s:
                subs.add(s)
    for s in sorted(subs):
        print(s)
except:
    pass
" 2>/dev/null)
        while IFS= read -r sub; do
            [ -n "$sub" ] && subdomains+=("$sub")
        done <<< "$crt_subs"
    fi
    
    # Method 2: DNS Brute Force
    print_progress "DNS brute force enumeration"
    local common_subs=("www" "mail" "ftp" "smtp" "pop" "imap" "webmail" "admin" "portal"
                       "ns1" "ns2" "dns" "mx" "vpn" "remote" "gateway" "proxy" "cdn"
                       "api" "app" "dev" "staging" "test" "beta" "demo" "blog" "shop"
                       "store" "forum" "wiki" "docs" "help" "support" "status" "monitor"
                       "dashboard" "panel" "cpanel" "cloud" "s3" "assets" "static"
                       "media" "images" "img" "css" "js" "data" "db" "database"
                       "mysql" "postgres" "redis" "elastic" "kibana" "grafana"
                       "jenkins" "ci" "cd" "git" "gitlab" "bitbucket" "jira"
                       "confluence" "slack" "teams" "zoom" "meet" "chat"
                       "auth" "login" "sso" "oauth" "identity" "accounts"
                       "billing" "payment" "checkout" "cart" "order"
                       "internal" "intranet" "extranet" "private" "secure"
                       "m" "mobile" "wap" "touch" "amp"
                       "old" "new" "legacy" "v1" "v2" "v3"
                       "backup" "bak" "temp" "tmp" "cache"
                       "mx1" "mx2" "ns3" "ns4" "dns1" "dns2"
                       "relay" "edge" "lb" "loadbalancer" "firewall"
                       "web1" "web2" "app1" "app2" "srv1" "srv2")
    
    for sub in "${common_subs[@]}"; do
        local resolved=$(dig +short "${sub}.${target_domain}" A 2>/dev/null | head -1)
        if [ -n "$resolved" ]; then
            subdomains+=("${sub}.${target_domain}")
        fi
    done
    
    # Method 3: HackerTarget
    local ht_data=$(safe_curl "https://api.hackertarget.com/hostsearch/?q=${target_domain}")
    if [ -n "$ht_data" ] && [[ "$ht_data" != *"error"* ]]; then
        while IFS=',' read -r sub ip; do
            [ -n "$sub" ] && subdomains+=("$sub")
        done <<< "$ht_data"
    fi
    
    # Method 4: ThreatCrowd
    local tc_data=$(safe_curl "https://www.threatcrowd.org/searchApi/v2/domain/report/?domain=${target_domain}")
    if [ -n "$tc_data" ]; then
        local tc_subs=$(echo "$tc_data" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    for s in data.get('subdomains', []):
        print(s)
except:
    pass
" 2>/dev/null)
        while IFS= read -r sub; do
            [ -n "$sub" ] && subdomains+=("$sub")
        done <<< "$tc_subs"
    fi
    
    # Remove duplicates and display
    local unique_subs=($(printf '%s\n' "${subdomains[@]}" | sort -u))
    echo ""
    print_success "Found ${#unique_subs[@]} unique subdomains"
    echo ""
    
    echo -e "\n[SUBDOMAINS]" >> "$result_file"
    for sub in "${unique_subs[@]}"; do
        local sub_ip=$(dig +short "$sub" A 2>/dev/null | head -1)
        echo -e "  ${GREEN}→${WHITE} $sub ${GRAY}($sub_ip)${RESET}"
        echo "$sub -> $sub_ip" >> "$result_file"
    done
    
    # 4. Technology Detection
    separator
    print_info "Technology Detection"
    separator
    
    local headers=$(safe_curl -I "https://${target_domain}" -H "Accept: text/html")
    
    local server=$(echo "$headers" | grep -i "^server:" | cut -d: -f2- | xargs)
    local powered_by=$(echo "$headers" | grep -i "x-powered-by:" | cut -d: -f2- | xargs)
    local content_type=$(echo "$headers" | grep -i "content-type:" | cut -d: -f2- | xargs)
    local x_frame=$(echo "$headers" | grep -i "x-frame-options:" | cut -d: -f2- | xargs)
    local x_xss=$(echo "$headers" | grep -i "x-xss-protection:" | cut -d: -f2- | xargs)
    local csp=$(echo "$headers" | grep -i "content-security-policy:" | cut -d: -f2- | xargs)
    local hsts=$(echo "$headers" | grep -i "strict-transport-security:" | cut -d: -f2- | xargs)
    local x_content=$(echo "$headers" | grep -i "x-content-type-options:" | cut -d: -f2- | xargs)
    local cf_ray=$(echo "$headers" | grep -i "cf-ray:" | cut -d: -f2- | xargs)
    
    print_result "Server" "$server"
    print_result "Powered By" "$powered_by"
    print_result "Content Type" "$content_type"
    
    echo ""
    print_info "Security Headers"
    [ -n "$x_frame" ] && print_result "X-Frame-Options" "$x_frame" || print_warning "X-Frame-Options: Missing"
    [ -n "$x_xss" ] && print_result "X-XSS-Protection" "$x_xss" || print_warning "X-XSS-Protection: Missing"
    [ -n "$csp" ] && print_result "CSP" "${csp:0:80}..." || print_warning "Content-Security-Policy: Missing"
    [ -n "$hsts" ] && print_result "HSTS" "$hsts" || print_warning "HSTS: Missing"
    [ -n "$x_content" ] && print_result "X-Content-Type-Options" "$x_content" || print_warning "X-Content-Type-Options: Missing"
    [ -n "$cf_ray" ] && print_result "Cloudflare" "Detected (CF-Ray: $cf_ray)"
    
    # 5. SSL/TLS Analysis
    separator
    print_info "SSL/TLS Certificate Analysis"
    separator
    
    local ssl_info=$(echo | openssl s_client -connect "${target_domain}:443" -servername "$target_domain" 2>/dev/null)
    if [ -n "$ssl_info" ]; then
        local ssl_subject=$(echo "$ssl_info" | openssl x509 -noout -subject 2>/dev/null | sed 's/subject=//')
        local ssl_issuer=$(echo "$ssl_info" | openssl x509 -noout -issuer 2>/dev/null | sed 's/issuer=//')
        local ssl_dates=$(echo "$ssl_info" | openssl x509 -noout -dates 2>/dev/null)
        local ssl_serial=$(echo "$ssl_info" | openssl x509 -noout -serial 2>/dev/null | cut -d= -f2)
        local ssl_san=$(echo "$ssl_info" | openssl x509 -noout -ext subjectAltName 2>/dev/null)
        local ssl_proto=$(echo "$ssl_info" | grep "Protocol" | xargs)
        local ssl_cipher=$(echo "$ssl_info" | grep "Cipher" | head -1 | xargs)
        
        print_result "Subject" "$ssl_subject"
        print_result "Issuer" "$ssl_issuer"
        print_result "Serial" "$ssl_serial"
        print_result "Protocol" "$ssl_proto"
        print_result "Cipher" "$ssl_cipher"
        echo "$ssl_dates" | while IFS= read -r line; do
            [ -n "$line" ] && print_result "Date" "$line"
        done
        
        echo -e "\n[SSL/TLS]\n$ssl_info" >> "$result_file"
    fi
    
    # 6. Email Harvesting
    separator
    print_info "Email Harvesting"
    separator
    
    local emails=()
    
    # From page source
    local page_source=$(safe_curl "https://${target_domain}")
    if [ -n "$page_source" ]; then
        local found_emails=$(echo "$page_source" | grep -oE '[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}' | sort -u)
        while IFS= read -r email; do
            [ -n "$email" ] && emails+=("$email")
        done <<< "$found_emails"
    fi
    
    # From Hunter.io
    if [ -n "$HUNTER_API_KEY" ]; then
        local hunter_data=$(safe_curl "https://api.hunter.io/v2/domain-search?domain=${target_domain}&api_key=${HUNTER_API_KEY}")
        local hunter_emails=$(echo "$hunter_data" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    for e in data.get('data', {}).get('emails', []):
        print(e.get('value', ''))
except:
    pass
" 2>/dev/null)
        while IFS= read -r email; do
            [ -n "$email" ] && emails+=("$email")
        done <<< "$hunter_emails"
    fi
    
    local unique_emails=($(printf '%s\n' "${emails[@]}" | sort -u))
    echo -e "\n[EMAILS]" >> "$result_file"
    for email in "${unique_emails[@]}"; do
        echo -e "  ${GREEN}→${WHITE} $email${RESET}"
        echo "$email" >> "$result_file"
    done
    [ ${#unique_emails[@]} -eq 0 ] && print_warning "No emails found"
    
    # 7. Robots.txt & Sitemap
    separator
    print_info "Robots.txt & Sitemap Analysis"
    separator
    
    local robots=$(safe_curl "https://${target_domain}/robots.txt")
    if [ -n "$robots" ] && [[ "$robots" != *"404"* ]] && [[ "$robots" != *"Not Found"* ]]; then
        print_success "robots.txt found"
        local disallow=$(echo "$robots" | grep -i "disallow" | head -10)
        echo "$disallow" | while IFS= read -r line; do
            [ -n "$line" ] && echo -e "    ${GRAY}$line${RESET}"
        done
        echo -e "\n[ROBOTS.TXT]\n$robots" >> "$result_file"
    fi
    
    local sitemap=$(safe_curl "https://${target_domain}/sitemap.xml")
    if [ -n "$sitemap" ] && [[ "$sitemap" == *"<url"* ]]; then
        local sitemap_count=$(echo "$sitemap" | grep -c "<url>")
        print_result "Sitemap URLs" "$sitemap_count entries found"
    fi
    
    # 8. Wayback Machine
    separator
    print_info "Wayback Machine History"
    separator
    
    local wayback=$(safe_curl "https://web.archive.org/cdx/search/cdx?url=${target_domain}&output=json&limit=10&fl=timestamp,original,statuscode,mimetype")
    if [ -n "$wayback" ]; then
        local snapshot_count=$(safe_curl "https://web.archive.org/cdx/search/cdx?url=${target_domain}/*&output=json&limit=1&showNumPages=true")
        print_result "Total Snapshots" "$snapshot_count pages archived"
        
        local first_snapshot=$(safe_curl "https://web.archive.org/cdx/search/cdx?url=${target_domain}&output=json&limit=1&fl=timestamp" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    if len(data) > 1:
        ts = data[1][0]
        print(f'{ts[:4]}-{ts[4:6]}-{ts[6:8]}')
except:
    pass
" 2>/dev/null)
        print_result "First Archived" "$first_snapshot"
    fi
    
    # 9. Port Scan (Top ports)
    separator
    print_info "Quick Port Scan (Top 20)"
    separator
    
    local target_ip=$(dig +short "$target_domain" A 2>/dev/null | head -1)
    if [ -n "$target_ip" ]; then
        print_result "Resolved IP" "$target_ip"
        
        if check_dependency "nmap"; then
            local nmap_result=$(nmap -sT --top-ports 20 -T4 --open "$target_ip" 2>/dev/null)
            echo "$nmap_result" | grep "open" | while IFS= read -r line; do
                echo -e "  ${GREEN}→${WHITE} $line${RESET}"
            done
            echo -e "\n[PORT SCAN]\n$nmap_result" >> "$result_file"
        else
            # Fallback: bash port scan
            local common_ports=(21 22 23 25 53 80 110 143 443 445 993 995 3306 3389 5432 8080 8443 8888 9090 27017)
            for port in "${common_ports[@]}"; do
                (echo >/dev/tcp/"$target_ip"/"$port") &>/dev/null && \
                    echo -e "  ${GREEN}→${WHITE} Port $port: ${GREEN}OPEN${RESET}"
            done
        fi
    fi
    
    # 10. SecurityTrails Integration
    if [ -n "$SECURITYTRAILS_API_KEY" ]; then
        separator
        print_info "SecurityTrails Data"
        separator
        
        local st_data=$(safe_curl "https://api.securitytrails.com/v1/domain/${target_domain}" \
            -H "APIKEY: ${SECURITYTRAILS_API_KEY}")
        
        if [ -n "$st_data" ]; then
            local alexa_rank=$(json_extract "$st_data" "alexa_rank")
            print_result "Alexa Rank" "$alexa_rank"
        fi
    fi
    
    separator
    print_success "Domain intelligence report saved to: $result_file"
    log_success "Domain recon completed for $target_domain"
    
    echo ""
    read -p "  Press Enter to continue..."
}

#============================================================================
# MODULE 2: IP ADDRESS INTELLIGENCE
#============================================================================
ip_recon() {
    print_section "IP ADDRESS INTELLIGENCE"
    echo -ne "  ${WHITE}Enter target IP: ${CYAN}"
    read -r target_ip
    echo -e "${RESET}"
    
    if ! validate_ip "$target_ip"; then
        print_error "Invalid IP address format"
        return 1
    fi
    
    local result_file="$OUTPUT_DIR/ips/${target_ip}_$(date +%Y%m%d_%H%M%S).txt"
    log_info "Starting IP recon for: $target_ip"
    
    echo "========================================" > "$result_file"
    echo "IP INTELLIGENCE REPORT" >> "$result_file"
    echo "Target: $target_ip" >> "$result_file"
    echo "Date: $(date)" >> "$result_file"
    echo "========================================" >> "$result_file"
    
    # 1. GeoIP Information
    separator
    print_info "Geolocation & Network Information"
    separator
    
    # ip-api.com
    local geo_data=$(safe_curl "http://ip-api.com/json/${target_ip}?fields=status,message,continent,continentCode,country,countryCode,region,regionName,city,district,zip,lat,lon,timezone,offset,currency,isp,org,as,asname,reverse,mobile,proxy,hosting,query")
    
    if [ -n "$geo_data" ]; then
        print_result "Country" "$(json_extract "$geo_data" "country") ($(json_extract "$geo_data" "countryCode"))"
        print_result "Region" "$(json_extract "$geo_data" "regionName")"
        print_result "City" "$(json_extract "$geo_data" "city")"
        print_result "ZIP" "$(json_extract "$geo_data" "zip")"
        print_result "Latitude" "$(json_extract "$geo_data" "lat")"
        print_result "Longitude" "$(json_extract "$geo_data" "lon")"
        print_result "Timezone" "$(json_extract "$geo_data" "timezone")"
        print_result "ISP" "$(json_extract "$geo_data" "isp")"
        print_result "Organization" "$(json_extract "$geo_data" "org")"
        print_result "AS Number" "$(json_extract "$geo_data" "as")"
        print_result "AS Name" "$(json_extract "$geo_data" "asname")"
        print_result "Reverse DNS" "$(json_extract "$geo_data" "reverse")"
        print_result "Continent" "$(json_extract "$geo_data" "continent")"
        print_result "Is Proxy" "$(json_extract "$geo_data" "proxy")"
        print_result "Is Hosting" "$(json_extract "$geo_data" "hosting")"
        print_result "Is Mobile" "$(json_extract "$geo_data" "mobile")"
        
        echo -e "\n[GEOLOCATION]\n$geo_data" >> "$result_file"
    fi
    
    # ipinfo.io
    if [ -n "$IPINFO_TOKEN" ]; then
        local ipinfo_data=$(safe_curl "https://ipinfo.io/${target_ip}/json?token=${IPINFO_TOKEN}")
    else
        local ipinfo_data=$(safe_curl "https://ipinfo.io/${target_ip}/json")
    fi
    
    if [ -n "$ipinfo_data" ]; then
        print_result "Hostname" "$(json_extract "$ipinfo_data" "hostname")"
        echo -e "\n[IPINFO]\n$ipinfo_data" >> "$result_file"
    fi
    
    # 2. Reverse DNS
    separator
    print_info "Reverse DNS Lookup"
    separator
    
    local rdns=$(dig +short -x "$target_ip" 2>/dev/null)
    print_result "PTR Record" "$rdns"
    
    # HackerTarget Reverse DNS
    local rdns_hosts=$(safe_curl "https://api.hackertarget.com/reverseiplookup/?q=${target_ip}")
    if [ -n "$rdns_hosts" ] && [[ "$rdns_hosts" != *"error"* ]]; then
        local host_count=$(echo "$rdns_hosts" | wc -l)
        print_result "Hosted Domains" "$host_count found"
        echo "$rdns_hosts" | head -20 | while IFS= read -r host; do
            echo -e "    ${GRAY}→ $host${RESET}"
        done
        echo -e "\n[REVERSE DNS HOSTS]\n$rdns_hosts" >> "$result_file"
    fi
    
    # 3. WHOIS
    separator
    print_info "IP WHOIS Information"
    separator
    
    if check_dependency "whois"; then
        local ip_whois=$(whois "$target_ip" 2>/dev/null)
        local netname=$(echo "$ip_whois" | grep -i "netname\|NetName" | head -1 | awk '{print $NF}')
        local netrange=$(echo "$ip_whois" | grep -i "netrange\|NetRange\|inetnum" | head -1 | cut -d: -f2- | xargs)
        local org_name=$(echo "$ip_whois" | grep -i "orgname\|OrgName\|org-name" | head -1 | cut -d: -f2- | xargs)
        local abuse_email=$(echo "$ip_whois" | grep -i "abuse.*email\|OrgAbuseEmail" | head -1 | cut -d: -f2- | xargs)
        
        print_result "Network Name" "$netname"
        print_result "Net Range" "$netrange"
        print_result "Org Name" "$org_name"
        print_result "Abuse Email" "$abuse_email"
        
        echo -e "\n[IP WHOIS]\n$ip_whois" >> "$result_file"
    fi
    
    # 4. Shodan Integration
    if [ -n "$SHODAN_API_KEY" ]; then
        separator
        print_info "Shodan Intelligence"
        separator
        
        local shodan_data=$(safe_curl "https://api.shodan.io/shodan/host/${target_ip}?key=${SHODAN_API_KEY}")
        if [ -n "$shodan_data" ] && [[ "$shodan_data" != *"error"* ]]; then
            local open_ports=$(json_extract "$shodan_data" "ports")
            local vulns=$(echo "$shodan_data" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    vulns = data.get('vulns', [])
    print(', '.join(vulns[:10]))
except:
    print('N/A')
" 2>/dev/null)
            local os_info=$(json_extract "$shodan_data" "os")
            local last_update=$(json_extract "$shodan_data" "last_update")
            
            print_result "Open Ports" "$open_ports"
            print_result "OS Detected" "$os_info"
            print_result "Vulnerabilities" "$vulns"
            print_result "Last Updated" "$last_update"
            
            # Services detail
            echo "$shodan_data" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    for svc in data.get('data', [])[:10]:
        port = svc.get('port', 'N/A')
        transport = svc.get('transport', 'N/A')
        product = svc.get('product', 'N/A')
        version = svc.get('version', '')
        print(f'    Port {port}/{transport}: {product} {version}')
except:
    pass
" 2>/dev/null | while IFS= read -r svc_line; do
                echo -e "  ${CYAN}$svc_line${RESET}"
            done
            
            echo -e "\n[SHODAN]\n$shodan_data" >> "$result_file"
        fi
    fi
    
    # 5. AbuseIPDB Check
    if [ -n "$ABUSEIPDB_API_KEY" ]; then
        separator
        print_info "AbuseIPDB Reputation"
        separator
        
        local abuse_data=$(safe_curl "https://api.abuseipdb.com/api/v2/check?ipAddress=${target_ip}&maxAgeInDays=90&verbose" \
            -H "Key: ${ABUSEIPDB_API_KEY}" -H "Accept: application/json")
        
        if [ -n "$abuse_data" ]; then
            local abuse_score=$(json_extract "$abuse_data" "data.abuseConfidenceScore")
            local total_reports=$(json_extract "$abuse_data" "data.totalReports")
            local is_whitelisted=$(json_extract "$abuse_data" "data.isWhitelisted")
            local usage_type=$(json_extract "$abuse_data" "data.usageType")
            
            print_result "Abuse Score" "${abuse_score}%"
            print_result "Total Reports" "$total_reports"
            print_result "Whitelisted" "$is_whitelisted"
            print_result "Usage Type" "$usage_type"
        fi
    fi
    
    # 6. VirusTotal Check
    if [ -n "$VIRUSTOTAL_API_KEY" ]; then
        separator
        print_info "VirusTotal Analysis"
        separator
        
        local vt_data=$(safe_curl "https://www.virustotal.com/api/v3/ip_addresses/${target_ip}" \
            -H "x-apikey: ${VIRUSTOTAL_API_KEY}")
        
        if [ -n "$vt_data" ]; then
            local vt_rep=$(echo "$vt_data" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    stats = data.get('data', {}).get('attributes', {}).get('last_analysis_stats', {})
    mal = stats.get('malicious', 0)
    susp = stats.get('suspicious', 0)
    clean = stats.get('harmless', 0)
    undetected = stats.get('undetected', 0)
    print(f'Malicious: {mal}, Suspicious: {susp}, Clean: {clean}, Undetected: {undetected}')
except:
    print('N/A')
" 2>/dev/null)
            print_result "VT Analysis" "$vt_rep"
        fi
    fi
    
    # 7. Traceroute
    separator
    print_info "Network Traceroute"
    separator
    
    if check_dependency "traceroute"; then
        print_progress "Running traceroute"
        local trace=$(traceroute -m 15 -w 2 "$target_ip" 2>/dev/null)
        echo "$trace" | while IFS= read -r line; do
            echo -e "    ${GRAY}$line${RESET}"
        done
        echo -e "\n[TRACEROUTE]\n$trace" >> "$result_file"
    fi
    
    # 8. Port Scan
    separator
    print_info "Comprehensive Port Scan"
    separator
    
    if check_dependency "nmap"; then
        print_progress "Scanning ports (this may take a moment)"
        local nmap_out=$(nmap -sV -sC --top-ports 100 -T4 "$target_ip" 2>/dev/null)
        echo "$nmap_out" | grep -E "open|filtered" | while IFS= read -r line; do
            echo -e "  ${GREEN}→${WHITE} $line${RESET}"
        done
        local os_detection=$(echo "$nmap_out" | grep -A2 "OS details\|OS CPE\|Running:")
        [ -n "$os_detection" ] && print_result "OS Detection" "$(echo $os_detection | head -1)"
        echo -e "\n[NMAP SCAN]\n$nmap_out" >> "$result_file"
    fi
    
    # 9. Blacklist Check
    separator
    print_info "Blacklist Check"
    separator
    
    local reversed_ip=$(echo "$target_ip" | awk -F. '{print $4"."$3"."$2"."$1}')
    local dnsbl_servers=("zen.spamhaus.org" "bl.spamcop.net" "b.barracudacentral.org" 
                         "dnsbl.sorbs.net" "spam.dnsbl.sorbs.net" "cbl.abuseat.org"
                         "dnsbl-1.uceprotect.net" "psbl.surriel.com")
    
    for dnsbl in "${dnsbl_servers[@]}"; do
        local bl_result=$(dig +short "${reversed_ip}.${dnsbl}" A 2>/dev/null)
        if [ -n "$bl_result" ]; then
            echo -e "  ${RED}[LISTED]${WHITE} $dnsbl: ${RED}$bl_result${RESET}"
        else
            echo -e "  ${GREEN}[CLEAN]${WHITE} $dnsbl${RESET}"
        fi
    done
    
    separator
    print_success "IP intelligence report saved to: $result_file"
    log_success "IP recon completed for $target_ip"
    
    echo ""
    read -p "  Press Enter to continue..."
}

#============================================================================
# MODULE 3: EMAIL INTELLIGENCE
#============================================================================
email_recon() {
    print_section "EMAIL INTELLIGENCE"
    echo -ne "  ${WHITE}Enter target email: ${CYAN}"
    read -r target_email
    echo -e "${RESET}"
    
    if ! validate_email "$target_email"; then
        print_error "Invalid email format"
        return 1
    fi
    
    local result_file="$OUTPUT_DIR/emails/${target_email//[@.]/_}_$(date +%Y%m%d_%H%M%S).txt"
    local email_domain=$(echo "$target_email" | cut -d@ -f2)
    local email_user=$(echo "$target_email" | cut -d@ -f1)
    
    echo "========================================" > "$result_file"
    echo "EMAIL INTELLIGENCE REPORT" >> "$result_file"
    echo "Target: $target_email" >> "$result_file"
    echo "Date: $(date)" >> "$result_file"
    echo "========================================" >> "$result_file"
    
    # 1. Email Validation
    separator
    print_info "Email Validation"
    separator
    
    # MX Record Check
    local mx_records=$(dig +short MX "$email_domain" 2>/dev/null)
    if [ -n "$mx_records" ]; then
        print_result "Domain MX" "Valid - Mail server found"
        echo "$mx_records" | while IFS= read -r mx; do
            echo -e "    ${GRAY}→ $mx${RESET}"
        done
    else
        print_warning "No MX records found for $email_domain"
    fi
    
    # SPF Check
    local spf=$(dig +short TXT "$email_domain" 2>/dev/null | grep -i "spf")
    print_result "SPF Record" "$spf"
    
    # DMARC Check
    local dmarc=$(dig +short TXT "_dmarc.${email_domain}" 2>/dev/null)
    print_result "DMARC Record" "$dmarc"
    
    # DKIM Check (common selectors)
    local dkim_selectors=("default" "google" "selector1" "selector2" "k1" "mail" "dkim" "s1" "s2")
    for selector in "${dkim_selectors[@]}"; do
        local dkim=$(dig +short TXT "${selector}._domainkey.${email_domain}" 2>/dev/null)
        if [ -n "$dkim" ]; then
            print_result "DKIM ($selector)" "Found"
            break
        fi
    done
    
    # 2. Have I Been Pwned
    separator
    print_info "Data Breach Check"
    separator
    
    if [ -n "$HAVEIBEENPWNED_API_KEY" ]; then
        local hibp_data=$(safe_curl "https://haveibeenpwned.com/api/v3/breachedaccount/${target_email}" \
            -H "hibp-api-key: ${HAVEIBEENPWNED_API_KEY}" \
            -H "User-Agent: OSINT-X-Tool")
        
        if [ -n "$hibp_data" ] && [[ "$hibp_data" != *"404"* ]]; then
            local breach_count=$(echo "$hibp_data" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    print(len(data))
except:
    print(0)
" 2>/dev/null)
            print_result "Breaches Found" "$breach_count"
            
            echo "$hibp_data" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    for breach in data:
        name = breach.get('Name', 'Unknown')
        date = breach.get('BreachDate', 'Unknown')
        count = breach.get('PwnCount', 0)
        types = ', '.join(breach.get('DataClasses', []))
        print(f'{name}|{date}|{count}|{types}')
except:
    pass
" 2>/dev/null | while IFS='|' read -r name date count types; do
                echo -e "  ${RED}→${WHITE} $name ${GRAY}(${date}, ${count} accounts)${RESET}"
                echo -e "    ${DIM}Exposed: ${types}${RESET}"
            done
        else
            print_success "No breaches found"
        fi
        
        # Paste check
        local paste_data=$(safe_curl "https://haveibeenpwned.com/api/v3/pasteaccount/${target_email}" \
            -H "hibp-api-key: ${HAVEIBEENPWNED_API_KEY}")
        if [ -n "$paste_data" ] && [[ "$paste_data" != *"404"* ]]; then
            print_warning "Found in paste dumps"
        fi
    else
        # Alternative: breach directory check
        local breach_check=$(safe_curl "https://breachdirectory.org/api/check/${target_email}")
        if [ -n "$breach_check" ]; then
            print_result "Breach Directory" "$(echo $breach_check | head -c 200)"
        fi
    fi
    
    # 3. Social Media & Profile Discovery
    separator
    print_info "Profile & Social Media Discovery"
    separator
    
    local profile_sites=(
        "gravatar.com/avatar/$(echo -n "$target_email" | md5sum | cut -d' ' -f1)?d=404"
        "en.gravatar.com/$(echo -n "$target_email" | md5sum | cut -d' ' -f1).json"
    )
    
    # Gravatar
    local gravatar_hash=$(echo -n "$target_email" | md5sum | cut -d' ' -f1)
    local gravatar_check=$(safe_curl -o /dev/null -w "%{http_code}" "https://gravatar.com/avatar/${gravatar_hash}?d=404")
    if [ "$gravatar_check" = "200" ]; then
        print_result "Gravatar" "Profile found (https://gravatar.com/${gravatar_hash})"
    fi
    
    # Gravatar profile data
    local gravatar_profile=$(safe_curl "https://en.gravatar.com/${gravatar_hash}.json")
    if [ -n "$gravatar_profile" ] && [[ "$gravatar_profile" != *"not found"* ]]; then
        local grav_name=$(json_extract "$gravatar_profile" "entry.0.displayName")
        local grav_location=$(json_extract "$gravatar_profile" "entry.0.currentLocation")
        local grav_about=$(json_extract "$gravatar_profile" "entry.0.aboutMe")
        print_result "Gravatar Name" "$grav_name"
        print_result "Gravatar Location" "$grav_location"
        print_result "Gravatar About" "$grav_about"
    fi
    
    # 4. Hunter.io Email Verification
    if [ -n "$HUNTER_API_KEY" ]; then
        separator
        print_info "Hunter.io Verification"
        separator
        
        local hunter_verify=$(safe_curl "https://api.hunter.io/v2/email-verifier?email=${target_email}&api_key=${HUNTER_API_KEY}")
        if [ -n "$hunter_verify" ]; then
            local h_status=$(json_extract "$hunter_verify" "data.status")
            local h_score=$(json_extract "$hunter_verify" "data.score")
            local h_disposable=$(json_extract "$hunter_verify" "data.disposable")
            local h_webmail=$(json_extract "$hunter_verify" "data.webmail")
            local h_firstname=$(json_extract "$hunter_verify" "data.first_name")
            local h_lastname=$(json_extract "$hunter_verify" "data.last_name")
            
            print_result "Verification Status" "$h_status"
            print_result "Score" "$h_score"
            print_result "Disposable" "$h_disposable"
            print_result "Webmail" "$h_webmail"
            print_result "First Name" "$h_firstname"
            print_result "Last Name" "$h_lastname"
        fi
    fi
    
    # 5. Username Derivation & Check
    separator
    print_info "Username Derivation"
    separator
    
    local derived_usernames=("$email_user")
    # Generate variations
    if [[ "$email_user" == *"."* ]]; then
        derived_usernames+=("$(echo $email_user | tr '.' '_')")
        derived_usernames+=("$(echo $email_user | tr -d '.')")
        derived_usernames+=("$(echo $email_user | cut -d. -f1)")
    fi
    if [[ "$email_user" == *"_"* ]]; then
        derived_usernames+=("$(echo $email_user | tr '_' '.')")
        derived_usernames+=("$(echo $email_user | tr -d '_')")
    fi
    derived_usernames+=("$(echo $email_user | tr -d '0-9')")
    
    local unique_usernames=($(printf '%s\n' "${derived_usernames[@]}" | sort -u))
    
    for uname in "${unique_usernames[@]}"; do
        [ -n "$uname" ] && echo -e "  ${CYAN}→${WHITE} Possible username: ${YELLOW}$uname${RESET}"
    done
    
    # 6. Domain Intelligence
    separator
    print_info "Email Domain Analysis"
    separator
    
    local domain_ip=$(dig +short A "$email_domain" 2>/dev/null | head -1)
    print_result "Domain IP" "$domain_ip"
    
    local domain_geo=$(safe_curl "http://ip-api.com/json/${domain_ip}?fields=country,city,isp,org")
    if [ -n "$domain_geo" ]; then
        print_result "Mail Server Country" "$(json_extract "$domain_geo" "country")"
        print_result "Mail Server City" "$(json_extract "$domain_geo" "city")"
        print_result "Mail Server ISP" "$(json_extract "$domain_geo" "isp")"
    fi
    
    # Check if disposable email
    local disposable_check=$(safe_curl "https://open.kickbox.com/v1/disposable/${email_domain}")
    if [ -n "$disposable_check" ]; then
        local is_disposable=$(json_extract "$disposable_check" "disposable")
        print_result "Disposable Email" "$is_disposable"
    fi
    
    separator
    print_success "Email intelligence report saved to: $result_file"
    
    echo ""
    read -p "  Press Enter to continue..."
}

#============================================================================
# MODULE 4: USERNAME INTELLIGENCE
#============================================================================
username_recon() {
    print_section "USERNAME INTELLIGENCE"
    echo -ne "  ${WHITE}Enter target username: ${CYAN}"
    read -r target_username
    echo -e "${RESET}"
    
    if [ -z "$target_username" ]; then
        print_error "Username cannot be empty"
        return 1
    fi
    
    local result_file="$OUTPUT_DIR/usernames/${target_username}_$(date +%Y%m%d_%H%M%S).txt"
    
    echo "========================================" > "$result_file"
    echo "USERNAME INTELLIGENCE REPORT" >> "$result_file"
    echo "Target: $target_username" >> "$result_file"
    echo "Date: $(date)" >> "$result_file"
    echo "========================================" >> "$result_file"
    
    separator
    print_info "Social Media & Platform Search"
    separator
    
    # Comprehensive platform list with URL patterns
    declare -A platforms=(
        ["GitHub"]="https://github.com/${target_username}"
        ["Twitter/X"]="https://x.com/${target_username}"
        ["Instagram"]="https://instagram.com/${target_username}"
        ["Facebook"]="https://facebook.com/${target_username}"
        ["LinkedIn"]="https://linkedin.com/in/${target_username}"
        ["Reddit"]="https://reddit.com/user/${target_username}"
        ["TikTok"]="https://tiktok.com/@${target_username}"
        ["YouTube"]="https://youtube.com/@${target_username}"
        ["Pinterest"]="https://pinterest.com/${target_username}"
        ["Tumblr"]="https://${target_username}.tumblr.com"
        ["Medium"]="https://medium.com/@${target_username}"
        ["Dev.to"]="https://dev.to/${target_username}"
        ["Keybase"]="https://keybase.io/${target_username}"
        ["GitLab"]="https://gitlab.com/${target_username}"
        ["Bitbucket"]="https://bitbucket.org/${target_username}"
        ["HackerNews"]="https://news.ycombinator.com/user?id=${target_username}"
        ["Steam"]="https://steamcommunity.com/id/${target_username}"
        ["Twitch"]="https://twitch.tv/${target_username}"
        ["Spotify"]="https://open.spotify.com/user/${target_username}"
        ["SoundCloud"]="https://soundcloud.com/${target_username}"
        ["Flickr"]="https://flickr.com/people/${target_username}"
        ["Vimeo"]="https://vimeo.com/${target_username}"
        ["Dribbble"]="https://dribbble.com/${target_username}"
        ["Behance"]="https://behance.net/${target_username}"
        ["SlideShare"]="https://slideshare.net/${target_username}"
        ["Quora"]="https://quora.com/profile/${target_username}"
        ["Telegram"]="https://t.me/${target_username}"
        ["PayPal"]="https://paypal.me/${target_username}"
        ["Patreon"]="https://patreon.com/${target_username}"
        ["Replit"]="https://replit.com/@${target_username}"
        ["CodePen"]="https://codepen.io/${target_username}"
        ["StackOverflow"]="https://stackoverflow.com/users/?tab=accounts&SearchOn=DisplayName&Search=${target_username}"
        ["Docker Hub"]="https://hub.docker.com/u/${target_username}"
        ["NPM"]="https://npmjs.com/~${target_username}"
        ["PyPI"]="https://pypi.org/user/${target_username}"
        ["Gravatar"]="https://gravatar.com/${target_username}"
        ["About.me"]="https://about.me/${target_username}"
        ["Hackernoon"]="https://hackernoon.com/u/${target_username}"
        ["ProductHunt"]="https://producthunt.com/@${target_username}"
        ["Fiverr"]="https://fiverr.com/${target_username}"
        ["Ello"]="https://ello.co/${target_username}"
        ["500px"]="https://500px.com/${target_username}"
        ["Last.fm"]="https://last.fm/user/${target_username}"
        ["Goodreads"]="https://goodreads.com/${target_username}"
        ["Mixcloud"]="https://mixcloud.com/${target_username}"
        ["BuyMeACoffee"]="https://buymeacoffee.com/${target_username}"
        ["Ko-fi"]="https://ko-fi.com/${target_username}"
        ["Linktree"]="https://linktr.ee/${target_username}"
        ["Mastodon"]="https://mastodon.social/@${target_username}"
        ["Threads"]="https://threads.net/@${target_username}"
        ["Snapchat"]="https://snapchat.com/add/${target_username}"
        ["Clubhouse"]="https://joinclubhouse.com/@${target_username}"
        ["Cash.App"]="https://cash.app/\$${target_username}"
        ["Imgur"]="https://imgur.com/user/${target_username}"
        ["MyAnimeList"]="https://myanimelist.net/profile/${target_username}"
        ["Roblox"]="https://roblox.com/user.aspx?username=${target_username}"
        ["Chess.com"]="https://chess.com/member/${target_username}"
        ["Letterboxd"]="https://letterboxd.com/${target_username}"
        ["Notion"]="https://notion.so/${target_username}"
    )
    
    local found_count=0
    local not_found_count=0
    local total=${#platforms[@]}
    local current=0
    
    echo -e "\n[PLATFORM RESULTS]" >> "$result_file"
    
    for platform in $(echo "${!platforms[@]}" | tr ' ' '\n' | sort); do
        ((current++))
        local url="${platforms[$platform]}"
        printf "  ${MAGENTA}[%d/%d]${WHITE} Checking %-20s\r" "$current" "$total" "$platform"
        
        local http_code=$(curl -s -o /dev/null -w "%{http_code}" -L --max-time 8 \
            -H "User-Agent: $USER_AGENT" "$url" 2>/dev/null)
        
        if [ "$http_code" = "200" ]; then
            echo -e "  ${GREEN}[FOUND]${WHITE}  %-20s ${CYAN}%s${RESET}" "$platform" "$url"
            echo "[FOUND] $platform: $url" >> "$result_file"
            ((found_count++))
        elif [ "$http_code" = "301" ] || [ "$http_code" = "302" ]; then
            echo -e "  ${YELLOW}[REDIR]${WHITE}  %-20s ${GRAY}%s (HTTP %s)${RESET}" "$platform" "$url" "$http_code"
            echo "[REDIRECT] $platform: $url ($http_code)" >> "$result_file"
        else
            echo -e "  ${RED}[  -  ]${WHITE}  %-20s ${DIM}Not found${RESET}" "$platform"
            echo "[NOT FOUND] $platform: $url ($http_code)" >> "$result_file"
            ((not_found_count++))
        fi
    done
    
    echo ""
    separator
    print_success "Results: ${found_count} found / ${not_found_count} not found / ${total} checked"
    
    # GitHub Deep Dive
    separator
    print_info "GitHub Profile Deep Dive"
    separator
    
    local gh_data=$(safe_curl "https://api.github.com/users/${target_username}")
    if [ -n "$gh_data" ] && [[ "$gh_data" != *"Not Found"* ]]; then
        print_result "Name" "$(json_extract "$gh_data" "name")"
        print_result "Bio" "$(json_extract "$gh_data" "bio")"
        print_result "Company" "$(json_extract "$gh_data" "company")"
        print_result "Location" "$(json_extract "$gh_data" "location")"
        print_result "Blog" "$(json_extract "$gh_data" "blog")"
        print_result "Public Repos" "$(json_extract "$gh_data" "public_repos")"
        print_result "Public Gists" "$(json_extract "$gh_data" "public_gists")"
        print_result "Followers" "$(json_extract "$gh_data" "followers")"
        print_result "Following" "$(json_extract "$gh_data" "following")"
        print_result "Created" "$(json_extract "$gh_data" "created_at")"
        print_result "Twitter" "$(json_extract "$gh_data" "twitter_username")"
        
        # Get repos
        local gh_repos=$(safe_curl "https://api.github.com/users/${target_username}/repos?sort=updated&per_page=10")
        if [ -n "$gh_repos" ]; then
            echo ""
            print_info "Recent Repositories:"
            echo "$gh_repos" | python3 -c "
import sys, json
try:
    repos = json.load(sys.stdin)
    for r in repos[:10]:
        name = r.get('name', 'N/A')
        lang = r.get('language', 'N/A')
        stars = r.get('stargazers_count', 0)
        desc = (r.get('description', '') or '')[:60]
        print(f'{name}|{lang}|{stars}|{desc}')
except:
    pass
" 2>/dev/null | while IFS='|' read -r name lang stars desc; do
                echo -e "    ${CYAN}→${WHITE} $name ${GRAY}($lang, ⭐$stars) $desc${RESET}"
            done
        fi
        
        # Get email from events
        local gh_events=$(safe_curl "https://api.github.com/users/${target_username}/events/public?per_page=30")
        if [ -n "$gh_events" ]; then
            local gh_email=$(echo "$gh_events" | python3 -c "
import sys, json
try:
    events = json.load(sys.stdin)
    emails = set()
    for e in events:
        payload = e.get('payload', {})
        commits = payload.get('commits', [])
        for c in commits:
            author = c.get('author', {})
            email = author.get('email', '')
            if email and 'noreply' not in email:
                emails.add(email)
    for e in emails:
        print(e)
except:
    pass
" 2>/dev/null)
            if [ -n "$gh_email" ]; then
                echo ""
                print_info "Emails found in GitHub events:"
                echo "$gh_email" | while IFS= read -r em; do
                    echo -e "    ${GREEN}→${WHITE} $em${RESET}"
                done
            fi
        fi
    fi
    
    separator
    print_success "Username intelligence report saved to: $result_file"
    
    echo ""
    read -p "  Press Enter to continue..."
}

#============================================================================
# MODULE 5: PHONE NUMBER INTELLIGENCE
#============================================================================
phone_recon() {
    print_section "PHONE NUMBER INTELLIGENCE"
    echo -ne "  ${WHITE}Enter phone number (with country code, e.g., +1234567890): ${CYAN}"
    read -r target_phone
    echo -e "${RESET}"
    
    if [ -z "$target_phone" ]; then
        print_error "Phone number cannot be empty"
        return 1
    fi
    
    local result_file="$OUTPUT_DIR/phones/${target_phone//+/_}_$(date +%Y%m%d_%H%M%S).txt"
    
    echo "========================================" > "$result_file"
    echo "PHONE NUMBER INTELLIGENCE REPORT" >> "$result_file"
    echo "Target: $target_phone" >> "$result_file"
    echo "Date: $(date)" >> "$result_file"
    echo "========================================" >> "$result_file"
    
    # Python-based phone analysis
    separator
    print_info "Phone Number Analysis"
    separator
    
    python3 << PYEOF 2>/dev/null
import sys
try:
    import phonenumbers
    from phonenumbers import geocoder, carrier, timezone
    
    phone = phonenumbers.parse("$target_phone", None)
    
    valid = phonenumbers.is_valid_number(phone)
    possible = phonenumbers.is_possible_number(phone)
    number_type_map = {
        0: "Fixed Line", 1: "Mobile", 2: "Fixed Line or Mobile",
        3: "Toll Free", 4: "Premium Rate", 5: "Shared Cost",
        6: "VoIP", 7: "Personal Number", 8: "Pager",
        9: "UAN", 10: "Voicemail", -1: "Unknown"
    }
    num_type = number_type_map.get(phonenumbers.number_type(phone), "Unknown")
    
    country = geocoder.description_for_number(phone, "en")
    carrier_name = carrier.name_for_number(phone, "en")
    tz = timezone.time_zones_for_number(phone)
    
    national = phonenumbers.format_number(phone, phonenumbers.PhoneNumberFormat.NATIONAL)
    international = phonenumbers.format_number(phone, phonenumbers.PhoneNumberFormat.INTERNATIONAL)
    e164 = phonenumbers.format_number(phone, phonenumbers.PhoneNumberFormat.E164)
    
    print(f"VALID|{valid}")
    print(f"POSSIBLE|{possible}")
    print(f"TYPE|{num_type}")
    print(f"COUNTRY|{country}")
    print(f"CARRIER|{carrier_name}")
    print(f"TIMEZONE|{', '.join(tz)}")
    print(f"NATIONAL|{national}")
    print(f"INTERNATIONAL|{international}")
    print(f"E164|{e164}")
    print(f"COUNTRY_CODE|{phone.country_code}")
    print(f"NATIONAL_NUMBER|{phone.national_number}")
    
except ImportError:
    print("ERROR|phonenumbers module not installed")
except Exception as e:
    print(f"ERROR|{str(e)}")
PYEOF

    local phone_analysis=$(python3 << 'PYEOF2' 2>/dev/null
import sys
try:
    import phonenumbers
    from phonenumbers import geocoder, carrier, timezone
    phone = phonenumbers.parse("'"$target_phone"'", None)
    valid = phonenumbers.is_valid_number(phone)
    possible = phonenumbers.is_possible_number(phone)
    num_type = phonenumbers.number_type(phone)
    type_names = {0:"Fixed Line",1:"Mobile",2:"Fixed/Mobile",3:"Toll Free",4:"Premium",5:"Shared Cost",6:"VoIP",7:"Personal",8:"Pager",-1:"Unknown"}
    country = geocoder.description_for_number(phone, "en")
    carrier_name = carrier.name_for_number(phone, "en")
    tz = timezone.time_zones_for_number(phone)
    national = phonenumbers.format_number(phone, phonenumbers.PhoneNumberFormat.NATIONAL)
    international = phonenumbers.format_number(phone, phonenumbers.PhoneNumberFormat.INTERNATIONAL)
    e164 = phonenumbers.format_number(phone, phonenumbers.PhoneNumberFormat.E164)
    print(f"Valid: {valid}")
    print(f"Possible: {possible}")
    print(f"Type: {type_names.get(num_type, 'Unknown')}")
    print(f"Country: {country}")
    print(f"Carrier: {carrier_name}")
    print(f"Timezone: {', '.join(tz)}")
    print(f"National: {national}")
    print(f"International: {international}")
    print(f"E.164: {e164}")
    print(f"Country Code: +{phone.country_code}")
except Exception as e:
    print(f"Error: {e}")
PYEOF2
)
    
    if [ -n "$phone_analysis" ]; then
        echo "$phone_analysis" | while IFS=': ' read -r label value; do
            print_result "$label" "$value"
        done
    fi
    
    # NumVerify API
    if [ -n "$NUMVERIFY_API_KEY" ]; then
        separator
        print_info "NumVerify API Data"
        separator
        
        local clean_phone=$(echo "$target_phone" | tr -d '+- ()')
        local nv_data=$(safe_curl "http://apilayer.net/api/validate?access_key=${NUMVERIFY_API_KEY}&number=${clean_phone}")
        if [ -n "$nv_data" ]; then
            print_result "Valid" "$(json_extract "$nv_data" "valid")"
            print_result "Local Format" "$(json_extract "$nv_data" "local_format")"
            print_result "International" "$(json_extract "$nv_data" "international_format")"
            print_result "Country" "$(json_extract "$nv_data" "country_name")"
            print_result "Location" "$(json_extract "$nv_data" "location")"
            print_result "Carrier" "$(json_extract "$nv_data" "carrier")"
            print_result "Line Type" "$(json_extract "$nv_data" "line_type")"
        fi
    fi
    
    # Social media lookup hints
    separator
    print_info "Social Media Lookup Hints"
    separator
    
    local clean_num=$(echo "$target_phone" | tr -d '+-() ')
    echo -e "  ${CYAN}→${WHITE} WhatsApp: https://wa.me/${clean_num}${RESET}"
    echo -e "  ${CYAN}→${WHITE} Telegram: Search in app with number${RESET}"
    echo -e "  ${CYAN}→${WHITE} Truecaller: https://www.truecaller.com/search/${clean_num}${RESET}"
    echo -e "  ${CYAN}→${WHITE} Sync.me: https://sync.me/search/?number=${clean_num}${RESET}"
    echo -e "  ${CYAN}→${WHITE} CallerID: https://calleridtest.com/number/${clean_num}${RESET}"
    
    separator
    print_success "Phone intelligence report saved to: $result_file"
    
    echo ""
    read -p "  Press Enter to continue..."
}

#============================================================================
# MODULE 6: WEBSITE ANALYSIS
#============================================================================
website_analysis() {
    print_section "WEBSITE ANALYSIS"
    echo -ne "  ${WHITE}Enter target URL (https://example.com): ${CYAN}"
    read -r target_url
    echo -e "${RESET}"
    
    if ! validate_url "$target_url"; then
        target_url="https://${target_url}"
    fi
    
    local domain=$(echo "$target_url" | sed -e 's|https\?://||' -e 's|/.*||' -e 's|:.*||')
    local result_file="$OUTPUT_DIR/web/${domain}_$(date +%Y%m%d_%H%M%S).txt"
    
    echo "========================================" > "$result_file"
    echo "WEBSITE ANALYSIS REPORT" >> "$result_file"
    echo "Target: $target_url" >> "$result_file"
    echo "Date: $(date)" >> "$result_file"
    echo "========================================" >> "$result_file"
    
    # 1. HTTP Headers Analysis
    separator
    print_info "HTTP Response Headers"
    separator
    
    local full_headers=$(safe_curl -D - -o /dev/null "$target_url")
    echo "$full_headers" | while IFS= read -r line; do
        line=$(echo "$line" | tr -d '\r')
        [ -n "$line" ] && echo -e "    ${GRAY}$line${RESET}"
    done
    echo -e "\n[HTTP HEADERS]\n$full_headers" >> "$result_file"
    
    # 2. Technology Stack
    separator
    print_info "Technology Stack Detection"
    separator
    
    local page_source=$(safe_curl "$target_url")
    
    if [ -n "$page_source" ]; then
        # CMS Detection
        echo "$page_source" | grep -qi "wp-content\|wordpress" && print_result "CMS" "WordPress"
        echo "$page_source" | grep -qi "joomla" && print_result "CMS" "Joomla"
        echo "$page_source" | grep -qi "drupal" && print_result "CMS" "Drupal"
        echo "$page_source" | grep -qi "shopify" && print_result "CMS" "Shopify"
        echo "$page_source" | grep -qi "wix\.com" && print_result "CMS" "Wix"
        echo "$page_source" | grep -qi "squarespace" && print_result "CMS" "Squarespace"
        echo "$page_source" | grep -qi "magento" && print_result "CMS" "Magento"
        echo "$page_source" | grep -qi "ghost" && print_result "CMS" "Ghost"
        echo "$page_source" | grep -qi "webflow" && print_result "CMS" "Webflow"
        
        # JS Frameworks
        echo "$page_source" | grep -qi "react\|__NEXT_DATA__\|_next" && print_result "Framework" "React/Next.js"
        echo "$page_source" | grep -qi "vue\|__vue__" && print_result "Framework" "Vue.js"
        echo "$page_source" | grep -qi "angular\|ng-" && print_result "Framework" "Angular"
        echo "$page_source" | grep -qi "svelte" && print_result "Framework" "Svelte"
        echo "$page_source" | grep -qi "ember" && print_result "Framework" "Ember.js"
        
        # Libraries
        echo "$page_source" | grep -qi "jquery" && print_result "Library" "jQuery"
        echo "$page_source" | grep -qi "bootstrap" && print_result "Library" "Bootstrap"
        echo "$page_source" | grep -qi "tailwind" && print_result "Library" "Tailwind CSS"
        echo "$page_source" | grep -qi "font-awesome\|fontawesome" && print_result "Library" "Font Awesome"
        
        # Analytics
        echo "$page_source" | grep -qi "google-analytics\|gtag\|GA-\|G-" && print_result "Analytics" "Google Analytics"
        echo "$page_source" | grep -qi "facebook.*pixel\|fbq" && print_result "Analytics" "Facebook Pixel"
        echo "$page_source" | grep -qi "hotjar" && print_result "Analytics" "Hotjar"
        echo "$page_source" | grep -qi "mixpanel" && print_result "Analytics" "Mixpanel"
        echo "$page_source" | grep -qi "segment" && print_result "Analytics" "Segment"
        
        # CDN
        echo "$page_source" | grep -qi "cloudflare" && print_result "CDN" "Cloudflare"
        echo "$page_source" | grep -qi "cloudfront" && print_result "CDN" "AWS CloudFront"
        echo "$page_source" | grep -qi "akamai" && print_result "CDN" "Akamai"
        echo "$page_source" | grep -qi "fastly" && print_result "CDN" "Fastly"
        
        # Extract Google Analytics ID
        local ga_id=$(echo "$page_source" | grep -oE "UA-[0-9]+-[0-9]+|G-[A-Z0-9]+" | head -1)
        [ -n "$ga_id" ] && print_result "GA ID" "$ga_id"
        
        # Meta information
        local title=$(echo "$page_source" | grep -oP '<title>\K[^<]+' | head -1)
        local description=$(echo "$page_source" | grep -oP 'name="description"[^>]*content="\K[^"]+' | head -1)
        local keywords=$(echo "$page_source" | grep -oP 'name="keywords"[^>]*content="\K[^"]+' | head -1)
        local generator=$(echo "$page_source" | grep -oP 'name="generator"[^>]*content="\K[^"]+' | head -1)
        
        print_result "Title" "$title"
        print_result "Description" "${description:0:100}"
        print_result "Keywords" "${keywords:0:100}"
        print_result "Generator" "$generator"
        
        # Extract internal/external links
        local internal_links=$(echo "$page_source" | grep -oP 'href="\K[^"]+' | grep -c "^/\|${domain}")
        local external_links=$(echo "$page_source" | grep -oP 'href="\K[^"]+' | grep -c "http" | head -1)
        print_result "Internal Links" "$internal_links"
        print_result "External Links" "$external_links"
        
        # Forms
        local form_count=$(echo "$page_source" | grep -ci "<form")
        local input_count=$(echo "$page_source" | grep -ci "<input")
        print_result "Forms Found" "$form_count"
        print_result "Input Fields" "$input_count"
        
        # Comments in source
        local comment_count=$(echo "$page_source" | grep -c "<!--")
        print_result "HTML Comments" "$comment_count"
        
        # Exposed emails
        local web_emails=$(echo "$page_source" | grep -oE '[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}' | sort -u)
        if [ -n "$web_emails" ]; then
            echo ""
            print_info "Emails found on page:"
            echo "$web_emails" | while IFS= read -r em; do
                echo -e "    ${GREEN}→${WHITE} $em${RESET}"
            done
        fi
    fi
    
    # 3. Sensitive Files Check
    separator
    print_info "Sensitive File Discovery"
    separator
    
    local sensitive_paths=(
        "/.git/config" "/.git/HEAD" "/.env" "/.env.local" "/.env.production"
        "/wp-config.php.bak" "/config.php.bak" "/.htaccess" "/.htpasswd"
        "/phpinfo.php" "/info.php" "/server-status" "/server-info"
        "/.DS_Store" "/Thumbs.db" "/crossdomain.xml" "/clientaccesspolicy.xml"
        "/sitemap.xml" "/robots.txt" "/humans.txt" "/security.txt"
        "/.well-known/security.txt" "/package.json" "/composer.json"
        "/Gruntfile.js" "/Gulpfile.js" "/webpack.config.js"
        "/backup.zip" "/backup.sql" "/dump.sql" "/db.sql"
        "/admin/" "/administrator/" "/login/" "/wp-admin/"
        "/phpmyadmin/" "/adminer.php" "/console/" "/debug/"
        "/api/" "/api/v1/" "/swagger.json" "/api-docs"
        "/graphql" "/graphiql" "/.svn/entries"
        "/web.config" "/elmah.axd" "/trace.axd"
        "/xmlrpc.php" "/wp-json/" "/wp-cron.php"
        "/Dockerfile" "/docker-compose.yml" "/.dockerignore"
        "/Makefile" "/Vagrantfile" "/Procfile"
        "/.bash_history" "/.ssh/id_rsa" "/id_rsa"
        "/error.log" "/access.log" "/debug.log"
    )
    
    local found_files=0
    for path in "${sensitive_paths[@]}"; do
        local check_url="${target_url}${path}"
        local status=$(curl -s -o /dev/null -w "%{http_code}" -L --max-time 5 \
            -H "User-Agent: $USER_AGENT" "$check_url" 2>/dev/null)
        
        if [ "$status" = "200" ]; then
            echo -e "  ${RED}[FOUND]${WHITE} $path ${RED}(HTTP 200)${RESET}"
            echo "[FOUND] $path (HTTP 200)" >> "$result_file"
            ((found_files++))
        elif [ "$status" = "403" ]; then
            echo -e "  ${YELLOW}[403]${WHITE}   $path ${YELLOW}(Forbidden - exists?)${RESET}"
            echo "[403] $path" >> "$result_file"
        fi
    done
    
    [ $found_files -eq 0 ] && print_info "No exposed sensitive files found"
    
    # 4. WAF Detection
    separator
    print_info "WAF (Web Application Firewall) Detection"
    separator
    
    local waf_headers=$(safe_curl -I "$target_url")
    
    echo "$waf_headers" | grep -qi "cloudflare" && print_result "WAF" "Cloudflare"
    echo "$waf_headers" | grep -qi "akamai" && print_result "WAF" "Akamai"
    echo "$waf_headers" | grep -qi "incapsula\|imperva" && print_result "WAF" "Imperva/Incapsula"
    echo "$waf_headers" | grep -qi "sucuri" && print_result "WAF" "Sucuri"
    echo "$waf_headers" | grep -qi "mod_security\|modsecurity" && print_result "WAF" "ModSecurity"
    echo "$waf_headers" | grep -qi "f5\|big-ip" && print_result "WAF" "F5 BIG-IP"
    echo "$waf_headers" | grep -qi "barracuda" && print_result "WAF" "Barracuda"
    echo "$waf_headers" | grep -qi "aws" && print_result "WAF" "AWS WAF"
    echo "$waf_headers" | grep -qi "ddos-guard" && print_result "WAF" "DDoS-Guard"
    
    # 5. BuiltWith API / WhatWeb
    if check_dependency "whatweb"; then
        separator
        print_info "WhatWeb Analysis"
        separator
        
        local whatweb_out=$(whatweb -a 3 "$target_url" 2>/dev/null)
        echo "$whatweb_out" | tr ',' '\n' | while IFS= read -r tech; do
            echo -e "    ${GRAY}$tech${RESET}"
        done
        echo -e "\n[WHATWEB]\n$whatweb_out" >> "$result_file"
    fi
    
    separator
    print_success "Website analysis report saved to: $result_file"
    
    echo ""
    read -p "  Press Enter to continue..."
}

#============================================================================
# MODULE 7: SOCIAL MEDIA INTELLIGENCE
#============================================================================
social_media_recon() {
    print_section "SOCIAL MEDIA INTELLIGENCE"
    echo -e "  ${WHITE}Select target type:${RESET}"
    echo -e "  ${CYAN}[1]${WHITE} Username across platforms${RESET}"
    echo -e "  ${CYAN}[2]${WHITE} Twitter/X deep analysis${RESET}"
    echo -e "  ${CYAN}[3]${WHITE} GitHub deep analysis${RESET}"
    echo -e "  ${CYAN}[4]${WHITE} Reddit user analysis${RESET}"
    echo ""
    echo -ne "  ${WHITE}Select option: ${CYAN}"
    read -r social_choice
    echo -e "${RESET}"
    
    case $social_choice in
        1) username_recon ;;
        2)
            echo -ne "  ${WHITE}Enter Twitter/X username (without @): ${CYAN}"
            read -r tw_user
            echo -e "${RESET}"
            
            separator
            print_info "Twitter/X Analysis for @${tw_user}"
            separator
            
            # Basic profile scraping
            local tw_page=$(safe_curl "https://nitter.net/${tw_user}")
            if [ -n "$tw_page" ]; then
                local tw_bio=$(echo "$tw_page" | grep -oP 'class="profile-bio"[^>]*>\K[^<]+' | head -1)
                local tw_location=$(echo "$tw_page" | grep -oP 'class="profile-location"[^>]*>\K[^<]+' | head -1)
                local tw_website=$(echo "$tw_page" | grep -oP 'class="profile-website"[^>]*>[^<]*<a[^>]*>\K[^<]+' | head -1)
                local tw_joined=$(echo "$tw_page" | grep -oP 'class="profile-joindate"[^>]*>[^<]*<span[^>]*>\K[^<]+' | head -1)
                
                print_result "Bio" "$tw_bio"
                print_result "Location" "$tw_location"
                print_result "Website" "$tw_website"
                print_result "Joined" "$tw_joined"
            fi
            
            echo -e "\n  ${CYAN}Direct links:${RESET}"
            echo -e "  ${GREEN}→${WHITE} Profile: https://x.com/${tw_user}${RESET}"
            echo -e "  ${GREEN}→${WHITE} Nitter: https://nitter.net/${tw_user}${RESET}"
            echo -e "  ${GREEN}→${WHITE} Archive: https://web.archive.org/web/*/twitter.com/${tw_user}${RESET}"
            echo -e "  ${GREEN}→${WHITE} Analytics: https://socialblade.com/twitter/user/${tw_user}${RESET}"
            ;;
        3)
            echo -ne "  ${WHITE}Enter GitHub username: ${CYAN}"
            read -r gh_user
            echo -e "${RESET}"
            
            separator
            print_info "GitHub Deep Analysis for ${gh_user}"
            separator
            
            local gh_data=$(safe_curl "https://api.github.com/users/${gh_user}")
            if [ -n "$gh_data" ] && [[ "$gh_data" != *"Not Found"* ]]; then
                print_result "Name" "$(json_extract "$gh_data" "name")"
                print_result "Bio" "$(json_extract "$gh_data" "bio")"
                print_result "Company" "$(json_extract "$gh_data" "company")"
                print_result "Location" "$(json_extract "$gh_data" "location")"
                print_result "Blog" "$(json_extract "$gh_data" "blog")"
                print_result "Twitter" "$(json_extract "$gh_data" "twitter_username")"
                print_result "Public Repos" "$(json_extract "$gh_data" "public_repos")"
                print_result "Followers" "$(json_extract "$gh_data" "followers")"
                print_result "Following" "$(json_extract "$gh_data" "following")"
                print_result "Created" "$(json_extract "$gh_data" "created_at")"
                print_result "Updated" "$(json_extract "$gh_data" "updated_at")"
                
                # Language statistics
                separator
                print_info "Language Usage:"
                local repos_data=$(safe_curl "https://api.github.com/users/${gh_user}/repos?per_page=100")
                echo "$repos_data" | python3 -c "
import sys, json
try:
    repos = json.load(sys.stdin)
    langs = {}
    for r in repos:
        lang = r.get('language')
        if lang:
            langs[lang] = langs.get(lang, 0) + 1
    for lang, count in sorted(langs.items(), key=lambda x: x[1], reverse=True)[:15]:
        bar = '█' * count
        print(f'{lang}|{count}|{bar}')
except:
    pass
" 2>/dev/null | while IFS='|' read -r lang count bar; do
                    printf "    ${CYAN}%-15s${WHITE} %3s repos ${GREEN}%s${RESET}\n" "$lang" "$count" "$bar"
                done
                
                # Contribution calendar (via events)
                separator
                print_info "Recent Activity:"
                local events=$(safe_curl "https://api.github.com/users/${gh_user}/events?per_page=15")
                echo "$events" | python3 -c "
import sys, json
try:
    events = json.load(sys.stdin)
    for e in events[:15]:
        etype = e.get('type', 'Unknown')
        repo = e.get('repo', {}).get('name', 'N/A')
        created = e.get('created_at', 'N/A')[:10]
        print(f'{created}|{etype}|{repo}')
except:
    pass
" 2>/dev/null | while IFS='|' read -r date etype repo; do
                    echo -e "    ${GRAY}$date${WHITE} $etype ${CYAN}→ $repo${RESET}"
                done
                
                # Organizations
                local orgs=$(safe_curl "https://api.github.com/users/${gh_user}/orgs")
                if [ -n "$orgs" ] && [ "$orgs" != "[]" ]; then
                    separator
                    print_info "Organizations:"
                    echo "$orgs" | python3 -c "
import sys, json
try:
    orgs = json.load(sys.stdin)
    for o in orgs:
        print(f'{o.get(\"login\", \"N/A\")}|{o.get(\"description\", \"\")}')
except:
    pass
" 2>/dev/null | while IFS='|' read -r org_name org_desc; do
                        echo -e "    ${GREEN}→${WHITE} $org_name ${GRAY}$org_desc${RESET}"
                    done
                fi
            fi
            ;;
        4)
            echo -ne "  ${WHITE}Enter Reddit username (without u/): ${CYAN}"
            read -r reddit_user
            echo -e "${RESET}"
            
            separator
            print_info "Reddit Analysis for u/${reddit_user}"
            separator
            
            local reddit_about=$(safe_curl "https://www.reddit.com/user/${reddit_user}/about.json" \
                -H "User-Agent: OSINT-Tool/1.0")
            
            if [ -n "$reddit_about" ] && [[ "$reddit_about" != *"error"* ]]; then
                print_result "Name" "$(json_extract "$reddit_about" "data.name")"
                print_result "Link Karma" "$(json_extract "$reddit_about" "data.link_karma")"
                print_result "Comment Karma" "$(json_extract "$reddit_about" "data.comment_karma")"
                print_result "Total Karma" "$(json_extract "$reddit_about" "data.total_karma")"
                
                local created_utc=$(json_extract "$reddit_about" "data.created_utc")
                if [ "$created_utc" != "N/A" ]; then
                    local created_date=$(date -d @"${created_utc%.*}" '+%Y-%m-%d' 2>/dev/null || echo "$created_utc")
                    print_result "Account Created" "$created_date"
                fi
                
                print_result "Has Gold" "$(json_extract "$reddit_about" "data.is_gold")"
                print_result "Is Mod" "$(json_extract "$reddit_about" "data.is_mod")"
                print_result "Verified" "$(json_extract "$reddit_about" "data.has_verified_email")"
                print_result "Icon" "$(json_extract "$reddit_about" "data.icon_img")"
                
                # Recent posts
                separator
                print_info "Recent Activity:"
                local reddit_posts=$(safe_curl "https://www.reddit.com/user/${reddit_user}.json?limit=10" \
                    -H "User-Agent: OSINT-Tool/1.0")
                echo "$reddit_posts" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    for post in data.get('data', {}).get('children', [])[:10]:
        p = post.get('data', {})
        sub = p.get('subreddit', 'N/A')
        title = p.get('title', p.get('body', 'Comment'))[:60]
        score = p.get('score', 0)
        print(f'r/{sub}|{score}|{title}')
except:
    pass
" 2>/dev/null | while IFS='|' read -r sub score title; do
                    echo -e "    ${CYAN}$sub${WHITE} (⬆$score) $title${RESET}"
                done
            fi
            ;;
    esac
    
    echo ""
    read -p "  Press Enter to continue..."
}

#============================================================================
# MODULE 8: IMAGE / METADATA ANALYSIS
#============================================================================
image_analysis() {
    print_section "IMAGE & METADATA ANALYSIS"
    echo -e "  ${WHITE}Select option:${RESET}"
    echo -e "  ${CYAN}[1]${WHITE} Analyze image from URL${RESET}"
    echo -e "  ${CYAN}[2]${WHITE} Analyze local image file${RESET}"
    echo -e "  ${CYAN}[3]${WHITE} Reverse image search links${RESET}"
    echo ""
    echo -ne "  ${WHITE}Select option: ${CYAN}"
    read -r img_choice
    echo -e "${RESET}"
    
    case $img_choice in
        1)
            echo -ne "  ${WHITE}Enter image URL: ${CYAN}"
            read -r img_url
            echo -e "${RESET}"
            
            local img_file="$TEMP_DIR/analyzed_image_$(date +%s)"
            wget -q -O "$img_file" "$img_url" 2>/dev/null
            
            if [ -f "$img_file" ]; then
                separator
                print_info "Image Metadata (EXIF)"
                separator
                
                python3 << PYEOF 2>/dev/null
try:
    import exifread
    with open("$img_file", 'rb') as f:
        tags = exifread.process_file(f, details=True)
        if tags:
            important_tags = [
                'Image Make', 'Image Model', 'Image Software',
                'EXIF DateTimeOriginal', 'EXIF DateTimeDigitized',
                'GPS GPSLatitude', 'GPS GPSLongitude', 'GPS GPSAltitude',
                'GPS GPSLatitudeRef', 'GPS GPSLongitudeRef',
                'EXIF ExifImageWidth', 'EXIF ExifImageLength',
                'EXIF ISOSpeedRatings', 'EXIF FocalLength',
                'EXIF ExposureTime', 'EXIF FNumber',
                'Image XResolution', 'Image YResolution',
                'EXIF Flash', 'EXIF LensModel', 'EXIF WhiteBalance',
                'Image Copyright', 'Image Artist', 'Image ImageDescription'
            ]
            for tag in important_tags:
                if tag in tags:
                    print(f"{tag}: {tags[tag]}")
            
            # Check for GPS
            if 'GPS GPSLatitude' in tags and 'GPS GPSLongitude' in tags:
                lat = tags['GPS GPSLatitude']
                lon = tags['GPS GPSLongitude']
                lat_ref = str(tags.get('GPS GPSLatitudeRef', 'N'))
                lon_ref = str(tags.get('GPS GPSLongitudeRef', 'E'))
                print(f"\nGPS COORDINATES FOUND!")
                print(f"Latitude: {lat} {lat_ref}")
                print(f"Longitude: {lon} {lon_ref}")
                print(f"Google Maps: https://maps.google.com/?q={lat},{lon}")
        else:
            print("No EXIF data found in image")
except ImportError:
    print("exifread module not available")
except Exception as e:
    print(f"Error: {e}")
PYEOF
                
                # File info
                separator
                print_info "File Information"
                separator
                
                local file_size=$(stat -f%z "$img_file" 2>/dev/null || stat -c%s "$img_file" 2>/dev/null)
                local file_type=$(file -b "$img_file" 2>/dev/null)
                local file_md5=$(md5sum "$img_file" 2>/dev/null | cut -d' ' -f1)
                local file_sha256=$(sha256sum "$img_file" 2>/dev/null | cut -d' ' -f1)
                
                print_result "File Size" "${file_size} bytes"
                print_result "File Type" "$file_type"
                print_result "MD5 Hash" "$file_md5"
                print_result "SHA256 Hash" "$file_sha256"
                
                # Hidden strings
                separator
                print_info "Embedded Strings"
                separator
                strings "$img_file" 2>/dev/null | grep -E "http|www|@|copyright|author|gps|location" | head -20 | while IFS= read -r str; do
                    echo -e "    ${GRAY}$str${RESET}"
                done
                
                rm -f "$img_file"
            fi
            ;;
        2)
            echo -ne "  ${WHITE}Enter file path: ${CYAN}"
            read -r local_file
            echo -e "${RESET}"
            
            if [ -f "$local_file" ]; then
                python3 << PYEOF2 2>/dev/null
try:
    import exifread
    with open("$local_file", 'rb') as f:
        tags = exifread.process_file(f, details=True)
        for tag, value in sorted(tags.items()):
            if tag not in ('JPEGThumbnail', 'TIFFThumbnail', 'Filename'):
                print(f"{tag}: {value}")
except ImportError:
    print("exifread module not available. Install: pip install exifread")
except Exception as e:
    print(f"Error: {e}")
PYEOF2
            else
                print_error "File not found: $local_file"
            fi
            ;;
        3)
            echo -ne "  ${WHITE}Enter image URL for reverse search: ${CYAN}"
            read -r rev_url
            echo -e "${RESET}"
            
            separator
            print_info "Reverse Image Search Links"
            separator
            
            local encoded_url=$(python3 -c "import urllib.parse; print(urllib.parse.quote('$rev_url', safe=''))" 2>/dev/null)
            
            echo -e "  ${GREEN}→${WHITE} Google: https://lens.google.com/uploadbyurl?url=${encoded_url}${RESET}"
            echo -e "  ${GREEN}→${WHITE} TinEye: https://tineye.com/search?url=${encoded_url}${RESET}"
            echo -e "  ${GREEN}→${WHITE} Yandex: https://yandex.com/images/search?rpt=imageview&url=${encoded_url}${RESET}"
            echo -e "  ${GREEN}→${WHITE} Bing: https://www.bing.com/images/search?view=detailv2&iss=sbi&q=imgurl:${encoded_url}${RESET}"
            echo -e "  ${GREEN}→${WHITE} Baidu: https://graph.baidu.com/details?isfromtus498=1&app=0&image=${encoded_url}${RESET}"
            ;;
    esac
    
    echo ""
    read -p "  Press Enter to continue..."
}

#============================================================================
# MODULE 9: NETWORK TOOLS
#============================================================================
network_tools() {
    print_section "NETWORK TOOLS"
    echo -e "  ${CYAN}[1]${WHITE}  Ping Sweep${RESET}"
    echo -e "  ${CYAN}[2]${WHITE}  Network Scanner${RESET}"
    echo -e "  ${CYAN}[3]${WHITE}  Traceroute Analysis${RESET}"
    echo -e "  ${CYAN}[4]${WHITE}  DNS Zone Transfer Test${RESET}"
    echo -e "  ${CYAN}[5]${WHITE}  SSL Certificate Check${RESET}"
    echo -e "  ${CYAN}[6]${WHITE}  HTTP Methods Test${RESET}"
    echo -e "  ${CYAN}[7]${WHITE}  Subnet Calculator${RESET}"
    echo -e "  ${CYAN}[8]${WHITE}  MAC Address Lookup${RESET}"
    echo -e "  ${CYAN}[9]${WHITE}  My IP Information${RESET}"
    echo -e "  ${CYAN}[10]${WHITE} DNS Resolver Test${RESET}"
    echo ""
    echo -ne "  ${WHITE}Select option: ${CYAN}"
    read -r net_choice
    echo -e "${RESET}"
    
    case $net_choice in
        1)
            echo -ne "  ${WHITE}Enter network (e.g., 192.168.1.0/24): ${CYAN}"
            read -r network
            echo -e "${RESET}"
            
            separator
            print_info "Ping Sweep on $network"
            separator
            
            local base=$(echo "$network" | cut -d/ -f1 | cut -d. -f1-3)
            local alive=0
            
            for i in $(seq 1 254); do
                (ping -c 1 -W 1 "${base}.${i}" &>/dev/null && \
                    echo -e "  ${GREEN}[ALIVE]${WHITE} ${base}.${i}${RESET}" && \
                    ((alive++))) &
                
                # Limit concurrent pings
                [ $(jobs -r | wc -l) -ge 50 ] && wait -n
            done
            wait
            
            echo ""
            print_success "Sweep complete. $alive hosts alive."
            ;;
        2)
            echo -ne "  ${WHITE}Enter target IP or range: ${CYAN}"
            read -r scan_target
            echo -e "${RESET}"
            
            if check_dependency "nmap"; then
                separator
                print_info "Network Scan Results"
                separator
                
                echo -e "  ${WHITE}Scan type:${RESET}"
                echo -e "  ${CYAN}[1]${WHITE} Quick scan (top 100 ports)${RESET}"
                echo -e "  ${CYAN}[2]${WHITE} Full scan (all ports)${RESET}"
                echo -e "  ${CYAN}[3]${WHITE} Service version detection${RESET}"
                echo -e "  ${CYAN}[4]${WHITE} OS detection${RESET}"
                echo -e "  ${CYAN}[5]${WHITE} Vulnerability scan${RESET}"
                echo -ne "  ${WHITE}Choice: ${CYAN}"
                read -r scan_type
                echo -e "${RESET}"
                
                case $scan_type in
                    1) nmap -T4 --top-ports 100 "$scan_target" 2>/dev/null ;;
                    2) nmap -T4 -p- "$scan_target" 2>/dev/null ;;
                    3) nmap -sV -T4 --top-ports 1000 "$scan_target" 2>/dev/null ;;
                    4) nmap -O -T4 "$scan_target" 2>/dev/null ;;
                    5) nmap -sV --script vuln -T4 "$scan_target" 2>/dev/null ;;
                    *) nmap -T4 "$scan_target" 2>/dev/null ;;
                esac
            else
                print_error "nmap not installed"
            fi
            ;;
        3)
            echo -ne "  ${WHITE}Enter target: ${CYAN}"
            read -r trace_target
            echo -e "${RESET}"
            
            separator
            print_info "Traceroute to $trace_target"
            separator
            
            traceroute -m 30 "$trace_target" 2>/dev/null
            ;;
        4)
            echo -ne "  ${WHITE}Enter domain: ${CYAN}"
            read -r zone_domain
            echo -e "${RESET}"
            
            separator
            print_info "DNS Zone Transfer Test for $zone_domain"
            separator
            
            local ns_servers=$(dig +short NS "$zone_domain" 2>/dev/null)
            echo "$ns_servers" | while IFS= read -r ns; do
                ns=$(echo "$ns" | sed 's/\.$//')
                print_info "Testing NS: $ns"
                local axfr_result=$(dig @"$ns" "$zone_domain" AXFR 2>/dev/null)
                if echo "$axfr_result" | grep -q "XFR size"; then
                    print_warning "Zone transfer ALLOWED on $ns!"
                    echo "$axfr_result"
                else
                    print_success "Zone transfer denied on $ns"
                fi
            done
            ;;
        5)
            echo -ne "  ${WHITE}Enter domain: ${CYAN}"
            read -r ssl_domain
            echo -e "${RESET}"
            
            separator
            print_info "SSL/TLS Certificate Analysis for $ssl_domain"
            separator
            
            echo | openssl s_client -connect "${ssl_domain}:443" -servername "$ssl_domain" 2>/dev/null | openssl x509 -noout -text 2>/dev/null
            
            separator
            print_info "SSL/TLS Protocol Support"
            separator
            
            for proto in tls1 tls1_1 tls1_2 tls1_3; do
                if echo | openssl s_client -connect "${ssl_domain}:443" -"$proto" 2>/dev/null | grep -q "CONNECTED"; then
                    echo -e "  ${GREEN}[✓]${WHITE} $proto: ${GREEN}Supported${RESET}"
                else
                    echo -e "  ${RED}[✗]${WHITE} $proto: ${RED}Not supported${RESET}"
                fi
            done
            ;;
        6)
            echo -ne "  ${WHITE}Enter URL: ${CYAN}"
            read -r methods_url
            echo -e "${RESET}"
            
            separator
            print_info "HTTP Methods Test for $methods_url"
            separator
            
            local methods=("GET" "POST" "PUT" "DELETE" "PATCH" "OPTIONS" "HEAD" "TRACE" "CONNECT")
            for method in "${methods[@]}"; do
                local code=$(curl -s -o /dev/null -w "%{http_code}" -X "$method" --max-time 5 "$methods_url" 2>/dev/null)
                if [ "$code" != "000" ] && [ "$code" != "405" ]; then
                    echo -e "  ${GREEN}[${code}]${WHITE} $method${RESET}"
                else
                    echo -e "  ${RED}[${code}]${WHITE} $method${RESET}"
                fi
            done
            ;;
        7)
            echo -ne "  ${WHITE}Enter IP/CIDR (e.g., 192.168.1.0/24): ${CYAN}"
            read -r subnet_input
            echo -e "${RESET}"
            
            separator
            print_info "Subnet Calculator"
            separator
            
            python3 << PYEOF 2>/dev/null
import ipaddress
try:
    net = ipaddress.ip_network("$subnet_input", strict=False)
    print(f"Network Address: {net.network_address}")
    print(f"Broadcast Address: {net.broadcast_address}")
    print(f"Netmask: {net.netmask}")
    print(f"Wildcard: {net.hostmask}")
    print(f"CIDR: /{net.prefixlen}")
    print(f"Total Addresses: {net.num_addresses}")
    print(f"Usable Hosts: {max(0, net.num_addresses - 2)}")
    print(f"First Host: {list(net.hosts())[0] if net.num_addresses > 2 else 'N/A'}")
    print(f"Last Host: {list(net.hosts())[-1] if net.num_addresses > 2 else 'N/A'}")
    print(f"Is Private: {net.is_private}")
    print(f"Version: IPv{net.version}")
except Exception as e:
    print(f"Error: {e}")
PYEOF
            ;;
        8)
            echo -ne "  ${WHITE}Enter MAC address (e.g., AA:BB:CC:DD:EE:FF): ${CYAN}"
            read -r mac_addr
            echo -e "${RESET}"
            
            separator
            print_info "MAC Address Lookup"
            separator
            
            local mac_prefix=$(echo "$mac_addr" | tr -d ':.-' | head -c 6 | tr '[:lower:]' '[:upper:]')
            local mac_lookup=$(safe_curl "https://api.macvendors.com/$(echo $mac_addr | tr -d ' ')")
            
            print_result "MAC Address" "$mac_addr"
            print_result "OUI Prefix" "$mac_prefix"
            print_result "Vendor" "$mac_lookup"
            ;;
        9)
            separator
            print_info "Your IP Information"
            separator
            
            local my_ip=$(safe_curl "https://api.ipify.org")
            local my_ip_info=$(safe_curl "http://ip-api.com/json/${my_ip}?fields=66846719")
            
            print_result "Public IP" "$my_ip"
            print_result "Country" "$(json_extract "$my_ip_info" "country")"
            print_result "Region" "$(json_extract "$my_ip_info" "regionName")"
            print_result "City" "$(json_extract "$my_ip_info" "city")"
            print_result "ISP" "$(json_extract "$my_ip_info" "isp")"
            print_result "Organization" "$(json_extract "$my_ip_info" "org")"
            print_result "AS" "$(json_extract "$my_ip_info" "as")"
            print_result "Timezone" "$(json_extract "$my_ip_info" "timezone")"
            print_result "Proxy" "$(json_extract "$my_ip_info" "proxy")"
            print_result "Mobile" "$(json_extract "$my_ip_info" "mobile")"
            print_result "Hosting" "$(json_extract "$my_ip_info" "hosting")"
            
            # IPv6
            local my_ipv6=$(safe_curl "https://api6.ipify.org" 2>/dev/null)
            [ -n "$my_ipv6" ] && print_result "IPv6" "$my_ipv6"
            
            # DNS leak check
            local dns_server=$(safe_curl "https://1.1.1.1/cdn-cgi/trace" | grep "ip=" | cut -d= -f2)
            print_result "DNS Resolver" "$dns_server"
            ;;
        10)
            echo -ne "  ${WHITE}Enter domain to resolve: ${CYAN}"
            read -r resolve_domain
            echo -e "${RESET}"
            
            separator
            print_info "DNS Resolution Test"
            separator
            
            local resolvers=(
                "8.8.8.8|Google DNS"
                "8.8.4.4|Google DNS Alt"
                "1.1.1.1|Cloudflare"
                "1.0.0.1|Cloudflare Alt"
                "9.9.9.9|Quad9"
                "208.67.222.222|OpenDNS"
                "208.67.220.220|OpenDNS Alt"
                "76.76.2.0|Control D"
                "94.140.14.14|AdGuard"
            )
            
            for resolver in "${resolvers[@]}"; do
                local ip=$(echo "$resolver" | cut -d'|' -f1)
                local name=$(echo "$resolver" | cut -d'|' -f2)
                local result=$(dig +short @"$ip" "$resolve_domain" A 2>/dev/null | head -1)
                local query_time=$(dig @"$ip" "$resolve_domain" A 2>/dev/null | grep "Query time" | awk '{print $4}')
                printf "  ${GREEN}→${WHITE} %-20s %-16s %-20s ${GRAY}(%s ms)${RESET}\n" "$name" "$ip" "${result:-NXDOMAIN}" "${query_time:-N/A}"
            done
            ;;
    esac
    
    echo ""
    read -p "  Press Enter to continue..."
}

#============================================================================
# MODULE 10: DARK WEB & PASTE SEARCH
#============================================================================
darkweb_paste_search() {
    print_section "DARK WEB & PASTE MONITORING"
    echo -e "  ${CYAN}[1]${WHITE} Search paste sites for keyword${RESET}"
    echo -e "  ${CYAN}[2]${WHITE} Check .onion site status${RESET}"
    echo -e "  ${CYAN}[3]${WHITE} Threat intelligence feeds${RESET}"
    echo -e "  ${CYAN}[4]${WHITE} Data leak check${RESET}"
    echo ""
    echo -ne "  ${WHITE}Select option: ${CYAN}"
    read -r dark_choice
    echo -e "${RESET}"
    
    case $dark_choice in
        1)
            echo -ne "  ${WHITE}Enter search keyword: ${CYAN}"
            read -r search_keyword
            echo -e "${RESET}"
            
            separator
            print_info "Paste Site Search for: $search_keyword"
            separator
            
            # Pastebin scraping (via Google dork style)
            print_info "Search these URLs manually:"
            echo -e "  ${GREEN}→${WHITE} Pastebin: https://pastebin.com/search?q=${search_keyword}${RESET}"
            echo -e "  ${GREEN}→${WHITE} GitHub: https://github.com/search?q=${search_keyword}&type=code${RESET}"
            echo -e "  ${GREEN}→${WHITE} GitLab: https://gitlab.com/search?search=${search_keyword}${RESET}"
            echo -e "  ${GREEN}→${WHITE} Ghostbin: https://ghostbin.com/search?q=${search_keyword}${RESET}"
            echo -e "  ${GREEN}→${WHITE} IntelX: https://intelx.io/?s=${search_keyword}${RESET}"
            echo -e "  ${GREEN}→${WHITE} Grep.app: https://grep.app/search?q=${search_keyword}${RESET}"
            echo -e "  ${GREEN}→${WHITE} SearchCode: https://searchcode.com/?q=${search_keyword}${RESET}"
            echo -e "  ${GREEN}→${WHITE} PublicWWW: https://publicwww.com/websites/${search_keyword}/${RESET}"
            echo -e "  ${GREEN}→${WHITE} Archive.org: https://archive.org/search?query=${search_keyword}${RESET}"
            
            # Google Dorks for pastes
            separator
            print_info "Google Dorks:"
            echo -e "  ${YELLOW}→${WHITE} site:pastebin.com \"${search_keyword}\"${RESET}"
            echo -e "  ${YELLOW}→${WHITE} site:github.com \"${search_keyword}\" password${RESET}"
            echo -e "  ${YELLOW}→${WHITE} site:trello.com \"${search_keyword}\"${RESET}"
            echo -e "  ${YELLOW}→${WHITE} site:justpaste.it \"${search_keyword}\"${RESET}"
            echo -e "  ${YELLOW}→${WHITE} site:codepad.co \"${search_keyword}\"${RESET}"
            ;;
        2)
            echo -ne "  ${WHITE}Enter .onion address: ${CYAN}"
            read -r onion_addr
            echo -e "${RESET}"
            
            separator
            print_info "Checking .onion via Tor2web gateways"
            separator
            
            print_warning "Direct .onion access requires Tor. Using gateways:"
            echo -e "  ${GREEN}→${WHITE} https://${onion_addr%.onion}.onion.ws${RESET}"
            echo -e "  ${GREEN}→${WHITE} https://${onion_addr%.onion}.onion.ly${RESET}"
            echo -e "  ${GREEN}→${WHITE} https://${onion_addr%.onion}.onion.pet${RESET}"
            echo -e "  ${GREEN}→${WHITE} Ahmia search: https://ahmia.fi/search/?q=${onion_addr}${RESET}"
            ;;
        3)
            separator
            print_info "Threat Intelligence Feeds"
            separator
            
            echo -e "  ${CYAN}Free Threat Intelligence Sources:${RESET}"
            echo -e "  ${GREEN}→${WHITE} AlienVault OTX: https://otx.alienvault.com/${RESET}"
            echo -e "  ${GREEN}→${WHITE} URLhaus: https://urlhaus.abuse.ch/${RESET}"
            echo -e "  ${GREEN}→${WHITE} ThreatFox: https://threatfox.abuse.ch/${RESET}"
            echo -e "  ${GREEN}→${WHITE} Feodo Tracker: https://feodotracker.abuse.ch/${RESET}"
            echo -e "  ${GREEN}→${WHITE} MalwareBazaar: https://bazaar.abuse.ch/${RESET}"
            echo -e "  ${GREEN}→${WHITE} Phishtank: https://phishtank.org/${RESET}"
            echo -e "  ${GREEN}→${WHITE} C2 Intel: https://tracker.viriback.com/${RESET}"
            
            # Fetch recent threats from URLhaus
            separator
            print_info "Recent Malware URLs (URLhaus):"
            local urlhaus=$(safe_curl "https://urlhaus-api.abuse.ch/v1/urls/recent/" \
                -X POST -d "limit=10")
            echo "$urlhaus" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    for url_entry in data.get('urls', [])[:10]:
        url = url_entry.get('url', 'N/A')
        threat = url_entry.get('threat', 'N/A')
        status = url_entry.get('url_status', 'N/A')
        print(f'{status}|{threat}|{url[:80]}')
except:
    pass
" 2>/dev/null | while IFS='|' read -r status threat url; do
                echo -e "    ${RED}[$status]${WHITE} $threat: ${GRAY}$url${RESET}"
            done
            ;;
        4)
            echo -ne "  ${WHITE}Enter email or domain to check: ${CYAN}"
            read -r leak_target
            echo -e "${RESET}"
            
            separator
            print_info "Data Leak Check for: $leak_target"
            separator
            
            # Multiple leak check services
            echo -e "  ${CYAN}Check these services:${RESET}"
            echo -e "  ${GREEN}→${WHITE} Have I Been Pwned: https://haveibeenpwned.com/account/${leak_target}${RESET}"
            echo -e "  ${GREEN}→${WHITE} Firefox Monitor: https://monitor.firefox.com/${RESET}"
            echo -e "  ${GREEN}→${WHITE} DeHashed: https://dehashed.com/search?query=${leak_target}${RESET}"
            echo -e "  ${GREEN}→${WHITE} LeakPeek: https://leakpeek.com/search?query=${leak_target}${RESET}"
            echo -e "  ${GREEN}→${WHITE} IntelX: https://intelx.io/?s=${leak_target}${RESET}"
            echo -e "  ${GREEN}→${WHITE} Snusbase: https://snusbase.com/${RESET}"
            
            # Breach Directory API (free)
            local bd_result=$(safe_curl "https://breachdirectory.org/api/check/${leak_target}")
            if [ -n "$bd_result" ]; then
                print_result "Breach Directory" "$bd_result"
            fi
            ;;
    esac
    
    echo ""
    read -p "  Press Enter to continue..."
}

#============================================================================
# MODULE 11: GOOGLE DORKING
#============================================================================
google_dorking() {
    print_section "GOOGLE DORKING ENGINE"
    echo -ne "  ${WHITE}Enter target domain or keyword: ${CYAN}"
    read -r dork_target
    echo -e "${RESET}"
    
    separator
    print_info "Generated Google Dorks for: $dork_target"
    separator
    
    # Organized dork categories
    echo -e "\n  ${YELLOW}━━━ SENSITIVE FILES ━━━${RESET}"
    local file_dorks=(
        "site:${dork_target} filetype:pdf"
        "site:${dork_target} filetype:doc OR filetype:docx"
        "site:${dork_target} filetype:xls OR filetype:xlsx"
        "site:${dork_target} filetype:ppt OR filetype:pptx"
        "site:${dork_target} filetype:sql"
        "site:${dork_target} filetype:log"
        "site:${dork_target} filetype:bak"
        "site:${dork_target} filetype:conf OR filetype:cfg"
        "site:${dork_target} filetype:env"
        "site:${dork_target} filetype:xml"
        "site:${dork_target} filetype:json"
        "site:${dork_target} filetype:csv"
        "site:${dork_target} filetype:key OR filetype:pem"
    )
    for dork in "${file_dorks[@]}"; do
        echo -e "  ${GREEN}→${WHITE} $dork${RESET}"
    done
    
    echo -e "\n  ${YELLOW}━━━ CREDENTIALS & SECRETS ━━━${RESET}"
    local cred_dorks=(
        "site:${dork_target} intext:\"password\" OR intext:\"passwd\""
        "site:${dork_target} intext:\"username\" intext:\"password\""
        "site:${dork_target} inurl:login OR inurl:signin"
        "site:${dork_target} intitle:\"index of\" \"password\""
        "site:${dork_target} intext:\"api_key\" OR intext:\"apikey\""
        "site:${dork_target} intext:\"secret_key\" OR intext:\"access_key\""
        "site:${dork_target} intext:\"BEGIN RSA PRIVATE KEY\""
        "site:${dork_target} intext:\"AWS_SECRET_ACCESS_KEY\""
        "site:${dork_target} intext:\"DB_PASSWORD\" OR intext:\"DATABASE_URL\""
        "\"${dork_target}\" intext:\"token\" site:github.com"
        "\"${dork_target}\" intext:\"password\" site:pastebin.com"
    )
    for dork in "${cred_dorks[@]}"; do
        echo -e "  ${GREEN}→${WHITE} $dork${RESET}"
    done
    
    echo -e "\n  ${YELLOW}━━━ DIRECTORY LISTINGS ━━━${RESET}"
    local dir_dorks=(
        "site:${dork_target} intitle:\"index of /\""
        "site:${dork_target} intitle:\"index of\" \"parent directory\""
        "site:${dork_target} intitle:\"index of\" \"backup\""
        "site:${dork_target} intitle:\"index of\" \"admin\""
        "site:${dork_target} intitle:\"index of\" \".git\""
        "site:${dork_target} intitle:\"index of\" \"wp-content\""
    )
    for dork in "${dir_dorks[@]}"; do
        echo -e "  ${GREEN}→${WHITE} $dork${RESET}"
    done
    
    echo -e "\n  ${YELLOW}━━━ VULNERABLE PAGES ━━━${RESET}"
    local vuln_dorks=(
        "site:${dork_target} inurl:php?id="
        "site:${dork_target} inurl:page= OR inurl:file= OR inurl:path="
        "site:${dork_target} inurl:redirect= OR inurl:url= OR inurl:return="
        "site:${dork_target} inurl:cmd= OR inurl:exec= OR inurl:command="
        "site:${dork_target} inurl:admin OR inurl:administrator"
        "site:${dork_target} inurl:config OR inurl:setup OR inurl:install"
        "site:${dork_target} inurl:upload OR inurl:file-upload"
        "site:${dork_target} \"error\" OR \"warning\" OR \"syntax error\""
        "site:${dork_target} \"SQL syntax\" OR \"mysql_fetch\""
        "site:${dork_target} \"phpinfo()\" OR \"PHP Version\""
    )
    for dork in "${vuln_dorks[@]}"; do
        echo -e "  ${GREEN}→${WHITE} $dork${RESET}"
    done
    
    echo -e "\n  ${YELLOW}━━━ INFORMATION DISCLOSURE ━━━${RESET}"
    local info_dorks=(
        "site:${dork_target} intext:\"@${dork_target}\" OR intext:\"@gmail.com\""
        "site:${dork_target} intext:\"phone\" OR intext:\"contact\""
        "site:${dork_target} intext:\"confidential\" OR intext:\"internal\""
        "site:${dork_target} intext:\"not for distribution\" OR intext:\"proprietary\""
        "site:${dork_target} ext:xml | ext:conf | ext:cnf | ext:reg | ext:inf"
        "\"${dork_target}\" site:linkedin.com"
        "\"${dork_target}\" site:twitter.com OR site:x.com"
        "\"${dork_target}\" site:glassdoor.com"
    )
    for dork in "${info_dorks[@]}"; do
        echo -e "  ${GREEN}→${WHITE} $dork${RESET}"
    done
    
    echo -e "\n  ${YELLOW}━━━ CLOUD & STORAGE ━━━${RESET}"
    local cloud_dorks=(
        "site:s3.amazonaws.com \"${dork_target}\""
        "site:blob.core.windows.net \"${dork_target}\""
        "site:storage.googleapis.com \"${dork_target}\""
        "site:drive.google.com \"${dork_target}\""
        "site:docs.google.com \"${dork_target}\""
        "site:trello.com \"${dork_target}\""
        "site:notion.so \"${dork_target}\""
        "site:atlassian.net \"${dork_target}\""
    )
    for dork in "${cloud_dorks[@]}"; do
        echo -e "  ${GREEN}→${WHITE} $dork${RESET}"
    done
    
    echo ""
    separator
    print_info "Total dorks generated: $(( ${#file_dorks[@]} + ${#cred_dorks[@]} + ${#dir_dorks[@]} + ${#vuln_dorks[@]} + ${#info_dorks[@]} + ${#cloud_dorks[@]} ))"
    
    echo ""
    read -p "  Press Enter to continue..."
}

#============================================================================
# MODULE 12: REPORT GENERATOR
#============================================================================
generate_report() {
    print_section "REPORT GENERATOR"
    echo -e "  ${CYAN}[1]${WHITE} Generate HTML report from all results${RESET}"
    echo -e "  ${CYAN}[2]${WHITE} Export results to JSON${RESET}"
    echo -e "  ${CYAN}[3]${WHITE} View recent results${RESET}"
    echo -e "  ${CYAN}[4]${WHITE} Clean old results${RESET}"
    echo ""
    echo -ne "  ${WHITE}Select option: ${CYAN}"
    read -r report_choice
    echo -e "${RESET}"
    
    case $report_choice in
        1)
            local html_file="$REPORT_DIR/osint_report_$(date +%Y%m%d_%H%M%S).html"
            
            cat << 'HTMLHEAD' > "$html_file"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>OSINT-X Report</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Segoe UI', Tahoma, sans-serif; background: #0a0a1a; color: #e0e0e0; padding: 20px; }
        .container { max-width: 1200px; margin: 0 auto; }
        .header { background: linear-gradient(135deg, #1a1a2e, #16213e); padding: 30px; border-radius: 10px; margin-bottom: 20px; border: 1px solid #0f3460; }
        .header h1 { color: #00d4ff; font-size: 2em; }
        .header p { color: #888; margin-top: 5px; }
        .section { background: #1a1a2e; border-radius: 10px; padding: 20px; margin-bottom: 15px; border: 1px solid #2a2a4a; }
        .section h2 { color: #00d4ff; margin-bottom: 15px; border-bottom: 1px solid #2a2a4a; padding-bottom: 10px; }
        .result { padding: 8px 0; border-bottom: 1px solid #1a1a3a; }
        .result .label { color: #00d4ff; font-weight: bold; }
        .result .value { color: #e0e0e0; }
        pre { background: #0d0d1a; padding: 15px; border-radius: 5px; overflow-x: auto; font-size: 0.85em; color: #b0b0b0; }
        .timestamp { color: #666; font-size: 0.8em; }
        .found { color: #00ff88; }
        .warning { color: #ffaa00; }
        .danger { color: #ff4444; }
    </style>
</head>
<body>
<div class="container">
    <div class="header">
        <h1>🔍 OSINT-X Intelligence Report</h1>
        <p>Generated: TIMESTAMP_PLACEHOLDER</p>
    </div>
HTMLHEAD
            
            sed -i "s/TIMESTAMP_PLACEHOLDER/$(date '+%Y-%m-%d %H:%M:%S')/" "$html_file"
            
            # Add all result files
            for dir in domains ips emails usernames phones web network social; do
                local dir_path="$OUTPUT_DIR/$dir"
                if [ -d "$dir_path" ] && [ "$(ls -A $dir_path 2>/dev/null)" ]; then
                    echo "<div class='section'>" >> "$html_file"
                    echo "<h2>${dir^^} Results</h2>" >> "$html_file"
                    
                    for file in "$dir_path"/*; do
                        if [ -f "$file" ]; then
                            echo "<h3>$(basename $file)</h3>" >> "$html_file"
                            echo "<pre>$(cat "$file" | sed 's/</\&lt;/g; s/>/\&gt;/g')</pre>" >> "$html_file"
                        fi
                    done
                    
                    echo "</div>" >> "$html_file"
                fi
            done
            
            echo "</div></body></html>" >> "$html_file"
            
            print_success "HTML report generated: $html_file"
            ;;
        2)
            local json_file="$EXPORT_DIR/osint_export_$(date +%Y%m%d_%H%M%S).json"
            
            python3 << PYEOF > "$json_file" 2>/dev/null
import os, json, glob
from datetime import datetime

export_data = {
    "tool": "OSINT-X",
    "version": "$VERSION",
    "generated": datetime.now().isoformat(),
    "results": {}
}

output_dir = "$OUTPUT_DIR"
for category in ["domains", "ips", "emails", "usernames", "phones", "web", "network", "social"]:
    dir_path = os.path.join(output_dir, category)
    if os.path.isdir(dir_path):
        files = {}
        for filepath in glob.glob(os.path.join(dir_path, "*")):
            with open(filepath, 'r', errors='ignore') as f:
                files[os.path.basename(filepath)] = f.read()
        if files:
            export_data["results"][category] = files

print(json.dumps(export_data, indent=2))
PYEOF
            
            print_success "JSON export generated: $json_file"
            ;;
        3)
            separator
            print_info "Recent Results"
            separator
            
            find "$OUTPUT_DIR" -type f -name "*.txt" -mtime -7 | sort -r | head -30 | while IFS= read -r file; do
                local fsize=$(stat -c%s "$file" 2>/dev/null || stat -f%z "$file" 2>/dev/null)
                local fdate=$(date -r "$file" '+%Y-%m-%d %H:%M' 2>/dev/null)
                printf "  ${CYAN}→${WHITE} %-60s ${GRAY}%s (%s bytes)${RESET}\n" "$file" "$fdate" "$fsize"
            done
            ;;
        4)
            echo -ne "  ${WHITE}Delete results older than (days): ${CYAN}"
            read -r days
            echo -e "${RESET}"
            
            local deleted=$(find "$OUTPUT_DIR" -type f -mtime +"$days" -delete -print 2>/dev/null | wc -l)
            print_success "Deleted $deleted files older than $days days"
            ;;
    esac
    
    echo ""
    read -p "  Press Enter to continue..."
}

#============================================================================
# MODULE 13: API KEY CONFIGURATION
#============================================================================
configure_api_keys() {
    print_section "API KEY CONFIGURATION"
    
    echo -e "  ${WHITE}Current API Key Status:${RESET}"
    separator
    
    local keys=(
        "SHODAN_API_KEY|Shodan"
        "VIRUSTOTAL_API_KEY|VirusTotal"
        "HUNTER_API_KEY|Hunter.io"
        "SECURITYTRAILS_API_KEY|SecurityTrails"
        "IPINFO_TOKEN|IPinfo"
        "ABUSEIPDB_API_KEY|AbuseIPDB"
        "HAVEIBEENPWNED_API_KEY|HaveIBeenPwned"
        "NUMVERIFY_API_KEY|NumVerify"
        "CENSYS_API_ID|Censys"
        "GOOGLE_API_KEY|Google"
    )
    
    local config_file="$HOME/.osint_api_keys"
    
    # Load existing config
    [ -f "$config_file" ] && source "$config_file"
    
    for key_pair in "${keys[@]}"; do
        local key_name=$(echo "$key_pair" | cut -d'|' -f1)
        local key_label=$(echo "$key_pair" | cut -d'|' -f2)
        local key_value="${!key_name}"
        
        if [ -n "$key_value" ]; then
            local masked="${key_value:0:6}...${key_value: -4}"
            echo -e "  ${GREEN}[✓]${WHITE} %-20s ${GREEN}Configured${GRAY} ($masked)${RESET}" "$key_label"
        else
            echo -e "  ${RED}[✗]${WHITE} %-20s ${RED}Not set${RESET}" "$key_label"
        fi
    done
    
    echo ""
    echo -e "  ${CYAN}[1]${WHITE} Configure API keys${RESET}"
    echo -e "  ${CYAN}[2]${WHITE} Load from file${RESET}"
    echo -e "  ${CYAN}[3]${WHITE} Clear all keys${RESET}"
    echo -e "  ${CYAN}[0]${WHITE} Back${RESET}"
    echo ""
    echo -ne "  ${WHITE}Select option: ${CYAN}"
    read -r key_choice
    echo -e "${RESET}"
    
    case $key_choice in
        1)
            echo ""
            for key_pair in "${keys[@]}"; do
                local key_name=$(echo "$key_pair" | cut -d'|' -f1)
                local key_label=$(echo "$key_pair" | cut -d'|' -f2)
                echo -ne "  ${WHITE}$key_label API key (Enter to skip): ${CYAN}"
                read -r new_key
                echo -e "${RESET}"
                if [ -n "$new_key" ]; then
                    eval "$key_name='$new_key'"
                    echo "${key_name}='${new_key}'" >> "$config_file"
                fi
            done
            print_success "API keys saved to $config_file"
            ;;
        2)
            echo -ne "  ${WHITE}Enter config file path: ${CYAN}"
            read -r custom_config
            echo -e "${RESET}"
            if [ -f "$custom_config" ]; then
                source "$custom_config"
                print_success "API keys loaded from $custom_config"
            else
                print_error "File not found"
            fi
            ;;
        3)
            rm -f "$config_file"
            print_success "All API keys cleared"
            ;;
    esac
    
    echo ""
    read -p "  Press Enter to continue..."
}

#============================================================================
# MODULE 14: ADVANCED RECON AUTOMATION
#============================================================================
automated_recon() {
    print_section "AUTOMATED RECONNAISSANCE"
    echo -e "  ${WHITE}This module runs comprehensive automated recon on a target.${RESET}"
    echo ""
    echo -e "  ${CYAN}[1]${WHITE} Full domain recon (all modules)${RESET}"
    echo -e "  ${CYAN}[2]${WHITE} Person lookup (name-based)${RESET}"
    echo -e "  ${CYAN}[3]${WHITE} Company/Organization OSINT${RESET}"
    echo ""
    echo -ne "  ${WHITE}Select option: ${CYAN}"
    read -r auto_choice
    echo -e "${RESET}"
    
    case $auto_choice in
        1)
            echo -ne "  ${WHITE}Enter target domain: ${CYAN}"
            read -r auto_target
            echo -e "${RESET}"
            
            if ! validate_domain "$auto_target"; then
                print_error "Invalid domain"
                return 1
            fi
            
            local auto_report="$REPORT_DIR/full_recon_${auto_target}_$(date +%Y%m%d_%H%M%S).txt"
            
            echo "===============================================" > "$auto_report"
            echo "FULL AUTOMATED RECONNAISSANCE REPORT" >> "$auto_report"
            echo "Target: $auto_target" >> "$auto_report"
            echo "Date: $(date)" >> "$auto_report"
            echo "Tool: OSINT-X v${VERSION}" >> "$auto_report"
            echo "===============================================" >> "$auto_report"
            
            local modules=(
                "WHOIS Lookup"
                "DNS Enumeration"
                "Subdomain Discovery"
                "Port Scanning"
                "Technology Detection"
                "SSL Analysis"
                "Email Harvesting"
                "WAF Detection"
                "Sensitive Files"
                "Wayback Machine"
            )
            
            local total=${#modules[@]}
            local current=0
            
            for module in "${modules[@]}"; do
                ((current++))
                echo ""
                echo -e "  ${MAGENTA}[${current}/${total}]${WHITE} Running: ${CYAN}${module}${RESET}"
                echo -e "\n=== ${module} ===" >> "$auto_report"
                
                case "$module" in
                    "WHOIS Lookup")
                        whois "$auto_target" >> "$auto_report" 2>/dev/null
                        ;;
                    "DNS Enumeration")
                        for rtype in A AAAA MX NS TXT CNAME SOA CAA; do
                            echo "[$rtype]" >> "$auto_report"
                            dig +short "$auto_target" "$rtype" >> "$auto_report" 2>/dev/null
                        done
                        ;;
                    "Subdomain Discovery")
                        safe_curl "https://crt.sh/?q=%.${auto_target}&output=json" | \
                            python3 -c "import sys,json;[print(e['name_value']) for e in json.load(sys.stdin)]" 2>/dev/null | \
                            sort -u >> "$auto_report"
                        ;;
                    "Port Scanning")
                        local ip=$(dig +short "$auto_target" A 2>/dev/null | head -1)
                        if [ -n "$ip" ] && check_dependency "nmap"; then
                            nmap -sV --top-ports 100 -T4 "$ip" >> "$auto_report" 2>/dev/null
                        fi
                        ;;
                    "Technology Detection")
                        safe_curl -I "https://${auto_target}" >> "$auto_report" 2>/dev/null
                        ;;
                    "SSL Analysis")
                        echo | openssl s_client -connect "${auto_target}:443" -servername "$auto_target" 2>/dev/null | \
                            openssl x509 -noout -text >> "$auto_report" 2>/dev/null
                        ;;
                    "Email Harvesting")
                        safe_curl "https://${auto_target}" | \
                            grep -oE '[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}' | \
                            sort -u >> "$auto_report" 2>/dev/null
                        ;;
                    "WAF Detection")
                        safe_curl -I "https://${auto_target}" | \
                            grep -iE "cloudflare|akamai|incapsula|sucuri|f5|barracuda" >> "$auto_report" 2>/dev/null
                        ;;
                    "Sensitive Files")
                        for path in /.git/config /.env /robots.txt /sitemap.xml /.htaccess /phpinfo.php; do
                            local code=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 "https://${auto_target}${path}" 2>/dev/null)
                            echo "$path: HTTP $code" >> "$auto_report"
                        done
                        ;;
                    "Wayback Machine")
                        safe_curl "https://web.archive.org/cdx/search/cdx?url=${auto_target}&output=text&limit=20" >> "$auto_report" 2>/dev/null
                        ;;
                esac
                
                print_success "$module complete"
            done
            
            echo ""
            separator
            print_success "Full recon report saved to: $auto_report"
            print_info "Report size: $(wc -c < "$auto_report") bytes"
            ;;
        2)
            echo -ne "  ${WHITE}Enter person's full name: ${CYAN}"
            read -r person_name
            echo -e "${RESET}"
            
            local encoded_name=$(echo "$person_name" | tr ' ' '+')
            
            separator
            print_info "Person Lookup: $person_name"
            separator
            
            echo -e "  ${CYAN}Search Links:${RESET}"
            echo -e "  ${GREEN}→${WHITE} Google: https://google.com/search?q=\"${encoded_name}\"${RESET}"
            echo -e "  ${GREEN}→${WHITE} LinkedIn: https://linkedin.com/search/results/all/?keywords=${encoded_name}${RESET}"
            echo -e "  ${GREEN}→${WHITE} Facebook: https://facebook.com/search/people/?q=${encoded_name}${RESET}"
            echo -e "  ${GREEN}→${WHITE} Twitter/X: https://x.com/search?q=${encoded_name}&f=user${RESET}"
            echo -e "  ${GREEN}→${WHITE} Instagram: https://instagram.com/explore/tags/${encoded_name// /}${RESET}"
            echo -e "  ${GREEN}→${WHITE} Pipl: https://pipl.com/search/?q=${encoded_name}${RESET}"
            echo -e "  ${GREEN}→${WHITE} Spokeo: https://spokeo.com/${person_name// /-}${RESET}"
            echo -e "  ${GREEN}→${WHITE} That's Them: https://thatsthem.com/name/${person_name// /-}${RESET}"
            echo -e "  ${GREEN}→${WHITE} Whitepages: https://whitepages.com/name/${person_name// /-}${RESET}"
            echo -e "  ${GREEN}→${WHITE} PeekYou: https://peekyou.com/${person_name// /_}${RESET}"
            echo -e "  ${GREEN}→${WHITE} GitHub: https://github.com/search?q=${encoded_name}&type=users${RESET}"
            echo -e "  ${GREEN}→${WHITE} Medium: https://medium.com/search?q=${encoded_name}${RESET}"
            echo -e "  ${GREEN}→${WHITE} Reddit: https://reddit.com/search/?q=${encoded_name}${RESET}"
            echo -e "  ${GREEN}→${WHITE} Google Scholar: https://scholar.google.com/scholar?q=${encoded_name}${RESET}"
            echo -e "  ${GREEN}→${WHITE} ResearchGate: https://researchgate.net/search?q=${encoded_name}${RESET}"
            ;;
        3)
            echo -ne "  ${WHITE}Enter company/organization name: ${CYAN}"
            read -r company_name
            echo -e "${RESET}"
            
            local encoded_company=$(echo "$company_name" | tr ' ' '+')
            
            separator
            print_info "Organization OSINT: $company_name"
            separator
            
            echo -e "  ${CYAN}Company Research Links:${RESET}"
            echo -e "  ${GREEN}→${WHITE} LinkedIn: https://linkedin.com/company/${company_name// /-}${RESET}"
            echo -e "  ${GREEN}→${WHITE} Crunchbase: https://crunchbase.com/organization/${company_name// /-}${RESET}"
            echo -e "  ${GREEN}→${WHITE} Glassdoor: https://glassdoor.com/Reviews/${company_name// /-}-Reviews${RESET}"
            echo -e "  ${GREEN}→${WHITE} Indeed: https://indeed.com/cmp/${company_name// /-}${RESET}"
            echo -e "  ${GREEN}→${WHITE} SEC (EDGAR): https://efts.sec.gov/LATEST/search-index?q=${encoded_company}${RESET}"
            echo -e "  ${GREEN}→${WHITE} GitHub: https://github.com/${company_name// /-}${RESET}"
            echo -e "  ${GREEN}→${WHITE} OpenCorporates: https://opencorporates.com/companies?q=${encoded_company}${RESET}"
            echo -e "  ${GREEN}→${WHITE} DNB: https://dnb.com/business-directory/company-search.html?term=${encoded_company}${RESET}"
            echo -e "  ${GREEN}→${WHITE} ZoomInfo: https://zoominfo.com/s/#!search/company&input=${encoded_company}${RESET}"
            echo -e "  ${GREEN}→${WHITE} BBB: https://bbb.org/search?find_text=${encoded_company}${RESET}"
            echo -e "  ${GREEN}→${WHITE} Shodan: https://shodan.io/search?query=org:\"${company_name}\"${RESET}"
            echo -e "  ${GREEN}→${WHITE} Censys: https://search.censys.io/search?q=${encoded_company}${RESET}"
            echo -e "  ${GREEN}→${WHITE} Hunter.io: https://hunter.io/search/${company_name// /-}${RESET}"
            echo -e "  ${GREEN}→${WHITE} BuiltWith: https://builtwith.com/${company_name// /}${RESET}"
            ;;
    esac
    
    echo ""
    read -p "  Press Enter to continue..."
}

#============================================================================
# MODULE 15: HASH & CRYPTO TOOLS
#============================================================================
hash_crypto_tools() {
    print_section "HASH & CRYPTO TOOLS"
    echo -e "  ${CYAN}[1]${WHITE} Hash identifier${RESET}"
    echo -e "  ${CYAN}[2]${WHITE} Hash generator${RESET}"
    echo -e "  ${CYAN}[3]${WHITE} Hash lookup (online)${RESET}"
    echo -e "  ${CYAN}[4]${WHITE} File hash calculator${RESET}"
    echo -e "  ${CYAN}[5]${WHITE} Base64 encode/decode${RESET}"
    echo -e "  ${CYAN}[6]${WHITE} URL encode/decode${RESET}"
    echo ""
    echo -ne "  ${WHITE}Select option: ${CYAN}"
    read -r hash_choice
    echo -e "${RESET}"
    
    case $hash_choice in
        1)
            echo -ne "  ${WHITE}Enter hash: ${CYAN}"
            read -r input_hash
            echo -e "${RESET}"
            
            separator
            print_info "Hash Identification"
            separator
            
            local hash_len=${#input_hash}
            echo -e "  ${WHITE}Hash Length: ${CYAN}$hash_len characters${RESET}"
            echo ""
            
            case $hash_len in
                32) print_result "Possible Type" "MD5 / NTLM / MD4" ;;
                40) print_result "Possible Type" "SHA-1 / MySQL5 / RIPEMD-160" ;;
                56) print_result "Possible Type" "SHA-224" ;;
                64) print_result "Possible Type" "SHA-256 / SHA3-256 / BLAKE2s" ;;
                96) print_result "Possible Type" "SHA-384 / SHA3-384" ;;
                128) print_result "Possible Type" "SHA-512 / SHA3-512 / BLAKE2b / Whirlpool" ;;
                13) print_result "Possible Type" "DES (Unix)" ;;
                16) print_result "Possible Type" "MySQL323 / Half-MD5" ;;
                *) print_result "Possible Type" "Unknown hash format" ;;
            esac
            
            [[ "$input_hash" =~ ^\$2[aby]?\$ ]] && print_result "Detected" "bcrypt"
            [[ "$input_hash" =~ ^\$6\$ ]] && print_result "Detected" "SHA-512 (Unix)"
            [[ "$input_hash" =~ ^\$5\$ ]] && print_result "Detected" "SHA-256 (Unix)"
            [[ "$input_hash" =~ ^\$1\$ ]] && print_result "Detected" "MD5 (Unix)"
            [[ "$input_hash" =~ ^\$apr1\$ ]] && print_result "Detected" "Apache MD5"
            [[ "$input_hash" =~ ^\{SHA\} ]] && print_result "Detected" "LDAP SHA"
            ;;
        2)
            echo -ne "  ${WHITE}Enter text to hash: ${CYAN}"
            read -r hash_text
            echo -e "${RESET}"
            
            separator
            print_info "Generated Hashes"
            separator
            
            print_result "MD5" "$(echo -n "$hash_text" | md5sum | cut -d' ' -f1)"
            print_result "SHA-1" "$(echo -n "$hash_text" | sha1sum | cut -d' ' -f1)"
            print_result "SHA-224" "$(echo -n "$hash_text" | sha224sum | cut -d' ' -f1)"
            print_result "SHA-256" "$(echo -n "$hash_text" | sha256sum | cut -d' ' -f1)"
            print_result "SHA-384" "$(echo -n "$hash_text" | sha384sum | cut -d' ' -f1)"
            print_result "SHA-512" "$(echo -n "$hash_text" | sha512sum | cut -d' ' -f1)"
            print_result "Base64" "$(echo -n "$hash_text" | base64)"
            print_result "CRC32" "$(echo -n "$hash_text" | python3 -c "import sys,binascii;print(format(binascii.crc32(sys.stdin.buffer.read()),'08x'))" 2>/dev/null)"
            ;;
        3)
            echo -ne "  ${WHITE}Enter hash to lookup: ${CYAN}"
            read -r lookup_hash
            echo -e "${RESET}"
            
            separator
            print_info "Online Hash Lookup"
            separator
            
            # MD5 decrypt services
            local md5_result=$(safe_curl "https://api.nitrxgen.net/md5decrypt?value=${lookup_hash}&md5=${lookup_hash}")
            if [ -n "$md5_result" ]; then
                print_result "Nitrxgen" "$md5_result"
            fi
            
            echo -e "\n  ${CYAN}Manual lookup links:${RESET}"
            echo -e "  ${GREEN}→${WHITE} CrackStation: https://crackstation.net/${RESET}"
            echo -e "  ${GREEN}→${WHITE} Hashes.com: https://hashes.com/en/decrypt/hash${RESET}"
            echo -e "  ${GREEN}→${WHITE} MD5Online: https://www.md5online.org/md5-decrypt.html${RESET}"
            echo -e "  ${GREEN}→${WHITE} HashKiller: https://hashkiller.io/listmanager${RESET}"
            echo -e "  ${GREEN}→${WHITE} CMD5: https://cmd5.org/${RESET}"
            
            # VirusTotal hash check
            if [ -n "$VIRUSTOTAL_API_KEY" ]; then
                local vt_hash=$(safe_curl "https://www.virustotal.com/api/v3/files/${lookup_hash}" \
                    -H "x-apikey: ${VIRUSTOTAL_API_KEY}")
                if [ -n "$vt_hash" ] && [[ "$vt_hash" != *"NotFoundError"* ]]; then
                    print_result "VirusTotal" "File found in database!"
                    local vt_stats=$(echo "$vt_hash" | python3 -c "
import sys,json
try:
    d=json.load(sys.stdin)
    s=d['data']['attributes']['last_analysis_stats']
    print(f\"Malicious: {s.get('malicious',0)}, Clean: {s.get('harmless',0)}\")
except:
    print('N/A')
" 2>/dev/null)
                    print_result "Analysis" "$vt_stats"
                fi
            fi
            ;;
        4)
            echo -ne "  ${WHITE}Enter file path: ${CYAN}"
            read -r hash_file
            echo -e "${RESET}"
            
            if [ -f "$hash_file" ]; then
                separator
                print_info "File Hashes for: $hash_file"
                separator
                
                print_result "MD5" "$(md5sum "$hash_file" | cut -d' ' -f1)"
                print_result "SHA-1" "$(sha1sum "$hash_file" | cut -d' ' -f1)"
                print_result "SHA-256" "$(sha256sum "$hash_file" | cut -d' ' -f1)"
                print_result "SHA-512" "$(sha512sum "$hash_file" | cut -d' ' -f1)"
                print_result "File Size" "$(stat -c%s "$hash_file" 2>/dev/null || stat -f%z "$hash_file" 2>/dev/null) bytes"
                print_result "File Type" "$(file -b "$hash_file" 2>/dev/null)"
            else
                print_error "File not found"
            fi
            ;;
        5)
            echo -e "  ${CYAN}[1]${WHITE} Encode${RESET}"
            echo -e "  ${CYAN}[2]${WHITE} Decode${RESET}"
            echo -ne "  ${WHITE}Choice: ${CYAN}"
            read -r b64_choice
            echo -ne "  ${WHITE}Enter text: ${CYAN}"
            read -r b64_text
            echo -e "${RESET}"
            
            if [ "$b64_choice" = "1" ]; then
                print_result "Base64 Encoded" "$(echo -n "$b64_text" | base64)"
            else
                print_result "Base64 Decoded" "$(echo -n "$b64_text" | base64 -d 2>/dev/null)"
            fi
            ;;
        6)
            echo -e "  ${CYAN}[1]${WHITE} Encode${RESET}"
            echo -e "  ${CYAN}[2]${WHITE} Decode${RESET}"
            echo -ne "  ${WHITE}Choice: ${CYAN}"
            read -r url_choice
            echo -ne "  ${WHITE}Enter text: ${CYAN}"
            read -r url_text
            echo -e "${RESET}"
            
            if [ "$url_choice" = "1" ]; then
                print_result "URL Encoded" "$(python3 -c "import urllib.parse;print(urllib.parse.quote('$url_text'))" 2>/dev/null)"
            else
                print_result "URL Decoded" "$(python3 -c "import urllib.parse;print(urllib.parse.unquote('$url_text'))" 2>/dev/null)"
            fi
            ;;
    esac
    
    echo ""
    read -p "  Press Enter to continue..."
}

#============================================================================
# MAIN MENU
#============================================================================
main_menu() {
    while true; do
        print_banner
        
        echo -e "  ${WHITE}${BOLD}RECONNAISSANCE MODULES${RESET}"
        echo -e "  ${GRAY}─────────────────────────────────────────────${RESET}"
        echo -e "  ${CYAN}[1]${WHITE}   🌐 Domain Intelligence${RESET}"
        echo -e "  ${CYAN}[2]${WHITE}   📡 IP Address Intelligence${RESET}"
        echo -e "  ${CYAN}[3]${WHITE}   📧 Email Intelligence${RESET}"
        echo -e "  ${CYAN}[4]${WHITE}   👤 Username Intelligence${RESET}"
        echo -e "  ${CYAN}[5]${WHITE}   📱 Phone Number Intelligence${RESET}"
        echo -e "  ${CYAN}[6]${WHITE}   🔍 Website Analysis${RESET}"
        echo -e "  ${CYAN}[7]${WHITE}   📲 Social Media Intelligence${RESET}"
        echo -e "  ${CYAN}[8]${WHITE}   🖼️  Image & Metadata Analysis${RESET}"
        echo ""
        echo -e "  ${WHITE}${BOLD}UTILITY MODULES${RESET}"
        echo -e "  ${GRAY}─────────────────────────────────────────────${RESET}"
        echo -e "  ${CYAN}[9]${WHITE}   🔧 Network Tools${RESET}"
        echo -e "  ${CYAN}[10]${WHITE}  🕵️  Dark Web & Paste Search${RESET}"
        echo -e "  ${CYAN}[11]${WHITE}  🔎 Google Dorking Engine${RESET}"
        echo -e "  ${CYAN}[12]${WHITE}  🔐 Hash & Crypto Tools${RESET}"
        echo -e "  ${CYAN}[13]${WHITE}  🤖 Automated Reconnaissance${RESET}"
        echo ""
        echo -e "  ${WHITE}${BOLD}SYSTEM${RESET}"
        echo -e "  ${GRAY}─────────────────────────────────────────────${RESET}"
        echo -e "  ${CYAN}[14]${WHITE}  📊 Report Generator${RESET}"
        echo -e "  ${CYAN}[15]${WHITE}  🔑 API Key Configuration${RESET}"
        echo -e "  ${CYAN}[16]${WHITE}  📦 Check Dependencies${RESET}"
        echo -e "  ${CYAN}[0]${WHITE}   🚪 Exit${RESET}"
        echo ""
        echo -e "  ${GRAY}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
        echo -ne "  ${WHITE}Select module ${CYAN}[0-16]${WHITE}: ${CYAN}"
        read -r choice
        echo -e "${RESET}"
        
        case $choice in
            1)  domain_recon ;;
            2)  ip_recon ;;
            3)  email_recon ;;
            4)  username_recon ;;
            5)  phone_recon ;;
            6)  website_analysis ;;
            7)  social_media_recon ;;
            8)  image_analysis ;;
            9)  network_tools ;;
            10) darkweb_paste_search ;;
            11) google_dorking ;;
            12) hash_crypto_tools ;;
            13) automated_recon ;;
            14) generate_report ;;
            15) configure_api_keys ;;
            16) check_and_install_deps ;;
            0)
                echo ""
                echo -e "  ${CYAN}╔═══════════════════════════════════════════╗${RESET}"
                echo -e "  ${CYAN}║${WHITE}  Thank you for using OSINT-X!             ${CYAN}║${RESET}"
                echo -e "  ${CYAN}║${WHITE}  Results saved to: ${GREEN}$OUTPUT_DIR  ${CYAN}║${RESET}"
                echo -e "  ${CYAN}║${WHITE}  Stay legal. Stay ethical.                ${CYAN}║${RESET}"
                echo -e "  ${CYAN}╚═══════════════════════════════════════════╝${RESET}"
                echo ""
                exit 0
                ;;
            *)
                print_error "Invalid option. Please select 0-16."
                sleep 1
                ;;
        esac
    done
}

#============================================================================
# STARTUP SEQUENCE
#============================================================================
startup() {
    # Legal disclaimer
    clear
    echo -e "${RED}"
    echo "  ╔══════════════════════════════════════════════════════════╗"
    echo "  ║                    LEGAL DISCLAIMER                      ║"
    echo "  ╠══════════════════════════════════════════════════════════╣"
    echo "  ║                                                          ║"
    echo "  ║  This tool is designed for LEGAL purposes only.          ║"
    echo "  ║  Use it only on targets you have permission to test.     ║"
    echo "  ║                                                          ║"
    echo "  ║  The developer assumes NO liability for misuse of        ║"
    echo "  ║  this software. Users are responsible for ensuring       ║"
    echo "  ║  compliance with all applicable laws and regulations.    ║"
    echo "  ║                                                          ║"
    echo "  ║  By proceeding, you agree to use this tool ethically     ║"
    echo "  ║  and legally.                                            ║"
    echo "  ║                                                          ║"
    echo "  ╚══════════════════════════════════════════════════════════╝"
    echo -e "${RESET}"
    echo ""
    echo -ne "  ${WHITE}Do you agree? ${CYAN}[y/N]${WHITE}: "
    read -r agree
    
    if [[ "$agree" != "y" && "$agree" != "Y" ]]; then
        echo -e "  ${RED}Exiting...${RESET}"
        exit 1
    fi
    
    # Setup
    setup_directories
    
    # Load API keys
    [ -f "$HOME/.osint_api_keys" ] && source "$HOME/.osint_api_keys"
    
    # Start logging
    log_info "OSINT-X v${VERSION} started"
    log_info "Output directory: $OUTPUT_DIR"
    
    # Launch main menu
    main_menu
}

#============================================================================
# ENTRY POINT
#============================================================================
startup
