#!/usr/bin/env python3
"""
NEXUS-OS: Hacker Graphical Terminal Interface for Termux.
A Hollywood-style hacker dashboard with live animations, functional asynchronous shell,
system diagnostics, and animated visualizers.

Dependencies: pip install textual
"""

import os
import sys
import time
import random
import string
import asyncio
from datetime import datetime

# Textual Imports
from textual.app import App, ComposeResult
from textual.containers import Container, Grid, Horizontal, Vertical
from textual.widgets import Header, Footer, RichLog, Input, Static, Label
from textual.reactive import reactive
from textual.worker import get_current_worker

# ==========================================
# CSS STYLING: THE "MATRIX" AESTHETIC
# ==========================================
HACKER_CSS = """
Screen {
    background: #000500;
    color: #00ff00;
}

/* Main Grid Layout */
#nexus-grid {
    layout: grid;
    grid-size: 4 4;
    grid-columns: 1fr 1fr 1fr 1fr;
    grid-rows: 1fr 2fr 2fr 1fr;
    padding: 0;
    grid-gutter: 1;
}

/* Base Panel Styling */
.hacker-panel {
    border: panel #005500;
    background: #000a00;
    padding: 0 1;
}

.hacker-panel:focus-within {
    border: double #00ff00;
    background: #001100;
}

/* Panel Titles */
.panel-title {
    content-align: center middle;
    width: 100%;
    background: #003300;
    color: #00ff00;
    text-style: bold;
    margin-bottom: 1;
}

/* Specific Grid Placements */
#header-panel {
    column-span: 4;
    row-span: 1;
    content-align: center middle;
    border: none;
    background: transparent;
}

#stats-panel {
    column-span: 1;
    row-span: 2;
}

#terminal-panel {
    column-span: 2;
    row-span: 2;
    layout: vertical;
}

#sniffer-panel {
    column-span: 1;
    row-span: 3;
}

#cracker-panel {
    column-span: 1;
    row-span: 1;
}

#radar-panel {
    column-span: 2;
    row-span: 1;
    content-align: center middle;
}

/* Terminal Specifics */
#terminal-log {
    height: 1fr;
    scrollbar-color: #00ff00;
    scrollbar-size: 1 1;
    color: #00cc00;
}

#terminal-input {
    dock: bottom;
    border: solid #005500;
    background: #000500;
    color: #00ff00;
    text-style: bold;
}

/* Animation Specifics */
.alert-text {
    color: #ff0000;
    text-style: bold blink;
}

.success-text {
    color: #00ff00;
    text-style: bold;
}

.cyan-text {
    color: #00ccff;
}
"""

# ==========================================
# UTILITY FUNCTIONS (SYSTEM STATS)
# ==========================================
def get_cpu_stats():
    """Read CPU stats from /proc/stat."""
    try:
        with open("/proc/stat", "r") as f:
            lines = f.readlines()
            for line in lines:
                if line.startswith("cpu "):
                    parts = list(map(int, line.split()[1:8]))
                    idle = parts[3] + parts[4]
                    total = sum(parts)
                    return idle, total
    except Exception:
        pass
    return 0, 0

def get_ram_stats():
    """Read RAM stats from /proc/meminfo."""
    mem_info = {}
    try:
        with open("/proc/meminfo", "r") as f:
            for line in f:
                parts = line.split(":")
                if len(parts) == 2:
                    val = parts[1].strip().split()[0]
                    mem_info[parts[0]] = int(val)
        total = mem_info.get("MemTotal", 1)
        free = mem_info.get("MemFree", 0)
        buffers = mem_info.get("Buffers", 0)
        cached = mem_info.get("Cached", 0)
        used = total - free - buffers - cached
        return used, total
    except Exception:
        return 1, 1

def create_progress_bar(percentage, length=20):
    """Generates an ASCII progress bar [||||    ]"""
    filled = int((percentage / 100) * length)
    empty = length - filled
    return f"[{'#' * filled}{'-' * empty}]"

