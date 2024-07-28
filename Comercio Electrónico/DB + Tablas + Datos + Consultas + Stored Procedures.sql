-- CREACION DB
CREATE DATABASE ecommerce;
USE ecommerce;

-- TABLAS
CREATE TABLE Categorias (
    ID_Categoria INT PRIMARY KEY IDENTITY(1,1), 
    Nombre VARCHAR(100) NOT NULL,
    Descripcion TEXT,
    UNIQUE (Nombre) 
);

CREATE TABLE Productos (
    ID_Producto INT PRIMARY KEY IDENTITY(1,1),
    Nombre VARCHAR(100) NOT NULL,
    Descripcion TEXT,
    Precio DECIMAL(10, 2) NOT NULL,
    ID_Categoria INT,
    Inventario INT NOT NULL,
    FOREIGN KEY (ID_Categoria) REFERENCES Categorias(ID_Categoria),
    INDEX idx_Nombre (Nombre),
    INDEX idx_ID_Categoria (ID_Categoria)
);

CREATE TABLE Usuarios (
    ID_Usuario INT PRIMARY KEY IDENTITY(1,1),
    Nombre VARCHAR(100) NOT NULL,
    CorreoElectronico VARCHAR(100) NOT NULL UNIQUE,
    Direccion TEXT,
    Telefono VARCHAR(15),
    INDEX idx_CorreoElectronico (CorreoElectronico)
);

CREATE TABLE Transacciones (
    ID_Transaccion INT PRIMARY KEY IDENTITY(1,1),
    ID_Usuario INT,
    Fecha DATETIME NOT NULL,
    Total DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (ID_Usuario) REFERENCES Usuarios(ID_Usuario),
    INDEX idx_Fecha (Fecha),
    INDEX idx_ID_Usuario (ID_Usuario)
);

CREATE TABLE DetallesTransaccion (
    ID_Detalle INT PRIMARY KEY IDENTITY(1,1),
    ID_Transaccion INT,
    ID_Producto INT,
    Cantidad INT NOT NULL,
    Precio DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (ID_Transaccion) REFERENCES Transacciones(ID_Transaccion),
    FOREIGN KEY (ID_Producto) REFERENCES Productos(ID_Producto),
    INDEX idx_ID_Transaccion (ID_Transaccion),
    INDEX idx_ID_Producto (ID_Producto)
);

CREATE TABLE Reseñas (
    ID_Reseña INT PRIMARY KEY IDENTITY(1,1),
    ID_Producto INT,
    ID_Usuario INT,
    Fecha DATE NOT NULL,
    Calificacion INT CHECK (Calificacion >= 1 AND Calificacion <= 5),
    Comentario TEXT,
    FOREIGN KEY (ID_Producto) REFERENCES Productos(ID_Producto),
    FOREIGN KEY (ID_Usuario) REFERENCES Usuarios(ID_Usuario),
    INDEX idx_ID_Producto (ID_Producto), 
    INDEX idx_ID_Usuario (ID_Usuario)
);

-- DATOS DE EJEMPLO

INSERT INTO Categorias (Nombre, Descripcion) VALUES
('Electrónica', 'Dispositivos electrónicos'),
('Calzado', 'Prendas para calzar'),
('Musica', 'Artículos para equipar tu estudio');

INSERT INTO Productos (Nombre, Descripcion, Precio, ID_Categoria, Inventario) VALUES
('iPhone 13 Pro Max', 'Versión más equipada de la edicion 13 del iPhone', 699.99, 1, 50),
('Jordan 13 Limited Edition', 'Edicion limitada de los Jordan 13', 299.99, 2, 25),
('Focusrite 2i2', 'Interfaz de sonido para musicos', 329.99, 3, 30);

INSERT INTO Usuarios (Nombre, CorreoElectronico, Direccion, Telefono) VALUES
('Enjher Javier', 'enjherjavier@gmail.com', 'Calle Warachita, Herrera', '809-547-5555'),
('Engel Ernesto', 'engelernesto@gmail.com', 'Calle SabraDio, Los Frailes', '809-447-5277'),
('Cristian Pimentel', 'cristianpimentel@gmail.com', 'Calle Jabladoria, Los Mina', '809-554-7888');

INSERT INTO Transacciones (ID_Usuario, Fecha, Total) VALUES
(1, '2023-07-22 14:30:00', 299.99),
(1, '2023-07-21 14:30:00', 299.99),
(2, '2023-07-22 10:15:00', 699.99);

INSERT INTO DetallesTransaccion (ID_Transaccion, ID_Producto, Cantidad, Precio) VALUES
(1, 1, 1, 699.99),
(1, 3, 1, 329.99),
(2, 2, 2, 299.99);

INSERT INTO Reseñas (ID_Producto, ID_Usuario, Fecha, Calificacion, Comentario) VALUES
(1, 1, '2023-07-23', 5, 'La misma vaina to los años'),
(2, 2, '2023-07-24', 4, 'Que vacaneria');

-- CONSULTAS AVANZADAS

-- Productos mejores vendidos
SELECT p.Nombre, SUM(dt.Cantidad) AS Total_Vendido
FROM Productos p
JOIN DetallesTransaccion dt ON p.ID_Producto = dt.ID_Producto
GROUP BY p.Nombre
ORDER BY Total_Vendido DESC;

-- Usuarios con más compras
SELECT u.Nombre, COUNT(t.ID_Transaccion) AS Total_Compras
FROM Usuarios u
JOIN Transacciones t ON u.ID_Usuario = t.ID_Usuario
GROUP BY u.Nombre
ORDER BY Total_Compras DESC;

-- Productos mejor valorados
SELECT p.Nombre, AVG(r.Calificacion) AS Promedio_Calificacion
FROM Productos p
JOIN Reseñas r ON p.ID_Producto = r.ID_Producto
GROUP BY p.Nombre
ORDER BY Promedio_Calificacion DESC;

-- STORED PROCEDURES
-- Estos son procedimientos almacenados para actualizar el inventario dependiendo si hay más o menos
-- La forma de llamarlos es CALL ActualizarInventario(ID_Producto, Cantidad que se quiera)
-- Ej: Para restar 5 unidades en el producto que tiene un 'uno' como ID, seria: EXEC ActualizarInventarioMenos @pID = 1, @cantidad = 5
-- Para sumar 10 unidades en el producto que tiene un 'uno' como ID, seria: EXEC ActualizarInventarioMas @pID = 1, @cantidad = 10

-- Stored Procedure para actualizar inventario cuando haya menos productos + Exec para llamarlo
CREATE PROCEDURE ActualizarInventarioMenos
    @pID INT,
    @cantidad INT
AS
BEGIN
    UPDATE Productos
    SET Inventario = Inventario - @cantidad
    WHERE ID_Producto = @pID;
END;

EXEC ActualizarInventarioMenos @pID = 1, @cantidad = 5

-- Stored Procedure para actualizar inventario cuando haya más productos + EXEC para llamarlo
CREATE PROCEDURE ActualizarInventarioMas
    @pID INT,
    @cantidad INT
AS
BEGIN
    UPDATE Productos
    SET Inventario = Inventario + @cantidad
    WHERE ID_Producto = @pID;
END;

EXEC ActualizarInventarioMas @pID = 1, @cantidad = 10
