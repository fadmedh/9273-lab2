#!/bin/bash

# 1. Check if the user provided the required 2 arguments
if [ $# -ne 2 ]; then
    echo "Error: You must provide exactly 2 arguments."
    echo "Usage: $0 <dir> <malicious_dir>"
    exit 1
fi

TARGET_DIR=$1
QUARANTINE_DIR=$2

# Check if quarantine directory exists and is not empty
if [ ! -d "$QUARANTINE_DIR" ] || [ -z "$(ls -A "$QUARANTINE_DIR")" ]; then
    echo "No malicious files to review."
    exit 0
fi

while true; do
    echo "----------------------------------------"
    echo "Choose a file:"

    # Create an array of files in the quarantine directory
    files=("$QUARANTINE_DIR"/*)

    # Check if there are any actual files
    if [ ${#files[@]} -eq 0 ] || [ ! -e "${files[0]}" ]; then
        echo "No malicious files to review."
        exit 0
    fi

    # List files with numbers (Modified to N: name)
    i=1
    for file in "${files[@]}"; do
        if [ -f "$file" ]; then
            echo "$i: $(basename "$file")"
            ((i++))
        fi
    done

    echo "----------------------------------------"
    # Modified prompt to match the "> " format
    read -p "> " choice

    # Allow user to quit (kept this as an extra safety, though not strictly required by TA)
    if [ "$choice" = "q" ]; then
        break
    fi

    # Validate the choice
    if ! [[ "$choice" =~ ^[0-9]+$ ]] || [ "$choice" -lt 1 ] || [ "$choice" -ge "$i" ]; then
        echo "Invalid selection. Please try again."
        continue
    fi

    # Get the selected file path
    selected_file="${files[$((choice-1))]}"
    filename=$(basename "$selected_file")

    # Modified options strictly to TA's format
    echo "For $filename:"
    echo "1: Restore this file back into dir (it was a false positive)"
    echo "2: Permanently delete this file from malicious_dir (it was genuinely malicious)"
    echo "3: Go back"

    read -p "> " option

    case $option in
        1)
            mv "$selected_file" "$TARGET_DIR/"
            # Add to whitelist (avoid duplicates)
            grep -qxF "$filename" whitelist.txt 2>/dev/null || echo "$filename" >> whitelist.txt
            echo "Restored $filename"
            ;;
        2)
            rm "$selected_file"
            echo "Deleted $filename"
            ;;
        3)
            # Just loop back
            ;;
        *)
            echo "Invalid option."
            ;;
    esac
done