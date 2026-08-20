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
        Sid       = "Statement1"
        Effect    = "Allow"
        Principal = "*"
        Action    = "*"
        Resource  = "*"
      }
    ]
  })

  tags = { Name = "std17-gw-endpoint" }
}

# ==================================================================
# ECR API 엔드포인트 (인증/이미지 메타데이터용)
# ==================================================================
resource "aws_vpc_endpoint" "std17_ecr_api" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.ap-northeast-3.ecr.api"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.public_subnet_ids
  security_group_ids  = [var.ecr_endpoint_sg_id]
  private_dns_enabled = true

  tags = { Name = "std17-ecr-api-endpoint" }
}

# ==================================================================
# ECR DKR 엔드포인트 (docker pull/push 실제 이미지 레이어용)
# ==================================================================
resource "aws_vpc_endpoint" "std17_ecr_dkr" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.ap-northeast-3.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.public_subnet_ids
  security_group_ids  = [var.ecr_endpoint_sg_id]
  private_dns_enabled = true

  tags = { Name = "std17-ecr-dkr-endpoint" }
}