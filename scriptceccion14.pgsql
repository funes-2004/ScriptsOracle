-- ====================================================
-- EJEMPLO DE RESTRICCIONES COMPLETO: advisory_customers
-- ====================================================

-- 1) Eliminar versión anterior
DROP TABLE IF EXISTS advisory_customers;

-- 2) Crear tabla con constraints a nivel de columna y de tabla
CREATE TABLE advisory_customers (
  customer_id   SERIAL,
  CONSTRAINT advisory_customers_id_pk PRIMARY KEY(customer_id),

  first_name    VARCHAR(30),

  last_name     VARCHAR(30)
    CONSTRAINT advisory_customers_last_name_nn NOT NULL,

  email_address VARCHAR(100)
    NOT NULL
    CONSTRAINT advisory_customers_email_uk UNIQUE,

  phone_number  VARCHAR(15),

  CONSTRAINT advisory_customers_email_phone_uk
    UNIQUE(email_address, phone_number)
);

-- 3) Insertar datos válidos
INSERT INTO advisory_customers (first_name, last_name, email_address, phone_number) VALUES
  ('Hiram',   'Peters', 'hpeters@yahoo.com',        '3715832249'),
  ('Serena',  'Jones',  'serena.jones@jones.com',  '7035335900'),
  ('Lauren',  'Vigil',  'lbv@lbv.net',             '4072220090');



-- ====================================================
-- EJEMPLO COMPLETO DE CONSTRAINTS EN PostgreSQL
-- ====================================================
-- Este script demuestra:
--  1) PRIMARY KEY a nivel de columna
--  2) PRIMARY KEY compuesto a nivel de tabla
--  3) UNIQUE a nivel de columna
--  4) FOREIGN KEY a nivel de columna con ON DELETE CASCADE
--  5) FOREIGN KEY a nivel de tabla con ON DELETE SET NULL
--  6) CHECK a nivel de tabla (comprobación entre dos columnas)
--
-- Nombres de tablas y constraints únicos para no chocar con objetos existentes.
-- ====================================================

-- 0) Eliminar versiones anteriores (en orden de dependencia inverso)
DROP TABLE IF EXISTS consulting_returns;
DROP TABLE IF EXISTS consulting_orders;
DROP TABLE IF EXISTS consulting_subscriptions;
DROP TABLE IF EXISTS consulting_products;
DROP TABLE IF EXISTS consulting_customers;


-- 1) CREATE consulting_customers
--    - PRIMARY KEY a nivel de columna
--    - UNIQUE en email a nivel de columna
CREATE TABLE consulting_customers (
  client_id   SERIAL
    CONSTRAINT consulting_customers_pk PRIMARY KEY,
  first_name  VARCHAR(50),
  last_name   VARCHAR(50) NOT NULL
    CONSTRAINT consulting_customers_last_name_nn,
  email       VARCHAR(100) NOT NULL
    CONSTRAINT consulting_customers_email_uk UNIQUE
);

-- Datos de ejemplo
INSERT INTO consulting_customers (first_name, last_name, email) VALUES
  ('Ana',    'García',   'ana.garcia@example.com'),
  ('Bruno',  'López',    'bruno.lopez@example.com'),
  ('Carmen', 'Martín',   'carmen.martin@example.org');


-- 2) CREATE consulting_products
--    - PRIMARY KEY a nivel de tabla
CREATE TABLE consulting_products (
  product_id   SERIAL,
  product_name VARCHAR(100) NOT NULL,
  CONSTRAINT consulting_products_pk PRIMARY KEY(product_id)
);

-- Datos de ejemplo
INSERT INTO consulting_products (product_name) VALUES
  ('Widget A'),
  ('Gadget B'),
  ('Doohickey C');


-- 3) CREATE consulting_subscriptions
--    - PRIMARY KEY compuesto a nivel de tabla
--    - CHECK que end_date > start_date (si end_date no es NULL)
CREATE TABLE consulting_subscriptions (
  client_id   INTEGER NOT NULL,
  start_date  DATE    NOT NULL,
  end_date    DATE,
  CONSTRAINT consulting_subs_pk PRIMARY KEY(client_id, start_date),
  CONSTRAINT consulting_subs_date_ck CHECK (
    end_date IS NULL OR end_date > start_date
  )
);

