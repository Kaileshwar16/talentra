-- Small, repeatable Phase 5 reference set for lookups that were empty in production.
-- These tables assign identity IDs automatically.

WITH source(code, display_name) AS (VALUES
  ('hi', 'Hindi'), ('ar', 'Arabic'), ('zh', 'Chinese'), ('ru', 'Russian')),
missing AS (
  SELECT s.* FROM source s
  WHERE NOT EXISTS (SELECT 1 FROM public.language t WHERE t.code = s.code))
INSERT INTO public.language(code, display_name)
SELECT code, display_name FROM missing;

WITH source(code, display_name) AS (VALUES
  ('TECH', 'Technology'), ('HEALTH', 'Healthcare'), ('FINANCE', 'Finance'),
  ('EDUCATION', 'Education'), ('RETAIL', 'Retail')),
missing AS (
  SELECT s.* FROM source s
  WHERE NOT EXISTS (SELECT 1 FROM public.industry t WHERE t.code = s.code))
INSERT INTO public.industry(code, display_name)
SELECT code, display_name FROM missing;

WITH source(code, display_name) AS (VALUES
  ('PYTHON', 'Python'), ('SQL', 'SQL'), ('JAVASCRIPT', 'JavaScript'),
  ('POSTGRESQL', 'PostgreSQL'), ('REACT', 'React'), ('DATA_ANALYSIS', 'Data analysis')),
missing AS (
  SELECT s.* FROM source s
  WHERE NOT EXISTS (SELECT 1 FROM public.skill t WHERE t.code = s.code))
INSERT INTO public.skill(code, display_name)
SELECT code, display_name FROM missing;

WITH source(code, display_name) AS (VALUES
  ('SOFTWARE_ENGINEER', 'Software engineer'), ('DATA_ANALYST', 'Data analyst'),
  ('RECRUITER', 'Recruiter'), ('PRODUCT_MANAGER', 'Product manager')),
missing AS (
  SELECT s.* FROM source s
  WHERE NOT EXISTS (SELECT 1 FROM public.job_role t WHERE t.code = s.code))
INSERT INTO public.job_role(code, display_name)
SELECT code, display_name FROM missing;

WITH source(code, display_name) AS (VALUES
  ('BACHELORS', 'Bachelor degree'), ('MASTERS', 'Master degree'),
  ('DOCTORATE', 'Doctorate')),
missing AS (
  SELECT s.* FROM source s
  WHERE NOT EXISTS (SELECT 1 FROM public.qualification t WHERE t.code = s.code))
INSERT INTO public.qualification(code, display_name)
SELECT code, display_name FROM missing;

WITH source(code, display_name, country_code) AS (VALUES
  ('KA', 'Karnataka', 'IN'), ('MH', 'Maharashtra', 'IN'),
  ('CA', 'California', 'US'), ('NY', 'New York', 'US')),
missing AS (
  SELECT s.*, c.id AS country_id
  FROM source s JOIN public.country c ON c.code = s.country_code
  WHERE NOT EXISTS (SELECT 1 FROM public.state t
    WHERE t.country_id = c.id AND t.code = s.code))
INSERT INTO public.state(code, display_name, country_id)
SELECT code, display_name, country_id FROM missing;

WITH source(display_name, state_code, country_code) AS (VALUES
  ('Bengaluru', 'KA', 'IN'), ('Mumbai', 'MH', 'IN'),
  ('San Francisco', 'CA', 'US'), ('New York City', 'NY', 'US')),
missing AS (
  SELECT s.display_name, st.id AS state_id
  FROM source s JOIN public.country c ON c.code = s.country_code
  JOIN public.state st ON st.country_id = c.id AND st.code = s.state_code
  WHERE NOT EXISTS (SELECT 1 FROM public.city t
    WHERE t.state_id = st.id AND t.display_name = s.display_name))
INSERT INTO public.city(display_name, state_id)
SELECT display_name, state_id FROM missing;
