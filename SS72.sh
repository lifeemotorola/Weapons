#!/data/data/com.termux/files/usr/bin/bash

#=====================================================
# SS7 Tools for Termux
# Educational & Authorized Testing Only
# Author: Security Research Tool
# Version: 2.0
#=====================================================

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Directories
WORK_DIR="$HOME/ss7_tools"
LOG_DIR="$WORK_DIR/logs"
RESULTS_DIR="$WORK_DIR/results"
CONFIG_DIR="$WORK_DIR/config"
PCAP_DIR="$WORK_DIR/pcaps"

# Log file
LOG_FILE="$LOG_DIR/ss7_tools_$(date +%Y%m%d_%H%M%S).log"

#=====================================================
# UTILITY FUNCTIONS
#=====================================================

log_message() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
}

print_banner() {
    clear
    echo -e "${RED}"
    cat << 'EOF'
   _____ _____ ______   _______          _
  / ____/ ____|____  | |__   __|        | |
 | (___| (___    / /     | | ___   ___ | |___
  \___ \\___ \  / /      | |/ _ \ / _ \| / __|
  ____) |___) |/ /       | | (_) | (_) | \__ \
 |_____/_____//_/        |_|\___/ \___/|_|___/

EOF
    echo -e "${NC}"
    echo -e "${CYAN}╔══════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${WHITE}   SS7 Security Analysis & Testing Framework     ${CYAN}║${NC}"
    echo -e "${CYAN}║${YELLOW}   For Termux - Educational Use Only             ${CYAN}║${NC}"
    echo -e "${CYAN}║${GREEN}   Version 2.0                                   ${CYAN}║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════╝${NC}"
    echo ""
}

print_separator() {
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

print_status() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

print_info() {
    echo -e "${BLUE}[i]${NC} $1"
}

press_enter() {
    echo ""
    echo -e "${YELLOW}Press [Enter] to continue...${NC}"
    read
}

validate_phone() {
    local phone="$1"
    if [[ "$phone" =~ ^\+?[0-9]{10,15}$ ]]; then
        return 0
    else
        return 1
    fi
}

validate_ip() {
    local ip="$1"
    if [[ "$ip" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        return 0
    else
        return 1
    fi
}

validate_gt() {
    local gt="$1"
    if [[ "$gt" =~ ^[0-9]{1,15}$ ]]; then
        return 0
    else
        return 1
    fi
}

#=====================================================
# INSTALLATION & SETUP
#=====================================================

setup_directories() {
    mkdir -p "$WORK_DIR" "$LOG_DIR" "$RESULTS_DIR" "$CONFIG_DIR" "$PCAP_DIR"
    log_message "INFO" "Directories created"
}

check_dependencies() {
    print_info "Checking dependencies..."
    echo ""

    local deps=("python" "pip" "git" "nmap" "tshark" "curl" "wget" "openssl" "tcpdump")
    local missing=()

    for dep in "${deps[@]}"; do
        if command -v "$dep" &> /dev/null; then
            print_status "$dep is installed"
        else
            print_error "$dep is NOT installed"
            missing+=("$dep")
        fi
    done

    if [ ${#missing[@]} -gt 0 ]; then
        echo ""
        print_warning "Missing dependencies: ${missing[*]}"
        return 1
    fi
    return 0
}

install_dependencies() {
    print_banner
    echo -e "${YELLOW}${BOLD}[INSTALLING DEPENDENCIES]${NC}"
    print_separator
    echo ""

    print_info "Updating package repositories..."
    pkg update -y 2>&1 | tail -1
    pkg upgrade -y 2>&1 | tail -1
    echo ""

    local packages=(
        "python"
        "nmap"
        "tshark"
        "curl"
        "wget"
        "openssl"
        "tcpdump"
        "git"
        "clang"
        "make"
        "libxml2"
        "libxslt"
        "net-tools"
        "iproute2"
        "dnsutils"
        "whois"
    )

    for pkg_name in "${packages[@]}"; do
        print_info "Installing $pkg_name..."
        pkg install -y "$pkg_name" 2>/dev/null
        if [ $? -eq 0 ]; then
            print_status "$pkg_name installed successfully"
        else
            print_warning "$pkg_name installation failed or already installed"
        fi
    done

    echo ""
    print_info "Installing Python packages..."

    pip install --upgrade pip 2>/dev/null

    local py_packages=(
        "scapy"
        "pysctp"
        "requests"
        "colorama"
        "tabulate"
        "ipaddress"
        "cryptography"
        "pyasn1"
        "pycryptodome"
    )

    for py_pkg in "${py_packages[@]}"; do
        print_info "Installing Python package: $py_pkg..."
        pip install "$py_pkg" 2>/dev/null
        if [ $? -eq 0 ]; then
            print_status "$py_pkg installed"
        else
            print_warning "$py_pkg installation failed"
        fi
    done

    setup_directories

    echo ""
    print_status "Installation complete!"
    log_message "INFO" "Dependencies installed"
    press_enter
}

#=====================================================
# SS7 PROTOCOL ANALYSIS
#=====================================================

generate_ss7_map_message() {
    local msg_type="$1"
    local target="$2"
    local output_file="$RESULTS_DIR/map_${msg_type}_$(date +%Y%m%d_%H%M%S).txt"

    cat > "$output_file" << MAPEOF
=====================================================
SS7 MAP Message Structure Analysis
Type: $msg_type
Target: $target
Timestamp: $(date)
=====================================================

MAP Protocol Data Unit (PDU):
-----------------------------------------------------
MAPEOF

    case "$msg_type" in
        "SRI")
            cat >> "$output_file" << 'SRIEOF'
Message Type: SendRoutingInfo (SRI)
Operation Code: 22

TCAP Layer:
├── Transaction ID: [AUTO-GENERATED]
├── Component Type: Invoke
├── Operation Code: 22 (sendRoutingInfo)
└── Dialog Portion:
    ├── Application Context: shortMsgGatewayContext-v3
    └── AC Version: 3

MAP Layer:
├── MSISDN: [TARGET_NUMBER]
│   ├── Nature of Address: International
│   ├── Numbering Plan: ISDN/E.164
│   └── Digits: [ENCODED]
├── SM-RP-PRI: True
├── Service Centre Address:
│   ├── Nature of Address: International
│   └── Digits: [SMSC_ADDRESS]
└── IMSI (if known): [UNKNOWN]

Expected Response (SRI Response):
├── IMSI: [SUBSCRIBER_IMSI]
├── Location Info:
│   ├── Network Node Number (MSC/VLR): [GT_ADDRESS]
│   └── LMSI: [LOCAL_MOBILE_SUBSCRIBER_ID]
└── MNP Info (if applicable):
    ├── Number Portability Status: [STATUS]
    └── Routing Number: [ROUTING_NUM]

SCCP Layer:
├── Message Type: UDT (Unitdata)
├── Called Party Address:
│   ├── SSN: 6 (HLR)
│   ├── GT: [HLR_GT]
│   └── Routing Indicator: GT
└── Calling Party Address:
    ├── SSN: 8 (MSC)
    ├── GT: [OWN_GT]
    └── Routing Indicator: GT

MTP3 Layer:
├── Service Indicator: SCCP (3)
├── Network Indicator: International (0)
├── OPC: [ORIGINATING_POINT_CODE]
└── DPC: [DESTINATION_POINT_CODE]
SRIEOF
            ;;
        "PSI")
            cat >> "$output_file" << 'PSIEOF'
Message Type: ProvideSubscriberInfo (PSI)
Operation Code: 70

TCAP Layer:
├── Transaction ID: [AUTO-GENERATED]
├── Component Type: Invoke
├── Operation Code: 70 (provideSubscriberInfo)
└── Dialog Portion:
    ├── Application Context: subscriberInfoEnquiryContext
    └── AC Version: 3

MAP Layer:
├── IMSI: [TARGET_IMSI]
├── Requested Info:
│   ├── Location Information: TRUE
│   ├── Subscriber State: TRUE
│   ├── Current Location: TRUE
│   ├── IMEI: TRUE
│   └── MS Classmark: TRUE
└── MNP Requested Info: [OPTIONAL]

Expected Response:
├── Subscriber Info:
│   ├── Location Information:
│   │   ├── Cell Global ID (CGI):
│   │   │   ├── MCC: [MOBILE_COUNTRY_CODE]
│   │   │   ├── MNC: [MOBILE_NETWORK_CODE]
│   │   │   ├── LAC: [LOCATION_AREA_CODE]
│   │   │   └── CI: [CELL_ID]
│   │   ├── Age of Location Info: [MINUTES]
│   │   ├── VLR Number: [VLR_GT]
│   │   ├── MSC Number: [MSC_GT]
│   │   └── Geographic Info: [LAT/LON if available]
│   ├── Subscriber State:
│   │   └── State: [ASSUMED_IDLE/BUSY/NOT_REACHABLE]
│   ├── IMEI: [DEVICE_IMEI]
│   └── MS Classmark:
│       ├── Revision Level: [R99/R98]
│       └── Encryption Algorithms: [A5/1, A5/3]
└── Error (if any):
    ├── Error Code: [CODE]
    └── Description: [DESCRIPTION]
PSIEOF
            ;;
        "ATI")
            cat >> "$output_file" << 'ATIEOF'
Message Type: AnyTimeInterrogation (ATI)
Operation Code: 71

TCAP Layer:
├── Transaction ID: [AUTO-GENERATED]
├── Component Type: Invoke
├── Operation Code: 71 (anyTimeInterrogation)
└── Dialog Portion:
    ├── Application Context: anyTimeInfoEnquiryContext
    └── AC Version: 3

MAP Layer:
├── Subscriber Identity:
│   ├── IMSI: [TARGET_IMSI] (Option 1)
│   └── MSISDN: [TARGET_MSISDN] (Option 2)
├── Requested Info:
│   ├── Location Information: TRUE
│   ├── Subscriber State: TRUE
│   ├── Current Location: TRUE (triggers paging)
│   ├── IMEI: TRUE
│   ├── MS Classmark: TRUE
│   ├── MNP Information: TRUE
│   └── T-ADS Data: FALSE
├── GSM SCF Address: [GSMSCF_GT]
└── Interrogation Type: [BASIC/FORWARDING]

Expected Response (ATI Response):
├── Subscriber Info:
│   ├── Location Information:
│   │   ├── Cell Global ID:
│   │   │   ├── MCC-MNC: [PLMN_ID]
│   │   │   ├── LAC: [LOCATION_AREA_CODE]
│   │   │   └── Cell ID: [CELL_ID]
│   │   ├── Service Area ID: [SAI]
│   │   ├── Age of Location: [AGE_MINUTES]
│   │   ├── Geographical Information:
│   │   │   ├── Latitude: [LAT]
│   │   │   └── Longitude: [LON]
│   │   ├── VLR Number: [VLR_GT]
│   │   └── MSC Number: [MSC_GT]
│   ├── Subscriber State: [ASSUMED_IDLE]
│   ├── IMEI-SV: [IMEI_SOFTWARE_VERSION]
│   └── PS Domain Info:
│       ├── SGSN Number: [SGSN_GT]
│       └── RAI: [ROUTING_AREA_ID]
└── Possible Errors:
    ├── ATI Not Allowed
    ├── Data Missing
    └── Unauthorized Requesting Network
ATIEOF
            ;;
        "UL")
            cat >> "$output_file" << 'ULEOF'
Message Type: UpdateLocation (UL)
Operation Code: 2

TCAP Layer:
├── Transaction ID: [AUTO-GENERATED]
├── Component Type: Invoke
├── Operation Code: 2 (updateLocation)
└── Dialog Portion:
    ├── Application Context: networkLocUpContext
    └── AC Version: 3

MAP Layer:
├── IMSI: [TARGET_IMSI]
├── MSC Number: [FAKE_MSC_GT]
├── VLR Number: [FAKE_VLR_GT]
├── VLR Capability:
│   ├── Supported CAMEL Phases: [1,2,3,4]
│   ├── Supported LCS Capability Sets: [1,2,3]
│   ├── IST Support Indicator: basicISTSupported
│   └── Super Charger Supported: TRUE
├── Informing Previous HLR: FALSE
└── CS/PS LCS Not Supported: FALSE

Expected Response (UL Response):
├── HLR Number: [HLR_GT]
├── Subscriber Data:
│   ├── MSISDN: [SUBSCRIBER_MSISDN]
│   ├── Category: ordinarySubscriber
│   ├── Bearer Services: [LIST]
│   ├── Teleservices: [LIST]
│   ├── Provisioned SS: [SUPPLEMENTARY_SERVICES]
│   ├── ODB Data: [OPERATOR_DETERMINED_BARRING]
│   └── Roaming Restriction:
│       └── Roaming Allowed: [YES/NO]
└── Possible Errors:
    ├── Roaming Not Allowed
    ├── Unknown Subscriber
    └── Data Missing

⚠️ SECURITY NOTE: UpdateLocation is one of the most
   dangerous SS7 attacks. It can redirect calls/SMS
   to an attacker-controlled MSC/VLR.
ULEOF
            ;;
        "CL")
            cat >> "$output_file" << 'CLEOF'
Message Type: CancelLocation (CL)
Operation Code: 3

TCAP Layer:
├── Transaction ID: [AUTO-GENERATED]
├── Component Type: Invoke
├── Operation Code: 3 (cancelLocation)
└── Dialog Portion:
    ├── Application Context: locationCancellationContext
    └── AC Version: 3

MAP Layer:
├── Identity:
│   ├── IMSI: [TARGET_IMSI]
│   └── IMSI with LMSI:
│       ├── IMSI: [TARGET_IMSI]
│       └── LMSI: [LOCAL_MOBILE_SUB_ID]
├── Cancellation Type:
│   ├── updateProcedure (0)
│   ├── subscriptionWithdraw (1)
│   └── initialAttachProcedure (2)
└── New MSC Number: [NEW_MSC_GT] (optional)

Expected Response:
├── Success: Empty result (CL accepted)
└── Possible Errors:
    ├── Data Missing
    └── Unexpected Data Value

⚠️ SECURITY NOTE: CancelLocation can be used for
   Denial of Service attacks against subscribers.
CLEOF
            ;;
        "ISD")
            cat >> "$output_file" << 'ISDEOF'
