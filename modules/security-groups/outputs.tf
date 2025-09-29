output "ec2_security_group_id" {
  description = "ID del Security Group para EC2"
  value       = aws_security_group.ec2.id
}

output "rds_security_group_id" {
  description = "ID del Security Group para RDS"
  value       = aws_security_group.rds.id
}

output "ec2_security_group_arn" {
  description = "ARN del Security Group para EC2"
  value       = aws_security_group.ec2.arn
}

output "rds_security_group_arn" {
  description = "ARN del Security Group para RDS"
  value       = aws_security_group.rds.arn
}

