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