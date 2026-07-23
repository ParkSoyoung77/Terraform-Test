# TGW & TGA

1. 2개의 VPC 생성
2. 데이터 베이스는 두 번째 VPC에 생성
3. 첫 번째 vpc의 private에 두 개의 nginx를 구성하되 진입점은 www.sy99.cloud으로 실행되게 구성
4. S3 bucket을 statice Web Site로 생성하고 www.sy99.cloud/index.html으로 실행
5. lambda를 통해 데이터베이스 연결 후 성공 메세지 출력
6. lambda는 API G/W로 생성하고 www.sy99.cloud/api로 동작될 수 있게 구성
7. 단, http / https 모두 동작되어야 함 (80->443 강제 리다이렉트)

(+) 5, 6번 => VPC 내부연결 확인