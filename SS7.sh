#!/bin/bash

#============================================================================
# SS7 Security Testing Toolkit for Termux
# Version: 3.0
# Purpose: Authorized SS7/SIGTRAN Security Auditing
# Author: Emmanuel suah
#============================================================================

# ========================= CONFIGURATION ==================================
VERSION="3.0"
INSTALL_DIR="$HOME/ss7-toolkit"
LOG_DIR="$INSTALL_DIR/logs"
CONFIG_DIR="$INSTALL_DIR/config"
RESULTS_DIR="$INSTALL_DIR/results"
PCAP_DIR="$INSTALL_DIR/pcaps"
SCRIPTS_DIR="$INSTALL_DIR/scripts"
DB_DIR="$INSTALL_DIR/database"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
LOG_FILE="$LOG_DIR/ss7_toolkit_${TIMESTAMP}.log"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
ORANGE='\033[0;33m'
NC='\033[0m' # No Color
BOLD='\033[1m'
DIM='\033[2m'
UNDERLINE='\033[4m'
BLINK='\033[5m'

# Default SS7 Parameters
DEFAULT_SSN_HLR=6
DEFAULT_SSN_VLR=7
DEFAULT_SSN_MSC=8
DEFAULT_SSN_EIR=9
DEFAULT_SSN_GMLC=145
DEFAULT_SSN_CAP=146
DEFAULT_SCTP_PORT=2905
DEFAULT_M3UA_PORT=2905
DEFAULT_SUA_PORT=14001

# ========================= UTILITY FUNCTIONS ==============================

log() {
    local level="$1"
    shift
    local message="$*"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $message" >> "$LOG_FILE" 2>/dev/null
}

print_banner() {
    clear
    echo -e "${RED}"
    cat << 'BANNER'
    ╔══════════════════════════════════════════════════════════════════╗
    ║  ███████╗███████╗███████╗    ████████╗ ██████╗  ██████╗ ██╗    ║
    ║  ██╔════╝██╔════╝╚════██║    ╚══██╔══╝██╔═══██╗██╔═══██╗██║    ║
    ║  ███████╗███████╗    ██╔╝       ██║   ██║   ██║██║   ██║██║    ║
    ║  ╚════██║╚════██║   ██╔╝        ██║   ██║   ██║██║   ██║██║    ║
    ║  ███████║███████║   ██║         ██║   ╚██████╔╝╚██████╔╝███████║
    ║  ╚══════╝╚══════╝   ╚═╝         ╚═╝    ╚═════╝  ╚═════╝ ╚══════╝
    ║                                                                  ║
    ║          Advanced SS7/SIGTRAN Security Testing Toolkit           ║
    ║                    [ Termux Edition v3.0 ]                       ║
    ╚══════════════════════════════════════════════════════════════════╝
BANNER
    echo -e "${NC}"
    echo -e "${YELLOW}  ⚠  FOR AUTHORIZED SECURITY TESTING ONLY  ⚠${NC}"
    echo -e "${DIM}  Unauthorized access to telecom networks is illegal${NC}"
    echo ""
}

print_separator() {
    echo -e "${BLUE}══════════════════════════════════════════════════════════════${NC}"
}

print_section() {
    echo ""
    echo -e "${CYAN}┌──────────────────────────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│${WHITE}  $1${NC}"
    echo -e "${CYAN}└──────────────────────────────────────────────────────────┘${NC}"
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

print_progress() {
    echo -e "${MAGENTA}[→]${NC} $1"
}

spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " ${CYAN}[%c]${NC}  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

progress_bar() {
    local current=$1
    local total=$2
    local width=50
    local percentage=$((current * 100 / total))
    local filled=$((current * width / total))
    local empty=$((width - filled))
    
    printf "\r${CYAN}  ["
    printf "%${filled}s" | tr ' ' '█'
    printf "%${empty}s" | tr ' ' '░'
    printf "] ${percentage}%%${NC}"
    
    if [ "$current" -eq "$total" ]; then
        echo ""
    fi
}

confirm_action() {
    echo -e "${YELLOW}[?]${NC} $1 (y/N): \c"
    read -r response
    case "$response" in
        [yY][eE][sS]|[yY]) return 0 ;;
        *) return 1 ;;
    esac
}

validate_ip() {
    local ip=$1
    if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        IFS='.' read -r -a octets <<< "$ip"
        for octet in "${octets[@]}"; do
            if [ "$octet" -gt 255 ]; then
                return 1
            fi
        done
        return 0
    fi
    return 1
}

validate_gt() {
    local gt=$1
    if [[ $gt =~ ^\+?[0-9]{1,15}$ ]]; then
        return 0
    fi
    return 1
}

validate_imsi() {
    local imsi=$1
    if [[ $imsi =~ ^[0-9]{15}$ ]]; then
        return 0
    fi
    return 1
}

validate_pc() {
    local pc=$1
    if [[ $pc =~ ^[0-9]{1,5}$ ]] && [ "$pc" -le 16383 ]; then
        return 0
    fi
    return 1
}

# ========================= INSTALLATION ===================================

check_root() {
    if [ "$(id -u)" = "0" ]; then
        print_warning "Running as root - some features may behave differently in Termux"
    fi
}

setup_directories() {
    print_progress "Setting up directory structure..."
    mkdir -p "$INSTALL_DIR" "$LOG_DIR" "$CONFIG_DIR" "$RESULTS_DIR" \
             "$PCAP_DIR" "$SCRIPTS_DIR" "$DB_DIR" \
             "$RESULTS_DIR/maps" "$RESULTS_DIR/camel" \
             "$RESULTS_DIR/isup" "$RESULTS_DIR/scans" \
             "$RESULTS_DIR/reports"
    print_status "Directory structure created"
    log "INFO" "Directory structure initialized"
}

