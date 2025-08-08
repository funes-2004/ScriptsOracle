-- ===============================
-- PROYECTO FINAL - PRUEBAS EN BASE DE DATOS (PostgreSQL)
-- ===============================

-- 1. CREAR TABLA DEPARTAMENTOS DE PRUEBA
DROP TABLE IF EXISTS copy_departments;
CREATE TABLE copy_departments (
    department_id INTEGER PRIMARY KEY,
    department_name VARCHAR(50) NOT NULL,
    manager_id INTEGER,
    location_id INTEGER
);

-- Insertar datos iniciales
INSERT INTO copy_departments VALUES
(60, 'Ventas', 201, 1700),
(70, 'Marketing', 202, 1800);

-- 2. CREAR TABLA JOBS PARA PRUEBAS DE NOT NULL
DROP TABLE IF EXISTS jobs;
CREATE TABLE jobs (
    job_id INTEGER PRIMARY KEY,
    job_title VARCHAR(50) NOT NULL,
    min_salary NUMERIC(8,2),
    max_salary NUMERIC(8,2)
);

-- Insertar datos válidos
INSERT INTO jobs VALUES
(200, 'Developer', 1000, 3000);

-- 3. TABLA PARA REGISTRAR RESULTADOS DE PRUEBAS
DROP TABLE IF EXISTS resultados_pruebas;
CREATE TABLE resultados_pruebas (
    numero_prueba INTEGER,
    fecha DATE,
    descripcion_prueba TEXT,
    entrada TEXT,
    salida_esperada TEXT,
    resultado_discrepancia TEXT,
    accion TEXT
);

-- ====================================
-- 4. PRUEBA DE RESTRICCIÓN NOT NULL
-- ====================================
-- Diseño de prueba
INSERT INTO resultados_pruebas VALUES
(1, CURRENT_DATE,
 'Confirmar restricción NOT NULL en job_title de tabla jobs',
 'INSERT INTO jobs(job_id, job_title, min_salary, max_salary) VALUES (222, NULL, 100, 200)',
 'Debe rechazar NULL en job_title',
 NULL,
 NULL
);

-- Ejecutar prueba
DO $$
BEGIN
    BEGIN
        INSERT INTO jobs(job_id, job_title, min_salary, max_salary) VALUES (222, NULL, 100, 200);
    EXCEPTION
        WHEN not_null_violation THEN
            UPDATE resultados_pruebas
            SET resultado_discrepancia = 'Rechazado correctamente: NOT NULL cumplido',
                accion = 'Ninguna'
            WHERE numero_prueba = 1;
    END;
END$$;

-- ====================================
-- 5. PRUEBA DE TRANSACCIÓN CON SAVEPOINT Y ROLLBACK
-- ====================================
BEGIN;

-- UPDATE correcto con WHERE
UPDATE copy_departments
SET manager_id = 101
WHERE department_id = 60;

SAVEPOINT sp1;

-- INSERT de ejemplo
INSERT INTO copy_departments VALUES (130, 'Estate Management', 102, 1500);

-- UPDATE incorrecto sin WHERE (afectaría a todos)
UPDATE copy_departments
SET department_id = 140;

-- Rollback al savepoint
ROLLBACK TO SAVEPOINT sp1;

-- Commit final
COMMIT;

-- Registrar prueba de transacción
INSERT INTO resultados_pruebas VALUES
(2, CURRENT_DATE,
 'Prueba de SAVEPOINT y ROLLBACK',
 'UPDATE sin WHERE revertido al SAVEPOINT',
 'Datos restaurados al estado del SAVEPOINT',
 'Comportamiento correcto',
 'Ninguna'
);

-- ====================================
-- 6. CONSULTAR RESULTADOS DE PRUEBAS
-- ====================================
SELECT * FROM resultados_pruebas;





-- ================================
-- PROYECTO FINAL - BASE DE DATOS "TECNOPLUS"
-- ================================

-- 1) LIMPIEZA PREVIA
DROP SCHEMA IF EXISTS tecnoplus CASCADE;
CREATE SCHEMA tecnoplus;
SET search_path TO tecnoplus;

-- ==================================
-- 2) CREAR SECUENCIAS PARA PK
-- ==================================
CREATE SEQUENCE seq_clientes START 1;
CREATE SEQUENCE seq_empleados START 1;
CREATE SEQUENCE seq_productos START 1;
CREATE SEQUENCE seq_pedidos START 1;
CREATE SEQUENCE seq_detalle START 1;

-- ==================================
-- 3) CREACIÓN DE TABLAS
-- ==================================

