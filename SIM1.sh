#!/bin/bash

#====================================================
# SIM/Contact Tracker Tool for Termux
# Author: Emmanuel Suah
# Version: 2.1
# Description: Lookup publicly available info
#              associated with a phone number
#              NOW WITH USERNAME LOOKUP!
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

# ============== DIRECTORIES ==============
RESULT_DIR="$HOME/sim_tracker_results"
LOG_FILE="$RESULT_DIR/tracker.log"

# ============== SETUP ==============
setup_environment() {
    echo -e "${CYAN}[*] Setting up environment...${RESET}"
    
    # Create results directory
    mkdir -p "$RESULT_DIR"
    
    # Install required packages
    local packages=("curl" "jq" "python" "git" "wget" "dnsutils" "nmap" "termux-api")
    
    for pkg in "${packages[@]}"; do
        if ! command -v "$pkg" &>/dev/null; then
            echo -e "${YELLOW}[+] Installing $pkg...${RESET}"
            pkg install -y "$pkg" 2>/dev/null
        fi
    done
    
    # Install Python packages
    pip install requests phonenumbers 2>/dev/null
    
    echo -e "${GREEN}[✓] Environment ready!${RESET}"
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
  ║        SIM / Contact Tracker v2.1            ║
  ║        WITH USERNAME LOOKUP! 🆕             ║
  ║        Educational Purpose Only              ║
  ╚══════════════════════════════════════════════╝
EOF
    echo -e "${RESET}"
    echo -e "${YELLOW}  ⚠  For authorized & legal use only!${RESET}"
    echo -e "${CYAN}  ─────────────────────────────────────${RESET}"
    echo ""
}

# ============== INPUT VALIDATION ==============
validate_phone() {
    local number="$1"
    # Remove spaces, dashes, parentheses
    number=$(echo "$number" | sed 's/[[:space:]()-]//g')
    
    # Check if it starts with + or is all digits
    if [[ "$number" =~ ^\+?[0-9]{7,15}$ ]]; then
        echo "$number"
        return 0
    else
        return 1
    fi
}

