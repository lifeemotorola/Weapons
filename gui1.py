#!/usr/bin/env python3
"""
Termux Advanced Graphical Terminal Dashboard.
A beautiful, highly organized TUI (Terminal User Interface) built for Termux.
Features: File Explorer, Async Terminal, System Monitor, File Editor, and Termux API.

Dependencies: pip install textual
System Requirements: Termux, termux-api (pkg install termux-api)
"""

import os
import sys
import json
import asyncio
import datetime
import subprocess
from pathlib import Path

# Textual Imports
from textual.app import App, ComposeResult
from textual.containers import Container, Grid, Horizontal, Vertical, ScrollableContainer
from textual.widgets import (
    Header, Footer, DirectoryTree, RichLog, Input, 
    Static, Button, Label, Markdown, TextArea
)
from textual.reactive import reactive
from textual.binding import Binding
from textual.screen import Screen
from textual.worker import Worker, get_current_worker

# ==========================================
# CSS STYLING
# ==========================================
# This defines the beautiful grid layout and neon/cyberpunk color scheme.
DASHBOARD_CSS = """
Screen {
    background: #0d1117;
    color: #c9d1d9;
}

#main-grid {
    layout: grid;
    grid-size: 4 3;
    grid-columns: 1fr 1fr 1fr 1fr;
    grid-rows: 1fr 2fr 2fr;
    padding: 1;
    grid-gutter: 1;
}

.box {
    border: round #30363d;
    background: #161b22;
    padding: 0 1;
}

.box:focus-within {
    border: double #58a6ff;
}

.panel-title {
    content-align: center middle;
    width: 100%;
    background: #238636;
    color: white;
    text-style: bold;
    margin-bottom: 1;
}

/* Specific Panel Layouts */
#sys-monitor {
    column-span: 1;
    row-span: 1;
}

#termux-api-panel {
    column-span: 1;
    row-span: 1;
}

#clock-panel {
    column-span: 2;
    row-span: 1;
    content-align: center middle;
}

#file-browser {
    column-span: 1;
    row-span: 2;
}

#editor-panel {
    column-span: 3;
    row-span: 1;
}

#terminal-panel {
    column-span: 3;
    row-span: 1;
    layout: vertical;
}

/* Widget Specific Styling */
#terminal-log {
    height: 1fr;
    border-bottom: solid #30363d;
    scrollbar-color: #58a6ff;
    scrollbar-size: 1 1;
}

#terminal-input {
    dock: bottom;
    border: none;
    background: #0d1117;
    color: #58a6ff;
}

#file-tree {
    height: 1fr;
    scrollbar-size: 1 1;
}

#text-editor {
    height: 1fr;
    border: none;
}

#clock-text {
    text-align: center;
    text-style: bold;
    color: #79c0ff;
}

.stat-label {
    color: #8b949e;
}

.stat-value {
    color: #3fb950;
    text-style: bold;
}
"""

# ==========================================
# UTILITY FUNCTIONS
# ==========================================

def get_termux_api(command: str) -> dict:
    """Execute a Termux API command and return parsed JSON."""
    try:
        result = subprocess.run(
            [command], stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True
        )
        if result.returncode == 0:
            return json.loads(result.stdout)
    except Exception:
        pass
    return {}

def read_proc_stat():
    """Read CPU statistics from /proc/stat."""
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
        return 0, 0
    return 0, 0

def read_proc_mem():
    """Read Memory statistics from /proc/meminfo."""
    mem_info = {}
    try:
        with open("/proc/meminfo", "r") as f:
            for line in f:
                parts = line.split(":")
                if len(parts) == 2:
                    val = parts[1].strip().split()[0]
                    mem_info[parts[0]] = int(val)
    except Exception:
        return 1, 1 # Prevent division by zero
    
    total = mem_info.get("MemTotal", 1)
    free = mem_info.get("MemFree", 0)
    buffers = mem_info.get("Buffers", 0)
    cached = mem_info.get("Cached", 0)
    
    used = total - free - buffers - cached
    return used, total

# ==========================================
# CUSTOM WIDGETS
# ==========================================

class ClockWidget(Static):
    """A highly visible digital clock."""
    
    time_str = reactive("")
    
    def on_mount(self) -> None:
        self.update_time()
        self.set_interval(1.0, self.update_time)

    def update_time(self) -> None:
        now = datetime.datetime.now()
        date_str = now.strftime("%A, %B %d, %Y")
        time_str = now.strftime("%H:%M:%S")
        self.update(f"🗓️  {date_str}\n\n🕒 [b]{time_str}[/b]")


