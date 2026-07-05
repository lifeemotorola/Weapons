#!/bin/bash

#====================================================
# SIM/Contact Tracker Tool for Termux
# Author: Emmanuel Suah
# Version: 3.0
# Description: Lookup publicly available info
#              associated with a phone number
# Update: Added username display feature
#====================================================

# ============== COLORS ==============
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
CYAN='\033[1;36m'
MAGENTA='\033[1;35m'
WHITE='\033[1;37m'
RESET='\033[0m'
BOLD='\033[1m'
DIM='\033[2m'
UNDERLINE='\033[4m'
BLINK='\033[5m'

# ============== DIRECTORIES ==============
RESULT_DIR="$HOME/sim_tracker_results"
LOG_FILE="$RESULT_DIR/tracker.log"
CONFIG_FILE="$RESULT_DIR/.user_config"
API_CONFIG="$RESULT_DIR/.api_config"

# ============== USER PROFILE ==============
USER_NAME=""
USER_SESSION_START=""

load_user_profile() {
    if [ -f "$CONFIG_FILE" ]; then
        source "$CONFIG_FILE"
        USER_NAME="$SAVED_USER_NAME"
    fi
}

save_user_profile() {
    local name="$1"
    echo "SAVED_USER_NAME=\"$name\"" > "$CONFIG_FILE"
    echo "LAST_LOGIN=\"$(date)\"" >> "$CONFIG_FILE"
    echo "LOGIN_COUNT=$((${LOGIN_COUNT:-0} + 1))" >> "$CONFIG_FILE"
}

