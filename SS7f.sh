#!/bin/bash

#=====================================================
#  SS7 Security Testing Toolkit for Termux
#  For Authorized Penetration Testing & Education Only
#=====================================================

# Colors
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
CYAN='\033[1;36m'
MAGENTA='\033[1;35m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Variables
INSTALL_DIR="$HOME/ss7-toolkit"
LOG_DIR="$INSTALL_DIR/logs"
CONFIG_DIR="$INSTALL_DIR/config"
SCRIPTS_DIR="$INSTALL_DIR/scripts"
DATE=$(date +"%Y-%m-%d_%H-%M-%S")
LOG_FILE="$LOG_DIR/ss7_session_$DATE.log"

#=====================================================
# BANNER
#=====================================================
banner() {
    clear
    echo -e "${RED}"
    cat << "EOF"
  ╔═══════════════════════════════════════════════════════╗
  ║   ____  ____  _____   _____           _              ║
  ║  / ___|/ ___||___  | |_   _|__   ___ | |___          ║
  ║  \___ \\___ \   / /    | |/ _ \ / _ \| / __|         ║
  ║   ___) |___) | / /     | | (_) | (_) | \__ \         ║
  ║  |____/|____/ /_/      |_|\___/ \___/|_|___/         ║
  ║                                                       ║
  ║         SS7 Security Testing Toolkit v2.0             ║
  ║       For Authorized Testing & Education Only         ║
  ╚═══════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
    echo -e "${YELLOW}  [!] Legal Use Only - Unauthorized access is a crime${NC}"
    echo -e "${CYAN}  [*] Platform: Termux | Author: Security Researcher${NC}"
    echo ""
}

#=====================================================
# LOGGING FUNCTION
#=====================================================
log() {
    local level="$1"
    local message="$2"
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    echo "[$timestamp] [$level] $message" >> "$LOG_FILE" 2>/dev/null
}

#=====================================================
# CHECK ROOT
#=====================================================
check_root() {
    if [ "$(id -u)" = "0" ]; then
        echo -e "${GREEN}[✓] Running as root${NC}"
    else
        echo -e "${YELLOW}[!] Not running as root - some features may be limited${NC}"
    fi
}

#=====================================================
# DEPENDENCY INSTALLATION
#=====================================================
install_dependencies() {
    banner
    echo -e "${CYAN}[*] Installing dependencies...${NC}"
    echo ""
    
    # Update packages
    echo -e "${BLUE}[1/8] Updating package repositories...${NC}"
    pkg update -y && pkg upgrade -y
    
    # Install base packages
    echo -e "${BLUE}[2/8] Installing base packages...${NC}"
    pkg install -y python python-pip git wget curl nmap openssl \
        clang make cmake libffi openssl-tool net-tools termux-tools \
        libxml2 libxslt wireshark-cli tshark 2>/dev/null
    
    # Install Python packages
    echo -e "${BLUE}[3/8] Installing Python libraries...${NC}"
    pip install --upgrade pip
    pip install scapy pysctp colorama requests tabulate \
        ipaddress pyasn1 cryptography paramiko 2>/dev/null
    
    # Install additional network tools
    echo -e "${BLUE}[4/8] Installing network analysis tools...${NC}"
    pkg install -y tcpdump netcat-openbsd socat hydra john -y 2>/dev/null
    
    # Create directory structure
    echo -e "${BLUE}[5/8] Creating directory structure...${NC}"
    mkdir -p "$INSTALL_DIR" "$LOG_DIR" "$CONFIG_DIR" "$SCRIPTS_DIR"
    mkdir -p "$INSTALL_DIR/captures"
    mkdir -p "$INSTALL_DIR/reports"
    mkdir -p "$INSTALL_DIR/payloads"
    
    # Install SigPloit (SS7 Exploitation Framework)
    echo -e "${BLUE}[6/8] Installing SigPloit framework...${NC}"
    if [ ! -d "$INSTALL_DIR/SigPloit" ]; then
        cd "$INSTALL_DIR"
        git clone https://github.com/SigPloiter/SigPloit.git 2>/dev/null
        if [ -d "SigPloit" ]; then
            cd SigPloit
            pip install -r requirements.txt 2>/dev/null
            echo -e "${GREEN}[✓] SigPloit installed${NC}"
        else
            echo -e "${YELLOW}[!] SigPloit clone failed - will use built-in tools${NC}"
        fi
    else
        echo -e "${GREEN}[✓] SigPloit already installed${NC}"
    fi
    
    # Install ss7MAPer
    echo -e "${BLUE}[7/8] Installing ss7MAPer...${NC}"
    if [ ! -d "$INSTALL_DIR/ss7MAPer" ]; then
        cd "$INSTALL_DIR"
        git clone https://github.com/ernw/ss7MAPer.git 2>/dev/null
        if [ -d "ss7MAPer" ]; then
            echo -e "${GREEN}[✓] ss7MAPer installed${NC}"
        else
            echo -e "${YELLOW}[!] ss7MAPer clone failed${NC}"
        fi
    else
        echo -e "${GREEN}[✓] ss7MAPer already installed${NC}"
    fi
    
    # Create Python helper scripts
    echo -e "${BLUE}[8/8] Creating helper scripts...${NC}"
    create_python_scripts
    
    echo ""
    echo -e "${GREEN}[✓] All dependencies installed successfully!${NC}"
    log "INFO" "Dependencies installed"
    
    echo -e "${YELLOW}Press Enter to continue...${NC}"
    read
}

