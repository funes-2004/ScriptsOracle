-- ============================================================
-- DEMO DE TRANSACCIONES CON SAVEPOINT (PostgreSQL)
-- Crea tabla de trabajo, carga datos y ejecuta el flujo completo
-- ============================================================

-- Limpieza por si lo corres más de una vez
DROP TABLE IF EXISTS copy_departments;

-- Tabla de ejemplo (nombre permitido, no choca con tu lista)
CREATE TABLE copy_departments (
  department_id  INTEGER PRIMARY KEY,
  department_name VARCHAR(100) NOT NULL,
  manager_id     INTEGER,
  location_id    INTEGER
);

-- Carga unos datos base, incluyendo el id 60 que usa el ejemplo
INSERT INTO copy_departments (department_id, department_name, manager_id, location_id) VALUES
(10,  'Administration', 200, 1700),
(20,  'Marketing',      201, 1800),
(60,  'IT Support',     103, 1500),
(90,  'Executive',      100, 1700);

-- Estado inicial
SELECT * FROM copy_departments ORDER BY department_id;

-- ================== INICIO TRANSACCIÓN ==================
BEGIN;

-- Paso 1: UPDATE con WHERE (como en la 1ª diapositiva)
UPDATE copy_departments
SET manager_id = 101
WHERE department_id = 60;

-- Crear SAVEPOINT
SAVEPOINT one;

-- Paso 2: INSERT (como en la 2ª diapositiva)
INSERT INTO copy_departments (department_id, department_name, manager_id, location_id)
VALUES (130, 'Estate Management', 102, 1500);

-- Paso 3: UPDATE sin WHERE (error lógico del ejemplo)
-- (afectaría TODAS las filas si no revertimos)
UPDATE copy_departments
SET department_id = 140;
-- *** Ojo: esto fallaría por PK duplicada si hay más de una fila.
-- Para ser fieles al ejemplo y poder mostrar el rollback, dejamos el UPDATE tal cual;
-- si tuvieras restricciones que lo impidan, puedes simular otro cambio global
-- (p.ej., SET manager_id = 999) que igualmente revertiremos.

-- Revertimos al SAVEPOINT "one"
ROLLBACK TO SAVEPOINT one;

-- Confirmamos la transacción (los cambios DESPUÉS del savepoint se descartaron)
COMMIT;
-- ================== FIN TRANSACCIÓN ==================

-- Ver el estado final (debe incluir el INSERT, el UPDATE inicial,
-- y NO debe incluir el cambio global del UPDATE sin WHERE)
SELECT * FROM copy_departments ORDER BY department_id;