Message Type: InsertSubscriberData (ISD)
Operation Code: 7

TCAP Layer:
├── Transaction ID: [AUTO-GENERATED]
├── Component Type: Invoke
├── Operation Code: 7 (insertSubscriberData)
└── Dialog Portion:
    ├── Application Context: subscriberDataMngtContext
    └── AC Version: 3

MAP Layer:
├── IMSI: [TARGET_IMSI]
├── MSISDN: [TARGET_MSISDN]
├── Category: ordinarySubscriber
├── Subscriber Status: serviceGranted
├── Bearer Service List:
│   ├── BS Code: allBearerServices
│   └── Specific BS: [DATA_CDA/SPEECH]
├── Teleservice List:
│   ├── TS Code: allTeleservices
│   └── Specific TS: [TELEPHONY/SMS]
├── Provisioned SS:
│   ├── Call Forwarding:
│   │   ├── SS Code: CFU (21)
│   │   ├── SS Status: Active
│   │   └── Forwarded-To Number: [ATTACKER_NUMBER]
│   ├── Call Barring:
│   │   ├── SS Code: BAOC (33)
│   │   └── SS Status: [ACTIVE/INACTIVE]
│   └── Call Waiting:
│       └── SS Status: Active
├── ODB Data:
│   └── ODB General Data: [BARRING_FLAGS]
├── Roaming Restriction:
│   └── Zone Code: [RESTRICTION_ZONE]
└── Regional Subscription Data: [ZONES]

Expected Response:
├── SS List (services not supported by VLR)
├── ODB General Data (if not supported)
└── Regional Subscription Response

⚠️ SECURITY NOTE: ISD can be abused to set up
   call forwarding to attacker-controlled numbers.
ISDEOF
            ;;
    esac

    echo ""
    print_status "MAP message structure saved to: $output_file"
    log_message "INFO" "Generated MAP $msg_type message structure for $target"
}

ss7_protocol_analyzer() {
    print_banner
    echo -e "${YELLOW}${BOLD}[SS7 PROTOCOL STRUCTURE ANALYZER]${NC}"
    print_separator
    echo ""

    echo -e "${WHITE}Select MAP Operation to Analyze:${NC}"
    echo ""
    echo -e "  ${GREEN}1)${NC} SendRoutingInfo (SRI) - SMS Routing"
    echo -e "  ${GREEN}2)${NC} ProvideSubscriberInfo (PSI) - Location Query"
    echo -e "  ${GREEN}3)${NC} AnyTimeInterrogation (ATI) - Subscriber Info"
    echo -e "  ${GREEN}4)${NC} UpdateLocation (UL) - Location Update"
    echo -e "  ${GREEN}5)${NC} CancelLocation (CL) - Cancel Registration"
    echo -e "  ${GREEN}6)${NC} InsertSubscriberData (ISD) - Modify Subscriber"
    echo -e "  ${GREEN}7)${NC} Analyze ALL message types"
    echo -e "  ${GREEN}0)${NC} Back to Main Menu"
    echo ""

    read -p "$(echo -e ${CYAN}"Select option: "${NC})" choice

    case "$choice" in
        1) generate_ss7_map_message "SRI" "analysis" ;;
        2) generate_ss7_map_message "PSI" "analysis" ;;
        3) generate_ss7_map_message "ATI" "analysis" ;;
        4) generate_ss7_map_message "UL" "analysis" ;;
        5) generate_ss7_map_message "CL" "analysis" ;;
        6) generate_ss7_map_message "ISD" "analysis" ;;
        7)
            for type in SRI PSI ATI UL CL ISD; do
                generate_ss7_map_message "$type" "full_analysis"
            done
            ;;
        0) return ;;
        *) print_error "Invalid option" ;;
    esac
    press_enter
}

#=====================================================
# SCTP SCANNER
#=====================================================

