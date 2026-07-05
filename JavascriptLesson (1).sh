#!/data/data/com.termux/files/usr/bin/bash

#=====================================================
# COMPLETE JAVASCRIPT LESSON FOR TERMUX
# File: js_lesson.sh
# Usage: chmod +x js_lesson.sh && ./js_lesson.sh
#=====================================================

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
BOLD='\033[1m'
UNDERLINE='\033[4m'
NC='\033[0m' # No Color

# Counters
TOTAL_EXERCISES=0
CORRECT_ANSWERS=0
CHALLENGES_WON=0

# Persistence Settings
PROGRESS_FILE="$HOME/.js_lesson_progress"
declare -A DONE_LESSONS

save_progress() {
    : > "$PROGRESS_FILE"
    echo "TOTAL|$TOTAL_EXERCISES" >> "$PROGRESS_FILE"
    echo "CORRECT|$CORRECT_ANSWERS" >> "$PROGRESS_FILE"
    echo "WON|$CHALLENGES_WON" >> "$PROGRESS_FILE"
    for idx in "${!DONE_LESSONS[@]}"; do
        echo "LESSON|$idx" >> "$PROGRESS_FILE"
    done
}

load_progress() {
    if [ -f "$PROGRESS_FILE" ]; then
        while IFS='|' read -r type val; do
            case "$type" in
                TOTAL) TOTAL_EXERCISES=$val ;;
                CORRECT) CORRECT_ANSWERS=$val ;;
                WON) CHALLENGES_WON=$val ;;
                LESSON) DONE_LESSONS["$val"]=1 ;;
            esac
        done < "$PROGRESS_FILE"
    fi
}

# Directory for lesson files
LESSON_DIR="$HOME/js_lessons"
mkdir -p "$LESSON_DIR"

#=====================================================
# UTILITY FUNCTIONS
#=====================================================

clear_screen() {
    clear
}

press_enter() {
    echo ""
    if [ -z "$1" ]; then
        echo -ne "${YELLOW}Press ENTER to continue, or 'p' for Playground: ${NC}"
        read -r input
        [[ "$input" == "p" || "$input" == "P" ]] && try_it_yourself
    else
        echo -e "${YELLOW}Press ENTER to continue...${NC}"
        read -r
    fi
}

get_rank() {
    local score=$CHALLENGES_WON
    if [ "$score" -ge 50 ]; then echo -e "${MAGENTA}JS Legend 👑${NC}"
    elif [ "$score" -ge 30 ]; then echo -e "${RED}Architect 🏗️${NC}"
    elif [ "$score" -ge 20 ]; then echo -e "${YELLOW}Grandmaster 🥋${NC}"
    elif [ "$score" -ge 10 ]; then echo -e "${BLUE}Senior Dev 💻${NC}"
    elif [ "$score" -ge 5 ]; then echo -e "${GREEN}Adept 🎓${NC}"
    elif [ "$score" -ge 1 ]; then echo -e "${CYAN}Novice 🌟${NC}"
    else echo -e "${WHITE}Unranked 🥚${NC}"; fi
}

is_lesson_unlocked() {
    local idx=$1
    if [ "$idx" -eq 0 ] || [ -n "${DONE_LESSONS[$((idx-1))]}" ]; then
        return 0
    else
        return 1
    fi
}

handle_lesson() {
    local idx=$1
    local func=$2
    if is_lesson_unlocked "$idx"; then
        "$func"
        DONE_LESSONS["$idx"]=1
        save_progress
    else
        echo -e "${RED}🔒 Lesson $idx is locked! Please complete the previous lesson first.${NC}"
        sleep 2
    fi
}

