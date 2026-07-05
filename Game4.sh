#!/bin/bash
# ============================================
# TIC TAC TOE (vs Computer AI)
# ============================================

declare -a BOARD

init_board() {
    for i in {0..8}; do
        BOARD[$i]=$((i + 1))
    done
}

draw_board() {
    echo ""
    echo "     │     │     "
    echo "  ${BOARD[0]}  │  ${BOARD[1]}  │  ${BOARD[2]}  "
    echo "─────┼─────┼─────"
    echo "  ${BOARD[3]}  │  ${BOARD[4]}  │  ${BOARD[5]}  "
    echo "─────┼─────┼─────"
    echo "  ${BOARD[6]}  │  ${BOARD[7]}  │  ${BOARD[8]}  "
    echo "     │     │     "
    echo ""
}

check_winner() {
    local b=("${BOARD[@]}")
    # Rows
    for i in 0 3 6; do
        if [ "${b[$i]}" = "${b[$((i+1))]}" ] && [ "${b[$((i+1))]}" = "${b[$((i+2))]}" ]; then
            echo "${b[$i]}"
            return
        fi
    done
    # Columns
    for i in 0 1 2; do
        if [ "${b[$i]}" = "${b[$((i+3))]}" ] && [ "${b[$((i+3))]}" = "${b[$((i+6))]}" ]; then
            echo "${b[$i]}"
            return
        fi
    done
    # Diagonals
    if [ "${b[0]}" = "${b[4]}" ] && [ "${b[4]}" = "${b[8]}" ]; then
        echo "${b[0]}"
        return
    fi
    if [ "${b[2]}" = "${b[4]}" ] && [ "${b[4]}" = "${b[6]}" ]; then
        echo "${b[2]}"
        return
    fi
    echo ""
}

is_board_full() {
    for i in {0..8}; do
        if [ "${BOARD[$i]}" != "X" ] && [ "${BOARD[$i]}" != "O" ]; then
            return 1
        fi
    done
    return 0
}

computer_move() {
    local mark="O"
    local opp="X"

    # 1. Try to win
    for i in {0..8}; do
        if [ "${BOARD[$i]}" != "X" ] && [ "${BOARD[$i]}" != "O" ]; then
            local saved=${BOARD[$i]}
            BOARD[$i]="O"
            local winner=$(check_winner)
            BOARD[$i]=$saved
            if [ "$winner" = "O" ]; then
                BOARD[$i]="O"
                return
            fi
        fi
    done

    # 2. Block player
    for i in {0..8}; do
        if [ "${BOARD[$i]}" != "X" ] && [ "${BOARD[$i]}" != "O" ]; then
            local saved=${BOARD[$i]}
            BOARD[$i]="X"
            local winner=$(check_winner)
            BOARD[$i]=$saved
            if [ "$winner" = "X" ]; then
                BOARD[$i]="O"
                return
            fi
        fi
    done

    # 3. Take center
    if [ "${BOARD[4]}" != "X" ] && [ "${BOARD[4]}" != "O" ]; then
        BOARD[4]="O"
        return
    fi

    # 4. Take corners
    for i in 0 2 6 8; do
        if [ "${BOARD[$i]}" != "X" ] && [ "${BOARD[$i]}" != "O" ]; then
            BOARD[$i]="O"
            return
        fi
    done

    # 5. Take any available
    for i in {0..8}; do
        if [ "${BOARD[$i]}" != "X" ] && [ "${BOARD[$i]}" != "O" ]; then
            BOARD[$i]="O"
            return
        fi
    done
}

play_game() {
    init_board
    local current_player="X"
    local winner=""

    clear
    echo "╔══════════════════════════════════════╗"
    echo "║       ❌ TIC TAC TOE ⭕             ║"
    echo "║    You are X, Computer is O          ║"
    echo "╚══════════════════════════════════════╝"

    while true; do
        draw_board

        winner=$(check_winner)
        if [ -n "$winner" ]; then
            if [ "$winner" = "X" ]; then
                echo "🎉 YOU WIN! Congratulations! 🎉"
            else
                echo "🤖 Computer wins! Better luck next time!"
            fi
            break
        fi

        if is_board_full; then
            echo "🤝 It's a DRAW!"
            break
        fi

        if [ "$current_player" = "X" ]; then
            read -p "Your move (1-9): " move

            if ! [[ "$move" =~ ^[1-9]$ ]]; then
                echo "❌ Invalid! Enter 1-9."
                sleep 1
                clear
                echo "╔══════════════════════════════════════╗"
                echo "║       ❌ TIC TAC TOE ⭕             ║"
                echo "╚══════════════════════════════════════╝"
                continue
            fi

            local idx=$((move - 1))
            if [ "${BOARD[$idx]}" = "X" ] || [ "${BOARD[$idx]}" = "O" ]; then
                echo "❌ That spot is taken!"
                sleep 1
                clear
                echo "╔══════════════════════════════════════╗"
                echo "║       ❌ TIC TAC TOE ⭕             ║"
                echo "╚══════════════════════════════════════╝"
                continue
            fi

            BOARD[$idx]="X"
            current_player="O"
        else
            echo "🤖 Computer is thinking..."
            sleep 0.7
            computer_move
            current_player="X"
        fi

        clear
        echo "╔══════════════════════════════════════╗"
        echo "║       ❌ TIC TAC TOE ⭕             ║"
        echo "╚══════════════════════════════════════╝"
    done
}

# Main loop
while true; do
    play_game
    echo ""
    read -p "Play again? (y/n): " again
    if [ "$again" != "y" ] && [ "$again" != "Y" ]; then
        echo "Thanks for playing!"
        exit 0
    fi
done