sctp_scanner() {
    print_banner
    echo -e "${YELLOW}${BOLD}[SCTP PORT SCANNER]${NC}"
    print_separator
    echo ""

    print_info "SCTP (Stream Control Transmission Protocol) is used"
    print_info "as the transport layer for SS7 over IP (SIGTRAN)."
    echo ""

    read -p "$(echo -e ${CYAN}"Enter target IP or range: "${NC})" target_ip

    if [ -z "$target_ip" ]; then
        print_error "Target IP is required"
        press_enter
        return
    fi

    echo ""
    echo -e "${WHITE}Scan Type:${NC}"
    echo -e "  ${GREEN}1)${NC} Quick SCTP scan (common SS7 ports)"
    echo -e "  ${GREEN}2)${NC} Full SCTP port scan"
    echo -e "  ${GREEN}3)${NC} SIGTRAN specific scan"
    echo -e "  ${GREEN}4)${NC} Diameter protocol scan"
    echo ""

    read -p "$(echo -e ${CYAN}"Select scan type: "${NC})" scan_type

    local output_file="$RESULTS_DIR/sctp_scan_$(date +%Y%m%d_%H%M%S).txt"
    local ports=""

    case "$scan_type" in
        1)
            ports="2905,2906,2907,2908,2909,2944,2945,3868,9900,14001"
            print_info "Scanning common SS7/SIGTRAN ports..."
            ;;
        2)
            ports="1-65535"
            print_info "Full SCTP port scan (this may take a while)..."
            ;;
        3)
            ports="2905,2906,2907,2908,2909,2944,2945,9900,14001"
            print_info "SIGTRAN specific port scan..."
            ;;
        4)
            ports="3868,3869,3870,5868"
            print_info "Diameter protocol port scan..."
            ;;
        *)
            print_error "Invalid option"
            press_enter
            return
            ;;
    esac

    echo ""
    print_separator

    # Create detailed output header
    cat > "$output_file" << EOF
=====================================================
SCTP/SIGTRAN Port Scan Results
Target: $target_ip
Date: $(date)
Scan Type: $scan_type
=====================================================

Port Reference:
- 2905: M3UA (MTP3 User Adaptation)
- 2906: M2UA (MTP2 User Adaptation)
- 2907: M2PA (MTP2 Peer-to-Peer Adaptation)
- 2908: M3UA (alternate)
- 2909: SUA (SCCP User Adaptation)
- 2944: MEGACO/H.248
- 2945: MEGACO/H.248 (alternate)
- 3868: Diameter
- 9900: IUA (ISDN User Adaptation)
- 14001: SUA (alternate)

Scan Results:
-----------------------------------------------------
EOF

    # Perform nmap SCTP scan
    if command -v nmap &> /dev/null; then
        echo -e "${GREEN}Running nmap SCTP scan...${NC}"
        echo ""

        nmap -sY -p "$ports" -sV --open \
            --script=banner \
            -oN "$output_file.nmap" \
            "$target_ip" 2>&1 | tee -a "$output_file"

        echo "" >> "$output_file"
        echo "-----------------------------------------------------" >> "$output_file"

        # Additional TCP scan for related services
        echo "" >> "$output_file"
        echo "Additional TCP Scan for SS7-related services:" >> "$output_file"
        echo "-----------------------------------------------------" >> "$output_file"

        nmap -sS -p "2905-2909,2944,2945,3868,5060,5061,9900,14001" \
            -sV --open \
            -oN "$output_file.tcp" \
            "$target_ip" 2>&1 | tee -a "$output_file"

        echo ""
        print_status "Scan results saved to: $output_file"
    else
        print_error "nmap not installed. Run installation first."
    fi

    log_message "INFO" "SCTP scan completed for $target_ip"
    press_enter
}

#=====================================================
# SS7 VULNERABILITY ASSESSMENT
#=====================================================

ss7_vuln_assessment() {
    print_banner
    echo -e "${YELLOW}${BOLD}[SS7 VULNERABILITY ASSESSMENT]${NC}"
    print_separator
    echo ""

    local output_file="$RESULTS_DIR/ss7_vuln_assessment_$(date +%Y%m%d_%H%M%S).txt"

    read -p "$(echo -e ${CYAN}"Enter target network/operator name: "${NC})" target_name
    read -p "$(echo -e ${CYAN}"Enter target GT (Global Title) [optional]: "${NC})" target_gt
    read -p "$(echo -e ${CYAN}"Enter target IP range [optional]: "${NC})" target_ip

    cat > "$output_file" << EOF
╔══════════════════════════════════════════════════════╗
║          SS7 VULNERABILITY ASSESSMENT REPORT         ║
╚══════════════════════════════════════════════════════╝

Target: $target_name
Global Title: ${target_gt:-N/A}
IP Range: ${target_ip:-N/A}
Assessment Date: $(date)
Report ID: $(cat /dev/urandom | tr -dc 'A-Z0-9' | fold -w 8 | head -n 1)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. CATEGORY A - LOCATION TRACKING VULNERABILITIES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[A.1] AnyTimeInterrogation (ATI) - Location Disclosure
  Severity: HIGH
  CVE Reference: N/A (Protocol Design)
  GSMA Category: Cat 1
  Description: ATI messages can be sent from any network
    to query real-time location of subscribers.
  Attack Vector:
    - Send MAP ATI to target HLR
    - Receive CGI (Cell Global Identity)
    - Convert CGI to geographic coordinates
  Impact:
    - Real-time subscriber tracking
    - Movement pattern analysis
    - Privacy violation
  Mitigation:
    □ Implement ATI filtering on STP
    □ Allow ATI only from authorized GTs
    □ Deploy SS7 firewall rules
    □ Monitor for anomalous ATI volumes
  Test Status: [ ] Tested  [ ] Not Tested

[A.2] SendRoutingInfoForSM (SRI-SM) - Coarse Location
  Severity: MEDIUM-HIGH
  GSMA Category: Cat 1
  Description: SRI-SM reveals the serving MSC/VLR
    which indicates the general area of subscriber.
  Attack Vector:
    - Send MAP SRI-SM with target MSISDN
    - Receive serving MSC GT in response
    - Map MSC GT to geographic area
  Impact:
    - Coarse location determination
    - Network topology disclosure
    - Identification of roaming status
  Mitigation:
    □ SRI-SM home routing
    □ SMS firewall implementation
    □ GT filtering on STP
  Test Status: [ ] Tested  [ ] Not Tested

[A.3] ProvideSubscriberLocation (PSL)
  Severity: CRITICAL
  GSMA Category: Cat 1
  Description: Direct location request providing
    precise GPS coordinates.
  Mitigation:
    □ Strict GT whitelisting for PSL
    □ Authorization checks
    □ Rate limiting
  Test Status: [ ] Tested  [ ] Not Tested

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

2. CATEGORY B - CALL/SMS INTERCEPTION VULNERABILITIES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[B.1] UpdateLocation (UL) - Call/SMS Redirect
  Severity: CRITICAL
  GSMA Category: Cat 2
  Description: Attacker registers a fake MSC/VLR for
    the target subscriber at the HLR, redirecting
    all incoming calls and SMS.
  Attack Vector:
    - Obtain target IMSI (via SRI-SM)
    - Send UpdateLocation with fake MSC/VLR GT
    - Incoming calls/SMS routed to attacker
    - Forward to original destination (MitM)
  Impact:
    - Complete call interception
    - SMS interception (2FA bypass)
    - Service disruption
  Mitigation:
    □ UL source validation
    □ IMSI validation against known ranges
    □ UL rate limiting
    □ Previous VLR notification checks
    □ Anomaly detection (rapid location changes)
  Test Status: [ ] Tested  [ ] Not Tested

[B.2] InsertSubscriberData (ISD) - Call Forwarding
  Severity: HIGH
  GSMA Category: Cat 2
  Description: Inject call forwarding to attacker's
    number via ISD to the VLR.
  Attack Vector:
    - Send ISD with CFU to attacker number
    - VLR activates unconditional forwarding
    - All calls forwarded to attacker
  Impact:
    - Call interception via forwarding
    - Subscriber unaware of forwarding
  Mitigation:
    □ ISD source validation
    □ Forward-to number validation
    □ Subscriber notification of CF changes
  Test Status: [ ] Tested  [ ] Not Tested

[B.3] RegisterSS - Supplementary Service Abuse
  Severity: HIGH
  GSMA Category: Cat 2
  Description: Register call forwarding directly
    at the HLR level.
  Mitigation:
    □ RegisterSS filtering
    □ Authentication of source
  Test Status: [ ] Tested  [ ] Not Tested

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

3. CATEGORY C - DENIAL OF SERVICE VULNERABILITIES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[C.1] CancelLocation - Service Denial
  Severity: HIGH
  GSMA Category: Cat 3
  Description: Deregister subscriber from VLR
    causing loss of service.
  Impact:
    - Complete service denial
    - No incoming calls/SMS
    - Data service disruption
  Mitigation:
    □ CL source validation
    □ CL confirmation with HLR
    □ Rate limiting
  Test Status: [ ] Tested  [ ] Not Tested

[C.2] DeleteSubscriberData (DSD)
  Severity: HIGH
  GSMA Category: Cat 3
  Description: Remove subscriber data from VLR
    causing partial service denial.
  Mitigation:
    □ DSD source validation
    □ HLR confirmation
  Test Status: [ ] Tested  [ ] Not Tested

[C.3] PurgeMS
  Severity: MEDIUM
  GSMA Category: Cat 3
  Description: Purge subscriber from VLR as if
    device was switched off.
  Mitigation:
    □ PurgeMS source validation
  Test Status: [ ] Tested  [ ] Not Tested

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

4. CATEGORY D - FRAUD VULNERABILITIES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[D.1] SendIMSI - Identity Theft
  Severity: HIGH
  GSMA Category: Cat 1
  Description: Retrieve IMSI using MSISDN.
  Impact:
    - IMSI harvesting
    - Foundation for further attacks
  Mitigation:
    □ SendIMSI filtering
    □ GT-based access control
  Test Status: [ ] Tested  [ ] Not Tested

[D.2] USSD Request Manipulation
  Severity: MEDIUM
  GSMA Category: Cat 3
  Description: Send unauthorized USSD commands.
  Impact:
    - Balance theft
    - Service modification
  Mitigation:
    □ USSD source validation
    □ USSD command filtering
  Test Status: [ ] Tested  [ ] Not Tested

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

5. NETWORK SECURITY ASSESSMENT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[N.1] SS7 Firewall Presence
  Check: Is an SS7 firewall/filter deployed?
  Status: [ ] Present  [ ] Absent  [ ] Unknown

[N.2] STP Filtering Rules
  Check: Are SCCP/MAP filtering rules in place?
  Status: [ ] Configured  [ ] Not Configured  [ ] Unknown

[N.3] GT Whitelisting
  Check: Is GT-based access control implemented?
  Status: [ ] Yes  [ ] No  [ ] Partial

[N.4] MAP Message Screening
  Check: Are specific MAP operations filtered?
  Status: [ ] Yes  [ ] No  [ ] Partial

[N.5] SCCP Management
  Check: Is SCCP routing properly secured?
  Status: [ ] Yes  [ ] No  [ ] Unknown

[N.6] Monitoring & Alerting
  Check: Is SS7 traffic monitored for anomalies?
  Status: [ ] Yes  [ ] No  [ ] Partial

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

6. RECOMMENDATIONS SUMMARY
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Priority 1 (Critical):
  □ Deploy SS7 firewall (e.g., GSMA FS.11 compliant)
  □ Implement MAP message filtering
  □ Deploy SRI-SM Home Routing
  □ Block unauthorized UpdateLocation

Priority 2 (High):
  □ Implement GT whitelisting
  □ Deploy anomaly detection
  □ Set up alerting for suspicious operations
  □ Implement rate limiting

Priority 3 (Medium):
  □ Regular SS7 security audits
  □ Staff training on SS7 security
  □ Implement GSMA IR.82 recommendations
  □ Deploy end-to-end encryption

References:
  - GSMA FS.11: SS7/Diameter Security
  - GSMA IR.82: Security SS7 Implementation
  - 3GPP TS 29.002: MAP Protocol
  - 3GPP TS 09.02: MAP Specification
  - NIST SP 800-187: LTE Security

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Report Generated by SS7 Tools for Termux
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF

    echo ""
    print_status "Vulnerability assessment template saved to:"
    print_info "$output_file"
    log_message "INFO" "Vulnerability assessment generated for $target_name"
    press_enter
}

