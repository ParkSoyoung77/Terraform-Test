# ==================================================================
# 0. 현재 실행 계정 정보 (admin_principal_arns 미지정 시 자동 사용)
# ==================================================================
data "aws_caller_identity" "current" {}

locals {
    # admin_principal_arns를 지정하지 않으면 현재 apply를 실행하는 계정(IAM 사용자/역할)이
    # 자동으로 클러스터 admin 권한을 받도록 처리 (하드코딩 방지)
    admin_arns = length(var.admin_principal_arns) > 0 ? var.admin_principal_arns : [data.aws_caller_identity.current.arn]
}


# ==================================================================
# 1. IAM — EKS 클러스터 / 노드그룹 역할
# ==================================================================

resource "aws_iam_role" "std17_eks_cluster_role" {
    name = "std17-eks-cluster-role"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
            Effect    = "Allow"
            Principal = { Service = "eks.amazonaws.com" }
            Action    = "sts:AssumeRole"
        }]
    })

    tags = { Name = "std17-eks-cluster-role" }
}

resource "aws_iam_role_policy_attachment" "std17_eks_cluster_policy" {
    role       = aws_iam_role.std17_eks_cluster_role.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role" "std17_eks_node_role" {
    name = "std17-eks-node-role"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
            Effect    = "Allow"
            Principal = { Service = "ec2.amazonaws.com" }
            Action    = "sts:AssumeRole"
        }]
    })

    tags = { Name = "std17-eks-node-role" }
}