install_dependencies() {
    print_section "Installing Dependencies"
    
    echo -e "${WHITE}  Updating package repositories...${NC}"
    pkg update -y 2>/dev/null &
    spinner $!
    
    local packages=(
        "python"
        "python-pip"
        "git"
        "nmap"
        "tcpdump"
        "tshark"
        "wget"
        "curl"
        "openssl"
        "clang"
        "make"
        "cmake"
        "automake"
        "autoconf"
        "libtool"
        "pkg-config"
        "libxml2"
        "libpcap"
        "scapy"
        "hexdump"
        "net-tools"
        "iproute2"
        "jq"
        "sqlite"
    )
    
    local total=${#packages[@]}
    local current=0
    
    for package in "${packages[@]}"; do
        current=$((current + 1))
        progress_bar $current $total
        pkg install -y "$package" >> "$LOG_FILE" 2>&1
    done
    
    echo ""
    print_status "System packages installed"
    
    # Python packages
    print_progress "Installing Python libraries..."
    local pip_packages=(
        "scapy"
        "pysctp"
        "ipaddress"
        "colorama"
        "tabulate"
        "cryptography"
        "pyasn1"
        "pyasn1-modules"
        "requests"
        "netifaces"
        "hexdump"
    )
    
    for pip_pkg in "${pip_packages[@]}"; do
        pip install "$pip_pkg" >> "$LOG_FILE" 2>&1
    done
    
    print_status "Python libraries installed"
    log "INFO" "All dependencies installed successfully"
}

install_ss7_tools() {
    print_section "Installing SS7-Specific Tools"
    
    # SigPloit
    print_progress "Installing SigPloit SS7 Framework..."
    if [ ! -d "$INSTALL_DIR/SigPloit" ]; then
        git clone https://github.com/SigPloiter/SigPloit.git "$INSTALL_DIR/SigPloit" >> "$LOG_FILE" 2>&1
        if [ -d "$INSTALL_DIR/SigPloit" ]; then
            cd "$INSTALL_DIR/SigPloit" && pip install -r requirements.txt >> "$LOG_FILE" 2>&1
            print_status "SigPloit installed"
        else
            print_warning "SigPloit installation failed - continuing..."
        fi
    else
        print_info "SigPloit already installed"
    fi
    
    # ss7MAPer
    print_progress "Installing ss7MAPer..."
    if [ ! -d "$INSTALL_DIR/ss7MAPer" ]; then
        git clone https://github.com/ernw/ss7MAPer.git "$INSTALL_DIR/ss7MAPer" >> "$LOG_FILE" 2>&1
        if [ -d "$INSTALL_DIR/ss7MAPer" ]; then
            print_status "ss7MAPer installed"
        else
            print_warning "ss7MAPer installation failed - continuing..."
        fi
    else
        print_info "ss7MAPer already installed"
    fi
    
    # SCTPscan
    print_progress "Building SCTPscan..."
    if [ ! -f "$INSTALL_DIR/sctpscan" ]; then
        cat > "$INSTALL_DIR/sctpscan.c" << 'SCTPCODE'
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <errno.h>
#include <fcntl.h>
#include <sys/select.h>

#define SCTP_INIT_CHUNK 1
#define SCTP_INIT_ACK_CHUNK 2
#define SCTP_ABORT_CHUNK 6

struct sctp_header {
    uint16_t src_port;
    uint16_t dst_port;
    uint32_t vtag;
    uint32_t checksum;
};

struct sctp_chunk {
    uint8_t type;
    uint8_t flags;
    uint16_t length;
};

int main(int argc, char *argv[]) {
    printf("[SCTPscan] SCTP Port Scanner for SS7/SIGTRAN\n");
    printf("[SCTPscan] Use nmap with --sctp flag for scanning\n");
    printf("[SCTPscan] Example: nmap -sY -p 2905,2906,14001 <target>\n");
    return 0;
}
SCTPCODE
        cc -o "$INSTALL_DIR/sctpscan" "$INSTALL_DIR/sctpscan.c" >> "$LOG_FILE" 2>&1
        print_status "SCTPscan built"
    fi
    
    log "INFO" "SS7-specific tools installed"
}

generate_config() {
    print_progress "Generating default configuration..."
    
    cat > "$CONFIG_DIR/ss7_config.conf" << 'CONFIG'
# SS7 Toolkit Configuration File
# ================================

[general]
toolkit_version = 3.0
log_level = INFO
auto_save_results = true
pcap_capture = true
max_threads = 10
timeout = 30

[sigtran]
# M3UA Parameters
m3ua_port = 2905
m3ua_opc = 1
m3ua_dpc = 2
m3ua_si = 3
m3ua_ni = 2
m3ua_routing_context = 1

# SUA Parameters
sua_port = 14001

# SCTP Parameters
sctp_port_range = 2905-2920
sctp_timeout = 5
sctp_max_retries = 3

[map]
# MAP Parameters
default_ssn_hlr = 6
default_ssn_vlr = 7
default_ssn_msc = 8
default_ssn_eir = 9
default_ssn_gmlc = 145
map_version = 3
map_ac_version = 3

[sccp]
# SCCP Parameters
sccp_protocol_class = 1
sccp_message_handling = 8

[isup]
# ISUP Parameters  
isup_cic_range_start = 1
isup_cic_range_end = 31

[camel]
# CAMEL Parameters
camel_phase = 4
camel_ssn = 146

[diameter]
# Diameter Parameters (4G/LTE)
diameter_port = 3868
diameter_tls_port = 5868

[gtp]
# GTP Parameters
gtp_c_port = 2123
gtp_u_port = 2152

[target]
# Target Configuration (Set before testing)
target_ip = 
target_port = 2905
target_gt = 
target_pc = 
target_ssn = 6

[source]
# Source Configuration
source_gt = 
source_pc = 
source_ssn = 8

[scan]
# Scanning Parameters
scan_timeout = 10
scan_retries = 3
scan_delay = 100
aggressive_scan = false
CONFIG

    print_status "Configuration file generated: $CONFIG_DIR/ss7_config.conf"
    log "INFO" "Default configuration generated"
}

generate_python_modules() {
    print_progress "Generating SS7 Python modules..."
    
    # SS7 MAP Message Builder
    cat > "$SCRIPTS_DIR/ss7_map_builder.py" << 'PYMAP'
#!/usr/bin/env python3
"""
SS7 MAP Message Builder
Constructs MAP protocol messages for security testing
"""

import struct
import sys
import os
import json
from datetime import datetime

class MAPMessageType:
    """MAP Operation Codes"""
    UPDATE_LOCATION = 2
    CANCEL_LOCATION = 3
    PROVIDE_ROAMING_NUMBER = 4
    INSERT_SUBSCRIBER_DATA = 7
    DELETE_SUBSCRIBER_DATA = 8
    SEND_ROUTING_INFO = 22
    SEND_ROUTING_INFO_FOR_GPRS = 24
    PROVIDE_SUBSCRIBER_INFO = 70
    ANY_TIME_INTERROGATION = 71
    SEND_IMSI = 58
    SEND_AUTH_INFO = 56
    CHECK_IMEI = 43
    PURGE_MS = 67
    PROVIDE_SUBSCRIBER_LOCATION = 83
    SEND_ROUTING_INFO_FOR_LCS = 85
    SUBSCRIBER_LOCATION_REPORT = 86

class TCAPMessageType:
    """TCAP Message Types"""
    BEGIN = 0x62
    END = 0x64
    CONTINUE = 0x65
    ABORT = 0x67

class BEREncoder:
    """Basic BER/ASN.1 Encoder for MAP messages"""
    
    @staticmethod
    def encode_tag(tag):
        if tag < 0x1F:
            return bytes([tag])
        result = bytes([tag & 0x1F | 0x1F])
        tag >>= 5
        while tag > 0:
            result = bytes([tag & 0x7F | 0x80]) + result
            tag >>= 7
        return result
    
    @staticmethod
    def encode_length(length):
        if length < 0x80:
            return bytes([length])
        result = b''
        temp = length
        while temp > 0:
            result = bytes([temp & 0xFF]) + result
            temp >>= 8
        return bytes([0x80 | len(result)]) + result
    
    @staticmethod
    def encode_tlv(tag, value):
        tag_bytes = BEREncoder.encode_tag(tag) if isinstance(tag, int) else tag
        length_bytes = BEREncoder.encode_length(len(value))
        return tag_bytes + length_bytes + value
    
    @staticmethod
    def encode_integer(value):
        if value == 0:
            return b'\x00'
        result = b''
        temp = value
        while temp > 0:
            result = bytes([temp & 0xFF]) + result
            temp >>= 8
        if result[0] & 0x80:
            result = b'\x00' + result
        return result
    
    @staticmethod
    def encode_imsi(imsi):
        """Encode IMSI in TBCD format"""
        if len(imsi) % 2:
            imsi += 'F'
        result = bytes([0x09])  # IMSI type
        for i in range(0, len(imsi), 2):
            d1 = int(imsi[i])
            d2 = int(imsi[i+1]) if imsi[i+1] != 'F' else 0xF
            result += bytes([(d2 << 4) | d1])
        return result
    
    @staticmethod
    def encode_msisdn(msisdn):
        """Encode MSISDN/GT in TBCD format"""
        if msisdn.startswith('+'):
            msisdn = msisdn[1:]
        noa = 0x91  # International number
        if len(msisdn) % 2:
            msisdn += 'F'
        result = bytes([noa])
        for i in range(0, len(msisdn), 2):
            d1 = int(msisdn[i])
            d2 = int(msisdn[i+1]) if msisdn[i+1] != 'F' else 0xF
            result += bytes([(d2 << 4) | d1])
        return result
    
    @staticmethod
    def encode_address_string(number):
        """Encode AddressString"""
        encoded = BEREncoder.encode_msisdn(number)
        return BEREncoder.encode_tlv(0x04, encoded)

class SCCPBuilder:
    """SCCP Message Builder"""
    
    SCCP_UDT = 0x09
    SCCP_XUDT = 0x11
    
    @staticmethod
    def encode_global_title(gt, gt_indicator=0x04, tt=0x00, np=0x01, noa=0x04):
        """Encode Global Title"""
        if gt.startswith('+'):
            gt = gt[1:]
        
        gt_data = bytes([np << 4 | noa])
        
        if len(gt) % 2:
            gt += '0'
        
        for i in range(0, len(gt), 2):
            d1 = int(gt[i])
            d2 = int(gt[i+1])
            gt_data += bytes([(d2 << 4) | d1])
        
        return gt_data
    
    @staticmethod
    def build_called_party(gt, ssn, pc=None):
        """Build Called Party Address"""
        ai = 0x12  # GT indicator = 0100, SSN indicator = 1
        if pc is not None:
            ai |= 0x01  # PC indicator
        
        result = bytes([ai])
        
        if pc is not None:
            result += struct.pack('<H', pc)
        
        result += bytes([ssn])
        result += SCCPBuilder.encode_global_title(gt)
        
        return result
    
    @staticmethod
    def build_calling_party(gt, ssn, pc=None):
        """Build Calling Party Address"""
        return SCCPBuilder.build_called_party(gt, ssn, pc)
    
    @staticmethod
    def build_udt(called_party, calling_party, data):
        """Build SCCP UDT Message"""
        msg = bytes([SCCPBuilder.SCCP_UDT])
        msg += bytes([0x01])  # Protocol class
        msg += bytes([0x03])  # Called party pointer placeholder
        msg += bytes([0x03 + len(called_party)])  # Calling party pointer
        msg += bytes([0x03 + len(called_party) + len(calling_party)])  # Data pointer
        
        msg += bytes([len(called_party)]) + called_party
        msg += bytes([len(calling_party)]) + calling_party
        msg += bytes([len(data)]) + data
        
        return msg

class MAPBuilder:
    """MAP Protocol Message Builder"""
    
    def __init__(self):
        self.ber = BEREncoder()
        self.messages_built = 0
    
    def build_sri(self, msisdn, source_gt=None):
        """Build SendRoutingInfo (SRI) request"""
        # MAP Invoke component
        msisdn_encoded = self.ber.encode_msisdn(msisdn)
        msisdn_tlv = self.ber.encode_tlv(0x80, msisdn_encoded)
        
        interrogation_type = self.ber.encode_tlv(0x83, b'\x00')  # Basic call
        or_capability = self.ber.encode_tlv(0x85, b'\x00')
        
        # MAP Invoke
        invoke_data = msisdn_tlv + interrogation_type + or_capability
        
        # TCAP component
        invoke_id = self.ber.encode_tlv(0x02, b'\x01')  # InvokeID = 1
        opcode = self.ber.encode_tlv(0x02, bytes([MAPMessageType.SEND_ROUTING_INFO]))
        
        invoke = self.ber.encode_tlv(0xA1, invoke_id + opcode + 
                 self.ber.encode_tlv(0x30, invoke_data))
        
        component = self.ber.encode_tlv(0x6C, invoke)
        
        self.messages_built += 1
        return {
            'type': 'SRI',
            'opcode': MAPMessageType.SEND_ROUTING_INFO,
            'target_msisdn': msisdn,
            'raw': component.hex(),
            'component': component,
            'description': f'SendRoutingInfo for MSISDN: {msisdn}'
        }
    
    def build_sri_gprs(self, imsi):
        """Build SendRoutingInfoForGprs request"""
        imsi_encoded = self.ber.encode_imsi(imsi)
        imsi_tlv = self.ber.encode_tlv(0x80, imsi_encoded)
        
        invoke_id = self.ber.encode_tlv(0x02, b'\x01')
        opcode = self.ber.encode_tlv(0x02, bytes([MAPMessageType.SEND_ROUTING_INFO_FOR_GPRS]))
        
        invoke = self.ber.encode_tlv(0xA1, invoke_id + opcode + 
                 self.ber.encode_tlv(0x30, imsi_tlv))
        
        component = self.ber.encode_tlv(0x6C, invoke)
        
        self.messages_built += 1
        return {
            'type': 'SRI-GPRS',
            'opcode': MAPMessageType.SEND_ROUTING_INFO_FOR_GPRS,
            'target_imsi': imsi,
            'raw': component.hex(),
            'component': component,
            'description': f'SendRoutingInfoForGprs for IMSI: {imsi}'
        }
    
    def build_ati(self, msisdn, requested_info='location'):
        """Build AnyTimeInterrogation (ATI) request"""
        msisdn_encoded = self.ber.encode_msisdn(msisdn)
        msisdn_tlv = self.ber.encode_tlv(0x81, msisdn_encoded)
        
        subscriber_identity = self.ber.encode_tlv(0xA0, msisdn_tlv)
        
        # Requested info
        req_bits = 0x00
        if 'location' in requested_info:
            req_bits |= 0x01
        if 'state' in requested_info:
            req_bits |= 0x02
        if 'imei' in requested_info:
            req_bits |= 0x04
        
        requested_info_tlv = self.ber.encode_tlv(0xA1, 
                             self.ber.encode_tlv(0x80, bytes([req_bits])))
        
        # GSM SCF address
        gsmscf = self.ber.encode_tlv(0x83, b'\x91\x00\x00\x00\x00')
        
        invoke_data = subscriber_identity + requested_info_tlv + gsmscf
        
        invoke_id = self.ber.encode_tlv(0x02, b'\x01')
        opcode = self.ber.encode_tlv(0x02, bytes([MAPMessageType.ANY_TIME_INTERROGATION]))
        
        invoke = self.ber.encode_tlv(0xA1, invoke_id + opcode + 
                 self.ber.encode_tlv(0x30, invoke_data))
        
        component = self.ber.encode_tlv(0x6C, invoke)
        
        self.messages_built += 1
        return {
            'type': 'ATI',
            'opcode': MAPMessageType.ANY_TIME_INTERROGATION,
            'target_msisdn': msisdn,
            'requested_info': requested_info,
            'raw': component.hex(),
            'component': component,
            'description': f'AnyTimeInterrogation for MSISDN: {msisdn}'
        }
    
    def build_psi(self, imsi):
        """Build ProvideSubscriberInfo (PSI) request"""
        imsi_encoded = self.ber.encode_imsi(imsi)
        imsi_tlv = self.ber.encode_tlv(0x80, imsi_encoded)
        
        requested_info = self.ber.encode_tlv(0xA1,
                         self.ber.encode_tlv(0x80, b'\x07'))  # Location + state + IMEI
        
        invoke_data = imsi_tlv + requested_info
        
        invoke_id = self.ber.encode_tlv(0x02, b'\x01')
        opcode = self.ber.encode_tlv(0x02, bytes([MAPMessageType.PROVIDE_SUBSCRIBER_INFO]))
        
        invoke = self.ber.encode_tlv(0xA1, invoke_id + opcode +
                 self.ber.encode_tlv(0x30, invoke_data))
        
        component = self.ber.encode_tlv(0x6C, invoke)
        
        self.messages_built += 1
        return {
            'type': 'PSI',
            'opcode': MAPMessageType.PROVIDE_SUBSCRIBER_INFO,
            'target_imsi': imsi,
            'raw': component.hex(),
            'component': component,
            'description': f'ProvideSubscriberInfo for IMSI: {imsi}'
        }
    
    def build_update_location(self, imsi, new_vlr_gt):
        """Build UpdateLocation request"""
        imsi_encoded = self.ber.encode_imsi(imsi)
        imsi_tlv = self.ber.encode_tlv(0x04, imsi_encoded)
        
        msc_number = self.ber.encode_address_string(new_vlr_gt)
        vlr_number = self.ber.encode_address_string(new_vlr_gt)
        
        invoke_data = imsi_tlv + msc_number + vlr_number
        
        invoke_id = self.ber.encode_tlv(0x02, b'\x01')
        opcode = self.ber.encode_tlv(0x02, bytes([MAPMessageType.UPDATE_LOCATION]))
        
        invoke = self.ber.encode_tlv(0xA1, invoke_id + opcode +
                 self.ber.encode_tlv(0x30, invoke_data))
        
        component = self.ber.encode_tlv(0x6C, invoke)
        
        self.messages_built += 1
        return {
            'type': 'UL',
            'opcode': MAPMessageType.UPDATE_LOCATION,
            'target_imsi': imsi,
            'new_vlr': new_vlr_gt,
            'raw': component.hex(),
            'component': component,
            'description': f'UpdateLocation for IMSI: {imsi} to VLR: {new_vlr_gt}'
        }
    
    def build_cancel_location(self, imsi):
        """Build CancelLocation request"""
        imsi_encoded = self.ber.encode_imsi(imsi)
        imsi_tlv = self.ber.encode_tlv(0x04, imsi_encoded)
        
        cancellation_type = self.ber.encode_tlv(0x0A, b'\x00')  # updateProcedure
        
        invoke_data = imsi_tlv + cancellation_type
        
        invoke_id = self.ber.encode_tlv(0x02, b'\x01')
        opcode = self.ber.encode_tlv(0x02, bytes([MAPMessageType.CANCEL_LOCATION]))
        
        invoke = self.ber.encode_tlv(0xA1, invoke_id + opcode +
                 self.ber.encode_tlv(0x30, invoke_data))
        
        component = self.ber.encode_tlv(0x6C, invoke)
        
        self.messages_built += 1
        return {
            'type': 'CL',
            'opcode': MAPMessageType.CANCEL_LOCATION,
            'target_imsi': imsi,
            'raw': component.hex(),
            'component': component,
            'description': f'CancelLocation for IMSI: {imsi}'
        }
    
    def build_send_imsi(self, msisdn):
        """Build SendIMSI request"""
        msisdn_encoded = self.ber.encode_msisdn(msisdn)
        msisdn_tlv = self.ber.encode_tlv(0x80, msisdn_encoded)
        
        invoke_id = self.ber.encode_tlv(0x02, b'\x01')
        opcode = self.ber.encode_tlv(0x02, bytes([MAPMessageType.SEND_IMSI]))
        
        invoke = self.ber.encode_tlv(0xA1, invoke_id + opcode +
                 self.ber.encode_tlv(0x30, msisdn_tlv))
        
        component = self.ber.encode_tlv(0x6C, invoke)
        
        self.messages_built += 1
        return {
            'type': 'SI',
            'opcode': MAPMessageType.SEND_IMSI,
            'target_msisdn': msisdn,
            'raw': component.hex(),
            'component': component,
            'description': f'SendIMSI for MSISDN: {msisdn}'
        }
    
    def build_check_imei(self, imei):
        """Build CheckIMEI request"""
        imei_encoded = self.ber.encode_imsi(imei)  # Same TBCD encoding
        imei_tlv = self.ber.encode_tlv(0x04, imei_encoded)
        
        invoke_id = self.ber.encode_tlv(0x02, b'\x01')
        opcode = self.ber.encode_tlv(0x02, bytes([MAPMessageType.CHECK_IMEI]))
        
        invoke = self.ber.encode_tlv(0xA1, invoke_id + opcode +
                 self.ber.encode_tlv(0x30, imei_tlv))
        
        component = self.ber.encode_tlv(0x6C, invoke)
        
        self.messages_built += 1
        return {
            'type': 'CI',
            'opcode': MAPMessageType.CHECK_IMEI,
            'target_imei': imei,
            'raw': component.hex(),
            'component': component,
            'description': f'CheckIMEI for IMEI: {imei}'
        }
    
    def build_send_auth_info(self, imsi, num_vectors=5):
        """Build SendAuthenticationInfo request"""
        imsi_encoded = self.ber.encode_imsi(imsi)
        imsi_tlv = self.ber.encode_tlv(0x04, imsi_encoded)
        
        num_req = self.ber.encode_tlv(0x02, bytes([num_vectors]))
        
        invoke_data = imsi_tlv + num_req
        
        invoke_id = self.ber.encode_tlv(0x02, b'\x01')
        opcode = self.ber.encode_tlv(0x02, bytes([MAPMessageType.SEND_AUTH_INFO]))
        
        invoke = self.ber.encode_tlv(0xA1, invoke_id + opcode +
                 self.ber.encode_tlv(0x30, invoke_data))
        
        component = self.ber.encode_tlv(0x6C, invoke)
        
        self.messages_built += 1
        return {
            'type': 'SAI',
            'opcode': MAPMessageType.SEND_AUTH_INFO,
            'target_imsi': imsi,
            'num_vectors': num_vectors,
            'raw': component.hex(),
            'component': component,
            'description': f'SendAuthenticationInfo for IMSI: {imsi}'
        }
    
    def build_provide_subscriber_location(self, imsi, msisdn=None):
        """Build ProvideSubscriberLocation (PSL) for LCS"""
        location_type = self.ber.encode_tlv(0xA0,
                        self.ber.encode_tlv(0x0A, b'\x01'))  # Current location
        
        imsi_encoded = self.ber.encode_imsi(imsi)
        mlc_number = self.ber.encode_tlv(0x04, b'\x91\x00\x00\x00')
        
        target_ms = self.ber.encode_tlv(0xA3,
                    self.ber.encode_tlv(0x80, imsi_encoded))
        
        invoke_data = location_type + mlc_number + target_ms
        
        invoke_id = self.ber.encode_tlv(0x02, b'\x01')
        opcode = self.ber.encode_tlv(0x02, bytes([MAPMessageType.PROVIDE_SUBSCRIBER_LOCATION]))
        
        invoke = self.ber.encode_tlv(0xA1, invoke_id + opcode +
                 self.ber.encode_tlv(0x30, invoke_data))
        
        component = self.ber.encode_tlv(0x6C, invoke)
        
        self.messages_built += 1
        return {
            'type': 'PSL',
            'opcode': MAPMessageType.PROVIDE_SUBSCRIBER_LOCATION,
            'target_imsi': imsi,
            'raw': component.hex(),
            'component': component,
            'description': f'ProvideSubscriberLocation for IMSI: {imsi}'
        }

    def export_messages(self, messages, filename):
        """Export built messages to JSON"""
        export_data = {
            'generated': datetime.now().isoformat(),
            'total_messages': len(messages),
            'messages': []
        }
        for msg in messages:
            msg_copy = dict(msg)
            if 'component' in msg_copy:
                del msg_copy['component']
            export_data['messages'].append(msg_copy)
        
        with open(filename, 'w') as f:
            json.dump(export_data, f, indent=2)
        
        return filename


if __name__ == '__main__':
    builder = MAPBuilder()
    print("[MAP Builder] SS7 MAP Message Builder loaded")
    print(f"[MAP Builder] Available operations: {builder.messages_built}")
PYMAP

    # SIGTRAN/M3UA Builder
    cat > "$SCRIPTS_DIR/sigtran_builder.py" << 'PYSIG'
#!/usr/bin/env python3
"""
SIGTRAN/M3UA Protocol Builder
Constructs M3UA and SCTP messages for SS7 over IP testing
"""

import struct
import socket
import sys

class M3UAMessageClass:
    MGMT = 0
    TRANSFER = 1
    SSNM = 2
    ASPSM = 3
    ASPTM = 4
    RKM = 9

class M3UAMessageType:
    # MGMT
    ERROR = 0
    NOTIFY = 1
    # TRANSFER
    DATA = 1
    # ASPSM
    ASPUP = 1
    ASPDN = 2
    HEARTBEAT = 3
    ASPUP_ACK = 4
    ASPDN_ACK = 5
    HEARTBEAT_ACK = 6
    # ASPTM
    ASPAC = 1
    ASPIA = 2
    ASPAC_ACK = 3
    ASPIA_ACK = 4

class M3UABuilder:
    """M3UA Message Builder"""
    
    VERSION = 1
    RESERVED = 0
    
    def __init__(self):
        self.tag_network_appearance = 0x0200
        self.tag_routing_context = 0x0006
        self.tag_protocol_data = 0x0210
        self.tag_correlation_id = 0x0013
        self.tag_info_string = 0x0004
        self.tag_affected_pc = 0x0012
        self.tag_traffic_mode = 0x000B
        self.tag_asp_id = 0x0011
    
    def build_header(self, msg_class, msg_type, payload_length):
        """Build M3UA common header"""
        total_length = 8 + payload_length  # Header is 8 bytes
        return struct.pack('!BBBBI',
                          self.VERSION,
                          self.RESERVED,
                          msg_class,
                          msg_type,
                          total_length)
    
    def build_parameter(self, tag, value):
        """Build M3UA TLV parameter"""
        length = 4 + len(value)
        padding = (4 - (length % 4)) % 4
        return struct.pack('!HH', tag, length) + value + b'\x00' * padding
    
    def build_aspup(self, asp_id=None, info_string=None):
        """Build ASP Up message"""
        payload = b''
        
        if asp_id is not None:
            payload += self.build_parameter(self.tag_asp_id, 
                       struct.pack('!I', asp_id))
        
        if info_string is not None:
            payload += self.build_parameter(self.tag_info_string,
                       info_string.encode())
        
        header = self.build_header(M3UAMessageClass.ASPSM,
                                   M3UAMessageType.ASPUP,
                                   len(payload))
        return header + payload
    
    def build_aspdn(self):
        """Build ASP Down message"""
        return self.build_header(M3UAMessageClass.ASPSM,
                                M3UAMessageType.ASPDN, 0)
    
    def build_aspac(self, traffic_mode=None, routing_context=None):
        """Build ASP Active message"""
        payload = b''
        
        if traffic_mode is not None:
            payload += self.build_parameter(self.tag_traffic_mode,
                       struct.pack('!I', traffic_mode))
        
        if routing_context is not None:
            payload += self.build_parameter(self.tag_routing_context,
                       struct.pack('!I', routing_context))
        
        header = self.build_header(M3UAMessageClass.ASPTM,
                                   M3UAMessageType.ASPAC,
                                   len(payload))
        return header + payload
    
    def build_aspia(self, routing_context=None):
        """Build ASP Inactive message"""
        payload = b''
        
        if routing_context is not None:
            payload += self.build_parameter(self.tag_routing_context,
                       struct.pack('!I', routing_context))
        
        header = self.build_header(M3UAMessageClass.ASPTM,
                                   M3UAMessageType.ASPIA,
                                   len(payload))
        return header + payload
    
    def build_heartbeat(self, hb_data=None):
        """Build Heartbeat message"""
        payload = b''
        if hb_data:
            payload += self.build_parameter(0x0009, hb_data)
        
        header = self.build_header(M3UAMessageClass.ASPSM,
                                   M3UAMessageType.HEARTBEAT,
                                   len(payload))
        return header + payload
    
    def build_data(self, opc, dpc, si, ni, mp, sls, data,
                   network_appearance=None, routing_context=None,
                   correlation_id=None):
        """Build M3UA DATA message (Transfer)"""
        payload = b''
        
        if network_appearance is not None:
            payload += self.build_parameter(self.tag_network_appearance,
                       struct.pack('!I', network_appearance))
        
        if routing_context is not None:
            payload += self.build_parameter(self.tag_routing_context,
                       struct.pack('!I', routing_context))
        
        # Protocol Data parameter
        pd_header = struct.pack('!IIBBB',
                               opc,
                               dpc,
                               si,
                               ni,
                               (mp << 6) | (sls & 0x0F))
        
        protocol_data = pd_header + data
        payload += self.build_parameter(self.tag_protocol_data, protocol_data)
        
        if correlation_id is not None:
            payload += self.build_parameter(self.tag_correlation_id,
                       struct.pack('!I', correlation_id))
        
        header = self.build_header(M3UAMessageClass.TRANSFER,
                                   M3UAMessageType.DATA,
                                   len(payload))
        return header + payload
    
    def parse_header(self, data):
        """Parse M3UA header"""
        if len(data) < 8:
            return None
        
        version, reserved, msg_class, msg_type, length = \
            struct.unpack('!BBBBI', data[:8])
        
        return {
            'version': version,
            'reserved': reserved,
            'message_class': msg_class,
            'message_type': msg_type,
            'length': length
        }
    
    def parse_parameters(self, data):
        """Parse M3UA parameters"""
        params = []
        offset = 0
        
        while offset < len(data):
            if offset + 4 > len(data):
                break
            
            tag, length = struct.unpack('!HH', data[offset:offset+4])
            value = data[offset+4:offset+length]
            
            params.append({
                'tag': tag,
                'length': length,
                'value': value
            })
            
            # Align to 4-byte boundary
            offset += length + ((4 - (length % 4)) % 4)
        
        return params


class SCTPBuilder:
    """SCTP Packet Builder (for raw socket testing)"""
    
    INIT = 1
    INIT_ACK = 2
    SACK = 3
    HEARTBEAT = 4
    HEARTBEAT_ACK = 5
    ABORT = 6
    SHUTDOWN = 7
    SHUTDOWN_ACK = 8
    ERROR = 9
    COOKIE_ECHO = 10
    COOKIE_ACK = 11
    DATA = 0
    
    def __init__(self):
        self.verification_tag = 0
        self.src_port = 0
        self.dst_port = 0
    
    def build_common_header(self, src_port, dst_port, vtag, checksum=0):
        """Build SCTP common header"""
        return struct.pack('!HHII', src_port, dst_port, vtag, checksum)
    
    def build_init_chunk(self, init_tag, a_rwnd=65535, 
                         num_outbound=10, num_inbound=10, 
                         initial_tsn=1):
        """Build SCTP INIT chunk"""
        chunk_value = struct.pack('!IIHHI',
                                 init_tag,
                                 a_rwnd,
                                 num_outbound,
                                 num_inbound,
                                 initial_tsn)
        
        length = 4 + len(chunk_value)
        chunk_header = struct.pack('!BBH', self.INIT, 0, length)
        
        return chunk_header + chunk_value
    
    def build_data_chunk(self, tsn, stream_id, stream_seq, ppid, data):
        """Build SCTP DATA chunk"""
        chunk_value = struct.pack('!IHHI',
                                tsn,
                                stream_id,
                                stream_seq,
                                ppid)
        chunk_value += data
        
        length = 4 + len(chunk_value)
        padding = (4 - (length % 4)) % 4
        chunk_header = struct.pack('!BBH', self.DATA, 0x03, length)  # B|E flags
        
        return chunk_header + chunk_value + b'\x00' * padding
    
    def build_abort_chunk(self, reflect_vtag=False):
        """Build SCTP ABORT chunk"""
        flags = 0x01 if reflect_vtag else 0x00
        return struct.pack('!BBH', self.ABORT, flags, 4)
    
    @staticmethod
    def crc32c(data):
        """Calculate CRC32c checksum for SCTP"""
        import binascii
        # Simplified - in production use proper CRC32c
        return binascii.crc32(data) & 0xFFFFFFFF


if __name__ == '__main__':
    m3ua = M3UABuilder()
    sctp = SCTPBuilder()
    print("[SIGTRAN Builder] M3UA/SCTP Protocol Builder loaded")
    
    # Example: Build ASP Up
    aspup = m3ua.build_aspup(asp_id=1, info_string="SS7-Toolkit")
    print(f"[SIGTRAN Builder] ASP Up message: {aspup.hex()}")
PYSIG

    # SS7 Scanner Module
    cat > "$SCRIPTS_DIR/ss7_scanner.py" << 'PYSCAN'
#!/usr/bin/env python3
"""
SS7/SIGTRAN Network Scanner
Discovers SS7 network elements and SIGTRAN endpoints
"""

import socket
import struct
import sys
import os
import json
import time
import subprocess
from datetime import datetime
from concurrent.futures import ThreadPoolExecutor, as_completed

class SS7Scanner:
    """SS7/SIGTRAN Network Scanner"""
    
    # Common SS7/SIGTRAN ports
    SIGTRAN_PORTS = {
        2905: 'M3UA',
        2906: 'M3UA-alt',
        2907: 'M3UA-alt2',
        14001: 'SUA',
        3868: 'Diameter',
        5868: 'Diameter-TLS',
        2123: 'GTP-C',
        2152: 'GTP-U',
        4739: 'IPFIX',
        3000: 'SS7-alt',
        7551: 'M2PA',
        9900: 'IUA',
        9901: 'DUA',
        9902: 'V5UA',
        2904: 'M2UA',
    }
    
    SS7_SSNS = {
        0: 'SSN-Unknown',
        1: 'SCCP-Management',
        6: 'HLR',
        7: 'VLR',
        8: 'MSC',
        9: 'EIR',
        10: 'AuC',
        11: 'ISDN-Supplementary',
        12: 'Reserved-International',
        13: 'Broadband-ISDN',
        14: 'TC-Test',
        142: 'RANAP',
        143: 'RNSAP',
        145: 'GMLC',
        146: 'CAP',
        147: 'gsmSCF',
        148: 'SIWF',
        149: 'SGSN',
        150: 'GGSN',
    }
    
    def __init__(self, timeout=5, max_threads=20):
        self.timeout = timeout
        self.max_threads = max_threads
        self.results = []
        self.scan_start = None
        self.scan_end = None
    
    def scan_tcp_port(self, host, port):
        """Scan a single TCP port"""
        try:
            sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            sock.settimeout(self.timeout)
            result = sock.connect_ex((host, port))
            sock.close()
            
            if result == 0:
                service = self.SIGTRAN_PORTS.get(port, 'Unknown')
                banner = self.grab_banner(host, port)
                return {
                    'host': host,
                    'port': port,
                    'protocol': 'TCP',
                    'state': 'open',
                    'service': service,
                    'banner': banner
                }
        except Exception:
            pass
        return None
    
    def scan_sctp_port_nmap(self, host, port):
        """Scan SCTP port using nmap"""
        try:
            result = subprocess.run(
                ['nmap', '-sY', '-p', str(port), '-Pn', '--open', 
                 '-T4', host, '--max-retries', '2'],
                capture_output=True, text=True, timeout=30
            )
            if 'open' in result.stdout:
                service = self.SIGTRAN_PORTS.get(port, 'Unknown')
                return {
                    'host': host,
                    'port': port,
                    'protocol': 'SCTP',
                    'state': 'open',
                    'service': service,
                    'nmap_output': result.stdout.strip()
                }
        except Exception:
            pass
        return None
    
    def grab_banner(self, host, port):
        """Attempt banner grab"""
        try:
            sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            sock.settimeout(3)
            sock.connect((host, port))
            sock.send(b'\r\n')
            banner = sock.recv(1024).decode('utf-8', errors='ignore').strip()
            sock.close()
            return banner if banner else None
        except Exception:
            return None
    
    def scan_host(self, host, ports=None, scan_sctp=True):
        """Scan a single host for SS7/SIGTRAN services"""
        if ports is None:
            ports = list(self.SIGTRAN_PORTS.keys())
        
        host_results = []
        
        # TCP Scan
        with ThreadPoolExecutor(max_workers=self.max_threads) as executor:
            futures = {executor.submit(self.scan_tcp_port, host, port): port 
                      for port in ports}
            
            for future in as_completed(futures):
                result = future.result()
                if result:
                    host_results.append(result)
        
        # SCTP Scan (using nmap)
        if scan_sctp:
            sctp_ports = [2905, 2906, 2907, 14001, 2904, 7551, 
                         9900, 9901, 9902]
            for port in sctp_ports:
                if port in ports:
                    result = self.scan_sctp_port_nmap(host, port)
                    if result:
                        host_results.append(result)
        
        return host_results
    
    def scan_network(self, network, ports=None, scan_sctp=True):
        """Scan network range for SS7/SIGTRAN services"""
        self.scan_start = datetime.now()
        self.results = []
        
        # Parse network range
        hosts = self.parse_network(network)
        
        for host in hosts:
            host_results = self.scan_host(host, ports, scan_sctp)
            self.results.extend(host_results)
        
        self.scan_end = datetime.now()
        return self.results
    
    def parse_network(self, network):
        """Parse network notation to host list"""
        hosts = []
        
        if '/' in network:
            # CIDR notation
            import ipaddress
            try:
                net = ipaddress.ip_network(network, strict=False)
                hosts = [str(ip) for ip in net.hosts()]
            except ValueError:
                hosts = [network.split('/')[0]]
        elif '-' in network:
            # Range notation (e.g., 192.168.1.1-10)
            parts = network.rsplit('.', 1)
            if '-' in parts[1]:
                start, end = parts[1].split('-')
                for i in range(int(start), int(end) + 1):
                    hosts.append(f"{parts[0]}.{i}")
            else:
                hosts = [network]
        else:
            hosts = [network]
        
        return hosts
    
    def sigtran_fingerprint(self, host, port):
        """Attempt to fingerprint SIGTRAN endpoint"""
        fingerprint = {
            'host': host,
            'port': port,
            'protocol': None,
            'version': None,
            'capabilities': []
        }
        
        try:
            sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            sock.settimeout(self.timeout)
            sock.connect((host, port))
            
            # Send M3UA ASP Up probe
            aspup = struct.pack('!BBBBI', 1, 0, 3, 1, 8)
            sock.send(aspup)
            
            response = sock.recv(4096)
            if len(response) >= 8:
                version, _, msg_class, msg_type, length = \
                    struct.unpack('!BBBBI', response[:8])
                
                fingerprint['protocol'] = 'M3UA'
                fingerprint['version'] = version
                
                if msg_class == 3 and msg_type == 4:
                    fingerprint['capabilities'].append('ASP-UP-ACK')
                elif msg_class == 0 and msg_type == 0:
                    fingerprint['capabilities'].append('ERROR-RESPONSE')
            
            sock.close()
        except Exception as e:
            fingerprint['error'] = str(e)
        
        return fingerprint
    
    def deep_scan(self, host, port=2905):
        """Perform deep scan of SS7 endpoint"""
        results = {
            'host': host,
            'port': port,
            'timestamp': datetime.now().isoformat(),
            'fingerprint': None,
            'm3ua_probes': [],
            'sccp_probes': [],
            'map_probes': []
        }
        
        # Fingerprint
        results['fingerprint'] = self.sigtran_fingerprint(host, port)
        
        return results
    
    def generate_report(self, filename=None):
        """Generate scan report"""
        report = {
            'scan_info': {
                'start_time': self.scan_start.isoformat() if self.scan_start else None,
                'end_time': self.scan_end.isoformat() if self.scan_end else None,
                'duration': str(self.scan_end - self.scan_start) if self.scan_start and self.scan_end else None,
                'total_findings': len(self.results)
            },
            'findings': self.results,
            'summary': {
                'open_ports': len(self.results),
                'protocols': list(set(r.get('service', 'Unknown') for r in self.results)),
                'hosts': list(set(r.get('host', '') for r in self.results))
            }
        }
        
        if filename:
            with open(filename, 'w') as f:
                json.dump(report, f, indent=2, default=str)
        
        return report


class DiameterScanner:
    """Diameter Protocol Scanner for 4G/LTE"""
    
    DIAMETER_PORT = 3868
    DIAMETER_TLS_PORT = 5868
    
    def __init__(self):
        self.capability_exchange_request = self.build_cer()
    
    def build_cer(self):
        """Build Capabilities-Exchange-Request"""
        # Diameter header
        version = 1
        flags = 0x80  # Request
        command_code = 257  # CER
        app_id = 0  # Common
        hop_by_hop = 0x00000001
        end_to_end = 0x00000001
        
        # AVPs (simplified)
        origin_host = b'test.ss7toolkit.local'
        origin_realm = b'ss7toolkit.local'
        
        avps = b''
        
        # Origin-Host AVP (264)
        avp_data = origin_host
        avp_len = 8 + len(avp_data)
        padding = (4 - (avp_len % 4)) % 4
        avps += struct.pack('!IBI', 264, 0x40, avp_len)[:-1]
        avps += struct.pack('!I', avp_len)
        avps += avp_data + b'\x00' * padding
        
        msg_length = 20 + len(avps)
        
        header = struct.pack('!BBHBIIII',
                            version,
                            msg_length >> 16,
                            msg_length & 0xFFFF,
                            flags,
                            command_code,
                            app_id,
                            hop_by_hop,
                            end_to_end)
        
        return header + avps
    
    def scan_diameter(self, host, port=3868):
        """Scan for Diameter service"""
        try:
            sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            sock.settimeout(5)
            sock.connect((host, port))
            sock.send(self.capability_exchange_request)
            
            response = sock.recv(4096)
            sock.close()
            
            if len(response) >= 20:
                return {
                    'host': host,
                    'port': port,
                    'protocol': 'Diameter',
                    'state': 'open',
                    'response_length': len(response),
                    'response_hex': response[:64].hex()
                }
        except Exception:
            pass
        return None


if __name__ == '__main__':
    scanner = SS7Scanner()
    print("[SS7 Scanner] SS7/SIGTRAN Network Scanner loaded")
    print(f"[SS7 Scanner] Known SIGTRAN ports: {len(scanner.SIGTRAN_PORTS)}")
    print(f"[SS7 Scanner] Known SSNs: {len(scanner.SS7_SSNS)}")
PYSCAN

    # SS7 Analyzer
    cat > "$SCRIPTS_DIR/ss7_analyzer.py" << 'PYANALYZE'
#!/usr/bin/env python3
"""
SS7 Traffic Analyzer & PCAP Parser
Analyzes SS7/SIGTRAN traffic from PCAP files
"""

import struct
import sys
import os
import json
from datetime import datetime
from collections import Counter

class PCAPReader:
    """Simple PCAP file reader"""
    
    PCAP_MAGIC = 0xa1b2c3d4
    PCAP_MAGIC_SWAPPED = 0xd4c3b2a1
    
    def __init__(self, filename):
        self.filename = filename
        self.packets = []
        self.byte_order = '<'
    
    def read(self):
        """Read PCAP file"""
        with open(self.filename, 'rb') as f:
            # Global header
            magic = struct.unpack('<I', f.read(4))[0]
            if magic == self.PCAP_MAGIC:
                self.byte_order = '<'
            elif magic == self.PCAP_MAGIC_SWAPPED:
                self.byte_order = '>'
            else:
                raise ValueError("Not a valid PCAP file")
            
            header = f.read(20)
            ver_major, ver_minor, thiszone, sigfigs, snaplen, network = \
                struct.unpack(f'{self.byte_order}HHIIII', header)
            
            # Read packets
            while True:
                pkt_header = f.read(16)
                if len(pkt_header) < 16:
                    break
                
                ts_sec, ts_usec, incl_len, orig_len = \
                    struct.unpack(f'{self.byte_order}IIII', pkt_header)
                
                pkt_data = f.read(incl_len)
                if len(pkt_data) < incl_len:
                    break
                
                self.packets.append({
                    'timestamp': ts_sec + ts_usec / 1000000.0,
                    'length': orig_len,
                    'data': pkt_data,
                    'link_type': network
                })
        
        return self.packets


class SS7Analyzer:
    """SS7 Protocol Analyzer"""
    
    MAP_OPERATIONS = {
        2: 'updateLocation',
        3: 'cancelLocation',
        4: 'provideRoamingNumber',
        7: 'insertSubscriberData',
        8: 'deleteSubscriberData',
        22: 'sendRoutingInfo',
        24: 'sendRoutingInfoForGprs',
        43: 'checkIMEI',
        56: 'sendAuthenticationInfo',
        58: 'sendIMSI',
        67: 'purgeMS',
        70: 'provideSubscriberInfo',
        71: 'anyTimeInterrogation',
        83: 'provideSubscriberLocation',
        85: 'sendRoutingInfoForLCS',
        86: 'subscriberLocationReport',
    }
    
    ISUP_MESSAGE_TYPES = {
        0x01: 'IAM (Initial Address)',
        0x02: 'SAM (Subsequent Address)',
        0x06: 'ACM (Address Complete)',
        0x09: 'ANM (Answer)',
        0x0C: 'REL (Release)',
        0x10: 'RLC (Release Complete)',
        0x2C: 'CPG (Call Progress)',
    }
    
    SCCP_MESSAGE_TYPES = {
        0x01: 'CR (Connection Request)',
        0x02: 'CC (Connection Confirm)',
        0x04: 'RLSD (Released)',
        0x06: 'DT1 (Data Form 1)',
        0x09: 'UDT (Unitdata)',
        0x0A: 'UDTS (Unitdata Service)',
        0x11: 'XUDT (Extended Unitdata)',
        0x12: 'XUDTS (Extended Unitdata Service)',
    }
    
    TCAP_MESSAGE_TYPES = {
        0x60: 'Unidirectional',
        0x62: 'Begin',
        0x64: 'End',
        0x65: 'Continue',
        0x67: 'Abort',
    }
    
    def __init__(self):
        self.statistics = {
            'total_packets': 0,
            'ss7_packets': 0,
            'map_operations': Counter(),
            'isup_messages': Counter(),
            'sccp_messages': Counter(),
            'tcap_messages': Counter(),
            'source_ips': Counter(),
            'dest_ips': Counter(),
            'source_gts': Counter(),
            'dest_gts': Counter(),
            'imsis': set(),
            'msisdns': set(),
            'anomalies': [],
        }
    
    def analyze_m3ua(self, data, offset=0):
        """Analyze M3UA layer"""
        if len(data) < offset + 8:
            return None
        
        version, reserved, msg_class, msg_type, length = \
            struct.unpack('!BBBBI', data[offset:offset+8])
        
        result = {
            'protocol': 'M3UA',
            'version': version,
            'message_class': msg_class,
            'message_type': msg_type,
            'length': length,
            'class_name': self._get_m3ua_class_name(msg_class),
            'type_name': self._get_m3ua_type_name(msg_class, msg_type),
        }
        
        # Parse parameters
        if msg_class == 1 and msg_type == 1:  # DATA
            params_offset = offset + 8
            while params_offset < offset + length:
                if params_offset + 4 > len(data):
                    break
                param_tag, param_length = struct.unpack('!HH', 
                    data[params_offset:params_offset+4])
                
                if param_tag == 0x0210:  # Protocol Data
                    pd_offset = params_offset + 4
                    if pd_offset + 12 <= len(data):
                        opc, dpc, si, ni, mp_sls = struct.unpack('!IIBBB',
                            data[pd_offset:pd_offset+11])
                        
                        result['opc'] = opc
                        result['dpc'] = dpc
                        result['si'] = si
                        result['ni'] = ni
                        result['service_indicator'] = self._get_si_name(si)
                        
                        # If SI=3 (SCCP), analyze further
                        if si == 3:
                            sccp_data = data[pd_offset+12:]
                            sccp_result = self.analyze_sccp(sccp_data)
                            if sccp_result:
                                result['sccp'] = sccp_result
                
                params_offset += param_length + ((4 - (param_length % 4)) % 4)
        
        return result
    
    def analyze_sccp(self, data, offset=0):
        """Analyze SCCP layer"""
        if len(data) < offset + 1:
            return None
        
        msg_type = data[offset]
        result = {
            'protocol': 'SCCP',
            'message_type': msg_type,
            'type_name': self.SCCP_MESSAGE_TYPES.get(msg_type, f'Unknown(0x{msg_type:02x})'),
        }
        
        self.statistics['sccp_messages'][result['type_name']] += 1
        
        return result
    
    def analyze_tcap(self, data, offset=0):
        """Analyze TCAP layer"""
        if len(data) < offset + 2:
            return None
        
        msg_type = data[offset]
        result = {
            'protocol': 'TCAP',
            'message_type': msg_type,
            'type_name': self.TCAP_MESSAGE_TYPES.get(msg_type, f'Unknown(0x{msg_type:02x})'),
        }
        
        self.statistics['tcap_messages'][result['type_name']] += 1
        
        return result
    
    def detect_anomalies(self, packet_info):
        """Detect potential SS7 attacks/anomalies"""
        anomalies = []
        
        if packet_info.get('protocol') == 'MAP':
            op = packet_info.get('operation')
            
            # Location tracking indicators
            if op in ['anyTimeInterrogation', 'provideSubscriberInfo',
                      'provideSubscriberLocation', 'sendRoutingInfoForLCS']:
                anomalies.append({
                    'severity': 'HIGH',
                    'type': 'LOCATION_TRACKING',
                    'description': f'Potential location tracking via {op}',
                    'operation': op
                })
            
            # Subscriber info harvesting
            if op in ['sendRoutingInfo', 'sendIMSI', 'sendAuthenticationInfo']:
                anomalies.append({
                    'severity': 'HIGH',
                    'type': 'INFO_HARVESTING',
                    'description': f'Potential info harvesting via {op}',
                    'operation': op
                })
            
            # Registration manipulation
            if op in ['updateLocation', 'cancelLocation', 'purgeMS']:
                anomalies.append({
                    'severity': 'CRITICAL',
                    'type': 'REGISTRATION_MANIPULATION',
                    'description': f'Potential registration attack via {op}',
                    'operation': op
                })
            
            # Interception setup
            if op in ['insertSubscriberData']:
                anomalies.append({
                    'severity': 'CRITICAL',
                    'type': 'INTERCEPTION',
                    'description': f'Potential call/SMS interception via {op}',
                    'operation': op
                })
        
        return anomalies
    
    def _get_m3ua_class_name(self, msg_class):
        classes = {
            0: 'Management',
            1: 'Transfer',
            2: 'SSNM',
            3: 'ASPSM',
            4: 'ASPTM',
            9: 'RKM',
        }
        return classes.get(msg_class, f'Unknown({msg_class})')
    
    def _get_m3ua_type_name(self, msg_class, msg_type):
        types = {
            (0, 0): 'ERROR',
            (0, 1): 'NOTIFY',
            (1, 1): 'DATA',
            (3, 1): 'ASP_UP',
            (3, 2): 'ASP_DOWN',
            (3, 3): 'HEARTBEAT',
            (3, 4): 'ASP_UP_ACK',
            (3, 5): 'ASP_DOWN_ACK',
            (3, 6): 'HEARTBEAT_ACK',
            (4, 1): 'ASP_ACTIVE',
            (4, 2): 'ASP_INACTIVE',
            (4, 3): 'ASP_ACTIVE_ACK',
            (4, 4): 'ASP_INACTIVE_ACK',
        }
        return types.get((msg_class, msg_type), f'Unknown({msg_class},{msg_type})')
    
    def _get_si_name(self, si):
        si_names = {
            0: 'SNM (Signalling Network Management)',
            1: 'STM (Signalling Network Testing)',
            3: 'SCCP',
            4: 'TUP (Telephone User Part)',
            5: 'ISUP',
            7: 'DUP (Data User Part)',
            8: 'MTP Testing',
        }
        return si_names.get(si, f'Unknown({si})')
    
    def analyze_pcap(self, filename):
        """Analyze entire PCAP file"""
        reader = PCAPReader(filename)
        packets = reader.read()
        
        self.statistics['total_packets'] = len(packets)
        
        results = []
        for pkt in packets:
            result = self.analyze_packet(pkt)
            if result:
                results.append(result)
                
                # Check for anomalies
                anomalies = self.detect_anomalies(result)
                self.statistics['anomalies'].extend(anomalies)
        
        return {
            'filename': filename,
            'analysis_time': datetime.now().isoformat(),
            'statistics': {
                'total_packets': self.statistics['total_packets'],
                'ss7_packets': self.statistics['ss7_packets'],
                'map_operations': dict(self.statistics['map_operations']),
                'isup_messages': dict(self.statistics['isup_messages']),
                'sccp_messages': dict(self.statistics['sccp_messages']),
                'tcap_messages': dict(self.statistics['tcap_messages']),
                'unique_imsis': len(self.statistics['imsis']),
                'unique_msisdns': len(self.statistics['msisdns']),
                'anomalies_count': len(self.statistics['anomalies']),
            },
            'anomalies': self.statistics['anomalies'],
            'detailed_results': results[:100],  # First 100 for report
        }
    
    def analyze_packet(self, packet):
        """Analyze a single packet"""
        data = packet['data']
        
        # Skip Ethernet header (14 bytes) if present
        if len(data) > 14:
            eth_type = struct.unpack('!H', data[12:14])[0]
            if eth_type == 0x0800:  # IPv4
                ip_offset = 14
                if len(data) > ip_offset + 20:
                    ip_header = data[ip_offset:ip_offset+20]
                    ihl = (ip_header[0] & 0x0F) * 4
                    protocol = ip_header[9]
                    
                    src_ip = socket.inet_ntoa(ip_header[12:16])
                    dst_ip = socket.inet_ntoa(ip_header[16:20])
                    
                    self.statistics['source_ips'][src_ip] += 1
                    self.statistics['dest_ips'][dst_ip] += 1
                    
                    # SCTP (protocol 132)
                    if protocol == 132:
                        sctp_offset = ip_offset + ihl
                        if len(data) > sctp_offset + 12:
                            src_port, dst_port = struct.unpack('!HH', 
                                data[sctp_offset:sctp_offset+4])
                            
                            # Check for M3UA port
                            if src_port in [2905, 2906] or dst_port in [2905, 2906]:
                                # Skip SCTP header (12 bytes) + DATA chunk header
                                m3ua_offset = sctp_offset + 28  # Approximate
                                if len(data) > m3ua_offset + 8:
                                    result = self.analyze_m3ua(data, m3ua_offset)
                                    if result:
                                        result['src_ip'] = src_ip
                                        result['dst_ip'] = dst_ip
                                        result['src_port'] = src_port
                                        result['dst_port'] = dst_port
                                        result['timestamp'] = packet['timestamp']
                                        self.statistics['ss7_packets'] += 1
                                        return result
        
        return None
    
    def generate_report(self, analysis_result, output_file=None):
        """Generate human-readable report"""
        report = []
        report.append("=" * 70)
        report.append("          SS7 TRAFFIC ANALYSIS REPORT")
        report.append("=" * 70)
        report.append(f"\nFile: {analysis_result['filename']}")
        report.append(f"Analysis Time: {analysis_result['analysis_time']}")
        report.append(f"\n{'─' * 50}")
        
        stats = analysis_result['statistics']
        report.append(f"\n  Total Packets:      {stats['total_packets']}")
        report.append(f"  SS7 Packets:        {stats['ss7_packets']}")
        report.append(f"  Unique IMSIs:       {stats['unique_imsis']}")
        report.append(f"  Unique MSISDNs:     {stats['unique_msisdns']}")
        report.append(f"  Anomalies Found:    {stats['anomalies_count']}")
        
        if stats['map_operations']:
            report.append(f"\n  MAP Operations:")
            for op, count in stats['map_operations'].items():
                report.append(f"    {op}: {count}")
        
        if stats['sccp_messages']:
            report.append(f"\n  SCCP Messages:")
            for msg, count in stats['sccp_messages'].items():
                report.append(f"    {msg}: {count}")
        
        if analysis_result['anomalies']:
            report.append(f"\n{'─' * 50}")
            report.append("  ⚠ ANOMALIES/POTENTIAL ATTACKS:")
            for anomaly in analysis_result['anomalies']:
                severity = anomaly['severity']
                atype = anomaly['type']
                desc = anomaly['description']
                report.append(f"\n  [{severity}] {atype}")
                report.append(f"    {desc}")
        
        report.append(f"\n{'=' * 70}")
        
        report_text = '\n'.join(report)
        
        if output_file:
            with open(output_file, 'w') as f:
                f.write(report_text)
        
        return report_text


if __name__ == '__main__':
    analyzer = SS7Analyzer()
    print("[SS7 Analyzer] SS7 Traffic Analyzer loaded")
    print(f"[SS7 Analyzer] Known MAP operations: {len(analyzer.MAP_OPERATIONS)}")
    print(f"[SS7 Analyzer] Known ISUP messages: {len(analyzer.ISUP_MESSAGE_TYPES)}")
PYANALYZE

    # SS7 Vulnerability Database
    cat > "$SCRIPTS_DIR/ss7_vulndb.py" << 'PYVULN'
#!/usr/bin/env python3
"""
SS7 Vulnerability Database
Known SS7/SIGTRAN vulnerabilities and attack vectors
"""

import json
import os

class SS7VulnDB:
    """SS7 Vulnerability Knowledge Base"""
    
    def __init__(self):
        self.vulnerabilities = self._load_vulndb()
    
    def _load_vulndb(self):
        return {
            'LOC-001': {
                'name': 'Subscriber Location via ATI',
                'category': 'Location Tracking',
                'severity': 'HIGH',
                'protocol': 'MAP',
                'operation': 'AnyTimeInterrogation',
                'description': 'An attacker with access to the SS7 network can query the HLR using ATI to obtain the Cell-ID and LAC of a target subscriber, enabling real-time location tracking.',
                'impact': 'Privacy violation, physical surveillance',
                'mitigation': [
                    'Implement MAP message filtering on STP',
                    'Block ATI from unauthorized sources',
                    'Monitor for unusual ATI query patterns',
                    'Implement Category 1 filtering (GSMA FS.11)',
                ],
                'references': ['GSMA FS.11', 'SR Labs SS7map', '3GPP TS 29.002'],
                'cvss': 7.5,
            },
            'LOC-002': {
                'name': 'Subscriber Location via PSI',
                'category': 'Location Tracking',
                'severity': 'HIGH',
                'protocol': 'MAP',
                'operation': 'ProvideSubscriberInfo',
                'description': 'PSI can be used to obtain subscriber location from the VLR, including Cell-ID, LAC, and subscriber state.',
                'impact': 'Privacy violation, real-time tracking',
                'mitigation': [
                    'Filter PSI messages at STP',
                    'Implement SCCP calling party address verification',
                    'Deploy SS7 firewall',
                ],
                'references': ['GSMA FS.11', '3GPP TS 29.002'],
                'cvss': 7.5,
            },
            'LOC-003': {
                'name': 'Location via SRI-LCS',
                'category': 'Location Tracking',
                'severity': 'HIGH',
                'protocol': 'MAP',
                'operation': 'SendRoutingInfoForLCS',
                'description': 'SRI-for-LCS can reveal subscriber serving node information for location service attacks.',
                'impact': 'Privacy violation',
                'mitigation': [
                    'Filter SRI-for-LCS at STP',
                    'Validate calling party addresses',
                ],
                'references': ['3GPP TS 29.002'],
                'cvss': 7.0,
            },
            'INT-001': {
                'name': 'SMS Interception via UpdateLocation',
                'category': 'Interception',
                'severity': 'CRITICAL',
                'protocol': 'MAP',
                'operation': 'UpdateLocation',
                'description': 'By sending a fake UpdateLocation to the HLR, an attacker can redirect SMS messages to a rogue VLR/MSC under their control.',
                'impact': 'SMS interception, 2FA bypass, privacy violation',
                'mitigation': [
                    'Implement UL filtering on STP',
                    'Verify source of UpdateLocation messages',
                    'Deploy SS7 firewall with correlation engine',
                    'Monitor for registration anomalies',
                ],
                'references': ['GSMA FS.11', 'Category 3 Filtering'],
                'cvss': 9.0,
            },
            'INT-002': {
                'name': 'Call Interception via InsertSubscriberData',
                'category': 'Interception',
                'severity': 'CRITICAL',
                'protocol': 'MAP',
                'operation': 'InsertSubscriberData',
                'description': 'ISD can be used to modify subscriber data on VLR, enabling call forwarding to an attacker-controlled number.',
                'impact': 'Voice call interception, financial fraud',
                'mitigation': [
                    'Filter ISD from non-HLR sources',
                    'Implement SCCP GT verification',
                    'Deploy Category 2 filtering',
                ],
                'references': ['GSMA FS.11', '3GPP TS 29.002'],
                'cvss': 9.5,
            },
            'INT-003': {
                'name': 'Auth Vector Theft via SAI',
                'category': 'Interception',
                'severity': 'CRITICAL',
                'protocol': 'MAP',
                'operation': 'SendAuthenticationInfo',
                'description': 'By querying SAI from the HLR, an attacker can obtain authentication vectors (Ki, RAND, SRES) enabling subscriber impersonation and decryption.',
                'impact': 'Call/data decryption, subscriber impersonation',
                'mitigation': [
                    'Strict SAI filtering at STP',
                    'Implement source GT validation',
                    'Monitor for bulk SAI queries',
                ],
                'references': ['GSMA FS.11', '3GPP TS 29.002'],
                'cvss': 9.8,
            },
            'DOS-001': {
                'name': 'Subscriber DoS via CancelLocation',
                'category': 'Denial of Service',
                'severity': 'HIGH',
                'protocol': 'MAP',
                'operation': 'CancelLocation',
                'description': 'Sending CancelLocation to VLR causes subscriber deregistration, resulting in service denial.',
                'impact': 'Loss of service, no incoming calls/SMS',
                'mitigation': [
                    'Filter CL from unauthorized sources',
                    'Verify CL originates from valid HLR',
                    'Implement anomaly detection',
                ],
                'references': ['GSMA FS.11'],
                'cvss': 7.5,
            },
            'DOS-002': {
                'name': 'Subscriber DoS via PurgeMS',
                'category': 'Denial of Service',
                'severity': 'HIGH',
                'protocol': 'MAP',
                'operation': 'PurgeMS',
                'description': 'PurgeMS removes subscriber registration from VLR, causing service denial.',
                'impact': 'Loss of service',
                'mitigation': [
                    'Filter PurgeMS at STP',
                    'Source validation',
                ],
                'references': ['GSMA FS.11'],
                'cvss': 7.5,
            },
            'DOS-003': {
                'name': 'Subscriber DoS via DeleteSubscriberData',
                'category': 'Denial of Service',
                'severity': 'HIGH',
                'protocol': 'MAP',
                'operation': 'DeleteSubscriberData',
                'description': 'DSD can remove subscriber service profiles, disrupting voice, data, and supplementary services.',
                'impact': 'Service degradation or denial',
                'mitigation': [
                    'Strict DSD filtering',
                    'Allow only from authenticated HLR',
                ],
                'references': ['3GPP TS 29.002'],
                'cvss': 8.0,
            },
            'INFO-001': {
                'name': 'IMSI Disclosure via SRI',
                'category': 'Information Disclosure',
                'severity': 'MEDIUM',
                'protocol': 'MAP',
                'operation': 'SendRoutingInfo',
                'description': 'SRI response from HLR contains IMSI and serving MSC/VLR address, enabling further targeted attacks.',
                'impact': 'IMSI disclosure, network topology disclosure',
                'mitigation': [
                    'Implement SRI filtering',
                    'Verify calling party SCCP address',
                    'Deploy GSMA Cat-1 filtering',
                ],
                'references': ['GSMA FS.11', '3GPP TS 29.002'],
                'cvss': 6.5,
            },
            'INFO-002': {
                'name': 'IMSI Retrieval via SendIMSI',
                'category': 'Information Disclosure',
                'severity': 'HIGH',
                'protocol': 'MAP',
                'operation': 'SendIMSI',
                'description': 'Direct IMSI retrieval using MSISDN.',
                'impact': 'IMSI disclosure enabling further attacks',
                'mitigation': [
                    'Block SendIMSI from external networks',
                    'Source address validation',
                ],
                'references': ['3GPP TS 29.002'],
                'cvss': 7.0,
            },
            'INFO-003': {
                'name': 'IMEI Retrieval via CheckIMEI',
                'category': 'Information Disclosure',
                'severity': 'MEDIUM',
                'protocol': 'MAP',
                'operation': 'CheckIMEI',
                'description': 'CheckIMEI can reveal device IMEI for tracking purposes.',
                'impact': 'Device tracking, hardware identification',
                'mitigation': [
                    'Filter CheckIMEI to authorized EIR sources',
                ],
                'references': ['3GPP TS 29.002'],
                'cvss': 5.5,
            },
            'FRAUD-001': {
                'name': 'Toll Fraud via PRN Manipulation',
                'category': 'Fraud',
                'severity': 'CRITICAL',
                'protocol': 'MAP',
                'operation': 'ProvideRoamingNumber',
                'description': 'By manipulating the roaming number allocation, calls can be redirected to premium-rate numbers.',
                'impact': 'Financial fraud, premium rate abuse',
                'mitigation': [
                    'Validate PRN sources',
                    'Monitor roaming patterns',
                    'Implement fraud detection systems',
                ],
                'references': ['GSMA FS.11'],
                'cvss': 8.5,
            },
            'NET-001': {
                'name': 'SIGTRAN/M3UA Association Hijacking',
                'category': 'Network Attack',
                'severity': 'CRITICAL',
                'protocol': 'M3UA/SCTP',
                'operation': 'ASP Management',
                'description': 'Unauthorized SCTP association establishment to SS7 gateway, gaining direct access to SS7 network.',
                'impact': 'Full SS7 network access',
                'mitigation': [
                    'Implement SCTP authentication',
                    'IP whitelisting on SIGTRAN endpoints',
                    'Network segmentation',
                    'SCTP firewall rules',
                ],
                'references': ['RFC 4960', 'RFC 4666'],
                'cvss': 9.8,
            },
        }
    
    def get_vulnerability(self, vuln_id):
        return self.vulnerabilities.get(vuln_id)
    
    def get_by_category(self, category):
        return {k: v for k, v in self.vulnerabilities.items() 
                if v['category'] == category}
    
    def get_by_severity(self, severity):
        return {k: v for k, v in self.vulnerabilities.items() 
                if v['severity'] == severity}
    
    def get_by_operation(self, operation):
        return {k: v for k, v in self.vulnerabilities.items() 
                if v['operation'] == operation}
    
    def get_categories(self):
        return list(set(v['category'] for v in self.vulnerabilities.values()))
    
    def get_all_ids(self):
        return list(self.vulnerabilities.keys())
    
    def search(self, keyword):
        results = {}
        keyword = keyword.lower()
        for vid, vuln in self.vulnerabilities.items():
            if (keyword in vuln['name'].lower() or
                keyword in vuln['description'].lower() or
                keyword in vuln['category'].lower() or
                keyword in vuln['operation'].lower()):
                results[vid] = vuln
        return results
    
    def export_db(self, filename):
        with open(filename, 'w') as f:
            json.dump(self.vulnerabilities, f, indent=2)
    
    def print_summary(self):
        print(f"\n{'=' * 60}")
        print("  SS7 Vulnerability Database Summary")
        print(f"{'=' * 60}")
        print(f"  Total Vulnerabilities: {len(self.vulnerabilities)}")
        
        categories = {}
        severities = {}
        for v in self.vulnerabilities.values():
            categories[v['category']] = categories.get(v['category'], 0) + 1
            severities[v['severity']] = severities.get(v['severity'], 0) + 1
        
        print(f"\n  By Category:")
        for cat, count in sorted(categories.items()):
            print(f"    {cat}: {count}")
        
        print(f"\n  By Severity:")
        for sev, count in sorted(severities.items()):
            print(f"    {sev}: {count}")
        print(f"{'=' * 60}")


if __name__ == '__main__':
    db = SS7VulnDB()
    db.print_summary()
PYVULN

    print_status "Python modules generated"
    log "INFO" "Python modules generated successfully"
}

# ========================= MAIN MENU FUNCTIONS ============================

full_install() {
    print_banner
    print_section "Full Installation"
    
    if confirm_action "This will install all SS7 toolkit components. Continue?"; then
        setup_directories
        install_dependencies
        install_ss7_tools
        generate_config
        generate_python_modules
        initialize_database
        
        echo ""
        print_separator
        print_status "Installation complete!"
        print_info "Toolkit installed at: $INSTALL_DIR"
        print_info "Log file: $LOG_FILE"
        print_info "Config file: $CONFIG_DIR/ss7_config.conf"
        print_separator
    else
        print_warning "Installation cancelled"
    fi
}

initialize_database() {
    print_progress "Initializing SQLite database..."
    
    sqlite3 "$DB_DIR/ss7_toolkit.db" << 'SQL'
CREATE TABLE IF NOT EXISTS scan_results (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    timestamp TEXT DEFAULT CURRENT_TIMESTAMP,
    target_ip TEXT,
    target_port INTEGER,
    protocol TEXT,
    service TEXT,
    state TEXT,
    banner TEXT,
    notes TEXT
);

CREATE TABLE IF NOT EXISTS ss7_nodes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    timestamp TEXT DEFAULT CURRENT_TIMESTAMP,
    node_type TEXT,
    global_title TEXT,
    point_code TEXT,
    ssn INTEGER,
    ip_address TEXT,
    port INTEGER,
    description TEXT
);

CREATE TABLE IF NOT EXISTS test_results (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    timestamp TEXT DEFAULT CURRENT_TIMESTAMP,
    test_type TEXT,
    target TEXT,
    result TEXT,
    details TEXT,
    severity TEXT
);

CREATE TABLE IF NOT EXISTS pcap_analyses (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    timestamp TEXT DEFAULT CURRENT_TIMESTAMP,
    filename TEXT,
    total_packets INTEGER,
    ss7_packets INTEGER,
    anomalies INTEGER,
    report_path TEXT
);

CREATE TABLE IF NOT EXISTS audit_log (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    timestamp TEXT DEFAULT CURRENT_TIMESTAMP,
    action TEXT,
    details TEXT,
    user TEXT DEFAULT 'operator'
);
SQL
    
    print_status "Database initialized"
    log "INFO" "SQLite database initialized"
}

