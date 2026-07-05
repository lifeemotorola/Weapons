import os
import sys

# Platform UI Colors
C = "\033[96m"
G = "\033[92m"
R = "\033[91m"
W = "\033[0m"

# The Engine Database Rules
# (Native tools use pkg install, Git tools use git clone, etc.)
def get_install_command(tool):
    python_tools = ['sherlock', 'sqlmap', 'recon-ng', 'droopescan', 'wpscan']
    git_tools = ['zphisher', 'nexphisher', 'hiddeneye', 'fsociety', 'lazymux']
    go_tools = ['nuclei', 'amass', 'subfinder', 'httpx']
    api_tools = ['termux-battery-status', 'termux-camera-photo', 'termux-api']

    if tool in python_tools:
        return f"pkg install python -y && pip install {tool}"
    elif tool in git_tools:
        return f"git clone https://github.com/search?q={tool} \n# (Find the specific repo and clone it)"
    elif tool in go_tools:
        return f"pkg install golang -y && go install -v github.com/projectdiscovery/{tool}/v2/cmd/{tool}@latest"
    elif tool in api_tools:
        return f"pkg install termux-api -y"
    else:
        return f"pkg install {tool} -y"

def get_usage(tool):
    return f"{tool} -h  OR  {tool} --help  OR  man {tool}"

def clear():
    os.system('clear')

def main_menu():
    clear()
    print(f"{C}=========================================")
    print(f"        TERMUX FORGE - 500+ TOOLS        ")
    print(f"========================================={W}")
    print(f"1. {G}Search for a Tool{W}")
    print(f"2. {G}Learn How to Install/Use{W}")
    print(f"3. {G}Exit Platform{W}")
    print(f"{C}========================================={W}")
    
    choice = input("Enter choice (1-3): ")
    if choice == '1':
        search_tool()
    elif choice == '2':
        install_menu()
    elif choice == '3':
        sys.exit()
    else:
        main_menu()

def search_tool():
    clear()
    query = input(f"{C}Enter tool name to search in the 500+ database: {W}").lower()
    print(f"\n{G}[+] Information for: {query.upper()}{W}")
    print("-" * 40)
    print(f"{C}Suggested Installation:{W} \n{get_install_command(query)}")
    print(f"\n{C}How to Use:{W} \n{get_usage(query)}")
    print("-" * 40)
    input(f"\n{R}Press Enter to return to menu...{W}")
    main_menu()

def install_menu():
    clear()
    print(f"{C}--- UNIVERSAL INSTALLATION GUIDE ---{W}")
    print("1. Native Termux: pkg install [tool]")
    print("2. Python Pip:    pip install [tool]")
    print("3. Git Hub Repos: git clone [url]")
    print("4. Go Lang:       go install [url]")
    print("5. Ruby Gems:     gem install [tool]")
    print("\nTo see this applied to a specific tool, use the Search function.")
    input(f"\n{R}Press Enter to return to menu...{W}")
    main_menu()

if __name__ == "__main__":
    try:
        main_menu()
    except KeyboardInterrupt:
        print(f"\n{R}Exiting Termux Forge...{W}")
        sys.exit()
