variable "project_name" {
  description = "Nombre del proyecto"
  type        = string
}

variable "environment" {
  description = "Ambiente de despliegue"
  type        = string
}

variable "ami_id" {
  description = "ID de la AMI"
  type        = string
}

variable "instance_type" {
  description = "Tipo de instancia EC2"
  type        = string
}

variable "key_pair_name" {
  description = "Nombre del key pair para acceso SSH"
  type        = string
}

variable "vpc_id" {
  description = "ID de la VPC"
  type        = string
}

variable "public_subnet_id" {
  description = "ID de la subnet pública"
  type        = string
}

variable "security_group_id" {
  description = "ID del Security Group para EC2"
  type        = string
}

variable "rds_endpoint" {
  description = "Endpoint de la base de datos RDS"
  type        = string
}

variable "rds_username" {
  description = "Usuario de la base de datos"
  type        = string
}

variable "rds_password" {
  description = "Contraseña de la base de datos"
  type        = string
  sensitive   = true
}

variable "rds_database" {
  description = "Nombre de la base de datos"
  type        = string
}

variable "docker_image_url" {
  description = "URL de la imagen Docker en Docker Hub"
  type        = string
}

variable "common_tags" {
  description = "Tags comunes para todos los recursos"
  type        = map(string)
}