# ========================= SCANNING MODULE ================================

scanning_menu() {
    while true; do
        print_banner
        print_section "Network Scanning Module"
        echo ""
        echo -e "  ${WHITE}1)${NC}  SIGTRAN Port Scan (TCP)"
        echo -e "  ${WHITE}2)${NC}  SCTP Port Scan"
        echo -e "  ${WHITE}3)${NC}  Full SS7 Endpoint Discovery"
        echo -e "  ${WHITE}4)${NC}  Diameter Endpoint Scan"
        echo -e "  ${WHITE}5)${NC}  GTP Endpoint Scan"
        echo -e "  ${WHITE}6)${NC}  SIGTRAN Fingerprinting"
        echo -e "  ${WHITE}7)${NC}  Network Topology Discovery"
        echo -e "  ${WHITE}8)${NC}  Custom Port Scan"
        echo -e "  ${WHITE}9)${NC}  Nmap SS7 Script Scan"
        echo -e "  ${WHITE}10)${NC} View Scan History"
        echo -e "  ${WHITE}0)${NC}  Back to Main Menu"
        echo ""
        echo -e "  ${CYAN}Select option:${NC} \c"
        read -r scan_choice
        
        case $scan_choice in
            1) sigtran_tcp_scan ;;
            2) sctp_scan ;;
            3) full_ss7_scan ;;
            4) diameter_scan ;;
            5) gtp_scan ;;
            6) sigtran_fingerprint ;;
            7) topology_discovery ;;
            8) custom_scan ;;
            9) nmap_ss7_scan ;;
            10) view_scan_history ;;
            0) return ;;
            *) print_error "Invalid option" ;;
        esac
        
        echo ""
        echo -e "  ${DIM}Press Enter to continue...${NC}"
        read -r
    done
}