print_header() {
    echo -e "${CYAN}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC} ${BOLD}${WHITE}$1${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

print_subheader() {
    echo -e "${MAGENTA}┌──────────────────────────────────────────────────┐${NC}"
    echo -e "${MAGENTA}│${NC} ${BOLD}$1${NC}"
    echo -e "${MAGENTA}└──────────────────────────────────────────────────┘${NC}"
    echo ""
}

print_code() {
    echo -e "${GREEN}┌─── CODE ──────────────────────────────────────────┐${NC}"
    while IFS= read -r line; do
        echo -e "${GREEN}│${NC}  ${WHITE}$line${NC}"
    done <<< "$1"
    echo -e "${GREEN}└───────────────────────────────────────────────────┘${NC}"
    echo ""
}

print_output() {
    echo -e "${BLUE}┌─── OUTPUT ─────────────────────────────────────────┐${NC}"
    while IFS= read -r line; do
        echo -e "${BLUE}│${NC}  ${YELLOW}$line${NC}"
    done <<< "$1"
    echo -e "${BLUE}└───────────────────────────────────────────────────┘${NC}"
    echo ""
}

print_note() {
    echo -e "${YELLOW}💡 NOTE: $1${NC}"
    echo ""
}

print_tip() {
    echo -e "${CYAN}🔧 TIP: $1${NC}"
    echo ""
}

run_js() {
    local code="$1"
    local file="$LESSON_DIR/temp_lesson.js"
    echo "$code" > "$file"
    node "$file" 2>&1
}

run_and_show() {
    local code="$1"
    print_code "$code"
    echo -e "${BLUE}Output:${NC}"
    local output
    output=$(run_js "$code")
    print_output "$output"
}

quiz() {
    TOTAL_EXERCISES=$((TOTAL_EXERCISES + 1))
    local question="$1"
    local correct="$2"
    local opt1="$3"
    local opt2="$4"
    local opt3="$5"
    local opt4="$6"

    echo -e "${YELLOW}╔═══ QUIZ ═══════════════════════════════════════════╗${NC}"
    echo -e "${YELLOW}║${NC} ${WHITE}$question${NC}"
    echo -e "${YELLOW}╠════════════════════════════════════════════════════╣${NC}"
    echo -e "${YELLOW}║${NC}  ${CYAN}1)${NC} $opt1"
    echo -e "${YELLOW}║${NC}  ${CYAN}2)${NC} $opt2"
    echo -e "${YELLOW}║${NC}  ${CYAN}3)${NC} $opt3"
    echo -e "${YELLOW}║${NC}  ${CYAN}4)${NC} $opt4"
    echo -e "${YELLOW}╚════════════════════════════════════════════════════╝${NC}"
    echo ""

    while true; do
        echo -ne "${WHITE}Your answer (1-4): ${NC}"
        read -r answer
        if [[ "$answer" =~ ^[1-4]$ ]]; then
            break
        fi
        echo -e "${RED}Please enter 1, 2, 3, or 4${NC}"
    done

    if [ "$answer" == "$correct" ]; then
        CORRECT_ANSWERS=$((CORRECT_ANSWERS + 1))
        echo -e "${GREEN}✅ CORRECT! Well done!${NC}"
    else
        echo -e "${RED}❌ WRONG! The correct answer was: $correct${NC}"
    fi
    save_progress
    echo ""
}

coding_challenge() {
    TOTAL_EXERCISES=$((TOTAL_EXERCISES + 1))
    local description="$1"
    local expected_output="$2"
    local hint="$3"

    echo -e "${MAGENTA}╔═══ CODING CHALLENGE ═══════════════════════════════╗${NC}"
    echo -e "${MAGENTA}║${NC} ${WHITE}$description${NC}"
    echo -e "${MAGENTA}║${NC} ${CYAN}Expected output: ${YELLOW}$expected_output${NC}"
    if [ -n "$hint" ]; then
        echo -e "${MAGENTA}║${NC} ${GREEN}Hint: $hint${NC}"
    fi
    echo -e "${MAGENTA}╚════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${WHITE}Write your JavaScript code (type ${CYAN}END${WHITE} on a new line when done):${NC}"

    local code=""
    while IFS= read -r line; do
        if [ "$line" == "END" ]; then
            break
        fi
        code+="$line"$'\n'
    done

    local output
    output=$(run_js "$code")
    local trimmed_output
    trimmed_output=$(echo "$output" | xargs)
    local trimmed_expected
    trimmed_expected=$(echo "$expected_output" | xargs)

    echo ""
    echo -e "${BLUE}Your output: ${YELLOW}$output${NC}"

    if [ "$trimmed_output" == "$trimmed_expected" ]; then
        CORRECT_ANSWERS=$((CORRECT_ANSWERS + 1))
        echo -e "${GREEN}✅ PERFECT! Your code works correctly!${NC}"
        save_progress
        return 0
    else
        echo -e "${RED}❌ Output doesn't match expected. Keep practicing!${NC}"
        save_progress
        return 1
    fi
    echo ""
}

show_progress() {
    local rank=$(get_rank)
    local completed=${#DONE_LESSONS[@]}
    local total=16 # Modules 0-15
    
    # Course Progress Calculation
    local prog_percent=$(( completed * 100 / total ))
    local bar_filled=$(( completed * 20 / total ))
    local bar=$(printf "%${bar_filled}s" | tr ' ' '█')$(printf "%$((20 - bar_filled))s" | tr ' ' '░')

    echo -e "${CYAN}╔═══ USER DASHBOARD ═════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC}  Rank: $rank"
    echo -e "${CYAN}║${NC}  Course: [${GREEN}$bar${NC}] ${prog_percent}% ($completed/$total modules)"
    
    if [ $TOTAL_EXERCISES -gt 0 ]; then
        local accuracy=$((CORRECT_ANSWERS * 100 / TOTAL_EXERCISES))
        echo -e "${CYAN}║${NC}  Accuracy: ${YELLOW}${accuracy}%${NC} (${GREEN}$CORRECT_ANSWERS${NC}/${WHITE}$TOTAL_EXERCISES${NC} exercises)"
    fi
    echo -e "${CYAN}╚════════════════════════════════════════════════════╝${NC}"
    echo ""
}

reset_progress() {
    echo -ne "${RED}Are you sure you want to reset all progress? (y/n): ${NC}"
    read -r confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        TOTAL_EXERCISES=0
        CORRECT_ANSWERS=0
        CHALLENGES_WON=0
        DONE_LESSONS=()
        rm -f "$PROGRESS_FILE"
        echo -e "${GREEN}Progress has been wiped clean!${NC}"
        sleep 1
    fi
}

#=====================================================
# CHECK PREREQUISITES
#=====================================================

check_prerequisites() {
    clear_screen
    print_header "🔍 CHECKING PREREQUISITES"

    echo -e "${WHITE}Checking if Node.js is installed...${NC}"
    echo ""

    if command -v node &> /dev/null; then
        local node_version
        node_version=$(node -v)
        echo -e "${GREEN}✅ Node.js is installed! Version: $node_version${NC}"
        echo ""
    else
        echo -e "${RED}❌ Node.js is NOT installed!${NC}"
        echo ""
        echo -e "${YELLOW}Installing Node.js now...${NC}"
        pkg update -y && pkg install nodejs -y

        if command -v node &> /dev/null; then
            echo -e "${GREEN}✅ Node.js installed successfully!${NC}"
        else
            echo -e "${RED}Failed to install Node.js. Please run:${NC}"
            echo -e "${CYAN}pkg install nodejs${NC}"
            exit 1
        fi
    fi

    press_enter "plain"
}

#=====================================================
# LESSON 0: INTRODUCTION
#=====================================================

lesson_0_introduction() {
    clear_screen
    print_header "📚 COMPLETE JAVASCRIPT COURSE FOR TERMUX"

    echo -e "${WHITE}Welcome to the Complete JavaScript Course!${NC}"
    echo ""
    echo -e "${CYAN}What you will learn:${NC}"
    echo -e "  ${GREEN}📌${NC} Lesson 1:  Variables & Data Types"
    echo -e "  ${GREEN}📌${NC} Lesson 2:  Operators"
    echo -e "  ${GREEN}📌${NC} Lesson 3:  Strings & String Methods"
    echo -e "  ${GREEN}📌${NC} Lesson 4:  Conditional Statements (if/else/switch)"
    echo -e "  ${GREEN}📌${NC} Lesson 5:  Loops (for, while, do-while)"
    echo -e "  ${GREEN}📌${NC} Lesson 6:  Functions"
    echo -e "  ${GREEN}📌${NC} Lesson 7:  Arrays"
    echo -e "  ${GREEN}📌${NC} Lesson 8:  Objects"
    echo -e "  ${GREEN}📌${NC} Lesson 9:  Array Methods (map, filter, reduce)"
    echo -e "  ${GREEN}📌${NC} Lesson 10: Destructuring & Spread Operator"
    echo -e "  ${GREEN}📌${NC} Lesson 11: Classes & OOP"
    echo -e "  ${GREEN}📌${NC} Lesson 12: Promises & Async/Await"
    echo -e "  ${GREEN}📌${NC} Lesson 13: Error Handling"
    echo -e "  ${GREEN}📌${NC} Lesson 14: Modules & File I/O (Node.js)"
    echo -e "  ${GREEN}📌${NC} Lesson 15: Final Project"
    echo ""
    echo -e "${YELLOW}Each lesson includes examples, explanations, quizzes,${NC}"
    echo -e "${YELLOW}and hands-on coding challenges!${NC}"
    echo ""

    press_enter "plain"
}

#=====================================================
# LESSON 1: VARIABLES & DATA TYPES
#=====================================================

lesson_1_variables() {
    clear_screen
    print_header "📖 LESSON 1: VARIABLES & DATA TYPES"

    # --- Section 1: What are Variables? ---
    print_subheader "1.1 What are Variables?"
    echo -e "${WHITE}Variables are containers for storing data values.${NC}"
    echo -e "${WHITE}JavaScript has 3 ways to declare variables:${NC}"
    echo ""
    echo -e "  ${CYAN}var${NC}   - Old way (function-scoped, avoid using)"
    echo -e "  ${CYAN}let${NC}   - Modern way (block-scoped, can be reassigned)"
    echo -e "  ${CYAN}const${NC} - Modern way (block-scoped, cannot be reassigned)"
    echo ""

    run_and_show 'var oldWay = "I am var";
let modern = "I am let";
const constant = "I am const";

console.log(oldWay);
console.log(modern);
console.log(constant);'

    press_enter
    clear_screen

    # --- Section 2: let vs const ---
    print_subheader "1.2 let vs const"
    echo -e "${WHITE}The key difference:${NC}"
    echo -e "  ${CYAN}let${NC}   → value CAN be changed later"
    echo -e "  ${CYAN}const${NC} → value CANNOT be changed later"
    echo ""

    run_and_show 'let age = 25;
console.log("Before:", age);

age = 26;  // This works fine with let
console.log("After:", age);

const name = "John";
console.log("Name:", name);

// name = "Jane";  // This would cause an ERROR!'

    print_note "Always prefer 'const' unless you need to reassign the variable."
    press_enter
    clear_screen

    # --- Section 3: Data Types ---
    print_subheader "1.3 Data Types"
    echo -e "${WHITE}JavaScript has 7 primitive data types:${NC}"
    echo ""
    echo -e "  ${CYAN}1. String${NC}    → Text:        ${YELLOW}\"Hello\"${NC}"
    echo -e "  ${CYAN}2. Number${NC}    → Numbers:     ${YELLOW}42, 3.14${NC}"
    echo -e "  ${CYAN}3. Boolean${NC}   → True/False:  ${YELLOW}true, false${NC}"
    echo -e "  ${CYAN}4. Undefined${NC} → Not assigned: ${YELLOW}undefined${NC}"
    echo -e "  ${CYAN}5. Null${NC}      → Empty value:  ${YELLOW}null${NC}"
    echo -e "  ${CYAN}6. BigInt${NC}    → Large numbers: ${YELLOW}9007199254740991n${NC}"
    echo -e "  ${CYAN}7. Symbol${NC}    → Unique identifier${NC}"
    echo ""

    run_and_show '// String
let greeting = "Hello, Termux!";
console.log(greeting, "→ Type:", typeof greeting);

// Number
let price = 19.99;
console.log(price, "→ Type:", typeof price);

// Boolean
let isLearning = true;
console.log(isLearning, "→ Type:", typeof isLearning);

// Undefined
let notDefined;
console.log(notDefined, "→ Type:", typeof notDefined);

// Null
let empty = null;
console.log(empty, "→ Type:", typeof empty);

// BigInt
let bigNumber = 12345678901234567890n;
console.log(bigNumber, "→ Type:", typeof bigNumber);'

    press_enter
    clear_screen

    # --- Section 4: Type Conversion ---
    print_subheader "1.4 Type Conversion"

    run_and_show '// String to Number
let strNum = "42";
let num = Number(strNum);
console.log(num, typeof num);

// Number to String
let myNum = 100;
let str = String(myNum);
console.log(str, typeof str);

// To Boolean
console.log(Boolean(1));       // true
console.log(Boolean(0));       // false
console.log(Boolean("hello")); // true
console.log(Boolean(""));      // false
console.log(Boolean(null));    // false

// parseInt and parseFloat
console.log(parseInt("42px"));     // 42
console.log(parseFloat("3.14em")); // 3.14'

    press_enter
    clear_screen

    # --- Section 5: Template Literals ---
    print_subheader "1.5 Template Literals (String Interpolation)"

    run_and_show 'const name = "Termux User";
const age = 25;
const language = "JavaScript";

// Old way (concatenation)
console.log("Hello, " + name + "! You are " + age + " years old.");

// New way (template literals) - use backticks!
console.log(`Hello, ${name}! You are ${age} years old.`);
console.log(`You are learning ${language}!`);
console.log(`Next year you will be ${age + 1} years old.`);

// Multi-line strings
const multiLine = `
  This is line 1
  This is line 2
  This is line 3
`;
console.log(multiLine);'

    press_enter
    clear_screen

    # --- Quizzes ---
    print_subheader "📝 LESSON 1 QUIZ"

    quiz "Which keyword creates a variable that CANNOT be reassigned?" \
        "3" \
        "var" \
        "let" \
        "const" \
        "function"

    quiz "What is the type of: typeof 42?" \
        "2" \
        "integer" \
        "number" \
        "Number" \
        "float"

    quiz "What does typeof null return?" \
        "4" \
        "null" \
        "undefined" \
        "boolean" \
        "object"

    quiz "Which syntax is used for template literals?" \
        "1" \
        "Backticks (\`...\`)" \
        "Single quotes ('...')" \
        "Double quotes (\"...\")" \
        "Parentheses ((...))  "

    # --- Coding Challenge ---
    print_subheader "💻 CODING CHALLENGE"
    coding_challenge \
        "Create variables for your name and age, then print: Hi, I am [name] and I am [age] years old" \
        "Hi, I am Termux and I am 10 years old" \
        "Use: const name = 'Termux'; const age = 10; console.log(\`Hi, I am \${name} and I am \${age} years old\`);"

    show_progress
    press_enter
}

#=====================================================
# LESSON 2: OPERATORS
#=====================================================

lesson_2_operators() {
    clear_screen
    print_header "📖 LESSON 2: OPERATORS"

    # --- Arithmetic ---
    print_subheader "2.1 Arithmetic Operators"

    run_and_show 'let a = 10;
let b = 3;

console.log("a + b =", a + b);   // Addition: 13
console.log("a - b =", a - b);   // Subtraction: 7
console.log("a * b =", a * b);   // Multiplication: 30
console.log("a / b =", a / b);   // Division: 3.333...
console.log("a % b =", a % b);   // Modulus (remainder): 1
console.log("a ** b =", a ** b); // Exponentiation: 1000

// Increment & Decrement
let x = 5;
console.log("x++ =", x++);  // Post: prints 5, then becomes 6
console.log("x now =", x);  // 6
console.log("++x =", ++x);  // Pre: becomes 7, then prints 7
console.log("x-- =", x--);  // Post: prints 7, then becomes 6
console.log("--x =", --x);  // Pre: becomes 5, then prints 5'

    press_enter
    clear_screen

    # --- Comparison ---
    print_subheader "2.2 Comparison Operators"

    run_and_show 'console.log("=== COMPARISON OPERATORS ===");
console.log("5 == 5:", 5 == 5);        // true (loose equality)
console.log("5 == \"5\":", 5 == "5");  // true (type coercion!)
console.log("5 === \"5\":", 5 === "5"); // false (strict equality)
console.log("5 === 5:", 5 === 5);      // true
console.log("5 != \"5\":", 5 != "5");  // false
console.log("5 !== \"5\":", 5 !== "5"); // true
console.log("10 > 5:", 10 > 5);        // true
console.log("10 < 5:", 10 < 5);        // false
console.log("5 >= 5:", 5 >= 5);        // true
console.log("4 <= 5:", 4 <= 5);        // true'

    print_note "Always use === (strict equality) instead of == (loose equality)!"
    press_enter
    clear_screen

    # --- Logical ---
    print_subheader "2.3 Logical Operators"

    run_and_show 'console.log("=== LOGICAL OPERATORS ===");
// AND (&&) - both must be true
console.log("true && true:", true && true);     // true
console.log("true && false:", true && false);   // false

// OR (||) - at least one must be true
console.log("true || false:", true || false);   // true
console.log("false || false:", false || false); // false

// NOT (!) - reverses the value
console.log("!true:", !true);   // false
console.log("!false:", !false); // true

// Practical example
let age = 25;
let hasLicense = true;

let canDrive = age >= 18 && hasLicense;
console.log("Can drive:", canDrive); // true

// Nullish coalescing (??)
let username = null;
let displayName = username ?? "Guest";
console.log("Display:", displayName); // Guest

// Optional chaining (?.)
let user = { name: "John", address: { city: "NYC" } };
console.log(user?.address?.city);    // NYC
console.log(user?.phone?.number);    // undefined (no error!)'

    press_enter
    clear_screen

    # --- Assignment ---
    print_subheader "2.4 Assignment Operators"

    run_and_show 'let x = 10;
console.log("x =", x);      // 10

x += 5;   // same as: x = x + 5
console.log("x += 5 →", x); // 15

x -= 3;   // same as: x = x - 3
console.log("x -= 3 →", x); // 12

x *= 2;   // same as: x = x * 2
console.log("x *= 2 →", x); // 24

x /= 4;   // same as: x = x / 4
console.log("x /= 4 →", x); // 6

x %= 4;   // same as: x = x % 4
console.log("x %%= 4 →", x); // 2

x **= 3;  // same as: x = x ** 3
console.log("x **= 3 →", x); // 8'

    press_enter
    clear_screen

    # --- Ternary ---
    print_subheader "2.5 Ternary Operator"

    run_and_show 'let age = 20;

// Instead of if/else:
let status = age >= 18 ? "Adult" : "Minor";
console.log(status); // Adult

// Nested ternary
let score = 85;
let grade = score >= 90 ? "A" :
            score >= 80 ? "B" :
            score >= 70 ? "C" :
            score >= 60 ? "D" : "F";
console.log(`Score: ${score}, Grade: ${grade}`); // B'

    press_enter
    clear_screen

    # --- Quiz ---
    print_subheader "📝 LESSON 2 QUIZ"

    quiz "What does 10 % 3 return?" \
        "2" \
        "3" \
        "1" \
        "3.33" \
        "0"

    quiz "What does 5 === '5' return?" \
        "2" \
        "true" \
        "false" \
        "undefined" \
        "error"

    quiz "What does true && false return?" \
        "1" \
        "false" \
        "true" \
        "null" \
        "undefined"

    quiz "What does the ?? operator do?" \
        "3" \
        "Logical AND" \
        "Logical OR" \
        "Returns right side if left is null/undefined" \
        "Compares types"

    show_progress
    press_enter
}

#=====================================================
# LESSON 3: STRINGS & STRING METHODS
#=====================================================

lesson_3_strings() {
    clear_screen
    print_header "📖 LESSON 3: STRINGS & STRING METHODS"

    print_subheader "3.1 Creating Strings"

    run_and_show 'let single = '\''Hello'\'';
let double = "World";
let backtick = `${single} ${double}!`;

console.log(single);   // Hello
console.log(double);   // World
console.log(backtick); // Hello World!

// String length
let text = "JavaScript";
console.log("Length:", text.length); // 10

// Accessing characters
console.log("First char:", text[0]);          // J
console.log("Last char:", text[text.length - 1]); // t
console.log("charAt(4):", text.charAt(4));    // S'

    press_enter
    clear_screen

    print_subheader "3.2 String Methods"

    run_and_show 'let str = "Hello, JavaScript World!";

// Case methods
console.log(str.toUpperCase()); // HELLO, JAVASCRIPT WORLD!
console.log(str.toLowerCase()); // hello, javascript world!

// Search methods
console.log("indexOf:", str.indexOf("JavaScript"));   // 7
console.log("includes:", str.includes("Java"));        // true
console.log("startsWith:", str.startsWith("Hello"));   // true
console.log("endsWith:", str.endsWith("World!"));      // true

// Extract methods
console.log("slice(7, 17):", str.slice(7, 17));     // JavaScript
console.log("slice(-6):", str.slice(-6));            // orld!
console.log("substring(0, 5):", str.substring(0, 5)); // Hello

// Modify methods
console.log("replace:", str.replace("World", "Termux"));
console.log("trim:", "  spaces  ".trim());        // "spaces"
console.log("trimStart:", "  hello".trimStart());  // "hello"

// Split & Join
let csv = "apple,banana,cherry";
let fruits = csv.split(",");
console.log("split:", fruits);        // ["apple","banana","cherry"]
console.log("join:", fruits.join(" | ")); // apple | banana | cherry

// Repeat & Pad
console.log("repeat:", "Ha".repeat(3));           // HaHaHa
console.log("padStart:", "5".padStart(3, "0"));   // 005
console.log("padEnd:", "Hi".padEnd(10, "."));     // Hi........'

    press_enter
    clear_screen

    print_subheader "3.3 String Search with RegExp"

    run_and_show 'let text = "The rain in Spain stays mainly in the plain";

// match - find matches
console.log(text.match(/ain/g));  // ["ain","ain","ain","ain"]

// search - find position
console.log(text.search(/Spain/)); // 12

// replace with regex
console.log(text.replace(/ain/g, "***"));

// replaceAll
let msg = "foo bar foo bar foo";
console.log(msg.replaceAll("foo", "baz")); // baz bar baz bar baz

// Test if string is a valid email (simple)
let email = "user@example.com";
let emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
console.log("Valid email:", emailRegex.test(email)); // true'

    press_enter
    clear_screen

    print_subheader "📝 LESSON 3 QUIZ"

    quiz "What does 'Hello'.indexOf('l') return?" \
        "3" \
        "1" \
        "4" \
        "2" \
        "3"

    quiz "What does 'JavaScript'.slice(0, 4) return?" \
        "1" \
        "Java" \
        "Jav" \
        "JavaS" \
        "avas"

    coding_challenge \
        "Reverse the string 'hello' and print it" \
        "olleh" \
        "Use: console.log('hello'.split('').reverse().join(''));"

    show_progress
    press_enter
}

#=====================================================
# LESSON 4: CONDITIONAL STATEMENTS
#=====================================================

lesson_4_conditionals() {
    clear_screen
    print_header "📖 LESSON 4: CONDITIONAL STATEMENTS"

    print_subheader "4.1 if / else if / else"

    run_and_show 'let temperature = 30;

if (temperature > 35) {
    console.log("🔥 It'\''s very hot!");
} else if (temperature > 25) {
    console.log("☀️ It'\''s warm and nice!");
} else if (temperature > 15) {
    console.log("🌤️ It'\''s cool.");
} else if (temperature > 0) {
    console.log("🥶 It'\''s cold!");
} else {
    console.log("❄️ It'\''s freezing!");
}

// Nested if
let age = 20;
let hasID = true;

if (age >= 18) {
    if (hasID) {
        console.log("✅ You can enter.");
    } else {
        console.log("❌ You need an ID.");
    }
} else {
    console.log("❌ You are too young.");
}'

    press_enter
    clear_screen

    print_subheader "4.2 switch Statement"

    run_and_show 'let day = new Date().getDay();
let dayName;

switch (day) {
    case 0:
        dayName = "Sunday";
        break;
    case 1:
        dayName = "Monday";
        break;
    case 2:
        dayName = "Tuesday";
        break;
    case 3:
        dayName = "Wednesday";
        break;
    case 4:
        dayName = "Thursday";
        break;
    case 5:
        dayName = "Friday";
        break;
    case 6:
        dayName = "Saturday";
        break;
    default:
        dayName = "Unknown";
}

console.log(`Today is ${dayName}`);

// Switch with multiple cases
let fruit = "apple";
switch (fruit) {
    case "apple":
    case "pear":
        console.log("This is a pome fruit");
        break;
    case "banana":
    case "mango":
        console.log("This is a tropical fruit");
        break;
    default:
        console.log("Unknown fruit type");
}'

    press_enter
    clear_screen

    print_subheader "4.3 Truthy & Falsy Values"

    run_and_show '// Falsy values (evaluate to false):
console.log("=== FALSY VALUES ===");
console.log(Boolean(false));      // false
console.log(Boolean(0));          // false
console.log(Boolean(-0));         // false
console.log(Boolean(""));         // false
console.log(Boolean(null));       // false
console.log(Boolean(undefined));  // false
console.log(Boolean(NaN));        // false

// Everything else is truthy!
console.log("\n=== TRUTHY VALUES ===");
console.log(Boolean(1));           // true
console.log(Boolean("hello"));    // true
console.log(Boolean([]));         // true (empty array!)
console.log(Boolean({}));         // true (empty object!)
console.log(Boolean("0"));        // true (non-empty string!)

// Practical usage
let username = "";
if (username) {
    console.log(`Welcome, ${username}`);
} else {
    console.log("Welcome, Guest!");
}'

    press_enter
    clear_screen

    print_subheader "📝 LESSON 4 QUIZ"

    quiz "What is the output of: if (0) { 'yes' } else { 'no' }?" \
        "2" \
        "yes" \
        "no" \
        "error" \
        "undefined"

    quiz "Which value is truthy?" \
        "4" \
        "0" \
        "\"\"" \
        "null" \
        "\"0\""

    coding_challenge \
        "Write code that prints 'even' if 42 is even, 'odd' if odd" \
        "even" \
        "Use: if (42 % 2 === 0) console.log('even'); else console.log('odd');"

    show_progress
    press_enter
}

#=====================================================
# LESSON 5: LOOPS
#=====================================================

lesson_5_loops() {
    clear_screen
    print_header "📖 LESSON 5: LOOPS"

    print_subheader "5.1 for Loop"

    run_and_show '// Basic for loop
console.log("=== Basic For Loop ===");
for (let i = 1; i <= 5; i++) {
    console.log(`Count: ${i}`);
}

// Looping with step
console.log("\n=== Even Numbers ===");
for (let i = 0; i <= 10; i += 2) {
    console.log(i);
}

// Reverse loop
console.log("\n=== Countdown ===");
for (let i = 5; i >= 1; i--) {
    console.log(`${i}...`);
}
console.log("🚀 Liftoff!");

// Nested loops
console.log("\n=== Multiplication Table (3) ===");
for (let i = 1; i <= 5; i++) {
    console.log(`3 x ${i} = ${3 * i}`);
}'

    press_enter
    clear_screen

    print_subheader "5.2 while & do-while Loops"

    run_and_show '// while loop
console.log("=== While Loop ===");
let count = 1;
while (count <= 5) {
    console.log(`Count: ${count}`);
    count++;
}

// do-while (always runs at least once)
console.log("\n=== Do-While Loop ===");
let num = 1;
do {
    console.log(`Number: ${num}`);
    num++;
} while (num <= 3);

// Practical: find first power of 2 > 1000
let power = 1;
while (power <= 1000) {
    power *= 2;
}
console.log(`\nFirst power of 2 > 1000: ${power}`);'

    press_enter
    clear_screen

    print_subheader "5.3 for...of & for...in Loops"

    run_and_show '// for...of (iterates over VALUES - arrays, strings)
console.log("=== for...of ===");
let colors = ["red", "green", "blue"];
for (let color of colors) {
    console.log(`Color: ${color}`);
}

// Iterating a string
for (let char of "Hello") {
    process.stdout.write(char + " ");
}
console.log();

// for...in (iterates over KEYS - objects)
console.log("\n=== for...in ===");
let person = { name: "John", age: 30, city: "NYC" };
for (let key in person) {
    console.log(`${key}: ${person[key]}`);
}'

    press_enter
    clear_screen

    print_subheader "5.4 break & continue"

    run_and_show '// break - exit the loop entirely
console.log("=== break ===");
for (let i = 1; i <= 10; i++) {
    if (i === 5) break;
    console.log(i);
}
console.log("Loop ended at 5");

// continue - skip current iteration
console.log("\n=== continue ===");
for (let i = 1; i <= 10; i++) {
    if (i % 3 === 0) continue;  // skip multiples of 3
    process.stdout.write(i + " ");
}
console.log("\n(skipped 3, 6, 9)");

// Labeled loops
console.log("\n=== Labeled Break ===");
outer: for (let i = 1; i <= 3; i++) {
    for (let j = 1; j <= 3; j++) {
        if (i === 2 && j === 2) break outer;
        console.log(`i=${i}, j=${j}`);
    }
}'

    press_enter
    clear_screen

    print_subheader "📝 LESSON 5 QUIZ"

    quiz "How many times does this run: for(let i=0; i<5; i++) {}?" \
        "3" \
        "4" \
        "6" \
        "5" \
        "infinite"

    quiz "What does 'continue' do in a loop?" \
        "2" \
        "Exits the loop" \
        "Skips to the next iteration" \
        "Restarts the loop" \
        "Pauses the loop"

    coding_challenge \
        "Print the sum of numbers from 1 to 10 using a for loop" \
        "55" \
        "Use: let sum=0; for(let i=1;i<=10;i++){sum+=i;} console.log(sum);"

    show_progress
    press_enter
}

#=====================================================
# LESSON 6: FUNCTIONS
#=====================================================

lesson_6_functions() {
    clear_screen
    print_header "📖 LESSON 6: FUNCTIONS"

    print_subheader "6.1 Function Declaration & Expression"

    run_and_show '// Function Declaration
function greet(name) {
    return `Hello, ${name}!`;
}
console.log(greet("Termux"));

// Function Expression
const add = function(a, b) {
    return a + b;
};
console.log("Sum:", add(5, 3));

// Arrow Function (ES6)
const multiply = (a, b) => a * b;
console.log("Product:", multiply(4, 7));

// Arrow function with body
const getInfo = (name, age) => {
    const status = age >= 18 ? "adult" : "minor";
    return `${name} is an ${status}`;
};
console.log(getInfo("Alice", 25));

// Single parameter (no parentheses needed)
const double = x => x * 2;
console.log("Double 5:", double(5));'

    press_enter
    clear_screen

    print_subheader "6.2 Default Parameters & Rest Parameters"

    run_and_show '// Default parameters
function greet(name = "World", greeting = "Hello") {
    console.log(`${greeting}, ${name}!`);
}
greet();              // Hello, World!
greet("Termux");      // Hello, Termux!
greet("JS", "Hey");   // Hey, JS!

// Rest parameters (...args)
function sum(...numbers) {
    return numbers.reduce((total, num) => total + num, 0);
}
console.log("Sum:", sum(1, 2, 3, 4, 5)); // 15

// Mixed parameters
function logTeam(leader, ...members) {
    console.log(`Leader: ${leader}`);
    console.log(`Members: ${members.join(", ")}`);
}
logTeam("Alice", "Bob", "Charlie", "Dave");'

    press_enter
    clear_screen

    print_subheader "6.3 Scope & Closures"

    run_and_show '// Scope
let globalVar = "I am global";

function scopeDemo() {
    let localVar = "I am local";
    console.log(globalVar);  // ✅ Can access global
    console.log(localVar);   // ✅ Can access local
}
scopeDemo();
// console.log(localVar); // ❌ Error! Not accessible

// Block scope
if (true) {
    let blockVar = "block scoped";
    const alsoBlock = "also block scoped";
    var notBlock = "function scoped (leaks!)";
}
// console.log(blockVar);  // ❌ Error
console.log(notBlock);     // ✅ var leaks out!

// Closures
function createCounter() {
    let count = 0;
    return {
        increment: () => ++count,
        decrement: () => --count,
        getCount: () => count
    };
}

const counter = createCounter();
console.log(counter.increment()); // 1
console.log(counter.increment()); // 2
console.log(counter.increment()); // 3
console.log(counter.decrement()); // 2
console.log(counter.getCount());  // 2'

    press_enter
    clear_screen

    print_subheader "6.4 Higher-Order Functions & Callbacks"

    run_and_show '// A function that takes another function as argument
function doMath(a, b, operation) {
    return operation(a, b);
}

const addFn = (x, y) => x + y;
const subFn = (x, y) => x - y;

console.log(doMath(10, 5, addFn)); // 15
console.log(doMath(10, 5, subFn)); // 5

// Inline callbacks
console.log(doMath(10, 5, (a, b) => a * b)); // 50

// Function returning a function
function multiplier(factor) {
    return (number) => number * factor;
}

const triple = multiplier(3);
const tenTimes = multiplier(10);

console.log(triple(5));    // 15
console.log(tenTimes(5));  // 50

// IIFE (Immediately Invoked Function Expression)
const result = (() => {
    const x = 10;
    const y = 20;
    return x + y;
})();
console.log("IIFE result:", result); // 30'

    press_enter
    clear_screen

    print_subheader "📝 LESSON 6 QUIZ"

    quiz "What does this return: const f = (x) => x * 2; f(5);" \
        "1" \
        "10" \
        "5" \
        "25" \
        "undefined"

    quiz "What is a closure?" \
        "3" \
        "A function without parameters" \
        "A loop inside a function" \
        "A function that remembers its outer scope" \
        "A function that calls itself"

    coding_challenge \
        "Write an arrow function 'square' that returns x*x, then print square(7)" \
        "49" \
        "Use: const square = x => x * x; console.log(square(7));"

    show_progress
    press_enter
}

#=====================================================
# LESSON 7: ARRAYS
#=====================================================

lesson_7_arrays() {
    clear_screen
    print_header "📖 LESSON 7: ARRAYS"

    print_subheader "7.1 Creating & Accessing Arrays"

    run_and_show 'let fruits = ["apple", "banana", "cherry"];
console.log("Array:", fruits);
console.log("Length:", fruits.length);
console.log("First:", fruits[0]);
console.log("Last:", fruits[fruits.length - 1]);
console.log("Last (at):", fruits.at(-1));

// Array constructor
let numbers = new Array(1, 2, 3, 4, 5);
console.log("Numbers:", numbers);

// Array.from
let chars = Array.from("Hello");
console.log("Chars:", chars);

// Array.of
let arr = Array.of(1, 2, 3);
console.log("Array.of:", arr);

// Check if array
console.log("Is array?", Array.isArray(fruits));   // true
console.log("Is array?", Array.isArray("hello"));  // false'

    press_enter
    clear_screen

    print_subheader "7.2 Adding & Removing Elements"

    run_and_show 'let arr = ["b", "c", "d"];
console.log("Start:", arr);

// Add to end
arr.push("e");
console.log("push(e):", arr);     // [b,c,d,e]

// Add to beginning
arr.unshift("a");
console.log("unshift(a):", arr);  // [a,b,c,d,e]

// Remove from end
let last = arr.pop();
console.log("pop():", arr, "| removed:", last);

// Remove from beginning
let first = arr.shift();
console.log("shift():", arr, "| removed:", first);

// Splice - add/remove at any position
// splice(startIndex, deleteCount, ...itemsToAdd)
arr.splice(1, 1);          // Remove 1 element at index 1
console.log("splice remove:", arr);

arr.splice(1, 0, "x", "y"); // Insert at index 1
console.log("splice insert:", arr);

arr.splice(1, 1, "z");      // Replace 1 element at index 1
console.log("splice replace:", arr);

// Concat
let combined = [1, 2].concat([3, 4], [5, 6]);
console.log("concat:", combined);

// Slice (doesn'\''t modify original)
let sliced = combined.slice(1, 4);
console.log("slice(1,4):", sliced);'

    press_enter
    clear_screen

    print_subheader "7.3 Searching & Sorting"

    run_and_show 'let nums = [3, 1, 4, 1, 5, 9, 2, 6, 5, 3];

// Finding elements
console.log("indexOf(5):", nums.indexOf(5));       // 4
console.log("lastIndexOf(5):", nums.lastIndexOf(5)); // 8
console.log("includes(7):", nums.includes(7));       // false

// find - returns first match
let found = nums.find(n => n > 4);
console.log("find(>4):", found); // 5

// findIndex - returns index of first match
let foundIdx = nums.findIndex(n => n > 4);
console.log("findIndex(>4):", foundIdx); // 4

// Sorting
let fruits = ["cherry", "apple", "banana"];
fruits.sort();
console.log("sort():", fruits); // alphabetical

// Sort numbers (need compare function!)
nums.sort((a, b) => a - b);
console.log("sort nums asc:", nums);

nums.sort((a, b) => b - a);
console.log("sort nums desc:", nums);

// Reverse
let letters = ["a", "b", "c"];
letters.reverse();
console.log("reverse:", letters); // [c, b, a]

// flat
let nested = [1, [2, 3], [4, [5, 6]]];
console.log("flat():", nested.flat());     // [1,2,3,4,[5,6]]
console.log("flat(2):", nested.flat(2));    // [1,2,3,4,5,6]
console.log("flat(Inf):", nested.flat(Infinity));'

    press_enter
    clear_screen

    print_subheader "📝 LESSON 7 QUIZ"

    quiz "What does [1,2,3].push(4) return?" \
        "3" \
        "[1,2,3,4]" \
        "4" \
        "4 (the new length)" \
        "undefined"

    quiz "What does [1,2,3].slice(1,2) return?" \
        "2" \
        "[1,2]" \
        "[2]" \
        "[2,3]" \
        "[1]"

    coding_challenge \
        "Create an array [5,3,8,1,9], sort it ascending, and print it joined with '-'" \
        "1-3-5-8-9" \
        "Use: let a=[5,3,8,1,9]; a.sort((x,y)=>x-y); console.log(a.join('-'));"

    show_progress
    press_enter
}

#=====================================================
# LESSON 8: OBJECTS
#=====================================================

lesson_8_objects() {
    clear_screen
    print_header "📖 LESSON 8: OBJECTS"

    print_subheader "8.1 Creating & Accessing Objects"

    run_and_show 'const person = {
    name: "John",
    age: 30,
    city: "New York",
    hobbies: ["reading", "coding"],
    isStudent: false
};

// Accessing properties
console.log("Dot notation:", person.name);
console.log("Bracket notation:", person["age"]);

// Dynamic key access
let key = "city";
console.log("Dynamic:", person[key]);

// Nested access
console.log("Hobby:", person.hobbies[1]); // coding

// Add new property
person.email = "john@example.com";
console.log("Email:", person.email);

// Delete property
delete person.isStudent;
console.log("After delete:", person);

// Check if property exists
console.log("has name?", "name" in person);    // true
console.log("has phone?", "phone" in person);  // false'

    press_enter
    clear_screen

    print_subheader "8.2 Object Methods & 'this'"

    run_and_show 'const calculator = {
    value: 0,

    add(n) {
        this.value += n;
        return this;  // enables chaining
    },

    subtract(n) {
        this.value -= n;
        return this;
    },

    multiply(n) {
        this.value *= n;
        return this;
    },

    reset() {
        this.value = 0;
        return this;
    },

    getResult() {
        return this.value;
    }
};

// Method chaining
let result = calculator.add(10).add(5).subtract(3).multiply(2).getResult();
console.log("Result:", result); // 24

// Object with getter & setter
const user = {
    firstName: "John",
    lastName: "Doe",

    get fullName() {
        return `${this.firstName} ${this.lastName}`;
    },

    set fullName(name) {
        [this.firstName, this.lastName] = name.split(" ");
    }
};

console.log(user.fullName);     // John Doe
user.fullName = "Jane Smith";
console.log(user.firstName);    // Jane
console.log(user.fullName);     // Jane Smith'

    press_enter
    clear_screen

    print_subheader "8.3 Object Static Methods"

    run_and_show 'const car = { brand: "Toyota", year: 2023, color: "red" };

// Object.keys() - get all keys
console.log("Keys:", Object.keys(car));

// Object.values() - get all values
console.log("Values:", Object.values(car));

// Object.entries() - get key-value pairs
console.log("Entries:", Object.entries(car));

// Iterating over object
for (let [key, value] of Object.entries(car)) {
    console.log(`  ${key}: ${value}`);
}

// Object.assign() - copy/merge objects
const defaults = { theme: "dark", lang: "en", fontSize: 14 };
const userPrefs = { theme: "light", fontSize: 16 };
const settings = Object.assign({}, defaults, userPrefs);
console.log("Merged:", settings);

// Object.freeze() - make immutable
const frozen = Object.freeze({ x: 1, y: 2 });
frozen.x = 100;  // silently fails
console.log("Frozen:", frozen); // { x: 1, y: 2 }

// Object.fromEntries()
const entries = [["name", "John"], ["age", 30]];
const obj = Object.fromEntries(entries);
console.log("fromEntries:", obj);'

    press_enter
    clear_screen

    print_subheader "8.4 Shorthand & Computed Properties"

    run_and_show '// Property shorthand
const name = "Alice";
const age = 28;
const person = { name, age };  // same as { name: name, age: age }
console.log(person);

// Computed property names
const prop = "color";
const obj = {
    [prop]: "blue",
    [`${prop}Code`]: "#0000FF"
};
console.log(obj); // { color: "blue", colorCode: "#0000FF" }

// Method shorthand
const math = {
    add(a, b) { return a + b; },       // instead of add: function(a,b)
    subtract(a, b) { return a - b; }
};
console.log(math.add(5, 3)); // 8

// Optional chaining with objects
const data = {
    user: {
        profile: {
            avatar: "photo.jpg"
        }
    }
};
console.log(data?.user?.profile?.avatar);   // photo.jpg
console.log(data?.user?.settings?.theme);   // undefined (no error)'

    press_enter
    clear_screen

    print_subheader "📝 LESSON 8 QUIZ"

    quiz "How do you access a property with a variable key?" \
        "2" \
        "obj.key" \
        "obj[key]" \
        "obj->key" \
        "obj{key}"

    quiz "What does Object.keys({a:1, b:2}) return?" \
        "1" \
        "[\"a\", \"b\"]" \
        "[1, 2]" \
        "[[\"a\",1],[\"b\",2]]" \
        "{a, b}"

    coding_challenge \
        "Create an object with name:'JS' and version:2024, print all values joined by a space" \
        "JS 2024" \
        "Use: const o={name:'JS',version:2024}; console.log(Object.values(o).join(' '));"

    show_progress
    press_enter
}