# ==========================================
# ANIMATED WIDGETS (THE HACKER VISUALS)
# ==========================================

class GlitchHeader(Static):
    """Displays a large ASCII header that occasionally 'glitches'."""
    
    BASE_ART = """
    ███╗   ██╗███████╗██╗  ██╗██╗   ██╗███████╗    ████████╗███████╗██████╗ ███╗   ███╗
    ████╗  ██║██╔════╝╚██╗██╔╝██║   ██║██╔════╝    ╚══██╔══╝██╔════╝██╔══██╗████╗ ████║
    ██╔██╗ ██║█████╗   ╚███╔╝ ██║   ██║███████╗       ██║   █████╗  ██████╔╝██╔████╔██║
    ██║╚██╗██║██╔══╝   ██╔██╗ ██║   ██║╚════██║       ██║   ██╔══╝  ██╔══██╗██║╚██╔╝██║
    ██║ ╚████║███████╗██╔╝ ██╗╚██████╔╝███████║       ██║   ███████╗██║  ██║██║ ╚═╝ ██║
    ╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝       ╚═╝   ╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝
    """
    
    def on_mount(self) -> None:
        self.update(f"[b #00ff00]{self.BASE_ART}[/]")
        self.set_interval(3.5, self.glitch)

    def glitch(self) -> None:
        """Briefly changes color or adds weird characters to simulate a glitch."""
        glitch_chars = "!@#$%^&*()_+-=[]{}|;:,.<>?"
        glitched_art = ""
        for char in self.BASE_ART:
            if char != " " and char != "\n" and random.random() > 0.95:
                glitched_art += random.choice(glitch_chars)
            else:
                glitched_art += char
                
        # Flash cyan or red rarely
        color = random.choice(["#00ff00", "#00ff00", "#00ccff", "#ff0000"])
        self.update(f"[b {color}]{glitched_art}[/]")
        
        # Reset quickly after glitch
        def reset():
            self.update(f"[b #00ff00]{self.BASE_ART}[/]")
        self.set_timer(0.15, reset)


class SystemDiagnostics(Static):
    """Live ASCII CPU/RAM Bars and System Status."""
    
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.prev_idle = 0
        self.prev_total = 0
        self.auth_blink = True

    def on_mount(self) -> None:
        self.update_stats()
        self.set_interval(1.0, self.update_stats)

    def update_stats(self) -> None:
        # CPU
        idle, total = get_cpu_stats()
        diff_idle = idle - self.prev_idle
        diff_total = total - self.prev_total
        cpu_usage = 0.0
        if diff_total > 0:
            cpu_usage = (1.0 - (diff_idle / diff_total)) * 100
        self.prev_idle = idle
        self.prev_total = total
        
        # RAM
        used_mem, total_mem = get_ram_stats()
        ram_usage = (used_mem / total_mem) * 100 if total_mem > 0 else 0
        
        cpu_bar = create_progress_bar(cpu_usage, 15)
        ram_bar = create_progress_bar(ram_usage, 15)
        
        # Determine bar colors
        cpu_color = "#ff0000" if cpu_usage > 85 else ("#ffff00" if cpu_usage > 60 else "#00ff00")
        ram_color = "#ff0000" if ram_usage > 85 else ("#ffff00" if ram_usage > 60 else "#00ff00")
        
        # Blinking Uplink status
        self.auth_blink = not self.auth_blink
        uplink_status = "[b #00ff00]ONLINE  [/]" if self.auth_blink else "[b #005500]ONLINE  [/]"
        
        content = (
            f"[b]SYS_NODE: [cyan]TERMINAL-PRIME[/cyan][/b]\n"
            f"────────────────────────────\n\n"
            f"CPU: [{cpu_color}]{cpu_bar}[/] {cpu_usage:04.1f}%\n\n"
            f"RAM: [{ram_color}]{ram_bar}[/] {ram_usage:04.1f}%\n\n"
            f"────────────────────────────\n"
            f"UPLINK STAT : {uplink_status}\n"
            f"ENCRYPTION  : [b #00ff00]AES-256[/b]\n"
            f"PROXY CHAIN : [b #00ff00]ACTIVE (7)[/b]\n"
            f"ROOT PRIV   : [b #ff0000]GRANTED[/b]\n"
        )
        self.update(content)