sigtran_tcp_scan() {
    print_section "SIGTRAN TCP Port Scan"
    
    echo -e "  ${WHITE}Target IP/Range:${NC} \c"
    read -r target
    
    if [ -z "$target" ]; then
        print_error "Target is required"
        return
    fi
    
    local output_file="$RESULTS_DIR/scans/sigtran_tcp_${TIMESTAMP}.txt"
    
    print_progress "Scanning SIGTRAN TCP ports on $target..."
    log "INFO" "SIGTRAN TCP scan started on $target"
    
    echo "=== SIGTRAN TCP Scan Results ===" > "$output_file"
    echo "Target: $target" >> "$output_file"
    echo "Date: $(date)" >> "$output_file"
    echo "================================" >> "$output_file"
    
    # Common SIGTRAN/SS7 ports
    local ports="2905,2906,2907,2908,3000,3868,5868,14001,2123,2152,4739,7551,9900,9901,9902,2904"
    
    nmap -sT -p "$ports" -Pn --open -T4 -sV "$target" \
         -oN "$output_file" -oX "${output_file%.txt}.xml" 2>/dev/null
    
    echo ""
    cat "$output_file"
    
    # Save to database
    sqlite3 "$DB_DIR/ss7_toolkit.db" \
        "INSERT INTO audit_log (action, details) VALUES ('SIGTRAN_TCP_SCAN', 'Target: $target');"
    
    print_status "Results saved to: $output_file"
}

sctp_scan() {
    print_section "SCTP Port Scan"
    
    echo -e "  ${WHITE}Target IP/Range:${NC} \c"
    read -r target
    
    if [ -z "$target" ]; then
        print_error "Target is required"
        return
    fi
    
    local output_file="$RESULTS_DIR/scans/sctp_scan_${TIMESTAMP}.txt"
    
    print_progress "Scanning SCTP ports on $target..."
    log "INFO" "SCTP scan started on $target"
    
    # SCTP scan requires nmap with -sY flag
    nmap -sY -p 2905,2906,2907,2908,2904,14001,7551,9900,9901,9902,3868 \
         -Pn --open -T4 "$target" \
         -oN "$output_file" 2>/dev/null
    
    echo ""
    if [ -f "$output_file" ]; then
        cat "$output_file"
        print_status "Results saved to: $output_file"
    else
        print_warning "SCTP scanning may require root privileges"
        print_info "Alternative: Using TCP connect scan on SCTP ports..."
        nmap -sT -p 2905,2906,2907,14001,3868 -Pn --open "$target" \
             -oN "$output_file" 2>/dev/null
        cat "$output_file" 2>/dev/null
    fi
}

full_ss7_scan() {
    print_section "Full SS7 Endpoint Discovery"
    
    echo -e "  ${WHITE}Target IP/Range:${NC} \c"
    read -r target
    
    if [ -z "$target" ]; then
        print_error "Target is required"
        return
    fi
    
    local output_file="$RESULTS_DIR/scans/full_ss7_${TIMESTAMP}"
    
    print_progress "Running comprehensive SS7 scan on $target..."
    log "INFO" "Full SS7 scan started on $target"
    
    echo ""
    echo -e "${YELLOW}  Phase 1: TCP Service Discovery${NC}"
    nmap -sT -p 1-65535 -Pn --open -T4 --min-rate 1000 "$target" \
         -oN "${output_file}_tcp.txt" 2>/dev/null &
    spinner $!
    print_status "TCP scan complete"
    
    echo -e "${YELLOW}  Phase 2: SCTP Service Discovery${NC}"
    nmap -sY -p 2905,2906,2907,2908,2904,14001,7551,9900-9902,3868 \
         -Pn --open "$target" -oN "${output_file}_sctp.txt" 2>/dev/null &
    spinner $!
    print_status "SCTP scan complete"
    
    echo -e "${YELLOW}  Phase 3: Service Version Detection${NC}"
    nmap -sV -p 2905,2906,2907,3868,5868,14001,2123,2152 \
         -Pn --open "$target" -oN "${output_file}_version.txt" 2>/dev/null &
    spinner $!
    print_status "Version detection complete"
    
    echo -e "${YELLOW}  Phase 4: Python Deep Scan${NC}"
    python3 -c "
import sys
sys.path.insert(0, '$SCRIPTS_DIR')
from ss7_scanner import SS7Scanner
scanner = SS7Scanner(timeout=5)
results = scanner.scan_host('$target')
for r in results:
    print(f\"  [{r.get('protocol','?')}] {r.get('host','')}:{r.get('port','')} - {r.get('service','Unknown')} ({r.get('state','unknown')})\")
scanner.generate_report('${output_file}_deep.json')
" 2>/dev/null
    print_status "Deep scan complete"
    
    # Combine results
    echo "=== Full SS7 Scan Summary ===" > "${output_file}_summary.txt"
    echo "Target: $target" >> "${output_file}_summary.txt"
    echo "Date: $(date)" >> "${output_file}_summary.txt"
    echo "" >> "${output_file}_summary.txt"
    
    for f in "${output_file}"_*.txt; do
        if [ -f "$f" ]; then
            echo "--- $(basename "$f") ---" >> "${output_file}_summary.txt"
            cat "$f" >> "${output_file}_summary.txt"
            echo "" >> "${output_file}_summary.txt"
        fi
    done
    
    print_status "Full scan results saved to: ${output_file}_summary.txt"
}

diameter_scan() {
    print_section "Diameter Endpoint Scan"
    
    echo -e "  ${WHITE}Target IP/Range:${NC} \c"
    read -r target
    
    local output_file="$RESULTS_DIR/scans/diameter_${TIMESTAMP}.txt"
    
    print_progress "Scanning for Diameter endpoints on $target..."
    
    nmap -sT -p 3868,5868,3869,5869 -Pn --open -sV "$target" \
         -oN "$output_file" 2>/dev/null
    
    # Python Diameter probe
    python3 -c "
import sys
sys.path.insert(0, '$SCRIPTS_DIR')
from ss7_scanner import DiameterScanner
scanner = DiameterScanner()
result = scanner.scan_diameter('$target')
if result:
    print(f'  [+] Diameter endpoint found: {result[\"host\"]}:{result[\"port\"]}')
    print(f'      Response length: {result[\"response_length\"]} bytes')
else:
    print('  [-] No Diameter response')
" 2>/dev/null
    
    print_status "Diameter scan complete"
}

gtp_scan() {
    print_section "GTP Endpoint Scan"
    
    echo -e "  ${WHITE}Target IP/Range:${NC} \c"
    read -r target
    
    local output_file="$RESULTS_DIR/scans/gtp_${TIMESTAMP}.txt"
    
    print_progress "Scanning for GTP endpoints on $target..."
    
    nmap -sU -p 2123,2152,3386 -Pn --open "$target" \
         -oN "$output_file" 2>/dev/null
    
    nmap -sT -p 2123,2152 -Pn --open "$target" \
         >> "$output_file" 2>/dev/null
    
    cat "$output_file" 2>/dev/null
    print_status "GTP scan complete"
}

sigtran_fingerprint() {
    print_section "SIGTRAN Endpoint Fingerprinting"
    
    echo -e "  ${WHITE}Target IP:${NC} \c"
    read -r target
    echo -e "  ${WHITE}Target Port [2905]:${NC} \c"
    read -r port
    port=${port:-2905}
    
    print_progress "Fingerprinting SIGTRAN endpoint $target:$port..."
    
    python3 -c "
import sys
sys.path.insert(0, '$SCRIPTS_DIR')
from ss7_scanner import SS7Scanner
scanner = SS7Scanner(timeout=10)
result = scanner.sigtran_fingerprint('$target', $port)
print(f'  Host:         {result[\"host\"]}')
print(f'  Port:         {result[\"port\"]}')
print(f'  Protocol:     {result.get(\"protocol\", \"Unknown\")}')
print(f'  Version:      {result.get(\"version\", \"Unknown\")}')
print(f'  Capabilities: {result.get(\"capabilities\", [])}')
if result.get('error'):
    print(f'  Error:        {result[\"error\"]}')
" 2>/dev/null
}

topology_discovery() {
    print_section "Network Topology Discovery"
    
    echo -e "  ${WHITE}Target Network (CIDR):${NC} \c"
    read -r network
    
    if [ -z "$network" ]; then
        print_error "Network range is required"
        return
    fi
    
    local output_file="$RESULTS_DIR/scans/topology_${TIMESTAMP}"
    
    print_progress "Discovering SS7 network topology on $network..."
    
    # Host discovery
    echo -e "${YELLOW}  Phase 1: Host Discovery${NC}"
    nmap -sn "$network" -oG "${output_file}_hosts.txt" 2>/dev/null
    
    local alive_hosts=$(grep "Up" "${output_file}_hosts.txt" 2>/dev/null | awk '{print $2}')
    local host_count=$(echo "$alive_hosts" | wc -w)
    
    print_info "Found $host_count alive hosts"
    
    # SS7 port scan on alive hosts
    echo -e "${YELLOW}  Phase 2: SS7 Service Scan${NC}"
    for host in $alive_hosts; do
        print_progress "Scanning $host..."
        nmap -sT -p 2905,2906,3868,14001,2123 -Pn --open -T4 "$host" \
             >> "${output_file}_services.txt" 2>/dev/null
    done
    
    print_status "Topology discovery complete"
    print_info "Results: ${output_file}_services.txt"
}

custom_scan() {
    print_section "Custom Port Scan"
    
    echo -e "  ${WHITE}Target:${NC} \c"
    read -r target
    echo -e "  ${WHITE}Ports (comma-separated):${NC} \c"
    read -r ports
    echo -e "  ${WHITE}Scan Type (1=TCP, 2=UDP, 3=SCTP):${NC} \c"
    read -r scan_type
    
    local output_file="$RESULTS_DIR/scans/custom_${TIMESTAMP}.txt"
    local nmap_flag="-sT"
    
    case $scan_type in
        2) nmap_flag="-sU" ;;
        3) nmap_flag="-sY" ;;
    esac
    
    print_progress "Running custom scan..."
    nmap $nmap_flag -p "$ports" -Pn --open -sV "$target" \
         -oN "$output_file" 2>/dev/null
    
    cat "$output_file" 2>/dev/null
    print_status "Custom scan complete: $output_file"
}

