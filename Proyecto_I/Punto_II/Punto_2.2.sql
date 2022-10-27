-- TRIGGER para verificar antes de insertar
CREATE OR REPLACE TRIGGER before_insert_rutadirecta
  BEFORE INSERT ON rutadirecta
  FOR EACH ROW
DECLARE
  rutacorta rutadirecta.costo%TYPE;
BEGIN
  ruta_mas_corta.ruta_corta(:NEW.ciudadinicio, :NEW.ciudadfin, rutacorta);
  DBMS_OUTPUT.PUT_LINE('RUTA MAS CORTA: ' || rutacorta || ' < ' || :NEW.costo);
  IF rutacorta < :NEW.costo AND rutacorta > 0 THEN
    raise_application_error(-20101, 'No puede ingresar esta ruta');
  END IF;
END;
/