class NetworkSniffer(Container):
    """Simulates a rapid scrolling log of intercepted network packets."""
    
    def compose(self) -> ComposeResult:
        yield Label("📡 LIVE PACKET INTERCEPT", classes="panel-title")
        self.log_widget = RichLog(id="sniffer-log", highlight=False, markup=True)
        yield self.log_widget

    def on_mount(self) -> None:
        self.set_interval(0.1, self.inject_packet) # Very fast update

    def generate_ip(self):
        return f"{random.randint(1,255)}.{random.randint(0,255)}.{random.randint(0,255)}.{random.randint(1,255)}"
        
    def generate_mac(self):
        return ":".join([f"{random.randint(0, 255):02X}" for _ in range(6)])

    def inject_packet(self) -> None:
        protocols = ["TCP", "UDP", "ICMP", "HTTP", "TLSv1.3", "SSH", "DNS"]
        flags = ["[SYN]", "[ACK]", "[FIN]", "[RST]", "[PSH]", ""]
        
        proto = random.choice(protocols)
        src = f"{self.generate_ip()}:{random.randint(1024, 65535)}"
        dst = f"{self.generate_ip()}:{random.choice([80, 443, 22, 53, 8080, 3306])}"
        flag = random.choice(flags)
        length = random.randint(40, 1500)
        
        # Formatting for matrix look
        if proto == "TCP" or proto == "UDP":
            color = "#005500"
        elif proto == "TLSv1.3" or proto == "SSH":
            color = "#00ccff" # Cyan for encrypted
        else:
            color = "#00ff00"
            
        if random.random() > 0.98: # Occasional "red flag" packet
            line = f"[b #ff0000]!!! ANOMALY DETECTED: {src} -> {dst} LEN={length}[/]"
        else:
            line = f"[{color}]{proto}[/] {src} -> {dst} {flag} LEN={length}"
            
        self.log_widget.write(line)


class HashCracker(Static):
    """Animates a password/hash bruteforce decrypter."""
    
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.targets = ["ADMIN_PAYLOAD", "ROOT_OVERRIDE", "SYS_BACKDOOR", "DB_MASTER_KEY"]
        self.current_target = random.choice(self.targets)
        self.cracked_chars = 0
        self.chars = string.ascii_uppercase + string.digits + "!@#$%^&*"

    def on_mount(self) -> None:
        self.set_interval(0.08, self.animate_crack)

    def animate_crack(self) -> None:
        target_len = len(self.current_target)
        
        # Randomly advance the cracked count
        if random.random() > 0.9 and self.cracked_chars < target_len:
            self.cracked_chars += 1
            
        # Generate the display string
        display = ""
        for i in range(target_len):
            if i < self.cracked_chars:
                display += f"[b #00ff00]{self.current_target[i]}[/]"
            else:
                display += f"[#005500]{random.choice(self.chars)}[/]"
                
        # Status text
        if self.cracked_chars >= target_len:
            status = "[b blink #00ff00]DECRYPTED[/]"
            # Reset after a few seconds
            if random.random() > 0.95:
                self.current_target = random.choice(self.targets)
                self.cracked_chars = 0
        else:
            status = "[b #ff0000]BRUTEFORCING...[/]"
            
        hex_dump = " ".join([f"{random.randint(0, 255):02X}" for _ in range(8)])
            
        content = (
            f"[b]MODULE:[/] SHADOW_CRACK v3.1\n"
            f"[b]TARGET:[/] 0x{hex_dump}\n\n"
            f"[{display}]\n\n"
            f"STATUS: {status}"
        )
        self.update(content)


