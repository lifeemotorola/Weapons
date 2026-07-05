#!/data/data/com.termux/files/usr/bin/bash

#═══════════════════════════════════════════════════════════════
#  TERMUX ADVANCED GUI SHELL v3.0
#  A complete terminal interface replacement
#  Author: Emmanuel Suah
#  License: MIT
#═══════════════════════════════════════════════════════════════

# ──────────────── CONFIGURATION ────────────────
VERSION="3.0.0"
CONFIG_DIR="$HOME/.termux-gui"
CONFIG_FILE="$CONFIG_DIR/config.conf"
HISTORY_FILE="$CONFIG_DIR/command_history.log"
BOOKMARKS_FILE="$CONFIG_DIR/bookmarks.conf"
NOTES_FILE="$CONFIG_DIR/notes.txt"
SNIPPETS_DIR="$CONFIG_DIR/snippets"
THEME_DIR="$CONFIG_DIR/themes"
LOG_FILE="$CONFIG_DIR/session.log"
TASKS_FILE="$CONFIG_DIR/tasks.txt"
CLIPBOARD_FILE="$CONFIG_DIR/clipboard.txt"

# ──────────────── INIT DIRECTORIES ────────────────
mkdir -p "$CONFIG_DIR" "$SNIPPETS_DIR" "$THEME_DIR" 2>/dev/null
touch "$HISTORY_FILE" "$BOOKMARKS_FILE" "$NOTES_FILE" "$TASKS_FILE" "$CLIPBOARD_FILE" 2>/dev/null

# ──────────────── DEFAULT THEME ────────────────
load_default_theme() {
    # Colors
    C_RESET="\033[0m"
    C_BOLD="\033[1m"
    C_DIM="\033[2m"
    C_ITALIC="\033[3m"
    C_UNDERLINE="\033[4m"
    C_BLINK="\033[5m"
    C_REVERSE="\033[7m"

    # Foreground
    C_BLACK="\033[30m"
    C_RED="\033[31m"
    C_GREEN="\033[32m"
    C_YELLOW="\033[33m"
    C_BLUE="\033[34m"
    C_MAGENTA="\033[35m"
    C_CYAN="\033[36m"
    C_WHITE="\033[37m"

    # Bright Foreground
    C_BRED="\033[91m"
    C_BGREEN="\033[92m"
    C_BYELLOW="\033[93m"
    C_BBLUE="\033[94m"
    C_BMAGENTA="\033[95m"
    C_BCYAN="\033[96m"
    C_BWHITE="\033[97m"

    # Background
    BG_BLACK="\033[40m"
    BG_RED="\033[41m"
    BG_GREEN="\033[42m"
    BG_YELLOW="\033[43m"
    BG_BLUE="\033[44m"
    BG_MAGENTA="\033[45m"
    BG_CYAN="\033[46m"
    BG_WHITE="\033[47m"

    # Theme assignments
    T_BORDER="$C_CYAN"
    T_TITLE="$C_BOLD$C_BWHITE"
    T_HEADER="$C_BOLD$C_BCYAN"
    T_MENU_NUM="$C_BOLD$C_BYELLOW"
    T_MENU_TEXT="$C_WHITE"
    T_MENU_HIGHLIGHT="$C_BOLD$C_BGREEN"
    T_PROMPT="$C_BOLD$C_BGREEN"
    T_INPUT="$C_BWHITE"
    T_SUCCESS="$C_BOLD$C_BGREEN"
    T_ERROR="$C_BOLD$C_BRED"
    T_WARNING="$C_BOLD$C_BYELLOW"
    T_INFO="$C_BOLD$C_BCYAN"
    T_DIM="$C_DIM$C_WHITE"
    T_ACCENT="$C_BMAGENTA"
    T_SEPARATOR="$C_DIM$C_CYAN"
    T_STATUS_BAR="$BG_BLUE$C_BWHITE"
    T_ACTIVE="$C_BOLD$C_BGREEN"
    T_INACTIVE="$C_DIM$C_RED"
}

load_default_theme

# ──────────────── TERMINAL DIMENSIONS ────────────────
get_terminal_size() {
    TERM_COLS=$(tput cols 2>/dev/null || echo 80)
    TERM_ROWS=$(tput lines 2>/dev/null || echo 24)
    # Ensure minimum
    [[ $TERM_COLS -lt 40 ]] && TERM_COLS=40
    [[ $TERM_ROWS -lt 15 ]] && TERM_ROWS=15
}

# ──────────────── UTILITY FUNCTIONS ────────────────
cursor_to() { echo -ne "\033[${1};${2}H"; }
hide_cursor() { echo -ne "\033[?25l"; }
show_cursor() { echo -ne "\033[?25h"; }
save_cursor() { echo -ne "\033[s"; }
restore_cursor() { echo -ne "\033[u"; }
clear_line() { echo -ne "\033[2K"; }
clear_to_end() { echo -ne "\033[J"; }

# Center text
center_text() {
    local text="$1"
    local width="${2:-$TERM_COLS}"
    local text_len=${#text}
    local padding=$(( (width - text_len) / 2 ))
    [[ $padding -lt 0 ]] && padding=0
    printf "%*s%s" $padding "" "$text"
}

# Repeat character
repeat_char() {
    local char="$1"
    local count="$2"
    printf '%*s' "$count" '' | tr ' ' "$char"
}

# Truncate text to fit
truncate_text() {
    local text="$1"
    local max_len="$2"
    if [[ ${#text} -gt $max_len ]]; then
        echo "${text:0:$((max_len-3))}..."
    else
        echo "$text"
    fi
}

# ──────────────── BOX DRAWING ────────────────
# Unicode box characters
BOX_TL="╔" BOX_TR="╗" BOX_BL="╚" BOX_BR="╝"
BOX_H="═" BOX_V="║" BOX_LT="╠" BOX_RT="╣"
BOX_TT="╦" BOX_BT="╩" BOX_CROSS="╬"

# Single line variants
SB_TL="┌" SB_TR="┐" SB_BL="└" SB_BR="┘"
SB_H="─" SB_V="│" SB_LT="├" SB_RT="┤"

# Round variants
RB_TL="╭" RB_TR="╮" RB_BL="╰" RB_BR="╯"

draw_box() {
    local x=$1 y=$2 w=$3 h=$4
    local color="${5:-$T_BORDER}"
    local style="${6:-double}" # double, single, round

    local tl tr bl br hc vc lt rt
    case "$style" in
        double) tl=$BOX_TL; tr=$BOX_TR; bl=$BOX_BL; br=$BOX_BR; hc=$BOX_H; vc=$BOX_V; lt=$BOX_LT; rt=$BOX_RT ;;
        single) tl=$SB_TL; tr=$SB_TR; bl=$SB_BL; br=$SB_BR; hc=$SB_H; vc=$SB_V; lt=$SB_LT; rt=$SB_RT ;;
        round)  tl=$RB_TL; tr=$RB_TR; bl=$RB_BL; br=$RB_BR; hc=$SB_H; vc=$SB_V; lt=$SB_LT; rt=$SB_RT ;;
    esac

    echo -ne "$color"
    # Top border
    cursor_to $y $x
    echo -ne "${tl}$(repeat_char "$hc" $((w-2)))${tr}"
    # Sides
    for ((i=1; i<h-1; i++)); do
        cursor_to $((y+i)) $x
        echo -ne "${vc}$(printf '%*s' $((w-2)) '')${vc}"
    done
    # Bottom border
    cursor_to $((y+h-1)) $x
    echo -ne "${bl}$(repeat_char "$hc" $((w-2)))${br}"
    echo -ne "$C_RESET"
}

draw_separator() {
    local x=$1 y=$2 w=$3
    local color="${4:-$T_BORDER}"
    local style="${5:-double}"

    local lt rt hc
    case "$style" in
        double) lt=$BOX_LT; rt=$BOX_RT; hc=$BOX_H ;;
        single) lt=$SB_LT; rt=$SB_RT; hc=$SB_H ;;
        *) lt=$SB_LT; rt=$SB_RT; hc=$SB_H ;;
    esac

    echo -ne "$color"
    cursor_to $y $x
    echo -ne "${lt}$(repeat_char "$hc" $((w-2)))${rt}"
    echo -ne "$C_RESET"
}

# Write text inside box
write_in_box() {
    local x=$1 y=$2 text="$3" color="${4:-$C_RESET}" max_w="${5:-0}"
    cursor_to $y $((x+2))
    if [[ $max_w -gt 0 ]]; then
        text=$(truncate_text "$text" $((max_w-4)))
    fi
    echo -ne "${color}${text}${C_RESET}"
}

# ──────────────── PROGRESS BAR ────────────────
draw_progress_bar() {
    local x=$1 y=$2 w=$3 percent=$4
    local color="${5:-$T_ACCENT}"
    local filled=$((percent * (w-2) / 100))
    local empty=$(( (w-2) - filled ))

    cursor_to $y $x
    echo -ne "${T_DIM}[${C_RESET}"
    echo -ne "${color}$(repeat_char "█" $filled)${C_RESET}"
    echo -ne "${T_DIM}$(repeat_char "░" $empty)${C_RESET}"
    echo -ne "${T_DIM}]${C_RESET}"
    echo -ne " ${color}${percent}%%${C_RESET}"
}

# ──────────────── ANIMATED SPINNER ────────────────
spinner() {
    local pid=$1
    local msg="${2:-Loading...}"
    local frames=("⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏")
    local i=0

    hide_cursor
    while kill -0 "$pid" 2>/dev/null; do
        echo -ne "\r${T_ACCENT}${frames[$i]}${C_RESET} ${T_INFO}${msg}${C_RESET}"
        i=$(( (i+1) % ${#frames[@]} ))
        sleep 0.1
    done
    echo -ne "\r${T_SUCCESS}✓${C_RESET} ${msg}    \n"
    show_cursor
}

# ──────────────── NOTIFICATION SYSTEM ────────────────
notify() {
    local type="$1" msg="$2"
    local icon color

    case "$type" in
        success) icon="✅"; color="$T_SUCCESS" ;;
        error)   icon="❌"; color="$T_ERROR" ;;
        warning) icon="⚠️ "; color="$T_WARNING" ;;
        info)    icon="ℹ️ "; color="$T_INFO" ;;
        *)       icon="📌"; color="$T_INFO" ;;
    esac

    get_terminal_size
    local box_w=$((TERM_COLS - 4))
    local box_y=$((TERM_ROWS - 3))

    save_cursor
    cursor_to $box_y 2
    echo -ne "${color}${RB_TL}$(repeat_char "$SB_H" $((box_w-2)))${RB_TR}${C_RESET}"
    cursor_to $((box_y+1)) 2
    echo -ne "${color}${SB_V}${C_RESET} ${icon} $(truncate_text "$msg" $((box_w-8))) $(printf '%*s' $((box_w - ${#msg} - 7)) '')${color}${SB_V}${C_RESET}"
    cursor_to $((box_y+2)) 2
    echo -ne "${color}${RB_BL}$(repeat_char "$SB_H" $((box_w-2)))${RB_BR}${C_RESET}"
    restore_cursor

    # Auto dismiss after 2 seconds
    (sleep 2 && save_cursor && for i in 0 1 2; do cursor_to $((box_y+i)) 2; clear_line; done && restore_cursor) &
}

# ──────────────── DIALOG BOXES ────────────────
dialog_confirm() {
    local msg="$1"
    get_terminal_size

    local box_w=50
    [[ $box_w -gt $((TERM_COLS-4)) ]] && box_w=$((TERM_COLS-4))
    local box_h=7
    local box_x=$(( (TERM_COLS - box_w) / 2 ))
    local box_y=$(( (TERM_ROWS - box_h) / 2 ))

    draw_box $box_x $box_y $box_w $box_h "$T_WARNING" "round"
    write_in_box $box_x $((box_y+1)) "⚠️  Confirm Action" "$T_WARNING" $box_w
    cursor_to $((box_y+2)) $((box_x+1))
    echo -ne "${T_SEPARATOR}$(repeat_char "─" $((box_w-2)))${C_RESET}"
    write_in_box $box_x $((box_y+3)) "$msg" "$C_WHITE" $box_w
    write_in_box $box_x $((box_y+5)) "[Y]es  /  [N]o" "$T_MENU_HIGHLIGHT" $box_w

    while true; do
        read -rsn1 key
        case "$key" in
            y|Y) return 0 ;;
            n|N) return 1 ;;
        esac
    done
}

dialog_input() {
    local title="$1" prompt="$2" default="$3"
    get_terminal_size

    local box_w=56
    [[ $box_w -gt $((TERM_COLS-4)) ]] && box_w=$((TERM_COLS-4))
    local box_h=8
    local box_x=$(( (TERM_COLS - box_w) / 2 ))
    local box_y=$(( (TERM_ROWS - box_h) / 2 ))

    draw_box $box_x $box_y $box_w $box_h "$T_INFO" "round"
    write_in_box $box_x $((box_y+1)) "📝 $title" "$T_HEADER" $box_w
    cursor_to $((box_y+2)) $((box_x+1))
    echo -ne "${T_SEPARATOR}$(repeat_char "─" $((box_w-2)))${C_RESET}"
    write_in_box $box_x $((box_y+3)) "$prompt" "$C_WHITE" $box_w

    cursor_to $((box_y+5)) $((box_x+3))
    echo -ne "${T_DIM}▶ ${C_RESET}${T_INPUT}"
    show_cursor
    read -r DIALOG_RESULT
    DIALOG_RESULT="${DIALOG_RESULT:-$default}"
    echo -ne "$C_RESET"
    hide_cursor
}

