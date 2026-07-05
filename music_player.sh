#!/data/data/com.termux/files/usr/bin/bash

# ============================================================
#  ♫ ADVANCED TERMUX MUSIC PLAYER v2.0
#  Features: Library scan, playlists, queue, search, equalizer,
#            shuffle, repeat, favorites, album art, visualizer
# ============================================================

# ──────────────────────────────────────────────
# CONFIGURATION
# ──────────────────────────────────────────────
MUSIC_DIRS=(
    "$HOME/storage/music"
    "$HOME/storage/shared/Music"
    "$HOME/storage/shared/Download"
    "$HOME/storage/shared/Downloads"
    "$HOME/storage/external-1/Music"
    "$HOME/storage/shared/DCIM"
    "$HOME/storage/shared"
)
SUPPORTED_FORMATS="mp3|flac|wav|ogg|m4a|aac|wma|opus|aiff|ape|alac"
CACHE_DIR="$HOME/.music_player"
LIBRARY_FILE="$CACHE_DIR/library.txt"
PLAYLIST_DIR="$CACHE_DIR/playlists"
FAVORITES_FILE="$CACHE_DIR/favorites.txt"
HISTORY_FILE="$CACHE_DIR/history.txt"
CONFIG_FILE="$CACHE_DIR/config.txt"
QUEUE_FILE="$CACHE_DIR/queue.txt"
NOW_PLAYING_FILE="$CACHE_DIR/now_playing.txt"
MPV_SOCKET="/data/data/com.termux/files/usr/tmp/mpv-socket"

# Player state
CURRENT_TRACK=""
CURRENT_INDEX=0
SHUFFLE=0
REPEAT=0  # 0=off, 1=all, 2=one
VOLUME=100
IS_PLAYING=0
IS_PAUSED=0
EQUALIZER="none"
SLEEP_TIMER=0
SLEEP_PID=0

# Colors
R='\033[0;31m'
G='\033[0;32m'
Y='\033[0;33m'
B='\033[0;34m'
M='\033[0;35m'
C='\033[0;36m'
W='\033[1;37m'
D='\033[0;37m'
BOLD='\033[1m'
DIM='\033[2m'
BLINK='\033[5m'
NC='\033[0m'
BG_B='\033[44m'
BG_M='\033[45m'
BG_G='\033[42m'
BG_R='\033[41m'
BG_D='\033[100m'

# ──────────────────────────────────────────────
# INITIALIZATION
# ──────────────────────────────────────────────
init() {
    mkdir -p "$CACHE_DIR" "$PLAYLIST_DIR"
    touch "$FAVORITES_FILE" "$HISTORY_FILE" "$QUEUE_FILE"
    
    # Load config
    if [[ -f "$CONFIG_FILE" ]]; then
        source "$CONFIG_FILE"
    fi
    
    # Clean up any existing mpv instances
    cleanup_mpv
    
    # Check dependencies
    for cmd in mpv find grep sed; do
        if ! command -v "$cmd" &>/dev/null; then
            echo -e "${R}[✗] Missing: $cmd. Run setup_music_player.sh first.${NC}"
            exit 1
        fi
    done
}

save_config() {
    cat > "$CONFIG_FILE" << EOF
VOLUME=$VOLUME
SHUFFLE=$SHUFFLE
REPEAT=$REPEAT
EQUALIZER="$EQUALIZER"
EOF
}

cleanup_mpv() {
    pkill -f "mpv.*input-ipc-server" 2>/dev/null
    rm -f "$MPV_SOCKET"
}

cleanup() {
    cleanup_mpv
    [[ $SLEEP_PID -ne 0 ]] && kill $SLEEP_PID 2>/dev/null
    save_config
    tput cnorm  # Show cursor
    echo -e "\n${G}♫ Thanks for listening! Goodbye.${NC}"
    exit 0
}

trap cleanup EXIT INT TERM

# ──────────────────────────────────────────────
# LIBRARY MANAGEMENT
# ──────────────────────────────────────────────
scan_library() {
    local count=0
    echo -e "${C}${BOLD}♫ Scanning for music files...${NC}"
    echo -e "${DIM}  This may take a moment on first run.${NC}\n"
    
    > "$LIBRARY_FILE"
    
    for dir in "${MUSIC_DIRS[@]}"; do
        if [[ -d "$dir" ]]; then
            echo -e "  ${Y}→${NC} Scanning: ${DIM}$dir${NC}"
            find "$dir" -type f -regextype posix-extended \
                -iregex ".*\.($SUPPORTED_FORMATS)$" \
                2>/dev/null >> "$LIBRARY_FILE"
        fi
    done
    
    # Remove duplicates and empty lines
    sort -u "$LIBRARY_FILE" -o "$LIBRARY_FILE"
    sed -i '/^$/d' "$LIBRARY_FILE"
    
    count=$(wc -l < "$LIBRARY_FILE" 2>/dev/null || echo "0")
    echo -e "\n  ${G}✓ Found ${W}${BOLD}$count${NC}${G} tracks${NC}\n"
    
    if [[ $count -eq 0 ]]; then
        echo -e "  ${Y}⚠ No music files found!${NC}"
        echo -e "  ${DIM}Make sure you've granted storage permission.${NC}"
        echo -e "  ${DIM}Run: termux-setup-storage${NC}\n"
        read -rp "  Press Enter to continue..."
    fi
    
    sleep 1
}

get_track_count() {
    wc -l < "$LIBRARY_FILE" 2>/dev/null || echo "0"
}

get_track_by_index() {
    sed -n "${1}p" "$LIBRARY_FILE"
}

get_filename() {
    basename "$1" | sed 's/\.[^.]*$//'
}

get_extension() {
    echo "${1##*.}" | tr '[:lower:]' '[:upper:]'
}

get_directory() {
    dirname "$1" | sed "s|$HOME/storage/shared/||" | sed "s|$HOME/storage/||"
}

get_file_size() {
    local size
    size=$(stat -c%s "$1" 2>/dev/null || echo "0")
    if [[ $size -ge 1048576 ]]; then
        echo "$(echo "scale=1; $size/1048576" | bc) MB"
    elif [[ $size -ge 1024 ]]; then
        echo "$(echo "scale=0; $size/1024" | bc) KB"
    else
        echo "${size} B"
    fi
}

# ──────────────────────────────────────────────
# MPV CONTROL (IPC)
# ──────────────────────────────────────────────
mpv_command() {
    if [[ -S "$MPV_SOCKET" ]]; then
        echo "$1" | socat - "$MPV_SOCKET" 2>/dev/null
    fi
}

mpv_get_property() {
    if [[ -S "$MPV_SOCKET" ]]; then
        local result
        result=$(echo "{ \"command\": [\"get_property\", \"$1\"] }" | \
            socat - "$MPV_SOCKET" 2>/dev/null)
        echo "$result" | grep -o '"data":[^,}]*' | sed 's/"data"://'
    fi
}

mpv_set_property() {
    if [[ -S "$MPV_SOCKET" ]]; then
        echo "{ \"command\": [\"set_property\", \"$1\", $2] }" | \
            socat - "$MPV_SOCKET" 2>/dev/null
    fi
}

get_current_position() {
    local pos
    pos=$(mpv_get_property "time-pos" 2>/dev/null)
    if [[ -n "$pos" && "$pos" != "null" ]]; then
        printf "%.0f" "$pos" 2>/dev/null || echo "0"
    else
        echo "0"
    fi
}

get_duration() {
    local dur
    dur=$(mpv_get_property "duration" 2>/dev/null)
    if [[ -n "$dur" && "$dur" != "null" ]]; then
        printf "%.0f" "$dur" 2>/dev/null || echo "0"
    else
        echo "0"
    fi
}

