#!/bin/bash
# ============================================
# BLACKJACK (21) CARD GAME
# ============================================

declare -a DECK
DECK_POS=0
declare -a PLAYER_HAND
declare -a DEALER_HAND
PLAYER_COUNT=0
DEALER_COUNT=0
BALANCE=1000

create_deck() {
    local suits=("♠" "♥" "♦" "♣")
    local values=("A" "2" "3" "4" "5" "6" "7" "8" "9" "10" "J" "Q" "K")
    local idx=0

    for s in "${suits[@]}"; do
        for v in "${values[@]}"; do
            DECK[$idx]="${v}${s}"
            idx=$((idx + 1))
        done
    done

    # Shuffle (Fisher-Yates)
    for ((i = 51; i > 0; i--)); do
        local j=$((RANDOM % (i + 1)))
        local temp=${DECK[$i]}
        DECK[$i]=${DECK[$j]}
        DECK[$j]=$temp
    done

    DECK_POS=0
}

deal_card() {
    local card=${DECK[$DECK_POS]}
    DECK_POS=$((DECK_POS + 1))
    echo "$card"
}

card_value() {
    local card=$1
    local val="${card%[♠♥♦♣]}"

    case $val in
        A) echo 11 ;;
        K|Q|J) echo 10 ;;
        *) echo "$val" ;;
    esac
}

hand_total() {
    local -n hand_ref=$1
    local count=$2
    local total=0
    local aces=0

    for ((i = 0; i < count; i++)); do
        local val=$(card_value "${hand_ref[$i]}")
        total=$((total + val))
        if [[ "${hand_ref[$i]}" == A* ]]; then
            aces=$((aces + 1))
        fi
    done

    # Adjust for aces
    while [ $total -gt 21 ] && [ $aces -gt 0 ]; do
        total=$((total - 10))
        aces=$((aces - 1))
    done

    echo $total
}

display_card() {
    local card=$1
    printf "[%s]" "$card"
}

show_hands() {
    local show_dealer=$1

    echo ""
    echo "  ┌─────────────────────────────────┐"
    echo "  │  DEALER'S HAND:                  │"
    echo -n "  │  "

    if [ "$show_dealer" = true ]; then
        for ((i = 0; i < DEALER_COUNT; i++)); do
            display_card "${DEALER_HAND[$i]}"
            echo -n " "
        done
        local dt=$(hand_total DEALER_HAND $DEALER_COUNT)
        echo ""
        echo "  │  Total: $dt"
    else
        display_card "${DEALER_HAND[0]}"
        echo -n " [??] "
        echo ""
        echo "  │  Total: ??"
    fi

    echo "  ├─────────────────────────────────┤"
    echo "  │  YOUR HAND:                      │"
    echo -n "  │  "

    for ((i = 0; i < PLAYER_COUNT; i++)); do
        display_card "${PLAYER_HAND[$i]}"
        echo -n " "
    done

    local pt=$(hand_total PLAYER_HAND $PLAYER_COUNT)
    echo ""
    echo "  │  Total: $pt"
    echo "  └─────────────────────────────────┘"
    echo ""
}

