#!/data/data/com.termux/files/usr/bin/bash

#=========================================================
#  COMPLETE SHELL SCRIPTING LESSON FOR TERMUX
#  File: shell_lesson.sh
#  Usage: chmod +x shell_lesson.sh && ./shell_lesson.sh
#=========================================================

# --- Colors for better readability ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
WHITE='\033[1;37m'
BOLD='\033[1m'
UNDERLINE='\033[4m'
NC='\033[0m' # No Color

# --- Helper Functions ---
print_header() {
    clear
    echo -e "${BLUE}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${WHITE}${BOLD}        COMPLETE SHELL SCRIPTING LESSON - TERMUX         ${BLUE}║${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

print_lesson_title() {
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}${BOLD}  📘 $1${NC}"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

print_code() {
    echo -e "${CYAN}  ┌─ Code ─────────────────────────────────────────────┐${NC}"
    while IFS= read -r line; do
        echo -e "${CYAN}  │${WHITE}  $line${NC}"
    done <<< "$1"
    echo -e "${CYAN}  └──────────────────────────────────────────────────────┘${NC}"
    echo ""
}

print_output() {
    echo -e "${MAGENTA}  ┌─ Output ────────────────────────────────────────────┐${NC}"
    while IFS= read -r line; do
        echo -e "${MAGENTA}  │${WHITE}  $line${NC}"
    done <<< "$1"
    echo -e "${MAGENTA}  └──────────────────────────────────────────────────────┘${NC}"
    echo ""
}

print_note() {
    echo -e "${YELLOW}  💡 NOTE: ${WHITE}$1${NC}"
    echo ""
}

print_tip() {
    echo -e "${GREEN}  ✅ TIP: ${WHITE}$1${NC}"
    echo ""
}

print_warning() {
    echo -e "${RED}  ⚠️  WARNING: ${WHITE}$1${NC}"
    echo ""
}

pause_lesson() {
    echo ""
    echo -e "${BLUE}─────────────────────────────────────────────────────────${NC}"
    echo -ne "${YELLOW}  Press [Enter] to continue or [q] to quit... ${NC}"
    read -r input
    if [[ "$input" == "q" || "$input" == "Q" ]]; then
        echo -e "${GREEN}Thanks for learning! Goodbye! 👋${NC}"
        exit 0
    fi
}

run_demo() {
    echo -e "${GREEN}  ▶ Running demo...${NC}"
    echo -e "${MAGENTA}  ┌─ Live Output ─────────────────────────────────────────┐${NC}"
    eval "$1" 2>&1 | while IFS= read -r line; do
        echo -e "${MAGENTA}  │${WHITE}  $line${NC}"
    done
    echo -e "${MAGENTA}  └──────────────────────────────────────────────────────────┘${NC}"
    echo ""
}

quiz() {
    local question="$1"
    local answer="$2"
    local explanation="$3"
    
    echo -e "${YELLOW}  ┌─ 🧠 Quiz ──────────────────────────────────────────────┐${NC}"
    echo -e "${YELLOW}  │${WHITE}  $question${NC}"
    echo -e "${YELLOW}  └──────────────────────────────────────────────────────────┘${NC}"
    echo -ne "${CYAN}  Your answer: ${NC}"
    read -r user_answer
    
    if [[ "${user_answer,,}" == "${answer,,}" ]]; then
        echo -e "${GREEN}  ✅ Correct! $explanation${NC}"
    else
        echo -e "${RED}  ❌ Not quite. The answer is: ${WHITE}$answer${NC}"
        echo -e "${YELLOW}  📖 $explanation${NC}"
    fi
    echo ""
}

# ============================================================
# MAIN MENU
# ============================================================
show_menu() {
    print_header
    echo -e "${WHITE}${BOLD}  Choose a lesson:${NC}"
    echo ""
    echo -e "${GREEN}   1)${WHITE}  Introduction & First Script${NC}"
    echo -e "${GREEN}   2)${WHITE}  Variables & Data Types${NC}"
    echo -e "${GREEN}   3)${WHITE}  User Input & Output${NC}"
    echo -e "${GREEN}   4)${WHITE}  String Operations${NC}"
    echo -e "${GREEN}   5)${WHITE}  Arithmetic & Math${NC}"
    echo -e "${GREEN}   6)${WHITE}  Conditional Statements (if/else)${NC}"
    echo -e "${GREEN}   7)${WHITE}  Case Statements${NC}"
    echo -e "${GREEN}   8)${WHITE}  Loops (for, while, until)${NC}"
    echo -e "${GREEN}   9)${WHITE}  Arrays${NC}"
    echo -e "${GREEN}  10)${WHITE}  Functions${NC}"
    echo -e "${GREEN}  11)${WHITE}  File Operations${NC}"
    echo -e "${GREEN}  12)${WHITE}  Text Processing (grep, sed, awk)${NC}"
    echo -e "${GREEN}  13)${WHITE}  Pipes & Redirection${NC}"
    echo -e "${GREEN}  14)${WHITE}  Process Management${NC}"
    echo -e "${GREEN}  15)${WHITE}  Error Handling & Debugging${NC}"
    echo -e "${GREEN}  16)${WHITE}  Regular Expressions${NC}"
    echo -e "${GREEN}  17)${WHITE}  Termux-Specific Commands${NC}"
    echo -e "${GREEN}  18)${WHITE}  Practical Projects${NC}"
    echo -e "${GREEN}  19)${WHITE}  Best Practices & Tips${NC}"
    echo -e "${GREEN}  20)${WHITE}  Run ALL Lessons Sequentially${NC}"
    echo -e "${RED}   0)${WHITE}  Exit${NC}"
    echo ""
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -ne "${CYAN}  Enter your choice [0-20]: ${NC}"
}

# ============================================================
# LESSON 1: INTRODUCTION & FIRST SCRIPT
# ============================================================
lesson_1() {
    print_header
    print_lesson_title "LESSON 1: Introduction & Your First Script"
    
    echo -e "${WHITE}  ${BOLD}What is Shell Scripting?${NC}"
    echo -e "${WHITE}  Shell scripting is writing a series of commands in a file${NC}"
    echo -e "${WHITE}  that the shell (command-line interpreter) can execute.${NC}"
    echo -e "${WHITE}  In Termux, we use ${BOLD}Bash${NC}${WHITE} (Bourne Again Shell).${NC}"
    echo ""
    
    echo -e "${WHITE}  ${BOLD}Why Learn Shell Scripting?${NC}"
    echo -e "${WHITE}  • Automate repetitive tasks${NC}"
    echo -e "${WHITE}  • Manage files and directories efficiently${NC}"
    echo -e "${WHITE}  • Create tools and utilities${NC}"
    echo -e "${WHITE}  • System administration${NC}"
    echo -e "${WHITE}  • Process text and data${NC}"
    echo ""
    
    pause_lesson
    
    echo -e "${WHITE}  ${BOLD}Setting Up Termux for Scripting:${NC}"
    echo ""
    
    print_code 'pkg update && pkg upgrade
pkg install nano vim curl wget git'
    
    print_note "These are essential packages for development in Termux."
    
    echo -e "${WHITE}  ${BOLD}Your First Script - hello.sh:${NC}"
    echo ""
    
    print_code '#!/data/data/com.termux/files/usr/bin/bash
# This is a comment - it explains code
# Script: hello.sh - My first shell script

echo "Hello, World!"
echo "Welcome to Shell Scripting in Termux!"
echo "Today is: $(date)"
echo "You are: $(whoami)"
echo "Current directory: $(pwd)"'

    echo -e "${WHITE}  ${BOLD}The Shebang Line (#!):${NC}"
    echo -e "${WHITE}  The first line ${CYAN}#!/data/data/com.termux/files/usr/bin/bash${NC}"
    echo -e "${WHITE}  tells the system which interpreter to use.${NC}"
    echo ""
    
    echo -e "${WHITE}  ${BOLD}Termux Shebang Options:${NC}"
    print_code '#!/data/data/com.termux/files/usr/bin/bash    # Full path
#!/usr/bin/env bash                             # Portable (recommended)'
    
    echo -e "${WHITE}  ${BOLD}Making a Script Executable:${NC}"
    print_code 'chmod +x hello.sh    # Add execute permission
./hello.sh           # Run the script
bash hello.sh        # Alternative: run with bash directly'
    
    echo -e "${GREEN}  ▶ Live Demo:${NC}"
    run_demo 'echo "Hello, World!"
echo "Welcome to Shell Scripting in Termux!"
echo "Today is: $(date)"
echo "You are: $(whoami)"
echo "Current directory: $(pwd)"'
    
    echo -e "${WHITE}  ${BOLD}File Permissions Explained:${NC}"
    print_code 'chmod +x script.sh   # Make executable for all
chmod 755 script.sh  # rwxr-xr-x (owner: full, others: read+execute)
chmod 700 script.sh  # rwx------ (only owner can access)
ls -la script.sh     # View permissions'
    
    quiz "What does the shebang (#!) line do?" \
         "tells the system which interpreter to use" \
         "The shebang specifies the path to the interpreter (like bash)."
    
    pause_lesson
}

# ============================================================
# LESSON 2: VARIABLES & DATA TYPES
# ============================================================
lesson_2() {
    print_header
    print_lesson_title "LESSON 2: Variables & Data Types"
    
    echo -e "${WHITE}  ${BOLD}What are Variables?${NC}"
    echo -e "${WHITE}  Variables are containers that store data (text, numbers, etc.)${NC}"
    echo -e "${WHITE}  You can reference them later in your script.${NC}"
    echo ""
    
    echo -e "${WHITE}  ${BOLD}Variable Rules:${NC}"
    echo -e "${WHITE}  • No spaces around the = sign${NC}"
    echo -e "${WHITE}  • Start with a letter or underscore${NC}"
    echo -e "${WHITE}  • Case-sensitive (Name ≠ name)${NC}"
    echo -e "${WHITE}  • Use \$ to reference a variable${NC}"
    echo ""
    
    echo -e "${WHITE}  ${BOLD}1. Basic Variables:${NC}"
    print_code 'name="John"
age=25
city="New York"

echo "Name: $name"
echo "Age: $age"
echo "City: $city"'
    
    run_demo 'name="John"
age=25
city="New York"
echo "Name: $name"
echo "Age: $age"
echo "City: $city"'
    
    pause_lesson
    
    echo -e "${WHITE}  ${BOLD}2. Variable Types:${NC}"
    echo ""
    
    echo -e "${WHITE}  ${UNDERLINE}String Variables:${NC}"
    print_code 'greeting="Hello World"
single_quoted='"'"'This is literal $greeting'"'"'
double_quoted="This expands $greeting"

echo "$single_quoted"
echo "$double_quoted"'
    
    run_demo 'greeting="Hello World"
single_quoted='"'"'This is literal $greeting'"'"'
double_quoted="This expands $greeting"
echo "Single quotes: $single_quoted"
echo "Double quotes: $double_quoted"'
    
    print_note "Single quotes preserve literal text. Double quotes allow variable expansion."
    
    echo -e "${WHITE}  ${UNDERLINE}Integer Variables:${NC}"
    print_code 'declare -i number=42      # Declare as integer
readonly PI=3.14159       # Read-only constant
echo "Number: $number"
echo "PI: $PI"'
    
    run_demo 'declare -i number=42
readonly PI=3.14159
echo "Number: $number"
echo "PI: $PI"'
    
    pause_lesson
    
    echo -e "${WHITE}  ${BOLD}3. Environment Variables:${NC}"
    print_code 'echo "Home: $HOME"
echo "User: $USER"
echo "Shell: $SHELL"
echo "Path: $PATH"
echo "Term: $TERM"
echo "PWD: $PWD"
echo "Random: $RANDOM"'
    
    run_demo 'echo "Home: $HOME"
echo "User: $USER"
echo "Shell: $SHELL"
echo "Path: $PATH"
echo "PWD: $PWD"
echo "Random: $RANDOM"'
    
    echo -e "${WHITE}  ${BOLD}4. Special Variables:${NC}"
    print_code '$0    # Script name
$1-$9 # Positional parameters (arguments)
$#    # Number of arguments
$@    # All arguments as separate words
$*    # All arguments as single string
$?    # Exit status of last command
$$    # Current process ID
$!    # PID of last background process'
    
    run_demo 'echo "Script name: $0"
echo "Process ID: $$"
echo "Last exit status: $?"'
    
    pause_lesson
    
    echo -e "${WHITE}  ${BOLD}5. Command Substitution:${NC}"
    print_code 'current_date=$(date)
file_count=$(ls | wc -l)
my_ip=$(hostname -I 2>/dev/null || echo "N/A")

echo "Date: $current_date"
echo "Files in directory: $file_count"

# Backtick style (older, avoid)
old_style=`date`'
    
    run_demo 'current_date=$(date)
file_count=$(ls | wc -l)
echo "Date: $current_date"
echo "Files in directory: $file_count"'
    
    echo -e "${WHITE}  ${BOLD}6. Variable Operations:${NC}"
    print_code '# String length
name="Termux"
echo "Length: ${#name}"         # Output: 6

# Default values
echo "${undefined:-default}"   # Use default if unset
echo "${undefined:=assigned}"  # Assign default if unset

# Substring
text="Hello World"
echo "${text:0:5}"             # Output: Hello
echo "${text:6}"               # Output: World

# Replace
path="/home/user/file.txt"
echo "${path/user/admin}"      # Replace first occurrence
echo "${path//\//\\}"          # Replace all / with \'
    
    run_demo 'name="Termux"
echo "Length of name: ${#name}"
echo "Default value: ${undefined:-default_value}"
text="Hello World"
echo "Substring (0-5): ${text:0:5}"
echo "Substring (6+): ${text:6}"
path="/home/user/file.txt"
echo "Replace: ${path/user/admin}"'
    
    echo -e "${WHITE}  ${BOLD}7. Exporting Variables:${NC}"
    print_code 'export MY_VAR="Available to child processes"
MY_LOCAL="Only in this shell"

# Unsetting variables
unset MY_VAR'
    
    quiz "What character do you use to reference a variable?" \
         "\$" \
         "The dollar sign (\$) is used to reference/expand variables."
    
    pause_lesson
}

# ============================================================
# LESSON 3: USER INPUT & OUTPUT
# ============================================================
lesson_3() {
    print_header
    print_lesson_title "LESSON 3: User Input & Output"
    
    echo -e "${WHITE}  ${BOLD}1. Echo Command - Basic Output:${NC}"
    print_code 'echo "Hello World"              # With newline
echo -n "No newline at end"       # Without newline
echo -e "Tab:\there"              # Enable escape sequences
echo -e "Line1\nLine2"            # Newline
echo -e "\033[31mRed Text\033[0m" # Colored output'
    
    run_demo 'echo "Hello World"
echo -n "No newline: "
echo "continues here"
echo -e "Tab:\there"
echo -e "Line1\nLine2"
echo -e "\033[31mRed Text\033[0m"
echo -e "\033[32mGreen Text\033[0m"
echo -e "\033[34mBlue Text\033[0m"'
    
    pause_lesson
    
    echo -e "${WHITE}  ${BOLD}2. Printf - Formatted Output:${NC}"
    print_code 'printf "Name: %s\n" "John"
printf "Age: %d\n" 25
printf "Price: $%.2f\n" 19.99
printf "Hex: %x\n" 255
printf "%-20s %5d\n" "Alice" 90
printf "%-20s %5d\n" "Bob" 85'
    
    run_demo 'printf "Name: %s\n" "John"
printf "Age: %d\n" 25
printf "Price: $%.2f\n" 19.99
printf "Hex: %x\n" 255
echo ""
echo "Formatted Table:"
printf "%-20s %5s\n" "Name" "Score"
printf "%-20s %5s\n" "----" "-----"
printf "%-20s %5d\n" "Alice" 90
printf "%-20s %5d\n" "Bob" 85
printf "%-20s %5d\n" "Charlie" 92'
    
    pause_lesson
    
    echo -e "${WHITE}  ${BOLD}3. Read Command - User Input:${NC}"
    print_code 'read -p "Enter your name: " name
echo "Hello, $name!"

read -sp "Enter password: " pass  # -s = silent
echo ""

read -p "Enter age: " -t 10 age  # -t = timeout (seconds)

read -p "Continue? (y/n): " -n 1 choice  # -n 1 = one char
echo ""'
    
    echo -e "${GREEN}  ▶ Interactive Demo:${NC}"
    echo ""
    read -p "  Enter your name: " demo_name
    echo -e "  ${WHITE}Hello, ${GREEN}$demo_name${WHITE}! Welcome to the lesson!${NC}"
    echo ""
    read -p "  Enter your favorite color: " demo_color
    echo -e "  ${WHITE}Nice! ${GREEN}$demo_color${WHITE} is a great color!${NC}"
    echo ""
    
    pause_lesson
    
    echo -e "${WHITE}  ${BOLD}4. Reading Multiple Values:${NC}"
    print_code 'echo "Enter three numbers separated by spaces:"
read -p "> " num1 num2 num3
echo "You entered: $num1, $num2, $num3"

# Read into array
read -p "Enter words: " -a words
echo "First word: ${words[0]}"
echo "All words: ${words[@]}"'
    
    echo -e "${WHITE}  ${BOLD}5. Here Documents (Heredoc):${NC}"
    print_code 'cat << EOF
This is a multi-line
text block. Variables work: $HOME
Commands work: $(date)
EOF

# Indented heredoc (use <<- with tabs)
cat <<- EOF
    This text can be indented
    with tabs
EOF'
    
    run_demo 'cat << EOF
==============================
  Welcome to Termux!
  User: $(whoami)
  Date: $(date +%Y-%m-%d)
  Home: $HOME
==============================
EOF'
    
    echo -e "${WHITE}  ${BOLD}6. Color Output Reference:${NC}"
    print_code '# Color codes
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[34m"
MAGENTA="\033[35m"
CYAN="\033[36m"
BOLD="\033[1m"
RESET="\033[0m"

echo -e "${RED}Error message${RESET}"
echo -e "${GREEN}Success message${RESET}"
echo -e "${YELLOW}Warning message${RESET}"
echo -e "${BOLD}Bold text${RESET}"'
    
    run_demo 'echo -e "\033[31m● Red\033[0m"
echo -e "\033[32m● Green\033[0m"
echo -e "\033[33m● Yellow\033[0m"
echo -e "\033[34m● Blue\033[0m"
echo -e "\033[35m● Magenta\033[0m"
echo -e "\033[36m● Cyan\033[0m"
echo -e "\033[1m● Bold\033[0m"
echo -e "\033[4m● Underline\033[0m"
echo -e "\033[7m● Inverted\033[0m"'
    
    quiz "What flag makes 'read' hide user input (for passwords)?" \
         "-s" \
         "The -s flag makes read silent, hiding typed characters."
    
    pause_lesson
}

# ============================================================
# LESSON 4: STRING OPERATIONS
# ============================================================
lesson_4() {
    print_header
    print_lesson_title "LESSON 4: String Operations"
    
    echo -e "${WHITE}  ${BOLD}1. String Length:${NC}"
    print_code 'str="Hello Termux"
echo "Length: ${#str}"           # 12
echo "Length: $(echo -n "$str" | wc -c)"  # Alternative'
    
    run_demo 'str="Hello Termux"
echo "String: $str"
echo "Length: ${#str}"'
    
    echo -e "${WHITE}  ${BOLD}2. Substring Extraction:${NC}"
    print_code 'str="Hello World Termux"
echo "${str:0:5}"    # Hello (start:length)
echo "${str:6:5}"    # World
echo "${str:12}"     # Termux (from position 12)
echo "${str: -6}"    # Termux (last 6 chars, note the space)'
    
    run_demo 'str="Hello World Termux"
echo "Full: $str"
echo "First 5: ${str:0:5}"
echo "Middle: ${str:6:5}"
echo "From 12: ${str:12}"
echo "Last 6: ${str: -6}"'
    
    pause_lesson
    
    echo -e "${WHITE}  ${BOLD}3. String Replacement:${NC}"
    print_code 'str="Hello World World"
echo "${str/World/Termux}"     # Replace first: Hello Termux World
echo "${str//World/Termux}"    # Replace all: Hello Termux Termux
echo "${str/#Hello/Hi}"        # Replace at start
echo "${str/%World/Termux}"    # Replace at end'
    
    run_demo 'str="Hello World World"
echo "Original:      $str"
echo "Replace first: ${str/World/Termux}"
echo "Replace all:   ${str//World/Termux}"
echo "Replace start: ${str/#Hello/Hi}"
echo "Replace end:   ${str/%World/Termux}"'
    
    echo -e "${WHITE}  ${BOLD}4. String Deletion (Pattern Removal):${NC}"
    print_code 'file="/home/user/documents/report.txt"

echo "${file#*/}"      # home/user/documents/report.txt (remove shortest from start)
echo "${file##*/}"     # report.txt (remove longest from start)
echo "${file%/*}"      # /home/user/documents (remove shortest from end)
echo "${file%%/*}"     # (empty - remove longest from end)

# Practical: Get filename and extension
filename="${file##*/}"           # report.txt
extension="${filename##*.}"      # txt
name_only="${filename%.*}"       # report'
    
    run_demo 'file="/home/user/documents/report.txt"
echo "Full path: $file"
echo "Remove shortest from start (#*/): ${file#*/}"
echo "Remove longest from start (##*/): ${file##*/}"
echo "Remove shortest from end (%/*): ${file%/*}"
echo ""
filename="${file##*/}"
echo "Filename: $filename"
echo "Extension: ${filename##*.}"
echo "Name only: ${filename%.*}"'
    
    pause_lesson
    
    echo -e "${WHITE}  ${BOLD}5. String Comparison:${NC}"
    print_code 'str1="hello"
str2="world"

# Using [[ ]] (preferred)
[[ "$str1" == "$str2" ]] && echo "Equal" || echo "Not equal"
[[ "$str1" != "$str2" ]] && echo "Different"
[[ "$str1" < "$str2" ]]  && echo "$str1 comes before $str2"
[[ -z "$str1" ]]         && echo "Empty" || echo "Not empty"
[[ -n "$str1" ]]         && echo "Has value"'
    
    run_demo 'str1="hello"
str2="world"
str3=""

[[ "$str1" == "$str2" ]] && echo "$str1 == $str2: true" || echo "$str1 == $str2: false"
[[ "$str1" != "$str2" ]] && echo "$str1 != $str2: true" || echo "$str1 != $str2: false"
[[ "$str1" < "$str2" ]] && echo "$str1 comes before $str2 alphabetically"
[[ -z "$str3" ]] && echo "str3 is empty: true"
[[ -n "$str1" ]] && echo "str1 has value: true"'
    
    echo -e "${WHITE}  ${BOLD}6. Case Conversion:${NC}"
    print_code 'str="Hello World"
echo "${str^^}"    # HELLO WORLD (uppercase)
echo "${str,,}"    # hello world (lowercase)
echo "${str^}"     # Hello World (capitalize first)
echo "${str~}"     # toggle first char case'
    
    run_demo 'str="Hello World"
echo "Original:   $str"
echo "Uppercase:  ${str^^}"
echo "Lowercase:  ${str,,}"
echo "Capitalize: ${str^}"'
    
    echo -e "${WHITE}  ${BOLD}7. String Concatenation:${NC}"
    print_code 'first="Hello"
second="World"

# Method 1: Direct
result="$first $second"

# Method 2: Append
result="$first"
result+=" $second"

# Method 3: printf
result=$(printf "%s %s" "$first" "$second")'
    
    run_demo 'first="Hello"
second="World"
result="$first $second"
echo "Concatenated: $result"
result+="!!!"
echo "Appended: $result"'
    
    quiz "How do you get the length of a variable str?" \
         '${#str}' \
         '${#str} returns the number of characters in the variable.'
    
    pause_lesson
}

# ============================================================
# LESSON 5: ARITHMETIC & MATH
# ============================================================
lesson_5() {
    print_header
    print_lesson_title "LESSON 5: Arithmetic & Math Operations"
    
    echo -e "${WHITE}  ${BOLD}1. Arithmetic Expansion $(( )):${NC}"
    print_code 'a=10
b=3

echo "Add:      $((a + b))"      # 13
echo "Subtract: $((a - b))"      # 7
echo "Multiply: $((a * b))"      # 30
echo "Divide:   $((a / b))"      # 3 (integer division)
echo "Modulus:  $((a % b))"      # 1
echo "Power:    $((a ** 2))"     # 100'
    
    run_demo 'a=10; b=3
echo "a=$a, b=$b"
echo "Add:      $((a + b))"
echo "Subtract: $((a - b))"
echo "Multiply: $((a * b))"
echo "Divide:   $((a / b))"
echo "Modulus:  $((a % b))"
echo "Power:    $((a ** 2))"'
    
    pause_lesson
    
    echo -e "${WHITE}  ${BOLD}2. let Command:${NC}"
    print_code 'let "result = 5 + 3"
let "result += 10"
let "result++"
let "result--"
echo "Result: $result"'
    
    run_demo 'let "result = 5 + 3"
echo "5 + 3 = $result"
let "result += 10"
echo "+= 10 = $result"
let "result++"
echo "++ = $result"
let "result--"
echo "-- = $result"'
    
    echo -e "${WHITE}  ${BOLD}3. expr Command (Older Method):${NC}"
    print_code 'result=$(expr 5 + 3)
result=$(expr 10 \* 3)   # Note: * must be escaped
echo "Result: $result"'
    
    echo -e "${WHITE}  ${BOLD}4. Floating Point with bc:${NC}"
    print_code '# bc - Basic Calculator
echo "scale=2; 10/3" | bc          # 3.33
echo "scale=4; sqrt(2)" | bc -l    # 1.4142
echo "3.14 * 2.5" | bc             # 7.85

# Store result
pi=$(echo "scale=10; 4*a(1)" | bc -l)
echo "PI = $pi"'
    
    run_demo 'echo "Division: $(echo "scale=2; 10/3" | bc)"
echo "Square root of 2: $(echo "scale=4; sqrt(2)" | bc -l)"
echo "PI: $(echo "scale=10; 4*a(1)" | bc -l)"
echo "Circle area (r=5): $(echo "scale=2; 3.14159 * 5^2" | bc)"'
    
    print_tip "Install bc with: pkg install bc"
    
    pause_lesson
    
    echo -e "${WHITE}  ${BOLD}5. Comparison Operators:${NC}"
    print_code '# Integer comparison
[[ 5 -eq 5 ]]   # Equal
[[ 5 -ne 3 ]]   # Not equal
[[ 5 -gt 3 ]]   # Greater than
[[ 3 -lt 5 ]]   # Less than
[[ 5 -ge 5 ]]   # Greater or equal
[[ 3 -le 5 ]]   # Less or equal

# Inside (( )) - C-style
(( 5 == 5 ))    # Equal
(( 5 != 3 ))    # Not equal
(( 5 > 3 ))     # Greater than
(( 3 < 5 ))     # Less than'
    
    run_demo 'a=10; b=5
(( a > b )) && echo "$a > $b: true" || echo "$a > $b: false"
(( a == b )) && echo "$a == $b: true" || echo "$a == $b: false"
(( a != b )) && echo "$a != $b: true" || echo "$a != $b: false"
[[ $a -ge $b ]] && echo "$a >= $b: true"
[[ $b -le $a ]] && echo "$b <= $a: true"'
    
    echo -e "${WHITE}  ${BOLD}6. Bitwise Operations:${NC}"
    print_code 'echo $((5 & 3))    # AND: 1
echo $((5 | 3))    # OR: 7
echo $((5 ^ 3))    # XOR: 6
echo $((~5))       # NOT: -6
echo $((5 << 1))   # Left shift: 10
echo $((5 >> 1))   # Right shift: 2'
    
    run_demo 'echo "5 AND 3: $((5 & 3))"
echo "5 OR 3:  $((5 | 3))"
echo "5 XOR 3: $((5 ^ 3))"
echo "Left shift 5<<1:  $((5 << 1))"
echo "Right shift 5>>1: $((5 >> 1))"'
    
    echo -e "${WHITE}  ${BOLD}7. Practical Math Examples:${NC}"
    print_code '# Temperature converter
celsius=100
fahrenheit=$(( (celsius * 9/5) + 32 ))
echo "${celsius}°C = ${fahrenheit}°F"

# Random number in range
min=1; max=100
random=$(( (RANDOM % (max - min + 1)) + min ))
echo "Random (1-100): $random"'
    
    run_demo 'celsius=100
fahrenheit=$(( (celsius * 9/5) + 32 ))
echo "${celsius}°C = ${fahrenheit}°F"
echo ""
for i in {1..5}; do
    random=$(( (RANDOM % 100) + 1 ))
    echo "Random number $i: $random"
done'
    
    quiz "What does 10 % 3 return?" \
         "1" \
         "The modulus operator returns the remainder: 10 divided by 3 = 3 remainder 1"
    
    pause_lesson
}

# ============================================================
# LESSON 6: CONDITIONAL STATEMENTS
# ============================================================
lesson_6() {
    print_header
    print_lesson_title "LESSON 6: Conditional Statements (if/else)"
    
    echo -e "${WHITE}  ${BOLD}1. Basic if Statement:${NC}"
    print_code 'if [ condition ]; then
    # commands
fi

# Example
age=18
if [ $age -ge 18 ]; then
    echo "You are an adult"
fi'
    
    run_demo 'age=18
if [ $age -ge 18 ]; then
    echo "You are an adult"
fi'
    
    echo -e "${WHITE}  ${BOLD}2. if-else Statement:${NC}"
    print_code 'age=15
if [ $age -ge 18 ]; then
    echo "Adult"
else
    echo "Minor"
fi'
    
    run_demo 'age=15
if [ $age -ge 18 ]; then
    echo "Adult"
else
    echo "Minor (age: $age)"
fi'
    
    echo -e "${WHITE}  ${BOLD}3. if-elif-else Statement:${NC}"
    print_code 'score=85

if [ $score -ge 90 ]; then
    grade="A"
elif [ $score -ge 80 ]; then
    grade="B"
elif [ $score -ge 70 ]; then
    grade="C"
elif [ $score -ge 60 ]; then
    grade="D"
else
    grade="F"
fi

echo "Score: $score, Grade: $grade"'
    
    run_demo 'for score in 95 85 75 65 55; do
    if [ $score -ge 90 ]; then
        grade="A"
    elif [ $score -ge 80 ]; then
        grade="B"
    elif [ $score -ge 70 ]; then
        grade="C"
    elif [ $score -ge 60 ]; then
        grade="D"
    else
        grade="F"
    fi
    echo "Score: $score → Grade: $grade"
done'
    
    pause_lesson
    
    echo -e "${WHITE}  ${BOLD}4. Test Operators - [ ] vs [[ ]]:${NC}"
    echo ""
    echo -e "${WHITE}  ${UNDERLINE}File Tests:${NC}"
    print_code '[ -f file ]     # Is a regular file
[ -d dir ]      # Is a directory
[ -e path ]     # Exists
[ -r file ]     # Is readable
[ -w file ]     # Is writable
[ -x file ]     # Is executable
[ -s file ]     # File size > 0
[ -L file ]     # Is symbolic link
[ file1 -nt file2 ]  # file1 is newer
[ file1 -ot file2 ]  # file1 is older'
    
    run_demo 'echo "Checking files and directories:"
[ -f "$HOME/.bashrc" ] && echo "~/.bashrc exists" || echo "~/.bashrc not found"
[ -d "$HOME" ] && echo "$HOME is a directory"
[ -r "$HOME" ] && echo "$HOME is readable"
[ -w "$HOME" ] && echo "$HOME is writable"
[ -d "/sdcard" ] && echo "/sdcard exists" || echo "/sdcard not found"'
    
    pause_lesson
    
    echo -e "${WHITE}  ${UNDERLINE}String Tests:${NC}"
    print_code '[ -z "$str" ]        # String is empty
[ -n "$str" ]        # String is not empty
[ "$a" = "$b" ]      # Strings are equal (in [ ])
[[ "$a" == "$b" ]]   # Strings are equal (in [[ ]])
[[ "$a" != "$b" ]]   # Strings are not equal
[[ "$a" =~ regex ]]  # Regex match (only in [[ ]])'
    
    run_demo 'str1="hello"
str2=""
[[ -n "$str1" ]] && echo "str1 is not empty: \"$str1\""
[[ -z "$str2" ]] && echo "str2 is empty"
[[ "$str1" == "hello" ]] && echo "str1 equals hello"
[[ "$str1" =~ ^h ]] && echo "str1 starts with h (regex match)"'
    
    echo -e "${WHITE}  ${BOLD}5. Logical Operators:${NC}"
    print_code '# AND
[ condition1 ] && [ condition2 ]
[[ condition1 && condition2 ]]

# OR
[ condition1 ] || [ condition2 ]
[[ condition1 || condition2 ]]

# NOT
[ ! condition ]
[[ ! condition ]]'
    
    run_demo 'age=25
name="John"

if [[ $age -ge 18 && -n "$name" ]]; then
    echo "$name is an adult (age: $age)"
fi

hour=$(date +%H)
if [[ $hour -lt 12 ]]; then
    echo "Good morning!"
elif [[ $hour -lt 18 ]]; then
    echo "Good afternoon!"
else
    echo "Good evening!"
fi'
    
    echo -e "${WHITE}  ${BOLD}6. Ternary-like Operations:${NC}"
    print_code '# Using && and ||
age=20
status=$( (( age >= 18 )) && echo "adult" || echo "minor" )
echo "Status: $status"

# One-liners
[[ -f "file.txt" ]] && echo "exists" || echo "not found"'
    
    run_demo 'age=20
status=$( (( age >= 18 )) && echo "adult" || echo "minor" )
echo "Age $age: $status"

age=15
status=$( (( age >= 18 )) && echo "adult" || echo "minor" )
echo "Age $age: $status"'
    
    echo -e "${WHITE}  ${BOLD}7. Nested if Statements:${NC}"
    print_code 'num=15

if [ $num -gt 0 ]; then
    if [ $((num % 2)) -eq 0 ]; then
        echo "$num is positive and even"
    else
        echo "$num is positive and odd"
    fi
else
    echo "$num is not positive"
fi'
    
    run_demo 'for num in 15 -4 0 22 7; do
    if [ $num -gt 0 ]; then
        if [ $((num % 2)) -eq 0 ]; then
            echo "$num: positive and even"
        else
            echo "$num: positive and odd"
        fi
    elif [ $num -eq 0 ]; then
        echo "$num: zero"
    else
        echo "$num: negative"
    fi
done'
    
    quiz "What operator tests if a file exists?" \
         "-e" \
         "[ -e path ] returns true if the path exists (file or directory)."
    
    pause_lesson
}

# ============================================================
# LESSON 7: CASE STATEMENTS
# ============================================================
lesson_7() {
    print_header
    print_lesson_title "LESSON 7: Case Statements"
    
    echo -e "${WHITE}  ${BOLD}1. Basic Case Syntax:${NC}"
    print_code 'case $variable in
    pattern1)
        commands
        ;;
    pattern2)
        commands
        ;;
    pattern3|pattern4)
        commands
        ;;
    *)
        default commands
        ;;
