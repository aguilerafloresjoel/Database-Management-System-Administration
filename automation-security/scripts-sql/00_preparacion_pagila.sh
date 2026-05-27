#!/bin/bash

# El script se detiene automáticamente si un comando falla.
set -e

# Variables principales
DB_NAME="pagila"
DB_USER="postgres"
DB_HOST="localhost"
REPO_URL="https://github.com/devrimgunduz/pagila.git"
REPO_DIR="pagila"

echo "========================================"
echo " FASE 0 - Preparación de Pagila"
echo "========================================"

echo "[1/5] Eliminando repositorio anterior si existe..."
rm -rf "$REPO_DIR"

echo "[2/5] Clonando repositorio oficial de Pagila..."
git clone --depth 1 "$REPO_URL"

echo "[3/5] Recreando base de datos $DB_NAME..."
psql -h "$DB_HOST" -U "$DB_USER" -d postgres -v ON_ERROR_STOP=1 <<SQL
SELECT pg_terminate_backend(pid)
FROM pg_stat_activity
WHERE datname = '$DB_NAME'
  AND pid <> pg_backend_pid();

DROP DATABASE IF EXISTS $DB_NAME;
CREATE DATABASE $DB_NAME;
SQL

# ON_ERROR_STOP=1 -> Si alguna sentencia SQL falla, para la ejecución y devuelve error.
# <<SQL -> Eso se llama heredoc y sirve para meter varias líneas SQL directamente dentro del script Bash, sin tener que crear otro archivo aparte.

echo "[4/5] Cargando esquema de Pagila..."
psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" -v ON_ERROR_STOP=1 -f "$REPO_DIR/pagila-schema.sql"

echo "[5/5] Cargando datos de Pagila..."
psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" -v ON_ERROR_STOP=1 -f "$REPO_DIR/pagila-insert-data.sql"

echo "========================================"
echo " Pagila preparada correctamente"
echo "========================================"
