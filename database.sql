-- Crear la base de datos y usarla
CREATE DATABASE IF NOT EXISTS nlp_comentarios;
USE nlp_comentarios;

-- Tabla Usuarios
CREATE TABLE IF NOT EXISTS Usuarios (
    id_usuario INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    rol ENUM('Administrador', 'Estudiante', 'Docente') NOT NULL,
    contrasena VARCHAR(255) NOT NULL,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla Docente
CREATE TABLE IF NOT EXISTS Docente (
    id_docente INT PRIMARY KEY,
    titulo VARCHAR(150) NOT NULL,
    certificado VARCHAR(255),
    CONSTRAINT fk_docente_usuario FOREIGN KEY (id_docente) REFERENCES Usuarios(id_usuario) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Tabla Estudiante
CREATE TABLE IF NOT EXISTS Estudiante (
    id_estudiante INT PRIMARY KEY,
    estado ENUM('Activo', 'Inactivo') DEFAULT 'Activo',
    codigo VARCHAR(20) NOT NULL UNIQUE,
    telefono VARCHAR(15),
    cuenta_social VARCHAR(255),
    CONSTRAINT fk_estudiante_usuario FOREIGN KEY (id_estudiante) REFERENCES Usuarios(id_usuario) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Tabla Administrativos
CREATE TABLE IF NOT EXISTS Administrativos (
    id_administrativo INT PRIMARY KEY,
    area VARCHAR(100) NOT NULL,
    cargo VARCHAR(100) NOT NULL,
    telefono VARCHAR(15),
    correo_institucional VARCHAR(100) UNIQUE,
    CONSTRAINT fk_administrativo_usuario FOREIGN KEY (id_administrativo) REFERENCES Usuarios(id_usuario) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Tabla Asignaturas
CREATE TABLE IF NOT EXISTS Asignaturas (
    id_asignatura INT AUTO_INCREMENT PRIMARY KEY,
    nombre_asignatura VARCHAR(100) NOT NULL,
    creditos INT,
    id_docente INT,
    CONSTRAINT fk_asignatura_docente FOREIGN KEY (id_docente) REFERENCES Usuarios(id_usuario)
);

-- Tabla Evaluaciones
CREATE TABLE IF NOT EXISTS Evaluaciones (
    id_evaluacion INT AUTO_INCREMENT PRIMARY KEY,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NOT NULL,
    estado ENUM('Activo', 'Inactivo') DEFAULT 'Inactivo',
    descripcion TEXT
);

-- Tabla Comentarios
CREATE TABLE IF NOT EXISTS Comentarios (
    id_comentario INT AUTO_INCREMENT PRIMARY KEY,
    id_estudiante INT,
    id_docente INT,
    id_asignatura INT,
    promedio INT CHECK (promedio BETWEEN 1 AND 5),
    comentario TEXT NOT NULL,
    sentimiento ENUM('positivo', 'negativo', 'neutral'),
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_comentario_estudiante FOREIGN KEY (id_estudiante) REFERENCES Usuarios(id_usuario),
    CONSTRAINT fk_comentario_docente FOREIGN KEY (id_docente) REFERENCES Usuarios(id_usuario),
    CONSTRAINT fk_comentario_asignatura FOREIGN KEY (id_asignatura) REFERENCES Asignaturas(id_asignatura)
);

-- Tabla Analisis_sentimientos
CREATE TABLE IF NOT EXISTS Analisis_sentimientos (
    id_analisis INT AUTO_INCREMENT PRIMARY KEY,
    id_comentario INT,
    sentimiento ENUM('Positivo', 'Negativo', 'Neutral'),
    resumen TEXT,
    puntuacion DECIMAL(3,2),
    CONSTRAINT fk_analisis_comentario FOREIGN KEY (id_comentario) REFERENCES Comentarios(id_comentario)
);

-- Tabla Reportes
CREATE TABLE IF NOT EXISTS Reportes (
    id_reporte INT AUTO_INCREMENT PRIMARY KEY,
    id_docente INT,
    fecha_generacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    contenido TEXT,
    formato ENUM('PDF', 'Excel'),
    CONSTRAINT fk_reporte_docente FOREIGN KEY (id_docente) REFERENCES Usuarios(id_usuario)
);

-- Tabla Semestre
CREATE TABLE IF NOT EXISTS Semestre (
    id_semestre INT AUTO_INCREMENT PRIMARY KEY,
    nombre_semestre VARCHAR(50) NOT NULL,
    periodo YEAR NOT NULL,
    fecha_inicio DATE NOT NULL,
    fecha_final DATE NOT NULL
);

-- Tabla Programa
CREATE TABLE IF NOT EXISTS Programa (
    id_programa INT AUTO_INCREMENT PRIMARY KEY,
    nombre_programa VARCHAR(50) NOT NULL,
    codigo VARCHAR(50) NOT NULL
);

-- Tabla Materias_Docentes_Semestre (MDS)
CREATE TABLE IF NOT EXISTS MDS (
    id_mds INT AUTO_INCREMENT PRIMARY KEY,
    id_docente INT,
    id_asignatura INT,
    id_semestre INT,
    CONSTRAINT fk_mds_docente FOREIGN KEY (id_docente) REFERENCES Docente(id_docente),
    CONSTRAINT fk_mds_asignatura FOREIGN KEY (id_asignatura) REFERENCES Asignaturas(id_asignatura),
    CONSTRAINT fk_mds_semestre FOREIGN KEY (id_semestre) REFERENCES Semestre(id_semestre)
);

-- Tabla Materia Estudiante (ME)
CREATE TABLE IF NOT EXISTS ME (
    id_me INT AUTO_INCREMENT PRIMARY KEY,
    id_estudiante INT,
    id_asignatura INT,
    CONSTRAINT fk_me_estudiante FOREIGN KEY (id_estudiante) REFERENCES Estudiante(id_estudiante),
    CONSTRAINT fk_me_asignatura FOREIGN KEY (id_asignatura) REFERENCES Asignaturas(id_asignatura)
);

-- Usuarios: mínimo 5
INSERT INTO Usuarios (nombre, email, rol, contrasena)
VALUES
('Nicolas Vargas', 'nicolas@uniautonoma.edu.co', 'Estudiante', '123'),
('Carlos Mendoza', 'carlosm@uniautonoma.edu.co', 'Estudiante', '123'),
('Laura Pérez', 'laura.perez@uniautonoma.edu.co', 'Docente', '123'),
('Miguel Soto', 'miguel.soto@uniautonoma.edu.co', 'Docente', '123'),
('Elena Ruiz', 'elena.ruiz@uniautonoma.edu.co', 'Administrador', '123'),
('Ana maría', 'anamaria@uniautonoma.edu.co', 'Docente', '123'),
('Diego Prado', 'diegoprado@uniautonoma.edu.co', 'Docente', '123'),
('Christian Cañar', 'christiancañar@Uniautonoma.edu.co', 'Docente', '123'),
('Andrés Torres', 'andres.torres@Uniautonoma.edu.co', 'Administrador', 'admin123'),
('Sofía Martínez', 'sofia.martinez@Uniautonoma.edu.co', 'Administrador', 'admin123'),
('Luis Ramírez', 'luis.ramirez@Uniautonoma.edu.co', 'Administrador', 'admin123'),
('Camila Herrera', 'camila.herrera@Uniautonoma.edu.co', 'Administrador', 'admin123'),
('Fernando López', 'fernando.lopez@Uniautonoma.edu.co', 'Administrador', 'admin123');

-- Docentes: 5 (deben estar en Usuarios con rol 'Docente')
INSERT INTO Docente (id_docente, titulo, certificado)
VALUES
(3, 'Ingeniera de Sistemas', 'certificados/ana_maria.pdf'),
(4, 'Licenciado en Matemáticas', 'certificados/laura_perez.pdf'),
(6, 'Magíster en Ciencias de la Computación', 'certificados/miguel_soto.pdf'),
(7, 'Doctor en Educación', 'certificados/javier_garcia.pdf'),
(8, 'Ingeniero en Informática', 'certificados/paula_gomez.pdf');

-- Estudiantes: 5 (deben estar en Usuarios con rol 'Estudiante')
INSERT INTO Estudiante (id_estudiante, estado, codigo, telefono, cuenta_social)
VALUES
(1, 'Activo', 'EST1001', '555-1234', '@nicolasvargas'),
(2, 'Activo', 'EST1002', '555-5678', '@carlosm'),
(9, 'Inactivo', 'EST1003', '555-8765', '@juan_rodriguez'),
(10, 'Activo', 'EST1004', '555-4321', '@laura_gomez'),
(11, 'Activo', 'EST1005', '555-1357', '@mariafernandez');

-- Administrativos: 5 (deben estar en Usuarios con rol 'Administrativo')
INSERT INTO Administrativos (id_administrativo, area, cargo, telefono, correo_institucional)
VALUES
(5, 'Recursos Humanos', 'Coordinadora', '555-2468', 'elena.ruiz@uni.edu'),
(12, 'Admisiones', 'Asistente', '555-9753', 'andres.lopez@uni.edu'),
(13, 'Contabilidad', 'Analista', '555-8642', 'paula.martinez@uni.edu'),
(9, 'Tecnología', 'Soporte Técnico', '555-7531', 'jorge.mendez@uni.edu'),
(10, 'Biblioteca', 'Administrador', '555-1597', 'marta.vargas@uni.edu');

-- Asignaturas: 5
INSERT INTO Asignaturas (nombre_asignatura, id_docente)
VALUES
('Algoritmos y estructuras de datos', 4),
('Bases de datos avanzadas', 5),
('Sistemas operativos', 6),
('Redes de computadoras', 7),
('Inteligencia Artificial', 2);

-- Evaluaciones: 5
INSERT INTO Evaluaciones (fecha_inicio, fecha_fin, estado, descripcion)
VALUES
('2025-01-01', '2025-01-31', 'Inactivo', 'Evaluación inicial del semestre.'),
('2025-04-01', '2025-04-30', 'Activo', 'Evaluación de mitad de semestre.'),
('2025-07-01', '2025-07-31', 'Inactivo', 'Evaluación de seguimiento.'),
('2025-10-01', '2025-10-31', 'Inactivo', 'Evaluación final.'),
('2025-11-01', '2025-11-15', 'Inactivo', 'Evaluación especial.');

-- Comentarios: 5
INSERT INTO Comentarios (id_estudiante, id_docente, id_asignatura, comentario, sentimiento, promedio)
VALUES 
(1, 2, 1, 'Muy buena metodología.', 'positivo', 4.5),
(8, 4, 2, 'El docente explica con claridad.', 'positivo', 4.0),
(9, 5, 3, 'A veces las clases son confusas.', 'negativo', 2.8),
(10, 6, 4, 'Excelente manejo del tema.', 'positivo', 4.9),
(11, 7, 5, 'Podría mejorar la interacción.', 'neutral', 3.2);

-- Análisis de Sentimientos: 5
INSERT INTO Analisis_sentimientos (id_comentario, sentimiento, resumen, puntuacion)
VALUES
(1, 'Positivo', 'Comentario favorable sobre la metodología.', 0.95),
(2, 'Positivo', 'Explicaciones claras.', 0.90),
(3, 'Negativo', 'Confusión en algunas clases.', 0.30),
(4, 'Positivo', 'Excelente manejo.', 0.97),
(5, 'Neutral', 'Comentario con sugerencias.', 0.60);

-- Reportes: 5
INSERT INTO Reportes (id_docente, contenido, formato)
VALUES
(2, 'Reporte del primer trimestre.', 'PDF'),
(4, 'Reporte del segundo trimestre.', 'Excel'),
(5, 'Reporte de evaluación especial.', 'PDF'),
(6, 'Reporte de actividades académicas.', 'Excel'),
(7, 'Reporte final del semestre.', 'PDF');

-- Semestre: 5
INSERT INTO Semestre (nombre_semestre, periodo, fecha_inicio, fecha_final)
VALUES
('Semestre 2024-1', 2024, '2024-01-01', '2024-06-30'),
('Semestre 2024-2', 2024, '2024-07-01', '2024-12-31'),
('Semestre 2025-1', 2025, '2025-01-01', '2025-06-30'),
('Semestre 2025-2', 2025, '2025-07-01', '2025-12-31'),
('Semestre 2026-1', 2026, '2026-01-01', '2026-06-30');

-- Programa: 5
INSERT INTO Programa (nombre_programa, codigo)
VALUES
('Ingeniería de Sistemas', 'IS2025'),
('Ciencias de la Computación', 'CC2025'),
('Matemáticas Aplicadas', 'MA2025'),
('Administración de Empresas', 'AE2025'),
('Psicología', 'PSI2025');

-- MDS (Materia-Docente-Semestre): 5
INSERT INTO MDS (id_docente, id_asignatura, id_semestre)
VALUES
(3, 1, 1),
(4, 2, 2),
(8, 3, 3),
(6, 4, 4),
(7, 5, 5);

-- ME (Materia-Estudiante): 5
INSERT INTO ME (id_estudiante, id_asignatura)
VALUES
(1, 1),
(2, 2),
(9, 3),
(10, 4),
(11, 5);


-- PROCEDIMIENTOS ALMACENADOS
-- Docentes por estudiante:id

DELIMITER $$

CREATE PROCEDURE docentes_por_estudiantes(IN p_id_estudiante INT)
BEGIN
    SELECT 
        me.id_estudiante,
        u.id_usuario AS id_docente,
        u.nombre AS nombre_docente,
        a.id_asignatura,
        a.nombre_asignatura
    FROM 
        ME me
    JOIN 
        Asignaturas a ON me.id_asignatura = a.id_asignatura
    JOIN 
        MDS mds ON a.id_asignatura = mds.id_asignatura
    JOIN 
        Docente d ON mds.id_docente = d.id_docente
    JOIN 
        Usuarios u ON d.id_docente = u.id_usuario
    WHERE 
        me.id_estudiante = p_id_estudiante;
END $$

DELIMITER ;


-- Validar Login
DELIMITER $$

CREATE PROCEDURE obtener_usuario_por_email (
    IN p_email VARCHAR(100)
)
BEGIN
    SELECT id_usuario, nombre, rol, contrasena, email
    FROM Usuarios
    WHERE email = p_email;
END$$

DELIMITER ;

-- Usuarios
DELIMITER //

CREATE PROCEDURE CrearUsuario (
    IN p_nombre VARCHAR(100),
    IN p_email VARCHAR(100),
    IN p_rol ENUM('Administrador', 'Estudiante', 'Docente', 'Administrativo'),
    IN p_contrasena VARCHAR(255)
)
BEGIN
    INSERT INTO Usuarios (nombre, email, rol, contrasena)
    VALUES (p_nombre, p_email, p_rol, p_contrasena);
END;
//

DELIMITER ;

DELIMITER //

CREATE PROCEDURE LeerUsuario (
    IN p_id INT
)
BEGIN
    SELECT id_usuario, nombre, email, rol
    FROM Usuarios
    WHERE id_usuario = p_id;
END;
//

DELIMITER ;

DELIMITER //

CREATE PROCEDURE ActualizarUsuario (
    IN p_id_usuario INT,
    IN p_nombre VARCHAR(100),
    IN p_email VARCHAR(100),
    IN p_rol ENUM('Administrador', 'Estudiante', 'Docente', 'Administrativo'),
    IN p_contrasena VARCHAR(255)
)
BEGIN
    UPDATE Usuarios
    SET nombre = p_nombre,
        email = p_email,
        rol = p_rol,
        contrasena = p_contrasena
    WHERE id_usuario = p_id_usuario;
END;
//

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE EliminarUsuario (
    IN p_id INT
)
BEGIN
    DECLARE msg TEXT;

    -- Verificar si hay comentarios relacionados
    IF EXISTS (SELECT 1 FROM Comentarios WHERE id_estudiante = p_id) THEN
        SET msg = CONCAT('No se puede eliminar el usuario con ID ', p_id, ' porque tiene comentarios relacionados.');
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = msg;
    ELSE
        -- Si no hay comentarios, borrar el usuario
        DELETE FROM Usuarios WHERE id_usuario = p_id;
    END IF;
END$$

DELIMITER ;


DELIMITER ;


-- Asignaturas
DELIMITER //

CREATE PROCEDURE CrearAsignatura (
    IN p_nombre VARCHAR(100),
    IN p_id_docente INT
)
BEGIN
    INSERT INTO Asignaturas (nombre_asignatura, id_docente)
    VALUES (p_nombre, p_id_docente);
END;
//

DELIMITER ;

DELIMITER //

CREATE PROCEDURE LeerAsignatura (
    IN p_id INT
)
BEGIN
    SELECT id_asignatura, nombre_asignatura, id_docente
    FROM Asignaturas
    WHERE id_asignatura = p_id;
END;
//

DELIMITER ;

DELIMITER //

CREATE PROCEDURE ActualizarAsignatura (
    IN p_id INT,
    IN p_nombre VARCHAR(100),
    IN p_id_docente INT
)
BEGIN
    UPDATE Asignaturas
    SET nombre_asignatura = p_nombre,
        id_docente = p_id_docente
    WHERE id_asignatura = p_id;
END;
//

DELIMITER ;

DELIMITER //

CREATE PROCEDURE EliminarAsignatura (
    IN p_id INT
)
BEGIN
    DELETE FROM Asignaturas
    WHERE id_asignatura = p_id;
END;
//

DELIMITER ;


-- Evaluaciones
DELIMITER //

CREATE PROCEDURE CrearEvaluacion (
    IN p_fecha_inicio DATE,
    IN p_fecha_fin DATE,
    IN p_estado VARCHAR(20),
    IN p_descripcion TEXT
)
BEGIN
    INSERT INTO Evaluaciones (fecha_inicio, fecha_fin, estado, descripcion)
    VALUES (p_fecha_inicio, p_fecha_fin, p_estado, p_descripcion);
END;
//

DELIMITER ;

DELIMITER //

CREATE PROCEDURE LeerEvaluacion (
    IN p_id INT
)
BEGIN
    SELECT id_evaluacion, fecha_inicio, fecha_fin, estado, descripcion
    FROM Evaluaciones
    WHERE id_evaluacion = p_id;
END;
//

DELIMITER ;

DELIMITER //

CREATE PROCEDURE ActualizarEvaluacion (
    IN p_id INT,
    IN p_fecha_inicio DATE,
    IN p_fecha_fin DATE,
    IN p_estado VARCHAR(20),
    IN p_descripcion TEXT
)
BEGIN
    UPDATE Evaluaciones
    SET fecha_inicio = p_fecha_inicio,
        fecha_fin = p_fecha_fin,
        estado = p_estado,
        descripcion = p_descripcion
    WHERE id_evaluacion = p_id;
END;
//

DELIMITER ;

DELIMITER //

CREATE PROCEDURE EliminarEvaluacion (
    IN p_id INT
)
BEGIN
    DELETE FROM Evaluaciones
    WHERE id_evaluacion = p_id;
END;
//

DELIMITER ;


-- Comentarios
DELIMITER //

CREATE PROCEDURE InsertarComentario(
    IN p_id_estudiante INT, 
    IN p_id_docente INT, 
    IN p_id_asignatura INT, 
    IN p_comentario TEXT,
    IN p_sentimiento TEXT,
    IN p_promedio INT
)
BEGIN
    INSERT INTO Comentarios (
        id_estudiante, 
        id_docente, 
        id_asignatura, 
        comentario,
        sentimiento,
        promedio
    )
    VALUES (
        p_id_estudiante, 
        p_id_docente, 
        p_id_asignatura, 
        p_comentario,
        p_sentimiento,
        p_promedio
    );
END;
//

DELIMITER ;


DELIMITER //

CREATE PROCEDURE LeerComentario(
    IN p_id INT
)
BEGIN
    SELECT 
        id_comentario,
        id_estudiante,
        id_docente,
        id_asignatura,
        id_evaluacion,
        comentario,
        fecha_creacion,
        sentimiento
    FROM Comentarios
    WHERE id_comentario = p_id;
END;
//

DELIMITER ;

DELIMITER $$

-- Busqueda por nombre de docente
DELIMITER $$

CREATE PROCEDURE ComentariosPorNombreDocente(IN nombre_docente VARCHAR(100))
BEGIN
    SELECT 
        c.id_comentario,
        c.id_estudiante,
        c.id_docente,
        c.id_asignatura,
        c.id_evaluacion,
        c.comentario,
        c.sentimiento,
        c.fecha_creacion
    FROM Comentarios c
    JOIN Usuarios u ON c.id_docente = u.id_usuario
    JOIN Docente d ON d.id_docente = u.id_usuario
    WHERE u.nombre = nombre_docente;
END$$

DELIMITER ;

-- Procedimiento para listar los docentes


DELIMITER //

CREATE PROCEDURE ActualizarComentario(
    IN p_id INT,
    IN p_id_est INT,
    IN p_id_doc INT,
    IN p_id_asig INT,
    IN p_id_eval INT,
    IN p_comentario TEXT,
    IN p_sentimiento TEXT
)
BEGIN
    UPDATE Comentarios
    SET 
        id_estudiante = p_id_est,
        id_docente = p_id_doc,
        id_asignatura = p_id_asig,
        id_evaluacion = p_id_eval,
        comentario = p_comentario,
        sentimiento = p_sentimiento
    WHERE id_comentario = p_id;
END;
//

DELIMITER ;

DELIMITER //

CREATE PROCEDURE EliminarComentario(
    IN p_id INT
)
BEGIN
    DELETE FROM Comentarios
    WHERE id_comentario = p_id;
END;
//

DELIMITER ;

DELIMITER //

CREATE PROCEDURE resumen_sentimientos_global()
BEGIN
    DECLARE total_count INT;

    -- Calcular total general
    SELECT COUNT(*) INTO total_count FROM comentarios;

    -- Mostrar resumen con porcentaje
    SELECT 
        sentimiento,
        COUNT(*) AS total,
        ROUND((COUNT(*) / total_count) * 100, 2) AS porcentaje
    FROM 
        comentarios
    GROUP BY 
        sentimiento;
END //

DELIMITER;

-- Funciones

-- Función para mostar sentimientos como porcentaje
WITH total_sentimientos AS (
    SELECT 
        LOWER(sentimiento) AS sentimiento,
        COUNT(*) AS total
    FROM comentarios
    WHERE sentimiento IS NOT NULL
    GROUP BY LOWER(sentimiento)
),
total_general AS (
    SELECT SUM(total) AS total_global
    FROM total_sentimientos
)
SELECT 
    ts.sentimiento,
    ts.total,
    ROUND((ts.total * 100.0) / tg.total_global, 2) AS porcentaje
-- FROM total_sentimientos ts, total_general tg;

-- Función para mostrar sentimientos por docente
DELIMITER $$

CREATE PROCEDURE resumen_sentimientos_por_nombre_docente(IN nombre_docente_input VARCHAR(255))
BEGIN
    SELECT 
        d.id_usuario AS id_docente,
        d.nombre AS nombre_docente,
        a.id_asignatura,
        a.nombre_asignatura,
        COUNT(c.id_comentario) AS total_comentarios,
        SUM(CASE WHEN LOWER(c.sentimiento) = 'positivo' THEN 1 ELSE 0 END) AS positivos,
        SUM(CASE WHEN LOWER(c.sentimiento) = 'neutral' THEN 1 ELSE 0 END) AS neutrales,
        SUM(CASE WHEN LOWER(c.sentimiento) = 'negativo' THEN 1 ELSE 0 END) AS negativos
    FROM comentarios c
    JOIN usuarios d ON c.id_docente = d.id_usuario
    JOIN asignaturas a ON c.id_asignatura = a.id_asignatura
    WHERE d.rol = 'Docente'
      AND LOWER(d.nombre) LIKE CONCAT('%', LOWER(nombre_docente_input), '%')
    GROUP BY d.id_usuario, d.nombre, a.id_asignatura, a.nombre_asignatura;
END$$

DELIMITER ;


-- TRIGGERS

-- Triger para validar la creación de usuarios ✅
DELIMITER $$

CREATE TRIGGER trigger_validar_email
BEFORE INSERT ON Usuarios
FOR EACH ROW
BEGIN
    DECLARE email_duplicado INT DEFAULT 0;
    DECLARE msg VARCHAR(255);

    SELECT COUNT(*) INTO email_duplicado
    FROM Usuarios
    WHERE email = NEW.email;

    IF email_duplicado > 0 THEN
        SET msg = CONCAT('El correo electrónico ', NEW.email, ' ya está registrado.');
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = msg;
    END IF;
END$$

DELIMITER ;

-- Triger para registrarse solo con correo institucional ✅
DELIMITER //

CREATE TRIGGER validar_email_institucional
BEFORE INSERT ON Usuarios
FOR EACH ROW
BEGIN
    -- Verifica si el nuevo email termina en '@uniautonoma.edu.co'
    IF RIGHT(LOWER(TRIM(NEW.email)), LENGTH('@uniautonoma.edu.co')) != '@uniautonoma.edu.co' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Solo se permiten correos institucionales (@uniautonoma.edu.co)';
    END IF;
END;
//
CREATE TRIGGER validar_email_institucional_update
BEFORE UPDATE ON Usuarios
FOR EACH ROW
BEGIN
    IF NEW.email NOT LIKE '%@uniautonoma.edu.co' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Solo se permiten correos @uniautonoma.edu.co';
    END IF;
END;
//

DELIMITER ;

-- Trigger para no permitir borrar usuarios admin ✅
DELIMITER $$

CREATE TRIGGER trigger_proteger_admin
BEFORE DELETE ON Usuarios
FOR EACH ROW
BEGIN
    IF OLD.rol = 'Administrador' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No se puede eliminar un administrador.';
    END IF;
END$$

DELIMITER ;

-- Trigger para evitar cambiar el rol a los administradores ✅
DELIMITER $$

CREATE TRIGGER trigger_proteger_admin_actualizacion
BEFORE UPDATE ON Usuarios
FOR EACH ROW
BEGIN
    IF OLD.rol = 'Administrador' AND NEW.rol <> 'Administrador' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No se puede cambiar el rol de un administrador.';
    END IF;
END$$

DELIMITER ;

-- Trigger para evitar campos nulos al insertar y actualizar usuarios ✅
DELIMITER $$

CREATE TRIGGER trigger_validar_usuario_insert
BEFORE INSERT ON Usuarios
FOR EACH ROW
BEGIN
    IF NEW.nombre IS NULL OR TRIM(NEW.nombre) = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: El nombre no puede estar vacío.';
    END IF;

    IF NEW.email IS NULL OR TRIM(NEW.email) = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: El email no puede estar vacío.';
    END IF;

    IF NEW.rol IS NULL OR TRIM(NEW.rol) = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: El rol no puede estar vacío.';
    END IF;

    IF NEW.contrasena IS NULL OR TRIM(NEW.contrasena) = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: La contraseña no puede estar vacía.';
    END IF;
END$$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER trigger_validar_usuario_update 
BEFORE UPDATE ON Usuarios
FOR EACH ROW
BEGIN
    IF NEW.nombre IS NULL OR TRIM(NEW.nombre) = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: El nombre no puede estar vacío.';
    END IF;

    IF NEW.email IS NULL OR TRIM(NEW.email) = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: El email no puede estar vacío.';
    END IF;

    IF NEW.rol IS NULL OR TRIM(NEW.rol) = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: El rol no puede estar vacío.';
    END IF;

    IF NEW.contrasena IS NULL OR TRIM(NEW.contrasena) = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: La contraseña no puede estar vacía.';
    END IF;
END$$

DELIMITER ;

-- Trigger de inserción de comentarios ✅
DROP TRIGGER IF EXISTS validar_comentario;

DELIMITER //
CREATE TRIGGER validar_comentario
BEFORE INSERT ON Comentarios
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT 1 FROM Comentarios
        WHERE id_asignatura = NEW.id_asignatura
          AND id_estudiante = NEW.id_estudiante
          AND id_docente = NEW.id_docente
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Ya existe un comentario de este estudiante para esta asignatura y docente.';
    END IF;
END;
//
DELIMITER ;

-- Trigger para evitar elimiminar un docente con asignatura ✅
DELIMITER $

CREATE TRIGGER proteger_docente
BEFORE DELETE ON Docente
FOR EACH ROW
BEGIN
    IF EXISTS (SELECT 1 FROM Asignaturas WHERE id_docente = OLD.id_docente) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se puede eliminar el docente porque tiene asignaturas asignadas.';
    END IF;
END$$

DELIMITER ;

-- Trigger para no borrar estudiantes con comentarios ✅
DELIMITER $$

CREATE TRIGGER trg_no_eliminar_estudiante_con_comentarios
BEFORE DELETE ON Estudiante
FOR EACH ROW
BEGIN
    IF EXISTS (SELECT 1 FROM Comentarios WHERE id_estudiante = OLD.id_estudiante) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se puede eliminar el estudiante porque tiene comentarios registrados.';
    END IF;
END$$

DELIMITER ;

-- Trigger para evitar espacios en blanco para roles ✅

DELIMITER //

CREATE TRIGGER validar_rol_sin_espacios
BEFORE INSERT ON Usuarios
FOR EACH ROW
BEGIN
    IF TRIM(NEW.rol) NOT IN ('Administrador', 'Estudiante', 'Docente', 'Administrativo') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El rol ingresado no es válido o contiene espacios.';
    END IF;
END;
//

DELIMITER ;

-- Trigger para evitar espacios en blancos para roles update ✅

DELIMITER //

CREATE TRIGGER validar_rol_sin_espacios_update
BEFORE UPDATE ON Usuarios
FOR EACH ROW
BEGIN
    IF TRIM(NEW.rol) NOT IN ('Administrador', 'Estudiante', 'Docente', 'Administrativo') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El rol actualizado no es válido o contiene espacios.';
    END IF;
END;
//

DELIMITER ;

-- Trigger para evitar la misma descripcion de dos evaluaciones (insert, update) ✅
DELIMITER //

CREATE TRIGGER evitar_descripciones_duplicadas
BEFORE INSERT ON Evaluaciones
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT 1 FROM Evaluaciones WHERE descripcion = NEW.descripcion
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Ya existe una evaluación con esta descripción.';
    END IF;
END;
//

DELIMITER ;

DELIMITER //

CREATE TRIGGER evitar_descripciones_duplicadas_update
BEFORE UPDATE ON Evaluaciones
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT 1 FROM Evaluaciones 
        WHERE descripcion = NEW.descripcion 
          AND id_evaluacion != NEW.id_evaluacion
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Ya existe una evaluación con esta descripción.';
    END IF;
END;
//

-- Triger para evitar los comentarios nulos

DELIMITER //
CREATE TRIGGER evitar_campos_nulos_comentarios_insert
BEFORE INSERT ON comentarios
FOR EACH ROW
BEGIN
    IF NEW.comentario IS NULL OR NEW.promedio IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No se permiten campos nulos en comentario o promedio.';
    END IF;
END;
//

DELIMITER $$
CREATE TRIGGER evitar_campos_nulos_comentarios_update
BEFORE UPDATE ON comentarios
FOR EACH ROW
BEGIN
    IF NEW.comentario IS NULL OR NEW.promedio IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No se permiten campos nulos en comentario o promedio.';
    END IF;
END$$
DELIMITER ;



-- Vistas

-- Vista para que solo aparezcan los comentarios al seleccionar docente
CREATE OR REPLACE VIEW VistaComentariosPorDocente AS
SELECT
  u.nombre                AS nombre_docente,
  a.nombre_asignatura     AS asignatura,
  c.comentario,
  c.fecha_creacion,
  c.sentimiento           AS sentimiento
FROM Comentarios c
JOIN Usuarios u        ON c.id_docente = u.id_usuario
JOIN Docente d         ON d.id_docente = u.id_usuario
JOIN Asignaturas a     ON c.id_asignatura = a.id_asignatura;