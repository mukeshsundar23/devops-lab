#!/bin/bash

echo "===== CPU ====="
awk '/^cpu / {
  total = $2+$3+$4+$5+$6+$7+$8
  idle = $5
  print "CPU Usage:", (1 - idle/total) * 100 "%"
}' /proc/stat

echo ""
echo "===== MEMORY ====="
free -h

echo ""
echo "===== DISK ====="
df -h /