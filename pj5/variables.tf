variable "aws_region" {
    description = "리소스를 생성할 AWS 리전"
    type        = string
    default     = "ap-northeast-3"
}

variable "azs" {
    description = "사용할 가용영역 리스트 (2개 고정)"
    type        = list(string)
    default     = ["ap-northeast-3a", "ap-northeast-3b"]
}

variable "domain_name" {
    description = "ALB에 연결할 도메인 (Route53 퍼블릭 호스팅 영역이 이미 존재해야 함)"
    type        = string
    default     = "sy99.cloud"
}

variable "db_name" {
    description = "MySQL 데이터베이스 이름"
    type        = string
    default     = "testdb"
}

variable "general_instance_type" {
    description = "Nginx+FastAPI가 뜨는 일반 노드 인스턴스 타입"
    type        = string
    default     = "t3.medium"
}

variable "db_instance_type" {
    description = "MySQL 전용 노드 인스턴스 타입"
    type        = string
    default     = "t3.medium"
}

variable "general_desired_count" {
    description = "General 노드(=ECS EC2 인스턴스) 개수, AZ당 1대"
    type        = number
    default     = 2
}

variable "alert_email" {
    description = "예산 알림을 받을 이메일 주소"
    type        = string
}