# System Monitoring Script

## Overview
This Bash script monitors system resource usage, including disk, CPU, and memory utilization. It generates a report and optionally sends an alert if resource usage exceeds a specified threshold.

## Usage
```bash
./monitor.sh [-t threshold] [-f output_file]
```

### Options:
- `-t threshold` (optional): Set the disk usage threshold percentage (default: 80%).
- `-f output_file` (optional): Specify the output file for the report (default: `system_monitor.log`).

## Features
- Monitors disk usage and highlights partitions exceeding the specified threshold.
- Captures current CPU usage.
- Reports total, used, and free memory.
- Lists the top 5 memory-consuming processes.
- Saves the report to a log file.
- Sends an email alert if resource usage exceeds the threshold.

## Script Breakdown

### 1. **Setting Defaults**
```bash
THRESHOLD=80
OUTPUT_FILE="system_monitor.log"
```
Sets the default disk usage threshold to 80% and specifies the default log file.

### 2. **Parsing Command-Line Arguments**
```bash
while getopts ":t:f:" opt; do
  case $opt in
    t) THRESHOLD=$OPTARG;;
    f) OUTPUT_FILE=$OPTARG;;
    \?) echo "Invalid option: -$OPTARG" >&2; exit 1;;
  esac
done
```
Allows the user to override default values for disk threshold and output file.

### 3. **Generating Report Header**
```bash
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
REPORT="System Monitoring Report - $TIMESTAMP\n"
REPORT+="======================================\n\n"
```
Captures the current timestamp and initializes the report.

### 4. **Disk Usage Monitoring**
```bash
DISK_USAGE=$(df -h | awk 'NR==1 || /^\/dev\//')
echo "$DISK_USAGE" | while read -r line; do
  if [[ $line == /dev/* ]]; then
    USAGE_PERCENT=$(echo $line | awk '{print $5}' | tr -d '%')
    MOUNT_POINT=$(echo $line | awk '{print $6}')
    if [ "$USAGE_PERCENT" -ge "$THRESHOLD" ]; then
      REPORT+="Warning: $MOUNT_POINT is above ${THRESHOLD}% usage!\n"
      ALERT=1
    fi
  fi
done
```
Checks if disk usage exceeds the threshold and adds a warning if necessary.

### 5. **CPU and Memory Usage**
```bash
CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{usage=100 - $8} END {print usage}')
REPORT+="CPU Usage:\nCurrent CPU Usage: $CPU_USAGE%\n\n"
```
Captures current CPU usage.

```bash
MEM_TOTAL=$(free -h | awk '/^Mem:/ {print $2}')
MEM_USED=$(free -h | awk '/^Mem:/ {print $3}')
MEM_FREE=$(free -h | awk '/^Mem:/ {print $4}')
REPORT+="Memory Usage:\nTotal Memory: $MEM_TOTAL\nUsed Memory: $MEM_USED\nFree Memory: $MEM_FREE\n\n"
```
Reports total, used, and free memory.

### 6. **Top 5 Memory-Consuming Processes**
```bash
TOP_PROCESSES=$(ps aux --sort=-%mem | awk 'NR>1{printf "%-8s %-8s %-5s %s\n", $2, $1, $4, $11}' | head -5)
REPORT+="$TOP_PROCESSES\n"
```
Lists the top 5 processes consuming the most memory.

### 7. **Saving and Sending Alerts**
```bash
echo -e "$REPORT" > "$OUTPUT_FILE"
if [ "$ALERT" ]; then
  echo -e "$REPORT" | mail -s "System Monitoring Alert - $TIMESTAMP" youremail
fi
```
Saves the report to a file and sends an alert email if disk usage exceeds the threshold.

## Example Usage
```bash
./monitor.sh -t 90 -f my_log.log
```
This command sets the disk usage threshold to 90% and saves the report to `my_log.log`.

## Dependencies
- `df`, `top`, `awk`, `ps`, `mail`
- Ensure that the `mail` command is configured for email alerts.

## Conclusion
This script provides a simple yet effective way to monitor system resources and receive alerts when resource usage is high.


Here is a screenshot of the email sent

![email](https://github.com/user-attachments/assets/a4a85e3f-b7d1-4942-a717-657cb174aa02)

