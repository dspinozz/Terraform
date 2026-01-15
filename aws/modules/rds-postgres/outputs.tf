# ------------------------------------------------------------------------------
# RDS PostgreSQL Module Outputs
# ------------------------------------------------------------------------------

output "instance_id" {
  description = "ID of the RDS instance"
  value       = aws_db_instance.main.id
}

output "instance_arn" {
  description = "ARN of the RDS instance"
  value       = aws_db_instance.main.arn
}

output "endpoint" {
  description = "Connection endpoint"
  value       = aws_db_instance.main.endpoint
}

output "address" {
  description = "Hostname of the RDS instance"
  value       = aws_db_instance.main.address
}

output "port" {
  description = "Port of the RDS instance"
  value       = aws_db_instance.main.port
}

output "database_name" {
  description = "Name of the database"
  value       = aws_db_instance.main.db_name
}

output "username" {
  description = "Master username"
  value       = aws_db_instance.main.username
  sensitive   = true
}

output "security_group_id" {
  description = "ID of the RDS security group"
  value       = aws_security_group.main.id
}

output "subnet_group_name" {
  description = "Name of the DB subnet group"
  value       = aws_db_subnet_group.main.name
}

output "parameter_group_name" {
  description = "Name of the parameter group"
  value       = aws_db_parameter_group.main.name
}

output "secret_arn" {
  description = "ARN of the Secrets Manager secret"
  value       = var.create_secret ? aws_secretsmanager_secret.main[0].arn : null
}

output "connection_url" {
  description = "PostgreSQL connection URL"
  value       = "postgresql://${aws_db_instance.main.username}@${aws_db_instance.main.address}:${aws_db_instance.main.port}/${aws_db_instance.main.db_name}"
  sensitive   = true
}
