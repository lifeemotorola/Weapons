#!/data/data/com.termux/files/usr/bin/bash

#=====================================================
# COMPLETE PYTHON LESSON FOR TERMUX
# File: python_lesson.sh
# Usage: chmod +x python_lesson.sh && ./python_lesson.sh
#=====================================================

# --- Colors ---
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

# --- Variables ---
LESSON_DIR="$HOME/python_lessons"
SCORE=0
TOTAL_QUESTIONS=0

# ============================================
#            UTILITY FUNCTIONS
# ============================================

clear_screen() {
    clear
}

press_continue() {
    echo ""
    echo -e "${YELLOW}Press Enter to continue...${NC}"
    read -r
}

print_header() {
    clear_screen
    echo -e "${CYAN}╔══════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC}${BOLD}${WHITE}        COMPLETE PYTHON LESSON FOR TERMUX           ${NC}${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}${GREEN}           Learn Python Step by Step                ${NC}${CYAN}║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════╝${NC}"
    echo ""
}

print_section() {
    echo ""
    echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}${WHITE}  📘 $1${NC}"
    echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

print_subsection() {
    echo ""
    echo -e "${BLUE}  ── $1 ──${NC}"
    echo ""
}

print_code() {
    echo -e "${GREEN}  ┌─── Code ───────────────────────────────────────┐${NC}"
    while IFS= read -r line; do
        echo -e "${GREEN}  │${NC} ${YELLOW}$line${NC}"
    done <<< "$1"
    echo -e "${GREEN}  └────────────────────────────────────────────────┘${NC}"
}

print_output() {
    echo -e "${CYAN}  ┌─── Output ──────────────────────────────────────┐${NC}"
    while IFS= read -r line; do
        echo -e "${CYAN}  │${NC} ${WHITE}$line${NC}"
    done <<< "$1"
    echo -e "${CYAN}  └────────────────────────────────────────────────┘${NC}"
}

run_python() {
    echo -e "${CYAN}  ┌─── Live Output ─────────────────────────────────┐${NC}"
    python3 -c "$1" 2>&1 | while IFS= read -r line; do
        echo -e "${CYAN}  │${NC} ${WHITE}$line${NC}"
    done
    echo -e "${CYAN}  └────────────────────────────────────────────────┘${NC}"
}

run_python_file() {
    echo -e "${CYAN}  ┌─── Live Output ─────────────────────────────────┐${NC}"
    python3 "$1" 2>&1 | while IFS= read -r line; do
        echo -e "${CYAN}  │${NC} ${WHITE}$line${NC}"
    done
    echo -e "${CYAN}  └────────────────────────────────────────────────┘${NC}"
}

print_tip() {
    echo -e "${YELLOW}  💡 TIP: $1${NC}"
}

print_warning() {
    echo -e "${RED}  ⚠️  WARNING: $1${NC}"
}

print_success() {
    echo -e "${GREEN}  ✅ $1${NC}"
}

print_error() {
    echo -e "${RED}  ❌ $1${NC}"
}

quiz_question() {
    TOTAL_QUESTIONS=$((TOTAL_QUESTIONS + 1))
    echo ""
    echo -e "${YELLOW}  ╔═══ QUIZ QUESTION #$TOTAL_QUESTIONS ═══════════════════════════╗${NC}"
    echo -e "${YELLOW}  ║${NC} ${WHITE}$1${NC}"
    echo -e "${YELLOW}  ╠════════════════════════════════════════════════════╣${NC}"
    echo -e "${YELLOW}  ║${NC} ${CYAN}A)${NC} $2"
    echo -e "${YELLOW}  ║${NC} ${CYAN}B)${NC} $3"
    echo -e "${YELLOW}  ║${NC} ${CYAN}C)${NC} $4"
    echo -e "${YELLOW}  ║${NC} ${CYAN}D)${NC} $5"
    echo -e "${YELLOW}  ╚════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -ne "${WHITE}  Your answer (A/B/C/D): ${NC}"
    read -r answer
    answer=$(echo "$answer" | tr '[:lower:]' '[:upper:]')
    if [ "$answer" = "$6" ]; then
        SCORE=$((SCORE + 1))
        print_success "CORRECT! Well done! 🎉"
    else
        print_error "WRONG! The correct answer is: $6"
        echo -e "${WHITE}  📝 Explanation: $7${NC}"
    fi
}

# ============================================
#         INSTALLATION & SETUP
# ============================================

setup_environment() {
    print_header
    print_section "SETUP & INSTALLATION"

    echo -e "${WHITE}  Checking and setting up Python environment...${NC}"
    echo ""

    # Update packages
    echo -e "${CYAN}  [1/4]${NC} Updating package list..."
    pkg update -y > /dev/null 2>&1
    echo -e "${GREEN}  ✓ Package list updated${NC}"

    # Install Python
    echo -e "${CYAN}  [2/4]${NC} Installing Python..."
    pkg install python -y > /dev/null 2>&1
    echo -e "${GREEN}  ✓ Python installed${NC}"

    # Check Python version
    echo -e "${CYAN}  [3/4]${NC} Checking Python version..."
    PYVER=$(python3 --version 2>&1)
    echo -e "${GREEN}  ✓ $PYVER${NC}"

    # Create lesson directory
    echo -e "${CYAN}  [4/4]${NC} Creating lesson directory..."
    mkdir -p "$LESSON_DIR"
    echo -e "${GREEN}  ✓ Lesson directory: $LESSON_DIR${NC}"

    echo ""
    echo -e "${GREEN}  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}  ✅ Setup complete! You're ready to learn Python!${NC}"
    echo -e "${GREEN}  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    press_continue
}

# ============================================
#       LESSON 1: PYTHON BASICS
# ============================================

lesson_1_basics() {
    print_header
    print_section "LESSON 1: PYTHON BASICS"

    echo -e "${WHITE}  Python is a powerful, easy-to-learn programming language.${NC}"
    echo -e "${WHITE}  Let's start with the very basics!${NC}"

    # --- 1.1 Hello World ---
    print_subsection "1.1 - Your First Program: Hello World"

    echo -e "${WHITE}  The print() function displays text on screen.${NC}"
    echo ""

    CODE='print("Hello, World!")
print("Welcome to Python on Termux!")
print("Learning Python is fun! 🐍")'
    print_code "$CODE"

    echo ""
    echo -e "${WHITE}  Running the code:${NC}"
    run_python "$CODE"

    press_continue

    # --- 1.2 Comments ---
    print_subsection "1.2 - Comments"

    echo -e "${WHITE}  Comments are notes in your code that Python ignores.${NC}"
    echo -e "${WHITE}  They help explain what your code does.${NC}"
    echo ""

    CODE='# This is a single-line comment
print("Comments are ignored by Python")

# You can also use multi-line comments:
"""
This is a
multi-line comment
(docstring)
"""

print("Only print statements show output")

# Inline comment:
x = 5  # This assigns 5 to x
print("x =", x)'
    print_code "$CODE"

    echo ""
    echo -e "${WHITE}  Running the code:${NC}"
    run_python "$CODE"

    press_continue

    # --- 1.3 Print Formatting ---
    print_subsection "1.3 - Print Formatting"

    CODE='# Different ways to print
name = "Termux User"
age = 25

# Method 1: Concatenation
print("Hello, " + name + "!")

# Method 2: Comma separated
print("Name:", name, "| Age:", age)

# Method 3: f-strings (RECOMMENDED - Python 3.6+)
print(f"Hello, {name}! You are {age} years old.")

# Method 4: .format()
print("Hello, {}! Age: {}".format(name, age))

# Method 5: % formatting (old style)
print("Hello, %s! Age: %d" % (name, age))

# Special characters
print("Line 1\nLine 2")        # New line
print("Tab\there")              # Tab
print("She said \"hello\"")    # Escape quotes'
    print_code "$CODE"

    echo ""
    echo -e "${WHITE}  Running the code:${NC}"
    run_python "$CODE"

    print_tip "f-strings are the most modern and readable way to format text!"

    press_continue

    # --- Quiz ---
    print_subsection "📝 LESSON 1 QUIZ"
    quiz_question \
        "What function is used to display output in Python?" \
        "echo()" \
        "print()" \
        "display()" \
        "show()" \
        "B" \
        "print() is Python's built-in function for displaying output."

    quiz_question \
        "Which symbol starts a single-line comment?" \
        "// (double slash)" \
        "/* (slash asterisk)" \
        "# (hash/pound)" \
        "-- (double dash)" \
        "C" \
        "Python uses # for single-line comments."

    quiz_question \
        "What is an f-string in Python?" \
        "A file string" \
        "A formatted string literal with f prefix" \
        "A function string" \
        "A float string" \
        "B" \
        "f-strings (f\"...\") allow embedding expressions inside strings."

    press_continue
}

# ============================================
#     LESSON 2: VARIABLES & DATA TYPES
# ============================================

lesson_2_variables() {
    print_header
    print_section "LESSON 2: VARIABLES & DATA TYPES"

    echo -e "${WHITE}  Variables store data values. Python automatically${NC}"
    echo -e "${WHITE}  detects the data type - no declaration needed!${NC}"

    # --- 2.1 Variables ---
    print_subsection "2.1 - Creating Variables"

    CODE='# Variables are created when you assign a value
name = "Python Learner"     # String (text)
age = 20                     # Integer (whole number)
height = 5.9                 # Float (decimal number)
is_student = True            # Boolean (True/False)
grade = None                 # NoneType (no value)

print(f"Name: {name}")
print(f"Age: {age}")
print(f"Height: {height}")
print(f"Student: {is_student}")
print(f"Grade: {grade}")

# Check types with type()
print(f"\nType of name: {type(name)}")
print(f"Type of age: {type(age)}")
print(f"Type of height: {type(height)}")
print(f"Type of is_student: {type(is_student)}")
print(f"Type of grade: {type(grade)}")'
    print_code "$CODE"

    echo ""
    run_python "$CODE"

    press_continue

    # --- 2.2 Variable Rules ---
    print_subsection "2.2 - Variable Naming Rules"

    CODE='# ✅ VALID variable names:
my_name = "John"
_private = "hidden"
myAge = 25
name2 = "Jane"
MY_CONSTANT = 3.14

# ❌ INVALID (would cause errors):
# 2name = "error"    # Cannot start with number
# my-name = "error"  # No hyphens
# my name = "error"  # No spaces
# class = "error"    # Cannot use reserved words

# Multiple assignment
a, b, c = 1, 2, 3
print(f"a={a}, b={b}, c={c}")

# Same value to multiple variables
x = y = z = 0
print(f"x={x}, y={y}, z={z}")

# Swap variables
a, b = b, a
print(f"After swap: a={a}, b={b}")'
    print_code "$CODE"

    echo ""
    run_python "$CODE"

    press_continue

    # --- 2.3 Data Types Deep Dive ---
    print_subsection "2.3 - Data Types Deep Dive"

    CODE='# ═══ STRINGS ═══
s1 = "Hello"
s2 = '"'"'World'"'"'
s3 = """Multi
line string"""
print("String:", s1, s2)
print("Multi-line:", s3)
print("Length:", len(s1))
print("Upper:", s1.upper())
print("Lower:", s1.lower())
print("Slicing:", s1[0:3])     # Hel
print("Reverse:", s1[::-1])    # olleH

print("\n" + "="*40)

# ═══ NUMBERS ═══
integer = 42
floating = 3.14159
negative = -17
big_num = 1_000_000    # Underscore for readability
scientific = 2.5e3      # 2500.0

print(f"\nInteger: {integer}")
print(f"Float: {floating}")
print(f"Negative: {negative}")
print(f"Big number: {big_num}")
print(f"Scientific: {scientific}")

print("\n" + "="*40)

# ═══ TYPE CONVERSION ═══
num_str = "42"
str_to_int = int(num_str)       # String -> Integer
str_to_float = float(num_str)   # String -> Float
int_to_str = str(42)            # Integer -> String
float_to_int = int(3.7)         # Float -> Integer (truncates!)
int_to_float = float(5)         # Integer -> Float
int_to_bool = bool(1)           # Integer -> Boolean

print(f"\nstr->int: {str_to_int} (type: {type(str_to_int).__name__})")
print(f"str->float: {str_to_float} (type: {type(str_to_float).__name__})")
print(f"int->str: {int_to_str} (type: {type(int_to_str).__name__})")
print(f"float->int: {float_to_int} (truncated!)")
print(f"int->float: {int_to_float}")
print(f"int->bool: {int_to_bool}")'
    print_code "$CODE"

    echo ""
    run_python "$CODE"

    print_tip "bool(0) is False, bool(any_other_number) is True!"
    print_tip "bool('') is False, bool('any_text') is True!"

    press_continue

    # --- Quiz ---
    print_subsection "📝 LESSON 2 QUIZ"

    quiz_question \
        "What is the output of: type(3.14)?" \
        "<class 'int'>" \
        "<class 'float'>" \
        "<class 'str'>" \
        "<class 'double'>" \
        "B" \
        "3.14 is a decimal number, which is a float type in Python."

    quiz_question \
        "What does int(3.9) return?" \
        "4 (rounds up)" \
        "3.0" \
        "3 (truncates decimal)" \
        "Error" \
        "C" \
        "int() truncates (removes) the decimal part, it doesn't round."

    quiz_question \
        "Which variable name is INVALID?" \
        "_count" \
        "my_var" \
        "2nd_place" \
        "firstName" \
        "C" \
        "Variable names cannot start with a number."

    press_continue
}

