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
        Sid       = "AllowEksRoles"
        Effect    = "Allow"
        Principal = {
          AWS = [
            var.eks_node_role_arn,
            var.eks_s3_csi_role_arn
          ]
        }
        Action    = "s3:*"
        Resource  = "*"
      },
      {
        Sid       = "AllowEcrImageLayerPull"
        Effect    = "Allow"
        Principal = "*"
        Action    = ["s3:GetObject"]
        Resource  = "arn:aws:s3:::prod-*-starport-layer-bucket/*"
      }
    ]
  })

  tags = { Name = "std17-gw-endpoint" }
}