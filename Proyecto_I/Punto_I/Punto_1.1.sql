----PUNTO 1-A-------------------------------------------
--------TRIGGER--TABLA producto y camion------------------------


CREATE OR REPLACE TRIGGER controlcamiones 
FOR UPDATE OR DELETE ON camion COMPOUND TRIGGER

peso NUMBER(8);
id NUMBER(8);
p NUMBER(8);
vlor NUMBER(8);

AFTER EACH ROW IS
BEGIN
peso:= :NEW.pesomax;
END AFTER EACH ROW;

AFTER STATEMENT IS
BEGIN
SELECT MAX(peso) INTO p FROM producto;
SELECT COUNT(*) INTO vlor FROM camion where pesomax >= p;
IF vlor < 1 THEN
  RAISE_APPLICATION_ERROR(-20505,'no hay mas camiones con pesomax mayor al de los productos');
END IF; 
END AFTER STATEMENT;
END;
/

--------------------------------

CREATE OR REPLACE TRIGGER control_productos 
FOR INSERT OR UPDATE ON producto COMPOUND TRIGGER

peso_max NUMBER(8);
peso NUMBER(8);
id NUMBER(8);

AFTER EACH ROW IS
BEGIN
peso:= :NEW.peso;
id := :NEW.codproducto;
END AFTER EACH ROW;

AFTER STATEMENT IS
BEGIN
SELECT MAX(pesomax) INTO peso_max FROM camion;
IF peso > peso_max THEN
  DELETE FROM producto WHERE codproducto = id;
  RAISE_APPLICATION_ERROR(-20505,'el peso del producto es mayor que el pesomax de los camiones');
END IF; 
END AFTER STATEMENT;
END;
/