#=====================================================
# PCAP ANALYZER
#=====================================================

pcap_analyzer() {
    print_banner
    echo -e "${YELLOW}${BOLD}[SS7 PCAP ANALYZER]${NC}"
    print_separator
    echo ""

    echo -e "${WHITE}Options:${NC}"
    echo -e "  ${GREEN}1)${NC} Analyze existing PCAP file"
    echo -e "  ${GREEN}2)${NC} Live capture SS7/SIGTRAN traffic"
    echo -e "  ${GREEN}3)${NC} Generate sample PCAP analysis"
    echo -e "  ${GREEN}4)${NC} Extract MAP operations from PCAP"
    echo -e "  ${GREEN}5)${NC} SCTP stream analysis"
    echo -e "  ${GREEN}0)${NC} Back"
    echo ""

    read -p "$(echo -e ${CYAN}"Select option: "${NC})" choice

    case "$choice" in
        1)
            read -p "$(echo -e ${CYAN}"Enter PCAP file path: "${NC})" pcap_file
            if [ -f "$pcap_file" ]; then
                local output_file="$RESULTS_DIR/pcap_analysis_$(date +%Y%m%d_%H%M%S).txt"

                print_info "Analyzing PCAP file..."
                echo ""

                if command -v tshark &> /dev/null; then
                    echo "=== SS7 PCAP Analysis ===" > "$output_file"
                    echo "File: $pcap_file" >> "$output_file"
                    echo "Date: $(date)" >> "$output_file"
                    echo "" >> "$output_file"

                    # General stats
                    echo "--- Capture Statistics ---" >> "$output_file"
                    tshark -r "$pcap_file" -q -z io,stat,0 2>/dev/null >> "$output_file"
                    echo "" >> "$output_file"

                    # Protocol hierarchy
                    echo "--- Protocol Hierarchy ---" >> "$output_file"
                    tshark -r "$pcap_file" -q -z io,phs 2>/dev/null >> "$output_file"
                    echo "" >> "$output_file"

                    # SCTP analysis
                    echo "--- SCTP Connections ---" >> "$output_file"
                    tshark -r "$pcap_file" -Y "sctp" -T fields \
                        -e ip.src -e ip.dst -e sctp.srcport -e sctp.dstport \
                        2>/dev/null | sort -u >> "$output_file"
                    echo "" >> "$output_file"

                    # M3UA messages
                    echo "--- M3UA Messages ---" >> "$output_file"
                    tshark -r "$pcap_file" -Y "m3ua" -T fields \
                        -e m3ua.message_class -e m3ua.message_type \
                        2>/dev/null >> "$output_file"
                    echo "" >> "$output_file"

                    # SCCP messages
                    echo "--- SCCP Messages ---" >> "$output_file"
                    tshark -r "$pcap_file" -Y "sccp" -T fields \
                        -e sccp.message_type -e sccp.calling.digits \
                        -e sccp.called.digits -e sccp.calling.ssn \
                        -e sccp.called.ssn \
                        2>/dev/null >> "$output_file"
                    echo "" >> "$output_file"

                    # TCAP messages
                    echo "--- TCAP Messages ---" >> "$output_file"
                    tshark -r "$pcap_file" -Y "tcap" -T fields \
                        -e tcap.msgtype -e tcap.otid -e tcap.dtid \
                        2>/dev/null >> "$output_file"
                    echo "" >> "$output_file"

                    # MAP operations
                    echo "--- MAP Operations ---" >> "$output_file"
                    tshark -r "$pcap_file" -Y "gsm_map" -T fields \
                        -e gsm_map.old.localValue \
                        -e gsm_map.old.imsi \
                        -e gsm_map.old.msisdn \
                        2>/dev/null >> "$output_file"

                    print_status "Analysis saved to: $output_file"
                    cat "$output_file"
                else
                    print_error "tshark not installed"
                fi
            else
                print_error "File not found: $pcap_file"
            fi
            ;;
        2)
            print_info "Live capture mode"
            read -p "$(echo -e ${CYAN}"Enter interface (default: any): "${NC})" iface
            iface=${iface:-any}

            local capture_file="$PCAP_DIR/ss7_capture_$(date +%Y%m%d_%H%M%S).pcap"
            print_info "Capturing to: $capture_file"
            print_warning "Press Ctrl+C to stop capture"
            echo ""

            if command -v tcpdump &> /dev/null; then
                tcpdump -i "$iface" -w "$capture_file" \
                    "sctp or port 2905 or port 2906 or port 2907 or port 2944 or port 3868" \
                    2>&1
                print_status "Capture saved to: $capture_file"
            elif command -v tshark &> /dev/null; then
                tshark -i "$iface" -w "$capture_file" \
                    -f "sctp or port 2905 or port 2906 or port 2907 or port 2944 or port 3868" \
                    2>&1
                print_status "Capture saved to: $capture_file"
            else
                print_error "Neither tcpdump nor tshark is installed"
            fi
            ;;
        3)
            local output_file="$RESULTS_DIR/sample_pcap_analysis_$(date +%Y%m%d_%H%M%S).txt"
            cat > "$output_file" << 'SAMPLEEOF'
=== Sample SS7 PCAP Analysis Report ===

--- Capture Statistics ---
Packets: 1,247
Duration: 00:05:23
Avg packet size: 187 bytes

--- Protocol Distribution ---
SCTP:      1,247 (100%)
├── M3UA:  1,198 (96.1%)
│   ├── SCCP:  1,156 (92.7%)
│   │   ├── TCAP:  1,089 (87.3%)
│   │   │   ├── MAP:  987 (79.1%)
│   │   │   └── CAP:  102 (8.2%)
│   │   └── Other: 67 (5.4%)
│   └── ISUP: 42 (3.4%)
└── M3UA Mgmt: 49 (3.9%)

