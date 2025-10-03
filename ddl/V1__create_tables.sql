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

-- 1. Create history table
CREATE TABLE x_property_history
(
    history_id           BIGSERIAL PRIMARY KEY,
    property_id          UUID        NOT NULL,
    cena                 NUMERIC(15, 2) NOT NULL,
    lokalizacja          TEXT           NOT NULL,
    powierzchnia         NUMERIC(10, 2) NOT NULL,
    powierzchnia_dzialki NUMERIC(12, 2),
    udzial               BOOLEAN,
    ksiega               TEXT,
    typ                  TEXT,
    udzial_wartosc       TEXT,
    wadium               TEXT,
    wadium_kwota         NUMERIC(15, 2) NOT NULL,
    ktora                TEXT,
    edytowano            TIMESTAMPTZ NOT NULL,
    changed_at           TIMESTAMPTZ DEFAULT NOW(),   -- when the change happened
    operation            TEXT         NOT NULL        -- e.g. 'UPDATE'
);

-- 2. Create trigger function
CREATE OR REPLACE FUNCTION fn_x_property_audit()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'UPDATE' THEN
        INSERT INTO x_property_history (
            property_id, cena, lokalizacja, powierzchnia,
            powierzchnia_dzialki, udzial, ksiega, typ, udzial_wartosc,
            wadium, wadium_kwota, ktora, edytowano, operation
        )
        VALUES (
            OLD.id, OLD.cena, OLD.lokalizacja, OLD.powierzchnia,
            OLD.powierzchnia_dzialki, OLD.udzial, OLD.ksiega, OLD.typ,
            OLD.udzial_wartosc, OLD.wadium, OLD.wadium_kwota,
            OLD.ktora, OLD.edytowano, TG_OP
        );
END IF;

    -- also update the "edytowano" column on the main table
    NEW.edytowano := NOW();

RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 3. Attach trigger to x_property
CREATE TRIGGER trg_x_property_history
    BEFORE UPDATE ON x_property
    FOR EACH ROW
    EXECUTE FUNCTION fn_x_property_audit();


-- Create publication only if it does not exist
DO $$
BEGIN
   IF NOT EXISTS (SELECT 1 FROM pg_publication WHERE pubname = 'syndyk_pub') THEN
      CREATE PUBLICATION syndyk_pub FOR TABLE x_offers, x_property, x_property_offer;
   END IF;
END
$$;

-- Create user only if it does not exist
DO $$
BEGIN
   IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'syndyk_reader') THEN
      CREATE USER syndyk_reader WITH PASSWORD 'changeme';
   END IF;
END
$$;

-- Allow the user to connect to the DB and use the schema
GRANT CONNECT ON DATABASE temporal TO syndyk_reader;
GRANT USAGE ON SCHEMA public TO syndyk_reader;

-- Grant read-only access to the tables
GRANT SELECT ON x_offers TO syndyk_reader;
GRANT SELECT ON x_property TO syndyk_reader;
GRANT SELECT ON x_property_offer TO syndyk_reader;

-- Give replication privilege (safe if already set)
ALTER ROLE syndyk_reader WITH REPLICATION;

-- Ensure read-only user can see sequences
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO syndyk_reader;
