# IAM 역할 - EC2가 AWS 서비스를 호출할 수 있도록 허용
resource "aws_iam_role" "std17_s3_role" {
  name        = var.role_name
  description = var.role_description

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = merge(
    { Name = var.role_name },
    var.tags
  )
}

# 관리형 정책 연결
resource "aws_iam_role_policy_attachment" "std17_s3_readonly" {
  role       = aws_iam_role.std17_s3_role.name
  policy_arn = var.policy_arn
}

# 인스턴스 프로파일
resource "aws_iam_instance_profile" "std17_s3_profile" {
  name = var.role_name
  role = aws_iam_role.std17_s3_role.name
}