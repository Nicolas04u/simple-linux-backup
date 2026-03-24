# simple-linux-backup

A lightweight, reliable Bash script designed for junior SysAdmins and freelancers to automate backups on Linux servers (RHEL/Rocky Linux/AlmaLinux focus, adaptable for Debian/Ubuntu).

This script implements a "Dump & Sync" strategy, perfect for securing small business websites (WordPress, e-commerce) and professional firm data.

## 🚀 Features

* **MySQL/MariaDB Dump:** Consistent database backups using `mysqldump`.
* **File Archiving:** Creates compressed `.tar.gz` archives of specific web directories or data folders.
* **Remote Sync:** Uses `rsync` over SSH to securely transfer backups to a remote storage server (incremental, saves bandwidth).
* **Automated Retention:** Automatically finds and deletes backups older than 7 days on the local server to save disk space.
* **RHCSA Compliant:** Built using standard Linux tools (find, tar, rsync, bash).

## 📋 Prerequisites

Before running the script, ensure you have:
* Root or sudo access on the source server.
* `mysql-client` and `rsync` installed.
* SSH Key-based authentication configured between the source and remote storage server.

## 🔧 Installation & Usage

1.  **Clone the script:**
    ```bash
    curl -O https://raw.githubusercontent.com/Nicolas04u/simple-linux-backup/refs/heads/main/backup_stack.sh
    ```
2.  **Make it executable:**
    ```bash
    chmod +x backup_stack.sh
    ```
3.  **Configure:** Edit the variables at the top of the script (DB credentials, paths, remote SSH user/IP).
4.  **Test run:**
    ```bash
    ./backup_stack.sh
    ```
5.  **Automate:** Add to crontab for daily execution.

---
**Developed by [Nicolas Schirosi]**
*Freelance Linux SysAdmin based in Pisa (IT), relocating to Prague (CZ).*
*Currently studying for RHCSA certification.*
[Inserisci qui il link al tuo LinkedIn se ce l'hai, altrimenti cancella questa riga]
