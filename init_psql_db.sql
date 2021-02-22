SELECT 'CREATE DATABASE shorty_database_development'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'shorty_database_development')\gexec

SELECT 'CREATE DATABASE shorty_database_test'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'shorty_database_test')\gexec