CREATE TABLE tb_clientes (
    id_cliente INT PRIMARY KEY DEFAULT nextval('seq_clientes'),
    nombre VARCHAR(100) NOT NULL,
    telefono VARCHAR(20) UNIQUE,
    correo VARCHAR(100) UNIQUE,
    direccion TEXT
);

CREATE TABLE tb_empleados (
    id_empleado INT PRIMARY KEY DEFAULT nextval('seq_empleados'),
    nombre VARCHAR(100) NOT NULL,
    cargo VARCHAR(50) NOT NULL,
    salario NUMERIC(10,2) CHECK (salario > 0)
);

CREATE TABLE tb_productos (
    id_producto INT PRIMARY KEY DEFAULT nextval('seq_productos'),
    nombre VARCHAR(100) NOT NULL,
    precio NUMERIC(10,2) CHECK (precio > 0),
    stock INT CHECK (stock >= 0)
);

CREATE TABLE tb_pedidos (
    id_pedido INT PRIMARY KEY DEFAULT nextval('seq_pedidos'),
    id_cliente INT NOT NULL,
    id_empleado INT NOT NULL,
    fecha DATE DEFAULT CURRENT_DATE,
    FOREIGN KEY (id_cliente) REFERENCES tb_clientes(id_cliente) ON DELETE CASCADE,
    FOREIGN KEY (id_empleado) REFERENCES tb_empleados(id_empleado) ON DELETE SET NULL
);

CREATE TABLE tb_detalle_pedido (
    id_detalle INT PRIMARY KEY DEFAULT nextval('seq_detalle'),
    id_pedido INT NOT NULL,
    id_producto INT NOT NULL,
    cantidad INT CHECK (cantidad > 0),
    subtotal NUMERIC(10,2),
    FOREIGN KEY (id_pedido) REFERENCES tb_pedidos(id_pedido) ON DELETE CASCADE,
    FOREIGN KEY (id_producto) REFERENCES tb_productos(id_producto) ON DELETE CASCADE
);

-- ==================================
-- 4) CREAR ÍNDICES
-- ==================================
CREATE INDEX idx_clientes_nombre ON tb_clientes(nombre);
CREATE INDEX idx_productos_nombre ON tb_productos(nombre);
CREATE INDEX idx_pedidos_fecha ON tb_pedidos(fecha);

-- ==================================
-- 5) INSERTAR DATOS DE EJEMPLO
-- ==================================

-- Clientes
INSERT INTO tb_clientes(nombre, telefono, correo, direccion) VALUES
('Carlos Pérez', '9999-1111', 'carlos@example.com', 'San Pedro Sula'),
('María López', '9999-2222', 'maria@example.com', 'Tegucigalpa');

-- Empleados
INSERT INTO tb_empleados(nombre, cargo, salario) VALUES
('Juan Torres', 'Vendedor', 15000),
('Ana Martínez', 'Gerente', 25000);

-- Productos
INSERT INTO tb_productos(nombre, precio, stock) VALUES
('Laptop Dell', 18000, 10),
('Mouse Logitech', 500, 50),
('Teclado Mecánico', 1500, 20);

-- Pedidos
INSERT INTO tb_pedidos(id_cliente, id_empleado, fecha) VALUES
(1, 1, '2025-08-01'),
(2, 2, '2025-08-02');

-- Detalle pedidos
INSERT INTO tb_detalle_pedido(id_pedido, id_producto, cantidad, subtotal) VALUES
(1, 1, 1, 18000),
(1, 2, 2, 1000),
(2, 3, 1, 1500);

-- ==================================
-- 6) CREAR VISTAS
-- ==================================
CREATE VIEW vw_pedidos_detallados AS
SELECT p.id_pedido, c.nombre AS cliente, e.nombre AS empleado,
       pr.nombre AS producto, d.cantidad, d.subtotal, p.fecha
FROM tb_pedidos p
JOIN tb_clientes c ON p.id_cliente = c.id_cliente
JOIN tb_empleados e ON p.id_empleado = e.id_empleado
JOIN tb_detalle_pedido d ON p.id_pedido = d.id_pedido
JOIN tb_productos pr ON d.id_producto = pr.id_producto;

-- ==================================
-- 7) CREAR SINÓNIMOS (en PostgreSQL se usan VIEWS o ALIAS)
-- ==================================
CREATE VIEW clientes AS SELECT * FROM tb_clientes;
CREATE VIEW productos AS SELECT * FROM tb_productos;

-- ==================================
-- 8) CONSULTAS DE PRUEBA
-- ==================================

