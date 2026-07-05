#!/data/data/com.termux/files/usr/bin/bash

######################################################################
#                                                                    #
#   COMPLETE TERMUX LESSON & TOOLS GUIDE                             #
#   Author: AI Assistant                                             #
#   Description: Interactive tutorial for learning Termux            #
#   Usage: chmod +x termux_lesson.sh && ./termux_lesson.sh           #
#                                                                    #
######################################################################

# ===================== COLORS & FORMATTING =====================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
BOLD='\033[1m'
UNDERLINE='\033[4m'
RESET='\033[0m'

# Global array to store completed lesson IDs
declare -a COMPLETED_LESSONS=()
PROGRESS_FILE="$HOME/.termux_lesson_progress"
LAST_LESSON_FILE="$HOME/.termux_last_lesson"

# Tool definitions for the installer and status checks
declare -a TOOL_NAMES=(
    "htop"
    "neofetch"
    "nmap"
    "curl"
    "git"
    "python"
    "tmux"
    "ffmpeg"
    "yt-dlp"
    "aria2"
    "tldr"
    "ranger"
    "lazygit"
    "micro"
    "speedtest-go"
    "openssh (ssh client)"
    "zip"
    "unzip"
    "figlet"
    "cmatrix"
    "proxychains-ng"
)

declare -a TOOL_CHECK_COMMANDS=(
    "command -v htop"
    "command -v neofetch"
    "command -v nmap"
    "command -v curl"
    "command -v git"
    "command -v python || command -v python3"
    "command -v tmux"
    "command -v ffmpeg"
    "command -v yt-dlp"
    "command -v aria2c"
    "command -v tldr"
    "command -v ranger"
    "command -v lazygit"
    "command -v micro"
    "command -v speedtest-go"
    "command -v ssh"
    "command -v zip"
    "command -v unzip"
    "command -v figlet"
    "command -v cmatrix"
    "command -v proxychains4"
)

declare -a TOOL_INSTALL_COMMANDS=(
    "pkg install -y htop" # Added -y for non-interactive install
    "pkg install -y neofetch"
    "pkg install -y nmap"
    "pkg install -y curl"
    "pkg install -y git"
    "pkg install -y python"
    "pkg install -y tmux"
    "pkg install -y ffmpeg"
    "pkg install -y python && pip install yt-dlp" # yt-dlp needs pip
    "pkg install -y aria2"
    "pkg install -y tldr"
    "pkg install -y ranger"
    "pkg install -y lazygit"
    "pkg install -y micro"
    "pkg install -y speedtest-go"
    "pkg install -y openssh"
    "pkg install -y zip"
    "pkg install -y unzip"
    "pkg install -y figlet"
    "pkg install -y cmatrix"
    "pkg install -y proxychains-ng"
)

# ===================== HELPER FUNCTIONS =====================

banner() {
    clear
    echo -e "${CYAN}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                                                            ║"
    echo "║       ████████╗███████╗██████╗ ███╗   ███╗██╗   ██╗██╗  ██║"
    echo "║       ╚══██╔══╝██╔════╝██╔══██╗████╗ ████║██║   ██║╚██╗██╔║"
    echo "║          ██║   █████╗  ██████╔╝██╔████╔██║██║   ██║ ╚███╔╝║"
    echo "║          ██║   ██╔══╝  ██╔══██╗██║╚██╔╝██║██║   ██║ ██╔██╗║"
    echo "║          ██║   ███████╗██║  ██║██║ ╚═╝ ██║╚██████╔╝██╔╝ ██║"
    echo "║          ╚═╝   ╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝ ╚═════╝╚═╝  ╚═║"
    echo "║                                                            ║"
    echo "║            COMPLETE TERMUX LESSON & TOOLS GUIDE            ║"
    echo "║                                                            ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${RESET}"
}

section_header() {
    echo ""
    echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "${BOLD}${YELLOW}  📘 $1${RESET}"
    echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo ""
}

sub_header() {
    echo ""
    echo -e "${CYAN}  ── $1 ──${RESET}"
    echo ""
}

info() {
    echo -e "  ${GREEN}[✔]${RESET} $1"
}

warn() {
    echo -e "  ${YELLOW}[!]${RESET} $1"
}

error() {
    echo -e "  ${RED}[✘]${RESET} $1"
}

cmd_example() {
    echo -e "  ${WHITE}${BOLD}Command:${RESET} ${CYAN}$1${RESET}"
    echo -e "  ${WHITE}${BOLD}Purpose:${RESET} $2"
    echo ""
}

code_block() {
    echo -e "  ${BLUE}┌─────────────────────────────────────────────────┐${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}$1${RESET}"
    echo -e "  ${BLUE}└─────────────────────────────────────────────────┘${RESET}"
}

interactive_tool() {
    local cmd="$1"
    local desc="$2"
    cmd_example "$cmd" "$desc"
    if confirm_run; then
        run_demo "$cmd"
    fi
    echo ""
}

load_progress() {
    if [[ -f "$PROGRESS_FILE" ]]; then
        mapfile -t COMPLETED_LESSONS < "$PROGRESS_FILE"
    fi
}

save_progress() {
    printf "%s\n" "${COMPLETED_LESSONS[@]}" > "$PROGRESS_FILE"
}

mark_lesson_complete() {
    local lesson_id="$1"
    local found=0
    for id in "${COMPLETED_LESSONS[@]}"; do
        if [[ "$id" == "$lesson_id" ]]; then
            found=1
            break
        fi
    done

    if [[ "$found" -eq 0 ]]; then
        COMPLETED_LESSONS+=("$lesson_id")
        save_progress
        info "Lesson $lesson_id marked as complete!"
    else
        warn "Lesson $lesson_id was already marked as complete."
    fi
}

is_lesson_complete() {
    local lesson_id="$1"
    for id in "${COMPLETED_LESSONS[@]}"; do
        if [[ "$id" == "$lesson_id" ]]; then
            return 0 # True
        fi
    done
    return 1 # False
}

pause_continue() {
    echo ""
    echo -e "  ${YELLOW}Press [ENTER] to continue...${RESET}"
    read -r
}

run_demo() {
    echo -e "  ${GREEN}${BOLD}Running Demo:${RESET} ${CYAN}$1${RESET}"
    echo -e "  ${BLUE}───── Output ─────${RESET}"
    eval "$1" 2>&1 | sed 's/^/    /'
    echo -e "  ${BLUE}───── End ────────${RESET}"
    echo ""
}

confirm_run() {
    echo -e "  ${YELLOW}Do you want to run this command? (y/n):${RESET} \c"
    read -r choice
    if [[ "$choice" == "y" || "$choice" == "Y" ]]; then
        return 0
    else
        return 1
    fi
}

save_last_lesson() {
    echo "$1" > "$LAST_LESSON_FILE"
}

continue_last_lesson() {
    if [[ -f "$LAST_LESSON_FILE" ]]; then
        local last_id
        last_id=$(cat "$LAST_LESSON_FILE")
        execute_choice "$last_id"
    else
        error "No history found. Please start a lesson first!"
        sleep 1
        main_menu
    fi
}

execute_choice() {
    local choice="$1"
    
    # Save history for valid lesson numbers (1-23)
    if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le 23 ]; then
        save_last_lesson "$choice"
    fi

    case $choice in
        1) lesson_intro ;;
        2) lesson_package_mgmt ;;
        3) lesson_filesystem ;;
        4) lesson_file_ops ;;
        5) lesson_permissions ;;
        6) lesson_networking ;;
        7) lesson_programming ;;
        8) lesson_sysinfo ;;
        9) lesson_storage ;;
        10) lesson_security ;;
        11) lesson_scripting ;;
        12) lesson_advanced ;;
        13) lesson_ssh ;;
        14) lesson_git ;;
        15) lesson_database ;;
        16) lesson_customization ;;
        17) full_setup ;;
        18) cheat_sheet ;;
        19) search_tool ;;
        20) lesson_quiz ;;
        21) sandbox_mode ;;
        22) lesson_popular_tools ;;
        23) lesson_tool_installer ;;
        c|C) continue_last_lesson ;;
        0) echo -e "\n  ${GREEN}Goodbye! Happy hacking! 🎉${RESET}\n"; exit 0 ;;
        *) echo -e "\n  ${RED}Invalid choice. Try again.${RESET}"; sleep 1; main_menu ;;
    esac
}

# ===================== MAIN MENU =====================

main_menu() {
    banner
    # load_progress # Ensure latest progress is loaded before displaying menu (called in main)
    echo -e "${WHITE}${BOLD}  SELECT A LESSON:${RESET}"
    echo ""
    local status_icon
    status_icon=$(is_lesson_complete 1 && echo "${GREEN}✔${RESET}" || echo " ") ; echo -e "  $status_icon ${GREEN}1${RESET}  📖 Introduction to Termux"
    status_icon=$(is_lesson_complete 2 && echo "${GREEN}✔${RESET}" || echo " ") ; echo -e "  $status_icon ${GREEN}2${RESET}  📦 Package Management (pkg/apt)"
    status_icon=$(is_lesson_complete 3 && echo "${GREEN}✔${RESET}" || echo " ") ; echo -e "  $status_icon ${GREEN}3${RESET}  📁 File System & Navigation"
    status_icon=$(is_lesson_complete 4 && echo "${GREEN}✔${RESET}" || echo " ") ; echo -e "  $status_icon ${GREEN}4${RESET}  📝 File Operations & Text Editing"
    status_icon=$(is_lesson_complete 5 && echo "${GREEN}✔${RESET}" || echo " ") ; echo -e "  $status_icon ${GREEN}5${RESET}  🔐 Permissions & Ownership"
    status_icon=$(is_lesson_complete 6 && echo "${GREEN}✔${RESET}" || echo " ") ; echo -e "  $status_icon ${GREEN}6${RESET}  🌐 Networking Tools"
    status_icon=$(is_lesson_complete 7 && echo "${GREEN}✔${RESET}" || echo " ") ; echo -e "  $status_icon ${GREEN}7${RESET}  🐍 Programming in Termux (Python, Node, C)"
    status_icon=$(is_lesson_complete 8 && echo "${GREEN}✔${RESET}" || echo " ") ; echo -e "  $status_icon ${GREEN}8${RESET}  🔧 System Information & Monitoring"
    status_icon=$(is_lesson_complete 9 && echo "${GREEN}✔${RESET}" || echo " ") ; echo -e "  $status_icon ${GREEN}9${RESET}  📂 Termux Storage & Android Integration"
    status_icon=$(is_lesson_complete 10 && echo "${GREEN}✔${RESET}" || echo " ") ; echo -e "  $status_icon ${GREEN}10${RESET} 🛡️  Security & Hacking Tools"
    status_icon=$(is_lesson_complete 11 && echo "${GREEN}✔${RESET}" || echo " ") ; echo -e "  $status_icon ${GREEN}11${RESET} 📜 Shell Scripting Basics"
    status_icon=$(is_lesson_complete 12 && echo "${GREEN}✔${RESET}" || echo " ") ; echo -e "  $status_icon ${GREEN}12${RESET} 🧰 Advanced Tools & Utilities"
    status_icon=$(is_lesson_complete 13 && echo "${GREEN}✔${RESET}" || echo " ") ; echo -e "  $status_icon ${GREEN}13${RESET} 🔑 SSH & Remote Access"
    status_icon=$(is_lesson_complete 14 && echo "${GREEN}✔${RESET}" || echo " ") ; echo -e "  $status_icon ${GREEN}14${RESET} 🐙 Git & Version Control"
    status_icon=$(is_lesson_complete 15 && echo "${GREEN}✔${RESET}" || echo " ") ; echo -e "  $status_icon ${GREEN}15${RESET} 🗄️  Database Tools"
    status_icon=$(is_lesson_complete 16 && echo "${GREEN}✔${RESET}" || echo " ") ; echo -e "  $status_icon ${GREEN}16${RESET} 🎨 Termux Customization"
    status_icon=$(is_lesson_complete 17 && echo "${GREEN}✔${RESET}" || echo " ") ; echo -e "  $status_icon ${GREEN}17${RESET} 🏗️  Full Setup Script (Auto-Install)"
    status_icon=$(is_lesson_complete 18 && echo "${GREEN}✔${RESET}" || echo " ") ; echo -e "  $status_icon ${GREEN}18${RESET} 📋 Quick Cheat Sheet"
    status_icon=$(is_lesson_complete 19 && echo "${GREEN}✔${RESET}" || echo " ") ; echo -e "  $status_icon ${GREEN}19${RESET} 🔍 Search Commands"
    status_icon=$(is_lesson_complete 20 && echo "${GREEN}✔${RESET}" || echo " ") ; echo -e "  $status_icon ${GREEN}20${RESET} 📝 Interactive Quiz"
    status_icon=$(is_lesson_complete 21 && echo "${GREEN}✔${RESET}" || echo " ") ; echo -e "  $status_icon ${GREEN}21${RESET} 🏜️  Sandbox Mode"
    status_icon=$(is_lesson_complete 23 && echo "${GREEN}✔${RESET}" || echo " ") ; echo -e "  $status_icon ${GREEN}23${RESET}  🛠️  Tool Installer"
    status_icon=$(is_lesson_complete 22 && echo "${GREEN}✔${RESET}" || echo " ") ; echo -e "  $status_icon ${GREEN}22${RESET}  🚀 Top 20 Popular Tools Showcase"
    
    if [[ -f "$LAST_LESSON_FILE" ]]; then
        echo -e "  ${YELLOW}[C]${RESET}  🕒 Continue Last Visited (Lesson $(cat "$LAST_LESSON_FILE"))"
    fi

    echo -e "  ${GREEN}[0]${RESET}  🚪 Exit"
    echo ""
    echo -e "  ${WHITE}Enter your choice:${RESET} \c"
    read -r choice
    execute_choice "$choice"
}

