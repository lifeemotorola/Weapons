#! /data/data/com.termux/files/usr/bin/python

import os
import time
import platform
import shutil
import json
import subprocess
from rich.console import Console
from rich.panel import Panel
from rich.table import Table
from rich.progress import track
from rich.prompt import Prompt
from rich.text import Text
from rich import box
from rich.status import Status

# Initialize the Rich Console
console = Console()

# --- Configuration ---
CONFIG_FILE = os.path.expanduser("~/.suahco4_tools.conf")
DEFAULT_TOOLS = [
    "nmap", "sqlmap", "htop", "neofetch", "python", "git", "wget", "curl", "vim",
    "nano", "tmux", "ssh", "hydra", "msfconsole", "ruby", "netcat", "nc", "ping",
    "macchanger", "cmatrix", "figlet", "toilet", "rustscan", "zsh", "pkg", "apt"
]
# This list will be loaded from the config file
TOOLS_TO_SCAN = []

def load_or_create_config():
    """Loads the tool list from the config file, or creates it if it doesn't exist."""
    global TOOLS_TO_SCAN
    if os.path.exists(CONFIG_FILE):
        with open(CONFIG_FILE, 'r') as f:
            TOOLS_TO_SCAN = [line.strip() for line in f if line.strip()]
    else:
        TOOLS_TO_SCAN = DEFAULT_TOOLS
        with open(CONFIG_FILE, 'w') as f:
            for tool in TOOLS_TO_SCAN:
                f.write(f"{tool}\n")

def save_config():
    """Saves the current tool list to the config file."""
    with open(CONFIG_FILE, 'w') as f:
        for tool in TOOLS_TO_SCAN:
            f.write(f"{tool}\n")

def check_termux_api():
    """Checks for termux-api and prompts to install if missing."""
    if not shutil.which("termux-battery-status"):
        console.print(Panel("[bold yellow]The 'termux-api' package is required for the Live Stats feature.[/]",
                            title="[bold red]Dependency Missing[/]", border_style="red"))
        if Prompt.confirm("[bold cyan]Do you want to install it now?[/]"):
            os.system("pkg install termux-api -y")
            console.print("[bold green]termux-api installed successfully![/]")
            time.sleep(2)

def clear_screen():
    os.system('clear')

def print_banner():
    banner = """
[bold cyan]  ____  _   _    _    _   _  ____ ___  _  _   [/]
[bold cyan] / ___|| | | |  / \\  | | | |/ ___/ _ \\| || |  [/]
[bold magenta] \\___ \\| | | | / _ \\ | |_| | |  | | | | || |_ [/]
[bold magenta]  ___) | |_| |/ ___ \\|  _  | |__| |_| |__   _|[/]
[bold bright_cyan] |____/ \\___//_/   \\_\\_| |_|\\____\\___/   |_|  [/]
    """
    panel = Panel(
        banner, border_style="bright_magenta", title="[bold yellow] 💎 SUAHCO4 B-Spec v2.0 💎 [/]",
        subtitle="[bold green] ⚡ System Initialized ⚡ [/]", box=box.HEAVY, expand=False
    )
    console.print(panel, justify="center")

def scan_installed_tools():
    installed = []
    for tool in TOOLS_TO_SCAN:
        if shutil.which(tool):
            installed.append(tool)
    return installed

def install_new_tool():
    tool_name = Prompt.ask("[bold cyan]Enter the name of the tool to install (e.g., metasploit)[/]").strip()
    if not tool_name:
        console.print("[bold red]Installation cancelled.[/]")
        time.sleep(1)
        return
        
    with Status(f"[bold green]Attempting to install '{tool_name}' via pkg...[/]", spinner="dots") as status:
        # We use a file to capture output to keep the UI clean
        result = os.system(f"pkg install {tool_name} -y > /dev/null 2>&1")
        
        if shutil.which(tool_name):
            console.print(f"[bold bright_green]✔ '{tool_name}' installed successfully![/]")
            if tool_name not in TOOLS_TO_SCAN:
                TOOLS_TO_SCAN.append(tool_name)
                save_config()
                console.print(f"[bold cyan]Added '{tool_name}' to your SUAHCO4 scan list.[/]")
        else:
            console.print(f"[bold red]✖ Failed to install '{tool_name}'. Check the package name and try again.[/]")
    
    time.sleep(2)