class SystemMonitor(Static):
    """Displays live CPU and RAM usage."""
    
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.prev_idle = 0
        self.prev_total = 0

    def on_mount(self) -> None:
        self.update_stats()
        self.set_interval(2.0, self.update_stats)

    def update_stats(self) -> None:
        # CPU Calc
        idle, total = read_proc_stat()
        diff_idle = idle - self.prev_idle
        diff_total = total - self.prev_total
        
        cpu_usage = 0.0
        if diff_total > 0:
            cpu_usage = (1.0 - (diff_idle / diff_total)) * 100
            
        self.prev_idle = idle
        self.prev_total = total
        
        # RAM Calc
        used_mem, total_mem = read_proc_mem()
        ram_usage = (used_mem / total_mem) * 100 if total_mem > 0 else 0
        
        # Disk Calc (Termux Home)
        try:
            st = os.statvfs(os.environ.get("HOME", "/data/data/com.termux/files/home"))
            total_disk = (st.f_blocks * st.f_frsize) / (1024**3)
            free_disk = (st.f_bavail * st.f_frsize) / (1024**3)
            used_disk = total_disk - free_disk
            disk_usage = (used_disk / total_disk) * 100
        except Exception:
            disk_usage = 0.0
            
        content = (
            f"💻 [b]System Resources[/b]\n\n"
            f"[#8b949e]CPU Usage:[/] [#3fb950]{cpu_usage:.1f}%[/]\n"
            f"[#8b949e]RAM Usage:[/] [#3fb950]{ram_usage:.1f}%[/]\n"
            f"[#8b949e]Storage:  [/] [#3fb950]{disk_usage:.1f}%[/]\n"
        )
        self.update(content)


class TermuxAPIMonitor(Static):
    """Displays Android Device status via Termux-API."""
    
    def on_mount(self) -> None:
        self.update_api_stats()
        self.set_interval(10.0, self.update_api_stats) # Update every 10s to save battery

    def update_api_stats(self) -> None:
        battery = get_termux_api("termux-battery-status")
        wifi = get_termux_api("termux-wifi-connectioninfo")
        
        bat_percent = battery.get("percentage", "N/A")
        bat_status = battery.get("status", "N/A")
        bat_temp = battery.get("temperature", 0)
        
        ssid = wifi.get("ssid", "Disconnected")
        ip = wifi.get("ip", "N/A")
        
        content = (
            f"📱 [b]Android Device[/b]\n\n"
            f"[#8b949e]Battery:[/] [#3fb950]{bat_percent}% ({bat_status})[/]\n"
            f"[#8b949e]Temp:   [/] [#3fb950]{bat_temp}°C[/]\n"
            f"[#8b949e]Wi-Fi:  [/] [#3fb950]{ssid}[/]\n"
            f"[#8b949e]IP Addr:[/] [#3fb950]{ip}[/]\n"
        )
        self.update(content)


class BuiltInTerminal(Container):
    """A custom asynchronous terminal emulator wrapper."""
    
    def compose(self) -> ComposeResult:
        yield Label("  Termux Async Shell", classes="panel-title")
        self.log_widget = RichLog(id="terminal-log", markup=True, highlight=True)
        yield self.log_widget
        self.input_widget = Input(placeholder="Enter command... (e.g., ls -la, pkg update)", id="terminal-input")
        yield self.input_widget

    def on_mount(self) -> None:
        # Start in Termux home directory
        self.current_dir = os.environ.get("HOME", "/data/data/com.termux/files/home")
        self.log_widget.write(f"[#58a6ff]Welcome to Termux Advanced GUI.[/]")
        self.log_widget.write(f"System architecture: {os.uname().machine}")
        self.update_prompt()

    def update_prompt(self):
        short_dir = self.current_dir.replace(os.environ.get("HOME", ""), "~")
        self.input_widget.placeholder = f"user@termux:{short_dir}$ "

    async def on_input_submitted(self, event: Input.Submitted) -> None:
        command = event.value.strip()
        self.input_widget.value = ""
        
        if not command:
            return
            
        short_dir = self.current_dir.replace(os.environ.get("HOME", ""), "~")
        self.log_widget.write(f"\n[bold green]user@termux:[bold blue]{short_dir}$[/] {command}")
        
        # Handle internal commands
        if command == "clear":
            self.log_widget.clear()
            return
        elif command == "exit":
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
                self.log_widget.write(f"[red]cd: {target}: No such file or directory[/red]")
            return

        # Execute external command asynchronously
        self.run_worker(self.execute_command(command), exclusive=False)

    async def execute_command(self, command: str) -> None:
        """Runs the shell command and streams output to the RichLog."""
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
                            self.app.call_from_thread(self.log_widget.write, decoded_line)

            # Await both streams concurrently
            await asyncio.gather(
                read_stream(process.stdout),
                read_stream(process.stderr, is_stderr=True)
            )
            
            await process.wait()
            
        except Exception as e:
            self.app.call_from_thread(self.log_widget.write, f"[bold red]Error executing command:[/] {str(e)}")


