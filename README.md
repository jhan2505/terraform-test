# 🚀 Terraform AWS Infrastructure

## 📋 Descripción del Proyecto

Este proyecto implementa una infraestructura completa en AWS utilizando Terraform, que incluye:

- **Servicio de cómputo**: EC2 con Amazon Linux
- **Base de datos**: RDS MySQL
- **Políticas de seguridad**: Security Groups con restricciones SSH por IP
- **Imagen Docker optimizada**: Con Apache HTTP Server y MySQL client
- **Verificación de Base de Datos**: Script automatizado de conexión a MySQL RDS
- **Conectividad**: Entre Docker y RDS con verificación en tiempo real

## 🏗️ Arquitectura

```
┌─────────────────┐    ┌─────────────────┐
│   Internet      │    │   VPC           │
│                 │    │                 │
│  ┌───────────┐  │    │  ┌───────────┐  │
│  │   EC2     │──┼────┼──│  Public   │  │
│  │           │  │    │  │  Subnet   │  │
│  └───────────┘  │    │  └───────────┘  │
└─────────────────┘    │                 │
                       │  ┌───────────┐  │
                       │  │  Private  │  │
                       │  │  Subnet   │  │
                       │  └───────────┘  │
                       │                 │
                       │  ┌───────────┐  │
                       │  │    RDS    │  │
                       │  │   MySQL   │  │
                       │  └───────────┘  │
                       └─────────────────┘
```

### Flujo de Aplicación Web

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   EC2 Instance  │    │  Docker Image   │    │   RDS MySQL     │
│  (Amazon Linux) │    │  (Web App)      │    │   (Database)    │
│                 │    │                 │    │                 │
│  ┌───────────┐  │    │  ┌───────────┐  │    │  ┌───────────┐  │
│  │  Docker   │──┼────┼──│  Apache   │  │    │  │  MySQL    │  │
│  │  Engine   │  │    │  │  HTTP     │  │    │  │  Database │  │
│  └───────────┘  │    │  │  Server   │  │    │  └───────────┘  │
│                 │    │  └───────────┘  │    │                 │
│  ┌───────────┐  │    │  ┌───────────┐  │    │                 │
│  │  AWS CLI  │  │    │  │  Database │  │    │                 │
│  │  CloudWatch│ │    │  │  Check    │  │    │                 │
│  └───────────┘  │    │  └───────────┘  │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## 📁 Estructura del Proyecto

```
terraform-test/
├── README.md
├── DEPLOYMENT.md
├── main.tf
├── variables.tf
├── outputs.tf
├── terraform.tfvars.example
├── versions.tf
├── backend.tf
├── modules/
│   ├── vpc/
│   ├── security-groups/
│   ├── ec2/
│   ├── rds/
│   └── ecr/
├── docker/
│   ├── Dockerfile
│   ├── index.html
│   ├── db_check.sh
│   ├── apache.conf
│   └── build.sh
├── scripts/
│   ├── deploy.sh
│   └── destroy.sh
└── .github/
    └── workflows/
        └── terraform.yml
```

## ⚙️ Requisitos

- Terraform >= 1.0
- AWS CLI configurado
- Docker
- Git

## 🚀 Uso Rápido

### Despliegue en 4 Pasos

1. **Configurar backend S3**:
   ```bash
   # Editar backend.tf con tu bucket único
   nano backend.tf  # Cambiar bucket = "tu-bucket-unico"
   ```