# ===================== LESSON 1: INTRODUCTION =====================

lesson_intro() {
    banner
    section_header "LESSON 1: INTRODUCTION TO TERMUX"

    echo -e "  ${WHITE}${BOLD}What is Termux?${RESET}"
    echo ""
    info "Termux is an Android terminal emulator and Linux environment app."
    info "It works WITHOUT rooting your device."
    info "It uses the APT package manager (like Debian/Ubuntu)."
    info "Termux provides a powerful command-line interface on Android."
    info "It supports many Linux packages and tools."
    echo ""

    sub_header "Key Features"
    info "✦ Run Linux commands on Android"
    info "✦ Install packages with pkg/apt"
    info "✦ Write and run scripts (Bash, Python, etc.)"
    info "✦ Access Android storage"
    info "✦ SSH into remote servers"
    info "✦ Run web servers"
    info "✦ Use development tools (git, gcc, node, etc.)"
    info "✦ Customize your shell environment"
    echo ""

    sub_header "Termux Directory Structure"
    info "Home directory:     /data/data/com.termux/files/home  (~)"
    info "Prefix directory:   /data/data/com.termux/files/usr"
    info "Binary directory:   /data/data/com.termux/files/usr/bin"
    info "Etc directory:      /data/data/com.termux/files/usr/etc"
    info "Tmp directory:      /data/data/com.termux/files/usr/tmp"
    info "Shared storage:     ~/storage/ (after termux-setup-storage)"
    echo ""

    sub_header "First Steps After Installing Termux"
    code_block "pkg update && pkg upgrade -y"
    info "Always update packages first!"
    echo ""
    interactive_tool "termux-setup-storage" "Grants Termux permission to access /sdcard. Creates the ~/storage folder with symlinks to your DCIM, Downloads, and Pictures."
    
    interactive_tool "pkg install -y coreutils" "Installs the basic GNU file, shell, and text manipulation utilities which are essential for any Linux environment."

    pause_continue

    section_header "TERMUX NAVIGATION & SHORTCUTS"

    sub_header "Keyboard Shortcuts"
    echo -e "  ${WHITE}${BOLD}Essential shortcuts:${RESET}"
    info "CTRL + A         → Move cursor to beginning of line"
    info "CTRL + E         → Move cursor to end of line"
    info "CTRL + K         → Cut text from cursor to end"
    info "CTRL + U         → Cut text from cursor to beginning"
    info "CTRL + W         → Cut previous word"
    info "CTRL + Y         → Paste cut text"
    info "CTRL + C         → Stop/kill current process"
    info "CTRL + D         → Exit current session (EOF)"
    info "CTRL + Z         → Suspend current process"
    info "CTRL + L         → Clear screen"
    info "TAB              → Auto-complete commands/filenames"
    info "VOL DOWN + Q     → Show extra keys row"
    info "VOL UP + Q       → Toggle extra keys"
    echo ""

    sub_header "Termux Touch Gestures"
    info "Long press        → Paste / Select text"
    info "Pinch in/out      → Zoom text"
    info "Swipe left edge   → Open drawer (sessions)"
    info "Two-finger tap    → Context menu"

    pause_continue
    echo ""
    echo -e "  ${YELLOW}Mark Lesson 1 as complete? (y/n):${RESET} \c"
    read -r mark_choice
    if [[ "$mark_choice" == "y" || "$mark_choice" == "Y" ]]; then
        mark_lesson_complete 1
    fi
    main_menu
}

# ===================== LESSON 2: PACKAGE MANAGEMENT =====================

lesson_package_mgmt() {
    banner
    section_header "LESSON 2: PACKAGE MANAGEMENT (pkg / apt)"

    echo -e "  ${WHITE}${BOLD}Package Manager Basics${RESET}"
    echo ""
    info "Termux uses 'pkg' (a wrapper for apt) to manage packages."
    info "'pkg' automatically runs 'apt update' before installing."
    echo ""

    sub_header "Essential Package Commands"

    interactive_tool "pkg list-installed" "Lists every package currently installed in your Termux environment. Useful for auditing your setup."
    
    cmd_example "pkg update" "Synchronizes the local package index with the remote repositories. Run this before installing anything."
    cmd_example "pkg upgrade" "Downloads and installs the latest versions of all your current packages."
    cmd_example "pkg search <term>" "Searches the repositories for packages matching the keyword (e.g., 'pkg search python')."
    cmd_example "pkg show <pkg>" "Displays metadata about a package, including its version, size, and dependencies."

    pause_continue

    sub_header "APT Commands (Alternative)"
    cmd_example "apt update" "Update package lists"
    cmd_example "apt upgrade -y" "Upgrade all packages (auto-yes)"
    cmd_example "apt install <package> -y" "Install package (auto-yes)"
    cmd_example "apt remove <package>" "Remove a package"
    cmd_example "apt autoremove" "Remove unused dependencies"
    cmd_example "apt list --installed" "List installed packages"
    cmd_example "dpkg -l" "List all installed packages (detailed)"
    cmd_example "dpkg -L <package>" "List files in a package"

    sub_header "Essential Packages to Install"
    echo -e "  ${WHITE}Development:${RESET}"
    code_block "pkg install -y git python nodejs clang golang rust"
    echo ""
    echo -e "  ${WHITE}Networking:${RESET}"
    code_block "pkg install -y curl wget nmap openssh net-tools dnsutils"
    echo ""
    echo -e "  ${WHITE}Utilities:${RESET}"
    code_block "pkg install -y vim nano htop tree zip unzip tar man"
    echo ""
    echo -e "  ${WHITE}Fun/Extra:${RESET}"
    code_block "pkg install -y figlet toilet cowsay fortune sl neofetch"

    pause_continue
    echo ""
    echo -e "  ${YELLOW}Mark Lesson 2 as complete? (y/n):${RESET} \c"
    read -r mark_choice
    if [[ "$mark_choice" == "y" || "$mark_choice" == "Y" ]]; then
        mark_lesson_complete 2
    fi
    main_menu
}

# ===================== LESSON 3: FILE SYSTEM & NAVIGATION =====================

lesson_filesystem() {
    banner
    section_header "LESSON 3: FILE SYSTEM & NAVIGATION"

    sub_header "Basic Navigation Commands"

    interactive_tool "pwd" "Displays the Absolute Path of your current location. In Termux, the home folder is deep in the Android data directory."
    
    interactive_tool "ls -laF" "List all files. -l: long format (details), -a: all files (including hidden . files), -F: appends symbols to identify directories/executables."
    
    cmd_example "cd ~" "Navigates to your Home directory (/data/data/com.termux/files/home)."
    cmd_example "cd .." "Moves one level up in the directory tree."
    cmd_example "cd -" "Returns you to the last directory you were working in."

    pause_continue

    sub_header "Creating Directories & Files"

    cmd_example "mkdir mydir" "Create a directory"
    cmd_example "mkdir -p dir1/dir2/dir3" "Create nested directories"
    cmd_example "touch myfile.txt" "Create an empty file"
    cmd_example "touch file1 file2 file3" "Create multiple files"

    sub_header "Copying, Moving & Deleting"

    cmd_example "cp file1 file2" "Copy file1 to file2"
    cmd_example "cp -r dir1 dir2" "Copy directory recursively"
    cmd_example "mv file1 file2" "Move/rename file1 to file2"
    cmd_example "mv file1 /path/to/" "Move file1 to another location"
    cmd_example "rm file1" "Delete a file"
    cmd_example "rm -r mydir" "Delete a directory recursively"
    cmd_example "rm -rf mydir" "Force delete (no confirmation)"
    cmd_example "rmdir emptydir" "Remove empty directory only"

    sub_header "Finding Files"

    cmd_example "find . -name '*.txt'" "Find all .txt files in current dir"
    cmd_example "find / -name 'filename'" "Find file by name from root"
    cmd_example "find . -type f -size +1M" "Find files larger than 1MB"
    cmd_example "find . -mtime -7" "Find files modified in last 7 days"
    cmd_example "locate filename" "Fast search (needs mlocate package)"
    cmd_example "which command" "Show path of a command"
    cmd_example "whereis command" "Show all locations of a command"

    sub_header "Tree Command"
    info "Install: pkg install tree"
    cmd_example "tree" "Show directory structure as tree"
    cmd_example "tree -L 2" "Show tree with depth limit of 2"
    cmd_example "tree -a" "Show all files including hidden"

    pause_continue
    echo ""
    echo -e "  ${YELLOW}Mark Lesson 3 as complete? (y/n):${RESET} \c"
    read -r mark_choice
    if [[ "$mark_choice" == "y" || "$mark_choice" == "Y" ]]; then
        mark_lesson_complete 3
    fi
    main_menu
}

# ===================== LESSON 4: FILE OPERATIONS & TEXT EDITING =====================

lesson_file_ops() {
    banner
    section_header "LESSON 4: FILE OPERATIONS & TEXT EDITING"

    sub_header "Viewing File Contents"

    cmd_example "cat file.txt" "Display entire file"
    cmd_example "cat -n file.txt" "Display with line numbers"
    cmd_example "head file.txt" "Show first 10 lines"
    cmd_example "head -20 file.txt" "Show first 20 lines"
    cmd_example "tail file.txt" "Show last 10 lines"
    cmd_example "tail -f logfile" "Follow file changes in real-time"
    cmd_example "less file.txt" "Page through file (q to quit)"
    cmd_example "more file.txt" "Page through file (older version)"
    cmd_example "wc file.txt" "Count lines, words, characters"
    cmd_example "wc -l file.txt" "Count lines only"

    pause_continue

    sub_header "Text Processing"

    cmd_example "grep 'pattern' file.txt" "Search for pattern in file"
    cmd_example "grep -i 'pattern' file.txt" "Case-insensitive search"
    cmd_example "grep -r 'pattern' /dir/" "Recursive search in directory"
    cmd_example "grep -n 'pattern' file.txt" "Show line numbers"
    cmd_example "grep -c 'pattern' file.txt" "Count matches"
    cmd_example "grep -v 'pattern' file.txt" "Show lines NOT matching"
    echo ""
    cmd_example "sed 's/old/new/g' file.txt" "Replace text (print to stdout)"
    cmd_example "sed -i 's/old/new/g' file.txt" "Replace text in-place"
    cmd_example "awk '{print \$1}' file.txt" "Print first column"
    cmd_example "awk -F: '{print \$1}' /etc/passwd" "Print with custom delimiter"
    cmd_example "sort file.txt" "Sort lines alphabetically"
    cmd_example "sort -n file.txt" "Sort numerically"
    cmd_example "sort -r file.txt" "Sort in reverse"
    cmd_example "uniq file.txt" "Remove duplicate lines"
    cmd_example "cut -d: -f1 file.txt" "Cut fields by delimiter"
    cmd_example "tr 'a-z' 'A-Z' < file.txt" "Convert to uppercase"

    pause_continue

    sub_header "Input/Output Redirection"

    cmd_example "echo 'hello' > file.txt" "Write to file (overwrite)"
    cmd_example "echo 'world' >> file.txt" "Append to file"
    cmd_example "command 2> error.log" "Redirect errors to file"
    cmd_example "command &> output.log" "Redirect all output to file"
    cmd_example "command1 | command2" "Pipe output to another command"
    cmd_example "cat file.txt | grep 'word' | wc -l" "Chain multiple commands"
    cmd_example "tee file.txt" "Write to file AND stdout"
    cmd_example "command | tee output.txt" "Save output while displaying it"

    sub_header "Text Editors in Termux"

    echo -e "  ${WHITE}${BOLD}1. Nano (beginner-friendly):${RESET}"
    code_block "pkg install nano && nano filename.txt"
    info "CTRL+O = Save | CTRL+X = Exit | CTRL+K = Cut line"
    info "CTRL+W = Search | CTRL+G = Help"
    echo ""

    echo -e "  ${WHITE}${BOLD}2. Vim (powerful editor):${RESET}"
    code_block "pkg install vim && vim filename.txt"
    info "i = Insert mode | ESC = Normal mode"
    info ":w = Save | :q = Quit | :wq = Save & Quit | :q! = Force quit"
    info "dd = Delete line | yy = Copy line | p = Paste | u = Undo"
    info "/pattern = Search | :s/old/new/g = Replace"
    echo ""

    echo -e "  ${WHITE}${BOLD}3. Micro (modern editor):${RESET}"
    code_block "pkg install micro && micro filename.txt"
    info "CTRL+S = Save | CTRL+Q = Quit | CTRL+F = Find"

    sub_header "Live Demo: Create and View a File"
    if confirm_run; then
        echo "Hello from Termux Lesson!" > /tmp/demo_file.txt
        echo "This is line 2" >> /tmp/demo_file.txt
        echo "This is line 3" >> /tmp/demo_file.txt
        echo "Termux is awesome!" >> /tmp/demo_file.txt
        run_demo "cat -n /tmp/demo_file.txt"
        run_demo "wc /tmp/demo_file.txt"
        run_demo "grep 'Termux' /tmp/demo_file.txt"
        rm -f /tmp/demo_file.txt
    fi

    pause_continue
    echo ""
    echo -e "  ${YELLOW}Mark Lesson 4 as complete? (y/n):${RESET} \c"
    read -r mark_choice
    if [[ "$mark_choice" == "y" || "$mark_choice" == "Y" ]]; then
        mark_lesson_complete 4
    fi
    main_menu
}

