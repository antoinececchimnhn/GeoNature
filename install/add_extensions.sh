#TODO: Remettre les logs
psql $DATABASE_URL -c "CREATE EXTENSION IF NOT EXISTS hstore;"
psql $DATABASE_URL -c "CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog; COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';"
psql $DATABASE_URL -c 'CREATE EXTENSION IF NOT EXISTS "uuid-ossp";'
psql $DATABASE_URL -c "CREATE EXTENSION IF NOT EXISTS pg_trgm WITH SCHEMA pg_catalog;"


# Mise en place de la structure de la BDD et des données permettant son fonctionnement avec l'application
for table in geometry_columns geography_columns spatial_ref_sys; do
  psql $DATABASE_URL -c "GRANT SELECT ON TABLE ${table} TO ${user_pg}"
done
