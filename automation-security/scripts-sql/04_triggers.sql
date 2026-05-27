-- ==========================================================
-- 04_triggers.sql
-- Trigger de integridad para controlar alquileres en Pagila
-- ==========================================================

-- Eliminamos primero el trigger y la función si ya existen.
-- Así podemos repetir la práctica sin errores.
DROP TRIGGER IF EXISTS trg_control_alquiler_cliente ON rental;
DROP FUNCTION IF EXISTS controlar_alquiler_cliente();

-- Creamos la función que se ejecutará antes de insertar un alquiler.
CREATE OR REPLACE FUNCTION controlar_alquiler_cliente()
RETURNS TRIGGER AS $$
DECLARE
    alquileres_antiguos INTEGER;
    pagos_pendientes INTEGER;
BEGIN
    -- Comprobamos si el cliente tiene alquileres sin devolver desde hace más de 30 días.
    SELECT COUNT(*)
    INTO alquileres_antiguos
    FROM rental
    WHERE customer_id = NEW.customer_id
      AND return_date IS NULL
      AND rental_date < NOW() - INTERVAL '30 days';

    -- Comprobamos si el cliente tiene alquileres sin pago asociado.
    -- En esta práctica se interpreta como deuda pendiente.
    SELECT COUNT(*)
    INTO pagos_pendientes
    FROM rental r
    LEFT JOIN payment p ON r.rental_id = p.rental_id
    WHERE r.customer_id = NEW.customer_id
      AND p.payment_id IS NULL;

    -- Si tiene alquileres antiguos sin devolver, bloqueamos el nuevo alquiler.
    IF alquileres_antiguos > 0 THEN
        RAISE EXCEPTION 'El cliente % no puede alquilar: tiene alquileres sin devolver desde hace más de 30 días.',
            NEW.customer_id;
    END IF;

    -- Si tiene pagos pendientes, también bloqueamos el alquiler.
    IF pagos_pendientes > 0 THEN
        RAISE EXCEPTION 'El cliente % no puede alquilar: tiene pagos pendientes.',
            NEW.customer_id;
    END IF;

    -- Si todo está correcto, permitimos insertar el alquiler.
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Creamos el trigger sobre la tabla rental.
-- Se ejecuta antes de insertar un nuevo alquiler.
CREATE TRIGGER trg_control_alquiler_cliente
BEFORE INSERT ON rental
FOR EACH ROW
EXECUTE FUNCTION controlar_alquiler_cliente();

DO $$
BEGIN
    RAISE NOTICE 'Trigger de control de alquileres creado correctamente.';
END;
$$;
