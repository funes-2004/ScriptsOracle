-- Tabla de personal
DROP TABLE IF EXISTS team_members;

CREATE TABLE team_members (
    member_id  SERIAL PRIMARY KEY,
    full_name  VARCHAR(100),
    role_code  VARCHAR(20)
);

-- Tabla de roles
DROP TABLE IF EXISTS roles_catalog;

CREATE TABLE roles_catalog (
    role_code   VARCHAR(20) PRIMARY KEY,
    role_title  VARCHAR(100)
);

-- Insertar datos en roles
INSERT INTO roles_catalog (role_code, role_title) VALUES
('DIR_EXEC', 'Executive Director'),
('DIR_FIN',  'Finance Director'),
('ANL_DATA', 'Data Analyst'),
('MNG_OPS',  'Operations Manager'),
('ACC_PAY',  'Payroll Accountant'),
('SLS_LEAD', 'Sales Lead');

-- Insertar datos en miembros del equipo
INSERT INTO team_members (full_name, role_code) VALUES
('Luis Mendoza',   'DIR_EXEC'),
('Sofía Ramírez',  'DIR_FIN'),
('Pedro Torres',   'ANL_DATA'),
('Lucía Herrera',  'MNG_OPS'),
('Javier Castro',  'ACC_PAY'),
('Gabriela López', 'SLS_LEAD');

SELECT full_name, 
       team_members.role_code, 
       role_title
FROM team_members
NATURAL JOIN roles_catalog
WHERE member_id > 3;


SELECT full_name,
       team_members.role_code,
       role_title
FROM team_members
NATURAL JOIN roles_catalog
WHERE member_id > 3;

SELECT role_title AS department_name,
       full_name   AS city
FROM team_members
NATURAL JOIN roles_catalog;

SELECT full_name,
       role_title AS department_name
FROM team_members
CROSS JOIN roles_catalog;

SELECT full_name,
       team_members.role_code AS department_id,
       role_title             AS department_name
FROM team_members
JOIN roles_catalog USING (role_code);

SELECT full_name,
       team_members.role_code AS department_id,
       role_title             AS department_name
FROM team_members
JOIN roles_catalog USING (role_code)
WHERE full_name LIKE '%Higgins';

SELECT full_name AS last_name,
       role_title AS job_title
FROM team_members e
JOIN roles_catalog j
ON (e.role_code = j.role_code);

SELECT full_name AS last_name,
       role_title AS job_title
FROM team_members e
JOIN roles_catalog j
  ON (e.role_code = j.role_code)
WHERE full_name LIKE 'H%';

DROP TABLE IF EXISTS salary_grades;

CREATE TABLE salary_grades (
    grade_level  VARCHAR(10),
    lowest_sal   NUMERIC(10,2),
    highest_sal  NUMERIC(10,2)
);

-- Insertar rangos de ejemplo
INSERT INTO salary_grades (grade_level, lowest_sal, highest_sal) VALUES
('A', 0,    2999),
('B', 3000, 4999),
('C', 5000, 7999),
('D', 8000, 9999);


SELECT staff_name AS last_name,
       salary,
       CASE
            WHEN salary BETWEEN 0    AND 2999 THEN 'Grade A'
            WHEN salary BETWEEN 3000 AND 4999 THEN 'Grade B'
            WHEN salary BETWEEN 5000 AND 9999 THEN 'Grade C'
            ELSE 'Grade D'
       END AS grade_level,
       0    AS lowest_sal,
       9999 AS highest_sal
FROM company_staff;

-- Tabla de ubicaciones
DROP TABLE IF EXISTS locations;
CREATE TABLE locations (
    location_id  SERIAL PRIMARY KEY,
    city         VARCHAR(50)
);

INSERT INTO locations (city) VALUES
('New York'), ('Chicago'), ('San Francisco');

-- Tabla de departamentos
DROP TABLE IF EXISTS departments;
CREATE TABLE departments (
    department_id   SERIAL PRIMARY KEY,
    department_name VARCHAR(50),
    location_id     INT REFERENCES locations(location_id)
);

INSERT INTO departments (department_name, location_id) VALUES
('Sales', 1), ('IT', 2), ('Finance', 3);

-- Modificar empleados para incluir departamento
ALTER TABLE company_staff ADD COLUMN department_id INT;
UPDATE company_staff SET department_id = 1 WHERE staff_id IN (1, 2);
UPDATE company_staff SET department_id = 2 WHERE staff_id = 3;
UPDATE company_staff SET department_id = 3 WHERE staff_id IN (4, 5);

SELECT staff_name AS last_name,
       department_name AS "Department",
       city
FROM company_staff
JOIN departments USING (department_id)
JOIN locations USING (location_id);

SELECT e.staff_name AS last_name,
       d.department_id,
       d.department_name
FROM company_staff e
LEFT JOIN departments d
  ON e.department_id = d.department_id;

  SELECT e.staff_name AS last_name, d.department_id,
       d.department_name
FROM company_staff e LEFT OUTER JOIN
     departments d
ON (e.department_id = d.department_id);

SELECT e.staff_name AS last_name, d.department_id,
       d.department_name
FROM company_staff e RIGHT OUTER JOIN
     departments d
ON (e.department_id = d.department_id);

SELECT e.staff_name AS last_name, d.department_id, d.department_name
FROM company_staff e FULL OUTER JOIN departments d
ON (e.department_id = d.department_id);


INSERT INTO business_units (unit_name, site_id) VALUES
('Innovation', 1),
('Customer Care', 2),
('Distribution', 3);

-- Crear tabla de productos
CREATE TABLE productos (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    categoria VARCHAR(50) NOT NULL,
    precio DECIMAL(10,2) NOT NULL,
    stock INT NOT NULL,
    fecha_ingreso DATE DEFAULT CURRENT_DATE
);

-- Insertar datos de ejemplo
INSERT INTO productos (nombre, categoria, precio, stock)
VALUES 
('Laptop Lenovo ThinkPad', 'Electrónica', 1200.50, 10),
('Teléfono Samsung Galaxy S22', 'Electrónica', 950.00, 15),
('Audífonos JBL Tune 500', 'Accesorios', 50.99, 40),
('Silla Gamer Cougar Armor One', 'Muebles', 280.75, 5),
('Teclado Mecánico Redragon K552', 'Accesorios', 45.00, 25),
('Monitor LG UltraGear 27"', 'Electrónica', 320.00, 8),
('Impresora HP LaserJet Pro', 'Oficina', 180.00, 12),
('Escritorio de Madera 120cm', 'Muebles', 150.50, 7),
('Cámara Canon EOS 90D', 'Fotografía', 1350.00, 4),
('Mochila Samsonite', 'Accesorios', 65.00, 20);

-- Consultar todos los productos
SELECT * FROM productos;