--- MAP Operation Summary ---
Operation                Count   Percentage
─────────────────────────────────────────
sendRoutingInfo          234     23.7%
sendRoutingInfoForSM     189     19.1%
anyTimeInterrogation     156     15.8%
updateLocation           98      9.9%
insertSubscriberData     87      8.8%
provideSubscriberInfo    76      7.7%
sendAuthenticationInfo   54      5.5%
cancelLocation           34      3.4%
registerSS               28      2.8%
eraseSS                  12      1.2%
processUnstructuredSS    11      1.1%
Other                    8       0.8%

--- Suspicious Activity Detected ---
[!] HIGH: 34 UpdateLocation from unknown GT
[!] HIGH: 12 CancelLocation burst (possible DoS)
[!] MEDIUM: ATI requests from non-CAMEL GT
[!] LOW: SRI-SM volume spike detected

--- Source GT Analysis ---
GT                      Count   SSN   Description
──────────────────────────────────────────────────
1234567890              456     6     HLR
1234567891              312     8     MSC
9876543210              89      8     Suspicious
0000000001              23      8     Suspicious

--- IMSI Analysis ---
Total unique IMSIs seen: 156
IMSI Range Analysis:
├── Home network: 134 (85.9%)
├── Roaming: 18 (11.5%)
└── Unknown range: 4 (2.6%)

SAMPLEEOF
            print_status "Sample analysis saved to: $output_file"
            cat "$output_file"
            ;;
        4)
            read -p "$(echo -e ${CYAN}"Enter PCAP file path: "${NC})" pcap_file
            if [ -f "$pcap_file" ] && command -v tshark &> /dev/null; then
                local output_file="$RESULTS_DIR/map_extract_$(date +%Y%m%d_%H%M%S).txt"
                echo "=== MAP Operations Extracted ===" > "$output_file"
                tshark -r "$pcap_file" -Y "gsm_map" -V 2>/dev/null >> "$output_file"
                print_status "MAP operations extracted to: $output_file"
            else
                print_error "File not found or tshark not installed"
            fi
            ;;
        5)
            read -p "$(echo -e ${CYAN}"Enter PCAP file path: "${NC})" pcap_file
            if [ -f "$pcap_file" ] && command -v tshark &> /dev/null; then
                local output_file="$RESULTS_DIR/sctp_streams_$(date +%Y%m%d_%H%M%S).txt"
                echo "=== SCTP Stream Analysis ===" > "$output_file"
                tshark -r "$pcap_file" -q -z "sctp,stat" 2>/dev/null >> "$output_file"
                echo "" >> "$output_file"
                echo "=== SCTP Chunks ===" >> "$output_file"
                tshark -r "$pcap_file" -Y "sctp" -T fields \
                    -e sctp.chunk_type -e sctp.srcport -e sctp.dstport \
                    -e sctp.verification_tag 2>/dev/null >> "$output_file"
                print_status "SCTP analysis saved to: $output_file"
            else
                print_error "File not found or tshark not installed"
            fi
            ;;
        0) return ;;
        *) print_error "Invalid option" ;;
    esac
    press_enter
}

#=====================================================
# GLOBAL TITLE (GT) LOOKUP
#=====================================================

gt_lookup() {
    print_banner
    echo -e "${YELLOW}${BOLD}[GLOBAL TITLE (GT) LOOKUP & ANALYSIS]${NC}"
    print_separator
    echo ""

    echo -e "${WHITE}Options:${NC}"
    echo -e "  ${GREEN}1)${NC} Analyze a phone number / GT"
    echo -e "  ${GREEN}2)${NC} MCC/MNC lookup"
    echo -e "  ${GREEN}3)${NC} Point Code analysis"
    echo -e "  ${GREEN}4)${NC} SSN (Subsystem Number) reference"
    echo -e "  ${GREEN}0)${NC} Back"
    echo ""

    read -p "$(echo -e ${CYAN}"Select option: "${NC})" choice

    case "$choice" in
        1)
            read -p "$(echo -e ${CYAN}"Enter phone number / GT (with country code): "${NC})" number
            local output_file="$RESULTS_DIR/gt_lookup_$(date +%Y%m%d_%H%M%S).txt"

            # Extract country code
            local cc=""
            local cleaned=$(echo "$number" | sed 's/[^0-9]//g')

            cat > "$output_file" << EOF
=====================================================
Global Title Analysis
=====================================================
Input Number: $number
Cleaned: $cleaned
Analysis Date: $(date)
=====================================================

Number Analysis:
EOF
            # Basic E.164 analysis
            echo "  Format: E.164 International" >> "$output_file"
            echo "  Total Digits: ${#cleaned}" >> "$output_file"
            echo "" >> "$output_file"

            # Country code detection
            echo "Country Code Detection:" >> "$output_file"

            # Common country codes
            declare -A country_codes
            country_codes=(
                ["1"]="United States / Canada"
                ["7"]="Russia"
                ["20"]="Egypt"
                ["27"]="South Africa"
                ["30"]="Greece"
                ["31"]="Netherlands"
                ["32"]="Belgium"
                ["33"]="France"
                ["34"]="Spain"
                ["36"]="Hungary"
                ["39"]="Italy"
                ["40"]="Romania"
                ["41"]="Switzerland"
                ["43"]="Austria"
                ["44"]="United Kingdom"
                ["45"]="Denmark"
                ["46"]="Sweden"
                ["47"]="Norway"
                ["48"]="Poland"
                ["49"]="Germany"
                ["51"]="Peru"
                ["52"]="Mexico"
                ["53"]="Cuba"
                ["54"]="Argentina"
                ["55"]="Brazil"
                ["56"]="Chile"
                ["57"]="Colombia"
                ["60"]="Malaysia"
                ["61"]="Australia"
                ["62"]="Indonesia"
                ["63"]="Philippines"
                ["64"]="New Zealand"
                ["65"]="Singapore"
                ["66"]="Thailand"
                ["81"]="Japan"
                ["82"]="South Korea"
                ["84"]="Vietnam"
                ["86"]="China"
                ["90"]="Turkey"
                ["91"]="India"
                ["92"]="Pakistan"
                ["93"]="Afghanistan"
                ["94"]="Sri Lanka"
                ["95"]="Myanmar"
                ["212"]="Morocco"
                ["213"]="Algeria"
                ["216"]="Tunisia"
                ["218"]="Libya"
                ["220"]="Gambia"
                ["221"]="Senegal"
                ["234"]="Nigeria"
                ["249"]="Sudan"
                ["254"]="Kenya"
                ["255"]="Tanzania"
                ["256"]="Uganda"
                ["260"]="Zambia"
                ["263"]="Zimbabwe"
                ["351"]="Portugal"
                ["353"]="Ireland"
                ["354"]="Iceland"
                ["358"]="Finland"
                ["380"]="Ukraine"
                ["381"]="Serbia"
                ["420"]="Czech Republic"
                ["421"]="Slovakia"
                ["852"]="Hong Kong"
                ["853"]="Macau"
                ["880"]="Bangladesh"
                ["886"]="Taiwan"
                ["960"]="Maldives"
                ["961"]="Lebanon"
                ["962"]="Jordan"
                ["963"]="Syria"
                ["964"]="Iraq"
                ["965"]="Kuwait"
                ["966"]="Saudi Arabia"
                ["967"]="Yemen"
                ["968"]="Oman"
                ["970"]="Palestine"
                ["971"]="UAE"
                ["972"]="Israel"
                ["973"]="Bahrain"
                ["974"]="Qatar"
                ["975"]="Bhutan"
                ["976"]="Mongolia"
                ["977"]="Nepal"
                ["992"]="Tajikistan"
                ["993"]="Turkmenistan"
                ["994"]="Azerbaijan"
                ["995"]="Georgia"
                ["996"]="Kyrgyzstan"
                ["998"]="Uzbekistan"
            )

            local found_cc=""
            local country=""

            # Try 3-digit, then 2-digit, then 1-digit country codes
            for len in 3 2 1; do
                local try_cc="${cleaned:0:$len}"
                if [ -n "${country_codes[$try_cc]}" ]; then
                    found_cc="$try_cc"
                    country="${country_codes[$try_cc]}"
                    break
                fi
            done

            if [ -n "$found_cc" ]; then
                echo "  Country Code: +$found_cc" >> "$output_file"
                echo "  Country: $country" >> "$output_file"
                local national="${cleaned:${#found_cc}}"
                echo "  National Number: $national" >> "$output_file"
                echo "  National Number Length: ${#national}" >> "$output_file"
                print_status "Country: $country (+$found_cc)"
            else
                echo "  Country Code: Unknown" >> "$output_file"
                print_warning "Country code not found in database"
            fi

            echo "" >> "$output_file"
            echo "SS7 Addressing Context:" >> "$output_file"
            echo "  As SCCP Called Party GT:" >> "$output_file"
            echo "    GT Indicator: 0100 (GT includes TT, NP, ES, NAI)" >> "$output_file"
            echo "    Translation Type: 0 (Not used)" >> "$output_file"
            echo "    Numbering Plan: 1 (ISDN/E.164)" >> "$output_file"
            echo "    Encoding Scheme: BCD" >> "$output_file"
            echo "    Nature of Address: 4 (International)" >> "$output_file"
            echo "    Digits: $cleaned" >> "$output_file"
            echo "" >> "$output_file"
            echo "  Potential SSN Associations:" >> "$output_file"
            echo "    SSN 6 (HLR) - If this is an HLR GT" >> "$output_file"
            echo "    SSN 7 (VLR) - If this is a VLR GT" >> "$output_file"
            echo "    SSN 8 (MSC) - If this is an MSC GT" >> "$output_file"
            echo "" >> "$output_file"

            # Online lookup using HLR lookup API concept
            echo "HLR Lookup Information:" >> "$output_file"
            echo "  (Requires API access for live data)" >> "$output_file"
            echo "  Typical HLR Response Fields:" >> "$output_file"
            echo "    - IMSI" >> "$output_file"
            echo "    - MCC+MNC (Network)" >> "$output_file"
            echo "    - Original Network" >> "$output_file"
            echo "    - Ported Status" >> "$output_file"
            echo "    - Current Network" >> "$output_file"
            echo "    - Roaming Status" >> "$output_file"
            echo "    - Roaming Network" >> "$output_file"
            echo "    - Status (reachable/unreachable)" >> "$output_file"

            echo ""
            print_status "Analysis saved to: $output_file"
            cat "$output_file"
            ;;
        2)
            local output_file="$RESULTS_DIR/mcc_mnc_$(date +%Y%m%d_%H%M%S).txt"

            read -p "$(echo -e ${CYAN}"Enter MCC (3 digits) [or press Enter for list]: "${NC})" mcc

            cat > "$output_file" << 'MCCEOF'
