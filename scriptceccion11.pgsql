-- ==========================================
-- USO DE TABLAS EXISTENTES (NOMBRES MODIFICADOS)
-- ==========================================
-- Se asume que las tablas ya existen:
--   locaciones, departamentos, trabajos, grados_trabajo, empleados
-- ==========================================
-- CREACIÓN DE TABLAS CON NOMBRES MODIFICADOS
-- ==========================================
DROP SCHEMA IF EXISTS demo CASCADE;
CREATE SCHEMA demo;
SET search_path TO demo;

-- Tabla LOCACIONES
CREATE TABLE locaciones (
    location_id SERIAL PRIMARY KEY,
    city VARCHAR(50),
    state_province VARCHAR(50)
);

-- Tabla DEPARTAMENTOS
CREATE TABLE departamentos (
    department_id SERIAL PRIMARY KEY,
    department_name VARCHAR(50) NOT NULL,
    manager_id INT,
    location_id INT REFERENCES locaciones(location_id)
);

-- Tabla TRABAJOS
CREATE TABLE trabajos (
    job_id SERIAL PRIMARY KEY,
    job_title VARCHAR(50) NOT NULL,
    min_salary NUMERIC(10,2),
    max_salary NUMERIC(10,2)
);

-- Tabla GRADOS_TRABAJO
CREATE TABLE grados_trabajo (
    grade_level CHAR(1) PRIMARY KEY,
    lowest_sal NUMERIC(10,2),
    highest_sal NUMERIC(10,2)
);

-- Tabla EMPLEADOS
CREATE TABLE empleados (
    employee_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(50),
    salary NUMERIC(10,2),
    commission_pct NUMERIC(3,2),
    manager_id INT,
    hire_date DATE,
    job_id INT REFERENCES trabajos(job_id),
    department_id INT REFERENCES departamentos(department_id)
);



-- ==========================================
-- CONSULTAS ADAPTADAS A NUEVOS NOMBRES DE TABLAS
-- ==========================================

-- Consulta 1: Inicial y apellido de empleados
SELECT CONCAT(LEFT(first_name,1),' ',last_name) AS "Employee Names" FROM empleados;

-- Consulta 2: Nombre completo + email con IN
SELECT CONCAT(first_name,' ',last_name) AS "Employee Name", email AS "Email" FROM empleados WHERE email LIKE '%IN%';

-- Consulta 3: Apellido más pequeño y más grande
SELECT MIN(last_name) AS "First Last Name", MAX(last_name) AS "Last Last Name" FROM empleados;

-- Consulta 4: Salarios semanales entre 700 y 3000
SELECT TO_CHAR(salary/4,'$9999.99') AS "Weekly Salary" FROM empleados WHERE salary/4 BETWEEN 700 AND 3000;

-- Consulta 5: Empleados y su cargo ordenados por título
SELECT CONCAT(LEFT(e.first_name,1),' ',e.last_name) AS "Employee Name", t.job_title AS "Job" FROM empleados e JOIN trabajos t ON e.job_id=t.job_id ORDER BY t.job_title;

-- Consulta 6: Cargos, rangos de salario y salario del empleado
SELECT CONCAT(LEFT(e.first_name,1),' ',e.last_name) AS "Employee Name", t.job_title AS "Job", CONCAT(t.min_salary,'-',t.max_salary) AS "Salary Range", e.salary AS "Employee's Salary" FROM empleados e JOIN trabajos t ON e.job_id=t.job_id;

-- Consulta 7: Inicial + apellido + nombre de departamento
SELECT CONCAT(LEFT(e.first_name,1),' ',e.last_name) AS "Employee Name", d.department_name AS "Department Name" FROM empleados e JOIN departamentos d ON e.department_id=d.department_id;

-- Consulta 8: Unión solo por department_id
SELECT CONCAT(LEFT(e.first_name,1),' ',e.last_name) AS "Employee Name", d.department_name AS "Department Name" FROM empleados e NATURAL JOIN departamentos d;

-- Consulta 9: Nobody / Somebody según jefe
SELECT CASE WHEN manager_id IS NULL THEN 'Nobody' ELSE 'Somebody' END AS "Works for", last_name AS "Last Name" FROM empleados;

-- Consulta 10: Comisión (sí/no)
SELECT CONCAT(LEFT(first_name,1),' ',last_name) AS "Employee Name", salary AS "Salary", CASE WHEN commission_pct IS NULL THEN 'No' ELSE 'Yes' END AS "Commission" FROM empleados;

-- Consulta 11: Apellido, departamento, ciudad y estado (LEFT JOIN)
SELECT e.last_name, d.department_name, l.city, l.state_province FROM empleados e LEFT JOIN departamentos d ON e.department_id=d.department_id LEFT JOIN locaciones l ON d.location_id=l.location_id;

