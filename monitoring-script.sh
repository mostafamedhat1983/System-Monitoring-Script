#!/bin/bash

# Default threshold and output file
THRESHOLD=80
OUTPUT_FILE="system_monitor.log"

# Colors for warnings
RED='\033[0;31m'
NC='\033[0m' # No Color

# Parse optional arguments
while getopts ":t:f:" opt; do
  case $opt in
    t) THRESHOLD=$OPTARG;;
    f) OUTPUT_FILE=$OPTARG;;
    \?) echo "Invalid option: -$OPTARG" >&2; exit 1;;
  esac
done

# Get current timestamp
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# Initialize the report
REPORT="System Monitoring Report - $TIMESTAMP\n"
REPORT+="======================================\n\n"

# Disk Usage
REPORT+="Disk Usage:\n"
DISK_USAGE=$(df -h | awk 'NR==1 || /^\/dev\//')
REPORT+="$DISK_USAGE\n\n"

# Check disk usage against threshold
echo "$DISK_USAGE" | while read -r line; do
  if [[ $line == /dev/* ]]; then
    USAGE_PERCENT=$(echo $line | awk '{print $5}' | tr -d '%')
    MOUNT_POINT=$(echo $line | awk '{print $6}')
    if [ "$USAGE_PERCENT" -ge "$THRESHOLD" ]; then
      REPORT+="${RED}Warning: $MOUNT_POINT is above ${THRESHOLD}% usage!${NC}\n"
      ALERT=1
    fi
  fi
done

REPORT+="\n"

# CPU Usage
CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{usage=100 - $8} END {print usage}')
REPORT+="CPU Usage:\nCurrent CPU Usage: $CPU_USAGE%\n\n"

# Memory Usage
MEM_TOTAL=$(free -h | awk '/^Mem:/ {print $2}')
MEM_USED=$(free -h | awk '/^Mem:/ {print $3}')
MEM_FREE=$(free -h | awk '/^Mem:/ {print $4}')
REPORT+="Memory Usage:\nTotal Memory: $MEM_TOTAL\nUsed Memory: $MEM_USED\nFree Memory: $MEM_FREE\n\n"

# Top 5 Memory-Consuming Processes
REPORT+="Top 5 Memory-Consuming Processes:\n"
REPORT+="PID      USER     %MEM  COMMAND\n"
TOP_PROCESSES=$(ps aux --sort=-%mem | awk 'NR>1{printf "%-8s %-8s %-5s %s\n", $2, $1, $4, $11}' | head -5)
REPORT+="$TOP_PROCESSES\n"

# Save report to file
echo -e "$REPORT" > "$OUTPUT_FILE"

# Send email alert if thresholds are breached
if [ "$ALERT" ]; then
  echo -e "$REPORT" | mail -s "System Monitoring Alert - $TIMESTAMP" youremail
fi