# ============================================
#     LESSON 3: OPERATORS
# ============================================

lesson_3_operators() {
    print_header
    print_section "LESSON 3: OPERATORS"

    echo -e "${WHITE}  Operators perform operations on values and variables.${NC}"

    # --- 3.1 Arithmetic ---
    print_subsection "3.1 - Arithmetic Operators"

    CODE='a, b = 17, 5

print("═══ ARITHMETIC OPERATORS ═══")
print(f"{a} + {b} = {a + b}")      # Addition
print(f"{a} - {b} = {a - b}")      # Subtraction
print(f"{a} * {b} = {a * b}")      # Multiplication
print(f"{a} / {b} = {a / b}")      # Division (always float)
print(f"{a} // {b} = {a // b}")    # Floor division (integer)
print(f"{a} % {b} = {a % b}")      # Modulo (remainder)
print(f"{a} ** {b} = {a ** b}")    # Exponentiation (power)

print("\n═══ ORDER OF OPERATIONS (PEMDAS) ═══")
result = 2 + 3 * 4          # 14, not 20
print(f"2 + 3 * 4 = {result}")
result = (2 + 3) * 4        # 20
print(f"(2 + 3) * 4 = {result}")
result = 2 ** 3 + 1         # 9
print(f"2 ** 3 + 1 = {result}")

print("\n═══ USEFUL MATH ═══")
import math
print(f"Square root of 16: {math.sqrt(16)}")
print(f"Pi: {math.pi}")
print(f"Ceiling of 4.2: {math.ceil(4.2)}")
print(f"Floor of 4.8: {math.floor(4.8)}")
print(f"Absolute of -5: {abs(-5)}")
print(f"Round 3.7: {round(3.7)}")
print(f"Round 3.14159 to 2: {round(3.14159, 2)}")
print(f"Max: {max(1, 5, 3)}")
print(f"Min: {min(1, 5, 3)}")'
    print_code "$CODE"

    echo ""
    run_python "$CODE"

    press_continue

    # --- 3.2 Comparison & Logical ---
    print_subsection "3.2 - Comparison & Logical Operators"

    CODE='x, y = 10, 20

print("═══ COMPARISON OPERATORS ═══")
print(f"{x} == {y} : {x == y}")    # Equal
print(f"{x} != {y} : {x != y}")    # Not equal
print(f"{x} > {y}  : {x > y}")     # Greater than
print(f"{x} < {y}  : {x < y}")     # Less than
print(f"{x} >= {y} : {x >= y}")    # Greater or equal
print(f"{x} <= {y} : {x <= y}")    # Less or equal

print("\n═══ LOGICAL OPERATORS ═══")
a, b = True, False
print(f"True and False : {a and b}")
print(f"True or False  : {a or b}")
print(f"not True       : {not a}")

# Practical example
age = 25
income = 50000
print(f"\nAge: {age}, Income: {income}")
print(f"Can get loan (age>18 AND income>30000): {age > 18 and income > 30000}")
print(f"Is teen OR senior: {(age >= 13 and age <= 19) or age >= 65}")

print("\n═══ ASSIGNMENT OPERATORS ═══")
n = 10
print(f"n = {n}")
n += 5    # n = n + 5
print(f"n += 5  → {n}")
n -= 3    # n = n - 3
print(f"n -= 3  → {n}")
n *= 2    # n = n * 2
print(f"n *= 2  → {n}")
n //= 3   # n = n // 3
print(f"n //= 3 → {n}")
n **= 2   # n = n ** 2
print(f"n **= 2 → {n}")
n %= 5    # n = n % 5
print(f"n %= 5  → {n}")

print("\n═══ IDENTITY & MEMBERSHIP ═══")
a = [1, 2, 3]
b = [1, 2, 3]
c = a
print(f"a == b : {a == b}")     # Same value
print(f"a is b : {a is b}")     # Same object? No
print(f"a is c : {a is c}")     # Same object? Yes

print(f"2 in a     : {2 in a}")
print(f"5 not in a : {5 not in a}")'
    print_code "$CODE"

    echo ""
    run_python "$CODE"

    press_continue

    # --- Quiz ---
    print_subsection "📝 LESSON 3 QUIZ"

    quiz_question \
        "What is 17 // 5 in Python?" \
        "3.4" \
        "3" \
        "4" \
        "2" \
        "B" \
        "// is floor division: it divides and rounds DOWN to nearest integer."

    quiz_question \
        "What is 2 ** 4?" \
        "8" \
        "6" \
        "16" \
        "24" \
        "C" \
        "** is the power operator: 2^4 = 2×2×2×2 = 16."

    quiz_question \
        "What does 'True and False' evaluate to?" \
        "True" \
        "False" \
        "None" \
        "Error" \
        "B" \
        "'and' requires BOTH to be True. Since one is False, result is False."

    press_continue
}

# ============================================
#     LESSON 4: CONTROL FLOW
# ============================================

lesson_4_control_flow() {
    print_header
    print_section "LESSON 4: CONTROL FLOW (if/elif/else)"

    echo -e "${WHITE}  Control flow lets your program make decisions!${NC}"

    # --- 4.1 If Statements ---
    print_subsection "4.1 - If / Elif / Else"

    CODE='# Basic if statement
age = 18

if age >= 18:
    print("You are an adult! ✅")
else:
    print("You are a minor! ❌")

print()

# If / elif / else chain
score = 85

if score >= 90:
    grade = "A"
    emoji = "🌟"
elif score >= 80:
    grade = "B"
    emoji = "👍"
elif score >= 70:
    grade = "C"
    emoji = "📝"
elif score >= 60:
    grade = "D"
    emoji = "⚠️"
else:
    grade = "F"
    emoji = "❌"

print(f"Score: {score} → Grade: {grade} {emoji}")

print()

# Nested if
temperature = 35
humidity = 80

if temperature > 30:
    if humidity > 70:
        print("🥵 Hot and humid! Stay hydrated!")
    else:
        print("☀️ Hot but dry.")
elif temperature > 20:
    print("😊 Pleasant weather!")
else:
    print("🥶 Cold! Wear a jacket!")

print()

# One-line if (ternary operator)
x = 15
result = "Even" if x % 2 == 0 else "Odd"
print(f"{x} is {result}")

# Multiple conditions
name = "Alice"
role = "admin"
active = True

if name and role == "admin" and active:
    print(f"Welcome, {name}! Full access granted. 🔓")'
    print_code "$CODE"

    echo ""
    run_python "$CODE"

    press_continue

    # --- 4.2 Loops ---
    print_subsection "4.2 - For Loops"

    CODE='# Basic for loop with range
print("═══ COUNTING ═══")
for i in range(5):
    print(f"  Count: {i}")

print()

# Range with start, stop, step
print("═══ EVEN NUMBERS (0-10) ═══")
for i in range(0, 11, 2):
    print(f"  {i}", end=" ")
print()

print("\n═══ COUNTDOWN ═══")
for i in range(5, 0, -1):
    print(f"  {i}...", end=" ")
print("🚀 Launch!")

# Loop through a string
print("\n═══ LOOP THROUGH STRING ═══")
word = "PYTHON"
for index, letter in enumerate(word):
    print(f"  Index {index}: {letter}")

# Loop through a list
print("\n═══ LOOP THROUGH LIST ═══")
fruits = ["🍎 Apple", "🍌 Banana", "🍊 Orange", "🍇 Grape"]
for fruit in fruits:
    print(f"  {fruit}")

# Nested loop - multiplication table
print("\n═══ MULTIPLICATION TABLE (1-5) ═══")
for i in range(1, 6):
    for j in range(1, 6):
        print(f"{i*j:4}", end="")
    print()'
    print_code "$CODE"

    echo ""
    run_python "$CODE"

    press_continue

    # --- 4.3 While Loops ---
    print_subsection "4.3 - While Loops"

    CODE='# Basic while loop
print("═══ WHILE LOOP ═══")
count = 0
while count < 5:
    print(f"  Count is: {count}")
    count += 1

# While with break
print("\n═══ BREAK EXAMPLE ═══")
for i in range(10):
    if i == 5:
        print(f"  Breaking at {i}! 🛑")
        break
    print(f"  i = {i}")

# While with continue
print("\n═══ CONTINUE EXAMPLE (skip even) ═══")
for i in range(10):
    if i % 2 == 0:
        continue
    print(f"  Odd: {i}")

# While with else
print("\n═══ WHILE-ELSE ═══")
n = 5
while n > 0:
    print(f"  n = {n}")
    n -= 1
else:
    print("  Loop completed normally! ✅")

# Practical: Sum of digits
print("\n═══ SUM OF DIGITS ═══")
number = 12345
total = 0
temp = number
while temp > 0:
    digit = temp % 10
    total += digit
    temp //= 10
print(f"  Sum of digits in {number} = {total}")

# Practical: Fibonacci sequence
print("\n═══ FIBONACCI (first 10) ═══")
a, b = 0, 1
fib_list = []
for _ in range(10):
    fib_list.append(a)
    a, b = b, a + b
print(f"  {fib_list}")'
    print_code "$CODE"

    echo ""
    run_python "$CODE"

    press_continue

    # --- 4.4 Match Statement (Python 3.10+) ---
    print_subsection "4.4 - Match Statement (Python 3.10+)"

    CODE='# Match-case (like switch in other languages)
# Note: Requires Python 3.10+
import sys
version = sys.version_info

if version >= (3, 10):
    day = "Monday"
    match day:
        case "Monday":
            print("Start of work week 💼")
        case "Friday":
            print("Almost weekend! 🎉")
        case "Saturday" | "Sunday":
            print("Weekend! 🏖️")
        case _:
            print("Regular weekday 📅")
else:
    # Fallback for older Python
    day = "Monday"
    if day == "Monday":
        print("Start of work week 💼")
    elif day == "Friday":
        print("Almost weekend! 🎉")
    elif day in ("Saturday", "Sunday"):
        print("Weekend! 🏖️")
    else:
        print("Regular weekday 📅")
    print(f"  (Using if/elif - Python {version.major}.{version.minor})")'
    print_code "$CODE"

    echo ""
    run_python "$CODE"

    press_continue

    # --- Quiz ---
    print_subsection "📝 LESSON 4 QUIZ"

    quiz_question \
        "What does 'break' do in a loop?" \
        "Pauses the loop temporarily" \
        "Skips to the next iteration" \
        "Exits the loop immediately" \
        "Restarts the loop" \
        "C" \
        "'break' immediately exits/terminates the loop."

    quiz_question \
        "What does range(2, 10, 3) generate?" \
        "2, 5, 8" \
        "2, 4, 6, 8" \
        "3, 6, 9" \
        "2, 3, 4, 5, 6, 7, 8, 9" \
        "A" \
        "range(start=2, stop=10, step=3) → 2, 5, 8"

    quiz_question \
        "What keyword skips the current iteration?" \
        "skip" \
        "pass" \
        "next" \
        "continue" \
        "D" \
        "'continue' skips the rest of the current iteration."

    press_continue
}

