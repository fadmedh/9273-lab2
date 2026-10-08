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