is_mpv_running() {
    [[ -S "$MPV_SOCKET" ]] && kill -0 $(cat "$CACHE_DIR/mpv_pid" 2>/dev/null) 2>/dev/null
}

format_time() {
    local total_seconds=$1
    if [[ -z "$total_seconds" || "$total_seconds" == "0" ]]; then
        echo "00:00"
        return
    fi
    local minutes=$((total_seconds / 60))
    local seconds=$((total_seconds % 60))
    printf "%02d:%02d" "$minutes" "$seconds"
}

# ──────────────────────────────────────────────
# PLAYBACK ENGINE
# ──────────────────────────────────────────────
play_track() {
    local track="$1"
    
    if [[ ! -f "$track" ]]; then
        echo -e "${R}  ✗ File not found: $track${NC}"
        return 1
    fi
    
    # Stop current playback
    cleanup_mpv
    sleep 0.3
    
    # Build mpv command with equalizer
    local eq_filter=""
    case "$EQUALIZER" in
        "bass")    eq_filter="--af=equalizer=1=6:2=5:3=4:4=2" ;;
        "treble")  eq_filter="--af=equalizer=8=5:9=6:10=5" ;;
        "vocal")   eq_filter="--af=equalizer=4=4:5=5:6=4" ;;
        "rock")    eq_filter="--af=equalizer=1=5:2=4:5=3:8=4:9=5" ;;
        "pop")     eq_filter="--af=equalizer=3=3:4=4:5=3:7=3" ;;
        "jazz")    eq_filter="--af=equalizer=1=3:4=4:5=3:8=4" ;;
        "classical") eq_filter="--af=equalizer=1=4:5=3:8=5:9=4:10=3" ;;
    esac
    
    # Start mpv with IPC
    mpv --no-video --no-terminal \
        --input-ipc-server="$MPV_SOCKET" \
        --volume="$VOLUME" \
        $eq_filter \
        "$track" &>/dev/null &
    
    echo $! > "$CACHE_DIR/mpv_pid"
    
    CURRENT_TRACK="$track"
    IS_PLAYING=1
    IS_PAUSED=0
    
    # Save to now playing and history
    echo "$track" > "$NOW_PLAYING_FILE"
    echo "$(date '+%Y-%m-%d %H:%M') | $(get_filename "$track")" >> "$HISTORY_FILE"
    
    # Keep history manageable
    tail -500 "$HISTORY_FILE" > "$HISTORY_FILE.tmp"
    mv "$HISTORY_FILE.tmp" "$HISTORY_FILE"
    
    sleep 0.5
}

toggle_pause() {
    if is_mpv_running; then
        mpv_command '{ "command": ["cycle", "pause"] }'
        if [[ $IS_PAUSED -eq 0 ]]; then
            IS_PAUSED=1
        else
            IS_PAUSED=0
        fi
    fi
}

stop_playback() {
    cleanup_mpv
    IS_PLAYING=0
    IS_PAUSED=0
    CURRENT_TRACK=""
}

seek_forward() {
    if is_mpv_running; then
        mpv_command '{ "command": ["seek", "10"] }'
    fi
}

seek_backward() {
    if is_mpv_running; then
        mpv_command '{ "command": ["seek", "-10"] }'
    fi
}

volume_up() {
    VOLUME=$((VOLUME + 5))
    [[ $VOLUME -gt 150 ]] && VOLUME=150
    if is_mpv_running; then
        mpv_set_property "volume" "$VOLUME"
    fi
    save_config
}

volume_down() {
    VOLUME=$((VOLUME - 5))
    [[ $VOLUME -lt 0 ]] && VOLUME=0
    if is_mpv_running; then
        mpv_set_property "volume" "$VOLUME"
    fi
    save_config
}

# ──────────────────────────────────────────────
# QUEUE MANAGEMENT
# ──────────────────────────────────────────────
load_queue_from_library() {
    cp "$LIBRARY_FILE" "$QUEUE_FILE"
    if [[ $SHUFFLE -eq 1 ]]; then
        shuffle_queue
    fi
}

shuffle_queue() {
    if [[ -f "$QUEUE_FILE" ]]; then
        sort -R "$QUEUE_FILE" -o "$QUEUE_FILE"
        CURRENT_INDEX=1
    fi
}

get_queue_length() {
    wc -l < "$QUEUE_FILE" 2>/dev/null || echo "0"
}

play_from_queue() {
    local total
    total=$(get_queue_length)
    
    if [[ $total -eq 0 ]]; then
        echo -e "${Y}  ⚠ Queue is empty${NC}"
        return 1
    fi
    
    if [[ $CURRENT_INDEX -lt 1 ]]; then
        CURRENT_INDEX=1
    fi
    
    if [[ $CURRENT_INDEX -gt $total ]]; then
        if [[ $REPEAT -eq 1 ]]; then
            CURRENT_INDEX=1
        else
            stop_playback
            return 1
        fi
    fi
    
    local track
    track=$(sed -n "${CURRENT_INDEX}p" "$QUEUE_FILE")
    play_track "$track"
}

next_track() {
    local total
    total=$(get_queue_length)
    
    if [[ $REPEAT -eq 2 ]]; then
        play_from_queue
        return
    fi
    
    CURRENT_INDEX=$((CURRENT_INDEX + 1))
    
    if [[ $CURRENT_INDEX -gt $total ]]; then
        if [[ $REPEAT -eq 1 ]]; then
            CURRENT_INDEX=1
        else
            CURRENT_INDEX=$total
            stop_playback
            return
        fi
    fi
    
    play_from_queue
}

prev_track() {
    local pos
    pos=$(get_current_position)
    
    # If more than 3 seconds in, restart current track
    if [[ $pos -gt 3 ]]; then
        play_from_queue
        return
    fi
    
    CURRENT_INDEX=$((CURRENT_INDEX - 1))
    
    if [[ $CURRENT_INDEX -lt 1 ]]; then
        if [[ $REPEAT -eq 1 ]]; then
            CURRENT_INDEX=$(get_queue_length)
        else
            CURRENT_INDEX=1
        fi
    fi
    
    play_from_queue
}

# Auto-advance to next track
check_track_ended() {
    if [[ $IS_PLAYING -eq 1 ]] && ! is_mpv_running; then
        next_track
    fi
}

# ──────────────────────────────────────────────
# DISPLAY FUNCTIONS
# ──────────────────────────────────────────────
clear_screen() {
    clear
    tput cup 0 0
}

get_cols() {
    tput cols 2>/dev/null || echo 60
}