#=====================================================
# LESSON 9: ARRAY METHODS (map, filter, reduce)
#=====================================================

lesson_9_array_methods() {
    clear_screen
    print_header "📖 LESSON 9: ARRAY METHODS (map, filter, reduce)"

    print_subheader "9.1 forEach"

    run_and_show 'const fruits = ["apple", "banana", "cherry"];

// forEach - execute function for each element
fruits.forEach((fruit, index) => {
    console.log(`${index + 1}. ${fruit}`);
});

// forEach with objects
const users = [
    { name: "Alice", age: 25 },
    { name: "Bob", age: 30 },
    { name: "Charlie", age: 35 }
];

users.forEach(user => {
    console.log(`${user.name} is ${user.age} years old`);
});'

    press_enter
    clear_screen

    print_subheader "9.2 map - Transform Arrays"

    run_and_show '// map creates a NEW array with transformed elements
const numbers = [1, 2, 3, 4, 5];

const doubled = numbers.map(n => n * 2);
console.log("Doubled:", doubled);     // [2,4,6,8,10]

const squared = numbers.map(n => n ** 2);
console.log("Squared:", squared);     // [1,4,9,16,25]

// Map with objects
const users = [
    { first: "John", last: "Doe" },
    { first: "Jane", last: "Smith" }
];

const fullNames = users.map(u => `${u.first} ${u.last}`);
console.log("Names:", fullNames);

// Map with index
const indexed = ["a", "b", "c"].map((item, i) => `${i}:${item}`);
console.log("Indexed:", indexed);

// Chaining
const result = [1, 2, 3, 4, 5]
    .map(n => n * 3)
    .map(n => n + 1);
console.log("Chained:", result);  // [4, 7, 10, 13, 16]'

    press_enter
    clear_screen

    print_subheader "9.3 filter - Select Elements"

    run_and_show 'const numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

// Filter even numbers
const evens = numbers.filter(n => n % 2 === 0);
console.log("Evens:", evens);    // [2,4,6,8,10]

// Filter odds
const odds = numbers.filter(n => n % 2 !== 0);
console.log("Odds:", odds);     // [1,3,5,7,9]

// Filter objects
const products = [
    { name: "Laptop", price: 999, inStock: true },
    { name: "Phone", price: 699, inStock: false },
    { name: "Tablet", price: 449, inStock: true },
    { name: "Watch", price: 299, inStock: true },
    { name: "TV", price: 1299, inStock: false }
];

const available = products.filter(p => p.inStock);
console.log("In stock:", available.map(p => p.name));

const affordable = products.filter(p => p.price < 500 && p.inStock);
console.log("Affordable & available:", affordable.map(p => p.name));

// Remove duplicates
const arr = [1, 2, 2, 3, 3, 3, 4, 4, 5];
const unique = arr.filter((val, idx, self) => self.indexOf(val) === idx);
console.log("Unique:", unique);  // [1,2,3,4,5]'

    press_enter
    clear_screen

    print_subheader "9.4 reduce - Accumulate Values"

    run_and_show 'const numbers = [1, 2, 3, 4, 5];

// Sum all numbers
const sum = numbers.reduce((accumulator, current) => {
    return accumulator + current;
}, 0);
console.log("Sum:", sum); // 15

// Product
const product = numbers.reduce((acc, n) => acc * n, 1);
console.log("Product:", product); // 120

// Find max
const max = numbers.reduce((a, b) => a > b ? a : b);
console.log("Max:", max); // 5

// Count occurrences
const fruits = ["apple", "banana", "apple", "cherry", "banana", "apple"];
const count = fruits.reduce((acc, fruit) => {
    acc[fruit] = (acc[fruit] || 0) + 1;
    return acc;
}, {});
console.log("Count:", count);

// Group by
const people = [
    { name: "Alice", dept: "Engineering" },
    { name: "Bob", dept: "Marketing" },
    { name: "Charlie", dept: "Engineering" },
    { name: "Dave", dept: "Marketing" },
    { name: "Eve", dept: "Engineering" }
];

const grouped = people.reduce((acc, person) => {
    acc[person.dept] = acc[person.dept] || [];
    acc[person.dept].push(person.name);
    return acc;
}, {});
console.log("Grouped:", JSON.stringify(grouped, null, 2));'

    press_enter
    clear_screen

    print_subheader "9.5 Other Useful Methods"

    run_and_show 'const numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

// every - check if ALL elements pass
console.log("All positive?", numbers.every(n => n > 0));  // true
console.log("All even?", numbers.every(n => n % 2 === 0)); // false

// some - check if ANY element passes
console.log("Any > 5?", numbers.some(n => n > 5));    // true
console.log("Any > 100?", numbers.some(n => n > 100)); // false

// flatMap - map + flat in one step
const sentences = ["Hello World", "Foo Bar"];
const words = sentences.flatMap(s => s.split(" "));
console.log("Words:", words); // ["Hello","World","Foo","Bar"]

// Chaining everything together
const data = [
    { name: "Widget A", price: 25, qty: 10 },
    { name: "Widget B", price: 50, qty: 5 },
    { name: "Widget C", price: 15, qty: 20 },
    { name: "Widget D", price: 75, qty: 3 },
];

const result = data
    .filter(item => item.price >= 20)        // affordable items
    .map(item => ({                          // add total
        ...item,
        total: item.price * item.qty
    }))
    .sort((a, b) => b.total - a.total)       // sort by total desc
    .reduce((acc, item) => {                 // build summary
        acc.items.push(item.name);
        acc.grandTotal += item.total;
        return acc;
    }, { items: [], grandTotal: 0 });

console.log("Pipeline result:", JSON.stringify(result, null, 2));'

    press_enter
    clear_screen

    print_subheader "📝 LESSON 9 QUIZ"

    quiz "What does [1,2,3].map(x => x * 2) return?" \
        "2" \
        "[1,2,3]" \
        "[2,4,6]" \
        "12" \
        "[2,2,2]"

    quiz "What does [1,2,3,4].filter(x => x > 2) return?" \
        "3" \
        "[1,2]" \
        "[2,3,4]" \
        "[3,4]" \
        "[3]"

    quiz "What does [1,2,3].reduce((a,b) => a+b, 0) return?" \
        "4" \
        "0" \
        "3" \
        "123" \
        "6"

    coding_challenge \
        "Use filter and reduce to get the sum of even numbers in [1,2,3,4,5,6,7,8,9,10]" \
        "30" \
        "Use: console.log([1,2,3,4,5,6,7,8,9,10].filter(n=>n%2===0).reduce((a,b)=>a+b,0));"

    show_progress
    press_enter
}

