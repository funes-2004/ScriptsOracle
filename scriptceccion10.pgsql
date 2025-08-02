-- 1. Eliminar la tabla si ya existe
DROP TABLE IF EXISTS table_data;

-- 2. Crear tabla con todos los campos necesarios
CREATE TABLE table_data (
    id SERIAL PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    hire_date DATE,
    department_id INT,
    height NUMERIC(5,2) -- Campo agregado para futuras consultas
);

-- 3. Insertar datos de ejemplo
INSERT INTO table_data (first_name, last_name, hire_date, department_id, height) VALUES
('Peter',    'Vargas',  '2000-01-01', 1, 1.75),
('Eleni',    'Zlotkey', '2000-01-29', 1, 1.68),
('Kimberely','Grant',   '1999-05-24', NULL, 1.70), -- departamento nulo
('Kevin',    'Mourgous','1999-11-16', 2, 1.80),
('Diana',    'Lorentz', '1999-02-07', 2, 1.60),
('Carlos',   'Funes',   '2001-03-12', 1, 1.74),
('María',    'Palma',   '2001-07-19', 3, 1.65);

-- ============================================
-- Consultas de las imágenes adaptadas a Postgres
-- ============================================

-- Ejemplo de subconsulta: empleados contratados después de Peter Vargas
SELECT first_name, last_name, hire_date
FROM table_data
WHERE hire_date > (
    SELECT hire_date
    FROM table_data
    WHERE last_name = 'Vargas'
);

-- Subconsulta con valor nulo
SELECT last_name
FROM table_data
WHERE department_id = (
    SELECT department_id
    FROM table_data
    WHERE last_name = 'Grant'
);

-- Caso con valor NULL explícito (similar a ejemplo donde department_id es nulo)
SELECT last_name
FROM table_data
WHERE department_id = (
    SELECT department_id
    FROM table_data
    WHERE last_name = 'Grant'
);

-- Eliminar tablas si existen
DROP TABLE IF EXISTS staff_data;
DROP TABLE IF EXISTS division_data;

-- Crear tabla division_data
CREATE TABLE division_data (
    division_id SERIAL PRIMARY KEY,
    division_name VARCHAR(50),
    region_id INT
);

-- Crear tabla staff_data
CREATE TABLE staff_data (
    staff_id SERIAL PRIMARY KEY,
    surname VARCHAR(50),
    role_code VARCHAR(20),
    income NUMERIC(10,2),
    division_id INT,
    hire_date DATE,
    FOREIGN KEY (division_id) REFERENCES division_data(division_id)
);

-- Insertar datos en division_data
INSERT INTO division_data (division_name, region_id) VALUES
('Marketing', 1000),
('IT', 1500),
('Finance', 1500);

-- Insertar datos en staff_data
INSERT INTO staff_data (surname, role_code, income, division_id, hire_date) VALUES
('Hartstein', 'MK_MAN', 13000, 1, '2000-01-01'),
('Fay', 'MK_REP', 6000, 1, '2001-02-15'),
('Raj', 'ST_CLERK', 3500, 2, '2002-03-10'),
('Davies', 'ST_CLERK', 3100, 2, '2002-04-12'),
('Matos', 'ST_CLERK', 2600, 2, '2002-05-18'),
('Vargas', 'ST_CLERK', 2500, 2, '2002-06-25'),
('Whalen', 'AD_ASST', 4400, 3, '1999-11-10'),
('Gietz', 'AC_ACCOUNT', 8300, 3, '1998-10-10'),
('Taylor', 'AC_MGR', 8600, 3, '1997-09-05'),
('Grant', 'SA_REP', 7000, 3, '2003-08-20'),
('Mourgous', 'IT_PROG', 5800, 3, '2001-12-01'),
('Ernst', 'HR_REP', 6000, 3, '2001-06-30'),
('Lorentz', 'PU_CLERK', 4200, 3, '1999-07-19'),
('Fay', 'HR_REP', 6000, 3, '2001-01-01');

SELECT surname, role_code, division_id
FROM staff_data
WHERE division_id = (
    SELECT division_id
    FROM division_data
    WHERE division_name = 'Marketing'
)
ORDER BY role_code;

-- 1. ¿Quién trabaja en la división "Marketing"?
SELECT surname, role_code, division_id
FROM staff_data
WHERE division_id IN (
    SELECT division_id
    FROM division_data
    WHERE division_name = 'Marketing'
)
ORDER BY role_code;

-- 2. Empleados con el mismo rol que staff_id = 1 y en divisiones de region_id = 1500
SELECT surname, role_code, income, division_id
FROM staff_data
WHERE role_code = (
    SELECT role_code
    FROM staff_data
    WHERE staff_id = 1
    LIMIT 1        -- Garantiza un único valor
)
AND division_id IN (
    SELECT division_id
    FROM division_data
    WHERE region_id = 1500
);