dialog_message() {
    local title="$1" msg="$2" icon="${3:-ℹ️ }"
    get_terminal_size

    local box_w=56
    [[ $box_w -gt $((TERM_COLS-4)) ]] && box_w=$((TERM_COLS-4))

    # Split message into lines
    local -a lines=()
    while IFS= read -r line; do
        lines+=("$line")
    done <<< "$msg"

    local box_h=$(( ${#lines[@]} + 5 ))
    [[ $box_h -gt $((TERM_ROWS-4)) ]] && box_h=$((TERM_ROWS-4))
    local box_x=$(( (TERM_COLS - box_w) / 2 ))
    local box_y=$(( (TERM_ROWS - box_h) / 2 ))

    draw_box $box_x $box_y $box_w $box_h "$T_INFO" "round"
    write_in_box $box_x $((box_y+1)) "$icon $title" "$T_HEADER" $box_w
    cursor_to $((box_y+2)) $((box_x+1))
    echo -ne "${T_SEPARATOR}$(repeat_char "─" $((box_w-2)))${C_RESET}"

    local line_num=0
    for line in "${lines[@]}"; do
        [[ $((line_num + 4)) -ge $((box_h - 1)) ]] && break
        write_in_box $box_x $((box_y+3+line_num)) "$line" "$C_WHITE" $box_w
        ((line_num++))
    done

    write_in_box $box_x $((box_y+box_h-2)) "Press any key to continue..." "$T_DIM" $box_w
    read -rsn1
}

# ──────────────── STATUS BAR ────────────────
draw_status_bar() {
    get_terminal_size
    local user=$(whoami 2>/dev/null || echo "user")
    local cwd=$(pwd | sed "s|$HOME|~|")
    local time_str=$(date "+%H:%M:%S")
    local date_str=$(date "+%Y-%m-%d")
    local battery=""

    # Try to get battery info (Termux)
    if command -v termux-battery-status &>/dev/null; then
        local bat_json=$(termux-battery-status 2>/dev/null)
        if [[ -n "$bat_json" ]]; then
            local bat_pct=$(echo "$bat_json" | grep -o '"percentage":[0-9]*' | grep -o '[0-9]*')
            local bat_status=$(echo "$bat_json" | grep -o '"status":"[^"]*"' | cut -d'"' -f4)
            if [[ -n "$bat_pct" ]]; then
                local bat_icon="🔋"
                [[ "$bat_status" == "CHARGING" ]] && bat_icon="⚡"
                [[ $bat_pct -le 20 ]] && bat_icon="🪫"
                battery=" ${bat_icon}${bat_pct}%%"
            fi
        fi
    fi

    # Top status bar
    cursor_to 1 1
    echo -ne "${T_STATUS_BAR}${C_BOLD}"
    local left_status=" 🖥️  $user@termux  📂 $(truncate_text "$cwd" 30)"
    local right_status="📅 $date_str  🕐 $time_str${battery} "
    local padding=$((TERM_COLS - ${#left_status} - ${#right_status}))
    [[ $padding -lt 0 ]] && padding=0
    printf "%s%*s%s" "$left_status" $padding "" "$right_status"
    echo -ne "$C_RESET"

    # Bottom status bar
    cursor_to $TERM_ROWS 1
    echo -ne "${T_STATUS_BAR}"
    local bottom_left=" [F1]Help [F5]Refresh [Ctrl+C]Back"
    local bottom_right="Termux GUI v${VERSION} "
    padding=$((TERM_COLS - ${#bottom_left} - ${#bottom_right}))
    [[ $padding -lt 0 ]] && padding=0
    printf "%s%*s%s" "$bottom_left" $padding "" "$bottom_right"
    echo -ne "$C_RESET"
}

# ──────────────── SPLASH SCREEN ────────────────
show_splash() {
    clear
    get_terminal_size
    hide_cursor

    local logo=(
    "  ████████╗███████╗██████╗ ███╗   ███╗██╗   ██╗██╗  ██╗"
    "  ╚══██╔══╝██╔════╝██╔══██╗████╗ ████║██║   ██║╚██╗██╔╝"
    "     ██║   █████╗  ██████╔╝██╔████╔██║██║   ██║ ╚███╔╝ "
    "     ██║   ██╔══╝  ██╔══██╗██║╚██╔╝██║██║   ██║ ██╔██╗ "
    "     ██║   ███████╗██║  ██║██║ ╚═╝ ██║╚██████╔╝██╔╝ ██╗"
    "     ╚═╝   ╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝ ╚═════╝╚═╝  ╚═╝"
    )

    local subtitle="━━━ A D V A N C E D   G U I   S H E L L ━━━"
    local version_text="Version $VERSION"

    local start_y=$(( (TERM_ROWS - ${#logo[@]} - 8) / 2 ))
    [[ $start_y -lt 2 ]] && start_y=2

    # Animate logo
    for i in "${!logo[@]}"; do
        cursor_to $((start_y + i)) 1
        echo -ne "$T_ACCENT"
        center_text "${logo[$i]}" $TERM_COLS
        sleep 0.05
    done

    cursor_to $((start_y + ${#logo[@]} + 1)) 1
    echo -ne "$T_HEADER"
    center_text "$subtitle" $TERM_COLS

    cursor_to $((start_y + ${#logo[@]} + 3)) 1
    echo -ne "$T_DIM"
    center_text "$version_text" $TERM_COLS

    # Loading bar animation
    local bar_w=40
    local bar_x=$(( (TERM_COLS - bar_w - 6) / 2 ))
    local bar_y=$((start_y + ${#logo[@]} + 5))

    for ((p=0; p<=100; p+=2)); do
        draw_progress_bar $bar_x $bar_y $bar_w $p "$T_ACCENT"
        sleep 0.02
    done

    cursor_to $((bar_y + 2)) 1
    echo -ne "$T_SUCCESS"
    center_text "✓ System Ready" $TERM_COLS
    echo -ne "$C_RESET"

    sleep 0.5
    show_cursor
}

# ──────────────── MAIN DASHBOARD ────────────────
show_dashboard() {
    while true; do
        clear
        get_terminal_size
        draw_status_bar

        local content_start=3
        local content_width=$((TERM_COLS - 4))

        # Title Box
        draw_box 2 $content_start $content_width 3 "$T_ACCENT" "double"
        cursor_to $((content_start+1)) 4
        echo -ne "$T_TITLE"
        center_text "🚀 TERMUX ADVANCED GUI - MAIN DASHBOARD 🚀" $((content_width-4))
        echo -ne "$C_RESET"

        # Calculate layout
        local menu_start=$((content_start + 4))
        local left_w=$(( (content_width - 2) / 2 ))
        local right_w=$(( content_width - left_w - 2 ))
        local left_x=2
        local right_x=$((left_x + left_w + 2))
        local menu_h=20

        [[ $((menu_start + menu_h)) -gt $((TERM_ROWS - 2)) ]] && menu_h=$((TERM_ROWS - menu_start - 2))

        # Left Panel - Main Menu
        draw_box $left_x $menu_start $left_w $menu_h "$T_BORDER" "round"
        cursor_to $((menu_start+1)) $((left_x+2))
        echo -ne "${T_HEADER}📋 MAIN MENU${C_RESET}"

        cursor_to $((menu_start+2)) $((left_x+1))
        echo -ne "${T_SEPARATOR}$(repeat_char "─" $((left_w-2)))${C_RESET}"

        local -a menu_items=(
            "📦 Package Manager"
            "📂 File Manager"
            "💻 Shell & Terminal"
            "🌐 Network Tools"
            "📊 System Monitor"
            "🔧 System Settings"
            "📝 Text Editor"
            "⏰ Task Scheduler"
            "🔐 Security Tools"
            "🐍 Dev Environment"
            "📋 Clipboard Manager"
            "📌 Bookmarks"
            "🗒️  Notes & Tasks"
            "🎨 Theme Manager"
            "❓ Help & About"
            "🚪 Exit"
        )

        for i in "${!menu_items[@]}"; do
            local row=$((menu_start + 3 + i))
            [[ $row -ge $((menu_start + menu_h - 1)) ]] && break
            cursor_to $row $((left_x+3))
            printf "${T_MENU_NUM}[%2d]${C_RESET} ${T_MENU_TEXT}%s${C_RESET}" $((i+1)) "${menu_items[$i]}"
        done

        # Right Panel - System Info
        draw_box $right_x $menu_start $right_w $menu_h "$T_BORDER" "round"
        cursor_to $((menu_start+1)) $((right_x+2))
        echo -ne "${T_HEADER}📊 SYSTEM INFO${C_RESET}"

        cursor_to $((menu_start+2)) $((right_x+1))
        echo -ne "${T_SEPARATOR}$(repeat_char "─" $((right_w-2)))${C_RESET}"

        # System information
        local info_row=$((menu_start+3))
        local info_x=$((right_x+3))
        local info_w=$((right_w-6))

        # OS Info
        cursor_to $info_row $info_x
        echo -ne "${T_INFO}OS:${C_RESET} $(uname -o 2>/dev/null || echo 'Android')"
        ((info_row++))

        # Kernel
        cursor_to $info_row $info_x
        echo -ne "${T_INFO}Kernel:${C_RESET} $(uname -r 2>/dev/null | cut -d'-' -f1)"
        ((info_row++))

        # Architecture
        cursor_to $info_row $info_x
        echo -ne "${T_INFO}Arch:${C_RESET} $(uname -m 2>/dev/null)"
        ((info_row++))

        # Shell
        cursor_to $info_row $info_x
        echo -ne "${T_INFO}Shell:${C_RESET} $(basename "$SHELL")"
        ((info_row++))

        # Uptime
        cursor_to $info_row $info_x
        local uptime_str=$(uptime -p 2>/dev/null || uptime 2>/dev/null | sed 's/.*up /up /' | cut -d',' -f1)
        echo -ne "${T_INFO}Uptime:${C_RESET} $(truncate_text "$uptime_str" $info_w)"
        ((info_row++))

        # Separator
        cursor_to $info_row $((right_x+1))
        echo -ne "${T_SEPARATOR}$(repeat_char "─" $((right_w-2)))${C_RESET}"
        ((info_row++))

        # Storage
        cursor_to $info_row $info_x
        echo -ne "${T_HEADER}💾 Storage:${C_RESET}"
        ((info_row++))
        local storage_info=$(df -h "$HOME" 2>/dev/null | tail -1)
        if [[ -n "$storage_info" ]]; then
            local used=$(echo "$storage_info" | awk '{print $3}')
            local total=$(echo "$storage_info" | awk '{print $2}')
            local pct=$(echo "$storage_info" | awk '{print $5}' | tr -d '%')
            cursor_to $info_row $info_x
            echo -ne "${C_WHITE}${used}/${total}${C_RESET}"
            ((info_row++))
            if [[ -n "$pct" ]] && [[ "$pct" =~ ^[0-9]+$ ]]; then
                local bar_color="$T_SUCCESS"
                [[ $pct -gt 70 ]] && bar_color="$T_WARNING"
                [[ $pct -gt 90 ]] && bar_color="$T_ERROR"
                draw_progress_bar $info_x $info_row $((info_w > 25 ? 25 : info_w)) $pct "$bar_color"
            fi
            ((info_row++))
        fi

        # Memory
        ((info_row++))
        cursor_to $info_row $info_x
        echo -ne "${T_HEADER}🧠 Memory:${C_RESET}"
        ((info_row++))
        local mem_info=$(free -h 2>/dev/null | grep Mem)
        if [[ -n "$mem_info" ]]; then
            local mem_used=$(echo "$mem_info" | awk '{print $3}')
            local mem_total=$(echo "$mem_info" | awk '{print $2}')
            cursor_to $info_row $info_x
            echo -ne "${C_WHITE}${mem_used}/${mem_total}${C_RESET}"
            ((info_row++))
            local mem_pct=$(free 2>/dev/null | grep Mem | awk '{printf "%.0f", $3/$2*100}')
            if [[ -n "$mem_pct" ]] && [[ "$mem_pct" =~ ^[0-9]+$ ]]; then
                local mem_bar_color="$T_SUCCESS"
                [[ $mem_pct -gt 70 ]] && mem_bar_color="$T_WARNING"
                [[ $mem_pct -gt 90 ]] && mem_bar_color="$T_ERROR"
                draw_progress_bar $info_x $info_row $((info_w > 25 ? 25 : info_w)) $mem_pct "$mem_bar_color"
            fi
        fi

        # Packages count
        ((info_row += 2))
        if [[ $info_row -lt $((menu_start + menu_h - 2)) ]]; then
            cursor_to $info_row $info_x
            local pkg_count=$(dpkg -l 2>/dev/null | grep '^ii' | wc -l)
            echo -ne "${T_INFO}Packages:${C_RESET} ${pkg_count} installed"
        fi

        # Prompt
        cursor_to $((TERM_ROWS - 1)) 2
        echo -ne "${T_PROMPT}  Enter choice [1-${#menu_items[@]}]: ${C_RESET}${T_INPUT}"
        show_cursor
        read -r choice
        echo -ne "$C_RESET"
        hide_cursor

        # Log command
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] Dashboard choice: $choice" >> "$LOG_FILE"

        case "$choice" in
            1)  package_manager ;;
            2)  file_manager ;;
            3)  shell_terminal ;;
            4)  network_tools ;;
            5)  system_monitor ;;
            6)  system_settings ;;
            7)  text_editor_menu ;;
            8)  task_scheduler ;;
            9)  security_tools ;;
            10) dev_environment ;;
            11) clipboard_manager ;;
            12) bookmark_manager ;;
            13) notes_tasks ;;
            14) theme_manager ;;
            15) show_help ;;
            16) exit_gui ;;
            *)  notify "warning" "Invalid choice. Please select 1-${#menu_items[@]}" ; sleep 1 ;;
        esac
    done
}

# ══════════════════════════════════════════════════
#  MODULE: PACKAGE MANAGER
# ══════════════════════════════════════════════════
package_manager() {
    while true; do
        clear
        get_terminal_size
        draw_status_bar

        local w=$((TERM_COLS - 4))
        draw_box 2 3 $w 3 "$T_ACCENT" "double"
        write_in_box 2 4 "$(center_text "📦 PACKAGE MANAGER" $((w-4)))" "$T_TITLE" $w

        draw_box 2 7 $w 18 "$T_BORDER" "round"
        local row=8
        local items=(
            "🔄 Update Package Lists     (apt update)"
            "⬆️  Upgrade All Packages     (apt upgrade)"
            "📥 Install Package           (apt install)"
            "🗑️  Remove Package            (apt remove)"
            "🔍 Search Package            (apt search)"
            "📋 List Installed Packages"
            "ℹ️  Package Info              (apt show)"
            "🧹 Clean Package Cache       (apt clean)"
            "📦 Install from .deb File"
            "🔙 Back to Dashboard"
        )

        for i in "${!items[@]}"; do
            cursor_to $((row + i)) 5
            printf "${T_MENU_NUM}[%2d]${C_RESET} ${T_MENU_TEXT}%s${C_RESET}" $((i+1)) "${items[$i]}"
        done

        cursor_to $((TERM_ROWS - 1)) 2
        echo -ne "${T_PROMPT}  Select option: ${C_RESET}"
        show_cursor; read -r choice; hide_cursor

        case "$choice" in
            1)
                clear; echo -e "${T_INFO}🔄 Updating package lists...${C_RESET}\n"
                apt update 2>&1
                echo -e "\n${T_SUCCESS}✓ Update complete${C_RESET}"
                read -rp "Press Enter to continue..." ;;
            2)
                clear; echo -e "${T_INFO}⬆️  Upgrading packages...${C_RESET}\n"
                apt upgrade -y 2>&1
                echo -e "\n${T_SUCCESS}✓ Upgrade complete${C_RESET}"
                read -rp "Press Enter to continue..." ;;
            3)
                dialog_input "Install Package" "Enter package name:" ""
                if [[ -n "$DIALOG_RESULT" ]]; then
                    clear; echo -e "${T_INFO}📥 Installing $DIALOG_RESULT...${C_RESET}\n"
                    apt install -y "$DIALOG_RESULT" 2>&1
                    echo -e "\n${T_SUCCESS}✓ Done${C_RESET}"
                    read -rp "Press Enter to continue..."
                fi ;;
            4)
                dialog_input "Remove Package" "Enter package name:" ""
                if [[ -n "$DIALOG_RESULT" ]]; then
                    if dialog_confirm "Remove package '$DIALOG_RESULT'?"; then
                        clear; echo -e "${T_INFO}🗑️  Removing $DIALOG_RESULT...${C_RESET}\n"
                        apt remove -y "$DIALOG_RESULT" 2>&1
                        echo -e "\n${T_SUCCESS}✓ Done${C_RESET}"
                    fi
                    read -rp "Press Enter to continue..."
                fi ;;
            5)
                dialog_input "Search Package" "Enter search term:" ""
                if [[ -n "$DIALOG_RESULT" ]]; then
                    clear; echo -e "${T_INFO}🔍 Searching for '$DIALOG_RESULT'...${C_RESET}\n"
                    apt search "$DIALOG_RESULT" 2>&1 | head -40
                    echo -e "\n${T_DIM}(Showing first 40 results)${C_RESET}"
                    read -rp "Press Enter to continue..."
                fi ;;
            6)
                clear; echo -e "${T_INFO}📋 Installed Packages:${C_RESET}\n"
                dpkg -l 2>/dev/null | grep '^ii' | awk '{printf "  %-30s %s\n", $2, $3}' | less
                ;;
            7)
                dialog_input "Package Info" "Enter package name:" ""
                if [[ -n "$DIALOG_RESULT" ]]; then
                    clear; echo -e "${T_INFO}ℹ️  Package info: $DIALOG_RESULT${C_RESET}\n"
                    apt show "$DIALOG_RESULT" 2>&1
                    read -rp "Press Enter to continue..."
                fi ;;
            8)
                clear; echo -e "${T_INFO}🧹 Cleaning cache...${C_RESET}\n"
                apt clean 2>&1; apt autoclean 2>&1; apt autoremove -y 2>&1
                echo -e "\n${T_SUCCESS}✓ Cache cleaned${C_RESET}"
                read -rp "Press Enter to continue..." ;;
            9)
                dialog_input "Install .deb" "Enter path to .deb file:" ""
                if [[ -n "$DIALOG_RESULT" ]] && [[ -f "$DIALOG_RESULT" ]]; then
                    clear; dpkg -i "$DIALOG_RESULT" 2>&1
                    echo -e "\n${T_SUCCESS}✓ Done${C_RESET}"
                    read -rp "Press Enter to continue..."
                else
                    notify "error" "File not found"
                    sleep 1
                fi ;;
            10) return ;;
            *) notify "warning" "Invalid option" ; sleep 1 ;;
        esac
    done
}