#=====================================================
# LESSON 10: DESTRUCTURING & SPREAD
#=====================================================

lesson_10_destructuring() {
    clear_screen
    print_header "📖 LESSON 10: DESTRUCTURING & SPREAD OPERATOR"

    print_subheader "10.1 Array Destructuring"

    run_and_show '// Basic array destructuring
const [a, b, c] = [1, 2, 3];
console.log(a, b, c); // 1 2 3

// Skip elements
const [first, , third] = [10, 20, 30];
console.log(first, third); // 10 30

// Default values
const [x = 5, y = 10, z = 15] = [1, 2];
console.log(x, y, z); // 1 2 15

// Rest pattern
const [head, ...tail] = [1, 2, 3, 4, 5];
console.log("Head:", head);  // 1
console.log("Tail:", tail);  // [2,3,4,5]

// Swap variables
let m = "Hello";
let n = "World";
[m, n] = [n, m];
console.log(m, n); // World Hello

// Nested destructuring
const [[p, q], [r, s]] = [[1, 2], [3, 4]];
console.log(p, q, r, s); // 1 2 3 4

// From function return
function getCoordinates() {
    return [37.7749, -122.4194];
}
const [lat, lng] = getCoordinates();
console.log(`Lat: ${lat}, Lng: ${lng}`);'

    press_enter
    clear_screen

    print_subheader "10.2 Object Destructuring"

    run_and_show '// Basic object destructuring
const person = { name: "Alice", age: 30, city: "NYC" };
const { name, age, city } = person;
console.log(name, age, city);

// Rename variables
const { name: userName, age: userAge } = person;
console.log(userName, userAge);

// Default values
const { name: n, phone = "N/A" } = person;
console.log(n, phone);

// Nested destructuring
const user = {
    id: 1,
    info: {
        firstName: "John",
        lastName: "Doe"
    },
    scores: [90, 85, 92]
};

const { info: { firstName, lastName }, scores: [s1, s2, s3] } = user;
console.log(firstName, lastName, s1, s2, s3);

// Function parameter destructuring
function displayUser({ name, age, city = "Unknown" }) {
    console.log(`${name}, ${age}, from ${city}`);
}

displayUser({ name: "Bob", age: 25, city: "LA" });
displayUser({ name: "Eve", age: 22 });

// Rest with objects
const { name: nm, ...rest } = { name: "Test", a: 1, b: 2, c: 3 };
console.log("Name:", nm);
console.log("Rest:", rest);'

    press_enter
    clear_screen

    print_subheader "10.3 Spread Operator (...)"

    run_and_show '// Spread arrays
const arr1 = [1, 2, 3];
const arr2 = [4, 5, 6];
const combined = [...arr1, ...arr2];
console.log("Combined:", combined);

// Copy array
const original = [1, 2, 3];
const copy = [...original];
copy.push(4);
console.log("Original:", original); // [1,2,3] unchanged
console.log("Copy:", copy);         // [1,2,3,4]

// Insert in middle
const middle = [1, 2, ...["a", "b", "c"], 3, 4];
console.log("Middle:", middle);

// Spread objects
const defaults = { theme: "dark", lang: "en", font: 14 };
const userPrefs = { theme: "light", font: 16 };
const settings = { ...defaults, ...userPrefs };
console.log("Settings:", settings); // theme: light, lang: en, font: 16

// Add properties
const user = { name: "John", age: 30 };
const enhanced = { ...user, email: "john@test.com", age: 31 };
console.log("Enhanced:", enhanced);

// Spread with functions
const nums = [5, 3, 8, 1, 9, 2];
console.log("Max:", Math.max(...nums));
console.log("Min:", Math.min(...nums));

// Remove a property from object (using rest + spread)
const { age: _, ...withoutAge } = { name: "Alice", age: 30, city: "NYC" };
console.log("Without age:", withoutAge);'

    press_enter
    clear_screen

    print_subheader "📝 LESSON 10 QUIZ"

    quiz "What does const [a,,b] = [1,2,3] assign to b?" \
        "3" \
        "2" \
        "undefined" \
        "3" \
        "null"

    quiz "What does {...{a:1,b:2}, b:3} result in?" \
        "2" \
        "{a:1, b:2, b:3}" \
        "{a:1, b:3}" \
        "{a:1, b:2}" \
        "Error"

    show_progress
    press_enter
}