# ===================== LESSON 5: PERMISSIONS =====================

lesson_permissions() {
    banner
    section_header "LESSON 5: PERMISSIONS & OWNERSHIP"

    sub_header "Understanding File Permissions"

    echo -e "  ${WHITE}Permission Format: ${CYAN}-rwxrwxrwx${RESET}"
    echo ""
    info "Position 1:    File type (- = file, d = directory, l = link)"
    info "Position 2-4:  Owner permissions  (r=read, w=write, x=execute)"
    info "Position 5-7:  Group permissions  (r=read, w=write, x=execute)"
    info "Position 8-10: Other permissions  (r=read, w=write, x=execute)"
    echo ""

    echo -e "  ${WHITE}${BOLD}Numeric (Octal) Values:${RESET}"
    info "r (read)    = 4"
    info "w (write)   = 2"
    info "x (execute) = 1"
    info "- (none)    = 0"
    echo ""

    echo -e "  ${WHITE}${BOLD}Common Permission Values:${RESET}"
    info "755 = rwxr-xr-x  (owner: all, others: read+execute)"
    info "644 = rw-r--r--  (owner: read+write, others: read only)"
    info "777 = rwxrwxrwx  (everyone: all permissions)"
    info "700 = rwx------  (owner only)"
    info "600 = rw-------  (owner: read+write only)"

    pause_continue

    sub_header "Permission Commands"

    cmd_example "chmod 755 file.sh" "Set permissions using octal"
    cmd_example "chmod +x file.sh" "Add execute permission"
    cmd_example "chmod -w file.txt" "Remove write permission"
    cmd_example "chmod u+x file.sh" "Add execute for owner"
    cmd_example "chmod g+w file.txt" "Add write for group"
    cmd_example "chmod o-r file.txt" "Remove read for others"
    cmd_example "chmod -R 755 dir/" "Set permissions recursively"
    cmd_example "ls -la" "View file permissions"

    sub_header "Making Scripts Executable"
    echo -e "  ${WHITE}Steps to create and run a script:${RESET}"
    code_block "echo '#!/bin/bash' > myscript.sh"
    code_block "echo 'echo Hello World' >> myscript.sh"
    code_block "chmod +x myscript.sh"
    code_block "./myscript.sh"

    sub_header "Live Demo: Permissions"
    if confirm_run; then
        touch /tmp/perm_demo.txt
        run_demo "ls -la /tmp/perm_demo.txt"
        chmod 755 /tmp/perm_demo.txt
        run_demo "ls -la /tmp/perm_demo.txt"
        rm -f /tmp/perm_demo.txt
    fi

    pause_continue
    echo ""
    echo -e "  ${YELLOW}Mark Lesson 5 as complete? (y/n):${RESET} \c"
    read -r mark_choice
    if [[ "$mark_choice" == "y" || "$mark_choice" == "Y" ]]; then
        mark_lesson_complete 5
    fi
    main_menu
}

# ===================== LESSON 6: NETWORKING =====================

lesson_networking() {
    banner
    section_header "LESSON 6: NETWORKING TOOLS"

    sub_header "Basic Network Commands"

    interactive_tool "ip addr" "The modern way to check your local IP addresses. Look for 'wlan0' for your WiFi IP."
    
    interactive_tool "ping -c 3 google.com" "Sends 3 ICMP echo requests to a server to check latency and connectivity."
    
    cmd_example "traceroute google.com" "Displays the path (hops) that packets take to reach a destination. Great for debugging network delays."

    pause_continue

    sub_header "Download Tools"

    echo -e "  ${WHITE}${BOLD}wget:${RESET}"
    cmd_example "wget <url>" "Download a file"
    cmd_example "wget -O name.zip <url>" "Download with custom filename"
    cmd_example "wget -c <url>" "Continue interrupted download"
    cmd_example "wget -q <url>" "Quiet mode (no progress)"
    cmd_example "wget -r <url>" "Recursive download"
    echo ""

    echo -e "  ${WHITE}${BOLD}curl:${RESET}"
    cmd_example "curl <url>" "Fetch content from URL"
    cmd_example "curl -O <url>" "Download file"
    cmd_example "curl -o name.html <url>" "Download with custom name"
    cmd_example "curl -I <url>" "Get HTTP headers only"
    cmd_example "curl -L <url>" "Follow redirects"
    cmd_example "curl -s <url>" "Silent mode"
    interactive_tool "curl -I https://www.google.com" "Fetches just the HTTP header from Google. Useful for checking server status (200 OK, 404, etc.)"
    cmd_example "curl ifconfig.me" "Get your public IP"

    pause_continue

    sub_header "Nmap - Network Scanner"
    info "Install: pkg install nmap"
    echo ""
    cmd_example "nmap <target_ip>" "Basic port scan"
    cmd_example "nmap -sV <target>" "Detect service versions"
    cmd_example "nmap -sS <target>" "SYN stealth scan"
    cmd_example "nmap -O <target>" "OS detection"
    cmd_example "nmap -A <target>" "Aggressive scan (all info)"
    cmd_example "nmap -p 80,443 <target>" "Scan specific ports"
    cmd_example "nmap -p- <target>" "Scan all 65535 ports"
    cmd_example "nmap -sn 192.168.1.0/24" "Ping sweep (discover hosts)"
    cmd_example "nmap --script vuln <target>" "Vulnerability scan"
    warn "Only scan networks you own or have permission to test!"

    pause_continue

    sub_header "Netcat (nc) - Network Swiss Army Knife"
    info "Install: pkg install nmap-ncat or netcat-openbsd"
    echo ""
    cmd_example "nc -l -p 1234" "Listen on port 1234"
    cmd_example "nc <ip> 1234" "Connect to IP on port 1234"
    cmd_example "nc -zv <ip> 1-1000" "Port scan range"
    cmd_example "echo 'hello' | nc <ip> 1234" "Send message"

    sub_header "Other Network Tools"
    cmd_example "netstat -tlnp" "Show listening ports"
    cmd_example "ss -tlnp" "Show listening ports (modern)"
    cmd_example "arp -a" "Show ARP table"

    echo ""
    echo -e "  ${YELLOW}Mark Lesson 6 as complete? (y/n):${RESET} \c"
    read -r mark_choice
    if [[ "$mark_choice" == "y" || "$mark_choice" == "Y" ]]; then
        mark_lesson_complete 6
    fi
    main_menu
}

# ===================== LESSON 7: PROGRAMMING =====================

lesson_programming() {
    banner
    section_header "LESSON 7: PROGRAMMING IN TERMUX"

    sub_header "Python"
    info "Install: pkg install python"
    echo ""
    cmd_example "python --version" "Check Python version"
    cmd_example "python" "Start Python interactive shell"
    cmd_example "python script.py" "Run a Python script"
    cmd_example "pip install <package>" "Install Python packages"
    cmd_example "pip list" "List installed packages"
    cmd_example "pip install requests flask" "Install web packages"
    echo ""

    echo -e "  ${WHITE}${BOLD}Quick Python Demo Script:${RESET}"
    echo -e "  ${BLUE}┌─────────────────────────────────────────┐${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}#!/usr/bin/env python3${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}# Save as: hello.py${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}import os, platform${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}print('Hello from Termux!')${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}print(f'Python: {platform.python_version()}')${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}print(f'OS: {os.uname().sysname}')${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}name = input('Your name: ')${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}print(f'Welcome, {name}!')${RESET}"
    echo -e "  ${BLUE}└─────────────────────────────────────────┘${RESET}"

    pause_continue

    sub_header "Node.js / JavaScript"
    info "Install: pkg install nodejs"
    echo ""
    cmd_example "node --version" "Check Node.js version"
    cmd_example "node" "Start Node.js REPL"
    cmd_example "node script.js" "Run a JavaScript file"
    cmd_example "npm install <package>" "Install npm packages"
    cmd_example "npm init -y" "Initialize a new project"
    cmd_example "npx <command>" "Run npm packages without installing"
    echo ""

    echo -e "  ${WHITE}${BOLD}Quick Node.js Demo:${RESET}"
    echo -e "  ${BLUE}┌─────────────────────────────────────────┐${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}// Save as: server.js${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}const http = require('http');${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}const server = http.createServer(${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}  (req, res) => {${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}    res.end('Hello from Termux!');${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}  }${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE});${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}server.listen(8080, () => {${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}  console.log('Server on :8080');${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}});${RESET}"
    echo -e "  ${BLUE}└─────────────────────────────────────────┘${RESET}"

    pause_continue

    sub_header "C/C++ Programming"
    info "Install: pkg install clang"
    echo ""
    cmd_example "clang hello.c -o hello" "Compile C program"
    cmd_example "clang++ hello.cpp -o hello" "Compile C++ program"
    cmd_example "./hello" "Run compiled program"
    echo ""

    echo -e "  ${WHITE}${BOLD}Quick C Demo:${RESET}"
    echo -e "  ${BLUE}┌─────────────────────────────────────────┐${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}// Save as: hello.c${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}#include <stdio.h>${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}int main() {${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}    printf(\"Hello from Termux!\\n\");${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}    return 0;${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}}${RESET}"
    echo -e "  ${BLUE}└─────────────────────────────────────────┘${RESET}"

    sub_header "Go Programming"
    info "Install: pkg install golang"
    cmd_example "go version" "Check Go version"
    cmd_example "go run main.go" "Run Go program"
    cmd_example "go build -o app main.go" "Compile Go program"

    sub_header "Rust Programming"
    info "Install: pkg install rust"
    cmd_example "rustc --version" "Check Rust version"
    cmd_example "rustc main.rs" "Compile Rust program"
    cmd_example "cargo new myproject" "Create new Rust project"
    cmd_example "cargo run" "Build and run project"

    sub_header "Ruby"
    info "Install: pkg install ruby"
    cmd_example "ruby --version" "Check Ruby version"
    cmd_example "ruby script.rb" "Run Ruby script"
    cmd_example "irb" "Interactive Ruby shell"
    cmd_example "gem install <package>" "Install Ruby gems"

    sub_header "PHP"
    pause_continue
    echo ""
    echo -e "  ${YELLOW}Mark Lesson 7 as complete? (y/n):${RESET} \c"
    read -r mark_choice
    if [[ "$mark_choice" == "y" || "$mark_choice" == "Y" ]]; then
        mark_lesson_complete 7
    fi
    info "Install: pkg install php"
    cmd_example "php --version" "Check PHP version"
    cmd_example "php script.php" "Run PHP script"
    cmd_example "php -S localhost:8080" "Start PHP dev server"

    pause_continue
    main_menu
}

