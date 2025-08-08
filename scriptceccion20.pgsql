-- =========================================================
-- PROYECTO FINAL (100% funcional y sin choques) — Prefijo: pf3_
-- =========================================================

-- 0) LIMPIEZA TOTAL (cierra sesiones, re-asigna y elimina TODO lo previo del prefijo)
DO $$
BEGIN
  -- matar sesiones activas de los roles del proyecto
  PERFORM pg_terminate_backend(pid)
  FROM pg_stat_activity
  WHERE usename IN ('pf3_user','pf3_manager')
    AND pid <> pg_backend_pid();

  -- borrar esquema por si quedó algo
  EXECUTE 'DROP SCHEMA IF EXISTS pf3_lab CASCADE';

  -- limpiar pf3_user si existe (reassign -> drop owned -> drop role)
  IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'pf3_user') THEN
    EXECUTE 'REASSIGN OWNED BY pf3_user TO CURRENT_USER';
    EXECUTE 'DROP OWNED BY pf3_user';
    EXECUTE 'DROP ROLE pf3_user';
  END IF;

  -- limpiar pf3_manager si existe
  IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'pf3_manager') THEN
    EXECUTE 'REASSIGN OWNED BY pf3_manager TO CURRENT_USER';
    EXECUTE 'DROP OWNED BY pf3_manager';
    EXECUTE 'DROP ROLE pf3_manager';
  END IF;
END$$;

-- 1) ROLES (creación segura)
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname='pf3_user') THEN
    EXECUTE $$CREATE ROLE pf3_user LOGIN PASSWORD 'pf3_pwd' NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION$$;
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname='pf3_manager') THEN
    EXECUTE 'CREATE ROLE pf3_manager NOLOGIN';
  END IF;
END$$;

-- 2) PRIVILEGIOS A NIVEL BASE
DO $$
DECLARE dbname text := current_database();
BEGIN
  EXECUTE format('GRANT CONNECT, TEMP ON DATABASE %I TO pf3_user;', dbname);
END$$;

-- 3) ESQUEMA + SEARCH_PATH
CREATE SCHEMA pf3_lab AUTHORIZATION CURRENT_USER;
GRANT USAGE, CREATE ON SCHEMA pf3_lab TO pf3_user;
ALTER ROLE pf3_user SET search_path = pf3_lab, public;

-- 4) TABLAS PRINCIPALES (nombres propios)
CREATE TABLE pf3_lab.pf3_nations(
  nation_id   INTEGER PRIMARY KEY,
  nation_name VARCHAR(60) UNIQUE
);

CREATE TABLE pf3_lab.pf3_sites(
  site_id     INTEGER PRIMARY KEY,
  city        VARCHAR(80) NOT NULL,
  nation_id   INTEGER NOT NULL REFERENCES pf3_lab.pf3_nations(nation_id) ON DELETE RESTRICT
);

CREATE TABLE pf3_lab.pf3_depts(
  dept_id     INTEGER PRIMARY KEY,
  dept_name   VARCHAR(80) NOT NULL UNIQUE,
  site_id     INTEGER NOT NULL REFERENCES pf3_lab.pf3_sites(site_id) ON DELETE RESTRICT
);

CREATE SEQUENCE pf3_lab.pf3_staff_id_seq START 100 INCREMENT 1 NO CYCLE;

CREATE TABLE pf3_lab.pf3_staff(
  emp_id          INTEGER PRIMARY KEY DEFAULT nextval('pf3_lab.pf3_staff_id_seq'),
  first_name      VARCHAR(20),
  last_name       VARCHAR(25) NOT NULL,
  email           VARCHAR(50) UNIQUE,
  phone_number    VARCHAR(30),
  hire_date       DATE NOT NULL DEFAULT CURRENT_DATE,
  job_title       VARCHAR(35) NOT NULL,
  salary          NUMERIC(10,2) NOT NULL CHECK (salary >= 0),
  commission_pct  NUMERIC(4,2),
  manager_id      INTEGER,
  dept_id         INTEGER REFERENCES pf3_lab.pf3_depts(dept_id) ON DELETE SET NULL
);

ALTER TABLE pf3_lab.pf3_staff
  ADD CONSTRAINT pf3_staff_mgr_fk FOREIGN KEY (manager_id)
  REFERENCES pf3_lab.pf3_staff(emp_id) ON DELETE SET NULL;

-- 5) DATOS DE MUESTRA
INSERT INTO pf3_lab.pf3_nations VALUES
 (1,'United States of America'),
 (2,'Canada'),
 (3,'United Kingdom');

