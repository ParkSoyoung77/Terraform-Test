# ---------------------------------------------------------
# EC2 (S3 접근용)
# ---------------------------------------------------------
resource "aws_iam_role" "std17_s3_role" {
  name        = var.role_name
  description = var.role_description

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = merge({ Name = var.role_name }, var.tags)
}

resource "aws_iam_role_policy_attachment" "std17_s3_readonly" {
  role       = aws_iam_role.std17_s3_role.name
  policy_arn = var.policy_arn
}

resource "aws_iam_instance_profile" "std17_s3_profile" {
  name = var.role_name
  role = aws_iam_role.std17_s3_role.name
}

# ---------------------------------------------------------
# RDS Proxy (역할만 - 시크릿 정책은 database 모듈에서 부착)
# ---------------------------------------------------------
resource "aws_iam_role" "std17_rds_proxy_role" {
  name = "std17-rds-proxy-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "rds.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = { Name = "std17-rds-proxy-role" }
}

# ---------------------------------------------------------
# Lambda (역할만 - 시크릿 정책은 api 모듈에서 부착)
# ---------------------------------------------------------
resource "aws_iam_role" "std17_lambda_role" {
  name = "std17-lambda-db-check-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = { Name = "std17-lambda-db-check-role" }
}

resource "aws_iam_role_policy_attachment" "std17_lambda_vpc_access" {
  role       = aws_iam_role.std17_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}