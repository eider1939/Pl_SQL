CREATE OR REPLACE PACKAGE ruta_mas_corta AS

  TYPE t_rutas IS TABLE OF rutadirecta%ROWTYPE INDEX BY BINARY_INTEGER;
  TYPE t_procedimiento IS TABLE OF procedimiento%ROWTYPE INDEX BY BINARY_INTEGER;
  PROCEDURE guardar(nuevaCiudadfin    IN procedimiento.ciudadfin%TYPE,
                    nuevoCosto        IN procedimiento.costo%TYPE,
                    nuevaCiudadinicio IN procedimiento.ciudadinicio%TYPE,
                    nuevoPaso         IN procedimiento.paso%TYPE,
                    nuevoFijo         IN procedimiento.fijo%TYPE,
                    rutas             IN OUT t_procedimiento);
  PROCEDURE obtenerCiudades(inicio    IN rutadirecta.ciudadinicio%TYPE,
                            mis_rutas OUT t_rutas);
  PROCEDURE esMinimo(fin       IN rutadirecta.ciudadfin%TYPE,
                     acumulado IN NUMBER,
                     nuevoPaso IN procedimiento.paso%TYPE,
                     rutas     IN t_procedimiento,
                     minimo    OUT NUMBER);
  PROCEDURE minimaRuta(paso         IN procedimiento.paso%TYPE,
                       rutas        IN t_procedimiento,
                       minimoCamino OUT procedimiento%ROWTYPE);
  PROCEDURE actualizarGuardado(fin       IN procedimiento.ciudadfin%TYPE,
                               nuevoPaso IN procedimiento.paso%TYPE,
                               nuevoFijo IN procedimiento.fijo%TYPE,
                               rutas     IN OUT t_procedimiento);
  PROCEDURE actualizarLista(nuevoPaso IN procedimiento.paso%TYPE,
                            rutas     IN OUT t_procedimiento);
  PROCEDURE checkearRutas(nuevoPaso IN procedimiento.paso%TYPE,
                          rutas     IN t_procedimiento,
                          ruta      OUT procedimiento%ROWTYPE);
  PROCEDURE ruta_corta(inicio    IN rutadirecta.ciudadinicio%TYPE,
                       fin       IN rutadirecta.ciudadfin%TYPE,
                       rutacorta OUT NUMBER);

END;
/