# ══════════════════════════════════════════════════
#  MODULE: FILE MANAGER
# ══════════════════════════════════════════════════
file_manager() {
    local current_dir="$PWD"

    while true; do
        clear
        get_terminal_size
        draw_status_bar

        local w=$((TERM_COLS - 4))
        draw_box 2 3 $w 3 "$T_ACCENT" "double"
        write_in_box 2 4 "$(center_text "📂 FILE MANAGER" $((w-4)))" "$T_TITLE" $w

        # Path bar
        cursor_to 7 4
        echo -ne "${T_INFO}📍 Path: ${C_RESET}${T_MENU_HIGHLIGHT}$(truncate_text "$current_dir" $((w-15)))${C_RESET}"

        draw_box 2 8 $w 3 "$T_SEPARATOR" "single"
        cursor_to 9 4
        echo -ne "${T_DIM}[N]ew [D]elete [C]opy [M]ove [R]ename [P]ermissions [S]ize [V]iew [E]dit [B]ack${C_RESET}"

        # File listing area
        local list_start=12
        local list_h=$((TERM_ROWS - list_start - 2))
        draw_box 2 $((list_start-1)) $w $((list_h+2)) "$T_BORDER" "round"

        # Header
        cursor_to $list_start 4
        printf "${T_HEADER}%-4s %-10s %-8s %-12s %s${C_RESET}" "#" "PERMS" "SIZE" "DATE" "NAME"
        cursor_to $((list_start+1)) 3
        echo -ne "${T_SEPARATOR}$(repeat_char "─" $((w-4)))${C_RESET}"

        # List files
        local -a files=()
        local -a file_info=()
        local idx=0

        # Add parent directory
        files+=("..")
        cursor_to $((list_start+2)) 4
        printf "${T_MENU_NUM}[%2d]${C_RESET} ${T_DIM}%-10s %-8s %-12s${C_RESET} ${T_MENU_HIGHLIGHT}📁 ../${C_RESET}" 0 "" "" ""
        ((idx++))

        while IFS= read -r line; do
            [[ $((list_start + 2 + idx)) -ge $((list_start + list_h - 1)) ]] && break
            local fname=$(echo "$line" | awk '{print $NF}')
            local fperms=$(echo "$line" | awk '{print $1}')
            local fsize=$(echo "$line" | awk '{print $5}')
            local fdate=$(echo "$line" | awk '{print $6, $7}')

            files+=("$fname")

            cursor_to $((list_start + 2 + idx)) 4

            local ficon="📄"
            local fcolor="$C_WHITE"
            if [[ -d "$current_dir/$fname" ]]; then
                ficon="📁"
                fcolor="$T_MENU_HIGHLIGHT"
            elif [[ -x "$current_dir/$fname" ]]; then
                ficon="⚙️ "
                fcolor="$T_SUCCESS"
            elif [[ "$fname" == *.sh ]]; then
                ficon="📜"
                fcolor="$C_GREEN"
            elif [[ "$fname" == *.py ]]; then
                ficon="🐍"
                fcolor="$C_YELLOW"
            elif [[ "$fname" == *.txt || "$fname" == *.md ]]; then
                ficon="📝"
                fcolor="$C_CYAN"
            elif [[ "$fname" == *.tar.* || "$fname" == *.zip || "$fname" == *.gz ]]; then
                ficon="📦"
                fcolor="$C_MAGENTA"
            elif [[ "$fname" == *.jpg || "$fname" == *.png || "$fname" == *.gif ]]; then
                ficon="🖼️ "
                fcolor="$C_MAGENTA"
            fi

            printf "${T_MENU_NUM}[%2d]${C_RESET} ${T_DIM}%-10s %-8s %-12s${C_RESET} ${fcolor}%s %s${C_RESET}" \
                $idx "$(truncate_text "$fperms" 10)" "$(truncate_text "$fsize" 8)" \
                "$(truncate_text "$fdate" 12)" "$ficon" "$(truncate_text "$fname" $((w-48)))"
            ((idx++))
        done < <(ls -la "$current_dir" 2>/dev/null | tail -n +4)

        cursor_to $((TERM_ROWS - 1)) 2
        echo -ne "${T_PROMPT}  Command (# to open, or action key): ${C_RESET}"
        show_cursor; read -r fm_cmd; hide_cursor

        case "$fm_cmd" in
            [0-9]*)
                if [[ $fm_cmd -ge 0 && $fm_cmd -lt ${#files[@]} ]]; then
                    local selected="${files[$fm_cmd]}"
                    if [[ "$selected" == ".." ]]; then
                        current_dir=$(dirname "$current_dir")
                    elif [[ -d "$current_dir/$selected" ]]; then
                        current_dir="$current_dir/$selected"
                    elif [[ -f "$current_dir/$selected" ]]; then
                        clear
                        echo -e "${T_INFO}📄 Viewing: $selected${C_RESET}\n"
                        if file "$current_dir/$selected" | grep -q text; then
                            less "$current_dir/$selected"
                        else
                            echo "Binary file. Size: $(du -h "$current_dir/$selected" | cut -f1)"
                            file "$current_dir/$selected"
                            read -rp "Press Enter..."
                        fi
                    fi
                fi ;;
            n|N)
                dialog_input "Create New" "File or Directory name:" ""
                if [[ -n "$DIALOG_RESULT" ]]; then
                    if dialog_confirm "Create as directory?"; then
                        mkdir -p "$current_dir/$DIALOG_RESULT"
                        notify "success" "Directory created"
                    else
                        touch "$current_dir/$DIALOG_RESULT"
                        notify "success" "File created"
                    fi
                    sleep 1
                fi ;;
            d|D)
                dialog_input "Delete" "Enter file number to delete:" ""
                if [[ "$DIALOG_RESULT" =~ ^[0-9]+$ ]] && [[ $DIALOG_RESULT -lt ${#files[@]} ]]; then
                    local del_file="${files[$DIALOG_RESULT]}"
                    if dialog_confirm "Delete '$del_file'?"; then
                        rm -rf "$current_dir/$del_file"
                        notify "success" "Deleted: $del_file"
                    fi
                    sleep 1
                fi ;;
            c|C)
                dialog_input "Copy" "Enter file number to copy:" ""
                if [[ "$DIALOG_RESULT" =~ ^[0-9]+$ ]] && [[ $DIALOG_RESULT -lt ${#files[@]} ]]; then
                    local src="${files[$DIALOG_RESULT]}"
                    dialog_input "Copy Destination" "Copy '$src' to:" "$current_dir/"
                    if [[ -n "$DIALOG_RESULT" ]]; then
                        cp -r "$current_dir/$src" "$DIALOG_RESULT" 2>&1
                        notify "success" "Copied: $src"
                    fi
                    sleep 1
                fi ;;
            m|M)
                dialog_input "Move" "Enter file number to move:" ""
                if [[ "$DIALOG_RESULT" =~ ^[0-9]+$ ]] && [[ $DIALOG_RESULT -lt ${#files[@]} ]]; then
                    local src="${files[$DIALOG_RESULT]}"
                    dialog_input "Move Destination" "Move '$src' to:" "$current_dir/"
                    if [[ -n "$DIALOG_RESULT" ]]; then
                        mv "$current_dir/$src" "$DIALOG_RESULT" 2>&1
                        notify "success" "Moved: $src"
                    fi
                    sleep 1
                fi ;;
            r|R)
                dialog_input "Rename" "Enter file number to rename:" ""
                if [[ "$DIALOG_RESULT" =~ ^[0-9]+$ ]] && [[ $DIALOG_RESULT -lt ${#files[@]} ]]; then
                    local old_name="${files[$DIALOG_RESULT]}"
                    dialog_input "New Name" "Rename '$old_name' to:" "$old_name"
                    if [[ -n "$DIALOG_RESULT" ]]; then
                        mv "$current_dir/$old_name" "$current_dir/$DIALOG_RESULT" 2>&1
                        notify "success" "Renamed to: $DIALOG_RESULT"
                    fi
                    sleep 1
                fi ;;
            p|P)
                dialog_input "Permissions" "Enter file number:" ""
                if [[ "$DIALOG_RESULT" =~ ^[0-9]+$ ]] && [[ $DIALOG_RESULT -lt ${#files[@]} ]]; then
                    local pf="${files[$DIALOG_RESULT]}"
                    dialog_input "Set Permissions" "Enter chmod value (e.g. 755):" "644"
                    if [[ -n "$DIALOG_RESULT" ]]; then
                        chmod "$DIALOG_RESULT" "$current_dir/$pf" 2>&1
                        notify "success" "Permissions set"
                    fi
                    sleep 1
                fi ;;
            s|S)
                clear; echo -e "${T_INFO}📊 Directory Size:${C_RESET}\n"
                du -sh "$current_dir"/* 2>/dev/null | sort -rh | head -20
                echo -e "\n${T_DIM}Total:${C_RESET} $(du -sh "$current_dir" 2>/dev/null | cut -f1)"
                read -rp "Press Enter..." ;;
            e|E)
                dialog_input "Edit File" "Enter file number:" ""
                if [[ "$DIALOG_RESULT" =~ ^[0-9]+$ ]] && [[ $DIALOG_RESULT -lt ${#files[@]} ]]; then
                    local ef="${files[$DIALOG_RESULT]}"
                    if [[ -f "$current_dir/$ef" ]]; then
                        nano "$current_dir/$ef" 2>/dev/null || vi "$current_dir/$ef"
                    fi
                fi ;;
            v|V)
                dialog_input "View File" "Enter file number:" ""
                if [[ "$DIALOG_RESULT" =~ ^[0-9]+$ ]] && [[ $DIALOG_RESULT -lt ${#files[@]} ]]; then
                    local vf="${files[$DIALOG_RESULT]}"
                    if [[ -f "$current_dir/$vf" ]]; then
                        clear; less "$current_dir/$vf"
                    fi
                fi ;;
            b|B|q|Q) return ;;
        esac

        # Normalize path
        current_dir=$(cd "$current_dir" 2>/dev/null && pwd || echo "$current_dir")
    done
}

# ══════════════════════════════════════════════════
#  MODULE: SHELL & TERMINAL
# ══════════════════════════════════════════════════
shell_terminal() {
    while true; do
        clear
        get_terminal_size
        draw_status_bar

        local w=$((TERM_COLS - 4))
        draw_box 2 3 $w 3 "$T_ACCENT" "double"
        write_in_box 2 4 "$(center_text "💻 SHELL & TERMINAL" $((w-4)))" "$T_TITLE" $w

        draw_box 2 7 $w 16 "$T_BORDER" "round"

        local items=(
            "🖥️  Open Interactive Shell"
            "📜 Run Custom Command"
            "📂 Run Shell Script (.sh)"
            "📋 Command History"
            "📎 Saved Command Snippets"
            "💾 Save Command Snippet"
            "🔄 Run Last Command"
            "⏱️  Run Command with Timer"
            "📤 Pipe Command Output to File"
            "🔁 Watch Command (repeat)"
            "🧮 Quick Calculator"
            "🔙 Back"
        )

        for i in "${!items[@]}"; do
            cursor_to $((8 + i)) 5
            printf "${T_MENU_NUM}[%2d]${C_RESET} ${T_MENU_TEXT}%s${C_RESET}" $((i+1)) "${items[$i]}"
        done

        cursor_to $((TERM_ROWS - 1)) 2
        echo -ne "${T_PROMPT}  Select option: ${C_RESET}"
        show_cursor; read -r choice; hide_cursor

        case "$choice" in
            1)
                clear
                echo -e "${T_INFO}═══ Interactive Shell ═══${C_RESET}"
                echo -e "${T_DIM}Type 'exit' to return to GUI${C_RESET}\n"
                export PS1="\[\033[1;32m\]termux-gui\[\033[0m\]:\[\033[1;34m\]\w\[\033[0m\]\$ "
                bash --norc
                ;;
            2)
                dialog_input "Run Command" "Enter command:" ""
                if [[ -n "$DIALOG_RESULT" ]]; then
                    clear
                    echo -e "${T_INFO}▶ Running: ${C_RESET}$DIALOG_RESULT\n"
                    echo "[$(date)] $DIALOG_RESULT" >> "$HISTORY_FILE"
                    eval "$DIALOG_RESULT" 2>&1
                    echo -e "\n${T_SUCCESS}✓ Command completed (exit: $?)${C_RESET}"
                    read -rp "Press Enter..."
                fi ;;
            3)
                dialog_input "Run Script" "Enter script path:" ""
                if [[ -n "$DIALOG_RESULT" ]] && [[ -f "$DIALOG_RESULT" ]]; then
                    clear
                    echo -e "${T_INFO}▶ Running script: $DIALOG_RESULT${C_RESET}\n"
                    bash "$DIALOG_RESULT" 2>&1
                    echo -e "\n${T_SUCCESS}✓ Script completed (exit: $?)${C_RESET}"
                    read -rp "Press Enter..."
                else
                    notify "error" "Script not found"
                    sleep 1
                fi ;;
            4)
                clear
                echo -e "${T_INFO}📋 Command History:${C_RESET}\n"
                if [[ -s "$HISTORY_FILE" ]]; then
                    tail -50 "$HISTORY_FILE" | nl
                else
                    echo "No history yet."
                fi
                read -rp "Press Enter..." ;;
            5)
                clear
                echo -e "${T_INFO}📎 Saved Snippets:${C_RESET}\n"
                if ls "$SNIPPETS_DIR"/*.snip &>/dev/null; then
                    local sn=1
                    for snip in "$SNIPPETS_DIR"/*.snip; do
                        local sname=$(basename "$snip" .snip)
                        echo -e "  ${T_MENU_NUM}[$sn]${C_RESET} ${T_MENU_HIGHLIGHT}$sname${C_RESET}"
                        echo -e "      ${T_DIM}$(cat "$snip")${C_RESET}"
                        ((sn++))
                    done
                    echo ""
                    read -rp "Run snippet # (or Enter to skip): " sn_choice
                    if [[ -n "$sn_choice" ]]; then
                        local sfiles=("$SNIPPETS_DIR"/*.snip)
                        local sfile="${sfiles[$((sn_choice-1))]}"
                        if [[ -f "$sfile" ]]; then
                            local scmd=$(cat "$sfile")
                            clear
                            echo -e "${T_INFO}▶ Running: $scmd${C_RESET}\n"
                            eval "$scmd" 2>&1
                            echo -e "\n${T_SUCCESS}✓ Done${C_RESET}"
                        fi
                    fi
                else
                    echo "No snippets saved yet."
                fi
                read -rp "Press Enter..." ;;
            6)
                dialog_input "Snippet Name" "Enter name for snippet:" ""
                local sn_name="$DIALOG_RESULT"
                if [[ -n "$sn_name" ]]; then
                    dialog_input "Snippet Command" "Enter command:" ""
                    if [[ -n "$DIALOG_RESULT" ]]; then
                        echo "$DIALOG_RESULT" > "$SNIPPETS_DIR/${sn_name}.snip"
                        notify "success" "Snippet '$sn_name' saved"
                        sleep 1
                    fi
                fi ;;
            7)
                local last_cmd=$(tail -1 "$HISTORY_FILE" 2>/dev/null | sed 's/^[^]]*] //')
                if [[ -n "$last_cmd" ]]; then
                    clear
                    echo -e "${T_INFO}▶ Re-running: $last_cmd${C_RESET}\n"
                    eval "$last_cmd" 2>&1
                    echo -e "\n${T_SUCCESS}✓ Done${C_RESET}"
                else
                    echo -e "${T_WARNING}No previous command found${C_RESET}"
                fi
                read -rp "Press Enter..." ;;
            8)
                dialog_input "Timed Command" "Enter command:" ""
                if [[ -n "$DIALOG_RESULT" ]]; then
                    clear
                    echo -e "${T_INFO}⏱️  Running with timer: $DIALOG_RESULT${C_RESET}\n"
                    local start_time=$(date +%s%N)
                    eval "$DIALOG_RESULT" 2>&1
                    local end_time=$(date +%s%N)
                    local elapsed=$(( (end_time - start_time) / 1000000 ))
                    echo -e "\n${T_SUCCESS}✓ Completed in ${elapsed}ms${C_RESET}"
                    read -rp "Press Enter..."
                fi ;;
            9)
                dialog_input "Command" "Enter command:" ""
                local pipe_cmd="$DIALOG_RESULT"
                if [[ -n "$pipe_cmd" ]]; then
                    dialog_input "Output File" "Enter output file path:" "$HOME/output.txt"
                    if [[ -n "$DIALOG_RESULT" ]]; then
                        eval "$pipe_cmd" > "$DIALOG_RESULT" 2>&1
                        notify "success" "Output saved to $DIALOG_RESULT"
                        sleep 1
                    fi
                fi ;;
            10)
                dialog_input "Watch Command" "Enter command to watch:" ""
                local watch_cmd="$DIALOG_RESULT"
                if [[ -n "$watch_cmd" ]]; then
                    dialog_input "Interval" "Refresh interval (seconds):" "2"
                    local interval="${DIALOG_RESULT:-2}"
                    clear
                    echo -e "${T_DIM}Press Ctrl+C to stop watching${C_RESET}\n"
                    trap 'break' INT
                    while true; do
                        clear
                        echo -e "${T_INFO}⏱️  Every ${interval}s: $watch_cmd${C_RESET} | $(date)"
                        echo -e "$(repeat_char "─" $TERM_COLS)\n"
                        eval "$watch_cmd" 2>&1
                        sleep "$interval"
                    done
                    trap - INT
                fi ;;
            11)
                dialog_input "Calculator" "Enter expression:" ""
                if [[ -n "$DIALOG_RESULT" ]]; then
                    local result=$(echo "scale=4; $DIALOG_RESULT" | bc 2>/dev/null || echo "Error")
                    dialog_message "Result" "$DIALOG_RESULT = $result" "🧮"
                fi ;;
            12) return ;;
        esac
    done
}

# ══════════════════════════════════════════════════
#  MODULE: NETWORK TOOLS
# ══════════════════════════════════════════════════
network_tools() {
    while true; do
        clear
        get_terminal_size
        draw_status_bar

        local w=$((TERM_COLS - 4))
        draw_box 2 3 $w 3 "$T_ACCENT" "double"
        write_in_box 2 4 "$(center_text "🌐 NETWORK TOOLS" $((w-4)))" "$T_TITLE" $w

        draw_box 2 7 $w 18 "$T_BORDER" "round"

        local items=(
            "📊 Network Information (ifconfig)"
            "🏓 Ping Host"
            "🔍 DNS Lookup (nslookup)"
            "🌍 Public IP Address"
            "🔌 Port Scanner"
            "📡 WiFi Information"
            "📥 Download File (wget/curl)"
            "🔗 HTTP Request (curl)"
            "📶 Speed Test"
            "🛣️  Traceroute"
            "🔎 Whois Lookup"
            "📊 Active Connections"
            "🔙 Back"
        )

        for i in "${!items[@]}"; do
            cursor_to $((8 + i)) 5
            printf "${T_MENU_NUM}[%2d]${C_RESET} ${T_MENU_TEXT}%s${C_RESET}" $((i+1)) "${items[$i]}"
        done

        cursor_to $((TERM_ROWS - 1)) 2
        echo -ne "${T_PROMPT}  Select option: ${C_RESET}"
        show_cursor; read -r choice; hide_cursor

        case "$choice" in
            1)
                clear; echo -e "${T_INFO}📊 Network Interfaces:${C_RESET}\n"
                ifconfig 2>/dev/null || ip addr 2>/dev/null || echo "ifconfig/ip not available"
                read -rp "Press Enter..." ;;
            2)
                dialog_input "Ping" "Enter host to ping:" "google.com"
                if [[ -n "$DIALOG_RESULT" ]]; then
                    clear; echo -e "${T_INFO}🏓 Pinging $DIALOG_RESULT...${C_RESET}\n"
                    ping -c 5 "$DIALOG_RESULT" 2>&1
                    read -rp "Press Enter..."
                fi ;;
            3)
                dialog_input "DNS Lookup" "Enter domain:" "google.com"
                if [[ -n "$DIALOG_RESULT" ]]; then
                    clear; echo -e "${T_INFO}🔍 DNS Lookup: $DIALOG_RESULT${C_RESET}\n"
                    nslookup "$DIALOG_RESULT" 2>&1 || dig "$DIALOG_RESULT" 2>&1 || host "$DIALOG_RESULT" 2>&1
                    read -rp "Press Enter..."
                fi ;;
            4)
                clear; echo -e "${T_INFO}🌍 Fetching public IP...${C_RESET}\n"
                local pub_ip=$(curl -s ifconfig.me 2>/dev/null || curl -s icanhazip.com 2>/dev/null || echo "Could not determine")
                echo -e "${T_SUCCESS}Public IP: ${C_BWHITE}$pub_ip${C_RESET}"
                echo ""
                curl -s "ipinfo.io/$pub_ip" 2>/dev/null || true
                read -rp "Press Enter..." ;;
            5)
                dialog_input "Port Scanner" "Enter host:" "localhost"
                local scan_host="$DIALOG_RESULT"
                dialog_input "Port Range" "Enter port range (e.g. 1-1000):" "1-100"
                if [[ -n "$scan_host" ]] && [[ -n "$DIALOG_RESULT" ]]; then
                    clear; echo -e "${T_INFO}🔌 Scanning $scan_host ports $DIALOG_RESULT...${C_RESET}\n"
                    local start_port=$(echo "$DIALOG_RESULT" | cut -d'-' -f1)
                    local end_port=$(echo "$DIALOG_RESULT" | cut -d'-' -f2)
                    for ((port=start_port; port<=end_port; port++)); do
                        (echo >/dev/tcp/$scan_host/$port) 2>/dev/null && echo -e "${T_SUCCESS}  Port $port: OPEN${C_RESET}"
                    done
                    echo -e "\n${T_SUCCESS}✓ Scan complete${C_RESET}"
                    read -rp "Press Enter..."
                fi ;;
            6)
                clear; echo -e "${T_INFO}📡 WiFi Information:${C_RESET}\n"
                if command -v termux-wifi-connectioninfo &>/dev/null; then
                    termux-wifi-connectioninfo 2>&1
                else
                    echo "Install termux-api for WiFi info"
                    echo "Run: pkg install termux-api"
                fi
                read -rp "Press Enter..." ;;
            7)
                dialog_input "Download" "Enter URL:" ""
                if [[ -n "$DIALOG_RESULT" ]]; then
                    dialog_input "Save As" "Save filename (or Enter for default):" ""
                    clear; echo -e "${T_INFO}📥 Downloading...${C_RESET}\n"
                    if [[ -n "$DIALOG_RESULT" ]]; then
                        wget -O "$DIALOG_RESULT" "$DIALOG_RESULT" 2>&1 || curl -L -o "$DIALOG_RESULT" "$DIALOG_RESULT" 2>&1
                    else
                        wget "$DIALOG_RESULT" 2>&1 || curl -LO "$DIALOG_RESULT" 2>&1
                    fi
                    echo -e "\n${T_SUCCESS}✓ Download complete${C_RESET}"
                    read -rp "Press Enter..."
                fi ;;
            8)
                dialog_input "HTTP Request" "Enter URL:" "https://httpbin.org/get"
                if [[ -n "$DIALOG_RESULT" ]]; then
                    clear; echo -e "${T_INFO}🔗 HTTP GET: $DIALOG_RESULT${C_RESET}\n"
                    curl -sv "$DIALOG_RESULT" 2>&1 | head -80
                    read -rp "Press Enter..."
                fi ;;
            9)
                clear; echo -e "${T_INFO}📶 Speed Test (simple)...${C_RESET}\n"
                if command -v speedtest-cli &>/dev/null; then
                    speedtest-cli 2>&1
                else
                    echo "Testing download speed..."
                    local start_t=$(date +%s)
                    curl -o /dev/null -w "Downloaded: %{size_download} bytes\nSpeed: %{speed_download} bytes/sec\nTime: %{time_total}s\n" \
                        "http://speedtest.tele2.net/1MB.zip" 2>/dev/null
                    echo -e "\n${T_DIM}Install speedtest-cli for full test: pip install speedtest-cli${C_RESET}"
                fi
                read -rp "Press Enter..." ;;
            10)
                dialog_input "Traceroute" "Enter host:" "google.com"
                if [[ -n "$DIALOG_RESULT" ]]; then
                    clear; echo -e "${T_INFO}🛣️  Traceroute to $DIALOG_RESULT...${C_RESET}\n"
                    traceroute "$DIALOG_RESULT" 2>&1 || tracepath "$DIALOG_RESULT" 2>&1 || echo "traceroute not installed"
                    read -rp "Press Enter..."
                fi ;;
            11)
                dialog_input "Whois" "Enter domain:" "google.com"
                if [[ -n "$DIALOG_RESULT" ]]; then
                    clear; echo -e "${T_INFO}🔎 Whois: $DIALOG_RESULT${C_RESET}\n"
                    whois "$DIALOG_RESULT" 2>&1 | head -60
                    read -rp "Press Enter..."
                fi ;;
            12)
                clear; echo -e "${T_INFO}📊 Active Connections:${C_RESET}\n"
                netstat -tlnp 2>/dev/null || ss -tlnp 2>/dev/null || echo "netstat/ss not available"
                read -rp "Press Enter..." ;;
            13) return ;;
        esac
    done
}

# ══════════════════════════════════════════════════
#  MODULE: SYSTEM MONITOR
# ══════════════════════════════════════════════════
system_monitor() {
    while true; do
        clear
        get_terminal_size
        draw_status_bar

        local w=$((TERM_COLS - 4))
        draw_box 2 3 $w 3 "$T_ACCENT" "double"
        write_in_box 2 4 "$(center_text "📊 SYSTEM MONITOR" $((w-4)))" "$T_TITLE" $w

        local row=7

        # CPU Info
        draw_box 2 $row $w 6 "$T_BORDER" "round"
        write_in_box 2 $((row+1)) "🖥️  CPU Information" "$T_HEADER" $w
        local cpu_model=$(cat /proc/cpuinfo 2>/dev/null | grep "model name" | head -1 | cut -d':' -f2 | xargs)
        local cpu_cores=$(nproc 2>/dev/null || grep -c processor /proc/cpuinfo 2>/dev/null || echo "?")
        local load_avg=$(cat /proc/loadavg 2>/dev/null | awk '{print $1, $2, $3}')
        write_in_box 2 $((row+2)) "Model: $(truncate_text "${cpu_model:-Unknown}" $((w-12)))" "$C_WHITE" $w
        write_in_box 2 $((row+3)) "Cores: $cpu_cores  |  Load: $load_avg" "$C_WHITE" $w
        if [[ -n "$load_avg" ]]; then
            local load_1m=$(echo "$load_avg" | awk '{printf "%.0f", $1 * 100 / '"$cpu_cores"'}')
            [[ $load_1m -gt 100 ]] && load_1m=100
            draw_progress_bar 4 $((row+4)) 30 $load_1m "$T_ACCENT"
        fi

        row=$((row + 7))

        # Memory Info
        draw_box 2 $row $w 6 "$T_BORDER" "round"
        write_in_box 2 $((row+1)) "🧠 Memory Usage" "$T_HEADER" $w
        if command -v free &>/dev/null; then
            local mem_line=$(free -h | grep Mem)
            local mem_total=$(echo "$mem_line" | awk '{print $2}')
            local mem_used=$(echo "$mem_line" | awk '{print $3}')
            local mem_free=$(echo "$mem_line" | awk '{print $4}')
            local mem_pct=$(free | grep Mem | awk '{printf "%.0f", $3/$2*100}')
            write_in_box 2 $((row+2)) "Total: $mem_total  |  Used: $mem_used  |  Free: $mem_free" "$C_WHITE" $w
            local mem_color="$T_SUCCESS"
            [[ $mem_pct -gt 70 ]] && mem_color="$T_WARNING"
            [[ $mem_pct -gt 90 ]] && mem_color="$T_ERROR"
            draw_progress_bar 4 $((row+3)) 30 $mem_pct "$mem_color"

            local swap_line=$(free -h | grep Swap)
            if [[ -n "$swap_line" ]]; then
                local swap_total=$(echo "$swap_line" | awk '{print $2}')
                local swap_used=$(echo "$swap_line" | awk '{print $3}')
                write_in_box 2 $((row+4)) "Swap: $swap_used / $swap_total" "$T_DIM" $w
            fi
        fi

        row=$((row + 7))

        # Storage
        if [[ $row -lt $((TERM_ROWS - 10)) ]]; then
            draw_box 2 $row $w 6 "$T_BORDER" "round"
            write_in_box 2 $((row+1)) "💾 Storage" "$T_HEADER" $w
            local storage=$(df -h "$HOME" 2>/dev/null | tail -1)
            if [[ -n "$storage" ]]; then
                local st_total=$(echo "$storage" | awk '{print $2}')
                local st_used=$(echo "$storage" | awk '{print $3}')
                local st_free=$(echo "$storage" | awk '{print $4}')
                local st_pct=$(echo "$storage" | awk '{print $5}' | tr -d '%')
                write_in_box 2 $((row+2)) "Total: $st_total  |  Used: $st_used  |  Free: $st_free" "$C_WHITE" $w
                local st_color="$T_SUCCESS"
                [[ $st_pct -gt 70 ]] && st_color="$T_WARNING"
                [[ $st_pct -gt 90 ]] && st_color="$T_ERROR"
                draw_progress_bar 4 $((row+3)) 30 $st_pct "$st_color"
            fi
            row=$((row + 7))
        fi

        # Process info
        if [[ $row -lt $((TERM_ROWS - 5)) ]]; then
            cursor_to $row 4
            local proc_count=$(ps aux 2>/dev/null | wc -l || echo "?")
            echo -ne "${T_INFO}⚙️  Running Processes: ${C_RESET}${C_BWHITE}$proc_count${C_RESET}"
        fi

        cursor_to $((TERM_ROWS - 1)) 2
        echo -ne "${T_PROMPT}  [R]efresh [P]rocesses [T]op [B]ack: ${C_RESET}"
        show_cursor; read -rsn1 choice; hide_cursor

        case "$choice" in
            r|R) continue ;;
            p|P)
                clear; echo -e "${T_INFO}⚙️  Running Processes:${C_RESET}\n"
                ps aux 2>/dev/null | head -40 || ps 2>/dev/null
                read -rp "Press Enter..." ;;
            t|T)
                clear; top -n 1 2>/dev/null || htop 2>/dev/null || (ps aux --sort=-%mem 2>/dev/null | head -20)
                read -rp "Press Enter..." ;;
            b|B|q|Q) return ;;
        esac
    done
}

# ══════════════════════════════════════════════════
#  MODULE: SYSTEM SETTINGS
# ══════════════════════════════════════════════════
system_settings() {
    while true; do
        clear
        get_terminal_size
        draw_status_bar

        local w=$((TERM_COLS - 4))
        draw_box 2 3 $w 3 "$T_ACCENT" "double"
        write_in_box 2 4 "$(center_text "🔧 SYSTEM SETTINGS" $((w-4)))" "$T_TITLE" $w

        draw_box 2 7 $w 16 "$T_BORDER" "round"

        local items=(
            "🎨 Change Termux Color Scheme"
            "🔤 Change Font"
            "📱 Termux Properties"
            "🔑 Setup SSH Key"
            "📂 Setup Storage Access"
            "🔔 Termux API Setup"
            "📋 Edit .bashrc"
            "📋 Edit .zshrc"
            "🔄 Reload Shell Config"
            "🧹 Clear Temp Files"
            "📊 Environment Variables"
            "🔙 Back"
        )

        for i in "${!items[@]}"; do
            cursor_to $((8 + i)) 5
            printf "${T_MENU_NUM}[%2d]${C_RESET} ${T_MENU_TEXT}%s${C_RESET}" $((i+1)) "${items[$i]}"
        done

        cursor_to $((TERM_ROWS - 1)) 2
        echo -ne "${T_PROMPT}  Select option: ${C_RESET}"
        show_cursor; read -r choice; hide_cursor

        case "$choice" in
            1)
                clear; echo -e "${T_INFO}🎨 Available Color Schemes:${C_RESET}\n"
                local -a schemes=("Monokai" "Solarized-Dark" "Solarized-Light" "Dracula" "Nord" "Gruvbox" "One-Dark" "Default")
                for i in "${!schemes[@]}"; do
                    echo -e "  ${T_MENU_NUM}[$((i+1))]${C_RESET} ${schemes[$i]}"
                done
                echo ""
                read -rp "Select scheme: " sc
                if [[ -n "$sc" ]] && [[ $sc -ge 1 ]] && [[ $sc -le ${#schemes[@]} ]]; then
                    local scheme_name="${schemes[$((sc-1))]}"
                    mkdir -p "$HOME/.termux"
                    # Generate basic color schemes
                    case "$scheme_name" in
                        Dracula)
                            cat > "$HOME/.termux/colors.properties" << 'COLORS'
foreground=#F8F8F2
background=#282A36
cursor=#F8F8F2
color0=#21222C
color1=#FF5555
color2=#50FA7B
color3=#F1FA8C
color4=#BD93F9
color5=#FF79C6
color6=#8BE9FD
color7=#F8F8F2
color8=#6272A4
color9=#FF6E6E
color10=#69FF94
color11=#FFFFA5
color12=#D6ACFF
color13=#FF92DF
color14=#A4FFFF
color15=#FFFFFF
COLORS
                            ;;
                        Nord)
                            cat > "$HOME/.termux/colors.properties" << 'COLORS'
foreground=#D8DEE9
background=#2E3440
cursor=#D8DEE9
color0=#3B4252
color1=#BF616A
color2=#A3BE8C
color3=#EBCB8B
color4=#81A1C1
color5=#B48EAD
color6=#88C0D0
color7=#E5E9F0
color8=#4C566A
color9=#BF616A
color10=#A3BE8C
color11=#EBCB8B
color12=#81A1C1
color13=#B48EAD
color14=#8FBCBB
color15=#ECEFF4
COLORS
                            ;;
                        Gruvbox)
                            cat > "$HOME/.termux/colors.properties" << 'COLORS'
foreground=#EBDBB2
background=#282828
cursor=#EBDBB2
color0=#282828
color1=#CC241D
color2=#98971A
color3=#D79921
color4=#458588
color5=#B16286
color6=#689D6A
color7=#A89984
color8=#928374
color9=#FB4934
color10=#B8BB26
color11=#FABD2F
color12=#83A598
color13=#D3869B
color14=#8EC07C
color15=#EBDBB2
COLORS
                            ;;
                        Default)
                            rm -f "$HOME/.termux/colors.properties"
                            ;;
                        *)
                            echo -e "${T_WARNING}Basic scheme applied${C_RESET}"
                            ;;
                    esac
                    termux-reload-settings 2>/dev/null
                    notify "success" "Color scheme: $scheme_name applied"
                    sleep 1
                fi ;;
            2)
                clear; echo -e "${T_INFO}🔤 Font Setup:${C_RESET}\n"
                echo "Place your .ttf font file at:"
                echo "  ~/.termux/font.ttf"
                echo ""
                echo "Popular options (download manually):"
                echo "  - FiraCode Nerd Font"
                echo "  - JetBrains Mono"
                echo "  - Hack Nerd Font"
                echo "  - Source Code Pro"
                read -rp "Press Enter..." ;;
            3)
                mkdir -p "$HOME/.termux"
                local prop_file="$HOME/.termux/termux.properties"
                if [[ ! -f "$prop_file" ]]; then
                    cat > "$prop_file" << 'PROPS'
# Extra keys
extra-keys = [['ESC','/','-','HOME','UP','END','PGUP'],['TAB','CTRL','ALT','LEFT','DOWN','RIGHT','PGDN']]

# Bell
bell-character = vibrate

# Fullscreen
fullscreen = false

# Volume keys as workaround
volume-keys = volume
PROPS
                fi
                nano "$prop_file" 2>/dev/null || vi "$prop_file"
                termux-reload-settings 2>/dev/null
                ;;
            4)
                clear; echo -e "${T_INFO}🔑 SSH Key Setup:${C_RESET}\n"
                if [[ -f "$HOME/.ssh/id_rsa.pub" ]]; then
                    echo "Existing key found:"
                    cat "$HOME/.ssh/id_rsa.pub"
                else
                    echo "Generating new SSH key..."
                    ssh-keygen -t rsa -b 4096 -f "$HOME/.ssh/id_rsa" -N ""
                    echo -e "\n${T_SUCCESS}✓ Key generated${C_RESET}"
                    echo -e "\nPublic key:"
                    cat "$HOME/.ssh/id_rsa.pub"
                fi
                read -rp "Press Enter..." ;;
            5)
                clear; echo -e "${T_INFO}📂 Setting up storage access...${C_RESET}\n"
                termux-setup-storage 2>&1 || echo "Run: termux-setup-storage"
                read -rp "Press Enter..." ;;
            6)
                clear; echo -e "${T_INFO}🔔 Termux API Setup:${C_RESET}\n"
                echo "Installing termux-api package..."
                apt install -y termux-api 2>&1
                echo -e "\n${T_WARNING}Also install the Termux:API app from F-Droid${C_RESET}"
                read -rp "Press Enter..." ;;
            7)
                nano "$HOME/.bashrc" 2>/dev/null || vi "$HOME/.bashrc" ;;
            8)
                [[ -f "$HOME/.zshrc" ]] && { nano "$HOME/.zshrc" 2>/dev/null || vi "$HOME/.zshrc"; } || echo "No .zshrc found"
                read -rp "Press Enter..." ;;
            9)
                source "$HOME/.bashrc" 2>/dev/null
                notify "success" "Shell config reloaded"
                sleep 1 ;;
            10)
                clear; echo -e "${T_INFO}🧹 Cleaning...${C_RESET}\n"
                apt clean 2>/dev/null; apt autoclean 2>/dev/null
                rm -rf "$PREFIX/tmp/"* 2>/dev/null
                echo -e "${T_SUCCESS}✓ Cleaned${C_RESET}"
                read -rp "Press Enter..." ;;
            11)
                clear; echo -e "${T_INFO}📊 Environment Variables:${C_RESET}\n"
                env | sort | less ;;
            12) return ;;
        esac
    done
}

# ══════════════════════════════════════════════════
#  MODULE: TEXT EDITOR
# ══════════════════════════════════════════════════
text_editor_menu() {
    while true; do
        clear
        get_terminal_size
        draw_status_bar

        local w=$((TERM_COLS - 4))
        draw_box 2 3 $w 3 "$T_ACCENT" "double"
        write_in_box 2 4 "$(center_text "📝 TEXT EDITOR" $((w-4)))" "$T_TITLE" $w

        draw_box 2 7 $w 12 "$T_BORDER" "round"

        local items=(
            "📝 Open file in Nano"
            "📝 Open file in Vi/Vim"
            "📄 Create new file"
            "🔍 Find text in files"
            "🔄 Replace text in file"
            "📊 Word/Line count"
            "📋 View file head/tail"
            "🔙 Back"
        )

        for i in "${!items[@]}"; do
            cursor_to $((8 + i)) 5
            printf "${T_MENU_NUM}[%2d]${C_RESET} ${T_MENU_TEXT}%s${C_RESET}" $((i+1)) "${items[$i]}"
        done

        cursor_to $((TERM_ROWS - 1)) 2
        echo -ne "${T_PROMPT}  Select option: ${C_RESET}"
        show_cursor; read -r choice; hide_cursor

        case "$choice" in
            1)
                dialog_input "Open in Nano" "Enter file path:" ""
                [[ -n "$DIALOG_RESULT" ]] && nano "$DIALOG_RESULT" 2>/dev/null ;;
            2)
                dialog_input "Open in Vi" "Enter file path:" ""
                [[ -n "$DIALOG_RESULT" ]] && vi "$DIALOG_RESULT" ;;
            3)
                dialog_input "Create File" "Enter new file path:" ""
                if [[ -n "$DIALOG_RESULT" ]]; then
                    touch "$DIALOG_RESULT"
                    nano "$DIALOG_RESULT" 2>/dev/null || vi "$DIALOG_RESULT"
                fi ;;
            4)
                dialog_input "Find Text" "Search string:" ""
                local search_str="$DIALOG_RESULT"
                dialog_input "Search In" "Directory:" "."
                if [[ -n "$search_str" ]]; then
                    clear; echo -e "${T_INFO}🔍 Searching for '$search_str'...${C_RESET}\n"
                    grep -rn --color=always "$search_str" "$DIALOG_RESULT" 2>/dev/null | head -50
                    read -rp "Press Enter..."
                fi ;;
            5)
                dialog_input "Replace" "File path:" ""
                local rfile="$DIALOG_RESULT"
                dialog_input "Find" "Text to find:" ""
                local rfind="$DIALOG_RESULT"
                dialog_input "Replace" "Replace with:" ""
                if [[ -n "$rfile" ]] && [[ -n "$rfind" ]]; then
                    sed -i "s/$rfind/$DIALOG_RESULT/g" "$rfile" 2>&1
                    notify "success" "Replacement done"
                    sleep 1
                fi ;;
            6)
                dialog_input "Word Count" "Enter file path:" ""
                if [[ -n "$DIALOG_RESULT" ]] && [[ -f "$DIALOG_RESULT" ]]; then
                    clear; echo -e "${T_INFO}📊 File Statistics: $DIALOG_RESULT${C_RESET}\n"
                    echo -e "  Lines:      $(wc -l < "$DIALOG_RESULT")"
                    echo -e "  Words:      $(wc -w < "$DIALOG_RESULT")"
                    echo -e "  Characters: $(wc -c < "$DIALOG_RESULT")"
                    echo -e "  Size:       $(du -h "$DIALOG_RESULT" | cut -f1)"
                    read -rp "Press Enter..."
                fi ;;
            7)
                dialog_input "View File" "Enter file path:" ""
                if [[ -n "$DIALOG_RESULT" ]] && [[ -f "$DIALOG_RESULT" ]]; then
                    clear
                    echo -e "${T_INFO}═══ HEAD (first 20 lines) ═══${C_RESET}\n"
                    head -20 "$DIALOG_RESULT"
                    echo -e "\n${T_INFO}═══ TAIL (last 20 lines) ═══${C_RESET}\n"
                    tail -20 "$DIALOG_RESULT"
                    read -rp "Press Enter..."
                fi ;;
            8) return ;;
        esac
    done
}

# ══════════════════════════════════════════════════
#  MODULE: TASK SCHEDULER
# ══════════════════════════════════════════════════
task_scheduler() {
    while true; do
        clear
        get_terminal_size
        draw_status_bar

        local w=$((TERM_COLS - 4))
        draw_box 2 3 $w 3 "$T_ACCENT" "double"
        write_in_box 2 4 "$(center_text "⏰ TASK SCHEDULER" $((w-4)))" "$T_TITLE" $w

        draw_box 2 7 $w 12 "$T_BORDER" "round"

        local items=(
            "📋 View Scheduled Tasks (crontab)"
            "➕ Add New Cron Job"
            "📝 Edit Crontab"
            "🗑️  Clear All Cron Jobs"
            "▶️  Run Command After Delay"
            "🔄 Run Command at Specific Time"
            "📊 View Running Background Jobs"
            "🔙 Back"
        )

        for i in "${!items[@]}"; do
            cursor_to $((8 + i)) 5
            printf "${T_MENU_NUM}[%2d]${C_RESET} ${T_MENU_TEXT}%s${C_RESET}" $((i+1)) "${items[$i]}"
        done

        cursor_to $((TERM_ROWS - 1)) 2
        echo -ne "${T_PROMPT}  Select option: ${C_RESET}"
        show_cursor; read -r choice; hide_cursor

        case "$choice" in
            1)
                clear; echo -e "${T_INFO}📋 Current Crontab:${C_RESET}\n"
                crontab -l 2>/dev/null || echo "No crontab found. Install cronie: pkg install cronie"
                read -rp "Press Enter..." ;;
            2)
                dialog_input "Cron Schedule" "Enter cron schedule (e.g. */5 * * * *):" "*/5 * * * *"
                local cron_sched="$DIALOG_RESULT"
                dialog_input "Command" "Enter command to run:" ""
                if [[ -n "$DIALOG_RESULT" ]]; then
                    (crontab -l 2>/dev/null; echo "$cron_sched $DIALOG_RESULT") | crontab -
                    notify "success" "Cron job added"
                    sleep 1
                fi ;;
            3) crontab -e 2>/dev/null || echo "crontab not available"; read -rp "Press Enter..." ;;
            4)
                if dialog_confirm "Clear ALL cron jobs?"; then
                    crontab -r 2>/dev/null
                    notify "success" "All cron jobs cleared"
                    sleep 1
                fi ;;
            5)
                dialog_input "Delay" "Delay in seconds:" "60"
                local delay="$DIALOG_RESULT"
                dialog_input "Command" "Command to run:" ""
                if [[ -n "$DIALOG_RESULT" ]]; then
                    (sleep "$delay" && eval "$DIALOG_RESULT") &
                    notify "success" "Task scheduled in ${delay}s (PID: $!)"
                    sleep 1
                fi ;;
            6)
                dialog_input "Time" "Run at (HH:MM):" "$(date -d '+1 hour' +%H:%M 2>/dev/null || echo '12:00')"
                local run_time="$DIALOG_RESULT"
                dialog_input "Command" "Command to run:" ""
                if [[ -n "$DIALOG_RESULT" ]]; then
                    echo "$DIALOG_RESULT" | at "$run_time" 2>/dev/null || \
                        echo "at command not available. Install: pkg install at"
                    read -rp "Press Enter..."
                fi ;;
            7)
                clear; echo -e "${T_INFO}📊 Background Jobs:${C_RESET}\n"
                jobs -l 2>/dev/null
                echo ""
                ps aux 2>/dev/null | head -20
                read -rp "Press Enter..." ;;
            8) return ;;
        esac
    done
}

# ══════════════════════════════════════════════════
#  MODULE: SECURITY TOOLS
# ══════════════════════════════════════════════════
security_tools() {
    while true; do
        clear
        get_terminal_size
        draw_status_bar

        local w=$((TERM_COLS - 4))
        draw_box 2 3 $w 3 "$T_ACCENT" "double"
        write_in_box 2 4 "$(center_text "🔐 SECURITY TOOLS" $((w-4)))" "$T_TITLE" $w

        draw_box 2 7 $w 14 "$T_BORDER" "round"

        local items=(
            "🔑 Generate Random Password"
            "🔒 Hash Generator (MD5/SHA)"
            "📝 Base64 Encode/Decode"
            "🔐 File Encryption (GPG)"
            "🔍 Check File Integrity"
            "🛡️  File Permission Auditor"
            "📊 SSL Certificate Check"
            "🔏 Generate SSH Keypair"
            "📋 View Auth Logs"
            "🔙 Back"
        )

        for i in "${!items[@]}"; do
            cursor_to $((8 + i)) 5
            printf "${T_MENU_NUM}[%2d]${C_RESET} ${T_MENU_TEXT}%s${C_RESET}" $((i+1)) "${items[$i]}"
        done

        cursor_to $((TERM_ROWS - 1)) 2
        echo -ne "${T_PROMPT}  Select option: ${C_RESET}"
        show_cursor; read -r choice; hide_cursor

        case "$choice" in
            1)
                clear; echo -e "${T_INFO}🔑 Random Passwords:${C_RESET}\n"
                for len in 8 12 16 24 32; do
                    local pw=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9!@#$%^&*()_+' | head -c $len)
                    echo -e "  ${T_MENU_NUM}${len} chars:${C_RESET}  $pw"
                done
                echo -e "\n  ${T_MENU_NUM}Passphrase:${C_RESET}  $(cat /dev/urandom | tr -dc 'a-z' | fold -w 5 | head -4 | tr '\n' '-' | sed 's/-$//')"
                read -rp "Press Enter..." ;;
            2)
                dialog_input "Hash Input" "Enter text to hash:" ""
                if [[ -n "$DIALOG_RESULT" ]]; then
                    clear; echo -e "${T_INFO}🔒 Hash Results:${C_RESET}\n"
                    echo -e "  ${T_MENU_NUM}MD5:${C_RESET}    $(echo -n "$DIALOG_RESULT" | md5sum | cut -d' ' -f1)"
                    echo -e "  ${T_MENU_NUM}SHA1:${C_RESET}   $(echo -n "$DIALOG_RESULT" | sha1sum | cut -d' ' -f1)"
                    echo -e "  ${T_MENU_NUM}SHA256:${C_RESET} $(echo -n "$DIALOG_RESULT" | sha256sum | cut -d' ' -f1)"
                    echo -e "  ${T_MENU_NUM}SHA512:${C_RESET} $(echo -n "$DIALOG_RESULT" | sha512sum | cut -d' ' -f1)"
                    read -rp "Press Enter..."
                fi ;;
            3)
                clear; echo -e "${T_INFO}📝 Base64:${C_RESET}\n"
                echo -e "  ${T_MENU_NUM}[1]${C_RESET} Encode"
                echo -e "  ${T_MENU_NUM}[2]${C_RESET} Decode"
                read -rp "  Choice: " b64c
                dialog_input "Input" "Enter text:" ""
                if [[ -n "$DIALOG_RESULT" ]]; then
                    if [[ "$b64c" == "1" ]]; then
                        echo -e "\n  Result: $(echo -n "$DIALOG_RESULT" | base64)"
                    else
                        echo -e "\n  Result: $(echo -n "$DIALOG_RESULT" | base64 -d 2>/dev/null)"
                    fi
                fi
                read -rp "Press Enter..." ;;
            4)
                clear; echo -e "${T_INFO}🔐 GPG File Encryption:${C_RESET}\n"
                echo -e "  ${T_MENU_NUM}[1]${C_RESET} Encrypt file"
                echo -e "  ${T_MENU_NUM}[2]${C_RESET} Decrypt file"
                read -rp "  Choice: " gpgc
                dialog_input "File" "Enter file path:" ""
                if [[ -n "$DIALOG_RESULT" ]]; then
                    if [[ "$gpgc" == "1" ]]; then
                        gpg -c "$DIALOG_RESULT" 2>&1
                    else
                        gpg -d "$DIALOG_RESULT" 2>&1
                    fi
                fi
                read -rp "Press Enter..." ;;
            5)
                dialog_input "File Integrity" "Enter file path:" ""
                if [[ -n "$DIALOG_RESULT" ]] && [[ -f "$DIALOG_RESULT" ]]; then
                    clear; echo -e "${T_INFO}🔍 File: $DIALOG_RESULT${C_RESET}\n"
                    echo -e "  ${T_MENU_NUM}Size:${C_RESET}   $(du -h "$DIALOG_RESULT" | cut -f1)"
                    echo -e "  ${T_MENU_NUM}Type:${C_RESET}   $(file "$DIALOG_RESULT" | cut -d: -f2)"
                    echo -e "  ${T_MENU_NUM}MD5:${C_RESET}    $(md5sum "$DIALOG_RESULT" | cut -d' ' -f1)"
                    echo -e "  ${T_MENU_NUM}SHA256:${C_RESET} $(sha256sum "$DIALOG_RESULT" | cut -d' ' -f1)"
                    read -rp "Press Enter..."
                fi ;;
            6)
                clear; echo -e "${T_INFO}🛡️  Permission Audit (current directory):${C_RESET}\n"
                echo -e "${T_WARNING}World-writable files:${C_RESET}"
                find . -perm -o+w -type f 2>/dev/null | head -20
                echo -e "\n${T_WARNING}SUID files:${C_RESET}"
                find . -perm -4000 -type f 2>/dev/null | head -20
                echo -e "\n${T_WARNING}SGID files:${C_RESET}"
                find . -perm -2000 -type f 2>/dev/null | head -20
                read -rp "Press Enter..." ;;
            7)
                dialog_input "SSL Check" "Enter domain:" "google.com"
                if [[ -n "$DIALOG_RESULT" ]]; then
                    clear; echo -e "${T_INFO}📊 SSL Certificate: $DIALOG_RESULT${C_RESET}\n"
                    echo | openssl s_client -connect "$DIALOG_RESULT:443" -servername "$DIALOG_RESULT" 2>/dev/null | openssl x509 -noout -text 2>/dev/null | head -30
                    read -rp "Press Enter..."
                fi ;;
            8)
                dialog_input "SSH Key Type" "Type (rsa/ed25519):" "ed25519"
                if [[ -n "$DIALOG_RESULT" ]]; then
                    ssh-keygen -t "$DIALOG_RESULT" -f "$HOME/.ssh/id_$DIALOG_RESULT" 2>&1
                    read -rp "Press Enter..."
                fi ;;
            9)
                clear; echo -e "${T_INFO}📋 Recent Auth:${C_RESET}\n"
                last 2>/dev/null | head -20 || echo "Auth logs not available on Termux"
                read -rp "Press Enter..." ;;
            10) return ;;
        esac
    done
}

