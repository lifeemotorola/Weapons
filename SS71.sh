#!/data/data/com.termux/files/usr/bin/bash

#=====================================================================
# SS7 Tools for Termux
# Educational SS7/SIGTRAN Protocol Analysis Toolkit
# Author: Security Research Tool
# Version: 2.0
#=====================================================================

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
PCAP_DIR="$WORK_DIR/pcaps"
CONFIG_DIR="$WORK_DIR/config"
RESULTS_DIR="$WORK_DIR/results"

# Log file
LOG_FILE="$LOG_DIR/ss7_tools_$(date +%Y%m%d_%H%M%S).log"

#=====================================================================
# UTILITY FUNCTIONS
#=====================================================================

log_message() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
}

print_banner() {
    clear
    echo -e "${CYAN}"
    cat << 'BANNER'
    ╔═══════════════════════════════════════════════════════════╗
    ║                                                           ║
    ║     ██████  ██████  ███████     ████████  ██████   ██████ ║
    ║     ██      ██           ██        ██    ██    ██ ██    ██║
    ║     ██████  ██████   █████         ██    ██    ██ ██    ██║
    ║          ██      ██      ██        ██    ██    ██ ██    ██║
    ║     ██████  ██████  ██████         ██     ██████   ██████ ║
    ║                                                           ║
    ║          SS7/SIGTRAN Analysis Toolkit v2.0                ║
    ║          For Educational & Authorized Testing             ║
    ╚═══════════════════════════════════════════════════════════╝
BANNER
    echo -e "${NC}"
    echo -e "${RED}${BOLD}  [!] For authorized security testing only${NC}"
    echo -e "${YELLOW}  [*] Unauthorized use is illegal and unethical${NC}"
    echo ""
}

print_separator() {
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

print_header() {
    echo ""
    print_separator
    echo -e "${WHITE}${BOLD}  $1${NC}"
    print_separator
    echo ""
}

success_msg() {
    echo -e "${GREEN}  [✓] $1${NC}"
    log_message "SUCCESS" "$1"
}

error_msg() {
    echo -e "${RED}  [✗] $1${NC}"
    log_message "ERROR" "$1"
}

info_msg() {
    echo -e "${CYAN}  [i] $1${NC}"
    log_message "INFO" "$1"
}

warn_msg() {
    echo -e "${YELLOW}  [!] $1${NC}"
    log_message "WARNING" "$1"
}

prompt_msg() {
    echo -ne "${MAGENTA}  [?] $1${NC}"
}

progress_bar() {
    local current=$1
    local total=$2
    local width=40
    local percentage=$((current * 100 / total))
    local filled=$((current * width / total))
    local empty=$((width - filled))

    printf "\r  ${CYAN}["
    printf "%${filled}s" | tr ' ' '█'
    printf "%${empty}s" | tr ' ' '░'
    printf "] ${percentage}%%${NC}"

    if [ "$current" -eq "$total" ]; then
        echo ""
    fi
}

validate_ip() {
    local ip=$1
    if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        IFS='.' read -ra ADDR <<< "$ip"
        for i in "${ADDR[@]}"; do
            if [ "$i" -gt 255 ]; then
                return 1
            fi
        done
        return 0
    fi
    return 1
}

validate_port() {
    local port=$1
    if [[ $port =~ ^[0-9]+$ ]] && [ "$port" -ge 1 ] && [ "$port" -le 65535 ]; then
        return 0
    fi
    return 1
}

validate_phone() {
    local phone=$1
    if [[ $phone =~ ^\+?[0-9]{7,15}$ ]]; then
        return 0
    fi
    return 1
}

validate_gt() {
    local gt=$1
    if [[ $gt =~ ^[0-9]{1,15}$ ]]; then
        return 0
    fi
    return 1
}

check_root() {
    if [ "$(id -u)" != "0" ]; then
        warn_msg "Some features may require root access"
        return 1
    fi
    return 0
}

#=====================================================================
# SETUP & INSTALLATION
#=====================================================================

setup_directories() {
    mkdir -p "$WORK_DIR" "$LOG_DIR" "$PCAP_DIR" "$CONFIG_DIR" "$RESULTS_DIR"
    touch "$LOG_FILE"
    log_message "INFO" "SS7 Tools started"
}

check_dependencies() {
    print_header "Checking Dependencies"

    local deps=("python" "pip" "git" "nmap" "tshark" "gcc" "make" "curl" "wget" "openssl")
    local missing=()
    local installed=0
    local total=${#deps[@]}

    for dep in "${deps[@]}"; do
        ((installed++))
        progress_bar $installed $total
        if command -v "$dep" &>/dev/null; then
            success_msg "$dep is installed"
        else
            warn_msg "$dep is NOT installed"
            missing+=("$dep")
        fi
        sleep 0.2
    done

    echo ""

    # Check Python modules
    local py_modules=("scapy" "socket" "struct" "binascii" "argparse" "json" "xml")
    info_msg "Checking Python modules..."
    for mod in "${py_modules[@]}"; do
        if python -c "import $mod" 2>/dev/null; then
            success_msg "Python module: $mod"
        else
            warn_msg "Python module missing: $mod"
        fi
    done

    if [ ${#missing[@]} -gt 0 ]; then
        echo ""
        warn_msg "Missing packages: ${missing[*]}"
        prompt_msg "Install missing packages? (y/n): "
        read -r answer
        if [[ "$answer" =~ ^[Yy]$ ]]; then
            install_dependencies "${missing[@]}"
        fi
    else
        success_msg "All dependencies are installed!"
    fi
}

install_dependencies() {
    print_header "Installing Dependencies"

    info_msg "Updating package repository..."
    pkg update -y 2>/dev/null
    pkg upgrade -y 2>/dev/null

    local packages=("python" "git" "nmap" "tshark" "clang" "make" "curl"
                     "wget" "openssl" "libpcap" "wireshark-cli"
                     "termux-tools" "net-tools" "iproute2" "coreutils")

    local total=${#packages[@]}
    local current=0

    for pkg_name in "${packages[@]}"; do
        ((current++))
        progress_bar $current $total
        pkg install -y "$pkg_name" 2>/dev/null
        sleep 0.3
    done

    echo ""
    info_msg "Installing Python packages..."

    pip install --upgrade pip 2>/dev/null
    pip install scapy 2>/dev/null
    pip install pysctp 2>/dev/null
    pip install dpkt 2>/dev/null
    pip install pyshark 2>/dev/null
    pip install cryptography 2>/dev/null
    pip install requests 2>/dev/null
    pip install colorama 2>/dev/null

    success_msg "Dependencies installation completed!"
}

install_ss7_frameworks() {
    print_header "Installing SS7 Frameworks"

    echo -e "${WHITE}  Select framework to install:${NC}"
    echo ""
    echo -e "  ${CYAN}1)${NC} SigPloit - SS7/GTP/Diameter Exploitation Framework"
    echo -e "  ${CYAN}2)${NC} SS7MAPer - SS7 MAP Protocol Testing"
    echo -e "  ${CYAN}3)${NC} SCTP Tools - SCTP Protocol Utilities"
    echo -e "  ${CYAN}4)${NC} Osmocom Libraries - Telecom Protocol Stack"
    echo -e "  ${CYAN}5)${NC} Custom SIGTRAN Stack"
    echo -e "  ${CYAN}6)${NC} Install All"
    echo -e "  ${CYAN}0)${NC} Back"
    echo ""
    prompt_msg "Select option: "
    read -r fw_choice

    case $fw_choice in
        1) install_sigploit ;;
        2) install_ss7maper ;;
        3) install_sctp_tools ;;
        4) install_osmocom ;;
        5) install_custom_sigtran ;;
        6)
            install_sigploit
            install_ss7maper
            install_sctp_tools
            install_osmocom
            install_custom_sigtran
            ;;
        0) return ;;
        *) error_msg "Invalid option" ;;
    esac
}

install_sigploit() {
    info_msg "Installing SigPloit..."
    cd "$WORK_DIR" || return

    if [ -d "SigPloit" ]; then
        warn_msg "SigPloit already exists. Updating..."
        cd SigPloit && git pull
    else
        git clone https://github.com/SigPloiter/SigPloit.git 2>/dev/null
        if [ $? -eq 0 ]; then
            cd SigPloit
            pip install -r requirements.txt 2>/dev/null
            success_msg "SigPloit installed successfully!"
        else
            error_msg "Failed to clone SigPloit"
        fi
    fi
    cd "$WORK_DIR" || return
}

install_ss7maper() {
    info_msg "Installing SS7MAPer..."
    cd "$WORK_DIR" || return

    if [ -d "ss7MAPer" ]; then
        warn_msg "SS7MAPer already exists. Updating..."
        cd ss7MAPer && git pull
    else
        git clone https://github.com/ernw/ss7MAPer.git 2>/dev/null
        if [ $? -eq 0 ]; then
            success_msg "SS7MAPer installed successfully!"
        else
            error_msg "Failed to clone SS7MAPer"
        fi
    fi
    cd "$WORK_DIR" || return
}

install_sctp_tools() {
    info_msg "Installing SCTP Tools..."

    pip install pysctp 2>/dev/null
    pkg install -y lksctp-tools 2>/dev/null

    # Create custom SCTP scanner
    cat > "$WORK_DIR/sctp_scanner.py" << 'PYEOF'
#!/usr/bin/env python3
"""SCTP Port Scanner for SS7/SIGTRAN"""

import socket
import struct
import sys
import time
import argparse

class SCTPScanner:
    """SCTP Protocol Scanner"""

    # Common SIGTRAN ports
    SIGTRAN_PORTS = {
        2904: "M2UA",
        2905: "M3UA",
        2906: "IUA",
        2907: "SUA",
        3565: "M2PA",
        3868: "Diameter",
        4739: "IPFIX",
        4740: "IPFIX/TLS",
        5060: "SIP",
        5061: "SIP/TLS",
        14001: "SUA-alt",
        36412: "S1AP",
        36422: "X2AP",
        36443: "M3AP",
        38412: "NGAP",
        38422: "XnAP"
    }

    def __init__(self, target, timeout=3):
        self.target = target
        self.timeout = timeout
        self.results = {}

    def create_sctp_init(self, src_port, dst_port):
        """Create SCTP INIT chunk"""
        # SCTP Header
        src_port_bytes = struct.pack('!H', src_port)
        dst_port_bytes = struct.pack('!H', dst_port)
        vtag = struct.pack('!I', 0)  # Verification tag = 0 for INIT

        # INIT Chunk
        chunk_type = 1  # INIT
        chunk_flags = 0
        init_tag = struct.pack('!I', 0x12345678)
        a_rwnd = struct.pack('!I', 65535)
        num_outbound = struct.pack('!H', 1)
        num_inbound = struct.pack('!H', 1)
        initial_tsn = struct.pack('!I', 1)

        chunk_value = init_tag + a_rwnd + num_outbound + num_inbound + initial_tsn
        chunk_length = struct.pack('!H', 4 + len(chunk_value))
        chunk = struct.pack('!BB', chunk_type, chunk_flags) + chunk_length + chunk_value

        # Calculate checksum placeholder
        checksum = struct.pack('!I', 0)

        packet = src_port_bytes + dst_port_bytes + vtag + checksum + chunk
        return packet

    def scan_port(self, port):
        """Scan a single SCTP port"""
        try:
            sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            sock.settimeout(self.timeout)
            result = sock.connect_ex((self.target, port))
            sock.close()

            if result == 0:
                service = self.SIGTRAN_PORTS.get(port, "Unknown")
                return (port, "open", service)
            return (port, "closed", "")
        except socket.timeout:
            return (port, "filtered", "")
        except Exception as e:
            return (port, "error", str(e))

    def scan_sigtran_ports(self):
        """Scan common SIGTRAN ports"""
        print(f"\n[*] Scanning SIGTRAN ports on {self.target}")
        print("-" * 60)

        for port, service in sorted(self.SIGTRAN_PORTS.items()):
            port_num, status, svc = self.scan_port(port)
            if status == "open":
                print(f"  [+] Port {port_num:5d}/sctp  OPEN    {service}")
                self.results[port] = {"status": status, "service": service}
            elif status == "filtered":
                print(f"  [?] Port {port_num:5d}/sctp  FILTERED {service}")

        print("-" * 60)
        print(f"[*] Scan complete. {len(self.results)} open ports found.")
        return self.results

    def scan_range(self, start_port, end_port):
        """Scan a range of ports"""
        print(f"\n[*] Scanning ports {start_port}-{end_port} on {self.target}")
        print("-" * 60)

        for port in range(start_port, end_port + 1):
            port_num, status, svc = self.scan_port(port)
            if status == "open":
                service = self.SIGTRAN_PORTS.get(port, "Unknown")
                print(f"  [+] Port {port_num:5d}/sctp  OPEN    {service}")
                self.results[port] = {"status": status, "service": service}

            # Progress indicator
            if port % 100 == 0:
                progress = ((port - start_port) / (end_port - start_port)) * 100
                print(f"\r  [*] Progress: {progress:.1f}%", end="", flush=True)

        print(f"\n{'-' * 60}")
        print(f"[*] Scan complete. {len(self.results)} open ports found.")
        return self.results


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="SCTP/SIGTRAN Port Scanner")
    parser.add_argument("target", help="Target IP address")
    parser.add_argument("-p", "--ports", help="Port range (e.g., 1-65535)")
    parser.add_argument("-s", "--sigtran", action="store_true",
                        help="Scan only SIGTRAN ports")
    parser.add_argument("-t", "--timeout", type=int, default=3,
                        help="Connection timeout (default: 3)")

    args = parser.parse_args()

    scanner = SCTPScanner(args.target, args.timeout)

    if args.sigtran or not args.ports:
        scanner.scan_sigtran_ports()
    elif args.ports:
        parts = args.ports.split("-")
        scanner.scan_range(int(parts[0]), int(parts[1]))
PYEOF

    chmod +x "$WORK_DIR/sctp_scanner.py"
    success_msg "SCTP Tools installed successfully!"
}

install_osmocom() {
    info_msg "Setting up Osmocom reference configs..."
    mkdir -p "$CONFIG_DIR/osmocom"

    # Create reference configuration
    cat > "$CONFIG_DIR/osmocom/README.md" << 'EOF'
# Osmocom SS7 Stack

Osmocom provides open-source implementations of telecom protocols.

## Components:
- libosmocore - Core library
- libosmo-sccp - SCCP implementation
- libosmo-sigtran - SIGTRAN (M3UA/SUA)
- osmo-stp - Signal Transfer Point

## Note:
Full Osmocom stack requires Linux with proper kernel support.
For Termux, use the analysis and simulation tools provided.

## Resources:
- https://osmocom.org/
- https://git.osmocom.org/
EOF

    success_msg "Osmocom reference configs created!"
}

