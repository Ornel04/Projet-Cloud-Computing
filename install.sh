#!/bin/bash

set -e  # Quitte le script si une commande échoue

ZABBIX_DB_PASSWORD="password"
ZABBIX_DB_NAME="zabbix"
ZABBIX_DB_USER="zabbix"
MYSQL_ROOT_PASSWORD=""

sudo apt update && sudo apt upgrade -y

sudo apt install -y mariadb-server

sudo apt install -y phpmyadmin php-mbstring php-zip php-gd php-json php-curl
sudo phpenmod mbstring
sudo systemctl restart apache2

sudo mysql <<EOF
CREATE USER IF NOT EXISTS 'user'@'localhost' IDENTIFIED BY 'mdp';
GRANT ALL PRIVILEGES ON *.* TO 'user'@'localhost' WITH GRANT OPTION;
FLUSH PRIVILEGES;
EOF

wget -q https://repo.zabbix.com/zabbix/7.2/release/debian/pool/main/z/zabbix-release/zabbix-release_latest_7.2+debian12_all.deb
sudo dpkg -i zabbix-release_latest_7.2+debian12_all.deb
sudo apt update

sudo apt install -y zabbix-server-mysql zabbix-frontend-php zabbix-apache-conf zabbix-sql-scripts zabbix-agent

sudo mysql <<EOF
CREATE DATABASE IF NOT EXISTS $ZABBIX_DB_NAME CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;
CREATE USER IF NOT EXISTS '$ZABBIX_DB_USER'@'localhost' IDENTIFIED BY '$ZABBIX_DB_PASSWORD';
GRANT ALL PRIVILEGES ON $ZABBIX_DB_NAME.* TO '$ZABBIX_DB_USER'@'localhost';
SET GLOBAL log_bin_trust_function_creators = 1;
FLUSH PRIVILEGES;
EOF

# Import de la structure initiale si aucune sauvegarde n’est fournie
if [ -f "zabbix_backup_2025-05-29.sql" ]; then
    echo " Restauration de la sauvegarde Zabbix..."
    sudo mysql -u root $ZABBIX_DB_NAME < zabbix_backup_2025-05-29.sql
else
    echo "Import du schéma de base Zabbix..."
    zcat /usr/share/zabbix-sql-scripts/mysql/server.sql.gz | sudo mysql --default-character-set=utf8mb4 -u $ZABBIX_DB_USER -p$ZABBIX_DB_PASSWORD $ZABBIX_DB_NAME
fi

# Désactivation de log_bin_trust_function_creators
sudo mysql -e "SET GLOBAL log_bin_trust_function_creators = 0;"

echo "Configuration du mot de passe dans zabbix_server.conf..."
sudo sed -i "s/^# DBPassword=.*/DBPassword=$ZABBIX_DB_PASSWORD/" /etc/zabbix/zabbix_server.conf
sudo sed -i "/^DBPassword=/!b;n;c\DBPassword=$ZABBIX_DB_PASSWORD" /etc/zabbix/zabbix_server.conf || echo "DBPassword=$ZABBIX_DB_PASSWORD" | sudo tee -a /etc/zabbix/zabbix_server.conf

echo "Redémarrage et activation des services..."
sudo systemctl restart zabbix-server zabbix-agent apache2
sudo systemctl enable zabbix-server zabbix-agent apache2

echo "Installation terminée avec succès."