#=====================================================
# LESSON 11: CLASSES & OOP
#=====================================================

lesson_11_classes() {
    clear_screen
    print_header "📖 LESSON 11: CLASSES & OOP"

    print_subheader "11.1 Class Basics"

    run_and_show 'class Animal {
    // Constructor
    constructor(name, sound) {
        this.name = name;
        this.sound = sound;
    }

    // Method
    speak() {
        console.log(`${this.name} says ${this.sound}!`);
    }

    // toString
    toString() {
        return `Animal(${this.name})`;
    }
}

const dog = new Animal("Rex", "Woof");
const cat = new Animal("Whiskers", "Meow");

dog.speak();   // Rex says Woof!
cat.speak();   // Whiskers says Meow!
console.log(String(dog)); // Animal(Rex)'

    press_enter
    clear_screen

    print_subheader "11.2 Inheritance"

    run_and_show 'class Shape {
    constructor(color) {
        this.color = color;
    }

    describe() {
        return `A ${this.color} ${this.constructor.name}`;
    }
}

class Circle extends Shape {
    constructor(color, radius) {
        super(color);  // call parent constructor
        this.radius = radius;
    }

    area() {
        return Math.PI * this.radius ** 2;
    }

    describe() {
        return `${super.describe()} with radius ${this.radius}`;
    }
}

class Rectangle extends Shape {
    constructor(color, width, height) {
        super(color);
        this.width = width;
        this.height = height;
    }

    area() {
        return this.width * this.height;
    }

    describe() {
        return `${super.describe()} (${this.width}x${this.height})`;
    }
}

const circle = new Circle("red", 5);
console.log(circle.describe());
console.log("Area:", circle.area().toFixed(2));

const rect = new Rectangle("blue", 4, 6);
console.log(rect.describe());
console.log("Area:", rect.area());

// instanceof
console.log("circle instanceof Circle:", circle instanceof Circle);
console.log("circle instanceof Shape:", circle instanceof Shape);'

    press_enter
    clear_screen

    print_subheader "11.3 Static Methods, Getters, Setters, Private Fields"

    run_and_show 'class BankAccount {
    // Private fields (# prefix)
    #balance;
    #owner;

    // Static property
    static bankName = "Termux Bank";
    static #totalAccounts = 0;

    constructor(owner, initialBalance = 0) {
        this.#owner = owner;
        this.#balance = initialBalance;
        BankAccount.#totalAccounts++;
        this.id = BankAccount.#totalAccounts;
    }

    // Getter
    get balance() {
        return this.#balance;
    }

    get owner() {
        return this.#owner;
    }

    // Setter
    set owner(newOwner) {
        if (typeof newOwner !== "string" || newOwner.length < 2) {
            throw new Error("Invalid owner name");
        }
        this.#owner = newOwner;
    }

    // Methods
    deposit(amount) {
        if (amount <= 0) throw new Error("Amount must be positive");
        this.#balance += amount;
        console.log(`Deposited $${amount}. Balance: $${this.#balance}`);
        return this;
    }

    withdraw(amount) {
        if (amount > this.#balance) throw new Error("Insufficient funds");
        this.#balance -= amount;
        console.log(`Withdrew $${amount}. Balance: $${this.#balance}`);
        return this;
    }

    // Static method
    static getTotalAccounts() {
        return BankAccount.#totalAccounts;
    }

    toString() {
        return `Account #${this.id}: ${this.#owner} ($${this.#balance})`;
    }
}

const acc1 = new BankAccount("Alice", 1000);
const acc2 = new BankAccount("Bob", 500);

acc1.deposit(500).withdraw(200);
console.log(String(acc1));
console.log("Balance:", acc1.balance);  // getter
console.log("Bank:", BankAccount.bankName);
console.log("Total accounts:", BankAccount.getTotalAccounts());'

    press_enter
    clear_screen

    print_subheader "📝 LESSON 11 QUIZ"

    quiz "What keyword is used to call the parent constructor?" \
        "2" \
        "parent()" \
        "super()" \
        "this()" \
        "base()"

    quiz "How do you mark a field as private in a class?" \
        "3" \
        "private keyword" \
        "_ prefix" \
        "# prefix" \
        "@ prefix"

    show_progress
    press_enter
}

#=====================================================
# LESSON 12: PROMISES & ASYNC/AWAIT
#=====================================================

