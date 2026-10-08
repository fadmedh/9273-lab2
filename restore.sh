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
    echo "Files currently in quarantine:"
    
    # Create an array of files in the quarantine directory
    files=("$QUARANTINE_DIR"/*)
    
    # Check if there are any actual files
    if [ ${#files[@]} -eq 0 ] || [ ! -e "${files[0]}" ]; then
        echo "No malicious files to review."
        exit 0
    fi
    
    # List files with numbers
    i=1
    for file in "${files[@]}"; do
        if [ -f "$file" ]; then
            echo "$i) $(basename "$file")"
            ((i++))
        fi
    done
    
    echo "----------------------------------------"
    read -p "Enter the number of the file to review (or type 'q' to quit): " choice
    
    # Allow user to quit
    if [ "$choice" = "q" ]; then
        echo "Exiting restore tool."
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
    
    echo "Selected file: $filename"
    echo "1) Restore this file back into $TARGET_DIR"
    echo "2) Permanently delete this file from quarantine"
    echo "3) Leave this file as-is and go back to the list"
    
    read -p "Choose an option (1-3): " option
    
    case $option in
        1)
            mv "$selected_file" "$TARGET_DIR/"
            # Add to whitelist (avoid duplicates)
            grep -qxF "$filename" whitelist.txt 2>/dev/null || echo "$filename" >> whitelist.txt
            echo "Restored $filename to $TARGET_DIR and added to whitelist."
            ;;
        2)
            rm "$selected_file"
            echo "$filename permanently deleted."
            ;;
        3)
            echo "Leaving file as-is."
            ;;
        *)
            echo "Invalid option. Going back to list."
            ;;
    esac
done