# ============== NEW MODULE: Username/Contact Name Lookup ==============
username_lookup() {
    local number="$1"
    local output_file="$RESULT_DIR/username_${number}.txt"
    
    echo -e "${CYAN}[*] Performing Username/Contact Name Lookup...${RESET}"
    echo -e "${CYAN}[*] Searching across multiple sources...${RESET}"
    echo ""
    
    {
        echo "╔════════════════════════════════════════════════════════╗"
        echo "║         USERNAME & CONTACT NAME LOOKUP REPORT          ║"
        echo "╠════════════════════════════════════════════════════════╣"
        echo "║  Target Number : $number"
        echo "║  Query Date    : $(date)"
        echo "╚════════════════════════════════════════════════════════╝"
        echo ""
    } > "$output_file"
    
    # --- Source 1: Device Contacts ---
    echo -e "${YELLOW}  [+] Checking device contacts...${RESET}"
    if command -v termux-contact-list &>/dev/null; then
        local contact_name=$(termux-contact-list 2>/dev/null | jq -r ".[] | select(.number | contains(\"$(echo $number | sed 's/[+]//g')\")) | .name" 2>/dev/null | head -1)
        
        if [ -n "$contact_name" ] && [ "$contact_name" != "null" ]; then
            echo -e "${GREEN}  [✓] MATCH FOUND IN CONTACTS!${RESET}"
            echo -e "${GREEN}    Name: ${WHITE}${contact_name}${RESET}"
            {
                echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                echo "  SOURCE 1: DEVICE CONTACTS"
                echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                echo "  Status    : FOUND ✓"
                echo "  Contact Name : ${contact_name}"
                echo ""
            } >> "$output_file"
        else
            echo -e "${RED}  [✗] Not found in device contacts${RESET}"
            echo "  Source 1 (Device Contacts): NOT FOUND" >> "$output_file"
        fi
    else
        echo -e "${YELLOW}  [!] Termux:API not available for contact lookup${RESET}"
        echo "  Source 1 (Device Contacts): SKIPPED (Termux:API not installed)" >> "$output_file"
    fi
    
    # --- Source 2: WhatsApp ---
    echo -e "${YELLOW}  [+] Checking WhatsApp...${RESET}"
    {
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "  SOURCE 2: WHATSAPP"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    } >> "$output_file"
    
    local wa_clean="${number//+/}"
    local wa_status=$(curl -s -o /dev/null -w "%{http_code}" "https://wa.me/${wa_clean}" 2>/dev/null)
    
    if [ "$wa_status" = "200" ] || [ "$wa_status" = "302" ]; then
        echo -e "${GREEN}  [✓] WhatsApp account likely registered${RESET}"
        echo "  Status    : REGISTERED (HTTP $wa_status)" >> "$output_file"
        echo "  Note      : To retrieve WhatsApp username, manual check needed" >> "$output_file"
    else
        echo -e "${RED}  [✗] Not registered on WhatsApp${RESET}"
        echo "  Status    : NOT FOUND (HTTP $wa_status)" >> "$output_file"
    fi
    echo "" >> "$output_file"
    
    # --- Source 3: Truecaller ---
    echo -e "${YELLOW}  [+] Checking Truecaller...${RESET}"
    {
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "  SOURCE 3: TRUECALLER"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    } >> "$output_file"
    
    # Truecaller free API
    local truecaller_result=$(curl -s "https://api5.truecaller.com/v1/search?q=${number}&countryCode=US&type=4&locAddr=&directoryId=&method=findUsersByPhoneNumber" \
        -H "Authorization: Bearer TrueCaller" 2>/dev/null)
    
    if echo "$truecaller_result" | jq -e '.data' &>/dev/null 2>/dev/null; then
        local tc_name=$(echo "$truecaller_result" | jq -r '.data[0].name' 2>/dev/null)
        local tc_type=$(echo "$truecaller_result" | jq -r '.data[0].phoneNumberType' 2>/dev/null)
        
        if [ -n "$tc_name" ] && [ "$tc_name" != "null" ]; then
            echo -e "${GREEN}  [✓] Truecaller Name Found!${RESET}"
            echo -e "${GREEN}    Name: ${WHITE}${tc_name}${RESET}"
            echo "  Name      : ${tc_name}" >> "$output_file"
            echo "  Type      : ${tc_type}" >> "$output_file"
        fi
    else
        echo -e "${YELLOW}  [~] Requires Truecaller API key for detailed lookup${RESET}"
        echo "  Note      : Requires valid Truecaller API key" >> "$output_file"
    fi
    echo "" >> "$output_file"
    
    # --- Source 4: Telegram ---
    echo -e "${YELLOW}  [+] Checking Telegram...${RESET}"
    {
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "  SOURCE 4: TELEGRAM"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    } >> "$output_file"
    
    echo -e "${YELLOW}    [Note] Telegram requires manual username search${RESET}"
    echo "  Status    : REQUIRES MANUAL CHECK" >> "$output_file"
    echo "  Method    : Search number directly in Telegram app" >> "$output_file"
    echo "" >> "$output_file"
    
    # --- Source 5: Facebook ---
    echo -e "${YELLOW}  [+] Checking Facebook...${RESET}"
    {
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "  SOURCE 5: FACEBOOK"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    } >> "$output_file"
    
    local fb_clean="${number//+/}"
    # Facebook phone reverse lookup (limited without auth)
    echo "  Status    : REQUIRES AUTHENTICATION" >> "$output_file"
    echo "  Note      : Facebook phone lookup requires account login" >> "$output_file"
    echo "" >> "$output_file"
    
    # --- Source 6: Instagram ---
    echo -e "${YELLOW}  [+] Checking Instagram...${RESET}"
    {
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "  SOURCE 6: INSTAGRAM"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    } >> "$output_file"
    
    echo "  Status    : REQUIRES AUTHENTICATION" >> "$output_file"
    echo "  Note      : Instagram phone lookup requires account login" >> "$output_file"
    echo "" >> "$output_file"
    
    # --- Source 7: LinkedIn ---
    echo -e "${YELLOW}  [+] Checking LinkedIn...${RESET}"
    {
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "  SOURCE 7: LINKEDIN"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    } >> "$output_file"
    
    echo "  Status    : REQUIRES AUTHENTICATION" >> "$output_file"
    echo "  Note      : LinkedIn reverse phone lookup available to members" >> "$output_file"
    echo "" >> "$output_file"
    
    # --- Source 8: Twitter/X ---
    echo -e "${YELLOW}  [+] Checking Twitter/X...${RESET}"
    {
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "  SOURCE 8: TWITTER/X"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    } >> "$output_file"
    
    echo "  Status    : REQUIRES AUTHENTICATION" >> "$output_file"
    echo "  Note      : Twitter/X phone verification optional" >> "$output_file"
    echo "" >> "$output_file"
    
    # --- Source 9: Viber ---
    echo -e "${YELLOW}  [+] Checking Viber...${RESET}"
    {
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "  SOURCE 9: VIBER"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    } >> "$output_file"
    
    echo "  Status    : REQUIRES MANUAL CHECK" >> "$output_file"
    echo "  Note      : Viber username visibility depends on privacy settings" >> "$output_file"
    echo "" >> "$output_file"
    
    # --- Source 10: Signal ---
    echo -e "${YELLOW}  [+] Checking Signal...${RESET}"
    {
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "  SOURCE 10: SIGNAL"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    } >> "$output_file"
    
    echo "  Status    : REQUIRES MANUAL CHECK" >> "$output_file"
    echo "  Note      : Signal is privacy-focused, limited public info" >> "$output_file"
    echo "" >> "$output_file"
    
    # Summary section
    {
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "  SUMMARY & RECOMMENDATIONS"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""
        echo "  FULLY AUTOMATED SOURCES:"
        echo "    • Device Contacts (if installed)"
        echo "    • WhatsApp Registration Check"
        echo ""
        echo "  REQUIRES API KEYS:"
        echo "    • Truecaller (API required)"
        echo "    • NumVerify (API required)"
        echo ""
        echo "  REQUIRES MANUAL/LOGIN:"
        echo "    • Facebook"
        echo "    • Instagram"
        echo "    • LinkedIn"
        echo "    • Twitter/X"
        echo "    • Telegram"
        echo "    • Viber"
        echo "    • Signal"
        echo ""
        echo "  BEST PRACTICES:"
        echo "    1. Start with device contacts"
        echo "    2. Check WhatsApp registration"
        echo "    3. Use Truecaller API (if available)"
        echo "    4. Manually search social platforms"
        echo ""
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "  Report Generated: $(date)"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    } >> "$output_file"
    
    echo ""
    echo -e "${GREEN}  [✓] Username lookup complete!${RESET}"
    echo -e "${GREEN}  [✓] Results saved to: ${WHITE}$output_file${RESET}"
    echo ""
    
    # Display results
    echo -e "${CYAN}"
    cat "$output_file"
    echo -e "${RESET}"
}