# ============================================
#     LESSON 5: DATA STRUCTURES
# ============================================

lesson_5_data_structures() {
    print_header
    print_section "LESSON 5: DATA STRUCTURES"

    echo -e "${WHITE}  Python has powerful built-in data structures!${NC}"

    # --- 5.1 Lists ---
    print_subsection "5.1 - Lists (Mutable, Ordered)"

    CODE='# Creating lists
fruits = ["apple", "banana", "cherry"]
numbers = [1, 2, 3, 4, 5]
mixed = [1, "hello", 3.14, True, None]
empty = []

print("═══ LIST BASICS ═══")
print(f"Fruits: {fruits}")
print(f"Length: {len(fruits)}")
print(f"First: {fruits[0]}")
print(f"Last: {fruits[-1]}")
print(f"Slice [0:2]: {fruits[0:2]}")

print("\n═══ LIST METHODS ═══")
fruits.append("date")           # Add to end
print(f"After append: {fruits}")

fruits.insert(1, "blueberry")   # Insert at index
print(f"After insert: {fruits}")

fruits.remove("banana")         # Remove by value
print(f"After remove: {fruits}")

popped = fruits.pop()           # Remove & return last
print(f"Popped: {popped}, List: {fruits}")

print("\n═══ MORE LIST OPERATIONS ═══")
nums = [3, 1, 4, 1, 5, 9, 2, 6, 5, 3]
print(f"Original: {nums}")
print(f"Sorted: {sorted(nums)}")
print(f"Reversed: {list(reversed(nums))}")
print(f"Count of 5: {nums.count(5)}")
print(f"Index of 9: {nums.index(9)}")
print(f"Sum: {sum(nums)}")
print(f"Max: {max(nums)}, Min: {min(nums)}")

# List comprehension
print("\n═══ LIST COMPREHENSION ═══")
squares = [x**2 for x in range(1, 6)]
print(f"Squares: {squares}")

evens = [x for x in range(20) if x % 2 == 0]
print(f"Evens: {evens}")

words = ["hello", "world", "python"]
upper = [w.upper() for w in words]
print(f"Upper: {upper}")

# Nested list (2D array / matrix)
print("\n═══ 2D LIST (MATRIX) ═══")
matrix = [
    [1, 2, 3],
    [4, 5, 6],
    [7, 8, 9]
]
for row in matrix:
    print(f"  {row}")
print(f"Element [1][2] = {matrix[1][2]}")  # 6'
    print_code "$CODE"

    echo ""
    run_python "$CODE"

    press_continue

    # --- 5.2 Tuples ---
    print_subsection "5.2 - Tuples (Immutable, Ordered)"

    CODE='# Tuples are like lists but CANNOT be changed
print("═══ TUPLES ═══")
coordinates = (10, 20)
colors = ("red", "green", "blue")
single = (42,)          # Note the comma for single element

print(f"Coordinates: {coordinates}")
print(f"Colors: {colors}")
print(f"First color: {colors[0]}")
print(f"Length: {len(colors)}")

# Tuple unpacking
x, y = coordinates
print(f"x={x}, y={y}")

# Tuple in for loop
print("\nIterating:")
for color in colors:
    print(f"  🎨 {color}")

# Why use tuples?
# 1. Faster than lists
# 2. Can be used as dictionary keys
# 3. Protect data from modification

# Named tuples (advanced)
from collections import namedtuple
Point = namedtuple("Point", ["x", "y"])
p = Point(3, 4)
print(f"\nNamedTuple Point: {p}")
print(f"p.x={p.x}, p.y={p.y}")'
    print_code "$CODE"

    echo ""
    run_python "$CODE"

    press_continue

    # --- 5.3 Dictionaries ---
    print_subsection "5.3 - Dictionaries (Key-Value Pairs)"

    CODE='# Creating dictionaries
print("═══ DICTIONARIES ═══")
person = {
    "name": "Alice",
    "age": 30,
    "city": "New York",
    "hobbies": ["reading", "coding"]
}

print(f"Person: {person}")
print(f"Name: {person['"'"'name'"'"']}")
print(f"Age: {person.get('"'"'age'"'"', '"'"'Unknown'"'"')}")

# Safe get (no error if key missing)
print(f"Phone: {person.get('"'"'phone'"'"', '"'"'Not found'"'"')}")

# Modify dictionary
person["email"] = "alice@mail.com"   # Add new
person["age"] = 31                    # Update
print(f"\nUpdated: {person}")

# Dictionary methods
print(f"\nKeys: {list(person.keys())}")
print(f"Values: {list(person.values())}")

print("\n═══ ITERATING ═══")
for key, value in person.items():
    print(f"  {key}: {value}")

# Dictionary comprehension
print("\n═══ DICT COMPREHENSION ═══")
squares = {x: x**2 for x in range(1, 6)}
print(f"Squares: {squares}")

# Nested dictionary
print("\n═══ NESTED DICT ═══")
students = {
    "s001": {"name": "Bob", "grade": "A"},
    "s002": {"name": "Carol", "grade": "B"},
    "s003": {"name": "Dave", "grade": "A+"}
}
for sid, info in students.items():
    print(f"  {sid}: {info['"'"'name'"'"']} - Grade: {info['"'"'grade'"'"']}")

# Merging dicts (Python 3.9+)
dict1 = {"a": 1, "b": 2}
dict2 = {"c": 3, "d": 4}
merged = {**dict1, **dict2}
print(f"\nMerged: {merged}")'
    print_code "$CODE"

    echo ""
    run_python "$CODE"

    press_continue

    # --- 5.4 Sets ---
    print_subsection "5.4 - Sets (Unique, Unordered)"

    CODE='print("═══ SETS ═══")
# Sets contain unique elements only
fruits = {"apple", "banana", "cherry", "apple"}  # duplicate removed
print(f"Fruits: {fruits}")
print(f"Length: {len(fruits)}")

# Set operations
a = {1, 2, 3, 4, 5}
b = {4, 5, 6, 7, 8}

print(f"\nA = {a}")
print(f"B = {b}")
print(f"Union (A | B):        {a | b}")
print(f"Intersection (A & B): {a & b}")
print(f"Difference (A - B):   {a - b}")
print(f"Symmetric Diff (A ^ B): {a ^ b}")

# Set methods
a.add(6)
print(f"\nAfter add(6): {a}")
a.discard(1)
print(f"After discard(1): {a}")

# Practical: Remove duplicates from list
print("\n═══ PRACTICAL: Remove Duplicates ═══")
numbers = [1, 2, 2, 3, 3, 3, 4, 4, 5]
unique = list(set(numbers))
print(f"Original: {numbers}")
print(f"Unique:   {unique}")

# Check membership (very fast in sets!)
print(f"\n3 in set: {3 in a}")
print(f"Subset: {a.issubset(b)}")'
    print_code "$CODE"

    echo ""
    run_python "$CODE"

    press_continue

    # --- Quiz ---
    print_subsection "📝 LESSON 5 QUIZ"

    quiz_question \
        "Which data structure uses key-value pairs?" \
        "List" \
        "Tuple" \
        "Dictionary" \
        "Set" \
        "C" \
        "Dictionaries store data as key:value pairs."

    quiz_question \
        "What's the difference between a list and a tuple?" \
        "Lists are faster" \
        "Tuples can be modified, lists cannot" \
        "Lists can be modified, tuples cannot" \
        "No difference" \
        "C" \
        "Lists are mutable (changeable), tuples are immutable (fixed)."

    quiz_question \
        "How do you get unique elements from a list?" \
        "list.unique()" \
        "set(list)" \
        "list.distinct()" \
        "unique(list)" \
        "B" \
        "Converting to a set automatically removes duplicates."

    press_continue
}

# ============================================
#     LESSON 6: FUNCTIONS
# ============================================

lesson_6_functions() {
    print_header
    print_section "LESSON 6: FUNCTIONS"

    echo -e "${WHITE}  Functions are reusable blocks of code!${NC}"

    # --- 6.1 Basic Functions ---
    print_subsection "6.1 - Defining & Calling Functions"

    CODE='# Basic function
def greet():
    print("Hello! 👋")

greet()
greet()

# Function with parameters
def greet_person(name):
    print(f"Hello, {name}! 👋")

greet_person("Alice")
greet_person("Bob")

# Function with return value
def add(a, b):
    return a + b

result = add(5, 3)
print(f"\n5 + 3 = {result}")

# Multiple return values
def min_max(numbers):
    return min(numbers), max(numbers)

low, high = min_max([3, 1, 7, 2, 9])
print(f"Min: {low}, Max: {high}")

# Default parameters
def power(base, exponent=2):
    return base ** exponent

print(f"\npower(3) = {power(3)}")        # Uses default exponent=2
print(f"power(3, 3) = {power(3, 3)}")    # Override exponent

# Keyword arguments
def create_profile(name, age, city="Unknown"):
    return f"{name}, {age} years old, from {city}"

print(f"\n{create_profile('"'"'Alice'"'"', 30, '"'"'NYC'"'"')}")
print(f"{create_profile(age=25, name='"'"'Bob'"'"')}")  # Named args, any order'
    print_code "$CODE"

    echo ""
    run_python "$CODE"

    press_continue

    # --- 6.2 Advanced Functions ---
    print_subsection "6.2 - Advanced Functions"

    CODE='# *args - variable number of arguments
def calculate_sum(*args):
    print(f"  Args received: {args}")
    return sum(args)

print("═══ *args ═══")
print(f"Sum: {calculate_sum(1, 2, 3)}")
print(f"Sum: {calculate_sum(10, 20, 30, 40, 50)}")

# **kwargs - variable keyword arguments
def print_info(**kwargs):
    for key, value in kwargs.items():
        print(f"  {key}: {value}")

print("\n═══ **kwargs ═══")
print_info(name="Alice", age=30, city="NYC")

# Lambda functions (anonymous functions)
print("\n═══ LAMBDA FUNCTIONS ═══")
square = lambda x: x ** 2
add = lambda a, b: a + b
print(f"square(5) = {square(5)}")
print(f"add(3, 4) = {add(3, 4)}")

# Lambda with sorted
students = [("Alice", 85), ("Bob", 92), ("Charlie", 78)]
sorted_by_grade = sorted(students, key=lambda s: s[1], reverse=True)
print(f"\nSorted by grade: {sorted_by_grade}")

# Map, Filter, Reduce
print("\n═══ MAP / FILTER / REDUCE ═══")
numbers = [1, 2, 3, 4, 5]

# Map: apply function to each element
squared = list(map(lambda x: x**2, numbers))
print(f"Squared: {squared}")

# Filter: keep elements that match condition
evens = list(filter(lambda x: x % 2 == 0, numbers))
print(f"Evens: {evens}")

# Reduce: accumulate values
from functools import reduce
total = reduce(lambda a, b: a + b, numbers)
print(f"Sum (reduce): {total}")

# Decorators (advanced)
print("\n═══ DECORATORS ═══")
def timer_decorator(func):
    import time
    def wrapper(*args, **kwargs):
        start = time.time()
        result = func(*args, **kwargs)
        end = time.time()
        print(f"  ⏱️ {func.__name__} took {end-start:.6f}s")
        return result
    return wrapper

@timer_decorator
def slow_function():
    total = sum(range(1000000))
    return total

result = slow_function()
print(f"  Result: {result}")

# Recursion
print("\n═══ RECURSION ═══")
def factorial(n):
    if n <= 1:
        return 1
    return n * factorial(n - 1)

for i in range(1, 8):
    print(f"  {i}! = {factorial(i)}")'
    print_code "$CODE"

    echo ""
    run_python "$CODE"

    press_continue

    # --- Quiz ---
    print_subsection "📝 LESSON 6 QUIZ"

    quiz_question \
        "What keyword is used to return a value from a function?" \
        "give" \
        "output" \
        "return" \
        "send" \
        "C" \
        "'return' sends a value back from a function to the caller."

    quiz_question \
        "What does *args do in a function definition?" \
        "Makes arguments required" \
        "Accepts variable number of positional arguments" \
        "Accepts keyword arguments" \
        "Creates a pointer" \
        "B" \
        "*args allows a function to accept any number of positional arguments."

    quiz_question \
        "What is a lambda function?" \
        "A named function" \
        "A class method" \
        "A small anonymous function" \
        "A recursive function" \
        "C" \
        "Lambda is a small anonymous (unnamed) function defined in one line."

    press_continue
}

