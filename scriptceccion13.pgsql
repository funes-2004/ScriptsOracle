-- ====================================================
-- 0) LIMPIAR CUALQUIER VERSIÓN ANTERIOR
-- ====================================================
DROP FOREIGN TABLE IF EXISTS advisory_emp_load;
DROP TABLE IF EXISTS advisory_contacts;
DROP TABLE IF EXISTS advisory_media_collection;


-- ====================================================
-- 1) INSPECCIÓN DEL ESQUEMA (“DESCRIBE” en Oracle)
--    – En psql usarías: \d advisory_media_collection
--    – Por SQL estándar:
-- ====================================================
-- Listar tablas en public
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_type = 'BASE TABLE'
ORDER BY table_name;

-- Listar columnas de una tabla
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_name = 'advisory_media_collection'
ORDER BY ordinal_position;


-- ====================================================
-- 2) CREAR advisory_media_collection (equivale a my_cd_collection)
-- ====================================================
CREATE TABLE advisory_media_collection (
  cd_id         SERIAL       PRIMARY KEY,            -- cd_number NUMBER(3)
  title         VARCHAR(50)  NOT NULL,               -- title VARCHAR2(20)
  artist        VARCHAR(50)  NOT NULL,               -- artist VARCHAR2(20)
  purchase_date DATE         DEFAULT CURRENT_DATE    -- purchase_date DATE DEFAULT SYSDATE
);

-- POBLAR advisory_media_collection
INSERT INTO advisory_media_collection (title, artist) VALUES
  ('The Best of 80s', 'Various Artists'),
  ('Latin Hits',      'DJ Fiesta'),
  ('Rolling Classics','The Rollers');


-- ====================================================
-- 3) CREAR advisory_contacts (equivale a my_friends)
-- ====================================================
CREATE TABLE advisory_contacts (
  contact_id  SERIAL      PRIMARY KEY,
  first_name  VARCHAR(30) NOT NULL,
  last_name   VARCHAR(30) NOT NULL,
  email       VARCHAR(50),
  phone_num   VARCHAR(15),
  birth_date  DATE
);

-- POBLAR advisory_contacts
INSERT INTO advisory_contacts (first_name, last_name, email, phone_num, birth_date) VALUES
  ('Ana',  'García',  'ana.garcia@example.com',  '555-1234', '1990-04-12'),
  ('Luis', 'Pérez',   'luis.perez@example.com',  '555-5678', '1985-11-30');


-- ====================================================
-- 4) CREAR advisory_emp_load COMO FOREIGN TABLE
--    (equivale a emp_load externo en Oracle)
-- ====================================================
-- Habilitar la extensión de acceso a archivos planos
CREATE EXTENSION IF NOT EXISTS file_fdw;
CREATE SERVER IF NOT EXISTS emp_load_srv FOREIGN DATA WRAPPER file_fdw;

-- Definir el directorio (necesita permiso en el servidor)
-- Aquí asumimos que “/var/lib/postgresql/data/” está permitido
CREATE FOREIGN TABLE advisory_emp_load (
  employee_number   CHAR(5),
  employee_dob      CHAR(10),
  employee_last_name CHAR(20),
  employee_first_name CHAR(15),
  employee_middle_name CHAR(15),
  employee_hire_date DATE
)
SERVER emp_load_srv
OPTIONS ( 
  filename '/var/lib/postgresql/data/info.csv',
  format 'csv',
  HEADER 'false'
);


-- ====================================================
-- 5) CONSULTAS AL DICCIONARIO DE DATOS (Data Dictionary)
--    – Índices
--    – Secuencias
-- ====================================================
-- Listar índices en public
SELECT indexname, tablename
FROM pg_indexes
WHERE schemaname = 'public'
  AND tablename LIKE 'advisory_%';

-- Listar secuencias en public
SELECT sequence_name
FROM information_schema.sequences
WHERE sequence_schema = 'public';


-- ====================================================
-- 6) EJEMPLOS DE DESCRIBE (equivalente a DESCRIBE jobs)
-- ====================================================
-- En psql simplemente usarías:
--   \d advisory_media_collection
--   \d advisory_contacts

