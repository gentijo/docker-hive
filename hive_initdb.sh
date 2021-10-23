
# Init Postgres
su - postgres -c  "${POSTGRES_BIN}/initdb -D ${POSTGRES_DATA}/data"
# Start the server
sleep 5
su - postgres -c "${POSTGRES_BIN}/pg_ctl  \
  -D ${POSTGRES_DATA}/data \
  -l ${POSTGRES_DATA}/logs/postgres.log \
  start"

#CREATE ROLE
su - postgres -c "${POSTGRES_BIN}/psql -c \"CREATE USER hiveuser WITH PASSWORD 'hivepass'; \" "
#CREATE DATABASE
su - postgres -c "${POSTGRES_BIN}/psql -c \"CREATE DATABASE metastore; \" "

sleep 5
#Stop Postgres cleanly
#su - postgres -c "${POSTGRES_BIN}/pg_ctl  -D ${POSTGRES_DATA}/data -l ${POSTGRES_DATA}/logs/postgres.log stop"

 /opt/hive/bin/schematool -dbType postgres -initSchema
 /opt/hive/bin/schematool -dbType postgres -info
