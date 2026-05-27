#!/bin/bash

# Controla los errores normales.
set -e

# Si el comando de una tubería (|) falla, el script también fallará.
set -o pipefail

# Variables principales
LOG_FILE="configuracion_pagila.log"
DB_NAME="pagila"
DB_USER="postgres"
DB_HOST="localhost"
SQL_DIR="scripts_sql"

# Colores para que la salida sea más clara
GREEN="\e[32m"
BLUE="\e[34m"
RED="\e[31m"
RESET="\e[0m"

# Todo lo que se muestre por pantalla también se guardará en el log
exec > >(tee "$LOG_FILE") 2>&1

echo -e "${BLUE}========================================${RESET}"
echo -e "${BLUE} CONFIGURACIÓN COMPLETA DE PAGILA${RESET}"
echo -e "${BLUE}========================================${RESET}"
echo "Fecha de ejecución: $(date)"
echo ""

echo -e "${GREEN}[1/5] Preparando base de datos Pagila...${RESET}"
# Este script clona el repositorio oficial, crea la base de datos y carga esquema + datos.
bash "$SQL_DIR/00_preparacion_pagila.sh"

echo -e "${GREEN}[2/5] Creando roles y usuarios...${RESET}"
# Ejecuta la creación de usuarios y roles de grupo.
psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" -v ON_ERROR_STOP=1 -f "$SQL_DIR/01_roles.sql"

echo -e "${GREEN}[3/5] Aplicando permisos...${RESET}"
# Aplica permisos concretos sobre tablas importantes.
psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" -v ON_ERROR_STOP=1 -f "$SQL_DIR/02_permisos.sql"

echo -e "${GREEN}[4/5] Creando vistas personalizadas...${RESET}"
# Crea vistas para mostrar solo la información necesaria a cada perfil.
psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" -v ON_ERROR_STOP=1 -f "$SQL_DIR/03_vistas.sql"

echo -e "${GREEN}[5/5] Creando triggers de integridad...${RESET}"
# Crea funciones y triggers para controlar reglas de negocio.
psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" -v ON_ERROR_STOP=1 -f "$SQL_DIR/04_triggers.sql"

echo ""
echo -e "${BLUE}========================================${RESET}"
echo -e "${GREEN} CONFIGURACIÓN FINALIZADA CORRECTAMENTE${RESET}"
echo -e "${BLUE}========================================${RESET}"
echo "Log generado en: $LOG_FILE"
