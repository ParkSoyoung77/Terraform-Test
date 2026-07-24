# ==================================================================
# pymysql Lambda Layer (함수 코드와 분리 - 수동 재적용 문제 해결)
# ==================================================================
resource "null_resource" "build_pymysql_layer" {
  triggers = {
    requirements_hash = filemd5("${path.module}/lambda/requirements.txt")
  }

  provisioner "local-exec" {
    command = join(" ", [
      "pip install",
      "-r ${path.module}/lambda/requirements.txt",
      "-t ${path.module}/layer/python",
      "--platform manylinux2014_x86_64",
      "--only-binary=:all:",
      "--python-version 3.14",
      "--upgrade",
      "--no-cache-dir",
      "--break-system-packages",
    ])
  }
}

data "archive_file" "pymysql_layer_zip" {
  type        = "zip"
  source_dir  = "${path.module}/layer"
  output_path = "${path.module}/build/pymysql_layer.zip"

  depends_on = [null_resource.build_pymysql_layer]
}

resource "aws_lambda_layer_version" "pymysql_layer" {
  layer_name               = "std17-pymysql-layer"
  filename                  = data.archive_file.pymysql_layer_zip.output_path
  source_code_hash          = data.archive_file.pymysql_layer_zip.output_base64sha256
  compatible_runtimes        = ["python3.14"]
  compatible_architectures   = ["x86_64"]
}

# ==================================================================
# Lambda 함수 코드 (db_check.py 단독 - Layer와 완전 분리)
# ==================================================================
data "archive_file" "std17_db_check_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda/db_check.py"
  output_path = "${path.module}/build/db_check.zip"
}

resource "aws_cloudwatch_log_group" "std17_db_check_lg" {
  name              = "/aws/lambda/std17-db-check"
  retention_in_days = 7
}

resource "aws_lambda_function" "std17_db_check" {
  function_name = "std17-db-check"
  role          = var.lambda_role_arn

  filename         = data.archive_file.std17_db_check_zip.output_path
  source_code_hash = data.archive_file.std17_db_check_zip.output_base64sha256

  handler = "db_check.lambda_handler"
  runtime = "python3.14"
  timeout = 30

  layers = [aws_lambda_layer_version.pymysql_layer.arn]

  vpc_config {
    subnet_ids         = var.private_subnet_ids
    security_group_ids = [var.security_group_id]
  }

  environment {
    variables = {
      DB_SECRET_NAME = var.db_secret_arn
      DB_HOST        = var.db_proxy_endpoint   # RDS 직결이 아니라 Proxy 엔드포인트
      DB_NAME        = var.db_name
      DB_PORT        = "3306"
    }
  }

  depends_on = [
    aws_cloudwatch_log_group.std17_db_check_lg,
    aws_iam_role_policy.std17_lambda_secrets_access,
  ]

  tags = { Name = "std17-db-check" }
}

# Lambda 역할에 시크릿 조회 권한 부착 (순환참조 방지: iam이 아니라 여기서)
resource "aws_iam_role_policy" "std17_lambda_secrets_access" {
  name = "std17-lambda-secrets-access"
  role = var.lambda_role_name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid      = "Statement1"
      Effect   = "Allow"
      Action   = ["secretsmanager:GetSecretValue"]
      Resource = var.db_secret_arn
    }]
  })
}