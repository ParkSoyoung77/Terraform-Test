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

# ===== 2. 파티션 2개 생성 (data1: 로그용, data2: 데이터용) =====
DISK="/dev/nvme1n1"
PART1="${DISK}p1"
PART2="${DISK}p2"
MNTDIR1="/mnt/data1"   # 로그
MNTDIR2="/mnt/data2"   # 데이터

if ! blkid "$PART1" >/dev/null 2>&1 && ! blkid "$PART2" >/dev/null 2>&1; then
    parted -s "$DISK" mklabel gpt
    parted -s "$DISK" mkpart primary xfs 0% 20%
    parted -s "$DISK" mkpart primary xfs 20% 100%
    udevadm settle
    sleep 2
    mkfs -t xfs "$PART1"
    mkfs -t xfs "$PART2"
fi

mkdir -p "$MNTDIR1" "$MNTDIR2"

if ! grep -q "$PART1" /etc/fstab; then
    UUID1=$(blkid -s UUID -o value "$PART1")
    echo "UUID=${UUID1}    ${MNTDIR1}    xfs    defaults,nofail    0    2" >> /etc/fstab
fi

if ! grep -q "$PART2" /etc/fstab; then
    UUID2=$(blkid -s UUID -o value "$PART2")
    echo "UUID=${UUID2}    ${MNTDIR2}    xfs    defaults,nofail    0    2" >> /etc/fstab
fi

systemctl daemon-reload
mount -a

# ===== 3. MySQL 설치 (자동 기동 방지 후 설치) =====
systemctl mask mysql
apt update
apt install -y mysql-server

# ===== 4. MySQL 로그 디렉토리 -> data1 =====
mkdir -p "${MNTDIR1}/log/mysql"
chmod 750 "${MNTDIR1}/log/mysql"
chown mysql:adm "${MNTDIR1}/log/mysql"

sed -i "s|/var/log/mysql|${MNTDIR1}/log/mysql|g" /etc/mysql/mysql.conf.d/mysqld.cnf
sed -i "s|/var/log/mysql/|${MNTDIR1}/log/mysql/|g" /etc/apparmor.d/usr.sbin.mysqld
sed -i "s|/var/log/mysql\.|${MNTDIR1}/log/mysql.|g" /etc/apparmor.d/usr.sbin.mysqld

# ===== 5. MySQL 데이터 디렉토리 -> data2 =====
mkdir -p "${MNTDIR2}/data/mysql"
chmod 700 "${MNTDIR2}/data/mysql"
chown mysql:mysql "${MNTDIR2}/data/mysql"

sed -i "s|# datadir\t= /var/lib/mysql|datadir\t= ${MNTDIR2}/data/mysql|g" /etc/mysql/mysql.conf.d/mysqld.cnf
sed -i "s|/var/lib/mysql/|${MNTDIR2}/data/mysql/|g" /etc/apparmor.d/usr.sbin.mysqld

# ===== 6. AppArmor 반영 및 MySQL 활성화 =====
systemctl reload apparmor
systemctl unmask mysql

# ===== 7. 데이터 디렉토리 초기화 =====
mysqld --initialize-insecure --user=mysql --datadir="${MNTDIR2}/data/mysql"

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