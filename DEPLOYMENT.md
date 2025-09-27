# 🚀 Guía de Despliegue - Terraform AWS Infrastructure

## 📋 Opciones de Despliegue

Este proyecto ofrece **3 opciones** para desplegar la infraestructura:

1. **Script de Despliegue** (Recomendado para desarrollo)
2. **Comandos Terraform Directos** (Para usuarios avanzados)
3. **GitHub Actions CI/CD** (Para producción)

---

## 🎯 Opción 1: Script de Despliegue (Recomendado)

### ✅ Ventajas
- **Fácil de usar**: Un solo comando para todo
- **Validaciones automáticas**: Verifica prerrequisitos
- **Logging detallado**: Muestra progreso paso a paso
- **Manejo de errores**: Detiene si algo falla

### 🚀 Uso

```bash
# 1. Configurar variables
cp terraform.tfvars.example terraform.tfvars
nano terraform.tfvars  # Editar con tus valores

# 2. Hacer ejecutables los scripts
chmod +x scripts/*.sh

# 3. Ejecutar despliegue completo
./scripts/deploy.sh dev all

# 4. Solo planificar cambios
./scripts/deploy.sh dev plan

# 5. Aplicar cambios
./scripts/deploy.sh dev apply

# 6. Construir y subir Docker
./scripts/deploy.sh dev docker

# 7. Destruir infraestructura
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

### ✅ Ventajas
- **Control total**: Cada comando ejecutado manualmente
- **Flexibilidad**: Personalizar cada paso
- **Debugging**: Fácil identificar problemas

### 🚀 Uso

```bash
# 1. Configurar variables
cp terraform.tfvars.example terraform.tfvars
nano terraform.tfvars

# 2. Inicializar Terraform
terraform init

# 3. Validar configuración
terraform validate

# 4. Formatear código
terraform fmt -recursive

# 5. Planificar cambios
terraform plan -var="environment=dev"

# 6. Aplicar infraestructura
terraform apply -var="environment=dev"

# 7. Ver outputs
terraform output

# 8. Destruir infraestructura
terraform destroy -var="environment=dev"
```

### 📊 Comandos Útiles

```bash
# Ver estado actual
terraform show

# Listar recursos
terraform state list

# Importar recurso existente
terraform import aws_instance.example i-1234567890abcdef0

# Refrescar estado
terraform refresh

# Verificar configuración
terraform validate

