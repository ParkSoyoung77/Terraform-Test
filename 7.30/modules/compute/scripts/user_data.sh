#!/bin/bash
set -e

# ===== 1. nginx 설치 및 정적 컨텐츠 배포 =====
apt update
apt install -y nginx unzip curl parted

systemctl enable nginx
systemctl start nginx

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install
rm -rf awscliv2.zip
aws s3 sync s3://std17-ex-bucket/ /var/www/html/
systemctl restart nginx

# ===== 2. 볼륨 파티션 생성 및 마운트 (MySQL 설치 전에 선행) =====
DISK="/dev/nvme1n1"
PART="${DISK}p1"
MNTDIR="/mnt/data1"

if ! blkid "$PART" >/dev/null 2>&1; then
    parted -s "$DISK" mklabel gpt
    parted -s "$DISK" mkpart primary xfs 0% 5GB
    udevadm settle
    sleep 2
    mkfs -t xfs "$PART"
fi

mkdir -p "$MNTDIR"

if ! grep -q "$PART" /etc/fstab; then
    UUID=$(blkid -s UUID -o value "$PART")
    echo "UUID=${UUID}    ${MNTDIR}    xfs    defaults,nofail    0    2" >> /etc/fstab
fi

systemctl daemon-reload
mount -a

# ===== 3. MySQL 설치 (자동 기동 방지 후 설치) =====
systemctl mask mysql
apt update
apt install -y mysql-server

# ===== 4. MySQL 로그 디렉토리를 EBS 볼륨으로 이전 =====
mkdir -p "${MNTDIR}/log/mysql"
chmod 750 "${MNTDIR}/log/mysql"
chown mysql:adm "${MNTDIR}/log/mysql"

sed -i "s|/var/log/mysql|${MNTDIR}/log/mysql|g" /etc/mysql/mysql.conf.d/mysqld.cnf
sed -i "s|/var/log/mysql/|${MNTDIR}/log/mysql|g" /etc/apparmor.d/usr.sbin.mysqld

# ===== 5. MySQL 데이터 디렉토리를 EBS 볼륨으로 이전 =====
mkdir -p "${MNTDIR}/data/mysql"
chmod 700 "${MNTDIR}/data/mysql"
chown mysql:mysql "${MNTDIR}/data/mysql"

sed -i "s|# datadir\t= /var/lib/mysql|datadir\t= ${MNTDIR}/data/mysql|g" /etc/mysql/mysql.conf.d/mysqld.cnf
sed -i "s|/var/lib/mysql/|${MNTDIR}/data/mysql/|g" /etc/apparmor.d/usr.sbin.mysqld

# ===== 6. AppArmor 반영 및 MySQL 활성화 =====
systemctl reload apparmor
systemctl unmask mysql

# ===== 7. 데이터 디렉토리 초기화 =====
mysqld --initialize-insecure --user=mysql --datadir="${MNTDIR}/data/mysql"

# ===== 8. 외부 접속 허용 (bind-address 수정) =====
MYSQL_CNF=$(grep -rl "^bind-address" /etc/mysql/ 2>/dev/null | head -1)
if [ -n "$MYSQL_CNF" ]; then
    sed -i "s/^bind-address.*/bind-address = 0.0.0.0/" "$MYSQL_CNF"
fi

# ===== 9. MySQL 서비스 시작 =====
systemctl start mysql
sleep 10

# ===== 10. 계정 및 DB 생성 (외부 접속용 '%' 호스트) =====
MYSQL_USER="std17"
MYSQL_PASSWORD="12341234"

mysql -u root <<SQL
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON *.* TO '${MYSQL_USER}'@'%' WITH GRANT OPTION;
FLUSH PRIVILEGES;
CREATE DATABASE IF NOT EXISTS testdb;
SQL