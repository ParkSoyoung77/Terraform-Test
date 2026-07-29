#!/bin/bash
set -e

apt update
apt install -y nginx unzip curl

systemctl enable nginx
systemctl start nginx

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install
rm -rf awscliv2.zip
aws s3 sync s3://std17-ex-bucket/ /var/www/html/
systemctl restart nginx

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