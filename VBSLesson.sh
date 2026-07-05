#!/data/data/com.termux/files/usr/bin/bash

# ============================================
#   VBScript Course in Termux (.sh)
#   Run with: bash VBSLesson.sh
# ============================================

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
WHITE='\033[1;37m'
RESET='\033[0m'

# ============================================
# FUNCTIONS
# ============================================

clear_screen() {
    clear
}

print_header() {
    echo -e "${CYAN}============================================${RESET}"
    echo -e "${WHITE}       VBScript Complete Course            ${RESET}"
    echo -e "${CYAN}============================================${RESET}"
    echo ""
}

print_topic() {
    echo -e "${YELLOW}>>> $1 ${RESET}"
    echo -e "${CYAN}--------------------------------------------${RESET}"
}

print_code() {
    echo -e "${GREEN}[CODE]${RESET}"
    echo -e "${WHITE}$1${RESET}"
    echo ""
}

print_output() {
    echo -e "${MAGENTA}[OUTPUT]${RESET}"
    echo -e "$1"
    echo ""
}

print_note() {
    echo -e "${BLUE}[NOTE] $1${RESET}"
    echo ""
}

wait_key() {
    echo -e "${YELLOW}Press [ENTER] to continue...${RESET}"
    read -r
}

# ============================================
# LESSONS
# ============================================

lesson_1() {
    clear_screen
    print_header
    print_topic "LESSON 1: Introduction to VBScript"
    echo -e "${WHITE}VBScript (Visual Basic Scripting Edition) is a${RESET}"
    echo -e "${WHITE}scripting language developed by Microsoft.${RESET}"
    echo ""
    echo -e "${WHITE}Key Features:${RESET}"
    echo -e "  ${GREEN}✔${RESET} Lightweight scripting language"
    echo -e "  ${GREEN}✔${RESET} Based on Visual Basic"
    echo -e "  ${GREEN}✔${RESET} Used in Windows Script Host (WSH)"
    echo -e "  ${GREEN}✔${RESET} Used in ASP (Active Server Pages)"
    echo -e "  ${GREEN}✔${RESET} Used in Internet Explorer"
    echo ""
    print_note "VBScript files use .vbs extension on Windows"
    echo ""
    print_code "' First VBScript Program
MsgBox \"Hello, World!\"
WScript.Echo \"Hello from VBScript!\""
    print_output "  Hello, World!  (popup dialog)
  Hello from VBScript! (console output)"
    wait_key
}

lesson_2() {
    clear_screen
    print_header
    print_topic "LESSON 2: Variables and Data Types"
    echo -e "${WHITE}Variables in VBScript are declared using 'Dim'${RESET}"
    echo ""
    echo -e "${WHITE}Data Types (Subtypes):${RESET}"
    echo -e "  ${GREEN}•${RESET} Empty    - Uninitialized variable"
    echo -e "  ${GREEN}•${RESET} Null     - No valid data"
    echo -e "  ${GREEN}•${RESET} Boolean  - True / False"
    echo -e "  ${GREEN}•${RESET} Byte     - 0 to 255"
    echo -e "  ${GREEN}•${RESET} Integer  - -32,768 to 32,767"
    echo -e "  ${GREEN}•${RESET} Long     - -2,147,483,648 to 2,147,483,647"
    echo -e "  ${GREEN}•${RESET} Single   - Single-precision float"
    echo -e "  ${GREEN}•${RESET} Double   - Double-precision float"
    echo -e "  ${GREEN}•${RESET} String   - Text"
    echo -e "  ${GREEN}•${RESET} Date     - Date and Time"
    echo -e "  ${GREEN}•${RESET} Object   - Object reference"
    echo ""
    print_code "' Variable Declaration
Dim myName
Dim myAge
Dim myScore
Dim isStudent

myName   = \"Alice\"
myAge    = 25
myScore  = 98.5
isStudent = True

WScript.Echo myName
WScript.Echo myAge
WScript.Echo myScore
WScript.Echo isStudent"
    print_output "  Alice
  25
  98.5
  True"
    print_note "VBScript uses Variant type for all variables"
    wait_key
}

lesson_3() {
    clear_screen
    print_header
    print_topic "LESSON 3: Constants"
    echo -e "${WHITE}Constants are declared using 'Const'${RESET}"
    echo ""
    print_code "' Constant Declaration
Const PI = 3.14159
Const MAX_SIZE = 100
Const APP_NAME = \"MyApp\"
Const IS_DEBUG = True

WScript.Echo PI
WScript.Echo MAX_SIZE
WScript.Echo APP_NAME
WScript.Echo IS_DEBUG"
    print_output "  3.14159
  100
  MyApp
  True"
    echo ""
    echo -e "${WHITE}Built-in Constants:${RESET}"
    echo -e "  ${GREEN}vbTrue${RESET}      = -1"
    echo -e "  ${GREEN}vbFalse${RESET}     = 0"
    echo -e "  ${GREEN}vbNull${RESET}      = Null"
    echo -e "  ${GREEN}vbEmpty${RESET}     = Empty"
    echo -e "  ${GREEN}vbCrLf${RESET}      = Carriage Return + Line Feed"
    echo -e "  ${GREEN}vbNewLine${RESET}   = New Line"
    echo -e "  ${GREEN}vbTab${RESET}       = Tab"
    echo ""
    print_note "Constants cannot be changed after declaration"
    wait_key
}