# ══════════════════════════════════════════════════
#  MODULE: DEV ENVIRONMENT
# ══════════════════════════════════════════════════
dev_environment() {
    while true; do
        clear
        get_terminal_size
        draw_status_bar

        local w=$((TERM_COLS - 4))
        draw_box 2 3 $w 3 "$T_ACCENT" "double"
        write_in_box 2 4 "$(center_text "🐍 DEVELOPMENT ENVIRONMENT" $((w-4)))" "$T_TITLE" $w

        draw_box 2 7 $w 18 "$T_BORDER" "round"

        local items=(
            "🐍 Python Setup & Run"
            "📦 Node.js Setup & Run"
            "☕ Java Setup"
            "🔧 C/C++ Compile & Run"
            "💎 Ruby Setup"
            "🐹 Go Setup"
            "🦀 Rust Setup"
            "📦 Git Manager"
            "🗄️  Database Tools (SQLite/MariaDB)"
            "🐳 Docker-like (proot)"
            "📱 Android Dev Tools"
            "🔧 Install Dev Toolchain"
            "📊 Language Version Check"
            "🔙 Back"
        )

        for i in "${!items[@]}"; do
            cursor_to $((8 + i)) 5
            printf "${T_MENU_NUM}[%2d]${C_RESET} ${T_MENU_TEXT}%s${C_RESET}" $((i+1)) "${items[$i]}"
        done

        cursor_to $((TERM_ROWS - 1)) 2
        echo -ne "${T_PROMPT}  Select option: ${C_RESET}"
        show_cursor; read -r choice; hide_cursor

        case "$choice" in
            1)
                clear; echo -e "${T_INFO}🐍 Python:${C_RESET}\n"
                echo -e "  ${T_MENU_NUM}[1]${C_RESET} Install Python"
                echo -e "  ${T_MENU_NUM}[2]${C_RESET} Run Python script"
                echo -e "  ${T_MENU_NUM}[3]${C_RESET} Python REPL"
                echo -e "  ${T_MENU_NUM}[4]${C_RESET} Install pip package"
                echo -e "  ${T_MENU_NUM}[5]${C_RESET} List pip packages"
                read -rp "  Choice: " pyc
                case "$pyc" in
                    1) apt install -y python 2>&1 ;;
                    2) dialog_input "Script" "Python script path:" ""; [[ -n "$DIALOG_RESULT" ]] && python "$DIALOG_RESULT" ;;
                    3) python 2>/dev/null || python3 2>/dev/null ;;
                    4) dialog_input "Package" "pip package name:" ""; [[ -n "$DIALOG_RESULT" ]] && pip install "$DIALOG_RESULT" ;;
                    5) pip list 2>/dev/null ;;
                esac
                read -rp "Press Enter..." ;;
            2)
                clear; echo -e "${T_INFO}📦 Node.js:${C_RESET}\n"
                echo -e "  ${T_MENU_NUM}[1]${C_RESET} Install Node.js"
                echo -e "  ${T_MENU_NUM}[2]${C_RESET} Run JS file"
                echo -e "  ${T_MENU_NUM}[3]${C_RESET} Node REPL"
                echo -e "  ${T_MENU_NUM}[4]${C_RESET} npm install package"
                echo -e "  ${T_MENU_NUM}[5]${C_RESET} npm global packages"
                read -rp "  Choice: " ndc
                case "$ndc" in
                    1) apt install -y nodejs 2>&1 ;;
                    2) dialog_input "File" "JS file path:" ""; [[ -n "$DIALOG_RESULT" ]] && node "$DIALOG_RESULT" ;;
                    3) node ;;
                    4) dialog_input "Package" "npm package:" ""; [[ -n "$DIALOG_RESULT" ]] && npm install -g "$DIALOG_RESULT" ;;
                    5) npm list -g --depth=0 2>/dev/null ;;
                esac
                read -rp "Press Enter..." ;;
            3)
                clear; echo -e "${T_INFO}☕ Java Setup:${C_RESET}\n"
                echo "Installing Java (ecj + dx)..."
                apt install -y ecj dx 2>&1
                echo -e "\n${T_DIM}Alternatively: pkg install openjdk-17${C_RESET}"
                read -rp "Press Enter..." ;;
            4)
                clear; echo -e "${T_INFO}🔧 C/C++:${C_RESET}\n"
                echo -e "  ${T_MENU_NUM}[1]${C_RESET} Install clang"
                echo -e "  ${T_MENU_NUM}[2]${C_RESET} Compile C file"
                echo -e "  ${T_MENU_NUM}[3]${C_RESET} Compile C++ file"
                read -rp "  Choice: " cc
                case "$cc" in
                    1) apt install -y clang 2>&1 ;;
                    2)
                        dialog_input "C File" "Enter .c file:" ""
                        if [[ -n "$DIALOG_RESULT" ]]; then
                            local out="${DIALOG_RESULT%.c}"
                            clang "$DIALOG_RESULT" -o "$out" 2>&1 && echo -e "${T_SUCCESS}✓ Compiled: $out${C_RESET}" && "./$out"
                        fi ;;
                    3)
                        dialog_input "C++ File" "Enter .cpp file:" ""
                        if [[ -n "$DIALOG_RESULT" ]]; then
                            local out="${DIALOG_RESULT%.cpp}"
                            clang++ "$DIALOG_RESULT" -o "$out" 2>&1 && echo -e "${T_SUCCESS}✓ Compiled: $out${C_RESET}" && "./$out"
                        fi ;;
                esac
                read -rp "Press Enter..." ;;
            5) apt install -y ruby 2>&1; read -rp "Press Enter..." ;;
            6) apt install -y golang 2>&1; read -rp "Press Enter..." ;;
            7) apt install -y rust 2>&1; read -rp "Press Enter..." ;;
            8)
                while true; do
                    clear; echo -e "${T_INFO}📦 Git Manager:${C_RESET}\n"
                    echo -e "  ${T_MENU_NUM}[1]${C_RESET} Git status"
                    echo -e "  ${T_MENU_NUM}[2]${C_RESET} Git log"
                    echo -e "  ${T_MENU_NUM}[3]${C_RESET} Git clone"
                    echo -e "  ${T_MENU_NUM}[4]${C_RESET} Git add & commit"
                    echo -e "  ${T_MENU_NUM}[5]${C_RESET} Git push"
                    echo -e "  ${T_MENU_NUM}[6]${C_RESET} Git pull"
                    echo -e "  ${T_MENU_NUM}[7]${C_RESET} Git branch"
                    echo -e "  ${T_MENU_NUM}[8]${C_RESET} Git diff"
                    echo -e "  ${T_MENU_NUM}[9]${C_RESET} Git config"
                    echo -e "  ${T_MENU_NUM}[0]${C_RESET} Back"
                    read -rp "  Choice: " gc
                    case "$gc" in
                        1) git status 2>&1 ;;
                        2) git log --oneline -20 2>&1 ;;
                        3) dialog_input "Clone" "Repo URL:" ""; [[ -n "$DIALOG_RESULT" ]] && git clone "$DIALOG_RESULT" 2>&1 ;;
                        4)
                            git add -A 2>&1
                            dialog_input "Commit" "Commit message:" "Update"
                            git commit -m "$DIALOG_RESULT" 2>&1 ;;
                        5) git push 2>&1 ;;
                        6) git pull 2>&1 ;;
                        7) git branch -a 2>&1 ;;
                        8) git diff 2>&1 | less ;;
                        9)
                            dialog_input "Git Name" "Your name:" ""
                            [[ -n "$DIALOG_RESULT" ]] && git config --global user.name "$DIALOG_RESULT"
                            dialog_input "Git Email" "Your email:" ""
                            [[ -n "$DIALOG_RESULT" ]] && git config --global user.email "$DIALOG_RESULT"
                            echo -e "${T_SUCCESS}✓ Git configured${C_RESET}" ;;
                        0) break ;;
                    esac
                    read -rp "Press Enter..."
                done ;;
            9)
                clear; echo -e "${T_INFO}🗄️  Database Tools:${C_RESET}\n"
                echo -e "  ${T_MENU_NUM}[1]${C_RESET} Install SQLite"
                echo -e "  ${T_MENU_NUM}[2]${C_RESET} Open SQLite DB"
                echo -e "  ${T_MENU_NUM}[3]${C_RESET} Install MariaDB"
                echo -e "  ${T_MENU_NUM}[4]${C_RESET} Start MariaDB"
                read -rp "  Choice: " dbc
                case "$dbc" in
                    1) apt install -y sqlite 2>&1 ;;
                    2) dialog_input "DB File" "Enter .db file:" ""; [[ -n "$DIALOG_RESULT" ]] && sqlite3 "$DIALOG_RESULT" ;;
                    3) apt install -y mariadb 2>&1 ;;
                    4) mysqld_safe & 2>/dev/null; echo "MariaDB starting..." ;;
                esac
                read -rp "Press Enter..." ;;
            10)
                clear; echo -e "${T_INFO}🐳 Linux Environments (proot):${C_RESET}\n"
                echo -e "  ${T_MENU_NUM}[1]${C_RESET} Install proot-distro"
                echo -e "  ${T_MENU_NUM}[2]${C_RESET} List available distros"
                echo -e "  ${T_MENU_NUM}[3]${C_RESET} Install a distro"
                echo -e "  ${T_MENU_NUM}[4]${C_RESET} Login to distro"
                read -rp "  Choice: " prc
                case "$prc" in
                    1) apt install -y proot-distro 2>&1 ;;
                    2) proot-distro list 2>&1 ;;
                    3) dialog_input "Distro" "Enter distro name:" "ubuntu"; proot-distro install "$DIALOG_RESULT" 2>&1 ;;
                    4) dialog_input "Distro" "Enter distro name:" "ubuntu"; proot-distro login "$DIALOG_RESULT" ;;
                esac
                read -rp "Press Enter..." ;;
            11)
                clear; echo -e "${T_INFO}📱 Android Dev:${C_RESET}\n"
                echo "Installing ADB & build tools..."
                apt install -y android-tools aapt apksigner dx ecj 2>&1
                read -rp "Press Enter..." ;;
            12)
                clear; echo -e "${T_INFO}🔧 Installing full dev toolchain...${C_RESET}\n"
                apt install -y git python nodejs clang make cmake gdb valgrind curl wget openssh 2>&1
                echo -e "\n${T_SUCCESS}✓ Dev toolchain installed${C_RESET}"
                read -rp "Press Enter..." ;;
            13)
                clear; echo -e "${T_INFO}📊 Installed Language Versions:${C_RESET}\n"
                echo -ne "  Python:  "; python --version 2>/dev/null || python3 --version 2>/dev/null || echo "Not installed"
                echo -ne "  Node.js: "; node --version 2>/dev/null || echo "Not installed"
                echo -ne "  npm:     "; npm --version 2>/dev/null || echo "Not installed"
                echo -ne "  Ruby:    "; ruby --version 2>/dev/null || echo "Not installed"
                echo -ne "  Go:      "; go version 2>/dev/null || echo "Not installed"
                echo -ne "  Rust:    "; rustc --version 2>/dev/null || echo "Not installed"
                echo -ne "  Clang:   "; clang --version 2>/dev/null | head -1 || echo "Not installed"
                echo -ne "  Git:     "; git --version 2>/dev/null || echo "Not installed"
                echo -ne "  Java:    "; java -version 2>&1 | head -1 || echo "Not installed"
                echo -ne "  PHP:     "; php --version 2>/dev/null | head -1 || echo "Not installed"
                echo -ne "  Perl:    "; perl --version 2>/dev/null | head -2 | tail -1 || echo "Not installed"
                read -rp "Press Enter..." ;;
            14) return ;;
        esac
    done
}

