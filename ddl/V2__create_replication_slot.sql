-- flyway:executeInTransaction=false

-- Utworzenie slotu replikacyjnego dla Temporal / CDC
SELECT pg_create_logical_replication_slot('syndyk_pub', 'pgoutput');
