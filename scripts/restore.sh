export PGPASSWORD=$POSTGRES_PASSWORD

#dropdb -U $POSTGRES_USER -h 127.0.0.1 $1
createdb -U $POSTGRES_USER -h 127.0.0.1 $1
psql -U $POSTGRES_USER -h 127.0.0.1 $1 < /app/backups/$2.sql