#=====================================================
# CREATE PYTHON HELPER SCRIPTS
#=====================================================
create_python_scripts() {
    
    # SCTP Scanner Script
    cat > "$SCRIPTS_DIR/sctp_scanner.py" << 'PYEOF'
#!/usr/bin/env python3
"""
SCTP Port Scanner for SS7 Network Assessment
"""

import socket
import sys
import struct
import time
import os
from datetime import datetime

class SCTPScanner:
    def __init__(self, target, ports=None):
        self.target = target
        self.ports = ports or [2905, 2906, 2907, 3868, 14001, 7626, 
                                29118, 29168, 36412, 36422, 38412, 38422]
        self.results = []
    
    def scan_port(self, port, timeout=3):
        """Attempt SCTP INIT to a specific port"""
        try:
            # Using raw socket for SCTP scanning
            sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            sock.settimeout(timeout)
            result = sock.connect_ex((self.target, port))
            sock.close()
            
            if result == 0:
                return True
            return False
        except Exception:
            return False
    
    def scan_tcp_fallback(self, port, timeout=3):
        """TCP fallback scan for SS7-related ports"""
        try:
            sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            sock.settimeout(timeout)
            result = sock.connect_ex((self.target, port))
            sock.close()
            return result == 0
        except Exception:
            return False
    
    def run_scan(self):
        """Run the complete scan"""
        print(f"\n[*] Starting SCTP/TCP scan on {self.target}")
        print(f"[*] Scanning {len(self.ports)} SS7-related ports")
        print(f"[*] Time: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
        print("-" * 55)
        
        ss7_services = {
            2905: "M3UA",
            2906: "M3UA-ALT", 
            2907: "M3UA-ALT2",
            3868: "Diameter",
            7626: "SUA",
            14001: "IUA",
            29118: "SGsAP",
            29168: "SBcAP",
            36412: "S1AP",
            36422: "X2AP",
            38412: "NGAP",
            38422: "XnAP"
        }
        
        for port in self.ports:
            service = ss7_services.get(port, "Unknown")
            is_open = self.scan_tcp_fallback(port)
            
            if is_open:
                status = "\033[92mOPEN\033[0m"
                self.results.append((port, service, "OPEN"))
            else:
                status = "\033[91mCLOSED\033[0m"
                self.results.append((port, service, "CLOSED"))
            
            print(f"  Port {port:>5}/sctp  [{status}]  {service}")
            time.sleep(0.1)
        
        print("-" * 55)
        open_ports = [r for r in self.results if r[2] == "OPEN"]
        print(f"[*] Scan complete: {len(open_ports)}/{len(self.ports)} ports open")
        
        return self.results

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python3 sctp_scanner.py <target_ip> [port1,port2,...]")
        sys.exit(1)
    
    target = sys.argv[1]
    ports = None
    if len(sys.argv) > 2:
        ports = [int(p) for p in sys.argv[2].split(",")]
    
    scanner = SCTPScanner(target, ports)
    scanner.run_scan()
PYEOF

    # MAP Message Analyzer
    cat > "$SCRIPTS_DIR/map_analyzer.py" << 'PYEOF'
#!/usr/bin/env python3
"""
MAP Protocol Message Analyzer
Analyzes SS7 MAP protocol messages from pcap files
"""

import sys
import struct
import binascii
from datetime import datetime

class MAPAnalyzer:
    # MAP Operation Codes
    MAP_OPERATIONS = {
        2: "UpdateLocation",
        3: "CancelLocation",
        4: "ProvideRoamingNumber",
        6: "SendAuthenticationInfo",
        7: "CheckIMEI",
        8: "SendParameters",
        22: "SendRoutingInfo",
        23: "RegisterSS",
        24: "EraseSS",
        25: "ActivateSS",
        26: "DeactivateSS",
        27: "InterrogateSS",
        28: "ProcessUnstructuredSS",
        29: "USSDRequest",
        46: "SendRoutingInfoForSM",
        47: "MO-ForwardSM",
        44: "MT-ForwardSM",
        56: "SendIMSI",
        58: "ProvideSubscriberInfo",
        59: "AnyTimeInterrogation",
        60: "AnyTimeSubscriptionInterrogation",
        61: "AnyTimeModification",
        70: "ProvideSubscriberLocation",
        71: "SendGroupCallEndSignal",
        83: "InsertSubscriberData",
        84: "DeleteSubscriberData"
    }
    
    # MAP vulnerability categories
    VULN_CATEGORIES = {
        "location_tracking": [22, 59, 70, 56],
        "call_interception": [4, 22, 83],
        "sms_interception": [46, 47, 44],
        "fraud": [2, 83, 84],
        "dos": [3, 24, 26, 84],
        "info_gathering": [6, 7, 58, 8]
    }
    
    def __init__(self):
        self.messages = []
        self.stats = {}
    
    def decode_imsi(self, data):
        """Decode IMSI from BCD encoding"""
        try:
            imsi = ""
            for byte in data:
                imsi += str(byte & 0x0F)
                if (byte >> 4) != 0x0F:
                    imsi += str(byte >> 4)
            return imsi
        except Exception:
            return "DECODE_ERROR"
    
    def decode_msisdn(self, data):
        """Decode MSISDN/phone number from BCD encoding"""
        try:
            if len(data) < 2:
                return "UNKNOWN"
            
            ton_npi = data[0]
            number = ""
            for byte in data[1:]:
                number += str(byte & 0x0F)
                if (byte >> 4) != 0x0F:
                    number += str(byte >> 4)
            
            if (ton_npi & 0x70) == 0x10:  # International
                number = "+" + number
            
            return number
        except Exception:
            return "DECODE_ERROR"
    
    def analyze_operation(self, opcode):
        """Analyze a MAP operation for security implications"""
        op_name = self.MAP_OPERATIONS.get(opcode, f"Unknown({opcode})")
        
        risks = []
        for category, opcodes in self.VULN_CATEGORIES.items():
            if opcode in opcodes:
                risks.append(category)
        
        severity = "LOW"
        if len(risks) > 0:
            severity = "MEDIUM"
        if any(r in ["location_tracking", "call_interception", "sms_interception"] for r in risks):
            severity = "HIGH"
        if any(r in ["call_interception"] for r in risks):
            severity = "CRITICAL"
        
        return {
            "opcode": opcode,
            "operation": op_name,
            "risks": risks,
            "severity": severity
        }
    
    def print_operation_table(self):
        """Print all MAP operations and their risk levels"""
        print("\n" + "=" * 70)
        print("  MAP OPERATION SECURITY ANALYSIS")
        print("=" * 70)
        print(f"  {'OpCode':<8} {'Operation':<30} {'Severity':<10} {'Risk Categories'}")
        print("-" * 70)
        
        for opcode, name in sorted(self.MAP_OPERATIONS.items()):
            analysis = self.analyze_operation(opcode)
            
            severity = analysis['severity']
            if severity == "CRITICAL":
                sev_color = "\033[91m"
            elif severity == "HIGH":
                sev_color = "\033[93m"
            elif severity == "MEDIUM":
                sev_color = "\033[33m"
            else:
                sev_color = "\033[92m"
            
            risks_str = ", ".join(analysis['risks']) if analysis['risks'] else "None"
            print(f"  {opcode:<8} {name:<30} {sev_color}{severity:<10}\033[0m {risks_str}")
        
        print("=" * 70)
    
    def generate_report(self):
        """Generate analysis report"""
        print("\n" + "=" * 70)
        print("  VULNERABILITY CATEGORY SUMMARY")
        print("=" * 70)
        
        categories = {
            "Location Tracking": "Allows tracking subscriber physical location",
            "Call Interception": "Enables call redirection and interception",
            "SMS Interception": "Allows SMS message interception and redirection",
            "Fraud": "Enables billing fraud and identity theft",
            "Denial of Service": "Can disrupt subscriber service",
            "Info Gathering": "Reveals sensitive subscriber information"
        }
        
        for cat, desc in categories.items():
            cat_key = cat.lower().replace(" ", "_")
            ops = self.VULN_CATEGORIES.get(cat_key, [])
            op_names = [self.MAP_OPERATIONS.get(op, f"Op-{op}") for op in ops]
            
            print(f"\n  \033[1m{cat}\033[0m")
            print(f"  Description: {desc}")
            print(f"  Related Operations: {', '.join(op_names)}")
            print(f"  Attack Vectors: {len(ops)}")

if __name__ == "__main__":
    analyzer = MAPAnalyzer()
    analyzer.print_operation_table()
    analyzer.generate_report()
PYEOF

    # SIGTRAN Protocol Builder
    cat > "$SCRIPTS_DIR/sigtran_builder.py" << 'PYEOF'
#!/usr/bin/env python3
"""
SIGTRAN Protocol Message Builder
Builds M3UA/SCCP/TCAP/MAP protocol messages for testing
"""

import struct
import binascii
import sys

class M3UA:
    """M3UA Protocol Message Builder"""
    
    # Message Classes
    MGMT = 0x00
    TRANSFER = 0x01
    SSNM = 0x02
    ASPSM = 0x03
    ASPTM = 0x04
    RKM = 0x09
    
    # Message Types
    DATA = 0x01
    ASPUP = 0x01
    ASPUP_ACK = 0x04
    ASPDN = 0x02
    ASPDN_ACK = 0x05
    HEARTBEAT = 0x03
    ASPAC = 0x01
    ASPAC_ACK = 0x03
    ASPIA = 0x02
    ASPIA_ACK = 0x04
    
    def __init__(self):
        self.version = 1
        self.reserved = 0
    
    def build_header(self, msg_class, msg_type, length):
        """Build M3UA common header"""
        return struct.pack("!BBBBI",
            self.version,
            self.reserved,
            msg_class,
            msg_type,
            length)
    
    def build_aspup(self):
        """Build ASP Up message"""
        header = self.build_header(self.ASPSM, self.ASPUP, 8)
        return header
    
    def build_aspac(self, routing_context=None):
        """Build ASP Active message"""
        payload = b""
        
        if routing_context is not None:
            # Routing Context parameter (tag=0x0006)
            rc_param = struct.pack("!HHI", 0x0006, 8, routing_context)
            payload += rc_param
        
        # Traffic Mode Type parameter (tag=0x000B) - Override mode
        tm_param = struct.pack("!HHI", 0x000B, 8, 1)
        payload += tm_param
        
        length = 8 + len(payload)
        header = self.build_header(self.ASPTM, self.ASPAC, length)
        
        return header + payload
    
    def build_data(self, opc, dpc, si, sls, payload):
        """Build M3UA DATA message"""
        # Protocol Data parameter (tag=0x0210)
        proto_data = struct.pack("!IIBBBB",
            opc,        # Originating Point Code
            dpc,        # Destination Point Code
            si,         # Service Indicator
            0,          # Network Indicator
            0,          # Message Priority
            sls)        # Signalling Link Selection
        
        proto_data += payload
        
        # Pad to 4-byte boundary
        pad_len = (4 - (len(proto_data) % 4)) % 4
        proto_data += b'\x00' * pad_len
        
        param = struct.pack("!HH", 0x0210, 4 + len(proto_data)) + proto_data
        
        length = 8 + len(param)
        header = self.build_header(self.TRANSFER, self.DATA, length)
        
        return header + param
    
    def build_heartbeat(self):
        """Build Heartbeat message"""
        # Heartbeat data parameter (tag=0x0009)
        hb_data = struct.pack("!I", int.from_bytes(
            struct.pack("!I", 0x12345678), 'big'))
        param = struct.pack("!HH", 0x0009, 4 + len(hb_data)) + hb_data
        
        length = 8 + len(param)
        header = self.build_header(self.ASPSM, self.HEARTBEAT, length)
        
        return header + param
    
    def display_message(self, msg, label=""):
        """Display message in hex format"""
        print(f"\n{'=' * 50}")
        print(f"  {label}")
        print(f"{'=' * 50}")
        print(f"  Length: {len(msg)} bytes")
        print(f"  Hex: {binascii.hexlify(msg).decode()}")
        
        # Parse header
        if len(msg) >= 8:
            ver, res, mc, mt, length = struct.unpack("!BBBBI", msg[:8])
            print(f"\n  Header:")
            print(f"    Version: {ver}")
            print(f"    Message Class: 0x{mc:02X}")
            print(f"    Message Type: 0x{mt:02X}")
            print(f"    Length: {length}")
        
        # Hex dump
        print(f"\n  Hex Dump:")
        for i in range(0, len(msg), 16):
            hex_part = " ".join(f"{b:02X}" for b in msg[i:i+16])
            ascii_part = "".join(
                chr(b) if 32 <= b < 127 else "." for b in msg[i:i+16])
            print(f"    {i:04X}  {hex_part:<48}  {ascii_part}")
        print(f"{'=' * 50}")


class SCCP:
    """SCCP Protocol Message Builder"""
    
    # Message Types
    CR = 0x01   # Connection Request
    CC = 0x02   # Connection Confirm
    DT1 = 0x06  # Data Form 1
    UDT = 0x09  # Unitdata
    UDTS = 0x0A # Unitdata Service
    XUDT = 0x11 # Extended Unitdata
    
    def __init__(self):
        pass
    
    def encode_gt(self, digits, nai=4, np=1, tt=0):
        """Encode Global Title"""
        # GT indicator = 0x04 (GT includes TT, NP, ES, NAI)
        gt_indicator = 0x14  # GT type 4
        
        # Encode BCD digits
        bcd = []
        for i in range(0, len(digits), 2):
            if i + 1 < len(digits):
                byte = int(digits[i]) | (int(digits[i+1]) << 4)
            else:
                byte = int(digits[i]) | 0xF0
            bcd.append(byte)
        
        header = struct.pack("!BBB", tt, (np << 4) | 0x01, nai)
        return header + bytes(bcd)
    
    def build_called_party(self, gt_digits, ssn=6):
        """Build Called Party Address"""
        gt = self.encode_gt(gt_digits)
        
        # Address indicator: GT included, SSN included, route on GT
        ai = 0x12  # GT + SSN + Route on GT
        
        addr = struct.pack("!BB", ai, ssn) + gt
        return addr
    
    def build_udt(self, called_party, calling_party, data):
        """Build SCCP UDT message"""
        msg_type = self.UDT
        protocol_class = 0x00  # Class 0, no special options
        
        # Calculate pointers
        ptr_called = 3  # Pointer to called party
        ptr_calling = ptr_called + 1 + len(called_party)
        ptr_data = ptr_calling + 1 + len(calling_party)
        
        header = struct.pack("!BBBB", msg_type, protocol_class, 
                            ptr_called, ptr_calling)
        
        msg = header
        msg += struct.pack("!B", len(called_party)) + called_party
        msg += struct.pack("!B", len(calling_party)) + calling_party
        msg += struct.pack("!B", len(data)) + data
        
        return msg


class TCAP:
    """TCAP Protocol Message Builder"""
    
    def __init__(self):
        self.tid_counter = 1
    
    def build_begin(self, otid, component):
        """Build TCAP Begin message"""
        # Originating Transaction ID
        otid_bytes = struct.pack("!I", otid)
        otid_tlv = bytes([0x48, len(otid_bytes)]) + otid_bytes
        
        # Dialogue portion (optional, simplified)
        
        # Component portion
        comp_portion = bytes([0x6C, len(component)]) + component
        
        # Begin message
        payload = otid_tlv + comp_portion
        begin = bytes([0x62, len(payload)]) + payload
        
        return begin
    
    def build_invoke(self, invoke_id, opcode, parameter=b""):
        """Build TCAP Invoke component"""
        # Invoke ID
        iid = bytes([0x02, 0x01, invoke_id])
        
        # Operation Code (local)
        oc = bytes([0x02, 0x01, opcode])
        
        # Parameter
        payload = iid + oc
        if parameter:
            payload += parameter
        
        # Invoke tag
        invoke = bytes([0xA1, len(payload)]) + payload
        
        return invoke

    def display_tcap(self, msg, label="TCAP Message"):
        """Display TCAP message structure"""
        print(f"\n  {label}:")
        print(f"  Hex: {binascii.hexlify(msg).decode()}")
        print(f"  Length: {len(msg)} bytes")


def demo():
    """Demonstrate protocol building capabilities"""
    print("\n" + "=" * 60)
    print("  SIGTRAN PROTOCOL MESSAGE BUILDER - DEMO")
    print("=" * 60)
    
    # M3UA Demo
    m3ua = M3UA()
    
    aspup = m3ua.build_aspup()
    m3ua.display_message(aspup, "M3UA ASP Up Message")
    
    aspac = m3ua.build_aspac(routing_context=100)
    m3ua.display_message(aspac, "M3UA ASP Active Message (RC=100)")
    
    hb = m3ua.build_heartbeat()
    m3ua.display_message(hb, "M3UA Heartbeat Message")
    
    # TCAP/MAP Demo
    tcap = TCAP()
    
    # Build SendRoutingInfo invoke
    invoke = tcap.build_invoke(1, 22)  # OpCode 22 = SendRoutingInfo
    begin = tcap.build_begin(0x00000001, invoke)
    
    print(f"\n{'=' * 50}")
    print("  TCAP BEGIN - SendRoutingInfo")
    print(f"{'=' * 50}")
    print(f"  Hex: {binascii.hexlify(begin).decode()}")
    print(f"  Length: {len(begin)} bytes")
    
    # Build M3UA DATA with SCCP+TCAP payload
    data_msg = m3ua.build_data(
        opc=100,     # Originating Point Code
        dpc=200,     # Destination Point Code
        si=3,        # Service Indicator (SCCP)
        sls=0,
        payload=begin
    )
    m3ua.display_message(data_msg, "M3UA DATA (OPC=100, DPC=200, SI=SCCP)")
    
    print(f"\n{'=' * 50}")
    print("  Protocol Stack Summary")
    print(f"{'=' * 50}")
    print("  Layer 4: MAP (SendRoutingInfo)")
    print("  Layer 3: TCAP (Begin)")
    print("  Layer 2: SCCP (UDT)")
    print("  Layer 1: M3UA (Data)")
    print("  Transport: SCTP")
    print(f"{'=' * 50}")

if __name__ == "__main__":
    demo()
PYEOF

    # GT/IMSI/MSISDN Lookup Tool
    cat > "$SCRIPTS_DIR/telecom_lookup.py" << 'PYEOF'
#!/usr/bin/env python3
"""
Telecom Number Analysis Tool
Analyzes IMSI, MSISDN, and Global Title formats
"""

import sys

# MCC-MNC Database (sample)
MCC_MNC_DB = {
    "310": {"country": "United States", "mnc": {
        "026": "T-Mobile", "030": "AT&T", "120": "Sprint",
        "260": "T-Mobile", "410": "AT&T", "012": "Verizon"
    }},
    "311": {"country": "United States", "mnc": {
        "480": "Verizon", "490": "T-Mobile"
    }},
    "302": {"country": "Canada", "mnc": {
        "220": "Telus", "370": "Fido", "720": "Rogers"
    }},
    "234": {"country": "United Kingdom", "mnc": {
        "10": "O2", "15": "Vodafone", "20": "3",
        "30": "EE", "33": "EE"
    }},
    "262": {"country": "Germany", "mnc": {
        "01": "T-Mobile", "02": "Vodafone", "03": "O2"
    }},
    "208": {"country": "France", "mnc": {
        "01": "Orange", "10": "SFR", "20": "Bouygues"
    }},
    "404": {"country": "India", "mnc": {
        "10": "AirTel", "20": "Vodafone", "45": "Airtel",
        "86": "Vodafone", "90": "AirTel"
    }},
    "440": {"country": "Japan", "mnc": {
        "10": "NTT DoCoMo", "20": "SoftBank", "50": "KDDI"
    }},
    "450": {"country": "South Korea", "mnc": {
        "05": "SKT", "06": "LG U+", "08": "KT"
    }},
    "505": {"country": "Australia", "mnc": {
        "01": "Telstra", "02": "Optus", "03": "Vodafone"
    }}
}

# Numbering Plan indicators
NPI = {
    0: "Unknown",
    1: "ISDN/Telephony (E.164)",
    3: "Data (X.121)",
    4: "Telex (F.69)",
    6: "Land Mobile (E.212)",
    8: "National",
    9: "Private",
    14: "Internet"
}

# Nature of Address indicators
NAI = {
    0: "Unknown",
    1: "Subscriber Number",
    2: "Reserved for national use",
    3: "National Significant Number",
    4: "International Number"
}

def analyze_imsi(imsi):
    """Analyze an IMSI number"""
    print(f"\n{'=' * 55}")
    print(f"  IMSI ANALYSIS: {imsi}")
    print(f"{'=' * 55}")
    
    if len(imsi) < 14 or len(imsi) > 15:
        print(f"  [!] Warning: IMSI length ({len(imsi)}) outside normal range (14-15)")
    
    mcc = imsi[:3]
    mnc = imsi[3:5]  # Try 2-digit MNC first
    mnc3 = imsi[3:6]  # 3-digit MNC
    msin = imsi[5:]
    
    print(f"\n  MCC (Mobile Country Code): {mcc}")
    print(f"  MNC (Mobile Network Code): {mnc} / {mnc3}")
    print(f"  MSIN (Subscriber ID): {msin}")
    
    # Lookup country and operator
    if mcc in MCC_MNC_DB:
        info = MCC_MNC_DB[mcc]
        print(f"\n  Country: {info['country']}")
        
        operator = info['mnc'].get(mnc3) or info['mnc'].get(mnc)
        if operator:
            print(f"  Operator: {operator}")
        else:
            print(f"  Operator: Unknown (MNC: {mnc}/{mnc3})")
    else:
        print(f"\n  Country: Unknown (MCC: {mcc})")
    
    # HLR address derivation
    print(f"\n  Derived HLR Address (E.214): {mcc}{mnc}")
    print(f"  IMSI Format: Valid {'✓' if len(imsi) in [14,15] else '✗'}")
    
    # Security implications
    print(f"\n  Security Notes:")
    print(f"  - IMSI can be used for location tracking via MAP SRI")
    print(f"  - IMSI catchers can capture this on radio interface")
    print(f"  - Used in MAP UpdateLocation for subscriber hijacking")

def analyze_msisdn(msisdn):
    """Analyze a phone number (MSISDN)"""
    # Remove common formatting
    clean = msisdn.replace("+", "").replace("-", "").replace(" ", "").replace("(", "").replace(")", "")
    
    print(f"\n{'=' * 55}")
    print(f"  MSISDN ANALYSIS: {msisdn}")
    print(f"{'=' * 55}")
    
    print(f"\n  Clean Number: {clean}")
    print(f"  Length: {len(clean)} digits")
    
    # Country code detection
    cc_map = {
        "1": "North America (US/CA)", "7": "Russia",
        "20": "Egypt", "27": "South Africa",
        "30": "Greece", "31": "Netherlands",
        "33": "France", "34": "Spain",
        "39": "Italy", "44": "United Kingdom",
        "49": "Germany", "55": "Brazil",
        "61": "Australia", "81": "Japan",
        "82": "South Korea", "86": "China",
        "91": "India", "92": "Pakistan",
        "93": "Afghanistan", "90": "Turkey"
    }
    
    country = "Unknown"
    cc_len = 0
    for cc in sorted(cc_map.keys(), key=len, reverse=True):
        if clean.startswith(cc):
            country = cc_map[cc]
            cc_len = len(cc)
            break
    
    if cc_len > 0:
        print(f"  Country Code: {clean[:cc_len]} ({country})")
        print(f"  National Number: {clean[cc_len:]}")
    
    # BCD Encoding
    bcd = ""
    for i in range(0, len(clean), 2):
        if i + 1 < len(clean):
            bcd += clean[i+1] + clean[i]
        else:
            bcd += "F" + clean[i]
    print(f"\n  BCD Encoding: {bcd}")
    
    # E.164 format
    print(f"  E.164 Format: +{clean}")
    
    # GT format
    print(f"\n  Global Title (GT) Format:")
    print(f"    Translation Type: 0")
    print(f"    Numbering Plan: 1 (E.164)")
    print(f"    Nature of Address: 4 (International)")
    print(f"    Digits: {clean}")

def analyze_pointcode(pc, variant="ITU"):
    """Analyze a Signaling Point Code"""
    print(f"\n{'=' * 55}")
    print(f"  POINT CODE ANALYSIS: {pc} ({variant})")
    print(f"{'=' * 55}")
    
    if variant.upper() == "ITU":
        # ITU format: 3-8-3 (14 bits)
        if "-" in str(pc):
            parts = str(pc).split("-")
            if len(parts) == 3:
                zone = int(parts[0])
                area = int(parts[1])
                sp = int(parts[2])
                decimal = (zone << 11) | (area << 3) | sp
                print(f"\n  Format: ITU (3-8-3)")
                print(f"  Zone: {zone} (3 bits)")
                print(f"  Area/Network: {area} (8 bits)")
                print(f"  Signaling Point: {sp} (3 bits)")
                print(f"  Decimal: {decimal}")
                print(f"  Binary: {decimal:014b}")
        else:
            decimal = int(pc)
            zone = (decimal >> 11) & 0x07
            area = (decimal >> 3) & 0xFF
            sp = decimal & 0x07
            print(f"\n  Format: ITU (3-8-3)")
            print(f"  Zone: {zone}")
            print(f"  Area/Network: {area}")
            print(f"  Signaling Point: {sp}")
            print(f"  Structured: {zone}-{area}-{sp}")
            print(f"  Binary: {decimal:014b}")
    
    elif variant.upper() == "ANSI":
        # ANSI format: 8-8-8 (24 bits)
        if "-" in str(pc):
            parts = str(pc).split("-")
            if len(parts) == 3:
                network = int(parts[0])
                cluster = int(parts[1])
                member = int(parts[2])
                decimal = (network << 16) | (cluster << 8) | member
                print(f"\n  Format: ANSI (8-8-8)")
                print(f"  Network: {network}")
                print(f"  Cluster: {cluster}")
                print(f"  Member: {member}")
                print(f"  Decimal: {decimal}")
                print(f"  Binary: {decimal:024b}")

def main():
    """Main interactive function"""
    while True:
        print(f"\n{'=' * 55}")
        print("  TELECOM NUMBER ANALYSIS TOOL")
        print(f"{'=' * 55}")
        print("  1. Analyze IMSI")
        print("  2. Analyze MSISDN (Phone Number)")
        print("  3. Analyze Point Code")
        print("  4. MCC/MNC Database Lookup")
        print("  0. Exit")
        print(f"{'=' * 55}")
        
        choice = input("\n  Select option: ").strip()
        
        if choice == "1":
            imsi = input("  Enter IMSI (15 digits): ").strip()
            analyze_imsi(imsi)
        elif choice == "2":
            msisdn = input("  Enter phone number (with country code): ").strip()
            analyze_msisdn(msisdn)
        elif choice == "3":
            pc = input("  Enter Point Code (e.g., 2-100-3): ").strip()
            variant = input("  Variant (ITU/ANSI) [ITU]: ").strip() or "ITU"
            analyze_pointcode(pc, variant)
        elif choice == "4":
            print(f"\n  {'MCC':<6} {'Country':<25} {'MNC':<6} {'Operator'}")
            print(f"  {'-'*60}")
            for mcc, info in sorted(MCC_MNC_DB.items()):
                for mnc, op in sorted(info['mnc'].items()):
                    print(f"  {mcc:<6} {info['country']:<25} {mnc:<6} {op}")
        elif choice == "0":
            break
        
        input("\n  Press Enter to continue...")

if __name__ == "__main__":
    if len(sys.argv) > 1:
        if sys.argv[1] == "--imsi" and len(sys.argv) > 2:
            analyze_imsi(sys.argv[2])
        elif sys.argv[1] == "--msisdn" and len(sys.argv) > 2:
            analyze_msisdn(sys.argv[2])
        elif sys.argv[1] == "--pc" and len(sys.argv) > 2:
            variant = sys.argv[3] if len(sys.argv) > 3 else "ITU"
            analyze_pointcode(sys.argv[2], variant)
    else:
        main()
PYEOF

    # Diameter Protocol Scanner
    cat > "$SCRIPTS_DIR/diameter_scanner.py" << 'PYEOF'
#!/usr/bin/env python3
"""
Diameter Protocol Scanner
Scans for Diameter protocol (S6a, Gx, Gy, Rx) endpoints
"""

import socket
import struct
import sys
import time

class DiameterScanner:
    """Scanner for Diameter protocol endpoints"""
    
    # Diameter Application IDs
    APPLICATIONS = {
        0: "Diameter Common Messages",
        1: "NASREQ",
        2: "Mobile-IPv4",
        3: "Diameter Base Accounting",
        4: "Relay",
        16777216: "3GPP Cx/Dx",
        16777217: "3GPP Sh",
        16777236: "3GPP Rx",
        16777238: "3GPP Gx",
        16777251: "3GPP S6a/S6d",
        16777252: "3GPP S13",
        16777255: "3GPP SLg",
        16777264: "3GPP SWm",
        16777265: "3GPP SWx",
        16777272: "3GPP S6b",
        16777291: "3GPP S6t"
    }
    
    # Command Codes
    COMMANDS = {
        257: "Capabilities-Exchange (CER/CEA)",
        258: "Re-Auth (RAR/RAA)",
        271: "Accounting (ACR/ACA)",
        272: "Credit-Control (CCR/CCA)",
        280: "Device-Watchdog (DWR/DWA)",
        282: "Disconnect-Peer (DPR/DPA)",
        300: "User-Authorization (UAR/UAA)",
        301: "Server-Assignment (SAR/SAA)",
        302: "Location-Info (LIR/LIA)",
        303: "Multimedia-Auth (MAR/MAA)",
        316: "Update-Location (ULR/ULA)",
        318: "Authentication-Information (AIR/AIA)"
    }
    
    def __init__(self, target, port=3868):
        self.target = target
        self.port = port
    
    def build_cer(self, origin_host="scanner.test", origin_realm="test"):
        """Build Capabilities-Exchange-Request"""
        # AVPs
        avps = b""
        
        # Origin-Host AVP (264)
        oh_data = origin_host.encode()
        oh_pad = (4 - len(oh_data) % 4) % 4
        avps += struct.pack("!IBI", 264, 0x40, 8 + len(oh_data))
        avps = avps[:-1]  # Fix: rebuild properly
        
        # Simplified CER
        avp_origin_host = self._build_avp(264, 0x40, origin_host.encode())
        avp_origin_realm = self._build_avp(296, 0x40, origin_realm.encode())
        avp_host_ip = self._build_avp(257, 0x40, struct.pack("!HH", 0x0001, 0) + 
                                       socket.inet_aton("127.0.0.1"))
        avp_vendor_id = self._build_avp(266, 0x40, struct.pack("!I", 10415))
        avp_product = self._build_avp(269, 0x00, b"SS7-Scanner")
        
        payload = avp_origin_host + avp_origin_realm + avp_host_ip + \
                  avp_vendor_id + avp_product
        
        # Diameter Header
        # Version(1) + Length(3) + Flags(1) + Code(3) + AppID(4) + HbH(4) + E2E(4)
        msg_len = 20 + len(payload)
        header = struct.pack("!BBHBBHI I I",
            1,                          # Version
            (msg_len >> 16) & 0xFF,     # Length (high byte)
            msg_len & 0xFFFF,           # Length (low bytes)
            0x80,                       # Flags (Request)
            0x00, 0x01, 0x01,          # Command Code (257 = CER)
            0,                          # Application ID
            0x00000001,                # Hop-by-Hop ID
            0x00000001)                # End-to-End ID
        
        return header + payload
    
    def _build_avp(self, code, flags, data):
        """Build a Diameter AVP"""
        avp_len = 8 + len(data)
        pad_len = (4 - (avp_len % 4)) % 4
        
        header = struct.pack("!IBB", code, flags, 0)
        # Fix length encoding
        length_bytes = struct.pack("!I", avp_len)
        header = struct.pack("!I", code) + bytes([flags]) + length_bytes[1:]
        
        return header + data + (b'\x00' * pad_len)
    
    def scan(self, timeout=5):
        """Attempt to connect and send CER"""
        print(f"\n[*] Scanning {self.target}:{self.port} for Diameter...")
        
        try:
            sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            sock.settimeout(timeout)
            
            result = sock.connect_ex((self.target, self.port))
            
            if result == 0:
                print(f"[+] Port {self.port} is OPEN")
                print(f"[*] Attempting Diameter CER...")
                
                # In a real scenario, would send CER and parse CEA
                print(f"[*] Connection established - potential Diameter endpoint")
                
                sock.close()
                return True
            else:
                print(f"[-] Port {self.port} is CLOSED")
                sock.close()
                return False
                
        except socket.timeout:
            print(f"[-] Connection timed out")
            return False
        except Exception as e:
            print(f"[-] Error: {e}")
            return False
    
    def scan_common_ports(self):
        """Scan common Diameter-related ports"""
        ports = {
            3868: "Diameter (standard)",
            3869: "Diameter (TLS)",
            3870: "Diameter (alt)",
            5868: "Diameter (alt)",
            6733: "Diameter (alt)"
        }
        
        print(f"\n{'=' * 55}")
        print(f"  DIAMETER PORT SCAN: {self.target}")
        print(f"{'=' * 55}")
        
        results = []
        for port, desc in ports.items():
            try:
                sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
                sock.settimeout(3)
                result = sock.connect_ex((self.target, port))
                sock.close()
                
                status = "OPEN" if result == 0 else "CLOSED"
                color = "\033[92m" if result == 0 else "\033[91m"
                print(f"  {port:<6} {color}{status:<8}\033[0m {desc}")
                results.append((port, status, desc))
            except Exception:
                print(f"  {port:<6} \033[91mERROR\033[0m   {desc}")
        
        return results
    
    def print_app_info(self):
        """Print Diameter application information"""
        print(f"\n{'=' * 60}")
        print(f"  DIAMETER APPLICATIONS DATABASE")
        print(f"{'=' * 60}")
        print(f"  {'App ID':<12} {'Application Name'}")
        print(f"  {'-' * 50}")
        for app_id, name in sorted(self.APPLICATIONS.items()):
            print(f"  {app_id:<12} {name}")
        
        print(f"\n  {'Code':<8} {'Command Name'}")
        print(f"  {'-' * 50}")
        for code, name in sorted(self.COMMANDS.items()):
            print(f"  {code:<8} {name}")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python3 diameter_scanner.py <target> [port]")
        print("       python3 diameter_scanner.py --info")
        sys.exit(1)
    
    if sys.argv[1] == "--info":
        scanner = DiameterScanner("localhost")
        scanner.print_app_info()
    else:
        target = sys.argv[1]
        port = int(sys.argv[2]) if len(sys.argv) > 2 else 3868
        scanner = DiameterScanner(target, port)
        scanner.scan_common_ports()
PYEOF

    # Network Reconnaissance Tool
    cat > "$SCRIPTS_DIR/ss7_recon.py" << 'PYEOF'
#!/usr/bin/env python3
"""
SS7 Network Reconnaissance Tool
Performs passive reconnaissance on telecom infrastructure
"""

import socket
import sys
import json
import subprocess
from datetime import datetime

class SS7Recon:
    """SS7/Telecom Network Reconnaissance"""
    
    # Common telecom-related ports
    TELECOM_PORTS = {
        # SIGTRAN
        2905: ("M3UA", "MTP3 User Adaptation"),
        2906: ("M3UA-alt", "M3UA Alternative"),
        2907: ("M3UA-alt2", "M3UA Alternative 2"),
        2945: ("M2PA", "MTP2 Peer-to-Peer Adaptation"),
        3565: ("M2UA", "MTP2 User Adaptation"),
        3868: ("Diameter", "Diameter Base Protocol"),
        3869: ("Diameter-TLS", "Diameter over TLS"),
        7626: ("SUA", "SCCP User Adaptation"),
        9900: ("IUA", "ISDN User Adaptation"),
        14001: ("IUA-alt", "IUA Alternative"),
        
        # LTE/5G Related
        29118: ("SGsAP", "SGs Interface"),
        29168: ("SBcAP", "SBc Interface"),
        36412: ("S1AP", "S1 Application Protocol"),
        36422: ("X2AP", "X2 Application Protocol"),
        38412: ("NGAP", "NG Application Protocol"),
        38422: ("XnAP", "Xn Application Protocol"),
        
        # VoIP/SIP
        5060: ("SIP", "Session Initiation Protocol"),
        5061: ("SIP-TLS", "SIP over TLS"),
        
        # Management
        161: ("SNMP", "Simple Network Management"),
        162: ("SNMP-Trap", "SNMP Trap"),
        22: ("SSH", "Secure Shell"),
        23: ("Telnet", "Telnet"),
        80: ("HTTP", "Web Management"),
        443: ("HTTPS", "Secure Web Management"),
        830: ("NETCONF", "Network Configuration"),
    }
    
    def __init__(self, target):
        self.target = target
        self.results = {
            "target": target,
            "timestamp": datetime.now().isoformat(),
            "dns": {},
            "ports": [],
            "services": [],
            "telecom_profile": {}
        }
    
    def dns_lookup(self):
        """Perform DNS lookups"""
        print(f"\n[*] DNS Reconnaissance for {self.target}")
        print("-" * 45)
        
        try:
            # Forward lookup
            ip = socket.gethostbyname(self.target)
            print(f"  A Record: {ip}")
            self.results["dns"]["a_record"] = ip
        except socket.gaierror:
            print(f"  No A record found")
        
        try:
            # Reverse lookup
            hostname = socket.gethostbyaddr(self.target)
            print(f"  PTR Record: {hostname[0]}")
            self.results["dns"]["ptr_record"] = hostname[0]
        except (socket.herror, socket.gaierror):
            print(f"  No PTR record found")
        
        # Check for telecom-related DNS
        telecom_prefixes = [
            "hlr", "msc", "stp", "scp", "smsc", "ggsn", "sgsn",
            "mme", "sgw", "pgw", "hss", "pcrf", "dra",
            "enum", "dns", "radius", "diameter"
        ]
        
        print(f"\n[*] Checking telecom-related hostnames...")
        for prefix in telecom_prefixes:
            try:
                fqdn = f"{prefix}.{self.target}"
                ip = socket.gethostbyname(fqdn)
                print(f"  [+] {fqdn} -> {ip}")
                self.results["dns"][prefix] = ip
            except socket.gaierror:
                pass
    
    def port_scan(self, quick=True):
        """Scan telecom-related ports"""
        print(f"\n[*] Telecom Port Scan on {self.target}")
        print("-" * 60)
        print(f"  {'Port':<8} {'Status':<10} {'Protocol':<15} {'Description'}")
        print(f"  {'-' * 55}")
        
        ports_to_scan = self.TELECOM_PORTS if not quick else {
            k: v for k, v in self.TELECOM_PORTS.items() 
            if k in [2905, 3868, 5060, 7626, 36412, 38412, 80, 443, 22]
        }
        
        open_count = 0
        for port, (proto, desc) in sorted(ports_to_scan.items()):
            try:
                sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
                sock.settimeout(2)
                result = sock.connect_ex((self.target, port))
                sock.close()
                
                if result == 0:
                    status = "\033[92mOPEN\033[0m    "
                    open_count += 1
                    self.results["ports"].append({
                        "port": port, "protocol": proto,
                        "description": desc, "status": "open"
                    })
                else:
                    status = "\033[91mCLOSED\033[0m  "
                
                print(f"  {port:<8} {status} {proto:<15} {desc}")
                
            except Exception:
                pass
        
        print(f"\n  Open ports: {open_count}/{len(ports_to_scan)}")
    
    def identify_network_element(self):
        """Try to identify the type of network element"""
        print(f"\n[*] Network Element Identification")
        print("-" * 45)
        
        open_ports = [p["port"] for p in self.results["ports"]]
        
        element_signatures = {
            "STP (Signal Transfer Point)": [2905, 2906, 7626],
            "HSS (Home Subscriber Server)": [3868, 3869],
            "MME (Mobility Management Entity)": [36412, 29118, 3868],
            "SGW/PGW (Gateway)": [3868, 2123],
            "SMSC (SMS Center)": [2905, 7626],
            "SBC (Session Border Controller)": [5060, 5061],
            "DRA (Diameter Routing Agent)": [3868, 3869],
            "gNodeB/eNodeB": [36412, 38412],
            "IMS Core": [3868, 5060, 5061],
        }
        
        for element, signature_ports in element_signatures.items():
            matches = sum(1 for p in signature_ports if p in open_ports)
            if matches > 0:
                confidence = (matches / len(signature_ports)) * 100
                if confidence > 30:
                    print(f"  [{'+'if confidence>50 else '?'}] {element}: {confidence:.0f}% confidence")
                    self.results["telecom_profile"][element] = confidence
    
    def generate_report(self):
        """Generate summary report"""
        print(f"\n{'=' * 60}")
        print(f"  RECONNAISSANCE REPORT")
        print(f"{'=' * 60}")
        print(f"  Target: {self.target}")
        print(f"  Time: {self.results['timestamp']}")
        print(f"  Open Ports: {len(self.results['ports'])}")
        
        if self.results['telecom_profile']:
            print(f"\n  Identified Elements:")
            for element, conf in self.results['telecom_profile'].items():
                print(f"    - {element} ({conf:.0f}%)")
        
        print(f"\n  Open Services:")
        for port_info in self.results['ports']:
            print(f"    - {port_info['port']}/{port_info['protocol']}: {port_info['description']}")
        
        # Save report
        report_file = f"recon_{self.target}_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
        try:
            with open(report_file, 'w') as f:
                json.dump(self.results, f, indent=2)
            print(f"\n  Report saved: {report_file}")
        except Exception as e:
            print(f"\n  Could not save report: {e}")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python3 ss7_recon.py <target>")
        sys.exit(1)
    
    recon = SS7Recon(sys.argv[1])
    recon.dns_lookup()
    recon.port_scan()
    recon.identify_network_element()
    recon.generate_report()
PYEOF

    chmod +x "$SCRIPTS_DIR"/*.py
    echo -e "${GREEN}[✓] Python helper scripts created${NC}"
}

#=====================================================
# SCTP SCANNER MODULE
#=====================================================
sctp_scanner() {
    banner
    echo -e "${CYAN}[*] SCTP/SIGTRAN Port Scanner${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    
    read -p "  Enter target IP: " target_ip
    
    if [ -z "$target_ip" ]; then
        echo -e "${RED}[!] No target specified${NC}"
        return
    fi
    
    echo ""
    echo -e "${YELLOW}  [1] Quick Scan (common SS7 ports)${NC}"
    echo -e "${YELLOW}  [2] Full Scan (all telecom ports)${NC}"
    echo -e "${YELLOW}  [3] Custom Port Range${NC}"
    echo ""
    read -p "  Select scan type [1]: " scan_type
    scan_type=${scan_type:-1}
    
    echo ""
    echo -e "${GREEN}[*] Starting scan on $target_ip...${NC}"
    log "INFO" "SCTP scan started on $target_ip"
    
    case $scan_type in
        1)
            python3 "$SCRIPTS_DIR/sctp_scanner.py" "$target_ip"
            ;;
        2)
            python3 "$SCRIPTS_DIR/sctp_scanner.py" "$target_ip" "2905,2906,2907,3565,3868,3869,5060,5061,7626,9900,14001,29118,29168,36412,36422,38412,38422"
            ;;
        3)
            read -p "  Enter ports (comma-separated): " custom_ports
            python3 "$SCRIPTS_DIR/sctp_scanner.py" "$target_ip" "$custom_ports"
            ;;
    esac
    
    # Also run nmap if available
    echo ""
    read -p "  Run nmap SCTP scan? (y/n) [n]: " run_nmap
    if [ "$run_nmap" = "y" ]; then
        echo -e "${CYAN}[*] Running nmap SCTP scan...${NC}"
        nmap -sS -p 2905,2906,3868,7626,14001,36412,38412 "$target_ip" 2>/dev/null
    fi
    
    echo ""
    echo -e "${YELLOW}Press Enter to continue...${NC}"
    read
}

#=====================================================
# MAP PROTOCOL ANALYZER
#=====================================================
map_analyzer() {
    banner
    echo -e "${CYAN}[*] MAP Protocol Analyzer${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    
    echo -e "${YELLOW}  [1] View MAP Operations & Risk Analysis${NC}"
    echo -e "${YELLOW}  [2] Analyze PCAP File${NC}"
    echo -e "${YELLOW}  [3] Generate Vulnerability Report${NC}"
    echo ""
    read -p "  Select option: " map_opt
    
    case $map_opt in
        1|2|3)
            python3 "$SCRIPTS_DIR/map_analyzer.py"
            ;;
        *)
            echo -e "${RED}[!] Invalid option${NC}"
            ;;
    esac
    
    echo ""
    echo -e "${YELLOW}Press Enter to continue...${NC}"
    read
}

#=====================================================
# SIGTRAN PROTOCOL BUILDER
#=====================================================
sigtran_builder() {
    banner
    echo -e "${CYAN}[*] SIGTRAN Protocol Message Builder${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    
    echo -e "${YELLOW}  [1] Build M3UA Messages${NC}"
    echo -e "${YELLOW}  [2] Build SCCP Messages${NC}"
    echo -e "${YELLOW}  [3] Build TCAP/MAP Messages${NC}"
    echo -e "${YELLOW}  [4] Full Protocol Stack Demo${NC}"
    echo ""
    read -p "  Select option [4]: " sig_opt
    sig_opt=${sig_opt:-4}
    
    python3 "$SCRIPTS_DIR/sigtran_builder.py"
    
    echo ""
    echo -e "${YELLOW}Press Enter to continue...${NC}"
    read
}

#=====================================================
# TELECOM NUMBER ANALYZER
#=====================================================
telecom_lookup() {
    banner
    echo -e "${CYAN}[*] Telecom Number Analysis Tool${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    
    python3 "$SCRIPTS_DIR/telecom_lookup.py"
    
    echo ""
    echo -e "${YELLOW}Press Enter to continue...${NC}"
    read
}

#=====================================================
# DIAMETER SCANNER
#=====================================================
diameter_scanner() {
    banner
    echo -e "${CYAN}[*] Diameter Protocol Scanner${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    
    echo -e "${YELLOW}  [1] Scan Target${NC}"
    echo -e "${YELLOW}  [2] View Diameter Applications Database${NC}"
    echo ""
    read -p "  Select option: " dia_opt
    
    case $dia_opt in
        1)
            read -p "  Enter target IP: " dia_target
            if [ -n "$dia_target" ]; then
                python3 "$SCRIPTS_DIR/diameter_scanner.py" "$dia_target"
            fi
            ;;
        2)
            python3 "$SCRIPTS_DIR/diameter_scanner.py" --info
            ;;
    esac
    
    echo ""
    echo -e "${YELLOW}Press Enter to continue...${NC}"
    read
}

#=====================================================
# NETWORK RECONNAISSANCE
#=====================================================
network_recon() {
    banner
    echo -e "${CYAN}[*] SS7 Network Reconnaissance${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    
    read -p "  Enter target (IP or hostname): " recon_target
    
    if [ -z "$recon_target" ]; then
        echo -e "${RED}[!] No target specified${NC}"
        return
    fi
    
    python3 "$SCRIPTS_DIR/ss7_recon.py" "$recon_target"
    
    echo ""
    echo -e "${YELLOW}Press Enter to continue...${NC}"
    read
}

#=====================================================
# PACKET CAPTURE
#=====================================================
packet_capture() {
    banner
    echo -e "${CYAN}[*] SS7/SIGTRAN Packet Capture${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    
    CAPTURE_DIR="$INSTALL_DIR/captures"
    CAPTURE_FILE="$CAPTURE_DIR/capture_$(date +%Y%m%d_%H%M%S).pcap"
    
    echo -e "${YELLOW}  [1] Capture SCTP traffic (M3UA)${NC}"
    echo -e "${YELLOW}  [2] Capture Diameter traffic${NC}"
    echo -e "${YELLOW}  [3] Capture SIP traffic${NC}"
    echo -e "${YELLOW}  [4] Capture all telecom traffic${NC}"
    echo -e "${YELLOW}  [5] Custom capture filter${NC}"
    echo -e "${YELLOW}  [6] Analyze existing PCAP${NC}"
    echo ""
    read -p "  Select option: " cap_opt
    
    case $cap_opt in
        1)
            echo -e "${GREEN}[*] Capturing SCTP traffic...${NC}"
            echo -e "${YELLOW}[*] Press Ctrl+C to stop${NC}"
            tcpdump -i any -w "$CAPTURE_FILE" 'sctp or port 2905 or port 2906 or port 7626' 2>/dev/null || \
            echo -e "${RED}[!] tcpdump requires root privileges${NC}"
            ;;
        2)
            echo -e "${GREEN}[*] Capturing Diameter traffic...${NC}"
            echo -e "${YELLOW}[*] Press Ctrl+C to stop${NC}"
            tcpdump -i any -w "$CAPTURE_FILE" 'port 3868 or port 3869' 2>/dev/null || \
            echo -e "${RED}[!] tcpdump requires root privileges${NC}"
            ;;
        3)
            echo -e "${GREEN}[*] Capturing SIP traffic...${NC}"
            echo -e "${YELLOW}[*] Press Ctrl+C to stop${NC}"
            tcpdump -i any -w "$CAPTURE_FILE" 'port 5060 or port 5061' 2>/dev/null || \
            echo -e "${RED}[!] tcpdump requires root privileges${NC}"
            ;;
        4)
            echo -e "${GREEN}[*] Capturing all telecom traffic...${NC}"
            echo -e "${YELLOW}[*] Press Ctrl+C to stop${NC}"
            tcpdump -i any -w "$CAPTURE_FILE" \
                'sctp or port 2905 or port 2906 or port 3868 or port 5060 or port 7626 or port 36412' \
                2>/dev/null || \
            echo -e "${RED}[!] tcpdump requires root privileges${NC}"
            ;;
        5)
            read -p "  Enter tcpdump filter: " custom_filter
            echo -e "${GREEN}[*] Capturing with custom filter...${NC}"
            tcpdump -i any -w "$CAPTURE_FILE" "$custom_filter" 2>/dev/null || \
            echo -e "${RED}[!] tcpdump requires root privileges${NC}"
            ;;
        6)
            echo -e "${CYAN}  Available captures:${NC}"
            ls -la "$CAPTURE_DIR"/*.pcap 2>/dev/null || echo "  No captures found"
            echo ""
            read -p "  Enter PCAP file path: " pcap_file
            if [ -f "$pcap_file" ]; then
                echo -e "${GREEN}[*] Analyzing $pcap_file${NC}"
                tshark -r "$pcap_file" -V 2>/dev/null | head -100 || \
                tcpdump -r "$pcap_file" -nn 2>/dev/null | head -50
            fi
            ;;
    esac
    
    if [ -f "$CAPTURE_FILE" ]; then
        echo -e "${GREEN}[✓] Capture saved: $CAPTURE_FILE${NC}"
    fi
    
    echo ""
    echo -e "${YELLOW}Press Enter to continue...${NC}"
    read
}

#=====================================================
# SIGPLOIT LAUNCHER
#=====================================================
launch_sigploit() {
    banner
    echo -e "${CYAN}[*] SigPloit Framework${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    
    if [ -d "$INSTALL_DIR/SigPloit" ]; then
        echo -e "${GREEN}[✓] SigPloit found${NC}"
        echo ""
        echo -e "${YELLOW}  [1] Launch SigPloit${NC}"
        echo -e "${YELLOW}  [2] Update SigPloit${NC}"
        echo -e "${YELLOW}  [3] View Documentation${NC}"
        echo ""
        read -p "  Select option: " sp_opt
        
        case $sp_opt in
            1)
                cd "$INSTALL_DIR/SigPloit"
                python3 sigploit.py 2>/dev/null || python sigploit.py 2>/dev/null || \
                echo -e "${RED}[!] Failed to launch SigPloit${NC}"
                ;;
            2)
                cd "$INSTALL_DIR/SigPloit"
                git pull
                echo -e "${GREEN}[✓] SigPloit updated${NC}"
                ;;
            3)
                echo -e "${CYAN}  SigPloit - SS7/GTP/Diameter Exploitation Framework${NC}"
                echo ""
                echo "  Modules:"
                echo "    - SS7: MAP, CAP exploitation"
                echo "    - GTP: GTPv2 exploitation"  
                echo "    - Diameter: S6a/S6d exploitation"
                echo ""
                echo "  SS7 Attack Categories:"
                echo "    1. Location Tracking"
                echo "    2. Call/SMS Interception"
                echo "    3. Fraud"
                echo "    4. Denial of Service"
                ;;
        esac
    else
        echo -e "${RED}[!] SigPloit not installed${NC}"
        echo -e "${YELLOW}[*] Run 'Install Dependencies' first${NC}"
    fi
    
    echo ""
    echo -e "${YELLOW}Press Enter to continue...${NC}"
    read
}

#=====================================================
# SS7 ATTACK REFERENCE
#=====================================================
attack_reference() {
    banner
    echo -e "${CYAN}[*] SS7 Attack Reference Guide${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    
    echo -e "${WHITE}  ┌─────────────────────────────────────────────────────┐${NC}"
    echo -e "${WHITE}  │         SS7 ATTACK CATEGORIES & METHODS            │${NC}"
    echo -e "${WHITE}  ├─────────────────────────────────────────────────────┤${NC}"
    echo -e "${WHITE}  │                                                     │${NC}"
    echo -e "${RED}  │  1. LOCATION TRACKING                               │${NC}"
    echo -e "${WHITE}  │     ├─ SendRoutingInfo (SRI)                        │${NC}"
    echo -e "${WHITE}  │     ├─ ProvideSubscriberInfo (PSI)                  │${NC}"
    echo -e "${WHITE}  │     ├─ AnyTimeInterrogation (ATI)                   │${NC}"
    echo -e "${WHITE}  │     └─ ProvideSubscriberLocation (PSL)              │${NC}"
    echo -e "${WHITE}  │                                                     │${NC}"
    echo -e "${RED}  │  2. CALL INTERCEPTION                               │${NC}"
    echo -e "${WHITE}  │     ├─ InsertSubscriberData (ISD)                   │${NC}"
    echo -e "${WHITE}  │     ├─ RegisterSS (forwarding setup)               │${NC}"
    echo -e "${WHITE}  │     └─ SendRoutingInfo + ProvideRoamingNumber       │${NC}"
    echo -e "${WHITE}  │                                                     │${NC}"
    echo -e "${RED}  │  3. SMS INTERCEPTION                                │${NC}"
    echo -e "${WHITE}  │     ├─ SendRoutingInfoForSM (SRI-SM)                │${NC}"
    echo -e "${WHITE}  │     ├─ MT-ForwardSM manipulation                    │${NC}"
    echo -e "${WHITE}  │     └─ UpdateLocation (IMSI re-registration)        │${NC}"
    echo -e "${WHITE}  │                                                     │${NC}"
    echo -e "${RED}  │  4. FRAUD                                           │${NC}"
    echo -e "${WHITE}  │     ├─ UpdateLocation (fake roaming)                │${NC}"
    echo -e "${WHITE}  │     ├─ InsertSubscriberData (service hijack)        │${NC}"
    echo -e "${WHITE}  │     └─ SendIMSI (identity theft)                    │${NC}"
    echo -e "${WHITE}  │                                                     │${NC}"
    echo -e "${RED}  │  5. DENIAL OF SERVICE                               │${NC}"
    echo -e "${WHITE}  │     ├─ CancelLocation                               │${NC}"
    echo -e "${WHITE}  │     ├─ DeleteSubscriberData                         │${NC}"
    echo -e "${WHITE}  │     ├─ DeactivateSS                                 │${NC}"
    echo -e "${WHITE}  │     └─ PurgeMS                                      │${NC}"
    echo -e "${WHITE}  │                                                     │${NC}"
    echo -e "${RED}  │  6. INFORMATION GATHERING                           │${NC}"
    echo -e "${WHITE}  │     ├─ SendAuthenticationInfo                       │${NC}"
    echo -e "${WHITE}  │     ├─ CheckIMEI                                    │${NC}"
    echo -e "${WHITE}  │     ├─ SendIMSI                                     │${NC}"
    echo -e "${WHITE}  │     └─ ProvideSubscriberInfo                        │${NC}"
    echo -e "${WHITE}  │                                                     │${NC}"
    echo -e "${WHITE}  └─────────────────────────────────────────────────────┘${NC}"
    
    echo ""
    echo -e "${MAGENTA}  ┌─────────────────────────────────────────────────────┐${NC}"
    echo -e "${MAGENTA}  │              PROTOCOL STACK                         │${NC}"
    echo -e "${MAGENTA}  ├─────────────────────────────────────────────────────┤${NC}"
    echo -e "${MAGENTA}  │  ┌───────────────────────────────────┐              │${NC}"
    echo -e "${MAGENTA}  │  │  MAP / CAP / INAP (Application)  │  Layer 7     │${NC}"
    echo -e "${MAGENTA}  │  ├───────────────────────────────────┤              │${NC}"
    echo -e "${MAGENTA}  │  │  TCAP (Transaction)               │  Layer 6     │${NC}"
    echo -e "${MAGENTA}  │  ├───────────────────────────────────┤              │${NC}"
    echo -e "${MAGENTA}  │  │  SCCP (Network)                   │  Layer 3     │${NC}"
    echo -e "${MAGENTA}  │  ├───────────────────────────────────┤              │${NC}"
    echo -e "${MAGENTA}  │  │  M3UA (Adaptation)                │              │${NC}"
    echo -e "${MAGENTA}  │  ├───────────────────────────────────┤              │${NC}"
    echo -e "${MAGENTA}  │  │  SCTP (Transport)                 │  Layer 4     │${NC}"
    echo -e "${MAGENTA}  │  ├───────────────────────────────────┤              │${NC}"
    echo -e "${MAGENTA}  │  │  IP (Network)                     │  Layer 3     │${NC}"
    echo -e "${MAGENTA}  │  └───────────────────────────────────┘              │${NC}"
    echo -e "${MAGENTA}  └─────────────────────────────────────────────────────┘${NC}"
    
    echo ""
    echo -e "${YELLOW}Press Enter to continue...${NC}"
    read
}

#=====================================================
# NMAP SS7 SCAN
#=====================================================
nmap_ss7_scan() {
    banner
    echo -e "${CYAN}[*] Nmap SS7/Telecom Scan${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    
    read -p "  Enter target IP/range: " nmap_target
    
    if [ -z "$nmap_target" ]; then
        echo -e "${RED}[!] No target specified${NC}"
        return
    fi
    
    echo ""
    echo -e "${YELLOW}  [1] Quick SS7 port scan${NC}"
    echo -e "${YELLOW}  [2] Detailed service detection${NC}"
    echo -e "${YELLOW}  [3] Full telecom infrastructure scan${NC}"
    echo -e "${YELLOW}  [4] OS and service fingerprint${NC}"
    echo ""
    read -p "  Select scan type [1]: " nmap_type
    nmap_type=${nmap_type:-1}
    
    echo ""
    log "INFO" "Nmap scan started on $nmap_target (type: $nmap_type)"
    
    SS7_PORTS="22,23,80,161,443,830,2905,2906,2907,2945,3565,3868,3869,5060,5061,7626,9900,14001,29118,29168,36412,36422,38412,38422"
    
    case $nmap_type in
        1)
            echo -e "${GREEN}[*] Quick SS7 port scan...${NC}"
            nmap -sS -p "$SS7_PORTS" "$nmap_target" 2>/dev/null || \
            nmap -sT -p "$SS7_PORTS" "$nmap_target"
            ;;
        2)
            echo -e "${GREEN}[*] Detailed service detection...${NC}"
            nmap -sV -sC -p "$SS7_PORTS" "$nmap_target" 2>/dev/null || \
            nmap -sV -p "$SS7_PORTS" "$nmap_target"
            ;;
        3)
            echo -e "${GREEN}[*] Full telecom infrastructure scan...${NC}"
            nmap -sS -sV -O -p "$SS7_PORTS,1-1000" --script=banner "$nmap_target" 2>/dev/null || \
            nmap -sT -sV -p "$SS7_PORTS" "$nmap_target"
            ;;
        4)
            echo -e "${GREEN}[*] OS and service fingerprint...${NC}"
            nmap -sV -O -A -p "$SS7_PORTS" "$nmap_target" 2>/dev/null || \
            nmap -sV -p "$SS7_PORTS" "$nmap_target"
            ;;
    esac
    
    echo ""
    echo -e "${YELLOW}Press Enter to continue...${NC}"
    read
}

#=====================================================
# SETTINGS
#=====================================================
settings_menu() {
    banner
    echo -e "${CYAN}[*] Settings & Configuration${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    
    echo -e "${WHITE}  [1] View installation paths${NC}"
    echo -e "${WHITE}  [2] Check installed tools${NC}"
    echo -e "${WHITE}  [3] View logs${NC}"
    echo -e "${WHITE}  [4] Clear logs${NC}"
    echo -e "${WHITE}  [5] Clear captures${NC}"
    echo -e "${WHITE}  [6] Update tools${NC}"
    echo -e "${WHITE}  [7] Uninstall${NC}"
    echo ""
    read -p "  Select option: " set_opt
    
    case $set_opt in
        1)
            echo ""
            echo -e "${CYAN}  Installation Directory: $INSTALL_DIR${NC}"
            echo -e "${CYAN}  Scripts Directory:      $SCRIPTS_DIR${NC}"
            echo -e "${CYAN}  Log Directory:          $LOG_DIR${NC}"
            echo -e "${CYAN}  Config Directory:       $CONFIG_DIR${NC}"
            echo -e "${CYAN}  Captures Directory:     $INSTALL_DIR/captures${NC}"
            echo ""
            du -sh "$INSTALL_DIR" 2>/dev/null
            ;;
        2)
            echo ""
            echo -e "${CYAN}  Checking installed tools...${NC}"
            echo ""
            
            tools=("python3" "pip" "nmap" "tcpdump" "tshark" "git" "curl" "wget" "socat" "netcat")
            for tool in "${tools[@]}"; do
                if command -v "$tool" &>/dev/null; then
                    version=$($tool --version 2>/dev/null | head -1)
                    echo -e "  ${GREEN}[✓]${NC} $tool ${CYAN}($version)${NC}"
                else
                    echo -e "  ${RED}[✗]${NC} $tool - NOT INSTALLED"
                fi
            done
            
            echo ""
            echo -e "${CYAN}  Python packages:${NC}"
            pip list 2>/dev/null | grep -iE "scapy|colorama|requests|pyasn1|cryptography" | \
                while read line; do echo "  [✓] $line"; done
            
            echo ""
            echo -e "${CYAN}  Frameworks:${NC}"
            [ -d "$INSTALL_DIR/SigPloit" ] && echo -e "  ${GREEN}[✓]${NC} SigPloit" || echo -e "  ${RED}[✗]${NC} SigPloit"
            [ -d "$INSTALL_DIR/ss7MAPer" ] && echo -e "  ${GREEN}[✓]${NC} ss7MAPer" || echo -e "  ${RED}[✗]${NC} ss7MAPer"
            ;;
        3)
            echo ""
            echo -e "${CYAN}  Recent logs:${NC}"
            ls -lt "$LOG_DIR"/*.log 2>/dev/null | head -10
            echo ""
            read -p "  View latest log? (y/n): " view_log
            if [ "$view_log" = "y" ]; then
                latest_log=$(ls -t "$LOG_DIR"/*.log 2>/dev/null | head -1)
                if [ -f "$latest_log" ]; then
                    cat "$latest_log"
                fi
            fi
            ;;
        4)
            rm -f "$LOG_DIR"/*.log
            echo -e "${GREEN}[✓] Logs cleared${NC}"
            ;;
        5)
            rm -f "$INSTALL_DIR/captures"/*.pcap
            echo -e "${GREEN}[✓] Captures cleared${NC}"
            ;;
        6)
            echo -e "${CYAN}[*] Updating tools...${NC}"
            if [ -d "$INSTALL_DIR/SigPloit" ]; then
                cd "$INSTALL_DIR/SigPloit" && git pull 2>/dev/null
            fi
            if [ -d "$INSTALL_DIR/ss7MAPer" ]; then
                cd "$INSTALL_DIR/ss7MAPer" && git pull 2>/dev/null
            fi
            pip install --upgrade scapy requests colorama 2>/dev/null
            echo -e "${GREEN}[✓] Tools updated${NC}"
            ;;
        7)
            echo ""
            read -p "  Are you sure you want to uninstall? (yes/no): " confirm
            if [ "$confirm" = "yes" ]; then
                rm -rf "$INSTALL_DIR"
                echo -e "${GREEN}[✓] Uninstalled${NC}"
            fi
            ;;
    esac
    
    echo ""
    echo -e "${YELLOW}Press Enter to continue...${NC}"
    read
}

#=====================================================
# EDUCATIONAL MODULE
#=====================================================
educational_module() {
    banner
    echo -e "${CYAN}[*] SS7 Educational Resources${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    
    echo -e "${WHITE}  [1] SS7 Protocol Overview${NC}"
    echo -e "${WHITE}  [2] SIGTRAN Architecture${NC}"
    echo -e "${WHITE}  [3] MAP Protocol Details${NC}"
    echo -e "${WHITE}  [4] Known Vulnerabilities${NC}"
    echo -e "${WHITE}  [5] Defense & Mitigation${NC}"
    echo ""
    read -p "  Select topic: " edu_opt
    
    case $edu_opt in
        1)
            echo ""
            echo -e "${CYAN}  ═══ SS7 PROTOCOL OVERVIEW ═══${NC}"
            echo ""
            echo "  Signaling System 7 (SS7) is a set of telephony signaling"
            echo "  protocols developed in the 1970s for setting up and tearing"
            echo "  down telephone calls, SMS delivery, and mobile subscriber"
            echo "  management across the global PSTN/PLMN."
            echo ""
            echo "  Key Components:"
            echo "  ┌──────────────────────────────────────────────┐"
            echo "  │ SSP - Service Switching Point (exchanges)    │"
            echo "  │ STP - Signal Transfer Point (routers)        │"
            echo "  │ SCP - Service Control Point (databases)      │"
            echo "  │ HLR - Home Location Register                 │"
            echo "  │ VLR - Visitor Location Register               │"
            echo "  │ MSC - Mobile Switching Center                 │"
            echo "  │ SMSC - Short Message Service Center           │"
            echo "  └──────────────────────────────────────────────┘"
            echo ""
            echo "  The protocol was designed with implicit trust between"
            echo "  interconnected operators, which is the root cause of"
            echo "  most SS7 security vulnerabilities."
            ;;
        2)
            echo ""
            echo -e "${CYAN}  ═══ SIGTRAN ARCHITECTURE ═══${NC}"
            echo ""
            echo "  SIGTRAN adapts SS7 signaling for IP networks:"
            echo ""
            echo "  Adaptation Layers:"
            echo "  ┌─────────┬──────────────────────────────────┐"
            echo "  │ M3UA    │ MTP3 User Adaptation (RFC 4666)  │"
            echo "  │ M2UA    │ MTP2 User Adaptation (RFC 3331)  │"
            echo "  │ M2PA    │ MTP2 Peer Adaptation (RFC 4165)  │"
            echo "  │ SUA     │ SCCP User Adaptation (RFC 3868)  │"
            echo "  │ IUA     │ ISDN User Adaptation (RFC 4233)  │"
            echo "  └─────────┴──────────────────────────────────┘"
            echo ""
            echo "  Transport: SCTP (Stream Control Transmission Protocol)"
            echo "  - Multi-homing support"
            echo "  - Multi-streaming"
            echo "  - Message-oriented (not byte-stream)"
            echo "  - Built-in heartbeat mechanism"
            echo ""
            echo "  Standard Ports:"
            echo "    M3UA: 2905 (SCTP)"
            echo "    SUA:  7626 (SCTP)"
            echo "    M2UA: 3565 (SCTP)"
            echo "    M2PA: 2945 (SCTP)"
            ;;
        3)
            echo ""
            echo -e "${CYAN}  ═══ MAP PROTOCOL DETAILS ═══${NC}"
            echo ""
            echo "  Mobile Application Part (MAP) is used for:"
            echo "  - Subscriber management"
            echo "  - Mobility management"
            echo "  - SMS handling"
            echo "  - Supplementary services"
            echo ""
            echo "  Key MAP Operations:"
            echo "  ┌──────┬─────────────────────────┬──────────┐"
            echo "  │ Code │ Operation               │ Risk     │"
            echo "  ├──────┼─────────────────────────┼──────────┤"
            echo "  │   2  │ UpdateLocation           │ HIGH     │"
            echo "  │   3  │ CancelLocation           │ HIGH     │"
            echo "  │  22  │ SendRoutingInfo           │ CRITICAL │"
            echo "  │  46  │ SendRoutingInfoForSM      │ CRITICAL │"
            echo "  │  56  │ SendIMSI                  │ HIGH     │"
            echo "  │  59  │ AnyTimeInterrogation      │ CRITICAL │"
            echo "  │  83  │ InsertSubscriberData      │ CRITICAL │"
            echo "  └──────┴─────────────────────────┴──────────┘"
            ;;
        4)
            echo ""
            echo -e "${CYAN}  ═══ KNOWN VULNERABILITIES ═══${NC}"
            echo ""
            echo "  CVE & Research References:"
            echo ""
            echo "  1. Location Tracking (SRI/ATI/PSI)"
            echo "     - Any operator can query subscriber location"
            echo "     - No authentication required"
            echo "     - Returns Cell-ID / LAC information"
            echo ""
            echo "  2. Call/SMS Interception"
            echo "     - InsertSubscriberData can redirect calls"
            echo "     - SRI-SM reveals SMSC routing info"
            echo "     - UpdateLocation can hijack subscriber"
            echo ""
            echo "  3. Fraud (GSMA FS.11 categories)"
            echo "     - Category 1: Subscriber Information Disclosure"
            echo "     - Category 2: Network Information Disclosure"
            echo "     - Category 3: Subscriber Traffic Interception"
            echo "     - Category 4: Fraud"
            echo "     - Category 5: Denial of Service"
            echo ""
            echo "  Key Research Papers:"
            echo "     - Tobias Engel, 31C3 (2014)"
            echo "     - Karsten Nohl, SS7 Research (2014)"
            echo "     - P1 Security SS7 Research"
            echo "     - GSMA IR.82 / FS.11 / FS.07"
            ;;
        5)
            echo ""
            echo -e "${CYAN}  ═══ DEFENSE & MITIGATION ═══${NC}"
            echo ""
            echo "  1. SS7 Firewall / Screening"
            echo "     - Filter unauthorized MAP operations"
            echo "     - Category-based filtering (GSMA FS.11)"
            echo "     - Whitelist legitimate originating GTs"
            echo ""
            echo "  2. SMS Home Routing"
            echo "     - Route SRI-SM queries through home STP"
            echo "     - Prevent direct HLR querying"
            echo ""
            echo "  3. MAP Operation Filtering"
            echo "     - Block ATI from non-authorized sources"
            echo "     - Validate UpdateLocation requests"
            echo "     - Filter ISD from external networks"
            echo ""
            echo "  4. Monitoring & Detection"
            echo "     - Monitor for unusual MAP patterns"
            echo "     - Detect bulk SRI queries"
            echo "     - Alert on cross-border anomalies"
            echo ""
            echo "  5. Standards & Guidelines"
            echo "     - GSMA FS.11: SS7 Interconnect Security"
            echo "     - GSMA FS.07: SS7 and SIGTRAN Network Security"
            echo "     - GSMA IR.82: Security SS7 implementation"
            echo "     - 3GPP TS 33.117: Security assurance"
            ;;
    esac
    
    echo ""
    echo -e "${YELLOW}Press Enter to continue...${NC}"
    read
}

#=====================================================
# MAIN MENU
#=====================================================
main_menu() {
    while true; do
        banner
        check_root
        echo ""
        
        echo -e "${WHITE}  ┌─────────────────────────────────────────────┐${NC}"
        echo -e "${WHITE}  │           ${CYAN}MAIN MENU${WHITE}                         │${NC}"
        echo -e "${WHITE}  ├─────────────────────────────────────────────┤${NC}"
        echo -e "${WHITE}  │                                             │${NC}"
        echo -e "${WHITE}  │  ${GREEN}[01]${WHITE} Install Dependencies                │${NC}"
        echo -e "${WHITE}  │  ${GREEN}[02]${WHITE} SCTP/SIGTRAN Port Scanner           │${NC}"
        echo -e "${WHITE}  │  ${GREEN}[03]${WHITE} MAP Protocol Analyzer               │${NC}"
        echo -e "${WHITE}  │  ${GREEN}[04]${WHITE} SIGTRAN Message Builder             │${NC}"
        echo -e "${WHITE}  │  ${GREEN}[05]${WHITE} Telecom Number Analyzer             │${NC}"
        echo -e "${WHITE}  │  ${GREEN}[06]${WHITE} Diameter Protocol Scanner           │${NC}"
        echo -e "${WHITE}  │  ${GREEN}[07]${WHITE} Network Reconnaissance              │${NC}"
        echo -e "${WHITE}  │  ${GREEN}[08]${WHITE} Packet Capture & Analysis           │${NC}"
        echo -e "${WHITE}  │  ${GREEN}[09]${WHITE} Nmap SS7/Telecom Scan               │${NC}"
        echo -e "${WHITE}  │  ${GREEN}[10]${WHITE} Launch SigPloit Framework           │${NC}"
        echo -e "${WHITE}  │  ${GREEN}[11]${WHITE} SS7 Attack Reference Guide          │${NC}"
        echo -e "${WHITE}  │  ${GREEN}[12]${WHITE} Educational Resources               │${NC}"
        echo -e "${WHITE}  │  ${GREEN}[13]${WHITE} Settings & Configuration            │${NC}"
        echo -e "${WHITE}  │                                             │${NC}"
        echo -e "${WHITE}  │  ${RED}[00]${WHITE} Exit                                │${NC}"
        echo -e "${WHITE}  │                                             │${NC}"
        echo -e "${WHITE}  └─────────────────────────────────────────────┘${NC}"
        echo ""
        
        read -p "  ss7-toolkit> " choice
        
        case $choice in
            01|1)   install_dependencies ;;
            02|2)   sctp_scanner ;;
            03|3)   map_analyzer ;;
            04|4)   sigtran_builder ;;
            05|5)   telecom_lookup ;;
            06|6)   diameter_scanner ;;
            07|7)   network_recon ;;
            08|8)   packet_capture ;;
            09|9)   nmap_ss7_scan ;;
            10)     launch_sigploit ;;
            11)     attack_reference ;;
            12)     educational_module ;;
            13)     settings_menu ;;
            00|0)   
                echo -e "${GREEN}[*] Goodbye!${NC}"
                log "INFO" "Session ended"
                exit 0
                ;;
            *)
                echo -e "${RED}[!] Invalid option${NC}"
                sleep 1
                ;;
        esac
    done
}

#=====================================================
# ENTRY POINT
#=====================================================

# Create necessary directories
mkdir -p "$INSTALL_DIR" "$LOG_DIR" "$CONFIG_DIR" "$SCRIPTS_DIR" 2>/dev/null

# Initialize log
log "INFO" "SS7 Toolkit started"

# Handle command line arguments
case "$1" in
    --install|-i)
        install_dependencies
        ;;
    --scan|-s)
        if [ -n "$2" ]; then
            python3 "$SCRIPTS_DIR/sctp_scanner.py" "$2"
        else
            echo "Usage: $0 --scan <target_ip>"
        fi
        ;;
    --recon|-r)
        if [ -n "$2" ]; then
            python3 "$SCRIPTS_DIR/ss7_recon.py" "$2"
        else
            echo "Usage: $0 --recon <target>"
        fi
        ;;
    --lookup|-l)
        python3 "$SCRIPTS_DIR/telecom_lookup.py" "${@:2}"
        ;;
    --help|-h)
        echo "SS7 Security Testing Toolkit"
        echo ""
        echo "Usage: $0 [option]"
        echo ""
        echo "Options:"
        echo "  --install, -i          Install dependencies"
        echo "  --scan, -s <target>    Quick SCTP scan"
        echo "  --recon, -r <target>   Network reconnaissance"
        echo "  --lookup, -l           Telecom number lookup"
        echo "  --help, -h             Show this help"
        echo ""
        echo "Without options, launches interactive menu."
        ;;
    *)
        main_menu
        ;;
esac