lesson_4() {
    clear_screen
    print_header
    print_topic "LESSON 4: Operators"
    echo ""
    echo -e "${WHITE}Arithmetic Operators:${RESET}"
    echo -e "  ${GREEN}+${RESET}   Addition"
    echo -e "  ${GREEN}-${RESET}   Subtraction"
    echo -e "  ${GREEN}*${RESET}   Multiplication"
    echo -e "  ${GREEN}/${RESET}   Division"
    echo -e "  ${GREEN}\\${RESET}   Integer Division"
    echo -e "  ${GREEN}Mod${RESET} Modulus"
    echo -e "  ${GREEN}^${RESET}   Exponentiation"
    echo ""
    echo -e "${WHITE}Comparison Operators:${RESET}"
    echo -e "  ${GREEN}=${RESET}   Equal"
    echo -e "  ${GREEN}<>${RESET}  Not Equal"
    echo -e "  ${GREEN}>${RESET}   Greater Than"
    echo -e "  ${GREEN}<${RESET}   Less Than"
    echo -e "  ${GREEN}>=${RESET}  Greater or Equal"
    echo -e "  ${GREEN}<=${RESET}  Less or Equal"
    echo ""
    echo -e "${WHITE}Logical Operators:${RESET}"
    echo -e "  ${GREEN}And${RESET}  Logical AND"
    echo -e "  ${GREEN}Or${RESET}   Logical OR"
    echo -e "  ${GREEN}Not${RESET}  Logical NOT"
    echo -e "  ${GREEN}Xor${RESET}  Logical XOR"
    echo ""
    echo -e "${WHITE}String Operator:${RESET}"
    echo -e "  ${GREEN}&${RESET}   Concatenation"
    echo ""
    print_code "Dim a, b
a = 10
b = 3

WScript.Echo a + b    ' 13
WScript.Echo a - b    ' 7
WScript.Echo a * b    ' 30
WScript.Echo a / b    ' 3.333...
WScript.Echo a \\ b   ' 3  (integer division)
WScript.Echo a Mod b  ' 1
WScript.Echo a ^ b    ' 1000
WScript.Echo \"Hello\" & \" \" & \"World\""
    print_output "  13
  7
  30
  3.33333333333333
  3
  1
  1000
  Hello World"
    wait_key
}

lesson_5() {
    clear_screen
    print_header
    print_topic "LESSON 5: Conditional Statements"
    echo ""
    echo -e "${WHITE}1. If...Then Statement:${RESET}"
    print_code "Dim age
age = 20

If age >= 18 Then
    WScript.Echo \"Adult\"
End If"
    print_output "  Adult"

    echo -e "${WHITE}2. If...Then...Else Statement:${RESET}"
    print_code "Dim score
score = 75

If score >= 90 Then
    WScript.Echo \"Grade: A\"
ElseIf score >= 80 Then
    WScript.Echo \"Grade: B\"
ElseIf score >= 70 Then
    WScript.Echo \"Grade: C\"
Else
    WScript.Echo \"Grade: F\"
End If"
    print_output "  Grade: C"

    echo -e "${WHITE}3. Select Case Statement:${RESET}"
    print_code "Dim day
day = 3

Select Case day
    Case 1
        WScript.Echo \"Monday\"
    Case 2
        WScript.Echo \"Tuesday\"
    Case 3
        WScript.Echo \"Wednesday\"
    Case 4
        WScript.Echo \"Thursday\"
    Case 5
        WScript.Echo \"Friday\"
    Case Else
        WScript.Echo \"Weekend\"
End Select"
    print_output "  Wednesday"
    wait_key
}

lesson_6() {
    clear_screen
    print_header
    print_topic "LESSON 6: Loops"
    echo ""
    echo -e "${WHITE}1. For...Next Loop:${RESET}"
    print_code "Dim i
For i = 1 To 5
    WScript.Echo \"Count: \" & i
Next"
    print_output "  Count: 1
  Count: 2
  Count: 3
  Count: 4
  Count: 5"

    echo -e "${WHITE}2. For...Next with Step:${RESET}"
    print_code "For i = 0 To 10 Step 2
    WScript.Echo i
Next"
    print_output "  0  2  4  6  8  10"

    echo -e "${WHITE}3. Do While Loop:${RESET}"
    print_code "Dim count
count = 1
Do While count <= 3
    WScript.Echo \"Item: \" & count
    count = count + 1
Loop"
    print_output "  Item: 1
  Item: 2
  Item: 3"

    echo -e "${WHITE}4. Do Until Loop:${RESET}"
    print_code "Dim n
n = 1
Do Until n > 3
    WScript.Echo n
    n = n + 1
Loop"
    print_output "  1  2  3"

    echo -e "${WHITE}5. For Each Loop (Arrays):${RESET}"
    print_code "Dim fruits(2)
fruits(0) = \"Apple\"
fruits(1) = \"Banana\"
fruits(2) = \"Cherry\"

Dim fruit
For Each fruit In fruits
    WScript.Echo fruit
Next"
    print_output "  Apple
  Banana
  Cherry"
    wait_key
}

