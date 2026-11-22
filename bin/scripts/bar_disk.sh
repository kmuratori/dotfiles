#!/bin/sh
# Clean, aligned disk management summary

sep() {
  printf "\n%s\n" "------------------------------------------------------------"
}

header() {
  printf "\n%-60s\n" "$1"
}

kv() {
  printf "  %-22s : %s\n" "$1" "$2"
}

printf "\nDISK STATUS REPORT\n"
kv "Date" "$(date)"

sep
header "FILESYSTEM USAGE"
df -hT -x tmpfs -x devtmpfs | awk '
NR==1 { printf "  %-20s %-7s %-8s %-8s %-6s %-s\n", $1,$2,$3,$4,$6,$7; next }
{ printf "  %-20s %-7s %-8s %-8s %-6s %-s\n", $1,$2,$3,$4,$6,$7 }
'

sep
header "INODE USAGE"
df -i -x tmpfs -x devtmpfs | awk '
NR==1 { printf "  %-20s %-8s %-8s %-8s %-6s %-s\n", $1,$2,$3,$4,$5,$6; next }
{ printf "  %-20s %-8s %-8s %-8s %-6s %-s\n", $1,$2,$3,$4,$5,$6 }
'

sep
header "CRITICAL FILESYSTEMS (>=90%)"
df -h -x tmpfs -x devtmpfs | awk '
NR>1 {
  gsub("%","",$5)
  if ($5 >= 90)
    printf "  %-20s %-6s %-s\n", $1, $5"%", $6
}'
awk 'BEGIN{exit !found}' found=1 || printf "  None\n"

sep
header "BLOCK DEVICES"
lsblk -o NAME,TYPE,SIZE,FSTYPE,MOUNTPOINT | awk '
NR==1 { printf "  %-10s %-8s %-8s %-8s %-s\n",$1,$2,$3,$4,$5; next }
{ printf "  %-10s %-8s %-8s %-8s %-s\n",$1,$2,$3,$4,$5 }
'

sep
header "MOUNTED FILESYSTEMS"
mount | awk '
{ printf "  %-25s -> %-25s (%s)\n", $1, $3, $5 }
'

sep
header "SUMMARY"
df -h -x tmpfs -x devtmpfs | awk '
NR>1 { printf "  %-25s : %s used\n", $6, $5 }
'

sep