# Formatear archivos
terraform fmt -recursive
```

---

## 🔄 Opción 3: GitHub Actions CI/CD

### ✅ Ventajas
- **Automatización completa**: Sin intervención manual
- **Validaciones automáticas**: Tests y seguridad
- **Historial de despliegues**: Tracking completo
- **Rollback automático**: En caso de errores

### 🚀 Configuración

#### 1. Configurar Secrets en GitHub

Ve a `Settings > Secrets and variables > Actions` y agrega:

```
AWS_ACCESS_KEY_ID: tu-access-key
AWS_SECRET_ACCESS_KEY: tu-secret-key
```

#### 2. Configurar Backend S3

Edita `backend.tf` con tu bucket:

```hcl
terraform {
  backend "s3" {
    bucket         = "tu-terraform-state-bucket"
    key            = "infrastructure/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
```

#### 3. Desplegar

```bash
# Hacer push a main branch
git add .
git commit -m "Deploy infrastructure"
git push origin main

# El pipeline se ejecutará automáticamente:
# 1. Validación de Terraform
# 2. Planificación de cambios
# 3. Aplicación de infraestructura
# 4. Construcción de Docker
```

### 📊 Pipeline Stages

| Stage | Descripción | Duración |
|-------|-------------|----------|
| **Validate** | Validar Terraform | ~2 min |
| **Security** | Escaneo de seguridad | ~3 min |
| **Plan** | Planificar cambios | ~5 min |
| **Apply** | Aplicar infraestructura | ~10 min |
| **Docker** | Construir imagen | ~8 min |

---

## 🔧 Comandos de Verificación

### Verificar Infraestructura

```bash
# Ver outputs de Terraform
terraform output

# Verificar instancia EC2
aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=terraform-aws-infrastructure-dev-ec2"

# Verificar RDS
aws rds describe-db-instances \
  --db-instance-identifier terraform-aws-infrastructure-dev-mysql

# Verificar ECR
aws ecr describe-repositories \
  --repository-names terraform-docker-app
```

### Verificar Aplicación

```bash
# Obtener IP de la instancia
INSTANCE_IP=$(aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=terraform-aws-infrastructure-dev-ec2" \
  --query 'Reservations[0].Instances[0].PublicIpAddress' \
  --output text)

# Probar endpoints
curl http://$INSTANCE_IP/health
curl http://$INSTANCE_IP/
curl http://$INSTANCE_IP/api/status
```

### Verificar Docker

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

---

## 🆘 Troubleshooting

### Problemas Comunes

#### 1. Error de permisos IAM
```bash
# Verificar credenciales
aws sts get-caller-identity

# Verificar políticas
aws iam list-attached-user-policies --user-name tu-usuario
```

#### 2. Error de key pair
```bash
# Crear key pair
aws ec2 create-key-pair --key-name terraform-key --query 'KeyMaterial' --output text > ~/.ssh/terraform-key.pem
chmod 400 ~/.ssh/terraform-key.pem
```

#### 3. Error de backend S3
```bash
# Crear bucket S3
aws s3 mb s3://tu-terraform-state-bucket

# Crear tabla DynamoDB
aws dynamodb create-table \
  --table-name terraform-locks \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5
```

#### 4. Error de conectividad
```bash
# Verificar Security Groups
aws ec2 describe-security-groups \
  --group-names terraform-aws-infrastructure-dev-ec2-sg

# Verificar logs
ssh -i ~/.ssh/terraform-key.pem ec2-user@$INSTANCE_IP
sudo tail -f /var/log/user-data.log
```

---

## 📊 Comparación de Opciones

| Aspecto | Script | Terraform | GitHub Actions |
|---------|--------|-----------|----------------|
| **Facilidad** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐ |
| **Control** | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐ |
| **Automatización** | ⭐⭐⭐⭐ | ⭐⭐ | ⭐⭐⭐⭐⭐ |
| **Debugging** | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ |
| **Producción** | ⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |

---

## 🎯 Recomendaciones

- **Desarrollo**: Usar **Script de Despliegue**
- **Testing**: Usar **Comandos Terraform Directos**
- **Producción**: Usar **GitHub Actions CI/CD**

---

## 📚 Comandos Útiles

```bash
# Ver estado de la infraestructura
terraform output

# Ver logs de la aplicación
ssh -i ~/.ssh/terraform-key.pem ec2-user@[EC2-IP]
sudo tail -f /var/log/user-data.log

# Verificar conectividad
curl http://$(terraform output -raw ec2_public_ip)/health

# Destruir infraestructura
./scripts/destroy.sh dev

# Ver ayuda del script de despliegue
./scripts/deploy.sh --help

# Verificar conectividad SSH
ssh -i ~/.ssh/terraform-key.pem ec2-user@[EC2-IP]

# Verificar contenedores Docker
ssh -i ~/.ssh/terraform-key.pem ec2-user@[EC2-IP]
docker ps

# Ver logs de Docker
ssh -i ~/.ssh/terraform-key.pem ec2-user@[EC2-IP]
docker logs app-container

# Reiniciar aplicación
ssh -i ~/.ssh/terraform-key.pem ec2-user@[EC2-IP]
docker restart app-container
```

---

## 🏗️ Arquitectura Detallada

### Componentes Principales

#### 1. Red y Conectividad

**VPC (Virtual Private Cloud)**
- **CIDR**: 10.0.0.0/16
- **DNS Resolution**: Habilitado
- **DNS Hostnames**: Habilitado

**Subnets**
- **Públicas**: 10.0.1.0/24, 10.0.2.0/24
  - Para instancias EC2 con acceso a Internet
  - NAT Gateways para salida a Internet
- **Privadas**: 10.0.11.0/24, 10.0.12.0/24
  - Para base de datos RDS
  - Sin acceso directo a Internet

#### 2. Computación

**EC2 Instance**
- **AMI**: Amazon Linux 2 (más reciente)
- **Tipo**: t3.medium (2 vCPU, 4 GB RAM)
- **Almacenamiento**: 20 GB GP3 encriptado
- **Key Pair**: Configurable
- **Monitoring**: Habilitado

**Herramientas en Docker**
- **Git**: Control de versiones
- **VS Code Server**: Editor de código web
- **Maven**: Gestión de dependencias Java
- **Java JRE 11**: Entorno de ejecución Java
- **.NET Core 6.0**: Framework .NET
- **PostgreSQL Client**: Cliente de base de datos
- **Apache HTTP Server**: Servidor web
- **Docker**: Contenedores
- **AWS CLI**: Interfaz de línea de comandos

#### 3. Base de Datos

**RDS MySQL**
- **Motor**: MySQL 8.0
- **Clase**: db.t3.micro
- **Almacenamiento**: 20 GB GP2 (auto-scaling hasta 100 GB)
- **Multi-AZ**: Habilitado para alta disponibilidad
- **Backup**: 7 días de retención
- **Encriptación**: Habilitada en reposo
- **Performance Insights**: Habilitado

#### 4. Contenedores

**ECR (Elastic Container Registry)**
- Repositorio privado para imágenes Docker
- Encriptación AES256
- Lifecycle policies configuradas
- Scanning de vulnerabilidades habilitado

**Imagen Docker**
- **Base**: Amazon Linux 2
- **Herramientas**: Todas las especificadas
- **Puertos**: 80 (HTTP), 8080 (App), 5432 (PostgreSQL)
- **Usuario**: developer (no root)

#### 5. Seguridad

**Security Groups**
- **EC2**: SSH (IPs específicas), HTTP, HTTPS, 8080
- **RDS**: MySQL desde EC2 únicamente
- **ALB**: HTTP y HTTPS desde Internet

**IAM Roles**
- **EC2 Role**: CloudWatch, ECR, SSM
- **RDS Monitoring**: Enhanced monitoring

**Encriptación**
- **EBS**: Encriptado en reposo
- **RDS**: Encriptado en reposo y en tránsito
- **S3**: Encriptado para state file

#### 6. Monitoreo y Logging

**CloudWatch**
- **Log Groups**: /aws/ec2/ y /aws/rds/
- **Métricas**: CPU, memoria, disco, red
- **Retención**: 7 días

**Performance Insights**
- Monitoreo de base de datos
- Retención de 7 días

---

## 💰 Costos Estimados (us-west-2)

| Servicio | Tipo | Costo Mensual |
|----------|------|---------------|
| EC2 | t3.medium | ~$30 |
| RDS | db.t3.micro | ~$15 |
| ALB | Application LB | ~$16 |
| NAT Gateway | 2x | ~$45 |
| EBS | 20 GB GP3 | ~$2 |
| S3 | State + Logs | ~$1 |
| **Total** | | **~$109** |

---

## 🔧 Mejores Prácticas

### Seguridad
- Usar IPs específicas para SSH
- Rotar credenciales regularmente
- Habilitar MFA en AWS
- Usar IAM roles en lugar de access keys

### Costos
- Monitorear costos en AWS Cost Explorer
- Usar instancias spot para desarrollo
- Programar parada de instancias
- Limpiar recursos no utilizados

### Mantenimiento
- Actualizar AMIs regularmente
- Aplicar parches de seguridad
- Monitorear logs de CloudWatch
- Hacer backups regulares

---

¡Elige la opción que mejor se adapte a tu flujo de trabajo! 🚀