# ============== NEW MODULE: Quick Name Search ==============
quick_name_search() {
    local number="$1"
    
    echo -e "${CYAN}[*] Quick Name Search for: $number${RESET}"
    echo ""
    echo -e "${YELLOW}  ┌─────────────────────────────────────┐${RESET}"
    echo -e "${YELLOW}  │      QUICK NAME LOOKUP RESULTS       │${RESET}"
    echo -e "${YELLOW}  ├─────────────────────────────────────┤${RESET}"
    
    # Check device contacts first (fastest)
    if command -v termux-contact-list &>/dev/null; then
        local matches=$(termux-contact-list 2>/dev/null | jq -r ".[] | select(.number | contains(\"$(echo $number | sed 's/[+]//g')\")) | .name" 2>/dev/null)
        
        if [ -n "$matches" ]; then
            while IFS= read -r name; do
                if [ -n "$name" ] && [ "$name" != "null" ]; then
                    echo -e "${YELLOW}  │${RESET}${GREEN}  ✓ DEVICE CONTACT: ${name}${RESET}"
                fi
            done <<< "$matches"
        fi
    fi
    
    # WhatsApp check
    local wa_status=$(curl -s -o /dev/null -w "%{http_code}" "https://wa.me/$(echo $number | sed 's/[+]//g')" 2>/dev/null)
    if [ "$wa_status" = "200" ] || [ "$wa_status" = "302" ]; then
        echo -e "${YELLOW}  │${RESET}${GREEN}  ✓ WHATSAPP: Registered${RESET}"
    fi
    
    echo -e "${YELLOW}  └─────────────────────────────────────┘${RESET}"
    echo ""
}

