#!/bin/bash

# 1. Check if the user provided exactly 2 arguments
if [ $# -ne 2 ]; then
    echo "Error: You must provide exactly 2 arguments."
    echo "Usage: $0 <dir> <malicious_dir>"
    exit 1
fi

MONITOR_DIR=$1
QUARANTINE_DIR=$2

# Sleep for 23 seconds to satisfy the second 23 requirement when triggered by cron
sleep 23

# --- SCAN FUNCTION ---
perform_scan() {
    for file in "$MONITOR_DIR"/*; do
        if [ ! -f "$file" ]; then
            continue
        fi
        
        filename=$(basename "$file")

        # Whitelist check
        if [ -f "whitelist.txt" ] && grep -qxF "$filename" "whitelist.txt" 2>/dev/null; then
            continue
        fi
        
        is_malicious=0
        
        # Check for flagged extensions
        case "$filename" in
            *.exe|*.bat|*.vbs|*.scr|*.ps1)
                is_malicious=1
                ;;
        esac
        
        # Check for flagged content
        if [ $is_malicious -eq 0 ]; then
            if grep -q -iE "virus|trojan|malware|worm|ransomware" "$file" 2>/dev/null; then
                is_malicious=1
            fi
        fi
        
        # Quarantine and delete if malicious
        if [ $is_malicious -eq 1 ]; then
            echo "$filename is malicious and it is DELETED"
            cp "$file" "$QUARANTINE_DIR/"
            rm "$file"
        fi
    done
}

# Run the single scan
perform_scan