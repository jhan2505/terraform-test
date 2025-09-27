variable "project_name" {
  description = "Nombre del proyecto"
  type        = string
}

variable "environment" {
  description = "Ambiente de despliegue"
  type        = string
}

variable "vpc_id" {
  description = "ID de la VPC"
  type        = string
}

variable "private_subnet_ids" {
  description = "IDs de las subnets privadas"
  type        = list(string)
}

variable "security_group_id" {
  description = "ID del Security Group para RDS"
  type        = string
}

variable "db_instance_class" {
  description = "Clase de instancia RDS"
  type        = string
}

variable "db_allocated_storage" {
  description = "Almacenamiento asignado para RDS (GB)"
  type        = number
}

variable "db_max_allocated_storage" {
  description = "Almacenamiento máximo para auto-scaling (GB)"
  type        = number
}

variable "db_engine_version" {
  description = "Versión del motor MySQL"
  type        = string
}

variable "db_name" {
  description = "Nombre de la base de datos"
  type        = string
}

variable "db_username" {
  description = "Usuario administrador de la base de datos"
  type        = string
}

variable "db_password" {
  description = "Contraseña de la base de datos"
  type        = string
  sensitive   = true
}

variable "common_tags" {
  description = "Tags comunes para todos los recursos"
  type        = map(string)
}