# ===================== LESSON 8: SYSTEM INFO =====================

lesson_sysinfo() {
    banner
    section_header "LESSON 8: SYSTEM INFORMATION & MONITORING"

    sub_header "System Information Commands"

    interactive_tool "uname -smr" "Displays kernel name (-s), machine architecture (-m), and kernel release (-r). Essential for hardware compatibility checks."
    
    interactive_tool "uptime -p" "Shows how long your Android device has been running since the last reboot in a pretty format."
    
    interactive_tool "whoami" "Displays the effective username of the current user. In Termux, this is usually a UID like 'u0_a123'."
    
    interactive_tool "df -h /data" "Displays disk space usage for the data partition where Termux lives. '-h' makes it human-readable (GB/MB)."
    cmd_example "echo \$PATH" "Current PATH variable"
    cmd_example "echo \$HOME" "Home directory"
    cmd_example "echo \$PREFIX" "Termux prefix directory"

    pause_continue

    sub_header "Process Management"

    cmd_example "ps" "Show running processes"
    cmd_example "ps aux" "Show all processes (detailed)"
    cmd_example "ps aux | grep <name>" "Find specific process"
    cmd_example "top" "Interactive process viewer"
    cmd_example "htop" "Better interactive viewer (install: pkg install htop)"
    cmd_example "kill <PID>" "Kill process by ID"
    cmd_example "kill -9 <PID>" "Force kill process"
    cmd_example "killall <name>" "Kill process by name"
    cmd_example "jobs" "List background jobs"
    cmd_example "bg" "Resume job in background"
    cmd_example "fg" "Bring job to foreground"
    cmd_example "command &" "Run command in background"
    cmd_example "nohup command &" "Run command that survives session close"

    sub_header "Disk & Memory"

    cmd_example "df -h" "Disk space usage"
    cmd_example "du -sh *" "Size of files/dirs in current directory"
    cmd_example "du -sh /path" "Size of specific path"
    cmd_example "free -h" "Memory usage (if available)"

    sub_header "Environment Variables"

    cmd_example "env" "Show all environment variables"
    cmd_example "export VAR=value" "Set an environment variable"
    cmd_example "echo \$VAR" "Print variable value"
    cmd_example "unset VAR" "Unset a variable"

    sub_header "Neofetch - System Info Display"
    info "Install: pkg install neofetch"
    cmd_example "neofetch" "Display system info with ASCII art"
    pause_continue
    echo ""
    echo -e "  ${YELLOW}Mark Lesson 8 as complete? (y/n):${RESET} \c"
    read -r mark_choice
    if [[ "$mark_choice" == "y" || "$mark_choice" == "Y" ]]; then
        mark_lesson_complete 8
    fi
    main_menu
}

# ===================== LESSON 9: STORAGE =====================

lesson_storage() {
    banner
    section_header "LESSON 9: TERMUX STORAGE & ANDROID INTEGRATION"

    sub_header "Setting Up Storage Access"

    info "Termux needs special permission to access phone storage."
    echo ""
    code_block "termux-setup-storage"
    echo ""
    info "This creates symlinks in ~/storage:"
    info "  ~/storage/shared     → Internal shared storage"
    info "  ~/storage/downloads  → Downloads folder"
    info "  ~/storage/dcim       → Camera photos"
    info "  ~/storage/pictures   → Pictures folder"
    info "  ~/storage/music      → Music folder"
    info "  ~/storage/movies     → Movies folder"
    info "  ~/storage/external-1 → SD card (if available)"

    pause_continue

    sub_header "Accessing Phone Files"

    cmd_example "ls ~/storage/shared/" "List shared storage"
    cmd_example "ls ~/storage/downloads/" "List downloads"
    cmd_example "cp file.txt ~/storage/downloads/" "Copy file to Downloads"
    cmd_example "cp ~/storage/dcim/photo.jpg ~/" "Copy photo to Termux"

    sub_header "Termux:API - Android Integration"

    info "Install Termux:API app from F-Droid"
    info "Then install API package:"
    code_block "pkg install termux-api"
    echo ""

    echo -e "  ${WHITE}${BOLD}Available API Commands:${RESET}"
    echo ""
    cmd_example "termux-battery-status" "Get battery info"
    cmd_example "termux-brightness 255" "Set screen brightness (0-255)"
    cmd_example "termux-camera-photo -c 0 photo.jpg" "Take photo"
    cmd_example "termux-clipboard-get" "Get clipboard content"
    cmd_example "termux-clipboard-set 'text'" "Set clipboard content"
    cmd_example "termux-contact-list" "List contacts"
    cmd_example "termux-dialog" "Show input dialog"
    cmd_example "termux-download <url>" "Download via Android"
    cmd_example "termux-fingerprint" "Use fingerprint sensor"
    cmd_example "termux-location" "Get GPS location"
    cmd_example "termux-media-player play <file>" "Play media file"
    cmd_example "termux-notification -t 'Title' -c 'Content'" "Show notification"
    cmd_example "termux-open <url>" "Open URL in browser"
    cmd_example "termux-open <file>" "Open file with default app"
    cmd_example "termux-share -a send file.txt" "Share a file"
    cmd_example "termux-sms-list" "List SMS messages"
    cmd_example "termux-sms-send -n <number> 'message'" "Send SMS"
    cmd_example "termux-toast 'message'" "Show toast message"
    cmd_example "termux-torch on" "Turn on flashlight"
    cmd_example "termux-torch off" "Turn off flashlight"
    cmd_example "termux-tts-speak 'Hello'" "Text to speech"
    cmd_example "termux-vibrate" "Vibrate phone"
    cmd_example "termux-volume" "Get volume info"
    cmd_example "termux-wifi-connectioninfo" "WiFi connection details"
    cmd_example "termux-wifi-scaninfo" "Scan WiFi networks"

    sub_header "Termux:Boot - Run Scripts on Boot"
    info "Install Termux:Boot app"
    info "Create scripts in: ~/.termux/boot/"
    code_block "mkdir -p ~/.termux/boot"
    code_block "echo '#!/bin/bash' > ~/.termux/boot/start.sh"
    code_block "chmod +x ~/.termux/boot/start.sh"

    sub_header "Termux:Widget"
    info "Install Termux:Widget app"
    info "Put scripts in: ~/.shortcuts/"
    code_block "mkdir -p ~/.shortcuts"

    pause_continue
    echo ""
    echo -e "  ${YELLOW}Mark Lesson 9 as complete? (y/n):${RESET} \c"
    read -r mark_choice
    if [[ "$mark_choice" == "y" || "$mark_choice" == "Y" ]]; then
        mark_lesson_complete 9
    fi
    main_menu
}

# ===================== LESSON 10: SECURITY TOOLS =====================

lesson_security() {
    banner
    section_header "LESSON 10: SECURITY & ETHICAL HACKING TOOLS"

    warn "⚠️  IMPORTANT DISCLAIMER ⚠️"
    warn "These tools are for EDUCATIONAL purposes and"
    warn "authorized penetration testing ONLY."
    warn "Always get written permission before testing."
    warn "Unauthorized access is ILLEGAL."
    echo ""

    pause_continue

    sub_header "Nmap - Network Scanner"
    info "Install: pkg install nmap"
    cmd_example "nmap -sn 192.168.1.0/24" "Discover devices on network"
    cmd_example "nmap -sV <target>" "Service version detection"
    cmd_example "nmap -A <target>" "Full scan (OS, version, scripts)"
    cmd_example "nmap --script=http-headers <target>" "HTTP header scan"
    cmd_example "nmap -sU <target>" "UDP scan"

    sub_header "Hydra - Password Cracker"
    info "Install: pkg install hydra"
    cmd_example "hydra -l admin -P wordlist.txt <target> ssh" "SSH brute force"
    cmd_example "hydra -l admin -P wordlist.txt <target> ftp" "FTP brute force"
    cmd_example "hydra -L users.txt -P pass.txt <target> http-post-form '/login:user=^USER^&pass=^PASS^:Failed'" "Web login"

    sub_header "SQLMap - SQL Injection"
    info "Install via pip: pip install sqlmap"
    cmd_example "sqlmap -u 'http://target/page?id=1'" "Test for SQL injection"
    cmd_example "sqlmap -u '<url>' --dbs" "List databases"
    cmd_example "sqlmap -u '<url>' -D dbname --tables" "List tables"
    cmd_example "sqlmap -u '<url>' -D dbname -T tablename --dump" "Dump table"

    pause_continue

    sub_header "Metasploit Framework"
    info "Install: pkg install unstable-repo && pkg install metasploit"
    info "Alternative: Install via script"
    cmd_example "msfconsole" "Start Metasploit console"
    cmd_example "msfvenom" "Payload generator"

    sub_header "Other Security Tools"

    echo -e "  ${WHITE}${BOLD}Hashcat - Password Recovery:${RESET}"
    cmd_example "pkg install hashcat" "Install hashcat"
    cmd_example "hashcat -m 0 hash.txt wordlist.txt" "Crack MD5 hash"
    echo ""

    echo -e "  ${WHITE}${BOLD}John the Ripper:${RESET}"
    cmd_example "pkg install john" "Install John"
    cmd_example "john --wordlist=wordlist.txt hashes.txt" "Crack passwords"
    echo ""

    echo -e "  ${WHITE}${BOLD}Aircrack-ng (WiFi):${RESET}"
    info "Limited on non-rooted devices"
    cmd_example "pkg install aircrack-ng" "Install aircrack-ng"
    echo ""

    echo -e "  ${WHITE}${BOLD}Wireshark (tshark):${RESET}"
    cmd_example "pkg install tshark" "Install terminal Wireshark"
    cmd_example "tshark -i wlan0" "Capture packets"
    echo ""

    echo -e "  ${WHITE}${BOLD}Wordlist Generation:${RESET}"
    cmd_example "pkg install crunch" "Install crunch"
    cmd_example "crunch 4 6 abc123 -o wordlist.txt" "Generate wordlist"

    sub_header "Python Security Tools (pip install)"
    cmd_example "pip install scapy" "Packet manipulation"
    cmd_example "pip install paramiko" "SSH automation"
    cmd_example "pip install shodan" "Shodan API"
    cmd_example "pip install dnspython" "DNS tools"

    pause_continue
    echo ""
    echo -e "  ${YELLOW}Mark Lesson 10 as complete? (y/n):${RESET} \c"
    read -r mark_choice
    if [[ "$mark_choice" == "y" || "$mark_choice" == "Y" ]]; then
        mark_lesson_complete 10
    fi
    main_menu
}

# ===================== LESSON 11: SHELL SCRIPTING =====================

