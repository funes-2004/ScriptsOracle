-- Crear nueva tabla para registrar el uso de secuencias
CREATE TABLE sequence_audit_log (
    id SERIAL PRIMARY KEY,
    sequence_name TEXT NOT NULL,
    min_value BIGINT,
    max_value BIGINT,
    increment_by INT,
    last_value BIGINT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Consulta de información de secuencias (equivalente a user_sequences de Oracle)
SELECT 
    schemaname AS sequence_schema,
    sequencename AS sequence_name,
    start_value,
    increment_by,
    min_value,
    max_value,
    cycle,
    cache_size,
    last_value
FROM pg_sequences
WHERE sequencename = 'runner_id_seq';


-- Registrar en la tabla los datos de la secuencia creada
INSERT INTO sequence_audit_log (sequence_name, min_value, max_value, increment_by, last_value)
SELECT 
    sequencename,
    min_value,
    max_value,
    increment_by,
    last_value
FROM pg_sequences
WHERE sequencename = 'runner_id_seq';

-- 1. Crear una nueva tabla (no está en tu lista)
CREATE TABLE race_runners (
    runner_id INTEGER PRIMARY KEY,
    first_name VARCHAR(30),
    last_name VARCHAR(30)
);

-- 2. Crear una secuencia (funcional en PostgreSQL)
CREATE SEQUENCE runner_id_seq
    INCREMENT BY 1
    START WITH 1
    MAXVALUE 50000
    NO CYCLE
    NO CACHE;

-- 3. Insertar datos usando la secuencia
INSERT INTO race_runners (runner_id, first_name, last_name)
VALUES (NEXTVAL('runner_id_seq'), 'Joanne', 'Everely');

INSERT INTO race_runners (runner_id, first_name, last_name)
VALUES (NEXTVAL('runner_id_seq'), 'Adam', 'Curtis');

-- 4. Consultar la tabla
SELECT runner_id, first_name, last_name
FROM race_runners;

-- 5. Consultar información de la secuencia (equivalente a USER_SEQUENCES en Oracle)
SELECT 
    sequencename AS sequence_name,
    min_value,
    max_value,
    last_value AS "Next number"
FROM pg_sequences
WHERE sequencename = 'runner_id_seq';

-- 6. Modificar la secuencia (ALTER SEQUENCE como en Oracle)
ALTER SEQUENCE runner_id_seq
    INCREMENT BY 1
    MAXVALUE 999999
    NO CACHE
    NO CYCLE;

-- 7. Crear tabla ejemplo para múltiples secuencias
CREATE TABLE employee_log (
    employee_id INTEGER,
    department_id INTEGER,
    description TEXT
);

-- 8. Crear secuencias auxiliares
CREATE SEQUENCE employees_seq START 1000;
CREATE SEQUENCE dept_deptid_seq START 500;

-- Generar valores iniciales para poder usar CURRVAL
SELECT NEXTVAL('dept_deptid_seq'); -- Necesario antes de usar CURRVAL

-- 9. Insertar usando NEXTVAL y CURRVAL
INSERT INTO employee_log (employee_id, department_id, description)
VALUES (
    NEXTVAL('employees_seq'),
    CURRVAL('dept_deptid_seq'),
    'Nuevo empleado insertado desde ejemplo'
);

-- 10. Verificar contenido
SELECT * FROM employee_log;



-- ================================
-- 1. LIMPIEZA PREVIA (opcional para reiniciar)
-- ================================
DROP TABLE IF EXISTS country_demo;
DROP INDEX IF EXISTS idx_country_region;
DROP INDEX IF EXISTS idx_country_name_capitol;
DROP INDEX IF EXISTS idx_upper_country_name;
DROP INDEX IF EXISTS idx_hire_year;

-- ================================
-- 2. CREAR TABLA DE EJEMPLO (No está en tu lista)
-- ================================
CREATE TABLE country_demo (
    country_id INTEGER PRIMARY KEY,
    country_name VARCHAR(100),
    capitol VARCHAR(100),
    region_id INTEGER
);

-- ================================
-- 3. INSERTAR DATOS DE EJEMPLO
-- ================================
INSERT INTO country_demo (country_id, country_name, capitol, region_id) VALUES
(1, 'United States of America', 'Washington, DC', 21),
(2, 'Canada', 'Ottawa', 21),
(3, 'Republic of Kazakhstan', 'Astana', 143),
(7, 'Russian Federation', 'Moscow', 151),
(12, 'Coral Sea Islands Territory', NULL, 9),
(13, 'Cook Islands', 'Avarua', 9),
(15, 'Europa Island', NULL, 18),
(20, 'Arab Republic of Egypt', 'Cairo', 15);

-- ================================
-- 4. CREAR ÍNDICE SIMPLE (region_id)
-- ================================
CREATE INDEX idx_country_region
ON country_demo(region_id);

-- ================================
-- 5. CREAR ÍNDICE COMPUESTO (country_name + capitol)
-- ================================
CREATE INDEX idx_country_name_capitol
ON country_demo(country_name, capitol);

-- ================================
-- 6. CONSULTAR INFORMACIÓN DE ÍNDICES (equivalente a user_indexes en Oracle)
-- ================================
SELECT
    tablename AS table_name,
    indexname AS index_name,
    indexdef AS definition
FROM pg_indexes
WHERE tablename = 'country_demo';

-- ================================
-- 7. CREAR ÍNDICE BASADO EN FUNCIÓN (UPPER(country_name))
-- ================================
CREATE INDEX idx_upper_country_name
ON country_demo (UPPER(country_name));

-- Consulta usando el índice
SELECT *
FROM country_demo
WHERE UPPER(country_name) = 'CANADA';

-- ================================
-- 8. CREAR TABLA DE EMPLEADOS PARA EJEMPLO DE FECHA
-- ================================
DROP TABLE IF EXISTS employee_demo;
CREATE TABLE employee_demo (
    employee_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    hire_date DATE
);

-- Insertar datos
INSERT INTO employee_demo (first_name, last_name, hire_date) VALUES
('Steven', 'King', '1987-06-17'),
('Jennifer', 'Whalen', '1987-09-17'),
('Luis', 'Gomez', '1990-05-10');

-- ================================
-- 9. CREAR ÍNDICE BASADO EN EXTRACT(YEAR)
-- ================================
CREATE INDEX idx_hire_year
ON employee_demo (EXTRACT(YEAR FROM hire_date));

-- Consulta usando el índice
SELECT first_name, last_name, hire_date
FROM employee_demo
WHERE EXTRACT(YEAR FROM hire_date) = 1987;





