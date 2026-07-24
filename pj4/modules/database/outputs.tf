# output "db_instance_id" {
#   description = "RDS Writer 인스턴스 ID"
#   value       = aws_db_instance.std17_mysql_rds.id
# }

# output "db_endpoint" {
#   description = "RDS Writer 엔드포인트 (포트 포함)"
#   value       = aws_db_instance.std17_mysql_rds.endpoint
# }

# output "db_address" {
#   description = "포트가 붙지 않은 순수 호스트 주소(Lambda용)"
#   value       = aws_db_instance.std17_mysql_rds.address
# }

# output "db_subnet_group_name" {
#   description = "DB 서브넷 그룹 이름"
#   value       = aws_db_subnet_group.std17_db_private_subnet_group.name
# }

# output "master_user_secret_arn" {
#   description = "Secrets Manager ARN (Lambda DB_SECRET_NAME용)"
#   value       = aws_secretsmanager_secret.std17_db_secret.arn 
# }

# output "rds_proxy_endpoint" {
#   description = "Lambda가 접속할 RDS Proxy 엔드포인트 (RDS 직결 주소 대신 이걸 사용)"
#   value       = aws_db_proxy.std17_rds_proxy.endpoint
# }