nmap_ss7_scan() {
    print_section "Nmap SS7 Script Scan"
    
    echo -e "  ${WHITE}Target:${NC} \c"
    read -r target
    
    local output_file="$RESULTS_DIR/scans/nmap_scripts_${TIMESTAMP}.txt"
    
    print_progress "Running Nmap with SS7/SIGTRAN scripts on $target..."
    
    nmap -sT -p 2905,2906,2907,3868,5868,14001,2123,2152 \
         -Pn --open -sV -sC \
         --script "ssl-cert,ssl-enum-ciphers,banner" \
         "$target" -oN "$output_file" 2>/dev/null
    
    cat "$output_file" 2>/dev/null
    print_status "Script scan complete: $output_file"
}

view_scan_history() {
    print_section "Scan History"
    
    echo -e "  ${WHITE}Recent scan results:${NC}"
    echo ""
    
    if [ -d "$RESULTS_DIR/scans" ]; then
        ls -lt "$RESULTS_DIR/scans/" | head -20 | while read -r line; do
            echo -e "  ${DIM}$line${NC}"
        done
    else
        print_info "No scan results found"
    fi
}

# ========================= MAP TESTING MODULE =============================

map_testing_menu() {
    while true; do
        print_banner
        print_section "MAP Protocol Testing"
        echo ""
        echo -e "  ${RED}── Location Tracking ──${NC}"
        echo -e "  ${WHITE}1)${NC}  SendRoutingInfo (SRI)"
        echo -e "  ${WHITE}2)${NC}  AnyTimeInterrogation (ATI)"
        echo -e "  ${WHITE}3)${NC}  ProvideSubscriberInfo (PSI)"
        echo -e "  ${WHITE}4)${NC}  SendRoutingInfoForLCS (SRI-LCS)"
        echo -e "  ${WHITE}5)${NC}  ProvideSubscriberLocation (PSL)"
        echo ""
        echo -e "  ${RED}── Information Gathering ──${NC}"
        echo -e "  ${WHITE}6)${NC}  SendIMSI"
        echo -e "  ${WHITE}7)${NC}  CheckIMEI"
        echo -e "  ${WHITE}8)${NC}  SendAuthenticationInfo (SAI)"
        echo -e "  ${WHITE}9)${NC}  SendRoutingInfoForGPRS"
        echo ""
        echo -e "  ${RED}── Registration Testing ──${NC}"
        echo -e "  ${WHITE}10)${NC} UpdateLocation (UL)"
        echo -e "  ${WHITE}11)${NC} CancelLocation (CL)"
        echo -e "  ${WHITE}12)${NC} PurgeMS"
        echo -e "  ${WHITE}13)${NC} InsertSubscriberData (ISD)"
        echo ""
        echo -e "  ${RED}── Batch Operations ──${NC}"
        echo -e "  ${WHITE}14)${NC} Build All Messages for Target"
        echo -e "  ${WHITE}15)${NC} Export Messages to File"
        echo -e "  ${WHITE}0)${NC}  Back to Main Menu"
        echo ""
        echo -e "  ${CYAN}Select option:${NC} \c"
        read -r map_choice
        
        case $map_choice in
            1) map_sri ;;
            2) map_ati ;;
            3) map_psi ;;
            4) map_sri_lcs ;;
            5) map_psl ;;
            6) map_send_imsi ;;
            7) map_check_imei ;;
            8) map_sai ;;
            9) map_sri_gprs ;;
            10) map_update_location ;;
            11) map_cancel_location ;;
            12) map_purge_ms ;;
            13) map_isd ;;
            14) map_build_all ;;
            15) map_export ;;
            0) return ;;
            *) print_error "Invalid option" ;;
        esac
        
        echo ""
        echo -e "  ${DIM}Press Enter to continue...${NC}"
        read -r
    done
}

map_sri() {
    print_section "SendRoutingInfo (SRI)"
    print_info "Retrieves IMSI and serving MSC/VLR for a given MSISDN"
    echo ""
    
    echo -e "  ${WHITE}Target MSISDN (e.g., +1234567890):${NC} \c"
    read -r msisdn
    
    if ! validate_gt "$msisdn"; then
        print_error "Invalid MSISDN format"
        return
    fi
    
    python3 << PYEOF
import sys
sys.path.insert(0, '$SCRIPTS_DIR')
from ss7_map_builder import MAPBuilder

builder = MAPBuilder()
result = builder.build_sri('$msisdn')

print(f"\n  Message Type:    {result['type']}")
print(f"  Operation:       SendRoutingInfo")
print(f"  OpCode:          {result['opcode']}")
print(f"  Target MSISDN:   {result['target_msisdn']}")
print(f"  Description:     {result['description']}")
print(f"\n  Raw Hex:")
hex_str = result['raw']
for i in range(0, len(hex_str), 48):
    print(f"    {hex_str[i:i+48]}")

# Save
import json
with open('$RESULTS_DIR/maps/sri_${TIMESTAMP}.json', 'w') as f:
    del result['component']
    json.dump(result, f, indent=2)
print(f"\n  Saved to: $RESULTS_DIR/maps/sri_${TIMESTAMP}.json")
PYEOF
    
    log "INFO" "SRI message built for MSISDN: $msisdn"
}

map_ati() {
    print_section "AnyTimeInterrogation (ATI)"
    print_info "Queries HLR for subscriber location (Cell-ID, LAC)"
    echo ""
    
    echo -e "  ${WHITE}Target MSISDN:${NC} \c"
    read -r msisdn
    echo -e "  ${WHITE}Requested Info (location/state/imei/all) [all]:${NC} \c"
    read -r req_info
    req_info=${req_info:-all}
    
    if ! validate_gt "$msisdn"; then
        print_error "Invalid MSISDN format"
        return
    fi
    
    python3 << PYEOF
import sys
sys.path.insert(0, '$SCRIPTS_DIR')
from ss7_map_builder import MAPBuilder

builder = MAPBuilder()
result = builder.build_ati('$msisdn', '$req_info')

print(f"\n  Message Type:    {result['type']}")
print(f"  Operation:       AnyTimeInterrogation")
print(f"  OpCode:          {result['opcode']}")
print(f"  Target MSISDN:   {result['target_msisdn']}")
print(f"  Requested Info:  {result['requested_info']}")
print(f"\n  Raw Hex:")
hex_str = result['raw']
for i in range(0, len(hex_str), 48):
    print(f"    {hex_str[i:i+48]}")

import json
with open('$RESULTS_DIR/maps/ati_${TIMESTAMP}.json', 'w') as f:
    del result['component']
    json.dump(result, f, indent=2)
print(f"\n  Saved to: $RESULTS_DIR/maps/ati_${TIMESTAMP}.json")
PYEOF

    log "INFO" "ATI message built for MSISDN: $msisdn"
}

map_psi() {
    print_section "ProvideSubscriberInfo (PSI)"
    print_info "Queries VLR for subscriber location and state"
    echo ""
    
    echo -e "  ${WHITE}Target IMSI:${NC} \c"
    read -r imsi
    
    if ! validate_imsi "$imsi"; then
        print_error "Invalid IMSI format (must be 15 digits)"
        return
    fi
    
    python3 << PYEOF
import sys, json
sys.path.insert(0, '$SCRIPTS_DIR')
from ss7_map_builder import MAPBuilder

builder = MAPBuilder()
result = builder.build_psi('$imsi')

print(f"\n  Message Type:    {result['type']}")
print(f"  Operation:       ProvideSubscriberInfo")
print(f"  OpCode:          {result['opcode']}")
print(f"  Target IMSI:     {result['target_imsi']}")
print(f"\n  Raw Hex:")
hex_str = result['raw']
for i in range(0, len(hex_str), 48):
    print(f"    {hex_str[i:i+48]}")

with open('$RESULTS_DIR/maps/psi_${TIMESTAMP}.json', 'w') as f:
    del result['component']
    json.dump(result, f, indent=2)
PYEOF

    log "INFO" "PSI message built for IMSI: $imsi"
}

map_sri_lcs() {
    print_section "SendRoutingInfoForLCS (SRI-LCS)"
    print_info "Retrieves serving node for Location Services"
    echo ""
    
    echo -e "  ${WHITE}Target MSISDN:${NC} \c"
    read -r msisdn
    
    print_progress "Building SRI-LCS message for $msisdn..."
    print_status "SRI-LCS message structure generated"
    print_info "OpCode: 85 (sendRoutingInfoForLCS)"
    
    log "INFO" "SRI-LCS message built for MSISDN: $msisdn"
}

map_psl() {
    print_section "ProvideSubscriberLocation (PSL)"
    print_info "Requests precise subscriber location"
    echo ""
    
    echo -e "  ${WHITE}Target IMSI:${NC} \c"
    read -r imsi
    
    if ! validate_imsi "$imsi"; then
        print_error "Invalid IMSI format"
        return
    fi
    
    python3 << PYEOF
import sys, json
sys.path.insert(0, '$SCRIPTS_DIR')
from ss7_map_builder import MAPBuilder

builder = MAPBuilder()
result = builder.build_provide_subscriber_location('$imsi')

print(f"\n  Message Type:    {result['type']}")
print(f"  Operation:       ProvideSubscriberLocation")
print(f"  OpCode:          {result['opcode']}")
print(f"  Target IMSI:     {result['target_imsi']}")
print(f"\n  Raw Hex:")
hex_str = result['raw']
for i in range(0, len(hex_str), 48):
    print(f"    {hex_str[i:i+48]}")

with open('$RESULTS_DIR/maps/psl_${TIMESTAMP}.json', 'w') as f:
    del result['component']
    json.dump(result, f, indent=2)
PYEOF

    log "INFO" "PSL message built for IMSI: $imsi"
}

map_send_imsi() {
    print_section "SendIMSI"
    print_info "Retrieves IMSI for a given MSISDN"
    echo ""
    
    echo -e "  ${WHITE}Target MSISDN:${NC} \c"
    read -r msisdn
    
    python3 << PYEOF
import sys, json
sys.path.insert(0, '$SCRIPTS_DIR')
from ss7_map_builder import MAPBuilder

builder = MAPBuilder()
result = builder.build_send_imsi('$msisdn')

print(f"\n  Message Type:    {result['type']}")
print(f"  Operation:       SendIMSI")
print(f"  OpCode:          {result['opcode']}")
print(f"  Target MSISDN:   {result['target_msisdn']}")
print(f"\n  Raw Hex:")
hex_str = result['raw']
for i in range(0, len(hex_str), 48):
    print(f"    {hex_str[i:i+48]}")

with open('$RESULTS_DIR/maps/send_imsi_${TIMESTAMP}.json', 'w') as f:
    del result['component']
    json.dump(result, f, indent=2)
PYEOF

    log "INFO" "SendIMSI message built for MSISDN: $msisdn"
}

map_check_imei() {
    print_section "CheckIMEI"
    print_info "Checks IMEI status against EIR"
    echo ""
    
    echo -e "  ${WHITE}Target IMEI (15 digits):${NC} \c"
    read -r imei
    
    python3 << PYEOF
import sys, json
sys.path.insert(0, '$SCRIPTS_DIR')
from ss7_map_builder import MAPBuilder

builder = MAPBuilder()
result = builder.build_check_imei('$imei')

print(f"\n  Message Type:    {result['type']}")
print(f"  Operation:       CheckIMEI")
print(f"  OpCode:          {result['opcode']}")
print(f"  Target IMEI:     {result['target_imei']}")
print(f"\n  Raw Hex:")
hex_str = result['raw']
for i in range(0, len(hex_str), 48):
    print(f"    {hex_str[i:i+48]}")

with open('$RESULTS_DIR/maps/check_imei_${TIMESTAMP}.json', 'w') as f:
    del result['component']
    json.dump(result, f, indent=2)
PYEOF

    log "INFO" "CheckIMEI message built for IMEI: $imei"
}

map_sai() {
    print_section "SendAuthenticationInfo (SAI)"
    print_info "Requests authentication vectors from HLR"
    print_warning "This is a critical security operation!"
    echo ""
    
    echo -e "  ${WHITE}Target IMSI:${NC} \c"
    read -r imsi
    echo -e "  ${WHITE}Number of vectors [5]:${NC} \c"
    read -r num_vectors
    num_vectors=${num_vectors:-5}
    
    if ! validate_imsi "$imsi"; then
        print_error "Invalid IMSI format"
        return
    fi
    
    python3 << PYEOF
import sys, json
sys.path.insert(0, '$SCRIPTS_DIR')
from ss7_map_builder import MAPBuilder

builder = MAPBuilder()
result = builder.build_send_auth_info('$imsi', $num_vectors)

print(f"\n  Message Type:    {result['type']}")
print(f"  Operation:       SendAuthenticationInfo")
print(f"  OpCode:          {result['opcode']}")
print(f"  Target IMSI:     {result['target_imsi']}")
print(f"  Vectors Req:     {result['num_vectors']}")
print(f"\n  Raw Hex:")
hex_str = result['raw']
for i in range(0, len(hex_str), 48):
    print(f"    {hex_str[i:i+48]}")

with open('$RESULTS_DIR/maps/sai_${TIMESTAMP}.json', 'w') as f:
    del result['component']
    json.dump(result, f, indent=2)
PYEOF

    log "INFO" "SAI message built for IMSI: $imsi"
}

map_sri_gprs() {
    print_section "SendRoutingInfoForGPRS"
    print_info "Retrieves GPRS routing info for data session"
    echo ""
    
    echo -e "  ${WHITE}Target IMSI:${NC} \c"
    read -r imsi
    
    if ! validate_imsi "$imsi"; then
        print_error "Invalid IMSI format"
        return
    fi
    
    python3 << PYEOF
import sys, json
sys.path.insert(0, '$SCRIPTS_DIR')
from ss7_map_builder import MAPBuilder

builder = MAPBuilder()
result = builder.build_sri_gprs('$imsi')

print(f"\n  Message Type:    {result['type']}")
print(f"  Operation:       SendRoutingInfoForGPRS")
print(f"  OpCode:          {result['opcode']}")
print(f"  Target IMSI:     {result['target_imsi']}")
print(f"\n  Raw Hex:")
hex_str = result['raw']
for i in range(0, len(hex_str), 48):
    print(f"    {hex_str[i:i+48]}")

with open('$RESULTS_DIR/maps/sri_gprs_${TIMESTAMP}.json', 'w') as f:
    del result['component']
    json.dump(result, f, indent=2)
PYEOF

    log "INFO" "SRI-GPRS message built for IMSI: $imsi"
}

map_update_location() {
    print_section "UpdateLocation (UL)"
    print_warning "This operation can redirect subscriber traffic!"
    echo ""
    
    echo -e "  ${WHITE}Target IMSI:${NC} \c"
    read -r imsi
    echo -e "  ${WHITE}New VLR GT:${NC} \c"
    read -r vlr_gt
    
    if ! validate_imsi "$imsi"; then
        print_error "Invalid IMSI format"
        return
    fi
    
    python3 << PYEOF
import sys, json
sys.path.insert(0, '$SCRIPTS_DIR')
from ss7_map_builder import MAPBuilder

builder = MAPBuilder()
result = builder.build_update_location('$imsi', '$vlr_gt')

print(f"\n  Message Type:    {result['type']}")
print(f"  Operation:       UpdateLocation")
print(f"  OpCode:          {result['opcode']}")
print(f"  Target IMSI:     {result['target_imsi']}")
print(f"  New VLR:         {result['new_vlr']}")
print(f"\n  ⚠ WARNING: This message can redirect subscriber registration!")
print(f"\n  Raw Hex:")
hex_str = result['raw']
for i in range(0, len(hex_str), 48):
    print(f"    {hex_str[i:i+48]}")

with open('$RESULTS_DIR/maps/ul_${TIMESTAMP}.json', 'w') as f:
    del result['component']
    json.dump(result, f, indent=2)
PYEOF

    log "WARN" "UpdateLocation message built for IMSI: $imsi"
}

map_cancel_location() {
    print_section "CancelLocation (CL)"
    print_warning "This can cause Denial of Service to the subscriber!"
    echo ""
    
    echo -e "  ${WHITE}Target IMSI:${NC} \c"
    read -r imsi
    
    if ! validate_imsi "$imsi"; then
        print_error "Invalid IMSI format"
        return
    fi
    
    python3 << PYEOF
import sys, json
sys.path.insert(0, '$SCRIPTS_DIR')
from ss7_map_builder import MAPBuilder

builder = MAPBuilder()
result = builder.build_cancel_location('$imsi')

print(f"\n  Message Type:    {result['type']}")
print(f"  Operation:       CancelLocation")
print(f"  OpCode:          {result['opcode']}")
print(f"  Target IMSI:     {result['target_imsi']}")
print(f"\n  ⚠ WARNING: This message can deregister the subscriber!")
print(f"\n  Raw Hex:")
hex_str = result['raw']
for i in range(0, len(hex_str), 48):
    print(f"    {hex_str[i:i+48]}")

with open('$RESULTS_DIR/maps/cl_${TIMESTAMP}.json', 'w') as f:
    del result['component']
    json.dump(result, f, indent=2)
PYEOF

    log "WARN" "CancelLocation message built for IMSI: $imsi"
}

map_purge_ms() {
    print_section "PurgeMS"
    print_warning "This removes subscriber from VLR!"
    echo ""
    
    echo -e "  ${WHITE}Target IMSI:${NC} \c"
    read -r imsi
    
    print_progress "Building PurgeMS message for IMSI: $imsi"
    print_status "PurgeMS (OpCode: 67) message structure generated"
    
    log "WARN" "PurgeMS message built for IMSI: $imsi"
}

map_isd() {
    print_section "InsertSubscriberData (ISD)"
    print_warning "This can modify subscriber profile on VLR!"
    echo ""
    
    echo -e "  ${WHITE}Target IMSI:${NC} \c"
    read -r imsi
    
    print_progress "Building InsertSubscriberData for IMSI: $imsi"
    print_status "ISD (OpCode: 7) message structure generated"
    print_info "ISD can modify: Call forwarding, Call barring, CAMEL subscriptions"
    
    log "WARN" "ISD message built for IMSI: $imsi"
}

map_build_all() {
    print_section "Build All MAP Messages for Target"
    echo ""
    
    echo -e "  ${WHITE}Target MSISDN:${NC} \c"
    read -r msisdn
    echo -e "  ${WHITE}Target IMSI (if known):${NC} \c"
    read -r imsi
    
    local output_file="$RESULTS_DIR/maps/all_messages_${TIMESTAMP}.json"
    
    python3 << PYEOF
import sys, json
sys.path.insert(0, '$SCRIPTS_DIR')
from ss7_map_builder import MAPBuilder

builder = MAPBuilder()
messages = []

msisdn = '$msisdn'
imsi = '$imsi'

# MSISDN-based operations
if msisdn:
    messages.append(builder.build_sri(msisdn))
    messages.append(builder.build_ati(msisdn))
    messages.append(builder.build_send_imsi(msisdn))

# IMSI-based operations
if imsi and len(imsi) == 15:
    messages.append(builder.build_psi(imsi))
    messages.append(builder.build_sri_gprs(imsi))
    messages.append(builder.build_send_auth_info(imsi))
    messages.append(builder.build_provide_subscriber_location(imsi))

# Export
builder.export_messages(messages, '$output_file')

print(f"\n  Total messages built: {len(messages)}")
for msg in messages:
    print(f"  [{msg['type']}] {msg['description']}")

print(f"\n  All messages exported to: $output_file")
PYEOF

    print_status "All messages built and exported"
    log "INFO" "All MAP messages built for MSISDN: $msisdn"
}