CREATE OR REPLACE PACKAGE BODY ruta_mas_corta AS

    -- procedimiento para guardar en tabla de apoyo
    PROCEDURE guardar
        (nuevaCiudadfin IN procedimiento.ciudadfin%TYPE,
        nuevoCosto IN procedimiento.costo%TYPE,
        nuevaCiudadinicio IN procedimiento.ciudadinicio%TYPE,
        nuevoPaso IN procedimiento.paso%TYPE,
        nuevoFijo IN procedimiento.fijo%TYPE,
        rutas IN OUT t_procedimiento)
    IS
        k NUMBER(4) := 0;
    BEGIN
        k := rutas.COUNT + 1;
        rutas(k).ciudadfin := nuevaCiudadfin;
        rutas(k).costo := nuevoCosto;
        rutas(k).ciudadinicio := nuevaCiudadinicio;
        rutas(k).paso := nuevoPaso;
        rutas(k).fijo := nuevoFijo;
    END;


    -- procedimiento para obtenerCiudades con los que conecta una ciudad
    PROCEDURE obtenerCiudades
        (inicio IN rutadirecta.ciudadinicio%TYPE, mis_rutas OUT t_rutas)
    IS
        k NUMBER(8) := 1;
    BEGIN
        FOR mi_r IN (SELECT * FROM rutadirecta WHERE ciudadinicio = inicio) LOOP
            mis_rutas(k) := mi_r;            
            k := k+1;
        END LOOP;
    END;


    -- procedimiento para verificar que si es el minimo a esa ciudad
    PROCEDURE esMinimo
        (fin IN rutadirecta.ciudadfin%TYPE,
        acumulado IN NUMBER,
        nuevoPaso IN procedimiento.paso%TYPE,
        rutas IN t_procedimiento,
        minimo OUT NUMBER)
    IS
    BEGIN
        minimo := 1;
        FOR i IN 1 .. rutas.COUNT LOOP
            IF  rutas(i).ciudadfin = fin AND rutas(i).paso = nuevoPaso THEN
                IF  acumulado > rutas(i).costo THEN
                    minimo := 0;
                END IF;
            END IF;
        END LOOP;
    END;


    -- procedimiento para optener ruta minima en cada paso
    PROCEDURE minimaRuta
        (paso IN procedimiento.paso%TYPE, rutas IN t_procedimiento, minimoCamino OUT procedimiento%ROWTYPE)
    IS
    BEGIN
        FOR i IN 1 .. rutas.COUNT LOOP
            IF  minimoCamino.costo IS NULL AND rutas(i).paso = paso THEN
                minimoCamino := rutas(i);
            ELSIF rutas(i).paso = paso AND rutas(i).costo < minimoCamino.costo THEN
                minimoCamino := rutas(i);
            END IF;
        END LOOP;
    END;


    -- procedimiento para actualizar ruta a fija
    PROCEDURE actualizarGuardado
        (fin IN procedimiento.ciudadfin%TYPE,
        nuevoPaso IN procedimiento.paso%TYPE,
        nuevoFijo IN procedimiento.fijo%TYPE,
        rutas IN OUT t_procedimiento)
    IS
    BEGIN
        FOR i IN 1 .. rutas.COUNT LOOP
            IF  rutas(i).ciudadfin = fin AND rutas(i).paso = nuevoPaso THEN
                rutas(i).fijo := nuevoFijo;
            END IF;
        END LOOP;
    END;


    -- procedimiento para actualizar ruta a fija
    PROCEDURE actualizarLista
        (nuevoPaso IN procedimiento.paso%TYPE, rutas IN OUT t_procedimiento)
    IS
    BEGIN
        FOR i IN 1 .. rutas.COUNT LOOP
            IF  rutas(i).paso = nuevoPaso - 1 THEN
                rutas(i).paso := nuevoPaso;
            END IF;
        END LOOP;
    END;


    -- procedimiento para actualizar ruta a fija
    PROCEDURE checkearRutas
        (nuevoPaso IN procedimiento.paso%TYPE, rutas IN t_procedimiento, ruta OUT procedimiento%ROWTYPE)
    IS
    BEGIN
        FOR i IN 1 .. rutas.COUNT LOOP
            IF  rutas(i).fijo = 0 AND rutas(i).paso = nuevoPaso THEN
                 ruta := rutas(i);
            END IF;
        END LOOP;
    END;


    -- procedimiento para obtener ruta mas corta
    PROCEDURE ruta_corta
        (inicio IN rutadirecta.ciudadinicio%TYPE, fin IN rutadirecta.ciudadfin%TYPE, rutacorta OUT NUMBER)
    IS
        paso NUMBER(4) := 1;
        acumulado NUMBER(4) := 0;
        rutacorta_costo NUMBER(4) := 0;
        acum NUMBER(4) := 0;
        minimo NUMBER(1) := 0;        
        mis_rutas t_rutas;
        rutas t_procedimiento;
        ruta_corta procedimiento%ROWTYPE;
        ruta procedimiento%ROWTYPE;
        inicial rutadirecta.ciudadinicio%TYPE;
    BEGIN
        inicial := inicio;
        obtenerCiudades(inicial, mis_rutas); -- PROCEDURE obtenerCiudades
        IF mis_rutas.COUNT > 0 THEN
            LOOP
                paso := paso + 1;
                FOR i IN 1 .. mis_rutas.COUNT LOOP  
                    acum := acumulado + mis_rutas(i).costo;
                    esMinimo(mis_rutas(i).ciudadfin, acum, paso - 1, rutas, minimo);  -- PROCEDURE esMinimo                    
                    IF  minimo = 1 THEN
                        guardar(mis_rutas(i).ciudadfin , acum, inicial, paso, 0, rutas); -- PROCEDURE guardar                
                    END IF;
                END LOOP;
                minimaRuta(paso, rutas, ruta_corta); -- PROCEDURE minimaRuta   
                actualizarLista(paso, rutas); -- PROCEDURE actualizarLista
                IF  ruta_corta.ciudadfin IS NULL OR ruta_corta.ciudadfin = fin THEN
                    checkearRutas(paso, rutas, ruta); -- PROCEDURE checkearRutas
                    IF  ruta.ciudadfin IS NULL THEN
                        EXIT;
                    ELSE
                        inicial := ruta.ciudadfin;
                        acumulado := ruta.costo;
                        actualizarGuardado(ruta.ciudadfin, paso, 1, rutas); -- PROCEDURE actualizarGuardado
                    END IF;
                ELSE
                    inicial := ruta_corta.ciudadfin;                                                      
                    acumulado := ruta_corta.costo;                
                    actualizarGuardado(ruta_corta.ciudadfin, paso, 1, rutas); -- PROCEDURE actualizarGuardado
                END IF;
                obtenerCiudades(inicial, mis_rutas); -- PROCEDURE obtenerCiudades
            END LOOP;            
            FOR i IN 1 .. rutas.COUNT LOOP
                IF  rutas(i).paso = paso AND rutas(i).ciudadfin = fin THEN
                    rutacorta_costo := rutas(i).costo;                
                END IF;
            END LOOP;
        END IF;
        rutacorta := rutacorta_costo;
    END;

END ruta_mas_corta;
/