esac'
    
    echo -e "${WHITE}  ${BOLD}2. Simple Case Example:${NC}"
    print_code 'fruit="apple"

case $fruit in
    apple)
        echo "🍎 An apple a day!"
        ;;
    banana)
        echo "🍌 Banana is yellow!"
        ;;
    orange)
        echo "🍊 Orange you glad?"
        ;;
    *)
        echo "Unknown fruit: $fruit"
        ;;
esac'
    
    run_demo 'for fruit in apple banana orange grape; do
    case $fruit in
        apple)  echo "🍎 $fruit - An apple a day!" ;;
        banana) echo "🍌 $fruit - Banana is yellow!" ;;
        orange) echo "🍊 $fruit - Orange you glad?" ;;
        *)      echo "❓ $fruit - Unknown fruit" ;;
    esac
done'
    
    pause_lesson
    
    echo -e "${WHITE}  ${BOLD}3. Pattern Matching in Case:${NC}"
    print_code 'read -p "Enter a character: " char

case $char in
    [a-z])      echo "Lowercase letter" ;;
    [A-Z])      echo "Uppercase letter" ;;
    [0-9])      echo "Digit" ;;
    ?)          echo "Special character" ;;
    *)          echo "Multiple characters or empty" ;;
esac'
    
    run_demo 'for char in a Z 5 @ "hi"; do
    case $char in
        [a-z])      echo "'$char' → Lowercase letter" ;;
        [A-Z])      echo "'$char' → Uppercase letter" ;;
        [0-9])      echo "'$char' → Digit" ;;
        ?)          echo "'$char' → Special character" ;;
        *)          echo "'$char' → Multiple characters" ;;
    esac
