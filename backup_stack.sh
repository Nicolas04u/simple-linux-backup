#!/bin/bash

# ==============================================================================
# PROJECT: simple-linux-backup
# DESCRIPTION: Automated File & MySQL/MariaDB backup with remote rsync and retention.
# AUTHOR: Nicolas - Freelance Linux SysAdmin
# ==============================================================================

# Abilita lo strict mode: ferma lo script se un comando fallisce
set -e
set -o pipefail

cleanup() {
    local exit_code=$?
    rm -f "${STAGING_DIR}/db_dump_${TIMESTAMP}.sql"
    if [ $exit_code -ne 0 ]; then
        echo "[$(date +'%Y-%m-%d %H:%M:%S')] [ERRORE] Backup fallito con codice ${exit_code}" | \
            mail -s "[BACKUP FAIL] ${CLIENT_ID} - $(date +'%Y-%m-%d')" "${ALERT_EMAIL}"
    fi
}
trap cleanup EXIT

# --- 1. CONFIGURAZIONE ---
CLIENT_ID="cliente_acme"
TIMESTAMP=$(date +%Y-%m-%d_%H%M)
STAGING_DIR="/var/backups/${CLIENT_ID}_staging" # Cartella di lavoro sicura
WEB_ROOT="/var/www/html"                        # Percorso assoluto root del sito
REMOTE_HOST="backup_user@192.168.1.100"
REMOTE_DEST="${REMOTE_HOST}:/home/backup_user/storage/${CLIENT_ID}/"
ALERT_EMAIL="tua@email.com"
DB_NAME="db_cliente"
# NOTA: Le credenziali DB devono stare in ~/.my.cnf dell'utente che lancia lo script

# --- 2. PREPARAZIONE ---
echo "[$(date +'%Y-%m-%d %H:%M:%S')] Avvio procedura di backup per ${CLIENT_ID}..."
mkdir -p "${STAGING_DIR}"

# --- 3. DUMP DEL DATABASE ---
echo "[*] Esecuzione dump del database: ${DB_NAME}..."
# --single-transaction garantisce consistenza senza lockare le tabelle InnoDB
mysqldump --single-transaction "${DB_NAME}" > "${STAGING_DIR}/db_dump_${TIMESTAMP}.sql"

# --- 4. CREAZIONE ARCHIVIO COMPRESSO ---
echo "[*] Compressione dei file web e del database..."
ARCHIVE_NAME="full_backup_${TIMESTAMP}.tar.gz"

# Il flag -C cambia directory per evitare percorsi assoluti all'interno dell'archivio
tar -czf "${STAGING_DIR}/${ARCHIVE_NAME}" \
    -C "${WEB_ROOT}" . \
    -C "${STAGING_DIR}" "./db_dump_${TIMESTAMP}.sql"
tar -tzf "${STAGING_DIR}/${ARCHIVE_NAME}" > /dev/null

# --- 5. SINCRONIZZAZIONE REMOTA ---
echo "[*] Trasferimento sicuro al server di storage..."
# -a (archive), -v (verbose), -z (compress in transit), -e (specifica SSH)
rsync -avz -e "ssh -o StrictHostKeyChecking=yes" "${STAGING_DIR}/${ARCHIVE_NAME}" "${REMOTE_DEST}"

ssh "${REMOTE_HOST}" \
    "find /home/backup_user/storage/${CLIENT_ID}/ -type f -name '*.tar.gz' -mtime +7 -delete"

# --- 6. ROTAZIONE (RETENTION POLICY LOCALE) ---
echo "[*] Pulizia dei backup locali più vecchi di 7 giorni..."
find "${STAGING_DIR}" -type f -name "*.tar.gz" -mtime +7 -exec rm -f {} \;

echo "[$(date +'%Y-%m-%d %H:%M:%S')] Backup completato con successo."
