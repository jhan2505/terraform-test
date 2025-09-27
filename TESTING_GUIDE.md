# 🧪 Guía de Testing - Terraform AWS Infrastructure

## 📋 Prerrequisitos Antes de Comenzar

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

### 3. Configuración del Proyecto
```bash
# Clonar o navegar al proyecto
cd /home/jhan/git/terraform-test

# Configurar variables
cp terraform.tfvars.example terraform.tfvars
nano terraform.tfvars  # Editar con tus valores
```

---

## 🎯 Opción 1: Script de Despliegue (Recomendado para Testing)

### ✅ Ventajas para Testing
- **Fácil de usar**: Un solo comando
- **Logging detallado**: Ve cada paso
- **Validaciones automáticas**: Detecta errores
- **Rollback automático**: Si algo falla

### 🚀 Pasos para Probar

#### Paso 1: Preparación
```bash
# 1. Navegar al proyecto
cd /home/jhan/git/terraform-test

# 2. Hacer ejecutables los scripts
chmod +x scripts/*.sh

# 3. Verificar configuración
cat terraform.tfvars
```

#### Paso 2: Testing de Validación
```bash
# Validar configuración de Terraform
./scripts/deploy.sh dev validate

# Formatear código
./scripts/deploy.sh dev format

# Verificar que no hay errores
echo "✅ Validación completada"
```

#### Paso 3: Testing de Planificación
```bash
# Planificar cambios (no aplica nada)
./scripts/deploy.sh dev plan

# Verificar que el plan se ve correcto
echo "✅ Planificación completada"
```

#### Paso 4: Testing de Despliegue Completo
```bash
# Ejecutar pipeline completo
./scripts/deploy.sh dev all

# Esto ejecutará:
# 1. terraform init
# 2. terraform validate
# 3. terraform plan
# 4. terraform apply
# 5. Construcción de Docker
# 6. Subida a ECR
```

#### Paso 5: Verificación Post-Despliegue
```bash
# Obtener IP de la instancia
INSTANCE_IP=$(terraform output -raw ec2_public_ip)
echo "IP de la instancia: $INSTANCE_IP"

# Probar endpoints
curl http://$INSTANCE_IP/health
curl http://$INSTANCE_IP/
curl http://$INSTANCE_IP/api/status

# Verificar conectividad SSH
ssh -i ~/.ssh/terraform-key.pem ec2-user@$INSTANCE_IP "docker ps"
```

#### Paso 6: Testing de Destrucción
```bash
# Destruir infraestructura
./scripts/destroy.sh dev

# Verificar que todo se eliminó
aws ec2 describe-instances --filters "Name=tag:Name,Values=terraform-aws-infrastructure-dev-ec2"
```

### 🔧 Comandos de Debugging
```bash
# Ver logs detallados
./scripts/deploy.sh dev plan 2>&1 | tee deploy.log

# Ver estado de Terraform
terraform show

# Ver recursos creados
terraform state list

# Ver outputs
terraform output
```

---

## ⚙️ Opción 2: Comandos Terraform Directos

### ✅ Ventajas para Testing
- **Control total**: Cada comando manual
- **Debugging fácil**: Identificar problemas específicos
- **Flexibilidad**: Personalizar cada paso

### 🚀 Pasos para Probar

#### Paso 1: Inicialización
```bash
# 1. Navegar al proyecto
cd /home/jhan/git/terraform-test

# 2. Inicializar Terraform
terraform init

# 3. Verificar que se descargaron providers
ls -la .terraform/providers/
```

#### Paso 2: Validación y Formateo
```bash
# Validar configuración
terraform validate

# Formatear código
terraform fmt -recursive

# Verificar que no hay errores
echo "✅ Validación completada"
```

#### Paso 3: Planificación Detallada
```bash
# Planificar con variables específicas
terraform plan -var="environment=dev" -out=tfplan

# Ver el plan generado
terraform show tfplan

# Verificar que el plan se ve correcto
echo "✅ Planificación completada"
```

#### Paso 4: Aplicación Paso a Paso
```bash
# Aplicar el plan
terraform apply tfplan

# O aplicar directamente
terraform apply -var="environment=dev"

# Confirmar con 'yes' cuando pregunte
```

#### Paso 5: Verificación de Recursos
```bash
# Ver estado actual
terraform show

# Ver outputs
terraform output

# Ver recursos específicos
terraform state list
terraform state show aws_instance.ec2
```

