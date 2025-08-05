-- ====================================================
-- 0) LIMPIAR CUALQUIER TABLA ANTERIOR
-- ====================================================
DROP TABLE IF EXISTS advisory_personnel_archive;
DROP TABLE IF EXISTS advisory_commission_records;
DROP TABLE IF EXISTS advisory_personnel;
DROP TABLE IF EXISTS advisory_branches;


-- ====================================================
-- 1) CREAR advisory_branches  (no “departments” ni “locations”)
-- ====================================================
CREATE TABLE advisory_branches (
  branch_id    INT           PRIMARY KEY,
  branch_name  VARCHAR(100)  NOT NULL,
  manager_id   INT,
  location_id  INT
);


-- ====================================================
-- 2) CREAR advisory_personnel  (no “employees”, “staff” ni “worker”)
-- ====================================================
CREATE TABLE advisory_personnel (
  person_id       INT            PRIMARY KEY,
  first_name      VARCHAR(50)    NOT NULL,
  last_name       VARCHAR(50)    NOT NULL,
  email           VARCHAR(100)   NOT NULL,
  phone_number    VARCHAR(20),
  hire_date       TIMESTAMP      NOT NULL,
  job_id          VARCHAR(20)    NOT NULL,
  salary          NUMERIC(12,2)  NOT NULL,
  commission_pct  NUMERIC(5,2),
  manager_id      INT,
  branch_id       INT
);


-- ====================================================
-- 3) POBLAR advisory_branches
-- ====================================================
INSERT INTO advisory_branches (branch_id, branch_name, manager_id, location_id) VALUES
  (200, 'Human Resources',   205, 1500),
  (210, 'Estate Management', 102, 1700);


-- ====================================================
-- 4) POBLAR advisory_personnel
-- ====================================================
INSERT INTO advisory_personnel (
   person_id, first_name, last_name, email, phone_number,
   hire_date, job_id, salary, commission_pct, manager_id, branch_id
) VALUES
  -- a) Solo fecha (sin hora), sin comisión
  (301, 'Katie',    'Hernandez', 'khernandez',  '8586667641',
   TO_DATE('July 8, 2017', 'Month FMDD, YYYY')::TIMESTAMP,
   'MK_REP', 4200, NULL, NULL, NULL),

  -- b) Fecha literal (YYYY-MM-DD), con comisión
  (302, 'Grigorz',  'Polanski',  'gpolanski',   '',
   '2017-06-15'::TIMESTAMP,
   'IT_PROG', 4200, 12.5, NULL, NULL),

  -- c) Fecha + hora, sin comisión
  (303, 'Angelina', 'Wright',    'awright',     '4159982010',
   TO_TIMESTAMP('July 10, 2017 17:20', 'Month FMDD, YYYY HH24:MI'),
   'MK_REP', 3600, NULL, NULL, NULL),

  -- d) CURRENT_USER & NOW(), comisión 5%
  (304, 'Test',     CURRENT_USER,'t_user',      '4159982010',
   NOW(),
   'ST_CLERK', 2500, 5.0, NULL, NULL);


-- ====================================================
-- 5) CONSULTAS DE EJEMPLO
-- ====================================================
-- Veré  ambos catálogos:
SELECT * FROM advisory_branches    LIMIT 5;
SELECT * FROM advisory_personnel   LIMIT 5;

-- Formato “Month DD, YYYY”
SELECT
  first_name,
  TO_CHAR(hire_date, 'FMMonth FMDD, YYYY') AS formatted_hire
FROM advisory_personnel
WHERE person_id = 301;

-- Formato “DD-Mon-YYYY HH24:MI”
SELECT
  first_name,
  last_name,
  TO_CHAR(hire_date, 'DD-Mon-YYYY HH24:MI') AS formatted_datetime
FROM advisory_personnel
WHERE person_id = 303;


-- ====================================================
-- 6.a) EXTRAER REP → advisory_commission_records
-- ====================================================
CREATE TABLE advisory_commission_records AS
SELECT
  person_id      AS rep_id,
  last_name      AS rep_name,
  salary,
  commission_pct
FROM advisory_personnel
WHERE job_id LIKE '%REP%';

SELECT * FROM advisory_commission_records LIMIT 5;


-- ====================================================
-- 6.b) RESPALDO TOTAL → advisory_personnel_archive
-- ====================================================
CREATE TABLE advisory_personnel_archive AS
SELECT * FROM advisory_personnel;

SELECT COUNT(*) AS total_archived
  FROM advisory_personnel_archive;

  -- 0) ELIMINAR CUALQUIER VERSIÓN ANTERIOR
