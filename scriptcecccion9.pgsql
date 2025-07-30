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


SELECT 3 FROM student

