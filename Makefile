# Define variables for directories and interval
DIR = test_dir
MALICIOUS_DIR = malicious_dir
INTERVAL = 10

# Pre-build target to create the quarantine directory if it doesn't exist
$(MALICIOUS_DIR):
	mkdir -p $(MALICIOUS_DIR)

# Target to run the antivirus daemon
run-antivirus: $(MALICIOUS_DIR)
	./antivirusd.sh $(DIR) $(MALICIOUS_DIR) $(INTERVAL)

# Target to run the restore tool
restore: $(MALICIOUS_DIR)
	./restore.sh $(DIR) $(MALICIOUS_DIR)