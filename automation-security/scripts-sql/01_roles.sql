-- ==========================================================
-- 01_roles.sql
-- Creación de roles de grupo y usuarios para Pagila
-- ==========================================================

-- Primero eliminamos los usuarios si ya existen.
-- Esto permite repetir la práctica varias veces sin errores.
DROP ROLE IF EXISTS manager_user;
DROP ROLE IF EXISTS staff_user;

-- Eliminamos los roles de grupo si ya existen.
DROP ROLE IF EXISTS grupo_gerencia;
DROP ROLE IF EXISTS grupo_atencion;

-- Creamos roles de grupo.
-- Estos roles no tienen LOGIN porque no son usuarios reales,
-- solo sirven para agrupar permisos.
CREATE ROLE grupo_gerencia;
CREATE ROLE grupo_atencion;

-- Creamos usuarios reales con LOGIN.
-- Estos usuarios serán los que podrían conectarse a la base de datos.
CREATE ROLE manager_user WITH
    LOGIN
    PASSWORD 'Manager_Pagila';

CREATE ROLE staff_user WITH
    LOGIN
    PASSWORD 'Staff_Pagila';

-- Asignamos los usuarios a sus grupos.
-- Así los permisos se darán a los grupos, no directamente a cada usuario.
GRANT grupo_gerencia TO manager_user;
GRANT grupo_atencion TO staff_user;

-- Dejamos una salida visible para confirmar que el script ha terminado.
DO $$
BEGIN
    RAISE NOTICE 'Roles de grupo y usuarios creados correctamente.';
END;
$$;
