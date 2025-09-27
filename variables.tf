# Variables globales
variable "aws_region" {
  description = "Región de AWS donde se desplegarán los recursos"
  type        = string
  default     = "us-west-2"
}

variable "project_name" {
  description = "Nombre del proyecto"
  type        = string
  default     = "terraform-aws-infrastructure"
}

variable "environment" {
  description = "Ambiente de despliegue (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "allowed_ssh_ips" {
  description = "Lista de IPs permitidas para acceso SSH"
  type        = list(string)
  default     = ["0.0.0.0/0"] # Cambiar por IPs específicas en producción
}

# Variables de VPC
variable "vpc_cidr" {
  description = "CIDR block para la VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Zonas de disponibilidad a utilizar"
  type        = list(string)
  default     = ["us-west-2a", "us-west-2b"]
}

# Variables de EC2
variable "instance_type" {
  description = "Tipo de instancia EC2"
  type        = string
  default     = "t3.medium"
}

variable "key_pair_name" {
  description = "Nombre del key pair para acceso SSH"
  type        = string
  default     = "terraform-key"
}

variable "ami_id" {
  description = "ID de la AMI de Amazon Linux 2"
  type        = string
  default     = "" # Se obtendrá dinámicamente
}

# Variables de RDS
variable "db_instance_class" {
  description = "Clase de instancia RDS"
  type        = string
  default     = "db.t3.micro"
}

variable "db_allocated_storage" {
  description = "Almacenamiento asignado para RDS (GB)"
  type        = number
  default     = 20
}

variable "db_max_allocated_storage" {
  description = "Almacenamiento máximo para auto-scaling (GB)"
  type        = number
  default     = 100
}

variable "db_engine_version" {
  description = "Versión del motor MySQL"
  type        = string
  default     = "8.0"
}

variable "db_name" {
  description = "Nombre de la base de datos"
  type        = string
  default     = "terraformdb"
}

variable "db_username" {
  description = "Usuario administrador de la base de datos"
  type        = string
  default     = "admin"
}

variable "db_password" {
  description = "Contraseña de la base de datos"
  type        = string
  sensitive   = true
}

# Variables de ECR
variable "ecr_repository_name" {
  description = "Nombre del repositorio ECR"
  type        = string
  default     = "terraform-docker-app"
}

# Variables de tags
variable "common_tags" {
  description = "Tags comunes para todos los recursos"
  type        = map(string)
  default = {
    Project     = "terraform-aws-infrastructure"
    Environment = "dev"
    ManagedBy   = "terraform"
    Owner       = "devops-team"
  }
}

