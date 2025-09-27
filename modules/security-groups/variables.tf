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

variable "allowed_ssh_ips" {
  description = "Lista de IPs permitidas para acceso SSH"
  type        = list(string)
}

variable "common_tags" {
  description = "Tags comunes para todos los recursos"
  type        = map(string)
}

