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
