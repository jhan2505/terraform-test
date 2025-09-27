output "rds_endpoint" {
  description = "Endpoint de la base de datos RDS"
  value       = aws_db_instance.main.endpoint
}

output "rds_port" {
  description = "Puerto de la base de datos RDS"
  value       = aws_db_instance.main.port
}

output "rds_database_name" {
  description = "Nombre de la base de datos"
  value       = aws_db_instance.main.db_name
}

output "rds_username" {
  description = "Usuario de la base de datos"
  value       = aws_db_instance.main.username
  sensitive   = true
}

output "rds_arn" {
  description = "ARN de la instancia RDS"
  value       = aws_db_instance.main.arn
}

output "rds_identifier" {
  description = "Identificador de la instancia RDS"
  value       = aws_db_instance.main.identifier
}

output "rds_instance_class" {
  description = "Clase de instancia RDS"
  value       = aws_db_instance.main.instance_class
}

output "rds_allocated_storage" {
  description = "Almacenamiento asignado"
  value       = aws_db_instance.main.allocated_storage
}

output "rds_engine_version" {
  description = "Versión del motor de base de datos"
  value       = aws_db_instance.main.engine_version
}

output "rds_multi_az" {
  description = "Si la instancia está en Multi-AZ"
  value       = aws_db_instance.main.multi_az
}

output "rds_backup_retention_period" {
  description = "Período de retención de backups"
  value       = aws_db_instance.main.backup_retention_period
}

output "rds_performance_insights_enabled" {
  description = "Si Performance Insights está habilitado"
  value       = aws_db_instance.main.performance_insights_enabled
}

