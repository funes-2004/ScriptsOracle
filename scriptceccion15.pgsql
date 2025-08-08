-- ELIMINAR TABLAS SI EXISTEN
DROP VIEW IF EXISTS view_employees;
DROP VIEW IF EXISTS view_euro_countries;
DROP VIEW IF EXISTS view_high_pop;
DROP TABLE IF EXISTS employees CASCADE;
DROP TABLE IF EXISTS wf_countries CASCADE;
DROP TABLE IF EXISTS wf_world_regions CASCADE;

-- CREAR TABLAS CORRECTAS
CREATE TABLE employees (
    employee_id INT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100)
);

CREATE TABLE wf_countries (
    country_id INT PRIMARY KEY,
    region_id INT,
    country_name VARCHAR(100),
    capitol VARCHAR(100),
    location VARCHAR(100),
    population BIGINT
);

CREATE TABLE wf_world_regions (
    region_id INT PRIMARY KEY,
    region_name VARCHAR(100)
);

-- DATOS DE EJEMPLO
INSERT INTO employees (employee_id, first_name, last_name, email) VALUES
(100, 'Steven', 'King', 'SKING'),
(101, 'Neena', 'Kochhar', 'NKOCHHAR'),
(102, 'Lex', 'De Haan', 'LDEHAAN'),
(103, 'Alexander', 'Hunold', 'AHUNOLD'),
(104, 'Bruce', 'Ernst', 'BERNST'),
(107, 'Diana', 'Lorentz', 'DLORENTZ');

INSERT INTO wf_countries (country_id, region_id, country_name, capitol, location, population) VALUES
(22, 155, 'Bailiwick of Guernsey', 'Saint Peter Port', 'Europe West', 188078227),
(203, 155, 'Bailiwick of Jersey', 'Saint Helier', 'Europe West', 20264082),
(387, 39, 'Bosnia and Herzegovina', 'Sarajevo', 'Europe East', 131859731),
(420, 151, 'Czech Republic', 'Prague', 'Europe Central', 107449525),
(298, 154, 'Faroe Islands', 'Torshavn', 'Europe North', 74777981),
(33, 155, 'French Republic', 'Paris', 'Europe West', 298444215);

INSERT INTO wf_world_regions (region_id, region_name) VALUES
(151, 'Europe Central'),
(154, 'Europe East'),
(155, 'Europe West');

-- CREAR VISTAS
CREATE OR REPLACE VIEW view_employees AS
SELECT employee_id, first_name, last_name, email
FROM employees
WHERE employee_id BETWEEN 100 AND 124;

CREATE OR REPLACE VIEW view_euro_countries AS
SELECT 
    c.country_id AS "ID",
    c.country_name AS "Country",
    c.capitol AS "Capitol City",
    r.region_name AS "Region"
FROM wf_countries c
JOIN wf_world_regions r USING (region_id)
WHERE location ILIKE '%Europe%';

CREATE OR REPLACE VIEW view_high_pop AS
SELECT 
    region_id AS "Region ID",
    MAX(population) AS "Highest population"
FROM wf_countries
GROUP BY region_id;

-- CONSULTAS DE PRUEBA
SELECT * FROM view_employees;
SELECT * FROM view_euro_countries;
SELECT * FROM view_high_pop;





-- ==============================
-- 1. LIMPIEZA DE OBJETOS ANTERIORES
-- ==============================
DROP VIEW IF EXISTS view_dept50 CASCADE;
DROP VIEW IF EXISTS view_dept50_check CASCADE;
DROP VIEW IF EXISTS view_dept50_readonly CASCADE;
DROP TABLE IF EXISTS copy_employees CASCADE;

-- ==============================
-- 2. CREACIÓN DE TABLA COPY_EMPLOYEES
-- ==============================
CREATE TABLE copy_employees (
    department_id INT,
    employee_id INT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    salary NUMERIC(10,2),
    hire_date DATE
);