# ============== MODULE: Phone Number Info (Python) ==============
phone_number_lookup() {
    local number="$1"
    local output_file="$RESULT_DIR/phone_info_${number}.txt"
    
    echo -e "${CYAN}[*] Analyzing phone number: ${WHITE}$number${RESET}"
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
    
    # Number type mapping
    type_map = {
        0: "FIXED_LINE",
        1: "MOBILE", 
        2: "FIXED_LINE_OR_MOBILE",
        3: "TOLL_FREE",
        4: "PREMIUM_RATE",
        5: "SHARED_COST",
        6: "VOIP",
        7: "PERSONAL_NUMBER",
        8: "PAGER",
        9: "UAN",
        10: "VOICEMAIL",
        27: "UNKNOWN"
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

# ============== MODULE: OSINT Lookup via APIs ==============
osint_lookup() {
    local number="$1"
    local output_file="$RESULT_DIR/osint_${number}.txt"
    
    echo -e "${CYAN}[*] Running OSINT lookups...${RESET}"
    echo ""
    
    echo "========================================" > "$output_file"
    echo "       OSINT LOOKUP RESULTS" >> "$output_file"
    echo "========================================" >> "$output_file"
    echo "  Target: $number" >> "$output_file"
    echo "  Date  : $(date)" >> "$output_file"
    echo "========================================" >> "$output_file"
    
    # --- NumVerify API (Free Tier) ---
    echo -e "${YELLOW}  [+] Querying NumVerify API...${RESET}"
    local numverify_result=$(curl -s "http://apilayer.net/api/validate?access_key=YOUR_API_KEY&number=${number}&country_code=&format=1" 2>/dev/null)
    
    if echo "$numverify_result" | jq -e '.valid' &>/dev/null; then
        echo "" >> "$output_file"
        echo "--- NumVerify Results ---" >> "$output_file"
        echo "$numverify_result" | jq '.' >> "$output_file" 2>/dev/null
        echo -e "${GREEN}  [✓] NumVerify data retrieved${RESET}"
    else
        echo -e "${YELLOW}  [!] NumVerify: Add API key for results${RESET}"
        echo "  [!] NumVerify: No API key configured" >> "$output_file"
    fi
    
    # --- Abstract API ---
    echo -e "${YELLOW}  [+] Querying Abstract API...${RESET}"
    local abstract_result=$(curl -s "https://phonevalidation.abstractapi.com/v1/?api_key=YOUR_API_KEY&phone=${number}" 2>/dev/null)
    
    if echo "$abstract_result" | jq -e '.phone' &>/dev/null; then
        echo "" >> "$output_file"
        echo "--- Abstract API Results ---" >> "$output_file"
        echo "$abstract_result" | jq '.' >> "$output_file" 2>/dev/null
        echo -e "${GREEN}  [✓] Abstract API data retrieved${RESET}"
    else
        echo -e "${YELLOW}  [!] Abstract API: Add API key for results${RESET}"
        echo "  [!] Abstract API: No API key configured" >> "$output_file"
    fi
    
    echo ""
    echo -e "${GREEN}  [✓] OSINT results saved to: $output_file${RESET}"
}

# ============== MODULE: Carrier HLR Lookup ==============
hlr_lookup() {
    local number="$1"
    
    echo -e "${CYAN}[*] Performing HLR/Carrier Lookup...${RESET}"
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

# ============== MODULE: Social Media Footprint ==============
social_media_check() {
    local number="$1"
    local output_file="$RESULT_DIR/social_${number}.txt"
    
    echo -e "${CYAN}[*] Checking social media footprint...${RESET}"
    echo ""
    
    echo "========================================" > "$output_file"
    echo "    SOCIAL MEDIA FOOTPRINT CHECK" >> "$output_file"
    echo "========================================" >> "$output_file"
    echo "  Target: $number" >> "$output_file"
    echo "  Date  : $(date)" >> "$output_file"
    echo "========================================" >> "$output_file"
    
    # Check various platforms
    local platforms=("WhatsApp" "Telegram" "Viber" "Signal" "Truecaller")
    
    for platform in "${platforms[@]}"; do
        echo -e "  ${YELLOW}[+] Checking ${platform}...${RESET}"
        
        case "$platform" in
            "WhatsApp")
                # Check WhatsApp existence via wa.me redirect
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
                # Telegram check via t.me
                local tg_status=$(curl -s -o /dev/null -w "%{http_code}" "https://t.me/${number//+/}" 2>/dev/null)
                echo "  Telegram: HTTP Status $tg_status" >> "$output_file"
                echo -e "  ${YELLOW}  [~] Telegram: Check manually${RESET}"
                ;;
            "Truecaller")
                echo -e "  ${YELLOW}  [~] Truecaller: Manual check required${RESET}"
                echo "  Truecaller: Requires manual/API check" >> "$output_file"
                ;;
            *)
                echo -e "  ${YELLOW}  [~] ${platform}: Manual check required${RESET}"
                echo "  ${platform}: Requires manual check" >> "$output_file"
                ;;
        esac
        sleep 1
    done
    
    echo ""
    echo -e "${GREEN}  [✓] Social media results saved to: $output_file${RESET}"
}

