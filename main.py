from fastapi import FastAPI, Depends, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from database import SessionLocal, engine, Base
from sqlalchemy.orm import Session
import crud

from schemas import (
    UserCreate, UserResponse, UserUpdate,
    AsignaturaCreate, AsignaturaResponse, AsignaturaUpdate,
    EvaluacionCreate, EvaluacionResponse, EvaluacionUpdate,
    ComentarioCreate, ComentarioResponse, ComentarioUpdate
)
from sqlalchemy import create_engine

#Corroboración de la conexion a la base de datos
try:
    engine.connect()  # Intenta conectar
    print("Conexión exitosa a la base de datos")
except Exception as e:
    print(f"Error al conectar a la base de datos: {e}")


app = FastAPI()
Base.metadata.create_all(bind=engine)

def get_db():
    db = SessionLocal()
    try:
        yield db

    finally:
        db.close()

# ---------------------- Rutas para usuarios ----------------------#

@app.post("/usuarios/", response_model=UserResponse)

def crear_usuario(user: UserCreate, db: Session = Depends(get_db)):
    nuevo = crud.create_user(db, user)

    if not nuevo:
        raise HTTPException(status_code=400, detail="No se pudo crear el usuario")

    return nuevo

@app.get("/usuarios/{user_id}", response_model=UserResponse)

def obtener_usuario(user_id: int, db: Session = Depends(get_db)):
    user = crud.get_user(db, user_id)

    if user is None:
        raise HTTPException(status_code=404, detail="Usuario no encontrado")

    return user


@app.put("/usuarios/{user_id}", response_model=UserResponse)

def actualizar_usuario(user_id: int, user: UserUpdate, db: Session = Depends(get_db)):
    actualizado = crud.update_user(db, user_id, user)

    if actualizado is None:
        raise HTTPException(status_code=404, detail="Usuario no encontrado")

    return actualizado


@app.delete("/usuarios/{user_id}", response_model=UserResponse)

def eliminar_usuario(user_id: int, db: Session = Depends(get_db)):
    eliminado = crud.delete_user(db, user_id)

    if eliminado is None:
        raise HTTPException(status_code=404, detail="Usuario no encontrado")

    return eliminado

# ---------------------- Rutas para asignaturas ----------------------#

@app.post("/asignaturas/", response_model=AsignaturaResponse)

def crear_asignatura(asignatura: AsignaturaCreate, db: Session = Depends(get_db)):

    nueva = crud.create_asignatura(db, asignatura)
    if not nueva:
        raise HTTPException(status_code=400, detail="No se pudo crear la asignatura")

    return nueva


@app.get("/asignaturas/{id_asignatura}", response_model=AsignaturaResponse)

def obtener_asignatura(id_asignatura: int, db: Session = Depends(get_db)):
    asignatura = crud.get_asignatura(db, id_asignatura)
    if asignatura is None:
        raise HTTPException(status_code=404, detail="Asignatura no encontrada")
    return asignatura


@app.put("/asignaturas/{id_asignatura}", response_model=AsignaturaResponse)

def actualizar_asignatura(id_asignatura: int, asignatura: AsignaturaUpdate, db: Session = Depends(get_db)):
    actualizada = crud.update_asignatura(db, id_asignatura, asignatura)

    if actualizada is None:
        raise HTTPException(status_code=404, detail="Asignatura no encontrada")
    return actualizada


@app.delete("/asignaturas/{id_asignatura}")

def eliminar_asignatura(id_asignatura: int, db: Session = Depends(get_db)):
    eliminada = crud.delete_asignatura(db, id_asignatura)

    if eliminada is None:
        raise HTTPException(status_code=404, detail="Asignatura no encontrada")
    return eliminada

# ---------------------- Rutas para evaluaciones ----------------------#

@app.post("/evaluaciones/", response_model=EvaluacionResponse)

def crear_evaluacion(evaluacion: EvaluacionCreate, db: Session = Depends(get_db)):
    return crud.create_evaluacion(db, evaluacion)


@app.get("/evaluaciones/{evaluacion_id}", response_model=EvaluacionResponse)

def obtener_evaluacion(evaluacion_id: int, db: Session = Depends(get_db)):
    return crud.get_evaluacion(db, evaluacion_id)

@app.put("/evaluaciones/{evaluacion_id}", response_model=EvaluacionResponse)

def actualizar_evaluacion(evaluacion_id: int, evaluacion: EvaluacionUpdate, db: Session = Depends(get_db)):
    return crud.update_evaluacion(db, evaluacion_id, evaluacion)


@app.delete("/evaluaciones/{evaluacion_id}", response_model=EvaluacionResponse)

def eliminar_evaluacion(evaluacion_id: int, db: Session = Depends(get_db)):
    return crud.delete_evaluacion(db, evaluacion_id)


# ---------------------- Rutas para comentarios ----------------------#

@app.post("/comentarios/", response_model=ComentarioResponse)

def crear_comentario(comentario: ComentarioCreate, db: Session = Depends(get_db)):
    return crud.create_comentario(db, comentario)


@app.get("/comentarios/{comentario_id}", response_model=ComentarioResponse)

def obtener_comentario(comentario_id: int, db: Session = Depends(get_db)):
    return crud.get_comentario(db, comentario_id)


@app.put("/comentarios/{comentario_id}", response_model=ComentarioResponse)

def actualizar_comentario(comentario_id: int, comentario: ComentarioUpdate, db: Session = Depends(get_db)):
    return crud.update_comentario(db, comentario_id, comentario)


@app.delete("/comentarios/{comentario_id}", response_model=ComentarioResponse)

def eliminar_comentario(comentario_id: int, db: Session = Depends(get_db)):
    return crud.delete_comentario(db, comentario_id)
