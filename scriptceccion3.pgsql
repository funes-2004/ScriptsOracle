-- ===========================
-- Crear tabla nueva: PROJECTS
-- ===========================
DROP TABLE IF EXISTS projects;

CREATE TABLE projects (
    project_id      SERIAL PRIMARY KEY,
    project_name    VARCHAR(100) NOT NULL,
    start_date      DATE NOT NULL,
    end_date        DATE,
    budget          NUMERIC(12,2),
    status          VARCHAR(20)  -- Ej: 'Active', 'Completed', 'On Hold'
);

-- ===========================
-- Insertar datos de ejemplo
-- ===========================
INSERT INTO projects (project_name, start_date, end_date, budget, status)
VALUES
('Migration ERP', '2024-01-15', '2024-07-30', 50000.00, 'Completed'),
('Website Redesign', '2024-03-01', NULL, 15000.00, 'Active'),
('Mobile App Development', '2024-05-10', NULL, 30000.00, 'Active'),
('Data Warehouse', '2023-11-01', '2024-04-15', 80000.00, 'Completed'),
('AI Chatbot', '2024-06-20', NULL, 20000.00, 'On Hold');

-- ===========================
-- Consultas de ejemplo
-- ===========================

-- 1) Proyectos activos
SELECT project_name, status
FROM projects
WHERE status = 'Active';

-- 2) Proyectos con presupuesto mayor a 20000
SELECT project_name, budget
FROM projects
WHERE budget > 20000;

-- 3) Proyectos finalizados (end_date no es NULL)
SELECT project_name, end_date
FROM projects
WHERE end_date IS NOT NULL;

-- 4) Buscar proyectos cuyo nombre contiene 'App'
SELECT project_name
FROM projects
WHERE project_name LIKE '%App%';

SELECT project_name, start_date, status
FROM projects
WHERE start_date > DATE '2024-01-01'
  AND status LIKE 'A%';

SELECT project_name, status, budget
FROM projects
WHERE budget = 25000 OR status = 'On Hold';

SELECT project_name, budget
FROM projects
WHERE budget NOT IN (25000, 45000);

SELECT project_name || ' ' || budget * 1.05 AS "Project Raise"
FROM projects
WHERE status IN ('Active','On Hold')
  AND project_name LIKE 'C%'
   OR project_name LIKE '%s%';

SELECT project_name || ' ' || budget * 1.05 AS "Project Raise",
       status,
       start_date
FROM projects
WHERE status IN ('Active','On Hold')
  AND project_name LIKE 'C%'
   OR project_name LIKE '%s%';

SELECT project_name || ' ' || budget * 1.05 AS "Project Raise",
       status,
       start_date
FROM projects
WHERE status IN ('Active','On Hold')
   OR project_name LIKE 'C%'
  AND project_name LIKE '%s%';

  SELECT project_name || ' ' || budget * 1.05 AS "Project Raise",
       status,
       start_date
FROM projects
WHERE (status IN ('Active','On Hold') OR project_name LIKE 'C%')
  AND project_name LIKE '%s%';


-- ====================================
-- Crear tabla nueva: products_inventory
-- ====================================
DROP TABLE IF EXISTS products_inventory;

CREATE TABLE products_inventory (
    product_id      SERIAL PRIMARY KEY,
    product_name    VARCHAR(100) NOT NULL,
    category        VARCHAR(50),
    price           NUMERIC(10,2),
    stock_quantity  INT,
    supplier        VARCHAR(100),
    arrival_date    DATE
);

-- ====================================
-- Insertar datos de ejemplo
-- ====================================
INSERT INTO products_inventory (product_name, category, price, stock_quantity, supplier, arrival_date)
VALUES
('Laptop Pro 15', 'Electronics', 1200.00, 30, 'TechSource', '2024-03-15'),
('Office Chair', 'Furniture', 150.00, 100, 'ComfortCo', '2024-02-10'),
('Gaming Mouse', 'Electronics', 45.99, 200, 'GadgetWorld', '2024-04-01'),
('Standing Desk', 'Furniture', 320.00, 50, 'ErgoSupply', '2024-01-20'),
('LED Monitor 27"', 'Electronics', 280.00, 75, 'VisionTech', '2024-02-25');

-- ====================================
-- Consultas de ejemplo
-- ====================================

-- 1) Productos electrónicos con precio mayor a 100
SELECT product_name, price
FROM products_inventory
WHERE category = 'Electronics' AND price > 100;

-- 2) Productos cuyo stock sea menor a 80
SELECT product_name, stock_quantity
FROM products_inventory
WHERE stock_quantity < 80;

-- 3) Productos que llegaron después de marzo 2024
SELECT product_name, arrival_date
FROM products_inventory
WHERE arrival_date > DATE '2024-03-01';

-- 4) Productos cuyo nombre contiene la palabra "Desk"
SELECT product_name, category
FROM products_inventory
WHERE product_name LIKE '%Desk%';

-- 5) Incremento del precio de todos los productos en 5%
SELECT product_name || ' - New Price: ' || price * 1.05 AS "Price Update"
FROM products_inventory;

SELECT product_name, arrival_date
FROM products_inventory
ORDER BY arrival_date;

SELECT product_name, arrival_date
FROM products_inventory
ORDER BY arrival_date DESC;

SELECT product_name, arrival_date AS "Date Arrived"
FROM products_inventory
ORDER BY "Date Arrived";

SELECT product_id,
       product_name
FROM products_inventory
WHERE product_id < 5
ORDER BY category;

SELECT category, product_name
FROM products_inventory
WHERE category <= 'Furniture'
ORDER BY category, product_name;

SELECT category, product_name
FROM products_inventory
WHERE category <= 'Furniture'
ORDER BY category DESC, product_name;