done'
    
    echo -e "${WHITE}  ${BOLD}4. Menu System with Case:${NC}"
    print_code 'echo "=== File Manager ==="
echo "1) List files"
echo "2) Show disk usage"
echo "3) Show date"
echo "4) Exit"
read -p "Choice: " choice

case $choice in
    1) ls -la ;;
    2) du -sh * ;;
    3) date ;;
    4) exit 0 ;;
    *) echo "Invalid choice" ;;
esac'
    
    echo -e "${WHITE}  ${BOLD}5. Case with File Extensions:${NC}"
    
    run_demo 'for file in script.sh image.png document.txt video.mp4 data.csv; do
    case "${file##*.}" in
        sh|bash)     echo "📜 $file → Shell script" ;;
        png|jpg|gif) echo "🖼️  $file → Image file" ;;
        txt|doc)     echo "📄 $file → Document" ;;
        mp4|avi|mkv) echo "🎬 $file → Video file" ;;
        csv|json)    echo "📊 $file → Data file" ;;
        *)           echo "❓ $file → Unknown type" ;;
    esac
done'
    
    echo -e "${WHITE}  ${BOLD}6. Case with Yes/No:${NC}"
    print_code 'read -p "Continue? (yes/no): " answer

case "${answer,,}" in   # ${answer,,} converts to lowercase
    yes|y|yeah|yep)
        echo "Continuing..."
        ;;
    no|n|nah|nope)
        echo "Stopping..."
        ;;
    *)
        echo "Please answer yes or no"
        ;;
esac'
    
    quiz "What does ;; do in a case statement?" \
         "ends a case block" \
         "The ;; terminates each case block, similar to break in other languages."
    
    pause_lesson
}