lesson_12_async() {
    clear_screen
    print_header "📖 LESSON 12: PROMISES & ASYNC/AWAIT"

    print_subheader "12.1 Callbacks (The Old Way)"

    run_and_show '// Simulating async with setTimeout
function fetchData(callback) {
    console.log("Fetching data...");
    setTimeout(() => {
        callback(null, { id: 1, name: "John" });
    }, 100);
}

fetchData((error, data) => {
    if (error) {
        console.log("Error:", error);
    } else {
        console.log("Got data:", data);
    }
});

// Callback hell (what we want to avoid)
// getData(result1 => {
//     getMore(result1, result2 => {
//         process(result2, result3 => {
//             // deeply nested... hard to read!
//         });
//     });
// });

console.log("This runs first (async is non-blocking)!");'

    press_enter
    clear_screen

    print_subheader "12.2 Promises"

    run_and_show '// Creating a Promise
function fetchUser(id) {
    return new Promise((resolve, reject) => {
        setTimeout(() => {
            if (id > 0) {
                resolve({ id, name: `User_${id}`, email: `user${id}@test.com` });
            } else {
                reject(new Error("Invalid ID"));
            }
        }, 100);
    });
}

// Using .then() and .catch()
fetchUser(1)
    .then(user => {
        console.log("Got user:", user);
        return fetchUser(2);  // chain another promise
    })
    .then(user2 => {
        console.log("Got user 2:", user2);
    })
    .catch(error => {
        console.log("Error:", error.message);
    })
    .finally(() => {
        console.log("Done!");
    });

// Promise.all - wait for ALL promises
Promise.all([fetchUser(1), fetchUser(2), fetchUser(3)])
    .then(users => {
        console.log("All users:", users.map(u => u.name));
    });

// Promise.race - first to complete wins
Promise.race([
    new Promise(resolve => setTimeout(() => resolve("Fast!"), 50)),
    new Promise(resolve => setTimeout(() => resolve("Slow..."), 200))
]).then(result => console.log("Race winner:", result));'

    press_enter
    clear_screen

    print_subheader "12.3 Async/Await (The Modern Way)"

    run_and_show '// Helper function
function delay(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
}

function fetchUser(id) {
    return new Promise((resolve) => {
        setTimeout(() => {
            resolve({ id, name: `User_${id}` });
        }, 50);
    });
}

// async/await - makes async code look synchronous!
async function main() {
    console.log("Starting...");

    // await pauses until promise resolves
    const user1 = await fetchUser(1);
    console.log("User 1:", user1);

    const user2 = await fetchUser(2);
    console.log("User 2:", user2);

    // Parallel execution with Promise.all
    const [u3, u4, u5] = await Promise.all([
        fetchUser(3),
        fetchUser(4),
        fetchUser(5)
    ]);
    console.log("Parallel:", u3.name, u4.name, u5.name);

    // Error handling with try/catch
    try {
        await delay(50);
        console.log("After delay");

        // Simulating an error
        throw new Error("Something went wrong");
    } catch (error) {
        console.log("Caught:", error.message);
    } finally {
        console.log("Cleanup done");
    }
}

main().then(() => console.log("All finished!"));'

    press_enter
    clear_screen

    print_subheader "12.4 Real-World Async Patterns"

    run_and_show 'async function retry(fn, maxRetries = 3) {
    for (let attempt = 1; attempt <= maxRetries; attempt++) {
        try {
            return await fn();
        } catch (error) {
            console.log(`Attempt ${attempt} failed: ${error.message}`);
            if (attempt === maxRetries) throw error;
        }
    }
}

let callCount = 0;
async function unreliableFunction() {
    callCount++;
    if (callCount < 3) {
        throw new Error("Not ready yet");
    }
    return "Success!";
}

retry(unreliableFunction)
    .then(result => console.log("Result:", result))
    .catch(err => console.log("Final error:", err.message));

// Async iteration
async function* generateNumbers() {
    for (let i = 1; i <= 5; i++) {
        await new Promise(resolve => setTimeout(resolve, 10));
        yield i;
    }
}

async function consumeNumbers() {
    for await (const num of generateNumbers()) {
        console.log("Generated:", num);
    }
}

consumeNumbers();'

    press_enter
    clear_screen

    print_subheader "📝 LESSON 12 QUIZ"

    quiz "What does 'await' do?" \
        "2" \
        "Creates a new thread" \
        "Pauses until a Promise resolves" \
        "Makes code run faster" \
        "Catches errors"

    quiz "Which runs Promises in parallel?" \
        "3" \
        "Promise.race()" \
        "Promise.resolve()" \
        "Promise.all()" \
        "Promise.any()"

    show_progress
    press_enter
}

#=====================================================
# LESSON 13: ERROR HANDLING
#=====================================================

lesson_13_errors() {
    clear_screen
    print_header "📖 LESSON 13: ERROR HANDLING"

    print_subheader "13.1 try / catch / finally"

    run_and_show '// Basic try-catch
try {
    let result = JSON.parse("invalid json");
} catch (error) {
    console.log("Error type:", error.constructor.name); // SyntaxError
    console.log("Message:", error.message);
}

// try-catch-finally
function divide(a, b) {
    try {
        if (b === 0) throw new Error("Cannot divide by zero");
        return a / b;
    } catch (error) {
        console.log("Error:", error.message);
        return null;
    } finally {
        console.log("Division attempted"); // always runs
    }
}

console.log(divide(10, 2));  // 5
console.log(divide(10, 0));  // null

// Throwing custom errors
function validateAge(age) {
    if (typeof age !== "number") {
        throw new TypeError("Age must be a number");
    }
    if (age < 0 || age > 150) {
        throw new RangeError("Age must be between 0 and 150");
    }
    return true;
}

try {
    validateAge("twenty");
} catch (e) {
    if (e instanceof TypeError) {
        console.log("Type error:", e.message);
    } else if (e instanceof RangeError) {
        console.log("Range error:", e.message);
    }
}'

    press_enter
    clear_screen

    print_subheader "13.2 Custom Error Classes"

    run_and_show 'class ValidationError extends Error {
    constructor(field, message) {
        super(message);
        this.name = "ValidationError";
        this.field = field;
    }
}

class NotFoundError extends Error {
    constructor(resource) {
        super(`${resource} not found`);
        this.name = "NotFoundError";
        this.resource = resource;
    }
}

function createUser(data) {
    if (!data.name) throw new ValidationError("name", "Name is required");
    if (!data.email) throw new ValidationError("email", "Email is required");
    if (data.age < 18) throw new ValidationError("age", "Must be 18+");
    return { id: 1, ...data };
}

// Handle specific error types
const testCases = [
    { name: "", email: "test@test.com", age: 25 },
    { name: "John", email: "john@test.com", age: 15 },
    { name: "Jane", email: "jane@test.com", age: 25 }
];

for (const data of testCases) {
    try {
        const user = createUser(data);
        console.log("✅ Created:", user.name);
    } catch (e) {
        if (e instanceof ValidationError) {
            console.log(`❌ Validation: ${e.field} - ${e.message}`);
        } else {
            console.log(`❌ Unexpected: ${e.message}`);
        }
    }
}'

    press_enter
    clear_screen

    print_subheader "📝 LESSON 13 QUIZ"

    quiz "What block ALWAYS executes, even after an error?" \
        "3" \
        "try" \
        "catch" \
        "finally" \
        "throw"

    quiz "How do you create a custom error in modern JS?" \
        "1" \
        "class MyError extends Error {}" \
        "function MyError() {}" \
        "const MyError = new Error()" \
        "Error.create('MyError')"

    show_progress
    press_enter
}

#=====================================================
# LESSON 14: MODULES & FILE I/O
#=====================================================

lesson_14_modules() {
    clear_screen
    print_header "📖 LESSON 14: MODULES & FILE I/O (Node.js)"

    print_subheader "14.1 Node.js Modules"

    # Create module files
    cat > "$LESSON_DIR/math_utils.js" << 'MODULEOF'
// Exporting with module.exports (CommonJS)
function add(a, b) { return a + b; }
function subtract(a, b) { return a - b; }
function multiply(a, b) { return a * b; }
function divide(a, b) {
    if (b === 0) throw new Error("Division by zero");
    return a / b;
}

const PI = 3.14159265359;

module.exports = { add, subtract, multiply, divide, PI };
MODULEOF

    cat > "$LESSON_DIR/test_module.js" << 'TESTEOF'
// Importing (CommonJS)
const { add, subtract, multiply, PI } = require('./math_utils');

console.log("add(5, 3):", add(5, 3));
console.log("subtract(10, 4):", subtract(10, 4));
console.log("multiply(6, 7):", multiply(6, 7));
console.log("PI:", PI);

// Built-in modules
const path = require('path');
console.log("\nPath separator:", path.sep);
console.log("Join:", path.join('/home', 'user', 'docs', 'file.txt'));
console.log("Extension:", path.extname('script.js'));
console.log("Basename:", path.basename('/home/user/file.txt'));

const os = require('os');
console.log("\nOS Platform:", os.platform());
console.log("Architecture:", os.arch());
console.log("Home dir:", os.homedir());
console.log("Free memory:", (os.freemem() / 1024 / 1024).toFixed(0), "MB");
TESTEOF

    local code=$(cat "$LESSON_DIR/test_module.js")
    print_code "$code"

    echo -e "${BLUE}Output:${NC}"
    local output
    output=$(cd "$LESSON_DIR" && node test_module.js 2>&1)
    print_output "$output"

    press_enter
    clear_screen

    print_subheader "14.2 File System (fs module)"

    cat > "$LESSON_DIR/file_demo.js" << 'FSEOF'
const fs = require('fs');
const path = require('path');

const filePath = path.join(__dirname, 'test_data.json');

// Write file
const data = {
    students: [
        { name: "Alice", grade: 95 },
        { name: "Bob", grade: 87 },
        { name: "Charlie", grade: 92 }
    ],
    subject: "JavaScript",
    date: new Date().toISOString()
};

fs.writeFileSync(filePath, JSON.stringify(data, null, 2));
console.log("✅ File written!");

// Read file
const content = fs.readFileSync(filePath, 'utf8');
const parsed = JSON.parse(content);
console.log("📄 Read file:", parsed.subject);
console.log("Students:", parsed.students.map(s => s.name).join(", "));

// Append to file
const logFile = path.join(__dirname, 'log.txt');
fs.writeFileSync(logFile, "=== Log Start ===\n");
fs.appendFileSync(logFile, `Entry 1: ${new Date().toLocaleTimeString()}\n`);
fs.appendFileSync(logFile, `Entry 2: Program running\n`);
console.log("\n📝 Log contents:");
console.log(fs.readFileSync(logFile, 'utf8'));

// File info
const stats = fs.statSync(filePath);
console.log("File size:", stats.size, "bytes");
console.log("Created:", stats.birthtime.toLocaleDateString());
console.log("Is file:", stats.isFile());

// List directory
console.log("\nFiles in lesson dir:");
const files = fs.readdirSync(__dirname);
files.filter(f => f.endsWith('.js')).forEach(f => {
    console.log(`  📄 ${f}`);
});

// Check if file exists
console.log("\ntest_data.json exists?", fs.existsSync(filePath));
console.log("nonexistent.txt exists?", fs.existsSync("nonexistent.txt"));

// Cleanup
fs.unlinkSync(filePath);
fs.unlinkSync(logFile);
console.log("\n🗑️ Cleanup done!");
FSEOF

    local code=$(cat "$LESSON_DIR/file_demo.js")
    print_code "$code"

    echo -e "${BLUE}Output:${NC}"
    local output
    output=$(cd "$LESSON_DIR" && node file_demo.js 2>&1)
    print_output "$output"

    press_enter
    clear_screen

    print_subheader "14.3 Async File Operations"

    run_and_show 'const fs = require("fs").promises;
const path = require("path");

async function main() {
    const file = path.join(require("os").tmpdir(), "async_test.txt");

    // Async write
    await fs.writeFile(file, "Hello from async!\nLine 2\nLine 3");
    console.log("Written!");

    // Async read
    const content = await fs.readFile(file, "utf8");
    console.log("Content:", content);

    // Async stat
    const stats = await fs.stat(file);
    console.log("Size:", stats.size, "bytes");

    // Cleanup
    await fs.unlink(file);
    console.log("Cleaned up!");
}

main().catch(console.error);'

    press_enter
    clear_screen

    print_subheader "📝 LESSON 14 QUIZ"

    quiz "Which function reads a file synchronously in Node.js?" \
        "1" \
        "fs.readFileSync()" \
        "fs.readFile()" \
        "fs.openSync()" \
        "fs.loadFile()"

    quiz "What does require() do?" \
        "3" \
        "Creates a new module" \
        "Installs a package" \
        "Imports a module" \
        "Exports a function"

    show_progress
    press_enter
}

