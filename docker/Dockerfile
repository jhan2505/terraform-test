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

# Instalar todas las herramientas de desarrollo requeridas
RUN yum update -y && \
    yum install -y \
    git \
    wget \
    curl \
    unzip \
    tar \
    gcc \
    gcc-c++ \
    make \
    httpd \
    mysql \
    postgresql \
    postgresql-contrib \
    && yum clean all

# Instalar Java 11
RUN yum install -y java-11-amazon-corretto-headless

# Instalar Maven
RUN wget https://archive.apache.org/dist/maven/maven-3/3.8.6/binaries/apache-maven-3.8.6-bin.tar.gz && \
    tar -xzf apache-maven-3.8.6-bin.tar.gz -C /opt && \
    ln -s /opt/apache-maven-3.8.6 /opt/maven && \
    rm apache-maven-3.8.6-bin.tar.gz

# Instalar .NET 6
RUN rpm -Uvh https://packages.microsoft.com/config/centos/7/packages-microsoft-prod.rpm && \
    yum install -y dotnet-sdk-6.0

# Instalar VS Code Server
RUN wget https://github.com/coder/code-server/releases/download/v4.0.2/code-server-4.0.2-linux-amd64.tar.gz && \
    tar -xzf code-server-4.0.2-linux-amd64.tar.gz -C /opt && \
    ln -s /opt/code-server-4.0.2-linux-amd64/code-server /usr/local/bin/code-server && \
    rm code-server-4.0.2-linux-amd64.tar.gz

# Configurar variables de entorno
ENV JAVA_HOME=/usr/lib/jvm/java-11-amazon-corretto
ENV MAVEN_HOME=/opt/maven
ENV PATH=$PATH:$MAVEN_HOME/bin:$JAVA_HOME/bin

# Crear usuario developer
RUN useradd -m -s /bin/bash developer && \
    usermod -aG wheel developer

# Crear directorio de la aplicación
RUN mkdir -p /home/developer/app/www && \
    chown -R developer:developer /home/developer/app && \
    chmod -R 755 /home/developer/app && \
    chmod 755 /home/developer

# Copiar archivos de configuración
COPY apache.conf /etc/httpd/conf.d/app.conf
COPY index.html /home/developer/app/www/
COPY db_check.sh /home/developer/app/www/
COPY start.sh /home/developer/app/
COPY build-dotnet.sh /home/developer/app/
COPY build-java.sh /home/developer/app/

# Configurar permisos
RUN chmod +x /home/developer/app/start.sh && \
    chmod +x /home/developer/app/build-dotnet.sh && \
    chmod +x /home/developer/app/build-java.sh && \
    chmod +x /home/developer/app/www/db_check.sh && \
    chown -R developer:developer /home/developer/app

# Exponer puertos
EXPOSE 80 8080

# Script de inicio
CMD ["/usr/sbin/httpd", "-D", "FOREGROUND"]
