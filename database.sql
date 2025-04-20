
-- ================================
-- Esquema completo para PostgreSQL
-- Proyecto: NLP Comentarios
-- ================================

-- Creación de base de datos
CREATE DATABASE nlp_comentarios
    WITH ENCODING 'UTF8'
    LC_COLLATE='en_US.utf8'
    LC_CTYPE='en_US.utf8'
    TEMPLATE=template0;

-- Cambiar de base de datos
-- \c nlp_comentarios

-- Tipos ENUM
CREATE TYPE tipo_rol AS ENUM ('admin', 'docente', 'estudiante');

-- Tablas
CREATE TABLE usuarios (
    id UUID PRIMARY KEY,
    nombre_completo VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    tipo_documento VARCHAR(50) NOT NULL,
    numero_documento VARCHAR(50) UNIQUE NOT NULL,
    rol tipo_rol NOT NULL,
    departamento VARCHAR(100),
    password_hash VARCHAR(255) NOT NULL,
    estado BOOLEAN DEFAULT TRUE,
    metadata JSONB,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE programas (
    id UUID PRIMARY KEY,
    codigo VARCHAR(50) UNIQUE NOT NULL,
    nombre VARCHAR(255) NOT NULL,
    descripcion TEXT,
    estado BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE asignaturas (
    id UUID PRIMARY KEY,
    programa_id UUID REFERENCES programas(id),
    codigo VARCHAR(50) UNIQUE NOT NULL,
    nombre VARCHAR(255) NOT NULL,
    creditos INTEGER NOT NULL,
    semestre INTEGER NOT NULL,
    descripcion TEXT,
    estado BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE periodos_academicos (
    id UUID PRIMARY KEY,
    codigo VARCHAR(50) UNIQUE NOT NULL,
    nombre VARCHAR(255) NOT NULL,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NOT NULL,
    estado BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE matriculas (
    id UUID PRIMARY KEY,
    docente_id UUID REFERENCES usuarios(id),
    asignatura_id UUID REFERENCES asignaturas(id),
    periodo_id UUID REFERENCES periodos_academicos(id),
    grupo VARCHAR(50) NOT NULL,
    estado BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (docente_id, asignatura_id, periodo_id, grupo)
);

CREATE TABLE evaluaciones (
    id UUID PRIMARY KEY,
    matricula_id UUID REFERENCES matriculas(id),
    fecha_inicio TIMESTAMPTZ NOT NULL,
    fecha_fin TIMESTAMPTZ NOT NULL,
    estado BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE criterios_evaluacion (
    id UUID PRIMARY KEY,
    nombre VARCHAR(255) NOT NULL,
    descripcion TEXT,
    peso NUMERIC(3,2) NOT NULL CHECK (peso > 0 AND peso <= 1),
    estado BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE respuestas_evaluacion (
    id UUID PRIMARY KEY,
    evaluacion_id UUID REFERENCES evaluaciones(id),
    criterio_id UUID REFERENCES criterios_evaluacion(id),
    estudiante_id UUID REFERENCES usuarios(id),
    calificacion INTEGER CHECK (calificacion >= 1 AND calificacion <= 5),
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (evaluacion_id, criterio_id, estudiante_id)
);

CREATE TABLE comentarios (
    id UUID PRIMARY KEY,
    evaluacion_id UUID REFERENCES evaluaciones(id),
    estudiante_id UUID REFERENCES usuarios(id),
    texto TEXT NOT NULL,
    anonimo BOOLEAN DEFAULT TRUE,
    estado BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE analisis_nlp (
    id UUID PRIMARY KEY,
    comentario_id UUID REFERENCES comentarios(id),
    sentimiento NUMERIC(4,3) NOT NULL,
    categoria VARCHAR(50) NOT NULL,
    palabras_clave JSONB NOT NULL,
    entidades JSONB,
    embedding JSONB,
    metadata JSONB,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE reportes (
    id UUID PRIMARY KEY,
    evaluacion_id UUID REFERENCES evaluaciones(id),
    tipo VARCHAR(50) NOT NULL,
    contenido JSONB NOT NULL,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Índices
CREATE INDEX idx_usuarios_rol ON usuarios(rol);
CREATE INDEX idx_usuarios_estado ON usuarios(estado);
CREATE INDEX idx_asignaturas_programa ON asignaturas(programa_id);
CREATE INDEX idx_matriculas_docente ON matriculas(docente_id);
CREATE INDEX idx_matriculas_periodo ON matriculas(periodo_id);
CREATE INDEX idx_evaluaciones_matricula ON evaluaciones(matricula_id);
CREATE INDEX idx_comentarios_evaluacion ON comentarios(evaluacion_id);
CREATE INDEX idx_comentarios_estudiante ON comentarios(estudiante_id);
CREATE INDEX idx_analisis_comentario ON analisis_nlp(comentario_id);
CREATE INDEX idx_reportes_evaluacion ON reportes(evaluacion_id);

-- Funciones y triggers

CREATE OR REPLACE FUNCTION check_periodo_dates_fn()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.fecha_fin <= NEW.fecha_inicio THEN
        RAISE EXCEPTION 'La fecha de fin debe ser posterior a la fecha de inicio';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_periodo_dates
BEFORE INSERT ON periodos_academicos
FOR EACH ROW EXECUTE FUNCTION check_periodo_dates_fn();

CREATE OR REPLACE FUNCTION check_evaluacion_dates_fn()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.fecha_fin <= NEW.fecha_inicio THEN
        RAISE EXCEPTION 'La fecha de fin debe ser posterior a la fecha de inicio';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_evaluacion_dates
BEFORE INSERT ON evaluaciones
FOR EACH ROW EXECUTE FUNCTION check_evaluacion_dates_fn();

-- Funciones para consultas

CREATE OR REPLACE FUNCTION GetTeacherStats(teacher_id UUID)
RETURNS TABLE(
    total_comentarios INTEGER,
    promedio_sentimiento NUMERIC,
    comentarios_positivos INTEGER,
    comentarios_neutrales INTEGER,
    comentarios_negativos INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        COUNT(c.id),
        AVG(a.sentimiento),
        COUNT(CASE WHEN a.sentimiento >= 0.5 THEN 1 END),
        COUNT(CASE WHEN a.sentimiento BETWEEN -0.5 AND 0.5 THEN 1 END),
        COUNT(CASE WHEN a.sentimiento < -0.5 THEN 1 END)
    FROM comentarios c
    JOIN analisis_nlp a ON c.id = a.comentario_id
    JOIN evaluaciones e ON c.evaluacion_id = e.id
    JOIN matriculas m ON e.matricula_id = m.id
    WHERE m.docente_id = teacher_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION InsertarComentarioConAnalisis(
    p_id UUID,
    p_evaluacion_id UUID,
    p_estudiante_id UUID,
    p_texto TEXT,
    p_sentimiento NUMERIC(4,3),
    p_categoria VARCHAR,
    p_palabras_clave JSONB,
    p_entidades JSONB,
    p_embedding JSONB
)
RETURNS VOID AS $$
DECLARE
    nuevo_id UUID := gen_random_uuid();
BEGIN
    INSERT INTO comentarios (id, evaluacion_id, estudiante_id, texto)
    VALUES (p_id, p_evaluacion_id, p_estudiante_id, p_texto);

    INSERT INTO analisis_nlp (
        id,
        comentario_id,
        sentimiento,
        categoria,
        palabras_clave,
        entidades,
        embedding
    )
    VALUES (
        nuevo_id,
        p_id,
        p_sentimiento,
        p_categoria,
        p_palabras_clave,
        p_entidades,
        p_embedding
    );
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION GetSimilarComments(
    comment_id UUID,
    limit_count INTEGER
)
RETURNS TABLE(id UUID, texto TEXT, embedding JSONB) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        c.id,
        c.texto,
        a.embedding
    FROM comentarios c
    JOIN analisis_nlp a ON c.id = a.comentario_id
    WHERE c.id != comment_id
    LIMIT limit_count;
END;
$$ LANGUAGE plpgsql;