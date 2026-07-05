#!/data/data/com.termux/files/usr/bin/bash
# Advanced ASCII Art Generator v2.0 - Termux
# Features: Colored ASCII, Rainbow text, Borders, Multiple styles, Batch processing, etc.

# ==================== COLORS ====================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
WHITE='\033[1;37m'
NC='\033[0m'
BOLD='\033[1m'

# ==================== AUTO INSTALL ====================
install_dependencies() {
    echo -e "${YELLOW}[*] Installing advanced dependencies...${NC}"
    pkg update -y
    pkg install -y figlet toilet imagemagick python git
    pip install pillow colorama --quiet
    
    # Install additional figlet fonts
    if [ ! -d "$PREFIX/share/figlet/fonts" ]; then
        mkdir -p "$PREFIX/share/figlet/fonts"
        git clone https://github.com/xero/figlet-fonts.git /tmp/figlet-fonts 2>/dev/null
        cp /tmp/figlet-fonts/*.flf "$PREFIX/share/figlet/fonts/" 2>/dev/null || true
    fi
    echo -e "${GREEN}[+] All dependencies installed!${NC}"
    sleep 1
}

check_dependencies() {
    if ! command -v figlet &> /dev/null || ! command -v convert &> /dev/null; then
        install_dependencies
    fi
}

# ==================== RAINBOW TEXT ====================
rainbow_text() {
    local text="$1"
    local colors=("$RED" "$YELLOW" "$GREEN" "$CYAN" "$BLUE" "$MAGENTA")
    local i=0
    for ((j=0; j<${#text}; j++)); do
        char="${text:$j:1}"
        printf "${colors[$i]}${char}"
        ((i++))
        if [ $i -ge ${#colors[@]} ]; then i=0; fi
    done
    printf "${NC}\n"
}

# ==================== TEXT TO ASCII (ADVANCED) ====================
text_to_ascii_advanced() {
    clear
    echo -e "${CYAN}╔════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║         ADVANCED TEXT TO ASCII             ║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════╝${NC}"
    
    read -p "Enter your text: " text
    
    echo -e "\n${YELLOW}Select Style:${NC}"
    echo "1. Standard Figlet"
    echo "2. Big / Slant / Doom"
    echo "3. Toilet (Colored)"
    echo "4. Rainbow ASCII"
    echo "5. Bordered Box"
    echo "6. Multiple Fonts (Random)"
    echo "7. Shadow Effect"
    read -p "Choice: " style_choice

    case $style_choice in
        1) figlet "$text" ;;
        2) 
            read -p "Font (big/slant/doom/banner): " font
            figlet -f "${font:-big}" "$text"
            ;;
        3) toilet -f term "$text" --gay ;;
        4) 
            figlet "$text" | while IFS= read -r line; do
                rainbow_text "$line"
            done
            ;;
        5)
            echo -e "${BLUE}┌$(printf '─%.0s' $(seq 1 $((${#text}+4))))┐${NC}"
            figlet "$text" | while read line; do
                printf "${BLUE}│${NC} %s ${BLUE}│${NC}\n" "$line"
            done
            echo -e "${BLUE}└$(printf '─%.0s' $(seq 1 $((${#text}+4))))┘${NC}"
            ;;
        6)
            fonts=("big" "slant" "doom" "banner" "block" "doh")
            for f in "${fonts[@]}"; do
                echo -e "${MAGENTA}=== Font: $f ===${NC}"
                figlet -f "$f" "$text" 2>/dev/null || true
                echo ""
            done
            ;;
        7)
            figlet "$text" | sed 's/./&/g; s/^/  /'
            echo -e "${RED}"
            figlet "$text" | sed 's/^/ /'
            echo -e "${NC}"
            ;;
        *) figlet "$text" ;;
    esac

    echo -e "\n${GREEN}Options:${NC}"
    echo "1. Save to .txt"
    echo "2. Save to .html (with colors)"
    echo "3. Back to menu"
    read -p "Choice: " save_choice

    if [[ $save_choice == "1" ]]; then
        read -p "Filename: " fname
        figlet "$text" > "${fname}.txt"
        echo -e "${GREEN}[+] Saved as ${fname}.txt${NC}"
    elif [[ $save_choice == "2" ]]; then
        read -p "Filename: " fname
        echo "<pre style='color:green; background:black; font-family:monospace;'>" > "${fname}.html"
        figlet "$text" >> "${fname}.html"
        echo "</pre>" >> "${fname}.html"
        echo -e "${GREEN}[+] Saved as ${fname}.html${NC}"
    fi
}

# ==================== IMAGE TO ASCII (ADVANCED) ====================
image_to_ascii_advanced() {
    clear
    echo -e "${CYAN}╔════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║       ADVANCED IMAGE TO ASCII              ║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════╝${NC}"
    
    read -p "Image path: " img
    if [ ! -f "$img" ]; then
        echo -e "${RED}[!] File not found!${NC}"
        sleep 1
        return
    fi

    read -p "Width (default 100): " width
    width=${width:-100}
    
    echo -e "\n${YELLOW}ASCII Style:${NC}"
    echo "1. Grayscale (Standard)"
    echo "2. Colored ASCII"
    echo "3. Block Characters"
    echo "4. High Detail"
    echo "5. Inverted Colors"
    read -p "Style: " img_style

    python3 <<EOF
from PIL import Image
import sys

def get_char(val, style=1):
    if style == 3:
        chars = "█▓▒░ "
    elif style == 4:
        chars = "$@B%8&WM#*oahkbdpqwmZO0QLCJUYXzcvunxrjft/\|()1{}[]?-_+~<>i!lI;:,\"^`'. "
    else:
        chars = "@%#*+=-:. "
    return chars[min(val // (256 // len(chars)), len(chars)-1)]

img = Image.open("$img")
aspect = img.height / img.width
new_h = int($width * aspect * 0.55)
img = img.resize(($width, new_h))

if "$img_style" == "2":
    img_rgb = img.convert("RGB")
    for y in range(new_h):
        for x in range($width):
            r, g, b = img_rgb.getpixel((x, y))
            gray = int((r + g + b) / 3)
            char = get_char(gray, 1)
            print(f"\033[38;2;{r};{g};{b}m{char}", end="")
        print("\033[0m")
elif "$img_style" == "5":
    img = img.convert("L").point(lambda x: 255 - x)
    for y in range(new_h):
        line = ""
        for x in range($width):
            gray = img.getpixel((x, y))
            line += get_char(gray)
        print(line)
else:
    img = img.convert("L")
    style = 3 if "$img_style" == "3" else 4 if "$img_style" == "4" else 1
    for y in range(new_h):
        line = ""
        for x in range($width):
            gray = img.getpixel((x, y))
            line += get_char(gray, style)
        print(line)
EOF

    echo -e "\n${GREEN}Save output? (y/n)${NC}"
    read -p "> " save
    if [[ $save == "y" ]]; then
        read -p "Filename: " fname
        # Simple save (grayscale version)
        python3 -c "
from PIL import Image
img = Image.open('$img').convert('L').resize(($width, int($width * (img.height/img.width) * 0.55)))
chars = '@%#*+=-:. '
with open('${fname}.txt','w') as f:
    for i,p in enumerate(img.getdata()):
        f.write(chars[p//25])
        if (i+1) % $width == 0: f.write('\n')
print('Saved!')
        "
    fi
}

# ==================== MAIN MENU ====================
main_menu() {
    check_dependencies
    while true; do
        clear
        echo -e "${GREEN}"
        echo "╔══════════════════════════════════════════════════════╗"
        echo "║     ADVANCED ASCII ART GENERATOR v2.0 (Termux)       ║"
        echo "╚══════════════════════════════════════════════════════╝"
        echo -e "${NC}"
        echo -e "${CYAN}1.${NC} Text → ASCII (Advanced)"
        echo -e "${CYAN}2.${NC} Image → ASCII (Color + Multiple Styles)"
        echo -e "${CYAN}3.${NC} List Available Figlet Fonts"
        echo -e "${CYAN}4.${NC} Random ASCII Art"
        echo -e "${CYAN}5.${NC} Exit"
        echo ""
        read -p "Select option: " choice

        case $choice in
            1) text_to_ascii_advanced ;;
            2) image_to_ascii_advanced ;;
            3) 
                echo -e "${YELLOW}Available fonts:${NC}"
                ls "$PREFIX/share/figlet/fonts/" 2>/dev/null | head -20
                ;;
            4)
                echo -e "${MAGENTA}Generating random art...${NC}"
                figlet -f "$(ls $PREFIX/share/figlet/fonts/ | shuf -n1)" "Termux" 2>/dev/null || figlet "Termux"
                ;;
            5) echo -e "${GREEN}Goodbye!${NC}"; exit 0 ;;
            *) echo -e "${RED}Invalid option!${NC}"; sleep 1 ;;
        esac
        echo ""
        read -p "Press Enter to continue..."
    done
}

main_menu