# ══════════════════════════════════════════════════
#  MODULE: CLIPBOARD MANAGER
# ══════════════════════════════════════════════════
clipboard_manager() {
    while true; do
        clear
        get_terminal_size
        draw_status_bar

        local w=$((TERM_COLS - 4))
        draw_box 2 3 $w 3 "$T_ACCENT" "double"
        write_in_box 2 4 "$(center_text "📋 CLIPBOARD MANAGER" $((w-4)))" "$T_TITLE" $w

        draw_box 2 7 $w 12 "$T_BORDER" "round"

        local items=(
            "📋 View Clipboard"
            "📝 Add to Clipboard"
            "📄 Copy File Contents"
            "📤 Export Clipboard to File"
            "🧹 Clear Clipboard"
            "📊 Clipboard History"
            "🔙 Back"
        )

        for i in "${!items[@]}"; do
            cursor_to $((8 + i)) 5
            printf "${T_MENU_NUM}[%2d]${C_RESET} ${T_MENU_TEXT}%s${C_RESET}" $((i+1)) "${items[$i]}"
        done

        cursor_to $((TERM_ROWS - 1)) 2
        echo -ne "${T_PROMPT}  Select option: ${C_RESET}"
        show_cursor; read -r choice; hide_cursor

        case "$choice" in
            1)
                clear; echo -e "${T_INFO}📋 Current Clipboard:${C_RESET}\n"
                if [[ -s "$CLIPBOARD_FILE" ]]; then
                    cat "$CLIPBOARD_FILE"
                else
                    echo "Clipboard is empty"
                fi
                echo ""
                # Try termux clipboard too
                if command -v termux-clipboard-get &>/dev/null; then
                    echo -e "\n${T_INFO}📱 System Clipboard:${C_RESET}"
                    termux-clipboard-get 2>/dev/null
                fi
                read -rp "Press Enter..." ;;
            2)
                dialog_input "Clipboard" "Enter text to copy:" ""
                if [[ -n "$DIALOG_RESULT" ]]; then
                    echo "$DIALOG_RESULT" >> "$CLIPBOARD_FILE"
                    # Also copy to system clipboard if available
                    echo -n "$DIALOG_RESULT" | termux-clipboard-set 2>/dev/null
                    notify "success" "Copied to clipboard"
                    sleep 1
                fi ;;
            3)
                dialog_input "Copy File" "Enter file path:" ""
                if [[ -n "$DIALOG_RESULT" ]] && [[ -f "$DIALOG_RESULT" ]]; then
                    cat "$DIALOG_RESULT" >> "$CLIPBOARD_FILE"
                    cat "$DIALOG_RESULT" | termux-clipboard-set 2>/dev/null
                    notify "success" "File contents copied"
                    sleep 1
                fi ;;
            4)
                dialog_input "Export" "Export to file:" "$HOME/clipboard_export.txt"
                if [[ -n "$DIALOG_RESULT" ]]; then
                    cp "$CLIPBOARD_FILE" "$DIALOG_RESULT"
                    notify "success" "Exported to $DIALOG_RESULT"
                    sleep 1
                fi ;;
            5)
                > "$CLIPBOARD_FILE"
                notify "success" "Clipboard cleared"
                sleep 1 ;;
            6)
                clear; echo -e "${T_INFO}📊 Clipboard History:${C_RESET}\n"
                if [[ -s "$CLIPBOARD_FILE" ]]; then
                    nl "$CLIPBOARD_FILE"
                else
                    echo "No history"
                fi
                read -rp "Press Enter..." ;;
            7) return ;;
        esac
    done
}

