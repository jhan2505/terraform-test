output "instance_id" {
  description = "ID de la instancia EC2"
  value       = aws_instance.main.id
}

output "instance_arn" {
  description = "ARN de la instancia EC2"
  value       = aws_instance.main.arn
}

output "public_ip" {
  description = "IP pública de la instancia EC2"
  value       = aws_eip.main.public_ip
}

output "public_dns" {
  description = "DNS público de la instancia EC2"
  value       = aws_instance.main.public_dns
}

output "private_ip" {
  description = "IP privada de la instancia EC2"
  value       = aws_instance.main.private_ip
}

output "instance_type" {
  description = "Tipo de instancia EC2"
  value       = aws_instance.main.instance_type
}

output "availability_zone" {
  description = "Zona de disponibilidad de la instancia"
  value       = aws_instance.main.availability_zone
}

output "security_group_ids" {
  description = "IDs de los Security Groups"
  value       = aws_instance.main.vpc_security_group_ids
}

output "iam_instance_profile_name" {
  description = "Nombre del IAM Instance Profile"
  value       = aws_iam_instance_profile.ec2_profile.name
}

output "iam_role_arn" {
  description = "ARN del IAM Role"
  value       = aws_iam_role.ec2_role.arn
}

