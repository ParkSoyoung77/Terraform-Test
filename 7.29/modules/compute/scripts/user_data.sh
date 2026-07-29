#!/bin/bash
set -e

# ===== 설치 =====
apt update
apt install -y nginx unzip curl mysql-server

systemctl enable nginx
systemctl start nginx

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install
rm -rf awscliv2.zip
aws s3 sync s3://std17-ex-bucket/ /var/www/html/
systemctl restart nginx

# ===== 볼륨 마운트 =====
DISK="/dev/nvme1n1"
PART="${DISK}p1"

if ! blkid "$PART" >/dev/null 2>&1; then
    parted -s "$DISK" mklabel gpt
    parted -s "$DISK" mkpart primary xfs 0% 5GB
    udevadm settle
    sleep 2
    mkfs -t xfs "$PART"
fi

if ! grep -q "$PART" /etc/fstab; then
    UUID=$(blkid -s UUID -o value "$PART")
    echo "UUID=${UUID}    /mnt/data1    xfs    defaults,nofail    0    2" >> /etc/fstab
fi

mkdir -p /mnt/data1
systemctl daemon-reload
mount -a

systemctl enable mysql
systemctl start mysql

# ===== MySQL 서버 초기 설정 =====
MYSQL_USER="std17"
MYSQL_PASSWORD="12341234"

mysql -u root <<SQL
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED WITH mysql_native_password BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON *.* TO '${MYSQL_USER}'@'%' WITH GRANT OPTION;
FLUSH PRIVILEGES;
CREATE DATABASE IF NOT EXISTS testdb;
SQL

# 외부에서도 접속 테스트가 가능하도록 bind-address 개방 (필요시)
sed -i "s/^bind-address.*/bind-address = 0.0.0.0/" /etc/mysql/mysql.conf.d/mysqld.cnf
systemctl restart mysql