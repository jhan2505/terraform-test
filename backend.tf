# Configuración del backend remoto para Terraform
# Este archivo debe ser configurado antes del primer despliegue

terraform {
  backend "s3" {
    # Cambiar por tu bucket de S3
    bucket         = "terraform-state-bucket-jhan"
    key            = "infrastructure/terraform.tfstate"
    region         = "us-west-2"
    
    # Tabla DynamoDB para bloqueo de estado
    dynamodb_table = "terraform-locks"
    
    # Encriptación del state file
    encrypt        = true
    
    # Versionado del bucket (recomendado)
    versioning     = true
    
    # Prevención de borrado accidental
    force_path_style = true
  }
}

# Nota: Para migrar de backend local a remoto:
# 1. Configurar las variables del backend arriba
# 2. Ejecutar: terraform init
# 3. Seleccionar "yes" cuando pregunte si migrar el estado
# 4. Verificar: terraform state list

