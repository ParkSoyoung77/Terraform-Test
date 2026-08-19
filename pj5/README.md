# std17 ECS 인프라

Docker Swarm에서 전환한 ECS(EC2 launch type) 기반 웹 서비스 인프라입니다.
Nginx(리버스 프록시) + FastAPI + MySQL 컨테이너를 ECS로 오케스트레이션하고, ALB + Route53(도메인)으로 서비스합니다.

## 아키텍처
Route53 → ALB(HTTPS) → ECS 컨테이너 인스턴스(EC2, AZ x2)
├─ general 노드 x2: nginx + fastapi
└─ db 노드 x1: mysql

- ECS 클러스터는 관리형, EC2 노드만 Terraform으로 프로비저닝
- DB 노드는 ASG 미사용(상태 있는 노드), general 노드는 ASG 고정 2대
- 환경변수는 전부 Secrets Manager(`std17-mysql-credentials`)에서 주입