#### Paso 6: Testing de Docker
```bash
# Obtener URL de ECR
ECR_URL=$(terraform output -raw ecr_repository_url)
echo "ECR URL: $ECR_URL"

# Construir y subir Docker
cd docker
./build.sh latest us-west-2 $ECR_URL

# Verificar que se subió
aws ecr list-images --repository-name terraform-docker-app
```

#### Paso 7: Testing de Conectividad
```bash
# Obtener IP de la instancia
INSTANCE_IP=$(terraform output -raw ec2_public_ip)

# Probar endpoints
curl -v http://$INSTANCE_IP/health
curl -v http://$INSTANCE_IP/
curl -v http://$INSTANCE_IP/api/status

# Conectarse por SSH
ssh -i ~/.ssh/terraform-key.pem ec2-user@$INSTANCE_IP

# Dentro de la instancia:
docker ps
docker logs app-container
docker exec -it app-container bash
```

#### Paso 8: Destrucción
```bash
# Destruir infraestructura
terraform destroy -var="environment=dev"

# Confirmar con 'yes'
# Verificar que todo se eliminó
```

### 🔧 Comandos de Debugging Avanzado
```bash
# Ver logs de Terraform
export TF_LOG=DEBUG
terraform apply -var="environment=dev"

# Ver plan en formato JSON
terraform plan -var="environment=dev" -json > plan.json

# Importar recurso existente
terraform import aws_instance.example i-1234567890abcdef0

# Refrescar estado
terraform refresh -var="environment=dev"

# Verificar configuración
terraform validate
```

---

## 🔄 Opción 3: GitHub Actions CI/CD

### ✅ Ventajas para Testing
- **Automatización completa**: Sin intervención manual
- **Testing en entorno real**: Como producción
- **Historial de despliegues**: Tracking completo

### 🚀 Pasos para Probar

#### Paso 1: Configuración del Repositorio
```bash
# 1. Inicializar git si no está inicializado
git init
git add .
git commit -m "Initial commit"

# 2. Crear repositorio en GitHub
# Ir a GitHub.com > New Repository
# Nombre: terraform-aws-infrastructure
# Público o Privado

# 3. Conectar repositorio local
git remote add origin https://github.com/tu-usuario/terraform-aws-infrastructure.git
git branch -M main
git push -u origin main
```

#### Paso 2: Configuración de Secrets
```bash
# 1. Ir a GitHub.com > tu-repo > Settings > Secrets and variables > Actions

# 2. Agregar los siguientes secrets:
# AWS_ACCESS_KEY_ID: tu-access-key
# AWS_SECRET_ACCESS_KEY: tu-secret-key

# 3. Verificar que estén configurados
echo "✅ Secrets configurados"
```

#### Paso 3: Configuración del Backend
```bash
# 1. Crear bucket S3 para state
aws s3 mb s3://tu-terraform-state-bucket

# 2. Crear tabla DynamoDB para locks
aws dynamodb create-table \
  --table-name terraform-locks \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5

# 3. Editar backend.tf con tu bucket
nano backend.tf
```

#### Paso 4: Testing de Pull Request
```bash
# 1. Crear rama para testing
git checkout -b feature/testing

# 2. Hacer un cambio pequeño
echo "# Testing" >> README.md

# 3. Commit y push
git add .
git commit -m "Add testing feature"
git push origin feature/testing

# 4. Crear Pull Request en GitHub
# Ir a GitHub.com > tu-repo > Pull Requests > New Pull Request

# 5. Verificar que el pipeline se ejecuta
# Ir a Actions tab y ver el workflow
```

#### Paso 5: Testing de Despliegue en Main
```bash
# 1. Mergear el PR a main
# En GitHub: Merge Pull Request

# 2. Verificar que se ejecuta el pipeline completo
# Ir a Actions tab y ver el workflow completo

# 3. Verificar que se crearon los recursos
aws ec2 describe-instances --filters "Name=tag:Name,Values=terraform-aws-infrastructure-dev-ec2"
```

#### Paso 6: Testing de Rollback
```bash
# 1. Hacer un cambio que cause error
echo "invalid_terraform_code" >> main.tf

# 2. Commit y push
git add .
git commit -m "Test rollback"
git push origin main

# 3. Verificar que el pipeline falla
# Ir a Actions tab y ver el error

# 4. Revertir el cambio
git revert HEAD
git push origin main

# 5. Verificar que se recupera
```

### 🔧 Comandos de Debugging del Pipeline
```bash
# Ver logs del workflow
# Ir a GitHub.com > tu-repo > Actions > [workflow run] > [job] > [step]

# Ver logs de Terraform en el pipeline
# Buscar en los logs: "terraform plan" o "terraform apply"

# Ver logs de Docker en el pipeline
# Buscar en los logs: "docker build" o "docker push"
```

