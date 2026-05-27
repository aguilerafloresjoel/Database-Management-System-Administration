#!/bin/bash

# Controla los errores normales.
set -e

# Si falla algún comando dentro de una tubería, también falla el script.
set -o pipefail

# Variables principales
LOG_FILE="mantenimiento_pagila.log"
DB_NAME="pagila"
DB_USER="postgres"
DB_HOST="localhost"

# Tablas principales con más movimiento en la base de datos.
TABLAS=("film" "inventory" "rental" "customer" "payment")

# Colores para mejorar la lectura por terminal.
GREEN="\e[32m"
BLUE="\e[34m"
RESET="\e[0m"

# Guardamos toda la salida por pantalla y en el fichero de log.
exec > >(tee "$LOG_FILE") 2>&1

echo -e "${BLUE}========================================${RESET}"
echo -e "${BLUE} MANTENIMIENTO DE BASE DE DATOS PAGILA${RESET}"
echo -e "${BLUE}========================================${RESET}"
echo "Fecha de ejecución: $(date)"
echo ""

echo -e "${GREEN}[1/2] Ejecutando VACUUM ANALYZE sobre tablas principales...${RESET}"

# VACUUM ANALYZE limpia espacio reutilizable y actualiza estadísticas
# para que el planificador de consultas pueda optimizar mejor las búsquedas.
for TABLA in "${TABLAS[@]}"; do
    echo "Ejecutando VACUUM ANALYZE sobre tabla: $TABLA"
    psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" -v ON_ERROR_STOP=1 -c "VACUUM ANALYZE $TABLA;"
done

echo ""
echo -e "${GREEN}[2/2] Ejecutando REINDEX sobre tablas principales...${RESET}"

# REINDEX reconstruye los índices de las tablas indicadas.
# Esto puede mejorar el rendimiento si los índices están fragmentados o corruptos.
for TABLA in "${TABLAS[@]}"; do
    echo "Ejecutando REINDEX sobre tabla: $TABLA"
    psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" -v ON_ERROR_STOP=1 -c "REINDEX TABLE $TABLA;"
done

echo ""
echo -e "${BLUE}========================================${RESET}"
echo -e "${GREEN} MANTENIMIENTO FINALIZADO CORRECTAMENTE${RESET}"
echo -e "${BLUE}========================================${RESET}"
echo "Log generado en: $LOG_FILE"
