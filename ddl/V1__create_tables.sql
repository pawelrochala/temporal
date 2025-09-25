CREATE TABLE x_offers
(
    url        VARCHAR(2048) PRIMARY KEY,
    portal     VARCHAR(30),
    summary      TEXT NOT NULL,
    utworzono  TIMESTAMPTZ DEFAULT NOW()
);


CREATE TABLE x_property
(
    id                   UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    cena                 NUMERIC(15, 2) NOT NULL,
    lokalizacja          TEXT           NOT NULL,
    powierzchnia         NUMERIC(10, 2) NOT NULL,
    powierzchnia_dzialki NUMERIC(12, 2),
    udzial               BOOLEAN,
    ksiega               TEXT,
    typ                  TEXT,
    udzial_wartosc        TEXT,
    wadium               TEXT,
    wadium_kwota           NUMERIC(15, 2) NOT NULL,
    ktora                TEXT,
    edytowano  TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE x_property_offer
(
    id         UUID,
    url        VARCHAR(2048) PRIMARY KEY
);

CREATE PUBLICATION syndyk_pub FOR TABLE x_offers, x_property, x_property_offer;

CREATE USER syndyk_reader WITH PASSWORD 'changeme';

-- Allow the user to connect to the DB and use the schema
GRANT CONNECT ON DATABASE temporal TO syndyk_reader;
GRANT USAGE ON SCHEMA public TO syndyk_reader;

-- Grant read-only access to the tables
GRANT SELECT ON x_offers TO syndyk_reader;
GRANT SELECT ON x_property TO syndyk_reader;
GRANT SELECT ON x_property_offer TO syndyk_reader;

-- Ensure read-only user can see sequences (needed if default values use them)
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO syndyk_reader;