#!/bin/bash
# ============================================
# HANGMAN GAME
# ============================================

WORDS=(
    "terminal" "android" "python" "keyboard" "function"
    "variable" "script" "kernel" "server" "network"
    "package" "library" "compile" "execute" "process"
    "browser" "storage" "memory" "display" "battery"
    "hacker" "program" "digital" "system" "update"
    "module" "binary" "cipher" "debug" "encode"
    "github" "linux" "shell" "array" "string"
)

draw_hangman() {
    local wrong=$1
    echo ""
    case $wrong in
        0) echo "  ┌───┐ "
           echo "  │     "
           echo "  │     "
           echo "  │     "
           echo "  │     "
           echo "══╧══   " ;;
        1) echo "  ┌───┐ "
           echo "  │   😐"
           echo "  │     "
           echo "  │     "
           echo "  │     "
           echo "══╧══   " ;;
        2) echo "  ┌───┐ "
           echo "  │   😟"
           echo "  │   │ "
           echo "  │     "
           echo "  │     "
           echo "══╧══   " ;;
        3) echo "  ┌───┐ "
           echo "  │   😟"
           echo "  │  /│ "
           echo "  │     "
           echo "  │     "
           echo "══╧══   " ;;
        4) echo "  ┌───┐ "
           echo "  │   😨"
           echo "  │  /│\\"
           echo "  │     "
           echo "  │     "
           echo "══╧══   " ;;
        5) echo "  ┌───┐ "
           echo "  │   😰"
           echo "  │  /│\\"
           echo "  │  /  "
           echo "  │     "
           echo "══╧══   " ;;
        6) echo "  ┌───┐ "
           echo "  │   💀"
           echo "  │  /│\\"
           echo "  │  / \\"
           echo "  │     "
           echo "══╧══   " ;;
    esac
    echo ""
}

play_hangman() {
    local word=${WORDS[$((RANDOM % ${#WORDS[@]}))]}
    local word_upper=$(echo "$word" | tr '[:lower:]' '[:upper:]')
    local word_len=${#word}
    local guessed=""
    local wrong=0
    local max_wrong=6
    local display=""
    local used_letters=""
    local won=false

    clear
    echo "╔══════════════════════════════════════╗"
    echo "║          🎯 HANGMAN GAME 🎯          ║"
    echo "╚══════════════════════════════════════╝"

    while [ $wrong -lt $max_wrong ]; do
        # Build display word
        display=""
        local all_found=true
        for ((i = 0; i < word_len; i++)); do
            local c="${word:$i:1}"
            if [[ "$guessed" == *"$c"* ]]; then
                display+="$(echo "$c" | tr '[:lower:]' '[:upper:]') "
            else
                display+="_ "
                all_found=false
            fi
        done

        echo ""
        draw_hangman $wrong
        echo "  Word: $display"
        echo ""
        echo "  Wrong guesses: $wrong / $max_wrong"
        echo "  Used letters: $used_letters"
        echo ""

        if [ "$all_found" = true ]; then
            won=true
            break
        fi

        read -p "  Guess a letter: " -n1 letter
        echo ""

        # Validate
        letter=$(echo "$letter" | tr '[:upper:]' '[:lower:]')
        if ! [[ "$letter" =~ ^[a-z]$ ]]; then
            echo "  ❌ Please enter a letter (a-z)!"
            sleep 1
            clear
            echo "╔══════════════════════════════════════╗"
            echo "║          🎯 HANGMAN GAME 🎯          ║"
            echo "╚══════════════════════════════════════╝"
            continue
        fi

        if [[ "$guessed" == *"$letter"* ]] || [[ "$used_letters" == *"$(echo $letter | tr '[:lower:]' '[:upper:]')"* ]]; then
            echo "  ⚠️  You already guessed '$letter'!"
            sleep 1
            clear
            echo "╔══════════════════════════════════════╗"
            echo "║          🎯 HANGMAN GAME 🎯          ║"
            echo "╚══════════════════════════════════════╝"
            continue
        fi

        used_letters+="$(echo $letter | tr '[:lower:]' '[:upper:]') "

        if [[ "$word" == *"$letter"* ]]; then
            guessed+="$letter"
            echo "  ✅ Correct!"
        else
            wrong=$((wrong + 1))
            echo "  ❌ Wrong!"
        fi

        sleep 0.5
        clear
        echo "╔══════════════════════════════════════╗"
        echo "║          🎯 HANGMAN GAME 🎯          ║"
        echo "╚══════════════════════════════════════╝"
    done

    echo ""
    if [ "$won" = true ]; then
        echo "  🎉🎉🎉 CONGRATULATIONS! 🎉🎉🎉"
        echo "  You guessed the word: $word_upper"
        echo "  Wrong guesses: $wrong"
    else
        draw_hangman 6
        echo "  💀 GAME OVER! 💀"
        echo "  The word was: $word_upper"
    fi
}

# Main loop
while true; do
    play_hangman
    echo ""
    read -p "  Play again? (y/n): " again
    if [ "$again" != "y" ] && [ "$again" != "Y" ]; then
        echo "  Thanks for playing! Goodbye!"
        exit 0
    fi
done
