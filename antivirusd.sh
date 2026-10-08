#!/bin/bash

# 1. Check if the user provided exactly 3 arguments
if [ $# -ne 3 ]; then
    echo "Error: You must provide exactly 3 arguments."
    echo "Usage: $0 <dir> <malicious_dir> <interval-secs>"
    exit 1
fi

# 2. Assign arguments to variables with clear names
MONITOR_DIR=$1
QUARANTINE_DIR=$2
INTERVAL=$3

# 3. Print a message to know the script started
echo "Starting Antivirus Daemon..."
echo "Monitoring: $MONITOR_DIR"
echo "Quarantine: $QUARANTINE_DIR"
echo "Interval: $INTERVAL seconds"

# --- SCAN FUNCTION ---
# This function checks for malicious extensions and keywords
perform_scan() {
    # Loop through all files in the monitored directory
    for file in "$MONITOR_DIR"/*; do
        # Skip if directory is empty or it is not a regular file
        if [ ! -f "$file" ]; then
            continue
        fi
        
        # Extract just the filename without the full path
        filename=$(basename "$file")

        # --- WHITELIST CHECK ---
        if [ -f "whitelist.txt" ] && grep -qxF "$filename" "whitelist.txt" 2>/dev/null; then
            continue
        fi
        # -----------------------
        
        is_malicious=0
        
        # Check for flagged extensions
        case "$filename" in
            *.exe|*.bat|*.vbs|*.scr|*.ps1)
                is_malicious=1
                ;;
        esac
        
        # Check for flagged content (case-insensitive) if not already flagged
        if [ $is_malicious -eq 0 ]; then
            # grep -q is quiet mode, -i is case-insensitive, -E allows multiple words
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
# ---------------------

# 4. Initial scan (required before taking the first snapshot)
echo "Performing initial scan..."
perform_scan

# 5. Take the initial snapshot of the directory and save it
ls -l "$MONITOR_DIR" > directory-info.last

# 6. Infinite loop to keep the script running as a daemon
while true; do
    # Pause the script for the specified interval
    sleep "$INTERVAL"

    # Take a new snapshot of the directory
    ls -l "$MONITOR_DIR" > directory-info.new

    # Compare the two snapshots (! means if they are NOT identical)
    if ! cmp -s directory-info.last directory-info.new; then
        echo "Change detected! Directory was modified."
        
        # Run the scan again because a change happened
        perform_scan

        # Regenerate snapshot correctly as per instructions
        ls -l "$MONITOR_DIR" > directory-info.last
    fi
done