# ==================== main.tf ====================

# ---------------------------------------------------------
# EC2 (S3 ReadOnly 접근용)
# ---------------------------------------------------------
resource "aws_iam_role" "std17_s3_readonly_role" {
  name        = var.readonly_role_name
  description = var.role_description

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = merge({ Name = var.readonly_role_name }, var.tags)
}

resource "aws_iam_role_policy_attachment" "std17_s3_readonly_attach" {
  role       = aws_iam_role.std17_s3_readonly_role.name
  policy_arn = var.readonly_policy_arn
}

resource "aws_iam_instance_profile" "std17_s3_readonly_profile" {
  name = var.readonly_role_name
  role = aws_iam_role.std17_s3_readonly_role.name
}

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

# data "aws_iam_policy_document" "s3_backup_scoped" {
#   statement {
#     effect = "Allow"
#     actions = [
#       "s3:ListBucket",
#       "s3:PutObject",
#       "s3:GetObject"
#     ]
#     resources = [
#       "arn:aws:s3:::${var.backup_bucket_name}",
#       "arn:aws:s3:::${var.backup_bucket_name}/*"
#     ]
#   }
# }

# resource "aws_iam_role_policy" "s3_backup_scoped" {
#   name   = "${var.fullaccess_role_name}-scoped"
#   role   = aws_iam_role.std17_s3_fullaccess_role.name
#   policy = data.aws_iam_policy_document.s3_backup_scoped.json
# }