# ============== MODULE: Termux Contacts Lookup ==============
termux_contacts_lookup() {
    local number="$1"
    
    echo -e "${CYAN}[*] Searching device contacts...${RESET}"
    echo ""
    
    # Check if termux-api is available
    if command -v termux-contact-list &>/dev/null; then
        echo -e "${YELLOW}  [+] Fetching contact list...${RESET}"
        
        local contacts=$(termux-contact-list 2>/dev/null)
        
        if [ -n "$contacts" ]; then
            echo -e "${GREEN}  ┌──────────────────────────────────────┐${RESET}"
            echo -e "${GREEN}  │  MATCHING CONTACTS                   │${RESET}"
            echo -e "${GREEN}  ├──────────────────────────────────────┤${RESET}"
            
            local match_count=0
            echo "$contacts" | jq -r '.[] | "\(.number)|\(.name)"' 2>/dev/null | while IFS='|' read -r phone name; do
                if echo "$phone" | grep -q "$number"; then
                    match_count=$((match_count + 1))
                    echo -e "${GREEN}  │ ${name}${RESET}"
                    echo -e "${GREEN}  │ ${phone}${RESET}"
                    echo -e "${GREEN}  ├──────────────────────────────────────┤${RESET}"
                fi
            done
            
            local match_count=$(echo "$contacts" | jq -r '.[] | .number' 2>/dev/null | grep -c "$number")
            
            if [ "$match_count" -eq 0 ]; then
                echo -e "${RED}  │ Number not found in device contacts  │${RESET}"
                echo -e "${GREEN}  └──────────────────────────────────────┘${RESET}"
            else
                echo -e "${GREEN}  │ Found $match_count match(es)${RESET}"
                echo -e "${GREEN}  └──────────────────────────────────────┘${RESET}"
            fi
        else
            echo -e "${RED}  [✗] Could not retrieve contacts${RESET}"
            echo -e "${YELLOW}  [!] Grant Termux:API contacts permission${RESET}"
        fi
    else
        echo -e "${RED}  [✗] termux-api not installed${RESET}"
        echo -e "${YELLOW}  [!] Install: pkg install termux-api${RESET}"
    fi
}

