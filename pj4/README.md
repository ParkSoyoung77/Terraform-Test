### 네트워크 구성

- VPC: CIDR: 10.0.0.0/24
- Public Subnet: 2개
- Private Subnet: 2개(NAT 사용)

### HTML 문서 생성

- www.domain.cloud: 메인 페이지
    - 중앙에 아래와 같이 4개의 박스 디자인 및 링크
- www.domain.cloud/ubuntu: 우분투 소개 페이지
    - 상단에 메인 페이지로 돌아갈 수 있도록 링크
- www.domain.cloud/mysql: mysql 소개 페이지
    - 상단에 메인 페이지로 돌아갈 수 있도록 링크
    - 버튼을 구성하여 클릭하면 람다 함수를 통해 데이터베이스를 연결하고
    - 연결이 성공하면 Success가 뜰 수 있도록 구성
    - 람다 함수는 api.domain.cloud로 동작할 수 있도록 구성
- www.domain.cloud/docker: docker 소개 페이지
    - 상단에 메인 페이지로 돌아갈 수 있도록 링크

### MySQL

- 데이터베이스 전용 VPC 생성: 완전 격리형
- 서브넷 그룹 / Systems Manager / Proxy 사용
- 다중 AZ DB 클러스터 배포(인스턴스 3개)로 구성
- 주어진 쿼리문을 통해 데이터베이스 및 테이블 생성 할 것

### www.domain.cloud

- Auto Scaling Group로 서비스
- 최소 1, 유지 1, 최대 2
- 새로운 인스턴스 생성시 S3 Bucket에 있는 파일로 서비스 할 수 있도록 구성
- S3 파일 복사는 AWS 내부 전용선을 이용

### api.domain.cloud

- Lambda
- 데이터베이스 연결
- 성공하면 {”status”: “Success”}를 반환

### /ubuntu, /mysql, /docker

- 각각 별도의 S3 Bucket Static Web Site로 구성

### 기타

- https 프로토콜 사용 추가