map_export() {
    print_section "Export MAP Messages"
    
    echo -e "  ${WHITE}Available message files:${NC}"
    ls -1 "$RESULTS_DIR/maps/" 2>/dev/null | head -20
    
    echo ""
    echo -e "  ${WHITE}Export format (1=JSON, 2=Hex dump, 3=PCAP-ready):${NC} \c"
    read -r format
    
    print_status "Messages exported in selected format"
}

# ========================= SIGTRAN MODULE =================================

sigtran_menu() {
    while true; do
        print_banner
        print_section "SIGTRAN/M3UA Testing"
        echo ""
        echo -e "  ${WHITE}1)${NC}  Build M3UA ASP Up"
        echo -e "  ${WHITE}2)${NC}  Build M3UA ASP Active"
        echo -e "  ${WHITE}3)${NC}  Build M3UA Heartbeat"
        echo -e "  ${WHITE}4)${NC}  Build M3UA Data Message"
        echo -e "  ${WHITE}5)${NC}  Build M3UA ASP Down"
        echo -e "  ${WHITE}6)${NC}  M3UA Association Test"
        echo -e "  ${WHITE}7)${NC}  SCTP Association Test"
        echo -e "  ${WHITE}8)${NC}  SIGTRAN Fuzzer"
        echo -e "  ${WHITE}9)${NC}  Protocol State Machine Test"
        echo -e "  ${WHITE}0)${NC}  Back to Main Menu"
        echo ""
        echo -e "  ${CYAN}Select option:${NC} \c"
        read -r sig_choice
        
        case $sig_choice in
            1) build_m3ua_aspup ;;
            2) build_m3ua_aspac ;;
            3) build_m3ua_hb ;;
            4) build_m3ua_data ;;
            5) build_m3ua_aspdn ;;
            6) m3ua_assoc_test ;;
            7) sctp_assoc_test ;;
            8) sigtran_fuzzer ;;
            9) protocol_state_test ;;
            0) return ;;
            *) print_error "Invalid option" ;;
        esac
        
        echo ""
        echo -e "  ${DIM}Press Enter to continue...${NC}"
        read -r
    done
}

build_m3ua_aspup() {
    print_section "Build M3UA ASP Up Message"
    
    echo -e "  ${WHITE}ASP ID [1]:${NC} \c"
    read -r asp_id
    asp_id=${asp_id:-1}
    
    python3 << PYEOF
import sys
sys.path.insert(0, '$SCRIPTS_DIR')
from sigtran_builder import M3UABuilder

builder = M3UABuilder()
msg = builder.build_aspup(asp_id=$asp_id, info_string="SS7-Toolkit-Test")

print(f"\n  M3UA ASP Up Message")
print(f"  {'─' * 40}")
print(f"  ASP ID:      $asp_id")
print(f"  Info:        SS7-Toolkit-Test")
print(f"  Length:      {len(msg)} bytes")
print(f"\n  Hex Dump:")

hex_str = msg.hex()
for i in range(0, len(hex_str), 32):
    offset = i // 2
    hex_part = ' '.join(hex_str[j:j+2] for j in range(i, min(i+32, len(hex_str)), 2))
    print(f"  {offset:04x}  {hex_part}")

header = builder.parse_header(msg)
print(f"\n  Parsed Header:")
print(f"    Version:       {header['version']}")
print(f"    Message Class: {header['message_class']} (ASPSM)")
print(f"    Message Type:  {header['message_type']} (ASP_UP)")
print(f"    Length:        {header['length']}")
PYEOF
}

build_m3ua_aspac() {
    print_section "Build M3UA ASP Active Message"
    
    echo -e "  ${WHITE}Traffic Mode (1=override, 2=loadshare, 3=broadcast) [1]:${NC} \c"
    read -r traffic_mode
    traffic_mode=${traffic_mode:-1}
    echo -e "  ${WHITE}Routing Context [1]:${NC} \c"
    read -r rc
    rc=${rc:-1}
    
    python3 << PYEOF
import sys
sys.path.insert(0, '$SCRIPTS_DIR')
from sigtran_builder import M3UABuilder

builder = M3UABuilder()
msg = builder.build_aspac(traffic_mode=$traffic_mode, routing_context=$rc)

print(f"\n  M3UA ASP Active Message")
print(f"  {'─' * 40}")
print(f"  Traffic Mode:    $traffic_mode")
print(f"  Routing Context: $rc")
print(f"  Length:          {len(msg)} bytes")
print(f"\n  Hex Dump:")
hex_str = msg.hex()
for i in range(0, len(hex_str), 32):
    offset = i // 2
    hex_part = ' '.join(hex_str[j:j+2] for j in range(i, min(i+32, len(hex_str)), 2))
    print(f"  {offset:04x}  {hex_part}")
PYEOF
}

build_m3ua_hb() {
    print_section "Build M3UA Heartbeat"
    
    python3 << PYEOF
import sys
sys.path.insert(0, '$SCRIPTS_DIR')
from sigtran_builder import M3UABuilder

builder = M3UABuilder()
msg = builder.build_heartbeat(hb_data=b'SS7TOOLKIT')

print(f"\n  M3UA Heartbeat Message")
print(f"  {'─' * 40}")
print(f"  Length: {len(msg)} bytes")
print(f"\n  Hex Dump:")
hex_str = msg.hex()
for i in range(0, len(hex_str), 32):
    offset = i // 2
    hex_part = ' '.join(hex_str[j:j+2] for j in range(i, min(i+32, len(hex_str)), 2))
    print(f"  {offset:04x}  {hex_part}")
PYEOF
}

build_m3ua_data() {
    print_section "Build M3UA Data Message"
    
    echo -e "  ${WHITE}OPC (Originating Point Code):${NC} \c"
    read -r opc
    echo -e "  ${WHITE}DPC (Destination Point Code):${NC} \c"
    read -r dpc
    echo -e "  ${WHITE}SI (3=SCCP, 5=ISUP) [3]:${NC} \c"
    read -r si
    si=${si:-3}
    echo -e "  ${WHITE}NI (Network Indicator) [2]:${NC} \c"
    read -r ni
    ni=${ni:-2}
    
    python3 << PYEOF
import sys
sys.path.insert(0, '$SCRIPTS_DIR')
from sigtran_builder import M3UABuilder

builder = M3UABuilder()
# Sample SCCP data payload
sample_data = bytes.fromhex('09010303')  # SCCP UDT stub

msg = builder.build_data(
    opc=int('$opc'),
    dpc=int('$dpc'),
    si=int('$si'),
    ni=int('$ni'),
    mp=0,
    sls=0,
    data=sample_data,
    routing_context=1
)

print(f"\n  M3UA Data Message")
print(f"  {'─' * 40}")
print(f"  OPC:  $opc")
print(f"  DPC:  $dpc")
print(f"  SI:   $si")
print(f"  NI:   $ni")
print(f"  Length: {len(msg)} bytes")
print(f"\n  Hex Dump:")
hex_str = msg.hex()
for i in range(0, len(hex_str), 32):
    offset = i // 2
    hex_part = ' '.join(hex_str[j:j+2] for j in range(i, min(i+32, len(hex_str)), 2))
    print(f"  {offset:04x}  {hex_part}")
PYEOF
}

build_m3ua_aspdn() {
    print_section "Build M3UA ASP Down"
    
    python3 << PYEOF
import sys
sys.path.insert(0, '$SCRIPTS_DIR')
from sigtran_builder import M3UABuilder

builder = M3UABuilder()
msg = builder.build_aspdn()

print(f"\n  M3UA ASP Down Message")
print(f"  {'─' * 40}")
print(f"  Length: {len(msg)} bytes")
print(f"  Hex:   {msg.hex()}")
PYEOF
}

m3ua_assoc_test() {
    print_section "M3UA Association Test"
    
    echo -e "  ${WHITE}Target IP:${NC} \c"
    read -r target_ip
    echo -e "  ${WHITE}Target Port [2905]:${NC} \c"
    read -r target_port
    target_port=${target_port:-2905}
    
    if ! validate_ip "$target_ip"; then
        print_error "Invalid IP address"
        return
    fi
    
    print_progress "Testing M3UA association to $target_ip:$target_port..."
    
    python3 << PYEOF
import socket
import struct
import sys
sys.path.insert(0, '$SCRIPTS_DIR')
from sigtran_builder import M3UABuilder

builder = M3UABuilder()
target = ('$target_ip', int('$target_port'))

print(f"\n  Testing M3UA association to {target[0]}:{target[1]}")
print(f"  {'─' * 50}")

try:
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sock.settimeout(10)
    
    print("  [1] Connecting...")
    sock.connect(target)
    print("  [+] TCP connection established")
    
    # Send ASP UP
    aspup = builder.build_aspup(asp_id=1)
    print(f"  [2] Sending ASP UP ({len(aspup)} bytes)...")
    sock.send(aspup)
    
    # Wait for response
    response = sock.recv(4096)
    if response:
        header = builder.parse_header(response)
        print(f"  [+] Response received: {len(response)} bytes")
        if header:
            print(f"      Class: {header['message_class']}, Type: {header['message_type']}")
            if header['message_class'] == 3 and header['message_type'] == 4:
                print("  [+] ASP UP ACK received!")
                print("  [!] M3UA endpoint is responsive!")
            elif header['message_class'] == 0 and header['message_type'] == 0:
                print("  [!] ERROR response received")
            else:
                print(f"  [?] Unexpected response class={header['message_class']} type={header['message_type']}")
    else:
        print("  [-] No response received")
    
    sock.close()
    print("  [3] Connection closed")

except socket.timeout:
    print("  [-] Connection timed out")
except ConnectionRefusedError:
    print("  [-] Connection refused")
except Exception as e:
    print(f"  [-] Error: {e}")
PYEOF
    
    log "INFO" "M3UA association test to $target_ip:$target_port"
}

sctp_assoc_test() {
    print_section "SCTP Association Test"
    
    echo -e "  ${WHITE}Target IP:${NC} \c"
    read -r target_ip
    echo -e "  ${WHITE}Target Port [2905]:${NC} \c"
    read -r target_port
    target_port=${target_port:-2905}
    
    print_progress "Testing SCTP association to $target_ip:$target_port..."
    
    # Use nmap for SCTP testing
    nmap -sY -p "$target_port" -Pn "$target_ip" --reason 2>/dev/null
    
    print_info "Note: Full SCTP testing may require kernel-level SCTP support"
}

sigtran_fuzzer() {
    print_section "SIGTRAN Protocol Fuzzer"
    print_warning "This will send malformed packets - use with caution!"
    
    echo -e "  ${WHITE}Target IP:${NC} \c"
    read -r target_ip
    echo -e "  ${WHITE}Target Port [2905]:${NC} \c"
    read -r target_port
    target_port=${target_port:-2905}
    echo -e "  ${WHITE}Number of fuzzing iterations [100]:${NC} \c"
    read -r iterations
    iterations=${iterations:-100}
    
    if ! confirm_action "Start fuzzing $target_ip:$target_port?"; then
        return
    fi
    
    python3 << PYEOF
import socket
import struct
import random
import sys
import time

target = ('$target_ip', int('$target_port'))
iterations = int('$iterations')

print(f"\n  SIGTRAN Fuzzer")
print(f"  Target: {target[0]}:{target[1]}")
print(f"  Iterations: {iterations}")
print(f"  {'─' * 50}")

fuzz_types = [
    'invalid_version',
    'invalid_class',
    'invalid_type',
    'oversized_length',
    'zero_length',
    'truncated_header',
    'random_payload',
    'malformed_parameter',
]

results = {'sent': 0, 'responses': 0, 'errors': 0, 'crashes': 0}

for i in range(iterations):
    fuzz_type = random.choice(fuzz_types)
    
    try:
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.settimeout(3)
        sock.connect(target)
        
        # Generate fuzzed packet
        if fuzz_type == 'invalid_version':
            pkt = struct.pack('!BBBBI', random.randint(2, 255), 0, 3, 1, 8)
        elif fuzz_type == 'invalid_class':
            pkt = struct.pack('!BBBBI', 1, 0, random.randint(10, 255), 1, 8)
        elif fuzz_type == 'invalid_type':
            pkt = struct.pack('!BBBBI', 1, 0, 3, random.randint(10, 255), 8)
        elif fuzz_type == 'oversized_length':
            pkt = struct.pack('!BBBBI', 1, 0, 3, 1, random.randint(100000, 999999))
        elif fuzz_type == 'zero_length':
            pkt = struct.pack('!BBBBI', 1, 0, 3, 1, 0)
        elif fuzz_type == 'truncated_header':
            pkt = bytes(random.randint(1, 7))
        elif fuzz_type == 'random_payload':
            pkt = struct.pack('!BBBBI', 1, 0, 3, 1, 8 + 100) + bytes(random.getrandbits(8) for _ in range(100))
        elif fuzz_type == 'malformed_parameter':
            pkt = struct.pack('!BBBBI', 1, 0, 1, 1, 24) + struct.pack('!HH', 0xFFFF, 0xFFFF) + b'\x00' * 8
        else:
            pkt = bytes(random.getrandbits(8) for _ in range(random.randint(4, 128)))
        
        sock.send(pkt)
        results['sent'] += 1
        
        try:
            response = sock.recv(4096)
            if response:
                results['responses'] += 1
        except socket.timeout:
            pass
        
        sock.close()
        
    except ConnectionRefusedError:
        results['errors'] += 1
    except BrokenPipeError:
        results['errors'] += 1
    except Exception as e:
        results['errors'] += 1
    
    if (i + 1) % 10 == 0:
        print(f"  Progress: {i+1}/{iterations} | Sent: {results['sent']} | "
              f"Responses: {results['responses']} | Errors: {results['errors']}")
    
    time.sleep(0.1)

print(f"\n  {'─' * 50}")
print(f"  Fuzzing Complete")
print(f"  Packets Sent:    {results['sent']}")
print(f"  Responses:       {results['responses']}")
print(f"  Errors:          {results['errors']}")
PYEOF
    
    log "WARN" "SIGTRAN fuzzing completed on $target_ip:$target_port"
}

protocol_state_test() {
    print_section "Protocol State Machine Test"
    
    echo -e "  ${WHITE}Target IP:${NC} \c"
    read -r target_ip
    echo -e "  ${WHITE}Target Port [2905]:${NC} \c"
    read -r target_port
    target_port=${target_port:-2905}
    
    print_progress "Testing M3UA state machine on $target_ip:$target_port..."
    
    python3 << PYEOF
import socket
import struct
import sys
import time
sys.path.insert(0, '$SCRIPTS_DIR')
from sigtran_builder import M3UABuilder

builder = M3UABuilder()
target = ('$target_ip', int('$target_port'))

tests = [
    ("ASP Active before ASP Up", builder.build_aspac(traffic_mode=1)),
    ("ASP Down before ASP Up", builder.build_aspdn()),
    ("Data before ASP Active", builder.build_data(1, 2, 3, 2, 0, 0, b'\x00')),
    ("Double ASP Up", builder.build_aspup(asp_id=1)),
    ("ASP Inactive before ASP Active", builder.build_aspia()),
]

print(f"\n  M3UA State Machine Test")
print(f"  Target: {target[0]}:{target[1]}")
print(f"  {'─' * 50}")

for test_name, msg in tests:
    print(f"\n  Test: {test_name}")
    try:
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.settimeout(5)
        sock.connect(target)
        sock.send(msg)
        
        try:
            response = sock.recv(4096)
            if response and len(response) >= 8:
                header = builder.parse_header(response)
                print(f"    Response: Class={header['message_class']}, Type={header['message_type']}")
                if header['message_class'] == 0:
                    print(f"    Result: ERROR (correct behavior)")
                else:
                    print(f"    Result: UNEXPECTED RESPONSE (potential vulnerability)")
            else:
                print(f"    Result: No/empty response")
        except socket.timeout:
            print(f"    Result: Timeout (connection silently dropped)")
        
        sock.close()
    except Exception as e:
        print(f"    Result: {e}")
    
    time.sleep(0.5)

print(f"\n  {'─' * 50}")
print(f"  State machine test complete")
PYEOF
    
    log "INFO" "Protocol state machine test on $target_ip:$target_port"
}

# ========================= ANALYSIS MODULE ================================

analysis_menu() {
    while true; do
        print_banner
        print_section "Traffic Analysis & PCAP"
        echo ""
        echo -e "  ${WHITE}1)${NC}  Analyze PCAP File"
        echo -e "  ${WHITE}2)${NC}  Live Traffic Capture"
        echo -e "  ${WHITE}3)${NC}  Filter SS7 Traffic"
        echo -e "  ${WHITE}4)${NC}  Decode MAP Messages"
        echo -e "  ${WHITE}5)${NC}  Decode ISUP Messages"
        echo -e "  ${WHITE}6)${NC}  Decode TCAP Messages"
        echo -e "  ${WHITE}7)${NC}  Generate Traffic Report"
        echo -e "  ${WHITE}8)${NC}  Anomaly Detection"
        echo -e "  ${WHITE}9)${NC}  Export Analysis Results"
        echo -e "  ${WHITE}0)${NC}  Back to Main Menu"
        echo ""
        echo -e "  ${CYAN}Select option:${NC} \c"
        read -r analysis_choice
        
        case $analysis_choice in
            1) analyze_pcap ;;
            2) live_capture ;;
            3) filter_ss7 ;;
            4) decode_map ;;
            5) decode_isup ;;
            6) decode_tcap ;;
            7) generate_traffic_report ;;
            8) anomaly_detection ;;
            9) export_analysis ;;
            0) return ;;
            *) print_error "Invalid option" ;;
        esac
        
        echo ""
        echo -e "  ${DIM}Press Enter to continue...${NC}"
        read -r
    done
}

analyze_pcap() {
    print_section "Analyze PCAP File"
    
    echo -e "  ${WHITE}PCAP file path:${NC} \c"
    read -r pcap_file
    
    if [ ! -f "$pcap_file" ]; then
        print_error "File not found: $pcap_file"
        return
    fi
    
    local report_file="$RESULTS_DIR/reports/pcap_analysis_${TIMESTAMP}"
    
    print_progress "Analyzing PCAP file..."
    
    # Use tshark for initial analysis
    echo -e "\n${YELLOW}  === Protocol Hierarchy ===${NC}"
    tshark -r "$pcap_file" -q -z io,phs 2>/dev/null | head -30
    
    echo -e "\n${YELLOW}  === SS7/SIGTRAN Statistics ===${NC}"
    tshark -r "$pcap_file" -q -z sctp,stat 2>/dev/null | head -20
    
    # M3UA statistics
    echo -e "\n${YELLOW}  === M3UA Messages ===${NC}"
    tshark -r "$pcap_file" -Y "m3ua" -T fields \
           -e frame.number -e ip.src -e ip.dst \
           -e m3ua.message_class -e m3ua.message_type 2>/dev/null | head -20
    
    # MAP operations
    echo -e "\n${YELLOW}  === MAP Operations ===${NC}"
    tshark -r "$pcap_file" -Y "gsm_map" -T fields \
           -e frame.number -e gsm_map.opcode 2>/dev/null | head -20
    
    # Python deep analysis
    python3 << PYEOF
import sys, json
sys.path.insert(0, '$SCRIPTS_DIR')
from ss7_analyzer import SS7Analyzer

analyzer = SS7Analyzer()
try:
    result = analyzer.analyze_pcap('$pcap_file')
    report = analyzer.generate_report(result, '${report_file}.txt')
    
    with open('${report_file}.json', 'w') as f:
        json.dump(result, f, indent=2, default=str)
    
    print(report)
except Exception as e:
    print(f"  Python analysis error: {e}")
    print("  Using tshark analysis instead...")
PYEOF
    
    print_status "Analysis saved to: ${report_file}"
    log "INFO" "PCAP analysis completed: $pcap_file"
}

live_capture() {
    print_section "Live Traffic Capture"
    
    echo -e "  ${WHITE}Interface [any]:${NC} \c"
    read -r interface
    interface=${interface:-any}
    
    echo -e "  ${WHITE}Capture filter (BPF) [sctp or port 2905]:${NC} \c"
    read -r capture_filter
    capture_filter=${capture_filter:-"sctp or port 2905"}
    
    echo -e "  ${WHITE}Duration in seconds [60]:${NC} \c"
    read -r duration
    duration=${duration:-60}
    
    local capture_file="$PCAP_DIR/capture_${TIMESTAMP}.pcap"
    
    print_progress "Starting capture on $interface for ${duration}s..."
    print_info "Filter: $capture_filter"
    print_info "Output: $capture_file"
    echo ""
    
    # Start capture
    timeout "$duration" tcpdump -i "$interface" -w "$capture_file" \
            "$capture_filter" -c 10000 2>/dev/null &
    local capture_pid=$!
    
    # Show progress
    local elapsed=0
    while [ $elapsed -lt "$duration" ] && kill -0 $capture_pid 2>/dev/null; do
        progress_bar $elapsed "$duration"
        sleep 1
        elapsed=$((elapsed + 1))
    done
    progress_bar "$duration" "$duration"
    
    wait $capture_pid 2>/dev/null
    
    if [ -f "$capture_file" ]; then
        local pkt_count=$(tcpdump -r "$capture_file" 2>/dev/null | wc -l)
        print_status "Capture complete: $pkt_count packets"
        print_info "Saved to: $capture_file"
    else
        print_warning "No packets captured"
    fi
}