resource "aws_iam_role_policy_attachment" "std17_eks_worker_node_policy" {
    role       = aws_iam_role.std17_eks_node_role.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "std17_eks_cni_policy" {
    role       = aws_iam_role.std17_eks_node_role.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "std17_eks_ecr_readonly" {
    role       = aws_iam_role.std17_eks_node_role.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# 디버깅용: SSM Session Manager로 노드에 접속해서 실시간 kubelet 로그 확인 가능하게 함
resource "aws_iam_role_policy_attachment" "std17_eks_ssm_core" {
    role       = aws_iam_role.std17_eks_node_role.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}


# ==================================================================
# 2. 보안그룹 — 컨트롤플레인 <-> 노드 통신
# ==================================================================

resource "aws_security_group" "std17_eks_cluster_sg" {
    name        = "std17-eks-cluster-sg"
    vpc_id      = var.vpc_id
    description = "EKS control plane to node communication SG"

    tags = { Name = "std17-eks-cluster-sg" }
}

resource "aws_security_group" "std17_eks_node_sg" {
    name        = "std17-eks-node-sg"
    vpc_id      = var.vpc_id
    description = "EKS worker node SG"

    tags = { Name = "std17-eks-node-sg" }
}

# 클러스터 SG 전체 아웃바운드 허용 (인라인 egress 대신 별도 rule로 관리)
resource "aws_security_group_rule" "std17_cluster_egress_all" {
    type              = "egress"
    from_port         = 0
    to_port           = 0
    protocol          = "-1"
    cidr_blocks       = ["0.0.0.0/0"]
    security_group_id = aws_security_group.std17_eks_cluster_sg.id
    description       = "cluster SG all outbound"
}

# 노드 SG 전체 아웃바운드 허용 (인라인 egress 대신 별도 rule로 관리)
resource "aws_security_group_rule" "std17_node_egress_all" {
    type              = "egress"
    from_port         = 0
    to_port           = 0
    protocol          = "-1"
    cidr_blocks       = ["0.0.0.0/0"]
    security_group_id = aws_security_group.std17_eks_node_sg.id
    description       = "node SG all outbound"
}

# 노드 -> 클러스터 API 서버 (443) : kubelet이 컨트롤플레인에 join/통신하기 위해 반드시 필요
resource "aws_security_group_rule" "std17_cluster_from_node" {
    type                     = "ingress"
    from_port                = 443
    to_port                  = 443
    protocol                 = "tcp"
    security_group_id        = aws_security_group.std17_eks_cluster_sg.id
    source_security_group_id = aws_security_group.std17_eks_node_sg.id
    description              = "node to cluster API server"
}

# 클러스터 SG -> 노드 SG (kubelet, HTTPS 등)
resource "aws_security_group_rule" "std17_cluster_to_node" {
    type                     = "egress"
    from_port                = 0
    to_port                  = 65535
    protocol                 = "tcp"
    security_group_id        = aws_security_group.std17_eks_cluster_sg.id
    source_security_group_id = aws_security_group.std17_eks_node_sg.id
    description              = "cluster SG to node SG"
}

resource "aws_security_group_rule" "std17_node_from_cluster" {
    type                     = "ingress"
    from_port                = 1025
    to_port                  = 65535
    protocol                 = "tcp"
    security_group_id        = aws_security_group.std17_eks_node_sg.id
    source_security_group_id = aws_security_group.std17_eks_cluster_sg.id
    description              = "kubelet communication from cluster"
}

resource "aws_security_group_rule" "std17_node_https_from_cluster" {
    type                     = "ingress"
    from_port                = 443
    to_port                  = 443
    protocol                 = "tcp"
    security_group_id        = aws_security_group.std17_eks_node_sg.id
    source_security_group_id = aws_security_group.std17_eks_cluster_sg.id
    description              = "HTTPS response to cluster"
}

# 노드간 통신 (self)
resource "aws_security_group_rule" "std17_node_to_node" {
    type              = "ingress"
    from_port         = 0
    to_port           = 65535
    protocol          = "-1"
    security_group_id = aws_security_group.std17_eks_node_sg.id
    self              = true
    description       = "node to node pod communication"
}


# ==================================================================
# 3. EKS 클러스터
# ==================================================================

resource "aws_eks_cluster" "std17_eks" {
    name     = var.cluster_name
    version  = var.cluster_version
    role_arn = aws_iam_role.std17_eks_cluster_role.arn

    vpc_config {
        subnet_ids              = var.private_subnet_ids
        security_group_ids      = [aws_security_group.std17_eks_cluster_sg.id]
        endpoint_private_access = true
        endpoint_public_access  = var.endpoint_public_access
        public_access_cidrs     = var.endpoint_public_access_cidrs
    }

    enabled_cluster_log_types = var.enabled_cluster_log_types

    # aws-auth configmap 대신 access entry 방식 사용
    access_config {
        authentication_mode = "API"
    }

    depends_on = [
        aws_iam_role_policy_attachment.std17_eks_cluster_policy
    ]

    tags = { Name = var.cluster_name }
}


# ==================================================================
# 4. OIDC Provider (IRSA용)
# ==================================================================

data "tls_certificate" "std17_eks_oidc" {
    url = aws_eks_cluster.std17_eks.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "std17_eks_oidc" {
    url             = aws_eks_cluster.std17_eks.identity[0].oidc[0].issuer
    client_id_list  = ["sts.amazonaws.com"]
    thumbprint_list = [data.tls_certificate.std17_eks_oidc.certificates[0].sha1_fingerprint]

    tags = { Name = "std17-eks-oidc" }
}


# ==================================================================
# 5. 관리형 노드그룹
# ==================================================================

resource "aws_eks_node_group" "std17_eks_nodegroup" {
    cluster_name    = aws_eks_cluster.std17_eks.name
    node_group_name = var.node_group_name
    node_role_arn   = aws_iam_role.std17_eks_node_role.arn
    subnet_ids      = var.private_subnet_ids

    instance_types = var.node_instance_types
    capacity_type  = var.node_capacity_type
    disk_size      = var.node_disk_size

    scaling_config {
        desired_size = var.node_desired_size
        min_size     = var.node_min_size
        max_size     = var.node_max_size
    }

    update_config {
        max_unavailable = 1
    }

    depends_on = [
        aws_iam_role_policy_attachment.std17_eks_worker_node_policy,
        aws_iam_role_policy_attachment.std17_eks_cni_policy,
        aws_iam_role_policy_attachment.std17_eks_ecr_readonly
    ]

    tags = { Name = var.node_group_name }
}


# ==================================================================
# 6. 코어 애드온 (VPC CNI, CoreDNS, kube-proxy)
# ==================================================================

resource "aws_eks_addon" "std17_vpc_cni" {
    cluster_name  = aws_eks_cluster.std17_eks.name
    addon_name    = "vpc-cni"
    addon_version = lookup(var.addon_versions, "vpc-cni", null)

    resolve_conflicts_on_create = "OVERWRITE"
    resolve_conflicts_on_update = "OVERWRITE"

    depends_on = [aws_eks_node_group.std17_eks_nodegroup]
}

resource "aws_eks_addon" "std17_coredns" {
    cluster_name  = aws_eks_cluster.std17_eks.name
    addon_name    = "coredns"
    addon_version = lookup(var.addon_versions, "coredns", null)

    resolve_conflicts_on_create = "OVERWRITE"
    resolve_conflicts_on_update = "OVERWRITE"

    depends_on = [aws_eks_node_group.std17_eks_nodegroup]
}

resource "aws_eks_addon" "std17_kube_proxy" {
    cluster_name  = aws_eks_cluster.std17_eks.name
    addon_name    = "kube-proxy"
    addon_version = lookup(var.addon_versions, "kube-proxy", null)

    resolve_conflicts_on_create = "OVERWRITE"
    resolve_conflicts_on_update = "OVERWRITE"

    depends_on = [aws_eks_node_group.std17_eks_nodegroup]
}


# ==================================================================
# 7. 스토리지 CSI 애드온 (EBS / EFS / S3) + IRSA
# ==================================================================

# --- 7-1. EBS CSI Driver ---
resource "aws_iam_role" "std17_ebs_csi_role" {
    count = var.enable_ebs_csi_driver ? 1 : 0
    name  = "std17-eks-ebs-csi-role"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
            Effect = "Allow"
            Principal = {
                Federated = aws_iam_openid_connect_provider.std17_eks_oidc.arn
            }
            Action = "sts:AssumeRoleWithWebIdentity"
            Condition = {
                StringEquals = {
                    "${replace(aws_iam_openid_connect_provider.std17_eks_oidc.url, "https://", "")}:sub" = "system:serviceaccount:kube-system:ebs-csi-controller-sa"
                    "${replace(aws_iam_openid_connect_provider.std17_eks_oidc.url, "https://", "")}:aud" = "sts.amazonaws.com"
                }
            }
        }]
    })

    tags = { Name = "std17-eks-ebs-csi-role" }
}