draw_header() {
    local cols
    cols=$(get_cols)
    local line
    line=$(printf '═%.0s' $(seq 1 $((cols - 2))))
    
    echo -e "${C}╔${line}╗${NC}"
    
    local title="♫  ADVANCED MUSIC PLAYER v2.0  ♫"
    local pad=$(( (cols - 2 - ${#title}) / 2 ))
    printf "${C}║${NC}%*s${BOLD}${M}%s${NC}%*s${C}║${NC}\n" $pad "" "$title" $((cols - 2 - pad - ${#title})) ""
    
    echo -e "${C}╚${line}╝${NC}"
}

draw_separator() {
    local cols
    cols=$(get_cols)
    local line
    line=$(printf '─%.0s' $(seq 1 $((cols - 4))))
    echo -e "  ${DIM}${line}${NC}"
}

draw_progress_bar() {
    local current=$1
    local total=$2
    local cols
    cols=$(get_cols)
    local bar_width=$((cols - 20))
    
    [[ $bar_width -lt 10 ]] && bar_width=10
    
    if [[ $total -gt 0 ]]; then
        local filled=$(( (current * bar_width) / total ))
        [[ $filled -gt $bar_width ]] && filled=$bar_width
        local empty=$((bar_width - filled))
        
        local bar_filled=""
        local bar_empty=""
        for ((i=0; i<filled; i++)); do bar_filled+="█"; done
        for ((i=0; i<empty; i++)); do bar_empty+="░"; done
        
        printf "  ${C}%s${NC} ${G}%s${D}%s${NC} ${C}%s${NC}\n" \
            "$(format_time $current)" "$bar_filled" "$bar_empty" "$(format_time $total)"
    else
        printf "  ${C}00:00${NC} ${D}$(printf '░%.0s' $(seq 1 $bar_width))${NC} ${C}00:00${NC}\n"
    fi
}

draw_now_playing() {
    if [[ -z "$CURRENT_TRACK" ]]; then
        echo -e "\n  ${DIM}No track playing${NC}\n"
        return
    fi
    
    local name
    name=$(get_filename "$CURRENT_TRACK")
    local ext
    ext=$(get_extension "$CURRENT_TRACK")
    local dir
    dir=$(get_directory "$CURRENT_TRACK")
    local size
    size=$(get_file_size "$CURRENT_TRACK")
    local pos dur
    pos=$(get_current_position)
    dur=$(get_duration)
    local total_q
    total_q=$(get_queue_length)
    
    # Status icon
    local status_icon=""
    local status_color=""
    if [[ $IS_PAUSED -eq 1 ]]; then
        status_icon="⏸ PAUSED"
        status_color="$Y"
    elif [[ $IS_PLAYING -eq 1 ]]; then
        status_icon="▶ PLAYING"
        status_color="$G"
    else
        status_icon="⏹ STOPPED"
        status_color="$R"
    fi
    
    echo ""
    echo -e "  ${status_color}${BOLD}${status_icon}${NC}"
    echo ""
    
    # Track name with animation dots
    local dots=""
    if [[ $IS_PLAYING -eq 1 && $IS_PAUSED -eq 0 ]]; then
        local tick=$((SECONDS % 4))
        case $tick in
            0) dots="♪   " ;;
            1) dots=" ♪  " ;;
            2) dots="  ♪ " ;;
            3) dots="   ♪" ;;
        esac
    fi
    
    echo -e "  ${BOLD}${W}🎵 $name${NC} ${M}$dots${NC}"
    echo -e "  ${DIM}📁 $dir${NC}"
    echo -e "  ${DIM}📀 $ext • $size • Track $CURRENT_INDEX/$total_q${NC}"
    echo ""
    
    # Progress bar
    draw_progress_bar "$pos" "$dur"
    echo ""
    
    # Player status line
    local shuffle_status repeat_status vol_bar eq_status
    
    [[ $SHUFFLE -eq 1 ]] && shuffle_status="${G}🔀ON${NC}" || shuffle_status="${DIM}🔀OFF${NC}"
    
    case $REPEAT in
        0) repeat_status="${DIM}🔁OFF${NC}" ;;
        1) repeat_status="${G}🔁ALL${NC}" ;;
        2) repeat_status="${G}🔂ONE${NC}" ;;
    esac
    
    # Volume bar
    local vol_filled=$((VOLUME / 10))
    local vol_empty=$((10 - vol_filled))
    vol_bar=""
    for ((i=0; i<vol_filled; i++)); do vol_bar+="▮"; done
    for ((i=0; i<vol_empty; i++)); do vol_bar+="▯"; done
    
    [[ "$EQUALIZER" != "none" ]] && eq_status="${G}🎛${EQUALIZER}${NC}" || eq_status="${DIM}🎛OFF${NC}"
    
    echo -e "  🔊${C}${vol_bar}${NC} ${VOLUME}%  $shuffle_status  $repeat_status  $eq_status"
    
    # Sleep timer
    if [[ $SLEEP_TIMER -gt 0 ]]; then
        local remaining=$((SLEEP_TIMER - SECONDS))
        if [[ $remaining -gt 0 ]]; then
            echo -e "  ${Y}⏰ Sleep in $(format_time $remaining)${NC}"
        fi
    fi
}

draw_mini_visualizer() {
    if [[ $IS_PLAYING -eq 1 && $IS_PAUSED -eq 0 ]]; then
        local bars=("▁" "▂" "▃" "▄" "▅" "▆" "▇" "█")
        local vis=""
        local colors=("$R" "$Y" "$G" "$C" "$B" "$M" "$R" "$Y" "$G" "$C" "$B" "$M" "$G" "$C" "$B" "$M")
        for i in $(seq 1 16); do
            local height=$((RANDOM % 8))
            vis+="${colors[$((i-1))]}${bars[$height]}${NC}"
        done
        echo -e "\n  $vis"
    fi
}

# ──────────────────────────────────────────────
# MAIN MENU (NOW PLAYING SCREEN)
# ──────────────────────────────────────────────
show_main_screen() {
    clear_screen
    draw_header
    draw_now_playing
    draw_mini_visualizer
    draw_separator
    
    echo -e "
  ${BOLD}${W}CONTROLS:${NC}
  ${C}[Space]${NC} Pause/Resume    ${C}[n]${NC} Next         ${C}[p]${NC} Previous
  ${C}[+/-]${NC}   Volume          ${C}[→/←]${NC} Seek ±10s  ${C}[s]${NC} Stop

  ${BOLD}${W}NAVIGATION:${NC}
  ${C}[l]${NC} Library Browser     ${C}[f]${NC} Search       ${C}[q]${NC} Queue
  ${C}[a]${NC} Playlists           ${C}[v]${NC} Favorites    ${C}[h]${NC} History

  ${BOLD}${W}OPTIONS:${NC}
  ${C}[r]${NC} Repeat Mode         ${C}[z]${NC} Shuffle      ${C}[e]${NC} Equalizer
  ${C}[t]${NC} Sleep Timer         ${C}[i]${NC} Track Info   ${C}[c]${NC} Rescan
  ${C}[x]${NC} Exit Player
"
}