INSERT INTO pf3_lab.pf3_sites VALUES
 (10,'Seattle',1),
 (20,'Toronto',2),
 (30,'London',3);

INSERT INTO pf3_lab.pf3_depts VALUES
 (90,'Executive',10),
 (60,'IT',10),
 (50,'Shipping',10),
 (20,'Marketing',20),
 (110,'Accounting',10);

INSERT INTO pf3_lab.pf3_staff
 (emp_id,first_name,last_name,email,phone_number,hire_date,job_title,salary,commission_pct,manager_id,dept_id) VALUES
 (200,'Steven','King','s.king@demo','515.123.4567',DATE '2003-06-17','Executive',24000,NULL,NULL,90),
 (201,'Neena','Kochhar','n.kochhar@demo','515.123.4568',DATE '2005-09-21','Executive',17000,NULL,200,90),
 (202,'Lex','De Haan','l.dehaan@demo','515.123.4569',DATE '2001-01-13','Executive',17000,NULL,200,90),
 (100,'Steven','Whalen','steven.whalen@demo','515.123.4800',CURRENT_DATE,'Administration',4400,NULL,200,20),
 (101,'Neena','Fay','neena.fay@demo','515.123.4801',CURRENT_DATE,'Marketing',6000,NULL,200,20),
 (102,'Lex','Hartstein','lex.hartstein@demo','515.123.4802',CURRENT_DATE,'Marketing',13000,NULL,200,20),
 (103,'Alexander','Ernst','alex.ernst@demo','515.123.4803',CURRENT_DATE,'IT',6000,NULL,201,60),
 (104,'Bruce','Hunold','bruce.hunold@demo','515.123.4804',CURRENT_DATE,'IT',9000,NULL,103,60),
 (105,'David','Lorentz','d.lorentz@demo','515.123.4805',CURRENT_DATE,'IT',4200,NULL,103,60),
 (106,'Valli','Higgins','valli.higgins@demo','515.123.4806',CURRENT_DATE,'Accounting',12000,NULL,200,110),
 (107,'Diana','Zlotkey','diana.zlotkey@demo','515.123.4807',CURRENT_DATE,'Sales',10500,NULL,200,50);

-- 6) CTAS de trabajo (copias)
CREATE TABLE pf3_lab.pf3_emp  AS SELECT * FROM pf3_lab.pf3_staff;
CREATE TABLE pf3_lab.pf3_dept AS SELECT * FROM pf3_lab.pf3_depts;

-- 7) PK en copias
ALTER TABLE pf3_lab.pf3_emp  ADD CONSTRAINT pf3_emp_pk  PRIMARY KEY (emp_id);
ALTER TABLE pf3_lab.pf3_dept ADD CONSTRAINT pf3_dept_pk PRIMARY KEY (dept_id);

-- 8) FK con ON DELETE CASCADE
ALTER TABLE pf3_lab.pf3_emp
  ADD CONSTRAINT pf3_emp_dept_fk FOREIGN KEY (dept_id)
  REFERENCES pf3_lab.pf3_dept(dept_id) ON DELETE CASCADE;

-- 9) TRANSACCIÓN + SAVEPOINT (demo)
BEGIN;
UPDATE pf3_lab.pf3_dept SET dept_name = dept_name || ' *' WHERE dept_id = 90;
SAVEPOINT sv1;
INSERT INTO pf3_lab.pf3_emp(emp_id,first_name,last_name,email,hire_date,job_title,salary,dept_id)
VALUES (999,'Temp','Row','tmp@demo',CURRENT_DATE,'IT Intern',1200,60);
-- fallo intencional (sin WHERE)
UPDATE pf3_lab.pf3_emp SET dept_id = 140;
ROLLBACK TO SAVEPOINT sv1;
COMMIT;

-- 10) REGEX + CHECK
SELECT first_name,last_name
FROM pf3_lab.pf3_staff
WHERE first_name ~* '^ste(v|ph)en$';

SELECT last_name,
       regexp_replace(last_name,'^H(a|e|i|o|u)','**') AS name_changed
FROM pf3_lab.pf3_staff;

ALTER TABLE pf3_lab.pf3_staff
  ADD COLUMN email2 TEXT,
  ADD CONSTRAINT pf3_email2_chk CHECK (email2 IS NULL OR email2 ~ '.+@.+\..+');

-- 11) VISTAS
CREATE OR REPLACE VIEW pf3_lab.pf3_v2 AS
SELECT d.dept_name AS department_name,
       MIN(s.salary) AS lowest_salary,
       MAX(s.salary) AS highest_salary,
       AVG(s.salary)::numeric(10,2) AS average_salary
