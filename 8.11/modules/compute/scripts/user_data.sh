#!/bin/bash
set -e

# ===== 설치 =====
apt update -y
apt install -y nginx unzip curl mysql-server
systemctl enable nginx
systemctl start nginx

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install
rm -rf awscliv2.zip
aws s3 sync s3://std17-ex-bucket/ /var/www/html/
systemctl restart nginx

# ===== MySQL 서버 초기 설정 =====
systemctl enable mysql
systemctl start mysql

MYSQL_USER="std17"
MYSQL_PASSWORD="12341234"

mysql -u root <<SQL
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON *.* TO '${MYSQL_USER}'@'%' WITH GRANT OPTION;
FLUSH PRIVILEGES;
CREATE DATABASE IF NOT EXISTS testdb;
SQL

# 외부 접속 허용
MYSQL_CNF=$(grep -rl "^bind-address" /etc/mysql/ 2>/dev/null | head -1)
if [ -n "$MYSQL_CNF" ]; then
    sed -i "s/^bind-address.*/bind-address = 0.0.0.0/" "$MYSQL_CNF"
fi
systemctl restart mysql