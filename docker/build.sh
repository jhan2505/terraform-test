#!/bin/bash

# Script para construir y subir la imagen Docker a Docker Hub
# Uso: ./build.sh [tag] [repository]
# Ejemplo: ./build.sh latest jmarrufo/terraform

set -e

# Variables por defecto
TAG=${1:-latest}
REPOSITORY=${2:-jmarrufo/terraform}
REPOSITORY_URL="$REPOSITORY"

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🐳 Docker Build Script para Docker Hub${NC}"
echo "=================================================="

# Verificar que Docker esté instalado
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker no está instalado. Por favor instala Docker primero.${NC}"
    exit 1
fi

# Verificar que el usuario esté logueado en Docker Hub (solo para push)
if ! docker info | grep -q "Username:"; then
    echo -e "${YELLOW}⚠️  No estás logueado en Docker Hub.${NC}"
    echo "Para hacer push necesitas ejecutar: docker login"
    echo "Para solo construir localmente, puedes continuar sin login"
    echo "Uso: $0 [tag] [repository]"
    echo "Ejemplo: $0 v1.0.0 jmarrufo/terraform"
fi

echo -e "${BLUE}📋 Configuración:${NC}"
echo "  Tag: $TAG"
echo "  Repositorio: $REPOSITORY_URL"
echo ""

# Verificar login en Docker Hub (solo para push)
echo -e "${YELLOW}🔐 Verificando login en Docker Hub...${NC}"
if docker info | grep -q "Username:"; then
    echo -e "${GREEN}✅ Usuario logueado en Docker Hub${NC}"
    CAN_PUSH=true
else
    echo -e "${YELLOW}⚠️  No estás logueado en Docker Hub${NC}"
    echo "Solo se construirá la imagen localmente (sin push)"
    CAN_PUSH=false
fi

# Construir la imagen
echo -e "${YELLOW}🔨 Construyendo imagen Docker...${NC}"
docker build -t $REPOSITORY_URL:$TAG .

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Imagen construida exitosamente${NC}"
else
    echo -e "${RED}❌ Error al construir la imagen${NC}"
    exit 1
fi

# Subir la imagen a Docker Hub (solo si está logueado)
if [ "$CAN_PUSH" = true ]; then
    echo -e "${YELLOW}📤 Subiendo imagen a Docker Hub...${NC}"
    docker push $REPOSITORY_URL:$TAG

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Imagen subida exitosamente a Docker Hub${NC}"
    else
        echo -e "${RED}❌ Error al subir la imagen a Docker Hub${NC}"
        exit 1
    fi
else
    echo -e "${YELLOW}⏭️  Saltando push (no estás logueado en Docker Hub)${NC}"
    echo "Para subir la imagen, ejecuta: docker login"
    echo "Luego ejecuta: docker push $REPOSITORY_URL:$TAG"
fi

# Mostrar información de la imagen
echo ""
echo -e "${BLUE}📊 Información de la imagen:${NC}"
echo "  Repositorio: $REPOSITORY_URL"
echo "  Tag: $TAG"
echo "  Docker Hub: https://hub.docker.com/r/$USERNAME/$IMAGE_NAME"
echo ""

# Mostrar comandos útiles
echo -e "${BLUE}🔧 Comandos útiles:${NC}"
echo "  Descargar imagen: docker pull $REPOSITORY_URL:$TAG"
echo "  Ejecutar imagen: docker run -p 80:80 -p 8080:8080 $REPOSITORY_URL:$TAG"
echo "  Ver imágenes: docker images | grep $IMAGE_NAME"
echo ""

echo ""
echo -e "${GREEN}🎉 Proceso completado exitosamente!${NC}"
echo "La imagen Docker está disponible en Docker Hub y lista para ser desplegada."