lesson_scripting() {
    banner
    section_header "LESSON 11: SHELL SCRIPTING BASICS"

    sub_header "Creating Your First Script"

    echo -e "  ${WHITE}${BOLD}Step 1: Create the script${RESET}"
    echo -e "  ${BLUE}┌─────────────────────────────────────────┐${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}#!/bin/bash${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}# My first script${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}echo \"Hello, World!\"${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}echo \"Today is: \$(date)\"${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}echo \"You are: \$(whoami)\"${RESET}"
    echo -e "  ${BLUE}└─────────────────────────────────────────┘${RESET}"
    echo ""
    echo -e "  ${WHITE}${BOLD}Step 2: Make it executable${RESET}"
    code_block "chmod +x myscript.sh"
    echo ""
    echo -e "  ${WHITE}${BOLD}Step 3: Run it${RESET}"
    code_block "./myscript.sh"

    pause_continue

    sub_header "Variables"
    echo -e "  ${BLUE}┌─────────────────────────────────────────┐${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}#!/bin/bash${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}NAME=\"Termux User\"${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}AGE=25${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}echo \"Name: \$NAME\"${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}echo \"Age: \$AGE\"${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}# Read user input${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}read -p \"Enter your name: \" USER${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}echo \"Hello, \$USER!\"${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}# Command substitution${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}TODAY=\$(date +%Y-%m-%d)${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}echo \"Date: \$TODAY\"${RESET}"
    echo -e "  ${BLUE}└─────────────────────────────────────────┘${RESET}"

    pause_continue

    sub_header "Conditional Statements (if/else)"
    echo -e "  ${BLUE}┌─────────────────────────────────────────┐${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}#!/bin/bash${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}read -p \"Enter a number: \" NUM${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}if [ \$NUM -gt 10 ]; then${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}    echo \"Greater than 10\"${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}elif [ \$NUM -eq 10 ]; then${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}    echo \"Equal to 10\"${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}else${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}    echo \"Less than 10\"${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}fi${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}# File checks:${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}# -f file    File exists${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}# -d dir     Directory exists${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}# -r file    File is readable${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}# -w file    File is writable${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}# -x file    File is executable${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}# -z string  String is empty${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}# -n string  String is not empty${RESET}"
    echo -e "  ${BLUE}└─────────────────────────────────────────┘${RESET}"

    pause_continue

    sub_header "Loops"
    echo -e "  ${WHITE}${BOLD}For Loop:${RESET}"
    echo -e "  ${BLUE}┌─────────────────────────────────────────┐${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}# Loop through list${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}for i in 1 2 3 4 5; do${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}    echo \"Number: \$i\"${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}done${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}# C-style for loop${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}for ((i=0; i<10; i++)); do${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}    echo \$i${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}done${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}# Loop through files${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}for file in *.txt; do${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}    echo \"File: \$file\"${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}done${RESET}"
    echo -e "  ${BLUE}└─────────────────────────────────────────┘${RESET}"
    echo ""

    echo -e "  ${WHITE}${BOLD}While Loop:${RESET}"
    echo -e "  ${BLUE}┌─────────────────────────────────────────┐${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}count=1${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}while [ \$count -le 5 ]; do${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}    echo \"Count: \$count\"${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}    ((count++))${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}done${RESET}"
    echo -e "  ${BLUE}└─────────────────────────────────────────┘${RESET}"

    pause_continue

    sub_header "Functions"
    echo -e "  ${BLUE}┌─────────────────────────────────────────┐${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}#!/bin/bash${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}greet() {${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}    echo \"Hello, \$1!\"${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}    echo \"You are \$2 years old\"${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}}${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}add() {${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}    local result=\$((\$1 + \$2))${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}    echo \$result${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}}${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}greet \"Alice\" 25${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}SUM=\$(add 5 3)${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}echo \"5 + 3 = \$SUM\"${RESET}"
    echo -e "  ${BLUE}└─────────────────────────────────────────┘${RESET}"

    sub_header "Case Statement (Switch)"
    echo -e "  ${BLUE}┌─────────────────────────────────────────┐${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}read -p \"Choose (a/b/c): \" choice${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}case \$choice in${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}    a) echo \"You chose A\" ;;${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}    b) echo \"You chose B\" ;;${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}    c) echo \"You chose C\" ;;${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}    *) echo \"Invalid\" ;;${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}esac${RESET}"
    echo -e "  ${BLUE}└─────────────────────────────────────────┘${RESET}"

    sub_header "Arrays"
    echo -e "  ${BLUE}┌─────────────────────────────────────────┐${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}fruits=(\"apple\" \"banana\" \"cherry\")${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}echo \${fruits[0]}     # apple${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}echo \${fruits[@]}     # all elements${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}echo \${#fruits[@]}    # array length${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}fruits+=(\"date\")      # add element${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}for f in \"\${fruits[@]}\"; do${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}    echo \$f${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}done${RESET}"
    echo -e "  ${BLUE}└─────────────────────────────────────────┘${RESET}"

    pause_continue
    echo ""
    echo -e "  ${YELLOW}Mark Lesson 11 as complete? (y/n):${RESET} \c"
    read -r mark_choice
    if [[ "$mark_choice" == "y" || "$mark_choice" == "Y" ]]; then
        mark_lesson_complete 11
    fi
    main_menu
}

# ===================== LESSON 12: ADVANCED TOOLS =====================

lesson_advanced() {
    banner
    section_header "LESSON 12: ADVANCED TOOLS & UTILITIES"

    sub_header "tmux - Terminal Multiplexer"
    info "Install: pkg install tmux"
    echo ""
    cmd_example "tmux" "Start new session"
    cmd_example "tmux new -s mysession" "Start named session"
    cmd_example "tmux ls" "List sessions"
    cmd_example "tmux attach -t mysession" "Attach to session"
    cmd_example "tmux kill-session -t mysession" "Kill session"
    echo ""
    echo -e "  ${WHITE}${BOLD}tmux Key Bindings (prefix: CTRL+B):${RESET}"
    info "CTRL+B, C       → New window"
    info "CTRL+B, N       → Next window"
    info "CTRL+B, P       → Previous window"
    info "CTRL+B, %       → Split horizontally"
    info "CTRL+B, \"       → Split vertically"
    info "CTRL+B, D       → Detach session"
    info "CTRL+B, [       → Scroll mode (q to exit)"
    info "CTRL+B, X       → Kill current pane"

    pause_continue

    sub_header "tar, zip, gzip - Compression Tools"

    echo -e "  ${WHITE}${BOLD}tar:${RESET}"
    cmd_example "tar -czf archive.tar.gz dir/" "Create compressed archive"
    cmd_example "tar -xzf archive.tar.gz" "Extract archive"
    cmd_example "tar -tzf archive.tar.gz" "List archive contents"
    cmd_example "tar -cf archive.tar dir/" "Create tar (no compression)"
    cmd_example "tar -xf archive.tar" "Extract tar"
    echo ""

    echo -e "  ${WHITE}${BOLD}zip/unzip:${RESET}"
    info "Install: pkg install zip unzip"
    cmd_example "zip -r archive.zip dir/" "Create zip archive"
    cmd_example "unzip archive.zip" "Extract zip"
    cmd_example "unzip -l archive.zip" "List zip contents"
    cmd_example "unzip archive.zip -d /path/" "Extract to directory"
    echo ""

    echo -e "  ${WHITE}${BOLD}gzip:${RESET}"
    cmd_example "gzip file.txt" "Compress file (creates .gz)"
    cmd_example "gunzip file.txt.gz" "Decompress file"
    cmd_example "gzip -k file.txt" "Compress keeping original"

    pause_continue

    sub_header "cron - Task Scheduling"
    info "Install: pkg install cronie termux-services"
    echo ""
    cmd_example "sv-enable crond" "Enable cron service"
    cmd_example "crontab -e" "Edit cron jobs"
    cmd_example "crontab -l" "List cron jobs"
    echo ""
    echo -e "  ${WHITE}${BOLD}Cron Format: MIN HOUR DOM MON DOW COMMAND${RESET}"
    info "*/5 * * * * /path/script.sh    → Every 5 minutes"
    info "0 * * * * /path/script.sh      → Every hour"
    info "0 0 * * * /path/script.sh      → Every day at midnight"
    info "0 0 * * 1 /path/script.sh      → Every Monday"
    info "0 0 1 * * /path/script.sh      → First of every month"

    sub_header "screen - Terminal Session Manager"
    info "Install: pkg install screen"
    cmd_example "screen" "Start new screen session"
    cmd_example "screen -S name" "Start named session"
    cmd_example "screen -ls" "List sessions"
    cmd_example "screen -r name" "Reattach to session"
    info "CTRL+A, D    → Detach"
    info "CTRL+A, C    → New window"
    info "CTRL+A, N    → Next window"

    sub_header "jq - JSON Processor"
    info "Install: pkg install jq"
    cmd_example "cat data.json | jq '.'" "Pretty print JSON"
    cmd_example "cat data.json | jq '.key'" "Extract a key"
    cmd_example "curl -s api.example.com | jq '.'" "Parse API response"
    cmd_example "echo '{\"name\":\"test\"}' | jq '.name'" "Extract value"

    sub_header "ffmpeg - Media Processing"
    info "Install: pkg install ffmpeg"
    cmd_example "ffmpeg -i input.mp4 output.avi" "Convert video format"
    cmd_example "ffmpeg -i input.mp4 -vn output.mp3" "Extract audio"
    cmd_example "ffmpeg -i input.mp4 -an output.mp4" "Remove audio"
    cmd_example "ffmpeg -i input.mp3 -ss 00:01:00 -t 30 clip.mp3" "Trim audio"

    sub_header "ImageMagick - Image Processing"
    info "Install: pkg install imagemagick"
    cmd_example "convert input.png output.jpg" "Convert image format"
    cmd_example "convert input.jpg -resize 50% output.jpg" "Resize image"
    cmd_example "convert input.jpg -rotate 90 output.jpg" "Rotate image"

    pause_continue
    echo ""
    echo -e "  ${YELLOW}Mark Lesson 12 as complete? (y/n):${RESET} \c"
    read -r mark_choice
    if [[ "$mark_choice" == "y" || "$mark_choice" == "Y" ]]; then
        mark_lesson_complete 12
    fi
    main_menu
}

# ===================== LESSON 13: SSH =====================

lesson_ssh() {
    banner
    section_header "LESSON 13: SSH & REMOTE ACCESS"

    sub_header "SSH Client"
    info "Install: pkg install openssh"
    echo ""

    cmd_example "ssh user@hostname" "Connect to remote server"
    cmd_example "ssh -p 2222 user@hostname" "Connect on custom port"
    cmd_example "ssh user@hostname 'command'" "Run remote command"
    cmd_example "ssh -i key.pem user@hostname" "Connect using private key"

    sub_header "SSH Key Management"

    cmd_example "ssh-keygen -t rsa -b 4096" "Generate RSA key pair"
    cmd_example "ssh-keygen -t ed25519" "Generate Ed25519 key (recommended)"
    cmd_example "ssh-copy-id user@hostname" "Copy public key to server"
    cmd_example "cat ~/.ssh/id_rsa.pub" "View public key"

    sub_header "SCP - Secure Copy"

    cmd_example "scp file.txt user@host:/path/" "Upload file to server"
    cmd_example "scp user@host:/path/file.txt ." "Download file from server"
    cmd_example "scp -r dir/ user@host:/path/" "Upload directory"
    cmd_example "scp -P 2222 file.txt user@host:/path/" "SCP with custom port"

    sub_header "SFTP - Secure FTP"

    cmd_example "sftp user@hostname" "Start SFTP session"
    info "SFTP commands: ls, cd, get, put, mkdir, rm, exit"

    sub_header "Running SSH Server on Termux"

    info "Start SSH server in Termux:"
    code_block "sshd"
    info "Default port: 8022"
    info "Connect from another device:"
    code_block "ssh -p 8022 <your_phone_ip>"
    echo ""
    info "Set password:"
    code_block "passwd"
    echo ""
    info "Find your IP:"
    code_block "ifconfig | grep 'inet '"
    echo ""
    info "Stop SSH server:"
    code_block "pkill sshd"
    echo ""
    info "SSH to Termux uses your Termux username (run 'whoami')."

    sub_header "SSH Config File"
    info "Create: ~/.ssh/config"
    echo -e "  ${BLUE}┌─────────────────────────────────────────┐${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}Host myserver${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}    HostName 192.168.1.100${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}    User admin${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}    Port 22${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}    IdentityFile ~/.ssh/id_rsa${RESET}"
    echo -e "  ${BLUE}└─────────────────────────────────────────┘${RESET}"
    echo ""
    info "Then connect with: ssh myserver"

    pause_continue
    echo ""
    echo -e "  ${YELLOW}Mark Lesson 13 as complete? (y/n):${RESET} \c"
    read -r mark_choice
    if [[ "$mark_choice" == "y" || "$mark_choice" == "Y" ]]; then
        mark_lesson_complete 13
    fi
    main_menu
}

# ===================== LESSON 14: GIT =====================