# ============================================
#     LESSON 7: STRING METHODS
# ============================================

lesson_7_strings() {
    print_header
    print_section "LESSON 7: STRING METHODS & OPERATIONS"

    CODE='text = "  Hello, Python World!  "

print("═══ STRING METHODS ═══")
print(f"Original:    [{text}]")
print(f"strip():     [{text.strip()}]")
print(f"lstrip():    [{text.lstrip()}]")
print(f"rstrip():    [{text.rstrip()}]")

s = text.strip()
print(f"\nupper():     {s.upper()}")
print(f"lower():     {s.lower()}")
print(f"title():     {s.title()}")
print(f"capitalize(): {s.capitalize()}")
print(f"swapcase():  {s.swapcase()}")

print(f"\nfind(\"Python\"): {s.find('"'"'Python'"'"')}")
print(f"count(\"l\"):     {s.count('"'"'l'"'"')}")
print(f"replace:       {s.replace('"'"'World'"'"', '"'"'Termux'"'"')}")

print(f"\nstartswith(\"Hello\"): {s.startswith('"'"'Hello'"'"')}")
print(f"endswith(\"!\"):       {s.endswith('"'"'!'"'"')}")

print(f"\nisalpha (\"hello\"): {'"'"'hello'"'"'.isalpha()}")
print(f"isdigit (\"123\"):   {'"'"'123'"'"'.isdigit()}")
print(f"isalnum (\"abc123\"): {'"'"'abc123'"'"'.isalnum()}")

# Split and Join
print("\n═══ SPLIT & JOIN ═══")
sentence = "Python is awesome and powerful"
words = sentence.split()
print(f"Split: {words}")
print(f"Join with -: {'"'"'-'"'"'.join(words)}")

csv_data = "apple,banana,cherry"
items = csv_data.split(",")
print(f"CSV Split: {items}")

# String slicing
print("\n═══ STRING SLICING ═══")
s = "ABCDEFGHIJ"
print(f"String: {s}")
print(f"s[0:5]:   {s[0:5]}")
print(f"s[3:]:    {s[3:]}")
print(f"s[:4]:    {s[:4]}")
print(f"s[-3:]:   {s[-3:]}")
print(f"s[::2]:   {s[::2]}")
print(f"s[::-1]:  {s[::-1]}")

# Practical examples
print("\n═══ PRACTICAL EXAMPLES ═══")

# Check palindrome
def is_palindrome(word):
    word = word.lower().replace(" ", "")
    return word == word[::-1]

test_words = ["racecar", "hello", "madam", "A man a plan a canal Panama"]
for w in test_words:
    result = "✅ Yes" if is_palindrome(w) else "❌ No"
    print(f"  \"{w}\" palindrome? {result}")

# Count vowels
def count_vowels(text):
    return sum(1 for c in text.lower() if c in "aeiou")

print(f"\nVowels in \"Hello World\": {count_vowels('"'"'Hello World'"'"')}")

# Caesar cipher
def caesar_encrypt(text, shift):
    result = ""
    for char in text:
        if char.isalpha():
            base = ord("A") if char.isupper() else ord("a")
            result += chr((ord(char) - base + shift) % 26 + base)
        else:
            result += char
    return result

original = "Hello Python"
encrypted = caesar_encrypt(original, 3)
decrypted = caesar_encrypt(encrypted, -3)
print(f"\nOriginal:  {original}")
print(f"Encrypted: {encrypted}")
print(f"Decrypted: {decrypted}")'
    print_code "$CODE"

    echo ""
    run_python "$CODE"

    press_continue
}

# ============================================
#     LESSON 8: FILE HANDLING
# ============================================

lesson_8_files() {
    print_header
    print_section "LESSON 8: FILE HANDLING"

    CODE="import os

# Set working directory
work_dir = os.path.expanduser('~/python_lessons')
os.makedirs(work_dir, exist_ok=True)
os.chdir(work_dir)

print('═══ WRITING FILES ═══')

# Write to a file
with open('example.txt', 'w') as f:
    f.write('Hello, Termux!\\n')
    f.write('This is line 2.\\n')
    f.write('Python file handling is easy!\\n')
print('✅ File written: example.txt')

# Append to a file
with open('example.txt', 'a') as f:
    f.write('This line was appended.\\n')
    f.write('And this one too!\\n')
print('✅ Lines appended')

# Read entire file
print('\\n═══ READING FILES ═══')
with open('example.txt', 'r') as f:
    content = f.read()
print('Full content:')
print(content)

# Read line by line
print('Line by line:')
with open('example.txt', 'r') as f:
    for i, line in enumerate(f, 1):
        print(f'  Line {i}: {line.strip()}')

# Read into list
with open('example.txt', 'r') as f:
    lines = f.readlines()
print(f'\\nNumber of lines: {len(lines)}')

# Write CSV-like data
print('\\n═══ CSV-LIKE DATA ═══')
students = [
    ['Name', 'Age', 'Grade'],
    ['Alice', '20', 'A'],
    ['Bob', '22', 'B'],
    ['Charlie', '21', 'A+'],
    ['Diana', '23', 'B+']
]

with open('students.csv', 'w') as f:
    for row in students:
        f.write(','.join(row) + '\\n')
print('✅ students.csv written')

# Read and display CSV
with open('students.csv', 'r') as f:
    for line in f:
        parts = line.strip().split(',')
        print(f'  {parts[0]:10} {parts[1]:5} {parts[2]:5}')

# JSON file handling
print('\\n═══ JSON FILES ═══')
import json

data = {
    'app': 'Python Lesson',
    'version': '1.0',
    'lessons': ['basics', 'variables', 'functions'],
    'settings': {
        'theme': 'dark',
        'font_size': 14
    }
}

with open('config.json', 'w') as f:
    json.dump(data, f, indent=4)
print('✅ config.json written')

with open('config.json', 'r') as f:
    loaded = json.load(f)
print(f'Loaded: {json.dumps(loaded, indent=2)}')

# File operations
print('\\n═══ FILE OPERATIONS ═══')
print(f'File exists: {os.path.exists(\"example.txt\")}')
print(f'File size: {os.path.getsize(\"example.txt\")} bytes')
print(f'Is file: {os.path.isfile(\"example.txt\")}')
print(f'Current dir: {os.getcwd()}')
print(f'Files in dir: {os.listdir(\".\")}')"
    print_code "$CODE"

    echo ""
    run_python "$CODE"

    press_continue

    # --- Quiz ---
    print_subsection "📝 LESSON 8 QUIZ"

    quiz_question \
        "What mode opens a file for writing (overwrite)?" \
        "'r'" \
        "'w'" \
        "'a'" \
        "'x'" \
        "B" \
        "'w' mode opens for writing and overwrites existing content."

    quiz_question \
        "What does the 'with' statement do for files?" \
        "Opens files faster" \
        "Encrypts the file" \
        "Automatically closes the file when done" \
        "Compresses the file" \
        "C" \
        "'with' ensures the file is properly closed, even if errors occur."

    press_continue
}

# ============================================
#     LESSON 9: ERROR HANDLING
# ============================================

lesson_9_errors() {
    print_header
    print_section "LESSON 9: ERROR HANDLING"

    CODE='print("═══ TRY / EXCEPT ═══")

# Basic try/except
try:
    result = 10 / 0
except ZeroDivisionError:
    print("❌ Cannot divide by zero!")

# Multiple exceptions
try:
    numbers = [1, 2, 3]
    print(numbers[10])
except IndexError:
    print("❌ Index out of range!")
except TypeError:
    print("❌ Type error!")

# Catch any exception
try:
    value = int("hello")
except Exception as e:
    print(f"❌ Error: {type(e).__name__}: {e}")

# Try / Except / Else / Finally
print("\n═══ COMPLETE ERROR HANDLING ═══")
def safe_divide(a, b):
    try:
        result = a / b
    except ZeroDivisionError:
        print(f"  ❌ Cannot divide {a} by {b}")
        return None
    except TypeError as e:
        print(f"  ❌ Type error: {e}")
        return None
    else:
        print(f"  ✅ {a} / {b} = {result}")
        return result
    finally:
        print(f"  📝 Division attempted: {a} / {b}")

safe_divide(10, 3)
print()
safe_divide(10, 0)
print()
safe_divide("10", "3")

# Raising exceptions
print("\n═══ RAISING EXCEPTIONS ═══")
def validate_age(age):
    if not isinstance(age, int):
        raise TypeError("Age must be an integer")
    if age < 0:
        raise ValueError("Age cannot be negative")
    if age > 150:
        raise ValueError("Age seems unrealistic")
    return True

test_ages = [25, -5, 200, "twenty"]
for age in test_ages:
    try:
        validate_age(age)
        print(f"  ✅ Age {age} is valid")
    except (ValueError, TypeError) as e:
        print(f"  ❌ Age {repr(age)}: {e}")

# Custom exceptions
print("\n═══ CUSTOM EXCEPTIONS ═══")
class InsufficientFundsError(Exception):
    def __init__(self, balance, amount):
        self.balance = balance
        self.amount = amount
        super().__init__(
            f"Cannot withdraw ${amount}. Balance: ${balance}"
        )

class BankAccount:
    def __init__(self, balance):
        self.balance = balance

    def withdraw(self, amount):
        if amount > self.balance:
            raise InsufficientFundsError(self.balance, amount)
        self.balance -= amount
        return self.balance

account = BankAccount(100)
try:
    print(f"  Balance: ${account.balance}")
    account.withdraw(30)
    print(f"  After $30 withdrawal: ${account.balance}")
    account.withdraw(80)  # This will fail
except InsufficientFundsError as e:
    print(f"  ❌ {e}")'
    print_code "$CODE"

    echo ""
    run_python "$CODE"

    press_continue
}

