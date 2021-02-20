FROM postgres:13.1

COPY ./init_psql_db.sql /docker-entrypoint-initdb.d/