# ============== MODULE: Device SIM Info ==============
device_sim_info() {
    echo -e "${CYAN}[*] Fetching device SIM information...${RESET}"
    echo ""
    
    if command -v termux-telephony-deviceinfo &>/dev/null; then
        echo -e "${GREEN}  ┌─────────────────────────────────────┐${RESET}"
        echo -e "${GREEN}  │       DEVICE TELEPHONY INFO         │${RESET}"
        echo -e "${GREEN}  ├─────────────────────────────────────┤${RESET}"
        
        local device_info=$(termux-telephony-deviceinfo 2>/dev/null)
        
        if [ -n "$device_info" ]; then
            echo "$device_info" | jq -r 'to_entries[] | "  │  \(.key): \(.value)"' 2>/dev/null
            echo -e "${GREEN}  └─────────────────────────────────────┘${RESET}"
            
            # Save to file
            echo "$device_info" | jq '.' > "$RESULT_DIR/device_sim_info.txt" 2>/dev/null
            echo -e "${GREEN}  [✓] Saved to: $RESULT_DIR/device_sim_info.txt${RESET}"
        else
            echo -e "${RED}  │  Could not retrieve info           │${RESET}"
            echo -e "${GREEN}  └─────────────────────────────────────┘${RESET}"
        fi
        
        # Cell info
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

# ============== MODULE: Generate Full Report ==============
generate_report() {
    local number="$1"
    local report_file="$RESULT_DIR/FULL_REPORT_${number}_$(date +%Y%m%d_%H%M%S).txt"
    
    echo -e "${CYAN}[*] Generating comprehensive report...${RESET}"
    echo ""
    
    {
        echo "╔══════════════════════════════════════════════════════╗"
        echo "║           COMPREHENSIVE TRACKING REPORT             ║"
        echo "╠══════════════════════════════════════════════════════╣"
        echo "║  Target Number : $number"
        echo "║  Report Date   : $(date)"
        echo "║  Generated By  : SIM Tracker v2.1"
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
        echo "  SECTION 2: USERNAME & CONTACT NAME"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        
        if command -v termux-contact-list &>/dev/null; then
            local contact=$(termux-contact-list 2>/dev/null | jq -r ".[] | select(.number | contains(\"$(echo $number | sed 's/[+]//g')\")) | .name" 2>/dev/null | head -1)
            if [ -n "$contact" ] && [ "$contact" != "null" ]; then
                echo "  Device Contact : ${contact}"
            else
                echo "  Device Contact : Not found"
            fi
        else
            echo "  Device Contact : Termux:API not available"
        fi
        
        echo ""
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "  SECTION 3: SOCIAL MEDIA CHECK"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        
        local clean_number="${number//+/}"
        local wa_check=$(curl -s -o /dev/null -w "%{http_code}" "https://wa.me/${clean_number}" 2>/dev/null)
        echo "  WhatsApp       : HTTP $wa_check"
        
        echo ""
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "  END OF REPORT"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        
    } > "$report_file"
    
    echo -e "${GREEN}  [✓] Full report saved to:${RESET}"
    echo -e "${WHITE}  $report_file${RESET}"
    echo ""
    echo -e "${YELLOW}  View report? (y/n): ${RESET}"
    read -r view_choice
    if [[ "$view_choice" =~ ^[Yy]$ ]]; then
        echo -e "${CYAN}"
        cat "$report_file"
        echo -e "${RESET}"
    fi
}

# ============== MODULE: Bulk Lookup ==============
bulk_lookup() {
    echo -e "${CYAN}[*] Bulk Number Lookup${RESET}"
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
    echo -e "${GREEN}  [✓] Bulk lookup complete!${RESET}"
}

# ============== MODULE: API Key Configuration ==============
configure_api_keys() {
    local config_file="$RESULT_DIR/.api_config"
    
    echo -e "${CYAN}[*] API Key Configuration${RESET}"
    echo ""
    echo -e "${YELLOW}  Configure API keys for enhanced lookups:${RESET}"
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
            echo "NUMVERIFY_KEY=$key" >> "$config_file"
            echo -e "${GREEN}  [✓] NumVerify key saved!${RESET}"
            ;;
        2)
            echo -ne "${YELLOW}  Enter Abstract API Key: ${RESET}"
            read -r key
            echo "ABSTRACT_KEY=$key" >> "$config_file"
            echo -e "${GREEN}  [✓] Abstract API key saved!${RESET}"
            ;;
        3)
            echo -ne "${YELLOW}  Enter Truecaller API Key: ${RESET}"
            read -r key
            echo "TRUECALLER_KEY=$key" >> "$config_file"
            echo -e "${GREEN}  [✓] Truecaller key saved!${RESET}"
            ;;
        4)
            if [ -f "$config_file" ]; then
                echo -e "${CYAN}"
                cat "$config_file"
                echo -e "${RESET}"
            else
                echo -e "${RED}  [!] No API keys configured${RESET}"
            fi
            ;;
        5) return ;;
    esac
}

