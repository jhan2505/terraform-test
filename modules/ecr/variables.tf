variable "project_name" {
  description = "Nombre del proyecto"
  type        = string
}

variable "environment" {
  description = "Ambiente de despliegue"
  type        = string
}

variable "ecr_repository_name" {
  description = "Nombre del repositorio ECR"
  type        = string
}

variable "common_tags" {
  description = "Tags comunes para todos los recursos"
  type        = map(string)
}

