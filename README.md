# 🚀 Terraform AWS Infrastructure

## 📋 Descripción del Proyecto

Este proyecto implementa una infraestructura completa en AWS utilizando Terraform, que incluye:

- **Servicio de cómputo**: EC2 con Amazon Linux
- **Base de datos**: RDS MySQL
- **Políticas de seguridad**: Security Groups con restricciones SSH por IP
- **Imagen Docker personalizada**: Con herramientas de desarrollo completas
- **Conectividad**: Entre Docker y RDS

## 🏗️ Arquitectura

```
┌─────────────────┐    ┌─────────────────┐
│   Internet      │    │   VPC           │
│                 │    │                 │
│  ┌───────────┐  │    │  ┌───────────┐  │
│  │   ALB     │──┼────┼──│  Public   │  │
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

### Flujo de Herramientas de Desarrollo

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   EC2 Instance  │    │  Docker Image   │    │   RDS MySQL     │
│  (Amazon Linux) │    │  (All Tools)    │    │   (Database)    │
│                 │    │                 │    │                 │
│  ┌───────────┐  │    │  ┌───────────┐  │    │  ┌───────────┐  │
│  │  Docker   │──┼────┼──│  Git      │  │    │  │  MySQL    │  │
│  │  Engine   │  │    │  │  VS Code  │  │    │  │  Database │  │
│  └───────────┘  │    │  │  Maven    │  │    │  └───────────┘  │
│                 │    │  │  Java     │  │    │                 │
│  ┌───────────┐  │    │  │  .NET     │  │    │                 │
│  │  AWS CLI  │  │    │  │  Postgres │  │    │                 │
│  │  CloudWatch│  │    │  │  Apache   │  │    │                 │
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
│   ├── health.json
│   ├── api/
│   │   └── status.json
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

### Despliegue en 3 Pasos

1. **Configurar variables**:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   # Editar terraform.tfvars con tus valores
   ```

2. **Ejecutar despliegue**:
   ```bash
   chmod +x scripts/*.sh
   ./scripts/deploy.sh dev all
   ```

3. **Verificar aplicación**:
   ```bash
   # Verificar conectividad HTTP
   curl http://$(terraform output -raw ec2_public_ip)/health
   
   # Verificar aplicación web
   curl http://$(terraform output -raw ec2_public_ip)/
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

### Docker Container (Imagen Personalizada)
- **Herramientas encapsuladas**: Git, VS Code, Maven, Java, .NET, PostgreSQL, Apache
- **Portabilidad**: La misma imagen funciona en cualquier entorno
- **Versionado**: Control de versiones de herramientas y configuraciones
- **Aislamiento**: Herramientas aisladas del sistema host
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
    dynamodb_table = "terraform-locks"
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

**Fecha de entrega**: 29 de Septiembre de 2025  
**Versión**: 1.0.0