# Outputs de VPC
output "vpc_id" {
  description = "ID de la VPC creada"
  value       = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "CIDR block de la VPC"
  value       = module.vpc.vpc_cidr_block
}

output "public_subnet_ids" {
  description = "IDs de las subnets públicas"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs de las subnets privadas"
  value       = module.vpc.private_subnet_ids
}

# Outputs de EC2
output "ec2_instance_id" {
  description = "ID de la instancia EC2"
  value       = module.ec2.instance_id
}

output "ec2_public_ip" {
  description = "IP pública de la instancia EC2"
  value       = module.ec2.public_ip
}

output "ec2_public_dns" {
  description = "DNS público de la instancia EC2"
  value       = module.ec2.public_dns
}

output "ec2_ssh_command" {
  description = "Comando SSH para conectarse a la instancia"
  value       = "ssh -i ~/.ssh/${var.key_pair_name}.pem ec2-user@${module.ec2.public_ip}"
}

# Outputs de RDS
output "rds_endpoint" {
  description = "Endpoint de la base de datos RDS"
  value       = module.rds.rds_endpoint
  sensitive   = true
}

output "rds_port" {
  description = "Puerto de la base de datos RDS"
  value       = module.rds.rds_port
}

output "rds_database_name" {
  description = "Nombre de la base de datos"
  value       = module.rds.rds_database_name
}

# Outputs de Docker Hub
output "docker_image_url" {
  description = "URL de la imagen Docker en Docker Hub"
  value       = "jmarrufo/terraform:latest"
}

output "docker_hub_url" {
  description = "URL del repositorio en Docker Hub"
  value       = "https://hub.docker.com/r/jmarrufo/terraform"
}

# Outputs de aplicación
output "application_url" {
  description = "URL de la aplicación web"
  value       = "http://${module.ec2.public_ip}"
}

output "application_database_check" {
  description = "URL de verificación de conexión a base de datos"
  value       = "http://${module.ec2.public_ip}/db_check.sh"
}

# Outputs de información de conexión
output "database_connection_info" {
  description = "Información de conexión a la base de datos"
  value = {
    endpoint = module.rds.rds_endpoint
    port     = module.rds.rds_port
    database = module.rds.rds_database_name
    username = var.db_username
  }
  sensitive = true
}

# Outputs de Docker
output "docker_image_info" {
  description = "Información de la imagen Docker"
  value = {
    repository_url = "jmarrufo/terraform"
    image_tag      = "latest"
    pull_command   = "docker pull jmarrufo/terraform:latest"
    docker_hub_url = "https://hub.docker.com/r/jmarrufo/terraform"
  }
}

# Outputs de monitoreo
output "cloudwatch_log_groups" {
  description = "Grupos de logs de CloudWatch"
  value = {
    ec2_logs = "/aws/ec2/${var.project_name}-${var.environment}"
    rds_logs = "/aws/rds/${var.project_name}-${var.environment}"
  }
}