# ============================================================
# LESSON 8: LOOPS
# ============================================================
lesson_8() {
    print_header
    print_lesson_title "LESSON 8: Loops (for, while, until)"
    
    echo -e "${WHITE}  ${BOLD}1. For Loop - Basic:${NC}"
    print_code 'for name in Alice Bob Charlie; do
    echo "Hello, $name!"
done'
    
    run_demo 'for name in Alice Bob Charlie David Eve; do
    echo "Hello, $name!"
done'
    
    echo -e "${WHITE}  ${BOLD}2. For Loop - Range:${NC}"
    print_code 'for i in {1..5}; do
    echo "Number: $i"
done

# With step
for i in {0..20..5}; do
    echo "Count: $i"
done'
    
    run_demo 'echo "Counting 1-5:"
for i in {1..5}; do
    echo "  $i"
done
echo ""
echo "Counting by 5s (0-20):"
for i in {0..20..5}; do
    echo "  $i"
done'
    
    pause_lesson
    
    echo -e "${WHITE}  ${BOLD}3. C-style For Loop:${NC}"
    print_code 'for ((i=0; i<5; i++)); do
    echo "Index: $i"
done

# Countdown
for ((i=10; i>=0; i--)); do
    echo "$i..."
done
echo "Liftoff!"'
    
    run_demo 'echo "C-style loop:"
for ((i=0; i<5; i++)); do
    echo "  Index: $i"
done
echo ""
echo "Countdown:"
for ((i=5; i>=0; i--)); do
    echo -n "  $i"
    [[ $i -gt 0 ]] && echo -n "..." || echo ""
done
echo "  🚀 Liftoff!"'
    
    echo -e "${WHITE}  ${BOLD}4. For Loop - Files:${NC}"
    print_code 'for file in *.sh; do
    echo "Script: $file"
done

for file in /etc/*; do
    echo "$(basename "$file")"
done'
    
    run_demo 'echo "Files in home directory:"
count=0
for file in "$HOME"/*; do
    if [ -f "$file" ]; then
        echo "  📄 $(basename "$file")"
        ((count++))
    fi
    [[ $count -ge 5 ]] && echo "  ... (showing first 5)" && break
done

count=0
echo ""
echo "Directories in home:"
for dir in "$HOME"/*/; do
    if [ -d "$dir" ]; then
        echo "  📁 $(basename "$dir")"
        ((count++))
    fi
    [[ $count -ge 5 ]] && echo "  ... (showing first 5)" && break
done'
    
    pause_lesson
    
    echo -e "${WHITE}  ${BOLD}5. While Loop:${NC}"
    print_code 'count=1
while [ $count -le 5 ]; do
    echo "Count: $count"
    ((count++))
done

# Reading file line by line
while IFS= read -r line; do
    echo "Line: $line"
done < "filename.txt"'
    
    run_demo 'count=1
while [ $count -le 5 ]; do
    echo "  While count: $count"
    ((count++))
done'
    
    echo -e "${WHITE}  ${BOLD}6. Until Loop:${NC}"
    print_code '# Runs UNTIL condition is true
count=1
until [ $count -gt 5 ]; do
    echo "Count: $count"
    ((count++))
done'
    
    run_demo 'count=1
until [ $count -gt 5 ]; do
    echo "  Until count: $count"
    ((count++))
done'
    
    echo -e "${WHITE}  ${BOLD}7. Infinite Loops:${NC}"
    print_code '# While true
while true; do
    echo "Press Ctrl+C to stop"
    sleep 1
done

# For ever
for (( ; ; )); do
    echo "Infinite!"
    break  # Use break to exit
done'
    
    pause_lesson
    
    echo -e "${WHITE}  ${BOLD}8. Loop Control:${NC}"
    print_code '# break - Exit loop
for i in {1..10}; do
    [ $i -eq 5 ] && break
    echo "$i"
done

# continue - Skip iteration
for i in {1..10}; do
    [ $((i % 2)) -eq 0 ] && continue
    echo "$i"  # Only odd numbers
done'
    
    run_demo 'echo "Break at 5:"
for i in {1..10}; do
    [ $i -eq 5 ] && break
    echo -n "  $i"
done
echo ""
echo ""

echo "Skip even numbers (continue):"
for i in {1..10}; do
    [ $((i % 2)) -eq 0 ] && continue
    echo -n "  $i"
done
echo ""'
    
    echo -e "${WHITE}  ${BOLD}9. Nested Loops:${NC}"
    run_demo 'echo "Multiplication Table (1-5):"
echo ""
printf "     "
for j in {1..5}; do printf "%4d" $j; done
echo ""
echo "    --------------------"
for i in {1..5}; do
    printf " %2d |" $i
    for j in {1..5}; do
        printf "%4d" $((i * j))
    done
    echo ""
done'
    
    echo -e "${WHITE}  ${BOLD}10. Looping with Pipe:${NC}"
    print_code '# Process command output
ls -1 | while read -r file; do
    echo "Found: $file"
done

# Generate sequence
seq 1 5 | while read -r num; do
    echo "Number: $num"
done'
    
    quiz "What keyword skips the current iteration in a loop?" \
         "continue" \
         "continue skips the rest of the current iteration and moves to the next."
    
    pause_lesson
}

# ============================================================
# LESSON 9: ARRAYS
# ============================================================
lesson_9() {
    print_header
    print_lesson_title "LESSON 9: Arrays"
    
    echo -e "${WHITE}  ${BOLD}1. Indexed Arrays:${NC}"
    print_code '# Declaration methods
fruits=("apple" "banana" "cherry" "date")
declare -a numbers=(1 2 3 4 5)

# Access elements
echo "${fruits[0]}"     # apple (first element)
echo "${fruits[2]}"     # cherry
echo "${fruits[-1]}"    # date (last element)

# All elements
echo "${fruits[@]}"     # All elements
echo "${fruits[*]}"     # All as single string

# Length
echo "${#fruits[@]}"    # Number of elements: 4
echo "${#fruits[0]}"    # Length of first element: 5'
    
    run_demo 'fruits=("apple" "banana" "cherry" "date" "elderberry")
echo "All fruits: ${fruits[@]}"
echo "First: ${fruits[0]}"
echo "Third: ${fruits[2]}"
echo "Last: ${fruits[-1]}"
echo "Count: ${#fruits[@]}"
echo "Length of first: ${#fruits[0]}"'
    
    pause_lesson
    
    echo -e "${WHITE}  ${BOLD}2. Array Operations:${NC}"
    print_code '# Add elements
fruits+=("elderberry")
fruits[5]="fig"

# Remove elements
unset fruits[1]         # Remove banana

# Slice
echo "${fruits[@]:1:3}" # 3 elements starting from index 1

# Replace
fruits[0]="avocado"

# Check if element exists
[[ " ${fruits[@]} " =~ " cherry " ]] && echo "Found!"'
    
    run_demo 'colors=("red" "green" "blue")
echo "Original: ${colors[@]}"

colors+=("yellow" "purple")
echo "After add: ${colors[@]}"

unset colors[1]
echo "After remove [1]: ${colors[@]}"

echo "Slice [1:2]: ${colors[@]:1:2}"
echo "Indices: ${!colors[@]}"'
    
    echo -e "${WHITE}  ${BOLD}3. Looping Through Arrays:${NC}"
    print_code '# Loop through values
for fruit in "${fruits[@]}"; do
    echo "Fruit: $fruit"
done

# Loop through indices
for i in "${!fruits[@]}"; do
    echo "Index $i: ${fruits[$i]}"
done'
    
    run_demo 'languages=("Python" "JavaScript" "Bash" "Go" "Rust")
echo "Programming Languages:"
for lang in "${languages[@]}"; do
    echo "  • $lang"
done
echo ""
echo "With indices:"
for i in "${!languages[@]}"; do
    echo "  [$i] ${languages[$i]}"
done'
    
    pause_lesson
    
    echo -e "${WHITE}  ${BOLD}4. Associative Arrays (Dictionaries):${NC}"
    print_code 'declare -A user
user[name]="John"
user[age]=25
user[city]="New York"
user[email]="john@example.com"

echo "Name: ${user[name]}"
echo "Age: ${user[age]}"
echo "Keys: ${!user[@]}"
echo "Values: ${user[@]}"'
    
    run_demo 'declare -A user
user[name]="John"
user[age]=25
user[city]="New York"
user[email]="john@example.com"

echo "User Profile:"
for key in "${!user[@]}"; do
    printf "  %-8s: %s\n" "$key" "${user[$key]}"
done
echo ""
echo "Total fields: ${#user[@]}"'
    
    echo -e "${WHITE}  ${BOLD}5. Array Sorting:${NC}"
    print_code 'numbers=(5 3 8 1 9 2 7 4 6)

# Sort using readarray
sorted=($(printf "%s\n" "${numbers[@]}" | sort -n))
echo "Sorted: ${sorted[@]}"

# Reverse sort
reversed=($(printf "%s\n" "${numbers[@]}" | sort -rn))
echo "Reversed: ${reversed[@]}"'
    
    run_demo 'numbers=(5 3 8 1 9 2 7 4 6)
echo "Original: ${numbers[@]}"

sorted=($(printf "%s\n" "${numbers[@]}" | sort -n))
echo "Sorted:   ${sorted[@]}"

reversed=($(printf "%s\n" "${numbers[@]}" | sort -rn))
echo "Reversed: ${reversed[@]}"

# String sort
words=("banana" "apple" "cherry" "date")
echo ""
echo "Words: ${words[@]}"
sorted_words=($(printf "%s\n" "${words[@]}" | sort))
echo "Sorted: ${sorted_words[@]}"'
    
    echo -e "${WHITE}  ${BOLD}6. Practical Array Examples:${NC}"
    
    run_demo '# Stack implementation
declare -a stack=()

push() { stack+=("$1"); echo "  Pushed: $1"; }
pop() {
    if [ ${#stack[@]} -eq 0 ]; then
        echo "  Stack is empty!"
        return
    fi
    local top="${stack[-1]}"
    unset "stack[-1]"
    echo "  Popped: $top"
}
show() { echo "  Stack: [${stack[*]}]"; }

echo "Stack Operations:"
push "A"
push "B"
push "C"
show
pop
show
pop
show'
    
    quiz "How do you get all elements of array arr?" \
         '${arr[@]}' \
         '${arr[@]} expands to all elements of the array.'
    
    pause_lesson
}

# ============================================================
# LESSON 10: FUNCTIONS
# ============================================================
lesson_10() {
    print_header
    print_lesson_title "LESSON 10: Functions"
    
    echo -e "${WHITE}  ${BOLD}1. Function Syntax:${NC}"
    print_code '# Method 1 (preferred)
function_name() {
    commands
}

# Method 2
function function_name {
    commands
}

# Calling a function
function_name'
    
    echo -e "${WHITE}  ${BOLD}2. Basic Functions:${NC}"
    print_code 'greet() {
    echo "Hello, World!"
}

say_hello() {
    echo "Hello, $1!"  # $1 is first argument
}

greet
say_hello "John"'
    
    run_demo 'greet() {
    echo "Hello, World!"
}

say_hello() {
    echo "Hello, $1! You are $2 years old."
}

greet
say_hello "John" 25
say_hello "Alice" 30'
    
    pause_lesson
    
    echo -e "${WHITE}  ${BOLD}3. Function Arguments:${NC}"
    print_code 'show_info() {
    echo "Function name: $FUNCNAME"
    echo "Arguments count: $#"
    echo "All arguments: $@"
    echo "First arg: $1"
    echo "Second arg: $2"
}

show_info "hello" "world" "test"'
    
    run_demo 'show_info() {
    echo "  Function: $FUNCNAME"
    echo "  Arg count: $#"
    echo "  All args: $@"
    echo "  Arg 1: $1"
    echo "  Arg 2: $2"
    echo "  Arg 3: $3"
}
show_info "hello" "world" "test"'
    
    echo -e "${WHITE}  ${BOLD}4. Return Values:${NC}"
    print_code '# Return exit status (0-255)
is_even() {
    if (( $1 % 2 == 0 )); then
        return 0  # true/success
    else
        return 1  # false/failure
    fi
}

is_even 4 && echo "4 is even" || echo "4 is odd"
is_even 7 && echo "7 is even" || echo "7 is odd"

# Return values via echo (stdout)
add() {
    echo $(( $1 + $2 ))
}

result=$(add 5 3)
echo "5 + 3 = $result"'
    
    run_demo 'is_even() {
    (( $1 % 2 == 0 )) && return 0 || return 1
}

add() { echo $(( $1 + $2 )); }
multiply() { echo $(( $1 * $2 )); }

is_even 4 && echo "4 is even" || echo "4 is odd"
is_even 7 && echo "7 is even" || echo "7 is odd"
echo ""
echo "5 + 3 = $(add 5 3)"
echo "4 × 7 = $(multiply 4 7)"'
    
    pause_lesson
    
    echo -e "${WHITE}  ${BOLD}5. Local Variables:${NC}"
    print_code 'my_func() {
    local local_var="I am local"
    global_var="I am global"
    echo "Inside: $local_var"
    echo "Inside: $global_var"
}

my_func
echo "Outside: $local_var"    # Empty - local is gone
echo "Outside: $global_var"   # Still accessible'
    
    run_demo 'my_func() {
    local local_var="I am local"
    global_var="I am global"
    echo "  Inside function:"
    echo "    local_var = $local_var"
    echo "    global_var = $global_var"
}

my_func
echo ""
echo "  Outside function:"
echo "    local_var = '$local_var' (empty - local scope)"
echo "    global_var = '$global_var' (accessible - global scope)"'
    
    echo -e "${WHITE}  ${BOLD}6. Recursive Functions:${NC}"
    print_code 'factorial() {
    if [ $1 -le 1 ]; then
        echo 1
    else
        local prev=$(factorial $(( $1 - 1 )))
        echo $(( $1 * prev ))
    fi
}

echo "5! = $(factorial 5)"  # 120'
    
    run_demo 'factorial() {
    if [ $1 -le 1 ]; then
        echo 1
    else
        local prev=$(factorial $(( $1 - 1 )))
        echo $(( $1 * prev ))
    fi
}

for n in 1 2 3 4 5 6 7 8 9 10; do
    echo "  $n! = $(factorial $n)"
done'
    
    pause_lesson
    
    echo -e "${WHITE}  ${BOLD}7. Practical Function Library:${NC}"
    
    run_demo '# --- Utility Functions Library ---

# Logging
log_info()  { echo "[INFO]  $(date +%H:%M:%S) $*"; }
log_warn()  { echo "[WARN]  $(date +%H:%M:%S) $*"; }
log_error() { echo "[ERROR] $(date +%H:%M:%S) $*"; }

# String utils
to_upper() { echo "${1^^}"; }
to_lower() { echo "${1,,}"; }
trim() { echo "$1" | xargs; }

# Math utils
max() { (( $1 > $2 )) && echo "$1" || echo "$2"; }
min() { (( $1 < $2 )) && echo "$1" || echo "$2"; }
abs() { (( $1 < 0 )) && echo "$(( -$1 ))" || echo "$1"; }

# Validation
is_number() { [[ "$1" =~ ^[0-9]+$ ]] && return 0 || return 1; }

# Demo
log_info "Starting program"
log_warn "Low memory"
log_error "File not found"
echo ""
echo "Upper: $(to_upper "hello world")"
echo "Lower: $(to_lower "HELLO WORLD")"
echo "Max(5,3): $(max 5 3)"
echo "Min(5,3): $(min 5 3)"
echo "Abs(-7): $(abs -7)"
is_number "42" && echo "42 is a number"
is_number "abc" && echo "abc is a number" || echo "abc is NOT a number"'
    
    quiz "What keyword makes a variable local to a function?" \
         "local" \
         "The 'local' keyword restricts a variable's scope to the function."
    
    pause_lesson
}