# ══════════════════════════════════════════════════
#  MODULE: BOOKMARK MANAGER
# ══════════════════════════════════════════════════
bookmark_manager() {
    while true; do
        clear
        get_terminal_size
        draw_status_bar

        local w=$((TERM_COLS - 4))
        draw_box 2 3 $w 3 "$T_ACCENT" "double"
        write_in_box 2 4 "$(center_text "📌 BOOKMARKS" $((w-4)))" "$T_TITLE" $w

        draw_box 2 7 $w 10 "$T_BORDER" "round"

        echo -ne "$C_RESET"
        local items=(
            "📋 View Bookmarks"
            "➕ Add Bookmark (directory)"
            "🚀 Go to Bookmark"
            "🗑️  Remove Bookmark"
            "🔙 Back"
        )

        for i in "${!items[@]}"; do
            cursor_to $((8 + i)) 5
            printf "${T_MENU_NUM}[%2d]${C_RESET} ${T_MENU_TEXT}%s${C_RESET}" $((i+1)) "${items[$i]}"
        done

        cursor_to $((TERM_ROWS - 1)) 2
        echo -ne "${T_PROMPT}  Select option: ${C_RESET}"
        show_cursor; read -r choice; hide_cursor

        case "$choice" in
            1)
                clear; echo -e "${T_INFO}📌 Saved Bookmarks:${C_RESET}\n"
                if [[ -s "$BOOKMARKS_FILE" ]]; then
                    local bn=1
                    while IFS='|' read -r name path; do
                        echo -e "  ${T_MENU_NUM}[$bn]${C_RESET} ${T_MENU_HIGHLIGHT}$name${C_RESET}  →  ${T_DIM}$path${C_RESET}"
                        ((bn++))
                    done < "$BOOKMARKS_FILE"
                else
                    echo "No bookmarks saved yet."
                fi
                read -rp "Press Enter..." ;;
            2)
                dialog_input "Bookmark Name" "Enter name:" ""
                local bname="$DIALOG_RESULT"
                dialog_input "Path" "Enter path:" "$PWD"
                if [[ -n "$bname" ]] && [[ -n "$DIALOG_RESULT" ]]; then
                    echo "${bname}|${DIALOG_RESULT}" >> "$BOOKMARKS_FILE"
                    notify "success" "Bookmark '$bname' saved"
                    sleep 1
                fi ;;
            3)
                if [[ -s "$BOOKMARKS_FILE" ]]; then
                    clear; echo -e "${T_INFO}📌 Select Bookmark:${C_RESET}\n"
                    local bn=1
                    while IFS='|' read -r name path; do
                        echo -e "  ${T_MENU_NUM}[$bn]${C_RESET} $name  →  $path"
                        ((bn++))
                    done < "$BOOKMARKS_FILE"
                    echo ""; read -rp "  Enter #: " bsel
                    if [[ "$bsel" =~ ^[0-9]+$ ]]; then
                        local bpath=$(sed -n "${bsel}p" "$BOOKMARKS_FILE" | cut -d'|' -f2)
                        if [[ -d "$bpath" ]]; then
                            cd "$bpath"
                            notify "success" "Changed to: $bpath"
                        else
                            notify "error" "Path not found: $bpath"
                        fi
                        sleep 1
                    fi
                fi ;;
            4)
                if [[ -s "$BOOKMARKS_FILE" ]]; then
                    clear; echo -e "${T_INFO}📌 Remove Bookmark:${C_RESET}\n"
                    local bn=1
                    while IFS='|' read -r name path; do
                        echo -e "  ${T_MENU_NUM}[$bn]${C_RESET} $name  →  $path"
                        ((bn++))
                    done < "$BOOKMARKS_FILE"
                    echo ""; read -rp "  Delete #: " bdel
                    if [[ "$bdel" =~ ^[0-9]+$ ]]; then
                        sed -i "${bdel}d" "$BOOKMARKS_FILE"
                        notify "success" "Bookmark removed"
                    fi
                    sleep 1
                fi ;;
            5) return ;;
        esac
    done
}