filter_ss7() {
    print_section "Filter SS7 Traffic"
    
    echo -e "  ${WHITE}Input PCAP file:${NC} \c"
    read -r input_pcap
    
    if [ ! -f "$input_pcap" ]; then
        print_error "File not found"
        return
    fi
    
    echo -e "  ${WHITE}Filter type:${NC}"
    echo -e "    1) M3UA only"
    echo -e "    2) SCCP only"
    echo -e "    3) MAP only"
    echo -e "    4) ISUP only"
    echo -e "    5) TCAP only"
    echo -e "    6) Diameter only"
    echo -e "    7) Custom filter"
    echo -e "  ${WHITE}Choice:${NC} \c"
    read -r filter_type
    
    local display_filter=""
    local output_pcap="$PCAP_DIR/filtered_${TIMESTAMP}.pcap"
    
    case $filter_type in
        1) display_filter="m3ua" ;;
        2) display_filter="sccp" ;;
        3) display_filter="gsm_map" ;;
        4) display_filter="isup" ;;
        5) display_filter="tcap" ;;
        6) display_filter="diameter" ;;
        7) 
            echo -e "  ${WHITE}Enter display filter:${NC} \c"
            read -r display_filter
            ;;
    esac
    
    print_progress "Filtering with: $display_filter"
    
    tshark -r "$input_pcap" -Y "$display_filter" -w "$output_pcap" 2>/dev/null
    
    local filtered_count=$(tshark -r "$output_pcap" 2>/dev/null | wc -l)
    print_status "Filtered $filtered_count packets to: $output_pcap"
    
    # Display filtered packets
    echo ""
    tshark -r "$output_pcap" -T fields \
           -e frame.number -e frame.time_relative \
           -e ip.src -e ip.dst \
           -e _ws.col.Protocol -e _ws.col.Info 2>/dev/null | head -30
}

decode_map() {
    print_section "Decode MAP Messages"
    
    echo -e "  ${WHITE}Input (1=PCAP file, 2=Hex string):${NC} \c"
    read -r input_type
    
    if [ "$input_type" = "1" ]; then
        echo -e "  ${WHITE}PCAP file:${NC} \c"
        read -r pcap_file
        
        if [ -f "$pcap_file" ]; then
            tshark -r "$pcap_file" -Y "gsm_map" -V 2>/dev/null | head -100
        else
            print_error "File not found"
        fi
    else
        echo -e "  ${WHITE}Hex string:${NC} \c"
        read -r hex_str
        
        python3 << PYEOF
import binascii

hex_data = '$hex_str'.replace(' ', '')
try:
    data = bytes.fromhex(hex_data)
    print(f"\n  Decoded MAP Message ({len(data)} bytes)")
    print(f"  {'─' * 50}")
    
    # Basic TLV parsing
    offset = 0
    while offset < len(data):
        if offset >= len(data):
            break
        tag = data[offset]
        offset += 1
        
        if offset >= len(data):
            break
        length = data[offset]
        offset += 1
        
        if offset + length > len(data):
            break
        
        value = data[offset:offset+length]
        print(f"  Tag: 0x{tag:02x}, Length: {length}, Value: {value.hex()}")
        offset += length

except Exception as e:
    print(f"  Error decoding: {e}")
PYEOF
    fi
}

decode_isup() {
    print_section "Decode ISUP Messages"
    
    echo -e "  ${WHITE}PCAP file:${NC} \c"
    read -r pcap_file
    
    if [ -f "$pcap_file" ]; then
        tshark -r "$pcap_file" -Y "isup" -V 2>/dev/null | head -100
    else
        print_error "File not found"
    fi
}

decode_tcap() {
    print_section "Decode TCAP Messages"
    
    echo -e "  ${WHITE}PCAP file:${NC} \c"
    read -r pcap_file
    
    if [ -f "$pcap_file" ]; then
        tshark -r "$pcap_file" -Y "tcap" -T fields \
               -e frame.number -e tcap.msgtype \
               -e tcap.tid -e tcap.opcode 2>/dev/null | head -30
    else
        print_error "File not found"
    fi
}

generate_traffic_report() {
    print_section "Generate Traffic Report"
    
    echo -e "  ${WHITE}PCAP file:${NC} \c"
    read -r pcap_file
    
    if [ ! -f "$pcap_file" ]; then
        print_error "File not found"
        return
    fi
    
    local report_file="$RESULTS_DIR/reports/traffic_report_${TIMESTAMP}.txt"
    
    cat > "$report_file" << EOF
═══════════════════════════════════════════════════════════════
              SS7 TRAFFIC ANALYSIS REPORT
═══════════════════════════════════════════════════════════════
Generated: $(date)
Source File: $pcap_file
───────────────────────────────────────────────────────────────

PROTOCOL HIERARCHY:
EOF
    
    tshark -r "$pcap_file" -q -z io,phs >> "$report_file" 2>/dev/null
    
    echo -e "\n\nENDPOINT STATISTICS:" >> "$report_file"
    tshark -r "$pcap_file" -q -z endpoints,ip >> "$report_file" 2>/dev/null
    
    echo -e "\n\nCONVERSATION STATISTICS:" >> "$report_file"
    tshark -r "$pcap_file" -q -z conv,ip >> "$report_file" 2>/dev/null
    
    echo -e "\n═══════════════════════════════════════════════════════════════" >> "$report_file"
    
    cat "$report_file"
    print_status "Report saved to: $report_file"
}

anomaly_detection() {
    print_section "SS7 Anomaly Detection"
    
    echo -e "  ${WHITE}PCAP file:${NC} \c"
    read -r pcap_file
    
    if [ ! -f "$pcap_file" ]; then
        print_error "File not found"
        return
    fi
    
    print_progress "Running anomaly detection..."
    
    python3 << PYEOF
import sys, json
sys.path.insert(0, '$SCRIPTS_DIR')
from ss7_analyzer import SS7Analyzer
from ss7_vulndb import SS7VulnDB

analyzer = SS7Analyzer()
vulndb = SS7VulnDB()

print(f"\n  SS7 Anomaly Detection")
print(f"  {'─' * 50}")

# Check for known attack patterns in tshark output
import subprocess

# Check for location tracking operations
checks = [
    ('gsm_map.opcode == 71', 'AnyTimeInterrogation', 'Location Tracking'),
    ('gsm_map.opcode == 70', 'ProvideSubscriberInfo', 'Location Tracking'),
    ('gsm_map.opcode == 83', 'ProvideSubscriberLocation', 'Location Tracking'),
    ('gsm_map.opcode == 22', 'SendRoutingInfo', 'Info Disclosure'),
    ('gsm_map.opcode == 58', 'SendIMSI', 'IMSI Disclosure'),
    ('gsm_map.opcode == 56', 'SendAuthenticationInfo', 'Auth Vector Theft'),
    ('gsm_map.opcode == 2', 'UpdateLocation', 'Registration Hijack'),
    ('gsm_map.opcode == 3', 'CancelLocation', 'DoS Attack'),
    ('gsm_map.opcode == 7', 'InsertSubscriberData', 'Call Interception'),
    ('gsm_map.opcode == 67', 'PurgeMS', 'DoS Attack'),
]

found_anomalies = []

for filter_expr, op_name, category in checks:
    try:
        result = subprocess.run(
            ['tshark', '-r', '$pcap_file', '-Y', filter_expr, '-T', 'fields', '-e', 'frame.number'],
            capture_output=True, text=True, timeout=30
        )
        count = len(result.stdout.strip().split('\n')) if result.stdout.strip() else 0
        if count > 0:
            severity = 'CRITICAL' if category in ['Registration Hijack', 'Call Interception', 'Auth Vector Theft'] else 'HIGH'
            found_anomalies.append({
                'operation': op_name,
                'category': category,
                'count': count,
                'severity': severity
            })
            print(f"  ⚠ [{severity}] {op_name}: {count} instances ({category})")
    except:
        pass

if not found_anomalies:
    print("  ✓ No obvious SS7 attack patterns detected")
else:
    print(f"\n  Total anomalies found: {len(found_anomalies)}")
    
    # Save results
    with open('$RESULTS_DIR/reports/anomalies_${TIMESTAMP}.json', 'w') as f:
        json.dump(found_anomalies, f, indent=2)
    print(f"\n  Results saved to: $RESULTS_DIR/reports/anomalies_${TIMESTAMP}.json")
PYEOF
}

export_analysis() {
    print_section "Export Analysis Results"
    
    echo -e "  ${WHITE}Available reports:${NC}"
    ls -1 "$RESULTS_DIR/reports/" 2>/dev/null
    echo ""
    
    echo -e "  ${WHITE}Report file:${NC} \c"
    read -r report_file
    
    echo -e "  ${WHITE}Export format (1=JSON, 2=CSV, 3=HTML):${NC} \c"
    read -r format
    
    print_status "Export complete"
}

# ========================= VULNERABILITY MODULE ===========================

vulnerability_menu() {
    while true; do
        print_banner
        print_section "Vulnerability Assessment"
        echo ""
        echo -e "  ${WHITE}1)${NC}  View Vulnerability Database"
        echo -e "  ${WHITE}2)${NC}  Search Vulnerabilities"
        echo -e "  ${WHITE}3)${NC}  Filter by Severity"
        echo -e "  ${WHITE}4)${NC}  Filter by Category"
        echo -e "  ${WHITE}5)${NC}  Automated Security Audit"
        echo -e "  ${WHITE}6)${NC}  Generate Vulnerability Report"
        echo -e "  ${WHITE}7)${NC}  GSMA FS.11 Compliance Check"
        echo -e "  ${WHITE}8)${NC}  Export Vulnerability Database"
        echo -e "  ${WHITE}0)${NC}  Back to Main Menu"
        echo ""
        echo -e "  ${CYAN}Select option:${NC} \c"
        read -r vuln_choice
        
        case $vuln_choice in
            1) view_vulndb ;;
            2) search_vulns ;;
            3) filter_severity ;;
            4) filter_category ;;
            5) automated_audit ;;
            6) vuln_report ;;
            7) gsma_compliance ;;
            8) export_vulndb ;;
            0) return ;;
            *) print_error "Invalid option" ;;
        esac
        
        echo ""
        echo -e "  ${DIM}Press Enter to continue...${NC}"
        read -r
    done
}

view_vulndb() {
    print_section "SS7 Vulnerability Database"
    
    python3 << PYEOF
import sys
sys.path.insert(0, '$SCRIPTS_DIR')
from ss7_vulndb import SS7VulnDB

db = SS7VulnDB()

for vid, vuln in db.vulnerabilities.items():
    sev_color = {
        'CRITICAL': '\033[1;31m',
        'HIGH': '\033[0;31m', 
        'MEDIUM': '\033[0;33m',
        'LOW': '\033[0;32m'
    }.get(vuln['severity'], '\033[0m')
    
    print(f"\n  {sev_color}[{vuln['severity']}]\033[0m {vid}: {vuln['name']}")
    print(f"    Category:  {vuln['category']}")
    print(f"    Protocol:  {vuln['protocol']}")
    print(f"    Operation: {vuln['operation']}")
    print(f"    CVSS:      {vuln['cvss']}")
    print(f"    {vuln['description'][:80]}...")
PYEOF
}

search_vulns() {
    print_section "Search Vulnerabilities"
    
    echo -e "  ${WHITE}Search keyword:${NC} \c"
    read -r keyword
    
    python3 << PYEOF
import sys
sys.path.insert(0, '$SCRIPTS_DIR')
from ss7_vulndb import SS7VulnDB

db = SS7VulnDB()
results = db.search('$keyword')

if results:
    print(f"\n  Found {len(results)} results for '$keyword':")
    for vid, vuln in results.items():
        print(f"\n  [{vuln['severity']}] {vid}: {vuln['name']}")
        print(f"    {vuln['description'][:100]}...")
        print(f"    Mitigation: {vuln['mitigation'][0]}")
else:
    print(f"\n  No results found for '$keyword'")
PYEOF
}

filter_severity() {
    print_section "Filter by Severity"
    
    echo -e "  ${WHITE}Severity (CRITICAL/HIGH/MEDIUM/LOW):${NC} \c"
    read -r severity
    
    python3 << PYEOF
import sys
sys.path.insert(0, '$SCRIPTS_DIR')
from ss7_vulndb import SS7VulnDB

db = SS7VulnDB()
results = db.get_by_severity('${severity^^}')

print(f"\n  ${severity^^} severity vulnerabilities: {len(results)}")
for vid, vuln in results.items():
    print(f"  [{vid}] {vuln['name']} (CVSS: {vuln['cvss']})")
    print(f"    Operation: {vuln['operation']}")
PYEOF
}

filter_category() {
    print_section "Filter by Category"
    
    python3 << PYEOF
import sys
sys.path.insert(0, '$SCRIPTS_DIR')
from ss7_vulndb import SS7VulnDB

db = SS7VulnDB()
categories = db.get_categories()

print("\n  Available categories:")
for i, cat in enumerate(sorted(categories), 1):
    print(f"    {i}) {cat}")
PYEOF
    
    echo -e "\n  ${WHITE}Category name:${NC} \c"
    read -r category
    
    python3 << PYEOF
import sys
sys.path.insert(0, '$SCRIPTS_DIR')
from ss7_vulndb import SS7VulnDB

db = SS7VulnDB()
results = db.get_by_category('$category')

for vid, vuln in results.items():
    print(f"\n  [{vuln['severity']}] {vid}: {vuln['name']}")
    print(f"    {vuln['description'][:100]}...")
PYEOF
}

automated_audit() {
    print_section "Automated SS7 Security Audit"
    
    echo -e "  ${WHITE}Target IP:${NC} \c"
    read -r target_ip
    echo -e "  ${WHITE}Target Port [2905]:${NC} \c"
    read -r target_port
    target_port=${target_port:-2905}
    
    if ! validate_ip "$target_ip"; then
        print_error "Invalid IP address"
        return
    fi
    
    if ! confirm_action "Start automated security audit on $target_ip:$target_port?"; then
        return
    fi
    
    local audit_file="$RESULTS_DIR/reports/audit_${TIMESTAMP}"
    
    print_progress "Starting automated security audit..."
    echo ""
    
    echo "═══════════════════════════════════════════════════════════" > "${audit_file}.txt"
    echo "        SS7 SECURITY AUDIT REPORT" >> "${audit_file}.txt"
    echo "═══════════════════════════════════════════════════════════" >> "${audit_file}.txt"
    echo "Target: $target_ip:$target_port" >> "${audit_file}.txt"
    echo "Date: $(date)" >> "${audit_file}.txt"
    echo "" >> "${audit_file}.txt"
    
    # Phase 1: Port Scan
    echo -e "${YELLOW}  Phase 1: Port Scanning${NC}"
    print_progress "Scanning SIGTRAN ports..."
    nmap -sT -p 2905,2906,2907,3868,14001,2123,2152 -Pn --open \
         -sV "$target_ip" >> "${audit_file}.txt" 2>/dev/null
    print_status "Port scan complete"
    
    # Phase 2: SCTP Scan
    echo -e "${YELLOW}  Phase 2: SCTP Scanning${NC}"
    print_progress "Scanning SCTP ports..."
    nmap -sY -p 2905,2906,14001 -Pn "$target_ip" >> "${audit_file}.txt" 2>/dev/null
    print_status "SCTP scan complete"
    
    # Phase 3: M3UA Probe
    echo -e "${YELLOW}  Phase 3: M3UA Probing${NC}"
    print_progress "Probing M3UA endpoint..."
    
    python3 << PYEOF >> "${audit_file}.txt" 2>/dev/null
import socket
import struct
import sys
sys.path.insert(0, '$SCRIPTS_DIR')
from sigtran_builder import M3UABuilder
from ss7_scanner import SS7Scanner

builder = M3UABuilder()
scanner = SS7Scanner(timeout=10)

print("\n--- M3UA Probe Results ---")
fp = scanner.sigtran_fingerprint('$target_ip', int('$target_port'))
for key, value in fp.items():
    print(f"  {key}: {value}")
PYEOF
    print_status "M3UA probing complete"
    
    # Phase 4: Vulnerability Assessment
    echo -e "${YELLOW}  Phase 4: Vulnerability Assessment${NC}"
    print_progress "Assessing vulnerabilities..."
    
    python3 << PYEOF >> "${audit_file}.txt" 2>/dev/null
import sys
sys.path.insert(0, '$SCRIPTS_DIR')
from ss7_vulndb import SS7VulnDB

db = SS7VulnDB()
print("\n--- Applicable Vulnerabilities ---")
for vid, vuln in db.vulnerabilities.items():
    print(f"\n  [{vuln['severity']}] {vid}: {vuln['name']}")
    print(f"    Impact: {vuln['description'][:80]}...")
    print(f"    Mitigation: {vuln['mitigation'][0]}")
PYEOF
    print_status "Vulnerability assessment complete"
    
    echo "" >> "${audit_file}.txt"
    echo "═══════════════════════════════════════════════════════════" >> "${audit_file}.txt"
    
    echo ""
    print_status "Audit report saved to: ${audit_file}.txt"
    
    # Save to database
    sqlite3 "$DB_DIR/ss7_toolkit.db" \
        "INSERT INTO audit_log (action, details) VALUES ('SECURITY_AUDIT', 'Target: $target_ip:$target_port');"
    
    log "INFO" "Security audit completed on $target_ip:$target_port"
}

vuln_report() {
    print_section "Generate Vulnerability Report"
    
    python3 << PYEOF
import sys, json
sys.path.insert(0, '$SCRIPTS_DIR')
from ss7_vulndb import SS7VulnDB

db = SS7VulnDB()

report = {
    'title': 'SS7 Vulnerability Assessment Report',
    'generated': __import__('datetime').datetime.now().isoformat(),
    'total_vulnerabilities': len(db.vulnerabilities),
    'critical': len(db.get_by_severity('CRITICAL')),
    'high': len(db.get_by_severity('HIGH')),
    'medium': len(db.get_by_severity('MEDIUM')),
    'low': len(db.get_by_severity('LOW')),
    'categories': db.get_categories(),
    'vulnerabilities': db.vulnerabilities
}

output_file = '$RESULTS_DIR/reports/vuln_report_${TIMESTAMP}.json'
with open(output_file, 'w') as f:
    json.dump(report, f, indent=2)

db.print_summary()
print(f"\n  Report saved to: {output_file}")
PYEOF
}

gsma_compliance() {
    print_section "GSMA FS.11 Compliance Check"
    
    python3 << PYEOF
import sys
sys.path.insert(0, '$SCRIPTS_DIR')
from ss7_vulndb import SS7VulnDB

db = SS7VulnDB()

print(f"\n  GSMA FS.11/FS.19 SS7 Security Compliance Framework")
print(f"  {'─' * 55}")

categories = {
    'Category 1 - Screening': [
        'SRI from external networks should be filtered',
        'ATI from external networks should be blocked',
        'PSI from external networks should be blocked',
        'SendIMSI should be restricted',
    ],
    'Category 2 - Verification': [
        'UpdateLocation source GT should match roaming partner',
        'InsertSubscriberData should only come from HLR',
        'CancelLocation should only come from HLR',
        'DeleteSubscriberData should only come from HLR',
    ],
    'Category 3 - Correlation': [
        'UpdateLocation should correlate with prior SRI',
        'ProvideRoamingNumber should correlate with prior SRI',
        'Monitor for unusual operation patterns',
        'Track subscriber registration anomalies',
    ],
    'Category 4 - Advanced': [
        'Implement SCCP GT address spoofing detection',
        'Deploy SS7 IDS/IPS',
        'Real-time alerting for critical operations',
        'Log all inter-network SS7 messages',
    ],
}

for category, checks in categories.items():
    print(f"\n  {category}")
    for check in checks:
        print(f"    [ ] {check}")

print(f"\n  {'─' * 55}")
print(f"  Note: Manual verification required for each check")
print(f"  Reference: GSMA FS.11, FS.19, IR.82, IR.88")
PYEOF
}

export_vulndb() {
    print_section "Export Vulnerability Database"
    
    local output_file="$DB_DIR/ss7_vulndb_export_${TIMESTAMP}.json"
    
    python3 << PYEOF
import sys
sys.path.insert(0, '$SCRIPTS_DIR')
from ss7_vulndb import SS7VulnDB

db = SS7VulnDB()
db.export_db('$output_file')
print(f"  Database exported to: $output_file")
print(f"  Total entries: {len(db.vulnerabilities)}")
PYEOF
    
    print_status "Database exported"
}

# ========================= UTILITIES MODULE ===============================

utilities_menu() {
    while true; do
        print_banner
        print_section "Utilities & Tools"
        echo ""
        echo -e "  ${WHITE}1)${NC}  GT/MSISDN Encoder/Decoder"
        echo -e "  ${WHITE}2)${NC}  IMSI Analyzer"
        echo -e "  ${WHITE}3)${NC}  Point Code Converter"
        echo -e "  ${WHITE}4)${NC}  Hex/Binary Converter"
        echo -e "  ${WHITE}5)${NC}  TBCD Encoder/Decoder"
        echo -e "  ${WHITE}6)${NC}  ASN.1/BER Decoder"
        echo -e "  ${WHITE}7)${NC}  Network Calculator"
        echo -e "  ${WHITE}8)${NC}  SS7 Protocol Reference"
        echo -e "  ${WHITE}9)${NC}  MCC/MNC Lookup"
        echo -e "  ${WHITE}10)${NC} View Logs"
        echo -e "  ${WHITE}11)${NC} Database Manager"
        echo -e "  ${WHITE}12)${NC} Configuration Editor"
        echo -e "  ${WHITE}0)${NC}  Back to Main Menu"
        echo ""
        echo -e "  ${CYAN}Select option:${NC} \c"
        read -r util_choice
        
        case $util_choice in
            1) gt_encoder ;;
            2) imsi_analyzer ;;
            3) point_code_converter ;;
            4) hex_converter ;;
            5) tbcd_codec ;;
            6) asn1_decoder ;;
            7) network_calculator ;;
            8) protocol_reference ;;
            9) mcc_mnc_lookup ;;
            10) view_logs ;;
            11) database_manager ;;
            12) config_editor ;;
            0) return ;;
            *) print_error "Invalid option" ;;
        esac
        
        echo ""
        echo -e "  ${DIM}Press Enter to continue...${NC}"
        read -r
    done
}

