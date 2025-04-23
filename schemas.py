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
    rol: str | None = None
    password: str | None = None

class UserResponse(UserBase):
    id: int

    class Config:
        orm_mode = True

# CRUD para asignaturas

class AsignaturaBase(BaseModel):

    nombre_asignatura: str
    id_docente: int

class AsignaturaCreate(AsignaturaBase):
    pass

class AsignaturaUpdate(BaseModel):

    nombre: str | None = None
    id_docente: int | None = None

class AsignaturaResponse(AsignaturaBase):
    id_asignatura: int

    class Config:
        orm_mode = True


# CRUD para comentarios

class EvaluacionBase(BaseModel):

    fecha_inicio: str
    fecha_fin: str     
    estado: str        
    descripcion: str   

class EvaluacionCreate(EvaluacionBase):

    pass

class EvaluacionUpdate(BaseModel):

    fecha_inicio: str | None = None
    fecha_fin: str | None = None
    estado: str | None = None
    descripcion: str | None = None

class EvaluacionResponse(EvaluacionBase):
    id_evaluacion: int

    class Config:
        orm_mode = True


# CRUD para comentarios

class ComentarioBase(BaseModel):
    id_estudiante: int
    id_docente: int     
    id_asignatura: int    
    id_evaluacion: int   
    contenido: str       

class ComentarioCreate(ComentarioBase):
    pass

class ComentarioUpdate(BaseModel):
    contenido: str | None = None  

class ComentarioResponse(ComentarioBase):
    id_comentario: int

    class Config:
        orm_mode = True