lesson_git() {
    banner
    section_header "LESSON 14: GIT & VERSION CONTROL"

    sub_header "Git Installation & Setup"
    info "Install: pkg install git"
    echo ""
    cmd_example "git config --global user.name 'Your Name'" "Set your name"
    cmd_example "git config --global user.email 'you@email.com'" "Set your email"
    cmd_example "git config --list" "View all configs"

    sub_header "Basic Git Commands"

    cmd_example "git init" "Initialize a new repository"
    cmd_example "git clone <url>" "Clone a repository"
    cmd_example "git status" "Check status of files"
    cmd_example "git add ." "Stage all changes"
    cmd_example "git add file.txt" "Stage specific file"
    cmd_example "git commit -m 'message'" "Commit with message"
    cmd_example "git log" "View commit history"
    cmd_example "git log --oneline" "Compact commit history"
    cmd_example "git diff" "Show unstaged changes"
    cmd_example "git diff --staged" "Show staged changes"

    pause_continue

    sub_header "Remote Repositories"

    cmd_example "git remote add origin <url>" "Add remote repository"
    cmd_example "git remote -v" "View remotes"
    cmd_example "git push origin main" "Push to remote"
    cmd_example "git push -u origin main" "Push and set upstream"
    cmd_example "git pull origin main" "Pull from remote"
    cmd_example "git fetch" "Fetch without merging"

    sub_header "Branching"

    cmd_example "git branch" "List branches"
    cmd_example "git branch feature" "Create new branch"
    cmd_example "git checkout feature" "Switch to branch"
    cmd_example "git checkout -b feature" "Create and switch"
    cmd_example "git merge feature" "Merge branch into current"
    cmd_example "git branch -d feature" "Delete branch"
    cmd_example "git branch -D feature" "Force delete branch"

    sub_header "Undoing Changes"

    cmd_example "git checkout -- file.txt" "Discard file changes"
    cmd_example "git reset HEAD file.txt" "Unstage a file"
    cmd_example "git reset --soft HEAD~1" "Undo last commit (keep changes)"
    cmd_example "git reset --hard HEAD~1" "Undo last commit (discard changes)"
    cmd_example "git stash" "Stash current changes"
    cmd_example "git stash pop" "Apply stashed changes"
    cmd_example "git revert <commit>" "Create revert commit"

    sub_header "Git with GitHub/GitLab"
    info "Generate SSH key: ssh-keygen -t ed25519"
    info "Copy key: cat ~/.ssh/id_ed25519.pub"
    info "Add the key to GitHub/GitLab settings"
    echo ""
    code_block "git clone git@github.com:user/repo.git"

    pause_continue
    echo ""
    echo -e "  ${YELLOW}Mark Lesson 14 as complete? (y/n):${RESET} \c"
    read -r mark_choice
    if [[ "$mark_choice" == "y" || "$mark_choice" == "Y" ]]; then
        mark_lesson_complete 14
    fi
    main_menu
}

# ===================== LESSON 15: DATABASE =====================

lesson_database() {
    banner
    section_header "LESSON 15: DATABASE TOOLS"

    sub_header "SQLite"
    info "Install: pkg install sqlite"
    echo ""
    cmd_example "sqlite3 mydb.db" "Create/open database"
    echo ""
    echo -e "  ${WHITE}${BOLD}SQLite Commands:${RESET}"
    info ".tables              → List all tables"
    info ".schema              → Show database schema"
    info ".headers on          → Show column headers"
    info ".mode column         → Column display mode"
    info ".quit                → Exit sqlite3"
    echo ""
    echo -e "  ${WHITE}${BOLD}SQL Examples:${RESET}"
    echo -e "  ${BLUE}┌─────────────────────────────────────────┐${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}CREATE TABLE users (${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}    id INTEGER PRIMARY KEY,${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}    name TEXT NOT NULL,${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}    email TEXT UNIQUE${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE});${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}INSERT INTO users (name, email)${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}VALUES ('Alice', 'alice@email.com');${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}SELECT * FROM users;${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}SELECT name FROM users WHERE id = 1;${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}UPDATE users SET name = 'Bob' WHERE id = 1;${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}DELETE FROM users WHERE id = 1;${RESET}"
    echo -e "  ${BLUE}└─────────────────────────────────────────┘${RESET}"

    pause_continue

    sub_header "MariaDB (MySQL)"
    info "Install: pkg install mariadb"
    echo ""
    cmd_example "mysqld_safe &" "Start MySQL server"
    cmd_example "mysql -u root" "Connect to MySQL"
    cmd_example "mysqladmin -u root password 'newpass'" "Set root password"
    echo ""
    echo -e "  ${WHITE}${BOLD}MySQL Commands:${RESET}"
    info "SHOW DATABASES;"
    info "CREATE DATABASE mydb;"
    info "USE mydb;"
    info "SHOW TABLES;"

    sub_header "PostgreSQL"
    info "Install: pkg install postgresql"
    echo ""
    cmd_example "initdb ~/pg_data" "Initialize database"
    cmd_example "pg_ctl -D ~/pg_data start" "Start PostgreSQL"
    cmd_example "createdb mydb" "Create database"
    cmd_example "psql mydb" "Connect to database"

    sub_header "Redis"
    info "Install: pkg install redis"
    cmd_example "redis-server &" "Start Redis server"
    cmd_example "redis-cli" "Connect to Redis"
    info "SET key value"
    info "GET key"
    info "KEYS *"

    sub_header "MongoDB (via Python)"
    info "Install: pip install pymongo"
    info "Note: Full MongoDB is not available in Termux"
    info "Alternative: Use MongoDB Atlas (cloud) or TinyDB"
    code_block "pip install tinydb"

    pause_continue
    echo ""
    echo -e "  ${YELLOW}Mark Lesson 15 as complete? (y/n):${RESET} \c"
    read -r mark_choice
    if [[ "$mark_choice" == "y" || "$mark_choice" == "Y" ]]; then
        mark_lesson_complete 15
    fi
    main_menu
}

# ===================== LESSON 16: CUSTOMIZATION =====================

lesson_customization() {
    banner
    section_header "LESSON 16: TERMUX CUSTOMIZATION"

    sub_header "Changing Shell Prompt"
    info "Edit ~/.bashrc or ~/.bash_profile"
    echo ""
    echo -e "  ${WHITE}${BOLD}Custom PS1 Prompt:${RESET}"
    echo -e "  ${BLUE}┌─────────────────────────────────────────┐${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}# Add to ~/.bashrc${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}PS1='\\[\\e[32m\\]\\u\\[\\e[0m\\]@\\[\\e[34m\\]termux\\[\\e[0m\\]:\\[\\e[33m\\]\\w\\[\\e[0m\\]\\\$ '${RESET}"
    echo -e "  ${BLUE}└─────────────────────────────────────────┘${RESET}"
    echo ""
    info "\\u = username | \\w = working dir | \\h = hostname"
    info "\\t = time | \\d = date | \\n = newline"

    sub_header "Install ZSH (Alternative Shell)"
    info "Install: pkg install zsh"
    echo ""
    cmd_example "chsh -s zsh" "Set ZSH as default shell"
    cmd_example "chsh -s bash" "Switch back to Bash"
    echo ""

    echo -e "  ${WHITE}${BOLD}Install Oh My ZSH:${RESET}"
    code_block "sh -c \"\$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)\""
    echo ""
    info "Edit ~/.zshrc to change themes and plugins"
    info "Popular themes: robbyrussell, agnoster, powerlevel10k"

    sub_header "Install Fish Shell"
    info "Install: pkg install fish"
    cmd_example "fish" "Start Fish shell"
    cmd_example "chsh -s fish" "Set as default"

    pause_continue

    sub_header "Termux Properties"
    info "Create/edit: ~/.termux/termux.properties"
    echo ""
    echo -e "  ${BLUE}┌─────────────────────────────────────────┐${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}# ~/.termux/termux.properties${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}# Extra keys row${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}extra-keys = [[${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}  'ESC','/','-','HOME','UP','END','PGUP',${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}  'TAB','CTRL','ALT','LEFT','DOWN','RIGHT','PGDN'${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}]]${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}# Use black color for drawer/header${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}use-black-ui = true${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}# Bell vibrate duration (ms)${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}bell-character = vibrate${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}# Fullscreen mode${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}fullscreen = true${RESET}"
    echo -e "  ${BLUE}└─────────────────────────────────────────┘${RESET}"
    echo ""
    info "After editing, run: termux-reload-settings"

    sub_header "Color Schemes"
    info "Set color scheme using termux-style script:"
    code_block "curl -fsSL https://raw.githubusercontent.com/adi1090x/termux-style/master/install | bash"
    echo ""
    info "Or manually edit: ~/.termux/colors.properties"
    echo -e "  ${BLUE}┌─────────────────────────────────────────┐${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}foreground=#FFFFFF${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}background=#000000${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}cursor=#FFFFFF${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}color0=#000000${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}color1=#FF0000${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}...${RESET}"
    echo -e "  ${BLUE}└─────────────────────────────────────────┘${RESET}"

    sub_header "Custom Font"
    info "Download a font (.ttf) and rename to font.ttf"
    code_block "cp font.ttf ~/.termux/font.ttf"
    code_block "termux-reload-settings"

    sub_header "Aliases (Command Shortcuts)"
    info "Add to ~/.bashrc:"
    echo -e "  ${BLUE}┌─────────────────────────────────────────┐${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}alias ll='ls -la'${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}alias la='ls -A'${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}alias cls='clear'${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}alias update='pkg update && pkg upgrade -y'${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}alias myip='curl ifconfig.me'${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}alias ports='netstat -tlnp'${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}alias ..='cd ..'${RESET}"
    echo -e "  ${BLUE}│${RESET} ${WHITE}alias ...='cd ../..'${RESET}"
    echo -e "  ${BLUE}└─────────────────────────────────────────┘${RESET}"
    echo ""
    info "Apply changes: source ~/.bashrc"

    sub_header "Fun Commands"
    info "pkg install figlet toilet cowsay fortune sl cmatrix"
    cmd_example "figlet 'Termux'" "ASCII art text"
    cmd_example "toilet -f mono12 'Hello'" "Colored ASCII text"
    cmd_example "cowsay 'Hello!'" "Talking cow"
    cmd_example "fortune" "Random fortune"
    cmd_example "fortune | cowsay" "Fortune with cow"
    cmd_example "cmatrix" "Matrix rain effect"
    cmd_example "sl" "Steam locomotive (typo corrector!)"

    pause_continue
    echo ""
    echo -e "  ${YELLOW}Mark Lesson 16 as complete? (y/n):${RESET} \c"
    read -r mark_choice
    if [[ "$mark_choice" == "y" || "$mark_choice" == "Y" ]]; then
        mark_lesson_complete 16
    fi
    main_menu
}

# ===================== LESSON 17: FULL SETUP =====================

full_setup() {
    banner
    section_header "FULL TERMUX SETUP SCRIPT"

    warn "This will install many packages and may take a while."
    warn "Make sure you have a stable internet connection."
    echo ""

    echo -e "  ${YELLOW}Do you want to proceed with the full setup? (y/n):${RESET} \c"
    read -r choice

    if [[ "$choice" != "y" && "$choice" != "Y" ]]; then
        main_menu
        return
    fi

    echo ""
    info "Starting full Termux setup..."
    echo ""

    # Step 1: Update
    sub_header "Step 1: Updating packages"
    pkg update -y && pkg upgrade -y
    info "Packages updated!"

    # Step 2: Essential tools
    sub_header "Step 2: Installing essential tools"
    pkg install -y coreutils findutils grep sed gawk tar gzip bzip2 xz-utils
    info "Essential tools installed!"

    # Step 3: Development tools
    sub_header "Step 3: Installing development tools"
    pkg install -y git vim nano curl wget python nodejs clang make cmake
    info "Development tools installed!"

    # Step 4: Networking tools
    sub_header "Step 4: Installing networking tools"
    pkg install -y openssh nmap net-tools dnsutils iproute2 traceroute whois
    info "Networking tools installed!"

    # Step 5: Utility tools
    sub_header "Step 5: Installing utilities"
    pkg install -y htop tree zip unzip man less tmux screen jq bc
    info "Utilities installed!"

    # Step 6: Fun packages
    sub_header "Step 6: Installing fun packages"
    pkg install -y figlet cowsay fortune neofetch 2>/dev/null
    info "Fun packages installed!"

    # Step 7: Setup storage
    sub_header "Step 7: Setting up storage"
    termux-setup-storage 2>/dev/null
    info "Storage setup complete!"

    # Step 8: Create .bashrc
    sub_header "Step 8: Creating .bashrc customization"
    if [ ! -f ~/.bashrc.backup ]; then
        cp ~/.bashrc ~/.bashrc.backup 2>/dev/null
    fi

    cat >> ~/.bashrc << 'BASHRC'

# === Termux Custom Setup ===
# Aliases
alias ll='ls -la --color=auto'
alias la='ls -A --color=auto'
alias l='ls -CF --color=auto'
alias cls='clear'
alias ..='cd ..'
alias ...='cd ../..'
alias update='pkg update && pkg upgrade -y'
alias myip='curl -s ifconfig.me'

# Custom prompt
PS1='\[\e[32m\]\u\[\e[0m\]@\[\e[34m\]termux\[\e[0m\]:\[\e[33m\]\w\[\e[0m\]\$ '

# Welcome message
echo ""
echo "Welcome to Termux!"
echo "Date: $(date)"
echo ""
BASHRC

    info ".bashrc customized!"

    # Step 9: Create useful scripts directory
    sub_header "Step 9: Creating scripts directory"
    mkdir -p ~/scripts
    mkdir -p ~/projects
    mkdir -p ~/.shortcuts

    # Create a handy info script
    cat > ~/scripts/sysinfo.sh << 'SYSINFO'
#!/bin/bash
echo "======== System Info ========"
echo "User: $(whoami)"
echo "Shell: $SHELL"
echo "Date: $(date)"
echo "Uptime: $(uptime -p 2>/dev/null || uptime)"
echo "Kernel: $(uname -r)"
echo "Arch: $(uname -m)"
echo "Home: $HOME"
echo "Packages: $(dpkg -l 2>/dev/null | wc -l)"
echo "============================="
SYSINFO
    chmod +x ~/scripts/sysinfo.sh
    info "Scripts directory created!"

    echo ""
    info "✅ Full setup complete!"
    info "Run 'source ~/.bashrc' to apply changes."
    info "Run '~/scripts/sysinfo.sh' to see system info."

    pause_continue
    echo ""
    echo -e "  ${YELLOW}Mark Lesson 17 as complete? (y/n):${RESET} \c"
    read -r mark_choice
    if [[ "$mark_choice" == "y" || "$mark_choice" == "Y" ]]; then
        mark_lesson_complete 17
    fi
    main_menu
}

