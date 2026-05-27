-- ==========================================================
-- 03_vistas.sql
-- Creación de vistas personalizadas para Pagila
-- ==========================================================

-- Eliminamos la vista si ya existe para poder repetir la práctica.
DROP VIEW IF EXISTS vista_peliculas_disponibles;

-- Esta vista está pensada para el personal de atención.
-- Muestra información útil para recepción, pero evita datos sensibles
-- como pagos, ingresos o información interna de la empresa.
CREATE VIEW vista_peliculas_disponibles AS
SELECT
    f.film_id,
    f.title AS titulo,
    f.rating AS clasificacion,
    COUNT(i.inventory_id) AS copias_totales,
    COUNT(i.inventory_id) FILTER (
        WHERE i.inventory_id NOT IN (
            SELECT r.inventory_id
            FROM rental r
            WHERE r.return_date IS NULL
        )
    ) AS copias_disponibles
FROM film f
JOIN inventory i ON f.film_id = i.film_id
GROUP BY f.film_id, f.title, f.rating
ORDER BY f.title;

-- Damos permiso de consulta de la vista al grupo de atención.
GRANT SELECT ON vista_peliculas_disponibles TO grupo_atencion;

-- También permitimos que gerencia pueda consultarla.
GRANT SELECT ON vista_peliculas_disponibles TO grupo_gerencia;

DO $$
BEGIN
    RAISE NOTICE 'Vista de películas disponibles creada correctamente.';
END;
$$;
