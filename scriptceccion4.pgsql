-- ===============================
-- Crear tabla DUAL
-- ===============================
DROP TABLE IF EXISTS dual;

CREATE TABLE dual (
    dummy VARCHAR(1)
);

-- ===============================
-- Insertar el único registro
-- ===============================
INSERT INTO dual (dummy)
VALUES ('X');

-- ===============================
-- Consulta de ejemplo
-- ===============================
SELECT dummy FROM dual;

SELECT (319/29) + 12
FROM DUAL;

SELECT product_name
FROM products_inventory
WHERE LOWER(product_name) = 'abel';

SELECT product_name
FROM products_inventory
WHERE UPPER(product_name) = 'ABEL';

SELECT product_name
FROM products_inventory
WHERE INITCAP(product_name) = 'Abel';

SELECT CONCAT('Hello', 'World') AS greeting
FROM dual;

SELECT CONCAT(product_name, category) AS product_full
FROM products_inventory;

SELECT SUBSTR('HelloWorld',1,5)
FROM DUAL;

SELECT SUBSTR('HelloWorld', 6)
FROM DUAL;

SELECT SUBSTRING(product_name, 1, 3) AS first_three_chars
FROM products_inventory;

SELECT LENGTH('HelloWorld')
FROM DUAL;

SELECT LENGTH(product_name) AS product_name_length
FROM products_inventory;

SELECT POSITION('W' IN 'HelloWorld') AS position_w
FROM dual;

SELECT product_name,
       POSITION('a' IN product_name) AS position_a
FROM products_inventory;

SELECT POSITION('W' IN 'HelloWorld') AS position_w
FROM dual;

SELECT product_name,
       POSITION('a' IN product_name) AS position_a
FROM products_inventory;

SELECT LPAD('HelloWorld', 15, '-') AS padded_text
FROM dual;

SELECT LPAD(product_name, 10, '*') AS padded_name
FROM products_inventory;

SELECT RPAD('HelloWorld', 15, '-') AS padded_text
FROM dual;

SELECT RPAD(product_name, 10, '*') AS padded_name
FROM products_inventory;

SELECT TRIM(TRAILING 'a' FROM 'abcba')
FROM dual;

SELECT TRIM(BOTH 'a' FROM 'abcba') AS trimmed_text
FROM dual;

SELECT REPLACE('Hello World', 'World', 'PostgreSQL') AS replaced_text;

SELECT REPLACE('JACK and JUE','J','BL') AS replaced_text
FROM dual;

SELECT REPLACE('JACK and JUE','J','') AS replaced_text
FROM dual;

SELECT REPLACE(product_name,'a','*') AS replaced_name
FROM products_inventory;


SELECT LOWER(product_name) || LOWER(SUBSTRING(category, 1, 1)) 
       AS "User Name"
FROM products_inventory;

SELECT product_name,
       ROUND(price::numeric, 1) AS rounded_price
FROM products_inventory;

SELECT product_name,
       TRUNC(price::numeric, 1) AS truncated_price
FROM products_inventory;

-- Eliminar si ya existía
DROP TABLE IF EXISTS wf_countries;

-- Crear tabla
CREATE TABLE wf_countries (
    country_id              SERIAL PRIMARY KEY,
    country_name            VARCHAR(70) NOT NULL,
    airports                INT
);

-- Insertar datos de ejemplo
INSERT INTO wf_countries (country_name, airports)
VALUES
('Honduras', 4),
('Canada', 10),
('United Kingdom', 7),
('El Salvador', 3),
('Costa Rica', 2);

SELECT country_name,
       MOD(airports::int, 2) AS "Mod Demo"
FROM wf_countries;

SELECT CURRENT_TIMESTAMP AS today
FROM dual;

SELECT product_name,
       arrival_date + INTERVAL '60 days' AS arrival_plus_60
FROM products_inventory;

SELECT product_name,
       (CURRENT_DATE - arrival_date) / 7 AS weeks_since_arrival
FROM products_inventory;

DROP TABLE IF EXISTS job_history;

CREATE TABLE job_history (
    employee_id INT,
    start_date  DATE NOT NULL,
    end_date    DATE NOT NULL
);

INSERT INTO job_history (employee_id, start_date, end_date) VALUES
(101, '2018-01-10', '2020-07-15'),
(102, '2019-03-05', '2021-05-25'),
(103, '2020-06-01', '2024-06-01');

SELECT employee_id,
       (end_date - start_date) / 365.0 AS "Tenure in last job"
FROM job_history;

SELECT product_name,
       arrival_date
FROM products_inventory
WHERE (
    (EXTRACT(YEAR FROM CURRENT_DATE) * 12 + EXTRACT(MONTH FROM CURRENT_DATE))
    - (EXTRACT(YEAR FROM arrival_date) * 12 + EXTRACT(MONTH FROM arrival_date))
) > 240;

SELECT (CURRENT_DATE + INTERVAL '12 months') AS "Next Year"
FROM dual;

SELECT (CURRENT_DATE + ((6 - EXTRACT(DOW FROM CURRENT_DATE) + 7) % 7) * INTERVAL '1 day') 
       AS "Next Saturday";

SELECT (DATE_TRUNC('MONTH', CURRENT_DATE) + INTERVAL '1 MONTH - 1 day') 
       AS "End of the Month"
FROM dual;

SELECT arrival_date,
       CASE 
         WHEN arrival_date < (DATE_TRUNC('year', arrival_date) + INTERVAL '6 months')
              THEN DATE_TRUNC('year', arrival_date)
         ELSE (DATE_TRUNC('year', arrival_date) + INTERVAL '1 year')
       END AS rounded_year
FROM products_inventory;

SELECT product_name,
       arrival_date + INTERVAL '60 days' AS arrival_plus_60
FROM products_inventory;

SELECT product_name,
       (CURRENT_DATE - arrival_date) / 7 AS weeks_since_arrival
FROM products_inventory;

SELECT employee_id,
       (end_date - start_date) / 365.0 AS "Tenure in last job"
FROM job_history;

SELECT product_id AS employee_id,   -- suponiendo que product_id simula employee_id
       arrival_date AS hire_date,

       -- TENURE (meses redondeados)
       ROUND((
         (EXTRACT(YEAR FROM CURRENT_DATE) * 12 + EXTRACT(MONTH FROM CURRENT_DATE)) -
         (EXTRACT(YEAR FROM arrival_date) * 12 + EXTRACT(MONTH FROM arrival_date))
       )) AS tenure,

       -- REVIEW (6 meses después de la fecha)
       (arrival_date + INTERVAL '6 months') AS review,

       -- NEXT FRIDAY después de hire_date
       (arrival_date + ((5 - EXTRACT(DOW FROM arrival_date) + 7) % 7) * INTERVAL '1 day') AS next_friday,

       -- LAST DAY del mes de hire_date
       (DATE_TRUNC('month', arrival_date) + INTERVAL '1 month - 1 day') AS last_day_month

FROM products_inventory
WHERE (
    (EXTRACT(YEAR FROM CURRENT_DATE) * 12 + EXTRACT(MONTH FROM CURRENT_DATE)) -
    (EXTRACT(YEAR FROM arrival_date) * 12 + EXTRACT(MONTH FROM arrival_date))
) > 36;