class CyberRadar(Static):
    """An animated ASCII radar/spinner for background visuals."""
    
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.frames = [
            "[#00ff00]⣾[/] UPLINK ESTABLISHED", 
            "[#00cc00]⣽[/] UPLINK ESTABLISHED", 
            "[#009900]⣻[/] SCANNING NODES...", 
            "[#006600]⢿[/] SCANNING NODES...", 
            "[#003300]⡿[/] BYPASSING FIREWALL", 
            "[#006600]⣟[/] BYPASSING FIREWALL", 
            "[#009900]⣯[/] INJECTING PAYLOAD", 
            "[#00cc00]⣷[/] INJECTING PAYLOAD"
        ]
        self.frame_idx = 0
        self.geo_lat = random.uniform(-90, 90)
        self.geo_lon = random.uniform(-180, 180)

    def on_mount(self) -> None:
        self.set_interval(0.15, self.spin)

    def spin(self) -> None:
        self.frame_idx = (self.frame_idx + 1) % len(self.frames)
        spinner = self.frames[self.frame_idx]
        
        # Change coordinates slightly
        self.geo_lat += random.uniform(-0.1, 0.1)
        self.geo_lon += random.uniform(-0.1, 0.1)
        
        content = (
            f"{spinner}\n"
            f"TRACING SATELLITE COMMS\n"
            f"LAT: [cyan]{self.geo_lat:.4f}[/]\n"
            f"LON: [cyan]{self.geo_lon:.4f}[/]\n"
            f"[#005500]SIG_STRENGTH: {'|' * random.randint(5,15)}[/]"
        )
        self.update(content)


# ==========================================
# FUNCTIONAL TERMINAL COMPONENT
# ==========================================
class RealTerminal(Container):
    """The functional heart of the Hacker GUI. A real async shell."""
    
    def compose(self) -> ComposeResult:
        yield Label("TERMINAL_ACCESS // ROOT", classes="panel-title")
        self.log_widget = RichLog(id="terminal-log", markup=True, highlight=True)
        yield self.log_widget
        self.input_widget = Input(placeholder="Execute command...", id="terminal-input")
        yield self.input_widget

    def on_mount(self) -> None:
        # Init shell path to Termux home
        self.current_dir = os.environ.get("HOME", "/data/data/com.termux/files/home")
        
        # Boot sequence animation for terminal
        self.run_worker(self.boot_sequence(), exclusive=True)

    async def boot_sequence(self):
        """Simulate a computer booting up before yielding control."""
        self.input_widget.disabled = True
        boot_lines = [
            "Initializing Nexus Kernel v9.4.2...",
            "Loading cryptographic modules [OK]",
            "Mounting virtual filesystems [OK]",
            "Bypassing mainframe security [OK]",
            "Establishing secure proxy tunnel...",
            "Connected to remote node.",
            "[b #00ff00]Welcome to Nexus OS. You have ROOT access.[/b]\n"
        ]
        for line in boot_lines:
            self.log_widget.write(f"[#005500]>[/] {line}")
            await asyncio.sleep(random.uniform(0.1, 0.4))
            
        self.input_widget.disabled = False
        self.update_prompt()
        self.input_widget.focus()

    def update_prompt(self):
        short_dir = self.current_dir.replace(os.environ.get("HOME", ""), "~")
        self.input_widget.placeholder = f"root@nexus:{short_dir}# "

    async def on_input_submitted(self, event: Input.Submitted) -> None:
        command = event.value.strip()
        self.input_widget.value = ""
        
        if not command:
            return
            
        short_dir = self.current_dir.replace(os.environ.get("HOME", ""), "~")
        self.log_widget.write(f"\n[bold #00ff00]root@nexus:[cyan]{short_dir}[/cyan]#[/] {command}")
        
        # Handle internal commands
        if command.lower() == "clear":
            self.log_widget.clear()
            return
        elif command.lower() == "exit":
            self.app.exit()
            return
        elif command.startswith("cd "):
            target = command.split(" ", 1)[1]
            if target == "~":
                target = os.environ.get("HOME", "")
            
            new_dir = os.path.abspath(os.path.join(self.current_dir, target))
            if os.path.isdir(new_dir):
                self.current_dir = new_dir
                self.update_prompt()
            else:
                self.log_widget.write(f"[red]cd: {target}: Directory not found.[/red]")
            return

        # Execute external command safely
        self.run_worker(self.execute_command(command), exclusive=False)

    async def execute_command(self, command: str) -> None:
        """Runs the shell command and streams output async to prevent GUI freezing."""
        worker = get_current_worker()
        try:
            process = await asyncio.create_subprocess_shell(
                command,
                cwd=self.current_dir,
                stdout=asyncio.subprocess.PIPE,
                stderr=asyncio.subprocess.PIPE,
            )

            async def read_stream(stream, is_stderr=False):
                while True:
                    line = await stream.readline()
                    if not line:
                        break
                    decoded_line = line.decode('utf-8', errors='replace').rstrip()
                    if not worker.is_cancelled:
                        if is_stderr:
                            self.app.call_from_thread(self.log_widget.write, f"[red]{decoded_line}[/red]")
                        else:
                            # Format output in hacker green
                            self.app.call_from_thread(self.log_widget.write, f"[#00cc00]{decoded_line}[/]")

            # Await both streams concurrently
            await asyncio.gather(
                read_stream(process.stdout),
                read_stream(process.stderr, is_stderr=True)
            )
            
            await process.wait()
            
        except Exception as e:
            self.app.call_from_thread(self.log_widget.write, f"[bold red]EXECUTION ERROR:[/] {str(e)}")


