import curses
import random
import time
import sys

# Generate Matrix Characters (ASCII + Katakana)
# Katakana unicode range is 0x30A0 to 0x30FF
CHARS = [chr(i) for i in range(33, 127)] + [chr(i) for i in range(0x30A0, 0x30FF)]

class Drop:
    def __init__(self, x, max_y):
        self.x = x
        self.max_y = max_y
        self.y = random.randint(-max_y, -1)
        self.length = random.randint(10, 30)
        self.speed = random.randint(1, 3)
        self.ticks = 0

    def update(self):
        # Control the speed of the drop
        self.ticks += 1
        if self.ticks >= self.speed:
            self.y += 1
            self.ticks = 0
            
            # Reset drop if it goes completely off screen
            if self.y - self.length > self.max_y:
                self.y = random.randint(-5, -1)
                self.length = random.randint(10, 30)
                self.speed = random.randint(1, 3)

    def draw(self, screen):
        # Draw the tail (erase the character at the very end of the drop)
        tail_y = self.y - self.length
        if 0 <= tail_y < self.max_y:
            try:
                screen.addstr(tail_y, self.x, " ")
            except curses.error:
                pass

        # Draw the body
        for i in range(1, self.length):
            body_y = self.y - i
            if 0 <= body_y < self.max_y:
                char = random.choice(CHARS)
                try:
                    # Green text for the body
                    screen.addstr(body_y, self.x, char, curses.color_pair(1))
                except curses.error:
                    pass

        # Draw the Head
        if 0 <= self.y < self.max_y:
            char = random.choice(CHARS)
            try:
                # White text for the head of the drop
                screen.addstr(self.y, self.x, char, curses.color_pair(2) | curses.A_BOLD)
            except curses.error:
                pass

def intro_sequence(screen):
    """Optional: The classic 'Wake up, Neo...' intro"""
    screen.clear()
    curses.curs_set(0)
    msg = "Wake up, Neo..."
    for i, char in enumerate(msg):
        screen.addstr(0, i, char, curses.color_pair(1))
        screen.refresh()
        time.sleep(0.15)
    time.sleep(1)
    screen.clear()

def main(screen):
    # Setup Colors
    curses.start_color()
    curses.use_default_colors()
    curses.init_pair(1, curses.COLOR_GREEN, -1)  # Green on transparent/black
    curses.init_pair(2, curses.COLOR_WHITE, -1)  # White on transparent/black
    
    # Hide cursor and make input non-blocking
    curses.curs_set(0)
    screen.nodelay(True)
    screen.timeout(0)

    # Play intro
    intro_sequence(screen)

    max_y, max_x = screen.getmaxyx()
    
    # Create a list of drops, placing one on almost every column
    # Step by 2 to leave space between columns (looks cleaner)
    drops = [Drop(x, max_y) for x in range(0, max_x, 2)]

    while True:
        # Handle terminal resizing gracefully
        new_max_y, new_max_x = screen.getmaxyx()
        if new_max_y != max_y or new_max_x != max_x:
            max_y, max_x = new_max_y, new_max_x
            screen.clear()
            # Re-generate drops for new screen size
            drops = [Drop(x, max_y) for x in range(0, max_x, 2)]

        # Check for user input to quit
        key = screen.getch()
        if key in [ord('q'), ord('Q'), 27]: # 27 is the ESC key
            break

        # Update and draw all drops
        for drop in drops:
            drop.update()
            drop.draw(screen)

        screen.refresh()
        time.sleep(0.04) # Adjust for overall animation speed

if __name__ == "__main__":
    try:
        # curses.wrapper handles initialization and safe teardown
        curses.wrapper(main)
    except KeyboardInterrupt:
        sys.exit(0)
