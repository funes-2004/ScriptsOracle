-- ============================================
-- Crear tabla employees
-- ============================================
DROP TABLE IF EXISTS employees;

CREATE TABLE employees (
    employee_id     SERIAL PRIMARY KEY,
    first_name      VARCHAR(50) NOT NULL,
    last_name       VARCHAR(50) NOT NULL,
    email           VARCHAR(100) UNIQUE NOT NULL,
    phone_number    VARCHAR(20),
    hire_date       DATE NOT NULL,
    job_id          VARCHAR(10) NOT NULL,
    salary          NUMERIC(10, 2) CHECK (salary > 0),
    commission_pct  NUMERIC(4, 2) DEFAULT 0,
    manager_id      INT,
    department_id   INT,
    CONSTRAINT fk_manager FOREIGN KEY (manager_id) REFERENCES employees(employee_id)
);

-- ============================================
-- Insertar datos de ejemplo
-- ============================================
INSERT INTO employees (first_name, last_name, email, phone_number, hire_date, job_id, salary, commission_pct, manager_id, department_id)
VALUES
('John', 'Doe', 'john.doe@example.com', '555-1234', '2020-01-10', 'IT_PROG', 4500.00, 0.10, NULL, 60),
('Jane', 'Smith', 'jane.smith@example.com', '555-5678', '2019-03-15', 'HR_REP', 3500.00, 0.05, 1, 40),
('Carlos', 'Funes', 'carlos.funes@example.com', '555-7890', '2021-07-01', 'SA_MAN', 6500.00, 0.15, 1, 80),
('Maria', 'Lopez', 'maria.lopez@example.com', '555-2468', '2022-09-20', 'MK_MAN', 7200.00, 0.20, 3, 20),
('Pedro', 'Martinez', 'pedro.martinez@example.com', '555-1357', '2021-05-05', 'FI_ACCOUNT', 5000.00, 0.10, 3, 100);

-- ============================================
-- Consulta para verificar
-- ============================================
SELECT * FROM employees;

SELECT first_name, last_name, job_id
FROM employees
WHERE job_id = 'IT_PROG';




-- ============================================
-- Crear tabla countries
-- ============================================
DROP TABLE IF EXISTS countries;

CREATE TABLE countries (
    country_id     CHAR(2) PRIMARY KEY,
    country_name   VARCHAR(50) NOT NULL,
    region_id      INT NOT NULL,
    capital        VARCHAR(50),
    population     BIGINT,
    area_km2       NUMERIC(12, 2),
    currency       VARCHAR(20)
);

-- ============================================
-- Insertar datos
-- ============================================
INSERT INTO countries (country_id, country_name, region_id, capital, population, area_km2, currency)
VALUES
('CA', 'Canada', 2, 'Ottawa', 38000000, 9984670.00, 'Canadian Dollar'),
('DE', 'Germany', 1, 'Berlin', 83200000, 357022.00, 'Euro'),
('UK', 'United Kingdom', 1, 'London', 67800000, 243610.00, 'Pound Sterling'),
('US', 'United States of America', 2, 'Washington D.C.', 331000000, 9833517.00, 'US Dollar'),
('MX', 'Mexico', 2, 'Mexico City', 128900000, 1964375.00, 'Mexican Peso'),
('JP', 'Japan', 3, 'Tokyo', 125800000, 377975.00, 'Yen'),
('BR', 'Brazil', 2, 'Brasilia', 214300000, 8515767.00, 'Brazilian Real'),
('AU', 'Australia', 3, 'Canberra', 25690000, 7692024.00, 'Australian Dollar');



-- ============================================
-- Crear tabla departments
-- ============================================
DROP TABLE IF EXISTS departments;

CREATE TABLE departments (
    department_id     SERIAL PRIMARY KEY,
    department_name   VARCHAR(100) NOT NULL,
    manager_id        INT,
    location_id       INT,
    budget            NUMERIC(12,2),
    phone_number      VARCHAR(20),
    email             VARCHAR(100),
    CONSTRAINT fk_manager FOREIGN KEY (manager_id) REFERENCES employees(employee_id)
);

-- ============================================
-- Insertar datos de ejemplo
-- ============================================
INSERT INTO departments (department_name, manager_id, location_id, budget, phone_number, email)
VALUES
('Human Resources', 2, 100, 50000.00, '555-1000', 'hr@example.com'),
('Finance', 3, 200, 150000.00, '555-2000', 'finance@example.com'),
('IT', 1, 300, 250000.00, '555-3000', 'it@example.com'),
('Marketing', 4, 400, 80000.00, '555-4000', 'marketing@example.com'),
('Sales', 3, 500, 300000.00, '555-5000', 'sales@example.com'),
('Logistics', 5, 600, 60000.00, '555-6000', 'logistics@example.com');

SELECT department_name
FROM departments; 

SELECT department_name
FROM departments;

SELECT salary
FROM employees
WHERE last_name LIKE
'Smith'; 

SELECT *
FROM countries;

SELECT country_id, country_name, region_id
FROM countries;

-- ============================================
-- Crear tabla locations
-- ============================================
DROP TABLE IF EXISTS locations;

CREATE TABLE locations (
    location_id     INT PRIMARY KEY,
    city            VARCHAR(100) NOT NULL,
    state_province  VARCHAR(100),
    postal_code     VARCHAR(20),
    country_id      CHAR(2) REFERENCES countries(country_id),
    street_address  VARCHAR(150)
);

-- ============================================
-- Insertar datos de ejemplo
-- ============================================
INSERT INTO locations (location_id, city, state_province, postal_code, country_id, street_address)
VALUES
(1800, 'Toronto', 'Ontario', 'M5H 2N2', 'CA', '100 King Street West'),
(2500, 'Oxford', 'Oxford', 'OX1 2JD', 'UK', '1 High Street'),
(1400, 'Southlake', 'Texas', '76092', 'US', '200 Main Street'),
(1500, 'South San Francisco', 'California', '94080', 'US', '300 Bay Area Blvd'),
(1700, 'Seattle', 'Washington', '98101', 'US', '400 Pine Street'),
(1600, 'Berlin', 'Berlin', '10115', 'DE', 'Unter den Linden 77'),
(2600, 'Mexico City', 'Distrito Federal', '01000', 'MX', 'Av. Reforma 500'),
(2700, 'Tokyo', 'Tokyo Prefecture', '100-0001', 'JP', 'Shinjuku 3-1-1'),
(2800, 'Sydney', 'New South Wales', '2000', 'AU', 'George Street 250');

SELECT location_id, city, state_province
FROM locations;

SELECT last_name, salary,
salary + 300
FROM employees;

SELECT last_name, salary,
12*salary +100
FROM employees;

SELECT last_name, salary,
12*(salary +100)
FROM employees;

SELECT last_name, job_id, salary, commission_pct,
salary*commission_pct
FROM employees;

SELECT last_name AS name,
commission_pct AS comm
FROM employees;

SELECT last_name "Name",
salary*12 "Annual Salary"
FROM employees;




