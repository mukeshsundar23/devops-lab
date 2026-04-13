#!/bin/bash

PATH=/usr/sbin:/usr/bin:/sbin:/bin

[ -f "$REPORT_FILE" ] && tail -n 1000 "$REPORT_FILE" > "${REPORT_FILE}.tmp" && mv "${REPORT_FILE}.tmp" "$REPORT_FILE"

REPORT_FILE="/var/log/sysreport.txt"
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")


echo "==============================" >> $REPORT_FILE
echo "System Report - $TIMESTAMP" >> $REPORT_FILE
echo "==============================" >> $REPORT_FILE

echo "" >> $REPORT_FILE
echo "---- SUMMARY ----" >> $REPORT_FILE

LOAD=$(awk '{print $1}' /proc/loadavg)
DISK=$(df / | awk 'NR==2 {print $5}')
CORES=$(nproc)

echo "Load: $LOAD (Cores: $CORES) | Disk Usage: $DISK" >> $REPORT_FILE
STATUS="OK"

# Load check
if (( $(echo "$LOAD > $CORES" | bc -l) )); then
  STATUS="HIGH LOAD"
fi

# Disk check
DISK_PCT=$(df / | awk 'NR==2 {gsub("%",""); print $5}')
if [ "$DISK_PCT" -gt 80 ]; then
  STATUS="DISK WARNING"
fi

echo "Status: $STATUS" >> $REPORT_FILE

echo "" >> $REPORT_FILE
echo "Hostname: $(hostname)" >> $REPORT_FILE
echo "Kernel: $(uname -r)" >> $REPORT_FILE


echo "" >> $REPORT_FILE
echo "---- CPU ----" >> $REPORT_FILE

awk '/^cpu / {
  total = $2+$3+$4+$5+$6+$7+$8
  idle = $5
  usage = (1 - idle/total) * 100
  printf "CPU Usage: %.2f%%\n", usage
}' /proc/stat >> $REPORT_FILE


echo "" >> $REPORT_FILE
echo "---- MEMORY ----" >> $REPORT_FILE

free -h >> $REPORT_FILE

awk '
/MemTotal/ {total=$2}
/MemAvailable/ {available=$2}
END {
  used = total - available
  printf "Used Memory: %.2f MB / %.2f MB\n", used/1024, total/1024
}' /proc/meminfo >> $REPORT_FILE


echo "" >> $REPORT_FILE
echo "---- DISK ----" >> $REPORT_FILE

printf "%-40s %-6s %-6s %-6s %-5s %s\n" "Filesystem" "Size" "Used" "Avail" "Use%" "Mount" >> $REPORT_FILE

df -h --output=source,size,used,avail,pcent,target | grep '^/dev/' | column -t >> $REPORT_FILE

echo "" >> $REPORT_FILE
df -h / | awk 'NR==2 {
  printf "Root Usage: %s / %s (%s)\n", $3, $2, $5
}' >> $REPORT_FILE


echo "" >> $REPORT_FILE
echo "---- TOP PROCESSES ----" >> $REPORT_FILE

ps -eo pid,user,%cpu,%mem,comm --sort=-%cpu | head -n 10 >> $REPORT_FILE


echo "" >> $REPORT_FILE
echo "---- LISTENING PORTS (EXPOSED) ----" >> $REPORT_FILE

ss -tuln | awk '
NR>1 && $1=="tcp" {
  if ($5 ~ /^\[::\]:22/) next
  if ($5 !~ /^127/ && $5 !~ /::1/)
    printf "%-5s %-22s\n", $1, $5
}' >> $REPORT_FILE

echo "" >> $REPORT_FILE

ss -tuln | awk '
NR>1 && $1=="tcp" && $5 ~ /^0.0.0.0/ {
  print "!!! WARNING: Publicly exposed ->", $5
}' >> $REPORT_FILE


echo "" >> $REPORT_FILE
echo "---- LOGGED IN USERS ----" >> $REPORT_FILE

who >> $REPORT_FILE


echo "" >> $REPORT_FILE
echo "---- UPTIME ----" >> $REPORT_FILE

uptime >> $REPORT_FILE

awk '{print "Load Average:", $1, $2, $3}' /proc/loadavg >> $REPORT_FILE

echo "" >> $REPORT_FILE
echo "========================================" >> $REPORT_FILE

if [ "$STATUS" != "OK" ]; then
  exit 1
else
  exit 0
fi