install_custom_sigtran() {
    info_msg "Creating custom SIGTRAN analysis tools..."

    # Create M3UA message parser
    cat > "$WORK_DIR/m3ua_parser.py" << 'PYEOF'
#!/usr/bin/env python3
"""M3UA Protocol Message Parser"""

import struct
import sys
import binascii

class M3UAParser:
    """Parse M3UA (MTP3 User Adaptation) messages"""

    # Message Classes
    MSG_CLASSES = {
        0: "Management (MGMT)",
        1: "Transfer",
        2: "SS7 Signaling Network Management (SSNM)",
        3: "ASP State Maintenance (ASPSM)",
        4: "ASP Traffic Maintenance (ASPTM)",
        9: "Routing Key Management (RKM)"
    }

    # Message Types per Class
    MSG_TYPES = {
        (0, 0): "ERR",
        (0, 1): "NTFY",
        (1, 1): "DATA",
        (2, 1): "DUNA",
        (2, 2): "DAVA",
        (2, 3): "DAUD",
        (2, 4): "SCON",
        (2, 5): "DUPU",
        (2, 6): "DRST",
        (3, 1): "ASPUP",
        (3, 2): "ASPDN",
        (3, 3): "BEAT",
        (3, 4): "ASPUP_ACK",
        (3, 5): "ASPDN_ACK",
        (3, 6): "BEAT_ACK",
        (4, 1): "ASPAC",
        (4, 2): "ASPIA",
        (4, 3): "ASPAC_ACK",
        (4, 4): "ASPIA_ACK",
        (9, 1): "REG_REQ",
        (9, 2): "REG_RSP",
        (9, 3): "DEREG_REQ",
        (9, 4): "DEREG_RSP"
    }

    # Parameter Tags
    PARAM_TAGS = {
        0x0001: "Interface Identifier (Integer)",
        0x0003: "Interface Identifier (Text)",
        0x0004: "Info String",
        0x0006: "Routing Context",
        0x0007: "Diagnostic Information",
        0x0009: "Heartbeat Data",
        0x000B: "Traffic Mode Type",
        0x000C: "Error Code",
        0x000D: "Status",
        0x0011: "ASP Identifier",
        0x0012: "Affected Point Code",
        0x0013: "Correlation ID",
        0x0200: "Network Appearance",
        0x0204: "User/Cause",
        0x0205: "Congestion Indications",
        0x0206: "Concerned Destination",
        0x0207: "Routing Key",
        0x0209: "Registration Result",
        0x020A: "Deregistration Result",
        0x020B: "Local Routing Key Identifier",
        0x020C: "Destination Point Code",
        0x020D: "Service Indicators",
        0x020E: "Originating Point Code List",
        0x0210: "Protocol Data",
        0x0212: "Registration Status",
        0x0213: "Deregistration Status"
    }

    def __init__(self):
        self.parsed_messages = []

    def parse_header(self, data):
        """Parse M3UA common header"""
        if len(data) < 8:
            return None

        version, reserved, msg_class, msg_type = struct.unpack('!BBBB', data[0:4])
        msg_length = struct.unpack('!I', data[4:8])[0]

        msg_class_name = self.MSG_CLASSES.get(msg_class, f"Unknown({msg_class})")
        msg_type_name = self.MSG_TYPES.get((msg_class, msg_type),
                                            f"Unknown({msg_class},{msg_type})")

        header = {
            "version": version,
            "msg_class": msg_class,
            "msg_class_name": msg_class_name,
            "msg_type": msg_type,
            "msg_type_name": msg_type_name,
            "length": msg_length
        }

        return header

    def parse_parameters(self, data):
        """Parse M3UA parameters (TLV format)"""
        params = []
        offset = 0

        while offset < len(data) - 3:
            tag = struct.unpack('!H', data[offset:offset+2])[0]
            length = struct.unpack('!H', data[offset+2:offset+4])[0]

            if length < 4:
                break

            value_length = length - 4
            value = data[offset+4:offset+4+value_length]

            tag_name = self.PARAM_TAGS.get(tag, f"Unknown(0x{tag:04X})")

            param = {
                "tag": tag,
                "tag_name": tag_name,
                "length": length,
                "value": value,
                "value_hex": binascii.hexlify(value).decode()
            }

            # Parse specific parameter values
            if tag == 0x0210:  # Protocol Data
                param["protocol_data"] = self.parse_protocol_data(value)
            elif tag == 0x000C:  # Error Code
                if len(value) >= 4:
                    param["error_code"] = struct.unpack('!I', value[0:4])[0]
            elif tag == 0x000D:  # Status
                if len(value) >= 4:
                    status_type = struct.unpack('!H', value[0:2])[0]
                    status_info = struct.unpack('!H', value[2:4])[0]
                    param["status_type"] = status_type
                    param["status_info"] = status_info

            params.append(param)

            # Align to 4-byte boundary
            padded_length = (length + 3) & ~3
            offset += padded_length

        return params

    def parse_protocol_data(self, data):
        """Parse Protocol Data parameter (contains MTP3/SCCP)"""
        if len(data) < 12:
            return None

        opc = struct.unpack('!I', data[0:4])[0]
        dpc = struct.unpack('!I', data[4:8])[0]
        si = data[8]
        ni = data[9]
        mp = data[10]
        sls = data[11]
        user_data = data[12:]

        si_names = {
            0: "SNMM", 1: "SNTM", 2: "SNSM", 3: "SCCP",
            4: "TUP", 5: "ISUP", 6: "DUP-C", 7: "DUP-F",
            8: "MTP Testing", 9: "Broadband ISUP", 10: "Satellite ISUP",
            13: "Q.2931"
        }

        return {
            "opc": opc,
            "dpc": dpc,
            "si": si,
            "si_name": si_names.get(si, f"Unknown({si})"),
            "ni": ni,
            "mp": mp,
            "sls": sls,
            "user_data_hex": binascii.hexlify(user_data).decode(),
            "user_data_length": len(user_data)
        }

    def parse_message(self, data):
        """Parse complete M3UA message"""
        header = self.parse_header(data)
        if not header:
            return None

        params = []
        if len(data) > 8:
            params = self.parse_parameters(data[8:])

        message = {
            "header": header,
            "parameters": params
        }

        self.parsed_messages.append(message)
        return message

    def display_message(self, message):
        """Display parsed M3UA message"""
        h = message["header"]
        print(f"\n{'='*60}")
        print(f"M3UA Message: {h['msg_type_name']}")
        print(f"{'='*60}")
        print(f"  Version:    {h['version']}")
        print(f"  Class:      {h['msg_class_name']}")
        print(f"  Type:       {h['msg_type_name']}")
        print(f"  Length:     {h['length']}")

        for param in message.get("parameters", []):
            print(f"\n  Parameter: {param['tag_name']}")
            print(f"    Tag:      0x{param['tag']:04X}")
            print(f"    Length:   {param['length']}")
            print(f"    Value:    {param['value_hex']}")

            if "protocol_data" in param:
                pd = param["protocol_data"]
                print(f"    --- Protocol Data ---")
                print(f"    OPC:      {pd['opc']}")
                print(f"    DPC:      {pd['dpc']}")
                print(f"    SI:       {pd['si_name']}")
                print(f"    NI:       {pd['ni']}")
                print(f"    SLS:      {pd['sls']}")
                print(f"    Data:     {pd['user_data_hex'][:80]}...")

        print(f"{'='*60}")


# Example / Test
if __name__ == "__main__":
    parser = M3UAParser()

    # Example M3UA ASPUP message
    sample = bytes.fromhex("01000301000000100011000800000001")
    msg = parser.parse_message(sample)
    if msg:
        parser.display_message(msg)
    else:
        print("[*] M3UA Parser ready. Use with captured data.")
        print("[*] Usage: Import M3UAParser class and call parse_message()")
PYEOF

    # Create SCCP message parser
    cat > "$WORK_DIR/sccp_parser.py" << 'PYEOF'
#!/usr/bin/env python3
"""SCCP (Signaling Connection Control Part) Parser"""

import struct
import binascii

class SCCPParser:
    """Parse SCCP messages"""

    MSG_TYPES = {
        0x01: "CR (Connection Request)",
        0x02: "CC (Connection Confirm)",
        0x03: "CREF (Connection Refused)",
        0x04: "RLSD (Released)",
        0x05: "RLC (Release Complete)",
        0x06: "DT1 (Data Form 1)",
        0x07: "DT2 (Data Form 2)",
        0x08: "AK (Data Acknowledgement)",
        0x09: "UDT (Unitdata)",
        0x0A: "UDTS (Unitdata Service)",
        0x0B: "ED (Expedited Data)",
        0x0C: "EA (Expedited Data Ack)",
        0x0D: "RSR (Reset Request)",
        0x0E: "RSC (Reset Confirm)",
        0x0F: "ERR (Protocol Data Unit Error)",
        0x10: "IT (Inactivity Test)",
        0x11: "XUDT (Extended Unitdata)",
        0x12: "XUDTS (Extended Unitdata Service)",
        0x13: "LUDT (Long Unitdata)",
        0x14: "LUDTS (Long Unitdata Service)"
    }

    # SCCP Called/Calling Party Address indicators
    GT_INDICATORS = {
        0b0000: "No Global Title",
        0b0001: "GT includes Nature of Address only",
        0b0010: "GT includes Translation Type only",
        0b0011: "GT includes TT, Numbering Plan, Encoding Scheme",
        0b0100: "GT includes TT, NP, ES, Nature of Address"
    }

    SSN_NAMES = {
        0: "SSN not known/not used",
        1: "SCCP management",
        2: "Reserved for ITU-T allocation",
        3: "ISUP",
        4: "OMAP",
        5: "MAP",
        6: "HLR",
        7: "VLR",
        8: "MSC",
        9: "EIR",
        10: "AUC",
        11: "ISDN Supplementary Services",
        12: "Reserved for international use",
        13: "Broadband ISDN edge-to-edge",
        14: "TC test responder",
        142: "RANAP",
        143: "RNSAP",
        145: "GMLC (MAP)",
        146: "CAP",
        147: "gsmSCF (MAP)",
        148: "SIWF (MAP)",
        149: "SGSN (MAP)",
        150: "GGSN (MAP)",
        249: "PCAP",
        250: "BSC (BSSAP-LE)",
        251: "MSC (BSSAP-LE)",
        252: "SMLC (BSSAP-LE)",
        253: "BSS O&M (A-interface)",
        254: "BSSAP (A-interface)"
    }

    def __init__(self):
        self.parsed = []

    def parse_gt(self, data, gt_indicator):
        """Parse Global Title"""
        gt_info = {"indicator": gt_indicator}

        if gt_indicator == 0b0100 and len(data) >= 2:
            gt_info["translation_type"] = data[0]
            np_es = data[1]
            gt_info["numbering_plan"] = (np_es >> 4) & 0x0F
            gt_info["encoding_scheme"] = np_es & 0x0F
            gt_info["nature_of_address"] = data[2] if len(data) > 2 else 0

            # Decode digits (BCD)
            digits = ""
            start = 3 if len(data) > 2 else 2
            for byte in data[start:]:
                digits += str(byte & 0x0F)
                if (byte >> 4) != 0x0F:
                    digits += str((byte >> 4) & 0x0F)
            gt_info["digits"] = digits

        elif gt_indicator == 0b0010 and len(data) >= 1:
            gt_info["translation_type"] = data[0]
            digits = ""
            for byte in data[1:]:
                digits += str(byte & 0x0F)
                if (byte >> 4) != 0x0F:
                    digits += str((byte >> 4) & 0x0F)
            gt_info["digits"] = digits

        return gt_info

    def parse_address(self, data):
        """Parse SCCP address"""
        if len(data) < 2:
            return None

        indicator = data[0]

        addr = {
            "address_indicator": indicator,
            "point_code_present": bool(indicator & 0x01),
            "ssn_present": bool(indicator & 0x02),
            "gt_indicator": (indicator >> 2) & 0x0F,
            "routing_indicator": (indicator >> 6) & 0x01
        }

        offset = 1

        if addr["point_code_present"] and len(data) >= offset + 2:
            addr["point_code"] = struct.unpack('<H', data[offset:offset+2])[0]
            offset += 2

        if addr["ssn_present"] and len(data) >= offset + 1:
            ssn = data[offset]
            addr["ssn"] = ssn
            addr["ssn_name"] = self.SSN_NAMES.get(ssn, f"Unknown({ssn})")
            offset += 1

        if addr["gt_indicator"] != 0 and offset < len(data):
            addr["global_title"] = self.parse_gt(data[offset:], addr["gt_indicator"])

        return addr

    def parse_udt(self, data):
        """Parse UDT (Unitdata) message"""
        if len(data) < 4:
            return None

        protocol_class = data[0]
        called_ptr = data[1]
        calling_ptr = data[2]
        data_ptr = data[3]

        result = {"protocol_class": protocol_class & 0x0F}

        # Parse Called Party Address
        if called_ptr > 0 and called_ptr + 1 < len(data):
            called_len = data[called_ptr]
            if called_ptr + 1 + called_len <= len(data):
                called_data = data[called_ptr + 1:called_ptr + 1 + called_len]
                result["called_party"] = self.parse_address(called_data)

        # Parse Calling Party Address
        calling_offset = calling_ptr + 1
        if calling_offset < len(data):
            calling_len = data[calling_offset]
            if calling_offset + 1 + calling_len <= len(data):
                calling_data = data[calling_offset + 1:calling_offset + 1 + calling_len]
                result["calling_party"] = self.parse_address(calling_data)

        return result

    def parse_message(self, data):
        """Parse SCCP message"""
        if len(data) < 1:
            return None

        msg_type = data[0]
        msg_type_name = self.MSG_TYPES.get(msg_type, f"Unknown(0x{msg_type:02X})")

        message = {
            "message_type": msg_type,
            "message_type_name": msg_type_name,
            "raw_hex": binascii.hexlify(data).decode()
        }

        if msg_type == 0x09:  # UDT
            udt = self.parse_udt(data[1:])
            if udt:
                message.update(udt)

        self.parsed.append(message)
        return message

    def display_message(self, message):
        """Display parsed SCCP message"""
        print(f"\n{'='*60}")
        print(f"SCCP Message: {message['message_type_name']}")
        print(f"{'='*60}")

        if "called_party" in message:
            cp = message["called_party"]
            print(f"\n  Called Party Address:")
            if "ssn_name" in cp:
                print(f"    SSN:            {cp['ssn']} ({cp['ssn_name']})")
            if "point_code" in cp:
                print(f"    Point Code:     {cp['point_code']}")
            if "global_title" in cp and "digits" in cp["global_title"]:
                print(f"    Global Title:   {cp['global_title']['digits']}")

        if "calling_party" in message:
            cp = message["calling_party"]
            print(f"\n  Calling Party Address:")
            if "ssn_name" in cp:
                print(f"    SSN:            {cp['ssn']} ({cp['ssn_name']})")
            if "point_code" in cp:
                print(f"    Point Code:     {cp['point_code']}")
            if "global_title" in cp and "digits" in cp["global_title"]:
                print(f"    Global Title:   {cp['global_title']['digits']}")

        print(f"{'='*60}")


if __name__ == "__main__":
    parser = SCCPParser()
    print("[*] SCCP Parser ready.")
    print("[*] Supported message types:")
    for code, name in sorted(parser.MSG_TYPES.items()):
        print(f"    0x{code:02X}: {name}")
PYEOF

    # Create MAP message parser
    cat > "$WORK_DIR/map_parser.py" << 'PYEOF'
#!/usr/bin/env python3
"""MAP (Mobile Application Part) Operation Code Reference"""

class MAPOperations:
    """SS7 MAP Operation Codes and Descriptions"""

    # MAP Operation Codes (based on 3GPP TS 29.002)
    OPERATIONS = {
        # Location Management
        2: {"name": "updateLocation", "category": "Location", "risk": "HIGH",
            "desc": "Update subscriber location in HLR"},
        3: {"name": "cancelLocation", "category": "Location", "risk": "HIGH",
            "desc": "Cancel subscriber location"},
        7: {"name": "insertSubscriberData", "category": "Subscription", "risk": "HIGH",
            "desc": "Insert subscriber data into VLR"},
        8: {"name": "deleteSubscriberData", "category": "Subscription", "risk": "HIGH",
            "desc": "Delete subscriber data from VLR"},

        # Handover
        28: {"name": "performHandover", "category": "Handover", "risk": "MEDIUM",
             "desc": "Perform handover operation"},
        29: {"name": "sendEndSignal", "category": "Handover", "risk": "LOW",
             "desc": "Send end signal for handover"},

        # Authentication
        14: {"name": "sendAuthenticationInfo", "category": "Auth", "risk": "CRITICAL",
             "desc": "Request authentication vectors from HLR"},
        56: {"name": "authenticationFailureReport", "category": "Auth", "risk": "MEDIUM",
             "desc": "Report authentication failure"},

        # IMEI check
        43: {"name": "checkIMEI", "category": "Equipment", "risk": "LOW",
             "desc": "Check IMEI in EIR"},

        # Subscriber info
        46: {"name": "sendRoutingInfo", "category": "Routing", "risk": "HIGH",
             "desc": "Get routing info (SRI) - used for call interception"},
        45: {"name": "sendRoutingInfoForSM", "category": "SMS", "risk": "HIGH",
             "desc": "Get routing info for SMS delivery"},
        47: {"name": "provideRoamingNumber", "category": "Routing", "risk": "HIGH",
             "desc": "Provide roaming number for call routing"},

        # SMS
        44: {"name": "forwardSM_MO", "category": "SMS", "risk": "HIGH",
             "desc": "Forward mobile-originated SMS"},
        46: {"name": "forwardSM_MT", "category": "SMS", "risk": "HIGH",
             "desc": "Forward mobile-terminated SMS"},
        66: {"name": "readyForSM", "category": "SMS", "risk": "LOW",
             "desc": "Indicate ready to receive SMS"},
        67: {"name": "reportSMDeliveryStatus", "category": "SMS", "risk": "MEDIUM",
             "desc": "Report SMS delivery status"},

        # Supplementary Services
        10: {"name": "registerSS", "category": "SS", "risk": "HIGH",
             "desc": "Register supplementary service"},
        11: {"name": "eraseSS", "category": "SS", "risk": "HIGH",
             "desc": "Erase supplementary service"},
        12: {"name": "activateSS", "category": "SS", "risk": "HIGH",
             "desc": "Activate supplementary service"},
        13: {"name": "deactivateSS", "category": "SS", "risk": "HIGH",
             "desc": "Deactivate supplementary service"},
        30: {"name": "registerPassword", "category": "SS", "risk": "HIGH",
             "desc": "Register SS password"},

        # USSD
        59: {"name": "processUnstructuredSS-Request", "category": "USSD", "risk": "MEDIUM",
             "desc": "Process USSD request"},
        60: {"name": "unstructuredSS-Request", "category": "USSD", "risk": "MEDIUM",
             "desc": "USSD request from network"},
        61: {"name": "unstructuredSS-Notify", "category": "USSD", "risk": "LOW",
             "desc": "USSD notification"},

        # Subscriber Information
        70: {"name": "provideSubscriberInfo", "category": "Info", "risk": "HIGH",
             "desc": "Get subscriber info (location, state)"},
        71: {"name": "anyTimeInterrogation", "category": "Info", "risk": "CRITICAL",
             "desc": "Real-time location query (ATI)"},
        72: {"name": "anyTimeSubscriptionInterrogation", "category": "Info", "risk": "HIGH",
             "desc": "Query subscription info anytime"},

        # Tracing
        48: {"name": "activateTraceMode", "category": "Trace", "risk": "CRITICAL",
             "desc": "Activate tracing on subscriber"},
        49: {"name": "deactivateTraceMode", "category": "Trace", "risk": "MEDIUM",
             "desc": "Deactivate subscriber tracing"},

        # CAMEL
        78: {"name": "provideSubscriberLocation", "category": "Location", "risk": "CRITICAL",
             "desc": "Get precise subscriber location"},
    }

    # Known attack patterns
    ATTACK_PATTERNS = {
        "location_tracking": {
            "operations": [71, 70, 78],
            "description": "Track subscriber location using ATI/PSI/PSL",
            "risk": "CRITICAL"
        },
        "sms_interception": {
            "operations": [45, 7],
            "description": "Intercept SMS by updating SM-RP-DA",
            "risk": "CRITICAL"
        },
        "call_interception": {
            "operations": [46, 7, 2],
            "description": "Intercept calls via SRI + updateLocation",
            "risk": "CRITICAL"
        },
        "dos_subscriber": {
            "operations": [3, 8],
            "description": "Deny service by canceling location/deleting data",
            "risk": "HIGH"
        },
        "imsi_discovery": {
            "operations": [45],
            "description": "Discover IMSI from phone number via SRI-SM",
            "risk": "HIGH"
        },
        "auth_vector_theft": {
            "operations": [14],
            "description": "Steal auth vectors for cloning",
            "risk": "CRITICAL"
        },
        "call_redirect": {
            "operations": [10, 12],
            "description": "Redirect calls via call forwarding SS",
            "risk": "HIGH"
        }
    }

    @classmethod
    def get_operation(cls, opcode):
        return cls.OPERATIONS.get(opcode)

    @classmethod
    def get_operations_by_category(cls, category):
        return {k: v for k, v in cls.OPERATIONS.items()
                if v["category"] == category}

    @classmethod
    def get_high_risk_operations(cls):
        return {k: v for k, v in cls.OPERATIONS.items()
                if v["risk"] in ("HIGH", "CRITICAL")}

    @classmethod
    def display_all(cls):
        print(f"\n{'='*80}")
        print(f"{'MAP Operation Codes':^80}")
        print(f"{'='*80}")
        print(f"{'OpCode':<8} {'Name':<40} {'Category':<12} {'Risk':<10}")
        print(f"{'-'*80}")

        for opcode, info in sorted(cls.OPERATIONS.items()):
            risk_color = {
                "CRITICAL": "\033[91m",
                "HIGH": "\033[93m",
                "MEDIUM": "\033[33m",
                "LOW": "\033[92m"
            }.get(info["risk"], "")

            print(f"  {opcode:<6} {info['name']:<40} {info['category']:<12} "
                  f"{risk_color}{info['risk']:<10}\033[0m")

    @classmethod
    def display_attacks(cls):
        print(f"\n{'='*80}")
        print(f"{'Known SS7/MAP Attack Patterns':^80}")
        print(f"{'='*80}")

        for name, attack in cls.ATTACK_PATTERNS.items():
            risk_color = "\033[91m" if attack["risk"] == "CRITICAL" else "\033[93m"
            print(f"\n  {risk_color}[{attack['risk']}]\033[0m {name}")
            print(f"    Description: {attack['description']}")
            ops = [cls.OPERATIONS.get(op, {}).get("name", str(op))
                   for op in attack["operations"]]
            print(f"    Operations:  {', '.join(ops)}")


if __name__ == "__main__":
    MAPOperations.display_all()
    print()
    MAPOperations.display_attacks()
PYEOF

    chmod +x "$WORK_DIR/m3ua_parser.py" "$WORK_DIR/sccp_parser.py" "$WORK_DIR/map_parser.py"
    success_msg "Custom SIGTRAN analysis tools created!"
}