# ============================================================
# LESSON 11: FILE OPERATIONS
# ============================================================
lesson_11() {
    print_header
    print_lesson_title "LESSON 11: File Operations"
    
    echo -e "${WHITE}  ${BOLD}1. Creating Files & Directories:${NC}"
    print_code 'touch newfile.txt              # Create empty file
mkdir mydir                    # Create directory
mkdir -p path/to/nested/dir   # Create nested directories

echo "content" > file.txt     # Create with content (overwrite)
echo "more" >> file.txt       # Append to file

cat > file.txt << EOF         # Create with heredoc
Line 1
Line 2
EOF'
    
    echo -e "${WHITE}  ${BOLD}2. Reading Files:${NC}"
    print_code '# Read entire file
content=$(cat file.txt)

# Read line by line
while IFS= read -r line; do
    echo "Line: $line"
done < file.txt

# Read specific line
sed -n "3p" file.txt          # Print line 3

# First/Last lines
head -n 5 file.txt            # First 5 lines
tail -n 5 file.txt            # Last 5 lines'
    
    # Create temp files for demo
    local tmpdir="/data/data/com.termux/files/usr/tmp/lesson_demo"
    mkdir -p "$tmpdir" 2>/dev/null
    
    run_demo "mkdir -p /data/data/com.termux/files/usr/tmp/lesson_demo
cd /data/data/com.termux/files/usr/tmp/lesson_demo

# Create a sample file
cat > sample.txt << 'EOF'
Hello World
This is line 2
Termux is awesome
Shell scripting rocks
Learning is fun
EOF

echo 'File contents:'
cat -n sample.txt
echo ''
echo 'First 3 lines:'
head -n 3 sample.txt
echo ''
echo 'Last 2 lines:'
tail -n 2 sample.txt
echo ''
echo 'Line count: \$(wc -l < sample.txt)'
echo 'Word count: \$(wc -w < sample.txt)'
echo 'Char count: \$(wc -c < sample.txt)'

rm -f sample.txt
cd ->/dev/null"
    
    pause_lesson
    
    echo -e "${WHITE}  ${BOLD}3. File Information:${NC}"
    print_code 'ls -la file.txt          # Detailed listing
stat file.txt            # Full file info
file file.txt            # File type
wc -l file.txt           # Line count
wc -w file.txt           # Word count
wc -c file.txt           # Byte count
du -sh file.txt          # File size
md5sum file.txt          # Checksum'
    
    echo -e "${WHITE}  ${BOLD}4. Copying, Moving, Deleting:${NC}"
    print_code 'cp source.txt dest.txt       # Copy file
cp -r srcdir/ destdir/       # Copy directory
mv old.txt new.txt           # Rename/move
rm file.txt                  # Delete file
rm -rf directory/             # Delete directory (careful!)
ln -s target linkname        # Create symbolic link'
    
    echo -e "${WHITE}  ${BOLD}5. Finding Files:${NC}"
    print_code 'find . -name "*.txt"                   # Find by name
find . -type f -size +1M               # Files > 1MB
find . -type f -mtime -7               # Modified in last 7 days
find . -type f -name "*.log" -delete   # Find and delete
find . -type f -exec chmod 644 {} \;   # Find and execute'
    
    run_demo 'echo "Finding files in home directory:"
echo ""
echo "Directories (first 5):"
find "$HOME" -maxdepth 1 -type d 2>/dev/null | head -5 | while read -r d; do
    echo "  📁 $(basename "$d")"
done
echo ""
echo "Files (first 5):"
find "$HOME" -maxdepth 1 -type f 2>/dev/null | head -5 | while read -r f; do
    echo "  📄 $(basename "$f")"
done'
    
    pause_lesson
    
    echo -e "${WHITE}  ${BOLD}6. File Testing Script:${NC}"
    
    run_demo 'check_path() {
    local path="$1"
    echo "Checking: $path"
    
    if [ -e "$path" ]; then
        echo "  ✅ Exists"
        [ -f "$path" ] && echo "  📄 Is a file"
        [ -d "$path" ] && echo "  📁 Is a directory"
        [ -r "$path" ] && echo "  👁️  Readable"
        [ -w "$path" ] && echo "  ✏️  Writable"
        [ -x "$path" ] && echo "  ⚡ Executable"
        if [ -f "$path" ]; then
            echo "  📏 Size: $(wc -c < "$path") bytes"
        fi
    else
        echo "  ❌ Does not exist"
    fi
    echo ""
}

check_path "$HOME"
check_path "$HOME/.bashrc"
check_path "/nonexistent"'
    
    echo -e "${WHITE}  ${BOLD}7. Temporary Files:${NC}"
    print_code '# Create temp file
tmpfile=$(mktemp)
echo "Temp file: $tmpfile"
echo "data" > "$tmpfile"
# ... use the file ...
rm -f "$tmpfile"

# Create temp directory
tmpdir=$(mktemp -d)
echo "Temp dir: $tmpdir"
rm -rf "$tmpdir"'
    
    quiz "What command reads a file line by line?" \
         "while read" \
         "while IFS= read -r line; do ... done < file reads each line."
    
    pause_lesson
}

# ============================================================
# LESSON 12: TEXT PROCESSING
# ============================================================
lesson_12() {
    print_header
    print_lesson_title "LESSON 12: Text Processing (grep, sed, awk)"
    
    # Create sample data
    local sample_data="John,25,Developer,50000
Alice,30,Designer,55000
Bob,28,Manager,60000
Charlie,35,Developer,65000
Diana,27,Designer,52000
Eve,32,Manager,70000"
    
    echo -e "${WHITE}  ${BOLD}1. grep - Pattern Searching:${NC}"
    print_code 'grep "pattern" file.txt          # Basic search
grep -i "pattern" file.txt       # Case insensitive
grep -n "pattern" file.txt       # Show line numbers
grep -c "pattern" file.txt       # Count matches
grep -v "pattern" file.txt       # Invert (non-matching)
grep -r "pattern" directory/     # Recursive search
grep -E "regex" file.txt         # Extended regex
grep -w "word" file.txt          # Whole word match
grep -l "pattern" *.txt          # List matching files'
    
    run_demo "echo 'Sample Data:'
echo '$sample_data'
echo ''
echo 'grep Developer:'
echo '$sample_data' | grep 'Developer'
echo ''
echo 'grep -i designer:'
echo '$sample_data' | grep -i 'designer'
echo ''
echo 'grep -c Developer (count):'
echo '$sample_data' | grep -c 'Developer'
echo ''
echo 'grep -v Developer (invert):'
echo '$sample_data' | grep -v 'Developer'
echo ''
echo 'grep -n Manager (line numbers):'
echo '$sample_data' | grep -n 'Manager'"
    
    pause_lesson
    
    echo -e "${WHITE}  ${BOLD}2. sed - Stream Editor:${NC}"
    print_code 'sed "s/old/new/" file.txt        # Replace first occurrence
sed "s/old/new/g" file.txt       # Replace all occurrences
sed -i "s/old/new/g" file.txt    # Edit in place
sed "3d" file.txt                # Delete line 3
sed "/pattern/d" file.txt        # Delete matching lines
sed -n "2,4p" file.txt           # Print lines 2-4
sed "2i\New line" file.txt       # Insert before line 2
sed "2a\New line" file.txt       # Append after line 2'
    
    run_demo "echo 'Original:'
echo '$sample_data'
echo ''
echo 'sed s/Developer/Engineer/g:'
echo '$sample_data' | sed 's/Developer/Engineer/g'
echo ''
echo 'sed delete line 3 (3d):'
echo '$sample_data' | sed '3d'
echo ''
echo 'sed print lines 2-4 (-n 2,4p):'
echo '$sample_data' | sed -n '2,4p'
echo ''
echo 'sed add line numbers:'
echo '$sample_data' | sed '=' | sed 'N;s/\n/\t/'"
    
    pause_lesson
    
    echo -e "${WHITE}  ${BOLD}3. awk - Text Processing Language:${NC}"
    print_code 'awk "{print}" file.txt                   # Print all
awk "{print $1}" file.txt                # Print first field
awk -F"," "{print $1, $3}" file.txt      # CSV with comma delimiter
awk "NR==3" file.txt                     # Print line 3
awk "$3 > 50 {print $1}" file.txt        # Conditional
awk "{sum+=$1} END {print sum}" file.txt # Sum values
awk "BEGIN {print \"Header\"} {print}"   # BEGIN block'
    
    run_demo "echo 'AWK Processing:'
echo ''
echo 'Print names (field 1):'
echo '$sample_data' | awk -F',' '{print \$1}'
echo ''
echo 'Print name and role:'
echo '$sample_data' | awk -F',' '{printf \"%-10s → %s\n\", \$1, \$3}'
echo ''
echo 'Filter salary > 55000:'
echo '$sample_data' | awk -F',' '\$4 > 55000 {printf \"%-10s \$%s\n\", \$1, \$4}'
echo ''
echo 'Average salary:'
echo '$sample_data' | awk -F',' '{sum+=\$4; count++} END {printf \"Average: \$%.0f\n\", sum/count}'"
    
    pause_lesson
    
    echo -e "${WHITE}  ${BOLD}4. cut & paste:${NC}"
    print_code 'cut -d"," -f1 file.csv          # Extract field 1
cut -d"," -f1,3 file.csv        # Fields 1 and 3
cut -c1-5 file.txt              # Characters 1-5
paste file1.txt file2.txt       # Merge files side by side
paste -d"," file1 file2         # Merge with comma'
    
    run_demo "echo 'Cut examples:'
echo '$sample_data' | cut -d',' -f1
echo ''
echo 'Names and Salaries:'
echo '$sample_data' | cut -d',' -f1,4"
    
    echo -e "${WHITE}  ${BOLD}5. sort & uniq:${NC}"
    print_code 'sort file.txt                   # Sort alphabetically
sort -n file.txt                # Sort numerically
sort -r file.txt                # Reverse sort
sort -t"," -k2 file.csv        # Sort by field 2
sort file.txt | uniq            # Remove duplicates
sort file.txt | uniq -c         # Count occurrences
sort file.txt | uniq -d         # Show only duplicates'
    
    run_demo "echo 'Sort by salary (field 4):'
echo '$sample_data' | sort -t',' -k4 -n
echo ''
echo 'Unique roles:'
echo '$sample_data' | cut -d',' -f3 | sort | uniq -c | sort -rn"
    
    echo -e "${WHITE}  ${BOLD}6. tr - Translate Characters:${NC}"
    print_code 'echo "hello" | tr "a-z" "A-Z"          # To uppercase
echo "HELLO" | tr "A-Z" "a-z"          # To lowercase
echo "hello   world" | tr -s " "       # Squeeze spaces
echo "h3ll0" | tr -d "0-9"             # Delete digits
echo "hello" | tr "helo" "HELO"        # Translate chars'
    
    run_demo 'echo "Uppercase: $(echo "hello world" | tr "a-z" "A-Z")"
echo "Lowercase: $(echo "HELLO WORLD" | tr "A-Z" "a-z")"
echo "ROT13: $(echo "Hello World" | tr "A-Za-z" "N-ZA-Mn-za-m")"
echo "Remove digits: $(echo "h3ll0 w0rld" | tr -d "0-9")"
echo "Remove vowels: $(echo "Hello World" | tr -d "aeiouAEIOU")"'
    
    quiz "What grep flag makes the search case insensitive?" \
         "-i" \
         "grep -i performs case-insensitive matching."
    
    pause_lesson
}