# ============================================
#     LESSON 10: OOP (CLASSES)
# ============================================

lesson_10_oop() {
    print_header
    print_section "LESSON 10: OBJECT-ORIENTED PROGRAMMING"

    CODE='print("═══ CLASSES & OBJECTS ═══")

class Dog:
    # Class variable (shared by all instances)
    species = "Canis familiaris"

    # Constructor
    def __init__(self, name, breed, age):
        # Instance variables
        self.name = name
        self.breed = breed
        self.age = age
        self.tricks = []

    # Instance method
    def bark(self):
        return f"{self.name} says: Woof! 🐕"

    def learn_trick(self, trick):
        self.tricks.append(trick)
        return f"{self.name} learned: {trick}!"

    def info(self):
        tricks_str = ", ".join(self.tricks) if self.tricks else "None yet"
        return f"{self.name} ({self.breed}, {self.age}yrs) - Tricks: {tricks_str}"

    # String representation
    def __str__(self):
        return f"Dog({self.name}, {self.breed})"

    def __repr__(self):
        return f"Dog(name={self.name!r}, breed={self.breed!r}, age={self.age})"

# Create objects
dog1 = Dog("Buddy", "Golden Retriever", 3)
dog2 = Dog("Max", "German Shepherd", 5)

print(dog1.bark())
print(dog2.bark())

dog1.learn_trick("sit")
dog1.learn_trick("shake")
dog2.learn_trick("roll over")

print(f"\n{dog1.info()}")
print(f"{dog2.info()}")
print(f"\nSpecies: {Dog.species}")
print(f"str: {dog1}")
print(f"repr: {repr(dog1)}")

# ═══ INHERITANCE ═══
print("\n" + "="*50)
print("═══ INHERITANCE ═══")

class Animal:
    def __init__(self, name, sound):
        self.name = name
        self.sound = sound

    def speak(self):
        return f"{self.name} says {self.sound}!"

    def __str__(self):
        return f"{self.__class__.__name__}({self.name})"

class Cat(Animal):
    def __init__(self, name, indoor=True):
        super().__init__(name, "Meow 🐱")
        self.indoor = indoor

    def purr(self):
        return f"{self.name} is purring... 😺"

class Bird(Animal):
    def __init__(self, name, can_fly=True):
        super().__init__(name, "Tweet 🐦")
        self.can_fly = can_fly

    def fly(self):
        if self.can_fly:
            return f"{self.name} is flying! ✈️"
        return f"{self.name} cannot fly 😢"

cat = Cat("Whiskers")
bird = Bird("Tweety")
penguin = Bird("Pingu", can_fly=False)

print(cat.speak())
print(cat.purr())
print(bird.speak())
print(bird.fly())
print(penguin.fly())

# Check inheritance
print(f"\nIs cat an Animal? {isinstance(cat, Animal)}")
print(f"Is Cat subclass of Animal? {issubclass(Cat, Animal)}")

# ═══ ENCAPSULATION ═══
print("\n" + "="*50)
print("═══ ENCAPSULATION ═══")

class BankAccount:
    def __init__(self, owner, balance=0):
        self.owner = owner
        self.__balance = balance  # Private attribute

    @property
    def balance(self):
        return self.__balance

    def deposit(self, amount):
        if amount > 0:
            self.__balance += amount
            return f"✅ Deposited ${amount}. Balance: ${self.__balance}"
        return "❌ Invalid amount"

    def withdraw(self, amount):
        if 0 < amount <= self.__balance:
            self.__balance -= amount
            return f"✅ Withdrew ${amount}. Balance: ${self.__balance}"
        return "❌ Insufficient funds"

    def __str__(self):
        return f"Account({self.owner}: ${self.__balance})"

acc = BankAccount("Alice", 1000)
print(acc)
print(acc.deposit(500))
print(acc.withdraw(200))
print(acc.withdraw(2000))
print(f"Balance: ${acc.balance}")

# ═══ STATIC & CLASS METHODS ═══
print("\n" + "="*50)
print("═══ STATIC & CLASS METHODS ═══")

class MathUtils:
    PI = 3.14159

    @staticmethod
    def add(a, b):
        return a + b

    @staticmethod
    def factorial(n):
        if n <= 1: return 1
        return n * MathUtils.factorial(n - 1)

    @classmethod
    def circle_area(cls, radius):
        return cls.PI * radius ** 2

print(f"Add: {MathUtils.add(3, 5)}")
print(f"Factorial(5): {MathUtils.factorial(5)}")
print(f"Circle area(r=5): {MathUtils.circle_area(5):.2f}")'
    print_code "$CODE"

    echo ""
    run_python "$CODE"

    press_continue

    # --- Quiz ---
    print_subsection "📝 LESSON 10 QUIZ"

    quiz_question \
        "What is __init__ in a Python class?" \
        "A destructor method" \
        "A constructor method" \
        "A static method" \
        "A private variable" \
        "B" \
        "__init__ is the constructor - it initializes new objects."

    quiz_question \
        "What does 'self' refer to in a class?" \
        "The class itself" \
        "The parent class" \
        "The current instance/object" \
        "A global variable" \
        "C" \
        "'self' refers to the current instance of the class."

    press_continue
}

# ============================================
#     LESSON 11: MODULES & PACKAGES
# ============================================

lesson_11_modules() {
    print_header
    print_section "LESSON 11: MODULES & PACKAGES"

    CODE='# ═══ BUILT-IN MODULES ═══
print("═══ BUILT-IN MODULES ═══")

# os module
import os
print(f"Current directory: {os.getcwd()}")
print(f"Home directory: {os.path.expanduser(\"~\")}")
print(f"Platform: {os.name}")

# sys module
import sys
print(f"\nPython version: {sys.version}")
print(f"Platform: {sys.platform}")

# math module
import math
print(f"\nPi: {math.pi}")
print(f"E: {math.e}")
print(f"sqrt(144): {math.sqrt(144)}")
print(f"log(100): {math.log10(100)}")

# datetime module
from datetime import datetime, timedelta
now = datetime.now()
print(f"\nCurrent time: {now.strftime(\"%Y-%m-%d %H:%M:%S\")}")
print(f"Day of week: {now.strftime(\"%A\")}")
tomorrow = now + timedelta(days=1)
print(f"Tomorrow: {tomorrow.strftime(\"%Y-%m-%d\")}")

# random module
import random
print(f"\nRandom int (1-100): {random.randint(1, 100)}")
print(f"Random float (0-1): {random.random():.4f}")
print(f"Random choice: {random.choice([\"🍎\",\"🍌\",\"🍊\",\"🍇\"])}")
items = [1, 2, 3, 4, 5]
random.shuffle(items)
print(f"Shuffled: {items}")
print(f"Sample 3: {random.sample(range(1, 50), 3)}")

# string module
import string
print(f"\nLetters: {string.ascii_letters[:26]}")
print(f"Digits: {string.digits}")
print(f"Punctuation: {string.punctuation}")

# Generate random password
def generate_password(length=12):
    chars = string.ascii_letters + string.digits + "!@#$%"
    return "".join(random.choice(chars) for _ in range(length))

print(f"\nRandom password: {generate_password()}")
print(f"Random password: {generate_password(16)}")

# collections module
print("\n═══ COLLECTIONS MODULE ═══")
from collections import Counter, defaultdict, deque

# Counter
words = "the cat sat on the mat the cat".split()
word_count = Counter(words)
print(f"Word count: {word_count}")
print(f"Most common: {word_count.most_common(2)}")

# defaultdict
dd = defaultdict(list)
pairs = [("fruit", "apple"), ("fruit", "banana"), ("veg", "carrot")]
for category, item in pairs:
    dd[category].append(item)
print(f"Grouped: {dict(dd)}")

# itertools
print("\n═══ ITERTOOLS MODULE ═══")
import itertools

# Combinations
print(f"Combinations of ABC, 2: {list(itertools.combinations(\"ABC\", 2))}")
print(f"Permutations of AB: {list(itertools.permutations(\"AB\"))}")

# Chain
combined = list(itertools.chain([1,2], [3,4], [5,6]))
print(f"Chained: {combined}")'
    print_code "$CODE"

    echo ""
    run_python "$CODE"

    # --- Creating Custom Module ---
    print_subsection "Creating Your Own Module"

    echo -e "${WHITE}  Let's create and use a custom module:${NC}"
    echo ""

    # Create the module file
    cat > "$LESSON_DIR/myutils.py" << 'PYEOF'
"""My Custom Utility Module"""

def greet(name):
    """Return a greeting string."""
    return f"Hello, {name}! 🐍"

def celsius_to_fahrenheit(c):
    """Convert Celsius to Fahrenheit."""
    return (c * 9/5) + 32

def is_prime(n):
    """Check if number is prime."""
    if n < 2:
        return False
    for i in range(2, int(n**0.5) + 1):
        if n % i == 0:
            return False
    return True

PI = 3.14159265
VERSION = "1.0.0"

if __name__ == "__main__":
    print("Module running directly!")
    print(greet("Developer"))
PYEOF

    cat > "$LESSON_DIR/test_module.py" << 'PYEOF'
# Import our custom module
import myutils

print("═══ USING CUSTOM MODULE ═══")
print(myutils.greet("Termux User"))
print(f"100°C = {myutils.celsius_to_fahrenheit(100)}°F")
print(f"Is 17 prime? {myutils.is_prime(17)}")
print(f"Version: {myutils.VERSION}")

# Import specific items
from myutils import is_prime, PI

primes = [n for n in range(2, 50) if is_prime(n)]
print(f"\nPrimes under 50: {primes}")
print(f"PI = {PI}")
PYEOF

    CODE=$(cat "$LESSON_DIR/myutils.py")
    echo -e "${WHITE}  myutils.py:${NC}"
    print_code "$CODE"

    echo ""
    echo -e "${WHITE}  test_module.py:${NC}"
    CODE=$(cat "$LESSON_DIR/test_module.py")
    print_code "$CODE"

    echo ""
    echo -e "${WHITE}  Running test_module.py:${NC}"
    cd "$LESSON_DIR"
    run_python_file "test_module.py"

    press_continue
}

# ============================================
#     LESSON 12: PRACTICAL PROJECTS
# ============================================

