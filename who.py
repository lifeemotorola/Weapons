import os
import random
import time
import shutil
import sys

# Windows color support
if os.name == "nt":
    os.system("")

# Matrix characters
chars = "01アイウエオカキクケコサシスセソABCDEFGHIJKLMNOPQRSTUVWXYZ"

# Get terminal size
columns, rows = shutil.get_terminal_size()

# Create drop positions
drops = [random.randint(0, rows) for _ in range(columns)]

label = "SUAHCO4"

def clear():
    os.system("cls" if os.name == "nt" else "clear")

try:
    while True:
        clear()

        output = []

        for y in range(rows):
            line = ""
            for x in range(columns):
                if drops[x] == y:
                    line += random.choice(chars)
                else:
                    line += " "
            output.append(line)

        # Insert centered label
        label_y = rows // 2
        label_x = (columns - len(label)) // 2
        if 0 <= label_y < rows:
            row_list = list(output[label_y])
            for i, ch in enumerate(label):
                if 0 <= label_x + i < columns:
                    row_list[label_x + i] = ch
            output[label_y] = "".join(row_list)

        # Print in green
        print("\033[92m" + "\n".join(output) + "\033[0m")

        # Move drops
        for i in range(len(drops)):
            if drops[i] > rows and random.random() > 0.975:
                drops[i] = 0
            drops[i] += 1

        time.sleep(0.05)

except KeyboardInterrupt:
    clear()
    sys.exit()