FROM pf3_lab.pf3_staff s
JOIN pf3_lab.pf3_depts d ON d.dept_id = s.dept_id
GROUP BY d.dept_name;

CREATE OR REPLACE VIEW pf3_lab.pf3_dept_managers_view AS
SELECT d.dept_name AS dept_name,
       (LEFT(m.first_name,1) || '.' || m.last_name) AS mgr_name
FROM pf3_lab.pf3_depts d
JOIN LATERAL (
  SELECT s.manager_id
  FROM pf3_lab.pf3_staff s
  WHERE s.dept_id = d.dept_id
  ORDER BY s.emp_id
  LIMIT 1
) x ON TRUE
JOIN pf3_lab.pf3_staff m ON m.emp_id = x.manager_id;

-- bloquear updates a la vista (como en Oracle)
DROP RULE IF EXISTS pf3_dept_mgr_ro ON pf3_lab.pf3_dept_managers_view;
CREATE RULE pf3_dept_mgr_ro AS
  ON UPDATE TO pf3_lab.pf3_dept_managers_view DO INSTEAD NOTHING;

-- 12) SECUENCIA + uso correcto
CREATE SEQUENCE pf3_lab.pf3_ct_seq;
SELECT nextval('pf3_lab.pf3_ct_seq');  -- inicializa
SELECT currval('pf3_lab.pf3_ct_seq');

-- 13) INSERT usando la secuencia
INSERT INTO pf3_lab.pf3_emp
 (emp_id,first_name,last_name,email,phone_number,hire_date,job_title,salary,commission_pct,manager_id,dept_id)
VALUES
 (nextval('pf3_lab.pf3_ct_seq'),'Kaare','Hansen','khansen@demo','4496583212',CURRENT_DATE,'Manager',6500,NULL,100,90);

-- 14) ÍNDICE FUNCIONAL
CREATE INDEX pf3_emp_indx ON pf3_lab.pf3_emp
  (emp_id DESC, UPPER(SUBSTRING(first_name FROM 1 FOR 1) || ' ' || last_name));

-- 15) “DICCIONARIO” equivalente (buscar objetos con 'priv')
SELECT table_schema, table_name
FROM information_schema.tables
WHERE table_schema NOT IN ('pg_catalog','information_schema')
  AND (table_name ILIKE '%priv%' OR table_schema ILIKE '%priv%');

-- 16) GRANT de ejemplo
GRANT SELECT ON pf3_lab.pf3_emp TO PUBLIC;

-- 17) CONSULTAS de unión/join
-- a) todos los emp_id con su dept_name (incluye sin dept)
SELECT e.emp_id, d.dept_name
FROM pf3_lab.pf3_staff e
LEFT JOIN pf3_lab.pf3_depts d ON d.dept_id = e.dept_id
ORDER BY e.emp_id;

-- b) solo el departamento actual del empleado
SELECT e.emp_id, d.dept_name
FROM pf3_lab.pf3_staff e
JOIN pf3_lab.pf3_depts d ON d.dept_id = e.dept_id
ORDER BY e.emp_id;

-- c) apellido, dept, salario y país
SELECT s.last_name, d.dept_name, s.salary, n.nation_name AS country_name
FROM pf3_lab.pf3_staff s
LEFT JOIN pf3_lab.pf3_depts d ON d.dept_id = s.dept_id
LEFT JOIN pf3_lab.pf3_sites  t ON t.site_id = d.site_id
LEFT JOIN pf3_lab.pf3_nations n ON n.nation_id = t.nation_id
ORDER BY s.last_name;

-- 18) REPORTE: salario > promedio del depto
WITH dept_avg AS (
  SELECT dept_id, AVG(salary) AS salavg
  FROM pf3_lab.pf3_staff
  GROUP BY dept_id
)
SELECT s.last_name, s.salary, s.dept_id, da.salavg
FROM pf3_lab.pf3_staff s
JOIN dept_avg da ON da.dept_id = s.dept_id
WHERE s.salary > da.salavg
ORDER BY s.last_name;

-- 19) Revisiones
SELECT * FROM pf3_lab.pf3_v2 ORDER BY department_name;
SELECT * FROM pf3_lab.pf3_dept_managers_view ORDER BY dept_name;

-- 20) PERMISOS FINALES PARA pf3_user
GRANT USAGE ON SCHEMA pf3_lab TO pf3_user;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES    IN SCHEMA pf3_lab TO pf3_user;
GRANT USAGE, SELECT, UPDATE          ON ALL SEQUENCES IN SCHEMA pf3_lab TO pf3_user;