def run_tools_menu():
    while True:
        clear_screen()
        print_banner()
        
        installed_tools = scan_installed_tools()
        
        table = Table(title="[bold yellow]🛠️ SUAHCO4 Installed Tools Detected[/]", box=box.DOUBLE_EDGE, caption_style="bold bright_black")
        table.add_column("ID", justify="center", style="cyan")
        table.add_column("Tool Name", style="magenta")
        
        for i, tool in enumerate(installed_tools):
            table.add_row(f"[{i+1}]", tool)

        console.print(table, justify="center")
        
        # New options for the tool menu
        console.print("\n[bold cyan]Choose an ID to launch a tool.[/]")
        console.print("[bold green]Type 'i' to install a new tool.[/]")
        console.print("[bold red]Type '0' to return to Main Menu.[/]\n")
        
        choice = Prompt.ask("[bold yellow]Enter your choice[/]").lower()
        
        if choice == '0':
            break
        elif choice == 'i':
            install_new_tool()
            # Loop continues, will rescan and show the new tool
        else:
            try:
                idx = int(choice) - 1
                if 0 <= idx < len(installed_tools):
                    selected_tool = installed_tools[idx]
                    args = Prompt.ask(f"[bold cyan]Enter arguments for [magenta]{selected_tool}[/magenta] (or press Enter)[/]")
                    command = f"{selected_tool} {args}".strip()
                    
                    clear_screen()
                    console.print(f"[bold magenta]Executing: {command}[/]\n")
                    time.sleep(1)
                    os.system(command)
                    
                    Prompt.ask("\n[bold yellow]Execution complete. Press Enter to return to SUAHCO4[/]")
                else:
                    console.print("[bold red]Invalid ID.[/]")
                    time.sleep(1)
            except ValueError:
                console.print("[bold red]Invalid input.[/]")
                time.sleep(1)

def live_stats_menu():
    clear_screen()
    print_banner()
    panel_content = Text()

    try:
        # Battery Status
        battery_json = subprocess.check_output(["termux-battery-status"], text=True)
        battery_data = json.loads(battery_json)
        percentage = battery_data['percentage']
        status = battery_data['status']
        color = "green" if percentage > 50 else "yellow" if percentage > 20 else "red"
        panel_content.append(f"🔋 Battery: [{color}]{percentage}%[/] ({status})\n", style="bold")
    except (subprocess.CalledProcessError, json.JSONDecodeError):
        panel_content.append("🔋 Battery: [red]Unavailable[/]\n", style="bold")

    try:
        # WiFi Info
        wifi_json = subprocess.check_output(["termux-wifi-connectioninfo"], text=True)
        wifi_data = json.loads(wifi_json)
        ssid = wifi_data.get('ssid', 'N/A')
        ip = wifi_data.get('ip_address', 'N/A')
        panel_content.append(f"📡 Wi-Fi: [cyan]{ssid}[/]\n", style="bold")
        panel_content.append(f"   IP Addr: [magenta]{ip}[/]\n", style="bold")
    except (subprocess.CalledProcessError, json.JSONDecodeError):
        panel_content.append("📡 Wi-Fi: [red]Not Connected or API Error[/]\n", style="bold")
        
    console.print(Panel(panel_content, title="[bold cyan]SUAHCO4 Live System Stats[/]", border_style="cyan", box=box.DOUBLE))
    Prompt.ask("\n[bold green]Press Enter to return to menu[/]")