lesson_7() {
    clear_screen
    print_header
    print_topic "LESSON 7: Arrays"
    echo ""
    echo -e "${WHITE}Declaring Arrays:${RESET}"
    print_code "' Static Array
Dim colors(4)
colors(0) = \"Red\"
colors(1) = \"Green\"
colors(2) = \"Blue\"
colors(3) = \"Yellow\"
colors(4) = \"Purple\"

WScript.Echo colors(0)
WScript.Echo colors(2)

' Dynamic Array
Dim numbers()
ReDim numbers(2)
numbers(0) = 10
numbers(1) = 20
numbers(2) = 30

' Resize and keep data
ReDim Preserve numbers(4)
numbers(3) = 40
numbers(4) = 50

' Array Functions
WScript.Echo UBound(numbers)  ' Upper bound
WScript.Echo LBound(numbers)  ' Lower bound"
    print_output "  Red
  Blue
  4
  0"

    echo ""
    echo -e "${WHITE}Multi-dimensional Arrays:${RESET}"
    print_code "Dim matrix(2, 2)
matrix(0, 0) = 1
matrix(0, 1) = 2
matrix(0, 2) = 3
matrix(1, 0) = 4
matrix(1, 1) = 5
matrix(1, 2) = 6

WScript.Echo matrix(0, 0)
WScript.Echo matrix(1, 2)"
    print_output "  1
  6"
    wait_key
}

