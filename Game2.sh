#!/bin/bash
# ============================================
# SNAKE GAME
# ============================================

# Game settings
WIDTH=30
HEIGHT=15
DELAY=0.15

# Snake data
declare -a SNAKE_X
declare -a SNAKE_Y
SNAKE_LEN=3
DIR="RIGHT"
NEXT_DIR="RIGHT"
SCORE=0
GAME_OVER=false
FOOD_X=0
FOOD_Y=0

init_game() {
    SNAKE_LEN=3
    DIR="RIGHT"
    NEXT_DIR="RIGHT"
    SCORE=0
    GAME_OVER=false

    # Initialize snake in the middle
    local start_x=$((WIDTH / 2))
    local start_y=$((HEIGHT / 2))

    for ((i = 0; i < SNAKE_LEN; i++)); do
        SNAKE_X[$i]=$((start_x - i))
        SNAKE_Y[$i]=$start_y
    done

    place_food
}

place_food() {
    while true; do
        FOOD_X=$((RANDOM % (WIDTH - 2) + 1))
        FOOD_Y=$((RANDOM % (HEIGHT - 2) + 1))

        local on_snake=false
        for ((i = 0; i < SNAKE_LEN; i++)); do
            if [ ${SNAKE_X[$i]} -eq $FOOD_X ] && [ ${SNAKE_Y[$i]} -eq $FOOD_Y ]; then
                on_snake=true
                break
            fi
        done

        if [ "$on_snake" = false ]; then
            break
        fi
    done
}

draw() {
    local screen=""

    # Build the board
    for ((y = 0; y < HEIGHT; y++)); do
        for ((x = 0; x < WIDTH; x++)); do
            if [ $y -eq 0 ] || [ $y -eq $((HEIGHT - 1)) ]; then
                screen+="█"
            elif [ $x -eq 0 ] || [ $x -eq $((WIDTH - 1)) ]; then
                screen+="█"
            elif [ $x -eq $FOOD_X ] && [ $y -eq $FOOD_Y ]; then
                screen+="◆"
            else
                local is_snake=false
                for ((i = 0; i < SNAKE_LEN; i++)); do
                    if [ ${SNAKE_X[$i]} -eq $x ] && [ ${SNAKE_Y[$i]} -eq $y ]; then
                        if [ $i -eq 0 ]; then
                            screen+="@"
                        else
                            screen+="○"
                        fi
                        is_snake=true
                        break
                    fi
                done
                if [ "$is_snake" = false ]; then
                    screen+=" "
                fi
            fi
        done
        screen+="\n"
    done

    printf "\033[H"
    echo -e "$screen"
    echo " Score: $SCORE | WASD to move | Q to quit"
}

update() {
    DIR="$NEXT_DIR"

    # Calculate new head position
    local new_x=${SNAKE_X[0]}
    local new_y=${SNAKE_Y[0]}

    case $DIR in
        UP)    new_y=$((new_y - 1)) ;;
        DOWN)  new_y=$((new_y + 1)) ;;
        LEFT)  new_x=$((new_x - 1)) ;;
        RIGHT) new_x=$((new_x + 1)) ;;
    esac

    # Check wall collision
    if [ $new_x -le 0 ] || [ $new_x -ge $((WIDTH - 1)) ] || \
       [ $new_y -le 0 ] || [ $new_y -ge $((HEIGHT - 1)) ]; then
        GAME_OVER=true
        return
    fi

    # Check self collision
    for ((i = 0; i < SNAKE_LEN; i++)); do
        if [ ${SNAKE_X[$i]} -eq $new_x ] && [ ${SNAKE_Y[$i]} -eq $new_y ]; then
            GAME_OVER=true
            return
        fi
    done

    # Check food
    local ate=false
    if [ $new_x -eq $FOOD_X ] && [ $new_y -eq $FOOD_Y ]; then
        ate=true
        SCORE=$((SCORE + 10))
    fi

    # Move snake: shift body
    if [ "$ate" = true ]; then
        SNAKE_LEN=$((SNAKE_LEN + 1))
    fi

    for ((i = SNAKE_LEN - 1; i > 0; i--)); do
        SNAKE_X[$i]=${SNAKE_X[$((i - 1))]}
        SNAKE_Y[$i]=${SNAKE_Y[$((i - 1))]}
    done

    SNAKE_X[0]=$new_x
    SNAKE_Y[0]=$new_y

    if [ "$ate" = true ]; then
        place_food
    fi
}

read_input() {
    local key
    read -rsn1 -t $DELAY key 2>/dev/null
    case "$key" in
        w|W) [ "$DIR" != "DOWN" ]  && NEXT_DIR="UP" ;;
        s|S) [ "$DIR" != "UP" ]    && NEXT_DIR="DOWN" ;;
        a|A) [ "$DIR" != "RIGHT" ] && NEXT_DIR="LEFT" ;;
        d|D) [ "$DIR" != "LEFT" ]  && NEXT_DIR="RIGHT" ;;
        q|Q) GAME_OVER=true ;;
    esac
}

# Main
clear
echo "╔══════════════════════════════════════╗"
echo "║           🐍 SNAKE GAME 🐍          ║"
echo "╠══════════════════════════════════════╣"
echo "║  Controls: W A S D to move           ║"
echo "║  Eat ◆ to grow and score             ║"
echo "║  Don't hit walls or yourself!        ║"
echo "║  Press Q to quit                     ║"
echo "╚══════════════════════════════════════╝"
echo ""
read -p "Press Enter to start..."

# Hide cursor
printf "\033[?25l"
trap 'printf "\033[?25h"; stty sane; exit' EXIT INT TERM

stty -echo -icanon min 0 time 0

init_game
clear

while [ "$GAME_OVER" = false ]; do
    draw
    read_input
    update
done

printf "\033[?25h"
stty sane

echo ""
echo "╔══════════════════════════════════════╗"
echo "║           GAME OVER!                 ║"
echo "║       Final Score: $(printf '%-18s' "$SCORE")║"
echo "╚══════════════════════════════════════╝"
