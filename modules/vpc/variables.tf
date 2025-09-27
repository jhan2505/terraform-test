variable "project_name" {
  description = "Nombre del proyecto"
  type        = string
}

variable "environment" {
  description = "Ambiente de despliegue"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block para la VPC"
  type        = string
}

variable "availability_zones" {
  description = "Zonas de disponibilidad a utilizar"
  type        = list(string)
}

variable "common_tags" {
  description = "Tags comunes para todos los recursos"
  type        = map(string)
}

