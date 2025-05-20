-- Crear la base de datos
CREATE DATABASE IF NOT EXISTS nlp_comentarios;
\c nlp_comentarios;

-- Tabla de Usuarios
CREATE TABLE IF NOT EXISTS Usuarios (
    id_usuario SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    rol VARCHAR(20) CHECK (rol IN ('Administrador', 'Estudiante', 'Docente')) NOT NULL,
    contrasena VARCHAR(255) NOT NULL,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Crear tabla Docente
CREATE TABLE IF NOT EXISTS Docente (
    id_docente INT PRIMARY KEY,
    titulo VARCHAR(150) NOT NULL,
    certificado VARCHAR(255), -- Puede ser la ruta del archivo o un enlace
    FOREIGN KEY (id_docente) REFERENCES Usuarios(id_usuario) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Crear tabla Estudiante
CREATE TABLE IF NOT EXISTS Estudiante (
    id_estudiante INT PRIMARY KEY,
    estado VARCHAR(20) CHECK (estado IN ('Activo', 'Inactivo')) DEFAULT 'Activo',
    codigo VARCHAR(20) UNIQUE NOT NULL,
    telefono VARCHAR(15),
    cuenta_social VARCHAR(255),
    FOREIGN KEY (id_estudiante) REFERENCES Usuarios(id_usuario) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Crear tabla Administrativos
CREATE TABLE IF NOT EXISTS Administrativos (
    id_administrativo INT PRIMARY KEY,
    area VARCHAR(100) NOT NULL,
    cargo VARCHAR(100) NOT NULL,
    telefono VARCHAR(15),
    correo_institucional VARCHAR(100) UNIQUE,
    FOREIGN KEY (id_administrativo) REFERENCES Usuarios(id_usuario) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Tabla de Asignaturas
CREATE TABLE IF NOT EXISTS Asignaturas (
    id_asignatura SERIAL PRIMARY KEY,
    nombre_asignatura VARCHAR(100) NOT NULL,
    creditos INT,
    id_docente INT,
    FOREIGN KEY (id_docente) REFERENCES Usuarios(id_usuario)
);

-- Tabla de Evaluaciones
CREATE TABLE IF NOT EXISTS Evaluaciones (
    id_evaluacion SERIAL PRIMARY KEY,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NOT NULL,
    estado VARCHAR(20) CHECK (estado IN ('Activo', 'Inactivo')) DEFAULT 'Inactivo',
    descripcion TEXT
);

-- Tabla de Comentarios
CREATE TABLE IF NOT EXISTS Comentarios (
    id_comentario SERIAL PRIMARY KEY,
    id_estudiante INT,
    id_docente INT,
    id_asignatura INT,
    id_evaluacion INT,
    comentario TEXT NOT NULL,
    sentimiento VARCHAR(10)
        CHECK (sentimiento IN ('positivo', 'negativo', 'neutral')),
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_estudiante) REFERENCES Usuarios(id_usuario),
    FOREIGN KEY (id_docente) REFERENCES Usuarios(id_usuario),
    FOREIGN KEY (id_asignatura) REFERENCES Asignaturas(id_asignatura),
    FOREIGN KEY (id_evaluacion) REFERENCES Evaluaciones(id_evaluacion)
);

-- Tabla de Análisis de Sentimientos
CREATE TABLE IF NOT EXISTS Analisis_sentimientos (
    id_analisis SERIAL PRIMARY KEY,
    id_comentario INT,
    sentimiento VARCHAR(20) CHECK (sentimiento IN ('Positivo', 'Negativo', 'Neutral')),
    resumen TEXT,
    puntuacion DECIMAL(3,2),
    FOREIGN KEY (id_comentario) REFERENCES Comentarios(id_comentario)
);

-- Tabla de Reportes
CREATE TABLE IF NOT EXISTS Reportes (
    id_reporte SERIAL PRIMARY KEY,
    id_docente INT,
    fecha_generacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    contenido TEXT,
    formato VARCHAR(10) CHECK (formato IN ('PDF', 'Excel')),
    FOREIGN KEY (id_docente) REFERENCES Usuarios(id_usuario)
);

-- Tabla de Semestre
CREATE TABLE IF NOT EXISTS Semestre (
    id_semestre SERIAL PRIMARY KEY,
    nombre_semestre VARCHAR(50) NOT NULL,
    periodo YEAR NOT NULL,
    fecha_inicio DATE NOT NULL,
    fecha_final DATE NOT NULL
);

-- Tabla de Programa
CREATE TABLE IF NOT EXISTS Programa (
    id_programa SERIAL PRIMARY KEY,
    nombre_programa VARCHAR(50) NOT NULL,
    codigo VARCHAR(50) NOT NULL
);

-- Tabla de Materias_Docentes_Semestre
CREATE TABLE IF NOT EXISTS MDS (
    id_mds SERIAL PRIMARY KEY,
    id_docente INT,
    id_asignatura INT,
    id_semestre INT,
    FOREIGN KEY (id_docente) REFERENCES Docente(id_docente),
    FOREIGN KEY (id_asignatura) REFERENCES Asignaturas(id_asignatura),
    FOREIGN KEY (id_semestre) REFERENCES Semestre(id_semestre)
);

-- Tabla Materia Estudiante
CREATE TABLE IF NOT EXISTS ME (
    id_me SERIAL PRIMARY KEY,
    id_estudiante INT,
    id_asignatura INT,
    FOREIGN KEY (id_estudiante) REFERENCES Estudiante(id_estudiante),
    FOREIGN KEY (id_asignatura) REFERENCES Asignaturas(id_asignatura)
);

-- Índices
CREATE INDEX idx_usuario_rol ON Usuarios(rol);
CREATE INDEX idx_comentario_fecha ON Comentarios(fecha_creacion);
CREATE INDEX idx_analisis_sentimiento ON Analisis_sentimientos(sentimiento);

-- Datos iniciales
INSERT INTO Usuarios (nombre, email, rol, contrasena)
VALUES 
('Nicolas Vargas', 'nicolas@hotmail.com', 'Estudiante', '123'),
('Ana Maria', 'ana@hotmail.com', 'Docente', '123'),
('Pablo Diago', 'diago@hotmail.com', 'Administrador', '123');

INSERT INTO Asignaturas (nombre_asignatura, id_docente)
VALUES
('Ingeniería de software', 2),
('Base de datos', 2),
('Complejidad Algorítmica', 2);

INSERT INTO Evaluaciones (fecha_inicio, fecha_fin, estado, descripcion)
VALUES
('2025-03-01', '2025-03-31', 'Activo', 'Evaluación del primer trimestre.'),
('2025-06-01', '2025-06-30', 'Inactivo', 'Evaluación del segundo trimestre.'),
('2025-09-01', '2025-09-30', 'Inactivo', 'Evaluación del tercer trimestre.');

INSERT INTO Comentarios (id_estudiante, id_docente, id_asignatura, id_evaluacion, comentario)
VALUES
(1, 2, 1, 1, 'La profesora explica muy bien los temas.'),
(1, 2, 2, 2, 'Las clases fueron interesantes pero algo rápidas.'),
(1, 2, 3, 1, 'Me gustó el enfoque práctico que se usó.');

-- Índices
CREATE INDEX idx_usuario_rol ON Usuarios(rol);
CREATE INDEX idx_comentario_fecha ON Comentarios(fecha_creacion);
CREATE INDEX idx_analisis_sentimiento ON Analisis_sentimientos(sentimiento);

CREATE TYPE rol_usuario AS ENUM ('Estudiante', 'Docente', 'Administrativo');
CREATE TYPE estado_evaluacion AS ENUM ('Activo', 'Inactivo');


-- PROCEDIMIENTOS ALMACENADOS

-- Usuarios
CREATE OR REPLACE PROCEDURE CrearUsuario(nombre VARCHAR, email VARCHAR, rol rol_usuario, contrasena VARCHAR)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO Usuarios (nombre, email, rol, contrasena)
    VALUES (nombre, email, rol, contrasena);
END;
$$;

CREATE OR REPLACE FUNCTION LeerUsuario(id integer)
RETURNS TABLE (id_usuario integer, nombre character varying, email character varying, rol character varying) AS
$$
BEGIN
    RETURN QUERY
    SELECT u.id_usuario, u.nombre, u.email, u.rol
    FROM usuarios u
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

CREATE OR REPLACE PROCEDURE EliminarUsuario(id INTEGER)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Verificar si hay comentarios relacionados
    IF EXISTS (
        SELECT 1 FROM Comentarios WHERE id_estudiante = id
    ) THEN
        RAISE EXCEPTION 'No se puede eliminar el usuario con ID % porque tiene comentarios relacionados.', id;
    END IF;

    -- Si no hay comentarios, borrar el usuario
    DELETE FROM Usuarios WHERE id_usuario = id;
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
RETURNS TABLE (
    id_asignatura INT,
    nombre_asignatura TEXT,
    id_docente INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT a.id_asignatura, a.nombre_asignatura, a.id_docente
    FROM Asignaturas a
    WHERE a.id_asignatura = id;
END;
$$;

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

CREATE OR REPLACE FUNCTION LeerEvaluacion(id integer)
RETURNS TABLE (
    id_evaluacion integer,
    fecha_inicio date,
    fecha_fin date,
    estado varchar(20),
    descripcion text
) AS $$
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
CREATE OR REPLACE PROCEDURE InsertarComentario(
    id_estudiante INT, 
    id_docente INT, 
    id_asignatura INT, 
    id_evaluacion INT, 
    comentario TEXT,
    sentimiento TEXT -- ← Nuevo campo
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO Comentarios (
        id_estudiante, 
        id_docente, 
        id_asignatura, 
        id_evaluacion, 
        comentario,
        sentimiento -- ← Añadirlo en la inserción
    )
    VALUES (
        id_estudiante, 
        id_docente, 
        id_asignatura, 
        id_evaluacion, 
        comentario,
        sentimiento -- ← Guardar el sentimiento
    );
END;
$$;

CREATE OR REPLACE FUNCTION LeerComentario(id INT)
RETURNS TABLE (
    id_comentario INT,
    id_estudiante INT,
    id_docente INT,
    id_asignatura INT,
    id_evaluacion INT,
    contenido TEXT,
    fecha_creacion TIMESTAMP
)
LANGUAGE plpgsql
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
$$;

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
--Funciones

--Función para mostar sentimientos como porcentaje
CREATE OR REPLACE FUNCTION resumen_sentimientos_global()
RETURNS TABLE (
    sentimiento VARCHAR,
    total INTEGER,
    porcentaje NUMERIC
)
AS $$
BEGIN
  RETURN QUERY
  WITH total_sentimientos AS (
    SELECT CAST(LOWER(c.sentimiento) AS VARCHAR) AS sentimiento_val,
           CAST(COUNT(*) AS INTEGER) AS total_val
    FROM comentarios c
    WHERE c.sentimiento IS NOT NULL
    GROUP BY LOWER(c.sentimiento)
  ),
  total_general AS (
    SELECT SUM(ts.total_val) AS total_general_val FROM total_sentimientos ts
  )
  SELECT 
    ts.sentimiento_val AS sentimiento,
    ts.total_val AS total,
    ROUND((ts.total_val * 100.0) / tg.total_general_val, 2) AS porcentaje
  FROM total_sentimientos ts, total_general tg;
END;
$$ LANGUAGE plpgsql;


-- TRIGGERS

-- Trigger de creación de Usuario
CREATE OR REPLACE FUNCTION validar_email_unico()
RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM Usuarios WHERE email = NEW.email) THEN
        RAISE EXCEPTION 'El correo electrónico "%" ya está registrado.', NEW.email;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para ejecutar la función antes de insertar en Usuarios
CREATE TRIGGER trigger_validar_email
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

-- Trigger para evitar campos nulos al ingresar y actualizar el usuario
CREATE OR REPLACE FUNCTION validar_campos_usuario()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.nombre IS NULL OR TRIM(NEW.nombre) = '' THEN
        RAISE EXCEPTION 'Error: El nombre no puede estar vacío.';
    END IF;

    IF NEW.email IS NULL OR TRIM(NEW.email) = '' THEN
        RAISE EXCEPTION 'Error: El email no puede estar vacío.';
    END IF;

    IF NEW.rol IS NULL OR TRIM(NEW.rol::TEXT) = '' THEN
        RAISE EXCEPTION 'Error: El rol no puede estar vacío.';
    END IF;

    IF NEW.contrasena IS NULL OR TRIM(NEW.contrasena) = '' THEN
        RAISE EXCEPTION 'Error: La contraseña no puede estar vacía.';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_validar_usuario_insert
BEFORE INSERT ON Usuarios
FOR EACH ROW
EXECUTE FUNCTION validar_campos_usuario();

CREATE TRIGGER trigger_validar_usuario_update
BEFORE UPDATE ON Usuarios
FOR EACH ROW
EXECUTE FUNCTION validar_campos_usuario();

-- Trigger de inserción de comentarios
