-- 1. Eliminar la tabla si ya existe
DROP TABLE IF EXISTS student;

-- 2. Crear tabla student
CREATE TABLE student (
    student_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    year_in_school INT,  -- año en el centro educativo
    height NUMERIC(5,2)  -- altura en metros
);

-- 3. Insertar datos de ejemplo
INSERT INTO student (first_name, last_name, year_in_school, height) VALUES
('Carlos', 'Funes', 10, 1.70),
('María', 'Palma', 10, 1.65),
('Angie', 'Pineda', 10, 1.72),
('Cleofas', 'Mejía', 11, 1.80),
('Juan', 'Pérez', 11, 1.75),
('Daniela', 'López', 11, 1.68),
('Miguel', 'Ramírez', 12, 1.82),
('Luis', 'Toledo', 12, 1.77),
('Ana', 'Chávez', 12, 1.69),
('Allan', 'Pérez', 12, 1.74);

SELECT AVG(height) AS altura_media
FROM student;

SELECT AVG(height) AS altura_media
FROM student
WHERE year_in_school = 10;

SELECT AVG(height) AS altura_media
FROM student
WHERE year_in_school = 11;

SELECT AVG(height) AS altura_media
FROM student
WHERE year_in_school = 12;

SELECT year_in_school, AVG(height) AS altura_media
FROM student
GROUP BY year_in_school
ORDER BY year_in_school;

SELECT year_in_school, AVG(height) AS altura_promedio
FROM student
GROUP BY year_in_school
ORDER BY year_in_school;

SELECT year_in_school, MAX(height) AS altura_maxima
FROM student
GROUP BY year_in_school
ORDER BY year_in_school;

SELECT year_in_school, last_name, COUNT(*) AS total_alumnos
FROM student
WHERE year_in_school > 10
GROUP BY year_in_school, last_name
ORDER BY year_in_school, last_name;

SELECT MAX(promedio_altura) AS altura_media_mas_alta
FROM (
    SELECT AVG(height) AS promedio_altura
    FROM student
    GROUP BY year_in_school
) AS subconsulta;

SELECT year_in_school, MAX(height) AS altura_maxima
FROM student
GROUP BY year_in_school
HAVING COUNT(*) > 1
ORDER BY year_in_school;

SELECT year_in_school, ROUND(AVG(height), 2) AS promedio_altura
FROM student
GROUP BY year_in_school
HAVING MIN(height) > 1.65
ORDER BY year_in_school;

SELECT year_in_school, MAX(height) AS altura_maxima
FROM student
GROUP BY year_in_school
ORDER BY year_in_school;

SELECT year_in_school, last_name, AVG(height) AS promedio_altura
FROM student
GROUP BY year_in_school, last_name
ORDER BY year_in_school, last_name;

SELECT COUNT(first_name) AS total_alumnos, year_in_school
FROM student
GROUP BY year_in_school
ORDER BY year_in_school;

SELECT COUNT(*) AS total_registros, year_in_school
FROM student
GROUP BY year_in_school
ORDER BY year_in_school;


SELECT year_in_school, MAX(height) AS altura_maxima
FROM student
WHERE last_name != 'Pérez'
GROUP BY year_in_school
ORDER BY year_in_school;

SELECT year_in_school, ROUND(AVG(height), 2) AS altura_promedio
FROM student
GROUP BY year_in_school
ORDER BY year_in_school;

SELECT year_in_school, COUNT(DISTINCT last_name) AS apellidos_distintos
FROM student
GROUP BY year_in_school
ORDER BY year_in_school;

SELECT AVG(height) AS altura_promedio
FROM student;

SELECT AVG(height) AS altura_promedio
FROM student
WHERE year_in_school = 10;

SELECT AVG(height) AS altura_promedio
FROM student
WHERE year_in_school = 11;

SELECT AVG(height) AS altura_promedio
FROM student
WHERE year_in_school = 12;

SELECT year_in_school, last_name, SUM(height) AS suma_alturas
FROM student
WHERE year_in_school < 12
GROUP BY ROLLUP (year_in_school, last_name);

SELECT year_in_school, last_name, SUM(height) AS suma_alturas
FROM student
WHERE year_in_school < 12
GROUP BY (year_in_school, last_name);

SELECT year_in_school, last_name, SUM(height) AS suma_alturas
FROM student
WHERE year_in_school < 12
GROUP BY CUBE (year_in_school, last_name);

SELECT year_in_school, last_name, first_name, SUM(height) AS suma_alturas
FROM student
WHERE year_in_school < 12
GROUP BY GROUPING SETS ((last_name, first_name),(year_in_school, last_name),(year_in_school, first_name));

SELECT year_in_school, last_name, SUM(height) AS suma_alturas,
       GROUPING(year_in_school) AS "Año subtotal",
       GROUPING(last_name) AS "Apellido subtotal"
FROM student
WHERE year_in_school < 12
GROUP BY CUBE (year_in_school, last_name);

-- 1. Eliminar si existen
DROP TABLE IF EXISTS tabla_a;
DROP TABLE IF EXISTS tabla_b;
DROP TABLE IF EXISTS job_history;

-- 2. Crear tabla A
CREATE TABLE tabla_a (
    a_id INT
);

-- 3. Crear tabla B
CREATE TABLE tabla_b (
    b_id INT
);

-- 4. Insertar datos de ejemplo
INSERT INTO tabla_a (a_id) VALUES
(1),(2),(3),(4),(5);

INSERT INTO tabla_b (b_id) VALUES
(4),(5),(6),(7),(8);

-- 5. Crear tabla job_history (simplificada)
CREATE TABLE job_history (
    employee_id INT,
    job_id VARCHAR(20),
    start_date DATE,
    end_date DATE,
    department_id INT
);

INSERT INTO job_history (employee_id, job_id, start_date, end_date, department_id) VALUES
(101, 'AC_ACCOUNT', '2020-01-01', '2021-01-01', 10),
(102, 'AD_VP', '2021-02-01', '2022-02-01', 20),
(103, 'IT_PROG', '2020-06-15', '2021-06-15', 30);

SELECT a_id AS id FROM tabla_a
UNION
SELECT b_id FROM tabla_b;

SELECT a_id AS id FROM tabla_a
UNION ALL
SELECT b_id FROM tabla_b;

SELECT a_id AS id FROM tabla_a
INTERSECT
SELECT b_id FROM tabla_b;

-- A - B
SELECT a_id AS id FROM tabla_a
EXCEPT
SELECT b_id FROM tabla_b;

-- B - A
SELECT b_id AS id FROM tabla_b
EXCEPT
SELECT a_id FROM tabla_a;

SELECT NULL::DATE AS hire_date, employee_id, job_id
FROM job_history
UNION
SELECT CURRENT_DATE AS hire_date, employee_id, job_id
FROM job_history
ORDER BY employee_id;

