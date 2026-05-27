-- ==========================================================
-- 02_permisos.sql
-- Asignación de permisos sobre la base de datos Pagila
-- ==========================================================

-- Damos permiso de conexión a la base de datos.
GRANT CONNECT ON DATABASE pagila TO grupo_gerencia;
GRANT CONNECT ON DATABASE pagila TO grupo_atencion;

-- Damos permiso de uso sobre el esquema public.
-- Sin esto, los roles no podrían acceder correctamente a los objetos del esquema.
GRANT USAGE ON SCHEMA public TO grupo_gerencia;
GRANT USAGE ON SCHEMA public TO grupo_atencion;

-- ----------------------------------------------------------
-- Permisos para gerencia
-- ----------------------------------------------------------
-- Gerencia puede consultar información general de negocio.
GRANT SELECT ON TABLE film TO grupo_gerencia;
GRANT SELECT ON TABLE inventory TO grupo_gerencia;
GRANT SELECT ON TABLE rental TO grupo_gerencia;
GRANT SELECT ON TABLE customer TO grupo_gerencia;
GRANT SELECT ON TABLE payment TO grupo_gerencia;

-- Gerencia también puede modificar datos clave de inventario y películas.
GRANT INSERT, UPDATE ON TABLE film TO grupo_gerencia;
GRANT INSERT, UPDATE ON TABLE inventory TO grupo_gerencia;

-- ----------------------------------------------------------
-- Permisos para atención al cliente / recepción
-- ----------------------------------------------------------
-- El personal de atención puede consultar películas e inventario.
GRANT SELECT ON TABLE film TO grupo_atencion;
GRANT SELECT ON TABLE inventory TO grupo_atencion;

-- También puede gestionar alquileres, ya que forma parte de su trabajo diario.
GRANT SELECT, INSERT, UPDATE ON TABLE rental TO grupo_atencion;

-- Puede consultar clientes, pero no modificar pagos ni información económica.
GRANT SELECT ON TABLE customer TO grupo_atencion;

-- No se conceden permisos sobre payment al grupo de atención
-- para evitar acceso a información sensible de pagos.

DO $$
BEGIN
    RAISE NOTICE 'Permisos aplicados correctamente a los grupos.';
END;
$$;
