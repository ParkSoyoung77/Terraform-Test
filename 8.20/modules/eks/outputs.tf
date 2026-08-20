output "cluster_id" {
    description = "EKS 클러스터 이름/ID"
    value       = aws_eks_cluster.std17_eks.id
}

output "cluster_arn" {
    description = "EKS 클러스터 ARN"
    value       = aws_eks_cluster.std17_eks.arn
}

output "cluster_endpoint" {
    description = "EKS API 서버 엔드포인트"
    value       = aws_eks_cluster.std17_eks.endpoint
}

output "cluster_certificate_authority_data" {
    description = "kubeconfig 구성용 클러스터 CA 인증서 데이터"
    value       = aws_eks_cluster.std17_eks.certificate_authority[0].data
}

output "cluster_security_group_id" {
    description = "EKS 컨트롤플레인 보안그룹 ID"
    value       = aws_security_group.std17_eks_cluster_sg.id
}

output "node_security_group_id" {
    description = "EKS 노드 보안그룹 ID"
    value       = aws_security_group.std17_eks_node_sg.id
}

output "node_role_arn" {
    description = "EKS 노드그룹 IAM 역할 ARN"
    value       = aws_iam_role.std17_eks_node_role.arn
}

output "cluster_role_arn" {
    description = "EKS 클러스터 IAM 역할 ARN"
    value       = aws_iam_role.std17_eks_cluster_role.arn
}

output "oidc_provider_arn" {
    description = "IRSA용 OIDC Provider ARN"
    value       = aws_iam_openid_connect_provider.std17_eks_oidc.arn
}

output "oidc_provider_url" {
    description = "IRSA용 OIDC Provider URL"
    value       = aws_iam_openid_connect_provider.std17_eks_oidc.url
}

output "node_group_id" {
    description = "EKS 관리형 노드그룹 ID"
    value       = aws_eks_node_group.std17_eks_nodegroup.id
}

output "kubeconfig_update_command" {
    description = "로컬에서 kubeconfig 갱신용 명령어"
    value       = "aws eks update-kubeconfig --region ap-northeast-3 --name ${aws_eks_cluster.std17_eks.name}"
}