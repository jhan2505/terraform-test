# Dockerfile para aplicación de desarrollo con todas las herramientas requeridas
FROM amazonlinux:2

# Metadatos
LABEL maintainer="devops-team@company.com"
LABEL version="1.0.0"
LABEL description="Docker image with development tools for Terraform AWS Infrastructure project"

# Variables de entorno
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8
ENV TZ=UTC

# Instalar herramientas básicas
RUN yum update -y && \
    yum install -y \
    git \
    wget \
    curl \
    unzip \
    tar \
    gzip \
    htop \
    vim \
    nano \
    net-tools \
    telnet \
    nc \
    which \
    sudo \
    shadow-utils \
    && yum clean all

# Instalar Git (versión más reciente)
RUN yum install -y git && \
    git --version

# Instalar Visual Studio Code Server (code-server)
RUN curl -fsSL https://code-server.dev/install.sh | sh && \
    code-server --version

# Instalar Maven
RUN wget https://archive.apache.org/dist/maven/maven-3/3.9.5/binaries/apache-maven-3.9.5-bin.tar.gz && \
    tar -xzf apache-maven-3.9.5-bin.tar.gz -C /opt && \
    ln -s /opt/apache-maven-3.9.5 /opt/maven && \
    ln -s /opt/maven/bin/mvn /usr/local/bin/mvn && \
    rm apache-maven-3.9.5-bin.tar.gz && \
    mvn --version

# Instalar PostgreSQL 9 (PostgreSQL 9.6)
RUN yum install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-7-x86_64/pgdg-redhat-repo-latest.noarch.rpm && \
    yum install -y postgresql96-server postgresql96 postgresql96-contrib && \
    /usr/pgsql-9.6/bin/postgresql96-setup initdb && \
    systemctl enable postgresql-9.6

# Instalar Java JRE 11
RUN yum install -y java-11-amazon-corretto-headless && \
    java -version

# Instalar .NET Core 6.0 para compilar proyectos .NET
RUN rpm -Uvh https://packages.microsoft.com/config/centos/7/packages-microsoft-prod.rpm && \
    yum install -y dotnet-sdk-6.0 && \
    dotnet --version

# Instalar Apache HTTP Server
RUN yum install -y httpd && \
    systemctl enable httpd

# Crear usuario para desarrollo
RUN useradd -m -s /bin/bash developer && \
    echo 'developer ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers && \
    usermod -aG wheel developer

# Configurar directorio de trabajo
WORKDIR /home/developer/app

# Crear estructura de directorios
RUN mkdir -p /home/developer/app/{src,logs,data,config} && \
    chown -R developer:developer /home/developer

# Copiar archivos de configuración
COPY --chown=developer:developer . /home/developer/app/

# Configurar Apache
RUN echo '<VirtualHost *:80>' > /etc/httpd/conf.d/app.conf && \
    echo '    DocumentRoot /home/developer/app/www' >> /etc/httpd/conf.d/app.conf && \
    echo '    ServerName localhost' >> /etc/httpd/conf.d/app.conf && \
    echo '    <Directory /home/developer/app/www>' >> /etc/httpd/conf.d/app.conf && \
    echo '        AllowOverride All' >> /etc/httpd/conf.d/app.conf && \
    echo '        Require all granted' >> /etc/httpd/conf.d/app.conf && \
    echo '    </Directory>' >> /etc/httpd/conf.d/app.conf && \
    echo '</VirtualHost>' >> /etc/httpd/conf.d/app.conf

# Crear directorio web y copiar archivos
RUN mkdir -p /home/developer/app/www

# Copiar archivos web desde el host
COPY index.html /home/developer/app/www/

# Copiar archivos de endpoints
COPY health.json /home/developer/app/www/health
COPY api/status.json /home/developer/app/www/api/status

# Crear script de inicio
RUN cat > /home/developer/app/start.sh << 'EOF'
#!/bin/bash
set -e

echo "🚀 Iniciando Hola Mundo desde AWS..."

# Iniciar Apache
sudo /usr/sbin/httpd -D FOREGROUND &

# Iniciar VS Code Server en background
nohup code-server --bind-addr 0.0.0.0:8080 --auth none /home/developer/app &

echo "✅ Servicios iniciados:"
echo "   - Apache HTTP Server (Puerto 80)"
echo "   - VS Code Server (Puerto 8080)"
echo "   - Base de datos: MySQL RDS"
echo ""
echo "🌐 Aplicación disponible en: http://localhost"
echo "📊 Health check: http://localhost/health"
echo ""
echo "¡Hola Mundo desde AWS está funcionando!"
EOF

RUN chmod +x /home/developer/app/start.sh

# Crear script de compilación para proyectos .NET
RUN cat > /home/developer/app/build-dotnet.sh << 'EOF'
#!/bin/bash
# Script para compilar proyectos .NET Core

if [ -z "$1" ]; then
    echo "Usage: $0 <project-directory>"
    exit 1
fi

PROJECT_DIR=$1
cd "$PROJECT_DIR"

echo "Building .NET Core project in $PROJECT_DIR..."

# Restaurar dependencias
dotnet restore

# Compilar proyecto
dotnet build

# Ejecutar tests (si existen)
if [ -d "Tests" ] || [ -f "*.Tests.csproj" ]; then
    echo "Running tests..."
    dotnet test
fi

echo "Build completed successfully!"
EOF

RUN chmod +x /home/developer/app/build-dotnet.sh

# Crear script de compilación para proyectos Java
RUN cat > /home/developer/app/build-java.sh << 'EOF'
#!/bin/bash
# Script para compilar proyectos Java con Maven

if [ -z "$1" ]; then
    echo "Usage: $0 <project-directory>"
    exit 1
fi

PROJECT_DIR=$1
cd "$PROJECT_DIR"

echo "Building Java project in $PROJECT_DIR..."

# Limpiar y compilar
mvn clean compile

# Ejecutar tests
mvn test

# Empaquetar
mvn package

echo "Build completed successfully!"
EOF

RUN chmod +x /home/developer/app/build-java.sh

# Exponer puertos
EXPOSE 80 8080 5432

# Cambiar a usuario developer
USER developer

# Comando por defecto
CMD ["/home/developer/app/start.sh"]