resource "aws_iam_role_policy_attachment" "std17_ebs_csi_policy" {
    count      = var.enable_ebs_csi_driver ? 1 : 0
    role       = aws_iam_role.std17_ebs_csi_role[0].name
    policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

resource "aws_eks_addon" "std17_ebs_csi" {
    count         = var.enable_ebs_csi_driver ? 1 : 0
    cluster_name  = aws_eks_cluster.std17_eks.name
    addon_name    = "aws-ebs-csi-driver"
    addon_version = lookup(var.addon_versions, "aws-ebs-csi-driver", null)

    service_account_role_arn = aws_iam_role.std17_ebs_csi_role[0].arn

    resolve_conflicts_on_create = "OVERWRITE"
    resolve_conflicts_on_update = "OVERWRITE"

    depends_on = [aws_eks_node_group.std17_eks_nodegroup]
}

# --- 7-2. EFS CSI Driver ---
resource "aws_iam_role" "std17_efs_csi_role" {
    count = var.enable_efs_csi_driver ? 1 : 0
    name  = "std17-eks-efs-csi-role"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
            Effect = "Allow"
            Principal = {
                Federated = aws_iam_openid_connect_provider.std17_eks_oidc.arn
            }
            Action = "sts:AssumeRoleWithWebIdentity"
            Condition = {
                StringEquals = {
                    "${replace(aws_iam_openid_connect_provider.std17_eks_oidc.url, "https://", "")}:sub" = "system:serviceaccount:kube-system:efs-csi-controller-sa"
                    "${replace(aws_iam_openid_connect_provider.std17_eks_oidc.url, "https://", "")}:aud" = "sts.amazonaws.com"
                }
            }
        }]
    })

    tags = { Name = "std17-eks-efs-csi-role" }
}

resource "aws_iam_role_policy_attachment" "std17_efs_csi_policy" {
    count      = var.enable_efs_csi_driver ? 1 : 0
    role       = aws_iam_role.std17_efs_csi_role[0].name
    policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy"
}

resource "aws_eks_addon" "std17_efs_csi" {
    count         = var.enable_efs_csi_driver ? 1 : 0
    cluster_name  = aws_eks_cluster.std17_eks.name
    addon_name    = "aws-efs-csi-driver"
    addon_version = lookup(var.addon_versions, "aws-efs-csi-driver", null)

    service_account_role_arn = aws_iam_role.std17_efs_csi_role[0].arn

    resolve_conflicts_on_create = "OVERWRITE"
    resolve_conflicts_on_update = "OVERWRITE"

    depends_on = [aws_eks_node_group.std17_eks_nodegroup]
}

