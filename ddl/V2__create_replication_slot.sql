-- flyway:executeInTransaction=false

-- Utworzenie slotu replikacyjnego dla Temporal / CDC
DO $$
BEGIN
   IF NOT EXISTS (
      SELECT 1
      FROM pg_replication_slots
      WHERE slot_name = 'syndyk_pub'
   ) THEN
      PERFORM pg_create_logical_replication_slot('syndyk_pub', 'pgoutput');
   END IF;
END
$$;