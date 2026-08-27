variable "vpc_id" {
    description = "EKS 클러스터가 속할 VPC ID"
    type        = string
}

variable "private_subnet_ids" {
    description = "EKS 클러스터/노드그룹이 사용할 프라이빗 서브넷 ID 리스트"
    type        = list(string)
}

variable "cluster_name" {
    description = "EKS 클러스터 이름"
    type        = string
    default     = "std17-eks-cluster"
}

variable "cluster_version" {
    description = "EKS 클러스터(쿠버네티스) 버전"
    type        = string
    default     = "1.34"
}

variable "endpoint_public_access" {
    description = "EKS API 서버 퍼블릭 엔드포인트 허용 여부"
    type        = bool
    default     = true
}

variable "endpoint_public_access_cidrs" {
    description = "퍼블릭 엔드포인트 접근을 허용할 CIDR 리스트"
    type        = list(string)
    default     = ["0.0.0.0/0"]
}

variable "enabled_cluster_log_types" {
    description = "CloudWatch로 전송할 EKS 컨트롤플레인 로그 타입"
    type        = list(string)
    default     = ["api", "audit", "authenticator"]
}

# ==================================================================
# 노드그룹 설정
# ==================================================================
variable "node_group_name" {
    description = "EKS 관리형 노드그룹 이름"
    type        = string
    default     = "std17-ng-t3"
}

variable "node_instance_types" {
    description = "노드그룹 EC2 인스턴스 타입"
    type        = list(string)
    default     = ["t3.small"]
}

variable "node_capacity_type" {
    description = "노드 용량 타입 (ON_DEMAND / SPOT)"
    type        = string
    default     = "ON_DEMAND"
}

variable "node_disk_size" {
    description = "노드 EC2 루트 볼륨 크기(GiB)"
    type        = number
    default     = 20
}

variable "node_desired_size" {
    description = "노드그룹 희망 노드 수"
    type        = number
    default     = 2
}

variable "node_min_size" {
    description = "노드그룹 최소 노드 수"
    type        = number
    default     = 1
}

variable "node_max_size" {
    description = "노드그룹 최대 노드 수"
    type        = number
    default     = 3
}

# ==================================================================
# 애드온
# ==================================================================
variable "addon_versions" {
    description = "EKS 애드온별 버전 (미지정 시 most_recent 사용)"
    type        = map(string)
    default     = {}
}

variable "enable_ebs_csi_driver" {
    description = "aws-ebs-csi-driver 애드온 설치 여부"
    type        = bool
    default     = true 
}

# ==================================================================
# Access Entry (aws-auth configmap 대체)
# ==================================================================
variable "admin_principal_arns" {
    description = "EKS 클러스터 관리자 권한을 부여할 IAM 사용자/역할 ARN 리스트"
    type        = list(string)
    default     = []
}