-- Pero por SQL estándar, para ver columnas:
SELECT column_name, data_type, character_maximum_length, is_nullable
FROM information_schema.columns
WHERE table_name = 'advisory_contacts'
ORDER BY ordinal_position;

-- ====================================================
-- A) TEMPORALES: TIMESTAMP, TIMESTAMPTZ y TIMESTAMP SIN ZONA
-- ====================================================
DROP TABLE IF EXISTS advisory_temporal_demo;
CREATE TABLE advisory_temporal_demo (
  demo_id         SERIAL       PRIMARY KEY,
  exact_ts        TIMESTAMP,       -- equivalente a Oracle TIMESTAMP
  ts_with_tz      TIMESTAMPTZ,     -- equivalente a Oracle TIMESTAMP WITH TIME ZONE
  local_ts        TIMESTAMP        -- equivalente a Oracle TIMESTAMP WITH LOCAL TIME ZONE
);

INSERT INTO advisory_temporal_demo (exact_ts, ts_with_tz, local_ts) VALUES
  -- literal con microsegundos
  ( '2017-06-10 10:52:29.123456'::TIMESTAMP,
    CURRENT_TIMESTAMP,                       -- equivalente a SYSTIMESTAMP
    CURRENT_TIMESTAMP AT TIME ZONE 'UTC'     -- demostración de zona local vs UTC
  ),
  -- Sysdate / now()
  ( NOW()::TIMESTAMP,
    NOW(), 
    NOW() AT TIME ZONE 'Europe/Istanbul'     -- si tu sesión está en CET, verás ajuste
  );

-- Ver resultados
SELECT * FROM advisory_temporal_demo;


-- ====================================================
-- B) INTERVALOS: YEAR TO MONTH y DAY TO SECOND
-- ====================================================
DROP TABLE IF EXISTS advisory_interval_demo;
CREATE TABLE advisory_interval_demo (
  id                   SERIAL       PRIMARY KEY,
  months_interval      INTERVAL,    -- INTERVAL YEAR TO MONTH
  years_months_term    INTERVAL,    -- INTERVAL '3 years 6 months'
  precise_interval     INTERVAL     -- INTERVAL DAY TO SECOND
);

INSERT INTO advisory_interval_demo (months_interval, years_months_term, precise_interval) VALUES
  ( INTERVAL '120 months',            -- 120 MONTHS → 10 años
    INTERVAL '3 years 6 months',      -- 3 YEARS 6 MONTHS
    INTERVAL '25 days 4 hours 30 minutes 15 seconds'  -- DAY TO SECOND
  );

-- Usos de los intervalos
SELECT
  now() + months_interval     AS "120 months from now",
  now() + years_months_term   AS "3 years 6 months from now",
  now() + precise_interval    AS "25 days 4h30m15s from now"
FROM advisory_interval_demo;




-- ====================================================
-- 0) LIMPIAR CUALQUIER VERSIÓN ANTERIOR
-- ====================================================
DROP TABLE IF EXISTS advisory_mod_demo;


-- ====================================================
-- 1) CREAR advisory_mod_demo (equivale a “mod_emp”)
-- ====================================================
CREATE TABLE advisory_mod_demo (
  last_entry     VARCHAR(20),
  salary_amount  NUMERIC(8,2)
);


-- ====================================================
-- 2) POBLAR advisory_mod_demo
-- ====================================================
INSERT INTO advisory_mod_demo (last_entry, salary_amount) VALUES
  ('Smith', 5000),
  ('Jones', 7000);


-- ====================================================
-- 3) ALTER TABLE: ADICIÓN DE UNA COLUMNA
--    (equivale a ADD release_date DATE DEFAULT SYSDATE)
-- ====================================================
ALTER TABLE advisory_mod_demo
  ADD COLUMN release_date DATE DEFAULT CURRENT_DATE;


-- Verificar la nueva columna
SELECT * FROM advisory_mod_demo;


-- ====================================================
-- 4) ALTER TABLE: MODIFICACIÓN DE UNA COLUMNA
--    (equivale a MODIFY last_name VARCHAR2(30), etc.)
-- ====================================================
-- a) Aumentar ancho de last_entry (permitido con o sin datos)
ALTER TABLE advisory_mod_demo
  ALTER COLUMN last_entry TYPE VARCHAR(30);

