variable "vpc_id" {
    description = "S3 엔드포인트가 속할 VPC ID"
    type        = string
}

variable "public_subnet_ids" {
    description = "프라이빗 서브넷 ID 리스트"
    type        = list(string)
}

variable "route_table_ids" {
    description = "S3 게이트웨이 엔드포인트에 연결할 라우트테이블 ID"
    type        = list(string)
}

variable "ecr_endpoint_sg_id" {
  description = "security 모듈에서 생성한 ECR 엔드포인트용 보안그룹 ID"
  type        = string
}