# ===================== SEARCH TOOL =====================

search_tool() {
    banner
    section_header "SEARCH COMMANDS & TOOLS"
    echo -e "  Enter a keyword to search for (e.g., 'git', 'ip', 'delete'): \c"
    read -r query
    
    if [[ -z "$query" ]]; then
        main_menu
        return
    fi

    echo ""
    info "Searching for: ${YELLOW}$query${RESET}"
    echo -e "  ${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"

    # Search the script itself for cmd_example lines containing the query
    local results
    results=$(grep -i "cmd_example" "$0" | grep -i "$query" | grep -vE "grep|search_tool")

    if [[ -z "$results" ]]; then
        warn "No matching commands found for '$query'."
    else
        echo "$results" | while read -r line; do
            local cmd=$(echo "$line" | sed -E 's/.*cmd_example "([^"]+)".*/\1/')
            local purpose=$(echo "$line" | sed -E 's/.*cmd_example "[^"]+" "([^"]+)".*/\1/')
            echo -e "  ${CYAN}${BOLD}$cmd${RESET}"
            echo -e "  ${WHITE}Purpose:${RESET} $purpose"
            echo ""
        done
    fi

    pause_continue
    echo ""
    echo -e "  ${YELLOW}Mark Search Tool as complete? (y/n):${RESET} \c"
    read -r mark_choice
    if [[ "$mark_choice" == "y" || "$mark_choice" == "Y" ]]; then
        mark_lesson_complete 19 # Using 19 for Search Tool
    fi
    main_menu
}

# ===================== INTERACTIVE QUIZ =====================

lesson_quiz() {
    banner
    section_header "TERMUX KNOWLEDGE QUIZ"
    local score=0
    local total=0

    ask_q() {
        ((total++))
        echo -e "\n  ${WHITE}${BOLD}Q$total: $1${RESET}"
        echo -e "  A) $2"
        echo -e "  B) $3"
        echo -e "  C) $4"
        echo -e "  ${YELLOW}Choice (A/B/C):${RESET} \c"
        read -r ans
        if [[ "${ans,,}" == "$5" ]]; then
            info "Correct!"
            ((score++))
        else
            error "Wrong! The correct answer was $5."
        fi
    }

    ask_q "Which command is used to update the package list?" "pkg upgrade" "pkg update" "pkg install" "b"
    ask_q "What is the default SSH port in Termux?" "22" "8080" "8022" "c"
    ask_q "How do you give a script execute permissions?" "chmod +x" "chmod 755" "Both A and B" "c"
    ask_q "Which tool is a terminal multiplexer?" "nmap" "tmux" "git" "b"
    ask_q "Which command sets up Android storage access?" "termux-storage-get" "termux-setup-storage" "termux-api" "b"

    echo ""
    sub_header "Quiz Results"
    info "Final Score: $score / $total"
    [ $score -eq $total ] && echo -e "  ${GREEN}${BOLD}Excellent! You are a Termux master! 🏆${RESET}"

    pause_continue
    echo ""
    echo -e "  ${YELLOW}Mark Interactive Quiz as complete? (y/n):${RESET} \c"
    read -r mark_choice
    if [[ "$mark_choice" == "y" || "$mark_choice" == "Y" ]]; then
        mark_lesson_complete 20 # Using 20 for Interactive Quiz
    fi
    main_menu
}

# ===================== SANDBOX MODE =====================

sandbox_mode() {
    banner
    section_header "🏜️ TERMUX SANDBOX MODE"
    echo -e "  Enter any command to analyze and explain it before running."
    echo -e "  Example: 'ls -la', 'uname -a', or 'python --version'."
    echo -e "  Type 'exit' or leave blank to return to menu."
    echo ""
    echo -e "  ${WHITE}${BOLD}Command:${RESET} \c"
    read -r user_cmd

    if [[ -z "$user_cmd" || "$user_cmd" == "exit" ]]; then
        main_menu
        return
    fi

    local base_cmd=$(echo "$user_cmd" | awk '{print $1}')

    if ! command -v "$base_cmd" >/dev/null 2>&1; then
        error "Command '$base_cmd' not found. Ensure it is installed via pkg."
        pause_continue
        sandbox_mode
        return
    fi

    sub_header "Command Analysis"
    
    # Try to get a description
    local desc=""
    
    # 1. Check a manual lookup for cleaner descriptions
    case "$base_cmd" in
        ls) desc="Lists files and directories in the current location." ;;
        cd) desc="Changes your current directory to a new path." ;;
        pkg) desc="The package manager used to install/update software in Termux." ;;
        pwd) desc="Shows the 'Print Working Directory' - exactly where you are." ;;
        rm) desc="Removes (deletes) files or directories permanently." ;;
        cp) desc="Copies files or directories from one place to another." ;;
        mv) desc="Moves or renames files or directories." ;;
        *)
            # 2. Try whatis database
            if command -v whatis >/dev/null 2>&1; then
                desc=$(whatis "$base_cmd" 2>/dev/null | head -n 1)
            fi
            # 3. Fallback to extracting the first line of help
            if [[ -z "$desc" || "$desc" == *":"* ]]; then
                desc=$($base_cmd --help 2>&1 | head -n 2 | tr '\n' ' ' | sed 's/  */ /g')
            fi
            ;;
    esac

    info "Analyzing: ${CYAN}$base_cmd${RESET}"
    info "What it does: ${WHITE}${desc:-'A system executable.'}${RESET}"
    echo ""

    if confirm_run; then
        run_demo "$user_cmd"
    fi

    pause_continue
    echo ""
    echo -e "  ${YELLOW}Mark Sandbox Mode as complete? (y/n):${RESET} \c"
    read -r mark_choice
    if [[ "$mark_choice" == "y" || "$mark_choice" == "Y" ]]; then
        mark_lesson_complete 21 # Using 21 for Sandbox Mode
    fi
    sandbox_mode
}

# ===================== LESSON 22: POPULAR TOOLS SHOWCASE =====================

lesson_popular_tools() {
    banner
    section_header "LESSON 22: TOP 20 POPULAR TERMUX TOOLS"
    echo -e "  Explore the most powerful and downloaded tools in the Termux ecosystem."
    echo ""

    sub_header "1. htop - Interactive Process Viewer"
    info "htop is an advanced, interactive, and real-time process monitor. It provides a dynamic and colorful view of your system's running processes, CPU usage, memory consumption, and swap space, making it much more user-friendly than the traditional 'top' command for identifying resource hogs."
    code_block "pkg install htop"
    interactive_tool "htop --version" "Checks if htop is ready to monitor your system resources."

    sub_header "2. neofetch - System Information"
    info "Neofetch is a command-line system information tool that displays system details in a visually appealing way, often alongside an ASCII art logo of the operating system or environment. It's popular for sharing system configurations and adding a personal touch to your terminal."
    code_block "pkg install neofetch"
    interactive_tool "neofetch --off" "Shows system details (OS, Kernel, Shell, CPU) in text mode."

    sub_header "3. nmap - Network Mapper"
    info "Nmap (Network Mapper) is a powerful and versatile open-source utility for network discovery and security auditing. It's widely used for port scanning, OS detection, service version detection, and identifying potential vulnerabilities on network hosts."
    code_block "pkg install nmap"
    interactive_tool "nmap -V" "Verifies the installation of the network scanner."

    sub_header "4. curl - URL Data Transfer"
    info "curl is a command-line tool and library for transferring data with URLs. It supports a vast range of protocols including HTTP, HTTPS, FTP, FTPS, SCP, SFTP, and more. It's indispensable for making web requests, interacting with APIs, and downloading files."
    interactive_tool "curl -s ifconfig.me" "Try it: Fetches your public IP address using curl."

    sub_header "5. git - Version Control"
    info "Git is a distributed version control system that tracks changes in source code during software development. It's fundamental for collaborative projects, allowing multiple developers to work on the same codebase efficiently, and is essential for cloning repositories from platforms like GitHub and GitLab."
    interactive_tool "git --version" "Checks your git version."

    sub_header "6. python - Programming Language"
    info "Python is a high-level, interpreted programming language known for its readability and versatility. It's widely used in Termux for scripting, automation, web development (with frameworks like Flask/Django), data analysis, and even ethical hacking tools due to its extensive libraries."
    interactive_tool "python --version" "Verifies your Python 3 environment."

    sub_header "7. tmux - Terminal Multiplexer"
    info "tmux (Terminal Multiplexer) allows you to create, access, and control multiple terminal sessions from a single window. It's incredibly useful for keeping programs running in the background even if you disconnect, and for organizing your workspace with multiple panes and windows."
    code_block "pkg install tmux"
    interactive_tool "tmux -V" "Checks the tmux version."

    sub_header "8. ffmpeg - Media Converter"
    info "FFmpeg is a comprehensive, cross-platform solution for recording, converting, and streaming audio and video. It's a powerful command-line tool capable of handling almost any multimedia format, making it invaluable for media manipulation tasks directly on your device."
    code_block "pkg install ffmpeg"
    interactive_tool "ffmpeg -version | head -n 1" "Displays the media processing engine version."

    sub_header "9. yt-dlp - Video Downloader"
    info "yt-dlp is a popular, feature-rich command-line program for downloading videos and audio from YouTube and thousands of other video hosting websites. It's highly customizable, supporting various formats, quality options, and metadata extraction."
    code_block "pkg install python && pip install yt-dlp"
    interactive_tool "yt-dlp --version" "Checks the downloader core."

    sub_header "10. aria2 - Lightweight Downloader"
    info "aria2 is a lightweight, multi-protocol & multi-source command-line download utility. It supports HTTP/HTTPS, FTP, SFTP, BitTorrent, and Metalink. Its ability to download a file from multiple sources/protocols simultaneously can significantly increase download speeds."
    code_block "pkg install aria2"
    interactive_tool "aria2c --version | head -n 1" "Checks the high-speed download engine."

    pause_continue

    sub_header "11. tldr - Simplified Man Pages"
    info "tldr (Too Long; Didn't Read) is a community-driven collection of simplified man pages that provide practical examples of how to use common command-line tools. It's perfect for quickly recalling command syntax without sifting through lengthy documentation."
    code_block "pkg install tldr"
    interactive_tool "tldr --version" "Checks the documentation helper."

    sub_header "12. ranger - Terminal File Manager"
    info "Ranger is a VIM-inspired console file manager with a clean, multi-column display. It's designed for efficiency, allowing quick navigation, file previewing, and integration with other command-line tools for a powerful file management experience."
    code_block "pkg install ranger"
    interactive_tool "ranger --version | head -n 1" "Checks the file manager version."

    sub_header "13. lazygit - Simple Git UI"
    info "lazygit is a simple, yet powerful terminal UI for Git. It provides an interactive and intuitive interface for common Git operations like staging, committing, branching, and rebasing, making Git workflows more accessible and efficient for many users."
    code_block "pkg install lazygit"
    interactive_tool "lazygit --version" "Verifies the Git UI helper."

    sub_header "14. micro - Modern Text Editor"
    info "Micro is a modern and intuitive terminal-based text editor that aims to be a pleasant replacement for nano and a more accessible alternative to vim. It supports mouse interaction, common keyboard shortcuts (Ctrl+S, Ctrl+C, Ctrl+V), and a plugin system."
    code_block "pkg install micro"
    interactive_tool "micro -version" "Checks the editor engine."

    sub_header "15. speedtest-go - Network Speed Test"
    info "speedtest-go is a command-line tool for testing your internet connection speed directly from the terminal. It measures download and upload speeds, as well as latency, providing a quick way to diagnose network performance issues."
    code_block "pkg install speedtest-go"
    interactive_tool "speedtest-go --version" "Checks the speed testing utility."

    sub_header "16. openssh - Secure Shell"
    info "OpenSSH is the premier connectivity tool for remote login with the SSH protocol. It provides secure encrypted communication between two untrusted hosts over an insecure network, enabling secure remote command execution, file transfers (SCP/SFTP), and even turning your Termux device into an SSH server."
    interactive_tool "ssh -V" "Checks the SSH client/server version."

    sub_header "17. zip/unzip - Archive Tools"
    info "zip and unzip are fundamental utilities for compressing and decompressing files and directories into the widely used .zip archive format. They are essential for packaging multiple files together, reducing file sizes, and transferring data efficiently."
    interactive_tool "zip -v | head -n 1" "Checks the compression utility."

    sub_header "18. figlet - ASCII Art Generator"
    info "Figlet is a program that generates large letters out of ordinary screen characters, creating decorative ASCII art banners. It's often used for adding flair to shell scripts, welcome messages, or simply for fun in the terminal."
    code_block "pkg install figlet"
    interactive_tool "figlet 'Termux'" "Try it: Generates a banner for 'Termux'."

    sub_header "19. cmatrix - Matrix Effect"
    info "cmatrix is a program that simulates the 'digital rain' effect seen in the movie 'The Matrix'. It's a popular aesthetic tool for terminal customization, providing a visually striking and nostalgic display."
    code_block "pkg install cmatrix"
    interactive_tool "cmatrix -V" "Checks the visual effect engine."

    sub_header "20. proxychains-ng - Proxy Redirector"
    info "ProxyChains-NG is a tool that forces any TCP connection made by any given application to follow through a proxy (or a chain of proxies). It's commonly used for anonymizing network traffic, bypassing geo-restrictions, and for security testing by routing connections through SOCKS5, SOCKS4, or HTTP proxies."
    code_block "pkg install proxychains-ng"
    interactive_tool "proxychains4 -h 2>&1 | head -n 1" "Checks the proxy utility."

    echo ""
    sub_header "Practice Exercise"
    info "Task: Create a banner, save it to a file, and check its size."
    echo -e "  1. Run: ${CYAN}figlet 'Success' > test.txt${RESET}"
    echo -e "  2. Run: ${CYAN}cat test.txt${RESET}"
    echo -e "  3. Run: ${CYAN}du -h test.txt${RESET}"
    echo ""

    pause_continue
    echo ""
    echo -e "  ${YELLOW}Mark Lesson 22 as complete? (y/n):${RESET} \c"
    read -r mark_choice
    if [[ "$mark_choice" == "y" || "$mark_choice" == "Y" ]]; then
        mark_lesson_complete 22
    fi
    main_menu
}