---

## 🧪 Testing de Funcionalidades Específicas

### 1. Testing de Conectividad de Red
```bash
# Verificar Security Groups
aws ec2 describe-security-groups --group-names terraform-aws-infrastructure-dev-ec2-sg

# Verificar VPC
aws ec2 describe-vpcs --filters "Name=tag:Name,Values=terraform-aws-infrastructure-dev-vpc"

# Verificar Subnets
aws ec2 describe-subnets --filters "Name=tag:Name,Values=terraform-aws-infrastructure-dev-*"
```

### 2. Testing de Base de Datos
```bash
# Verificar RDS
aws rds describe-db-instances --db-instance-identifier terraform-aws-infrastructure-dev-mysql

# Conectarse a la base de datos
mysql -h $(terraform output -raw rds_endpoint) -u admin -p

# Dentro de MySQL:
SHOW DATABASES;
USE terraformdb;
SHOW TABLES;
```

### 3. Testing de Docker
```bash
# Verificar ECR
aws ecr describe-repositories --repository-names terraform-docker-app

# Ver imágenes en ECR
aws ecr list-images --repository-name terraform-docker-app

# Probar pull de la imagen
docker pull $(terraform output -raw ecr_repository_url):latest
```

### 4. Testing de Aplicación Web
```bash
# Probar endpoints HTTP
curl -v http://$(terraform output -raw ec2_public_ip)/health
curl -v http://$(terraform output -raw ec2_public_ip)/
curl -v http://$(terraform output -raw ec2_public_ip)/api/status

# Probar con diferentes métodos HTTP
curl -X POST http://$(terraform output -raw ec2_public_ip)/api/status
curl -X PUT http://$(terraform output -raw ec2_public_ip)/api/status
```

---

## 🚨 Troubleshooting Común

### Error: "No such file or directory: terraform"
```bash
# Instalar Terraform
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update && sudo apt-get install terraform
```

### Error: "AWS credentials not found"
```bash
# Configurar credenciales
aws configure
# O usar variables de entorno
export AWS_ACCESS_KEY_ID=tu-access-key
export AWS_SECRET_ACCESS_KEY=tu-secret-key
export AWS_DEFAULT_REGION=us-west-2
```

### Error: "Key pair not found"
```bash
# Crear key pair
aws ec2 create-key-pair --key-name terraform-key --query 'KeyMaterial' --output text > ~/.ssh/terraform-key.pem
chmod 400 ~/.ssh/terraform-key.pem
```

### Error: "S3 bucket not found"
```bash
# Crear bucket S3
aws s3 mb s3://tu-terraform-state-bucket
```

### Error: "DynamoDB table not found"
```bash
# Crear tabla DynamoDB
aws dynamodb create-table \
  --table-name terraform-locks \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5
```

---

## 📊 Checklist de Testing

### ✅ Pre-Despliegue
- [ ] Herramientas instaladas (Terraform, AWS CLI, Docker, Git)
- [ ] Credenciales AWS configuradas
- [ ] Key pair creado
- [ ] Variables configuradas en terraform.tfvars
- [ ] Scripts ejecutables

### ✅ Durante el Despliegue
- [ ] terraform init ejecutado sin errores
- [ ] terraform validate pasa
- [ ] terraform plan se ve correcto
- [ ] terraform apply ejecutado sin errores
- [ ] Docker construido y subido
- [ ] Recursos creados en AWS

### ✅ Post-Despliegue
- [ ] Instancia EC2 ejecutándose
- [ ] RDS MySQL ejecutándose
- [ ] ECR con imagen Docker
- [ ] Endpoints HTTP respondiendo
- [ ] SSH funcionando
- [ ] Docker container ejecutándose

### ✅ Cleanup
- [ ] terraform destroy ejecutado
- [ ] Recursos eliminados de AWS
- [ ] Bucket S3 vacío (opcional)
- [ ] Tabla DynamoDB eliminada (opcional)

---

## 🎯 Recomendaciones de Testing

1. **Empezar con Script de Despliegue**: Más fácil para principiantes
2. **Probar Terraform Directo**: Para entender mejor el proceso
3. **Usar GitHub Actions**: Para testing de producción
4. **Hacer testing incremental**: Un módulo a la vez
5. **Documentar problemas**: Para futuras referencias
6. **Limpiar recursos**: Para evitar costos innecesarios

---

¡Elige la opción que mejor se adapte a tu nivel y necesidades! 🚀