-- Datos de ejemplo
INSERT INTO consulting_subscriptions (client_id, start_date, end_date) VALUES
  (1, '2025-01-01', '2025-06-30'),
  (2, '2025-03-15', NULL),
  (3, '2025-04-01', '2025-12-31');


-- 4) CREATE consulting_orders
--    - FOREIGN KEY a nivel de columna con ON DELETE CASCADE
CREATE TABLE consulting_orders (
  order_id   SERIAL
    CONSTRAINT consulting_orders_pk PRIMARY KEY,
  client_id  INTEGER
    CONSTRAINT consulting_orders_cust_fk
      REFERENCES consulting_customers(client_id)
      ON DELETE CASCADE,
  order_date TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Datos de ejemplo
INSERT INTO consulting_orders (client_id, order_date) VALUES
  (1, NOW()),
  (2, NOW() - INTERVAL '7 days'),
  (3, NOW() - INTERVAL '30 days');


-- 5) CREATE consulting_returns
--    - FOREIGN KEY a nivel de tabla con ON DELETE SET NULL
CREATE TABLE consulting_returns (
  return_id    SERIAL,
  order_id     INTEGER,
  return_date  DATE NOT NULL DEFAULT CURRENT_DATE,
  CONSTRAINT consulting_returns_pk PRIMARY KEY(return_id),
  CONSTRAINT consulting_returns_order_fk FOREIGN KEY(order_id)
    REFERENCES consulting_orders(order_id)
    ON DELETE SET NULL
);

-- Datos de ejemplo
INSERT INTO consulting_returns (order_id, return_date) VALUES
  (1, CURRENT_DATE - INTERVAL '2 days'),
  (2, CURRENT_DATE - INTERVAL '1 day');


-- ====================================================
-- ¡Listo! Ahora puede probar:
--  - Que la eliminación de un cliente borre sus órdenes (ON DELETE CASCADE).
--  - Que la eliminación de una orden deje NULL en consulting_returns.order_id.
--  - Que el CHECK impida fechas incorrectas en consulting_subscriptions.
--  - Que el UNIQUE en consulting_customers.email bloquee duplicados.
-- ====================================================




-- ====================================================
-- 6) VISUALIZAR RESTRICCIONES (constraints) EN POSTGRES
-- ====================================================

-- A) Listar las restricciones de clave primaria, única, foreign key, check, etc.
SELECT
  constraint_name,
  constraint_type,        -- 'P' = PRIMARY KEY, 'U' = UNIQUE, 'R' = FOREIGN KEY, 'C' = CHECK
  is_deferrable,
  initially_deferred,
  CASE 
    WHEN constraint_type = 'R' 
    THEN (SELECT delete_rule
          FROM information_schema.referential_constraints rc
          WHERE rc.constraint_name = tc.constraint_name
            AND rc.constraint_schema = tc.constraint_schema)
    ELSE NULL
  END AS on_delete_rule
FROM information_schema.table_constraints tc
WHERE tc.table_schema = 'public'
  AND tc.table_name   = 'advisory_customers'
ORDER BY constraint_name;


-- B) Ver detalles de las columnas afectadas por cada foreign key
SELECT
  tc.constraint_name,
  kcu.column_name            AS column_of_table,
  ccu.table_name   AS foreign_table,
  ccu.column_name  AS foreign_column,
  rc.update_rule   AS on_update,
  rc.delete_rule   AS on_delete
FROM information_schema.table_constraints      AS tc
JOIN information_schema.key_column_usage        AS kcu
  ON tc.constraint_name = kcu.constraint_name
     AND tc.constraint_schema = kcu.constraint_schema
JOIN information_schema.constraint_column_usage AS ccu
  ON ccu.constraint_name = tc.constraint_name
     AND ccu.constraint_schema = tc.constraint_schema
JOIN information_schema.referential_constraints AS rc
  ON rc.constraint_name = tc.constraint_name
     AND rc.constraint_schema = tc.constraint_schema
WHERE tc.table_schema = 'public'
  AND tc.table_name   = 'advisory_orders'
  AND tc.constraint_type = 'FOREIGN KEY'
ORDER BY tc.constraint_name;