# ══════════════════════════════════════════════════
#  MODULE: NOTES & TASKS
# ══════════════════════════════════════════════════
notes_tasks() {
    while true; do
        clear
        get_terminal_size
        draw_status_bar

        local w=$((TERM_COLS - 4))
        draw_box 2 3 $w 3 "$T_ACCENT" "double"
        write_in_box 2 4 "$(center_text "🗒️  NOTES & TASKS" $((w-4)))" "$T_TITLE" $w

        draw_box 2 7 $w 14 "$T_BORDER" "round"

        local items=(
            "📋 View Notes"
            "➕ Add Note"
            "🗑️  Delete Note"
            "────────────────"
            "☑️  View Tasks"
            "➕ Add Task"
            "✅ Complete Task"
            "🗑️  Delete Task"
            "────────────────"
            "🔙 Back"
        )

        for i in "${!items[@]}"; do
            cursor_to $((8 + i)) 5
            if [[ "${items[$i]}" == "────────────────" ]]; then
                echo -ne "${T_SEPARATOR}   ────────────────${C_RESET}"
            else
                printf "${T_MENU_NUM}[%2d]${C_RESET} ${T_MENU_TEXT}%s${C_RESET}" $((i+1)) "${items[$i]}"
            fi
        done

        cursor_to $((TERM_ROWS - 1)) 2
        echo -ne "${T_PROMPT}  Select option: ${C_RESET}"
        show_cursor; read -r choice; hide_cursor

        case "$choice" in
            1)
                clear; echo -e "${T_INFO}📋 Notes:${C_RESET}\n"
                if [[ -s "$NOTES_FILE" ]]; then
                    local nn=1
                    while IFS='|' read -r date note; do
                        echo -e "  ${T_MENU_NUM}[$nn]${C_RESET} ${T_DIM}[$date]${C_RESET} $note"
                        ((nn++))
                    done < "$NOTES_FILE"
                else
                    echo "No notes yet."
                fi
                read -rp "Press Enter..." ;;
            2)
                dialog_input "New Note" "Enter your note:" ""
                if [[ -n "$DIALOG_RESULT" ]]; then
                    echo "$(date '+%Y-%m-%d %H:%M')|$DIALOG_RESULT" >> "$NOTES_FILE"
                    notify "success" "Note saved"
                    sleep 1
                fi ;;
            3)
                dialog_input "Delete Note" "Enter note # to delete:" ""
                if [[ "$DIALOG_RESULT" =~ ^[0-9]+$ ]]; then
                    sed -i "${DIALOG_RESULT}d" "$NOTES_FILE"
                    notify "success" "Note deleted"
                    sleep 1
                fi ;;
            5)
                clear; echo -e "${T_INFO}☑️  Tasks:${C_RESET}\n"
                if [[ -s "$TASKS_FILE" ]]; then
                    local tn=1
                    while IFS='|' read -r status task; do
                        local icon="⬜"
                        local tc="$C_WHITE"
                        if [[ "$status" == "done" ]]; then
                            icon="✅"
                            tc="$T_DIM"
                        fi
                        echo -e "  ${T_MENU_NUM}[$tn]${C_RESET} $icon ${tc}$task${C_RESET}"
                        ((tn++))
                    done < "$TASKS_FILE"
                else
                    echo "No tasks yet."
                fi
                read -rp "Press Enter..." ;;
            6)
                dialog_input "New Task" "Enter task:" ""
                if [[ -n "$DIALOG_RESULT" ]]; then
                    echo "todo|$DIALOG_RESULT" >> "$TASKS_FILE"
                    notify "success" "Task added"
                    sleep 1
                fi ;;
            7)
                dialog_input "Complete Task" "Enter task #:" ""
                if [[ "$DIALOG_RESULT" =~ ^[0-9]+$ ]]; then
                    sed -i "${DIALOG_RESULT}s/^todo/done/" "$TASKS_FILE"
                    notify "success" "Task completed! ✅"
                    sleep 1
                fi ;;
            8)
                dialog_input "Delete Task" "Enter task # to delete:" ""
                if [[ "$DIALOG_RESULT" =~ ^[0-9]+$ ]]; then
                    sed -i "${DIALOG_RESULT}d" "$TASKS_FILE"
                    notify "success" "Task deleted"
                    sleep 1
                fi ;;
            10) return ;;
        esac
    done
}