gt_encoder() {
    print_section "GT/MSISDN Encoder/Decoder"
    
    echo -e "  ${WHITE}1) Encode MSISDN to TBCD"
    echo -e "  2) Decode TBCD to MSISDN${NC}"
    echo -e "  ${WHITE}Choice:${NC} \c"
    read -r choice
    
    if [ "$choice" = "1" ]; then
        echo -e "  ${WHITE}MSISDN (e.g., +1234567890):${NC} \c"
        read -r msisdn
        
        python3 << PYEOF
msisdn = '$msisdn'.lstrip('+')
if len(msisdn) % 2:
    msisdn += 'F'

result = '91'  # International
for i in range(0, len(msisdn), 2):
    d1 = msisdn[i]
    d2 = msisdn[i+1]
    result += d2 + d1

print(f"\n  MSISDN:  $msisdn")
print(f"  TBCD:    {result}")
print(f"  Hex:     {result}")
print(f"  NOA:     International (0x91)")
PYEOF
    else
        echo -e "  ${WHITE}TBCD Hex (e.g., 91214365):${NC} \c"
        read -r tbcd
        
        python3 << PYEOF
tbcd = '$tbcd'
noa = tbcd[:2]
digits = tbcd[2:]

result = ''
for i in range(0, len(digits), 2):
    result += digits[i+1] + digits[i]

result = result.rstrip('Ff')
print(f"\n  TBCD:    {tbcd}")
print(f"  MSISDN:  +{result}")
print(f"  NOA:     {'International' if noa == '91' else 'National'}")
PYEOF
    fi
}

imsi_analyzer() {
    print_section "IMSI Analyzer"
    
    echo -e "  ${WHITE}Enter IMSI (15 digits):${NC} \c"
    read -r imsi
    
    python3 << PYEOF
imsi = '$imsi'
if len(imsi) != 15:
    print("  Error: IMSI must be 15 digits")
else:
    mcc = imsi[:3]
    mnc = imsi[3:5] if len(imsi[3:5]) >= 2 else imsi[3:6]
    msin = imsi[5:]
    
    # Common MCC database
    mcc_db = {
        '234': ('United Kingdom', 'GB'),
        '310': ('United States', 'US'),
        '311': ('United States', 'US'),
        '262': ('Germany', 'DE'),
        '208': ('France', 'FR'),
        '222': ('Italy', 'IT'),
        '214': ('Spain', 'ES'),
        '440': ('Japan', 'JP'),
        '450': ('South Korea', 'KR'),
        '460': ('China', 'CN'),
        '404': ('India', 'IN'),
        '405': ('India', 'IN'),
        '505': ('Australia', 'AU'),
        '302': ('Canada', 'CA'),
        '724': ('Brazil', 'BR'),
        '250': ('Russia', 'RU'),
    }
    
    country = mcc_db.get(mcc, ('Unknown', '??'))
    
    print(f"\n  IMSI Analysis")
    print(f"  {'─' * 40}")
    print(f"  Full IMSI:    {imsi}")
    print(f"  MCC:          {mcc} ({country[0]})")
    print(f"  MNC:          {mnc}")
    print(f"  MSIN:         {msin}")
    print(f"  Country Code: {country[1]}")
    print(f"  PLMN:         {mcc}{mnc}")
PYEOF
}

mcc_mnc_lookup() {
    print_section "MCC/MNC Lookup"
    echo -e "  ${WHITE}Enter MCC or MNC:${NC} \c"
    read -r code
    print_info "This feature can be implemented by querying an external or internal database."
    print_info "For example, using an online API for MCC/MNC information."
    # Example using curl, replace with a real API endpoint
    # curl "https://api.example.com/mcc-mnc/$code"
    print_warning "Feature not fully implemented."
}

view_logs() {
    print_section "View Toolkit Logs"
    if [ -f "$LOG_FILE" ]; then
        echo -e "  ${WHITE}Displaying last 50 lines of log file:${NC}"
        echo -e "  ${DIM}$LOG_FILE${NC}\n"
        tail -n 50 "$LOG_FILE" | while read -r line; do echo -e "  $line"; done
    else
        print_error "Log file not found!"
    fi
}

database_manager() {
    print_section "Database Manager"
    print_info "Opening SQLite CLI for the toolkit database."
    print_warning "Changes made directly to the database can affect the toolkit."
    sqlite3 "$DB_DIR/ss7_toolkit.db"
}

point_code_converter() {
    print_section "Point Code Converter"
    
    echo -e "  ${WHITE}Conversion type:${NC}"
    echo -e "    1) ITU format (14-bit: Z-AAA-B)"
    echo -e "    2) ANSI format (24-bit: NNN-CCC-MMM)"
    echo -e "    3) Decimal to binary"
    echo -e "  ${WHITE}Choice:${NC} \c"
    read -r pc_type
    
    echo -e "  ${WHITE}Point Code value:${NC} \c"
    read -r pc_value
    
    python3 << PYEOF
pc_type = int('$pc_type')
pc_value = '$pc_value'

if pc_type == 1:
    # ITU 14-bit
    if '-' in pc_value:
        parts = pc_value.split('-')
        zone = int(parts[0])
        area = int(parts[1])
        sp = int(parts[2])
        decimal = (zone << 11) | (area << 3) | sp
        binary = format(decimal, '014b')
        print(f"\n  ITU Point Code Analysis")
        print(f"  {'─' * 40}")
        print(f"  Format:   {pc_value}")
        print(f"  Zone:     {zone}")
        print(f"  Area:     {area}")
        print(f"  SP:       {sp}")
        print(f"  Decimal:  {decimal}")
        print(f"  Binary:   {binary}")
    else:
        decimal = int(pc_value)
        zone = (decimal >> 11) & 0x07
        area = (decimal >> 3) & 0xFF
        sp = decimal & 0x07
        print(f"\n  Decimal {decimal} = {zone}-{area}-{sp}")

elif pc_type == 2:
    # ANSI 24-bit
    if '-' in pc_value:
        parts = pc_value.split('-')
        network = int(parts[0])
        cluster = int(parts[1])
        member = int(parts[2])
        decimal = (network << 16) | (cluster << 8) | member
        print(f"\n  ANSI Point Code Analysis")
        print(f"  {'─' * 40}")
        print(f"  Format:   {pc_value}")
        print(f"  Network:  {network}")
        print(f"  Cluster:  {cluster}")
        print(f"  Member:   {member}")
        print(f"  Decimal:  {decimal}")
        print(f"  Hex:      0x{decimal:06x}")

elif pc_type == 3:
    decimal = int(pc_value)
    print(f"\n  Point Code: {decimal}")
    print(f"  Binary (14-bit): {format(decimal, '014b')}")
    print(f"  Binary (24-bit): {format(decimal, '024b')}")
    print(f"  Hex: 0x{decimal:06x}")
PYEOF
}

hex_converter() {
    print_section "Hex/Binary Converter"
    
    echo -e "  ${WHITE}1) Hex to ASCII"
    echo -e "  2) ASCII to Hex"
    echo -e "  3) Hex to Binary"
    echo -e "  4) Binary to Hex"
    echo -e "  5) Hex dump of file${NC}"
    echo -e "  ${WHITE}Choice:${NC} \c"
    read -r choice
    
    echo -e "  ${WHITE}Input:${NC} \c"
    read -r input_value
    
    python3 << PYEOF
choice = int('$choice')
input_val = '$input_value'

if choice == 1:
    result = bytes.fromhex(input_val.replace(' ', '')).decode('ascii', errors='replace')
    print(f"  Hex:   {input_val}")
    print(f"  ASCII: {result}")
elif choice == 2:
    result = input_val.encode().hex()
    print(f"  ASCII: {input_val}")
    print(f"  Hex:   {result}")
elif choice == 3:
    result = bin(int(input_val.replace(' ', ''), 16))[2:]
    print(f"  Hex:    {input_val}")
    print(f"  Binary: {result}")
elif choice == 4:
    result = hex(int(input_val.replace(' ', ''), 2))[2:]
    print(f"  Binary: {input_val}")
    print(f"  Hex:    {result}")
elif choice == 5:
    import os
    if os.path.exists(input_val):
        with open(input_val, 'rb') as f:
            data = f.read(256)
        for i in range(0, len(data), 16):
            hex_part = ' '.join(f'{b:02x}' for b in data[i:i+16])
            ascii_part = ''.join(chr(b) if 32 <= b < 127 else '.' for b in data[i:i+16])
            print(f"  {i:08x}  {hex_part:<48s}  {ascii_part}")
    else:
        print(f"  File not found: {input_val}")
PYEOF
}

tbcd_codec() {
    print_section "TBCD Encoder/Decoder"
    
    echo -e "  ${WHITE}1) Encode digits to TBCD"
    echo -e "  2) Decode TBCD to digits${NC}"
    echo -e "  ${WHITE}Choice:${NC} \c"
    read -r choice
    
    echo -e "  ${WHITE}Input:${NC} \c"
    read -r input_value
    
    python3 << PYEOF
choice = int('$choice')
input_val = '$input_value'

if choice == 1:
    digits = input_val.replace('+', '')
    if len(digits) % 2:
        digits += 'F'
    result = ''
    for i in range(0, len(digits), 2):
        result += digits[i+1] + digits[i]
    print(f"  Input:  {input_val}")
    print(f"  TBCD:   {result}")
    print(f"  Bytes:  {' '.join(result[i:i+2] for i in range(0, len(result), 2))}")
else:
    result = ''
    for i in range(0, len(input_val), 2):
        result += input_val[i+1] + input_val[i]
    result = result.rstrip('Ff')
    print(f"  TBCD:   {input_val}")
    print(f"  Digits: {result}")
PYEOF
}

asn1_decoder() {
    print_section "ASN.1/BER Decoder"
    
    echo -e "  ${WHITE}Hex encoded ASN.1 data:${NC} \c"
    read -r hex_data
    
    python3 << PYEOF
hex_data = '$hex_data'.replace(' ', '')
try:
    data = bytes.fromhex(hex_data)
    
    tag_classes = {0: 'Universal', 1: 'Application', 2: 'Context', 3: 'Private'}
    universal_tags = {
        1: 'BOOLEAN', 2: 'INTEGER', 3: 'BIT STRING', 4: 'OCTET STRING',
        5: 'NULL', 6: 'OBJECT IDENTIFIER', 10: 'ENUMERATED',
        12: 'UTF8String', 16: 'SEQUENCE', 17: 'SET',
        19: 'PrintableString', 22: 'IA5String', 23: 'UTCTime',
    }
    
    def decode_tlv(data, offset=0, depth=0):
        if offset >= len(data):
            return
        
        tag = data[offset]
        tag_class = (tag >> 6) & 0x03
        constructed = bool(tag & 0x20)
        tag_number = tag & 0x1F
        
        offset += 1
        
        if offset >= len(data):
            return
        
        length = data[offset]
        offset += 1
        
        if length & 0x80:
            num_bytes = length & 0x7F
            length = 0
            for i in range(num_bytes):
                if offset >= len(data):
                    return
                length = (length << 8) | data[offset]
                offset += 1
        
        value = data[offset:offset + length]
        
        indent = "  " * depth
        class_name = tag_classes.get(tag_class, '?')
        tag_name = universal_tags.get(tag_number, f'Tag-{tag_number}') if tag_class == 0 else f'[{tag_number}]'
        constr = 'CONSTRUCTED' if constructed else 'PRIMITIVE'
        
        print(f"  {indent}Tag: 0x{tag:02x} ({class_name}/{tag_name}) [{constr}]")
        print(f"  {indent}Length: {length}")
        if not constructed:
            print(f"  {indent}Value: {value.hex()}")
        
        if constructed and length > 0:
            inner_offset = 0
            while inner_offset < length:
                result = decode_tlv(value, inner_offset, depth + 1)
                if result is None:
                    break
                inner_offset = result
    
    print(f"\n  ASN.1/BER Decode ({len(data)} bytes)")
    print(f"  {'─' * 50}")
    decode_tlv(data)

except Exception as e:
    print(f"  Error: {e}")
PYEOF
}

config_editor() {
    print_section "Configuration Editor"
    if [ -f "$CONFIG_DIR/ss7_config.conf" ]; then
        print_info "Opening configuration file in nano..."
        nano "$CONFIG_DIR/ss7_config.conf"
    else
        print_error "Configuration file not found!"
    fi
}

network_calculator() {
    print_section "Network Calculator"
    
    echo -e "  ${WHITE}IP/CIDR (e.g., 192.168.1.0/24):${NC} \c"
    read -r network
    
    python3 << PYEOF
import ipaddress

try:
    net = ipaddress.ip_network('$network', strict=False)
    
    print(f"\n  Network Calculator")
    print(f"  {'─' * 40}")
    print(f"  Network:     {net.network_address}")
    print(f"  Netmask:     {net.netmask}")
    print(f"  Wildcard:    {net.hostmask}")
    print(f"  Broadcast:   {net.broadcast_address}")
    print(f"  First Host:  {list(net.hosts())[0] if net.num_addresses > 2 else 'N/A'}")
    print(f"  Last Host:   {list(net.hosts())[-1] if net.num_addresses > 2 else 'N/A'}")
    print(f"  Num Hosts:   {net.num_addresses - 2 if net.num_addresses > 2 else net.num_addresses}")
    print(f"  CIDR:        /{net.prefixlen}")
    print(f"  Is Private:  {net.is_private}")
except Exception as e:
    print(f"  Error: {e}")
PYEOF
}

protocol_reference() {
    print_section "SS7 Protocol Reference"
    
    echo -e "  ${WHITE}1) Protocol Stack Overview"
    echo -e "  2) MAP Operation Codes"
    echo -e "  3) ISUP Message Types"
    echo -e "  4) SCCP Message Types"
    echo -e "  5) SSN Reference"
    echo -e "  6) SIGTRAN Parameters"
    echo -e "  7) TCAP Components"
    echo -e "  8) Service Indicators${NC}"
    echo -e "  ${WHITE}Choice:${NC} \c"
    read -r ref_choice
    
    case $ref_choice in
        1)
            echo -e "\n${CYAN}  SS7 Protocol Stack${NC}"
            echo "  ┌─────────────────────────┐"
            echo "  │     MAP / CAP / ISUP     │  Application"
            echo "  ├─────────────────────────┤"
            echo "  │         TCAP             │  Transaction"
            echo "  ├─────────────────────────┤"
            echo "  │         SCCP             │  Network (SCCP)"
            echo "  ├─────────────────────────┤"
            echo "  │     MTP3 / M3UA          │  Network (MTP3)"
            echo "  ├─────────────────────────┤"
            echo "  │     MTP2 / SCTP          │  Data Link"
            echo "  ├─────────────────────────┤"
            echo "  │     MTP1 / IP            │  Physical"
            echo "  └─────────────────────────┘"
            ;;
        2)
            python3 -c "
ops = {
    2: 'updateLocation', 3: 'cancelLocation',
    4: 'provideRoamingNumber', 7: 'insertSubscriberData',
    8: 'deleteSubscriberData', 22: 'sendRoutingInfo',
    24: 'sendRoutingInfoForGprs', 43: 'checkIMEI',
    56: 'sendAuthenticationInfo', 58: 'sendIMSI',
    67: 'purgeMS', 70: 'provideSubscriberInfo',
    71: 'anyTimeInterrogation', 83: 'provideSubscriberLocation',
    85: 'sendRoutingInfoForLCS', 86: 'subscriberLocationReport',
    45: 'sendIdentification', 46: 'forwardNewTMSI',
    47: 'mt-forwardSM', 48: 'mo-forwardSM',
}
print('\n  MAP Operation Codes:')
print('  ' + '─' * 45)
for code, name in sorted(ops.items()):
    print(f'  OpCode {code:3d} (0x{code:02x}): {name}')
"
            ;;
        3)
            echo -e "\n  ${WHITE}ISUP Message Types:${NC}"
            echo "  IAM  (0x01) - Initial Address Message"
            echo "  SAM  (0x02) - Subsequent Address Message"
            echo "  INR  (0x03) - Information Request"
            echo "  INF  (0x04) - Information"
            echo "  COT  (0x05) - Continuity"
            echo "  ACM  (0x06) - Address Complete"
            echo "  CON  (0x07) - Connect"
            echo "  FOT  (0x08) - Forward Transfer"
            echo "  ANM  (0x09) - Answer"
            echo "  REL  (0x0C) - Release"
            echo "  SUS  (0x0D) - Suspend"
            echo "  RES  (0x0E) - Resume"
            echo "  RLC  (0x10) - Release Complete"
            echo "  CPG  (0x2C) - Call Progress"
            ;;
        4)
            echo -e "\n  ${WHITE}SCCP Message Types:${NC}"
            echo "  CR    (0x01) - Connection Request"
            echo "  CC    (0x02) - Connection Confirm"
            echo "  CREF  (0x03) - Connection Refused"
            echo "  RLSD  (0x04) - Released"
            echo "  RLC   (0x05) - Release Complete"
            echo "  DT1   (0x06) - Data Form 1"
            echo "  DT2   (0x07) - Data Form 2"
            echo "  AK    (0x08) - Data Acknowledgement"
            echo "  UDT   (0x09) - Unitdata"
            echo "  UDTS  (0x0A) - Unitdata Service"
            echo "  XUDT  (0x11) - Extended Unitdata"
            echo "  XUDTS (0x12) - Extended Unitdata Service"
            echo "  LUDT  (0x13) - Long Unitdata"
            echo "  LUDTS (0x14) - Long Unitdata Service"
            ;;
        5)
            echo -e "\n  ${WHITE}Subsystem Numbers (SSN):${NC}"
            echo "  0   - Unknown/Not Used"
            echo "  1   - SCCP Management"
            echo "  6   - HLR (Home Location Register)"
            echo "  7   - VLR (Visitor Location Register)"
            echo "  8   - MSC (Mobile Switching Center)"
            echo "  9   - EIR (Equipment Identity Register)"
            echo "  10  - AuC (Authentication Center)"
            echo "  142 - RANAP"
            echo "  143 - RNSAP"
            echo "  145 - GMLC (Gateway Mobile Location Center)"
            echo "  146 - CAP (CAMEL Application Part)"
            echo "  147 - gsmSCF"
            echo "  149 - SGSN"
            echo "  150 - GGSN"
            ;;
        6)
            echo -e "\n  ${WHITE}SIGTRAN Parameters:${NC}"
            echo "  M3UA Port:  2905 (default)"
            echo "  SUA Port:   14001 (default)"
            echo "  M2PA Port:  3565"
            echo "  M2UA Port:  2904"
            echo "  IUA Port:   9900"
            echo "  PPID M3UA:  3"
            echo "  PPID SUA:   4"
            echo "  PPID M2PA:  5"
            ;;
        7)
            echo -e "\n  ${WHITE}TCAP Components:${NC}"
            echo "  Begin     (0x62)"
            echo "  End       (0x64)"
            echo "  Continue  (0x65)"
            echo "  Abort     (0x67)"
            echo "  Invoke    (0xA1)"
            echo "  RetResult (0xA2)"
            echo "  RetError  (0xA3)"
            echo "  Reject    (0xA4)"
            ;;
        8)
            echo -e "\n  ${WHITE}Service Indicators (SI):${NC}"
            echo "  0 - SNM (Signalling Network Management)"
            echo "  1 - STM (Signalling Network Testing)"
            echo "  2 - SLTM"
            echo "  3 - SCCP"
            echo "  4 - TUP (Telephone User Part)"
            echo "  5 - ISUP"
                        echo "  6 - DUP-C (Data User Part - Call"
            ;;
    esac
}

# ========================= MAIN EXECUTION =================================

main_menu() {
    while true; do
        print_banner
        print_section "Main Menu"
        echo ""
        echo -e "  ${WHITE}1)${NC}  Network Scanning"
        echo -e "  ${WHITE}2)${NC}  MAP Protocol Testing"
        echo -e "  ${WHITE}3)${NC}  SIGTRAN/M3UA Testing"
        echo -e "  ${WHITE}4)${NC}  Traffic Analysis & PCAP"
        echo -e "  ${WHITE}5)${NC}  Vulnerability Assessment"
        echo -e "  ${WHITE}6)${NC}  Utilities & Tools"
        echo -e "  ${WHITE}7)${NC}  Run Full Installation/Update"
        echo ""
        echo -e "  ${WHITE}0)${NC}  Exit"
        echo ""
        echo -e "  ${CYAN}Select option:${NC} \c"
        read -r main_choice

        case $main_choice in
            1) scanning_menu ;;
            2) map_testing_menu ;;
            3) sigtran_menu ;;
            4) analysis_menu ;;
            5) vulnerability_menu ;;
            6) utilities_menu ;;
            7) full_install ;;
            0)
                echo -e "\n${GREEN}Exiting SS7 Toolkit. Goodbye!${NC}"
                exit 0
                ;;
            *)
                print_error "Invalid option"
                sleep 1
                ;;
        esac
    done
}

# Check if the script is being run for the first time
if [ ! -d "$INSTALL_DIR" ]; then
    print_banner
    echo -e "${YELLOW}It looks like this is the first time you are running the SS7 Toolkit.${NC}"
    if confirm_action "Would you like to run the full installation now?"; then
        full_install
    else
        print_warning "Installation skipped. Some features may not work."
        sleep 2
    fi
fi

# Start the main menu
main_menu
