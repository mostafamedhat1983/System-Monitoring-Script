System Monitor Script
This script is designed to monitor key system metrics, including disk usage, CPU usage, memory usage, and running processes. It generates a report and can send email alerts if specified thresholds are breached. The script is intended to be run as a cron job for regular monitoring.

Features
Disk Usage Monitoring: Reports the percentage of disk space used for each mounted partition and warns if usage exceeds a specified threshold.

CPU Usage Monitoring: Displays the current CPU usage as a percentage.

Memory Usage Monitoring: Shows total, used, and free memory.

Running Processes: Displays the top 5 memory-consuming processes.

Report Generation: Saves the collected information into a log file.

Customizable Thresholds: Allows the user to specify a disk usage warning threshold and output file name via command-line arguments.

Email Alerts: Sends an email if any thresholds are breached (requires email configuration).

Here is a screenshot of the email sent
![Alt text]([https://assets.digitalocean.com/articles/alligator/boo.svg](https://drive.google.com/file/d/17-iCVGLVMhfi7uY49CNP0m9BpGA6COfi/view?usp=sharing) "a title")
