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
