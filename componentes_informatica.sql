# Borrar la base de datos
DROP DATABASE IF EXISTS componentes_informatica;
# La crea de nuevo
CREATE DATABASE IF NOT EXISTS componentes_informatica;
# La utiliza
USE componentes_informatica;

# Crea la BD solo si no existe antes
# CREATE DATABASE IF NOT EXISTS componentes_informatica;

# Ver que tablas tenemos en nuestra BD
SHOW TABLES;

# Crear una tabla
CREATE TABLE clientes (
id_clientes INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
nombre VARCHAR(25) NOT NULL,
apellido VARCHAR(50) NOT NULL,
email VARCHAR(100) NOT NULL,
telefono VARCHAR(9),
cif VARCHAR(10) NOT NULL
);

# Creamos la tabla proveedores como clientes
CREATE TABLE proveedores LIKE clientes;

# Modificamos apellido para que no sea obligatorio
ALTER TABLE clientes
MODIFY apellido VARCHAR(50);
ALTER TABLE proveedores
MODIFY apellido VARCHAR(50);

# Descripción de las tablas
DESCRIBE clientes;
DESCRIBE proveedores;

# Modificamos el nombre de la columna con el id
ALTER TABLE proveedores
CHANGE id_clientes id_proveedores INT NOT NULL AUTO_INCREMENT;

# Tabla productos
CREATE TABLE productos (
id_productos INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
tipo VARCHAR(20) NOT NULL,
nombre VARCHAR(50) NOT NULL,
marca VARCHAR(20) NOT NULL,
precio_compra DECIMAL(8,2) NOT NULL,
precio_venta DECIMAL(8,2) NOT NULL,
stock INT,
id_proveedores INT
);

CREATE TABLE ventas (
id_ventas INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
id_clientes INT,
id_productos INT,
cantidad_producto INT
);

# Añadir las claves foráneas
ALTER TABLE ventas # modificamos la tabla ventas
ADD FOREIGN KEY (id_clientes) # id_clientes es el de ventas
REFERENCES clientes(id_clientes); # se referencia con la tabla clientes

ALTER TABLE ventas # modificamos la tabla ventas
ADD FOREIGN KEY (id_productos) # id_productos es el de ventas
REFERENCES productos(id_productos); # se referencia con la tabla productos

ALTER TABLE productos # modificamos la tabla ventas
ADD FOREIGN KEY (id_proveedores) # id_proveedores es el de ventas
REFERENCES proveedores(id_proveedores); # se referencia con la tabla proveedores

# Añadir columna IVA 
ALTER TABLE productos
ADD COLUMN iva decimal(3,2) DEFAULT 0.21;

# Insertamos columna fecha creación de usuario
ALTER TABLE clientes
ADD COLUMN fecha_alta DATETIME DEFAULT current_timestamp;

# Si tenemos un problema con una columna
# lo más fácil puede ser borrarla e introducir después
# la definición correcta
# ALTER TABLE clientes
# DROP COLUMN fecha_alta;

# Añadir columna con solo dos opciones
ALTER TABLE clientes
ADD COLUMN tipo_usuario ENUM("particular", "empresa") DEFAULT "particular";

# Introducir (insertar) valores en la tabla
INSERT INTO clientes (nombre, apellido, email, telefono, cif) 
VALUES
("Bill", "Gates", "bill.gates@microsoft.com", "123456789", "111111111"),
("Steve", "Jobs", "steve.jobs@apple.com", "234567890", "222222222"),
("Jeff", "Bezos", "compras@amazon.com", "345678901", "555555555");
INSERT INTO clientes (nombre, email, telefono, cif, tipo_usuario) 
VALUES
("Amazon", "compras@amazon.com", "345678901", "333333333", "empresa"),
("X", "compras@x.com", "456789012", "444444444", "empresa");

# Ver el contenido de la tabla
SELECT * FROM clientes;