-- ==============================
-- 3. INSERCIÓN DE DATOS DE EJEMPLO
-- ==============================
INSERT INTO copy_employees (department_id, employee_id, first_name, last_name, salary, hire_date) VALUES
(50, 124, 'Kevin', 'Mourgos', 5800, '2000-06-17'),
(50, 141, 'Trenna', 'Rajs', 3500, '2002-09-17'),
(50, 142, 'Curtis', 'Davies', 3100, '2001-09-21'),
(50, 143, 'Randall', 'Matos', 2600, '2001-01-03'),
(50, 144, 'Peter', 'Vargas', 2500, '2001-05-21'),
(60, 150, 'Sarah', 'Johnson', 4000, '1998-01-10'),
(60, 151, 'Luis', 'Cabrera', 4500, '1997-07-15');

-- ==============================
-- 4. CREACIÓN DE VISTAS
-- ==============================

-- Vista simple para departamento 50
CREATE OR REPLACE VIEW view_dept50 AS
SELECT department_id, employee_id, first_name, last_name, salary
FROM copy_employees
WHERE department_id = 50;

-- Vista con "CHECK OPTION" (PostgreSQL no soporta nativo el WITH CHECK OPTION como Oracle)
-- Para simular la restricción usamos regla en la vista
CREATE OR REPLACE VIEW view_dept50_check AS
SELECT department_id, employee_id, first_name, last_name, salary
FROM copy_employees
WHERE department_id = 50;

-- Regla para evitar cambios fuera de dept_id = 50
CREATE OR REPLACE RULE view_dept50_check_update AS
ON UPDATE TO view_dept50_check
WHERE NEW.department_id <> 50
DO INSTEAD NOTHING;

-- Vista de solo lectura (PostgreSQL simula READ ONLY con reglas INSTEAD NOTHING)
CREATE OR REPLACE VIEW view_dept50_readonly AS
SELECT department_id, employee_id, first_name, last_name, salary
FROM copy_employees
WHERE department_id = 50;

CREATE OR REPLACE RULE view_dept50_readonly_insert AS
ON INSERT TO view_dept50_readonly DO INSTEAD NOTHING;
CREATE OR REPLACE RULE view_dept50_readonly_update AS
ON UPDATE TO view_dept50_readonly DO INSTEAD NOTHING;
CREATE OR REPLACE RULE view_dept50_readonly_delete AS
ON DELETE TO view_dept50_readonly DO INSTEAD NOTHING;

-- ==============================
-- 5. VISTAS EN LÍNEA
-- ==============================
-- Últimos salarios máximos por departamento
CREATE OR REPLACE VIEW view_max_salary AS
SELECT e.last_name, e.salary, e.department_id, d.maxsal
FROM copy_employees e
JOIN (
    SELECT department_id, MAX(salary) AS maxsal
    FROM copy_employees
    GROUP BY department_id
) d ON e.department_id = d.department_id
AND e.salary = d.maxsal;

-- ==============================
-- 6. ANÁLISIS DE N PRINCIPALES (TOP N)
-- ==============================
-- PostgreSQL usa LIMIT en lugar de ROWNUM
-- Empleados con más antigüedad (5 primeros)
CREATE OR REPLACE VIEW view_top5_longest_employed AS
SELECT last_name, hire_date
FROM copy_employees
ORDER BY hire_date ASC
LIMIT 5;

-- ==============================
-- 7. CONSULTAS DE PRUEBA
-- ==============================
-- Vista básica dept50
SELECT * FROM view_dept50;

-- Vista con "restricción" CHECK simulada
SELECT * FROM view_dept50_check;



-- Vista de solo lectura (NO permite cambios)
SELECT * FROM view_dept50_readonly;

-- Vista con salarios máximos
SELECT * FROM view_max_salary;

-- Top 5 empleados por antigüedad
SELECT * FROM view_top5_longest_employed;