=====================================================
MCC/MNC Reference Database
=====================================================

Common MCC/MNC Combinations:
─────────────────────────────────────────────────────
MCC  MNC  Operator                    Country
─────────────────────────────────────────────────────
202  01   Cosmote                     Greece
202  05   Vodafone                    Greece
204  04   Vodafone                    Netherlands
204  08   KPN                         Netherlands
206  01   Proximus                    Belgium
208  01   Orange                      France
208  10   SFR                         France
208  20   Bouygues                    France
214  01   Vodafone                    Spain
214  03   Orange                      Spain
214  07   Movistar                    Spain
216  01   Turkcell                    Turkey
216  02   Vodafone                    Turkey
222  01   TIM                         Italy
222  10   Vodafone                    Italy
222  88   Wind                        Italy
226  01   Vodafone                    Romania
226  10   Orange                      Romania
228  01   Swisscom                    Switzerland
230  01   T-Mobile                    Czech Republic
230  02   O2                          Czech Republic
234  10   O2                          UK
234  15   Vodafone                    UK
234  20   3                           UK
234  30   EE                          UK
234  33   EE                          UK
262  01   T-Mobile                    Germany
262  02   Vodafone                    Germany
262  03   O2                          Germany
268  01   Vodafone                    Portugal
268  06   NOS                         Portugal
272  01   Telenor                     Ireland
302  220  Telus                       Canada
302  370  Fido                        Canada
302  720  Rogers                      Canada
310  010  AT&T                        USA
310  012  Verizon                     USA
310  026  T-Mobile                    USA
310  260  T-Mobile                    USA
311  480  Verizon                     USA
312  530  Sprint                      USA
334  020  Telcel                      Mexico
404  01   Vodafone IN                 India
404  02   AirTel                      India
404  10   AirTel                      India
404  45   AirTel                      India
405  various  Jio                     India
410  01   Mobilink/Jazz               Pakistan
410  03   Ufone                       Pakistan
410  04   Zong                        Pakistan
410  06   Telenor PK                  Pakistan
420  01   STC                         Saudi Arabia
420  03   Mobily                      Saudi Arabia
420  04   Zain                        Saudi Arabia
424  02   Etisalat                    UAE
424  03   du                          UAE
425  01   Orange                      Israel
425  02   Cellcom                     Israel
425  03   Pelephone                   Israel
440  10   NTT Docomo                  Japan
440  20   SoftBank                    Japan
450  05   SKT                         South Korea
450  08   KT                          South Korea
452  01   MobiFone                    Vietnam
452  02   Vinaphone                   Vietnam
454  00   1O1O/CSL                    Hong Kong
460  00   China Mobile                China
460  01   China Unicom                China
460  11   China Telecom               China
502  12   Maxis                       Malaysia
502  13   Celcom                      Malaysia
502  16   Digi                        Malaysia
505  01   Telstra                     Australia
505  02   Optus                       Australia
510  10   Telkomsel                   Indonesia
510  11   XL Axiata                   Indonesia
515  02   Globe                       Philippines
515  03   Smart                       Philippines
520  01   AIS                         Thailand
520  04   TrueMove H                  Thailand
525  01   SingTel                     Singapore
525  03   M1                          Singapore
602  02   Vodafone                    Egypt
602  01   Orange                      Egypt
621  20   Airtel                      Nigeria
621  30   MTN                         Nigeria
621  50   Glo                         Nigeria
639  02   Safaricom                   Kenya
639  03   Airtel                      Kenya
655  01   Vodacom                     South Africa
655  07   Cell C                      South Africa
655  10   MTN                         South Africa
724  02   TIM                         Brazil
724  05   Claro                       Brazil
724  06   Vivo                        Brazil
724  10   Vivo                        Brazil
724  11   Vivo                        Brazil
724  23   Vivo                        Brazil
724  31   Oi                          Brazil
730  01   Entel                       Chile
730  02   Movistar                    Chile
730  10   Claro                       Chile
732  101  Claro                       Colombia
732  103  Tigo                        Colombia
732  123  Movistar                    Colombia
740  01   Movistar                    Ecuador
740  02   Claro                       Ecuador
─────────────────────────────────────────────────────

SS7 Relevance:
- MCC/MNC identifies the home network
- Used in IMSI structure: MCC(3) + MNC(2-3) + MSIN(9-10)
- Helps identify GT ranges for each operator
- Critical for UpdateLocation validation
MCCEOF

            print_status "MCC/MNC reference saved to: $output_file"
            cat "$output_file"
            ;;
        3)
            local output_file="$RESULTS_DIR/point_code_$(date +%Y%m%d_%H%M%S).txt"

            cat > "$output_file" << 'PCEOF'
=====================================================
Point Code Analysis Reference
=====================================================

Point Code Formats:
─────────────────────────────────────────────────────

ITU Format (14-bit): 3-8-3 (Zone-Area-SP)
  Example: 2-123-5
  Range: 0.0.0 to 7.255.7
  Binary: 3 bits + 8 bits + 3 bits = 14 bits
  Used in: Most countries worldwide

ANSI Format (24-bit): 8-8-8 (Network-Cluster-Member)
  Example: 250.10.5
  Range: 0.0.0 to 255.255.255
  Binary: 8 bits + 8 bits + 8 bits = 24 bits
  Used in: North America, some Asian countries

Chinese Format (24-bit): 8-8-8
  Similar to ANSI but different allocation

Japanese Format (16-bit): 5-4-7
  Used exclusively in Japan

SS7 Node Types and Typical Point Codes:
─────────────────────────────────────────────────────
Node Type    SSN    Description
─────────────────────────────────────────────────────
STP          0      Signaling Transfer Point
HLR          6      Home Location Register
VLR          7      Visitor Location Register
MSC          8      Mobile Switching Center
EIR          9      Equipment Identity Register
AuC          10     Authentication Center
SMSC         8      Short Message Service Center
GGSN         149    Gateway GPRS Support Node
SGSN         149    Serving GPRS Support Node
gsmSCF       147    GSM Service Control Function
PCRF         Diameter  Policy & Charging Rules

MTP3 Routing:
  OPC (Originating Point Code) → DPC (Destination Point Code)
  SLS (Signaling Link Selection) for load balancing

SCCP Routing:
  Route on GT (Global Title Translation)
  Route on DPC+SSN
  Route on DPC+SSN+GT

M3UA Routing Context:
  Maps to SS7 DPC+SI+OPC
  Allows multiple contexts per SCTP association
PCEOF

            print_status "Point code reference saved to: $output_file"
            cat "$output_file"
            ;;
        4)
            local output_file="$RESULTS_DIR/ssn_reference_$(date +%Y%m%d_%H%M%S).txt"

            cat > "$output_file" << 'SSNEOF'
=====================================================
SSN (Subsystem Number) Reference
=====================================================

