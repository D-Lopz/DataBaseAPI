-- Base de Datos NLP2
CREATE DATABASE nlp_comentarios;
\c nlp_comentarios;

-- Tipos ENUM
CREATE TYPE rol_usuario AS ENUM ('Administrador', 'Estudiante', 'Docente');
CREATE TYPE estado_evaluacion AS ENUM ('Activo', 'Inactivo');
CREATE TYPE tipo_sentimiento AS ENUM ('Positivo', 'Negativo', 'Neutral');
CREATE TYPE tipo_formato AS ENUM ('PDF', 'Excel');

-- Tabla de Usuarios
CREATE TABLE Usuarios (
    id_usuario SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    rol rol_usuario NOT NULL,
    contrasena VARCHAR(255) NOT NULL,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de Asignaturas
CREATE TABLE Asignaturas (
    id_asignatura SERIAL PRIMARY KEY,
    nombre_asignatura VARCHAR(100) NOT NULL,
    id_docente INT REFERENCES Usuarios(id_usuario)
);

-- Tabla de Evaluaciones
CREATE TABLE Evaluaciones (
    id_evaluacion SERIAL PRIMARY KEY,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NOT NULL,
    estado estado_evaluacion DEFAULT 'Inactivo',
    descripcion TEXT
);

-- Tabla de Comentarios
CREATE TABLE Comentarios (
    id_comentario SERIAL PRIMARY KEY,
    id_estudiante INT REFERENCES Usuarios(id_usuario),
    id_docente INT REFERENCES Usuarios(id_usuario),
    id_asignatura INT REFERENCES Asignaturas(id_asignatura),
    id_evaluacion INT REFERENCES Evaluaciones(id_evaluacion),
    comentario TEXT NOT NULL,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de Análisis de Sentimientos
CREATE TABLE AnalisisSentimientos (
    id_analisis SERIAL PRIMARY KEY,
    id_comentario INT REFERENCES Comentarios(id_comentario),
    sentimiento tipo_sentimiento,
    resumen TEXT,
    puntuacion DECIMAL(3,2)
);

-- Tabla de Reportes
CREATE TABLE Reportes (
    id_reporte SERIAL PRIMARY KEY,
    id_docente INT REFERENCES Usuarios(id_usuario),
    fecha_generacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    contenido TEXT,
    formato tipo_formato
);


-- Inserciones para la tabla Usuarios
INSERT INTO Usuarios (nombre, email, rol, contrasena)
VALUES 
('Nicolas Vargas','nicolas@hotmail.com','Estudiante','123'),
('Ana Maria','ana@hotmail.com','Docente','123'),
('Pablo Diago','diago@hotmail.com','Administrador','123');

-- Inserciones para la tabla Asignaturas
-- Nota: Se asume que 'Ana Maria' tiene id_usuario = 2
INSERT INTO Asignaturas (nombre_asignatura, id_docente)
VALUES
('Ingeniera de software', 2),
('Base de datos', 2),
('Complejidad Algoritmica', 2);

-- Inserciones para la tabla Evaluaciones
INSERT INTO Evaluaciones (fecha_inicio, fecha_fin, estado, descripcion)
VALUES
  ('2025-03-01', '2025-03-31', 'Activo', 'Evaluación del primer trimestre.'),
  ('2025-06-01', '2025-06-30', 'Inactivo', 'Evaluación del segundo trimestre.'),
  ('2025-09-01', '2025-09-30', 'Inactivo', 'Evaluación del tercer trimestre.');

-- Inserciones para la tabla Comentarios
-- Se asume que 'Nicolas Vargas' tiene id_usuario = 1
-- y las asignaturas tienen los IDs 1, 2 y 3 en orden
-- y la evaluación 1 es la activa
INSERT INTO Comentarios (id_estudiante, id_docente, id_asignatura, id_evaluacion, comentario)
VALUES
(1, 2, 1, 1, 'La profesora explica muy bien los temas.'),
(1, 2, 2, 2, 'Las clases fueron interesantes pero algo rápidas.'),
(1, 2, 3, 1, 'Me gustó el enfoque práctico que se usó.');

-- Índices
CREATE INDEX idx_usuario_rol ON Usuarios(rol);
CREATE INDEX idx_comentario_fecha ON Comentarios(fecha_creacion);
CREATE INDEX idx_analisis_sentimiento ON AnalisisSentimientos(sentimiento);

-- FUNCIONES (CRUD por tabla)
-- Usuarios
CREATE OR REPLACE FUNCTION CrearUsuario(nombre_in VARCHAR, email_in VARCHAR, rol_in rol_usuario, contrasena_in VARCHAR)
RETURNS VOID AS $$
BEGIN
    INSERT INTO Usuarios (nombre, email, rol, contrasena)
    VALUES (nombre_in, email_in, rol_in, contrasena_in);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION LeerUsuario(id INT)
RETURNS TABLE(id_usuario INT, nombre VARCHAR, email VARCHAR, rol rol_usuario, contrasena VARCHAR, fecha_creacion TIMESTAMP)
AS $$
BEGIN
    RETURN QUERY SELECT * FROM Usuarios WHERE id_usuario = id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION ActualizarUsuario(id INT, nombre_in VARCHAR, email_in VARCHAR, rol_in rol_usuario, contrasena_in VARCHAR)
RETURNS VOID AS $$
BEGIN
    UPDATE Usuarios SET nombre = nombre_in, email = email_in, rol = rol_in, contrasena = contrasena_in
    WHERE id_usuario = id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION EliminarUsuario(id INT)
RETURNS VOID AS $$
BEGIN
    DELETE FROM Usuarios WHERE id_usuario = id;
END;
$$ LANGUAGE plpgsql;

-- Asignaturas
CREATE OR REPLACE FUNCTION CrearAsignatura(nombre_in VARCHAR, id_docente_in INT)
RETURNS VOID AS $$
BEGIN
    INSERT INTO Asignaturas (nombre_asignatura, id_docente) VALUES (nombre_in, id_docente_in);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION LeerAsignatura(id INT)
RETURNS TABLE(id_asignatura INT, nombre_asignatura VARCHAR, id_docente INT)
AS $$
BEGIN
    RETURN QUERY SELECT * FROM Asignaturas WHERE id_asignatura = id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION ActualizarAsignatura(id INT, nombre_in VARCHAR, id_docente_in INT)
RETURNS VOID AS $$
BEGIN
    UPDATE Asignaturas SET nombre_asignatura = nombre_in, id_docente = id_docente_in WHERE id_asignatura = id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION EliminarAsignatura(id INT)
RETURNS VOID AS $$
BEGIN
    DELETE FROM Asignaturas WHERE id_asignatura = id;
END;
$$ LANGUAGE plpgsql;

-- Evaluaciones
CREATE OR REPLACE FUNCTION CrearEvaluacion(fecha_inicio_in DATE, fecha_fin_in DATE, estado_in estado_evaluacion, descripcion_in TEXT)
RETURNS VOID AS $$
BEGIN
    INSERT INTO Evaluaciones (fecha_inicio, fecha_fin, estado, descripcion)
    VALUES (fecha_inicio_in, fecha_fin_in, estado_in, descripcion_in);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION LeerEvaluacion(id INT)
RETURNS TABLE(id_evaluacion INT, fecha_inicio DATE, fecha_fin DATE, estado estado_evaluacion, descripcion TEXT)
AS $$
BEGIN
    RETURN QUERY SELECT * FROM Evaluaciones WHERE id_evaluacion = id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION ActualizarEvaluacion(id INT, fecha_inicio_in DATE, fecha_fin_in DATE, estado_in estado_evaluacion, descripcion_in TEXT)
RETURNS VOID AS $$
BEGIN
    UPDATE Evaluaciones SET fecha_inicio = fecha_inicio_in, fecha_fin = fecha_fin_in,
    estado = estado_in, descripcion = descripcion_in WHERE id_evaluacion = id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION EliminarEvaluacion(id INT)
RETURNS VOID AS $$
BEGIN
    DELETE FROM Evaluaciones WHERE id_evaluacion = id;
END;
$$ LANGUAGE plpgsql;

-- Comentarios
CREATE OR REPLACE FUNCTION InsertarComentario(idEst INT, idDoc INT, idAsig INT, idEval INT, comentarioTexto TEXT)
RETURNS VOID AS $$
BEGIN
    INSERT INTO Comentarios (id_estudiante, id_docente, id_asignatura, id_evaluacion, comentario)
    VALUES (idEst, idDoc, idAsig, idEval, comentarioTexto);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION LeerComentario(id INT)
RETURNS TABLE(id_comentario INT, id_estudiante INT, id_docente INT, id_asignatura INT, id_evaluacion INT, comentario TEXT, fecha_creacion TIMESTAMP)
AS $$
BEGIN
    RETURN QUERY SELECT * FROM Comentarios WHERE id_comentario = id;
END;
$$ LANGUAGE plpgsql;

-- CREATE OR REPLACE FUNCTION ActualizarComentario(id INT, id_est INT, id_doc INT, id_asig INT, id_eval INT, comentario_in TEXT)
-- RETURNS VOID AS $$
-- BEGIN
--     UPDATE Comentarios SET id_estudiante = id_est, id_docente = id_doc, id_asignatura = id_asig,
--     id_evaluacion = id_eval, comentario = comentario_in WHERE id_comentario = id;
-- END;
-- $$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION EliminarComentario(id INT)
RETURNS VOID AS $$
BEGIN
    DELETE FROM Comentarios WHERE id_comentario = id;
END;
$$ LANGUAGE plpgsql;
