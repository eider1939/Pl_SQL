-- crear la tabla rutadirecta
CREATE TABLE rutadirecta(
ciudadinicio VARCHAR2(10),
ciudadfin VARCHAR2(10),
costo NUMBER(8) NOT NULL CHECK (costo > 0),
PRIMARY KEY(ciudadinicio, ciudadfin),
CHECK (ciudadinicio <> ciudadfin)
);

-- tabla auxiliar para procedimiento
CREATE TABLE procedimiento(
ciudadfin VARCHAR2(10),
costo NUMBER(8) NOT NULL CHECK (costo >= 0),
ciudadinicio VARCHAR2(10),
paso NUMBER(8) NOT NULL CHECK (paso > 0),
fijo NUMBER(1) NOT NULL CHECK  (fijo in (0,1)),
PRIMARY KEY(ciudadfin, paso)
);