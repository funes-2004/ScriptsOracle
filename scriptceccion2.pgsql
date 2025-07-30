SELECT department_id ||
department_name
FROM departments;

SELECT department_id ||' '||department_name
FROM departments;

SELECT department_id ||' '||
department_name AS " Department Info "
FROM departments;

SELECT first_name ||' '||
last_name AS "Employee Name"
FROM employees;

SELECT last_name || ' has a monthly
salary of ' || salary || '
dollars.' AS Pay
FROM employees;

SELECT last_name ||' has a '|| 1 ||' year salary of '||
salary*12 || ' dollars.' AS Pay
FROM employees;

SELECT department_id
FROM employees;

SELECT department_id
FROM employees;

SELECT DISTINCT department_id
FROM employees;



-- ================================
-- ELIMINAR SI EXISTEN
-- ================================
DROP TABLE IF EXISTS staff CASCADE;
DROP TABLE IF EXISTS divisions CASCADE;

-- ================================
-- TABLA DIVISIONS (ANTES DEPARTMENTS)
-- ================================
CREATE TABLE divisions (
    division_id     SERIAL PRIMARY KEY,
    division_name   VARCHAR(100) NOT NULL,
    location        VARCHAR(100)
);

-- ================================
-- TABLA STAFF (ANTES EMPLOYEES)
-- ================================
CREATE TABLE staff (
    staff_id        SERIAL PRIMARY KEY,
    first_name      VARCHAR(50) NOT NULL,
    last_name       VARCHAR(50) NOT NULL,
    email           VARCHAR(100) UNIQUE,
    phone_number    VARCHAR(20),
    hire_date       DATE NOT NULL,
    job_title       VARCHAR(50),
    salary          NUMERIC(10,2),
    commission_pct  NUMERIC(4,2),
    manager_id      INT,
    division_id     INT REFERENCES divisions(division_id),
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ================================
-- DATOS PARA DIVISIONS
-- ================================
INSERT INTO divisions (division_name, location)
VALUES
('Executive', 'New York'),
('IT', 'Seattle'),
('Sales', 'Chicago'),
('HR', 'Toronto');

-- ================================
-- DATOS PARA STAFF
-- ================================
INSERT INTO staff (first_name, last_name, email, phone_number, hire_date, job_title, salary, commission_pct, manager_id, division_id)
VALUES
('Steven', 'King', 'steven.king@example.com', '515.123.4567', '2003-06-17', 'President', 24000, NULL, NULL, 1),
('Neena', 'Kochhar', 'neena.kochhar@example.com', '515.123.4568', '2005-09-21', 'Vice President', 17000, NULL, 1, 1),
('Lex', 'De Haan', 'lex.dehaan@example.com', '515.123.4569', '2001-01-13', 'Vice President', 17000, NULL, 1, 1),
('Alexander', 'Hunold', 'alex.hunold@example.com', '590.423.4567', '2006-01-03', 'Programmer', 9000, NULL, 3, 2),
('Bruce', 'Ernst', 'bruce.ernst@example.com', '590.423.4568', '2007-05-21', 'Programmer', 6000, NULL, 3, 2),
('David', 'Austin', 'david.austin@example.com', '590.423.4569', '2005-06-25', 'Sales Manager', 4800, 0.10, 2, 3),
('Diana', 'Lorentz', 'diana.lorentz@example.com', '590.423.4571', '2007-02-07', 'Sales Representative', 4200, 0.10, 2, 3);

-- ================================
-- CONSULTAS DISTINCT DE EJEMPLO
-- ================================
-- 1. Divisiones únicas de empleados
SELECT DISTINCT division_id
FROM staff;

-- 2. Divisiones y ubicaciones únicas
SELECT DISTINCT division_name, location
FROM divisions;

-- 3. Empleados con salario > 5000 (únicos por nombre)
SELECT DISTINCT first_name, last_name, salary
FROM staff
WHERE salary > 5000;

-- 4. Alias de columna
SELECT DISTINCT division_id AS "ID División"
FROM staff
WHERE salary > 5000;


SELECT staff_id, first_name, last_name
FROM staff;

SELECT staff_id, first_name, last_name
FROM staff
WHERE staff_id = 101;

SELECT staff_id, first_name, last_name FROM staff;

SELECT staff_id, last_name, division_id
FROM staff
WHERE division_id = 90; 

SELECT staff_id, first_name, last_name, hire_date
FROM staff
WHERE hire_date < DATE '2000-01-01';

SELECT staff_id, first_name, last_name, job_title
FROM staff
WHERE job_title = 'IT_PROG';

SELECT staff_id, first_name, last_name, salary
FROM staff
WHERE salary >= 6000;

SELECT staff_id AS "ID",
       first_name AS "Nombre",
       last_name AS "Apellido",
       salary AS "Salario"
FROM staff
WHERE salary >= 6000;

SELECT last_name, salary
FROM staff
WHERE salary <= 3000;


SELECT last_name, salary
FROM staff
WHERE salary BETWEEN 9000 AND 11000;



-- ============================
-- 1) Tabla PLACES (ejemplo IN)
-- ============================
DROP TABLE IF EXISTS places;

CREATE TABLE places (
    city            VARCHAR(100),
    state_province  VARCHAR(100),
    country_id      CHAR(2)
);

INSERT INTO places (city, state_province, country_id)
VALUES
('Toronto', 'Ontario', 'CA'),
('Oxford', 'Oxford', 'UK'),
('Southlake', 'Texas', 'US'),
('Seattle', 'Washington', 'US');

-- Consulta usando IN
SELECT city, state_province, country_id
FROM places
WHERE country_id IN ('UK', 'CA');

-- Consulta equivalente con OR
SELECT city, state_province, country_id
FROM places
WHERE country_id = 'UK' OR country_id = 'CA';

-- ============================
-- 2) Tabla LOCATIONS_SIMPLE (igual ejemplo)
-- ============================
DROP TABLE IF EXISTS locations_simple;

CREATE TABLE locations_simple (
    city            VARCHAR(100),
    state_province  VARCHAR(100),
    country_id      CHAR(2)
);

INSERT INTO locations_simple (city, state_province, country_id)
VALUES
('Toronto', 'Ontario', 'CA'),
('Oxford', 'Oxford', 'UK'),
('Southlake', 'Texas', 'US'),
('Seattle', 'Washington', 'US');

-- Consulta usando IN
SELECT city, state_province, country_id
FROM locations_simple
WHERE country_id IN ('UK', 'CA');

-- Consulta equivalente con OR
SELECT city, state_province, country_id
FROM locations_simple
WHERE country_id = 'UK' OR country_id = 'CA';

-- Consulta usando IN
SELECT city, state_province, country_id
FROM locations_simple
WHERE country_id IN ('UK', 'CA');

-- Consulta equivalente con OR
SELECT city, state_province, country_id
FROM locations_simple
WHERE country_id = 'UK' OR country_id = 'CA';

SELECT last_name, manager_id
FROM staff
WHERE manager_id IS NULL;

SELECT last_name, commission_pct
FROM staff
WHERE commission_pct IS NOT NULL;

SELECT last_name, job_title
FROM staff
WHERE job_title LIKE '%_R%';






