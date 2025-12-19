export PGPASSWORD=$POSTGRES_PASSWORD

DATABASE=ab_gym_prod

pg_dump -p 5432 -U $POSTGRES_USER -h 127.0.0.1 $DATABASE > backup_$DATABASE.sql

# backup_ab_gym_prod.sql

# /home/app/backup_ab_gym_prod.sql