play_round() {
    local bet=$1

    create_deck

    # Reset hands
    PLAYER_COUNT=0
    DEALER_COUNT=0

    # Deal initial cards
    PLAYER_HAND[0]=$(deal_card)
    DEALER_HAND[0]=$(deal_card)
    PLAYER_HAND[1]=$(deal_card)
    DEALER_HAND[1]=$(deal_card)
    PLAYER_COUNT=2
    DEALER_COUNT=2

    local player_total=$(hand_total PLAYER_HAND $PLAYER_COUNT)

    # Check for natural blackjack
    if [ $player_total -eq 21 ]; then
        show_hands true
        echo "  🎰 BLACKJACK! You win \$$((bet * 3 / 2))!"
        BALANCE=$((BALANCE + bet * 3 / 2))
        return
    fi

    # Player's turn
    while true; do
        show_hands false
        player_total=$(hand_total PLAYER_HAND $PLAYER_COUNT)

        if [ $player_total -gt 21 ]; then
            echo "  💥 BUST! You went over 21!"
            echo "  You lose \$$bet"
            BALANCE=$((BALANCE - bet))
            return
        fi

        if [ $player_total -eq 21 ]; then
            echo "  21! Standing automatically."
            break
        fi

        echo "  Bet: \$$bet | Balance: \$$BALANCE"
        echo "  [H]it or [S]tand?"
        read -p "  > " action

        case "$action" in
            h|H)
                PLAYER_HAND[$PLAYER_COUNT]=$(deal_card)
                PLAYER_COUNT=$((PLAYER_COUNT + 1))
                clear
                echo "╔══════════════════════════════════════╗"
                echo "║          🃏 BLACKJACK 🃏             ║"
                echo "╚══════════════════════════════════════╝"
                ;;
            s|S)
                break
                ;;
            *)
                echo "  Enter H or S"
                sleep 0.5
                clear
                echo "╔══════════════════════════════════════╗"
                echo "║          🃏 BLACKJACK 🃏             ║"
                echo "╚══════════════════════════════════════╝"
                ;;
        esac
    done

    # Dealer's turn
    player_total=$(hand_total PLAYER_HAND $PLAYER_COUNT)

    echo ""
    echo "  🤖 Dealer's turn..."
    sleep 1

    while true; do
        local dealer_total=$(hand_total DEALER_HAND $DEALER_COUNT)
        if [ $dealer_total -ge 17 ]; then
            break
        fi
        DEALER_HAND[$DEALER_COUNT]=$(deal_card)
        DEALER_COUNT=$((DEALER_COUNT + 1))
        echo "  Dealer hits..."
        sleep 0.7
    done

    local dealer_total=$(hand_total DEALER_HAND $DEALER_COUNT)

    clear
    echo "╔══════════════════════════════════════╗"
    echo "║          🃏 BLACKJACK 🃏             ║"
    echo "╚══════════════════════════════════════╝"
    show_hands true

    if [ $dealer_total -gt 21 ]; then
        echo "  🎉 Dealer BUSTS! You win \$$bet!"
        BALANCE=$((BALANCE + bet))
    elif [ $player_total -gt $dealer_total ]; then
        echo "  🎉 You WIN! +\$$bet!"
        BALANCE=$((BALANCE + bet))
    elif [ $player_total -lt $dealer_total ]; then
        echo "  😞 Dealer wins. -\$$bet"
        BALANCE=$((BALANCE - bet))
    else
        echo "  🤝 PUSH! It's a tie. Bet returned."
    fi
}

# Main game loop
clear
echo "╔══════════════════════════════════════╗"
echo "║          🃏 BLACKJACK 🃏              ║"
echo "║      Try to get close to 21!         ║"
echo "║      Starting balance: \$1000         ║"
echo "╚══════════════════════════════════════╝"
echo ""
read -p "Press Enter to start..."

while true; do
    if [ $BALANCE -le 0 ]; then
        echo ""
        echo "  💸 You're BROKE! Game over!"
        echo "  Final balance: \$$BALANCE"
        exit 0
    fi

    clear
    echo "╔══════════════════════════════════════╗"
    echo "║          🃏 BLACKJACK 🃏             ║"
    echo "╚══════════════════════════════════════╝"
    echo ""
    echo "  💰 Balance: \$$BALANCE"
    echo ""

    local valid_bet=false
    local bet=0

    while [ "$valid_bet" = false ]; do
        read -p "  Place your bet (or 'q' to quit): " bet_input

        if [ "$bet_input" = "q" ] || [ "$bet_input" = "Q" ]; then
            echo ""
            echo "  Final balance: \$$BALANCE"
            echo "  Thanks for playing!"
            exit 0
        fi

        if ! [[ "$bet_input" =~ ^[0-9]+$ ]]; then
            echo "  ❌ Enter a valid number!"
            continue
        fi

        bet=$bet_input

        if [ $bet -le 0 ]; then
            echo "  ❌ Minimum bet is \$1!"
        elif [ $bet -gt $BALANCE ]; then
            echo "  ❌ You only have \$$BALANCE!"
        else
            valid_bet=true
        fi
    done

    clear
    echo "╔══════════════════════════════════════╗"
    echo "║          🃏 BLACKJACK 🃏             ║"
    echo "╚══════════════════════════════════════╝"

    play_round $bet

    echo ""
    echo "  💰 Balance: \$$BALANCE"
    echo ""
    read -p "  Press Enter to continue..."
done