lesson_12_projects() {
    print_header
    print_section "LESSON 12: PRACTICAL MINI-PROJECTS"

    # --- Project 1: Calculator ---
    print_subsection "Project 1: Calculator"

    cat > "$LESSON_DIR/calculator.py" << 'PYEOF'
"""Simple Calculator"""

def calculator():
    operations = {
        '+': lambda a, b: a + b,
        '-': lambda a, b: a - b,
        '*': lambda a, b: a * b,
        '/': lambda a, b: a / b if b != 0 else "Error: Division by zero!",
        '**': lambda a, b: a ** b,
        '%': lambda a, b: a % b,
    }

    print("🧮 PYTHON CALCULATOR")
    print("=" * 30)

    # Demo calculations
    demos = [
        (10, '+', 5),
        (20, '-', 8),
        (6, '*', 7),
        (100, '/', 3),
        (2, '**', 10),
        (17, '%', 5),
        (10, '/', 0),
    ]

    for a, op, b in demos:
        result = operations[op](a, b)
        print(f"  {a} {op} {b} = {result}")

calculator()
PYEOF

    echo -e "${WHITE}  Running Calculator:${NC}"
    run_python_file "$LESSON_DIR/calculator.py"

    press_continue

    # --- Project 2: To-Do List ---
    print_subsection "Project 2: To-Do List Manager"

    cat > "$LESSON_DIR/todo.py" << 'PYEOF'
"""To-Do List Manager"""
import json
import os

class TodoList:
    def __init__(self, filename="todos.json"):
        self.filename = filename
        self.todos = self._load()

    def _load(self):
        if os.path.exists(self.filename):
            with open(self.filename) as f:
                return json.load(f)
        return []

    def _save(self):
        with open(self.filename, 'w') as f:
            json.dump(self.todos, f, indent=2)

    def add(self, task):
        self.todos.append({
            "task": task,
            "done": False,
            "id": len(self.todos) + 1
        })
        self._save()
        print(f"  ✅ Added: {task}")

    def complete(self, task_id):
        for todo in self.todos:
            if todo["id"] == task_id:
                todo["done"] = True
                self._save()
                print(f"  ✅ Completed: {todo['task']}")
                return
        print(f"  ❌ Task {task_id} not found!")

    def delete(self, task_id):
        self.todos = [t for t in self.todos if t["id"] != task_id]
        self._save()
        print(f"  🗑️ Deleted task {task_id}")

    def display(self):
        if not self.todos:
            print("  📝 No tasks yet!")
            return
        print("  ┌────────────────────────────────────┐")
        print("  │        📋 TO-DO LIST               │")
        print("  ├────────────────────────────────────┤")
        for t in self.todos:
            status = "✅" if t["done"] else "⬜"
            print(f"  │ {status} [{t['id']}] {t['task']:<24}│")
        print("  └────────────────────────────────────┘")
        done = sum(1 for t in self.todos if t["done"])
        print(f"  Progress: {done}/{len(self.todos)} tasks complete")

# Demo
print("📝 TO-DO LIST DEMO")
print("=" * 40)

todo = TodoList(os.path.expanduser("~/python_lessons/todos.json"))

# Clear previous demo data
todo.todos = []

todo.add("Learn Python basics")
todo.add("Practice loops")
todo.add("Build a project")
todo.add("Study OOP")
todo.add("Read documentation")

print()
todo.complete(1)
todo.complete(2)
print()
todo.display()
PYEOF

    echo -e "${WHITE}  Running To-Do List:${NC}"
    run_python_file "$LESSON_DIR/todo.py"

    press_continue

    # --- Project 3: Number Guessing Game ---
    print_subsection "Project 3: Number Guessing Game (AI Demo)"

    cat > "$LESSON_DIR/guess_game.py" << 'PYEOF'
"""Number Guessing Game - AI Player Demo"""
import random

def ai_guess_game():
    print("🎮 NUMBER GUESSING GAME")
    print("=" * 40)
    print("Computer picks a number, AI guesses it!")
    print()

    secret = random.randint(1, 100)
    low, high = 1, 100
    attempts = 0

    print(f"Secret number: {secret} (shhh!)")
    print(f"Range: {low} to {high}")
    print("-" * 40)

    while low <= high:
        attempts += 1
        guess = (low + high) // 2  # Binary search!

        if guess == secret:
            print(f"  Attempt {attempts}: AI guesses {guess} → 🎉 CORRECT!")
            break
        elif guess < secret:
            print(f"  Attempt {attempts}: AI guesses {guess} → Too LOW ⬆️")
            low = guess + 1
        else:
            print(f"  Attempt {attempts}: AI guesses {guess} → Too HIGH ⬇️")
            high = guess - 1

    print(f"\n🏆 AI found {secret} in {attempts} attempts!")
    print(f"📊 Max attempts needed for 1-100: {100 .bit_length()} (binary search)")

ai_guess_game()
print()

# Play 5 rounds
print("═══ 5 ROUND STATISTICS ═══")
total_attempts = 0
for game in range(1, 6):
    secret = random.randint(1, 100)
    low, high = 1, 100
    attempts = 0
    while low <= high:
        attempts += 1
        guess = (low + high) // 2
        if guess == secret: break
        elif guess < secret: low = guess + 1
        else: high = guess - 1
    total_attempts += attempts
    print(f"  Game {game}: Secret={secret:3d}, Attempts={attempts}")

print(f"\n  Average attempts: {total_attempts/5:.1f}")
PYEOF

    echo -e "${WHITE}  Running Guessing Game:${NC}"
    run_python_file "$LESSON_DIR/guess_game.py"

    press_continue

    # --- Project 4: Contact Book ---
    print_subsection "Project 4: Contact Book"

    cat > "$LESSON_DIR/contacts.py" << 'PYEOF'
"""Contact Book with Search"""
import json

class ContactBook:
    def __init__(self):
        self.contacts = {}

    def add(self, name, phone, email=""):
        self.contacts[name.lower()] = {
            "name": name,
            "phone": phone,
            "email": email
        }
        return f"✅ Added {name}"

    def search(self, query):
        results = []
        query = query.lower()
        for key, contact in self.contacts.items():
            if query in key or query in contact["phone"]:
                results.append(contact)
        return results

    def display_all(self):
        if not self.contacts:
            print("  📱 No contacts yet!")
            return
        print("  ┌─────────────────────────────────────────────┐")
        print("  │            📱 CONTACT BOOK                  │")
        print("  ├──────────────┬────────────┬─────────────────┤")
        print("  │ Name         │ Phone      │ Email           │")
        print("  ├──────────────┼────────────┼─────────────────┤")
        for c in self.contacts.values():
            name = c["name"][:12]
            phone = c["phone"][:10]
            email = c["email"][:15] if c["email"] else "N/A"
            print(f"  │ {name:<12} │ {phone:<10} │ {email:<15} │")
        print("  └──────────────┴────────────┴─────────────────┘")

# Demo
book = ContactBook()
print(book.add("Alice Johnson", "555-0101", "alice@mail.com"))
print(book.add("Bob Smith", "555-0102", "bob@mail.com"))
print(book.add("Charlie Brown", "555-0103", "charlie@mail.com"))
print(book.add("Diana Prince", "555-0104", "diana@mail.com"))
print(book.add("Eve Wilson", "555-0105"))

print()
book.display_all()

print("\n  🔍 Search for 'ali':")
results = book.search("ali")
for r in results:
    print(f"    Found: {r['name']} - {r['phone']}")

print("\n  🔍 Search for '0103':")
results = book.search("0103")
for r in results:
    print(f"    Found: {r['name']} - {r['phone']}")
PYEOF

    echo -e "${WHITE}  Running Contact Book:${NC}"
    run_python_file "$LESSON_DIR/contacts.py"

    press_continue

    # --- Project 5: Text Analyzer ---
    print_subsection "Project 5: Text Analyzer"

    cat > "$LESSON_DIR/text_analyzer.py" << 'PYEOF'
"""Text Analyzer Tool"""
from collections import Counter
import string

def analyze_text(text):
    print("📊 TEXT ANALYSIS REPORT")
    print("=" * 50)

    # Basic stats
    chars = len(text)
    chars_no_space = len(text.replace(" ", ""))
    words = text.split()
    word_count = len(words)
    sentences = text.count('.') + text.count('!') + text.count('?')
    paragraphs = text.count('\n') + 1

    print(f"\n📏 BASIC STATISTICS:")
    print(f"  Characters (with spaces):    {chars}")
    print(f"  Characters (without spaces): {chars_no_space}")
    print(f"  Words:                       {word_count}")
    print(f"  Sentences:                   {sentences}")
    print(f"  Paragraphs:                  {paragraphs}")

    if word_count > 0:
        avg_word_len = sum(len(w.strip(string.punctuation)) for w in words) / word_count
        print(f"  Average word length:         {avg_word_len:.1f}")

    if sentences > 0:
        print(f"  Average words/sentence:      {word_count/sentences:.1f}")

    # Word frequency
    clean_words = [w.strip(string.punctuation).lower() for w in words if w.strip(string.punctuation)]
    word_freq = Counter(clean_words)

    print(f"\n📈 TOP 10 WORDS:")
    for word, count in word_freq.most_common(10):
        bar = "█" * count
        print(f"  {word:15} {count:3} {bar}")

    # Letter frequency
    letters = [c.lower() for c in text if c.isalpha()]
    letter_freq = Counter(letters)

    print(f"\n🔤 TOP 10 LETTERS:")
    for letter, count in letter_freq.most_common(10):
        pct = count / len(letters) * 100 if letters else 0
        bar = "█" * int(pct)
        print(f"  {letter}: {count:4} ({pct:5.1f}%) {bar}")

    # Readability
    if sentences > 0 and word_count > 0:
        syllables = sum(max(1, sum(1 for c in w if c in 'aeiou')) for w in clean_words)
        # Simplified Flesch Reading Ease
        fre = 206.835 - 1.015 * (word_count / sentences) - 84.6 * (syllables / word_count)
        print(f"\n📖 READABILITY:")
        print(f"  Flesch Reading Ease: {fre:.1f}")
        if fre >= 80: level = "Easy (6th grade)"
        elif fre >= 60: level = "Standard (8th-9th grade)"
        elif fre >= 40: level = "Difficult (college)"
        else: level = "Very difficult (professional)"
        print(f"  Level: {level}")

# Sample text
sample = """Python is an amazing programming language. It is easy to learn and powerful to use.
Python was created by Guido van Rossum. Python is used for web development, data science, and automation.
Many developers love Python because of its simple syntax. Python is one of the most popular languages today.
You can build websites, games, and even artificial intelligence with Python. Learning Python is a great investment."""

analyze_text(sample)
PYEOF

    echo -e "${WHITE}  Running Text Analyzer:${NC}"
    run_python_file "$LESSON_DIR/text_analyzer.py"

    press_continue
}

# ============================================
#     LESSON 13: ADVANCED TOPICS
# ============================================