class FileEditorPanel(Container):
    """Allows previewing and editing files selected in the file browser."""
    
    def compose(self) -> ComposeResult:
        yield Label("📝 File Editor (Select a file to edit)", id="editor-title", classes="panel-title")
        self.text_area = TextArea(id="text-editor", language="python")
        yield self.text_area
        with Horizontal():
            yield Button("Save File", id="btn-save", variant="success")
            yield Button("Clear", id="btn-clear", variant="warning")
            
        self.current_file_path = None

    def load_file(self, filepath: str) -> None:
        self.current_file_path = filepath
        title = self.query_one("#editor-title", Label)
        title.update(f"📝 Editing: {os.path.basename(filepath)}")
        
        try:
            with open(filepath, "r", encoding="utf-8") as f:
                content = f.read()
            self.text_area.text = content
            
            # Auto-detect basic syntax highlighting
            ext = filepath.split('.')[-1].lower()
            lang_map = {
                "py": "python", "json": "json", "md": "markdown", 
                "html": "html", "css": "css", "js": "javascript",
                "sh": "bash"
            }
            if ext in lang_map:
                self.text_area.language = lang_map[ext]
            else:
                self.text_area.language = None
                
        except UnicodeDecodeError:
            self.text_area.text = "Error: Binary file or unsupported encoding."
            self.current_file_path = None
        except Exception as e:
            self.text_area.text = f"Error loading file: {str(e)}"
            self.current_file_path = None

    def on_button_pressed(self, event: Button.Pressed) -> None:
        if event.button.id == "btn-save":
            if self.current_file_path:
                try:
                    with open(self.current_file_path, "w", encoding="utf-8") as f:
                        f.write(self.text_area.text)
                    self.app.notify(f"Saved: {os.path.basename(self.current_file_path)}", title="Success")
                except Exception as e:
                    self.app.notify(f"Failed to save: {str(e)}", title="Error", severity="error")
            else:
                self.app.notify("No file currently open to save.", title="Warning", severity="warning")
                
        elif event.button.id == "btn-clear":
            self.text_area.text = ""
            self.current_file_path = None
            title = self.query_one("#editor-title", Label)
            title.update("📝 File Editor (Cleared)")


# ==========================================
# MAIN APP CLASS
# ==========================================

class TermuxDashboard(App):
    """The main application class configuring the Terminal UI."""
    
    CSS = DASHBOARD_CSS
    TITLE = "Termux Advanced Interface"
    SUB_TITLE = "Graphical Environment for CLI"
    
    BINDINGS = [
        Binding("ctrl+q", "quit", "Quit App"),
        Binding("ctrl+t", "focus_terminal", "Focus Terminal"),
        Binding("ctrl+e", "focus_editor", "Focus Editor"),
        Binding("ctrl+f", "focus_files", "Focus Files"),
    ]

    def compose(self) -> ComposeResult:
        """Create child widgets for the app."""
        yield Header(show_clock=True)
        
        # Main Layout Grid
        with Grid(id="main-grid"):
            
            # Row 1: System Info, Termux API, Clock
            with Container(id="sys-monitor", classes="box"):
                yield Label("📊 Hardware", classes="panel-title")
                yield SystemMonitor()
                
            with Container(id="termux-api-panel", classes="box"):
                yield Label("📡 Connectivity", classes="panel-title")
                yield TermuxAPIMonitor()
                
            with Container(id="clock-panel", classes="box"):
                yield ClockWidget(id="clock-text")

            # Row 2 & 3 (Left): File Browser
            with Container(id="file-browser", classes="box"):
                yield Label("📁 File System", classes="panel-title")
                home_dir = os.environ.get("HOME", "/")
                yield DirectoryTree(home_dir, id="file-tree")

            # Row 2 (Right): File Editor
            with Container(id="editor-panel", classes="box"):
                yield FileEditorPanel()

            # Row 3 (Right): Async Terminal Emulator
            with Container(id="terminal-panel", classes="box"):
                yield BuiltInTerminal()

        yield Footer()

    # --- Event Handlers ---

    def on_directory_tree_file_selected(self, event: DirectoryTree.FileSelected) -> None:
        """Triggered when a file is clicked in the directory tree."""
        filepath = str(event.path)
        editor = self.query_one(FileEditorPanel)
        editor.load_file(filepath)

    # --- Action Handlers (Keybinds) ---

    def action_focus_terminal(self) -> None:
        """Focus the terminal input field."""
        self.query_one("#terminal-input", Input).focus()

    def action_focus_editor(self) -> None:
        """Focus the text editor field."""
        self.query_one("#text-editor", TextArea).focus()
        
    def action_focus_files(self) -> None:
        """Focus the file browser directory tree."""
        self.query_one("#file-tree", DirectoryTree).focus()

    def action_quit(self) -> None:
        """Safely exit the application."""
        self.exit()


# ==========================================
# ENTRY POINT
# ==========================================
if __name__ == "__main__":
    # Safety check to ensure we are running on Linux/Android
    if sys.platform not in ["linux", "android"]:
        print("Warning: This app is optimized for Linux/Termux environments.")
        
    app = TermuxDashboard()
    app.run()