# ──────────────────────────────────────────────
# LIBRARY BROWSER
# ──────────────────────────────────────────────
show_library() {
    local page=1
    local per_page=15
    local total
    total=$(get_track_count)
    local total_pages=$(( (total + per_page - 1) / per_page ))
    [[ $total_pages -lt 1 ]] && total_pages=1
    
    while true; do
        clear_screen
        draw_header
        echo -e "\n  ${BOLD}${W}📚 MUSIC LIBRARY${NC} ${DIM}($total tracks)${NC}"
        echo -e "  ${DIM}Page $page of $total_pages${NC}"
        draw_separator
        
        local start=$(( (page - 1) * per_page + 1 ))
        local end=$((start + per_page - 1))
        [[ $end -gt $total ]] && end=$total
        
        local i=$start
        while [[ $i -le $end ]]; do
            local track
            track=$(get_track_by_index $i)
            local name
            name=$(get_filename "$track")
            local ext
            ext=$(get_extension "$track")
            local is_fav=""
            
            if grep -qF "$track" "$FAVORITES_FILE" 2>/dev/null; then
                is_fav=" ${R}♥${NC}"
            fi
            
            local marker=""
            if [[ "$track" == "$CURRENT_TRACK" ]]; then
                marker="${G}▶ ${NC}"
                echo -e "  ${G}${BOLD}$(printf '%3d' $i). ${marker}${name}${NC} ${DIM}[$ext]${NC}${is_fav}"
            else
                echo -e "  ${C}$(printf '%3d' $i).${NC} ${W}${name}${NC} ${DIM}[$ext]${NC}${is_fav}"
            fi
            
            i=$((i + 1))
        done
        
        draw_separator
        echo -e "  ${C}[#]${NC} Play track  ${C}[N/P]${NC} Next/Prev page  ${C}[A]${NC} Play all"
        echo -e "  ${C}[F]${NC} Add to favorites  ${C}[L]${NC} Add to playlist  ${C}[B]${NC} Back"
        echo ""
        echo -ne "  ${Y}▶ Choice: ${NC}"
        
        read -r choice
        
        case "$choice" in
            [Bb]) return ;;
            [Nn]) 
                page=$((page + 1))
                [[ $page -gt $total_pages ]] && page=$total_pages
                ;;
            [Pp]) 
                page=$((page - 1))
                [[ $page -lt 1 ]] && page=1
                ;;
            [Aa])
                cp "$LIBRARY_FILE" "$QUEUE_FILE"
                [[ $SHUFFLE -eq 1 ]] && shuffle_queue
                CURRENT_INDEX=1
                play_from_queue
                return
                ;;
            [Ff])
                echo -ne "  ${Y}Track # to favorite: ${NC}"
                read -r fav_num
                if [[ "$fav_num" =~ ^[0-9]+$ ]] && [[ $fav_num -ge 1 ]] && [[ $fav_num -le $total ]]; then
                    local fav_track
                    fav_track=$(get_track_by_index $fav_num)
                    if grep -qF "$fav_track" "$FAVORITES_FILE" 2>/dev/null; then
                        grep -vF "$fav_track" "$FAVORITES_FILE" > "$FAVORITES_FILE.tmp"
                        mv "$FAVORITES_FILE.tmp" "$FAVORITES_FILE"
                        echo -e "  ${Y}Removed from favorites${NC}"
                    else
                        echo "$fav_track" >> "$FAVORITES_FILE"
                        echo -e "  ${G}♥ Added to favorites${NC}"
                    fi
                    sleep 1
                fi
                ;;
            [Ll])
                echo -ne "  ${Y}Track # to add: ${NC}"
                read -r add_num
                if [[ "$add_num" =~ ^[0-9]+$ ]] && [[ $add_num -ge 1 ]] && [[ $add_num -le $total ]]; then
                    add_to_playlist_interactive "$(get_track_by_index $add_num)"
                fi
                ;;
            *)
                if [[ "$choice" =~ ^[0-9]+$ ]] && [[ $choice -ge 1 ]] && [[ $choice -le $total ]]; then
                    cp "$LIBRARY_FILE" "$QUEUE_FILE"
                    [[ $SHUFFLE -eq 1 ]] && shuffle_queue
                    CURRENT_INDEX=$choice
                    play_from_queue
                    return
                fi
                ;;
        esac
    done
}

# ──────────────────────────────────────────────
# SEARCH
# ──────────────────────────────────────────────
show_search() {
    clear_screen
    draw_header
    echo -e "\n  ${BOLD}${W}🔍 SEARCH MUSIC${NC}\n"
    echo -ne "  ${Y}Enter search term: ${NC}"
    read -r search_term
    
    if [[ -z "$search_term" ]]; then
        return
    fi
    
    local results_file="$CACHE_DIR/search_results.txt"
    grep -i "$search_term" "$LIBRARY_FILE" > "$results_file" 2>/dev/null
    
    local total
    total=$(wc -l < "$results_file" 2>/dev/null || echo "0")
    
    if [[ $total -eq 0 ]]; then
        echo -e "\n  ${R}No results found for '${search_term}'${NC}"
        sleep 2
        return
    fi
    
    local page=1
    local per_page=15
    local total_pages=$(( (total + per_page - 1) / per_page ))
    
    while true; do
        clear_screen
        draw_header
        echo -e "\n  ${BOLD}${W}🔍 SEARCH RESULTS${NC} ${DIM}for '${search_term}' ($total found)${NC}"
        echo -e "  ${DIM}Page $page of $total_pages${NC}"
        draw_separator
        
        local start=$(( (page - 1) * per_page + 1 ))
        local end=$((start + per_page - 1))
        [[ $end -gt $total ]] && end=$total
        
        local i=$start
        while [[ $i -le $end ]]; do
            local track
            track=$(sed -n "${i}p" "$results_file")
            local name
            name=$(get_filename "$track")
            local ext
            ext=$(get_extension "$track")
            
            # Highlight search term
            local highlighted
            highlighted=$(echo "$name" | sed "s/$search_term/$(echo -e "${R}${BOLD}")&$(echo -e "${NC}${W}")/gi")
            
            echo -e "  ${C}$(printf '%3d' $i).${NC} ${W}${highlighted}${NC} ${DIM}[$ext]${NC}"
            i=$((i + 1))
        done
        
        draw_separator
        echo -e "  ${C}[#]${NC} Play track  ${C}[A]${NC} Play all results  ${C}[N/P]${NC} Page  ${C}[B]${NC} Back"
        echo ""
        echo -ne "  ${Y}▶ Choice: ${NC}"
        
        read -r choice
        
        case "$choice" in
            [Bb]) return ;;
            [Nn])
                page=$((page + 1))
                [[ $page -gt $total_pages ]] && page=$total_pages
                ;;
            [Pp])
                page=$((page - 1))
                [[ $page -lt 1 ]] && page=1
                ;;
            [Aa])
                cp "$results_file" "$QUEUE_FILE"
                [[ $SHUFFLE -eq 1 ]] && shuffle_queue
                CURRENT_INDEX=1
                play_from_queue
                return
                ;;
            *)
                if [[ "$choice" =~ ^[0-9]+$ ]] && [[ $choice -ge 1 ]] && [[ $choice -le $total ]]; then
                    cp "$results_file" "$QUEUE_FILE"
                    CURRENT_INDEX=$choice
                    play_from_queue
                    return
                fi
                ;;
        esac
    done
}