lesson_13_advanced() {
    print_header
    print_section "LESSON 13: ADVANCED TOPICS"

    # --- 13.1 Generators ---
    print_subsection "13.1 - Generators"

    CODE='print("═══ GENERATORS ═══")

# Generator function
def countdown(n):
    while n > 0:
        yield n
        n -= 1

print("Countdown:")
for num in countdown(5):
    print(f"  {num}...", end="")
print(" 🚀 Go!")

# Generator expression
squares_gen = (x**2 for x in range(10))
print(f"\nGenerator: {squares_gen}")
print(f"As list: {list(squares_gen)}")

# Infinite generator
def fibonacci():
    a, b = 0, 1
    while True:
        yield a
        a, b = b, a + b

fib = fibonacci()
print(f"\nFirst 15 Fibonacci:")
print(f"  {[next(fib) for _ in range(15)]}")

# Generator for large data (memory efficient)
def read_large_data(n):
    """Simulate reading large dataset"""
    for i in range(n):
        yield {"id": i, "value": i * 2}

# Only processes one item at a time!
total = sum(item["value"] for item in read_large_data(1000))
print(f"\nSum of 1000 items: {total}")'
    print_code "$CODE"

    echo ""
    run_python "$CODE"

    press_continue

    # --- 13.2 Decorators & Context Managers ---
    print_subsection "13.2 - Decorators & Context Managers"

    CODE='import time
from functools import wraps

print("═══ DECORATORS ═══")

# Timer decorator
def timer(func):
    @wraps(func)
    def wrapper(*args, **kwargs):
        start = time.time()
        result = func(*args, **kwargs)
        elapsed = time.time() - start
        print(f"  ⏱️  {func.__name__}: {elapsed:.4f}s")
        return result
    return wrapper

# Cache/Memoize decorator
def memoize(func):
    cache = {}
    @wraps(func)
    def wrapper(*args):
        if args not in cache:
            cache[args] = func(*args)
        return cache[args]
    return wrapper

# Retry decorator
def retry(max_attempts=3):
    def decorator(func):
        @wraps(func)
        def wrapper(*args, **kwargs):
            for attempt in range(1, max_attempts + 1):
                try:
                    return func(*args, **kwargs)
                except Exception as e:
                    print(f"  Attempt {attempt} failed: {e}")
                    if attempt == max_attempts:
                        raise
        return wrapper
    return decorator

@timer
def slow_sum(n):
    return sum(range(n))

@memoize
@timer
def fibonacci(n):
    if n < 2: return n
    return fibonacci(n-1) + fibonacci(n-2)

result = slow_sum(1_000_000)
print(f"  Sum: {result}")
print()

# Fibonacci with memoization
result = fibonacci(30)
print(f"  Fibonacci(30): {result}")

# Context Manager
print("\n═══ CONTEXT MANAGERS ═══")

class Timer:
    def __enter__(self):
        self.start = time.time()
        return self

    def __exit__(self, *args):
        self.elapsed = time.time() - self.start
        print(f"  ⏱️  Block took: {self.elapsed:.4f}s")

with Timer():
    total = sum(x**2 for x in range(100000))
    print(f"  Sum of squares: {total}")

# Context manager with contextlib
from contextlib import contextmanager

@contextmanager
def section(title):
    print(f"\n  ┌── {title} ──")
    yield
    print(f"  └── End {title} ──")

with section("My Section"):
    print("  │ Doing some work...")
    print("  │ More work...")'
    print_code "$CODE"

    echo ""
    run_python "$CODE"

    press_continue

    # --- 13.3 List/Dict Comprehensions Advanced ---
    print_subsection "13.3 - Advanced Comprehensions"

    CODE='print("═══ ADVANCED COMPREHENSIONS ═══")

# Nested comprehension - flatten
matrix = [[1, 2, 3], [4, 5, 6], [7, 8, 9]]
flat = [num for row in matrix for num in row]
print(f"Flattened: {flat}")

# Conditional comprehension
data = [1, -2, 3, -4, 5, -6, 7]
positives = [x for x in data if x > 0]
transformed = [x if x > 0 else 0 for x in data]
print(f"Positives only: {positives}")
print(f"Replace negatives: {transformed}")

# Dict comprehension
words = ["hello", "world", "python", "code"]
word_lengths = {w: len(w) for w in words}
print(f"\nWord lengths: {word_lengths}")

# Invert a dictionary
original = {"a": 1, "b": 2, "c": 3}
inverted = {v: k for k, v in original.items()}
print(f"Inverted: {inverted}")

# Set comprehension
nums = [1, 1, 2, 2, 3, 3, 4, 4, 5]
unique_squares = {x**2 for x in nums}
print(f"\nUnique squares: {unique_squares}")

# Walrus operator (Python 3.8+) :=
import sys
if sys.version_info >= (3, 8):
    # Filter and transform in one pass
    results = [y for x in range(10) if (y := x**2) > 20]
    print(f"Squares > 20: {results}")

# Complex example: Word analysis
text = "the quick brown fox jumps over the lazy dog the fox"
word_stats = {
    word: {"count": text.split().count(word), "length": len(word)}
    for word in set(text.split())
}
print(f"\nWord stats:")
for word, stats in sorted(word_stats.items()):
    print(f"  {word:6} → count: {stats['"'"'count'"'"']}, length: {stats['"'"'length'"'"']}")'
    print_code "$CODE"

    echo ""
    run_python "$CODE"

    press_continue
}

# ============================================
#     LESSON 14: PIP & EXTERNAL PACKAGES
# ============================================

