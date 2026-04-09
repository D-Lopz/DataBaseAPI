from sqlalchemy import Column, String, Integer, ForeignKey, Text, DateTime, func
from sqlalchemy.orm import relationship
from database import Base

class User(Base):
    __tablename__ = 'usuarios'

    id_usuario = Column(Integer, primary_key=True, index=True)
    nombre = Column(String(255), nullable=False)
    email = Column(String(255), unique=True, index=True, nullable=False)
    rol = Column(String(50), nullable=False) # Rol suele ser más corto
    contrasena = Column(String(255), nullable=False)
    fecha_creacion = Column(DateTime, server_default=func.now())

    # Relaciones añadidas directamente en la clase
    docente_perfil = relationship("Docente", back_populates="usuario", uselist=False)
    asignaturas = relationship("Asignatura", back_populates="docente")

class Docente(Base):
    __tablename__ = 'docente'
    
    id_docente = Column(Integer, primary_key=True)
    titulo = Column(String(255), nullable=False)
    certificado = Column(String(255))

    usuario_id = Column(Integer, ForeignKey('usuarios.id_usuario'))
    # Corregido: 'User' es el nombre de la clase, no 'Usuarios'
    usuario = relationship('User', back_populates='docente_perfil')

class Asignatura(Base):
    __tablename__ = 'asignaturas'

    id_asignatura = Column(Integer, primary_key=True, index=True)
    nombre_asignatura = Column(String(255), nullable=False)
    id_docente = Column(Integer, ForeignKey('usuarios.id_usuario'))

    # Relación con el docente
    docente = relationship("User", back_populates="asignaturas")

class Comentario(Base):
    __tablename__ = 'comentarios'

    id_comentario = Column(Integer, primary_key=True, index=True)
    id_estudiante = Column(Integer, ForeignKey('usuarios.id_usuario'))
    id_docente = Column(Integer, ForeignKey('usuarios.id_usuario'))
    id_asignatura = Column(Integer, ForeignKey('asignaturas.id_asignatura'))
    
    comentario = Column(Text, nullable=False) # Text no necesita longitud
    sentimiento = Column(String(100), nullable=True)
    fecha_creacion = Column(DateTime, server_default=func.now())
    
    # Especificamos foreign_keys para evitar ambigüedad
    estudiante = relationship("User", foreign_keys=[id_estudiante])
    docente = relationship("User", foreign_keys=[id_docente])
    asignatura = relationship("Asignatura")

class Reporte(Base):
    __tablename__ = 'reportes'

    id_reporte = Column(Integer, primary_key=True, index=True)
    id_docente = Column(Integer, ForeignKey('usuarios.id_usuario'))
    fecha_generacion = Column(DateTime, server_default=func.now())
    contenido = Column(Text, nullable=False)
    formato = Column(String(50), nullable=False)

    docente = relationship("User")