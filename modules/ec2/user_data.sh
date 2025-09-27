#!/bin/bash

# Script de inicialización para EC2
# Solo instala Docker y ejecuta la imagen con las herramientas

set -e

# Variables
PROJECT_NAME="${project_name}"
ENVIRONMENT="${environment}"
RDS_ENDPOINT="${rds_endpoint}"
RDS_USERNAME="${rds_username}"
RDS_PASSWORD="${rds_password}"
RDS_DATABASE="${rds_database}"
ECR_REPOSITORY_URL="${ecr_repository_url}"

# Logging
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
echo "Starting user-data script for $PROJECT_NAME-$ENVIRONMENT"

# Actualizar sistema
yum update -y

# Instalar herramientas básicas necesarias
yum install -y \
    wget \
    curl \
    unzip \
    htop \
    vim \
    net-tools

# Instalar Docker
yum install -y docker
systemctl start docker
systemctl enable docker
usermod -a -G docker ec2-user

# Instalar AWS CLI v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install
rm -rf aws awscliv2.zip

# Configurar ECR login
aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin $ECR_REPOSITORY_URL

# Crear directorio para la aplicación
mkdir -p /opt/app
cd /opt/app

# Crear archivo de configuración de la base de datos
cat > /opt/app/db_config.env << EOF
DB_HOST=$RDS_ENDPOINT
DB_PORT=3306
DB_NAME=$RDS_DATABASE
DB_USER=$RDS_USERNAME
DB_PASS=$RDS_PASSWORD
EOF

# Crear script de despliegue de Docker
cat > /opt/app/deploy.sh << 'EOF'
#!/bin/bash
set -e

echo "🐳 Desplegando imagen Docker con todas las herramientas..."

# Pull de la imagen desde ECR
docker pull $ECR_REPOSITORY_URL:latest

# Detener contenedores existentes
docker stop app-container 2>/dev/null || true
docker rm app-container 2>/dev/null || true

# Ejecutar nuevo contenedor con todas las herramientas
docker run -d \
    --name app-container \
    --restart unless-stopped \
    -p 80:80 \
    -p 8080:8080 \
    --env-file /opt/app/db_config.env \
    $ECR_REPOSITORY_URL:latest

echo "✅ Aplicación desplegada exitosamente!"
echo "🌐 Aplicación web: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)"
echo "🔧 VS Code Server: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):8080"
EOF

chmod +x /opt/app/deploy.sh

# Crear script de monitoreo
cat > /opt/app/monitor.sh << 'EOF'
#!/bin/bash

echo "=== Estado del Sistema ==="
echo "Date: $(date)"
echo "Uptime: $(uptime)"
echo ""

echo "=== Contenedores Docker ==="
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
echo ""

echo "=== Recursos del Sistema ==="
echo "CPU: $(top -bn1 | grep "Cpu(s)" | awk "{print \$2}" | cut -d"%" -f1)%"
echo "Memoria: $(free -h | grep Mem | awk "{print \$3/\$2 * 100.0}")%"
echo "Disco: $(df -h / | awk "NR==2{print \$5}")"
echo ""

echo "=== Conectividad ==="
echo "Puerto 80 (HTTP): $(netstat -tuln | grep :80 | wc -l) conexiones"
echo "Puerto 8080 (VS Code): $(netstat -tuln | grep :8080 | wc -l) conexiones"
EOF

chmod +x /opt/app/monitor.sh

# Crear cron job para monitoreo
echo "*/5 * * * * /opt/app/monitor.sh >> /var/log/app-monitor.log 2>&1" | crontab -

# Configurar CloudWatch agent
yum install -y amazon-cloudwatch-agent

# Crear archivo de configuración de CloudWatch
cat > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json << 'EOF'
{
    "logs": {
        "logs_collected": {
            "files": {
                "collect_list": [
                    {
                        "file_path": "/var/log/user-data.log",
                        "log_group_name": "/aws/ec2/terraform-aws-infrastructure-dev",
                        "log_stream_name": "{instance_id}/user-data.log"
                    },
                    {
                        "file_path": "/var/log/app-monitor.log",
                        "log_group_name": "/aws/ec2/terraform-aws-infrastructure-dev",
                        "log_stream_name": "{instance_id}/app-monitor.log"
                    }
                ]
            }
        }
    },
    "metrics": {
        "namespace": "CWAgent",
        "metrics_collected": {
            "cpu": {
                "measurement": ["cpu_usage_idle", "cpu_usage_iowait", "cpu_usage_user", "cpu_usage_system"],
                "metrics_collection_interval": 60
            },
            "disk": {
                "measurement": ["used_percent"],
                "metrics_collection_interval": 60,
                "resources": ["*"]
            },
            "mem": {
                "measurement": ["mem_used_percent"],
                "metrics_collection_interval": 60
            }
        }
    }
}
EOF

# Iniciar CloudWatch agent
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
    -a fetch-config \
    -m ec2 \
    -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json \
    -s

# Ejecutar deploy de Docker en background
nohup /opt/app/deploy.sh > /var/log/docker-deploy.log 2>&1 &

# Crear archivo de estado
cat > /opt/app/deployment-status.json << EOF
{
    "project": "$PROJECT_NAME",
    "environment": "$ENVIRONMENT",
    "deployment_time": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
    "status": "completed",
    "docker_image": "$ECR_REPOSITORY_URL:latest",
    "services": {
        "docker": "running",
        "cloudwatch": "running"
    }
}
EOF

echo "✅ User-data script completed successfully!"
echo "🐳 Docker image will be deployed with all development tools:"
echo "   - Git, VS Code, Maven, PostgreSQL, Java, .NET Core, Apache"
echo "🌐 Application will be available at: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)"
echo "📊 Health check: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)/health"