lesson_14_pip() {
    print_header
    print_section "LESSON 14: PIP & EXTERNAL PACKAGES"

    echo -e "${WHITE}  pip is Python's package installer. Let's learn to use it!${NC}"
    echo ""

    echo -e "${BLUE}  Common pip commands:${NC}"
    echo -e "${YELLOW}  pip install package_name      ${NC}# Install a package"
    echo -e "${YELLOW}  pip install package==1.0.0     ${NC}# Install specific version"
    echo -e "${YELLOW}  pip uninstall package_name     ${NC}# Remove a package"
    echo -e "${YELLOW}  pip list                       ${NC}# List installed packages"
    echo -e "${YELLOW}  pip show package_name          ${NC}# Package details"
    echo -e "${YELLOW}  pip freeze > requirements.txt  ${NC}# Save requirements"
    echo -e "${YELLOW}  pip install -r requirements.txt${NC}# Install from file"
    echo ""

    echo -e "${BLUE}  Popular packages for Termux:${NC}"
    echo -e "${WHITE}  • requests  - HTTP requests (API calls)${NC}"
    echo -e "${WHITE}  • flask     - Web framework${NC}"
    echo -e "${WHITE}  • numpy    - Numerical computing${NC}"
    echo -e "${WHITE}  • beautifulsoup4 - Web scraping${NC}"
    echo -e "${WHITE}  • rich     - Beautiful terminal output${NC}"
    echo -e "${WHITE}  • click    - CLI tools${NC}"
    echo ""

    echo -e "${CYAN}  Installing 'requests' package as example...${NC}"
    pip install requests > /dev/null 2>&1

    CODE='# Using the requests library
import requests

print("═══ HTTP REQUESTS WITH requests ═══")

# GET request
try:
    response = requests.get("https://httpbin.org/get", timeout=10)
    print(f"Status Code: {response.status_code}")
    print(f"Content Type: {response.headers.get(\"content-type\")}")

    # JSON API example
    response = requests.get("https://api.github.com", timeout=10)
    data = response.json()
    print(f"\nGitHub API Status: {response.status_code}")
    print(f"Keys: {list(data.keys())[:5]}...")
    print("✅ API request successful!")

except requests.exceptions.ConnectionError:
    print("⚠️ No internet connection (offline mode)")
    print("The requests library would normally fetch data from APIs")

except Exception as e:
    print(f"⚠️ {e}")

print("\n═══ EXAMPLE: API DATA PROCESSING ═══")
# Even without internet, showing the pattern:
sample_data = [
    {"name": "Python", "stars": 50000},
    {"name": "JavaScript", "stars": 45000},
    {"name": "Rust", "stars": 35000},
    {"name": "Go", "stars": 30000},
]

print("Top Languages (sample data):")
for i, lang in enumerate(sample_data, 1):
    bar = "★" * (lang["stars"] // 10000)
    print(f"  {i}. {lang[\"name\"]:12} {lang[\"stars\"]:>6} {bar}")'
    print_code "$CODE"

    echo ""
    run_python "$CODE"

    press_continue
}

# ============================================
#    LESSON 15: BEST PRACTICES & TIPS
# ============================================

lesson_15_best_practices() {
    print_header
    print_section "LESSON 15: BEST PRACTICES & TIPS"

    CODE='# ═══ PYTHON BEST PRACTICES ═══

# 1. Use meaningful variable names
# ❌ Bad
x = 25
# ✅ Good
user_age = 25

# 2. Follow PEP 8 (Python Style Guide)
# - Use 4 spaces for indentation
# - Max line length: 79 characters
# - snake_case for functions/variables
# - PascalCase for classes
# - UPPER_CASE for constants

MAX_RETRIES = 3

class UserProfile:
    def __init__(self, first_name, last_name):
        self.first_name = first_name
        self.last_name = last_name

    def get_full_name(self):
        return f"{self.first_name} {self.last_name}"

# 3. Use docstrings
def calculate_bmi(weight_kg, height_m):
    """
    Calculate Body Mass Index.

    Args:
        weight_kg (float): Weight in kilograms.
        height_m (float): Height in meters.

    Returns:
        float: The BMI value.
    """
    return weight_kg / (height_m ** 2)

# 4. Use type hints (Python 3.5+)
def greet(name: str, times: int = 1) -> str:
    return (f"Hello, {name}! " * times).strip()

# 5. Use context managers for resources
# ✅ Good - auto-closes file
# with open("file.txt") as f:
#     data = f.read()

# 6. Use enumerate instead of range(len())
fruits = ["apple", "banana", "cherry"]
# ❌ Bad
# for i in range(len(fruits)):
#     print(i, fruits[i])
# ✅ Good
for i, fruit in enumerate(fruits):
    print(f"  {i}: {fruit}")

# 7. Use f-strings (Python 3.6+)
name = "World"
# ❌ Old: "Hello, " + name + "!"
# ✅ New:
print(f"  Hello, {name}!")

# 8. List comprehensions over loops
numbers = [1, 2, 3, 4, 5]
# ❌ Verbose
squares = []
for n in numbers:
    squares.append(n ** 2)
# ✅ Pythonic
squares = [n ** 2 for n in numbers]
print(f"  Squares: {squares}")

# 9. Use unpacking
# ❌ Bad
# first = coordinates[0]
# second = coordinates[1]
# ✅ Good
first, second = 10, 20
a, *rest, z = [1, 2, 3, 4, 5]
print(f"  a={a}, rest={rest}, z={z}")

# 10. EAFP vs LBYL
# LBYL (Look Before You Leap) - ❌
# if key in dictionary:
#     value = dictionary[key]
# EAFP (Easier to Ask Forgiveness) - ✅ Pythonic
d = {"key": "value"}
try:
    value = d["missing"]
except KeyError:
    value = "default"
print(f"  Value: {value}")

# Or simply:
value = d.get("missing", "default")
print(f"  Value: {value}")

print("\n✅ Following these practices makes your code:")
print("  📖 More readable")
print("  🐛 Easier to debug")
print("  🤝 Better for collaboration")
print("  🚀 More professional")'
    print_code "$CODE"

    echo ""
    run_python "$CODE"

    press_continue
}

# ============================================
#          FINAL SCORE & SUMMARY
# ============================================

show_final_score() {
    print_header
    print_section "🏆 FINAL RESULTS"

    echo -e "${WHITE}  ╔════════════════════════════════════════════════╗${NC}"
    echo -e "${WHITE}  ║          YOUR QUIZ RESULTS                    ║${NC}"
    echo -e "${WHITE}  ╠════════════════════════════════════════════════╣${NC}"
    echo -e "${WHITE}  ║                                                ║${NC}"

    if [ $TOTAL_QUESTIONS -gt 0 ]; then
        PERCENTAGE=$((SCORE * 100 / TOTAL_QUESTIONS))
        echo -e "${WHITE}  ║  Score: ${GREEN}$SCORE / $TOTAL_QUESTIONS${WHITE} ($PERCENTAGE%)                     ║${NC}"
    else
        PERCENTAGE=0
        echo -e "${WHITE}  ║  No quizzes taken                              ║${NC}"
    fi

    echo -e "${WHITE}  ║                                                ║${NC}"

    if [ $PERCENTAGE -ge 90 ]; then
        echo -e "${WHITE}  ║  Grade: ${GREEN}A+ - EXCELLENT! 🌟🌟🌟${WHITE}                ║${NC}"
        echo -e "${WHITE}  ║  You're a Python natural!                      ║${NC}"
    elif [ $PERCENTAGE -ge 80 ]; then
        echo -e "${WHITE}  ║  Grade: ${GREEN}A - GREAT JOB! 🌟🌟${WHITE}                   ║${NC}"
        echo -e "${WHITE}  ║  Very strong understanding!                    ║${NC}"
    elif [ $PERCENTAGE -ge 70 ]; then
        echo -e "${WHITE}  ║  Grade: ${YELLOW}B - GOOD! 🌟${WHITE}                          ║${NC}"
        echo -e "${WHITE}  ║  Keep practicing!                              ║${NC}"
    elif [ $PERCENTAGE -ge 60 ]; then
        echo -e "${WHITE}  ║  Grade: ${YELLOW}C - FAIR${WHITE}                               ║${NC}"
        echo -e "${WHITE}  ║  Review the lessons again.                     ║${NC}"
    else
        echo -e "${WHITE}  ║  Grade: ${RED}D - NEEDS IMPROVEMENT${WHITE}                 ║${NC}"
        echo -e "${WHITE}  ║  Don't give up! Practice more!                 ║${NC}"
    fi

    echo -e "${WHITE}  ║                                                ║${NC}"
    echo -e "${WHITE}  ╚════════════════════════════════════════════════╝${NC}"
    echo ""

    echo -e "${CYAN}  📁 Lesson files saved in: $LESSON_DIR${NC}"
    echo -e "${CYAN}  📄 Files created:${NC}"
    if [ -d "$LESSON_DIR" ]; then
        ls -la "$LESSON_DIR"/*.py "$LESSON_DIR"/*.json "$LESSON_DIR"/*.csv "$LESSON_DIR"/*.txt 2>/dev/null | while read -r line; do
            echo -e "${WHITE}     $line${NC}"
        done
    fi

    echo ""
    echo -e "${GREEN}  ════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}  🎓 CONGRATULATIONS ON COMPLETING THE COURSE! 🎓${NC}"
    echo -e "${GREEN}  ════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "${WHITE}  Next steps:${NC}"
    echo -e "${WHITE}  1. 📝 Practice with the project files${NC}"
    echo -e "${WHITE}  2. 📚 Read Python documentation: docs.python.org${NC}"
    echo -e "${WHITE}  3. 🏗️  Build your own projects${NC}"
    echo -e "${WHITE}  4. 🌐 Explore web frameworks (Flask, Django)${NC}"
    echo -e "${WHITE}  5. 📊 Try data science (pandas, matplotlib)${NC}"
    echo ""
}

# ============================================
#          INTERACTIVE PRACTICE
# ============================================

interactive_practice() {
    print_header
    print_section "INTERACTIVE PRACTICE MODE"

    echo -e "${WHITE}  Write and run Python code directly!${NC}"
    echo -e "${WHITE}  Type 'exit' to return to menu.${NC}"
    echo -e "${WHITE}  Type 'example' for sample code.${NC}"
    echo ""

    while true; do
        echo -ne "${GREEN}python>>> ${NC}"
        read -r user_input

        if [ "$user_input" = "exit" ] || [ "$user_input" = "quit" ]; then
            break
        fi

        if [ "$user_input" = "example" ]; then
            echo -e "${YELLOW}  Try these:${NC}"
            echo -e "${YELLOW}  print('Hello from Termux!')${NC}"
            echo -e "${YELLOW}  print(2 ** 10)${NC}"
            echo -e "${YELLOW}  print([x**2 for x in range(10)])${NC}"
            echo -e "${YELLOW}  import this${NC}"
            continue
        fi

        if [ -n "$user_input" ]; then
            python3 -c "$user_input" 2>&1 | while IFS= read -r line; do
                echo -e "${WHITE}  $line${NC}"
            done
        fi
    done
}

# ============================================
#             CHEAT SHEET
# ============================================

show_cheatsheet() {
    print_header
    print_section "PYTHON CHEAT SHEET"

    cat << 'CHEAT'

  ╔══════════════════════════════════════════════════════╗
  ║              PYTHON QUICK REFERENCE                  ║
  ╠══════════════════════════════════════════════════════╣
  ║                                                      ║
  ║  DATA TYPES:                                         ║
  ║    str    "hello"         int    42                   ║
  ║    float  3.14            bool   True/False           ║
  ║    list   [1,2,3]         tuple  (1,2,3)              ║
  ║    dict   {"a":1}         set    {1,2,3}              ║
  ║                                                      ║
  ║  OPERATORS:                                          ║
  ║    +  -  *  /  //  %  **                             ║
  ║    ==  !=  >  <  >=  <=                              ║
  ║    and  or  not  in  is                              ║
  ║                                                      ║
  ║  CONTROL FLOW:                                       ║
  ║    if/elif/else  for  while                          ║
  ║    break  continue  pass                             ║
  ║                                                      ║
  ║  FUNCTIONS:                                          ║
  ║    def func(arg):     lambda x: x*2                  ║
  ║    return value       *args  **kwargs                ║
  ║                                                      ║
  ║  STRINGS:                                            ║
  ║    .upper() .lower() .strip() .split()               ║
  ║    .replace() .find() .count() .join()               ║
  ║    f"text {var}" .startswith() .endswith()            ║
  ║                                                      ║
  ║  LISTS:                                              ║
  ║    .append() .insert() .remove() .pop()              ║
  ║    .sort() .reverse() .index() .count()              ║
  ║    len() sum() min() max() sorted()                  ║
  ║                                                      ║
  ║  DICT:                                               ║
  ║    .keys() .values() .items() .get()                 ║
  ║    .update() .pop() .setdefault()                    ║
  ║                                                      ║
  ║  FILES:                                              ║
  ║    open("f","r/w/a")  .read()  .write()              ║
  ║    .readlines()  with open() as f:                   ║
  ║                                                      ║
  ║  ERRORS:                                             ║
  ║    try/except/else/finally  raise                    ║
  ║                                                      ║
  ║  CLASSES:                                            ║
  ║    class Name:  __init__(self)  self.attr            ║
  ║    inheritance  @property  @staticmethod             ║
  ║                                                      ║
  ║  USEFUL MODULES:                                     ║
  ║    os  sys  math  random  datetime  json             ║
  ║    collections  itertools  functools  re             ║
  ║                                                      ║
  ║  TERMUX TIPS:                                        ║
  ║    python3 script.py    # Run script                 ║
  ║    python3 -i script.py # Interactive after run      ║
  ║    python3 -c "code"    # Run one-liner              ║
  ║    pip install pkg      # Install package            ║
  ║                                                      ║
  ╚══════════════════════════════════════════════════════╝
CHEAT

    press_continue
}

# ============================================
#              MAIN MENU
# ============================================

main_menu() {
    while true; do
        print_header

        echo -e "${WHITE}  ┌──────────────────────────────────────────────┐${NC}"
        echo -e "${WHITE}  │             📚 LESSON MENU                   │${NC}"
        echo -e "${WHITE}  ├──────────────────────────────────────────────┤${NC}"
        echo -e "${WHITE}  │                                              │${NC}"
        echo -e "${WHITE}  │  ${CYAN} 0)${WHITE} 🔧 Setup & Installation                 │${NC}"
        echo -e "${WHITE}  │  ${CYAN} 1)${WHITE} 📖 Lesson 1: Python Basics               │${NC}"
        echo -e "${WHITE}  │  ${CYAN} 2)${WHITE} 📖 Lesson 2: Variables & Data Types       │${NC}"
        echo -e "${WHITE}  │  ${CYAN} 3)${WHITE} 📖 Lesson 3: Operators                    │${NC}"
        echo -e "${WHITE}  │  ${CYAN} 4)${WHITE} 📖 Lesson 4: Control Flow                 │${NC}"
        echo -e "${WHITE}  │  ${CYAN} 5)${WHITE} 📖 Lesson 5: Data Structures              │${NC}"
        echo -e "${WHITE}  │  ${CYAN} 6)${WHITE} 📖 Lesson 6: Functions                    │${NC}"
        echo -e "${WHITE}  │  ${CYAN} 7)${WHITE} 📖 Lesson 7: String Methods               │${NC}"
        echo -e "${WHITE}  │  ${CYAN} 8)${WHITE} 📖 Lesson 8: File Handling                 │${NC}"
        echo -e "${WHITE}  │  ${CYAN} 9)${WHITE} 📖 Lesson 9: Error Handling                │${NC}"
        echo -e "${WHITE}  │  ${CYAN}10)${WHITE} 📖 Lesson 10: OOP (Classes)               │${NC}"
        echo -e "${WHITE}  │  ${CYAN}11)${WHITE} 📖 Lesson 11: Modules & Packages          │${NC}"
        echo -e "${WHITE}  │  ${CYAN}12)${WHITE} 🏗️  Lesson 12: Practical Projects          │${NC}"
        echo -e "${WHITE}  │  ${CYAN}13)${WHITE} 🚀 Lesson 13: Advanced Topics             │${NC}"
        echo -e "${WHITE}  │  ${CYAN}14)${WHITE} 📦 Lesson 14: Pip & Packages              │${NC}"
        echo -e "${WHITE}  │  ${CYAN}15)${WHITE} ✨ Lesson 15: Best Practices              │${NC}"
        echo -e "${WHITE}  │                                              │${NC}"
        echo -e "${WHITE}  │  ${GREEN} A)${WHITE} 🎯 Run ALL Lessons (Full Course)         │${NC}"
        echo -e "${WHITE}  │  ${GREEN} P)${WHITE} 💻 Interactive Practice Mode             │${NC}"
        echo -e "${WHITE}  │  ${GREEN} C)${WHITE} 📋 Cheat Sheet                           │${NC}"
        echo -e "${WHITE}  │  ${GREEN} S)${WHITE} 🏆 Show Score                            │${NC}"
        echo -e "${WHITE}  │  ${RED} Q)${WHITE} 🚪 Quit                                  │${NC}"
        echo -e "${WHITE}  │                                              │${NC}"
        echo -e "${WHITE}  └──────────────────────────────────────────────┘${NC}"
        echo ""

        if [ $TOTAL_QUESTIONS -gt 0 ]; then
            echo -e "${YELLOW}  Current Score: $SCORE/$TOTAL_QUESTIONS${NC}"
        fi

        echo -ne "${WHITE}  Enter your choice: ${NC}"
        read -r choice

        case $choice in
            0)  setup_environment ;;
            1)  lesson_1_basics ;;
            2)  lesson_2_variables ;;
            3)  lesson_3_operators ;;
            4)  lesson_4_control_flow ;;
            5)  lesson_5_data_structures ;;
            6)  lesson_6_functions ;;
            7)  lesson_7_strings ;;
            8)  lesson_8_files ;;
            9)  lesson_9_errors ;;
            10) lesson_10_oop ;;
            11) lesson_11_modules ;;
            12) lesson_12_projects ;;
            13) lesson_13_advanced ;;
            14) lesson_14_pip ;;
            15) lesson_15_best_practices ;;
            [aA])
                setup_environment
                lesson_1_basics
                lesson_2_variables
                lesson_3_operators
                lesson_4_control_flow
                lesson_5_data_structures
                lesson_6_functions
                lesson_7_strings
                lesson_8_files
                lesson_9_errors
                lesson_10_oop
                lesson_11_modules
                lesson_12_projects
                lesson_13_advanced
                lesson_14_pip
                lesson_15_best_practices
                show_final_score
                press_continue
                ;;
            [pP]) interactive_practice ;;
            [cC]) show_cheatsheet ;;
            [sS]) show_final_score; press_continue ;;
            [qQ])
                echo ""
                if [ $TOTAL_QUESTIONS -gt 0 ]; then
                    show_final_score
                fi
                echo -e "${GREEN}  Thank you for learning Python! 🐍${NC}"
                echo -e "${GREEN}  Happy coding! 🚀${NC}"
                echo ""
                exit 0
                ;;
            *)
                echo -e "${RED}  Invalid choice. Please try again.${NC}"
                sleep 1
                ;;
        esac
    done
}

# ============================================
#             START THE PROGRAM
# ============================================

# Check if running in Termux or regular terminal
if [ -d "/data/data/com.termux" ]; then
    SHELL_PATH="/data/data/com.termux/files/usr/bin/bash"
else
    SHELL_PATH="/bin/bash"
fi

# Ensure Python3 is available
if ! command -v python3 &> /dev/null; then
    echo -e "${RED}Python3 not found! Installing...${NC}"
    if command -v pkg &> /dev/null; then
        pkg install python -y
    elif command -v apt &> /dev/null; then
        sudo apt install python3 -y
    else
        echo "Please install Python3 manually."
        exit 1
    fi
fi

# Start the lesson
main_menu