# ============================================================
# LESSON 13: PIPES & REDIRECTION
# ============================================================
lesson_13() {
    print_header
    print_lesson_title "LESSON 13: Pipes & Redirection"
    
    echo -e "${WHITE}  ${BOLD}1. Output Redirection:${NC}"
    print_code '# Redirect stdout
echo "hello" > file.txt         # Overwrite
echo "world" >> file.txt        # Append

# Redirect stderr
command 2> error.log            # Stderr to file
command 2>> error.log           # Append stderr

# Redirect both
command > output.log 2>&1       # Both to same file
command &> output.log           # Shorthand (bash)
command > out.log 2> err.log    # Separate files

# Discard output
command > /dev/null             # Discard stdout
command 2> /dev/null            # Discard stderr
command &> /dev/null            # Discard all'
    
    run_demo 'echo "=== Redirection Demo ==="
echo ""

# Create temp file
tmpfile=$(mktemp)

echo "hello" > "$tmpfile"
echo "After >: $(cat $tmpfile)"

echo "world" >> "$tmpfile"
echo "After >>: $(cat $tmpfile)"

# Redirect stderr
ls /nonexistent 2>/dev/null
echo "Stderr suppressed successfully"

# File descriptors
echo "stdout goes here" > "$tmpfile"
echo "File contents: $(cat $tmpfile)"

rm -f "$tmpfile"'
    
    pause_lesson
    
    echo -e "${WHITE}  ${BOLD}2. Input Redirection:${NC}"
    print_code '# From file
wc -l < file.txt

# Here string
grep "hello" <<< "hello world"

# Here document
cat << EOF
Multiple lines
of text here
EOF'
    
    echo -e "${WHITE}  ${BOLD}3. Pipes ( | ):${NC}"
    print_code '# Chain commands
ls -la | grep ".txt"
cat file.txt | sort | uniq
ps aux | grep bash | wc -l
echo "Hello World" | tr "a-z" "A-Z" | rev'
    
    run_demo 'echo "=== Pipe Examples ==="
echo ""

echo "Files in home (first 5):"
ls -1 "$HOME" | head -5
echo ""

echo "Running processes with bash:"
ps aux 2>/dev/null | grep bash | head -3 || ps | grep bash | head -3
echo ""

echo "Text pipeline:"
echo "Hello World From Termux" | tr " " "\n" | sort | tr "\n" " "
echo ""
echo ""

echo "Count lines in PATH:"
echo "$PATH" | tr ":" "\n" | wc -l
echo ""

echo "Unique shells:"
cat /etc/shells 2>/dev/null | grep -v "^#" | sort -u || echo "  (shells file not available)"'
    
    pause_lesson
    
    echo -e "${WHITE}  ${BOLD}4. Named Pipes (FIFO):${NC}"
    print_code 'mkfifo mypipe             # Create named pipe
echo "data" > mypipe &     # Write (background)
cat < mypipe               # Read
rm mypipe                  # Clean up'
    
    echo -e "${WHITE}  ${BOLD}5. Process Substitution:${NC}"
    print_code '# Use command output as file
diff <(ls dir1) <(ls dir2)

# Compare sorted outputs
diff <(sort file1) <(sort file2)

# Multiple inputs
paste <(cut -f1 data.txt) <(cut -f3 data.txt)'
    
    echo -e "${WHITE}  ${BOLD}6. tee - Split Output:${NC}"
    print_code '# Write to file AND screen
echo "hello" | tee file.txt
echo "hello" | tee -a file.txt      # Append mode
echo "hello" | tee file1 file2      # Multiple files

# In pipeline
ls -la | tee listing.txt | grep ".sh"'
    
    run_demo 'tmpfile=$(mktemp)
echo "=== tee Demo ==="
echo "Writing to file and screen:"
echo "Hello from tee!" | tee "$tmpfile"
echo ""
echo "File contains: $(cat $tmpfile)"
rm -f "$tmpfile"'
    
    echo -e "${WHITE}  ${BOLD}7. xargs - Build Commands:${NC}"
    print_code 'echo "file1 file2 file3" | xargs touch      # Create files
find . -name "*.tmp" | xargs rm           # Delete found files
echo "1 2 3 4 5" | xargs -n 2 echo       # 2 args at a time
cat urls.txt | xargs -I {} curl -O {}     # Download each URL'
    
    run_demo 'echo "=== xargs Demo ==="
echo "1 2 3 4 5 6" | xargs -n 2 echo "Pair:"
echo ""
echo "A B C D" | xargs -I {} echo "Item: {}"'
    
    echo -e "${WHITE}  ${BOLD}8. Complex Pipeline Example:${NC}"
    
    run_demo 'echo "=== Complex Pipeline ==="
echo ""
echo "Top 5 largest items in home:"
du -sh "$HOME"/* 2>/dev/null | sort -rh | head -5 | while read -r size name; do
    printf "  %8s  %s\n" "$size" "$(basename "$name")"
done'
    
    quiz "What does 2>&1 do?" \
         "redirects stderr to stdout" \
         "2>&1 sends file descriptor 2 (stderr) to the same place as fd 1 (stdout)."
    
    pause_lesson
}

# ============================================================
# LESSON 14: PROCESS MANAGEMENT
# ============================================================
lesson_14() {
    print_header
    print_lesson_title "LESSON 14: Process Management"
    
    echo -e "${WHITE}  ${BOLD}1. Process Information:${NC}"
    print_code 'ps                       # Current user processes
ps aux                   # All processes (detailed)
ps -ef                   # All processes (full format)
top                      # Interactive process viewer
pgrep -l bash            # Find processes by name
pidof bash               # Get PID of a process'
    
    run_demo 'echo "Current processes:"
ps -o pid,ppid,comm | head -10
echo ""
echo "Bash processes:"
pgrep -la bash 2>/dev/null | head -5 || ps | grep bash
echo ""
echo "Current PID: $$"
echo "Parent PID: $PPID"'
    
    echo -e "${WHITE}  ${BOLD}2. Background & Foreground:${NC}"
    print_code 'command &                # Run in background
jobs                     # List background jobs
fg %1                    # Bring job 1 to foreground
bg %1                    # Resume job 1 in background
Ctrl+Z                   # Suspend current process
wait                     # Wait for all background jobs
wait $pid                # Wait for specific process'
    
    run_demo 'echo "Starting background process..."
sleep 1 &
bg_pid=$!
echo "Background PID: $bg_pid"
echo ""
echo "Jobs:"
jobs 2>/dev/null || echo "  (no jobs in subshell)"
echo ""
wait $bg_pid
echo "Background process finished (exit: $?)"'
    
    pause_lesson
    
    echo -e "${WHITE}  ${BOLD}3. Signals:${NC}"
    print_code 'kill PID                 # Send SIGTERM (graceful)
kill -9 PID              # Send SIGKILL (force)
kill -l                  # List all signals
killall process_name     # Kill by name
pkill -f "pattern"       # Kill by pattern

# Common signals:
# SIGHUP  (1)  - Hangup
# SIGINT  (2)  - Interrupt (Ctrl+C)
# SIGQUIT (3)  - Quit
# SIGKILL (9)  - Force kill
# SIGTERM (15) - Terminate (default)
# SIGSTOP (19) - Stop process'
    
    echo -e "${WHITE}  ${BOLD}4. Signal Trapping:${NC}"
    print_code 'trap "echo Caught SIGINT!" SIGINT
trap "cleanup_function" EXIT
trap "" SIGTERM  # Ignore SIGTERM

cleanup() {
    echo "Cleaning up..."
    rm -f /tmp/tempfile
}
trap cleanup EXIT'
    
    run_demo 'cleanup() {
    echo "  🧹 Cleanup function called!"
    echo "  Removing temp resources..."
}

trap cleanup EXIT

echo "Signal trapping demo:"
echo "  Trap set for EXIT signal"
echo "  When this subshell ends, cleanup runs..."
echo ""'
    
    pause_lesson
    
    echo -e "${WHITE}  ${BOLD}5. Subshells & Execution:${NC}"
    print_code '# Subshell
(cd /tmp && ls)           # Commands in subshell
var="outside"
(var="inside"; echo $var) # inside
echo $var                 # outside (unchanged)

# Command grouping
{ cmd1; cmd2; cmd3; }    # Run in current shell

# Source/dot
source script.sh         # Execute in current shell
. script.sh              # Same as source'
    
    run_demo 'echo "Subshell demo:"
var="outside"
echo "  Before subshell: var=$var"
(var="inside"; echo "  Inside subshell: var=$var")
echo "  After subshell: var=$var"
echo ""

echo "Command grouping:"
{
    echo "  Grouped command 1"
    echo "  Grouped command 2"
} '
    
    echo -e "${WHITE}  ${BOLD}6. Process Substitution & Parallel Execution:${NC}"
    print_code '# Parallel execution
command1 &
command2 &
command3 &
wait  # Wait for all

# Parallel with limited concurrency
for i in {1..10}; do
    do_work "$i" &
    # Limit to 4 parallel jobs
    [[ $(jobs -r | wc -l) -ge 4 ]] && wait -n
done
wait'
    
    run_demo 'echo "Parallel execution demo:"
start=$SECONDS

for i in {1..5}; do
    (sleep 0.5; echo "  Task $i completed") &
done
wait

elapsed=$(( SECONDS - start ))
echo ""
echo "  All tasks done in ${elapsed}s (ran in parallel!)"'
    
    quiz "What signal does Ctrl+C send?" \
         "SIGINT" \
         "Ctrl+C sends SIGINT (Signal Interrupt, signal number 2)."
    
    pause_lesson
}

# ============================================================
# LESSON 15: ERROR HANDLING & DEBUGGING
# ============================================================
lesson_15() {
    print_header
    print_lesson_title "LESSON 15: Error Handling & Debugging"
    
    echo -e "${WHITE}  ${BOLD}1. Exit Status:${NC}"
    print_code '# Every command returns an exit status
# 0 = success, non-zero = failure

ls /tmp
echo "Exit status: $?"    # 0 (success)

ls /nonexistent 2>/dev/null
echo "Exit status: $?"    # non-zero (failure)

# Set exit status
exit 0    # Success
exit 1    # General error
exit 2    # Misuse of shell command'
    
    run_demo 'echo "Testing exit status:"
echo ""
ls "$HOME" > /dev/null 2>&1
echo "  ls \$HOME → exit status: $?"

ls /nonexistent_path > /dev/null 2>&1
echo "  ls /nonexistent → exit status: $?"

true
echo "  true → exit status: $?"

false
echo "  false → exit status: $?"

[ 1 -eq 1 ]
echo "  [ 1 -eq 1 ] → exit status: $?"

[ 1 -eq 2 ]
echo "  [ 1 -eq 2 ] → exit status: $?"'
    
    pause_lesson
    
    echo -e "${WHITE}  ${BOLD}2. Error Handling Patterns:${NC}"
    print_code '# Pattern 1: || operator
cd /some/dir || { echo "Failed to cd"; exit 1; }

# Pattern 2: if statement
if ! command; then
    echo "Command failed"
    exit 1
fi

# Pattern 3: set -e (exit on error)
set -e    # Script exits on any error
set +e    # Disable exit on error

# Pattern 4: trap ERR
trap "echo Error on line $LINENO" ERR'
    
    run_demo 'echo "Error handling patterns:"
echo ""

# Pattern 1
echo "1. Using ||:"
ls /nonexistent 2>/dev/null || echo "   ❌ Command failed, handled gracefully"
echo ""

# Pattern 2
echo "2. Using if !:"
if ! ls /nonexistent 2>/dev/null; then
    echo "   ❌ Directory not found, handled"
fi
echo ""

# Pattern 3
echo "3. Checking exit status:"
some_command() { return 1; }
some_command
if [ $? -ne 0 ]; then
    echo "   ❌ Function returned error"
fi'
    
    echo -e "${WHITE}  ${BOLD}3. Strict Mode:${NC}"
    print_code '#!/bin/bash
set -euo pipefail

# -e : Exit on error
# -u : Error on undefined variables
# -o pipefail : Pipeline fails if any command fails

# Often combined as:
set -euo pipefail
IFS=$'"'"'\n\t'"'"''
    
    print_tip "Use 'set -euo pipefail' at the start of scripts for safety."
    
    pause_lesson
    
    echo -e "${WHITE}  ${BOLD}4. Debugging Techniques:${NC}"
    print_code '# Enable debug mode
set -x    # Print each command before execution
set +x    # Disable debug mode

# Debug entire script
bash -x script.sh

# Debug specific section
set -x
problematic_code
set +x

# Custom debug function
DEBUG=true
debug() {
    [[ "$DEBUG" == true ]] && echo "DEBUG: $*" >&2
}'
    
    run_demo 'echo "Debug mode demo:"
echo ""

# Enable debug
set -x
a=5
b=10
result=$((a + b))
set +x

echo ""
echo "Result: $result"
echo ""

# Custom debug function
debug() { echo "  [DEBUG] $*"; }
debug "Starting process"
debug "Variable a=$a, b=$b"
debug "Result=$result"'
    
    echo -e "${WHITE}  ${BOLD}5. Complete Error Handling Template:${NC}"
    
    run_demo '#!/bin/bash
# Error handling template

# Colors
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
NC="\033[0m"

# Logging
log()   { echo -e "${GREEN}[$(date +%H:%M:%S)] INFO: $*${NC}"; }
warn()  { echo -e "${YELLOW}[$(date +%H:%M:%S)] WARN: $*${NC}"; }
error() { echo -e "${RED}[$(date +%H:%M:%S)] ERROR: $*${NC}" >&2; }
die()   { error "$*"; }

# Cleanup on exit
cleanup() {
    log "Cleanup complete"
}
trap cleanup EXIT

# Main
log "Script starting..."
warn "This is a warning"
error "This is an error (non-fatal)"
log "Script continuing..."

# Validate input
validate_file() {
    local file="$1"
    if [ ! -f "$file" ]; then
        error "File not found: $file"
        return 1
    fi
    log "File validated: $file"
    return 0
}

validate_file "/etc/hostname" || warn "Validation failed but continuing"
validate_file "/nonexistent" || warn "Validation failed but continuing"
log "Script completed successfully"'
    
    quiz "What does 'set -e' do in a script?" \
         "exits on error" \
         "set -e makes the script exit immediately when any command returns non-zero."
    
    pause_lesson
}

# ============================================================
# LESSON 16: REGULAR EXPRESSIONS
# ============================================================
lesson_16() {
    print_header
    print_lesson_title "LESSON 16: Regular Expressions"
    
    echo -e "${WHITE}  ${BOLD}1. Basic Regex Patterns:${NC}"
    print_code '.         # Any single character
*         # Zero or more of previous
+         # One or more of previous (extended)
?         # Zero or one of previous (extended)
^         # Start of line
$         # End of line
[]        # Character class
[^]       # Negated character class
\         # Escape special character
|         # OR (alternation, extended)
()        # Grouping (extended)'
    
    echo -e "${WHITE}  ${BOLD}2. Character Classes:${NC}"
    print_code '[abc]     # a, b, or c
[a-z]     # Any lowercase letter
[A-Z]     # Any uppercase letter
[0-9]     # Any digit
[a-zA-Z]  # Any letter
[^0-9]    # NOT a digit
\d        # Digit (Perl-style, some tools)
\w        # Word character [a-zA-Z0-9_]
\s        # Whitespace
\b        # Word boundary'
    
    echo -e "${WHITE}  ${BOLD}3. Regex with grep:${NC}"
    
    run_demo 'data="john@email.com
alice_123
Bob Smith
phone: 555-1234
192.168.1.1
https://example.com
2024-01-15
hello world
UPPERCASE
12345"

echo "Sample data:"
echo "$data"
echo ""

echo "Lines starting with lowercase:"
echo "$data" | grep "^[a-z]"
echo ""

echo "Lines with numbers:"
echo "$data" | grep "[0-9]"
echo ""

echo "Email-like patterns:"
echo "$data" | grep -E "[a-zA-Z]+@[a-zA-Z]+\.[a-z]+"
echo ""

echo "Lines ending with numbers:"
echo "$data" | grep "[0-9]$"'
    
    pause_lesson
    
    echo -e "${WHITE}  ${BOLD}4. Regex in Bash [[ =~ ]]:${NC}"
    print_code 'string="Hello World 123"

if [[ "$string" =~ [0-9]+ ]]; then
    echo "Contains numbers"
    echo "Match: ${BASH_REMATCH[0]}"
fi

# Email validation
email="user@example.com"
if [[ "$email" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
    echo "Valid email"
fi'
    
    run_demo '# Regex matching in Bash
validate() {
    local input="$1"
    local label="$2"
    local pattern="$3"
    
    if [[ "$input" =~ $pattern ]]; then
        echo "  ✅ '$input' matches $label"
        [[ -n "${BASH_REMATCH[0]}" ]] && echo "     Match: ${BASH_REMATCH[0]}"
    else
        echo "  ❌ '$input' does NOT match $label"
    fi
}

echo "Regex Validation:"
echo ""

validate "user@email.com" "email" "^[a-zA-Z0-9]+@[a-zA-Z]+\.[a-z]+$"
validate "not-an-email" "email" "^[a-zA-Z0-9]+@[a-zA-Z]+\.[a-z]+$"
echo ""

validate "192.168.1.1" "IP address" "^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$"
validate "abc.def" "IP address" "^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$"
echo ""

validate "2024-01-15" "date (YYYY-MM-DD)" "^[0-9]{4}-[0-9]{2}-[0-9]{2}$"
validate "15/01/2024" "date (YYYY-MM-DD)" "^[0-9]{4}-[0-9]{2}-[0-9]{2}$"
echo ""

validate "Hello123" "alphanumeric" "^[a-zA-Z0-9]+$"
validate "Hello 123!" "alphanumeric" "^[a-zA-Z0-9]+$"'
    
    pause_lesson
    
    echo -e "${WHITE}  ${BOLD}5. Regex with sed:${NC}"
    
    run_demo 'echo "Sed regex examples:"
echo ""

echo "Remove HTML tags:"
echo "<h1>Hello</h1><p>World</p>" | sed "s/<[^>]*>//g"
echo ""

echo "Extract numbers:"
echo "Price: $19.99, Qty: 5" | grep -oE "[0-9]+\.?[0-9]*"
echo ""

echo "Format phone number:"
echo "5551234567" | sed "s/\([0-9]\{3\}\)\([0-9]\{3\}\)\([0-9]\{4\}\)/(\1) \2-\3/"
echo ""

echo "Mask email:"
echo "john.doe@example.com" | sed "s/\(.\).*@/\1***@/"'
    
    echo -e "${WHITE}  ${BOLD}6. Common Regex Patterns:${NC}"
    print_code '# Email
^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$

# URL
https?://[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}(/\S*)?

# IP Address
^([0-9]{1,3}\.){3}[0-9]{1,3}$

# Phone (US)
^\(?[0-9]{3}\)?[-. ]?[0-9]{3}[-. ]?[0-9]{4}$

# Date (YYYY-MM-DD)
^[0-9]{4}-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])$

# Strong Password (8+ chars, upper, lower, digit, special)
^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*[!@#$%]).{8,}$'
    
    quiz "What regex pattern matches the start of a line?" \
         "^" \
         "The caret ^ anchors the match to the beginning of a line."
    
    pause_lesson
}

# ============================================================
# LESSON 17: TERMUX-SPECIFIC COMMANDS
# ============================================================
lesson_17() {
    print_header
    print_lesson_title "LESSON 17: Termux-Specific Commands"
    
    echo -e "${WHITE}  ${BOLD}1. Termux API (requires termux-api package):${NC}"
    print_code '# Install
pkg install termux-api

# Battery info
termux-battery-status

# Notifications
termux-notification --title "Hello" --content "From Termux"

# Toast message
termux-toast "Hello from script!"

# Vibrate
termux-vibrate -d 500

# Clipboard
termux-clipboard-set "copied text"
termux-clipboard-get

# Camera
termux-camera-photo -c 0 photo.jpg

# Text-to-Speech
termux-tts-speak "Hello World"

# Get location
termux-location

# Share
termux-share -a send file.txt

# Open URL
termux-open-url "https://google.com"'
    
    pause_lesson
    
    echo -e "${WHITE}  ${BOLD}2. Termux Storage & Paths:${NC}"
    print_code '# Setup storage access
termux-setup-storage

# Important paths
echo $HOME                     # /data/data/com.termux/files/home
echo $PREFIX                   # /data/data/com.termux/files/usr
echo $TMPDIR                   # Temp directory
ls ~/storage/shared/           # Internal storage
ls ~/storage/dcim/             # Camera photos
ls ~/storage/downloads/        # Downloads
ls ~/storage/music/            # Music
ls ~/storage/movies/           # Movies'
    
    run_demo 'echo "Termux Environment:"
echo ""
echo "  HOME:    $HOME"
echo "  PREFIX:  $PREFIX"
echo "  SHELL:   $SHELL"
echo "  TERM:    $TERM"
echo "  TMPDIR:  ${TMPDIR:-/tmp}"
echo "  PATH segments:"
echo "$PATH" | tr ":" "\n" | head -5 | while read -r p; do
    echo "    $p"
done
echo ""
echo "  Disk usage:"
df -h "$HOME" 2>/dev/null | tail -1 | awk "{printf \"    Used: %s / %s (%s)\n\", \$3, \$2, \$5}"'
    
    echo -e "${WHITE}  ${BOLD}3. Package Management:${NC}"
    print_code 'pkg update                     # Update package list
pkg upgrade                    # Upgrade packages
pkg install <package>          # Install package
pkg uninstall <package>        # Remove package
pkg list-installed             # List installed
pkg search <keyword>           # Search packages
pkg show <package>             # Package info
apt list --upgradable          # Check for updates'
    
    pause_lesson
    
    echo -e "${WHITE}  ${BOLD}4. Termux Session Management:${NC}"
    print_code '# Multiple sessions
# Swipe from left edge to open drawer
# "NEW SESSION" to create new tab

# Background services
# Install termux-services
pkg install termux-services

# SSH Server
pkg install openssh
sshd                           # Start SSH server
passwd                         # Set password
# Connect: ssh user@phone-ip -p 8022

# Wake lock (prevent sleep)
termux-wake-lock
termux-wake-unlock'
    
    echo -e "${WHITE}  ${BOLD}5. Termux Boot Script:${NC}"
    print_code '# Install Termux:Boot app from F-Droid
# Create boot script directory
mkdir -p ~/.termux/boot

# Create boot script
cat > ~/.termux/boot/start.sh << "EOF"
#!/data/data/com.termux/files/usr/bin/bash
termux-wake-lock
sshd
# Add your startup commands here
EOF

chmod +x ~/.termux/boot/start.sh'
    
    echo -e "${WHITE}  ${BOLD}6. Termux Styling:${NC}"
    print_code '# Customize appearance
mkdir -p ~/.termux

# Set font
# Download font and copy to ~/.termux/font.ttf

# Set color scheme
# Create ~/.termux/colors.properties

# Extra keys bar
cat > ~/.termux/termux.properties << "EOF"
extra-keys = [["ESC","TAB","CTRL","ALT","-","DOWN","UP"]]
EOF

# Reload settings
termux-reload-settings'
    
    echo -e "${WHITE}  ${BOLD}7. Practical Termux Script:${NC}"
    
    run_demo '#!/bin/bash
# System info script for Termux

echo "╔══════════════════════════════════════╗"
echo "║     📱 TERMUX SYSTEM INFO           ║"
echo "╠══════════════════════════════════════╣"
printf "║ %-36s ║\n" "User: $(whoami)"
printf "║ %-36s ║\n" "Shell: $(basename $SHELL)"
printf "║ %-36s ║\n" "Date: $(date +%Y-%m-%d)"
printf "║ %-36s ║\n" "Time: $(date +%H:%M:%S)"
printf "║ %-36s ║\n" "Uptime: $(uptime -p 2>/dev/null || uptime | cut -d, -f1)"
printf "║ %-36s ║\n" "Packages: $(dpkg -l 2>/dev/null | wc -l || echo N/A)"

if [ -d "$HOME/storage" ]; then
    printf "║ %-36s ║\n" "Storage: accessible"
else
    printf "║ %-36s ║\n" "Storage: run termux-setup-storage"
fi

echo "╚══════════════════════════════════════╝"'
    
    quiz "What command sets up storage access in Termux?" \
         "termux-setup-storage" \
         "termux-setup-storage creates symlinks to access phone storage."
    
    pause_lesson
}

# ============================================================
# LESSON 18: PRACTICAL PROJECTS
# ============================================================
lesson_18() {
    print_header
    print_lesson_title "LESSON 18: Practical Projects"
    
    echo -e "${WHITE}  ${BOLD}Project 1: File Backup Script${NC}"
    echo ""
    
    print_code '#!/bin/bash
# backup.sh - Simple backup script

BACKUP_DIR="$HOME/backups"
DATE=$(date +%Y%m%d_%H%M%S)
SOURCE="$HOME/projects"

mkdir -p "$BACKUP_DIR"

BACKUP_FILE="$BACKUP_DIR/backup_$DATE.tar.gz"

echo "Creating backup..."
tar -czf "$BACKUP_FILE" -C "$(dirname "$SOURCE")" "$(basename "$SOURCE")" 2>/dev/null

if [ $? -eq 0 ]; then
    SIZE=$(du -sh "$BACKUP_FILE" | cut -f1)
    echo "✅ Backup created: $BACKUP_FILE ($SIZE)"
else
    echo "❌ Backup failed!"
    exit 1
fi

# Keep only last 5 backups
ls -t "$BACKUP_DIR"/backup_*.tar.gz 2>/dev/null | tail -n +6 | xargs rm -f
echo "Old backups cleaned up"'
    
    pause_lesson
    
    echo -e "${WHITE}  ${BOLD}Project 2: System Monitor${NC}"
    echo ""
    
    run_demo '#!/bin/bash
# System monitor

echo "┌─────────────────────────────────────────┐"
echo "│         📊 SYSTEM MONITOR               │"
echo "├─────────────────────────────────────────┤"

# Memory
if [ -f /proc/meminfo ]; then
    total_mem=$(grep MemTotal /proc/meminfo | awk "{print \$2}")
    free_mem=$(grep MemAvailable /proc/meminfo | awk "{print \$2}")
    used_mem=$((total_mem - free_mem))
    mem_percent=$((used_mem * 100 / total_mem))
    
    # Progress bar
    bar_width=20
    filled=$((mem_percent * bar_width / 100))
    empty=$((bar_width - filled))
    bar=$(printf "%${filled}s" | tr " " "█")
    bar+=$(printf "%${empty}s" | tr " " "░")
    
    printf "│ Memory: [%s] %3d%%           │\n" "$bar" "$mem_percent"
    printf "│ Total: %8d KB                  │\n" "$total_mem"
    printf "│ Used:  %8d KB                  │\n" "$used_mem"
fi

# Disk
disk_info=$(df -h "$HOME" 2>/dev/null | tail -1)
if [ -n "$disk_info" ]; then
    disk_used=$(echo "$disk_info" | awk "{print \$5}" | tr -d "%")
    disk_size=$(echo "$disk_info" | awk "{print \$2}")
    
    filled=$((disk_used * 20 / 100))
    empty=$((20 - filled))
    bar=$(printf "%${filled}s" | tr " " "█")
    bar+=$(printf "%${empty}s" | tr " " "░")
    
    printf "│ Disk:   [%s] %3d%%           │\n" "$bar" "$disk_used"
    printf "│ Size: %s                          │\n" "$disk_size"
fi

# Processes
proc_count=$(ps aux 2>/dev/null | wc -l || ps | wc -l)
printf "│ Processes: %-28s │\n" "$proc_count"

# Uptime
up=$(uptime 2>/dev/null | sed "s/.*up/Up/" | cut -d, -f1)
printf "│ %-39s │\n" "$up"

echo "├─────────────────────────────────────────┤"
printf "│ Updated: %-30s │\n" "$(date +%H:%M:%S)"
echo "└─────────────────────────────────────────┘"'
    
    pause_lesson
    
    echo -e "${WHITE}  ${BOLD}Project 3: Todo List Manager${NC}"
    echo ""
    
    print_code '#!/bin/bash
# todo.sh - Simple todo list manager

TODO_FILE="$HOME/.todo_list"
touch "$TODO_FILE"

add_task() {
    echo "[ ] $*" >> "$TODO_FILE"
    echo "✅ Added: $*"
}

list_tasks() {
    if [ ! -s "$TODO_FILE" ]; then
        echo "📋 No tasks yet!"
        return
    fi
    echo "📋 Todo List:"
    cat -n "$TODO_FILE"
}

complete_task() {
    sed -i "${1}s/\[ \]/[✓]/" "$TODO_FILE"
    echo "✅ Task $1 completed!"
}

delete_task() {
    sed -i "${1}d" "$TODO_FILE"
    echo "🗑️ Task $1 deleted!"
}

case "${1:-}" in
    add)    shift; add_task "$@" ;;
    list)   list_tasks ;;
    done)   complete_task "$2" ;;
    delete) delete_task "$2" ;;
    *)      echo "Usage: $0 {add|list|done|delete} [args]" ;;
esac'
    
    run_demo '# Todo demo
TODO_FILE=$(mktemp)

add_task() { echo "[ ] $*" >> "$TODO_FILE"; echo "  ✅ Added: $*"; }
list_tasks() { echo "  📋 Todo List:"; cat -n "$TODO_FILE"; }
complete_task() { sed -i "${1}s/\[ \]/[✓]/" "$TODO_FILE"; echo "  ✅ Task $1 completed!"; }

echo "Todo List Demo:"
echo ""
add_task "Learn Bash scripting"
add_task "Build a project"
add_task "Practice daily"
echo ""
list_tasks
echo ""
complete_task 1
echo ""
list_tasks

rm -f "$TODO_FILE"'
    
    pause_lesson
    
    echo -e "${WHITE}  ${BOLD}Project 4: Password Generator${NC}"
    echo ""
    
    run_demo '#!/bin/bash
# Password generator

generate_password() {
    local length=${1:-16}
    local charset="A-Za-z0-9!@#\$%^&*"
    
    cat /dev/urandom | tr -dc "$charset" | head -c "$length"
    echo ""
}

echo "🔐 Password Generator"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  8 chars:  $(generate_password 8)"
echo "  12 chars: $(generate_password 12)"
echo "  16 chars: $(generate_password 16)"
echo "  20 chars: $(generate_password 20)"
echo "  24 chars: $(generate_password 24)"
echo ""

# PIN generator
echo "📌 PIN Codes:"
for i in {1..3}; do
    pin=$(cat /dev/urandom | tr -dc "0-9" | head -c 4)
    echo "  PIN $i: $pin"
done

# Passphrase generator
echo ""
echo "📝 Passphrases:"
words=("apple" "brave" "cloud" "dream" "eagle" "flame" "grape" "heart" 
       "ivory" "jewel" "karma" "light" "magic" "noble" "ocean" "peace")
for i in {1..3}; do
    phrase=""
    for j in {1..4}; do
        idx=$((RANDOM % ${#words[@]}))
        phrase+="${words[$idx]}-"
    done
    echo "  ${phrase%-}"
done'
    
    pause_lesson
    
    echo -e "${WHITE}  ${BOLD}Project 5: Network Scanner (Basic)${NC}"
    echo ""
    
    print_code '#!/bin/bash
# Simple port scanner

target="${1:-localhost}"
echo "🔍 Scanning $target..."

for port in 22 80 443 8080 8443 3000 3306 5432; do
    (echo > /dev/tcp/$target/$port) 2>/dev/null
    if [ $? -eq 0 ]; then
        echo "  ✅ Port $port: OPEN"
    else
        echo "  ❌ Port $port: closed"
    fi
done'
    
    echo -e "${WHITE}  ${BOLD}Project 6: File Organizer${NC}"
    echo ""
    
    print_code '#!/bin/bash
# Organize files by extension

SOURCE="${1:-.}"
echo "📁 Organizing files in: $SOURCE"

for file in "$SOURCE"/*; do
    [ -f "$file" ] || continue
    
    ext="${file##*.}"
    [ "$ext" = "$file" ] && ext="no_extension"
    
    dest="$SOURCE/$ext"
    mkdir -p "$dest"
    mv "$file" "$dest/"
    echo "  Moved: $(basename "$file") → $ext/"
done

echo "✅ Organization complete!"'
    
    print_tip "Try building these projects and modifying them!"
    
    pause_lesson
}

# ============================================================
# LESSON 19: BEST PRACTICES & TIPS
# ============================================================
lesson_19() {
    print_header
    print_lesson_title "LESSON 19: Best Practices & Tips"
    
    echo -e "${WHITE}  ${BOLD}1. Script Template:${NC}"
    print_code '#!/usr/bin/env bash
#
# Script: script_name.sh
# Description: What this script does
# Author: Your Name
# Date: 2024-01-01
# Version: 1.0
#
# Usage: ./script_name.sh [options] [arguments]
#

set -euo pipefail
IFS=$'"'"'\n\t'"'"'

# --- Constants ---
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_NAME="$(basename "$0")"

# --- Functions ---
usage() {
    cat << EOF
Usage: $SCRIPT_NAME [options]

Options:
    -h, --help      Show this help message
    -v, --verbose   Enable verbose output
    -d, --debug     Enable debug mode
EOF
}

log() { echo "[$(date +%H:%M:%S)] $*"; }
die() { echo "ERROR: $*" >&2; exit 1; }

cleanup() {
    # Cleanup code here
    :
}
trap cleanup EXIT

# --- Main ---
main() {
    log "Starting $SCRIPT_NAME"
    # Your code here
    log "Done"
}

main "$@"'
    
    pause_lesson
    
    echo -e "${WHITE}  ${BOLD}2. Quoting Rules:${NC}"
    print_code '# ALWAYS quote variables
echo "$variable"          # ✅ Good
echo $variable            # ❌ Bad (word splitting)

# Use double quotes for expansion
echo "Hello $name"        # Variable expands
echo "$(command)"         # Command expands

# Use single quotes for literal strings
echo '"'"'No $expansion here'"'"'   # Nothing expands
echo '"'"'Path: $HOME'"'"'           # Prints: Path: $HOME

# Arrays need special quoting
"${array[@]}"             # ✅ Each element preserved
${array[@]}               # ❌ Elements may split'
    
    echo -e "${WHITE}  ${BOLD}3. Common Mistakes to Avoid:${NC}"
    echo ""
    
    echo -e "${RED}  ❌ Bad Practices:${NC}"
    print_code '# Missing quotes
if [ $var = "test" ]; then    # Fails if var is empty or has spaces

# Using == in [ ]
if [ "$var" == "test" ]; then # Use = in [ ], == only in [[ ]]

# cat abuse (Useless Use of Cat)
cat file.txt | grep "pattern"  # Unnecessary pipe

# Parsing ls output
for f in $(ls); do            # Breaks on spaces in filenames

# Not checking exit status
cd /some/dir                   # What if this fails?'
    
    echo -e "${GREEN}  ✅ Good Practices:${NC}"
    print_code '# Always quote
if [ "$var" = "test" ]; then

# Use [[ ]] for tests
if [[ "$var" == "test" ]]; then

# Direct input
grep "pattern" file.txt

# Use globs
for f in *; do

# Check exit status
cd /some/dir || exit 1'
    
    pause_lesson
    
    echo -e "${WHITE}  ${BOLD}4. Security Tips:${NC}"
    print_code '# Validate input
[[ "$input" =~ ^[a-zA-Z0-9]+$ ]] || die "Invalid input"

# Avoid eval
eval "$user_input"    # ❌ NEVER eval user input

# Use -- to end options
rm -- "$filename"     # Handles filenames starting with -

# Temp files securely
tmpfile=$(mktemp) || die "Cannot create temp file"
trap "rm -f $tmpfile" EXIT

# Check before destructive operations
[[ -d "$dir" ]] || die "Directory not found"
rm -rf "${dir:?}/"    # Fails if dir is empty'
    
    echo -e "${WHITE}  ${BOLD}5. Performance Tips:${NC}"
    print_code '# Use built-in string operations
"${var##*/}"           # ✅ Instead of: basename "$var"
"${var%/*}"            # ✅ Instead of: dirname "$var"

