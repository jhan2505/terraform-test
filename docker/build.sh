#!/bin/bash

# Script para construir y subir la imagen Docker a ECR
# Uso: ./build.sh [tag] [region] [repository-url]

set -e

# Variables por defecto
TAG=${1:-latest}
REGION=${2:-us-west-2}
REPOSITORY_URL=${3:-""}

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🐳 Docker Build Script para Terraform AWS Infrastructure${NC}"
echo "=================================================="

# Verificar que Docker esté instalado
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker no está instalado. Por favor instala Docker primero.${NC}"
    exit 1
fi

# Verificar que AWS CLI esté instalado
if ! command -v aws &> /dev/null; then
    echo -e "${RED}❌ AWS CLI no está instalado. Por favor instala AWS CLI primero.${NC}"
    exit 1
fi

# Si no se proporciona URL del repositorio, intentar obtenerla
if [ -z "$REPOSITORY_URL" ]; then
    echo -e "${YELLOW}⚠️  No se proporcionó URL del repositorio ECR.${NC}"
    echo "Por favor proporciona la URL del repositorio ECR:"
    echo "Uso: $0 [tag] [region] [repository-url]"
    echo "Ejemplo: $0 v1.0.0 us-west-2 123456789012.dkr.ecr.us-west-2.amazonaws.com/terraform-docker-app"
    exit 1
fi

echo -e "${BLUE}📋 Configuración:${NC}"
echo "  Tag: $TAG"
echo "  Región: $REGION"
echo "  Repositorio: $REPOSITORY_URL"
echo ""

# Autenticarse con ECR
echo -e "${YELLOW}🔐 Autenticándose con ECR...${NC}"
aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $REPOSITORY_URL

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Autenticación exitosa${NC}"
else
    echo -e "${RED}❌ Error en la autenticación con ECR${NC}"
    exit 1
fi

# Construir la imagen
echo -e "${YELLOW}🔨 Construyendo imagen Docker...${NC}"
docker build -t terraform-docker-app:$TAG .

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Imagen construida exitosamente${NC}"
else
    echo -e "${RED}❌ Error al construir la imagen${NC}"
    exit 1
fi

# Etiquetar la imagen para ECR
echo -e "${YELLOW}🏷️  Etiquetando imagen para ECR...${NC}"
docker tag terraform-docker-app:$TAG $REPOSITORY_URL:$TAG

# Subir la imagen a ECR
echo -e "${YELLOW}📤 Subiendo imagen a ECR...${NC}"
docker push $REPOSITORY_URL:$TAG

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Imagen subida exitosamente a ECR${NC}"
else
    echo -e "${RED}❌ Error al subir la imagen a ECR${NC}"
    exit 1
fi

# Mostrar información de la imagen
echo ""
echo -e "${BLUE}📊 Información de la imagen:${NC}"
echo "  Repositorio: $REPOSITORY_URL"
echo "  Tag: $TAG"
echo "  Región: $REGION"
echo ""

# Mostrar comandos útiles
echo -e "${BLUE}🔧 Comandos útiles:${NC}"
echo "  Descargar imagen: docker pull $REPOSITORY_URL:$TAG"
echo "  Ejecutar imagen: docker run -p 8080:8080 $REPOSITORY_URL:$TAG"
echo "  Ver imágenes: docker images | grep terraform-docker-app"
echo ""

# Verificar que la imagen esté en ECR
echo -e "${YELLOW}🔍 Verificando imagen en ECR...${NC}"
aws ecr describe-images --repository-name $(echo $REPOSITORY_URL | cut -d'/' -f2) --region $REGION --image-ids imageTag=$TAG

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Imagen verificada en ECR${NC}"
else
    echo -e "${YELLOW}⚠️  No se pudo verificar la imagen en ECR${NC}"
fi

echo ""
echo -e "${GREEN}🎉 Proceso completado exitosamente!${NC}"
echo "La imagen Docker está disponible en ECR y lista para ser desplegada."