# --- 7-3. Mountpoint for S3 CSI Driver ---
resource "aws_iam_policy" "std17_s3_csi_policy" {
    count       = var.enable_s3_csi_driver ? 1 : 0
    name        = "std17-eks-s3-csi-policy"
    description = "aws-mountpoint-s3-csi-driver가 S3 버킷에 접근하기 위한 정책"

    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
            Effect = "Allow"
            Action = [
                "s3:PutObject",
                "s3:GetObject",
                "s3:ListBucket",
                "s3:DeleteObject"
            ]
            Resource = [
                var.s3_logs_bucket_arn,
                "${var.s3_logs_bucket_arn}/*"
            ]
        }]
    })
}

resource "aws_iam_role" "std17_s3_csi_role" {
    count = var.enable_s3_csi_driver ? 1 : 0
    name  = "std17-eks-s3-csi-role"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
            Effect = "Allow"
            Principal = {
                Federated = aws_iam_openid_connect_provider.std17_eks_oidc.arn
            }
            Action = "sts:AssumeRoleWithWebIdentity"
            Condition = {
                StringLike = {
                    "${replace(aws_iam_openid_connect_provider.std17_eks_oidc.url, "https://", "")}:sub" = "system:serviceaccount:${var.s3_csi_sa_namespace}:s3-csi-driver-*"
                    "${replace(aws_iam_openid_connect_provider.std17_eks_oidc.url, "https://", "")}:aud" = "sts.amazonaws.com"
                }
            }
        }]
    })

    tags = { Name = "std17-eks-s3-csi-role" }
}

resource "aws_iam_role_policy_attachment" "std17_s3_csi_attach" {
    count      = var.enable_s3_csi_driver ? 1 : 0
    role       = aws_iam_role.std17_s3_csi_role[0].name
    policy_arn = aws_iam_policy.std17_s3_csi_policy[0].arn
}

resource "aws_eks_addon" "std17_s3_csi" {
    count         = var.enable_s3_csi_driver ? 1 : 0
    cluster_name  = aws_eks_cluster.std17_eks.name
    addon_name    = "aws-mountpoint-s3-csi-driver"
    addon_version = lookup(var.addon_versions, "aws-mountpoint-s3-csi-driver", null)

    service_account_role_arn = aws_iam_role.std17_s3_csi_role[0].arn

    resolve_conflicts_on_create = "OVERWRITE"
    resolve_conflicts_on_update = "OVERWRITE"

    depends_on = [aws_eks_node_group.std17_eks_nodegroup]
}


# ==================================================================
# 8. 관측/운영 애드온 (CloudWatch Observability, Pod Identity Agent)
# ==================================================================

# --- 8-1. CloudWatch Observability (컨테이너 인사이트, 로그/메트릭 수집) ---
resource "aws_iam_role" "std17_cw_observability_role" {
    count = var.enable_cloudwatch_observability ? 1 : 0
    name  = "std17-eks-cw-observability-role"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
            Effect = "Allow"
            Principal = {
                Federated = aws_iam_openid_connect_provider.std17_eks_oidc.arn
            }
            Action = "sts:AssumeRoleWithWebIdentity"
            Condition = {
                StringEquals = {
                    "${replace(aws_iam_openid_connect_provider.std17_eks_oidc.url, "https://", "")}:sub" = "system:serviceaccount:amazon-cloudwatch:cloudwatch-agent"
                    "${replace(aws_iam_openid_connect_provider.std17_eks_oidc.url, "https://", "")}:aud" = "sts.amazonaws.com"
                }
            }
        }]
    })

    tags = { Name = "std17-eks-cw-observability-role" }
}

resource "aws_iam_role_policy_attachment" "std17_cw_observability_policy" {
    count      = var.enable_cloudwatch_observability ? 1 : 0
    role       = aws_iam_role.std17_cw_observability_role[0].name
    policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_eks_addon" "std17_cw_observability" {
    count         = var.enable_cloudwatch_observability ? 1 : 0
    cluster_name  = aws_eks_cluster.std17_eks.name
    addon_name    = "amazon-cloudwatch-observability"
    addon_version = lookup(var.addon_versions, "amazon-cloudwatch-observability", null)

    service_account_role_arn = aws_iam_role.std17_cw_observability_role[0].arn

    resolve_conflicts_on_create = "OVERWRITE"
    resolve_conflicts_on_update = "OVERWRITE"

    depends_on = [aws_eks_node_group.std17_eks_nodegroup]
}