-- 1. Eliminar tablas si ya existen
DROP TABLE IF EXISTS staff_data;
DROP TABLE IF EXISTS area_data;

-- 2. Crear tabla de áreas
CREATE TABLE area_data (
    area_id SERIAL PRIMARY KEY,
    area_name VARCHAR(50),
    region_id INT
);

-- 3. Crear tabla de personal
CREATE TABLE staff_data (
    staff_id SERIAL PRIMARY KEY,
    surname VARCHAR(50),
    role_code VARCHAR(20),
    income INT,
    area_id INT,
    hire_date DATE,
    manager_id INT
);

-- 4. Insertar datos de ejemplo
INSERT INTO area_data (area_name, region_id) VALUES
('Marketing', 1500),
('IT', 1600),
('HR', 1700);

INSERT INTO staff_data (surname, role_code, income, area_id, hire_date, manager_id) VALUES
('Hartstein', 'MK_MAN', 13000, 1, '2000-01-01', NULL),
('Fay', 'MK_REP', 6000, 1, '2001-02-01', NULL),
('Raj', 'ST_CLERK', 3500, 2, '2002-03-15', 100),
('Davies', 'ST_CLERK', 3100, 2, '2003-04-20', 101),
('Matos', 'ST_CLERK', 2600, 2, '2003-05-25', NULL),
('Vargas', 'ST_CLERK', 2500, 2, '2003-06-30', 102),
('Grant', 'SA_REP', 7000, 3, '2003-08-20', NULL),
('Mourgous', 'IT_PROG', 5800, 3, '2001-12-01', 101),
('Ernst', 'HR_REP', 6000, 3, '2001-06-30', 205),
('Lorentz', 'PU_CLERK', 4200, 3, '1999-07-19', 100),
('Fay', 'HR_REP', 6000, 3, '2001-01-01', NULL);

-- 5. Consultas de ejemplo

-- ¿Quién trabaja en el área de marketing?
SELECT surname, role_code, area_id
FROM staff_data
WHERE area_id = (
    SELECT area_id
    FROM area_data
    WHERE area_name = 'Marketing'
)
ORDER BY role_code;

-- Más de una subconsulta
SELECT surname, role_code, income, area_id
FROM staff_data
WHERE role_code = (
    SELECT role_code
    FROM staff_data
    WHERE staff_id = 1
)
AND area_id = (
    SELECT area_id
    FROM area_data
    WHERE region_id = 1500
);

-- Salarios inferiores a la media
SELECT surname, income
FROM staff_data
WHERE income < (
    SELECT AVG(income)
    FROM staff_data
);

-- Áreas con salario mínimo mayor al salario mínimo del área 2
SELECT area_id, MIN(income)
FROM staff_data
GROUP BY area_id
HAVING MIN(income) > (
    SELECT MIN(income)
    FROM staff_data
    WHERE area_id = 2
);

-- ==========================================
-- 1. Eliminar tablas si existen
-- ==========================================
DROP TABLE IF EXISTS staff_info;
DROP TABLE IF EXISTS dept_info;

-- ==========================================
-- 2. Crear tablas
-- ==========================================
CREATE TABLE dept_info (
    dept_id SERIAL PRIMARY KEY,
    dept_name VARCHAR(50),
    region_id INT
);

CREATE TABLE staff_info (
    staff_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    job_code VARCHAR(20),
    manager_id INT,
    dept_id INT,
    salary NUMERIC(10,2),
    hire_date DATE,
    FOREIGN KEY (dept_id) REFERENCES dept_info(dept_id)
);

-- ==========================================
-- 3. Insertar datos de ejemplo
-- ==========================================
INSERT INTO dept_info (dept_name, region_id) VALUES
('Marketing', 1500),
('IT', 1200),
('HR', 1100);

INSERT INTO staff_info (first_name, last_name, job_code, manager_id, dept_id, salary, hire_date) VALUES
('Alexander', 'Hunold', 'IT_PROG', 100, 2, 4400, '1987-06-17'),
('Bruce', 'Ernst', 'IT_PROG', 100, 2, 13000, '1990-01-03'),
('Diana', 'Lorentz', 'IT_PROG', 149, 2, 6000, '1991-09-21'),
('Grant', 'Taylor', 'SA_REP', 149, 1, 7000, '1989-09-21'),
('Kimberely', 'Grant', 'HR_REP', 100, 3, 6000, '1993-09-13'),
('Mourgos', 'Rajs', 'SA_REP', 101, 1, 3500, '1991-05-21'),
('Ernst', 'Davies', 'ST_CLERK', 205, 2, 3100, '1990-09-21');

-- ==========================================
-- 4. CONSULTAS
-- ==========================================

