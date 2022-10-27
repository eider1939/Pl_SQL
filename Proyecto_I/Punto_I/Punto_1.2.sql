CREATE OR REPLACE PROCEDURE consulta_viajes
(codigo_pedido IN detalledepedido.codpedido%TYPE)
IS
CURSOR detpedido IS --Se declara el cursor
SELECT d.*, p.* FROM detalledepedido d JOIN producto p ON d.codprod = p.codproducto
WHERE d.codpedido = codigo_pedido ORDER BY p.peso DESC;
TYPE arreglo_detalles IS TABLE OF NUMBER(8) INDEX BY BINARY_INTEGER;
TYPE arreglo_tabla IS TABLE OF arreglo_detalles INDEX BY BINARY_INTEGER;
arreglo arreglo_tabla;
i NUMBER(8);
viajes NUMBER(8);
prod_a_llevar NUMBER(8);
prod_cargados NUMBER(8);
prod_cargados_t NUMBER(8);
prod_pend NUMBER(8);
peso_disp NUMBER(8);
BEGIN
	i := 0;
	prod_a_llevar := 0;
	FOR detalle  IN detpedido LOOP
		arreglo(i)(0) := detalle.codprod;
		arreglo(i)(1) := detalle.peso;
		arreglo(i)(2) := detalle.unidades;
		i := i + 1;
		prod_a_llevar := prod_a_llevar + detalle.unidades;
	END LOOP;

	DBMS_OUTPUT.PUT_LINE('Historial de viajes para el pedido '||codigo_pedido);
	DBMS_OUTPUT.PUT_LINE('Se deben llevar '||prod_a_llevar||' unidades en total');

	viajes := 1;
	WHILE(prod_a_llevar > 0) LOOP
		DBMS_OUTPUT.PUT_LINE('Viaje #'||viajes);
		FOR c IN (SELECT * FROM camion ORDER BY pesomax DESC) LOOP
			peso_disp := c.pesomax;
			prod_cargados_t := 0;
			FOR i IN arreglo.FIRST .. arreglo.LAST LOOP
				prod_cargados := 0;
				WHILE((arreglo(i)(2) > 0) and (peso_disp >= arreglo(i)(1))) LOOP
					prod_cargados := prod_cargados + 1;
					prod_a_llevar := prod_a_llevar - 1;
					peso_disp := peso_disp - arreglo(i)(1);
					arreglo(i)(2) := arreglo(i)(2) - 1;
				END LOOP;
				IF(prod_cargados != 0) THEN
					DBMS_OUTPUT.PUT_LINE('El camion '||c.codcamion||' cargo '||prod_cargados||
						' unidades del producto '||arreglo(i)(0));
					prod_cargados_t := prod_cargados_t + prod_cargados;
					EXIT WHEN prod_a_llevar = 0;
				END IF;
			END LOOP;
			DBMS_OUTPUT.PUT_LINE('El camion '||c.codcamion||' realizo el envio');
			EXIT WHEN prod_a_llevar = 0;
		END LOOP;
		viajes := viajes + 1;
	END LOOP;

	DBMS_OUTPUT.PUT_LINE('Fin de la ejecucion');

END;
/



#DBMS_OUTPUT.PUT_LINE(detalle.codpedido || ' ' || detalle.codprod);