lesson_8() {
    clear_screen
    print_header
    print_topic "LESSON 8: Functions and Subroutines"
    echo ""
    echo -e "${WHITE}1. Sub (Subroutine) - No return value:${RESET}"
    print_code "Sub Greet(name)
    WScript.Echo \"Hello, \" & name & \"!\"
End Sub

Call Greet(\"Alice\")
Greet \"Bob\""
    print_output "  Hello, Alice!
  Hello, Bob!"

    echo -e "${WHITE}2. Function - Returns a value:${RESET}"
    print_code "Function Add(a, b)
    Add = a + b
End Function

Function IsEven(num)
    If num Mod 2 = 0 Then
        IsEven = True
    Else
        IsEven = False
    End If
End Function

WScript.Echo Add(5, 3)
WScript.Echo IsEven(4)
WScript.Echo IsEven(7)"
    print_output "  8
  True
  False"

    echo -e "${WHITE}3. ByVal and ByRef:${RESET}"
    print_code "Sub ChangeByVal(ByVal x)
    x = 100
End Sub

Sub ChangeByRef(ByRef x)
    x = 100
End Sub

Dim num
num = 5

ChangeByVal num
WScript.Echo num  ' Still 5

ChangeByRef num
WScript.Echo num  ' Now 100"
    print_output "  5
  100"
    wait_key
}

lesson_9() {
    clear_screen
    print_header
    print_topic "LESSON 9: String Functions"
    echo ""
    print_code "Dim str
str = \"Hello, VBScript World!\"

' Length
WScript.Echo Len(str)

' Uppercase / Lowercase
WScript.Echo UCase(str)
WScript.Echo LCase(str)

' Substring
WScript.Echo Mid(str, 1, 5)    ' Hello
WScript.Echo Left(str, 5)      ' Hello
WScript.Echo Right(str, 6)     ' World!

' Search
WScript.Echo InStr(str, \"VBScript\")  ' Position

' Replace
WScript.Echo Replace(str, \"World\", \"Universe\")

' Trim
Dim padded
padded = \"   Hello   \"
WScript.Echo Trim(padded)
WScript.Echo LTrim(padded)
WScript.Echo RTrim(padded)

' String Repeat
WScript.Echo String(5, \"*\")

' Reverse
WScript.Echo StrReverse(\"Hello\")

' Space
WScript.Echo \"A\" & Space(5) & \"B\""
    print_output "  22
  HELLO, VBSCRIPT WORLD!
  hello, vbscript world!
  Hello
  Hello
  World!
  8
  Hello, VBScript Universe!
  Hello
  Hello   
     Hello
  *****
  olleH
  A     B"
    wait_key
}

lesson_10() {
    clear_screen
    print_header
    print_topic "LESSON 10: Math Functions"
    echo ""
    print_code "' Math Functions in VBScript

WScript.Echo Abs(-10)          ' 10
WScript.Echo Sqr(16)           ' 4
WScript.Echo Int(3.7)          ' 3
WScript.Echo Fix(3.7)          ' 3
WScript.Echo Round(3.567, 2)   ' 3.57
WScript.Echo Rnd()             ' Random 0-1
WScript.Echo Int(Rnd * 100)    ' Random 0-99

' Trigonometry
WScript.Echo Sin(0)            ' 0
WScript.Echo Cos(0)            ' 1
WScript.Echo Tan(0)            ' 0

' Logarithm / Exponential
WScript.Echo Exp(1)            ' e = 2.71828...
WScript.Echo Log(1)            ' 0

' Min / Max (no built-in, use If)
Function Max(a, b)
    If a > b Then Max = a Else Max = b
End Function

WScript.Echo Max(10, 20)"
    print_output "  10
  4
  3
  3
  3.57
  (random value)
  (random value)
  0
  1
  0
  2.71828182845905
  0
  20"
    wait_key
}

lesson_11() {
    clear_screen
    print_header
    print_topic "LESSON 11: Date and Time Functions"
    echo ""
    print_code "' Date and Time Functions

WScript.Echo Now()          ' Current date and time
WScript.Echo Date()         ' Current date
WScript.Echo Time()         ' Current time

WScript.Echo Year(Now())    ' Current year
WScript.Echo Month(Now())   ' Current month
WScript.Echo Day(Now())     ' Current day
WScript.Echo Hour(Now())    ' Current hour
WScript.Echo Minute(Now())  ' Current minute
WScript.Echo Second(Now())  ' Current second
WScript.Echo Weekday(Now()) ' Day of week (1=Sunday)

WScript.Echo WeekdayName(Weekday(Now()))
WScript.Echo MonthName(Month(Now()))

' Date Arithmetic
WScript.Echo DateAdd(\"d\", 7, Date())   ' Add 7 days
WScript.Echo DateDiff(\"d\", \"01/01/2024\", \"12/31/2024\") ' Days between

' Format Date
WScript.Echo FormatDateTime(Now(), 1)  ' Long date
WScript.Echo FormatDateTime(Now(), 2)  ' Short date"
    print_output "  1/15/2025 10:30:00 AM
  1/15/2025
  10:30:00 AM
  2025
  1
  15
  10
  30
  0
  4
  Wednesday
  January
  1/22/2025
  365
  Wednesday, January 15, 2025
  1/15/2025"
    wait_key
}

lesson_12() {
    clear_screen
    print_header
    print_topic "LESSON 12: Error Handling"
    echo ""
    print_code "' Error Handling in VBScript

' Enable error handling
On Error Resume Next

Dim result
result = 10 / 0   ' Division by zero

If Err.Number <> 0 Then
    WScript.Echo \"Error: \" & Err.Number
    WScript.Echo \"Description: \" & Err.Description
    WScript.Echo \"Source: \" & Err.Source
    Err.Clear
End If

' Custom Error
On Error Resume Next
Err.Raise 5  ' Invalid procedure call

If Err.Number <> 0 Then
    WScript.Echo \"Error caught: \" & Err.Description
    Err.Clear
End If

' Disable error handling
On Error GoTo 0"
    print_output "  Error: 11
  Description: Division by zero
  Source: Microsoft VBScript runtime error
  Error caught: Invalid procedure call or argument"
    print_note "On Error Resume Next ignores errors and continues"
    wait_key
}

lesson_13() {
    clear_screen
    print_header
    print_topic "LESSON 13: File System Operations"
    echo ""
    print_code "' File System using FileSystemObject

Dim fso
Set fso = CreateObject(\"Scripting.FileSystemObject\")

' Create a file
Dim file
Set file = fso.CreateTextFile(\"test.txt\", True)
file.WriteLine \"Hello, World!\"
file.WriteLine \"Line 2\"
file.WriteLine \"Line 3\"
file.Close

' Read a file
Dim readFile
Set readFile = fso.OpenTextFile(\"test.txt\", 1)
Do While Not readFile.AtEndOfStream
    WScript.Echo readFile.ReadLine
Loop
readFile.Close

' Check if file exists
If fso.FileExists(\"test.txt\") Then
    WScript.Echo \"File exists!\"
End If

' Delete file
fso.DeleteFile \"test.txt\"

' Folder operations
If Not fso.FolderExists(\"MyFolder\") Then
    fso.CreateFolder \"MyFolder\"
    WScript.Echo \"Folder created\"
End If

Set fso = Nothing"
    print_output "  Hello, World!
  Line 2
  Line 3
  File exists!
  Folder created"
    wait_key
}

lesson_14() {
    clear_screen
    print_header
    print_topic "LESSON 14: Classes and Objects"
    echo ""
    print_code "' Classes in VBScript

Class Person
    ' Properties
    Private m_Name
    Private m_Age

    ' Constructor
    Private Sub Class_Initialize()
        m_Name = \"Unknown\"
        m_Age = 0
    End Sub

    ' Destructor
    Private Sub Class_Terminate()
        WScript.Echo m_Name & \" object destroyed\"
    End Sub

    ' Property Get
    Public Property Get Name()
        Name = m_Name
    End Property

    ' Property Let
    Public Property Let Name(value)
        m_Name = value
    End Property

    Public Property Get Age()
        Age = m_Age
    End Property

    Public Property Let Age(value)
        If value > 0 Then
            m_Age = value
        End If
    End Property

    ' Method
    Public Sub Introduce()
        WScript.Echo \"Hi! I am \" & m_Name & _
                     \", Age: \" & m_Age
    End Sub

    Public Function IsAdult()
        IsAdult = (m_Age >= 18)
    End Function
End Class

' Create objects
Dim p1
Set p1 = New Person
p1.Name = \"Alice\"
p1.Age = 25
p1.Introduce()
WScript.Echo p1.IsAdult()

Set p1 = Nothing"
    print_output "  Hi! I am Alice, Age: 25
  True
  Alice object destroyed"
    wait_key
}

lesson_15() {
    clear_screen
    print_header
    print_topic "LESSON 15: WScript Object"
    echo ""
    echo -e "${WHITE}WScript object provides access to Windows Script Host:${RESET}"
    echo ""
    print_code "' WScript Object Properties and Methods

' Echo - Output text
WScript.Echo \"Hello from WScript!\"

' Script information
WScript.Echo WScript.Name
WScript.Echo WScript.Version
WScript.Echo WScript.FullName
WScript.Echo WScript.Path
WScript.Echo WScript.ScriptName
WScript.Echo WScript.ScriptFullName

' Arguments
WScript.Echo WScript.Arguments.Count

' Sleep - Pause (milliseconds)
WScript.Sleep 1000  ' 1 second

' Quit with exit code
' WScript.Quit 0

' Create objects
Dim shell
Set shell = WScript.CreateObject(\"WScript.Shell\")

' Run command
shell.Run \"notepad.exe\"

' Get environment variable
Dim env
Set env = shell.Environment(\"SYSTEM\")
WScript.Echo env(\"PATH\")

Set shell = Nothing"
    print_output "  Hello from WScript!
  Windows Script Host
  5.812
  C:\\Windows\\System32\\wscript.exe
  C:\\Windows\\System32
  script.vbs
  C:\\path\\script.vbs
  0"
    wait_key
}

lesson_16() {
    clear_screen
    print_header
    print_topic "LESSON 16: WScript.Shell Object"
    echo ""
    print_code "Dim shell
Set shell = CreateObject(\"WScript.Shell\")

' Run application
shell.Run \"notepad.exe\"

' Run and wait
shell.Run \"cmd.exe /c dir\", 1, True

' Execute command and get output
Dim exec
Set exec = shell.Exec(\"cmd.exe /c echo Hello\")
WScript.Echo exec.StdOut.ReadAll()

' Registry operations
shell.RegWrite \"HKCU\\Software\\MyApp\\Version\", \"1.0\"
WScript.Echo shell.RegRead(\"HKCU\\Software\\MyApp\\Version\")
shell.RegDelete \"HKCU\\Software\\MyApp\\\"

' Environment variables
WScript.Echo shell.ExpandEnvironmentStrings(\"%USERNAME%\")
WScript.Echo shell.ExpandEnvironmentStrings(\"%TEMP%\")

' Shortcuts
Dim shortcut
Set shortcut = shell.CreateShortcut(\"MyApp.lnk\")
shortcut.TargetPath = \"C:\\MyApp\\app.exe\"
shortcut.Save

' Popup dialog
shell.Popup \"Hello!\", 5, \"Title\", 64

' Special folders
WScript.Echo shell.SpecialFolders(\"Desktop\")
WScript.Echo shell.SpecialFolders(\"MyDocuments\")

Set shell = Nothing"
    print_output "  Hello
  1.0
  Alice
  C:\\Users\\Alice\\AppData\\Local\\Temp
  (Popup shown for 5 seconds)
  C:\\Users\\Alice\\Desktop
  C:\\Users\\Alice\\Documents"
    wait_key
}

lesson_17() {
    clear_screen
    print_header
    print_topic "LESSON 17: Regular Expressions"
    echo ""
    print_code "' Regular Expressions in VBScript

Dim regex
Set regex = New RegExp

' Basic match
regex.Pattern = \"\\d+\"   ' Match digits
regex.Global = True

Dim text
text = \"I have 3 cats and 12 dogs\"

If regex.Test(text) Then
    WScript.Echo \"Numbers found!\"
End If

' Find all matches
Dim matches
Set matches = regex.Execute(text)

Dim match
For Each match In matches
    WScript.Echo \"Found: \" & match.Value & _
                 \" at position \" & match.FirstIndex
Next

' Replace
regex.Pattern = \"\\d+\"
WScript.Echo regex.Replace(text, \"#\")

' Email validation
Dim emailRegex
Set emailRegex = New RegExp
emailRegex.Pattern = \"^[\\w.]+@[\\w]+\\.[\\w]{2,}$\"

Dim emails(2)
emails(0) = \"user@example.com\"
emails(1) = \"invalid-email\"
emails(2) = \"test@test.org\"

Dim i
For i = 0 To 2
    If emailRegex.Test(emails(i)) Then
        WScript.Echo emails(i) & \" - Valid\"
    Else
        WScript.Echo emails(i) & \" - Invalid\"
    End If
Next

Set regex = Nothing"
    print_output "  Numbers found!
  Found: 3 at position 7
  Found: 12 at position 19
  I have # cats and # dogs
  user@example.com - Valid
  invalid-email - Invalid
  test@test.org - Valid"
    wait_key
}

lesson_18() {
    clear_screen
    print_header
    print_topic "LESSON 18: Type Conversion Functions"
    echo ""
    print_code "' Type Conversion Functions

' To String
WScript.Echo CStr(42)           ' \"42\"
WScript.Echo CStr(3.14)         ' \"3.14\"
WScript.Echo CStr(True)         ' \"True\"

' To Integer
WScript.Echo CInt(\"42\")         ' 42
WScript.Echo CInt(3.7)          ' 4 (rounds)
WScript.Echo CInt(True)         ' -1

' To Long
WScript.Echo CLng(\"1000000\")    ' 1000000

' To Double
WScript.Echo CDbl(\"3.14\")       ' 3.14

' To Boolean
WScript.Echo CBool(0)           ' False
WScript.Echo CBool(1)           ' True
WScript.Echo CBool(\"\")          ' False
WScript.Echo CBool(\"True\")      ' True

' To Date
WScript.Echo CDate(\"01/15/2025\")

' Type checking
WScript.Echo IsNumeric(\"42\")    ' True
WScript.Echo IsNumeric(\"abc\")   ' False
WScript.Echo IsDate(\"01/15/2025\") ' True
WScript.Echo IsNull(Null)       ' True
WScript.Echo IsEmpty(Empty)     ' True
WScript.Echo IsArray(Array(1,2,3)) ' True

' VarType
WScript.Echo VarType(42)        ' 2 (Integer)
WScript.Echo VarType(\"hello\")   ' 8 (String)
WScript.Echo VarType(True)      ' 11 (Boolean)
WScript.Echo TypeName(42)"
    print_output "  42
  3.14
  True
  42
  4
  -1
  1000000
  3.14
  False
  True
  False
  True
  1/15/2025
  True
  False
  True
  True
  True
  True
  2
  8
  11
  Integer"
    wait_key
}

lesson_19() {
    clear_screen
    print_header
    print_topic "LESSON 19: Input and Output"
    echo ""
    print_code "' Input/Output in VBScript

' MsgBox - Display message
MsgBox \"Hello, World!\"

' MsgBox with options
Dim response
response = MsgBox(\"Continue?\", vbYesNo + vbQuestion, \"Confirm\")
If response = vbYes Then
    WScript.Echo \"User clicked Yes\"
Else
    WScript.Echo \"User clicked No\"
End If

' MsgBox Buttons Constants:
' vbOKOnly        = 0
' vbOKCancel      = 1
' vbAbortRetryIgnore = 2
' vbYesNoCancel   = 3
' vbYesNo         = 4
' vbRetryCancel   = 5

' InputBox - Get input from user
Dim name
name = InputBox(\"Enter your name:\", \"Input\", \"Default\")
WScript.Echo \"Hello, \" & name

' WScript.Echo - Console output
WScript.Echo \"Line 1\"
WScript.Echo \"Line 2\"

' Multiple values
WScript.Echo \"Name: \" & \"Alice\" & vbCrLf & _
             \"Age: \" & 25 & vbCrLf & _
             \"City: \" & \"NYC\""
    print_output "  [Dialog: Hello, World!]
  [Dialog: Continue?] User clicked Yes
  [InputBox appears]
  Hello, Alice
  Line 1
  Line 2
  Name: Alice
  Age: 25
  City: NYC"
    wait_key
}

lesson_20() {
    clear_screen
    print_header
    print_topic "LESSON 20: Complete Project - Calculator"
    echo ""
    print_code "' ==========================================
' VBScript Calculator
' ==========================================

Option Explicit

Class Calculator
    Private result

    Private Sub Class_Initialize()
        result = 0
    End Sub

    Public Property Get Result()
        Result = result
    End Property

    Public Sub SetValue(val)
        result = val
    End Sub

    Public Function Add(a, b)
        Add = a + b
    End Function

    Public Function Subtract(a, b)
        Subtract = a - b
    End Function

    Public Function Multiply(a, b)
        Multiply = a * b
    End Function

    Public Function Divide(a, b)
        If b = 0 Then
            WScript.Echo \"Error: Division by zero!\"
            Divide = 0
        Else
            Divide = a / b
        End If
    End Function

    Public Function Power(base, exp)
        Power = base ^ exp
    End Function

    Public Function Factorial(n)
        If n <= 1 Then
            Factorial = 1
        Else
            Factorial = n * Factorial(n - 1)
        End If
    End Function
End Class

' Main Program
Dim calc
Set calc = New Calculator

Dim a, b
a = 10
b = 3

WScript.Echo \"=== Calculator ==\"
WScript.Echo a & \" + \" & b & \" = \" & calc.Add(a, b)
WScript.Echo a & \" - \" & b & \" = \" & calc.Subtract(a, b)
WScript.Echo a & \" * \" & b & \" = \" & calc.Multiply(a, b)
WScript.Echo a & \" / \" & b & \" = \" & calc.Divide(a, b)
WScript.Echo a & \" ^ \" & b & \" = \" & calc.Power(a, b)
WScript.Echo \"5! = \" & calc.Factorial(5)

Set calc = Nothing"
    print_output "  === Calculator ==
  10 + 3 = 13
  10 - 3 = 7
  10 * 3 = 30
  10 / 3 = 3.33333333333333
  10 ^ 3 = 1000
  5! = 120"
    wait_key
}

# ============================================
# QUIZ SECTION
# ============================================

quiz() {
    clear_screen
    print_header
    echo -e "${YELLOW}         VBScript QUIZ TIME!             ${RESET}"
    echo -e "${CYAN}============================================${RESET}"
    echo ""

    local score=0
    local total=5

    # Q1
    echo -e "${WHITE}Q1. What keyword is used to declare a variable in VBScript?${RESET}"
    echo "  a) var"
    echo "  b) let"
    echo "  c) Dim"
    echo "  d) Declare"
    echo ""
    read -r -p "Your answer: " ans1
    if [[ "$ans1" == "c" || "$ans1" == "C" ]]; then
        echo -e "${GREEN}✔ Correct!${RESET}"
        ((score++))
    else
        echo -e "${RED}✘ Wrong! Answer: c) Dim${RESET}"
    fi
    echo ""

    # Q2
    echo -e "${WHITE}Q2. Which function returns the length of a string?${RESET}"
    echo "  a) Size()"
    echo "  b) Count()"
    echo "  c) Length()"
    echo "  d) Len()"
    echo ""
    read -r -p "Your answer: " ans2
    if [[ "$ans2" == "d" || "$ans2" == "D" ]]; then
        echo -e "${GREEN}✔ Correct!${RESET}"
        ((score++))
    else
        echo -e "${RED}✘ Wrong! Answer: d) Len()${RESET}"
    fi
    echo ""

    # Q3
    echo -e "${WHITE}Q3. What is the concatenation operator in VBScript?${RESET}"
    echo "  a) +"
    echo "  b) ."
    echo "  c) &"
    echo "  d) ++"
    echo ""
    read -r -p "Your answer: " ans3
    if [[ "$ans3" == "c" || "$ans3" == "C" ]]; then
        echo -e "${GREEN}✔ Correct!${RESET}"
        ((score++))
    else
        echo -e "${RED}✘ Wrong! Answer: c) &${RESET}"
    fi
    echo ""

    # Q4
    echo -e "${WHITE}Q4. What does 'On Error Resume Next' do?${RESET}"
    echo "  a) Stops the script"
    echo "  b) Ignores errors and continues"
    echo "  c) Shows error dialog"
    echo "  d) Restarts the script"
    echo ""
    read -r -p "Your answer: " ans4
    if [[ "$ans4" == "b" || "$ans4" == "B" ]]; then
        echo -e "${GREEN}✔ Correct!${RESET}"
        ((score++))
    else
        echo -e "${RED}✘ Wrong! Answer: b) Ignores errors and continues${RESET}"
    fi
    echo ""

    # Q5
    echo -e "${WHITE}Q5. Which object is used for File System operations?${RESET}"
    echo "  a) WScript.Shell"
    echo "  b) Scripting.FileSystemObject"
    echo "  c) WScript.File"
    echo "  d) Script.IO"
    echo ""
    read -r -p "Your answer: " ans5
    if [[ "$ans5" == "b" || "$ans5" == "B" ]]; then
        echo -e "${GREEN}✔ Correct!${RESET}"
        ((score++))
    else
        echo -e "${RED}✘ Wrong! Answer: b) Scripting.FileSystemObject${RESET}"
    fi
    echo ""

    # Result
    echo -e "${CYAN}============================================${RESET}"
    echo -e "${WHITE}Your Score: ${score}/${total}${RESET}"
    if [ $score -eq $total ]; then
        echo -e "${GREEN}🎉 Perfect Score! Excellent!${RESET}"
    elif [ $score -ge 3 ]; then
        echo -e "${YELLOW}👍 Good Job! Keep practicing!${RESET}"
    else
        echo -e "${RED}📚 Keep studying! You can do it!${RESET}"
    fi
    echo -e "${CYAN}============================================${RESET}"
    wait_key
}

# ============================================
# CHEAT SHEET
# ============================================

cheat_sheet() {
    clear_screen
    print_header
    echo -e "${YELLOW}       VBScript CHEAT SHEET              ${RESET}"
    echo -e "${CYAN}============================================${RESET}"
    echo ""
    echo -e "${GREEN}VARIABLES:${RESET}"
    echo "  Dim x          ' Declare variable"
    echo "  Const PI = 3.14 ' Declare constant"
    echo ""
    echo -e "${GREEN}DATA TYPES:${RESET}"
    echo "  String, Integer, Long, Double"
    echo "  Boolean, Date, Object, Null, Empty"
    echo ""
    echo -e "${GREEN}CONDITIONS:${RESET}"
    echo "  If x > 0 Then ... ElseIf ... Else ... End If"
    echo "  Select Case x ... Case 1 ... Case Else ... End Select"
    echo ""
    echo -e "${GREEN}LOOPS:${RESET}"
    echo "  For i = 1 To 10 ... Next"
    echo "  For Each item In collection ... Next"
    echo "  Do While condition ... Loop"
    echo "  Do Until condition ... Loop"
    echo ""
    echo -e "${GREEN}FUNCTIONS/SUBS:${RESET}"
    echo "  Sub MySub(arg) ... End Sub"
    echo "  Function MyFunc(arg) ... MyFunc = value ... End Function"
    echo ""
    echo -e "${GREEN}STRING FUNCTIONS:${RESET}"
    echo "  Len() UCase() LCase() Mid() Left() Right()"
    echo "  InStr() Replace() Trim() Split() Join()"
    echo ""
    echo -e "${GREEN}MATH FUNCTIONS:${RESET}"
    echo "  Abs() Sqr() Int() Fix() Round() Rnd()"
    echo "  Sin() Cos() Tan() Exp() Log()"
    echo ""
    echo -e "${GREEN}DATE FUNCTIONS:${RESET}"
    echo "  Now() Date() Time() Year() Month() Day()"
    echo "  DateAdd() DateDiff() FormatDateTime()"
    echo ""
    echo -e "${GREEN}TYPE FUNCTIONS:${RESET}"
    echo "  CStr() CInt() CDbl() CBool() CDate()"
    echo "  IsNumeric() IsDate() IsNull() IsArray()"
    echo ""
    echo -e "${GREEN}ERROR HANDLING:${RESET}"
    echo "  On Error Resume Next"
    echo "  If Err.Number <> 0 Then ... Err.Clear"
    echo "  On Error GoTo 0"
    echo ""
    echo -e "${GREEN}OBJECTS:${RESET}"
    echo "  Set obj = CreateObject(\"ProgID\")"
    echo "  Set obj = New MyClass"
    echo "  Set obj = Nothing"
    echo ""
    wait_key
}

# ============================================
# MAIN MENU
# ============================================

main_menu() {
    while true; do
        clear_screen
        print_header
        echo -e "${YELLOW}         MAIN MENU                       ${RESET}"
        echo -e "${CYAN}============================================${RESET}"
        echo ""
        echo -e "  ${GREEN}[01]${RESET} Introduction to VBScript"
        echo -e "  ${GREEN}[02]${RESET} Variables and Data Types"
        echo -e "  ${GREEN}[03]${RESET} Constants"
        echo -e "  ${GREEN}[04]${RESET} Operators"
        echo -e "  ${GREEN}[05]${RESET} Conditional Statements"
        echo -e "  ${GREEN}[06]${RESET} Loops"
        echo -e "  ${GREEN}[07]${RESET} Arrays"
        echo -e "  ${GREEN}[08]${RESET} Functions and Subroutines"
        echo -e "  ${GREEN}[09]${RESET} String Functions"
        echo -e "  ${GREEN}[10]${RESET} Math Functions"
        echo -e "  ${GREEN}[11]${RESET} Date and Time Functions"
        echo -e "  ${GREEN}[12]${RESET} Error Handling"
        echo -e "  ${GREEN}[13]${RESET} File System Operations"
        echo -e "  ${GREEN}[14]${RESET} Classes and Objects"
        echo -e "  ${GREEN}[15]${RESET} WScript Object"
        echo -e "  ${GREEN}[16]${RESET} WScript.Shell Object"
        echo -e "  ${GREEN}[17]${RESET} Regular Expressions"
        echo -e "  ${GREEN}[18]${RESET} Type Conversion Functions"
        echo -e "  ${GREEN}[19]${RESET} Input and Output"
        echo -e "  ${GREEN}[20]${RESET} Complete Project - Calculator"
        echo ""
        echo -e "  ${YELLOW}[Q]${RESET}  Take Quiz"
        echo -e "  ${YELLOW}[C]${RESET}  Cheat Sheet"
        echo -e "  ${RED}[X]${RESET}  Exit"
        echo ""
        echo -e "${CYAN}============================================${RESET}"
        read -r -p "Select option: " choice

        case "$choice" in
            1|01) lesson_1 ;;
            2|02) lesson_2 ;;
            3|03) lesson_3 ;;
            4|04) lesson_4 ;;
            5|05) lesson_5 ;;
            6|06) lesson_6 ;;
            7|07) lesson_7 ;;
            8|08) lesson_8 ;;
            9|09) lesson_9 ;;
            10)   lesson_10 ;;
            11)   lesson_11 ;;
            12)   lesson_12 ;;
            13)   lesson_13 ;;
            14)   lesson_14 ;;
            15)   lesson_15 ;;
            16)   lesson_16 ;;
            17)   lesson_17 ;;
            18)   lesson_18 ;;
            19)   lesson_19 ;;
            20)   lesson_20 ;;
            q|Q)  quiz ;;
            c|C)  cheat_sheet ;;
            x|X)
                clear_screen
                echo -e "${GREEN}Thanks for learning VBScript!${RESET}"
                echo -e "${CYAN}Goodbye!${RESET}"
                echo ""
                exit 0
                ;;
            *)
                echo -e "${RED}Invalid option! Try again.${RESET}"
                sleep 1
                ;;
        esac
    done
}

# ============================================
# START
# ============================================

main_menu