#=====================================================================
# NETWORK RECONNAISSANCE
#=====================================================================

network_reconnaissance() {
    print_header "Network Reconnaissance"

    echo -e "${WHITE}  Select reconnaissance type:${NC}"
    echo ""
    echo -e "  ${CYAN}1)${NC} SIGTRAN Port Scan (SCTP)"
    echo -e "  ${CYAN}2)${NC} Diameter Port Scan"
    echo -e "  ${CYAN}3)${NC} SIP Port Scan"
    echo -e "  ${CYAN}4)${NC} Full Telecom Port Scan"
    echo -e "  ${CYAN}5)${NC} Host Discovery"
    echo -e "  ${CYAN}6)${NC} Service Enumeration"
    echo -e "  ${CYAN}7)${NC} SCTP Association Scan"
    echo -e "  ${CYAN}8)${NC} GTP Port Scan"
    echo -e "  ${CYAN}0)${NC} Back"
    echo ""
    prompt_msg "Select option: "
    read -r recon_choice

    case $recon_choice in
        1) sigtran_scan ;;
        2) diameter_scan ;;
        3) sip_scan ;;
        4) full_telecom_scan ;;
        5) host_discovery ;;
        6) service_enumeration ;;
        7) sctp_association_scan ;;
        8) gtp_scan ;;
        0) return ;;
        *) error_msg "Invalid option" ;;
    esac
}

sigtran_scan() {
    print_header "SIGTRAN Port Scan"

    prompt_msg "Enter target IP: "
    read -r target_ip

    if ! validate_ip "$target_ip"; then
        error_msg "Invalid IP address"
        return
    fi

    info_msg "Scanning SIGTRAN ports on $target_ip..."
    echo ""

    local sigtran_ports="2904,2905,2906,2907,2944,2945,3565,3868,4739,4740,14001"
    local result_file="$RESULTS_DIR/sigtran_scan_$(date +%Y%m%d_%H%M%S).txt"

    # Using nmap for SCTP scan
    echo -e "${WHITE}  SIGTRAN/SCTP Port Scan Results${NC}" | tee "$result_file"
    echo -e "${WHITE}  Target: $target_ip${NC}" | tee -a "$result_file"
    echo -e "${WHITE}  Date: $(date)${NC}" | tee -a "$result_file"
    print_separator | tee -a "$result_file"

    if command -v nmap &>/dev/null; then
        # TCP scan as fallback (SCTP requires raw sockets)
        nmap -sT -p "$sigtran_ports" -sV --open "$target_ip" 2>/dev/null | tee -a "$result_file"

        echo "" | tee -a "$result_file"
        info_msg "Attempting SCTP scan (may require root)..."
        nmap -sY -p "$sigtran_ports" "$target_ip" 2>/dev/null | tee -a "$result_file"
    fi

    # Also try with custom scanner
    if [ -f "$WORK_DIR/sctp_scanner.py" ]; then
        echo "" | tee -a "$result_file"
        info_msg "Running custom SCTP scanner..."
        python "$WORK_DIR/sctp_scanner.py" "$target_ip" --sigtran 2>/dev/null | tee -a "$result_file"
    fi

    success_msg "Results saved to: $result_file"
}

diameter_scan() {
    print_header "Diameter Protocol Scan"

    prompt_msg "Enter target IP: "
    read -r target_ip

    if ! validate_ip "$target_ip"; then
        error_msg "Invalid IP address"
        return
    fi

    info_msg "Scanning Diameter ports on $target_ip..."

    local diameter_ports="3868,3869,3870,5868"
    local result_file="$RESULTS_DIR/diameter_scan_$(date +%Y%m%d_%H%M%S).txt"

    echo "Diameter Protocol Scan Results" > "$result_file"
    echo "Target: $target_ip" >> "$result_file"
    echo "Date: $(date)" >> "$result_file"
    echo "---" >> "$result_file"

    if command -v nmap &>/dev/null; then
        nmap -sT -p "$diameter_ports" -sV --open "$target_ip" 2>/dev/null | tee -a "$result_file"
    else
        # Manual port check
        for port in 3868 3869 3870 5868; do
            (echo >/dev/tcp/"$target_ip"/"$port") 2>/dev/null && \
                echo "  [+] Port $port: OPEN" | tee -a "$result_file" || \
                echo "  [-] Port $port: CLOSED" | tee -a "$result_file"
        done
    fi

    success_msg "Results saved to: $result_file"
}

sip_scan() {
    print_header "SIP Protocol Scan"

    prompt_msg "Enter target IP: "
    read -r target_ip

    if ! validate_ip "$target_ip"; then
        error_msg "Invalid IP address"
        return
    fi

    info_msg "Scanning SIP ports on $target_ip..."

    local result_file="$RESULTS_DIR/sip_scan_$(date +%Y%m%d_%H%M%S).txt"

    echo "SIP Protocol Scan Results" > "$result_file"
    echo "Target: $target_ip" >> "$result_file"

    local sip_ports="5060,5061,5062,5160,5161"

    if command -v nmap &>/dev/null; then
        nmap -sT -sU -p "$sip_ports" -sV --open "$target_ip" 2>/dev/null | tee -a "$result_file"
    fi

    # SIP OPTIONS probe
    info_msg "Sending SIP OPTIONS probe..."
    local sip_options="OPTIONS sip:test@${target_ip} SIP/2.0\r\n"
    sip_options+="Via: SIP/2.0/UDP 127.0.0.1:5060;branch=z9hG4bK-test\r\n"
    sip_options+="From: <sip:scanner@127.0.0.1>;tag=test123\r\n"
    sip_options+="To: <sip:test@${target_ip}>\r\n"
    sip_options+="Call-ID: test-scan@127.0.0.1\r\n"
    sip_options+="CSeq: 1 OPTIONS\r\n"
    sip_options+="Max-Forwards: 70\r\n"
    sip_options+="Content-Length: 0\r\n\r\n"

    echo -e "$sip_options" | nc -u -w 3 "$target_ip" 5060 2>/dev/null | tee -a "$result_file"

    success_msg "Results saved to: $result_file"
}

full_telecom_scan() {
    print_header "Full Telecom Port Scan"

    prompt_msg "Enter target IP: "
    read -r target_ip

    if ! validate_ip "$target_ip"; then
        error_msg "Invalid IP address"
        return
    fi

    local result_file="$RESULTS_DIR/full_telecom_scan_$(date +%Y%m%d_%H%M%S).txt"

    info_msg "Running comprehensive telecom port scan..."
    echo ""

    cat > "$result_file" << EOF
Full Telecom Port Scan Results
Target: $target_ip
Date: $(date)
==========================================
EOF

    # All telecom-related ports
    local telecom_ports=(
        "2427:MGCP"
        "2727:MGCP-GW"
        "2904:M2UA"
        "2905:M3UA"
        "2906:IUA"
        "2907:SUA"
        "2944:Megaco-H248"
        "2945:Megaco-H248-TLS"
        "3565:M2PA"
        "3868:Diameter"
        "3869:Diameter-TLS"
        "4739:IPFIX"
        "5060:SIP"
        "5061:SIP-TLS"
        "5090:SIP-ALT"
        "6000:X11"
        "7626:SIMalliance"
        "8080:HTTP-Proxy"
        "8443:HTTPS-Alt"
        "14001:SUA-ALT"
        "29118:SGsAP"
        "29168:SLs"
        "36412:S1AP"
        "36422:X2AP"
        "36443:M3AP"
        "36462:Xw-AP"
        "38412:NGAP"
        "38422:XnAP"
        "38462:E1AP"
        "38472:F1AP"
        "2123:GTPv1-C"
        "2152:GTPv1-U"
        "3386:GTPv0"
    )

    echo -e "${WHITE}  PORT      SERVICE         STATUS${NC}"
    print_separator

    for entry in "${telecom_ports[@]}"; do
        local port="${entry%%:*}"
        local service="${entry##*:}"

        local status="CLOSED"
        if (echo >/dev/tcp/"$target_ip"/"$port") 2>/dev/null; then
            status="OPEN"
            echo -e "  ${GREEN}${port}/tcp   ${service}$(printf '%*s' $((16-${#service})) '')${status}${NC}" | tee -a "$result_file"
        fi
    done

    echo "" | tee -a "$result_file"

    # Nmap comprehensive scan
    if command -v nmap &>/dev/null; then
        info_msg "Running nmap service detection..."
        local port_list=$(echo "${telecom_ports[@]}" | tr ' ' '\n' | cut -d: -f1 | tr '\n' ',' | sed 's/,$//')
        nmap -sT -sV -p "$port_list" --open "$target_ip" 2>/dev/null >> "$result_file"
    fi

    success_msg "Results saved to: $result_file"
}

host_discovery() {
    print_header "Host Discovery"

    prompt_msg "Enter network range (e.g., 192.168.1.0/24): "
    read -r network

    local result_file="$RESULTS_DIR/host_discovery_$(date +%Y%m%d_%H%M%S).txt"

    info_msg "Discovering hosts on $network..."

    if command -v nmap &>/dev/null; then
        nmap -sn "$network" 2>/dev/null | tee "$result_file"
    else
        # Manual ping sweep
        local base_ip="${network%.*}"
        for i in $(seq 1 254); do
            ping -c 1 -W 1 "${base_ip}.${i}" &>/dev/null && \
                echo "  [+] ${base_ip}.${i} is UP" | tee -a "$result_file" &
        done
        wait
    fi

    success_msg "Results saved to: $result_file"
}

service_enumeration() {
    print_header "Service Enumeration"

    prompt_msg "Enter target IP: "
    read -r target_ip

    if ! validate_ip "$target_ip"; then
        error_msg "Invalid IP address"
        return
    fi

    local result_file="$RESULTS_DIR/service_enum_$(date +%Y%m%d_%H%M%S).txt"

    info_msg "Enumerating services on $target_ip..."

    if command -v nmap &>/dev/null; then
        nmap -sT -sV -O -A -p 1-10000 "$target_ip" 2>/dev/null | tee "$result_file"
    fi

    success_msg "Results saved to: $result_file"
}

sctp_association_scan() {
    print_header "SCTP Association Scan"

    prompt_msg "Enter target IP: "
    read -r target_ip

    if ! validate_ip "$target_ip"; then
        error_msg "Invalid IP address"
        return
    fi

    local result_file="$RESULTS_DIR/sctp_assoc_$(date +%Y%m%d_%H%M%S).txt"

    info_msg "Scanning SCTP associations on $target_ip..."

    if command -v nmap &>/dev/null; then
        nmap -sY -p 1-10000 "$target_ip" 2>/dev/null | tee "$result_file"
    fi

    if [ -f "$WORK_DIR/sctp_scanner.py" ]; then
        python "$WORK_DIR/sctp_scanner.py" "$target_ip" -p 1-10000 2>/dev/null | tee -a "$result_file"
    fi

    success_msg "Results saved to: $result_file"
}

gtp_scan() {
    print_header "GTP Port Scan"

    prompt_msg "Enter target IP: "
    read -r target_ip

    if ! validate_ip "$target_ip"; then
        error_msg "Invalid IP address"
        return
    fi

    local result_file="$RESULTS_DIR/gtp_scan_$(date +%Y%m%d_%H%M%S).txt"

    info_msg "Scanning GTP ports on $target_ip..."

    local gtp_ports="2123,2152,3386"

    if command -v nmap &>/dev/null; then
        # GTP uses UDP
        nmap -sU -p "$gtp_ports" -sV "$target_ip" 2>/dev/null | tee "$result_file"
    fi

    # Manual GTP-C echo request
    info_msg "Sending GTP Echo Request..."

    python3 << GPYEOF | tee -a "$result_file"
import socket
import struct
import sys

def create_gtp_echo_request():
    """Create GTPv1-C Echo Request"""
    version_flags = 0x32  # Version 1, PT=1, E=0, S=1, PN=0
    msg_type = 1          # Echo Request
    length = 4            # Length of payload
    teid = 0              # TEID
    seq_num = 1           # Sequence number
    npdu = 0
    next_ext = 0

    header = struct.pack('!BBHI', version_flags, msg_type, length, teid)
    header += struct.pack('!HBB', seq_num, npdu, next_ext)
    return header

target = "$target_ip"
ports = [2123, 2152, 3386]

for port in ports:
    try:
        sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        sock.settimeout(3)
        packet = create_gtp_echo_request()
        sock.sendto(packet, (target, port))
        try:
            data, addr = sock.recvfrom(1024)
            print(f"  [+] GTP response from {addr[0]}:{addr[1]} ({len(data)} bytes)")
            if len(data) >= 2 and data[1] == 2:
                print(f"      Echo Response received!")
        except socket.timeout:
            print(f"  [-] No GTP response on port {port}")
        sock.close()
    except Exception as e:
        print(f"  [!] Error scanning port {port}: {e}")
GPYEOF

    success_msg "Results saved to: $result_file"
}

#=====================================================================
# PROTOCOL ANALYSIS
#=====================================================================

protocol_analysis() {
    print_header "Protocol Analysis"

    echo -e "${WHITE}  Select analysis type:${NC}"
    echo ""
    echo -e "  ${CYAN}1)${NC}  M3UA Message Parser"
    echo -e "  ${CYAN}2)${NC}  SCCP Message Parser"
    echo -e "  ${CYAN}3)${NC}  MAP Operation Reference"
    echo -e "  ${CYAN}4)${NC}  PCAP File Analysis"
    echo -e "  ${CYAN}5)${NC}  Live Capture Analysis"
    echo -e "  ${CYAN}6)${NC}  TCAP Decoder"
    echo -e "  ${CYAN}7)${NC}  ASN.1 Decoder"
    echo -e "  ${CYAN}8)${NC}  Protocol Statistics"
    echo -e "  ${CYAN}9)${NC}  Hex Packet Decoder"
    echo -e "  ${CYAN}10)${NC} Point Code Calculator"
    echo -e "  ${CYAN}0)${NC}  Back"
    echo ""
    prompt_msg "Select option: "
    read -r analysis_choice

    case $analysis_choice in
        1) run_m3ua_parser ;;
        2) run_sccp_parser ;;
        3) run_map_reference ;;
        4) pcap_analysis ;;
        5) live_capture ;;
        6) tcap_decoder ;;
        7) asn1_decoder ;;
        8) protocol_stats ;;
        9) hex_decoder ;;
        10) point_code_calc ;;
        0) return ;;
        *) error_msg "Invalid option" ;;
    esac
}

run_m3ua_parser() {
    print_header "M3UA Message Parser"

    if [ ! -f "$WORK_DIR/m3ua_parser.py" ]; then
        error_msg "M3UA parser not found. Install SIGTRAN tools first."
        return
    fi

    echo -e "  ${CYAN}1)${NC} Parse hex input"
    echo -e "  ${CYAN}2)${NC} Parse from file"
    echo -e "  ${CYAN}3)${NC} Interactive mode"
    echo ""
    prompt_msg "Select option: "
    read -r m3ua_opt

    case $m3ua_opt in
        1)
            prompt_msg "Enter M3UA hex data: "
            read -r hex_data
            python3 -c "
from m3ua_parser import M3UAParser
import binascii
parser = M3UAParser()
data = binascii.unhexlify('$hex_data')
msg = parser.parse_message(data)
if msg:
    parser.display_message(msg)
" 2>/dev/null
            ;;
        2)
            prompt_msg "Enter file path: "
            read -r file_path
            if [ -f "$file_path" ]; then
                python3 "$WORK_DIR/m3ua_parser.py" < "$file_path"
            else
                error_msg "File not found"
            fi
            ;;
        3)
            cd "$WORK_DIR" && python3 "$WORK_DIR/m3ua_parser.py"
            ;;
    esac
}

run_sccp_parser() {
    print_header "SCCP Message Parser"

    if [ ! -f "$WORK_DIR/sccp_parser.py" ]; then
        error_msg "SCCP parser not found. Install SIGTRAN tools first."
        return
    fi

    cd "$WORK_DIR" && python3 "$WORK_DIR/sccp_parser.py"
}

run_map_reference() {
    print_header "MAP Operation Reference"

    if [ ! -f "$WORK_DIR/map_parser.py" ]; then
        error_msg "MAP parser not found. Install SIGTRAN tools first."
        return
    fi

    echo -e "  ${CYAN}1)${NC} Show all operations"
    echo -e "  ${CYAN}2)${NC} Show attack patterns"
    echo -e "  ${CYAN}3)${NC} Show high-risk operations"
    echo -e "  ${CYAN}4)${NC} Lookup operation code"
    echo ""
    prompt_msg "Select option: "
    read -r map_opt

    cd "$WORK_DIR"

    case $map_opt in
        1)
            python3 -c "from map_parser import MAPOperations; MAPOperations.display_all()"
            ;;
        2)
            python3 -c "from map_parser import MAPOperations; MAPOperations.display_attacks()"
            ;;
        3)
            python3 -c "
from map_parser import MAPOperations
ops = MAPOperations.get_high_risk_operations()
print('\nHigh-Risk MAP Operations:')
print('='*60)
for code, info in sorted(ops.items()):
    print(f'  {code:3d}: {info[\"name\"]:40s} [{info[\"risk\"]}]')
    print(f'       {info[\"desc\"]}')
"
            ;;
        4)
            prompt_msg "Enter operation code: "
            read -r opcode
            python3 -c "