INSERT INTO clientes (nombre, apellido, email, telefono, cif, tipo_usuario) 
VALUES
("Elon", "Musk", "elon@musk.com", "666666666", "666666666", default),
("CIEF", default, "info@cief.com", "777777777", "777777777", "empresa");

# ¿Qué clientes tienen el email compras@amazon.com?
SELECT nombre, apellido 
FROM clientes 
WHERE email = "compras@amazon.com";

describe proveedores;
INSERT INTO proveedores (nombre, apellido, email, telefono, cif)
VALUES
("Xiaomi", "García", "xiaomi@garcia.cn", null, "aaaaaaaaa"),
("Apple", default, "apple@apple.com", "888888888", "888888888"),
("HP", default, "hp@hp.cpm", "999999999", "999999999");

select * from proveedores;

INSERT INTO productos (tipo, nombre, marca, precio_compra, precio_venta, stock, id_proveedores)
VALUES
("móvil", "Xiaomi 14", "Xiaomi", 700, 1000, 3, 1),
("portátil", "MacBook Pro M4", "Apple", 2000, 2700, 5, 2),
("portátil", "AirBook M3", "Apple", 1000, 2300.50, 5, 2),
("HD", "Samsung X14 512GB", "Samsung", 45, 60.85, 8, 1),
("portátil", "EliteBook 2024", "Apple", 600, 800, 5, 2);

SELECT * FROM productos;

UPDATE productos 
SET marca = "HP", id_proveedores = 3
WHERE id_productos = 5;

INSERT INTO ventas (id_clientes, id_productos, cantidad_producto)
VALUES (1, 2, 1),(2, 1, 3),(1, 3, 4);

# Quiero saber el nombre de los proveedores de mis productos
SELECT pv.nombre, pr.nombre
FROM proveedores pv, productos pr
WHERE pv.id_proveedores = pr.id_proveedores;

# Quiero saber el nombre del proveedor y el beneficio de cada producto
SELECT pv.nombre as "nombre proveedor", pr.nombre as "producto", (precio_venta - precio_compra) as beneficio
FROM proveedores pv
INNER JOIN productos pr
ON pv.id_proveedores = pr.id_proveedores;

# Quiero saber el nombre y apellido de cada cliente que ha comprado un producto de Apple
SELECT cl.nombre, cl.apellido, pr.nombre
FROM clientes cl
JOIN ventas ve
ON cl.id_clientes = ve.id_clientes
JOIN productos pr
ON ve.id_productos = pr.id_productos
JOIN proveedores pv
ON pv.id_proveedores = pr.id_proveedores
WHERE pv.nombre = "Apple";

# Obtener el nombre y precio de venta  y el beneficio de cada venta
SELECT pr.nombre, pr.precio_venta, ve.cantidad_producto,
((pr.precio_venta - pr.precio_compra)*ve.cantidad_producto) as "beneficio_parcial"
FROM productos pr
JOIN ventas ve
ON ve.id_productos = pr.id_productos;

# Obtener el beneficio total
SELECT sum((pr.precio_venta - pr.precio_compra)*ve.cantidad_producto) as "beneficio_parcial"
FROM productos pr
JOIN ventas ve
ON ve.id_productos = pr.id_productos;

# Obtener qué clientes no han comprado nada
SELECT c.id_clientes, c.nombre, c.apellido, c.email
FROM clientes c
LEFT JOIN ventas v ON c.id_clientes = v.id_clientes
WHERE v.id_clientes IS NULL;

# ¿De que producto/s hay más stock?
SELECT p.nombre, p.marca, p.tipo, p.stock
FROM productos p
WHERE p.stock = (SELECT MAX(stock) FROM productos);


# ¿Qué clientes contiene una "a"?
# busca en el nombre la letra "a"
SELECT id_clientes, nombre, apellido, email
FROM clientes
WHERE nombre LIKE '%a%';

# busca en el nombre y en el apellido l letra "a"
SELECT id_clientes, nombre, apellido, email
FROM clientes
WHERE nombre LIKE '%a%' OR apellido LIKE '%a%'; 


