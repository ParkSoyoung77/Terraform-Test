# ==================================================================
# Lambda 배포 패키지 빌드 (pymysql은 기본 런타임에 없으므로 함께 패키징)
# ==================================================================

resource "null_resource" "install_lambda_deps" {
  triggers = {
    requirements_hash = filemd5("${path.module}/lambda/requirements.txt")
    source_hash       = filemd5("${path.module}/lambda/db_check.py")
  }

  provisioner "local-exec" {
    command = "pip install -r ${path.module}/lambda/requirements.txt -t ${path.module}/lambda --upgrade --no-cache-dir --break-system-packages"
  }
}

data "archive_file" "std17_db_check_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda"
  output_path = "${path.module}/build/db_check.zip"
  excludes    = ["requirements.txt"]

  depends_on = [null_resource.install_lambda_deps]
}

# ==================================================================
# IAM 역할 / 권한
# ==================================================================

resource "aws_iam_role" "std17_lambda_role" {
  name = "std17-lambda-db-check-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { Service = "lambda.amazonaws.com" }
        Action    = "sts:AssumeRole"
      }
    ]
  })

  tags = { Name = "std17-lambda-db-check-role" }
}

# 1. VPC 안에서 ENI 생성/로그 작성을 위한 AWS 관리형 정책
resource "aws_iam_role_policy_attachment" "std17_lambda_vpc_access" {
  role       = aws_iam_role.std17_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

# 2. RDS 접속용 시크릿 조회 권한 (해당 시크릿에 대해서만 최소 권한 부여)
resource "aws_iam_role_policy" "std17_lambda_secrets_access" {
  name = "std17-lambda-secrets-access"
  role = aws_iam_role.std17_lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "Statement1"
        Effect   = "Allow"
        Action   = ["secretsmanager:GetSecretValue"]
        Resource = var.db_secret_arn
      }
    ]
  })
}

# ==================================================================
# Lambda 함수
# ==================================================================

resource "aws_cloudwatch_log_group" "std17_db_check_lg" {
  name              = "/aws/lambda/std17-db-check"
  retention_in_days = 7
}

resource "aws_lambda_function" "std17_db_check" {
  function_name = "std17-db-check"
  role          = aws_iam_role.std17_lambda_role.arn

  filename         = data.archive_file.std17_db_check_zip.output_path
  source_code_hash = data.archive_file.std17_db_check_zip.output_base64sha256

  handler = "db_check.lambda_handler"
  runtime = "python3.14"
  timeout = 10

  vpc_config {
    subnet_ids         = var.private_subnet_ids
    security_group_ids = [var.security_group_id]
  }

  environment {
    variables = {
      DB_SECRET_NAME = var.db_secret_arn
      DB_HOST        = var.db_host
      DB_NAME        = var.db_name
      DB_PORT        = "3306"
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.std17_lambda_vpc_access,
    aws_iam_role_policy.std17_lambda_secrets_access,
    aws_cloudwatch_log_group.std17_db_check_lg,
  ]

  tags = { Name = "std17-db-check" }
}

# # ==================================================================
# # Layer
# # ==================================================================
# data "archive_file" "pymysql_layer_zip" {
#   type        = "zip"
#   source_dir  = "${path.module}/layer"   # 이 안에 python/pymysql/ ... 구조
#   output_path = "${path.module}/build/pymysql_layer.zip"
# }

# resource "aws_lambda_layer_version" "pymysql_layer" {
#   layer_name          = "std17-pymysql-layer"
#   filename            = data.archive_file.pymysql_layer_zip.output_path
#   compatible_runtimes = ["python3.14"]
# }

# resource "aws_lambda_function" "std17_db_check" {
#   # ...
#   filename = data.archive_file.code_only_zip.output_path   # 이땐 db_check.py만 담긴 zip
#   layers   = [aws_lambda_layer_version.pymysql_layer.arn]
# }