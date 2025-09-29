# Configuración del backend remoto para Terraform
# Este archivo debe ser configurado antes del primer despliegue

terraform {
  backend "s3" {
    # Cambiar por tu bucket de S3
    bucket = "terraform-state-bucket-jhan"
    key    = "infrastructure/terraform.tfstate"
    region = "us-west-2"

    # Bloqueo nativo de S3 (Terraform 1.10+) - Sin necesidad de DynamoDB
    use_lockfile = true

    # Encriptación del state file
    encrypt = true
  }
}

# Nota: Para migrar de backend local a remoto:
# 1. Configurar las variables del backend arriba
# 2. Ejecutar: terraform init
# 3. Seleccionar "yes" cuando pregunte si migrar el estado
# 4. Verificar: terraform state list
#
# Configuración adicional del bucket S3 (opcional):
# - Habilitar versionado: aws s3api put-bucket-versioning --bucket tu-bucket --versioning-configuration Status=Enabled
# - Habilitar cifrado: aws s3api put-bucket-encryption --bucket tu-bucket --server-side-encryption-configuration '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"AES256"}}]}'