# Avoid external commands in loops
while read -r line; do
    echo "${line^^}"   # ✅ Built-in uppercase
done < file.txt

# Use [[ ]] instead of [ ]
[[ "$a" == "$b" ]]    # ✅ Faster, more features

# Avoid subshells
result=$((a + b))      # ✅ Instead of: result=$(expr $a + $b)'
    
    echo -e "${WHITE}  ${BOLD}6. Useful One-Liners:${NC}"
    
    run_demo 'echo "Useful One-Liners:"
echo ""

# Repeat a character
echo "  Line: $(printf "%-40s" | tr " " "=")"

# Quick HTTP server
echo "  HTTP server: python -m http.server 8080"

# Find large files
echo "  Large files (top 3):"
du -ah "$HOME" 2>/dev/null | sort -rh | head -3 | while read -r size path; do
    printf "    %8s  %s\n" "$size" "$(basename "$path")"
done

# Count file types
echo ""
echo "  File types in home:"
find "$HOME" -maxdepth 1 -type f 2>/dev/null | sed "s/.*\.//" | sort | uniq -c | sort -rn | head -5 | while read -r count ext; do
    printf "    %4d  .%s\n" "$count" "$ext"
done'
    
    echo -e "${WHITE}  ${BOLD}7. ShellCheck - Lint Your Scripts:${NC}"
    print_code '# Install
