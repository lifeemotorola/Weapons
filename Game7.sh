#!/bin/bash
# ============================================
# ROCK PAPER SCISSORS - Best of Series
# ============================================

PLAYER_SCORE=0
COMPUTER_SCORE=0
ROUND=0

show_art() {
    local choice=$1
    case $choice in
        "ROCK")
            echo "    _______"
            echo "---'   ____)"
            echo "      (_____)"
            echo "      (_____)"
            echo "      (____)"
            echo "---.__(___)  🪨"
            ;;
        "PAPER")
            echo "    _______"
            echo "---'   ____)____"
            echo "          ______)"
            echo "          _______)"
            echo "         _______)"
            echo "---.___________)  📄"
            ;;
        "SCISSORS")
            echo "    _______"
            echo "---'   ____)____"
            echo "          ______)"
            echo "       __________)"
            echo "      (____)"
            echo "---.__(___)  ✂️"
            ;;
    esac
}

get_computer_choice() {
    local r=$((RANDOM % 3))
    case $r in
        0) echo "ROCK" ;;
        1) echo "PAPER" ;;
        2) echo "SCISSORS" ;;
    esac
}

determine_winner() {
    local p=$1
    local c=$2

    if [ "$p" = "$c" ]; then
        echo "DRAW"
    elif [ "$p" = "ROCK" ] && [ "$c" = "SCISSORS" ]; then
        echo "PLAYER"
    elif [ "$p" = "PAPER" ] && [ "$c" = "ROCK" ]; then
        echo "PLAYER"
    elif [ "$p" = "SCISSORS" ] && [ "$c" = "PAPER" ]; then
        echo "PLAYER"
    else
        echo "COMPUTER"
    fi
}

play_game() {
    local wins_needed=$1
    PLAYER_SCORE=0
    COMPUTER_SCORE=0
    ROUND=0

    clear
    echo "╔══════════════════════════════════════╗"
    echo "║    🪨 ROCK PAPER SCISSORS ✂️         ║"
    echo "║      Best of $((wins_needed * 2 - 1)) (First to $wins_needed wins)     ║"
    echo "╚══════════════════════════════════════╝"

    while [ $PLAYER_SCORE -lt $wins_needed ] && [ $COMPUTER_SCORE -lt $wins_needed ]; do
        ROUND=$((ROUND + 1))

        echo ""
        echo "══════════ ROUND $ROUND ══════════"
        echo " Score - You: $PLAYER_SCORE | CPU: $COMPUTER_SCORE"
        echo ""
        echo " Choose your weapon:"
        echo "   1) 🪨  Rock"
        echo "   2) 📄  Paper"
        echo "   3) ✂️   Scissors"
        echo ""

        local valid=false
        local player_choice=""

        while [ "$valid" = false ]; do
            read -p " Your choice (1/2/3): " choice
            case $choice in
                1) player_choice="ROCK"; valid=true ;;
                2) player_choice="PAPER"; valid=true ;;
                3) player_choice="SCISSORS"; valid=true ;;
                *) echo " ❌ Enter 1, 2, or 3!" ;;
            esac
        done

        local computer_choice=$(get_computer_choice)

        echo ""
        echo " ⏳ 3..."
        sleep 0.4
        echo " ⏳ 2..."
        sleep 0.4
        echo " ⏳ 1..."
        sleep 0.4
        echo " 💥 SHOOT!"
        echo ""

        echo " YOUR CHOICE:"
        show_art "$player_choice"
        echo ""
        echo " COMPUTER'S CHOICE:"
        show_art "$computer_choice"
        echo ""

        local result=$(determine_winner "$player_choice" "$computer_choice")

        case $result in
            "PLAYER")
                echo " ✅ You WIN this round! $player_choice beats $computer_choice!"
                PLAYER_SCORE=$((PLAYER_SCORE + 1))
                ;;
            "COMPUTER")
                echo " ❌ You LOSE this round! $computer_choice beats $player_choice!"
                COMPUTER_SCORE=$((COMPUTER_SCORE + 1))
                ;;
            "DRAW")
                echo " 🤝 It's a DRAW! Both chose $player_choice!"
                ;;
        esac

        sleep 1.5
    done

    echo ""
    echo "╔══════════════════════════════════════╗"
    echo "║          FINAL RESULTS               ║"
    echo "╠══════════════════════════════════════╣"
    printf "║   You: %-3d | Computer: %-3d           ║\n" $PLAYER_SCORE $COMPUTER_SCORE
    echo "╠══════════════════════════════════════╣"

    if [ $PLAYER_SCORE -gt $COMPUTER_SCORE ]; then
        echo "║   🏆 YOU ARE THE CHAMPION! 🏆       ║"
    else
        echo "║   🤖 COMPUTER WINS! Try again!      ║"
    fi
    echo "╚══════════════════════════════════════╝"
}

# Main menu
while true; do
    clear
    echo "╔══════════════════════════════════════╗"
    echo "║    🪨 ROCK PAPER SCISSORS ✂️          ║"
    echo "╠══════════════════════════════════════╣"
    echo "║   Select Mode:                       ║"
    echo "║     1) Best of 3 (First to 2)        ║"
    echo "║     2) Best of 5 (First to 3)        ║"
    echo "║     3) Best of 7 (First to 4)        ║"
    echo "║     4) Single Round                   ║"
    echo "║     5) Quit                           ║"
    echo "╚══════════════════════════════════════╝"
    read -p "Choice: " mode

    case $mode in
        1) play_game 2 ;;
        2) play_game 3 ;;
        3) play_game 4 ;;
        4) play_game 1 ;;
        5) echo "Goodbye!"; exit 0 ;;
        *) echo "Invalid!"; sleep 1; continue ;;
    esac

    echo ""
    read -p "Play again? (y/n): " again
    if [ "$again" != "y" ] && [ "$again" != "Y" ]; then
        echo "Thanks for playing!"
        exit 0
    fi
done
