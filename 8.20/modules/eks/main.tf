# ==================================================================
# 현재 실행 계정 정보 (admin_principal_arns 미지정 시 자동 사용)
# ==================================================================
data "aws_caller_identity" "current" {}

locals {
    # admin_principal_arns를 지정하지 않으면 현재 apply를 실행하는 계정(IAM 사용자/역할)이
    # 자동으로 클러스터 admin 권한을 받도록 처리 (하드코딩 방지)
    admin_arns = length(var.admin_principal_arns) > 0 ? var.admin_principal_arns : [data.aws_caller_identity.current.arn]
}

# ==================================================================
# EKS 클러스터 IAM 역할
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

# ==================================================================
# EKS 노드그룹 IAM 역할
# ==================================================================
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

# ==================================================================
# 컨트롤플레인 <-> 노드 통신용 보안그룹
# ==================================================================
resource "aws_security_group" "std17_eks_cluster_sg" {
    name        = "std17-eks-cluster-sg"
    vpc_id      = var.vpc_id
    description = "EKS control plane to node communication SG"

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = { Name = "std17-eks-cluster-sg" }
}

resource "aws_security_group" "std17_eks_node_sg" {
    name        = "std17-eks-node-sg"
    vpc_id      = var.vpc_id
    description = "EKS worker node SG"

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = { Name = "std17-eks-node-sg" }
}

# 노드 -> 클러스터 API 서버 (443) : kubelet이 컨트롤플레인에 join/통신하기 위해 반드시 필요
resource "aws_security_group_rule" "std17_cluster_from_node" {
    type                     = "ingress"
    from_port                = 443
    to_port                  = 443
    protocol                 = "tcp"
    security_group_id        = aws_security_group.std17_eks_cluster_sg.id
    source_security_group_id = aws_security_group.std17_eks_node_sg.id
    description               = "node to cluster API server"
}

# 클러스터 SG -> 노드 SG (kubelet, HTTPS 등)
resource "aws_security_group_rule" "std17_cluster_to_node" {
    type                     = "egress"
    from_port                = 0
    to_port                  = 65535
    protocol                 = "tcp"
    security_group_id        = aws_security_group.std17_eks_cluster_sg.id
    source_security_group_id = aws_security_group.std17_eks_node_sg.id
    description               = "cluster SG to node SG"
}

resource "aws_security_group_rule" "std17_node_from_cluster" {
    type                     = "ingress"
    from_port                = 1025
    to_port                  = 65535
    protocol                 = "tcp"
    security_group_id        = aws_security_group.std17_eks_node_sg.id
    source_security_group_id = aws_security_group.std17_eks_cluster_sg.id
    description               = "kubelet communication from cluster"
}

resource "aws_security_group_rule" "std17_node_https_from_cluster" {
    type                     = "ingress"
    from_port                = 443
    to_port                  = 443
    protocol                 = "tcp"
    security_group_id        = aws_security_group.std17_eks_node_sg.id
    source_security_group_id = aws_security_group.std17_eks_cluster_sg.id
    description               = "HTTPS response to cluster"
}

# 노드간 통신 (self)
resource "aws_security_group_rule" "std17_node_to_node" {
    type              = "ingress"
    from_port         = 0
    to_port           = 65535
    protocol          = "-1"
    security_group_id = aws_security_group.std17_eks_node_sg.id
    self              = true
    description        = "node to node pod communication"
}

# ==================================================================
# EKS 클러스터
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
# OIDC Provider (IRSA용)
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
# 관리형 노드그룹
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
# 애드온 (VPC CNI, CoreDNS, kube-proxy)
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
# (옵션) EBS CSI Driver 애드온 + IRSA 역할
# ==================================================================
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

# ==================================================================
# Access Entry (관리자 권한 부여, aws-auth configmap 대체)
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