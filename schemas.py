from pydantic import BaseModel
from typing import Optional
from datetime import date
from typing import List


# --- Login ---

class LoginRequest(BaseModel):
    email: str
    password: str


# --- Filtrado de docentes por estudiantes matriculados ---


class Asignatura(BaseModel):
    id_asignatura: int
    nombre_asignatura: str

class Docente(BaseModel):
    id_docente: int
    nombre_docente: str
    asignaturas: List[Asignatura]

class EstudianteDocentesResponse(BaseModel):
    id_estudiante: int
    docentes: List[Docente]


# --- Resumen Sentimientos ---

class ResumenSentimientos(BaseModel):
    id_docente: int
    nombre_docente: str
    id_asignatura: int
    nombre_asignatura: str
    total_comentarios: int
    positivos: int
    neutrales: int
    negativos: int

    class Config:
        from_attributes = True

# --- CRUD Usuarios ---

class UserBase(BaseModel):
    nombre: str
    email: str
    rol: str

class UserCreate(UserBase):
    contrasena: str

class UserUpdate(BaseModel):
    nombre: Optional[str] = None
    email: Optional[str] = None
    rol: Optional[str] = None
    contrasena: Optional[str] = None

class UserResponse(UserBase):
    id_usuario: int

    class Config:
        from_attributes = True

# --- CRUD Asignaturas ---

class AsignaturaBase(BaseModel):
    nombre_asignatura: str
    id_docente: int

class AsignaturaCreate(AsignaturaBase):
    pass

class AsignaturaUpdate(BaseModel):
    nombre_asignatura: Optional[str] = None
    id_docente: Optional[int] = None  # unificado nombre con la base

class AsignaturaResponse(AsignaturaBase):
    id_asignatura: int

    class Config:
        from_attributes = True

# --- CRUD Evaluaciones ---

class EvaluacionBase(BaseModel):
    fecha_inicio: date
    fecha_fin: date
    estado: str
    descripcion: str

class EvaluacionCreate(EvaluacionBase):
    pass

class EvaluacionUpdate(BaseModel):
    fecha_inicio: Optional[date] = None
    fecha_fin: Optional[date] = None
    estado: Optional[str] = None
    descripcion: Optional[str] = None

class EvaluacionResponse(EvaluacionBase):
    id_evaluacion: int

    class Config:
        from_attributes = True

# --- CRUD Comentarios ---

class ComentarioBase(BaseModel):
    id_estudiante: int
    id_docente: int
    id_asignatura: int
    comentario: str
    promedio: float  # Aquí está el promedio para análisis de sentimiento

class ComentarioCreate(ComentarioBase):
    pass

class ComentarioUpdate(BaseModel):
    id_estudiante: Optional[int] = None
    id_docente: Optional[int] = None
    id_asignatura: Optional[int] = None
    comentario: Optional[str] = None
    promedio: Optional[float] = None

class ComentarioResponse(ComentarioBase):
    id_comentario: int
    sentimiento: str

    class Config:
        from_attributes = True