# ==========================================
# MAIN APP CLASS
# ==========================================
class HackerDashboard(App):
    """Main Application coordinating the Hacker GUI components."""
    
    CSS = HACKER_CSS
    TITLE = "NEXUS-OS TERMINAL"
    SUB_TITLE = "ENCRYPTED CONNECTION ACTIVE"
    
    BINDINGS = [
        ("ctrl+q", "quit", "Disconnect"),
        ("ctrl+t", "focus_terminal", "Focus Shell"),
    ]

    def compose(self) -> ComposeResult:
        """Assemble the Matrix Grid."""
        yield Header(show_clock=True)
        
        with Grid(id="nexus-grid"):
            # Row 1: Giant ASCII Header
            with Container(id="header-panel"):
                yield GlitchHeader()
                
            # Row 2 & 3 (Left): System Stats
            with Container(id="stats-panel", classes="hacker-panel"):
                yield Label("DIAGNOSTICS", classes="panel-title")
                yield SystemDiagnostics()

            # Row 2 & 3 (Center): Real Working Terminal
            with Container(id="terminal-panel", classes="hacker-panel"):
                yield RealTerminal()

            # Row 2 & 3 & 4 (Right): Network Sniffer
            with Container(id="sniffer-panel", classes="hacker-panel"):
                yield NetworkSniffer()

            # Row 4 (Left): Hash Bruteforcer
            with Container(id="cracker-panel", classes="hacker-panel"):
                yield Label("DECRYPTION UNIT", classes="panel-title")
                yield HashCracker()
                
            # Row 4 (Center): Radar/Uplink module
            with Container(id="radar-panel", classes="hacker-panel"):
                yield Label("SATELLITE UPLINK", classes="panel-title")
                yield CyberRadar()

        yield Footer()

    # --- Action Handlers ---
    def action_focus_terminal(self) -> None:
        """Hotkey to return focus to the real command line."""
        terminal_input = self.query_one("#terminal-input", Input)
        terminal_input.focus()

    def action_quit(self) -> None:
        """Exit the mainframe."""
        self.exit()


# ==========================================
# ENTRY POINT
# ==========================================
if __name__ == "__main__":
    # Ensure Termux/Linux compatibility
    if sys.platform not in ["linux", "android"]:
        print("\033[91mWARNING: System architecture not optimal. NEXUS-OS designed for Termux/Linux.\033[0m")
        time.sleep(1)
        
    app = HackerDashboard()
    app.run()