-- b) Reducir ancho de last_entry (solo si todos los valores caben)
ALTER TABLE advisory_mod_demo
  ALTER COLUMN last_entry TYPE VARCHAR(10);

-- c) Aumentar precisión de salary_amount
ALTER TABLE advisory_mod_demo
  ALTER COLUMN salary_amount TYPE NUMERIC(10,2);

-- d) Asignar DEFAULT a salary_amount
ALTER TABLE advisory_mod_demo
  ALTER COLUMN salary_amount SET DEFAULT 1000;


-- Verificar cambios de esquema
SELECT column_name, data_type, character_maximum_length, column_default
FROM information_schema.columns
WHERE table_name = 'advisory_mod_demo'
ORDER BY ordinal_position;


-- ====================================================
-- 5) ALTER TABLE: BORRADO DE UNA COLUMNA
--    (equivale a DROP COLUMN release_date)
-- ====================================================
ALTER TABLE advisory_mod_demo
  DROP COLUMN release_date;


-- Verificar que release_date ya no existe
SELECT column_name
FROM information_schema.columns
WHERE table_name = 'advisory_mod_demo';


-- ====================================================
-- 6) “SET UNUSED” (no disponible en Postgres)
--    → simulamos añadiendo y luego borrando la columna
-- ====================================================
ALTER TABLE advisory_mod_demo
  ADD COLUMN email_address VARCHAR(50);

ALTER TABLE advisory_mod_demo
  DROP COLUMN email_address;


-- ====================================================
-- 7) DROP TABLE
--    (equivale a DROP TABLE copy_employees)
-- ====================================================
DROP TABLE advisory_mod_demo;


-- ====================================================
-- A) SIMULAR “RECYCLEBIN” (FLASHBACK TABLE)
--    PostgreSQL no tiene recyclebin; vamos a capturar DROPs en un log
-- ====================================================
CREATE TABLE IF NOT EXISTS advisory_recycle_log (
  original_name TEXT       NOT NULL,
  operation     TEXT       NOT NULL,
  drop_time     TIMESTAMPTZ DEFAULT now()
);

-- Trigger function que registra el DROP
CREATE OR REPLACE FUNCTION log_drop() RETURNS event_trigger AS $$
BEGIN
  INSERT INTO advisory_recycle_log(original_name, operation)
  SELECT objid::regclass::text, TG_TAG
    FROM pg_event_trigger_dropped_objects();
END;
$$ LANGUAGE plpgsql;

-- Evento de trigger sobre DROP TABLE
DROP EVENT TRIGGER IF EXISTS trg_log_drop;
CREATE EVENT TRIGGER trg_log_drop
  ON sql_drop
  WHEN TAG IN ('DROP TABLE')
  EXECUTE PROCEDURE log_drop();

-- Prueba: dropea y revisa el log
DROP TABLE IF EXISTS advisory_temp_table;
CREATE TABLE advisory_temp_table(id INT);
DROP TABLE advisory_temp_table;
SELECT * FROM advisory_recycle_log ORDER BY drop_time DESC LIMIT 1;


-- ====================================================
-- B) RENAME (cambiar nombre de tabla)
-- ====================================================
-- Renombramos advisory_media_collection → advisory_music_collection
ALTER TABLE advisory_media_collection
  RENAME TO advisory_music_collection;

-- Verificar
\d advisory_music_collection


-- ====================================================
-- C) TRUNCATE (vaciar tabla rápidamente)
-- ====================================================
TRUNCATE TABLE advisory_contacts;
-- Ahora advisory_contacts está vacía.


-- ====================================================
-- D) COMMENT ON (añadir y consultar comentarios)
-- ====================================================
COMMENT ON TABLE advisory_music_collection
  IS 'Catálogo de música generado a partir de las diapositivas de Oracle';
COMMENT ON COLUMN advisory_music_collection.artist
  IS 'Artista o compilación de cada CD';

-- Consultar comentarios
SELECT
  c.relname   AS table_name,
  obj_description(c.oid) AS table_comment
FROM pg_class c
WHERE c.relkind = 'r'
  AND c.relname = 'advisory_music_collection';

SELECT
  cols.column_name,
  pg_catalog.col_description(c.oid, cols.ordinal_position::int) AS column_comment
