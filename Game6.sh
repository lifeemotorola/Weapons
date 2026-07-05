#!/bin/bash
# ============================================
# TRIVIA QUIZ GAME
# ============================================

declare -a QUESTIONS
declare -a OPTIONS_A
declare -a OPTIONS_B
declare -a OPTIONS_C
declare -a OPTIONS_D
declare -a ANSWERS

# Questions database
QUESTIONS[0]="What does CPU stand for?"
OPTIONS_A[0]="Central Processing Unit"
OPTIONS_B[0]="Central Program Utility"
OPTIONS_C[0]="Computer Personal Unit"
OPTIONS_D[0]="Central Processor Unifier"
ANSWERS[0]="A"

QUESTIONS[1]="Which planet is known as the Red Planet?"
OPTIONS_A[1]="Venus"
OPTIONS_B[1]="Jupiter"
OPTIONS_C[1]="Mars"
OPTIONS_D[1]="Saturn"
ANSWERS[1]="C"

QUESTIONS[2]="What is the largest ocean on Earth?"
OPTIONS_A[2]="Atlantic Ocean"
OPTIONS_B[2]="Pacific Ocean"
OPTIONS_C[2]="Indian Ocean"
OPTIONS_D[2]="Arctic Ocean"
ANSWERS[2]="B"

QUESTIONS[3]="Who created Linux?"
OPTIONS_A[3]="Bill Gates"
OPTIONS_B[3]="Steve Jobs"
OPTIONS_C[3]="Dennis Ritchie"
OPTIONS_D[3]="Linus Torvalds"
ANSWERS[3]="D"

QUESTIONS[4]="What year was the first iPhone released?"
OPTIONS_A[4]="2005"
OPTIONS_B[4]="2007"
OPTIONS_C[4]="2009"
OPTIONS_D[4]="2006"
ANSWERS[4]="B"

QUESTIONS[5]="What does HTML stand for?"
OPTIONS_A[5]="Hyper Text Markup Language"
OPTIONS_B[5]="High Tech Modern Language"
OPTIONS_C[5]="Hyper Transfer Mode Link"
OPTIONS_D[5]="Home Tool Markup Language"
ANSWERS[5]="A"

QUESTIONS[6]="Which gas do plants absorb from the atmosphere?"
OPTIONS_A[6]="Oxygen"
OPTIONS_B[6]="Nitrogen"
OPTIONS_C[6]="Carbon Dioxide"
OPTIONS_D[6]="Hydrogen"
ANSWERS[6]="C"

QUESTIONS[7]="How many bits are in a byte?"
OPTIONS_A[7]="4"
OPTIONS_B[7]="8"
OPTIONS_C[7]="16"
OPTIONS_D[7]="32"
ANSWERS[7]="B"

QUESTIONS[8]="What is the chemical symbol for Gold?"
OPTIONS_A[8]="Go"
OPTIONS_B[8]="Gd"
OPTIONS_C[8]="Au"
OPTIONS_D[8]="Ag"
ANSWERS[8]="C"

QUESTIONS[9]="Which programming language is named after a type of coffee?"
OPTIONS_A[9]="Python"
OPTIONS_B[9]="Java"
OPTIONS_C[9]="C++"
OPTIONS_D[9]="Ruby"
ANSWERS[9]="B"

QUESTIONS[10]="What is the speed of light approximately?"
OPTIONS_A[10]="300,000 km/s"
OPTIONS_B[10]="150,000 km/s"
OPTIONS_C[10]="500,000 km/s"
OPTIONS_D[10]="100,000 km/s"
ANSWERS[10]="A"

QUESTIONS[11]="Which company developed Android?"
OPTIONS_A[11]="Apple"
OPTIONS_B[11]="Microsoft"
OPTIONS_C[11]="Google"
OPTIONS_D[11]="Samsung"
ANSWERS[11]="C"

QUESTIONS[12]="What is the smallest prime number?"
OPTIONS_A[12]="0"
OPTIONS_B[12]="1"
OPTIONS_C[12]="2"
OPTIONS_D[12]="3"
ANSWERS[12]="C"

QUESTIONS[13]="What does RAM stand for?"
OPTIONS_A[13]="Read Access Memory"
OPTIONS_B[13]="Random Access Memory"
OPTIONS_C[13]="Rapid Access Module"
OPTIONS_D[13]="Run Active Memory"
ANSWERS[13]="B"

QUESTIONS[14]="Which element has the atomic number 1?"
OPTIONS_A[14]="Helium"
OPTIONS_B[14]="Oxygen"
OPTIONS_C[14]="Carbon"
OPTIONS_D[14]="Hydrogen"
ANSWERS[14]="D"

play_quiz() {
    local total=${#QUESTIONS[@]}
    local num_questions=10
    local score=0
    local question_num=0

    # Shuffle questions (pick random indices)
    local indices=()
    local used=()

    while [ ${#indices[@]} -lt $num_questions ]; do
        local r=$((RANDOM % total))
        local already=false
        for u in "${used[@]}"; do
            if [ "$u" -eq "$r" ]; then
                already=true
                break
            fi
        done
        if [ "$already" = false ]; then
            indices+=($r)
            used+=($r)
        fi
    done

    clear
    echo "╔══════════════════════════════════════╗"
    echo "║        🧠 TRIVIA QUIZ GAME 🧠       ║"
    echo "║       $num_questions Questions - Good Luck!     ║"
    echo "╚══════════════════════════════════════╝"

    for idx in "${indices[@]}"; do
        question_num=$((question_num + 1))
        echo ""
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo " Question $question_num of $num_questions"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""
        echo " ${QUESTIONS[$idx]}"
        echo ""
        echo "   A) ${OPTIONS_A[$idx]}"
        echo "   B) ${OPTIONS_B[$idx]}"
        echo "   C) ${OPTIONS_C[$idx]}"
        echo "   D) ${OPTIONS_D[$idx]}"
        echo ""

        local valid=false
        while [ "$valid" = false ]; do
            read -p " Your answer (A/B/C/D): " answer
            answer=$(echo "$answer" | tr '[:lower:]' '[:upper:]')
            if [[ "$answer" =~ ^[ABCD]$ ]]; then
                valid=true
            else
                echo " ❌ Please enter A, B, C, or D!"
            fi
        done

        if [ "$answer" = "${ANSWERS[$idx]}" ]; then
            echo " ✅ CORRECT! 🎉"
            score=$((score + 1))
        else
            echo " ❌ WRONG! The answer was: ${ANSWERS[$idx]}"
        fi

        sleep 1
    done

    echo ""
    echo "╔══════════════════════════════════════╗"
    echo "║          QUIZ COMPLETE!              ║"
    echo "╠══════════════════════════════════════╣"
    local pct=$((score * 100 / num_questions))
    printf "║  Score: %d/%d (%d%%)                   ║\n" $score $num_questions $pct
    echo "╠══════════════════════════════════════╣"

    if [ $pct -ge 90 ]; then
        echo "║  🏆 GENIUS! Outstanding!             ║"
    elif [ $pct -ge 70 ]; then
        echo "║  ⭐ Great job! Well done!             ║"
    elif [ $pct -ge 50 ]; then
        echo "║  👍 Not bad! Keep learning!           ║"
    else
        echo "║  📚 Study more and try again!         ║"
    fi
    echo "╚══════════════════════════════════════╝"
}

# Main loop
while true; do
    play_quiz
    echo ""
    read -p "Play again? (y/n): " again
    if [ "$again" != "y" ] && [ "$again" != "Y" ]; then
        echo "Thanks for playing!"
        exit 0
    fi
done
