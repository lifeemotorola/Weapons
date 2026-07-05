#!/bin/bash
# ============================================
# MAZE RUNNER GAME
# ============================================

declare -a MAZE
MAZE_W=0
MAZE_H=0
PLAYER_X=0
PLAYER_Y=0
EXIT_X=0
EXIT_Y=0
MOVES=0

load_maze() {
    local level=$1

    case $level in
        1)
            MAZE_H=9
            MAZE_W=21
            MAZE[0]="█████████████████████"
            MAZE[1]="█P  █     █         █"
            MAZE[2]="███ █ ███ █ ███████ █"
            MAZE[3]="█   █   █ █       █ █"
            MAZE[4]="█ █████ █ ███████ █ █"
            MAZE[5]="█       █       █   █"
            MAZE[6]="█ ███████████ █████ █"
            MAZE[7]="█                 E █"
            MAZE[8]="█████████████████████"
            ;;
        2)
            MAZE_H=11
            MAZE_W=25
            MAZE[0]="█████████████████████████"
            MAZE[1]="█P  █           █     █ █"
            MAZE[2]="███ █ █████████ █ ███ █ █"
            MAZE[3]="█   █ █       █   █ █   █"
            MAZE[4]="█ ███ █ █████ █████ ███ █"
            MAZE[5]="█     █     █       █   █"
            MAZE[6]="█████████ █ █████████ ███"
            MAZE[7]="█         █ █       █   █"
            MAZE[8]="█ █████████ █ █████ ███ █"
            MAZE[9]="█                     E █"
            MAZE[10]="█████████████████████████"
            ;;
        3)
            MAZE_H=13
            MAZE_W=29
            MAZE[0]="█████████████████████████████"
            MAZE[1]="█P    █     █     █       █ █"
            MAZE[2]="█ ███ █ ███ █ ███ █ █████ █ █"
            MAZE[3]="█ █   █ █     █   █ █     █ █"
            MAZE[4]="█ █ ███ █████ █ ███ █ █████ █"
            MAZE[5]="█ █         █ █     █       █"
            MAZE[6]="█ █████████ █ ███████████ ███"
            MAZE[7]="█     █     █   █     █     █"
            MAZE[8]="█████ █ █████ █ █ ███ █ ███ █"
            MAZE[9]="█     █       █   █   █ █   █"
            MAZE[10]="█ ███████████████ █ ███ █ ███"
            MAZE[11]="█                 █       E █"
            MAZE[12]="█████████████████████████████"
            ;;
    esac

    # Find player and exit positions
    for ((y = 0; y < MAZE_H; y++)); do
        local line="${MAZE[$y]}"
        for ((x = 0; x < MAZE_W; x++)); do
            local ch="${line:$x:1}"
            if [ "$ch" = "P" ]; then
                PLAYER_X=$x
                PLAYER_Y=$y
                # Replace P with space in maze
                MAZE[$y]="${line:0:$x} ${line:$((x+1))}"
            elif [ "$ch" = "E" ]; then
                EXIT_X=$x
                EXIT_Y=$y
            fi
        done
    done

    MOVES=0
}

draw_maze() {
    printf "\033[H"
    echo "╔═══════════════════════════════════════╗"
    echo "║        🏃 MAZE RUNNER 🏃              ║"
    echo "╚═══════════════════════════════════════╝"
    echo ""

    for ((y = 0; y < MAZE_H; y++)); do
        local line="${MAZE[$y]}"
        local output=""
        for ((x = 0; x < MAZE_W; x++)); do
            if [ $x -eq $PLAYER_X ] && [ $y -eq $PLAYER_Y ]; then
                output+="@"
            else
                local ch="${line:$x:1}"
                if [ "$ch" = "E" ]; then
                    output+="◆"
                else
                    output+="$ch"
                fi
            fi
        done
        echo " $output"
    done

    echo ""
    echo " Moves: $MOVES | WASD to move | Q to quit"
    echo " @ = You | ◆ = Exit"
}

play_maze() {
    local level=$1
    load_maze $level

    stty -echo -icanon min 1 time 0
    clear

    while true; do
        draw_maze

        # Check win
        if [ $PLAYER_X -eq $EXIT_X ] && [ $PLAYER_Y -eq $EXIT_Y ]; then
            stty sane
            echo ""
            echo " 🎉🎉🎉 YOU ESCAPED! 🎉🎉🎉"
            echo " Completed in $MOVES moves!"
            return 0
        fi

        local key
        read -rsn1 key

        local new_x=$PLAYER_X
        local new_y=$PLAYER_Y

        case "$key" in
            w|W) new_y=$((PLAYER_Y - 1)) ;;
            s|S) new_y=$((PLAYER_Y + 1)) ;;
            a|A) new_x=$((PLAYER_X - 1)) ;;
            d|D) new_x=$((PLAYER_X + 1)) ;;
            q|Q) stty sane; return 1 ;;
            *) continue ;;
        esac

        # Boundary check
        if [ $new_x -lt 0 ] || [ $new_x -ge $MAZE_W ] || \
           [ $new_y -lt 0 ] || [ $new_y -ge $MAZE_H ]; then
            continue
        fi

        # Wall check
        local target="${MAZE[$new_y]:$new_x:1}"
        if [ "$target" != "█" ]; then
            PLAYER_X=$new_x
            PLAYER_Y=$new_y
            MOVES=$((MOVES + 1))
        fi
    done
}

# Main menu
while true; do
    clear
    echo "╔══════════════════════════════════════╗"
    echo "║        🏃 MAZE RUNNER 🏃             ║"
    echo "╠══════════════════════════════════════╣"
    echo "║  Navigate through the maze!          ║"
    echo "║  Use WASD to move, Q to quit         ║"
    echo "╠══════════════════════════════════════╣"
    echo "║  Select Level:                       ║"
    echo "║    1) Easy                           ║"
    echo "║    2) Medium                         ║"
    echo "║    3) Hard                           ║"
    echo "║    4) Quit                           ║"
    echo "╚══════════════════════════════════════╝"
    read -p "Choice: " choice

    case $choice in
        1) play_maze 1 ;;
        2) play_maze 2 ;;
        3) play_maze 3 ;;
        4) echo "Goodbye!"; exit 0 ;;
        *) echo "Invalid!"; sleep 1 ;;
    esac

    echo ""
    read -p "Play again? (y/n): " again
    if [ "$again" != "y" ] && [ "$again" != "Y" ]; then
        echo "Goodbye!"
        exit 0
    fi
done