-- 4.1 GROUP BY con HAVING y ANY
SELECT dept_id, MIN(salary)
FROM staff_info
GROUP BY dept_id
HAVING MIN(salary) < ANY (
    SELECT salary
    FROM staff_info
    WHERE dept_id IN (1, 2)
)
ORDER BY dept_id;

-- 4.2 Subconsultas de varias columnas (pareadas)
SELECT staff_id, manager_id, dept_id
FROM staff_info
WHERE (manager_id, dept_id) IN (
    SELECT manager_id, dept_id
    FROM staff_info
    WHERE staff_id IN (2, 3)
)
AND staff_id NOT IN (2, 3);

-- 4.3 Subconsultas de varias columnas (separadas)
SELECT staff_id, manager_id, dept_id
FROM staff_info
WHERE manager_id IN (
        SELECT manager_id FROM staff_info WHERE staff_id IN (2, 3)
      )
  AND dept_id IN (
        SELECT dept_id FROM staff_info WHERE staff_id IN (2, 3)
      )
  AND staff_id NOT IN (2, 3);

-- 4.4 Subconsulta usando IN
SELECT first_name, last_name, job_code
FROM staff_info
WHERE job_code IN (
    SELECT job_code
    FROM staff_info
    WHERE last_name = 'Ernst'
);


-- =========================
-- 1. CREAR TABLA staff_data
-- =========================
DROP TABLE IF EXISTS staff_data;

CREATE TABLE staff_data (
    id_worker SERIAL PRIMARY KEY,
    surname VARCHAR(50) NOT NULL,
    role_code VARCHAR(10) NOT NULL,
    income NUMERIC(10,2) NOT NULL,
    division_id INT NOT NULL,
    boss_id INT NULL,
    hire_date DATE NOT NULL
);

-- =========================
-- 2. INSERTAR DATOS DE EJEMPLO
-- (sin apellidos repetidos)
-- =========================
INSERT INTO staff_data (surname, role_code, income, division_id, boss_id, hire_date) VALUES
('Ramirez',  'SA_REP', 7000, 1, NULL, '2019-05-20'),
('Gutierrez','IT_PROG',5800, 1, 1,    '2020-01-10'),
('Santos',   'HR_REP', 6000, 2, NULL, '2021-07-12'),
('Lopez',    'PU_CLERK',4200,2, 3,    '2022-03-25'),
('Vasquez',  'MK_MAN', 9000, 3, NULL, '2021-02-14'),
('Perez',    'MK_REP', 5000, 3, 5,    '2023-11-01'),
('Rojas',    'FI_ANAL',8200, 4, NULL, '2020-04-18'),
('Mendoza',  'FI_CLERK',3000,4, 7,    '2022-10-30');

-- =========================
-- 3. CONSULTAS AVANZADAS
-- =========================

-- 3.1 Salarios mayores al promedio de su división (subconsulta correlacionada)
SELECT s.surname, s.income, s.division_id
FROM staff_data s
WHERE s.income >
    (SELECT AVG(x.income)
     FROM staff_data x
     WHERE x.division_id = s.division_id);

-- 3.2 GROUP BY y HAVING con ANY
SELECT division_id, MIN(income)
FROM staff_data
GROUP BY division_id
HAVING MIN(income) < ANY (
    SELECT income
    FROM staff_data
    WHERE division_id IN (1, 2)
)
ORDER BY division_id;

-- 3.3 Subconsulta de varias columnas (comparaciones pareadas)
SELECT id_worker, boss_id, division_id
FROM staff_data
WHERE (boss_id, division_id) IN (
    SELECT boss_id, division_id
    FROM staff_data
    WHERE id_worker IN (1, 3)
)
AND id_worker NOT IN (1, 3);

-- 3.4 Subconsulta de varias columnas no pareadas
SELECT id_worker, boss_id, division_id
FROM staff_data
WHERE boss_id IN (
    SELECT boss_id FROM staff_data WHERE id_worker IN (1, 3)
)
AND division_id IN (
    SELECT division_id FROM staff_data WHERE id_worker IN (1, 3)
)
AND id_worker NOT IN (1, 3);

-- 3.5 EXISTS (trabajadores que no son jefes)
SELECT surname AS "No es Jefe"
FROM staff_data w
WHERE NOT EXISTS (
    SELECT 1
    FROM staff_data b
    WHERE b.boss_id = w.id_worker
);

-- 3.6 NOT IN (muestra posible error con NULL)
SELECT surname AS "No es Jefe"
FROM staff_data w
WHERE w.id_worker NOT IN (
    SELECT boss_id FROM staff_data
);

-- 3.7 Cláusula WITH (optimiza la búsqueda de jefes)
WITH only_bosses AS (
    SELECT DISTINCT boss_id
    FROM staff_data
    WHERE boss_id IS NOT NULL
)
SELECT surname AS "No es Jefe"
FROM staff_data
WHERE id_worker NOT IN (SELECT boss_id FROM only_bosses);



