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

variable "eks_node_role_arn" {
  description = "S3 엔드포인트 접근을 허용할 EKS 노드 IAM Role ARN"
  type        = string
}