#!/bin/bash

export PGPASSWORD=$POSTGRES_PASSWORD

# Crear directorio para backups con timestamp
BACKUP_DIR="/app/backups/postgres_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

echo "Backing up all databases to: $BACKUP_DIR"

# Obtener lista de todas las bases de datos (excluyendo templates)
databases=$(psql -h 127.0.0.1 -U $POSTGRES_USER -d postgres -t -c "SELECT datname FROM pg_database WHERE datistemplate = false AND datname != 'postgres';")

# Hacer backup de cada base de datos
for db in $databases; do
    # Limpiar espacios en blanco
    db=$(echo $db | xargs)
    
    if [ ! -z "$db" ]; then
        echo "Backing up database: $db"
        pg_dump -h 127.0.0.1 -U $POSTGRES_USER \
            -d "$db" \
            --no-owner \
            --no-acl \
            --clean \
            --if-exists \
            | gzip > "$BACKUP_DIR/${db}_$(date +%Y%m%d_%H%M%S).sql.gz"
        
        if [ $? -eq 0 ]; then
            echo "✓ $db backed up successfully"
        else
            echo "✗ Failed to backup $db"
        fi
    fi
done

echo "All backups completed in: $BACKUP_DIR"
ls -lh "$BACKUP_DIR"