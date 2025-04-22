from fastapi import FastAPI, Depends, HTTPException
from sqlalchemy.orm import Session
from database import SessionLocal, engine, Base
from schemas import UserCreate, UserResponse, UserUpdate
from fastapi.middleware.cors import CORSMiddleware
import crud

app = FastAPI()
Base.metadata.create_all(bind=engine)

def get_db():
    db = SessionLocal()
    try:
        yield db

    finally:
        db.close()

# CRUD para usuarios

@app.post("/usuarios/", response_model=UserResponse)

def crear_usuario(user: UserCreate, db: Session = Depends(get_db)):
    nuevo = crud.create_user(db, user)

    if not nuevo:
        raise HTTPException(status_code=400, detail="No se pudo crear el usuario")

    return nuevo


@app.get("/usuarios/", response_model=list[UserResponse])

def obtener_usuarios(skip: int = 0, limit: int = 10, db: Session = Depends(get_db)):
    return crud.get_users(db, skip=skip, limit=limit)


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

# CRUD para asignaturas

from schemas import AsignaturaCreate, AsignaturaUpdate, AsignaturaResponse  # Asegúrate de que existan

@app.post("/asignaturas/", response_model=AsignaturaResponse)

def crear_asignatura(asignatura: AsignaturaCreate, db: Session = Depends(get_db)):

    nueva = crud.create_asignatura(db, asignatura)
    if not nueva:
        raise HTTPException(status_code=400, detail="No se pudo crear la asignatura")

    return nueva


@app.get("/asignaturas/", response_model=list[AsignaturaResponse])

def obtener_asignaturas(skip: int = 0, limit: int = 10, db: Session = Depends(get_db)):
    return crud.get_asignaturas(db, skip=skip, limit=limit)


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

# CRUD para evaluaciones

# CRUD para comentarios
