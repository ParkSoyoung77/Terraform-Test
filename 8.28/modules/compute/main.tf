# ==================================================================
# 엔드포인트
# ==================================================================
resource "aws_vpc_endpoint" "std17_gw_endpoint" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.ap-northeast-3.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = var.route_table_ids

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowEksNodeRole"
        Effect    = "Allow"
        Principal = { AWS = var.eks_node_role_arn }
        Action    = "s3:*"
        Resource  = "*"
      }
    ]
  })

  tags = { Name = "std17-gw-endpoint" }
}
