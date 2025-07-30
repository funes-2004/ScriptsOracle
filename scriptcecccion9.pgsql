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