FROM pg_class c
JOIN information_schema.columns cols
  ON cols.table_name = c.relname
WHERE c.relname = 'advisory_music_collection'
  AND cols.column_name = 'artist';


-- ====================================================
-- E) “FLASHBACK QUERY” SIMULADO con TRANSACTION SNAPSHOT
--    (Oracle VERSIONS not available en Postgres nativo)
-- ====================================================
-- 1) iniciamos una sesión con snapshot
BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;

-- 2) Leemos la fila actual
SELECT * FROM advisory_personnel WHERE person_id = 401;

-- 3) Actualizamos y comprobamos que no veremos cambios hasta commit
UPDATE advisory_personnel SET salary = salary + 1 WHERE person_id = 401;
SELECT * FROM advisory_personnel WHERE person_id = 401;  -- aún verá el valor anterior

-- 4) hacemos ROLLBACK para “volver en el tiempo”
ROLLBACK;


-- ====================================================
-- X) SIMULACIÓN DE FLASHBACK QUERY MEDIANTE AUDIT TRAIL
-- ====================================================
-- 1) Crear tabla de auditoría
DROP TABLE IF EXISTS advisory_personnel_audit;
CREATE TABLE advisory_personnel_audit (
  audit_id        SERIAL        PRIMARY KEY,
  person_id       INT           NOT NULL,
  first_name      TEXT          NOT NULL,
  last_name       TEXT          NOT NULL,
  salary          NUMERIC(12,2) NOT NULL,
  operation       CHAR(1)       NOT NULL,       -- 'I'nsert, 'U'pdate, 'D'elete
  operation_time  TIMESTAMPTZ   NOT NULL DEFAULT now()
);

-- 2) Función de trigger para volcar cada cambio
CREATE OR REPLACE FUNCTION fn_advisory_personnel_audit() RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    INSERT INTO advisory_personnel_audit(person_id, first_name, last_name, salary, operation)
      VALUES(NEW.person_id, NEW.first_name, NEW.last_name, NEW.salary, 'I');
    RETURN NEW;
  ELSIF TG_OP = 'UPDATE' THEN
    INSERT INTO advisory_personnel_audit(person_id, first_name, last_name, salary, operation)
      VALUES(OLD.person_id, OLD.first_name, OLD.last_name, OLD.salary, 'U');
    RETURN NEW;
  ELSIF TG_OP = 'DELETE' THEN
    INSERT INTO advisory_personnel_audit(person_id, first_name, last_name, salary, operation)
      VALUES(OLD.person_id, OLD.first_name, OLD.last_name, OLD.salary, 'D');
    RETURN OLD;
  END IF;
END;
$$ LANGUAGE plpgsql;

-- 3) Trigger sobre advisory_personnel
DROP TRIGGER IF EXISTS trg_audit_personnel ON advisory_personnel;
CREATE TRIGGER trg_audit_personnel
  AFTER INSERT OR UPDATE OR DELETE ON advisory_personnel
  FOR EACH ROW EXECUTE PROCEDURE fn_advisory_personnel_audit();


-- ====================================================
-- Y) DEMOSTRACIÓN: INSERT → UPDATE → DELETE
-- ====================================================
-- a) Nuevo empleado ID=501 (I)
INSERT INTO advisory_personnel (
  person_id, first_name, last_name, email, phone_number,
  hire_date, job_id, salary
) VALUES (
  501, 'Flash', 'Back', 'fb@demo.com', '0000000000',
  NOW(), 'FLASH',  1000
);

-- b) Modificar salario (U)
UPDATE advisory_personnel
SET salary = 1
WHERE person_id = 501;

-- c) Borrar registro (D)
DELETE FROM advisory_personnel
WHERE person_id = 501;


-- ====================================================
-- Z) CONSULTAR HISTÓRICO (simula FLASHBACK QUERY)
-- ====================================================
SELECT
  person_id,
  first_name || ' ' || last_name AS name,
  operation AS op,
  to_char(operation_time, 'YYYY-MM-DD HH24:MI:SS.US TZ') AS when_ts
FROM advisory_personnel_audit
WHERE person_id = 501
ORDER BY operation_time DESC;
