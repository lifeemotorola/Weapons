#!/bin/bash
# termux-battery-logger.sh
# Purpose: Logs battery stats to a CSV file every 60 seconds.
# Requires: pkg install termux-api jq

LOG_FILE="battery_log_$(date +%Y%m%d).csv"
INTERVAL=60

# Check for required packages
if ! command -v jq &> /dev/null; then
    echo "[!] jq is not installed. Run: pkg install jq"
    exit 1
fi

# Create CSV header if file doesn't exist
if [ ! -f "$LOG_FILE" ]; then
    echo "Timestamp,Percentage,Temperature(C),Status" > "$LOG_FILE"
fi

echo "📊 Logging battery data to $LOG_FILE every $INTERVAL seconds."
echo "Press CTRL+C to stop."

while true; do
    # Fetch data from Termux API
    BATTERY_INFO=$(termux-battery-status)
    
    # Parse JSON output using jq
    PERCENT=$(echo "$BATTERY_INFO" | jq '.percentage')
    TEMP=$(echo "$BATTERY_INFO" | jq '.temperature')
    STATUS=$(echo "$BATTERY_INFO" | jq -r '.status')
    TIMESTAMP=$(date +%H:%M:%S)
    
    # Append to CSV
    echo "$TIMESTAMP,$PERCENT,$TEMP,$STATUS" >> "$LOG_FILE"
    
    # Show inline update
    echo -ne "Last logged at $TIMESTAMP: ${PERCENT}% | ${TEMP}°C | $STATUS \r"
    
    sleep $INTERVAL
done
