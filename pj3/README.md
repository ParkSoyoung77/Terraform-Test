# Endpoint

1. 3개의 html파일 생성
2. html파일은 버킷에 있는 파일을 복사하여 /var/www/html/에 복사해 s3를 위한 엔드포인트 생성
3. nginx에는 1번 html파일 실행
4. nginx 인스턴스는 최소 1개, 기본 유지 2개, 최대 3개까지 생성 - 프라이빗 서브넷 할당
5. www.domain.cloud는 nginx에 html 파일로 실행
6. 2번 html파일은 S3정적 웬사이트로 구성하되 www.domain.cloud/html1로 실행 되게 구현
7. 3번 html파일은 S3정적 웬사이트로 구성하되 www.domain.cloud/html2로 실행 되게 구현
8. 모두 http 및 https로 동작하게 구성