# ===================== LESSON 23: TOOL INSTALLER =====================

lesson_tool_installer() {
    banner
    section_header "LESSON 23: TERMUX TOOL INSTALLER"
    echo -e "  Select tools to install or update. Already installed tools are skipped."
    echo ""

    local selected_tools=()
    local choice
    local tool_count=${#TOOL_NAMES[@]}

    while true; do
        sub_header "Available Tools"
        for i in "${!TOOL_NAMES[@]}"; do
            local tool_name="${TOOL_NAMES[$i]}"
            local check_cmd="${TOOL_CHECK_COMMANDS[$i]}"
            local status_text
            if is_tool_installed "$check_cmd"; then
                status_text="${GREEN}Installed${RESET}"
            else
                status_text="${RED}Not Installed${RESET}"
            fi
            echo -e "  ${WHITE}[$(($i+1))] ${tool_name}: ${status_text}${RESET}"
        done
        echo ""
        echo -e "  ${YELLOW}Enter tool numbers (e.g., 1 3 5), 'a' for all, or 'q' to quit:${RESET} \c"
        read -r choice

        if [[ "$choice" == "q" || "$choice" == "Q" ]]; then
            break
        elif [[ "$choice" == "a" || "$choice" == "A" ]]; then
            for i in "${!TOOL_NAMES[@]}"; do
                selected_tools+=("$i")
            done
            break
        else
            # Validate and add selected numbers
            local invalid_selection=0
            for num_str in $choice; do
                if [[ "$num_str" =~ ^[0-9]+$ ]] && [ "$num_str" -ge 1 ] && [ "$num_str" -le "$tool_count" ]; then
                    selected_tools+=("$((num_str-1))")
                else
                    error "Invalid selection: $num_str. Please enter valid numbers."
                    invalid_selection=1
                    selected_tools=() # Clear selection on invalid input
                    break
                fi
            done
            if [[ "$invalid_selection" -eq 0 && ${#selected_tools[@]} -gt 0 ]]; then
                break
            fi
        fi
    done

    if [[ ${#selected_tools[@]} -eq 0 ]]; then
        warn "No tools selected for installation."
    else
        sub_header "Installing Selected Tools"
        for index in "${selected_tools[@]}"; do
            local tool_name="${TOOL_NAMES[$index]}"
            local check_cmd="${TOOL_CHECK_COMMANDS[$index]}"
            local install_cmd="${TOOL_INSTALL_COMMANDS[$index]}"

            echo ""
            info "Processing: ${tool_name}"
            if is_tool_installed "$check_cmd"; then
                warn "${tool_name} is already installed. Skipping."
            else
                echo -e "  ${YELLOW}Installing ${tool_name} with: ${CYAN}$install_cmd${RESET}"
                if eval "$install_cmd"; then
                    info "${tool_name} installed successfully!"
                else
                    error "Failed to install ${tool_name}."
                fi
            fi
        done
    fi

    echo ""
    sub_header "Installation Summary"
    for i in "${!TOOL_NAMES[@]}"; do
        local tool_name="${TOOL_NAMES[$i]}"
        local check_cmd="${TOOL_CHECK_COMMANDS[$i]}"
        if is_tool_installed "$check_cmd"; then
            echo -e "  ${GREEN}✔ ${tool_name}${RESET}"
        else
            echo -e "  ${RED}✘ ${tool_name}${RESET}"
        fi
    done

    pause_continue
    echo ""
    echo -e "  ${YELLOW}Mark Lesson 23 (Tool Installer) as complete? (y/n):${RESET} \c"
    read -r mark_choice
    if [[ "$mark_choice" == "y" || "$mark_choice" == "Y" ]]; then
        mark_lesson_complete 23
    fi
    main_menu
}

# ===================== LESSON 18: CHEAT SHEET =====================

cheat_sheet() {
    banner
    section_header "TERMUX QUICK CHEAT SHEET"

    echo -e "  ${WHITE}${BOLD}═══════════════════════════════════════════════${RESET}"
    echo -e "  ${WHITE}${BOLD}         ESSENTIAL COMMANDS REFERENCE          ${RESET}"
    echo -e "  ${WHITE}${BOLD}═══════════════════════════════════════════════${RESET}"
    echo ""

    echo -e "  ${CYAN}${BOLD}📦 PACKAGE MANAGEMENT${RESET}"
    echo -e "  pkg update              Update package lists"
    echo -e "  pkg upgrade             Upgrade all packages"
    echo -e "  pkg install <pkg>       Install a package"
    echo -e "  pkg uninstall <pkg>     Remove a package"
    echo -e "  pkg search <keyword>    Search packages"
    echo -e "  pkg list-installed      List installed packages"
    echo ""

    echo -e "  ${CYAN}${BOLD}📁 FILE SYSTEM${RESET}"
    echo -e "  ls -la                  List all files (detailed)"
    echo -e "  cd <dir>                Change directory"
    echo -e "  mkdir -p <dir>          Create directory (nested)"
    echo -e "  cp -r <src> <dst>       Copy files/dirs"
    echo -e "  mv <src> <dst>          Move/rename"
    echo -e "  rm -rf <target>         Delete (force)"
    echo -e "  find . -name '*.txt'    Find files"
    echo -e "  du -sh *                Show sizes"
    echo ""

    echo -e "  ${CYAN}${BOLD}📝 TEXT PROCESSING${RESET}"
    echo -e "  cat file                View file"
    echo -e "  grep 'pattern' file     Search in file"
    echo -e "  sed 's/old/new/g' file  Replace text"
    echo -e "  head -n 20 file         First 20 lines"
    echo -e "  tail -f file            Follow file changes"
    echo -e "  wc -l file              Count lines"
    echo -e "  sort file               Sort lines"
    echo ""

    pause_continue

    echo -e "  ${CYAN}${BOLD}🌐 NETWORKING${RESET}"
    echo -e "  ping <host>             Test connectivity"
    echo -e "  curl ifconfig.me        Get public IP"
    echo -e "  wget <url>              Download file"
    echo -e "  nmap <target>           Port scan"
    echo -e "  ssh user@host           SSH connection"
    echo -e "  scp file user@host:/p   Secure copy"
    echo ""

    echo -e "  ${CYAN}${BOLD}🔐 PERMISSIONS${RESET}"
    echo -e "  chmod +x file           Make executable"
    echo -e "  chmod 755 file          Set permissions"
    echo -e "  ls -la                  View permissions"
    echo ""

    echo -e "  ${CYAN}${BOLD}⚙️ PROCESS MANAGEMENT${RESET}"
    echo -e "  ps aux                  List processes"
    echo -e "  htop                    Interactive viewer"
    echo -e "  kill <PID>              Kill process"
    echo -e "  command &               Run in background"
    echo -e "  CTRL+C                  Stop process"
    echo -e "  CTRL+Z                  Suspend process"
    echo ""

    echo -e "  ${CYAN}${BOLD}🐙 GIT${RESET}"
    echo -e "  git init                Initialize repo"
    echo -e "  git clone <url>         Clone repo"
    echo -e "  git add .               Stage changes"
    echo -e "  git commit -m 'msg'     Commit"
    echo -e "  git push                Push to remote"
    echo -e "  git pull                Pull from remote"
    echo -e "  git branch              List branches"
    echo -e "  git checkout -b <name>  New branch"
    echo ""

    echo -e "  ${CYAN}${BOLD}🐍 PYTHON${RESET}"
    echo -e "  python script.py        Run script"
    echo -e "  pip install <pkg>       Install package"
    echo -e "  python -m venv env      Create virtualenv"
    echo ""

    echo -e "  ${CYAN}${BOLD}📱 TERMUX SPECIFIC${RESET}"
    echo -e "  termux-setup-storage    Setup storage access"
    echo -e "  termux-reload-settings  Reload settings"
    echo -e "  termux-info             Termux info"
    echo -e "  sshd                    Start SSH server"
    echo ""

    echo -e "  ${CYAN}${BOLD}⌨️ SHORTCUTS${RESET}"
    echo -e "  CTRL+A                  Beginning of line"
    echo -e "  CTRL+E                  End of line"
    echo -e "  CTRL+L                  Clear screen"
    echo -e "  CTRL+C                  Cancel command"
    echo -e "  CTRL+D                  Exit/EOF"
    echo -e "  TAB                     Auto-complete"
    echo -e "  VOL DOWN + Q            Extra keys"

    echo ""
    echo -e "  ${WHITE}${BOLD}═══════════════════════════════════════════════${RESET}"

    pause_continue
    echo ""
    echo -e "  ${YELLOW}Mark Quick Cheat Sheet as complete? (y/n):${RESET} \c"
    read -r mark_choice
    if [[ "$mark_choice" == "y" || "$mark_choice" == "Y" ]]; then
        mark_lesson_complete 18 # Using 18 for Quick Cheat Sheet
    fi
    main_menu
}

# ===================== STARTUP =====================

# Check if running in Termux
check_termux() {
    if [ -d "/data/data/com.termux" ]; then
        return 0
    else
        echo -e "${YELLOW}[!] This script is designed for Termux.${RESET}"
        echo -e "${YELLOW}[!] Some features may not work on other systems.${RESET}"
        echo -e "${YELLOW}[!] Continue anyway? (y/n):${RESET} \c"
        read -r choice
        if [[ "$choice" != "y" && "$choice" != "Y" ]]; then
            exit 0
        fi
    fi
}

# Main entry point
main() {
    load_progress # Load progress at startup
    check_termux
    main_menu
}

# Run the script
main