\set kansaPwd `echo "$KANSA_PG_PASSWORD"`

CREATE EXTENSION fuzzystrmatch WITH SCHEMA public;

CREATE USER kansa WITH PASSWORD :'kansaPwd' IN ROLE api_access;
CREATE SCHEMA AUTHORIZATION kansa;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO kansa;