Standard SSN Assignments:
─────────────────────────────────────────────────────
SSN   Name                    Description
─────────────────────────────────────────────────────
0     SSN not known/not used  Default/management
1     SCCP MG                 SCCP Management
2     Reserved (ITU-T)
3     ISUP                    ISDN User Part
4     OMAP                    Op & Maintenance
5     MAP                     Mobile Application Part
6     HLR                     Home Location Register
7     VLR                     Visitor Location Register
8     MSC                     Mobile Switching Center
9     EIR                     Equipment Identity Register
10    AuC                     Authentication Center
11    ISSS-MAP (EMS)          For PCS1900
12    ISSS-MAP (SPREAD)       For PCS1900
13    BSSAP                   BSS Application Part
14    RANAP                   Radio Access Network AP
142   PCAP                    Positioning Calc AP
143   BSC (BSSAP-LE)          Serving Mobile Location
145   SMLC (BSSAP-LE)         Serving Mobile Location
146   SIWF                    System Info Web Function
147   CAP/gsmSCF              CAMEL Service Control
148   gsmSSF                  CAMEL Switching Function
149   SGSN (MAP)              GPRS Support Node
150   GGSN (MAP)              Gateway GPRS Support
248   CSS                     Cell Selection Service
249   PCAP                    Positioning Protocol
250   BSC (BSSAP+)            Enhanced BSS AP
251   MSC (BSSAP+)            Enhanced MSS AP
252   SMLC                    Serving Mobile LC
253   BSS O&M                 BSS O&M
254   BSSAP                   A Interface

Security Notes:
─────────────────────────────────────────────────────
- SSN 6 (HLR): Primary target for SRI, ATI attacks
- SSN 7 (VLR): Target for CancelLocation, ISD
- SSN 8 (MSC): Used in UpdateLocation spoofing
- SSN 147 (gsmSCF): CAMEL service manipulation
- SSN 149 (SGSN): GPRS/data service attacks

Filter Recommendations:
- Block SSN 6 access from unauthorized GTs
- Monitor SSN 8 for spoofed MSC addresses
- Restrict SSN 147 to known CAMEL platforms
SSNEOF

            print_status "SSN reference saved to: $output_file"
            cat "$output_file"
            ;;
        0) return ;;
        *) print_error "Invalid option" ;;
    esac
    press_enter
}

#=====================================================
# DIAMETER PROTOCOL TOOLS
#=====================================================

diameter_tools() {
    print_banner
    echo -e "${YELLOW}${BOLD}[DIAMETER PROTOCOL TOOLS]${NC}"
    print_separator
    echo ""

    echo -e "${WHITE}Options:${NC}"
    echo -e "  ${GREEN}1)${NC} Diameter protocol reference"
    echo -e "  ${GREEN}2)${NC} Diameter/S6a vulnerability analysis"
    echo -e "  ${GREEN}3)${NC} Diameter port scanner"
    echo -e "  ${GREEN}4)${NC} Diameter message structure"
    echo -e "  ${GREEN}0)${NC} Back"
    echo ""

    read -p "$(echo -e ${CYAN}"Select option: "${NC})" choice

    case "$choice" in
        1)
            local output_file="$RESULTS_DIR/diameter_ref_$(date +%Y%m%d_%H%M%S).txt"
            cat > "$output_file" << 'DEOF'
=====================================================
DIAMETER PROTOCOL REFERENCE
=====================================================

Overview:
  Diameter is the successor to SS7/MAP for 4G/LTE
  networks, using TCP/SCTP over IP.

Key Interfaces:
─────────────────────────────────────────────────────
Interface  Nodes          Application    Purpose
─────────────────────────────────────────────────────
S6a/S6d    MME ↔ HSS     3GPP (16777251) Authentication
S13        MME ↔ EIR     3GPP (16777252) Equipment Check
SWx        3GPP AAA ↔ HSS Diameter SWx   WiFi Auth
S9         PCRF ↔ PCRF   Diameter S9     Policy Roaming
Gx         PCEF ↔ PCRF   Diameter Gx     Policy/Charging
Gy         PCEF ↔ OCS    Diameter Gy     Online Charging
Rx         AF ↔ PCRF     Diameter Rx     Policy Control
Sh         AS ↔ HSS      Diameter Sh     User Data
Cx/Dx      I/S-CSCF↔HSS  Diameter Cx     IMS Registration
S6c        SMS↔HSS       3GPP S6c        SMS MO/MT

Common Diameter Commands:
─────────────────────────────────────────────────────
Command              Code   Interface  Description
─────────────────────────────────────────────────────
Update-Location-Req   316   S6a        Location update
Auth-Information-Req  318   S6a        Auth vectors
Notify-Req            323   S6a        Notification
Purge-UE-Req          321   S6a        Purge subscriber
Insert-Sub-Data-Req   319   S6a        Insert data
Delete-Sub-Data-Req   320   S6a        Delete data
Cancel-Location-Req   317   S6a        Cancel location

Default Port: 3868 (TCP/SCTP)
Security: TLS/DTLS recommended but often not used

SS7 MAP Equivalent Operations:
─────────────────────────────────────────────────────
Diameter (S6a)        SS7 MAP
─────────────────────────────────────────────────────
Update-Location       updateLocation
Cancel-Location       cancelLocation
Authentication-Info   sendAuthInfo
Insert-Subscriber     insertSubscriberData
Delete-Subscriber     deleteSubscriberData
Purge-UE              purgeMS
Notify                n/a (new in LTE)
DEOF
            print_status "Reference saved to: $output_file"
            cat "$output_file"
            ;;
        2)
            local output_file="$RESULTS_DIR/diameter_vuln_$(date +%Y%m%d_%H%M%S).txt"
            cat > "$output_file" << 'DVEOF'
=====================================================
DIAMETER/S6a VULNERABILITY ANALYSIS
=====================================================

1. Location Tracking (similar to SS7 ATI)
   Command: Update-Location-Request (ULR)
   Risk: HIGH
   Attack: Query subscriber location via HSS
   Mitigation: IPX filtering, mutual TLS

2. Authentication Vector Theft
   Command: Authentication-Information-Request (AIR)
   Risk: CRITICAL
   Attack: Obtain auth vectors to clone SIM
   Mitigation: Strict origin validation

3. Subscriber Profile Manipulation
   Command: Insert-Subscriber-Data-Request (IDR)
   Risk: HIGH
   Attack: Modify subscriber profile
   Mitigation: Command filtering

4. Service Denial
   Command: Cancel-Location-Request (CLR)
   Risk: HIGH
   Attack: De-register subscriber from MME
   Mitigation: Origin validation, rate limiting

5. IMSI Disclosure
   Command: Various
   Risk: MEDIUM
   Attack: Correlate IMSI with MSISDN
   Mitigation: Privacy enhanced designs

Key Differences from SS7:
- IP-based (easier to access than TDM)
- Should use TLS (but often doesn't)
- Routing via DRA (Diameter Routing Agent)
- IPX-based interconnect
- More AVPs for security features

GSMA Recommendations:
- FS.19: Diameter Interconnect Security
- IR.88: Diameter Roaming Guidelines
- Implement DEA (Diameter Edge Agent)
- Mandatory TLS between peers
- AVP-level filtering
DVEOF
            print_status "Analysis saved to: $output_file"
            cat "$output_file"
            ;;
        3)
            read -p "$(echo -e ${CYAN}"Enter target IP: "${NC})" target_ip
            if [ -n "$target_ip" ]; then
                local output_file="$RESULTS_DIR/diameter_scan_$(date +%Y%m%d_%H%M%S).txt"
                print_info "Scanning Diameter ports..."
                nmap -sS -sV -p 3868,3869,3870,5868,5869 \
                    --open -oN "$output_file" "$target_ip" 2>&1 | tee -a "$output_file"
                print_status "Scan results saved to: $output_file"
            fi
            ;;
        4)
            local output_file="$RESULTS_DIR/diameter_msg_$(date +%Y%m%d_%H%M%S).txt"
            cat > "$output_file" << 'DMEOF'
=====================================================
DIAMETER MESSAGE STRUCTURE
=====================================================

Header (20 bytes):
├── Version (1 byte): 1
├── Message Length (3 bytes): Total message length
├── Flags (1 byte):
│   ├── R (Request): 0=Answer, 1=Request
│   ├── P (Proxiable): Can be proxied
│   ├── E (Error): Error message
│   └── T (Retransmitted): Retransmission
├── Command Code (3 bytes): Operation type
├── Application ID (4 bytes): Application identifier
├── Hop-by-Hop ID (4 bytes): Unique per hop
└── End-to-End ID (4 bytes): Unique end-to-end

AVP (Attribute Value Pair):
├── AVP Code (4 bytes)
├── AVP Flags (1 byte):
│   ├── V (Vendor): Vendor-specific
│   ├── M (Mandatory): Must be understood
│   └── P (Protected): Encrypted
├── AVP Length (3 bytes)
├── Vendor ID (4 bytes, optional)
└── Data (variable length, padded to 4-byte boundary)

S6a Update-Location-Request Example:
├── Header:
│   ├── Version: 1
│   ├── Length: [calculated]
│   ├── Flags: R=1, P=1
│   ├── Command: 316 (Update-Location)
│   └── Application: 16777251 (3GPP S6a)
├── Session-Id AVP (263)
├── Auth-Session-State AVP (277): NO_STATE_MAINTAINED
├── Origin-Host AVP (264): mme.operator.com
├── Origin-Realm AVP (296): operator.com
├── Destination-Realm AVP (283): home.com
├── User-Name AVP (1): [IMSI]
├── RAT-Type AVP (1032): EUTRAN
├── ULR-Flags AVP (1405):
│   ├── Single-Registration
│   ├── S6a/S6d-Indicator
│   └── Skip-Subscriber-Data
├── Visited-PLMN-Id AVP (1407): [MCC+MNC]
└── Terminal-Information AVP (1401):
    ├── IMEI AVP (1402): [DEVICE_IMEI]
    └── Software-Version AVP (1403): [VERSION]
