from sqlalchemy import Column, String, Integer, ForeignKey, Text, DateTime, func
from sqlalchemy.orm import relationship
from database import Base

class User(Base):
    __tablename__ = 'usuarios'

    id_usuario = Column(Integer, primary_key=True, index=True)
    nombre = Column(String, nullable=False)
    email = Column(String, unique=True, index=True, nullable=False)
    rol = Column(String, nullable=False)
    contrasena = Column(String, nullable=False)
    fecha_creacion = Column(DateTime, server_default=func.now())


class Docente(Base):
    __tablename__ = 'docente'
    id_docente = Column(Integer, primary_key=True)
    titulo = Column(String, nullable=False)
    certificado = Column(String)

    usuario_id = Column(Integer, ForeignKey('usuarios.id_usuario'))
    usuario = relationship('Usuarios', back_populates='docente')  # Relación con la tabla Usuarios

class Asignatura(Base):
    __tablename__ = 'asignaturas'

    id_asignatura = Column(Integer, primary_key=True, index=True)
    nombre_asignatura = Column(String, nullable=False)
    id_docente = Column(Integer, ForeignKey('usuarios.id_usuario'))

    # Relación con el docente
    docente = relationship("User", back_populates="asignaturas")

# Esto es para agregar la relación al modelo `User`
User.asignaturas = relationship("Asignatura", back_populates="docente")


class Comentario(Base):
    __tablename__ = 'comentarios'

    id_comentario = Column(Integer, primary_key=True, index=True)
    id_estudiante = Column(Integer, ForeignKey('usuarios.id_usuario'))
    id_docente = Column(Integer, ForeignKey('usuarios.id_usuario'))
    id_asignatura = Column(Integer, ForeignKey('asignaturas.id_asignatura'))
    id_evaluacion = Column(Integer, ForeignKey('evaluaciones.id_evaluacion'))
    comentario = Column(Text, nullable=False)
    sentimiento = Column(String, nullable=True)  # La nueva columna
    fecha_creacion = Column(DateTime, server_default=func.now())
    estudiante = relationship("User", foreign_keys=[id_estudiante])
    docente = relationship("User", foreign_keys=[id_docente])
    asignatura = relationship("Asignatura")


class Reporte(Base):
    __tablename__ = 'reportes'

    id_reporte = Column(Integer, primary_key=True, index=True)
    id_docente = Column(Integer, ForeignKey('usuarios.id_usuario'))
    fecha_generacion = Column(DateTime, server_default=func.now())
    contenido = Column(Text, nullable=False)
    formato = Column(String, nullable=False)

    docente = relationship("User")