# ══════════════════════════════════════════════════
#  MODULE: THEME MANAGER
# ══════════════════════════════════════════════════
theme_manager() {
    while true; do
        clear
        get_terminal_size
        draw_status_bar

        local w=$((TERM_COLS - 4))
        draw_box 2 3 $w 3 "$T_ACCENT" "double"
        write_in_box 2 4 "$(center_text "🎨 THEME MANAGER" $((w-4)))" "$T_TITLE" $w

        draw_box 2 7 $w 14 "$T_BORDER" "round"

        local items=(
            "🌊 Ocean Blue (Default)"
            "🌲 Forest Green"
            "🌅 Sunset Orange"
            "🍇 Purple Haze"
            "❄️  Arctic White"
            "🔥 Lava Red"
            "🌙 Midnight"
            "🎨 Preview All Colors"
            "🔙 Back"
        )

        for i in "${!items[@]}"; do
            cursor_to $((8 + i)) 5
            printf "${T_MENU_NUM}[%2d]${C_RESET} ${T_MENU_TEXT}%s${C_RESET}" $((i+1)) "${items[$i]}"
        done

        cursor_to $((TERM_ROWS - 1)) 2
        echo -ne "${T_PROMPT}  Select option: ${C_RESET}"
        show_cursor; read -r choice; hide_cursor

        case "$choice" in
            1) # Default Ocean Blue
                load_default_theme
                notify "success" "Theme: Ocean Blue applied" ; sleep 1 ;;
            2) # Forest Green
                T_BORDER="$C_GREEN"; T_ACCENT="$C_BGREEN"
                T_HEADER="$C_BOLD$C_BGREEN"; T_MENU_HIGHLIGHT="$C_BOLD$C_BGREEN"
                T_PROMPT="$C_BOLD$C_GREEN"; T_STATUS_BAR="$BG_GREEN$C_BWHITE"
                notify "success" "Theme: Forest Green applied" ; sleep 1 ;;
            3) # Sunset Orange
                T_BORDER="$C_YELLOW"; T_ACCENT="$C_BYELLOW"
                T_HEADER="$C_BOLD$C_BYELLOW"; T_MENU_HIGHLIGHT="$C_BOLD$C_BYELLOW"
                T_PROMPT="$C_BOLD$C_YELLOW"; T_STATUS_BAR="$BG_YELLOW$C_BLACK"
                notify "success" "Theme: Sunset Orange applied" ; sleep 1 ;;
            4) # Purple Haze
                T_BORDER="$C_MAGENTA"; T_ACCENT="$C_BMAGENTA"
                T_HEADER="$C_BOLD$C_BMAGENTA"; T_MENU_HIGHLIGHT="$C_BOLD$C_BMAGENTA"
                T_PROMPT="$C_BOLD$C_MAGENTA"; T_STATUS_BAR="$BG_MAGENTA$C_BWHITE"
                notify "success" "Theme: Purple Haze applied" ; sleep 1 ;;
            5) # Arctic White
                T_BORDER="$C_BWHITE"; T_ACCENT="$C_BCYAN"
                T_HEADER="$C_BOLD$C_BWHITE"; T_MENU_HIGHLIGHT="$C_BOLD$C_BCYAN"
                T_PROMPT="$C_BOLD$C_BWHITE"; T_STATUS_BAR="$BG_WHITE$C_BLACK"
                notify "success" "Theme: Arctic White applied" ; sleep 1 ;;
            6) # Lava Red
                T_BORDER="$C_RED"; T_ACCENT="$C_BRED"
                T_HEADER="$C_BOLD$C_BRED"; T_MENU_HIGHLIGHT="$C_BOLD$C_BRED"
                T_PROMPT="$C_BOLD$C_RED"; T_STATUS_BAR="$BG_RED$C_BWHITE"
                notify "success" "Theme: Lava Red applied" ; sleep 1 ;;
            7) # Midnight
                T_BORDER="$C_BLUE"; T_ACCENT="$C_BBLUE"
                T_HEADER="$C_BOLD$C_BBLUE"; T_MENU_HIGHLIGHT="$C_BOLD$C_BCYAN"
                T_PROMPT="$C_BOLD$C_BBLUE"; T_STATUS_BAR="$BG_BLACK$C_BBLUE"
                notify "success" "Theme: Midnight applied" ; sleep 1 ;;
            8)
                clear; echo -e "${T_INFO}🎨 Color Preview:${C_RESET}\n"
                echo -e "  ${C_BLACK}██${C_RESET} Black     ${C_RED}██${C_RESET} Red       ${C_GREEN}██${C_RESET} Green     ${C_YELLOW}██${C_RESET} Yellow"
                echo -e "  ${C_BLUE}██${C_RESET} Blue      ${C_MAGENTA}██${C_RESET} Magenta   ${C_CYAN}██${C_RESET} Cyan      ${C_WHITE}██${C_RESET} White"
                echo -e ""
                echo -e "  ${C_BRED}██${C_RESET} B-Red     ${C_BGREEN}██${C_RESET} B-Green   ${C_BYELLOW}██${C_RESET} B-Yellow  ${C_BBLUE}██${C_RESET} B-Blue"
                echo -e "  ${C_BMAGENTA}██${C_RESET} B-Magenta ${C_BCYAN}██${C_RESET} B-Cyan    ${C_BWHITE}██${C_RESET} B-White"
                echo -e ""
                echo -e "  ${BG_RED}  ${C_RESET} BG-Red    ${BG_GREEN}  ${C_RESET} BG-Green  ${BG_BLUE}  ${C_RESET} BG-Blue   ${BG_YELLOW}  ${C_RESET} BG-Yellow"
                echo -e "  ${BG_MAGENTA}  ${C_RESET} BG-Mag    ${BG_CYAN}  ${C_RESET} BG-Cyan   ${BG_WHITE}  ${C_RESET} BG-White"
                echo -e ""
                echo -e "  ${C_BOLD}Bold${C_RESET}  ${C_DIM}Dim${C_RESET}  ${C_ITALIC}Italic${C_RESET}  ${C_UNDERLINE}Underline${C_RESET}  ${C_REVERSE}Reverse${C_RESET}"
                echo -e ""
                echo -e "  Box Drawing: ╔═╗ ┌─┐ ╭─╮"
                echo -e "               ║ ║ │ │ │ │"
                echo -e "               ╚═╝ └─┘ ╰─╯"
                read -rp "Press Enter..." ;;
            9) return ;;
        esac
    done
}

# ══════════════════════════════════════════════════
#  MODULE: HELP & ABOUT
# ══════════════════════════════════════════════════
show_help() {
    clear
    get_terminal_size
    draw_status_bar

    local w=$((TERM_COLS - 4))
    draw_box 2 3 $w 3 "$T_ACCENT" "double"
    write_in_box 2 4 "$(center_text "❓ HELP & ABOUT" $((w-4)))" "$T_TITLE" $w

    local help_text="
  TERMUX ADVANCED GUI SHELL v${VERSION}
  ═══════════════════════════════════

  A comprehensive terminal interface replacement for Termux
  providing an intuitive, menu-driven experience.

  FEATURES:
  ─────────
  📦 Package Manager    - Install, update, remove packages
  📂 File Manager       - Browse, copy, move, edit files
  💻 Shell & Terminal   - Run commands, scripts, snippets
  🌐 Network Tools     - Ping, DNS, ports, downloads
  📊 System Monitor    - CPU, RAM, storage monitoring
  🔧 System Settings   - Termux customization
  📝 Text Editor       - File editing utilities
  ⏰ Task Scheduler    - Cron jobs, delayed tasks
  🔐 Security Tools    - Passwords, hashes, encryption
  🐍 Dev Environment   - Multi-language development
  📋 Clipboard         - Copy/paste management
  📌 Bookmarks         - Directory shortcuts
  🗒️  Notes & Tasks    - Personal productivity
  🎨 Themes           - UI customization

  KEYBOARD SHORTCUTS:
  ───────────────────
  Ctrl+C  - Go back / Cancel
  Numbers - Select menu items
  Letters - Quick actions in some menus

  CONFIG DIRECTORY: ~/.termux-gui/

  AUTHOR: Emmanuel Suah
  LICENSE: MIT"

    echo -e "$help_text" | less
}

# ══════════════════════════════════════════════════
#  EXIT FUNCTION
# ══════════════════════════════════════════════════
exit_gui() {
    clear
    get_terminal_size

    local msg=(
        ""
        "  ╔═══════════════════════════════════════╗"
        "  ║                                       ║"
        "  ║   👋 Thanks for using Workspace!      ║"
        "  ║                                       ║"
        "  ║   Session logged to:                  ║"
        "  ║   ~/.Workspace/session.log            ║"
        "  ║                                       ║"
        "  ║   Run again: bash Workspace.sh        ║"
        "  ║                                       ║"
        "  ╚═══════════════════════════════════════╝"
        ""
    )

    local start_y=$(( (TERM_ROWS - ${#msg[@]}) / 2 ))
    for i in "${!msg[@]}"; do
        cursor_to $((start_y + i)) 1
        echo -ne "$T_ACCENT"
        center_text "${msg[$i]}" $TERM_COLS
    done
    echo -ne "$C_RESET"

    cursor_to $((start_y + ${#msg[@]} + 1)) 1

    show_cursor
    echo ""
    exit 0
}

# ══════════════════════════════════════════════════
#  SIGNAL HANDLERS
# ══════════════════════════════════════════════════
cleanup() {
    show_cursor
    echo -ne "$C_RESET"
    clear
}

trap cleanup EXIT
trap 'echo ""' INT

# ══════════════════════════════════════════════════
#  MAIN ENTRY POINT
# ══════════════════════════════════════════════════
main() {
    # Check if running in Termux or compatible terminal
    if [[ -z "$TERM" ]]; then
        export TERM=xterm-256color
    fi

    # Parse arguments
    case "${1:-}" in
        --no-splash|-n)
            show_dashboard
            ;;
        --help|-h)
            echo "Termux Advanced GUI Shell v${VERSION}"
            echo ""
            echo "Usage: bash termux-gui.sh [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --no-splash, -n    Skip splash screen"
            echo "  --help, -h         Show this help"
            echo "  --version, -v      Show version"
            echo "  --reset            Reset all configuration"
            ;;
        --version|-v)
            echo "Termux GUI v${VERSION}"
            ;;
        --reset)
            if dialog_confirm "Reset all GUI configuration?"; then
                rm -rf "$CONFIG_DIR"
                mkdir -p "$CONFIG_DIR" "$SNIPPETS_DIR" "$THEME_DIR"
                echo "Configuration reset."
            fi
            ;;
        *)
            show_splash
            show_dashboard
            ;;
    esac
}

# Run
main "$@"
