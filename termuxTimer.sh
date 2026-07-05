#!/bin/bash
# termux-pomodoro.sh
# Purpose: A Pomodoro timer that uses Android native notifications and vibrations.
# Requires: pkg install termux-api

WORK_MINS=25
REST_MINS=5

countdown() {
    local mins=$1
    local msg=$2
    local secs=$((mins * 60))
    
    while [ $secs -gt 0 ]; do
        echo -ne "$msg: $(date -u --date @$secs +%H:%M:%S)\r"
        sleep 1
        : $((secs--))
    done
    echo ""
}

echo "🍅 Starting Termux Pomodoro Timer 🍅"

while true; do
    # Work session
    termux-notification --title "Pomodoro" --content "Time to work! ($WORK_MINS mins)" --id 1
    termux-vibrate -d 500
    countdown $WORK_MINS "💻 Focus Time"
    
    # Rest session
    termux-notification --title "Pomodoro" --content "Time to rest! ($REST_MINS mins)" --id 1
    termux-vibrate -d 1000 -f
    countdown $REST_MINS "☕ Break Time"
    
    read -p "Start next cycle? (Y/n): " choice
    if [[ "$choice" == "n" || "$choice" == "N" ]]; then
        echo "Great job! Exiting."
        break
    fi
done