get_username() {
    load_user_profile

    if [ -z "$USER_NAME" ]; then
        clear
        echo -e "${CYAN}"
        cat << 'EOF'
  ╔══════════════════════════════════════════╗
  ║                                          ║
  ║       Welcome to SIM Tracker v3.0        ║
  ║                                          ║
  ║     Let's set up your profile first      ║
  ║                                          ║
  ╚══════════════════════════════════════════╝
EOF
        echo -e "${RESET}"
        echo ""
        echo -e "  ${YELLOW}┌──────────────────────────────────────┐${RESET}"
        echo -e "  ${YELLOW}│  Please enter your name / username   │${RESET}"
        echo -e "  ${YELLOW}└──────────────────────────────────────┘${RESET}"
        echo ""
        echo -ne "  ${GREEN}➤ Your Name: ${WHITE}"
        read -r USER_NAME
        echo -e "${RESET}"

        # Validate name
        while [ -z "$USER_NAME" ] || [ ${#USER_NAME} -lt 2 ]; do
            echo -e "  ${RED}[✗] Name must be at least 2 characters!${RESET}"
            echo -ne "  ${GREEN}➤ Your Name: ${WHITE}"
            read -r USER_NAME
            echo -e "${RESET}"
        done

        save_user_profile "$USER_NAME"
        USER_SESSION_START=$(date +%s)

        echo ""
        echo -e "  ${GREEN}╔══════════════════════════════════════════╗${RESET}"
        echo -e "  ${GREEN}║                                          ║${RESET}"
        echo -e "  ${GREEN}║  ${WHITE}✓ Welcome, ${CYAN}${USER_NAME}${WHITE}!${GREEN}                       ║${RESET}"
        echo -e "  ${GREEN}║  ${WHITE}  Your profile has been saved.${GREEN}          ║${RESET}"
        echo -e "  ${GREEN}║                                          ║${RESET}"
        echo -e "  ${GREEN}╚══════════════════════════════════════════╝${RESET}"
        echo ""
        sleep 2
    else
        USER_SESSION_START=$(date +%s)
        echo ""
        echo -e "  ${GREEN}[✓] Welcome back, ${CYAN}${BOLD}${USER_NAME}${RESET}${GREEN}!${RESET}"
        
        if [ -f "$CONFIG_FILE" ]; then
            source "$CONFIG_FILE"
            echo -e "  ${DIM}  Last login: ${LAST_LOGIN:-Unknown}${RESET}"
        fi
        echo ""
        sleep 1
    fi
}

# ============== USER PROFILE DISPLAY ==============
show_user_profile() {
    echo ""
    echo -e "  ${CYAN}╔══════════════════════════════════════════════╗${RESET}"
    echo -e "  ${CYAN}║           ${WHITE}${BOLD}USER PROFILE${RESET}${CYAN}                      ║${RESET}"
    echo -e "  ${CYAN}╠══════════════════════════════════════════════╣${RESET}"
    echo -e "  ${CYAN}║${RESET}                                              ${CYAN}║${RESET}"
    echo -e "  ${CYAN}║${RESET}  ${YELLOW}👤 Username    :${RESET} ${WHITE}${BOLD}${USER_NAME}${RESET}"
    echo -e "  ${CYAN}║${RESET}  ${YELLOW}📅 Session     :${RESET} ${WHITE}$(date)${RESET}"
    
    # Calculate session duration
    if [ -n "$USER_SESSION_START" ]; then
        local current_time=$(date +%s)
        local duration=$((current_time - USER_SESSION_START))
        local minutes=$((duration / 60))
        local seconds=$((duration % 60))
        echo -e "  ${CYAN}║${RESET}  ${YELLOW}⏱  Duration   :${RESET} ${WHITE}${minutes}m ${seconds}s${RESET}"
    fi
    
    # System info
    echo -e "  ${CYAN}║${RESET}  ${YELLOW}💻 System      :${RESET} ${WHITE}$(uname -o 2>/dev/null || echo 'Android')${RESET}"
    echo -e "  ${CYAN}║${RESET}  ${YELLOW}📱 Device      :${RESET} ${WHITE}$(getprop ro.product.model 2>/dev/null || echo 'Unknown')${RESET}"
    echo -e "  ${CYAN}║${RESET}  ${YELLOW}🏠 Home Dir    :${RESET} ${WHITE}${HOME}${RESET}"
    echo -e "  ${CYAN}║${RESET}  ${YELLOW}📁 Results Dir :${RESET} ${WHITE}${RESULT_DIR}${RESET}"
    
    # Count results
    local result_count=$(ls -1 "$RESULT_DIR"/*.txt 2>/dev/null | wc -l)
    echo -e "  ${CYAN}║${RESET}  ${YELLOW}📊 Reports     :${RESET} ${WHITE}${result_count} file(s)${RESET}"
    
    # Login count
    if [ -f "$CONFIG_FILE" ]; then
        source "$CONFIG_FILE"
        echo -e "  ${CYAN}║${RESET}  ${YELLOW}🔑 Login Count :${RESET} ${WHITE}${LOGIN_COUNT:-1}${RESET}"
        echo -e "  ${CYAN}║${RESET}  ${YELLOW}📅 Last Login  :${RESET} ${WHITE}${LAST_LOGIN:-First time}${RESET}"
    fi
    
    echo -e "  ${CYAN}║${RESET}                                              ${CYAN}║${RESET}"
    echo -e "  ${CYAN}╚══════════════════════════════════════════════╝${RESET}"
    echo ""
}

# ============== CHANGE USERNAME ==============
change_username() {
    echo ""
    echo -e "  ${CYAN}╔══════════════════════════════════════════╗${RESET}"
    echo -e "  ${CYAN}║       ${WHITE}CHANGE USERNAME${CYAN}                    ║${RESET}"
    echo -e "  ${CYAN}╚══════════════════════════════════════════╝${RESET}"
    echo ""
    echo -e "  ${YELLOW}Current username: ${WHITE}${BOLD}${USER_NAME}${RESET}"
    echo ""
    echo -ne "  ${GREEN}➤ Enter new username: ${WHITE}"
    read -r new_name
    echo -e "${RESET}"
    
    if [ -z "$new_name" ] || [ ${#new_name} -lt 2 ]; then
        echo -e "  ${RED}[✗] Invalid name! Must be at least 2 characters.${RESET}"
        return 1
    fi
    
    local old_name="$USER_NAME"
    USER_NAME="$new_name"
    save_user_profile "$USER_NAME"
    
    echo -e "  ${GREEN}[✓] Username changed!${RESET}"
    echo -e "  ${DIM}  Old: $old_name${RESET}"
    echo -e "  ${GREEN}  New: ${WHITE}${BOLD}$USER_NAME${RESET}"
}

# ============== GREETING BASED ON TIME ==============
get_greeting() {
    local hour=$(date +%H)
    local greeting=""
    local emoji=""
    
    if [ "$hour" -ge 5 ] && [ "$hour" -lt 12 ]; then
        greeting="Good Morning"
        emoji="🌅"
    elif [ "$hour" -ge 12 ] && [ "$hour" -lt 17 ]; then
        greeting="Good Afternoon"
        emoji="☀️"
    elif [ "$hour" -ge 17 ] && [ "$hour" -lt 21 ]; then
        greeting="Good Evening"
        emoji="🌆"
    else
        greeting="Good Night"
        emoji="🌙"
    fi
    
    echo -e "  ${emoji} ${GREEN}${greeting}, ${CYAN}${BOLD}${USER_NAME}${RESET}${GREEN}!${RESET}"
}

# ============== SETUP ==============
setup_environment() {
    echo -e "${CYAN}[*] Setting up environment...${RESET}"
    
    mkdir -p "$RESULT_DIR"
    
    local packages=("curl" "jq" "python" "git" "wget" "dnsutils" "nmap" "termux-api")
    
    for pkg in "${packages[@]}"; do
        if ! command -v "$pkg" &>/dev/null; then
            echo -e "${YELLOW}[+] Installing $pkg...${RESET}"
            pkg install -y "$pkg" 2>/dev/null
        else
            echo -e "${GREEN}[✓] $pkg already installed${RESET}"
        fi
    done
    
    pip install requests phonenumbers 2>/dev/null
    
    echo -e "${GREEN}[✓] Environment ready, ${CYAN}${USER_NAME}${GREEN}!${RESET}"
}

# ============== BANNER ==============
show_banner() {
    clear
    echo -e "${RED}"
    cat << 'EOF'
  ╔══════════════════════════════════════════════╗
  ║                                              ║
  ║     ███████╗██╗███╗   ███╗                   ║
  ║     ██╔════╝██║████╗ ████║                   ║
  ║     ███████╗██║██╔████╔██║                   ║
  ║     ╚════██║██║██║╚██╔╝██║                   ║
  ║     ███████║██║██║ ╚═╝ ██║                   ║
  ║     ╚══════╝╚═╝╚═╝     ╚═╝                  ║
  ║                                              ║
  ║     ████████╗██████╗  █████╗  ██████╗██╗  ██╗║
  ║     ╚══██╔══╝██╔══██╗██╔══██╗██╔════╝██║ ██╔╝║
  ║        ██║   ██████╔╝███████║██║     █████╔╝  ║
  ║        ██║   ██╔══██╗██╔══██║██║     ██╔═██╗  ║
  ║        ██║   ██║  ██║██║  ██║╚██████╗██║  ██╗║
  ║        ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚╝║
  ║                                              ║
  ║        SIM / Contact Tracker v3.0            ║
  ║        Educational Purpose Only              ║
  ╚══════════════════════════════════════════════╝
EOF
    echo -e "${RESET}"
    
    # Display user greeting
    echo -e "${CYAN}  ─────────────────────────────────────────${RESET}"
    get_greeting
    echo -e "${CYAN}  ─────────────────────────────────────────${RESET}"
    echo -e "  ${DIM}  Logged in as: ${WHITE}${BOLD}${USER_NAME}${RESET} ${DIM}| $(date '+%H:%M:%S')${RESET}"
    echo -e "${YELLOW}  ⚠  For authorized & legal use only!${RESET}"
    echo ""
}

# ============== INPUT VALIDATION ==============
validate_phone() {
    local number="$1"
    number=$(echo "$number" | sed 's/[[:space:]()-]//g')
    
    if [[ "$number" =~ ^\+?[0-9]{7,15}$ ]]; then
        echo "$number"
        return 0
    else
        return 1
    fi
}

# ============== MODULE 1: Phone Number Info ==============
phone_number_lookup() {
    local number="$1"
    local output_file="$RESULT_DIR/phone_info_${number}.txt"
    
    echo -e "${CYAN}[*] ${USER_NAME}, analyzing phone number: ${WHITE}$number${RESET}"
    echo -e "${CYAN}[*] Running phonenumbers library analysis...${RESET}"
    
    python3 << PYEOF > "$output_file" 2>/dev/null
import phonenumbers
from phonenumbers import carrier, geocoder, timezone
import sys

try:
    number = "$number"
    if not number.startswith('+'):
        number = '+' + number
    
    phone = phonenumbers.parse(number)
    
    print("=" * 55)
    print("        PHONE NUMBER ANALYSIS REPORT")
    print("        Requested by: $USER_NAME")
    print("=" * 55)
    print(f"  Input Number    : {number}")
    print(f"  Valid Number    : {phonenumbers.is_valid_number(phone)}")
    print(f"  Possible Number : {phonenumbers.is_possible_number(phone)}")
    print(f"  International   : {phonenumbers.format_number(phone, phonenumbers.PhoneNumberFormat.INTERNATIONAL)}")
    print(f"  National        : {phonenumbers.format_number(phone, phonenumbers.PhoneNumberFormat.NATIONAL)}")
    print(f"  E164 Format     : {phonenumbers.format_number(phone, phonenumbers.PhoneNumberFormat.E164)}")
    print(f"  Country Code    : +{phone.country_code}")
    print(f"  National Number : {phone.national_number}")
    print(f"  Country         : {geocoder.description_for_number(phone, 'en')}")
    print(f"  Location        : {geocoder.description_for_number(phone, 'en')}")
    print(f"  Carrier/ISP     : {carrier.name_for_number(phone, 'en')}")
    print(f"  Number Type     : {phonenumbers.number_type(phone)}")
    
    tz = timezone.time_zones_for_number(phone)
    print(f"  Timezone(s)     : {', '.join(tz) if tz else 'Unknown'}")
    
    type_map = {
        0: "FIXED_LINE", 1: "MOBILE", 2: "FIXED_LINE_OR_MOBILE",
        3: "TOLL_FREE", 4: "PREMIUM_RATE", 5: "SHARED_COST",
        6: "VOIP", 7: "PERSONAL_NUMBER", 8: "PAGER",
        9: "UAN", 10: "VOICEMAIL", 27: "UNKNOWN"
    }
    num_type = phonenumbers.number_type(phone)
    print(f"  Line Type       : {type_map.get(num_type, 'UNKNOWN')}")
    print("=" * 55)
    
except Exception as e:
    print(f"  [!] Error: {e}")
    print("  [!] Make sure number includes country code (e.g., +1234567890)")
PYEOF

    if [ -f "$output_file" ]; then
        echo -e "${GREEN}"
        cat "$output_file"
        echo -e "${RESET}"
    else
        echo -e "${RED}[✗] Phone analysis failed.${RESET}"
    fi
}

# ============== MODULE 2: OSINT Lookup ==============
osint_lookup() {
    local number="$1"
    local output_file="$RESULT_DIR/osint_${number}.txt"
    
    echo -e "${CYAN}[*] ${USER_NAME}, running OSINT lookups...${RESET}"
    echo ""
    
    {
        echo "========================================"
        echo "       OSINT LOOKUP RESULTS"
        echo "========================================"
        echo "  Operator : $USER_NAME"
        echo "  Target   : $number"
        echo "  Date     : $(date)"
        echo "========================================"
    } > "$output_file"
    
    # Load API keys if available
    local numverify_key=""
    local abstract_key=""
    if [ -f "$API_CONFIG" ]; then
        source "$API_CONFIG"
        numverify_key="$NUMVERIFY_KEY"
        abstract_key="$ABSTRACT_KEY"
    fi
    
    # --- NumVerify API ---
    echo -e "${YELLOW}  [+] Querying NumVerify API...${RESET}"
    if [ -n "$numverify_key" ]; then
        local numverify_result=$(curl -s "http://apilayer.net/api/validate?access_key=${numverify_key}&number=${number}&format=1" 2>/dev/null)
        
        if echo "$numverify_result" | jq -e '.valid' &>/dev/null; then
            echo "" >> "$output_file"
            echo "--- NumVerify Results ---" >> "$output_file"
            echo "$numverify_result" | jq '.' >> "$output_file" 2>/dev/null
            echo -e "${GREEN}  [✓] NumVerify data retrieved${RESET}"
        fi
    else
        echo -e "${YELLOW}  [!] NumVerify: Add API key in settings${RESET}"
        echo "  [!] NumVerify: No API key configured" >> "$output_file"
    fi
    
    # --- Abstract API ---
    echo -e "${YELLOW}  [+] Querying Abstract API...${RESET}"
    if [ -n "$abstract_key" ]; then
        local abstract_result=$(curl -s "https://phonevalidation.abstractapi.com/v1/?api_key=${abstract_key}&phone=${number}" 2>/dev/null)
        
        if echo "$abstract_result" | jq -e '.phone' &>/dev/null; then
            echo "" >> "$output_file"
            echo "--- Abstract API Results ---" >> "$output_file"
            echo "$abstract_result" | jq '.' >> "$output_file" 2>/dev/null
            echo -e "${GREEN}  [✓] Abstract API data retrieved${RESET}"
        fi
    else
        echo -e "${YELLOW}  [!] Abstract API: Add API key in settings${RESET}"
        echo "  [!] Abstract API: No API key configured" >> "$output_file"
    fi
    
    echo ""
    echo -e "${GREEN}  [✓] OSINT results saved: $output_file${RESET}"
}

# ============== MODULE 3: Carrier HLR Lookup ==============
hlr_lookup() {
    local number="$1"
    
    echo -e "${CYAN}[*] ${USER_NAME}, performing HLR/Carrier Lookup...${RESET}"
    echo ""
    
    python3 << PYEOF 2>/dev/null
import phonenumbers
from phonenumbers import carrier, geocoder

try:
    number = "$number"
    if not number.startswith('+'):
        number = '+' + number
    
    phone = phonenumbers.parse(number)
    carrier_name = carrier.name_for_number(phone, 'en')
    location = geocoder.description_for_number(phone, 'en')
    
    print("  ┌─────────────────────────────────────┐")
    print("  │       HLR / CARRIER LOOKUP          │")
    print("  │       Operator: $USER_NAME")
    print("  ├─────────────────────────────────────┤")
    print(f"  │  Number   : {number:<23}│")
    print(f"  │  Carrier  : {carrier_name if carrier_name else 'Unknown':<23}│")
    print(f"  │  Location : {location if location else 'Unknown':<23}│")
    print(f"  │  Valid    : {str(phonenumbers.is_valid_number(phone)):<23}│")
    print("  └─────────────────────────────────────┘")
    
except Exception as e:
    print(f"  [!] Error: {e}")
PYEOF
}

# ============== MODULE 4: Social Media Footprint ==============
social_media_check() {
    local number="$1"
    local output_file="$RESULT_DIR/social_${number}.txt"
    
    echo -e "${CYAN}[*] ${USER_NAME}, checking social media footprint...${RESET}"
    echo ""
    
    {
        echo "========================================"
        echo "    SOCIAL MEDIA FOOTPRINT CHECK"
        echo "========================================"
        echo "  Operator : $USER_NAME"
        echo "  Target   : $number"
        echo "  Date     : $(date)"
        echo "========================================"
    } > "$output_file"
    
    local platforms=("WhatsApp" "Telegram" "Viber" "Signal" "Truecaller")
    
    for platform in "${platforms[@]}"; do
        echo -e "  ${YELLOW}[+] Checking ${platform}...${RESET}"
        
        case "$platform" in
            "WhatsApp")
                local wa_status=$(curl -s -o /dev/null -w "%{http_code}" "https://wa.me/${number//+/}" 2>/dev/null)
                if [ "$wa_status" = "200" ] || [ "$wa_status" = "302" ]; then
                    echo -e "  ${GREEN}  [✓] WhatsApp: Likely registered${RESET}"
                    echo "  WhatsApp: Likely registered (HTTP $wa_status)" >> "$output_file"
                else
                    echo -e "  ${RED}  [✗] WhatsApp: Not found or private${RESET}"
                    echo "  WhatsApp: Not found (HTTP $wa_status)" >> "$output_file"
                fi
                ;;
            "Telegram")
                local tg_status=$(curl -s -o /dev/null -w "%{http_code}" "https://t.me/${number//+/}" 2>/dev/null)
                echo "  Telegram: HTTP Status $tg_status" >> "$output_file"
                echo -e "  ${YELLOW}  [~] Telegram: Check manually${RESET}"
                ;;
            *)
                echo -e "  ${YELLOW}  [~] ${platform}: Manual check required${RESET}"
                echo "  ${platform}: Requires manual check" >> "$output_file"
                ;;
        esac
        sleep 1
    done
    
    echo ""
    echo -e "${GREEN}  [✓] Results saved: $output_file${RESET}"
}

# ============== MODULE 5: Contacts Lookup ==============
termux_contacts_lookup() {
    local number="$1"
    
    echo -e "${CYAN}[*] ${USER_NAME}, searching device contacts...${RESET}"
    echo ""
    
    if command -v termux-contact-list &>/dev/null; then
        echo -e "${YELLOW}  [+] Fetching contact list...${RESET}"
        
        local contacts=$(termux-contact-list 2>/dev/null)
        
        if [ -n "$contacts" ]; then
            local match_count=0
            
            echo "$contacts" | jq -r '.[] | "\(.name) - \(.number)"' 2>/dev/null | while read -r line; do
                if echo "$line" | grep -qi "$number"; then
                    echo -e "${GREEN}  [✓] MATCH FOUND: $line${RESET}"
                    match_count=$((match_count + 1))
                fi
            done
            
            local total_matches=$(echo "$contacts" | jq -r '.[] | .number' 2>/dev/null | grep -c "$number")
            
            if [ "$total_matches" -eq 0 ]; then
                echo -e "${RED}  [✗] Number not found in device contacts${RESET}"
            else
                echo -e "${GREEN}  [✓] Found $total_matches match(es)${RESET}"
            fi
        else
            echo -e "${RED}  [✗] Could not retrieve contacts${RESET}"
            echo -e "${YELLOW}  [!] Grant Termux:API contacts permission${RESET}"
        fi
    else
        echo -e "${RED}  [✗] termux-api not installed${RESET}"
        echo -e "${YELLOW}  [!] Install: pkg install termux-api${RESET}"
        echo -e "${YELLOW}  [!] Also install Termux:API app from F-Droid${RESET}"
    fi
}

# ============== MODULE 6: Device SIM Info ==============
device_sim_info() {
    echo -e "${CYAN}[*] ${USER_NAME}, fetching device SIM information...${RESET}"
    echo ""
    
    if command -v termux-telephony-deviceinfo &>/dev/null; then
        echo -e "${GREEN}  ┌─────────────────────────────────────┐${RESET}"
        echo -e "${GREEN}  │       DEVICE TELEPHONY INFO         │${RESET}"
        echo -e "${GREEN}  │       User: ${WHITE}${USER_NAME}${GREEN}${RESET}"
        echo -e "${GREEN}  ├─────────────────────────────────────┤${RESET}"
        
        local device_info=$(termux-telephony-deviceinfo 2>/dev/null)
        
        if [ -n "$device_info" ]; then
            echo "$device_info" | jq -r 'to_entries[] | "  │  \(.key): \(.value)"' 2>/dev/null
            echo -e "${GREEN}  └─────────────────────────────────────┘${RESET}"
            
            echo "$device_info" | jq '.' > "$RESULT_DIR/device_sim_info.txt" 2>/dev/null
            echo -e "${GREEN}  [✓] Saved to: $RESULT_DIR/device_sim_info.txt${RESET}"
        else
            echo -e "${RED}  │  Could not retrieve info           │${RESET}"
            echo -e "${GREEN}  └─────────────────────────────────────┘${RESET}"
        fi
        
        echo ""
        echo -e "${YELLOW}  [+] Fetching cell info...${RESET}"
        local cell_info=$(termux-telephony-cellinfo 2>/dev/null)
        if [ -n "$cell_info" ]; then
            echo "$cell_info" | jq '.[0]' 2>/dev/null
            echo "$cell_info" > "$RESULT_DIR/cell_info.txt" 2>/dev/null
        fi
    else
        echo -e "${RED}  [✗] termux-api not available${RESET}"
        echo -e "${YELLOW}  [!] Install Termux:API from F-Droid${RESET}"
    fi
}

# ============== MODULE 7: Generate Full Report ==============
generate_report() {
    local number="$1"
    local report_file="$RESULT_DIR/FULL_REPORT_${number}_$(date +%Y%m%d_%H%M%S).txt"
    
    echo -e "${CYAN}[*] ${USER_NAME}, generating comprehensive report...${RESET}"
    echo ""
    
    {
        echo "╔══════════════════════════════════════════════════════╗"
        echo "║           COMPREHENSIVE TRACKING REPORT             ║"
        echo "╠══════════════════════════════════════════════════════╣"
        echo "║  Operator      : $USER_NAME"
        echo "║  Target Number : $number"
        echo "║  Report Date   : $(date)"
        echo "║  Generated By  : SIM Tracker v3.0"
        echo "╚══════════════════════════════════════════════════════╝"
        echo ""
        
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "  SECTION 1: PHONE NUMBER ANALYSIS"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        
        python3 << PYEOF 2>/dev/null
import phonenumbers
from phonenumbers import carrier, geocoder, timezone

try:
    number = "$number"
    if not number.startswith('+'):
        number = '+' + number
    phone = phonenumbers.parse(number)
    
    print(f"  Number (Intl)  : {phonenumbers.format_number(phone, phonenumbers.PhoneNumberFormat.INTERNATIONAL)}")
    print(f"  Number (E164)  : {phonenumbers.format_number(phone, phonenumbers.PhoneNumberFormat.E164)}")
    print(f"  Valid          : {phonenumbers.is_valid_number(phone)}")
    print(f"  Country Code   : +{phone.country_code}")
    print(f"  Region         : {geocoder.description_for_number(phone, 'en')}")
    print(f"  Carrier        : {carrier.name_for_number(phone, 'en')}")
    print(f"  Timezone       : {', '.join(timezone.time_zones_for_number(phone))}")
    
    type_map = {0:"FIXED_LINE",1:"MOBILE",2:"FIXED_LINE_OR_MOBILE",3:"TOLL_FREE",
                4:"PREMIUM_RATE",5:"SHARED_COST",6:"VOIP",7:"PERSONAL",8:"PAGER"}
    print(f"  Line Type      : {type_map.get(phonenumbers.number_type(phone), 'UNKNOWN')}")
except Exception as e:
    print(f"  Error: {e}")
PYEOF
        
        echo ""
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "  SECTION 2: SOCIAL MEDIA CHECK"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        
        local clean_number="${number//+/}"
        local wa_check=$(curl -s -o /dev/null -w "%{http_code}" "https://wa.me/${clean_number}" 2>/dev/null)
        echo "  WhatsApp       : HTTP $wa_check"
        
        echo ""
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "  SECTION 3: DEVICE CONTACTS MATCH"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        
        if command -v termux-contact-list &>/dev/null; then
            termux-contact-list 2>/dev/null | jq -r '.[] | select(.number | contains("'"$number"'")) | "  Match: \(.name) - \(.number)"' 2>/dev/null
        else
            echo "  [!] Termux:API not available"
        fi
        
        echo ""
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "  REPORT GENERATED BY: $USER_NAME"
        echo "  END OF REPORT"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        
    } > "$report_file"
    
    echo -e "${GREEN}  [✓] Full report saved to:${RESET}"
    echo -e "${WHITE}  $report_file${RESET}"
    echo ""
    echo -ne "${YELLOW}  View report? (y/n): ${RESET}"
    read -r view_choice
    if [[ "$view_choice" =~ ^[Yy]$ ]]; then
        echo -e "${CYAN}"
        cat "$report_file"
        echo -e "${RESET}"
    fi
}

# ============== MODULE 8: Bulk Lookup ==============
bulk_lookup() {
    echo -e "${CYAN}[*] ${USER_NAME} - Bulk Number Lookup${RESET}"
    echo -e "${YELLOW}  Enter path to file (one number per line):${RESET}"
    read -r file_path
    
    if [ ! -f "$file_path" ]; then
        echo -e "${RED}  [✗] File not found: $file_path${RESET}"
        return 1
    fi
    
    local count=0
    local total=$(wc -l < "$file_path")
    
    echo -e "${CYAN}  [*] Processing $total numbers...${RESET}"
    echo ""
    
    while IFS= read -r line; do
        count=$((count + 1))
        local number=$(echo "$line" | tr -d '[:space:]')
        
        if [ -z "$number" ] || [[ "$number" == \#* ]]; then
            continue
        fi
        
        echo -e "${YELLOW}  [$count/$total] Processing: $number${RESET}"
        
        python3 << PYEOF 2>/dev/null
import phonenumbers
from phonenumbers import carrier, geocoder

try:
    number = "$number"
    if not number.startswith('+'):
        number = '+' + number
    phone = phonenumbers.parse(number)
    region = geocoder.description_for_number(phone, 'en')
    carr = carrier.name_for_number(phone, 'en')
    valid = phonenumbers.is_valid_number(phone)
    print(f"    → Valid: {valid} | Region: {region} | Carrier: {carr}")
except Exception as e:
    print(f"    → Error: {e}")
PYEOF
        
        sleep 0.5
    done < "$file_path"
    
    echo ""
    echo -e "${GREEN}  [✓] Bulk lookup complete, ${USER_NAME}!${RESET}"
}

# ============== MODULE 9: Call/SMS Logs ==============
device_logs() {
    echo -e "${CYAN}[*] ${USER_NAME} - Device Call/SMS Logs${RESET}"
    echo ""
    
    echo -e "  ${WHITE}1)${RESET} View Call Log"
    echo -e "  ${WHITE}2)${RESET} View SMS Inbox"
    echo -e "  ${WHITE}3)${RESET} Search logs by number"
    echo -e "  ${WHITE}4)${RESET} Back"
    echo ""
    echo -ne "${GREEN}  Select [1-4]: ${RESET}"
    read -r log_choice
    
    case "$log_choice" in
        1)
            echo -e "${YELLOW}  [+] Fetching call log...${RESET}"
            if command -v termux-call-log &>/dev/null; then
                termux-call-log -l 20 2>/dev/null | jq -r '.[] | "  \(.date) | \(.name // "Unknown") | \(.number) | \(.type) | \(.duration)s"' 2>/dev/null
            else
                echo -e "${RED}  [✗] termux-api required${RESET}"
            fi
            ;;
        2)
            echo -e "${YELLOW}  [+] Fetching SMS inbox...${RESET}"
            if command -v termux-sms-list &>/dev/null; then
                termux-sms-list -l 20 2>/dev/null | jq -r '.[] | "  \(.received) | \(.number) | \(.body[0:50])..."' 2>/dev/null
            else
                echo -e "${RED}  [✗] termux-api required${RESET}"
            fi
            ;;
        3)
            echo -ne "${YELLOW}  Enter number to search: ${RESET}"
            read -r search_num
            echo -e "${YELLOW}  [+] Searching...${RESET}"
            
            if command -v termux-call-log &>/dev/null; then
                echo -e "${CYAN}  --- Call Log Matches ---${RESET}"
                termux-call-log -l 100 2>/dev/null | jq -r '.[] | select(.number | contains("'"$search_num"'")) | "  \(.date) | \(.name // "Unknown") | \(.number) | \(.type)"' 2>/dev/null
            fi
            
            if command -v termux-sms-list &>/dev/null; then
                echo -e "${CYAN}  --- SMS Matches ---${RESET}"
                termux-sms-list -l 100 2>/dev/null | jq -r '.[] | select(.number | contains("'"$search_num"'")) | "  \(.received) | \(.number) | \(.body[0:80])"' 2>/dev/null
            fi
            ;;
        4) return ;;
    esac
}

# ============== MODULE 10: API Key Config ==============
configure_api_keys() {
    echo -e "${CYAN}[*] ${USER_NAME} - API Key Configuration${RESET}"
    echo ""
    echo -e "  ${WHITE}1)${RESET} NumVerify API Key     (numverify.com)"
    echo -e "  ${WHITE}2)${RESET} Abstract API Key      (abstractapi.com)"
    echo -e "  ${WHITE}3)${RESET} Truecaller API Key    (truecaller.com)"
    echo -e "  ${WHITE}4)${RESET} View current keys"
    echo -e "  ${WHITE}5)${RESET} Back to main menu"
    echo ""
    echo -ne "${GREEN}  Select [1-5]: ${RESET}"
    read -r api_choice
    
    case "$api_choice" in
        1)
            echo -ne "${YELLOW}  Enter NumVerify API Key: ${RESET}"
            read -r key
            # Remove old key and add new
            [ -f "$API_CONFIG" ] && sed -i '/NUMVERIFY_KEY/d' "$API_CONFIG"
            echo "NUMVERIFY_KEY=\"$key\"" >> "$API_CONFIG"
            echo -e "${GREEN}  [✓] NumVerify key saved!${RESET}"
            ;;
        2)
            echo -ne "${YELLOW}  Enter Abstract API Key: ${RESET}"
            read -r key
            [ -f "$API_CONFIG" ] && sed -i '/ABSTRACT_KEY/d' "$API_CONFIG"
            echo "ABSTRACT_KEY=\"$key\"" >> "$API_CONFIG"
            echo -e "${GREEN}  [✓] Abstract API key saved!${RESET}"
            ;;
        3)
            echo -ne "${YELLOW}  Enter Truecaller API Key: ${RESET}"
            read -r key
            [ -f "$API_CONFIG" ] && sed -i '/TRUECALLER_KEY/d' "$API_CONFIG"
            echo "TRUECALLER_KEY=\"$key\"" >> "$API_CONFIG"
            echo -e "${GREEN}  [✓] Truecaller key saved!${RESET}"
            ;;
        4)
            if [ -f "$API_CONFIG" ]; then
                echo -e "${CYAN}"
                cat "$API_CONFIG"
                echo -e "${RESET}"
            else
                echo -e "${RED}  [!] No API keys configured${RESET}"
            fi
            ;;
        5) return ;;
    esac
}

# ============== MODULE 11: Username Search from Number ==============
search_username_from_number() {
    local number="$1"
    local output_file="$RESULT_DIR/username_search_${number}.txt"
    
    echo -e "${CYAN}[*] ${USER_NAME}, searching for usernames linked to: ${WHITE}$number${RESET}"
    echo ""
    
    {
        echo "╔══════════════════════════════════════════════════╗"
        echo "║        USERNAME / IDENTITY SEARCH               ║"
        echo "╠══════════════════════════════════════════════════╣"
        echo "║  Operator : $USER_NAME"
        echo "║  Target   : $number"
        echo "║  Date     : $(date)"
        echo "╚══════════════════════════════════════════════════╝"
        echo ""
    } > "$output_file"
    
    # --- Method 1: Device Contacts Name ---
    echo -e "  ${YELLOW}[1/5] Checking device contacts...${RESET}"
    if command -v termux-contact-list &>/dev/null; then
        local contact_name=$(termux-contact-list 2>/dev/null | jq -r '.[] | select(.number | contains("'"$number"'")) | .name' 2>/dev/null)
        if [ -n "$contact_name" ]; then
            echo -e "  ${GREEN}  [✓] Contact Name: ${WHITE}${BOLD}$contact_name${RESET}"
            echo "  Contact Name : $contact_name" >> "$output_file"
        else
            echo -e "  ${RED}  [✗] Not found in contacts${RESET}"
            echo "  Contact Name : Not found" >> "$output_file"
        fi
    else
        echo -e "  ${YELLOW}  [!] termux-api needed${RESET}"
    fi
    
    # --- Method 2: WhatsApp Check ---
    echo -e "  ${YELLOW}[2/5] Checking WhatsApp...${RESET}"
    local clean_num="${number//+/}"
    local wa_check=$(curl -s -o /dev/null -w "%{http_code}" "https://wa.me/${clean_num}" 2>/dev/null)
    if [ "$wa_check" = "200" ] || [ "$wa_check" = "302" ]; then
        echo -e "  ${GREEN}  [✓] WhatsApp: Account exists (name visible in app)${RESET}"
        echo "  WhatsApp     : Account exists" >> "$output_file"
    else
        echo -e "  ${RED}  [✗] WhatsApp: Not registered${RESET}"
        echo "  WhatsApp     : Not found" >> "$output_file"
    fi
    
    # --- Method 3: Telegram Check ---
    echo -e "  ${YELLOW}[3/5] Checking Telegram...${RESET}"
    local tg_check=$(curl -s -o /dev/null -w "%{http_code}" "https://t.me/+${clean_num}" 2>/dev/null)
    echo "  Telegram     : HTTP $tg_check" >> "$output_file"
    echo -e "  ${YELLOW}  [~] Telegram: HTTP Status $tg_check${RESET}"
    
    # --- Method 4: Caller ID Services ---
    echo -e "  ${YELLOW}[4/5] Checking caller ID services...${RESET}"
    echo -e "  ${YELLOW}  [~] Truecaller: Open https://www.truecaller.com/search/${clean_num}${RESET}"
    echo "  Truecaller   : https://www.truecaller.com/search/${clean_num}" >> "$output_file"
    echo -e "  ${YELLOW}  [~] Sync.me   : Open https://sync.me/search/?number=${clean_num}${RESET}"
    echo "  Sync.me      : https://sync.me/search/?number=${clean_num}" >> "$output_file"
    
    # --- Method 5: Phonenumbers Library ---
    echo -e "  ${YELLOW}[5/5] Analyzing number identity...${RESET}"
    
    python3 << PYEOF 2>/dev/null
import phonenumbers
from phonenumbers import carrier, geocoder

try:
    number = "$number"
    if not number.startswith('+'):
        number = '+' + number
    phone = phonenumbers.parse(number)
    
    carr = carrier.name_for_number(phone, 'en')
    loc = geocoder.description_for_number(phone, 'en')
    
    print(f"    Carrier   : {carr if carr else 'Unknown'}")
    print(f"    Region    : {loc if loc else 'Unknown'}")
    
    with open("$output_file", "a") as f:
        f.write(f"  Carrier      : {carr if carr else 'Unknown'}\n")
        f.write(f"  Region       : {loc if loc else 'Unknown'}\n")
        
except Exception as e:
    print(f"    Error: {e}")
PYEOF

    echo ""
    echo -e "  ${CYAN}╔══════════════════════════════════════════╗${RESET}"
    echo -e "  ${CYAN}║  ${WHITE}Additional Manual Lookup URLs:${CYAN}          ║${RESET}"
    echo -e "  ${CYAN}╠══════════════════════════════════════════╣${RESET}"
    echo -e "  ${CYAN}║${RESET}  ${YELLOW}Truecaller:${RESET}"
    echo -e "  ${CYAN}║${RESET}  ${WHITE}https://www.truecaller.com/search/${clean_num}${RESET}"
    echo -e "  ${CYAN}║${RESET}  ${YELLOW}Sync.me:${RESET}"
    echo -e "  ${CYAN}║${RESET}  ${WHITE}https://sync.me/search/?number=${clean_num}${RESET}"
    echo -e "  ${CYAN}║${RESET}  ${YELLOW}WhatsApp:${RESET}"
    echo -e "  ${CYAN}║${RESET}  ${WHITE}https://wa.me/${clean_num}${RESET}"
    echo -e "  ${CYAN}║${RESET}  ${YELLOW}Facebook:${RESET}"
    echo -e "  ${CYAN}║${RESET}  ${WHITE}https://www.facebook.com/search/?q=${clean_num}${RESET}"
    echo -e "  ${CYAN}╚══════════════════════════════════════════╝${RESET}"
    echo ""
    echo -e "${GREEN}  [✓] Results saved: $output_file${RESET}"
}

# ============== USER MANAGEMENT MENU ==============
user_management_menu() {
    echo ""
    echo -e "  ${CYAN}╔══════════════════════════════════════════╗${RESET}"
    echo -e "  ${CYAN}║         ${WHITE}USER MANAGEMENT${CYAN}                  ║${RESET}"
    echo -e "  ${CYAN}╠══════════════════════════════════════════╣${RESET}"
    echo -e "  ${CYAN}║${RESET}  ${WHITE}1)${RESET} View My Profile                    ${CYAN}║${RESET}"
    echo -e "  ${CYAN}║${RESET}  ${WHITE}2)${RESET} Change Username                    ${CYAN}║${RESET}"
    echo -e "  ${CYAN}║${RESET}  ${WHITE}3)${RESET} View Session Info                  ${CYAN}║${RESET}"
    echo -e "  ${CYAN}║${RESET}  ${WHITE}4)${RESET} Reset Profile                      ${CYAN}║${RESET}"
    echo -e "  ${CYAN}║${RESET}  ${WHITE}5)${RESET} Back to Main Menu                  ${CYAN}║${RESET}"
    echo -e "  ${CYAN}╚══════════════════════════════════════════╝${RESET}"
    echo ""
    echo -ne "  ${GREEN}Select [1-5]: ${RESET}"
    read -r user_choice
    
    case "$user_choice" in
        1)
            show_user_profile
            ;;
        2)
            change_username
            ;;
        3)
            echo ""
            echo -e "  ${CYAN}━━━ SESSION INFO ━━━${RESET}"
            echo -e "  ${YELLOW}User       :${RESET} ${WHITE}${BOLD}${USER_NAME}${RESET}"
            echo -e "  ${YELLOW}Started    :${RESET} ${WHITE}$(date -d @$USER_SESSION_START 2>/dev/null || date)${RESET}"
            local current=$(date +%s)
            local dur=$((current - USER_SESSION_START))
            echo -e "  ${YELLOW}Duration   :${RESET} ${WHITE}$((dur/3600))h $((dur%3600/60))m $((dur%60))s${RESET}"
            echo -e "  ${YELLOW}Shell      :${RESET} ${WHITE}${SHELL}${RESET}"
            echo -e "  ${YELLOW}Terminal   :${RESET} ${WHITE}${TERM}${RESET}"
            echo -e "  ${YELLOW}PID        :${RESET} ${WHITE}$$${RESET}"
            ;;
        4)
            echo -ne "  ${RED}Are you sure you want to reset profile? (y/n): ${RESET}"
            read -r confirm
            if [[ "$confirm" =~ ^[Yy]$ ]]; then
                rm -f "$CONFIG_FILE"
                echo -e "  ${GREEN}[✓] Profile reset! Restart the tool.${RESET}"
                sleep 2
                exec "$0"
            fi
            ;;
        5) return ;;
    esac
}

# ============== MAIN MENU ==============
main_menu() {
    while true; do
        show_banner
        
        echo -e "  ${WHITE}╔══════════════════════════════════════════╗${RESET}"
        echo -e "  ${WHITE}║${RESET}  ${CYAN}[01]${RESET} Phone Number Analysis             ${WHITE}║${RESET}"
        echo -e "  ${WHITE}║${RESET}  ${CYAN}[02]${RESET} OSINT Lookup                      ${WHITE}║${RESET}"
        echo -e "  ${WHITE}║${RESET}  ${CYAN}[03]${RESET} Carrier / HLR Lookup              ${WHITE}║${RESET}"
        echo -e "  ${WHITE}║${RESET}  ${CYAN}[04]${RESET} Social Media Footprint            ${WHITE}║${RESET}"
        echo -e "  ${WHITE}║${RESET}  ${CYAN}[05]${RESET} Device Contacts Search            ${WHITE}║${RESET}"
        echo -e "  ${WHITE}║${RESET}  ${CYAN}[06]${RESET} Device SIM Info                   ${WHITE}║${RESET}"
        echo -e "  ${WHITE}║${RESET}  ${CYAN}[07]${RESET} Generate Full Report              ${WHITE}║${RESET}"
        echo -e "  ${WHITE}║${RESET}  ${CYAN}[08]${RESET} Bulk Number Lookup                ${WHITE}║${RESET}"
        echo -e "  ${WHITE}║${RESET}  ${CYAN}[09]${RESET} Device Call/SMS Logs              ${WHITE}║${RESET}"
        echo -e "  ${WHITE}║${RESET}  ${CYAN}[10]${RESET} Configure API Keys                ${WHITE}║${RESET}"
        echo -e "  ${WHITE}║${RESET}  ${MAGENTA}[11]${RESET} ${MAGENTA}Search Username from Number${RESET}      ${WHITE}║${RESET}"
        echo -e "  ${WHITE}║${RESET}  ${MAGENTA}[12]${RESET} ${MAGENTA}User Profile / Management${RESET}        ${WHITE}║${RESET}"
        echo -e "  ${WHITE}║${RESET}  ${YELLOW}[13]${RESET} Setup / Install Dependencies     ${WHITE}║${RESET}"
        echo -e "  ${WHITE}║${RESET}  ${RED}[00]${RESET} Exit                              ${WHITE}║${RESET}"
        echo -e "  ${WHITE}╚══════════════════════════════════════════╝${RESET}"
        echo ""
        echo -ne "  ${GREEN}${USER_NAME}@sim-tracker${RESET}${WHITE} > ${RESET}"
        read -r choice
        
        case "$choice" in
            1|01)
                echo ""
                echo -ne "  ${YELLOW}Enter phone number (e.g., +1234567890): ${RESET}"
                read -r target_number
                target_number=$(validate_phone "$target_number")
                if [ $? -eq 0 ] && [ -n "$target_number" ]; then
                    echo ""
                    phone_number_lookup "$target_number"
                else
                    echo -e "  ${RED}[✗] Invalid phone number format${RESET}"
                fi
                ;;
            2|02)
                echo ""
                echo -ne "  ${YELLOW}Enter phone number: ${RESET}"
                read -r target_number
                target_number=$(validate_phone "$target_number")
                if [ $? -eq 0 ] && [ -n "$target_number" ]; then
                    osint_lookup "$target_number"
                else
                    echo -e "  ${RED}[✗] Invalid phone number${RESET}"
                fi
                ;;
            3|03)
                echo ""
                echo -ne "  ${YELLOW}Enter phone number: ${RESET}"
                read -r target_number
                target_number=$(validate_phone "$target_number")
                if [ $? -eq 0 ] && [ -n "$target_number" ]; then
                    hlr_lookup "$target_number"
                else
                    echo -e "  ${RED}[✗] Invalid phone number${RESET}"
                fi
                ;;
            4|04)
                echo ""
                echo -ne "  ${YELLOW}Enter phone number: ${RESET}"
                read -r target_number
                target_number=$(validate_phone "$target_number")
                if [ $? -eq 0 ] && [ -n "$target_number" ]; then
                    social_media_check "$target_number"
                else
                    echo -e "  ${RED}[✗] Invalid phone number${RESET}"
                fi
                ;;
            5|05)
                echo ""
                echo -ne "  ${YELLOW}Enter phone number to search: ${RESET}"
                read -r target_number
                termux_contacts_lookup "$target_number"
                ;;
            6|06)
                device_sim_info
                ;;
            7|07)
                echo ""
                echo -ne "  ${YELLOW}Enter phone number: ${RESET}"
                read -r target_number
                target_number=$(validate_phone "$target_number")
                if [ $? -eq 0 ] && [ -n "$target_number" ]; then
                    generate_report "$target_number"
                else
                    echo -e "  ${RED}[✗] Invalid phone number${RESET}"
                fi
                ;;
            8|08)
                bulk_lookup
                ;;
            9|09)
                device_logs
                ;;
            10)
                configure_api_keys
                ;;
            11)
                echo ""
                echo -ne "  ${YELLOW}Enter phone number: ${RESET}"
                read -r target_number
                target_number=$(validate_phone "$target_number")
                if [ $? -eq 0 ] && [ -n "$target_number" ]; then
                    search_username_from_number "$target_number"
                else
                    echo -e "  ${RED}[✗] Invalid phone number${RESET}"
                fi
                ;;
            12)
                user_management_menu
                ;;
            13)
                setup_environment
                ;;
            0|00)
                echo ""
                echo -e "  ${GREEN}╔══════════════════════════════════════════╗${RESET}"
                echo -e "  ${GREEN}║                                          ║${RESET}"
                echo -e "  ${GREEN}║  ${WHITE}Goodbye, ${CYAN}${BOLD}${USER_NAME}${RESET}${WHITE}!${GREEN}                       ║${RESET}"
                echo -e "  ${GREEN}║  ${WHITE}Thanks for using SIM Tracker v3.0${GREEN}      ║${RESET}"
                echo -e "  ${GREEN}║  ${DIM}Session ended: $(date '+%H:%M:%S')${RESET}${GREEN}              ║${RESET}"
                echo -e "  ${GREEN}║                                          ║${RESET}"
                echo -e "  ${GREEN}╚══════════════════════════════════════════╝${RESET}"
                echo ""
                
                # Log session
                if [ -n "$USER_SESSION_START" ]; then
                    local end_time=$(date +%s)
                    local session_dur=$((end_time - USER_SESSION_START))
                    echo "[$(date)] User '$USER_NAME' session ended. Duration: ${session_dur}s" >> "$LOG_FILE"
                fi
                
                exit 0
                ;;
            *)
                echo -e "  ${RED}[✗] Invalid option, ${USER_NAME}!${RESET}"
                ;;
        esac
        
        echo ""
        echo -ne "  ${YELLOW}${USER_NAME}, press [Enter] to continue...${RESET}"
        read -r
    done
}

# ============== ENTRY POINT ==============

# Create directories
mkdir -p "$RESULT_DIR"

# Check Termux environment
if [ -d "/data/data/com.termux" ] || [ -n "$TERMUX_VERSION" ]; then
    echo -e "${GREEN}[✓] Termux environment detected${RESET}"
else
    echo -e "${YELLOW}[!] Warning: Not running in Termux. Some features may not work.${RESET}"
fi

# Get/Load username FIRST
get_username

# Log session start
echo "[$(date)] User '$USER_NAME' started SIM Tracker" >> "$LOG_FILE"

# Increment login count
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
    local_count=$((${LOGIN_COUNT:-0} + 1))
    sed -i "s/LOGIN_COUNT=.*/LOGIN_COUNT=$local_count/" "$CONFIG_FILE" 2>/dev/null
fi

# Start main menu
main_menu
