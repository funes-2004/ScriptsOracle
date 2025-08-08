-- =========================================
-- 0) LIMPIEZA PARA RE-EJECUTAR (robusta)
-- =========================================
DO $$
BEGIN
  -- Cierra sesiones abiertas de los roles que vamos a tocar
  PERFORM pg_terminate_backend(pid)
  FROM pg_stat_activity
  WHERE usename IN ('scott_demo','jennifer_cho') AND pid <> pg_backend_pid();
EXCEPTION WHEN OTHERS THEN NULL;
END$$;

-- Si ya existen roles/relaciones, romper dependencias primero:
-- (1) Revocar membresías de roles
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'jennifer_cho') AND
     EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'manager') THEN
    REVOKE manager FROM jennifer_cho;
  END IF;
END$$;

-- (2) Reasignar objetos que posean a CURRENT_USER y borrar sus privilegios/grants
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'scott_demo') THEN
    REASSIGN OWNED BY scott_demo TO CURRENT_USER;
    DROP OWNED BY scott_demo;
  END IF;
  IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'jennifer_cho') THEN
    REASSIGN OWNED BY jennifer_cho TO CURRENT_USER;
    DROP OWNED BY jennifer_cho;
  END IF;
END$$;

-- (3) Ahora ya se pueden eliminar objetos dependientes sin bloquear el DROP ROLE
DROP SCHEMA IF EXISTS labsec CASCADE;

-- (4) Finalmente eliminar los roles (ya sin dependencias)
DROP ROLE IF EXISTS manager;
DROP ROLE IF EXISTS scott_demo;
DROP ROLE IF EXISTS jennifer_cho;
