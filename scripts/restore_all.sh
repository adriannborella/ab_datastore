#!/bin/bash

export PGPASSWORD=$POSTGRES_PASSWORD

# Si se proporciona un directorio como argumento, usarlo; si no, usar el más reciente
if [ -z "$1" ]; then
    # Buscar el directorio de backup más reciente
    BACKUP_DIR=$(ls -td /app/backups/postgres_* 2>/dev/null | head -n 1)
    
    if [ -z "$BACKUP_DIR" ]; then
        echo "✗ No backup directories found in /app/backups"
        exit 1
    fi
else
    BACKUP_DIR="$1"
fi

if [ ! -d "$BACKUP_DIR" ]; then
    echo "✗ Backup directory not found: $BACKUP_DIR"
    exit 1
fi

echo "Restoring all databases from: $BACKUP_DIR"

# Obtener lista de todos los archivos de backup
backup_files=$(ls -1 "$BACKUP_DIR"/*.sql.gz 2>/dev/null)

if [ -z "$backup_files" ]; then
    echo "✗ No backup files found in $BACKUP_DIR"
    exit 1
fi

# Restaurar cada base de datos
for backup_file in $backup_files; do
    # Extraer el nombre de la base de datos del nombre del archivo
    # Formato: ${db}_TIMESTAMP.sql.gz
    filename=$(basename "$backup_file")
    db=$(echo "$filename" | sed 's/_[0-9]\{8\}_[0-9]\{6\}\.sql\.gz$//')
    
    if [ ! -z "$db" ]; then
        echo "Restoring database: $db"
        
        # Crear la base de datos si no existe
        createdb -h 127.0.0.1 -U $POSTGRES_USER "$db" 2>/dev/null || true
        
        # Restaurar desde el archivo comprimido
        gunzip -c "$backup_file" | psql -h 127.0.0.1 -U $POSTGRES_USER -d "$db"
        
        if [ $? -eq 0 ]; then
            echo "✓ $db restored successfully"
        else
            echo "✗ Failed to restore $db"
        fi
    fi
done

echo "All restores completed from: $BACKUP_DIR"

