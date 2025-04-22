from pydantic import BaseModel

# CRUD para usuarios

class UserBase(BaseModel):
    nombre: str
    email: str
    rol: str

class UserCreate(UserBase):
    password: str

class UserUpdate(BaseModel):
    nombre: str | None = None
    email: str | None = None
    password: str | None = None
    rol: str | None = None

class UserResponse(UserBase):
    id: int

    class Config:
        orm_mode = True

# CRUD para asignaturas

class AsignaturaBase(BaseModel):
    nombre: str
    descripcion: str

class AsignaturaCreate(AsignaturaBase):
    pass

class AsignaturaUpdate(BaseModel):
    nombre: str | None = None
    descripcion: str | None = None

class AsignaturaResponse(AsignaturaBase):
    id_asignatura: int

    class Config:
        orm_mode = True

# CRUD para evaluaciones

class EvaluacionBase(BaseModel):
    id_usuario: int
    id_asignatura: int
    calificacion: float

class EvaluacionCreate(EvaluacionBase):
    pass

class EvaluacionUpdate(BaseModel):
    calificacion: float | None = None

class EvaluacionResponse(EvaluacionBase):
    id_evaluacion: int

    class Config:
        orm_mode = True

# CRUD para comentarios

class ComentarioBase(BaseModel):
    id_usuario: int
    id_asignatura: int
    contenido: str

class ComentarioCreate(ComentarioBase):
    pass

class ComentarioUpdate(BaseModel):
    contenido: str | None = None

class ComentarioResponse(ComentarioBase):
    id_comentario: int

    class Config:
        orm_mode = True
