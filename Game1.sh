#!/bin/bash
# ============================================
# GUESS THE NUMBER GAME
# ============================================

clear
echo "╔══════════════════════════════════════╗"
echo "║       GUESS THE NUMBER GAME          ║"
echo "╚══════════════════════════════════════╝"
echo ""

play_game() {
    local max_num=$1
    local max_attempts=$2
    local secret=$((RANDOM % max_num + 1))
    local attempts=0
    local guessed=false

    echo "I'm thinking of a number between 1 and $max_num."
    echo "You have $max_attempts attempts."
    echo "-------------------------------------------"

    while [ $attempts -lt $max_attempts ]; do
        remaining=$((max_attempts - attempts))
        echo ""
        echo "Attempts remaining: $remaining"
        read -p "Enter your guess: " guess

        # Validate input
        if ! [[ "$guess" =~ ^[0-9]+$ ]]; then
            echo "❌ Please enter a valid number!"
            continue
        fi

        attempts=$((attempts + 1))

        if [ "$guess" -eq "$secret" ]; then
            echo ""
            echo "🎉🎉🎉 CORRECT! 🎉🎉🎉"
            echo "The number was $secret!"
            echo "You got it in $attempts attempt(s)!"

            if [ $attempts -eq 1 ]; then
                echo "⭐ LEGENDARY! First try!"
            elif [ $attempts -le 3 ]; then
                echo "⭐ EXCELLENT!"
            elif [ $attempts -le 5 ]; then
                echo "👍 Good job!"
            else
                echo "😅 Close call!"
            fi
            guessed=true
            break
        elif [ "$guess" -lt "$secret" ]; then
            diff=$((secret - guess))
            if [ $diff -le 5 ]; then
                echo "🔥 Too low! But you're VERY close!"
            elif [ $diff -le 15 ]; then
                echo "⬆️  Too low! Getting warmer..."
            else
                echo "⬆️  Too low! Way too low!"
            fi
        else
            diff=$((guess - secret))
            if [ $diff -le 5 ]; then
                echo "🔥 Too high! But you're VERY close!"
            elif [ $diff -le 15 ]; then
                echo "⬇️  Too high! Getting warmer..."
            else
                echo "⬇️  Too high! Way too high!"
            fi
        fi
    done

    if [ "$guessed" = false ]; then
        echo ""
        echo "💀 GAME OVER! You ran out of attempts!"
        echo "The number was: $secret"
    fi
}

# Difficulty selection
while true; do
    echo ""
    echo "Select Difficulty:"
    echo "  1) Easy   (1-50,  10 attempts)"
    echo "  2) Medium (1-100, 7 attempts)"
    echo "  3) Hard   (1-200, 6 attempts)"
    echo "  4) Insane (1-1000, 10 attempts)"
    echo "  5) Quit"
    echo ""
    read -p "Choice: " difficulty

    case $difficulty in
        1) play_game 50 10 ;;
        2) play_game 100 7 ;;
        3) play_game 200 6 ;;
        4) play_game 1000 10 ;;
        5) echo "Goodbye!"; exit 0 ;;
        *) echo "Invalid choice!" ;;
    esac

    echo ""
    read -p "Play again? (y/n): " again
    if [ "$again" != "y" ] && [ "$again" != "Y" ]; then
        echo "Thanks for playing! Goodbye!"
        exit 0
    fi
    clear
done