-- Consulta 12: commission_pct, manager_id o -1
SELECT first_name AS "First Name", last_name AS "Last Name", COALESCE(commission_pct::TEXT, manager_id::TEXT, '-1') AS "Which function???" FROM empleados;

-- Consulta 13: Empleados con department_id > 50 y job_grade
SELECT e.last_name, e.salary, g.grade_level FROM empleados e JOIN grados_trabajo g ON e.salary BETWEEN g.lowest_sal AND g.highest_sal WHERE department_id>50;

-- Consulta 14: Empleados y departamentos (full outer join)
SELECT e.last_name, d.department_name FROM empleados e FULL JOIN departamentos d ON e.department_id=d.department_id;

-- Consulta 15: Jerarquía de empleados (recursivo)
WITH RECURSIVE emp_hierarchy AS (
  SELECT employee_id, last_name, manager_id, 1 AS position FROM empleados WHERE employee_id=100
  UNION ALL
  SELECT e.employee_id, e.last_name, e.manager_id, eh.position+1 FROM empleados e JOIN emp_hierarchy eh ON e.manager_id=eh.employee_id)
SELECT position, last_name, COALESCE((SELECT last_name FROM empleados m WHERE m.employee_id=emp_hierarchy.manager_id),'-') AS manager_name FROM emp_hierarchy;

-- Consulta 16: Primer y última fecha de contratación y número de empleados
SELECT MIN(hire_date) AS "Lowest", MAX(hire_date) AS "Highest", COUNT(*) AS "No of Employees" FROM empleados;

-- Consulta 17: Costos de departamentos entre 15000 y 31000
SELECT d.department_name, SUM(e.salary) AS "Salaries" FROM empleados e JOIN departamentos d ON e.department_id=d.department_id GROUP BY d.department_name HAVING SUM(e.salary) BETWEEN 15000 AND 31000 ORDER BY SUM(e.salary);

-- Consulta 18: Promedio mayor de salarios por departamento
SELECT ROUND(MAX(avg_sal)) AS "Highest Avg Sal for Depts" FROM (SELECT AVG(salary) AS avg_sal FROM empleados GROUP BY department_id) t;

-- Consulta 19: Costos mensuales por departamento
SELECT d.department_name AS "Department Name", SUM(e.salary) AS "Monthly Cost" FROM empleados e JOIN departamentos d ON e.department_id=d.department_id GROUP BY d.department_name;

-- Consulta 20: Costos por job_id dentro de cada departamento
SELECT d.department_name AS "Department Name", t.job_title AS "Job Title", SUM(e.salary) AS "Monthly Cost" FROM empleados e JOIN trabajos t ON e.job_id=t.job_id JOIN departamentos d ON e.department_id=d.department_id GROUP BY d.department_name,t.job_title;

-- Consulta 21: Agrupación cubo con flags de uso
SELECT d.department_name, t.job_title, SUM(e.salary) AS "Monthly Cost", CASE WHEN GROUPING(d.department_name)=0 THEN 'Yes' ELSE 'No' END AS "Department ID Used", CASE WHEN GROUPING(t.job_title)=0 THEN 'Yes' ELSE 'No' END AS "Job ID Used" FROM empleados e JOIN trabajos t ON e.job_id=t.job_id JOIN departamentos d ON e.department_id=d.department_id GROUP BY CUBE(d.department_name,t.job_title);

-- Consulta 22: Juegos de agrupamiento (por ciudad)
SELECT d.department_name, t.job_title, l.city, SUM(e.salary) FROM empleados e JOIN trabajos t ON e.job_id=t.job_id JOIN departamentos d ON e.department_id=d.department_id JOIN locaciones l ON d.location_id=l.location_id GROUP BY GROUPING SETS ((d.department_name,t.job_title),(l.city));

-- Consulta 23: UNION de empleados, departamentos y ciudades
SELECT CONCAT(LEFT(first_name,1),' ',last_name) AS "Employee Name", department_id AS "Department Id", NULL AS "Department Name", NULL AS "City" FROM empleados
UNION ALL
SELECT NULL, department_id, department_name, NULL FROM departamentos
UNION ALL
SELECT NULL, NULL, NULL, city FROM locaciones;

-- Consulta 24: Empleados que ganan más que la media de su departamento
SELECT CONCAT(LEFT(e.first_name,1),' ',e.last_name) AS "Employee", e.salary AS "Salary", d.department_name AS "Department Name" FROM empleados e JOIN departamentos d ON e.department_id=d.department_id WHERE e.salary > (SELECT AVG(salary) FROM empleados WHERE department_id=e.department_id);