# ──────────────────────────────────────────────
# QUEUE VIEW
# ──────────────────────────────────────────────
show_queue() {
    local page=1
    local per_page=15
    local total
    total=$(get_queue_length)
    local total_pages=$(( (total + per_page - 1) / per_page ))
    [[ $total_pages -lt 1 ]] && total_pages=1
    
    # Jump to current track's page
    if [[ $CURRENT_INDEX -gt 0 ]]; then
        page=$(( (CURRENT_INDEX - 1) / per_page + 1 ))
    fi
    
    while true; do
        clear_screen
        draw_header
        echo -e "\n  ${BOLD}${W}📋 PLAY QUEUE${NC} ${DIM}($total tracks)${NC}"
        echo -e "  ${DIM}Page $page of $total_pages${NC}"
        draw_separator
        
        if [[ $total -eq 0 ]]; then
            echo -e "\n  ${DIM}Queue is empty. Browse library to add tracks.${NC}\n"
        else
            local start=$(( (page - 1) * per_page + 1 ))
            local end=$((start + per_page - 1))
            [[ $end -gt $total ]] && end=$total
            
            local i=$start
            while [[ $i -le $end ]]; do
                local track
                track=$(sed -n "${i}p" "$QUEUE_FILE")
                local name
                name=$(get_filename "$track")
                
                if [[ $i -eq $CURRENT_INDEX ]]; then
                    echo -e "  ${G}${BOLD}$(printf '%3d' $i). ▶ ${name}${NC}"
                else
                    echo -e "  ${C}$(printf '%3d' $i).${NC} ${W}${name}${NC}"
                fi
                
                i=$((i + 1))
            done
        fi
        
        draw_separator
        echo -e "  ${C}[#]${NC} Jump to track  ${C}[N/P]${NC} Page  ${C}[C]${NC} Clear queue"
        echo -e "  ${C}[S]${NC} Shuffle queue   ${C}[R]${NC} Remove track  ${C}[B]${NC} Back"
        echo ""
        echo -ne "  ${Y}▶ Choice: ${NC}"
        
        read -r choice
        
        case "$choice" in
            [Bb]) return ;;
            [Nn])
                page=$((page + 1))
                [[ $page -gt $total_pages ]] && page=$total_pages
                ;;
            [Pp])
                page=$((page - 1))
                [[ $page -lt 1 ]] && page=1
                ;;
            [Cc])
                > "$QUEUE_FILE"
                stop_playback
                total=0
                total_pages=1
                page=1
                ;;
            [Ss])
                shuffle_queue
                echo -e "  ${G}✓ Queue shuffled${NC}"
                sleep 1
                total=$(get_queue_length)
                total_pages=$(( (total + per_page - 1) / per_page ))
                page=1
                ;;
            [Rr])
                echo -ne "  ${Y}Track # to remove: ${NC}"
                read -r rem_num
                if [[ "$rem_num" =~ ^[0-9]+$ ]] && [[ $rem_num -ge 1 ]] && [[ $rem_num -le $total ]]; then
                    sed -i "${rem_num}d" "$QUEUE_FILE"
                    if [[ $rem_num -lt $CURRENT_INDEX ]]; then
                        CURRENT_INDEX=$((CURRENT_INDEX - 1))
                    fi
                    total=$(get_queue_length)
                    total_pages=$(( (total + per_page - 1) / per_page ))
                    [[ $page -gt $total_pages ]] && page=$total_pages
                    [[ $page -lt 1 ]] && page=1
                fi
                ;;
            *)
                if [[ "$choice" =~ ^[0-9]+$ ]] && [[ $choice -ge 1 ]] && [[ $choice -le $total ]]; then
                    CURRENT_INDEX=$choice
                    play_from_queue
                    return
                fi
                ;;
        esac
    done
}

# ──────────────────────────────────────────────
# PLAYLIST MANAGEMENT
# ──────────────────────────────────────────────
show_playlists() {
    while true; do
        clear_screen
        draw_header
        echo -e "\n  ${BOLD}${W}🎵 PLAYLISTS${NC}\n"
        
        local playlists=()
        local idx=1
        
        if [[ -d "$PLAYLIST_DIR" ]]; then
            while IFS= read -r -d '' pl; do
                playlists+=("$pl")
                local pl_name
                pl_name=$(basename "$pl" .m3u)
                local pl_count
                pl_count=$(wc -l < "$pl" 2>/dev/null || echo "0")
                echo -e "  ${C}${idx}.${NC} ${W}${pl_name}${NC} ${DIM}(${pl_count} tracks)${NC}"
                idx=$((idx + 1))
            done < <(find "$PLAYLIST_DIR" -name "*.m3u" -print0 2>/dev/null | sort -z)
        fi
        
        if [[ ${#playlists[@]} -eq 0 ]]; then
            echo -e "  ${DIM}No playlists yet. Create one!${NC}"
        fi
        
        draw_separator
        echo -e "  ${C}[#]${NC} Open playlist  ${C}[N]${NC} New playlist  ${C}[D]${NC} Delete playlist"
        echo -e "  ${C}[B]${NC} Back"
        echo ""
        echo -ne "  ${Y}▶ Choice: ${NC}"
        
        read -r choice
        
        case "$choice" in
            [Bb]) return ;;
            [Nn])
                echo -ne "  ${Y}Playlist name: ${NC}"
                read -r pl_name
                if [[ -n "$pl_name" ]]; then
                    touch "$PLAYLIST_DIR/${pl_name}.m3u"
                    echo -e "  ${G}✓ Created playlist: $pl_name${NC}"
                    sleep 1
                fi
                ;;
            [Dd])
                echo -ne "  ${Y}Playlist # to delete: ${NC}"
                read -r del_num
                if [[ "$del_num" =~ ^[0-9]+$ ]] && [[ $del_num -ge 1 ]] && [[ $del_num -le ${#playlists[@]} ]]; then
                    local del_file="${playlists[$((del_num - 1))]}"
                    rm -f "$del_file"
                    echo -e "  ${R}✗ Deleted${NC}"
                    sleep 1
                fi
                ;;
            *)
                if [[ "$choice" =~ ^[0-9]+$ ]] && [[ $choice -ge 1 ]] && [[ $choice -le ${#playlists[@]} ]]; then
                    show_playlist_contents "${playlists[$((choice - 1))]}"
                fi
                ;;
        esac
    done
}

show_playlist_contents() {
    local pl_file="$1"
    local pl_name
    pl_name=$(basename "$pl_file" .m3u)
    
    while true; do
        clear_screen
        draw_header
        
        local total
        total=$(wc -l < "$pl_file" 2>/dev/null || echo "0")
        
        echo -e "\n  ${BOLD}${W}🎵 Playlist: ${M}$pl_name${NC} ${DIM}($total tracks)${NC}"
        draw_separator
        
        if [[ $total -eq 0 ]]; then
            echo -e "\n  ${DIM}Empty playlist. Add tracks from library.${NC}\n"
        else
            local i=1
            while IFS= read -r track; do
                if [[ $i -gt 20 ]]; then
                    echo -e "  ${DIM}... and $((total - 20)) more${NC}"
                    break
                fi
                local name
                name=$(get_filename "$track")
                echo -e "  ${C}${i}.${NC} ${W}${name}${NC}"
                i=$((i + 1))
            done < "$pl_file"
        fi
        
        draw_separator
        echo -e "  ${C}[P]${NC} Play all  ${C}[#]${NC} Play track  ${C}[R]${NC} Remove track  ${C}[B]${NC} Back"
        echo ""
        echo -ne "  ${Y}▶ Choice: ${NC}"
        
        read -r choice
        
        case "$choice" in
            [Bb]) return ;;
            [Pp])
                if [[ $total -gt 0 ]]; then
                    cp "$pl_file" "$QUEUE_FILE"
                    [[ $SHUFFLE -eq 1 ]] && shuffle_queue
                    CURRENT_INDEX=1
                    play_from_queue
                    return
                fi
                ;;
            [Rr])
                echo -ne "  ${Y}Track # to remove: ${NC}"
                read -r rem_num
                if [[ "$rem_num" =~ ^[0-9]+$ ]] && [[ $rem_num -ge 1 ]] && [[ $rem_num -le $total ]]; then
                    sed -i "${rem_num}d" "$pl_file"
                fi
                ;;
            *)
                if [[ "$choice" =~ ^[0-9]+$ ]] && [[ $choice -ge 1 ]] && [[ $choice -le $total ]]; then
                    cp "$pl_file" "$QUEUE_FILE"
                    CURRENT_INDEX=$choice
                    play_from_queue
                    return
                fi
                ;;
        esac
    done
}

add_to_playlist_interactive() {
    local track="$1"
    
    echo -e "\n  ${BOLD}${W}Add to playlist:${NC}"
    
    local playlists=()
    local idx=1
    
    while IFS= read -r -d '' pl; do
        playlists+=("$pl")
        echo -e "  ${C}${idx}.${NC} $(basename "$pl" .m3u)"
        idx=$((idx + 1))
    done < <(find "$PLAYLIST_DIR" -name "*.m3u" -print0 2>/dev/null | sort -z)
    
    echo -e "  ${C}${idx}.${NC} ${G}+ New playlist${NC}"
    echo ""
    echo -ne "  ${Y}Choice: ${NC}"
    read -r choice
    
    if [[ "$choice" =~ ^[0-9]+$ ]]; then
        if [[ $choice -eq $idx ]]; then
            echo -ne "  ${Y}New playlist name: ${NC}"
            read -r new_name
            if [[ -n "$new_name" ]]; then
                echo "$track" >> "$PLAYLIST_DIR/${new_name}.m3u"
                echo -e "  ${G}✓ Added to $new_name${NC}"
            fi
        elif [[ $choice -ge 1 ]] && [[ $choice -le ${#playlists[@]} ]]; then
            echo "$track" >> "${playlists[$((choice - 1))]}"
            echo -e "  ${G}✓ Added!${NC}"
        fi
        sleep 1
    fi
}

# ──────────────────────────────────────────────
# FAVORITES
# ──────────────────────────────────────────────
show_favorites() {
    while true; do
        clear_screen
        draw_header
        
        local total
        total=$(wc -l < "$FAVORITES_FILE" 2>/dev/null || echo "0")
        # Remove empty lines count
        total=$(grep -c . "$FAVORITES_FILE" 2>/dev/null || echo "0")
        
        echo -e "\n  ${BOLD}${R}♥ FAVORITES${NC} ${DIM}($total tracks)${NC}"
        draw_separator
        
        if [[ $total -eq 0 ]]; then
            echo -e "\n  ${DIM}No favorites yet. Add some from the library!${NC}\n"
        else
            local i=1
            while IFS= read -r track; do
                [[ -z "$track" ]] && continue
                if [[ $i -gt 20 ]]; then
                    echo -e "  ${DIM}... and $((total - 20)) more${NC}"
                    break
                fi
                local name
                name=$(get_filename "$track")
                local marker=""
                [[ "$track" == "$CURRENT_TRACK" ]] && marker="${G}▶ ${NC}"
                echo -e "  ${R}♥${NC} ${C}${i}.${NC} ${marker}${W}${name}${NC}"
                i=$((i + 1))
            done < "$FAVORITES_FILE"
        fi
        
        draw_separator
        echo -e "  ${C}[#]${NC} Play track  ${C}[P]${NC} Play all  ${C}[R]${NC} Remove  ${C}[B]${NC} Back"
        echo ""
        echo -ne "  ${Y}▶ Choice: ${NC}"
        
        read -r choice
        
        case "$choice" in
            [Bb]) return ;;
            [Pp])
                if [[ $total -gt 0 ]]; then
                    cp "$FAVORITES_FILE" "$QUEUE_FILE"
                    sed -i '/^$/d' "$QUEUE_FILE"
                    [[ $SHUFFLE -eq 1 ]] && shuffle_queue
                    CURRENT_INDEX=1
                    play_from_queue
                    return
                fi
                ;;
            [Rr])
                echo -ne "  ${Y}Track # to remove: ${NC}"
                read -r rem_num
                if [[ "$rem_num" =~ ^[0-9]+$ ]] && [[ $rem_num -ge 1 ]] && [[ $rem_num -le $total ]]; then
                    sed -i "${rem_num}d" "$FAVORITES_FILE"
                    sed -i '/^$/d' "$FAVORITES_FILE"
                fi
                ;;
            *)
                if [[ "$choice" =~ ^[0-9]+$ ]] && [[ $choice -ge 1 ]] && [[ $choice -le $total ]]; then
                    cp "$FAVORITES_FILE" "$QUEUE_FILE"
                    sed -i '/^$/d' "$QUEUE_FILE"
                    CURRENT_INDEX=$choice
                    play_from_queue
                    return
                fi
                ;;
        esac
    done
}