def config_menu():
    while True:
        clear_screen()
        print_banner()
        
        config_text = Text()
        config_text.append("1. ", style="bold magenta")
        config_text.append("View Current Tool Scan List\n", style="bold white")
        config_text.append("2. ", style="bold magenta")
        config_text.append("Add a Tool to Scan List\n", style="bold white")
        config_text.append("3. ", style="bold magenta")
        config_text.append("Remove a Tool from Scan List\n", style="bold white")
        config_text.append("0. ", style="bold red")
        config_text.append("Return to Main Menu\n", style="bold white")

        console.print(Panel(config_text, title="[bold yellow]SUAHCO4 Platform Configuration[/]", border_style="yellow", box=box.DOUBLE))
        choice = Prompt.ask("[bold yellow]Select an option[/]", choices=["1", "2", "3", "0"])

        if choice == '1':
            console.print(Panel("\n".join(TOOLS_TO_SCAN), title="[cyan]Current Scan List[/]", border_style="cyan"))
            Prompt.ask("\n[bold green]Press Enter to continue[/]")
        elif choice == '2':
            new_tool = Prompt.ask("[bold cyan]Enter tool name to add[/]").strip().lower()
            if new_tool and new_tool not in TOOLS_TO_SCAN:
                TOOLS_TO_SCAN.append(new_tool)
                save_config()
                console.print(f"[bold green]'{new_tool}' added successfully![/]")
            else:
                console.print("[bold red]Invalid or duplicate tool name.[/]")
            time.sleep(1.5)
        elif choice == '3':
            # Similar to launch menu, show a numbered list
            table = Table(title="[bold red]Select a tool to remove[/]")
            table.add_column("ID", style="cyan")
            table.add_column("Tool", style="magenta")
            for i, tool in enumerate(TOOLS_TO_SCAN):
                table.add_row(str(i + 1), tool)
            console.print(table)
            try:
                rem_choice = int(Prompt.ask("[bold yellow]Enter ID to remove (0 to cancel)[/]"))
                if 0 < rem_choice <= len(TOOLS_TO_SCAN):
                    removed_tool = TOOLS_TO_SCAN.pop(rem_choice - 1)
                    save_config()
                    console.print(f"[bold green]'{removed_tool}' removed successfully![/]")
                else:
                    console.print("[bold red]Cancellation or invalid ID.[/]")
            except ValueError:
                console.print("[bold red]Invalid input.[/]")
            time.sleep(1.5)
        elif choice == '0':
            break

def menu():
    while True:
        clear_screen()
        print_banner()
        
        menu_text = Text()
        menu_text.append("1. ", style="bold cyan")
        menu_text.append("Scan & Launch My Tools\n", style="bold white")
        menu_text.append("2. ", style="bold cyan")
        menu_text.append("Live System Stats\n", style="bold white")
        menu_text.append("3. ", style="bold cyan")
        menu_text.append("Platform Configuration\n", style="bold white")
        menu_text.append("4. ", style="bold red")
        menu_text.append("Exit Platform\n", style="bold white")
        
        console.print(Panel(menu_text, title="[bold cyan]SUAHCO4 Command Center[/]", border_style="cyan", box=box.DOUBLE))
        
        choice = Prompt.ask("[bold yellow]Awaiting SUAHCO4 Input[/]", choices=["1", "2", "3", "4"])
        
        if choice == "1":
            run_tools_menu()
        elif choice == "2":
            live_stats_menu()
        elif choice == "3":
            config_menu()
        elif choice == "4":
            console.print("\n[bold red]Terminating SUAHCO4 Session... Goodbye![/]\n")
            break

if __name__ == "__main__":
    try:
        clear_screen()
        load_or_create_config()
        check_termux_api()
        print_banner()
        for _ in track(range(100), description="[bold magenta]SUAHCO4 Booting B-Spec Modules...[/]"):
            time.sleep(0.01)
        time.sleep(0.2)
        menu()
    except KeyboardInterrupt:
        console.print("\n[bold red]✖ SUAHCO4 Session Aborted by User.[/]\n")