DROP TABLE IF EXISTS review_agents;
DROP TABLE IF EXISTS review_centers;


-- 1) CREAR review_centers (equivalente a “departments” en tu captura)
CREATE TABLE review_centers (
  center_id    INT           PRIMARY KEY,
  center_name  VARCHAR(100)  NOT NULL,
  manager_ref  INT,
  location_ref INT
);


-- 2) CREAR review_agents (equivalente a “employees” en tu captura)
CREATE TABLE review_agents (
  agent_id       INT           PRIMARY KEY,
  first_name     VARCHAR(50)   NOT NULL,
  last_name      VARCHAR(50)   NOT NULL,
  phone_number   VARCHAR(20),
  hire_date      TIMESTAMP     NOT NULL,
  job_ref        VARCHAR(20)   NOT NULL,
  pay_rate       NUMERIC(12,2) NOT NULL,
  commission_pct NUMERIC(5,2),
  manager_ref    INT,
  center_ref     INT
);


-- 3) POBLAR review_centers
INSERT INTO review_centers (center_id, center_name, manager_ref, location_ref) VALUES
  (200, 'Human Resources',   205, 1500),
  (210, 'Estate Management', 102, 1700);


-- 4) POBLAR review_agents
INSERT INTO review_agents (
  agent_id, first_name, last_name, phone_number,
  hire_date, job_ref, pay_rate, commission_pct,
  manager_ref, center_ref
) VALUES
  -- ejemplos base
  (301, 'Katie',    'Hernandez', '8586667641',
   TO_TIMESTAMP('2017-07-08','YYYY-MM-DD'),
   'MK_REP', 4200, NULL, NULL, 200),

  (302, 'Grigorz',  'Polanski',  '',
   TIMESTAMP '2017-06-15 00:00:00',
   'IT_PROG', 4200, 12.5, NULL, 210),

  (303, 'Angelina', 'Wright',    '4159982010',
   TO_TIMESTAMP('2017-07-10 17:20','YYYY-MM-DD HH24:MI'),
   'MK_REP', 3600, NULL, NULL, 200),

  (304, 'Test',     CURRENT_USER,'4159982010',
   NOW(),
   'ST_CLERK', 2500, 5.0,   NULL, 210),

  -- adicionales para las subconsultas de UPDATE
  (401, 'Steven',   'King',      '1111111',
   TIMESTAMP '2010-01-01 09:00:00',
   'AC_MGR', 24000, NULL, NULL, 200),

  (402, 'Neena',    'Kochhar',   '2222222',
   TIMESTAMP '2011-02-01 10:00:00',
   'ST_CLERK', 12000, NULL, NULL, 210),

  (403, 'Shelley',  'Higgins',   '3333333',
   TIMESTAMP '2012-03-01 11:00:00',
   'AC_MGR', 12000, NULL, NULL, 200),

  (404, 'William',  'Gietz',     '4444444',
   TIMESTAMP '2013-04-01 12:00:00',
   'SA_REP', 11000, NULL, NULL, 210);


-- 5) UPDATE de una sola columna en un solo registro
UPDATE review_agents
SET phone_number = '123456'
WHERE agent_id = 303;


-- 6) UPDATE de varias columnas / filas
UPDATE review_agents
SET phone_number = '654321',
    last_name    = 'Jones'
WHERE agent_id >= 303;


-- 7) UPDATE usando subconsulta de la misma tabla
UPDATE review_agents
SET pay_rate = (
  SELECT pay_rate
    FROM review_agents
   WHERE agent_id = 401
)
WHERE agent_id = 402;


-- 8) UPDATE de dos columnas con dos subconsultas
UPDATE review_agents
SET
  pay_rate = (
    SELECT pay_rate
      FROM review_agents
     WHERE agent_id = 403
  ),
  job_ref  = (
    SELECT job_ref
      FROM review_agents
     WHERE agent_id = 403
  )
WHERE agent_id = 404;


-- 9) ALTER + UPDATE con subconsulta de otra tabla
ALTER TABLE review_agents
  ADD COLUMN center_name VARCHAR(100);

UPDATE review_agents ra
SET center_name = (
  SELECT rc.center_name
    FROM review_centers rc
   WHERE rc.center_id = ra.center_ref
);


-- 10) DELETE de un registro
DELETE FROM review_agents
WHERE agent_id = 303;


-- 11) DELETE usando subconsulta
DELETE FROM review_agents
WHERE center_ref = (
  SELECT center_id
    FROM review_centers
   WHERE center_name = 'Estate Management'
);



