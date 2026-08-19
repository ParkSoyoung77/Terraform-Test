# ---------------------------------------------------------
# EC2 (S3 FullAccess 접근용 - 백업용)
# s3:ListBucket, s3:PutObject를 포함해서 S3 관련 액션 전체(s3:*)가 이미 다 포함
# ---------------------------------------------------------
resource "aws_iam_role" "std17_s3_fullaccess_role" {
  name        = var.fullaccess_role_name
  description = var.role_description

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = merge({ Name = var.fullaccess_role_name }, var.tags)
}

resource "aws_iam_role_policy_attachment" "std17_s3_fullaccess_attach" {
  role       = aws_iam_role.std17_s3_fullaccess_role.name
  policy_arn = var.fullaccess_policy_arn
}

resource "aws_iam_instance_profile" "std17_s3_fullaccess_profile" {
  name = var.fullaccess_role_name
  role = aws_iam_role.std17_s3_fullaccess_role.name
}

# ---------------------------------------------------------
# ECR ReadOnly 정책 추가 (S3 FullAccess role에 동일하게 부착)
# 별도 role/profile 생성 없이 기존 role에 정책만 추가
# ---------------------------------------------------------
resource "aws_iam_role_policy_attachment" "std17_ecr_readonly_attach" {
  role       = aws_iam_role.std17_s3_fullaccess_role.name
  policy_arn = var.ecr_readonly_policy_arn
}