from map_parser import MAPOperations
op = MAPOperations.get_operation($opcode)
if op:
    print(f'\nOperation Code: $opcode')
    print(f'Name:     {op[\"name\"]}')
    print(f'Category: {op[\"category\"]}')
    print(f'Risk:     {op[\"risk\"]}')
    print(f'Desc:     {op[\"desc\"]}')
else:
    print('Operation not found')
" 2>/dev/null
            ;;
    esac
}

pcap_analysis() {
    print_header "PCAP File Analysis"

    prompt_msg "Enter PCAP file path: "
    read -r pcap_file

    if [ ! -f "$pcap_file" ]; then
        error_msg "File not found: $pcap_file"
        return
    fi

    local result_file="$RESULTS_DIR/pcap_analysis_$(date +%Y%m%d_%H%M%S).txt"

    echo -e "  ${CYAN}1)${NC} Full protocol decode"
    echo -e "  ${CYAN}2)${NC} SIGTRAN messages only"
    echo -e "  ${CYAN}3)${NC} SS7/MAP messages only"
    echo -e "  ${CYAN}4)${NC} Diameter messages only"
    echo -e "  ${CYAN}5)${NC} SIP messages only"
    echo -e "  ${CYAN}6)${NC} Statistics"
    echo ""
    prompt_msg "Select option: "
    read -r pcap_opt

    if command -v tshark &>/dev/null; then
        case $pcap_opt in
            1)
                tshark -r "$pcap_file" -V 2>/dev/null | tee "$result_file"
                ;;
            2)
                tshark -r "$pcap_file" -Y "m3ua or m2ua or sua or iua" -V 2>/dev/null | tee "$result_file"
                ;;
            3)
                tshark -r "$pcap_file" -Y "gsm_map or sccp or tcap" -V 2>/dev/null | tee "$result_file"
                ;;
            4)
                tshark -r "$pcap_file" -Y "diameter" -V 2>/dev/null | tee "$result_file"
                ;;
            5)
                tshark -r "$pcap_file" -Y "sip" -V 2>/dev/null | tee "$result_file"
                ;;
            6)
                tshark -r "$pcap_file" -z io,phs 2>/dev/null | tee "$result_file"
                tshark -r "$pcap_file" -z conv,sctp 2>/dev/null | tee -a "$result_file"
                ;;
        esac
    else
        error_msg "tshark not installed. Install wireshark-cli."
    fi

    success_msg "Results saved to: $result_file"
}

live_capture() {
    print_header "Live Capture Analysis"

    info_msg "Available interfaces:"
    if command -v ip &>/dev/null; then
        ip link show 2>/dev/null | grep -E "^[0-9]" | awk -F: '{print "  " $2}'
    fi

    prompt_msg "Enter interface (default: any): "
    read -r interface
    interface=${interface:-any}

    prompt_msg "Enter capture filter (e.g., 'port 2905', or press Enter for all): "
    read -r capture_filter

    prompt_msg "Capture duration in seconds (default: 30): "
    read -r duration
    duration=${duration:-30}

    local pcap_file="$PCAP_DIR/capture_$(date +%Y%m%d_%H%M%S).pcap"

    info_msg "Starting capture on $interface for $duration seconds..."

    if command -v tshark &>/dev/null; then
        if [ -n "$capture_filter" ]; then
            timeout "$duration" tshark -i "$interface" -f "$capture_filter" -w "$pcap_file" 2>/dev/null &
        else
            timeout "$duration" tshark -i "$interface" -w "$pcap_file" 2>/dev/null &
        fi

        local cap_pid=$!
        local elapsed=0
        while [ $elapsed -lt "$duration" ] && kill -0 $cap_pid 2>/dev/null; do
            progress_bar $elapsed "$duration"
            sleep 1
            ((elapsed++))
        done
        progress_bar "$duration" "$duration"

        wait $cap_pid 2>/dev/null
        echo ""
        success_msg "Capture saved to: $pcap_file"

        prompt_msg "Analyze capture now? (y/n): "
        read -r analyze
        if [[ "$analyze" =~ ^[Yy]$ ]]; then
            pcap_file_for_analysis="$pcap_file"
            tshark -r "$pcap_file" -V 2>/dev/null | head -100
        fi
    else
        error_msg "tshark not installed"
    fi
}

tcap_decoder() {
    print_header "TCAP Decoder"

    cat > /tmp/tcap_decode.py << 'PYEOF'
#!/usr/bin/env python3
"""TCAP (Transaction Capabilities Application Part) Decoder"""

import struct
import binascii

class TCAPDecoder:
    """Decode TCAP messages"""

    # TCAP Message Types
    MSG_TYPES = {
        0x60: "Begin (Originating Transaction)",
        0x61: "End (Response/Ending)",
        0x62: "Continue",
        0x63: "Abort",
        0x64: "Unidirectional"
    }

    # Component Types
    COMPONENT_TYPES = {
        0xA1: "Invoke",
        0xA2: "Return Result (Last)",
        0xA3: "Return Error",
        0xA4: "Reject",
        0xA7: "Return Result (Not Last)"
    }

    def decode_length(self, data, offset):
        """Decode ASN.1 BER length"""
        if offset >= len(data):
            return 0, offset + 1

        first_byte = data[offset]
        if first_byte < 0x80:
            return first_byte, offset + 1
        elif first_byte == 0x81:
            if offset + 1 < len(data):
                return data[offset + 1], offset + 2
        elif first_byte == 0x82:
            if offset + 2 < len(data):
                return struct.unpack('!H', data[offset+1:offset+3])[0], offset + 3
        return 0, offset + 1

    def decode_tag(self, data, offset):
        """Decode ASN.1 tag"""
        if offset >= len(data):
            return None, 0, offset

        tag = data[offset]
        length, new_offset = self.decode_length(data, offset + 1)
        return tag, length, new_offset

    def decode(self, data):
        """Decode TCAP message"""
        if len(data) < 2:
            return None

        result = {}
        offset = 0

        # Message Type
        msg_type = data[offset]
        result["message_type"] = msg_type
        result["message_type_name"] = self.MSG_TYPES.get(msg_type,
                                       f"Unknown(0x{msg_type:02X})")

        msg_len, offset = self.decode_length(data, offset + 1)
        result["message_length"] = msg_len

        # Transaction ID
        if offset < len(data) and data[offset] in (0x48, 0x49, 0x4A):
            tid_tag = data[offset]
            tid_len, offset = self.decode_length(data, offset + 1)
            if offset + tid_len <= len(data):
                tid = data[offset:offset + tid_len]
                result["transaction_id"] = binascii.hexlify(tid).decode()
                offset += tid_len

        # Dialogue Portion (optional, tag 0x6B)
        if offset < len(data) and data[offset] == 0x6B:
            dial_len, offset = self.decode_length(data, offset + 1)
            result["dialogue_portion"] = binascii.hexlify(
                data[offset:offset+dial_len]).decode()
            offset += dial_len

        # Component Portion (tag 0x6C)
        if offset < len(data) and data[offset] == 0x6C:
            comp_len, offset = self.decode_length(data, offset + 1)
            result["components"] = []

            comp_end = offset + comp_len
            while offset < comp_end and offset < len(data):
                comp_type = data[offset]
                c_len, offset = self.decode_length(data, offset + 1)

                component = {
                    "type": comp_type,
                    "type_name": self.COMPONENT_TYPES.get(comp_type,
                                  f"Unknown(0x{comp_type:02X})"),
                    "length": c_len
                }

                # Invoke ID
                if offset < len(data) and data[offset] == 0x02:
                    inv_len, inv_off = self.decode_length(data, offset + 1)
                    if inv_off + inv_len <= len(data):
                        component["invoke_id"] = data[inv_off]
                        offset = inv_off + inv_len

                # Operation Code
                if offset < len(data) and data[offset] == 0x02:
                    op_len, op_off = self.decode_length(data, offset + 1)
                    if op_off + op_len <= len(data):
                        component["operation_code"] = data[op_off]
                        offset = op_off + op_len

                result["components"].append(component)
                offset = min(offset + c_len, comp_end)

        return result

    def display(self, result):
        """Display decoded TCAP message"""
        if not result:
            print("  [!] Could not decode message")
            return

        print(f"\n  {'='*50}")
        print(f"  TCAP Message Decode")
        print(f"  {'='*50}")
        print(f"  Type:           {result.get('message_type_name', 'Unknown')}")
        print(f"  Transaction ID: {result.get('transaction_id', 'N/A')}")

        for comp in result.get("components", []):
            print(f"\n  Component: {comp['type_name']}")
            if "invoke_id" in comp:
                print(f"    Invoke ID:      {comp['invoke_id']}")
            if "operation_code" in comp:
                print(f"    Operation Code: {comp['operation_code']}")

        print(f"  {'='*50}")


decoder = TCAPDecoder()
print("[*] TCAP Decoder ready")
print("[*] Enter hex-encoded TCAP data (or 'quit' to exit):")

while True:
    try:
        hex_input = input("\n  TCAP> ").strip()
        if hex_input.lower() in ('quit', 'exit', 'q'):
            break
        if hex_input:
            data = binascii.unhexlify(hex_input.replace(' ', ''))
            result = decoder.decode(data)
            decoder.display(result)
    except (ValueError, KeyboardInterrupt):
        break
PYEOF

    python3 /tmp/tcap_decode.py
    rm -f /tmp/tcap_decode.py
}

asn1_decoder() {
    print_header "ASN.1 BER/DER Decoder"

    cat > /tmp/asn1_decode.py << 'PYEOF'
#!/usr/bin/env python3
"""ASN.1 BER/DER Decoder for SS7 messages"""

import binascii
import struct

class ASN1Decoder:
    TAG_CLASSES = {0: "Universal", 1: "Application", 2: "Context-specific", 3: "Private"}
    UNIVERSAL_TAGS = {
        1: "BOOLEAN", 2: "INTEGER", 3: "BIT STRING", 4: "OCTET STRING",
        5: "NULL", 6: "OBJECT IDENTIFIER", 10: "ENUMERATED",
        12: "UTF8String", 16: "SEQUENCE", 17: "SET",
        19: "PrintableString", 22: "IA5String", 23: "UTCTime"
    }

    def decode(self, data, offset=0, depth=0):
        """Recursively decode ASN.1 BER data"""
        results = []
        while offset < len(data):
            if offset >= len(data):
                break

            # Tag
            tag_byte = data[offset]
            tag_class = (tag_byte >> 6) & 0x03
            constructed = bool(tag_byte & 0x20)
            tag_number = tag_byte & 0x1F

            if tag_number == 0x1F:  # Long form
                tag_number = 0
                offset += 1
                while offset < len(data):
                    tag_number = (tag_number << 7) | (data[offset] & 0x7F)
                    if not (data[offset] & 0x80):
                        break
                    offset += 1

            offset += 1

            # Length
            if offset >= len(data):
                break
            length_byte = data[offset]
            offset += 1

            if length_byte < 0x80:
                length = length_byte
            elif length_byte == 0x80:
                length = -1  # Indefinite
            else:
                num_bytes = length_byte & 0x7F
                length = int.from_bytes(data[offset:offset+num_bytes], 'big')
                offset += num_bytes

            if length < 0 or offset + length > len(data):
                break

            value = data[offset:offset+length]

            # Build info
            indent = "  " * depth
            tag_class_name = self.TAG_CLASSES.get(tag_class, "?")
            if tag_class == 0:
                tag_name = self.UNIVERSAL_TAGS.get(tag_number, f"Tag({tag_number})")
            else:
                tag_name = f"[{tag_number}]"

            entry = {
                "depth": depth,
                "tag_byte": tag_byte,
                "tag_class": tag_class_name,
                "tag_name": tag_name,
                "tag_number": tag_number,
                "constructed": constructed,
                "length": length,
                "offset": offset,
            }

            print(f"{indent}├─ {tag_name} ({tag_class_name}, "
                  f"{'constructed' if constructed else 'primitive'}) "
                  f"[len={length}]", end="")

            if constructed and length > 0:
                print()
                self.decode(value, 0, depth + 1)
            else:
                if tag_number == 2 and tag_class == 0:  # INTEGER
                    val = int.from_bytes(value, 'big', signed=True)
                    print(f" = {val}")
                elif tag_number == 4 and tag_class == 0:  # OCTET STRING
                    print(f" = {binascii.hexlify(value).decode()}")
                elif tag_number == 6 and tag_class == 0:  # OID
                    print(f" = {self.decode_oid(value)}")
                elif tag_number == 1 and tag_class == 0:  # BOOLEAN
                    print(f" = {bool(value[0]) if value else 'empty'}")
                else:
                    hex_val = binascii.hexlify(value).decode()
                    print(f" = {hex_val[:60]}{'...' if len(hex_val) > 60 else ''}")

            results.append(entry)
            offset += length

        return results

    def decode_oid(self, data):
        """Decode Object Identifier"""
        if not data:
            return ""
        values = [data[0] // 40, data[0] % 40]
        val = 0
        for byte in data[1:]:
            val = (val << 7) | (byte & 0x7F)
            if not (byte & 0x80):
                values.append(val)
                val = 0
        return ".".join(str(v) for v in values)


decoder = ASN1Decoder()
print("[*] ASN.1 BER/DER Decoder")
print("[*] Enter hex data (or 'quit' to exit):")

while True:
    try:
        hex_input = input("\n  ASN1> ").strip()
        if hex_input.lower() in ('quit', 'exit', 'q'):
            break
        if hex_input:
            data = binascii.unhexlify(hex_input.replace(' ', ''))
            print(f"\n  Decoding {len(data)} bytes:")
            print(f"  {'─'*50}")
            decoder.decode(data)
    except (ValueError, KeyboardInterrupt):
        break
PYEOF

    python3 /tmp/asn1_decode.py
    rm -f /tmp/asn1_decode.py
}

protocol_stats() {
    print_header "Protocol Statistics"

    prompt_msg "Enter PCAP file path: "
    read -r pcap_file

    if [ ! -f "$pcap_file" ]; then
        error_msg "File not found"
        return
    fi

    local result_file="$RESULTS_DIR/protocol_stats_$(date +%Y%m%d_%H%M%S).txt"

    if command -v tshark &>/dev/null; then
        echo "=== Protocol Hierarchy ===" | tee "$result_file"
        tshark -r "$pcap_file" -z io,phs 2>/dev/null | tee -a "$result_file"

        echo "" | tee -a "$result_file"
        echo "=== Conversation Statistics ===" | tee -a "$result_file"
        tshark -r "$pcap_file" -z conv,ip 2>/dev/null | tee -a "$result_file"

        echo "" | tee -a "$result_file"
        echo "=== SCTP Statistics ===" | tee -a "$result_file"
        tshark -r "$pcap_file" -z sctp,stat 2>/dev/null | tee -a "$result_file"

        echo "" | tee -a "$result_file"
        echo "=== Endpoint Statistics ===" | tee -a "$result_file"
        tshark -r "$pcap_file" -z endpoints,ip 2>/dev/null | tee -a "$result_file"

        success_msg "Statistics saved to: $result_file"
    else
        error_msg "tshark not installed"
    fi
}

hex_decoder() {
    print_header "Hex Packet Decoder"

    prompt_msg "Enter hex data: "
    read -r hex_data

    # Remove spaces
    hex_data=$(echo "$hex_data" | tr -d ' ')

    if [ -z "$hex_data" ]; then
        error_msg "No data provided"
        return
    fi

    python3 << PYEOF
import binascii
import struct

data = binascii.unhexlify("$hex_data")

print(f"\n  Raw Data ({len(data)} bytes):")
print(f"  {'─'*60}")

# Hex dump
offset = 0
while offset < len(data):
    hex_part = ""
    ascii_part = ""
    for i in range(16):
        if offset + i < len(data):
            hex_part += f"{data[offset+i]:02X} "
            ch = data[offset+i]
            ascii_part += chr(ch) if 32 <= ch < 127 else "."
        else:
            hex_part += "   "
    print(f"  {offset:04X}  {hex_part}  |{ascii_part}|")
    offset += 16

print(f"\n  {'─'*60}")

# Try to identify protocol
if len(data) >= 8:
    # Check for M3UA
    if data[0] == 0x01 and data[1] == 0x00:
        msg_class = data[2]
        msg_type = data[3]
        length = struct.unpack('!I', data[4:8])[0]
        print(f"  Possible M3UA: Class={msg_class} Type={msg_type} Length={length}")

    # Check for SCCP
    if data[0] in (0x09, 0x0A, 0x11, 0x12, 0x01, 0x02):
        sccp_types = {
            0x09: "UDT", 0x0A: "UDTS", 0x11: "XUDT",
            0x12: "XUDTS", 0x01: "CR", 0x02: "CC"
        }
        print(f"  Possible SCCP: {sccp_types.get(data[0], 'Unknown')}")

    # Check for TCAP
    if data[0] in (0x60, 0x61, 0x62, 0x63, 0x64):
        tcap_types = {
            0x60: "Begin", 0x61: "End", 0x62: "Continue",
            0x63: "Abort", 0x64: "Unidirectional"
        }
        print(f"  Possible TCAP: {tcap_types.get(data[0], 'Unknown')}")
PYEOF
}

point_code_calc() {
    print_header "SS7 Point Code Calculator"

    cat > /tmp/pc_calc.py << 'PYEOF'
#!/usr/bin/env python3
"""SS7 Point Code Calculator"""

class PointCodeCalculator:
    """Convert between different point code formats"""

    @staticmethod
    def int_to_383(value):
        """Convert integer to ITU 3-8-3 format"""
        zone = (value >> 11) & 0x07
        area = (value >> 3) & 0xFF
        sp = value & 0x07
        return f"{zone}-{area}-{sp}"

    @staticmethod
    def int_to_14bit(value):
        """Convert to 14-bit ITU format"""
        return value & 0x3FFF

    @staticmethod
    def int_to_ansi(value):
        """Convert to ANSI 8-8-8 format"""
        network = (value >> 16) & 0xFF
        cluster = (value >> 8) & 0xFF
        member = value & 0xFF
        return f"{network}-{cluster}-{member}"

    @staticmethod
    def parse_383(pc_str):
        """Parse ITU 3-8-3 format to integer"""
        parts = pc_str.split('-')
        if len(parts) == 3:
            zone, area, sp = int(parts[0]), int(parts[1]), int(parts[2])
            return (zone << 11) | (area << 3) | sp
        return None

    @staticmethod
    def parse_ansi(pc_str):
        """Parse ANSI 8-8-8 format to integer"""
        parts = pc_str.split('-')
        if len(parts) == 3:
            network, cluster, member = int(parts[0]), int(parts[1]), int(parts[2])
            return (network << 16) | (cluster << 8) | member
        return None

    def interactive(self):
        print("[*] SS7 Point Code Calculator")
        print("[*] Formats: ITU (3-8-3), ANSI (8-8-8), Integer")
        print()

        while True:
            print("  1) Integer → ITU 3-8-3")
            print("  2) Integer → ANSI 8-8-8")
            print("  3) ITU 3-8-3 → Integer")
            print("  4) ANSI 8-8-8 → Integer")
            print("  5) Full conversion")
            print("  0) Exit")

            choice = input("\n  PC> ").strip()

            if choice == "0":
                break
            elif choice == "1":
                val = int(input("  Enter integer value: "))
                print(f"  ITU 3-8-3: {self.int_to_383(val)}")
            elif choice == "2":
                val = int(input("  Enter integer value: "))
                print(f"  ANSI 8-8-8: {self.int_to_ansi(val)}")
            elif choice == "3":
                pc = input("  Enter ITU PC (x-x-x): ")
                val = self.parse_383(pc)
                print(f"  Integer: {val} (0x{val:04X})" if val else "  Invalid format")
            elif choice == "4":
                pc = input("  Enter ANSI PC (x-x-x): ")
                val = self.parse_ansi(pc)
                print(f"  Integer: {val} (0x{val:06X})" if val else "  Invalid format")
            elif choice == "5":
                val = int(input("  Enter integer value: "))
                print(f"  Integer:    {val} (0x{val:06X})")
                print(f"  ITU 3-8-3:  {self.int_to_383(val)}")
                print(f"  ITU 14-bit: {self.int_to_14bit(val)}")
                print(f"  ANSI 8-8-8: {self.int_to_ansi(val)}")
                print(f"  Binary:     {val:024b}")
            print()

calc = PointCodeCalculator()
calc.interactive()
PYEOF

    python3 /tmp/pc_calc.py
    rm -f /tmp/pc_calc.py
}

#=====================================================================
# SS7 SECURITY ASSESSMENT
#=====================================================================

security_assessment() {
    print_header "SS7 Security Assessment"

    echo -e "${WHITE}  Select assessment type:${NC}"
    echo ""
    echo -e "  ${CYAN}1)${NC}  MAP Security Audit"
    echo -e "  ${CYAN}2)${NC}  SCCP Filter Test"
    echo -e "  ${CYAN}3)${NC}  Category Screening Check"
    echo -e "  ${CYAN}4)${NC}  Firewall Rule Analysis"
    echo -e "  ${CYAN}5)${NC}  Vulnerability Assessment Report"
    echo -e "  ${CYAN}6)${NC}  SMS Home Routing Check"
    echo -e "  ${CYAN}7)${NC}  TCAP Dialog Control Check"
    echo -e "  ${CYAN}8)${NC}  GT Filtering Analysis"
    echo -e "  ${CYAN}9)${NC}  Generate Security Report"
    echo -e "  ${CYAN}0)${NC}  Back"
    echo ""
    prompt_msg "Select option: "
    read -r sec_choice

    case $sec_choice in
        1) map_security_audit ;;
        2) sccp_filter_test ;;
        3) category_screening ;;
        4) firewall_analysis ;;
        5) vulnerability_report ;;
        6) sms_home_routing ;;
        7) tcap_dialog_check ;;
        8) gt_filtering ;;
        9) generate_security_report ;;
        0) return ;;
        *) error_msg "Invalid option" ;;
    esac
}

