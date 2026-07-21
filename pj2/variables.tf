variable "aws_region" {
    description = "리소스를 생성할 AWS 리전"
    type        = string
    default     = "us-west-1"
}

variable "azs" {
    description = "사용할 가용영역 리스트"
    type        = list(string)
    default     = ["us-west-1a", "us-west-1c"]
}

variable "key_name" {
    description = "EC2 키페어 이름"
    type        = string
    default     = "std17-key"
}

variable "root_domain" {
    description = "Route53 호스팅 영역의 루트 도메인"
    type        = string
    default     = "sy99.cloud"
}

variable "domain_name" {
    description = "서비스 진입점 도메인 (CloudFront alias)"
    type        = string
    default     = "www.sy99.cloud"
}

variable "db_name" {
    description = "애플리케이션이 사용할 데이터베이스 이름"
    type        = string
    default     = "studydb"
}