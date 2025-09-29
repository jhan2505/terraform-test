# 🚀 Guía de Despliegue - Terraform AWS Infrastructure

## 📋 Descripción del Proyecto

Ver descripción completa en [README.md](README.md#-descripción-del-proyecto)

## 🏗️ Arquitectura

Ver diagrama de arquitectura en [README.md](README.md#-arquitectura)


## ⚙️ Configuración Inicial

### 1. Herramientas Requeridas
```bash
# Verificar que tienes instalado:
terraform --version    # >= 1.0
aws --version         # AWS CLI v2
docker --version      # Docker
git --version         # Git
```

### 2. Configuración de AWS
```bash
# Configurar credenciales AWS
aws configure

# Verificar configuración
aws sts get-caller-identity

# Crear key pair para EC2
aws ec2 create-key-pair --key-name terraform-key --query 'KeyMaterial' --output text > ~/.ssh/terraform-key.pem
chmod 400 ~/.ssh/terraform-key.pem
```

### 3. Configuración del Proyecto (OBLIGATORIO)
```bash
# 1. Navegar al proyecto
cd terraform-test

# 2. Configurar backend S3 (OBLIGATORIO)
nano backend.tf  # Cambiar bucket = "tu-bucket-unico"

# 3. Configurar variables
cp terraform.tfvars.example terraform.tfvars
nano terraform.tfvars  # Editar con tus valores

# 4. Cambiar IPs de SSH (OBLIGATORIO)
allowed_ssh_ips = [
  "TU_IP_PUBLICA/32",  # Reemplazar con tu IP real
  "203.0.113.0/24"     # IPs adicionales si las tienes
]

# 5. Cambiar password de base de datos (OBLIGATORIO)
db_password = "TuPasswordSeguro123!"
```

### 4. Crear Recursos de Backend (Solo Primera Vez)
```bash
# Crear bucket S3 para state (usar el mismo nombre de backend.tf)
aws s3 mb s3://tu-bucket-unico

# Nota: Con Terraform 1.10+ y bloqueo nativo de S3, DynamoDB NO es necesario
# El bloqueo se maneja automáticamente en S3 con use_lockfile = true
```

---

## 🎯 Opción 1: Script de Despliegue (Recomendado)

### Ventajas
- Fácil de usar: Un solo comando para todo
- Validaciones automáticas: Verifica prerrequisitos
- Logging detallado: Muestra progreso paso a paso
- Manejo de errores: Detiene si algo falla

### 🚀 Pasos para Desplegar

```bash
# 1. Hacer ejecutables los scripts
chmod +x scripts/*.sh

# 2. Ejecutar pipeline completo
./scripts/deploy.sh dev all

# 3. Verificar aplicación
curl http://$(terraform output -raw ec2_public_ip)/
curl http://$(terraform output -raw ec2_public_ip)/db_check.sh

# 4. Destruir (opcional)
./scripts/destroy.sh dev
```

### 📊 Comandos Disponibles

| Comando | Descripción |
|---------|-------------|
| `./scripts/deploy.sh dev init` | Inicializar Terraform |
| `./scripts/deploy.sh dev validate` | Validar configuración |
| `./scripts/deploy.sh dev format` | Formatear código |
| `./scripts/deploy.sh dev plan` | Planificar cambios |
| `./scripts/deploy.sh dev apply` | Aplicar cambios |
| `./scripts/deploy.sh dev docker` | Construir Docker |
| `./scripts/deploy.sh dev all` | Pipeline completo |

---

## ⚙️ Opción 2: Comandos Terraform Directos

### Ventajas
- Control total: Cada comando ejecutado manualmente
- Flexibilidad: Personalizar cada paso
- Debugging: Fácil identificar problemas

### 🚀 Pasos para Desplegar

> **⚠️ IMPORTANTE**: La imagen Docker debe construirse ANTES de aplicar Terraform porque la instancia EC2 intentará descargar la imagen inmediatamente al arrancar.

```bash
# 1. Construir y subir imagen Docker (OBLIGATORIO ANTES)
cd docker
./build.sh latest jmarrufo/terraform
cd ..

# 2. Inicializar Terraform
terraform init

# 3. Validar y formatear
terraform validate
terraform fmt -recursive

# 4. Planificar cambios
terraform plan -var="environment=dev"

# 5. Aplicar infraestructura
terraform apply -var="environment=dev"

# 6. Verificar aplicación
curl http://$(terraform output -raw ec2_public_ip)/
curl http://$(terraform output -raw ec2_public_ip)/db_check.sh

# 7. Destruir (opcional)
terraform destroy -var="environment=dev"
```

---

## 🔄 Opción 3: GitHub Actions CI/CD

### Ventajas
- Automatización completa: Sin intervención manual
- Validaciones automáticas: Tests y seguridad
- Historial de despliegues: Tracking completo
- Rollback automático: En caso de errores

### 🚀 Pasos para Configurar

```bash
# 1. Configurar repositorio
git init
git add .
git commit -m "Initial commit"
git remote add origin https://github.com/tu-usuario/terraform-aws-infrastructure.git
git push -u origin main

# 2. Configurar secrets en GitHub
# Ir a Settings > Secrets and variables > Actions
# Agregar: AWS_ACCESS_KEY_ID y AWS_SECRET_ACCESS_KEY

# 3. Desplegar
git push origin main
# El pipeline se ejecutará automáticamente
```

---

## 🧪 Testing y Verificación

### 1. Verificar Infraestructura
```bash
# Ver outputs de Terraform
terraform output

# Verificar instancia EC2
aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=terraform-aws-infrastructure-dev-ec2"

# Verificar RDS
aws rds describe-db-instances \
  --db-instance-identifier terraform-aws-infrastructure-dev-mysql

# Verificar Docker Hub
docker pull jmarrufo/terraform:latest
```

### 2. Verificar Aplicación
```bash
# Obtener IP de la instancia
INSTANCE_IP=$(aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=terraform-aws-infrastructure-dev-ec2" \
  --query 'Reservations[0].Instances[0].PublicIpAddress' \
  --output text)

# Probar endpoints
curl http://$INSTANCE_IP/
curl http://$INSTANCE_IP/db_check.sh
```

### 3. Verificación de Base de Datos
El proyecto incluye un script automatizado que verifica la conexión a MySQL RDS:

**Endpoint**: `http://[EC2-IP]/db_check.sh`

**Respuesta exitosa**:
```json
{
    "status": "connected",
    "message": "Conexión exitosa a MySQL RDS",
    "database_info": {
        "host": "terraform-aws-infrastructure-dev-mysql.xxx.rds.amazonaws.com",
        "port": "3306",
        "database": "terraformdb",
        "user": "admin",
        "mysql_version": "8.0.42",
        "server_time": "2025-09-28 18:26:39"
    },
    "timestamp": "2025-09-28T18:26:39Z"
}
```

**Verificación manual**:
```bash
# Verificar conexión a base de datos
curl -s http://$(terraform output -raw ec2_public_ip)/db_check.sh | jq

# Verificar en navegador
open http://$(terraform output -raw ec2_public_ip)/
```

### 4. Verificar Docker
```bash
# Conectarse por SSH
ssh -i ~/.ssh/terraform-key.pem ec2-user@$INSTANCE_IP

# Ver contenedores
docker ps

# Ver logs
docker logs app-container

# Ejecutar comando en contenedor
docker exec -it app-container bash
```

### 4.1 Verificar Base de Datos Munualmente
```bash
# Conectarse a la base de datos
mysql -h $(terraform output -raw rds_endpoint) -u admin -p

# Dentro de MySQL:
SHOW DATABASES;
USE terraformdb;
SHOW TABLES;
```

---

¡Elige la opción que mejor se adapte a tu flujo de trabajo! 🚀

**Versión**: 1.0.0
