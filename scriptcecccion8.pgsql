-- 1. Eliminar tabla si existe
DROP TABLE IF EXISTS transacciones;

-- 2. Crear tabla
CREATE TABLE transacciones (
    transaccion_id SERIAL PRIMARY KEY,
    empleado VARCHAR(50) NOT NULL,
    deposito VARCHAR(20) NOT NULL,
    salario NUMERIC(10,2) NOT NULL,
    fecha DATE NOT NULL,
    monto NUMERIC(10,2) NOT NULL
);

-- 3. Insertar datos (ejemplo de 10+ transacciones)
INSERT INTO transacciones (empleado, deposito, salario, fecha, monto) VALUES
('Carlos Funes', 'DEP-001', 1500.00, '2025-07-01', 1500.00),
('María Palma',  'DEP-002', 1800.00, '2025-07-01', 1800.00),
('Angie Pineda', 'DEP-003', 1200.00, '2025-07-01', 1200.00),
('Cleofas Mejía','DEP-004', 2500.00, '2025-07-01', 2500.00),
('Juan Pérez',   'DEP-005', 1000.00, '2025-07-01', 1000.00),
('Carlos Funes', 'DEP-006', 1500.00, '2025-07-15', 500.00),   -- bono
('María Palma',  'DEP-007', 1800.00, '2025-07-15', 700.00),   -- bono
('Angie Pineda', 'DEP-008', 1200.00, '2025-07-20', 300.00),   -- extra
('Cleofas Mejía','DEP-009', 2500.00, '2025-07-25', 1000.00),  -- extra
('Juan Pérez',   'DEP-010', 1000.00, '2025-07-25', 200.00),   -- extra
('Carlos Funes', 'DEP-011', 1500.00, '2025-07-28', 1500.00),
('María Palma',  'DEP-012', 1800.00, '2025-07-28', 1800.00);

-- 4. Ver datos
SELECT * FROM transacciones;

SELECT MAX(salario)
FROM transacciones;

SELECT empleado,
       SUM(monto) AS total_depositado,
       MAX(monto) AS deposito_mas_alto
FROM transacciones
WHERE fecha >= '2025-07-01'
GROUP BY empleado;

SELECT empleado, salario
FROM transacciones
WHERE salario = (SELECT MIN(salario) FROM transacciones);

-- Salario más bajo
SELECT MIN(salario) AS "Salario más bajo"
FROM transacciones;

-- Nombre del empleado con orden alfabético más bajo (A-Z)
SELECT MIN(empleado) AS "Primer empleado alfabético"
FROM transacciones;

-- Fecha más antigua de transacción
SELECT MIN(fecha) AS "Primera transacción"
FROM transacciones;

-- Salario más alto
SELECT MAX(salario) AS "Salario más alto"
FROM transacciones;

-- Nombre del empleado con orden alfabético más alto (Z-A)
SELECT MAX(empleado) AS "Último empleado alfabético"
FROM transacciones;

-- Fecha más reciente de transacción
SELECT MAX(fecha) AS "Última transacción"
FROM transacciones;

-- Suma de todos los salarios registrados
SELECT SUM(salario) AS "Suma de salarios"
FROM transacciones;

-- Suma de montos depositados en una fecha específica
SELECT SUM(monto) AS "Suma de depósitos 25-Jul-2025"
FROM transacciones
WHERE fecha = '2025-07-25';

SELECT 
    MAX(salario) AS max_salario,
    MIN(salario) AS min_salario,
    MIN(transaccion_id) AS id_mas_bajo
FROM transacciones
WHERE fecha = '2025-07-25';

 
-- 1. Eliminar tabla si ya existe
DROP TABLE IF EXISTS souser;

-- 2. Crear tabla souser con campos de ejemplo
CREATE TABLE souser (
    employee_id SERIAL PRIMARY KEY,       -- Identificador único
    first_name VARCHAR(50),               -- Nombre
    last_name VARCHAR(50) NOT NULL,       -- Apellido
    job_id VARCHAR(10) NOT NULL,          -- ID del trabajo
    salary NUMERIC(10,2) NOT NULL,        -- Salario
    commission_pct NUMERIC(4,2),          -- Comisión
    department_id INT NOT NULL            -- Departamento
);

-- 3. Insertar datos de ejemplo
INSERT INTO souser (first_name, last_name, job_id, salary, commission_pct, department_id) VALUES
('Carlos',   'Funes',    'IT_PROG',  4500.00, 0.10, 60),
('María',    'Palma',    'SA_REP',   6000.00, 0.15, 80),
('Angie',    'Pineda',   'AD_VP',    9000.00, 0.20, 90),
('Cleofas',  'Mejía',    'FI_ACCOUNT', 5000.00, 0.12, 100),
('Juan',     'Pérez',    'SA_REP',   5800.00, NULL, 80),
('Daniela',  'López',    'HR_REP',   4200.00, 0.08, 40),
('Miguel',   'Ramírez',  'IT_PROG',  4700.00, 0.05, 60),
('Luis',     'Toledo',   'SA_MAN',   7500.00, 0.18, 80),
('Ana',      'Chávez',   'ST_CLERK', 3000.00, NULL, 50),
('Allan',    'Pérez',    'PU_CLERK', 3100.00, 0.07, 30);

-- 4. Ver datos
SELECT * FROM souser;

SELECT COUNT(job_id) AS total_trabajos
FROM souser;

SELECT commission_pct
FROM souser;

SELECT COUNT(commission_pct) AS total_comisiones
FROM souser;

ALTER TABLE souser ADD COLUMN fecha_contratacion DATE;

UPDATE souser SET fecha_contratacion = '1995-06-10' WHERE employee_id = 1;
UPDATE souser SET fecha_contratacion = '1997-03-25' WHERE employee_id = 2;
UPDATE souser SET fecha_contratacion = '1994-11-15' WHERE employee_id = 3;
-- ... (puedes asignar fechas según quieras)

SELECT COUNT(*)
FROM souser
WHERE fecha_contratacion < '1996-01-01';

SELECT DISTINCT job_id
FROM souser;

SELECT DISTINCT job_id,
       department_id
FROM souser;

SELECT SUM(salary) AS suma_salarios_depto_90
FROM souser
WHERE department_id = 90;

SELECT COUNT(DISTINCT job_id) AS trabajos_diferentes
FROM souser;

SELECT COUNT(DISTINCT salary) AS salarios_diferentes
FROM souser;

SELECT AVG(commission_pct) AS promedio_comision
FROM souser;

SELECT AVG(COALESCE(commission_pct, 0)) AS promedio_con_ceros
FROM souser;









