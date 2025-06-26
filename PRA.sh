sudo apt update && sudo apt upgrade -y

sudo apt install mariadb-server -y
sudo systemctl status mariadb
sudo mysql -u root -p


sudo apt install phpmyadmin php-mbstring php-zip php-gd php-json php-curl -y
sudo phpenmod mbstring
sudo systemctl restart apache2

CREATE USER 'user'@'localhost' IDENTIFIED BY 'mdp'; 
GRANT ALL PRIVILEGES ON *.* TO 'user'@'localhost' WITH GRANT OPTION; 

http://localhost/phpmyadmin


installer zabbix 12: https://www.zabbix.com/download?zabbix=7.2&os_distribution=debian&os_version=12&components=server_frontend_agent&db=mysql&ws=apache

wget https://repo.zabbix.com/zabbix/7.2/release/debian/pool/main/z/zabbix-release/zabbix-release_latest_7.2+debian12_all.deb
dpkg -i zabbix-release_latest_7.2+debian12_all.deb
apt update

apt install zabbix-server-mysql zabbix-frontend-php zabbix-apache-conf zabbix-sql-scripts zabbix-agent

mysql -uroot -p
password
mysql> create database zabbix character set utf8mb4 collate utf8mb4_bin;
mysql> create user zabbix@localhost identified by 'password';
mysql> grant all privileges on zabbix.* to zabbix@localhost;
mysql> set global log_bin_trust_function_creators = 1;
mysql> quit;

zcat /usr/share/zabbix/sql-scripts/mysql/server.sql.gz | mysql --default-character-set=utf8mb4 -uzabbix -p zabbix

mysql -uroot -p
password
mysql> set global log_bin_trust_function_creators = 0;
mysql> quit;

Edit file /etc/zabbix/zabbix_server.conf
DBPassword=password

systemctl restart zabbix-server zabbix-agent apache2
systemctl enable zabbix-server zabbix-agent apache2

vagrant@test-sauvegarde:/vagrant$ sudo mysql -u root -p zabbix < zabbix_backup_2025-05-29.sql 