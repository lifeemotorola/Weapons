import curses
import time
import random
import string

def generate_256_rainbow():
    """Generates a smooth 30-step rainbow gradient using xterm-256 color codes."""
    colors = []
    # xterm-256 RGB format: 16 + 36*R + 6*G + B (where R, G, B are 0-5)
    for g in range(0, 6): colors.append(16 + 36*5 + 6*g + 0) # Red to Yellow
    for r in range(4, -1, -1): colors.append(16 + 36*r + 6*5 + 0) # Yellow to Green
    for b in range(1, 6): colors.append(16 + 36*0 + 6*5 + b) # Green to Cyan
    for g in range(4, -1, -1): colors.append(16 + 36*0 + 6*g + 5) # Cyan to Blue
    for r in range(1, 6): colors.append(16 + 36*r + 6*0 + 5) # Blue to Magenta
    for b in range(4, 0, -1): colors.append(16 + 36*5 + 6*0 + b) # Magenta to Red
    return colors

def main(stdscr):
    # --- Terminal Setup ---
    curses.curs_set(0)        # Hide the cursor
    stdscr.nodelay(True)      # Don't block for user input
    curses.start_color()      # Enable colors
    curses.use_default_colors()

    # --- Gradient Setup ---
    gradient_pairs = []
    
    # Check if the terminal supports 256 colors for the smooth gradient
    if curses.COLORS >= 256:
        rainbow = generate_256_rainbow()
        for i, color_code in enumerate(rainbow):
            pair_idx = i + 1
            curses.init_pair(pair_idx, color_code, curses.COLOR_BLACK)
            gradient_pairs.append(pair_idx)
    else:
        # Fallback for older 8-color terminals
        basic_colors = [
            curses.COLOR_RED, curses.COLOR_YELLOW, curses.COLOR_GREEN,
            curses.COLOR_CYAN, curses.COLOR_BLUE, curses.COLOR_MAGENTA
        ]
        for i, color_code in enumerate(basic_colors):
            pair_idx = i + 1
            curses.init_pair(pair_idx, color_code, curses.COLOR_BLACK)
            gradient_pairs.append(pair_idx)

    num_colors = len(gradient_pairs)
    
    # Reserve the next available pair indexes for White (Head) and Label (Inverse)
    HEAD_PAIR = num_colors + 1
    LABEL_PAIR = num_colors + 2
    curses.init_pair(HEAD_PAIR, curses.COLOR_WHITE, curses.COLOR_BLACK)
    curses.init_pair(LABEL_PAIR, curses.COLOR_BLACK, curses.COLOR_WHITE)

    # Screen dimensions
    max_y, max_x = stdscr.getmaxyx()

    # Character set
    chars = string.ascii_letters + string.digits + "!@#$%^&*()_+-=[]{}|;':,./<>?"

    # --- Matrix State Arrays ---
    drops = [random.randint(0, max_y) for _ in range(max_x)]
    lengths = [random.randint(5, 20) for _ in range(max_x)]
    speeds = [random.randint(1, 3) for _ in range(max_x)]
    
    frames = 0

    while True:
        # Check for screen resize
        new_y, new_x = stdscr.getmaxyx()
        if new_y != max_y or new_x != max_x:
            max_y, max_x = new_y, new_x
            if max_y == 0: max_y = 1
            if max_x == 0: max_x = 1
            drops = [random.randint(0, max_y) for _ in range(max_x)]
            lengths = [random.randint(5, 20) for _ in range(max_x)]
            speeds = [random.randint(1, 3) for _ in range(max_x)]
            stdscr.clear()

        # --- Update and Draw Digital Rain ---
        for x in range(max_x):
            if frames % speeds[x] == 0:
                y = drops[x]

                # Calculate gradient color dynamically based on screen position & time
                # The math creates 2 horizontal waves and 2 vertical waves that flow diagonally
                color_math = ((x / max_x) * 2.0) + ((y / max_y) * 2.0) - (frames * 0.05)
                color_idx = gradient_pairs[int(color_math * num_colors) % num_colors]

                try:
                    # 1. Erase the tail
                    tail_y = y - lengths[x]
                    if 0 <= tail_y < max_y:
                        stdscr.addch(tail_y, x, ' ')

                    # 2. Turn the previous white head into the calculated gradient color
                    if 0 <= y < max_y:
                        stdscr.addch(y, x, random.choice(chars), curses.color_pair(color_idx))

                    # 3. Draw the new glowing white head
                    head_y = y + 1
                    if 0 <= head_y < max_y:
                        stdscr.addch(head_y, x, random.choice(chars), curses.color_pair(HEAD_PAIR) | curses.A_BOLD)
                except curses.error:
                    pass

                # Move drop down
                drops[x] += 1

                # Reset drop if it falls off screen
                if drops[x] - lengths[x] > max_y:
                    if random.random() > 0.4:
                        drops[x] = 0
                        lengths[x] = random.randint(5, int(max_y * 0.8))
                        speeds[x] = random.randint(1, 3)

        # --- Draw the "suahco4" Label ---
        # Drawn *after* the rain so it stays perfectly on top
        label_text = "  suahco4  "
        border_top = "+" + "-" * (len(label_text)) + "+"
        border_mid = "|" + label_text + "|"
        
        start_y = (max_y // 2) - 1
        start_x = (max_x // 2) - (len(border_top) // 2)

        if start_x > 0 and start_y > 0 and start_y + 2 < max_y:
            try:
                # Top border (Bold White)
                stdscr.addstr(start_y, start_x, border_top, curses.color_pair(HEAD_PAIR) | curses.A_BOLD)
                # Label (Black on White to stand out from the colorful background)
                stdscr.addstr(start_y + 1, start_x, border_mid, curses.color_pair(LABEL_PAIR) | curses.A_BOLD)
                # Bottom border (Bold White)
                stdscr.addstr(start_y + 2, start_x, border_top, curses.color_pair(HEAD_PAIR) | curses.A_BOLD)
            except curses.error:
                pass

        # Render frame
        stdscr.refresh()
        
        # Frame rate sleep
        time.sleep(0.025)
        frames += 1

        # Exit on any keypress
        if stdscr.getch() != -1:
            break

if __name__ == "__main__":
    try:
        curses.wrapper(main)
    except KeyboardInterrupt:
        pass