#=====================================================
# LESSON 15: FINAL PROJECT
#=====================================================

lesson_15_final_project() {
    clear_screen
    print_header "📖 LESSON 15: FINAL PROJECT - TODO APP"

    echo -e "${WHITE}Let's build a complete TODO application using Node.js!${NC}"
    echo -e "${WHITE}This combines everything we've learned.${NC}"
    echo ""

    press_enter

    cat > "$LESSON_DIR/todo_app.js" << 'TODOEOF'
const fs = require('fs');
const path = require('path');
const readline = require('readline');

// ============= Todo Class =============
class Todo {
    #id;
    #text;
    #completed;
    #createdAt;
    #priority;

    constructor(text, priority = 'medium') {
        this.#id = Date.now().toString(36) + Math.random().toString(36).substr(2, 5);
        this.#text = text;
        this.#completed = false;
        this.#createdAt = new Date();
        this.#priority = priority;
    }

    get id() { return this.#id; }
    get text() { return this.#text; }
    get completed() { return this.#completed; }
    get createdAt() { return this.#createdAt; }
    get priority() { return this.#priority; }

    set text(value) {
        if (!value || value.trim().length === 0) {
            throw new Error('Todo text cannot be empty');
        }
        this.#text = value.trim();
    }

    toggle() {
        this.#completed = !this.#completed;
    }

    toJSON() {
        return {
            id: this.#id,
            text: this.#text,
            completed: this.#completed,
            createdAt: this.#createdAt,
            priority: this.#priority
        };
    }

    static fromJSON(data) {
        const todo = new Todo(data.text, data.priority);
        todo.#id = data.id;
        todo.#completed = data.completed;
        todo.#createdAt = new Date(data.createdAt);
        return todo;
    }

    toString() {
        const status = this.#completed ? '✅' : '⬜';
        const priorityIcon = {
            high: '🔴',
            medium: '🟡',
            low: '🟢'
        }[this.#priority] || '⚪';
        return `${status} ${priorityIcon} [${this.#id.substr(0,6)}] ${this.#text}`;
    }
}

// ============= TodoList Manager =============
class TodoList {
    #todos;
    #filePath;

    constructor(filePath) {
        this.#filePath = filePath;
        this.#todos = [];
        this.load();
    }

    // Add a todo
    add(text, priority = 'medium') {
        const validPriorities = ['high', 'medium', 'low'];
        if (!validPriorities.includes(priority)) {
            throw new Error(`Priority must be: ${validPriorities.join(', ')}`);
        }
        const todo = new Todo(text, priority);
        this.#todos.push(todo);
        this.save();
        return todo;
    }

    // Remove a todo
    remove(id) {
        const index = this.#todos.findIndex(t => t.id.startsWith(id));
        if (index === -1) throw new Error(`Todo "${id}" not found`);
        const [removed] = this.#todos.splice(index, 1);
        this.save();
        return removed;
    }

    // Toggle completion
    toggle(id) {
        const todo = this.#todos.find(t => t.id.startsWith(id));
        if (!todo) throw new Error(`Todo "${id}" not found`);
        todo.toggle();
        this.save();
        return todo;
    }

    // Get filtered list
    getAll(filter = 'all') {
        switch (filter) {
            case 'done':
                return this.#todos.filter(t => t.completed);
            case 'pending':
                return this.#todos.filter(t => !t.completed);
            case 'all':
            default:
                return [...this.#todos];
        }
    }

    // Search
    search(query) {
        return this.#todos.filter(t =>
            t.text.toLowerCase().includes(query.toLowerCase())
        );
    }

    // Sort
    getSorted(by = 'date') {
        const sorted = [...this.#todos];
        const priorityOrder = { high: 0, medium: 1, low: 2 };

        switch (by) {
            case 'priority':
                return sorted.sort((a, b) => priorityOrder[a.priority] - priorityOrder[b.priority]);
            case 'name':
                return sorted.sort((a, b) => a.text.localeCompare(b.text));
            case 'status':
                return sorted.sort((a, b) => a.completed - b.completed);
            default:
                return sorted.sort((a, b) => b.createdAt - a.createdAt);
        }
    }

    // Statistics
    getStats() {
        const total = this.#todos.length;
        const done = this.#todos.filter(t => t.completed).length;
        const pending = total - done;
        const byPriority = this.#todos.reduce((acc, t) => {
            acc[t.priority] = (acc[t.priority] || 0) + 1;
            return acc;
        }, {});
        return { total, done, pending, byPriority, percentage: total ? Math.round(done/total*100) : 0 };
    }

    // Clear completed
    clearCompleted() {
        const before = this.#todos.length;
        this.#todos = this.#todos.filter(t => !t.completed);
        this.save();
        return before - this.#todos.length;
    }

    // Save to file
    save() {
        try {
            const data = JSON.stringify(this.#todos.map(t => t.toJSON()), null, 2);
            fs.writeFileSync(this.#filePath, data);
        } catch (error) {
            console.error('Error saving:', error.message);
        }
    }

    // Load from file
    load() {
        try {
            if (fs.existsSync(this.#filePath)) {
                const data = JSON.parse(fs.readFileSync(this.#filePath, 'utf8'));
                this.#todos = data.map(d => Todo.fromJSON(d));
            }
        } catch (error) {
            console.error('Error loading:', error.message);
            this.#todos = [];
        }
    }
}

// ============= CLI Interface =============
class TodoApp {
    #todoList;
    #rl;

    constructor() {
        const dataFile = path.join(__dirname, 'todos.json');
        this.#todoList = new TodoList(dataFile);
        this.#rl = readline.createInterface({
            input: process.stdin,
            output: process.stdout
        });
    }

    // Display helpers
    printHeader() {
        console.log('\n\x1b[36m╔════════════════════════════════════════╗\x1b[0m');
        console.log('\x1b[36m║\x1b[0m    \x1b[1m📋 TERMUX TODO APPLICATION\x1b[0m       \x1b[36m║\x1b[0m');
        console.log('\x1b[36m╚════════════════════════════════════════╝\x1b[0m\n');
    }

    printMenu() {
        const stats = this.#todoList.getStats();
        console.log(`\x1b[33m📊 ${stats.done}/${stats.total} done (${stats.percentage}%)\x1b[0m\n`);
        console.log('\x1b[36m  1)\x1b[0m 📝 Add todo');
        console.log('\x1b[36m  2)\x1b[0m 📋 List todos');
        console.log('\x1b[36m  3)\x1b[0m ✅ Toggle todo');
        console.log('\x1b[36m  4)\x1b[0m 🗑️  Remove todo');
        console.log('\x1b[36m  5)\x1b[0m 🔍 Search todos');
        console.log('\x1b[36m  6)\x1b[0m 📊 Statistics');
        console.log('\x1b[36m  7)\x1b[0m 🧹 Clear completed');
        console.log('\x1b[36m  8)\x1b[0m 🚪 Exit');
        console.log('');
    }

    printTodos(todos, title = 'Todos') {
        console.log(`\n\x1b[1m--- ${title} ---\x1b[0m`);
        if (todos.length === 0) {
            console.log('  \x1b[33m(empty)\x1b[0m');
        } else {
            todos.forEach(t => console.log(`  ${t.toString()}`));
        }
        console.log('');
    }

    prompt(question) {
        return new Promise(resolve => {
            this.#rl.question(`\x1b[32m${question}\x1b[0m`, resolve);
        });
    }

    async handleAdd() {
        const text = await this.prompt('Todo text: ');
        if (!text.trim()) { console.log('❌ Text required!'); return; }
        const priority = (await this.prompt('Priority (high/medium/low) [medium]: ')).trim() || 'medium';
        try {
            const todo = this.#todoList.add(text, priority);
            console.log(`\x1b[32m✅ Added: ${todo.toString()}\x1b[0m`);
        } catch (e) {
            console.log(`\x1b[31m❌ ${e.message}\x1b[0m`);
        }
    }

    async handleList() {
        const filter = (await this.prompt('Filter (all/done/pending) [all]: ')).trim() || 'all';
        const sort = (await this.prompt('Sort (date/priority/name/status) [date]: ')).trim() || 'date';
        let todos = this.#todoList.getAll(filter);
        // Apply sorting
        const priorityOrder = { high: 0, medium: 1, low: 2 };
        switch (sort) {
            case 'priority': todos.sort((a,b) => priorityOrder[a.priority] - priorityOrder[b.priority]); break;
            case 'name': todos.sort((a,b) => a.text.localeCompare(b.text)); break;
            case 'status': todos.sort((a,b) => a.completed - b.completed); break;
        }
        this.printTodos(todos, `${filter.toUpperCase()} (sorted by ${sort})`);
    }

    async handleToggle() {
        this.printTodos(this.#todoList.getAll());
        const id = await this.prompt('Todo ID (first chars): ');
        try {
            const todo = this.#todoList.toggle(id.trim());
            console.log(`\x1b[32m✅ Toggled: ${todo.toString()}\x1b[0m`);
        } catch (e) {
            console.log(`\x1b[31m❌ ${e.message}\x1b[0m`);
        }
    }

    async handleRemove() {
        this.printTodos(this.#todoList.getAll());
        const id = await this.prompt('Todo ID to remove: ');
        try {
            const todo = this.#todoList.remove(id.trim());
            console.log(`\x1b[32m🗑️ Removed: ${todo.text}\x1b[0m`);
        } catch (e) {
            console.log(`\x1b[31m❌ ${e.message}\x1b[0m`);
        }
    }

    async handleSearch() {
        const query = await this.prompt('Search query: ');
        const results = this.#todoList.search(query.trim());
        this.printTodos(results, `Search: "${query}"`);
    }

    handleStats() {
        const stats = this.#todoList.getStats();
        console.log('\n\x1b[1m📊 STATISTICS\x1b[0m');
        console.log(`  Total:     ${stats.total}`);
        console.log(`  Done:      ${stats.done}`);
        console.log(`  Pending:   ${stats.pending}`);
        console.log(`  Progress:  ${stats.percentage}%`);
        console.log(`  Priority breakdown:`);
        Object.entries(stats.byPriority).forEach(([p, count]) => {
            const icon = { high: '🔴', medium: '🟡', low: '🟢' }[p];
            console.log(`    ${icon} ${p}: ${count}`);
        });

        // Progress bar
        const barLen = 20;
        const filled = Math.round(barLen * stats.percentage / 100);
        const bar = '█'.repeat(filled) + '░'.repeat(barLen - filled);
        console.log(`  [${bar}] ${stats.percentage}%\n`);
    }

    handleClear() {
        const count = this.#todoList.clearCompleted();
        console.log(`\x1b[32m🧹 Cleared ${count} completed todo(s)\x1b[0m`);
    }

    async run() {
        // Add sample data if empty
        if (this.#todoList.getAll().length === 0) {
            this.#todoList.add('Learn JavaScript variables', 'high');
            this.#todoList.add('Practice array methods', 'medium');
            this.#todoList.add('Build a project', 'high');
            this.#todoList.add('Read documentation', 'low');
            console.log('📌 Added sample todos!');
        }

        while (true) {
            console.clear();
            this.printHeader();
            this.printMenu();

            const choice = await this.prompt('Choose option (1-8): ');

            switch (choice.trim()) {
                case '1': await this.handleAdd(); break;
                case '2': await this.handleList(); break;
                case '3': await this.handleToggle(); break;
                case '4': await this.handleRemove(); break;
                case '5': await this.handleSearch(); break;
                case '6': this.handleStats(); break;
                case '7': this.handleClear(); break;
                case '8':
                    console.log('\n\x1b[36m👋 Goodbye! Happy coding!\x1b[0m\n');
                    this.#rl.close();
                    return;
                default:
                    console.log('\x1b[31mInvalid option!\x1b[0m');
            }

            await this.prompt('\nPress ENTER to continue...');
        }
    }
}

// Run the app
const app = new TodoApp();
app.run().catch(console.error);
TODOEOF

    echo -e "${GREEN}✅ Todo App created at: $LESSON_DIR/todo_app.js${NC}"
    echo ""

    # Display the code with line count
    local linecount
    linecount=$(wc -l < "$LESSON_DIR/todo_app.js")
    echo -e "${WHITE}The app is ${CYAN}$linecount lines${WHITE} and uses:${NC}"
    echo -e "  ${GREEN}✓${NC} Classes & Inheritance"
    echo -e "  ${GREEN}✓${NC} Private fields (#)"
    echo -e "  ${GREEN}✓${NC} Getters & Setters"
    echo -e "  ${GREEN}✓${NC} Static methods"
    echo -e "  ${GREEN}✓${NC} Async/Await"
    echo -e "  ${GREEN}✓${NC} Error handling (try/catch)"
    echo -e "  ${GREEN}✓${NC} File I/O (fs module)"
    echo -e "  ${GREEN}✓${NC} Array methods (map, filter, reduce, find)"
    echo -e "  ${GREEN}✓${NC} Destructuring & Spread"
    echo -e "  ${GREEN}✓${NC} Template literals"
    echo -e "  ${GREEN}✓${NC} Closures"
    echo -e "  ${GREEN}✓${NC} switch statements"
    echo -e "  ${GREEN}✓${NC} JSON serialization"
    echo ""

    echo -e "${YELLOW}To run the Todo App:${NC}"
    echo -e "${CYAN}  cd $LESSON_DIR && node todo_app.js${NC}"
    echo ""

    echo -ne "${WHITE}Would you like to run the Todo App now? (y/n): ${NC}"
    read -r run_app

    if [[ "$run_app" == "y" || "$run_app" == "Y" ]]; then
        cd "$LESSON_DIR" && node todo_app.js
    fi

    press_enter
}

try_it_yourself() {
    while true; do
        clear_screen
        print_header "⚡ TRY IT YOURSELF: JavaScript Playground"
        echo -e "${WHITE}Experiment with JavaScript code here!${NC}"
        echo -e "  ${CYAN}1)${NC} Interactive REPL (Type commands and see results instantly)"
        echo -e "  ${CYAN}2)${NC} Multi-line Runner (Write a script and run it by typing ${CYAN}END${NC})"
        echo -e "  ${RED}B)${NC} Back to Main Menu"
        echo ""
        echo -ne "${WHITE}Your choice: ${NC}"
        read -r choice

        case "$choice" in
            1)
                echo -e "${YELLOW}Starting Node.js REPL... Type '.exit' to return.${NC}"
                node
                ;;
            2)
                clear_screen
                print_header "📝 Multi-line Script Runner"
                echo -e "${WHITE}Write your code. Type ${CYAN}END${WHITE} on a new line to execute.${NC}"
                echo -e "${WHITE}Type ${RED}EXIT${WHITE} to go back to Playground menu.${NC}"
                echo ""
                local code=""
                while IFS= read -r line; do
                    [[ "$line" == "EXIT" ]] && break
                    [[ "$line" == "END" ]] && break
                    code+="$line"$'\n'
                done
                if [ -n "$code" ] && [[ "$line" != "EXIT" ]]; then
                    echo -e "${BLUE}Output:${NC}"
                    local output=$(run_js "$code")
                    print_output "$output"
                    press_enter "plain"
                fi
                ;;
            [bB]) return ;;
            *) echo -e "${RED}Invalid choice!${NC}"; sleep 1 ;;
        esac
    done
}

challenge_mode() {
    local missions_this_run=0
    while true; do
        clear_screen
        print_header "🏆 CHALLENGE MODE: Gauntlet"
        echo -ne "  Current Rank: "
        get_rank
        echo -e "${WHITE}Missions completed this session: ${GREEN}$missions_this_run${NC}"
        echo ""

        # Define challenges: description|expected_output|hint
        local challenges=(
            "Declare a constant named PI with value 3.14 and print it.|3.14|const PI = 3.14; console.log(PI);"
            "Create a variable 'name' with 'JS' and print 'Hello ' followed by name.|Hello JS|let name = 'JS'; console.log('Hello ' + name);"
            "Calculate 15 modulo 4 and print it.|3|console.log(15 % 4);"
            "Add 5 and '5' (string) and print the result type.|string|console.log(typeof (5 + '5'));"
            "Print the length of the string 'Termux'.|6|console.log('Termux'.length);"
            "Print the character at index 2 of 'JavaScript'.|v|console.log('JavaScript'[2]);"
            "Create an array [1,2,3], remove the last element, and print the array.|[ 1, 2 ]|let a=[1,2,3]; a.pop(); console.log(a);"
            "Use .map() to double [1,2,3] and print the result.|[ 2, 4, 6 ]|console.log([1,2,3].map(x => x * 2));"
            "Print the keys of {a: 1, b: 2} as an array.|[ 'a', 'b' ]|console.log(Object.keys({a: 1, b: 2}));"
            "Write an arrow function 'greet' returning 'Hi' and print greet().|Hi|const greet = () => 'Hi'; console.log(greet());"
        )

        local rand_idx=$(( RANDOM % ${#challenges[@]} ))
        local selected="${challenges[$rand_idx]}"

        IFS='|' read -r desc expected hint <<< "$selected"
        if coding_challenge "$desc" "$expected" "$hint"; then
            ((CHALLENGES_WON++))
            ((missions_this_run++))
        fi
        
        echo -ne "${YELLOW}Try another mission? (y/n): ${NC}"
        read -r next_confirm
        [[ ! "$next_confirm" =~ ^[Yy]$ ]] && break
    done
}

#=====================================================
# FINAL SUMMARY & CERTIFICATE
#=====================================================

show_final_summary() {
    clear_screen

    echo -e "${CYAN}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                                                            ║"
    echo "║      🎓 CONGRATULATIONS! COURSE COMPLETE! 🎓               ║"
    echo "║                                                            ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo ""

    show_progress

    echo -e "${WHITE}📚 Topics Covered:${NC}"
    echo -e "  ${GREEN}✅${NC} Variables & Data Types"
    echo -e "  ${GREEN}✅${NC} Operators"
    echo -e "  ${GREEN}✅${NC} Strings & Methods"
    echo -e "  ${GREEN}✅${NC} Conditional Statements"
    echo -e "  ${GREEN}✅${NC} Loops"
    echo -e "  ${GREEN}✅${NC} Functions & Closures"
    echo -e "  ${GREEN}✅${NC} Arrays"
    echo -e "  ${GREEN}✅${NC} Objects"
    echo -e "  ${GREEN}✅${NC} Array Methods (map, filter, reduce)"
    echo -e "  ${GREEN}✅${NC} Destructuring & Spread"
    echo -e "  ${GREEN}✅${NC} Classes & OOP"
    echo -e "  ${GREEN}✅${NC} Promises & Async/Await"
    echo -e "  ${GREEN}✅${NC} Error Handling"
    echo -e "  ${GREEN}✅${NC} Modules & File I/O"
    echo -e "  ${GREEN}✅${NC} Final Project (Todo App)"
    echo ""

    echo -e "${YELLOW}📂 Lesson files saved in: $LESSON_DIR${NC}"
    echo ""

    echo -e "${CYAN}🚀 NEXT STEPS:${NC}"
    echo -e "  1. Practice building more projects"
    echo -e "  2. Learn a framework (Express.js, React)"
    echo -e "  3. Explore npm packages"
    echo -e "  4. Build REST APIs with Node.js"
    echo -e "  5. Try: ${CYAN}npm init${NC} in a new project"
    echo ""

    echo -e "${WHITE}Useful Termux commands:${NC}"
    echo -e "  ${CYAN}node${NC}              → Start Node.js REPL"
    echo -e "  ${CYAN}node file.js${NC}      → Run a JavaScript file"
    echo -e "  ${CYAN}npm init -y${NC}       → Create a new project"
    echo -e "  ${CYAN}npm install pkg${NC}   → Install a package"
    echo ""

    echo -e "${GREEN}Thank you for learning JavaScript! Happy Coding! 🎉${NC}"
    echo ""
}

#=====================================================
# MAIN MENU
#=====================================================

main_menu() {
    while true; do
        clear_screen
        echo -e "${CYAN}"
        echo "╔════════════════════════════════════════════════════════╗"
        echo "║     📚 COMPLETE JAVASCRIPT COURSE FOR TERMUX 📚      ║"
        echo "╠════════════════════════════════════════════════════════╣"
        echo "║                                                      ║"
        echo "║   0)  $(is_lesson_unlocked 0 && echo "📖" || echo "🔒") Introduction                                ║"
        echo "║   1)  $(is_lesson_unlocked 1 && echo "📖" || echo "🔒") Variables & Data Types                      ║"
        echo "║   2)  $(is_lesson_unlocked 2 && echo "📖" || echo "🔒") Operators                                   ║"
        echo "║   3)  $(is_lesson_unlocked 3 && echo "📖" || echo "🔒") Strings & String Methods                    ║"
        echo "║   4)  $(is_lesson_unlocked 4 && echo "📖" || echo "🔒") Conditional Statements                      ║"
        echo "║   5)  $(is_lesson_unlocked 5 && echo "📖" || echo "🔒") Loops                                       ║"
        echo "║   6)  $(is_lesson_unlocked 6 && echo "📖" || echo "🔒") Functions                                   ║"
        echo "║   7)  $(is_lesson_unlocked 7 && echo "📖" || echo "🔒") Arrays                                      ║"
        echo "║   8)  $(is_lesson_unlocked 8 && echo "📖" || echo "🔒") Objects                                     ║"
        echo "║   9)  $(is_lesson_unlocked 9 && echo "📖" || echo "🔒") Array Methods (map/filter/reduce)           ║"
        echo "║  10)  $(is_lesson_unlocked 10 && echo "📖" || echo "🔒") Destructuring & Spread                      ║"
        echo "║  11)  $(is_lesson_unlocked 11 && echo "📖" || echo "🔒") Classes & OOP                               ║"
        echo "║  12)  $(is_lesson_unlocked 12 && echo "📖" || echo "🔒") Promises & Async/Await                      ║"
        echo "║  13)  $(is_lesson_unlocked 13 && echo "📖" || echo "🔒") Error Handling                              ║"
        echo "║  14)  $(is_lesson_unlocked 14 && echo "📖" || echo "🔒") Modules & File I/O                          ║"
        echo "║  15)  $(is_lesson_unlocked 15 && echo "📖" || echo "🔒") Final Project (Todo App)                    ║"
        echo "╠════════════════════════════════════════════════════════╣"
        echo "║   P)  ⚡ Try It Yourself (Playground)                ║"
        echo "║   C)  🏆 Challenge Mode (Random Missions)            ║"
        echo "║   R)  🧹 Reset Progress                             ║"
        echo "║   A)  🚀 Run ALL Lessons (Full Course)               ║"
        echo "║   Q)  🚪 Quit                                        ║"
        echo "║                                                      ║"
        echo "╚════════════════════════════════════════════════════════╝"
        echo -e "${NC}"

        show_progress

        echo -ne "${WHITE}Choose a lesson (0-15, P, C, R, A, or Q): ${NC}"
        read -r choice

        case "$choice" in
            0) handle_lesson 0 lesson_0_introduction ;;
            1) handle_lesson 1 lesson_1_variables ;;
            2) handle_lesson 2 lesson_2_operators ;;
            3) handle_lesson 3 lesson_3_strings ;;
            4) handle_lesson 4 lesson_4_conditionals ;;
            5) handle_lesson 5 lesson_5_loops ;;
            6) handle_lesson 6 lesson_6_functions ;;
            7) handle_lesson 7 lesson_7_arrays ;;
            8) handle_lesson 8 lesson_8_objects ;;
            9) handle_lesson 9 lesson_9_array_methods ;;
            10) handle_lesson 10 lesson_10_destructuring ;;
            11) handle_lesson 11 lesson_11_classes ;;
            12) handle_lesson 12 lesson_12_async ;;
            13) handle_lesson 13 lesson_13_errors ;;
            14) handle_lesson 14 lesson_14_modules ;;
            15) handle_lesson 15 lesson_15_final_project ;;
            [pP]) try_it_yourself ;;
            [cC]) challenge_mode; save_progress ;;
            [rR]) reset_progress ;;
            [aA])
                lesson_0_introduction
                lesson_1_variables
                lesson_2_operators
                lesson_3_strings
                lesson_4_conditionals
                lesson_5_loops
                lesson_6_functions
                lesson_7_arrays
                lesson_8_objects
                lesson_9_array_methods
                lesson_10_destructuring
                lesson_11_classes
                lesson_12_async
                lesson_13_errors
                lesson_14_modules
                lesson_15_final_project
                for i in {0..15}; do DONE_LESSONS[$i]=1; done
                save_progress
                show_final_summary
                press_enter
                ;;
            [qQ])
                save_progress
                show_final_summary
                exit 0
                ;;
            *)
                echo -e "${RED}Invalid option. Please try again.${NC}"
                sleep 1
                ;;
        esac
    done
}

#=====================================================
# START THE COURSE
#=====================================================

check_prerequisites
main_menu