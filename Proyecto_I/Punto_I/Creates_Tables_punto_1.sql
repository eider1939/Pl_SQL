-------------primero se crean las tablas camion, producto y detalledeproducto---------

CREATE TABLE camion(
codcamion NUMBER(8) PRIMARY KEY,
pesomax NUMBER(8) NOT NULL CHECK (pesomax > 0)
);
CREATE TABLE producto(
codproducto NUMBER(8) PRIMARY KEY,
peso NUMBER(8) NOT NULL CHECK (peso > 0)
);
CREATE TABLE detalledepedido(
codpedido NUMBER(8),
codprod NUMBER(8) REFERENCES producto,
unidades NUMBER(8) NOT NULL CHECK (unidades > 0),
PRIMARY KEY (codpedido, codprod)
);