-- Ver todos los pedidos detallados
SELECT * FROM vw_pedidos_detallados;

-- Ver stock de productos
SELECT nombre, stock FROM tb_productos;

-- ==================================
-- FIN DEL SCRIPT
-- ==================================



-- ========================================
-- CREACIÓN DE TABLAS CON RESTRICCIONES
-- ========================================
CREATE TABLE proveedores_demo (
    id_proveedor SERIAL PRIMARY KEY,
    nombre_proveedor VARCHAR(50) NOT NULL,
    pais VARCHAR(30)
);

CREATE TABLE productos_demo (
    id_producto SERIAL PRIMARY KEY,
    nombre_producto VARCHAR(100) NOT NULL,
    categoria VARCHAR(30) UNIQUE,
    stock INT CHECK (stock >= 0),
    id_proveedor INT REFERENCES proveedores_demo(id_proveedor)
);

-- ========================================
-- ALTER TABLE (PostgreSQL)
-- ========================================
ALTER TABLE productos_demo
ADD COLUMN descripcion TEXT DEFAULT 'Sin descripción';

ALTER TABLE productos_demo
ALTER COLUMN nombre_producto TYPE VARCHAR(150);

ALTER TABLE productos_demo
DROP COLUMN descripcion;

-- ========================================
-- DROP TABLE
-- ========================================
DROP TABLE IF EXISTS pedidos_demo;

-- ========================================
-- CREACIÓN Y GESTIÓN DE VISTAS
-- ========================================
CREATE OR REPLACE VIEW vista_productos_disponibles AS
SELECT id_producto, nombre_producto, categoria, stock
FROM productos_demo
WHERE stock > 0;

DROP VIEW IF EXISTS vista_productos_disponibles;

-- ========================================
-- CONSULTA TOP N (PostgreSQL usa LIMIT)
-- ========================================
SELECT id_producto, nombre_producto, stock
FROM productos_demo
ORDER BY stock DESC
LIMIT 5;

-- ========================================
-- VISTAS EN LÍNEA (subconsultas en FROM)
-- ========================================
SELECT p.id_producto, p.nombre_producto, prov.nombre_proveedor
FROM productos_demo p
JOIN (
    SELECT id_proveedor, nombre_proveedor
    FROM proveedores_demo
    WHERE pais = 'Honduras'
) prov ON p.id_proveedor = prov.id_proveedor;

-- ========================================
-- CREACIÓN DE SECUENCIAS
-- ========================================
CREATE SEQUENCE seq_demo
INCREMENT BY 1
START WITH 1
MAXVALUE 99999
MINVALUE 1
CYCLE;

DROP SEQUENCE IF EXISTS seq_demo;

-- ========================================
-- CREACIÓN DE ÍNDICES
-- ========================================
CREATE INDEX idx_nombre_producto
ON productos_demo(nombre_producto);

DROP INDEX IF EXISTS idx_nombre_producto;

-- ========================================
-- CREACIÓN DE SINÓNIMOS (PostgreSQL usa ALIAS en vez de SYNONYM)
-- ========================================
-- PostgreSQL no tiene CREATE SYNONYM nativo, se usa CREATE VIEW o ALIAS
CREATE OR REPLACE VIEW alias_productos AS
SELECT * FROM productos_demo;

DROP VIEW IF EXISTS alias_productos;

-- ========================================
-- CREACIÓN DE USUARIOS Y PRIVILEGIOS
-- ========================================
CREATE USER usuario_demo WITH PASSWORD '12345';

GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO usuario_demo;

ALTER USER usuario_demo WITH PASSWORD '54321';

-- ========================================
-- CREACIÓN Y REVOCACIÓN DE PRIVILEGIOS DE OBJETO
-- ========================================
CREATE ROLE rol_demo;

GRANT SELECT, INSERT ON productos_demo TO rol_demo;
GRANT rol_demo TO usuario_demo;

REVOKE INSERT ON productos_demo FROM rol_demo;

-- ========================================
-- INSERCIÓN DE DATOS DE EJEMPLO
-- ========================================
INSERT INTO proveedores_demo (nombre_proveedor, pais) VALUES
('Proveedor A', 'Honduras'),
('Proveedor B', 'México');

INSERT INTO productos_demo (nombre_producto, categoria, stock, id_proveedor) VALUES
('Teclado', 'Periféricos', 50, 1),
('Mouse', 'Periféricos', 100, 1),
('Monitor', 'Pantallas', 20, 2);

-- ========================================
-- CONSULTAS DE PRUEBA
-- ========================================
SELECT * FROM productos_demo;
SELECT * FROM proveedores_demo;