map_security_audit() {
    print_header "MAP Security Audit"

    local result_file="$RESULTS_DIR/map_audit_$(date +%Y%m%d_%H%M%S).txt"

    cat > /tmp/map_audit.py << 'PYEOF'
#!/usr/bin/env python3
"""MAP Security Audit Tool"""

import json
from datetime import datetime

class MAPSecurityAudit:
    """Audit MAP protocol security configuration"""

    CRITICAL_OPERATIONS = {
        "Category 1 - Location Tracking": {
            "operations": [
                (71, "anyTimeInterrogation", "Real-time location query"),
                (70, "provideSubscriberInfo", "Get subscriber info"),
                (78, "provideSubscriberLocation", "Precise location"),
            ],
            "recommendation": "Block from external networks. Only allow from authorized HLR/VLR."
        },
        "Category 2 - Subscriber Data Manipulation": {
            "operations": [
                (7, "insertSubscriberData", "Insert data into VLR"),
                (8, "deleteSubscriberData", "Delete data from VLR"),
                (2, "updateLocation", "Update subscriber location"),
                (3, "cancelLocation", "Cancel subscriber location"),
            ],
            "recommendation": "Strict source validation. Only from home HLR."
        },
        "Category 3 - Call/SMS Interception": {
            "operations": [
                (46, "sendRoutingInfo", "Get routing info for calls"),
                (45, "sendRoutingInfoForSM", "Get routing info for SMS"),
                (22, "sendRoutingInfoForGprs", "Get routing info for GPRS"),
            ],
            "recommendation": "Implement SRI filtering. Validate source GT."
        },
        "Category 4 - Authentication": {
            "operations": [
                (14, "sendAuthenticationInfo", "Request auth vectors"),
                (56, "authenticationFailureReport", "Auth failure report"),
            ],
            "recommendation": "Never allow from external networks."
        },
        "Category 5 - Service Manipulation": {
            "operations": [
                (10, "registerSS", "Register supplementary service"),
                (11, "eraseSS", "Erase supplementary service"),
                (12, "activateSS", "Activate supplementary service"),
                (13, "deactivateSS", "Deactivate supplementary service"),
            ],
            "recommendation": "Only allow through proper MSC procedures."
        }
    }

    def run_audit(self):
        """Run the MAP security audit"""
        print(f"\n{'='*70}")
        print(f"{'MAP PROTOCOL SECURITY AUDIT':^70}")
        print(f"{'='*70}")
        print(f"  Date: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
        print(f"{'='*70}")

        total_checks = 0
        results = []

        for category, data in self.CRITICAL_OPERATIONS.items():
            print(f"\n  \033[1m{category}\033[0m")
            print(f"  {'-'*60}")

            for opcode, name, desc in data["operations"]:
                total_checks += 1
                print(f"  [{opcode:3d}] {name:<40s}")
                print(f"        Description: {desc}")
                print(f"        \033[93mAction Required: Verify filtering\033[0m")

            print(f"\n  \033[92mRecommendation: {data['recommendation']}\033[0m")

        # Security checklist
        print(f"\n{'='*70}")
        print(f"{'SECURITY CHECKLIST':^70}")
        print(f"{'='*70}")

        checklist = [
            "SCCP Gateway Screening (CGS) configured",
            "MAP operation filtering enabled",
            "Global Title (GT) filtering active",
            "SMS Home Routing implemented",
            "SRI rate limiting configured",
            "ATI blocking for external networks",
            "Category-based filtering enabled",
            "Interconnect firewall deployed",
            "Real-time monitoring active",
            "Anomaly detection enabled",
            "GSMA IR.82 compliance verified",
            "Regular penetration testing scheduled"
        ]

        for i, item in enumerate(checklist, 1):
            print(f"  [{i:2d}] [ ] {item}")

        print(f"\n{'='*70}")
        print(f"  Total operation categories audited: {len(self.CRITICAL_OPERATIONS)}")
        print(f"  Total critical operations checked:  {total_checks}")
        print(f"{'='*70}")

audit = MAPSecurityAudit()
audit.run_audit()
PYEOF

    python3 /tmp/map_audit.py | tee "$result_file"
    rm -f /tmp/map_audit.py

    success_msg "Audit report saved to: $result_file"
}

sccp_filter_test() {
    print_header "SCCP Filter Test"

    info_msg "This test validates SCCP message filtering rules."
    echo ""

    local result_file="$RESULTS_DIR/sccp_filter_$(date +%Y%m%d_%H%M%S).txt"

    cat > /tmp/sccp_filter.py << 'PYEOF'
#!/usr/bin/env python3
"""SCCP Filtering Rule Validator"""

class SCCPFilterValidator:
    """Validate SCCP filtering configuration"""

    # SSNs that should be filtered from external networks
    RESTRICTED_SSNS = {
        6: ("HLR", "HIGH", "Should only accept from known peers"),
        7: ("VLR", "CRITICAL", "Should never be exposed externally"),
        8: ("MSC", "HIGH", "Limited external access"),
        9: ("EIR", "MEDIUM", "Restrict to authorized queries"),
        10: ("AUC", "CRITICAL", "Never expose externally"),
        145: ("gsmSCF-MAP", "HIGH", "CAMEL service control"),
        146: ("CAP", "HIGH", "CAMEL Application Part"),
        149: ("SGSN", "HIGH", "GPRS signaling"),
        150: ("GGSN", "MEDIUM", "GPRS gateway"),
    }

    def validate(self):
        print(f"\n{'='*65}")
        print(f"{'SCCP FILTERING VALIDATION':^65}")
        print(f"{'='*65}")

        print(f"\n  {'SSN':<6} {'Node':<12} {'Risk':<10} {'Recommendation'}")
        print(f"  {'-'*60}")

        for ssn, (node, risk, rec) in sorted(self.RESTRICTED_SSNS.items()):
            risk_color = {
                "CRITICAL": "\033[91m",
                "HIGH": "\033[93m",
                "MEDIUM": "\033[33m"
            }.get(risk, "")
            print(f"  {ssn:<6} {node:<12} {risk_color}{risk:<10}\033[0m {rec}")

        print(f"\n  {'='*65}")
        print(f"\n  Filter Rules to Implement:")
        print(f"  {'-'*65}")
        print(f"  1. Block SSN 7 (VLR) from all external sources")
        print(f"  2. Block SSN 10 (AUC) from all external sources")
        print(f"  3. Restrict SSN 6 (HLR) to known roaming partners")
        print(f"  4. Apply GT-based filtering before SSN routing")
        print(f"  5. Log all rejected SCCP messages")
        print(f"  6. Implement rate limiting per source GT")
        print(f"  7. Validate SCCP calling party addresses")
        print(f"  {'='*65}")

validator = SCCPFilterValidator()
validator.validate()
PYEOF

    python3 /tmp/sccp_filter.py | tee "$result_file"
    rm -f /tmp/sccp_filter.py
    success_msg "Results saved to: $result_file"
}

category_screening() {
    print_header "Category Screening Check"

    local result_file="$RESULTS_DIR/cat_screening_$(date +%Y%m%d_%H%M%S).txt"

    cat << 'EOF' | tee "$result_file"

  ══════════════════════════════════════════════════════════════
   GSMA Category-Based Screening Reference (per FS.11/IR.82)
  ══════════════════════════════════════════════════════════════

  Category 1: Operations that should ALWAYS be filtered
  ─────────────────────────────────────────────────────────────
  • sendRoutingInfo (SRI) - without proper validation
  • provideRoamingNumber - from non-partner networks
  • sendAuthenticationInfo - from external networks
  • insertSubscriberData - unauthorized source
  • deleteSubscriberData - unauthorized source
  • anyTimeInterrogation (ATI) - from external networks

  Category 2: Operations requiring VALIDATION
  ─────────────────────────────────────────────────────────────
  • updateLocation - validate IMSI belongs to network
  • cancelLocation - validate source is legitimate HLR
  • sendRoutingInfoForSM - validate for SMS home routing
  • forwardSM (MT) - validate delivery path
  • provideSubscriberInfo - validate authorization

  Category 3: Operations to MONITOR
  ─────────────────────────────────────────────────────────────
  • processUnstructuredSS (USSD) - monitor for fraud
  • registerSS/activateSS - monitor for call forwarding attacks
  • checkIMEI - monitor patterns
  • readyForSM - monitor delivery reports

  IMPLEMENTATION GUIDELINES:
  ─────────────────────────────────────────────────────────────
  ✓ Deploy SS7 firewall at all interconnect points
  ✓ Implement whitelist-based GT filtering
  ✓ Enable real-time alerting for Category 1 violations
  ✓ Log all blocked messages for forensic analysis
  ✓ Regular review and update of screening rules
  ✓ Test screening effectiveness quarterly

  ══════════════════════════════════════════════════════════════
EOF

    success_msg "Results saved to: $result_file"
}

firewall_analysis() {
    print_header "SS7 Firewall Rule Analysis"

    local result_file="$RESULTS_DIR/fw_analysis_$(date +%Y%m%d_%H%M%S).txt"

    cat > /tmp/fw_analysis.py << 'PYEOF'
#!/usr/bin/env python3
"""SS7 Firewall Rule Analyzer"""

import json

class SS7FirewallAnalyzer:
    """Analyze SS7 firewall configuration"""

    # Default recommended rules
    RECOMMENDED_RULES = [
        {
            "id": "R001",
            "name": "Block external ATI",
            "direction": "inbound",
            "protocol": "MAP",
            "operation": "anyTimeInterrogation (71)",
            "source": "external",
            "action": "BLOCK",
            "priority": "CRITICAL",
            "description": "Block ATI from non-home networks"
        },
        {
            "id": "R002",
            "name": "Block external SAI",
            "direction": "inbound",
            "protocol": "MAP",
            "operation": "sendAuthenticationInfo (14)",
            "source": "external",
            "action": "BLOCK",
            "priority": "CRITICAL",
            "description": "Block auth info requests from external"
        },
        {
            "id": "R003",
            "name": "Validate SRI source",
            "direction": "inbound",
            "protocol": "MAP",
            "operation": "sendRoutingInfo (46)",
            "source": "any",
            "action": "VALIDATE",
            "priority": "HIGH",
            "description": "Validate SRI source against peer list"
        },
        {
            "id": "R004",
            "name": "Validate SRI-SM",
            "direction": "inbound",
            "protocol": "MAP",
            "operation": "sendRoutingInfoForSM (45)",
            "source": "any",
            "action": "VALIDATE",
            "priority": "HIGH",
            "description": "Implement SMS home routing"
        },
        {
            "id": "R005",
            "name": "Block external UL",
            "direction": "inbound",
            "protocol": "MAP",
            "operation": "updateLocation (2)",
            "source": "external",
            "action": "VALIDATE",
            "priority": "HIGH",
            "description": "Validate updateLocation IMSI ownership"
        },
        {
            "id": "R006",
            "name": "Block PSL",
            "direction": "inbound",
            "protocol": "MAP",
            "operation": "provideSubscriberLocation (78)",
            "source": "external",
            "action": "BLOCK",
            "priority": "CRITICAL",
            "description": "Block location requests from external"
        },
        {
            "id": "R007",
            "name": "Rate limit USSD",
            "direction": "both",
            "protocol": "MAP",
            "operation": "processUnstructuredSS (59)",
            "source": "any",
            "action": "RATE_LIMIT",
            "priority": "MEDIUM",
            "description": "Rate limit USSD requests"
        },
        {
            "id": "R008",
            "name": "Block ISD from external",
            "direction": "inbound",
            "protocol": "MAP",
            "operation": "insertSubscriberData (7)",
            "source": "non-HLR",
            "action": "BLOCK",
            "priority": "HIGH",
            "description": "Only accept ISD from legitimate HLR"
        },
        {
            "id": "R009",
            "name": "Block SS manipulation",
            "direction": "inbound",
            "protocol": "MAP",
            "operation": "registerSS/activateSS (10,12)",
            "source": "external",
            "action": "BLOCK",
            "priority": "HIGH",
            "description": "Block call forwarding manipulation"
        },
        {
            "id": "R010",
            "name": "Block tracing",
            "direction": "inbound",
            "protocol": "MAP",
            "operation": "activateTraceMode (48)",
            "source": "external",
            "action": "BLOCK",
            "priority": "CRITICAL",
            "description": "Block trace activation from external"
        }
    ]

    def display_rules(self):
        print(f"\n{'='*75}")
        print(f"{'SS7 FIREWALL - RECOMMENDED RULE SET':^75}")
        print(f"{'='*75}")

        for rule in self.RECOMMENDED_RULES:
            priority_color = {
                "CRITICAL": "\033[91m",
                "HIGH": "\033[93m",
                "MEDIUM": "\033[33m",
                "LOW": "\033[92m"
            }.get(rule["priority"], "")

            action_color = {
                "BLOCK": "\033[91m",
                "VALIDATE": "\033[93m",
                "RATE_LIMIT": "\033[33m",
                "ALLOW": "\033[92m"
            }.get(rule["action"], "")

            print(f"\n  Rule {rule['id']}: {rule['name']}")
            print(f"  ├─ Protocol:  {rule['protocol']}")
            print(f"  ├─ Operation: {rule['operation']}")
            print(f"  ├─ Direction: {rule['direction']}")
            print(f"  ├─ Source:    {rule['source']}")
            print(f"  ├─ Action:    {action_color}{rule['action']}\033[0m")
            print(f"  ├─ Priority:  {priority_color}{rule['priority']}\033[0m")
            print(f"  └─ Desc:      {rule['description']}")

        print(f"\n{'='*75}")
        print(f"  Total rules: {len(self.RECOMMENDED_RULES)}")
        critical = sum(1 for r in self.RECOMMENDED_RULES if r['priority'] == 'CRITICAL')
        high = sum(1 for r in self.RECOMMENDED_RULES if r['priority'] == 'HIGH')
        print(f"  Critical: {critical} | High: {high}")
        print(f"{'='*75}")

    def export_rules(self, filename):
        with open(filename, 'w') as f:
            json.dump(self.RECOMMENDED_RULES, f, indent=2)
        print(f"\n  [+] Rules exported to {filename}")

analyzer = SS7FirewallAnalyzer()
analyzer.display_rules()
PYEOF

    python3 /tmp/fw_analysis.py | tee "$result_file"
    rm -f /tmp/fw_analysis.py
    success_msg "Results saved to: $result_file"
}

vulnerability_report() {
    print_header "SS7 Vulnerability Assessment"

    local result_file="$RESULTS_DIR/vuln_assessment_$(date +%Y%m%d_%H%M%S).txt"

    cat > /tmp/vuln_report.py << 'PYEOF'
#!/usr/bin/env python3
"""SS7 Vulnerability Assessment Report Generator"""

from datetime import datetime

class SS7VulnAssessment:
    """Generate SS7 vulnerability assessment report"""

    VULNERABILITIES = [
        {
            "id": "SS7-001",
            "title": "Subscriber Location Disclosure",
            "severity": "CRITICAL",
            "cvss": 9.1,
            "attack_vector": "anyTimeInterrogation / provideSubscriberInfo",
            "impact": "Attacker can track subscriber location in real-time",
            "affected": "HLR, MSC/VLR",
            "mitigation": [
                "Block ATI from external networks",
                "Implement GT-based filtering",
                "Deploy SS7 firewall with ATI rules"
            ]
        },
        {
            "id": "SS7-002",
            "title": "SMS Interception via SRI-SM",
            "severity": "CRITICAL",
            "cvss": 9.3,
            "attack_vector": "sendRoutingInfoForSM + insertSubscriberData",
            "impact": "SMS messages can be intercepted and redirected",
            "affected": "HLR, SMSC",
            "mitigation": [
                "Implement SMS Home Routing",
                "Validate SRI-SM source GT",
                "Block ISD from non-home HLR"
            ]
        },
        {
            "id": "SS7-003",
            "title": "Call Interception via SRI",
            "severity": "CRITICAL",
            "cvss": 9.0,
            "attack_vector": "sendRoutingInfo + updateLocation",
            "impact": "Voice calls can be intercepted",
            "affected": "HLR, MSC, GMSC",
            "mitigation": [
                "Validate SRI responses",
                "Check updateLocation IMSI ownership",
                "Monitor abnormal routing patterns"
            ]
        },
        {
            "id": "SS7-004",
            "title": "IMSI Disclosure",
            "severity": "HIGH",
            "cvss": 7.5,
            "attack_vector": "sendRoutingInfoForSM",
            "impact": "IMSI can be discovered from MSISDN",
            "affected": "HLR",
            "mitigation": [
                "Rate limit SRI-SM requests",
                "Validate source GT against peer list",
                "Implement SRI-SM anomaly detection"
            ]
        },
        {
            "id": "SS7-005",
            "title": "Denial of Service - cancelLocation",
            "severity": "HIGH",
            "cvss": 8.0,
            "attack_vector": "cancelLocation / deleteSubscriberData",
            "impact": "Subscriber disconnected from network",
            "affected": "VLR, HLR",
            "mitigation": [
                "Validate cancelLocation source",
                "Only accept from known HLR GT",
                "Implement DoS protection rules"
            ]
        },
        {
            "id": "SS7-006",
            "title": "Authentication Vector Theft",
            "severity": "CRITICAL",
            "cvss": 9.5,
            "attack_vector": "sendAuthenticationInfo",
            "impact": "Authentication vectors stolen, SIM cloning possible",
            "affected": "HLR, AUC",
            "mitigation": [
                "NEVER allow SAI from external networks",
                "Strict source validation",
                "Alert on any external SAI attempt"
            ]
        },
        {
            "id": "SS7-007",
            "title": "Call Forwarding Fraud",
            "severity": "HIGH",
            "cvss": 7.8,
            "attack_vector": "registerSS / activateSS (Call Forwarding)",
            "impact": "Calls redirected to premium numbers",
            "affected": "HLR, VLR",
            "mitigation": [
                "Block SS operations from external",
                "Monitor CF activation patterns",
                "Implement SS operation validation"
            ]
        },
        {
            "id": "SS7-008",
            "title": "Subscriber Tracking via PSL",
            "severity": "CRITICAL",
            "cvss": 9.2,
            "attack_vector": "provideSubscriberLocation",
            "impact": "Precise GPS location of subscriber",
            "affected": "MSC, SMLC",
            "mitigation": [
                "Block PSL from external networks",
                "Validate LCS client authorization",
                "Log all location requests"
            ]
        }
    ]

    def generate_report(self):
        print(f"\n{'#'*75}")
        print(f"{'#':>1}{'SS7 VULNERABILITY ASSESSMENT REPORT':^73}{'#'}")
        print(f"{'#'*75}")
        print(f"\n  Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
        print(f"  Standard:  GSMA FS.11, IR.82, IR.88")
        print(f"  Framework: SS7 Security Assessment Methodology")

        # Summary
        critical = sum(1 for v in self.VULNERABILITIES if v['severity'] == 'CRITICAL')
        high = sum(1 for v in self.VULNERABILITIES if v['severity'] == 'HIGH')

        print(f"\n  {'═'*70}")
        print(f"  EXECUTIVE SUMMARY")
        print(f"  {'═'*70}")
        print(f"  Total Vulnerabilities: {len(self.VULNERABILITIES)}")
        print(f"  \033[91mCritical: {critical}\033[0m | \033[93mHigh: {high}\033[0m")
        print(f"  Overall Risk Level: \033[91mCRITICAL\033[0m")

        # Detailed findings
        print(f"\n  {'═'*70}")
        print(f"  DETAILED FINDINGS")
        print(f"  {'═'*70}")

        for vuln in self.VULNERABILITIES:
            sev_color = "\033[91m" if vuln['severity'] == 'CRITICAL' else "\033[93m"

            print(f"\n  ┌{'─'*68}┐")
            print(f"  │ {vuln['id']}: {vuln['title']:<55}│")
            print(f"  ├{'─'*68}┤")
            print(f"  │ Severity:     {sev_color}{vuln['severity']:<54}\033[0m│")
            print(f"  │ CVSS Score:   {vuln['cvss']:<54}│")
            print(f"  │ Attack:       {vuln['attack_vector']:<54}│")
            print(f"  │ Impact:       {vuln['impact'][:54]:<54}│")
            print(f"  │ Affected:     {vuln['affected']:<54}│")
            print(f"  │ Mitigation:                                                      │")
            for m in vuln['mitigation']:
                print(f"  │   • {m:<63}│")
            print(f"  └{'─'*68}┘")

        # Recommendations
        print(f"\n  {'═'*70}")
        print(f"  RECOMMENDATIONS")
        print(f"  {'═'*70}")
        print(f"""
  IMMEDIATE (0-30 days):
  1. Deploy SS7 signaling firewall at all interconnection points
  2. Block Category 1 operations from external networks
  3. Implement SMS Home Routing
  4. Enable logging and alerting for all SS7 messages

  SHORT-TERM (30-90 days):
  5. Implement GSMA IR.82 recommended filtering rules
  6. Deploy real-time monitoring and anomaly detection
  7. Conduct thorough penetration testing
  8. Review all peering agreements

  LONG-TERM (90+ days):
  9. Migrate to Diameter/5G with proper security
  10. Implement continuous security testing program
  11. Regular staff training on SS7 security
  12. Participate in GSMA information sharing
        """)

        print(f"  {'═'*70}")

assessment = SS7VulnAssessment()
assessment.generate_report()
PYEOF

    python3 /tmp/vuln_report.py | tee "$result_file"
    rm -f /tmp/vuln_report.py
    success_msg "Report saved to: $result_file"
}

sms_home_routing() {
    print_header "SMS Home Routing Check"

    local result_file="$RESULTS_DIR/sms_hr_$(date +%Y%m%d_%H%M%S).txt"

    cat << 'EOF' | tee "$result_file"

  ══════════════════════════════════════════════════════════════
   SMS HOME ROUTING ANALYSIS
  ══════════════════════════════════════════════════════════════

  SMS Home Routing is a critical defense against SMS interception
  attacks via the SS7 network.

  HOW SMS INTERCEPTION WORKS:
  ──────────────────────────────────────────────────────────────
  1. Attacker sends SRI-SM to victim's HLR
  2. HLR responds with IMSI + serving MSC address
  3. Attacker sends updateLocation to HLR with fake MSC
  4. SMS messages are now routed to attacker's fake MSC

  HOW SMS HOME ROUTING PREVENTS IT:
  ──────────────────────────────────────────────────────────────
  1. SRI-SM is handled by SMS Router (not directly by HLR)
  2. SMS Router returns its own address (not real MSC)
  3. External party only sees SMS Router, not real MSC/VLR
  4. SMS Router then internally routes to correct MSC

  ARCHITECTURE:

  External SMSC → SRI-SM → [SMS Router] → Response (Router GT)
  External SMSC → MT-FSM → [SMS Router] → Internal Routing → MSC

  VERIFICATION CHECKLIST:
  ──────────────────────────────────────────────────────────────
  [ ] SMS Router deployed and active
  [ ] All SRI-SM responses return Router GT (not MSC GT)
  [ ] IMSI not disclosed in SRI-SM response
  [ ] Internal routing table maintained securely
  [ ] Monitoring enabled for SRI-SM bypass attempts
  [ ] Regular testing of SMS HR effectiveness
  [ ] MT-FSM validation implemented
  [ ] Rate limiting on SRI-SM requests

  ══════════════════════════════════════════════════════════════
EOF

    success_msg "Results saved to: $result_file"
}

tcap_dialog_check() {
    print_header "TCAP Dialog Control Check"

    local result_file="$RESULTS_DIR/tcap_check_$(date +%Y%m%d_%H%M%S).txt"

    cat << 'EOF' | tee "$result_file"

  ══════════════════════════════════════════════════════════════
   TCAP DIALOG CONTROL SECURITY CHECK
  ══════════════════════════════════════════════════════════════

  TCAP Dialog security ensures proper message sequencing
  and prevents dialog-level attacks.

  CHECKS:
  ──────────────────────────────────────────────────────────────

  1. Application Context Validation
     [ ] Verify AC-OID matches expected service
     [ ] Block unknown/unauthorized AC-OIDs
     [ ] Validate AC version compatibility

  2. Dialog Portion Validation
     [ ] Check for proper Begin/Continue/End sequencing
     [ ] Validate Transaction IDs
     [ ] Detect orphaned transactions

  3. Component Handling
     [ ] Validate Invoke ID uniqueness
     [ ] Check for unexpected Return Results
     [ ] Detect component flooding

  4. Security Measures
     [ ] Dialog rate limiting per source
     [ ] Maximum dialog duration enforcement
     [ ] Anomaly detection on dialog patterns
     [ ] Transaction ID prediction prevention

  COMMON TCAP ATTACKS:
  ──────────────────────────────────────────────────────────────
  • TC-Begin flooding (DoS)
  • Transaction ID guessing
  • Component injection
  • Dialog hijacking
  • AC-OID manipulation

  ══════════════════════════════════════════════════════════════
EOF

    success_msg "Results saved to: $result_file"
}

gt_filtering() {
    print_header "Global Title Filtering Analysis"

    local result_file="$RESULTS_DIR/gt_filter_$(date +%Y%m%d_%H%M%S).txt"

    cat > /tmp/gt_filter.py << 'PYEOF'
#!/usr/bin/env python3
"""Global Title Filtering Analyzer"""

class GTFilterAnalyzer:
    """Analyze and recommend GT filtering rules"""

    # Common GT patterns by country code
    GT_PATTERNS = {
        "E.164 (MSISDN)": {
            "format": "+CC-NDC-SN",
            "example": "+1-555-1234567",
            "numbering_plan": 1,
            "nature_of_address": 4
        },
        "E.212 (IMSI)": {
            "format": "MCC-MNC-MSIN",
            "example": "310-260-123456789",
            "numbering_plan": 6,
            "nature_of_address": 1
        },
        "E.214 (MGT)": {
            "format": "CC-NDC (translated)",
            "example": "1-555",
            "numbering_plan": 1,
            "nature_of_address": 4
        }
    }

    def analyze(self):
        print(f"\n{'='*70}")
        print(f"{'GLOBAL TITLE FILTERING ANALYSIS':^70}")
        print(f"{'='*70}")

        # GT Format Reference
        print(f"\n  GT Format Reference:")
        print(f"  {'─'*65}")
        for name, info in self.GT_PATTERNS.items():
            print(f"\n  {name}:")
            print(f"    Format:   {info['format']}")
            print(f"    Example:  {info['example']}")
            print(f"    NP:       {info['numbering_plan']}")
            print(f"    NAI:      {info['nature_of_address']}")

        # Filtering recommendations
        print(f"\n\n  {'═'*65}")
        print(f"  FILTERING RECOMMENDATIONS")
        print(f"  {'═'*65}")

        rules = [
            ("ALLOW", "Home network GT range", "Based on your CC+NDC"),
            ("ALLOW", "Known roaming partner GTs", "Per roaming agreements"),
            ("ALLOW", "GSMA hub GTs", "IPX/GRX provider GTs"),
            ("BLOCK", "Spoofed home network GTs", "External msgs with home GT"),
            ("BLOCK", "Invalid GT formats", "Malformed or impossible GTs"),
            ("BLOCK", "Private/test GTs", "Non-routable GT ranges"),
            ("MONITOR", "Unusual GT patterns", "GTs from unexpected regions"),
            ("RATE_LIMIT", "High-volume source GTs", "Possible scanning/attack"),
        ]

        print(f"\n  {'Action':<12} {'Description':<35} {'Detail'}")
        print(f"  {'─'*65}")

        for action, desc, detail in rules:
            color = {
                "ALLOW": "\033[92m",
                "BLOCK": "\033[91m",
                "MONITOR": "\033[93m",
                "RATE_LIMIT": "\033[33m"
            }.get(action, "")
            print(f"  {color}{action:<12}\033[0m {desc:<35} {detail}")

        # Interactive GT validator
        print(f"\n\n  {'═'*65}")
        print(f"  GT VALIDATOR")
        print(f"  {'═'*65}")
        print(f"  Enter GT numbers to validate (or 'quit' to exit):")

        while True:
            try:
                gt = input("\n  GT> ").strip()
                if gt.lower() in ('quit', 'exit', 'q', ''):
                    break

                gt_clean = gt.replace('+', '').replace('-', '').replace(' ', '')

                if not gt_clean.isdigit():
                    print("  [\033[91m✗\033[0m] Invalid GT: contains non-numeric characters")
                    continue

                if len(gt_clean) < 7 or len(gt_clean) > 15:
                    print("  [\033[93m!\033[0m] Unusual GT length: {len(gt_clean)} digits")
                else:
                    print(f"  [\033[92m✓\033[0m] Valid GT format")

                # Identify country
                cc_map = {
                    "1": "North America", "7": "Russia",
                    "20": "Egypt", "27": "South Africa",
                    "30": "Greece", "31": "Netherlands",
                    "33": "France", "34": "Spain",
                    "39": "Italy", "44": "UK",
                    "49": "Germany", "55": "Brazil",
                    "61": "Australia", "81": "Japan",
                    "82": "South Korea", "86": "China",
                    "91": "India", "966": "Saudi Arabia"
                }

                for cc, country in cc_map.items():
                    if gt_clean.startswith(cc):
                        print(f"    Country:  {country} (+{cc})")
                        break

                print(f"    Digits:   {len(gt_clean)}")
                print(f"    Raw:      {gt_clean}")

            except (KeyboardInterrupt, EOFError):
                break

analyzer = GTFilterAnalyzer()
analyzer.analyze()
PYEOF

    python3 /tmp/gt_filter.py | tee "$result_file"
    rm -f /tmp/gt_filter.py
    success_msg "Results saved to: $result_file"
}

generate_security_report() {
    print_header "Generate Comprehensive Security Report"

    local report_file="$RESULTS_DIR/SS7_Security_Report_$(date +%Y%m%d_%H%M%S).txt"

    info_msg "Generating comprehensive report..."

    cat > "$report_file" << EOF
╔══════════════════════════════════════════════════════════════════════╗
║                   SS7 SECURITY ASSESSMENT REPORT                     ║
╚══════════════════════════════════════════════════════════════════════╝

Report Generated: $(date '+%Y-%m-%d %H:%M:%S')
Tool Version: SS7 Tools v2.0
Assessment Type: Comprehensive SS7/SIGTRAN Security Review

═══════════════════════════════════════════════════════════════════════
1. EXECUTIVE SUMMARY
═══════════════════════════════════════════════════════════════════════

This report provides a comprehensive assessment of SS7 network security
based on GSMA recommended practices (FS.11, IR.82, IR.88).

The SS7 protocol suite, designed in the 1980s, lacks inherent security
mechanisms such as authentication and encryption. This makes telecom
networks vulnerable to various attacks when proper security controls
are not implemented.

═══════════════════════════════════════════════════════════════════════
2. THREAT LANDSCAPE
═══════════════════════════════════════════════════════════════════════

2.1 Location Tracking
    - ATI (anyTimeInterrogation) enables real-time location queries
    - PSI (provideSubscriberInfo) reveals serving cell/LAC
    - PSL (provideSubscriberLocation) provides GPS coordinates

2.2 Communication Interception
    - SMS interception via SRI-SM + updateLocation
    - Call interception via SRI + call redirection
    - USSD session hijacking

2.3 Subscriber Identity Theft
    - IMSI disclosure via SRI-SM
    - Authentication vector theft via SAI
    - Potential SIM cloning

2.4 Denial of Service
    - cancelLocation removes subscriber from network
    - deleteSubscriberData removes subscription profile
    - purgeMS purges mobile station record

2.5 Fraud
    - Call forwarding to premium rate numbers
    - SMS redirection for OTP theft
    - Identity impersonation

═══════════════════════════════════════════════════════════════════════
3. TECHNICAL FINDINGS
═══════════════════════════════════════════════════════════════════════

[Findings from scans and analysis would be inserted here]

═══════════════════════════════════════════════════════════════════════
4. RECOMMENDATIONS
═══════════════════════════════════════════════════════════════════════

PRIORITY 1 - IMMEDIATE:
  □ Deploy SS7 signaling firewall
  □ Block ATI/PSI/PSL from external networks
  □ Block SAI from external networks
  □ Implement SMS Home Routing

PRIORITY 2 - SHORT-TERM:
  □ Implement GSMA IR.82 filtering rules
  □ Deploy GT-based access control
  □ Enable comprehensive logging
  □ Implement real-time monitoring

PRIORITY 3 - MEDIUM-TERM:
  □ Deploy anomaly detection system
  □ Implement rate limiting
  □ Review peering agreements
  □ Conduct regular penetration testing

PRIORITY 4 - LONG-TERM:
  □ Plan migration to Diameter/5G
  □ Implement end-to-end encryption
  □ Continuous security improvement program
  □ Staff security awareness training

═══════════════════════════════════════════════════════════════════════
5. COMPLIANCE REFERENCES
═══════════════════════════════════════════════════════════════════════

  • GSMA FS.11 - SS7 Interconnect Security
  • GSMA IR.82 - SS7 Security Network Implementation Guidelines
  • GSMA IR.88 - SS7 Interconnect Security Monitoring Guidelines
  • 3GPP TS 29.002 - MAP Protocol Specification
  • 3GPP TS 23.018 - Basic Call Handling
  • ITU-T Q.713 - SCCP Formats and Codes
  • ITU-T Q.773 - TCAP Formats and Procedures

═══════════════════════════════════════════════════════════════════════
6. APPENDICES
═══════════════════════════════════════════════════════════════════════

Appendix A: Scan results stored in $RESULTS_DIR/
Appendix B: PCAP captures stored in $PCAP_DIR/
Appendix C: Logs stored in $LOG_DIR/

═══════════════════════════════════════════════════════════════════════
                          END OF REPORT
═══════════════════════════════════════════════════════════════════════
EOF

    # Append any existing results
    if ls "$RESULTS_DIR"/*.txt 1>/dev/null 2>&1; then
        echo "" >> "$report_file"
        echo "═══════════════════════════════════════════════════════════════" >> "$report_file"
        echo "APPENDIX: Previous Scan Results" >> "$report_file"
        echo "═══════════════════════════════════════════════════════════════" >> "$report_file"

        for result in "$RESULTS_DIR"/*.txt; do
            if [ "$result" != "$report_file" ]; then
                echo "" >> "$report_file"
                echo "--- $(basename "$result") ---" >> "$report_file"
                head -50 "$result" >> "$report_file"
                echo "... [truncated] ..." >> "$report_file"
            fi
        done
    fi

    success_msg "Comprehensive report saved to: $report_file"
    info_msg "Report size: $(wc -c < "$report_file") bytes"
}

#=====================================================================
# SS7 PROTOCOL REFERENCE
#=====================================================================

protocol_reference() {
    print_header "SS7 Protocol Reference"

    echo -e "${WHITE}  Select reference:${NC}"
    echo ""
    echo -e "  ${CYAN}1)${NC}  SS7 Protocol Stack Overview"
    echo -e "  ${CYAN}2)${NC}  MTP (Message Transfer Part)"
    echo -e "  ${CYAN}3)${NC}  SCCP Reference"
    echo -e "  ${CYAN}4)${NC}  TCAP Reference"
    echo -e "  ${CYAN}5)${NC}  MAP Reference"
    echo -e "  ${CYAN}6)${NC}  ISUP Reference"
    echo -e "  ${CYAN}7)${NC}  SIGTRAN/M3UA Reference"
    echo -e "  ${CYAN}8)${NC}  Diameter Reference"
    echo -e "  ${CYAN}9)${NC}  Point Code Reference"
    echo -e "  ${CYAN}10)${NC} GSMA Security Standards"
    echo -e "  ${CYAN}0)${NC}  Back"
    echo ""
    prompt_msg "Select option: "
    read -r ref_choice

    case $ref_choice in
        1) ss7_stack_overview ;;
        2) mtp_reference ;;
        3) sccp_reference ;;
        4) tcap_reference ;;
        5) map_reference_detail ;;
        6) isup_reference ;;
        7) sigtran_reference ;;
        8) diameter_reference ;;
        9) point_code_reference ;;
        10) gsma_standards ;;
        0) return ;;
        *) error_msg "Invalid option" ;;
    esac
}

ss7_stack_overview() {
    print_header "SS7 Protocol Stack"

    cat << 'EOF'

  SS7 Protocol Stack (Traditional + SIGTRAN)
  ══════════════════════════════════════════════════════════

  Traditional SS7              SIGTRAN (IP)
  ─────────────               ──────────────
  ┌──────────────┐            ┌──────────────┐
  │    MAP/CAP   │            │    MAP/CAP   │
  │  ISUP/BICC   │            │  ISUP/BICC   │
  ├──────────────┤            ├──────────────┤
  │     TCAP     │            │     TCAP     │
  ├──────────────┤            ├──────────────┤
  │     SCCP     │            │     SCCP     │
  ├──────────────┤            ├──────────────┤
  │    MTP-3     │            │   M3UA/SUA   │
  ├──────────────┤            ├──────────────┤
  │    MTP-2     │            │     SCTP     │
  ├──────────────┤            ├──────────────┤
  │    MTP-1     │            │      IP      │
  │  (E1/T1/DS0) │            │  (Ethernet)  │
  └──────────────┘            └──────────────┘

  Layer Descriptions:
  ─────────────────────────────────────────────────────────

  MTP-1 (Physical):    E1/T1 signaling links
  MTP-2 (Data Link):   Error correction, flow control
  MTP-3 (Network):     Message routing, network management
  SCCP:                Connection-oriented/connectionless
  TCAP:                Transaction handling
  MAP:                 Mobile network operations
  ISUP:                Call setup/teardown
  CAP:                 Intelligent network triggers

  SIGTRAN Adaptations:
  ─────────────────────────────────────────────────────────

  M2UA:  MTP2 User Adaptation (replaces MTP-2)
  M2PA:  MTP2 Peer-to-Peer Adaptation
  M3UA:  MTP3 User Adaptation (replaces MTP-3)
  SUA:   SCCP User Adaptation (replaces SCCP)
  IUA:   ISDN User Adaptation

  All SIGTRAN protocols use SCTP (Stream Control
  Transmission Protocol) over IP.

EOF

    prompt_msg "Press Enter to continue..."
    read -r
}

mtp_reference() {
    print_header "MTP Reference"

    cat << 'EOF'

  MTP (Message Transfer Part) - ITU-T Q.700 Series
  ══════════════════════════════════════════════════

  MTP Level 1 (Physical Layer):
  ─────────────────────────────
  • 64 kbps signaling links
  • E1 (2.048 Mbps) or T1 (1.544 Mbps)
  • Timeslot 16 (E1) typically used

  MTP Level 2 (Data Link):
  ─────────────────────────────
  • Signal Unit types:
    - MSU (Message Signal Unit): User data
    - LSSU (Link Status Signal Unit): Link status
    - FISU (Fill-In Signal Unit): Keep-alive

  • MSU Format:
    ┌───┬───┬───┬───┬───┬───┬───┐
    │ F │BSN│BIB│FSN│FIB│ LI│SIF│
    │ 8 │ 7 │ 1 │ 7 │ 1 │ 6 │var│
    └───┴───┴───┴───┴───┴───┴───┘

  MTP Level 3 (Network):
  ─────────────────────────────
  • Routing Label:
    ┌───────┬───────┬───────┬────┐
    │  DPC  │  OPC  │  SLS  │ SI │
    │14 bits│14 bits│4 bits │4 b │
    └───────┴───────┴───────┴────┘

  • Service Indicators (SI):
    0: SNMM (Network Management)
    1: SNTM (Test/Maintenance)
    3: SCCP
    4: TUP
    5: ISUP
    13: Q.2931

  • Network management functions:
    - Traffic management (TFP, TFA, TFR)
    - Route management
    - Link management (COO, COA, CBD, CBA)

EOF

    prompt_msg "Press Enter to continue..."
    read -r
}

sccp_reference() {
    print_header "SCCP Reference"

    cat << 'EOF'

  SCCP (Signaling Connection Control Part) - ITU-T Q.711-Q.716
  ═══════════════════════════════════════════════════════════════

  Message Types:
  ──────────────
  0x01: CR   - Connection Request
  0x02: CC   - Connection Confirm
  0x03: CREF - Connection Refused
  0x04: RLSD - Released
  0x05: RLC  - Release Complete
  0x06: DT1  - Data Form 1
  0x09: UDT  - Unitdata (connectionless)
  0x0A: UDTS - Unitdata Service
  0x11: XUDT - Extended Unitdata
  0x12: XUDTS - Extended Unitdata Service

  Protocol Classes:
  ──────────────
  Class 0: Basic connectionless
  Class 1: Sequenced connectionless
  Class 2: Basic connection-oriented
  Class 3: Flow control connection-oriented

  Address Format:
  ──────────────
  ┌─────────────────────────┐
  │ Address Indicator (1B)  │
  │ ┌─ PC indicator         │
  │ ├─ SSN indicator        │
  │ ├─ GT indicator (4 bit) │
  │ └─ Routing indicator    │
  ├─────────────────────────┤
  │ Point Code (0-2 bytes)  │
  ├─────────────────────────┤
  │ SSN (0-1 byte)          │
  ├─────────────────────────┤
  │ Global Title (variable) │
  └─────────────────────────┘

  Common SSNs:
  ──────────────
  1:   SCCP Management
  6:   HLR
  7:   VLR
  8:   MSC
  9:   EIR
  10:  AUC
  142: RANAP
  146: CAP
  254: BSSAP

EOF

    prompt_msg "Press Enter to continue..."
    read -r
}

tcap_reference() {
    print_header "TCAP Reference"

    cat << 'EOF'

  TCAP (Transaction Capabilities Application Part) - ITU-T Q.771-Q.775
  ═════════════════════════════════════════════════════════════════════

  Message Types (BER encoded):
  ──────────────────────────────
  0x60: Unidirectional
  0x61: Begin
  0x62: End
  0x63: Continue
  0x64: Abort

  Component Types:
  ──────────────────────────────
  0xA1: Invoke
  0xA2: Return Result (Last)
  0xA3: Return Error
  0xA4: Reject
  0xA7: Return Result (Not Last)

  TCAP Message Structure:
  ──────────────────────────────
  ┌──────────────────────────┐
  │  Message Type Tag        │
  │  Message Length           │
  ├──────────────────────────┤
  │  Transaction Portion     │
  │  ├─ Originating TID      │
  │  └─ Destination TID      │
  ├──────────────────────────┤
  │  Dialogue Portion (opt)  │
  │  ├─ Application Context  │
  │  └─ User Information     │
  ├──────────────────────────┤
  │  Component Portion       │
  │  ├─ Component Type       │
  │  ├─ Invoke ID            │
  │  ├─ Operation Code       │
  │  └─ Parameter            │
  └──────────────────────────┘

  Application Context OIDs (MAP):
  ──────────────────────────────
  networkLocUpContext:     0.4.0.0.1.0.1.x
  locationCancellation:   0.4.0.0.1.0.2.x
  roamingNumberEnquiry:   0.4.0.0.1.0.3.x
  infoRetrieval:          0.4.0.0.1.0.14.x
  shortMsgRelay:          0.4.0.0.1.0.21.x
  shortMsgGateway:        0.4.0.0.1.0.20.x

EOF

    prompt_msg "Press Enter to continue..."
    read -r
}

map_reference_detail() {
    if [ -f "$WORK_DIR/map_parser.py" ]; then
        cd "$WORK_DIR"
        python3 -c "from map_parser import MAPOperations; MAPOperations.display_all(); print(); MAPOperations.display_attacks()"
    else
        error_msg "MAP parser not installed. Install SIGTRAN tools first."
    fi

    prompt_msg "Press Enter to continue..."
    read -r
}

isup_reference() {
    print_header "ISUP Reference"

    cat << 'EOF'

  ISUP (ISDN User Part) - ITU-T Q.761-Q.764
  ═══════════════════════════════════════════

  Message Types:
  ──────────────
  0x01: IAM  - Initial Address Message (call setup)
  0x02: SAM  - Subsequent Address Message
  0x06: ACM  - Address Complete Message
  0x09: ANM  - Answer Message
  0x0C: REL  - Release Message
  0x10: RLC  - Release Complete
  0x2C: CPG  - Call Progress
  0x33: FAC  - Facility
  0x08: CON  - Connect

  IAM Structure:
  ──────────────
  ┌─────────────────────────────┐
  │ Nature of Connection (1B)   │
  │ Forward Call Indicators (2B)│
  │ Calling Party Category (1B) │
  │ Transmission Medium Req (1B)│
  │ Called Party Number (var)   │
  ├─────────────────────────────┤
  │ Optional Parameters         │
  │ ├─ Calling Party Number     │
  │ ├─ Redirecting Number       │
  │ ├─ Original Called Number   │
  │ ├─ Generic Number           │
  │ └─ User-to-User Info        │
  └─────────────────────────────┘

  Calling Party Categories:
  ──────────────
  0x0A: Ordinary subscriber
  0x0B: Priority subscriber
  0x0C: Data call
  0x0D: Test call
  0x0E: Payphone

EOF

    prompt_msg "Press Enter to continue..."
    read -r
}

sigtran_reference() {
    print_header "SIGTRAN/M3UA Reference"

    cat << 'EOF'

  SIGTRAN Protocol Suite (RFC 4666, RFC 3868)
  ═══════════════════════════════════════════

  SCTP (Stream Control Transmission Protocol):
  ──────────────────────────────────────────────
  • Multi-homed (multiple IP addresses)
  • Multi-streamed (ordered delivery per stream)
  • Message-oriented (preserves boundaries)
  • Built-in heartbeat mechanism
  • 4-way handshake (INIT→INIT-ACK→COOKIE-ECHO→COOKIE-ACK)

  M3UA (RFC 4666):
  ──────────────────────────────────────────────
  Common Header:
  ┌──────┬──────┬──────┬──────┐
  │ Ver  │ Rsvd │Class │ Type │
  │ (1B) │ (1B) │ (1B) │ (1B) │
  ├──────┴──────┴──────┴──────┤
  │     Message Length (4B)    │
  ├────────────────────────────┤
  │   Parameters (TLV format) │
  └────────────────────────────┘

  Message Classes:
  0: Management     (ERR, NTFY)
  1: Transfer       (DATA)
  2: SSNM           (DUNA, DAVA, DAUD, SCON, DUPU)
  3: ASPSM          (ASPUP, ASPDN, BEAT + ACKs)
  4: ASPTM          (ASPAC, ASPIA + ACKs)
  9: RKM            (REG_REQ/RSP, DEREG_REQ/RSP)

  ASP State Machine:
  ──────────────────────────────────────────────
  DOWN → ASPUP → INACTIVE → ASPAC → ACTIVE

  Common Ports:
  ──────────────────────────────────────────────
  2904: M2UA      2907: SUA
  2905: M3UA      3565: M2PA
  2906: IUA       3868: Diameter

EOF

    prompt_msg "Press Enter to continue..."
    read -r
}

diameter_reference() {
    print_header "Diameter Protocol Reference"

    cat << 'EOF'

  Diameter Protocol (RFC 6733)
  ═══════════════════════════

  Diameter is the successor to SS7/MAP for LTE/4G networks.

  Header Format:
  ──────────────────────────────────
  ┌─────┬─────┬────────────────────┐
  │ Ver │Len  │ Flags │ Cmd Code   │
  │ (1) │(3)  │ (1)   │ (3)        │
  ├─────┴─────┴────────────────────┤
  │      Application ID (4B)       │
  ├────────────────────────────────┤
  │    Hop-by-Hop ID (4B)          │
  ├────────────────────────────────┤
  │    End-to-End ID (4B)          │
  ├────────────────────────────────┤
  │       AVPs (variable)          │
  └────────────────────────────────┘

  Key Command Codes:
  ──────────────────────────────────
  257: CE  (Capabilities Exchange)
  258: RA  (Re-Auth)
  271: AC  (Accounting)
  272: CC  (Credit Control)
  274: AS  (Abort Session)
  280: DW  (Device Watchdog)
  282: DP  (Disconnect Peer)

  3GPP Diameter Applications:
  ──────────────────────────────────
  S6a/S6d: MME ↔ HSS (replaces MAP)
  S13:     MME ↔ EIR
  Gx:      PCRF ↔ PCEF (policy)
  Gy:      OCS ↔ PCEF (charging)
  Rx:      AF ↔ PCRF (QoS)
  Sh:      AS ↔ HSS
  Cx:      I/S-CSCF ↔ HSS (IMS)

  S6a Commands (replaces MAP):
  ──────────────────────────────────
  316: UL  (Update Location)
  317: CL  (Cancel Location)
  318: AI  (Auth Info)
  319: ISD (Insert Subscriber Data)
  320: DSD (Delete Subscriber Data)
  321: PU  (Purge UE)
  322: RS  (Reset)
  323: NO  (Notify)

EOF

    prompt_msg "Press Enter to continue..."
    read -r
}

point_code_reference() {
    point_code_calc
}

gsma_standards() {
    print_header "GSMA Security Standards Reference"

    cat << 'EOF'

  GSMA SS7 Security Standards
  ═══════════════════════════

  FS.11 - SS7 Interconnect Security
  ──────────────────────────────────
  • Defines SS7 security requirements
  • Mandatory for GSMA member operators
  • Covers MAP, CAP, and ISUP security
  • Risk categorization of operations
  • Filtering and monitoring guidelines

  IR.82 - SS7 Security Implementation
  ──────────────────────────────────
  • Technical implementation guidelines
  • Network element security configs
  • Filtering rule specifications
  • Reference architecture
  • Testing methodologies

  IR.88 - SS7 Monitoring Guidelines
  ──────────────────────────────────
  • Real-time monitoring requirements
  • Anomaly detection rules
  • Incident response procedures
  • Reporting requirements
  • KPI definitions

  FS.07 - GSMA Guidelines for IPX
  ──────────────────────────────────
  • IPX network security
  • GRX migration to IPX
  • SCTP/IP security for SIGTRAN
  • Interconnect security controls

  FS.19 - Diameter Interconnect Security
  ──────────────────────────────────
  • Diameter security guidelines
  • DEA (Diameter Edge Agent) requirements
  • S6a/Gx/Gy security
  • Migration from SS7 to Diameter

  Key Requirements Summary:
  ──────────────────────────────────
  ✓ Signaling firewall deployment
  ✓ Category-based message filtering
  ✓ GT/address validation
  ✓ Real-time monitoring
  ✓ Incident response capability
  ✓ Regular security testing
  ✓ Threat intelligence sharing
  ✓ Compliance reporting

  Resources:
  ──────────────────────────────────
  • GSMA: https://www.gsma.com/security
  • 3GPP: https://www.3gpp.org
  • ITU-T: https://www.itu.int
  • ETSI: https://www.etsi.org

EOF

    prompt_msg "Press Enter to continue..."
    read -r
}

#=====================================================================
# UTILITY TOOLS
#=====================================================================

utility_tools() {
    print_header "Utility Tools"

    echo -e "${WHITE}  Select utility:${NC}"
    echo ""
    echo -e "  ${CYAN}1)${NC}  IMSI/MSISDN Formatter"
    echo -e "  ${CYAN}2)${NC}  E.164 Number Validator"
    echo -e "  ${CYAN}3)${NC}  Hex/Binary/Decimal Converter"
    echo -e "  ${CYAN}4)${NC}  BCD Encoder/Decoder"
    echo -e "  ${CYAN}5)${NC}  Point Code Calculator"
    echo -e "  ${CYAN}6)${NC}  TBCD Encoder/Decoder"
    echo -e "  ${CYAN}7)${NC}  View Logs"
    echo -e "  ${CYAN}8)${NC}  View Results"
    echo -e "  ${CYAN}9)${NC}  Clean Workspace"
    echo -e "  ${CYAN}0)${NC}  Back"
    echo ""
    prompt_msg "Select option: "
    read -r util_choice

    case $util_choice in
        1) imsi_formatter ;;
        2) e164_validator ;;
        3) number_converter ;;
        4) bcd_codec ;;
        5) point_code_calc ;;
        6) tbcd_codec ;;
        7) view_logs ;;
        8) view_results ;;
        9) clean_workspace ;;
        0) return ;;
        *) error_msg "Invalid option" ;;
    esac
}

imsi_formatter() {
    print_header "IMSI/MSISDN Formatter"

    cat > /tmp/imsi_fmt.py << 'PYEOF'
#!/usr/bin/env python3
"""IMSI/MSISDN Formatter and Analyzer"""

# MCC database (partial)
MCC_DB = {
    "202": "Greece", "204": "Netherlands", "206": "Belgium",
    "208": "France", "214": "Spain", "216": "Hungary",
    "222": "Italy", "226": "Romania", "228": "Switzerland",
    "230": "Czech Republic", "232": "Austria", "234": "UK",
    "240": "Sweden", "242": "Norway", "244": "Finland",
    "246": "Lithuania", "247": "Latvia", "248": "Estonia",
    "250": "Russia", "255": "Ukraine", "260": "Poland",
    "262": "Germany", "268": "Portugal", "270": "Luxembourg",
    "272": "Ireland", "276": "Albania", "278": "Malta",
    "280": "Cyprus", "282": "Georgia", "284": "Bulgaria",
    "286": "Turkey", "288": "Faroe Islands",
    "302": "Canada", "310": "USA", "311": "USA",
    "312": "USA", "313": "USA", "314": "USA",
    "316": "USA",
    "334": "Mexico", "338": "Jamaica",
    "404": "India", "405": "India", "410": "Pakistan",
    "420": "Saudi Arabia", "422": "Oman", "424": "UAE",
    "425": "Israel", "426": "Bahrain", "427": "Qatar",
    "428": "Mongolia", "432": "Iran",
    "440": "Japan", "450": "South Korea", "452": "Vietnam",
    "454": "Hong Kong", "455": "Macao", "460": "China",
    "466": "Taiwan", "470": "Bangladesh", "502": "Malaysia",
    "505": "Australia", "510": "Indonesia", "514": "Timor-Leste",
    "515": "Philippines", "520": "Thailand", "525": "Singapore",
    "528": "Brunei",
    "602": "Egypt", "603": "Algeria", "604": "Morocco",
    "607": "Gambia", "608": "Senegal", "612": "Ivory Coast",
    "616": "Burkina Faso", "620": "Ghana", "621": "Nigeria",
    "630": "Congo", "633": "Seychelles", "634": "Sudan",
    "639": "Kenya", "640": "Tanzania", "641": "Uganda",
    "645": "Zambia", "646": "Madagascar",
    "648": "Zimbabwe", "650": "Mozambique",
    "655": "South Africa", "657": "Eritrea",
    "702": "Belize", "704": "Guatemala", "706": "El Salvador",
    "708": "Honduras", "710": "Nicaragua", "712": "Costa Rica",
    "714": "Panama", "716": "Peru", "722": "Argentina",
    "724": "Brazil", "730": "Chile", "732": "Colombia",
    "734": "Venezuela", "736": "Bolivia", "738": "Guyana",
    "740": "Ecuador", "742": "French Guiana", "744": "Paraguay",
    "746": "Suriname", "748": "Uruguay"
}

def analyze_imsi(imsi):
    """Analyze IMSI number"""
    imsi = imsi.replace(' ', '').replace('-', '')

    if not imsi.isdigit() or len(imsi) != 15:
        print(f"  [!] Invalid IMSI format (must be 15 digits)")
        return

    mcc = imsi[0:3]
    mnc = imsi[3:5]  # Could be 2 or 3 digits
    msin = imsi[5:]

    # Try 3-digit MNC
    if mcc + imsi[3:6] in ["310260", "311480"]:  # Known 3-digit MNCs
        mnc = imsi[3:6]
        msin = imsi[6:]

    country = MCC_DB.get(mcc, "Unknown")

    print(f"\n  IMSI Analysis: {imsi}")
    print(f"  {'─'*40}")
    print(f"  MCC:     {mcc} ({country})")
    print(f"  MNC:     {mnc}")
    print(f"  MSIN:    {msin}")
    print(f"  E.212:   {mcc}-{mnc}-{msin}")
    print(f"  Length:  {len(imsi)} digits")

def analyze_msisdn(msisdn):
    """Analyze MSISDN number"""
    msisdn = msisdn.replace(' ', '').replace('-', '').replace('+', '')

    if not msisdn.isdigit() or len(msisdn) < 7 or len(msisdn) > 15:
        print(f"  [!] Invalid MSISDN format")
        return

    # Try to identify country code
    cc = ""
    country = ""
    cc_map = {
        "1": "North America", "7": "Russia/Kazakhstan",
        "20": "Egypt", "27": "South Africa",
        "30": "Greece", "31": "Netherlands", "32": "Belgium",
        "33": "France", "34": "Spain", "36": "Hungary",
        "39": "Italy", "40": "Romania", "41": "Switzerland",
        "43": "Austria", "44": "United Kingdom",
        "45": "Denmark", "46": "Sweden", "47": "Norway",
        "48": "Poland", "49": "Germany",
        "51": "Peru", "52": "Mexico", "53": "Cuba",
        "54": "Argentina", "55": "Brazil", "56": "Chile",
        "57": "Colombia", "58": "Venezuela",
        "60": "Malaysia", "61": "Australia", "62": "Indonesia",
        "63": "Philippines", "64": "New Zealand",
        "65": "Singapore", "66": "Thailand",
        "81": "Japan", "82": "South Korea", "84": "Vietnam",
        "86": "China", "90": "Turkey", "91": "India",
        "92": "Pakistan", "93": "Afghanistan",
        "94": "Sri Lanka", "95": "Myanmar",
        "960": "Maldives", "961": "Lebanon", "962": "Jordan",
        "963": "Syria", "964": "Iraq", "965": "Kuwait",
        "966": "Saudi Arabia", "967": "Yemen",
        "968": "Oman", "970": "Palestine", "971": "UAE",
        "972": "Israel", "973": "Bahrain", "974": "Qatar",
        "975": "Bhutan", "976": "Mongolia", "977": "Nepal",
        "992": "Tajikistan", "993": "Turkmenistan",
        "994": "Azerbaijan", "995": "Georgia",
        "996": "Kyrgyzstan", "998": "Uzbekistan"
    }

    for length in [3, 2, 1]:
        prefix = msisdn[:length]
        if prefix in cc_map:
            cc = prefix
            country = cc_map[prefix]
            break

    ndc = msisdn[len(cc):len(cc)+3] if cc else ""
    sn = msisdn[len(cc)+len(ndc):] if cc else msisdn

    print(f"\n  MSISDN Analysis: +{msisdn}")
    print(f"  {'─'*40}")
    if cc:
        print(f"  CC:      +{cc} ({country})")
    print(f"  NDC:     {ndc}")
    print(f"  SN:      {sn}")
    print(f"  E.164:   +{msisdn}")
    print(f"  Length:  {len(msisdn)} digits")

print("[*] IMSI/MSISDN Formatter")
print("[*] Enter 'imsi' or 'msisdn' followed by the number")
print("[*] Or just enter a number to auto-detect")

while True:
    try:
        inp = input("\n  > ").strip()
        if inp.lower() in ('quit', 'exit', 'q', ''):
            break

        if inp.lower().startswith('imsi '):
            analyze_imsi(inp[5:].strip())
        elif inp.lower().startswith('msisdn '):
            analyze_msisdn(inp[7:].strip())
        else:
            # Auto-detect
            num = inp.replace('+', '').replace('-', '').replace(' ', '')
            if len(num) == 15 and num.isdigit():
                analyze_imsi(num)
            elif num.isdigit():
                analyze_msisdn(num)
            else:
                print("  [!] Enter: imsi <number> or msisdn <number>")
    except (KeyboardInterrupt, EOFError):
        break
PYEOF

    python3 /tmp/imsi_fmt.py
    rm -f /tmp/imsi_fmt.py
}

e164_validator() {
    print_header "E.164 Number Validator"

    prompt_msg "Enter phone number (with country code): "
    read -r phone

    phone=$(echo "$phone" | tr -d ' ' | tr -d '-' | tr -d '(' | tr -d ')')

    if [[ "$phone" =~ ^\+?[0-9]{7,15}$ ]]; then
        success_msg "Valid E.164 format"
        info_msg "Number: $phone"
        info_msg "Digits: ${#phone}"
    else
        error_msg "Invalid E.164 format"
        info_msg "E.164 requires 7-15 digits"
    fi
}

number_converter() {
    print_header "Number Converter"

    prompt_msg "Enter value: "
    read -r value

    echo ""

    python3 << PYEOF
value = "$value"
try:
    if value.startswith('0x') or value.startswith('0X'):
        num = int(value, 16)
    elif value.startswith('0b') or value.startswith('0B'):
        num = int(value, 2)
    else:
        num = int(value)

    print(f"  Decimal:     {num}")
    print(f"  Hexadecimal: 0x{num:X}")
    print(f"  Binary:      0b{num:b}")
    print(f"  Octal:       0o{num:o}")
    print(f"  Bytes (BE):  {num.to_bytes((num.bit_length()+7)//8 or 1, 'big').hex()}")
except ValueError:
    print(f"  [!] Invalid number: {value}")
PYEOF
}

bcd_codec() {
    print_header "BCD Encoder/Decoder"

    echo -e "  ${CYAN}1)${NC} Encode digits to BCD"
    echo -e "  ${CYAN}2)${NC} Decode BCD to digits"
    echo ""
    prompt_msg "Select option: "
    read -r bcd_opt

    python3 << PYEOF
import binascii

def encode_bcd(digits):
    """Encode digit string to BCD"""
    if len(digits) % 2:
        digits += 'F'
    result = bytearray()
    for i in range(0, len(digits), 2):
        low = int(digits[i], 16)
        high = int(digits[i+1], 16)
        result.append((high << 4) | low)
    return bytes(result)

def decode_bcd(data):
    """Decode BCD to digit string"""
    digits = ""
    for byte in data:
        low = byte & 0x0F
        high = (byte >> 4) & 0x0F
        digits += str(low)
        if high != 0x0F:
            digits += str(high)
    return digits

opt = $bcd_opt
if opt == 1:
    digits = input("  Enter digits: ").strip()
    bcd = encode_bcd(digits)
    print(f"  BCD (hex): {binascii.hexlify(bcd).decode()}")
    print(f"  BCD (bytes): {list(bcd)}")
elif opt == 2:
    hex_input = input("  Enter BCD hex: ").strip()
    data = binascii.unhexlify(hex_input)
    digits = decode_bcd(data)
    print(f"  Digits: {digits}")
PYEOF
}

tbcd_codec() {
    print_header "TBCD (Telephony BCD) Encoder/Decoder"

    echo -e "  ${CYAN}1)${NC} Encode to TBCD"
    echo -e "  ${CYAN}2)${NC} Decode from TBCD"
    echo ""
    prompt_msg "Select option: "
    read -r tbcd_opt

    python3 << PYEOF
import binascii

TBCD_CHARS = "0123456789*#abc"

def encode_tbcd(string):
    """Encode string to TBCD format (used in MAP)"""
    result = bytearray()
    for i in range(0, len(string), 2):
        low = TBCD_CHARS.index(string[i]) if i < len(string) else 0x0F
        high = TBCD_CHARS.index(string[i+1]) if i+1 < len(string) else 0x0F
        result.append((high << 4) | low)
    return bytes(result)

def decode_tbcd(data):
    """Decode TBCD to string"""
    result = ""
    for byte in data:
        low = byte & 0x0F
        high = (byte >> 4) & 0x0F
        if low < len(TBCD_CHARS):
            result += TBCD_CHARS[low]
        if high < len(TBCD_CHARS) and high != 0x0F:
            result += TBCD_CHARS[high]
    return result

opt = $tbcd_opt
if opt == 1:
    string = input("  Enter string (0-9,*,#,a-c): ").strip()
    tbcd = encode_tbcd(string)
    print(f"  TBCD (hex): {binascii.hexlify(tbcd).decode()}")
elif opt == 2:
    hex_input = input("  Enter TBCD hex: ").strip()
    data = binascii.unhexlify(hex_input)
    string = decode_tbcd(data)
    print(f"  Decoded: {string}")
PYEOF
}

view_logs() {
    print_header "View Logs"

    if [ -d "$LOG_DIR" ]; then
        echo -e "${WHITE}  Available logs:${NC}"
        echo ""
        ls -la "$LOG_DIR"/*.log 2>/dev/null || echo "  No logs found"
        echo ""
        prompt_msg "Enter log filename to view (or 'latest'): "
        read -r log_choice

        if [ "$log_choice" = "latest" ]; then
            local latest=$(ls -t "$LOG_DIR"/*.log 2>/dev/null | head -1)
            if [ -n "$latest" ]; then
                less "$latest"
            else
                error_msg "No logs found"
            fi
        elif [ -f "$LOG_DIR/$log_choice" ]; then
            less "$LOG_DIR/$log_choice"
        elif [ -f "$log_choice" ]; then
            less "$log_choice"
        else
            error_msg "Log file not found"
        fi
    else
        error_msg "Log directory not found"
    fi
}

view_results() {
    print_header "View Results"

    if [ -d "$RESULTS_DIR" ]; then
        echo -e "${WHITE}  Available results:${NC}"
        echo ""
        local count=0
        for f in "$RESULTS_DIR"/*.txt; do
            if [ -f "$f" ]; then
                ((count++))
                echo -e "  ${CYAN}$count)${NC} $(basename "$f") ($(wc -c < "$f") bytes)"
            fi
        done

        if [ $count -eq 0 ]; then
            info_msg "No results found. Run some scans first."
            return
        fi

        echo ""
        prompt_msg "Enter filename to view (or number): "
        read -r result_choice

        if [[ "$result_choice" =~ ^[0-9]+$ ]]; then
            local file=$(ls "$RESULTS_DIR"/*.txt 2>/dev/null | sed -n "${result_choice}p")
            if [ -f "$file" ]; then
                less "$file"
            fi
        elif [ -f "$RESULTS_DIR/$result_choice" ]; then
            less "$RESULTS_DIR/$result_choice"
        fi
    else
        error_msg "Results directory not found"
    fi
}

clean_workspace() {
    print_header "Clean Workspace"

    echo -e "${WHITE}  Select what to clean:${NC}"
    echo ""
    echo -e "  ${CYAN}1)${NC} Clear logs"
    echo -e "  ${CYAN}2)${NC} Clear results"
    echo -e "  ${CYAN}3)${NC} Clear PCAP files"
    echo -e "  ${CYAN}4)${NC} Clear everything"
    echo -e "  ${CYAN}0)${NC} Cancel"
    echo ""
    prompt_msg "Select option: "
    read -r clean_opt

    case $clean_opt in
        1)
            rm -f "$LOG_DIR"/*.log
            success_msg "Logs cleared"
            ;;
        2)
            rm -f "$RESULTS_DIR"/*.txt
            success_msg "Results cleared"
            ;;
        3)
            rm -f "$PCAP_DIR"/*.pcap
            success_msg "PCAP files cleared"
            ;;
        4)
            prompt_msg "Are you sure? This will delete ALL data. (yes/no): "
            read -r confirm
            if [ "$confirm" = "yes" ]; then
                rm -rf "$WORK_DIR"
                setup_directories
                success_msg "Workspace cleaned"
            else
                info_msg "Cancelled"
            fi
            ;;
        0) return ;;
    esac
}

#=====================================================================
# EDUCATIONAL SIMULATIONS
#=====================================================================

educational_simulations() {
    print_header "Educational Simulations"

    echo -e "${WHITE}  Select simulation:${NC}"
    echo ""
    echo -e "  ${CYAN}1)${NC} MAP Message Flow Simulation"
    echo -e "  ${CYAN}2)${NC} SRI-SM Attack Simulation (Educational)"
    echo -e "  ${CYAN}3)${NC} Location Tracking Scenario"
    echo -e "  ${CYAN}4)${NC} SS7 Firewall Bypass Scenarios"
    echo -e "  ${CYAN}5)${NC} Protocol State Machine Viewer"
    echo -e "  ${CYAN}0)${NC} Back"
    echo ""
    prompt_msg "Select option: "
    read -r sim_choice

    case $sim_choice in
        1) map_flow_simulation ;;
        2) sri_sm_simulation ;;
        3) location_tracking_sim ;;
        4) firewall_bypass_scenarios ;;
        5) state_machine_viewer ;;
        0) return ;;
        *) error_msg "Invalid option" ;;
    esac
}

map_flow_simulation() {
    print_header "MAP Message Flow Simulation"

    echo -e "${WHITE}  Select flow to simulate:${NC}"
    echo ""
    echo -e "  ${CYAN}1)${NC} Mobile Originated Call"
    echo -e "  ${CYAN}2)${NC} Mobile Terminated Call"
    echo -e "  ${CYAN}3)${NC} SMS Delivery (MT-SMS)"
    echo -e "  ${CYAN}4)${NC} Location Update"
    echo -e "  ${CYAN}5)${NC} Authentication"
    echo ""
    prompt_msg "Select flow: "
    read -r flow

    case $flow in
        1)
            cat << 'EOF'

  Mobile Originated Call Flow
  ═══════════════════════════

  MS          BSS         MSC/VLR       HLR        GMSC      Called Party
  │            │            │            │           │            │
  │──SETUP───→│            │            │           │            │
  │            │──CM_SRQ──→│            │           │            │
  │            │            │──SAI─────→│           │            │
  │            │            │←─SAI_res──│           │            │
  │            │            │            │           │            │
  │            │←─AUTH_REQ─│            │           │            │
  │←─AUTH_REQ─│            │            │           │            │
  │──AUTH_RSP→│            │            │           │            │
  │            │──AUTH_RSP→│            │           │            │
  │            │            │            │           │            │
  │            
