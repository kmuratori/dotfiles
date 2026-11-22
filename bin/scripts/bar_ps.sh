#!/bin/sh
# System state summary using ps only (plus POSIX tools)

echo "=== SYSTEM SUMMARY ==="
echo "Date        : $(date)"
echo "Uptime      : $(uptime | sed 's/.*up \([^,]*\),.*/\1/')"
echo

# Total processes
TOTAL=$(ps -e --no-headers | wc -l)
RUNNING=$(ps -e -o stat= | grep -c '^R')
SLEEPING=$(ps -e -o stat= | grep -c '^S')
STOPPED=$(ps -e -o stat= | grep -c '^T')
ZOMBIES=$(ps -e -o stat= | grep -c '^Z')

echo "Processes:"
echo "  Total     : $TOTAL"
echo "  Running   : $RUNNING"
echo "  Sleeping  : $SLEEPING"
echo "  Stopped   : $STOPPED"
echo "  Zombies   : $ZOMBIES"
echo

# CPU usage (top processes)
echo "Top CPU consumers:"
ps -eo pid,user,comm,%cpu --sort=-%cpu | head -n 6
echo

# Memory usage (top processes)
echo "Top memory consumers:"
ps -eo pid,user,comm,%mem --sort=-%mem | head -n 6
echo

# Per-user process count
echo "Processes per user:"
ps -eo user= | sort | uniq -c | sort -nr
echo

# Thread count
THREADS=$(ps -e -o nlwp= | awk '{sum+=$1} END {print sum}')
echo "Total threads: $THREADS"
echo

# Zombies detail (if any)
if [ "$ZOMBIES" -gt 0 ]; then
  echo "Zombie processes:"
  ps -eo pid,ppid,user,comm,stat | awk '$5 ~ /^Z/'
else
  echo "No zombie processes detected."
fi

echo
echo "=== END ==="