pkg install shellcheck

# Check your script
shellcheck script.sh

# Common issues it finds:
# - Unquoted variables
# - Useless use of cat
# - Missing shebangs
# - Deprecated syntax
# - Potential bugs'
    
    print_tip "Always run shellcheck on your scripts before deploying!"
    
    echo -e "${WHITE}  ${BOLD}8. Quick Reference Card:${NC}"
    
    run_demo 'echo "╔══════════════════════════════════════════════════╗"
echo "║           📋 BASH QUICK REFERENCE              ║"
echo "╠══════════════════════════════════════════════════╣"
echo "║ Variables:   var=\"value\"   echo \"\$var\"          ║"
echo "║ Input:       read -p \"prompt: \" var             ║"
echo "║ If:          if [[ cond ]]; then ... fi         ║"
echo "║ For:         for i in {1..5}; do ... done       ║"
echo "║ While:       while [[ cond ]]; do ... done      ║"
echo "║ Function:    name() { commands; }               ║"
echo "║ Array:       arr=(a b c)   \${arr[@]}            ║"
echo "║ String len:  \${#var}                            ║"
echo "║ Substring:   \${var:start:length}                ║"
echo "║ Replace:     \${var/old/new}                     ║"
echo "║ Uppercase:   \${var^^}                           ║"
echo "║ Lowercase:   \${var,,}                           ║"
echo "║ Arithmetic:  \$((a + b))                         ║"
echo "║ Exit status: \$?                                 ║"
echo "║ All args:    \$@                                 ║"
echo "║ Arg count:   \$#                                 ║"
echo "║ Redirect:    > (write) >> (append) 2> (stderr)  ║"
echo "║ Pipe:        cmd1 | cmd2                        ║"
echo "╚══════════════════════════════════════════════════╝"'
    
    pause_lesson
}

# ============================================================
# RUN ALL LESSONS
# ============================================================
run_all() {
    lesson_1
    lesson_2
    lesson_3
    lesson_4
    lesson_5
    lesson_6
    lesson_7
    lesson_8
    lesson_9
    lesson_10
    lesson_11
    lesson_12
    lesson_13
    lesson_14
    lesson_15
    lesson_16
    lesson_17
    lesson_18
    lesson_19
    
    print_header
    echo -e "${GREEN}${BOLD}"
    echo "  ╔══════════════════════════════════════════════════╗"
    echo "  ║                                                  ║"
    echo "  ║    🎉 CONGRATULATIONS! 🎉                       ║"
    echo "  ║                                                  ║"
    echo "  ║    You've completed ALL 19 lessons!              ║"
    echo "  ║                                                  ║"
    echo "  ║    You now know:                                 ║"
    echo "  ║    ✅ Variables & Data Types                     ║"
    echo "  ║    ✅ Input/Output                               ║"
    echo "  ║    ✅ String Operations                          ║"
    echo "  ║    ✅ Arithmetic                                 ║"
    echo "  ║    ✅ Conditionals & Case                        ║"
    echo "  ║    ✅ Loops                                      ║"
    echo "  ║    ✅ Arrays & Functions                         ║"
    echo "  ║    ✅ File Operations                            ║"
    echo "  ║    ✅ Text Processing                            ║"
    echo "  ║    ✅ Pipes & Redirection                        ║"
    echo "  ║    ✅ Process Management                         ║"
    echo "  ║    ✅ Error Handling                              ║"
    echo "  ║    ✅ Regular Expressions                        ║"
    echo "  ║    ✅ Termux Commands                            ║"
    echo "  ║    ✅ Practical Projects                         ║"
    echo "  ║    ✅ Best Practices                             ║"
    echo "  ║                                                  ║"
    echo "  ║    Keep practicing and building projects! 🚀     ║"
    echo "  ║                                                  ║"
    echo "  ╚══════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# ============================================================
# MAIN PROGRAM LOOP
# ============================================================
main() {
    while true; do
        show_menu
        read -r choice
        
        case $choice in
            1)  lesson_1 ;;
            2)  lesson_2 ;;
            3)  lesson_3 ;;
            4)  lesson_4 ;;
            5)  lesson_5 ;;
            6)  lesson_6 ;;
            7)  lesson_7 ;;
            8)  lesson_8 ;;
            9)  lesson_9 ;;
            10) lesson_10 ;;
            11) lesson_11 ;;
            12) lesson_12 ;;
            13) lesson_13 ;;
            14) lesson_14 ;;
            15) lesson_15 ;;
            16) lesson_16 ;;
            17) lesson_17 ;;
            18) lesson_18 ;;
            19) lesson_19 ;;
            20) run_all ;;
            0)
                echo -e "${GREEN}  Thanks for learning! Happy scripting! 🚀👋${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}  Invalid choice. Please enter 0-20.${NC}"
                sleep 1
                ;;
        esac
    done
}

# Start the program
main