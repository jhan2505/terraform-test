#!/bin/bash

# Script para destruir infraestructura de Terraform AWS Infrastructure
# Uso: ./destroy.sh [environment]

set -e

# Variables
ENVIRONMENT=${1:-dev}
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TERRAFORM_DIR="$PROJECT_DIR"

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Función para mostrar ayuda
show_help() {
    echo -e "${BLUE}💥 Script de Destrucción - Terraform AWS Infrastructure${NC}"
    echo "=================================================="
    echo ""
    echo "Uso: $0 [environment]"
    echo ""
    echo "Environments:"
    echo "  dev      - Desarrollo (por defecto)"
    echo "  staging  - Staging"
    echo "  prod     - Producción"
    echo ""
    echo "Ejemplos:"
    echo "  $0 dev"
    echo "  $0 staging"
    echo "  $0 prod"
}

# Función para logging
log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

# Función para error
error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
    exit 1
}

# Función para warning
warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Función para success
success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

# Verificar prerrequisitos
check_prerequisites() {
    log "Verificando prerrequisitos..."
    
    # Verificar Terraform
    if ! command -v terraform &> /dev/null; then
        error "Terraform no está instalado. Por favor instala Terraform primero."
    fi
    
    # Verificar AWS CLI
    if ! command -v aws &> /dev/null; then
        error "AWS CLI no está instalado. Por favor instala AWS CLI primero."
    fi
    
    # Verificar archivo de variables
    if [ ! -f "$TERRAFORM_DIR/terraform.tfvars" ]; then
        error "Archivo terraform.tfvars no encontrado. No se puede destruir la infraestructura."
    fi
    
    success "Prerrequisitos verificados"
}

# Mostrar recursos que serán destruidos
show_resources() {
    log "Mostrando recursos que serán destruidos..."
    cd "$TERRAFORM_DIR"
    
    terraform plan -destroy -var="environment=$ENVIRONMENT" -out="destroy-$ENVIRONMENT.tfplan"
    
    if [ $? -eq 0 ]; then
        success "Plan de destrucción generado"
    else
        error "Error al generar plan de destrucción"
    fi
}

# Destruir infraestructura
destroy_infrastructure() {
    log "Destruyendo infraestructura del ambiente $ENVIRONMENT..."
    cd "$TERRAFORM_DIR"
    
    # Confirmar destrucción múltiples veces
    echo -e "${RED}⚠️  ADVERTENCIA: Esta acción destruirá TODA la infraestructura del ambiente $ENVIRONMENT${NC}"
    echo -e "${RED}   Esto incluye:${NC}"
    echo -e "${RED}   - Instancias EC2${NC}"
    echo -e "${RED}   - Bases de datos RDS${NC}"
    echo -e "${RED}   - VPC y subnets${NC}"
    echo -e "${RED}   - Security Groups${NC}"
    echo -e "${RED}   - Docker Hub images${NC}"
    echo -e "${RED}   - Y todos los datos asociados${NC}"
    echo ""
    
    # Primera confirmación
    read -p "¿Estás ABSOLUTAMENTE seguro? Escribe 'DESTROY' para continuar: " -r
    if [[ $REPLY != "DESTROY" ]]; then
        log "Operación cancelada"
        exit 0
    fi
    
    # Segunda confirmación
    echo ""
    echo -e "${YELLOW}Esta es tu última oportunidad para cancelar...${NC}"
    read -p "Escribe 'YES' para confirmar la destrucción: " -r
    if [[ $REPLY != "YES" ]]; then
        log "Operación cancelada"
        exit 0
    fi
    
    # Ejecutar destrucción
    log "Ejecutando destrucción..."
    terraform destroy -var="environment=$ENVIRONMENT" -auto-approve
    
    if [ $? -eq 0 ]; then
        success "Infraestructura destruida correctamente"
        
        # Limpiar archivos temporales
        log "Limpiando archivos temporales..."
        rm -f "terraform-$ENVIRONMENT.tfplan"
        rm -f "destroy-$ENVIRONMENT.tfplan"
        
        success "Limpieza completada"
    else
        error "Error al destruir infraestructura"
    fi
}

# Función principal
main() {
    # Mostrar banner
    echo -e "${PURPLE}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                💥 TERRAFORM AWS INFRASTRUCTURE              ║"
    echo "║                  Script de Destrucción                      ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    
    # Verificar argumentos
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        show_help
        exit 0
    fi
    
    # Ejecutar destrucción
    check_prerequisites
    show_resources
    destroy_infrastructure
    
    success "Destrucción completada exitosamente!"
    echo -e "${YELLOW}Nota: Algunos recursos pueden tardar unos minutos en eliminarse completamente.${NC}"
}

# Ejecutar función principal
main "$@"

