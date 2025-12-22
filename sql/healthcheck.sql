-- Minimal healthcheck function that returns 1
CREATE OR REPLACE FUNCTION public.healthcheck()
RETURNS integer
LANGUAGE sql
STABLE
AS $$
  SELECT 1;
$$;

-- Allow anon (publishable) key to execute it
GRANT EXECUTE ON FUNCTION public.healthcheck() TO anon;