# ──────────────────────────────────────────────
# HISTORY
# ──────────────────────────────────────────────
show_history() {
    clear_screen
    draw_header
    echo -e "\n  ${BOLD}${W}📜 PLAY HISTORY${NC} ${DIM}(last 25)${NC}"
    draw_separator
    
    if [[ ! -s "$HISTORY_FILE" ]]; then
        echo -e "\n  ${DIM}No history yet.${NC}\n"
    else
        tail -25 "$HISTORY_FILE" | tac | while IFS= read -r line; do
            local date_part="${line%% | *}"
            local track_part="${line#* | }"
            echo -e "  ${DIM}${date_part}${NC}  ${W}${track_part}${NC}"
        done
    fi
    
    draw_separator
    echo -e "  ${C}[C]${NC} Clear history  ${C}[B]${NC} Back"
    echo ""
    echo -ne "  ${Y}▶ Choice: ${NC}"
    
    read -r choice
    case "$choice" in
        [Cc]) > "$HISTORY_FILE"; echo -e "  ${G}✓ History cleared${NC}"; sleep 1 ;;
    esac
}

# ──────────────────────────────────────────────
# TRACK INFO
# ──────────────────────────────────────────────
show_track_info() {
    clear_screen
    draw_header
    
    if [[ -z "$CURRENT_TRACK" ]]; then
        echo -e "\n  ${DIM}No track playing.${NC}\n"
        read -rp "  Press Enter to continue..."
        return
    fi
    
    echo -e "\n  ${BOLD}${W}ℹ️  TRACK INFORMATION${NC}\n"
    draw_separator
    
    local name ext dir size
    name=$(get_filename "$CURRENT_TRACK")
    ext=$(get_extension "$CURRENT_TRACK")
    dir=$(get_directory "$CURRENT_TRACK")
    size=$(get_file_size "$CURRENT_TRACK")
    
    local dur
    dur=$(get_duration)
    
    local is_fav="${DIM}No${NC}"
    grep -qF "$CURRENT_TRACK" "$FAVORITES_FILE" 2>/dev/null && is_fav="${R}♥ Yes${NC}"
    
    echo -e "  ${C}Title:${NC}      ${W}${BOLD}$name${NC}"
    echo -e "  ${C}Format:${NC}     $ext"
    echo -e "  ${C}Size:${NC}       $size"
    echo -e "  ${C}Duration:${NC}   $(format_time $dur)"
    echo -e "  ${C}Location:${NC}   ${DIM}$dir${NC}"
    echo -e "  ${C}Full Path:${NC}  ${DIM}${CURRENT_TRACK}${NC}"
    echo -e "  ${C}Favorite:${NC}   $is_fav"
    echo -e "  ${C}Queue Pos:${NC}  $CURRENT_INDEX / $(get_queue_length)"
    
    # Try to get metadata with mpv
    echo ""
    echo -e "  ${BOLD}${W}Metadata (if available):${NC}"
    local metadata
    metadata=$(mpv --no-video --frames=0 --no-terminal "$CURRENT_TRACK" 2>&1 | grep -E "Artist|Album|Title|Genre|Date|Track" | head -10)
    if [[ -n "$metadata" ]]; then
        echo "$metadata" | while IFS= read -r line; do
            echo -e "  ${DIM}$line${NC}"
        done
    else
        echo -e "  ${DIM}No metadata available${NC}"
    fi
    
    draw_separator
    echo -e "  ${C}[F]${NC} Toggle favorite  ${C}[L]${NC} Add to playlist  ${C}[B]${NC} Back"
    echo ""
    echo -ne "  ${Y}▶ Choice: ${NC}"
    
    read -r choice
    case "$choice" in
        [Ff])
            if grep -qF "$CURRENT_TRACK" "$FAVORITES_FILE" 2>/dev/null; then
                grep -vF "$CURRENT_TRACK" "$FAVORITES_FILE" > "$FAVORITES_FILE.tmp"
                mv "$FAVORITES_FILE.tmp" "$FAVORITES_FILE"
                echo -e "  ${Y}Removed from favorites${NC}"
            else
                echo "$CURRENT_TRACK" >> "$FAVORITES_FILE"
                echo -e "  ${G}♥ Added to favorites${NC}"
            fi
            sleep 1
            ;;
        [Ll])
            add_to_playlist_interactive "$CURRENT_TRACK"
            ;;
    esac
}

