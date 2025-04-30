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
CREATE OR REPLACE PROCEDURE CrearUsuario(nombre VARCHAR, email VARCHAR, rol rol_usuario, contrasena VARCHAR)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO Usuarios (nombre, email, rol, contrasena)
    VALUES (nombre, email, rol, contrasena);
END;
$$;

CREATE OR REPLACE FUNCTION LeerUsuario(id INT)
RETURNS TABLE(id_usuario INT, nombre VARCHAR, email VARCHAR, rol rol_usuario, contrasena VARCHAR, fecha_creacion TIMESTAMP)
AS $$
BEGIN
    RETURN QUERY
    SELECT u.id_usuario, u.nombre, u.email, u.rol, u.contrasena, u.fecha_creacion
    FROM Usuarios u
    WHERE u.id_usuario = id;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE PROCEDURE ActualizarUsuario(
    IN p_id_usuario INT,
    IN p_nombre VARCHAR,
    IN p_email VARCHAR,
    IN p_rol rol_usuario,
    IN p_contrasena VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE Usuarios
    SET nombre = p_nombre,
        email = p_email,
        rol = p_rol,
        contrasena = p_contrasena
    WHERE id_usuario = p_id_usuario;
END;
$$;


CREATE OR REPLACE PROCEDURE eliminarusuario(id INTEGER)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Verificar si hay comentarios relacionados
    IF EXISTS (
        SELECT 1 FROM comentarios WHERE id_estudiante = id
    ) THEN
        RAISE EXCEPTION 'No se puede eliminar el usuario con ID % porque tiene comentarios relacionados.', id;
    END IF;

    -- Si no hay comentarios, borrar el usuario
    DELETE FROM usuarios WHERE id_usuario = id;
END;
$$;


-- Asignaturas
CREATE OR REPLACE PROCEDURE CrearAsignatura(nombre VARCHAR, id_docente INT)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO Asignaturas (nombre_asignatura, id_docente) VALUES (nombre, id_docente);
END;
$$;

CREATE OR REPLACE FUNCTION LeerAsignatura(id INT)
RETURNS TABLE(id_asignatura INT, nombre_asignatura VARCHAR, id_docente INT)
AS $$
BEGIN
    RETURN QUERY
    SELECT a.id_asignatura, a.nombre_asignatura, a.id_docente
    FROM Asignaturas a
    WHERE a.id_asignatura = id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE ActualizarAsignatura(id INT, nombre VARCHAR, docente_id INT)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE Asignaturas SET nombre_asignatura = nombre, id_docente = docente_id WHERE id_asignatura = id;
END;
$$;

CREATE OR REPLACE PROCEDURE EliminarAsignatura(id INT)
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM Asignaturas WHERE id_asignatura = id;
END;
$$;


-- Evaluaciones
CREATE OR REPLACE PROCEDURE CrearEvaluacion(fecha_inicio DATE, fecha_fin DATE, estado estado_evaluacion, descripcion TEXT)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO Evaluaciones (fecha_inicio, fecha_fin, estado, descripcion)
    VALUES (fecha_inicio, fecha_fin, estado, descripcion);
END;
$$;

CREATE OR REPLACE FUNCTION LeerEvaluacion(id INT)
RETURNS TABLE(id_evaluacion INT, fecha_inicio DATE, fecha_fin DATE, estado estado_evaluacion, descripcion TEXT)
AS $$
BEGIN
    RETURN QUERY
    SELECT e.id_evaluacion, e.fecha_inicio, e.fecha_fin, e.estado, e.descripcion
    FROM Evaluaciones e
    WHERE e.id_evaluacion = id;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE PROCEDURE ActualizarEvaluacion(id INT, fech_inicio DATE, fech_fin DATE, estado_e estado_evaluacion, descripcion_e TEXT)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE Evaluaciones SET fecha_inicio = fech_inicio, fecha_fin = fech_fin,
    estado = estado_e, descripcion = descripcion_e WHERE id_evaluacion = id;
END;
$$;

CREATE OR REPLACE PROCEDURE EliminarEvaluacion(id INT)
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM Evaluaciones WHERE id_evaluacion = id;
END;
$$;


-- Comentarios
CREATE OR REPLACE PROCEDURE InsertarComentario(id_estudiante INT, id_docente INT, id_asignatura INT, id_evaluacion INT, comentario TEXT)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO Comentarios (id_estudiante, id_docente, id_asignatura, id_evaluacion, comentario)
    VALUES (id_estudiante, id_docente, id_asignatura, id_evaluacion, comentario);
END;
$$;

CREATE OR REPLACE FUNCTION LeerComentario(id INT)
RETURNS TABLE(
    id_comentario INT,
    id_estudiante INT,
    id_docente INT,
    id_asignatura INT,
    id_evaluacion INT,
    contenido TEXT,
    fecha_creacion TIMESTAMP
)
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        c.id_comentario,
        c.id_estudiante,
        c.id_docente,
        c.id_asignatura,
        c.id_evaluacion,
        c.comentario AS contenido,
        c.fecha_creacion
    FROM Comentarios c
    WHERE c.id_comentario = id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE ActualizarComentario(
    IN id INT,
    IN id_est INT,
    IN id_doc INT,
    IN id_asig INT,
    IN id_eval INT,
    IN comentario_in TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE Comentarios
    SET 
        id_estudiante = id_est,
        id_docente = id_doc,
        id_asignatura = id_asig,
        id_evaluacion = id_eval,
        comentario = comentario_in
    WHERE id_comentario = id;
END;
$$;

CREATE OR REPLACE PROCEDURE EliminarComentario(id INT)
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM Comentarios WHERE id_comentario = id;
END;
$$;


-- Triggers
-- Trigger de creación de Usuario

CREATE OR REPLACE FUNCTION validar_email_unico()
RETURNS TRIGGER AS $$
DECLARE
    existe INT;
BEGIN
    SELECT COUNT(*) INTO existe FROM Usuarios WHERE email = NEW.email;
    
    IF existe > 0 THEN
        RAISE EXCEPTION 'El nuevo usuario no puede tener email repetido, utilice un email diferente a (%)', NEW.email;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER email_unico_trigger
BEFORE INSERT ON Usuarios
FOR EACH ROW
EXECUTE FUNCTION validar_email_unico();


-- Trigger para no permitir borrar usuarios admin
CREATE OR REPLACE FUNCTION proteger_admin()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.rol = 'Administrador' THEN
        RAISE EXCEPTION 'No se puede eliminar un administrador.';
    END IF;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_proteger_admin
BEFORE DELETE ON Usuarios
FOR EACH ROW
EXECUTE FUNCTION proteger_admin();


-- Trigger de creación de evaluación

CREATE OR REPLACE FUNCTION validar_evaluacion_descripcion()
RETURNS trigger AS $$
BEGIN
    IF NEW.descripcion = OLD.descripcion THEN
        RAISE EXCEPTION 'La evaluación ya se encuentra en la base de datos.';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER validar_evaluacion
BEFORE UPDATE ON Evaluaciones
FOR EACH ROW
EXECUTE FUNCTION validar_evaluacion_descripcion();


-- Trigger de inserción de comentarios

CREATE OR REPLACE FUNCTION validar_comentario_asignatura_evaluacion()
RETURNS trigger AS $$
BEGIN
    IF NEW.id_asignatura = OLD.id_asignatura AND NEW.id_evaluacion = OLD.id_evaluacion THEN
        RAISE EXCEPTION 'La evaluación de la asignatura en cuestión ya se ha introducido.';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER validar_comentario
BEFORE UPDATE ON Comentarios
FOR EACH ROW
EXECUTE FUNCTION validar_comentario_asignatura_evaluacion();