DMEOF
            print_status "Message structure saved to: $output_file"
            cat "$output_file"
            ;;
        0) return ;;
        *) print_error "Invalid option" ;;
    esac
    press_enter
}

#=====================================================
# SIGTRAN TOOLS
#=====================================================

sigtran_tools() {
    print_banner
    echo -e "${YELLOW}${BOLD}[SIGTRAN TOOLS]${NC}"
    print_separator
    echo ""

    echo -e "${WHITE}Options:${NC}"
    echo -e "  ${GREEN}1)${NC} SIGTRAN protocol stack reference"
    echo -e "  ${GREEN}2)${NC} M3UA connection tester"
    echo -e "  ${GREEN}3)${NC} SCTP association checker"
    echo -e "  ${GREEN}4)${NC} Generate M3UA ASP configuration"
    echo -e "  ${GREEN}5)${NC} SIGTRAN security checklist"
    echo -e "  ${GREEN}0)${NC} Back"
    echo ""

    read -p "$(echo -e ${CYAN}"Select option: "${NC})" choice

    case "$choice" in
        1)
            local output_file="$RESULTS_DIR/sigtran_ref_$(date +%Y%m%d_%H%M%S).txt"
            cat > "$output_file" << 'SIGEOF'
=====================================================
SIGTRAN PROTOCOL STACK REFERENCE
=====================================================

Protocol Stack Comparison:
─────────────────────────────────────────────────────

Traditional SS7:          SIGTRAN (SS7 over IP):
                          
┌──────────┐              ┌──────────┐
│   MAP    │              │   MAP    │
├──────────┤              ├──────────┤
│   TCAP   │              │   TCAP   │
├──────────┤              ├──────────┤
│   SCCP   │              │   SCCP   │
├──────────┤              ├──────────┤
│   MTP3   │              │   M3UA   │
├──────────┤              ├──────────┤
│   MTP2   │              │   SCTP   │
├──────────┤              ├──────────┤
│   MTP1   │              │    IP    │
└──────────┘              └──────────┘

SIGTRAN Adaptation Layers:
─────────────────────────────────────────────────────
Layer    RFC     Port   SS7 Equivalent   Description
─────────────────────────────────────────────────────
M3UA    4666    2905   MTP3             MTP3 User Adapt
M2UA    3331    2904   MTP2             MTP2 User Adapt
M2PA    4165    3565   MTP2             MTP2 Peer Adapt
SUA     3868    14001  SCCP             SCCP User Adapt
IUA     4233    9900   ISDN Q.921       ISDN User Adapt

M3UA Message Classes:
─────────────────────────────────────────────────────
Class  Type  Description
─────────────────────────────────────────────────────
0      0     Management: ERR
0      1     Management: NTFY (Notify)
1      1     Transfer: DATA
2      1     SSNM: DUNA (Dest Unavailable)
2      2     SSNM: DAVA (Dest Available)
2      3     SSNM: DAUD (Dest Audit)
2      4     SSNM: SCON (Signaling Congestion)
2      5     SSNM: DUPU (Dest User Part Unavail)
2      6     SSNM: DRST (Dest Restricted)
3      1     ASPSM: ASP UP
3      2     ASPSM: ASP DOWN
3      3     ASPSM: HEARTBEAT
3      4     ASPSM: ASP UP ACK
3      5     ASPSM: ASP DOWN ACK
3      6     ASPSM: HEARTBEAT ACK
4      1     RKM: REG REQ
4      2     RKM: REG RSP
4      3     RKM: DEREG REQ
4      4     RKM: DEREG RSP
9      1     ASPTM: ASP ACTIVE
9      2     ASPTM: ASP INACTIVE
9      3     ASPTM: ASP ACTIVE ACK
9      4     ASPTM: ASP INACTIVE ACK

ASP States:
  DOWN → INACTIVE → ACTIVE → INACTIVE → DOWN
  
Traffic Modes:
  - Override: 1 active ASP per AS
  - Loadshare: Multiple active ASPs
  - Broadcast: All ASPs receive traffic
SIGEOF
            print_status "Reference saved to: $output_file"
            cat "$output_file"
            ;;
        2)
            read -p "$(echo -e ${CYAN}"Enter target IP: "${NC})" target_ip
            read -p "$(echo -e ${CYAN}"Enter port (default: 2905): "${NC})" port
            port=${port:-2905}

            if [ -n "$target_ip" ]; then
                print_info "Testing M3UA connectivity to $target_ip:$port..."

                # Create Python SCTP test script
                local test_script="$WORK_DIR/m3ua_test.py"
                cat > "$test_script" << 'PYTEST'
#!/usr/bin/env python3
import socket
import struct
import sys
import time

def create_m3ua_aspup():
    """Create M3UA ASP-UP message"""
    # M3UA Header: Version(1) + Reserved(1) + Class(1) + Type(1) + Length(4)
    version = 1
    reserved = 0
    msg_class = 3   # ASPSM
    msg_type = 1    # ASP UP
    length = 8      # Header only

    header = struct.pack('!BBBBH2x',
                         version, reserved, msg_class, msg_type, length)
    return header

def create_m3ua_heartbeat():
    """Create M3UA Heartbeat message"""
    version = 1
    reserved = 0
    msg_class = 3   # ASPSM
    msg_type = 3    # Heartbeat
    length = 8

    header = struct.pack('!BBBBH2x',
                         version, reserved, msg_class, msg_type, length)
    return header

def test_m3ua(host, port):
    print(f"\n[*] Testing M3UA connection to {host}:{port}")
    print(f"[*] Timestamp: {time.strftime('%Y-%m-%d %H:%M:%S')}")
    print("-" * 50)

    try:
        # Try SCTP first
        try:
            import sctp
            sock = sctp.sctpsocket_tcp(socket.AF_INET)
            sock.settimeout(10)
            print(f"[*] Attempting SCTP connection...")
            sock.connect((host, int(port)))
            print(f"[+] SCTP connection established!")

            # Send ASP-UP
            aspup = create_m3ua_aspup()
            sock.send(aspup)
            print(f"[+] Sent M3UA ASP-UP message")

            # Wait for response
            response = sock.recv(1024)
            if response:
                print(f"[+] Received response: {response.hex()}")
                # Parse response
                if len(response) >= 4:
                    ver, res, cls, typ = struct.unpack('!BBBB', response[:4])
                    print(f"    Version: {ver}")
                    print(f"    Class: {cls}")
                    print(f"    Type: {typ}")
                    if cls == 3 and typ == 4:
                        print(f"[+] Received ASP-UP-ACK! M3UA peer is responsive.")
                    elif cls == 0 and typ == 0:
                        print(f"[-] Received ERR. Peer rejected connection.")

            sock.close()
        except ImportError:
            print("[!] pysctp not available, falling back to TCP probe")
            sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            sock.settimeout(10)
            print(f"[*] Attempting TCP connection to {host}:{port}...")
            result = sock.connect_ex((host, int(port)))
            if result == 0:
                print(f"[+] TCP port {port} is OPEN")
                print(f"[*] Sending M3UA probe...")
                aspup = create_m3ua_aspup()
                sock.send(aspup)
                try:
                    response = sock.recv(1024)
                    if response:
                        print(f"[+] Received response ({len(response)} bytes)")
                        print(f"    Hex: {response.hex()}")
                except:
                    print("[-] No response received")
            else:
                print(f"[-] TCP port {port} is CLOSED")
            sock.close()

    except socket.timeout:
        print(f"[-] Connection timed out")
    except ConnectionRefusedError:
        print(f"[-] Connection refused")
    except Exception as e:
        print(f"[-] Error: {e}")

if __name__ == '__main__':
    host = sys.argv[1] if len(sys.argv) > 1 else '127.0.0.1'
    port = sys.argv[2] if len(sys.argv) > 2 else '2905'
    test_m3ua(host, port)
PYTEST

                python "$test_script" "$target_ip" "$port" 2>&1
            fi
            ;;
        3)
            read -p "$(echo -e ${CYAN}"Enter target IP: "${NC})" target_ip
            if [ -n "$target_ip" ]; then
                print_info "Checking SCTP associations..."
                echo ""

                # SCTP INIT chunk scan
                if command -v nmap &> /dev/null; then
                    nmap -sY -sV -p 2905,2906,2907,2944,3868,9900,14001 \
                        --open "$target_ip" 2>&1
                fi

                echo ""
                # Check local SCTP associations
                if command -v ss &> /dev/null; then
                    print_info "Local SCTP associations:"
                    ss -s 2>/dev/null
                fi
            fi
            ;;
        4)
            local output_file="$CONFIG_DIR/m3ua_config_$(date +%Y%m%d_%H%M%S).conf"

            read -p "$(echo -e ${CYAN}"Local 