# ──────────────────────────────────────────────
# EQUALIZER
# ──────────────────────────────────────────────
show_equalizer() {
    clear_screen
    draw_header
    echo -e "\n  ${BOLD}${W}🎛  EQUALIZER PRESETS${NC}\n"
    draw_separator
    
    local presets=("none" "bass" "treble" "vocal" "rock" "pop" "jazz" "classical")
    local descriptions=(
        "Flat - No EQ applied"
        "Bass Boost - Enhanced low frequencies"
        "Treble Boost - Enhanced high frequencies"  
        "Vocal - Enhanced mid-range for vocals"
        "Rock - V-shaped, boosted lows and highs"
        "Pop - Balanced with slight mid boost"
        "Jazz - Warm tone with clarity"
        "Classical - Wide dynamic range"
    )
    
    for i in "${!presets[@]}"; do
        local marker=""
        if [[ "${presets[$i]}" == "$EQUALIZER" ]]; then
            marker="${G}◉${NC}"
        else
            marker="${DIM}○${NC}"
        fi
        echo -e "  $marker ${C}$((i + 1)).${NC} ${W}${BOLD}${presets[$i]^}${NC}"
        echo -e "     ${DIM}${descriptions[$i]}${NC}"
    done
    
    draw_separator
    echo -ne "\n  ${Y}Select preset (1-${#presets[@]}): ${NC}"
    read -r choice
    
    if [[ "$choice" =~ ^[0-9]+$ ]] && [[ $choice -ge 1 ]] && [[ $choice -le ${#presets[@]} ]]; then
        EQUALIZER="${presets[$((choice - 1))]}"
        save_config
        echo -e "  ${G}✓ EQ set to: ${EQUALIZER^}${NC}"
        
        # Restart current track with new EQ if playing
        if [[ $IS_PLAYING -eq 1 && -n "$CURRENT_TRACK" ]]; then
            local pos
            pos=$(get_current_position)
            play_track "$CURRENT_TRACK"
            sleep 0.5
            if [[ $pos -gt 0 ]] && is_mpv_running; then
                mpv_command "{ \"command\": [\"seek\", \"$pos\", \"absolute\"] }"
            fi
            echo -e "  ${G}✓ Restarted with new EQ${NC}"
        fi
        sleep 1
    fi
}

# ──────────────────────────────────────────────
# SLEEP TIMER
# ──────────────────────────────────────────────
show_sleep_timer() {
    clear_screen
    draw_header
    echo -e "\n  ${BOLD}${W}⏰ SLEEP TIMER${NC}\n"
    draw_separator
    
    local options=("Off" "5 minutes" "10 minutes" "15 minutes" "30 minutes" "45 minutes" "60 minutes" "90 minutes" "Custom")
    local values=(0 5 10 15 30 45 60 90 -1)
    
    for i in "${!options[@]}"; do
        echo -e "  ${C}$((i + 1)).${NC} ${W}${options[$i]}${NC}"
    done
    
    if [[ $SLEEP_TIMER -gt 0 ]]; then
        local remaining=$((SLEEP_TIMER - SECONDS))
        [[ $remaining -gt 0 ]] && echo -e "\n  ${Y}⏰ Current timer: $(format_time $remaining) remaining${NC}"
    fi
    
    draw_separator
    echo -ne "\n  ${Y}Select option: ${NC}"
    read -r choice
    
    if [[ "$choice" =~ ^[0-9]+$ ]] && [[ $choice -ge 1 ]] && [[ $choice -le ${#options[@]} ]]; then
        local minutes=${values[$((choice - 1))]}
        
        # Kill existing timer
        [[ $SLEEP_PID -ne 0 ]] && kill $SLEEP_PID 2>/dev/null
        SLEEP_PID=0
        SLEEP_TIMER=0
        
        if [[ $minutes -eq -1 ]]; then
            echo -ne "  ${Y}Enter minutes: ${NC}"
            read -r minutes
            [[ ! "$minutes" =~ ^[0-9]+$ ]] && return
        fi
        
        if [[ $minutes -gt 0 ]]; then
            SLEEP_TIMER=$((SECONDS + minutes * 60))
            (
                sleep $((minutes * 60))
                stop_playback
                echo -e "\n${Y}⏰ Sleep timer: Playback stopped.${NC}"
            ) &
            SLEEP_PID=$!
            echo -e "  ${G}✓ Sleep timer set for $minutes minutes${NC}"
        else
            echo -e "  ${G}✓ Sleep timer disabled${NC}"
        fi
        sleep 1
    fi
}

# ──────────────────────────────────────────────
# FOLDER BROWSER
# ──────────────────────────────────────────────
browse_folders() {
    local current_dir="$HOME/storage/shared"
    
    while true; do
        clear_screen
        draw_header
        echo -e "\n  ${BOLD}${W}📂 FOLDER BROWSER${NC}"
        echo -e "  ${DIM}$current_dir${NC}"
        draw_separator
        
        local items=()
        local idx=1
        
        # Add parent directory
        if [[ "$current_dir" != "$HOME/storage" ]]; then
            echo -e "  ${C} 0.${NC} ${Y}📁 ../ (Parent Directory)${NC}"
        fi
        
        # List directories
        while IFS= read -r -d '' dir; do
            local dirname
            dirname=$(basename "$dir")
            echo -e "  ${C}$(printf '%2d' $idx).${NC} ${Y}📁 ${dirname}/${NC}"
            items+=("DIR:$dir")
            idx=$((idx + 1))
        done < <(find "$current_dir" -maxdepth 1 -mindepth 1 -type d -print0 2>/dev/null | sort -z)
        
        # List music files
        while IFS= read -r -d '' file; do
            local fname
            fname=$(get_filename "$file")
            local fext
            fext=$(get_extension "$file")
            echo -e "  ${C}$(printf '%2d' $idx).${NC} ${W}🎵 ${fname}${NC} ${DIM}[$fext]${NC}"
            items+=("FILE:$file")
            idx=$((idx + 1))
        done < <(find "$current_dir" -maxdepth 1 -type f -regextype posix-extended \
            -iregex ".*\.($SUPPORTED_FORMATS)$" -print0 2>/dev/null | sort -z)
        
        if [[ ${#items[@]} -eq 0 ]]; then
            echo -e "\n  ${DIM}No music files or folders here.${NC}"
        fi
        
        draw_separator
        echo -e "  ${C}[#]${NC} Open item  ${C}[A]${NC} Play all in folder  ${C}[B]${NC} Back to menu"
        echo ""
        echo -ne "  ${Y}▶ Choice: ${NC}"
        
        read -r choice
        
        case "$choice" in
            [Bb]) return ;;
            0)
                current_dir=$(dirname "$current_dir")
                ;;
            [Aa])
                # Play all music in current folder
                find "$current_dir" -maxdepth 1 -type f -regextype posix-extended \
                    -iregex ".*\.($SUPPORTED_FORMATS)$" 2>/dev/null | sort > "$QUEUE_FILE"
                if [[ $(wc -l < "$QUEUE_FILE") -gt 0 ]]; then
                    [[ $SHUFFLE -eq 1 ]] && shuffle_queue
                    CURRENT_INDEX=1
                    play_from_queue
                    return
                else
                    echo -e "  ${R}No music files in this folder${NC}"
                    sleep 1
                fi
                ;;
            *)
                if [[ "$choice" =~ ^[0-9]+$ ]] && [[ $choice -ge 1 ]] && [[ $choice -le ${#items[@]} ]]; then
                    local item="${items[$((choice - 1))]}"
                    local type="${item%%:*}"
                    local path="${item#*:}"
                    
                    if [[ "$type" == "DIR" ]]; then
                        current_dir="$path"
                    elif [[ "$type" == "FILE" ]]; then
                        # Create queue from folder and play selected
                        find "$current_dir" -maxdepth 1 -type f -regextype posix-extended \
                            -iregex ".*\.($SUPPORTED_FORMATS)$" 2>/dev/null | sort > "$QUEUE_FILE"
                        CURRENT_INDEX=$(grep -n "$path" "$QUEUE_FILE" | head -1 | cut -d: -f1)
                        [[ -z "$CURRENT_INDEX" ]] && CURRENT_INDEX=1
                        play_from_queue
                        return
                    fi
                fi
                ;;
        esac
    done
}

# ──────────────────────────────────────────────
# ALBUM/ARTIST VIEW
# ──────────────────────────────────────────────
show_by_folders() {
    clear_screen
    draw_header
    echo -e "\n  ${BOLD}${W}📂 BROWSE BY FOLDER${NC}\n"
    draw_separator
    
    local folders=()
    local idx=1
    
    while IFS= read -r dir; do
        local count
        count=$(find "$dir" -maxdepth 1 -type f -regextype posix-extended \
            -iregex ".*\.($SUPPORTED_FORMATS)$" 2>/dev/null | wc -l)
        if [[ $count -gt 0 ]]; then
            local short_dir
            short_dir=$(echo "$dir" | sed "s|$HOME/storage/shared/||" | sed "s|$HOME/storage/||")
            folders+=("$dir")
            echo -e "  ${C}${idx}.${NC} ${W}${short_dir}${NC} ${DIM}(${count} tracks)${NC}"
            idx=$((idx + 1))
        fi
    done < <(cat "$LIBRARY_FILE" | xargs -I{} dirname "{}" 2>/dev/null | sort -u)
    
    if [[ ${#folders[@]} -eq 0 ]]; then
        echo -e "  ${DIM}No folders found.${NC}"
    fi
    
    draw_separator
    echo -e "  ${C}[#]${NC} Play folder  ${C}[B]${NC} Back"
    echo ""
    echo -ne "  ${Y}▶ Choice: ${NC}"
    
    read -r choice
    
    case "$choice" in
        [Bb]) return ;;
        *)
            if [[ "$choice" =~ ^[0-9]+$ ]] && [[ $choice -ge 1 ]] && [[ $choice -le ${#folders[@]} ]]; then
                local selected_dir="${folders[$((choice - 1))]}"
                find "$selected_dir" -maxdepth 1 -type f -regextype posix-extended \
                    -iregex ".*\.($SUPPORTED_FORMATS)$" 2>/dev/null | sort > "$QUEUE_FILE"
                [[ $SHUFFLE -eq 1 ]] && shuffle_queue
                CURRENT_INDEX=1
                play_from_queue
            fi
            ;;
    esac
}

# ──────────────────────────────────────────────
# VISUALIZER (Simple ASCII)
# ──────────────────────────────────────────────
show_visualizer() {
    echo -e "\n  ${BOLD}${W}🎵 VISUALIZER${NC} ${DIM}(Press any key to exit)${NC}\n"
    
    local bars=("▁" "▂" "▃" "▄" "▅" "▆" "▇" "█")
    local colors=("$R" "$Y" "$G" "$C" "$B" "$M")
    local cols
    cols=$(get_cols)
    local num_bars=$((cols / 2 - 4))
    [[ $num_bars -gt 32 ]] && num_bars=32
    
    while true; do
        if read -rsn1 -t 0.15 key; then
            break
        fi
        
        if [[ $IS_PLAYING -eq 1 && $IS_PAUSED -eq 0 ]]; then
            local line="  "
            for ((i=0; i<num_bars; i++)); do
                local height=$((RANDOM % 8))
                local color_idx=$((i % 6))
                line+="${colors[$color_idx]}${bars[$height]} ${NC}"
            done
            echo -ne "\r${line}"
        else
            echo -ne "\r  ${DIM}Not playing...${NC}                    "
        fi
    done
    echo ""
}

# ──────────────────────────────────────────────
# MAIN LOOP
# ──────────────────────────────────────────────
main() {
    init
    tput civis  # Hide cursor
    
    # Check if library exists
    if [[ ! -f "$LIBRARY_FILE" ]] || [[ ! -s "$LIBRARY_FILE" ]]; then
        scan_library
    fi
    
    # Load library into queue if empty
    if [[ ! -s "$QUEUE_FILE" ]]; then
        load_queue_from_library
    fi
    
    while true; do
        # Check if current track ended
        check_track_ended
        
        tput civis
        show_main_screen
        
        # Read single key with timeout for auto-refresh
        tput cnorm
        if read -rsn1 -t 2 key; then
            case "$key" in
                # Space = pause
                " ") toggle_pause ;;
                
                # Playback controls
                "n"|"N") next_track ;;
                "p") prev_track ;;
                "s"|"S") stop_playback ;;
                
                # Volume
                "+"|"=") volume_up ;;
                "-"|"_") volume_down ;;
                
                # Seek (arrow keys send escape sequences)
                $'\x1b')
                    read -rsn2 -t 0.1 arrow
                    case "$arrow" in
                        "[C") seek_forward ;;   # Right arrow
                        "[D") seek_backward ;;  # Left arrow
                    esac
                    ;;
                
                # Navigation
                "l"|"L") tput cnorm; show_library ;;
                "f"|"F") tput cnorm; show_search ;;
                "q"|"Q") tput cnorm; show_queue ;;
                "a"|"A") tput cnorm; show_playlists ;;
                "v"|"V") tput cnorm; show_favorites ;;
                "h"|"H") tput cnorm; show_history ;;
                "d"|"D") tput cnorm; browse_folders ;;
                "g"|"G") tput cnorm; show_by_folders ;;
                "w"|"W") tput cnorm; show_visualizer ;;
                
                # Options
                "r"|"R")
                    REPEAT=$(( (REPEAT + 1) % 3 ))
                    save_config
                    ;;
                "z"|"Z")
                    SHUFFLE=$((1 - SHUFFLE))
                    if [[ $SHUFFLE -eq 1 ]]; then
                        shuffle_queue
                    else
                        load_queue_from_library
                    fi
                    save_config
                    ;;
                "e"|"E") tput cnorm; show_equalizer ;;
                "t"|"T") tput cnorm; show_sleep_timer ;;
                "i"|"I") tput cnorm; show_track_info ;;
                "c"|"C") scan_library; load_queue_from_library ;;
                
                # Favorite current track
                "1")
                    if [[ -n "$CURRENT_TRACK" ]]; then
                        if grep -qF "$CURRENT_TRACK" "$FAVORITES_FILE" 2>/dev/null; then
                            grep -vF "$CURRENT_TRACK" "$FAVORITES_FILE" > "$FAVORITES_FILE.tmp"
                            mv "$FAVORITES_FILE.tmp" "$FAVORITES_FILE"
                        else
                            echo "$CURRENT_TRACK" >> "$FAVORITES_FILE"
                        fi
                    fi
                    ;;
                
                # Exit
                "x"|"X") break ;;
            esac
        fi
    done
}

# ──────────────────────────────────────────────
# START
# ──────────────────────────────────────────────
main "$@"