2. **Configurar variables**:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   nano terraform.tfvars  # Editar IPs y password
   ```

3. **Crear recursos de backend**:
   ```bash
   aws s3 mb s3://tu-bucket-unico
   aws dynamodb create-table --table-name terraform-locks --attribute-definitions AttributeName=LockID,AttributeType=S --key-schema AttributeName=LockID,KeyType=HASH --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5
   ```

4. **Ejecutar despliegue**:
   ```bash
   chmod +x scripts/*.sh
   ./scripts/deploy.sh dev all
   ```

5. **Verificar aplicación**:
   ```bash
   # Verificar aplicación web principal
   curl http://$(terraform output -raw ec2_public_ip)/
   
   # Verificar conexión a base de datos
   curl http://$(terraform output -raw ec2_public_ip)/db_check.sh
   ```

### Opciones de Despliegue

| Opción | Comando | Uso Recomendado |
|--------|---------|-----------------|
| **Script de Despliegue** | `./scripts/deploy.sh dev all` | Desarrollo |
| **Terraform Directo** | `terraform apply -var="environment=dev"` | Testing |
| **GitHub Actions** | Push a main branch | Producción |

## 🎯 Justificación de Servicios Elegidos

### EC2 (Elastic Compute Cloud)
- **Host para Docker**: Instancia ligera que solo ejecuta Docker Engine
- **Costo-efectivo**: Solo paga por la instancia base, no por herramientas individuales
- **Escalabilidad**: Fácil escalado horizontal con más contenedores
- **Integración**: Perfecta integración con ECR y otros servicios AWS

### Docker Container (Imagen Optimizada)
- **Servidor web**: Apache HTTP Server para servir la aplicación
- **Cliente MySQL**: Para verificación de conexión a base de datos
- **Verificación de Base de Datos**: Script automatizado de conectividad a MySQL
- **Portabilidad**: La misma imagen funciona en cualquier entorno
- **Versionado**: Control de versiones de la aplicación y configuraciones
- **Aislamiento**: Aplicación aislada del sistema host
- **Reproducibilidad**: Entorno idéntico en desarrollo, staging y producción

### RDS MySQL
- **Gestión automatizada**: Backups, parches, monitoreo automático
- **Alta disponibilidad**: Multi-AZ deployment
- **Seguridad**: Encriptación en tránsito y en reposo
- **Escalabilidad**: Fácil escalado vertical y horizontal
- **Compatibilidad**: Amplio soporte de aplicaciones

## 🔒 Gestión del State File

El state file se almacena en **Amazon S3** con las siguientes características:

- **Backend remoto**: S3 bucket con versionado habilitado
- **Bloqueo**: DynamoDB table para prevenir modificaciones concurrentes
- **Encriptación**: Encriptado en reposo con KMS
- **Versionado**: Historial completo de cambios
- **Backup**: Replicación automática entre regiones

### Configuración del Backend

```hcl
terraform {
  backend "s3" {
    bucket         = "terraform-state-bucket-jhan"
    key            = "infrastructure/terraform.tfstate"
    region         = "us-west-2"
    use_lockfile   = true
    encrypt        = true
  }
}
```

## 🔒 Gestión del Archive .lock

El archivo `.terraform.lock.hcl` gestiona las versiones de providers:

- **Versionado**: Fija versiones específicas de providers
- **Consistencia**: Garantiza el mismo entorno en todos los equipos
- **Seguridad**: Verificación de checksums de providers
- **Actualización**: `terraform init -upgrade` para actualizar

### Comandos de Gestión

```bash
# Ver providers bloqueados
terraform providers

# Actualizar providers
terraform init -upgrade

# Verificar lock file
terraform init -verify-plugins
```

## 🔄 Pipeline de CI/CD

El proyecto incluye un pipeline automatizado con GitHub Actions que:

1. **Validación**: `terraform validate` y `terraform fmt`
2. **Planificación**: `terraform plan` en pull requests
3. **Aplicación**: `terraform apply` en merge a main
4. **Testing**: Validación de conectividad y servicios
5. **Notificaciones**: Slack/Email con resultados

## 🧪 Testing

### Manual
1. Ejecutar `terraform plan` para validar configuración
2. Aplicar con `terraform apply`
3. Verificar conectividad SSH
4. Probar acceso a aplicación web
5. Validar conexión a base de datos

### Automatizado
- Pipeline de GitHub Actions
- Tests de conectividad
- Validación de seguridad
- Tests de performance

## 🔒 Seguridad

- **SSH restringido**: Solo IPs autorizadas
- **VPC privada**: RDS en subnet privada
- **Security Groups**: Reglas mínimas necesarias
- **Encriptación**: En tránsito y en reposo
- **IAM**: Roles con permisos mínimos

## 📊 Monitoreo

- **CloudWatch**: Logs y métricas
- **CloudTrail**: Auditoría de API calls
- **VPC Flow Logs**: Tráfico de red
- **RDS Performance Insights**: Monitoreo de base de datos

## 📖 Documentación Completa

Para instrucciones detalladas de despliegue, ver **[DEPLOYMENT.md](DEPLOYMENT.md)**

---

**Versión**: 1.0.0