# --- 8-2. EKS Pod Identity Agent (IRSA 없이도 role 매핑 가능하게 하는 최신 방식, 노드 데몬셋이라 별도 IAM 불필요) ---
resource "aws_eks_addon" "std17_pod_identity_agent" {
    count         = var.enable_pod_identity_agent ? 1 : 0
    cluster_name  = aws_eks_cluster.std17_eks.name
    addon_name    = "eks-pod-identity-agent"
    addon_version = lookup(var.addon_versions, "eks-pod-identity-agent", null)

    resolve_conflicts_on_create = "OVERWRITE"
    resolve_conflicts_on_update = "OVERWRITE"

    depends_on = [aws_eks_node_group.std17_eks_nodegroup]
}


# ==================================================================
# 9. Access Entry (관리자 권한 부여, aws-auth configmap 대체)
# ==================================================================

resource "aws_eks_access_entry" "std17_admin_entry" {
    count = length(local.admin_arns)

    cluster_name  = aws_eks_cluster.std17_eks.name
    principal_arn = local.admin_arns[count.index]
    type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "std17_admin_policy" {
    count = length(local.admin_arns)

    cluster_name  = aws_eks_cluster.std17_eks.name
    principal_arn = local.admin_arns[count.index]
    policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

    access_scope {
        type = "cluster"
    }

    depends_on = [aws_eks_access_entry.std17_admin_entry]
}


# ==================================================================
# 10. 애플리케이션 IRSA 역할 (파드가 직접 사용하는 커스텀 role)
# ==================================================================

# --- 10-1. external-secrets (Secrets Manager 연동) ---
resource "aws_iam_role" "std17_external_secrets_role" {
    name = "std17-eks-external-secrets-role"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
            Effect = "Allow"
            Principal = {
                Federated = aws_iam_openid_connect_provider.std17_eks_oidc.arn
            }
            Action = "sts:AssumeRoleWithWebIdentity"
            Condition = {
                StringEquals = {
                    "${replace(aws_iam_openid_connect_provider.std17_eks_oidc.url, "https://", "")}:sub" = "system:serviceaccount:external-secrets:external-secrets"
                    "${replace(aws_iam_openid_connect_provider.std17_eks_oidc.url, "https://", "")}:aud" = "sts.amazonaws.com"
                }
            }
        }]
    })

    tags = { Name = "std17-eks-external-secrets-role" }
}

resource "aws_iam_role_policy" "std17_external_secrets_policy" {
    name = "std17-external-secrets-policy"
    role = aws_iam_role.std17_external_secrets_role.id

    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
            Effect   = "Allow"
            Action   = [
                "secretsmanager:GetSecretValue",
                "secretsmanager:DescribeSecret"
            ]
            Resource = "*"
        }]
    })
}

# --- 10-2. ubuntu-s3-sa / nginx (S3 로그 업로드용) ---
resource "aws_iam_policy" "std17_s3_logs_policy" {
    name        = "std17-AmazonS3-Logs-Policy"
    description = "ubuntu-s3-sa가 S3에 로그를 업로드하기 위한 정책"

    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
            Effect = "Allow"
            Action = [
                "s3:PutObject",
                "s3:GetObject",
                "s3:ListBucket"
            ]
            Resource = [
                var.s3_logs_bucket_arn,
                "${var.s3_logs_bucket_arn}/*"
            ]
        }]
    })
}

resource "aws_iam_role" "std17_nginx_s3_role" {
    name = "Std17NginxS3Role"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
            Effect = "Allow"
            Principal = {
                Federated = aws_iam_openid_connect_provider.std17_eks_oidc.arn
            }
            Action = "sts:AssumeRoleWithWebIdentity"
            Condition = {
                StringEquals = {
                    "${replace(aws_iam_openid_connect_provider.std17_eks_oidc.url, "https://", "")}:sub" = "system:serviceaccount:${var.s3_sa_namespace}:ubuntu-s3-sa"
                    "${replace(aws_iam_openid_connect_provider.std17_eks_oidc.url, "https://", "")}:aud" = "sts.amazonaws.com"
                }
            }
        }]
    })

    tags = { Name = "Std17NginxS3Role" }
}

resource "aws_iam_role_policy_attachment" "std17_nginx_s3_attach" {
    role       = aws_iam_role.std17_nginx_s3_role.name
    policy_arn = aws_iam_policy.std17_s3_logs_policy.arn
}