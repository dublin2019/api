\set artPwd `echo "$RAAMI_PG_PASSWORD"`

CREATE USER art WITH PASSWORD :'artPwd' IN ROLE api_access;
CREATE SCHEMA AUTHORIZATION art;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO art;
GRANT USAGE ON SCHEMA members TO art;
GRANT SELECT, REFERENCES ON ALL TABLES IN SCHEMA members TO art;
SET ROLE art;

CREATE TABLE IF NOT EXISTS Artist (
    -- id SERIAL PRIMARY KEY,
    people_id integer REFERENCES members.People PRIMARY KEY,
    name text,
    continent text,
    url text,
    filename text,
    filedata text,
    category text,
    description text,
    transport text,
    auction integer,
    half integer,
    print integer,
    digital boolean,
    legal boolean,
    agent text,
    contact text,
    waitlist boolean,
    postage integer
    );

CREATE TABLE IF NOT EXISTS Works (
    id SERIAL PRIMARY KEY,
    people_id integer REFERENCES Artist NOT NULL,
    title text,
    width integer,
    height integer,
    depth integer,
    technique text,
    orientation text,
    graduation text,
    filename text,
    filedata text,
    price integer,
    gallery text,
    year integer,
    original boolean,
    copies integer,
    start integer,
    sale integer,
    permission boolean,
    form text
    );