# ============== MODULE: Device Call/SMS Logs ==============
device_logs() {
    echo -e "${CYAN}[*] Device Call/SMS Logs${RESET}"
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

# ============== MAIN MENU ==============
main_menu() {
    while true; do
        show_banner
        
        echo -e "  ${WHITE}╔══════════════════════════════════════╗${RESET}"
        echo -e "  ${WHITE}║${RESET}  ${CYAN}[01]${RESET} Quick Name Search       ${MAGENTA}NEW!${RESET}  ${WHITE}║${RESET}"
        echo -e "  ${WHITE}║${RESET}  ${CYAN}[02]${RESET} Full Username Lookup    ${MAGENTA}NEW!${RESET}  ${WHITE}║${RESET}"
        echo -e "  ${WHITE}║${RESET}  ${CYAN}[03]${RESET} Phone Number Analysis         ${WHITE}║${RESET}"
        echo -e "  ${WHITE}║${RESET}  ${CYAN}[04]${RESET} OSINT Lookup                  ${WHITE}║${RESET}"
        echo -e "  ${WHITE}║${RESET}  ${CYAN}[05]${RESET} Carrier / HLR Lookup          ${WHITE}║${RESET}"
        echo -e "  ${WHITE}║${RESET}  ${CYAN}[06]${RESET} Social Media Footprint        ${WHITE}║${RESET}"
        echo -e "  ${WHITE}║${RESET}  ${CYAN}[07]${RESET} Device Contacts Search        ${WHITE}║${RESET}"
        echo -e "  ${WHITE}║${RESET}  ${CYAN}[08]${RESET} Device SIM Info               ${WHITE}║${RESET}"
        echo -e "  ${WHITE}║${RESET}  ${CYAN}[09]${RESET} Generate Full Report          ${WHITE}║${RESET}"
        echo -e "  ${WHITE}║${RESET}  ${CYAN}[10]${RESET} Bulk Number Lookup            ${WHITE}║${RESET}"
        echo -e "  ${WHITE}║${RESET}  ${CYAN}[11]${RESET} Device Call/SMS Logs          ${WHITE}║${RESET}"
        echo -e "  ${WHITE}║${RESET}  ${CYAN}[12]${RESET} Configure API Keys            ${WHITE}║${RESET}"
        echo -e "  ${WHITE}║${RESET}  ${CYAN}[13]${RESET} Setup / Install Dependencies  ${WHITE}║${RESET}"
        echo -e "  ${WHITE}║${RESET}  ${RED}[00]${RESET} Exit                          ${WHITE}║${RESET}"
        echo -e "  ${WHITE}╚══════════════════════════════════════╝${RESET}"
        echo ""
        echo -ne "  ${GREEN}sim-tracker${RESET}${WHITE} > ${RESET}"
        read -r choice
        
        case "$choice" in
            1|01)
                echo ""
                echo -ne "  ${YELLOW}Enter phone number (with country code): ${RESET}"
                read -r target_number
                target_number=$(validate_phone "$target_number")
                if [ $? -eq 0 ] && [ -n "$target_number" ]; then
                    echo ""
                    quick_name_search "$target_number"
                else
                    echo -e "  ${RED}[✗] Invalid phone number format${RESET}"
                fi
                ;;
            2|02)
                echo ""
                echo -ne "  ${YELLOW}Enter phone number for full username lookup: ${RESET}"
                read -r target_number
                target_number=$(validate_phone "$target_number")
                if [ $? -eq 0 ] && [ -n "$target_number" ]; then
                    echo ""
                    username_lookup "$target_number"
                else
                    echo -e "  ${RED}[✗] Invalid phone number format${RESET}"
                fi
                ;;
            3|03)
                echo ""
                echo -ne "  ${YELLOW}Enter phone number: ${RESET}"
                read -r target_number
                target_number=$(validate_phone "$target_number")
                if [ $? -eq 0 ] && [ -n "$target_number" ]; then
                    echo ""
                    phone_number_lookup "$target_number"
                else
                    echo -e "  ${RED}[✗] Invalid phone number format${RESET}"
                fi
                ;;
            4|04)
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
            5|05)
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
            6|06)
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
            7|07)
                echo ""
                echo -ne "  ${YELLOW}Enter phone number to search: ${RESET}"
                read -r target_number
                termux_contacts_lookup "$target_number"
                ;;
            8|08)
                device_sim_info
                ;;
            9|09)
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
            10)
                bulk_lookup
                ;;
            11)
                device_logs
                ;;
            12)
                configure_api_keys
                ;;
            13)
                setup_environment
                ;;
            0|00)
                echo -e "${GREEN}  [*] Thanks for using SIM Tracker. Goodbye!${RESET}"
                echo ""
                exit 0
                ;;
            *)
                echo -e "${RED}  [✗] Invalid option!${RESET}"
                ;;
        esac
        
        echo ""
        echo -ne "  ${YELLOW}Press [Enter] to continue...${RESET}"
        read -r
    done
}

# ============== ENTRY POINT ==============
# Check if running in Termux
if [ -d "/data/data/com.termux" ] || [ -n "$TERMUX_VERSION" ]; then
    echo -e "${GREEN}[✓] Termux environment detected${RESET}"
else
    echo -e "${YELLOW}[!] Warning: Not running in Termux. Some features may not work.${RESET}"
fi

# Log execution
mkdir -p "$RESULT_DIR"
echo "[$(date)] SIM Tracker started" >> "$LOG_FILE"

# Start main menu
main_menu
