SET ROLE hugo;

CREATE TABLE Nominations (
    id SERIAL PRIMARY KEY,
    time timestamptz DEFAULT now(),
    client_ip text NOT NULL,
    client_ua text,
    person_id integer REFERENCES kansa.People NOT NULL,
    signature text NOT NULL,
    competition Competition NOT NULL default 'Hugos',
    category Category NOT NULL,
    nominations jsonb[] NOT NULL
);

CREATE TABLE Finalists (
    id SERIAL PRIMARY KEY,
    competition Competition NOT NULL default 'Hugos',
    category Category NOT NULL,
    sortindex int,
    title text NOT NULL,
    subtitle text
);

CREATE TABLE Votes (
    id SERIAL PRIMARY KEY,
    time timestamptz DEFAULT now(),
    client_ip text NOT NULL,
    client_ua text,
    person_id integer REFERENCES kansa.People NOT NULL,
    signature text NOT NULL,
    competition Competition NOT NULL default 'Hugos',
    category Category NOT NULL,
    votes integer[] NOT NULL
);

CREATE TABLE Packet (
    competition Competition NOT NULL default 'Hugos',
    category Category NOT NULL,
    filename text NOT NULL,
    filesize integer,
    format text NOT NULL
);

CREATE TABLE Canon (
    id SERIAL PRIMARY KEY,
    competition Competition NOT NULL default 'Hugos',
    category Category NOT NULL,
    nomination jsonb NOT NULL,
    disqualified bool NOT NULL DEFAULT false,
    relocated Category,
    UNIQUE (competition, category, nomination)
);

CREATE TABLE Classification (
    competition Competition NOT NULL default 'Hugos',
    category Category,
    nomination jsonb,
    canon_id integer REFERENCES Canon,
    PRIMARY KEY (competition, category, nomination)
);

CREATE VIEW CurrentBallots AS SELECT
    DISTINCT ON (person_id, competition, category)
    id AS ballot_id, category, nominations, competition
    FROM Nominations
    ORDER BY person_id, competition, category, time DESC;

CREATE VIEW CurrentNominations AS SELECT
    n.ballot_id, n.competition, n.category, n.nomination, c.canon_id
    FROM (
        SELECT ballot_id, competition, category, unnest(nominations) as nomination
        FROM CurrentBallots
    ) AS n
    NATURAL LEFT OUTER JOIN Classification c;

CREATE VIEW CurrentVotes AS SELECT
    DISTINCT ON (person_id, competition, category)
    id, person_id, signature, competition, category, votes
    FROM Votes
    ORDER BY person_id, competition, category, time DESC;


-- allow clients to listen to changes
CREATE FUNCTION canon_notify() RETURNS trigger as $$
BEGIN
    PERFORM pg_notify('canon', json_build_object(TG_TABLE_NAME, NEW)::text);
    RETURN null;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER notify
    AFTER INSERT OR UPDATE ON Canon
    FOR EACH ROW EXECUTE PROCEDURE canon_notify();

CREATE TRIGGER notify
    AFTER INSERT OR UPDATE ON Classification
    FOR EACH ROW EXECUTE PROCEDURE canon_notify();


-- remove empty canonicalisations
CREATE OR REPLACE FUNCTION canon_cleanup() RETURNS trigger as $$
BEGIN
    PERFORM FROM Classification WHERE canon_id = OLD.canon_id;
    IF NOT FOUND THEN
        DELETE FROM Canon WHERE id = OLD.canon_id;
    END IF;
    RETURN null;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER cleanup
    AFTER UPDATE ON Classification
    FOR EACH ROW
    WHEN (OLD.canon_id IS DISTINCT FROM NEW.canon_id)
    EXECUTE PROCEDURE canon_cleanup();
