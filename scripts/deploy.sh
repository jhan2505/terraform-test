#!/bin/bash

# Script de despliegue completo para Terraform AWS Infrastructure
# Uso: ./deploy.sh [environment] [action]

set -e

# Variables
ENVIRONMENT=${1:-dev}
ACTION=${2:-plan}
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
    echo -e "${BLUE}🚀 Script de Despliegue - Terraform AWS Infrastructure${NC}"
    echo "=================================================="
    echo ""
    echo "Uso: $0 [environment] [action]"
    echo ""
    echo "Environments:"
    echo "  dev      - Desarrollo (por defecto)"
    echo "  staging  - Staging"
    echo "  prod     - Producción"
    echo ""
    echo "Actions:"
    echo "  plan     - Planificar cambios (por defecto)"
    echo "  apply    - Aplicar cambios"
    echo "  destroy  - Destruir infraestructura"
    echo "  init     - Inicializar Terraform"
    echo "  validate - Validar configuración"
    echo "  format   - Formatear código"
    echo "  docker   - Construir y subir imagen Docker"
    echo "  all      - Ejecutar todo el pipeline"
    echo ""
    echo "Ejemplos:"
    echo "  $0 dev plan"
    echo "  $0 dev apply"
    echo "  $0 prod destroy"
    echo "  $0 dev all"
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
    
    # Verificar Docker (si es necesario)
    if [[ "$ACTION" == "docker" || "$ACTION" == "all" ]]; then
        if ! command -v docker &> /dev/null; then
            error "Docker no está instalado. Por favor instala Docker primero."
        fi
    fi
    
    # Verificar archivo de variables
    if [ ! -f "$TERRAFORM_DIR/terraform.tfvars" ]; then
        warning "Archivo terraform.tfvars no encontrado."
        if [ -f "$TERRAFORM_DIR/terraform.tfvars.example" ]; then
            log "Copiando terraform.tfvars.example a terraform.tfvars..."
            cp "$TERRAFORM_DIR/terraform.tfvars.example" "$TERRAFORM_DIR/terraform.tfvars"
            warning "Por favor edita terraform.tfvars con tus valores antes de continuar."
            read -p "¿Continuar? (y/N): " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                exit 1
            fi
        else
            error "No se encontró terraform.tfvars ni terraform.tfvars.example"
        fi
    fi
    
    success "Prerrequisitos verificados"
}

# Inicializar Terraform
init_terraform() {
    log "Inicializando Terraform..."
    cd "$TERRAFORM_DIR"
    
    terraform init -upgrade
    
    if [ $? -eq 0 ]; then
        success "Terraform inicializado correctamente"
    else
        error "Error al inicializar Terraform"
    fi
}

# Validar configuración
validate_terraform() {
    log "Validando configuración de Terraform..."
    cd "$TERRAFORM_DIR"
    
    terraform validate
    
    if [ $? -eq 0 ]; then
        success "Configuración de Terraform válida"
    else
        error "Error en la configuración de Terraform"
    fi
}

# Formatear código
format_terraform() {
    log "Formateando código de Terraform..."
    cd "$TERRAFORM_DIR"
    
    terraform fmt -recursive
    
    success "Código formateado"
}

# Planificar cambios
plan_terraform() {
    log "Planificando cambios de Terraform..."
    cd "$TERRAFORM_DIR"
    
    terraform plan -var="environment=$ENVIRONMENT" -out="terraform-$ENVIRONMENT.tfplan"
    
    if [ $? -eq 0 ]; then
        success "Planificación completada"
        log "Plan guardado en: terraform-$ENVIRONMENT.tfplan"
    else
        error "Error en la planificación"
    fi
}

# Aplicar cambios
apply_terraform() {
    log "Aplicando cambios de Terraform..."
    cd "$TERRAFORM_DIR"
    
    # Verificar si existe un plan
    if [ -f "terraform-$ENVIRONMENT.tfplan" ]; then
        terraform apply "terraform-$ENVIRONMENT.tfplan"
    else
        warning "No se encontró plan guardado, ejecutando plan y apply..."
        terraform apply -var="environment=$ENVIRONMENT" -auto-approve
    fi
    
    if [ $? -eq 0 ]; then
        success "Cambios aplicados correctamente"
        
        # Mostrar outputs
        log "Mostrando outputs..."
        terraform output
    else
        error "Error al aplicar cambios"
    fi
}

# Destruir infraestructura
destroy_terraform() {
    log "Destruyendo infraestructura..."
    cd "$TERRAFORM_DIR"
    
    # Confirmar destrucción
    warning "⚠️  Esta acción destruirá toda la infraestructura del ambiente $ENVIRONMENT"
    read -p "¿Estás seguro? Escribe 'yes' para continuar: " -r
    if [[ $REPLY != "yes" ]]; then
        log "Operación cancelada"
        exit 0
    fi
    
    terraform destroy -var="environment=$ENVIRONMENT" -auto-approve
    
    if [ $? -eq 0 ]; then
        success "Infraestructura destruida correctamente"
    else
        error "Error al destruir infraestructura"
    fi
}

# Construir y subir imagen Docker
build_docker() {
    log "Construyendo y subiendo imagen Docker..."
    cd "$PROJECT_DIR/docker"
    
    # Obtener información de Docker Hub desde Terraform
    cd "$TERRAFORM_DIR"
    DOCKER_IMAGE_URL=$(terraform output -raw docker_image_url 2>/dev/null || echo "")
    
    if [ -z "$DOCKER_IMAGE_URL" ]; then
        warning "No se pudo obtener URL de la imagen Docker. Usando configuración por defecto."
        DOCKER_IMAGE_URL="jmarrufo/terraform:latest"
    fi
    
    cd "$PROJECT_DIR/docker"
    ./build.sh latest jmarrufo/terraform
    
    if [ $? -eq 0 ]; then
        success "Imagen Docker construida y subida correctamente"
    else
        error "Error al construir o subir imagen Docker"
    fi
}

# Ejecutar pipeline completo
run_pipeline() {
    log "Ejecutando pipeline completo..."
    
    check_prerequisites
    init_terraform
    validate_terraform
    format_terraform
    
    # Construir imagen Docker ANTES de aplicar cambios
    log "Construyendo imagen Docker antes del despliegue..."
    build_docker
    
    plan_terraform
    
    # Preguntar si aplicar cambios
    read -p "¿Aplicar cambios? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        apply_terraform
    else
        log "Pipeline completado sin aplicar cambios"
    fi
}

# Función principal
main() {
    # Mostrar banner
    echo -e "${PURPLE}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                🚀 TERRAFORM AWS INFRASTRUCTURE              ║"
    echo "║                    Script de Despliegue                     ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    
    # Verificar argumentos
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        show_help
        exit 0
    fi
    
    # Ejecutar acción
    case $ACTION in
        "init")
            check_prerequisites
            init_terraform
            ;;
        "validate")
            check_prerequisites
            validate_terraform
            ;;
        "format")
            format_terraform
            ;;
        "plan")
            check_prerequisites
            init_terraform
            validate_terraform
            format_terraform
            plan_terraform
            ;;
        "apply")
            check_prerequisites
            init_terraform
            validate_terraform
            apply_terraform
            ;;
        "destroy")
            check_prerequisites
            init_terraform
            destroy_terraform
            ;;
        "docker")
            check_prerequisites
            build_docker
            ;;
        "all")
            run_pipeline
            ;;
        *)
            error "Acción no válida: $ACTION"
            show_help
            ;;
    esac
    
    success "Operación completada exitosamente!"
}

# Ejecutar función principal
main "$@"

