# Lab 2 - Simple Antivirus

This lab is a simple antivirus system implemented in Bash shell scripts.

## Contents
- antivirusd.sh: The main daemon script that monitors a directory, scans for malicious files, and moves them to quarantine.
- restore.sh: An interactive script to review quarantined files and either restore them or delete them permanently.
- Makefile: Automates running the daemon and the restore tool.

## Prerequisites
- Ubuntu Linux environment
- Bash shell
- Standard core utilities (cmp, ls, grep, cp, rm, mv)

## Detection Rules
- Flagged Extensions: .exe, .bat, .vbs, .scr, .ps1
- Flagged Keywords: virus, trojan, malware, worm, ransomware

## How to Run
1. Run the antivirus daemon:
   make run-antivirus

2. Run the restore tool:
   make restore

   ## Bonus 1: Cron Job Configuration

### Prerequisites
Before configuring the cron job, ensure the following:
1. **Execution Permissions:** The script must be executable. Run:
   ```bash
   chmod +x antivirus-cron.sh
   ```
2. **Absolute Paths:** You must know the full absolute paths to your script, monitor directory, and quarantine directory (e.g., `/home/os/9273_lab2/antivirus-cron.sh`). Cron does not understand relative paths (like `./`).
3. **Cron Service:** Ensure the cron daemon is running on your Linux machine.

### Step-by-Step Manual to Configure the Cron Job
1. Open your terminal.
2. Open the cron table editor by typing the following command and pressing Enter:
   ```bash
   crontab -e
   ```
   *(Note: If prompted, select an editor like `nano` by pressing `1`)*
3. Use the arrow keys to scroll to the very bottom of the file.
4. Add the following line to schedule the script to run every minute (the `sleep 23` inside the script will ensure it runs at exactly second 23):
   ```cron
   * * * * * /home/os/9273_lab2/antivirus-cron.sh /home/os/9273_lab2/test_dir /home/os/9273_lab2/malicious_dir
   ```
   
5. Save the file and exit. If using `nano`, press `Ctrl + O`, then `Enter` to save, and `Ctrl + X` to exit.
6. You can verify your cron job was added successfully by running: `crontab -l`

### Specific Cron Expression
To run this scan specifically on the **3rd Friday of the month at 12:31 am**, the cron expression is:
```cron
31 0 15-21 * 5
```
**Explanation:**
- `31`: Minute 31
- `0`: Hour 0 (12:00 AM)
- `15-21`: Day of the month (The 3rd week falls between the 15th and 21st)
- `*`: Every month
- `5`: Day of the week (Friday)

---

## Bonus 2: Whitelist Implementation

### How a File Gets Added to the Whitelist
When a file is flagged as a false positive, the user runs the `restore.sh` script. If the user chooses Option `1` (Restore this file), the script moves the file back to the monitored directory. Immediately after, it uses `grep` to check if the filename already exists in `whitelist.txt`. If it doesn't, it appends the filename to the whitelist. This ensures the file is marked as safe without creating duplicate entries.

### How the Daemon Checks the Whitelist
Inside both `antivirusd.sh` and `antivirus-cron.sh`, the `perform_scan` function processes each file in the directory. Before checking the file's extension or grepping its content for malicious keywords, the script first checks if `whitelist.txt` exists and if the current file's name is listed inside it. 
If a match is found, the script executes a `continue` statement, skipping the file entirely. Because `whitelist.txt` is saved on the disk, this memory persists across multiple runs and daemon restarts.