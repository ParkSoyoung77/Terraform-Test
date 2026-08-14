#!/bin/bash
set -e

# ===== 설치 =====
apt update -y
apt install -y nginx unzip curl mysql-server mysql-shell mysql-router docker.io
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

# ===== Docker 설치 =====
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

apt update -y
apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

systemctl enable docker
systemctl start docker

usermod -aG docker ubuntu

# ===== FastAPI Dockerfile 배치 (빌드/실행 X) =====
mkdir -p /opt/fastapi-app
cd /opt/fastapi-app

cat > main.py << 'EOF'
from fastapi import FastAPI

app = FastAPI()

@app.get("/")
def read_root():
    return {"message": "std17 FastAPI on Docker"}

@app.get("/health")
def health_check():
    return {"status": "ok"}
EOF

cat > requirements.txt << 'EOF'
fastapi
uvicorn[standard]
EOF

cat > Dockerfile << 'EOF'
FROM python:3.11-slim

WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .

EXPOSE 8000
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
EOF