from schemas import (
    LoginRequest, UserCreate, UserResponse, UserUpdate,
    AsignaturaCreate, AsignaturaResponse, AsignaturaUpdate,
    EvaluacionCreate, EvaluacionResponse, EvaluacionUpdate,
    ComentarioCreate, ComentarioResponse, ComentarioUpdate
)
from JWTKeys import SECRET_KEY, ALGORITHM, ACCESS_TOKEN_EXPIRE_MINUTES, create_access_token, pwd_context, oauth2_scheme
from fastapi.security import OAuth2PasswordRequestForm, OAuth2PasswordBearer
from sqlalchemy.exc import DBAPIError, IntegrityError
from fastapi import FastAPI, Depends, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from database import SessionLocal, engine, Base
from fastapi.responses import JSONResponse
from sqlalchemy import create_engine, text
from datetime import datetime, timedelta
from passlib.context import CryptContext
from schemas import ResumenSentimientos
from sqlalchemy.orm import Session
from dotenv import load_dotenv
from pydantic import BaseModel
from jose import jwt, JWTError
from typing import List, Dict
from database import DB_URL
import psycopg2
import schemas
import crud
import re
import os

 
load_dotenv()

app = FastAPI()
print(f"Conectando a la base de datos: {DB_URL}")

Base.metadata.create_all(bind=engine)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # O especifica ["http://localhost:3000"] si usas React, por ejemplo
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

#Corroboración de la conexion a la base de datos
try:
    engine.connect()  # Intenta conectar
    print("Conexión exitosa a la base de datos")
except Exception as e:
    print(f"Error al conectar a la base de datos: {e}")


def get_db():
    db = SessionLocal()
    try:
        yield db

    finally:
        db.close()


# ---------------------- Ruta para traer docentes por estudiantes ----------------------#


@app.get("/docentes-por-estudiante", response_model=List[ResumenSentimientos])
def ruta_docentes_por_estudiante(db: Session = Depends(get_db)):
    try:
        return crud.obtener_docentes_por_estudiante(db)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.get("/docentes-por-estudiante/{id_estudiante}", response_model=List[ResumenSentimientos])
def ruta_docentes_de_estudiante(id_estudiante: int, db: Session = Depends(get_db)):
    try:
        return crud.obtener_docentes_de_estudiante(db, id_estudiante)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


# ---------------------- Ruta para login----------------------#


@app.post("/login")

async def login(data: LoginRequest, db: Session = Depends(get_db)):
    user = crud.get_user_by_email(db, data.email)
    if not user:
        raise HTTPException(status_code=401, detail="Usuario no encontrado")

    if data.password != user.contrasena:
        raise HTTPException(status_code=401, detail="Contraseña incorrecta")

    access_token = create_access_token(
        data={"sub": user.email, "rol": user.rol}
    )
    return {"access_token": access_token, "token_type": "bearer"}


# ---------------------- Ruta para sentimiento resumido en dashboard----------------------#

@app.get("/resumen-sentimientos/")
def resumen_sentimientos(db: Session = Depends(get_db)):
    try:
        datos = crud.obtener_resumen_sentimientos(db)
        return JSONResponse(content=datos, status_code=200)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


# ---------------------- Ruta para sentimientos por docente----------------------#

@app.get("/resumen_sentimientos/nombre/{nombre_docente}", response_model=List[schemas.ResumenSentimientos])
def obtener_resumen_por_nombre(nombre_docente: str, db: Session = Depends(get_db)):
    try:
        # Llamamos a la función CRUD que interactúa con la base de datos
        resumen = crud.obtener_resumen_sentimientos_por_nombre(db, nombre_docente)

        if not resumen:
            raise HTTPException(status_code=404, detail="Resumen de sentimientos no encontrado para este docente")

        return resumen

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error al obtener el resumen: {str(e)}")
        
# ---------------------- Rutas para usuarios ----------------------#

@app.post("/usuarios/", response_model=UserResponse) # ✅
def crear_usuario(user: UserCreate, db: Session = Depends(get_db)):
    resultado = crud.create_user(db, user)

    if "error" in resultado:
        return JSONResponse(content=resultado, status_code=400)

    return JSONResponse(content=resultado, status_code=201)


@app.get("/usuarios/{id_usuario}", response_model=UserResponse)#✅

def obtener_usuario(id_usuario: int, db: Session = Depends(get_db)):
    user = crud.get_user(db, id_usuario)

    if user is None:
        raise HTTPException(status_code=404, detail="Usuario no encontrado")

    return user


@app.put("/usuarios/{user_id}", response_model=UserResponse)

def actualizar_usuario(user_id: int, user: UserUpdate, db: Session = Depends(get_db)):
    actualizado = crud.update_user(db, user_id, user)

    if actualizado is None:
        raise HTTPException(status_code=404, detail="Usuario no encontrado")

    return actualizado


@app.delete("/usuarios/{id_usuario}", response_model=dict)
def eliminar_usuario(id_usuario: int, db: Session = Depends(get_db)):
    try:
        eliminado = crud.delete_user(db, id_usuario)
        if eliminado is None:
            raise HTTPException(status_code=404, detail="Usuario no encontrado")
        return {"mensaje": f"Usuario con id {id_usuario} eliminado"}
    
    except DBAPIError as e:
        # Extraer el mensaje de error desde Postgres (RAISE)
        detalle = str(e.__cause__)
        raise HTTPException(status_code=400, detail=f"No se puede eliminar el usuario: {detalle}")

# ---------------------- Rutas para asignaturas ----------------------#

@app.post("/asignaturas/", response_model=AsignaturaResponse)

def crear_asignatura(asignatura: AsignaturaCreate, db: Session = Depends(get_db)):

    nueva = crud.create_asignatura(db, asignatura)
    if not nueva:
        raise HTTPException(status_code=400, detail="No se pudo crear la asignatura")

    return JSONResponse(content=nueva, status_code=201)


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
    return JSONResponse(content=actualizada, status_code=201)


@app.delete("/asignaturas/{id_asignatura}")

def eliminar_asignatura(id_asignatura: int, db: Session = Depends(get_db)):
    eliminada = crud.delete_asignatura(db, id_asignatura)

    if eliminada is None:
        raise HTTPException(status_code=404, detail="Asignatura no encontrada")
    return JSONResponse(content=eliminada, status_code=201)

# ---------------------- Rutas para evaluaciones ----------------------#

@app.post("/evaluaciones/", response_model=EvaluacionResponse)

def crear_evaluacion(evaluacion: EvaluacionCreate, db: Session = Depends(get_db)):
    return crud.create_evaluacion(db, evaluacion)


@app.get("/evaluaciones/{id_evaluacion}", response_model=EvaluacionResponse)

def obtener_evaluacion(id_evaluacion: int, db: Session = Depends(get_db)):
    evaluacion = crud.get_evaluacion(db, id_evaluacion)
    
    if evaluacion is None:
        raise HTTPException(status_code=404, detail="Evaluación no encontrada")
    return evaluacion

@app.put("/evaluaciones/{id_evaluacion}", response_model=EvaluacionResponse)

def actualizar_evaluacion(id_evaluacion: int, evaluacion: EvaluacionUpdate, db: Session = Depends(get_db)):
    actualizada = crud.update_evaluacion(db, id_evaluacion, evaluacion)
    
    if actualizada is None:
        raise HTTPException(status_code=404, detail="Evaluación no encontrada")
    return JSONResponse(content=actualizada, status_code=201)

@app.delete("/evaluaciones/{id_evaluacion}", response_model=EvaluacionResponse)

def eliminar_evaluacion(id_evaluacion: int, db: Session = Depends(get_db)):
    eliminada = crud.delete_evaluacion(db, id_evaluacion)

    if eliminada is None:
        raise HTTPException(status_code=404, detail="Evaluación no encontrada")
    return JSONResponse(content=eliminada, status_code=201)


# ---------------------- Rutas para comentarios ----------------------#

@app.post("/comentarios/", response_model=ComentarioResponse)

def crear_comentario(comentario: ComentarioCreate, db: Session = Depends(get_db)):
    creado = crud.create_comentario(db, comentario)

    if creado is None:
        raise HTTPException(status_code=404, detail="Comentario no encontrada")
    return JSONResponse(content=creado, status_code=201)

@app.get("/comentarios/{id_comentario}", response_model=ComentarioResponse)

def obtener_comentario(id_comentario: int, db: Session = Depends(get_db)):
    comentario = crud.get_comentario(db, id_comentario)
    
    if comentario is None:
        raise HTTPException(status_code=404, detail="Comentario no encontrado")
    return comentario


@app.get("/docentes")

def listar_docentes(db: Session = Depends(get_db)):
    docentes = crud.get_docentes(db)
    return [{"id": row.id_docente, "nombre": row.nombre} for row in docentes]


@app.get("/comentarios/nombre/{nombre_docente}")
def comentarios_docente(nombre_docente: str, db: Session = Depends(get_db)):
    return crud.get_comentarios_por_docente(db, nombre_docente)


@app.put("/comentarios/{id_comentario}", response_model=ComentarioResponse)

def actualizar_comentario(id_comentario: int, comentario: ComentarioUpdate, db: Session = Depends(get_db)):
    actualizada = crud.update_comentario(db, id_comentario, comentario)

    if actualizada is None:
        raise HTTPException(status_code=404, detail="Comentario no encontrado")
    return JSONResponse(content=actualizada, status_code=201)


@app.delete("/comentarios/{id_comentario}", response_model=ComentarioResponse)

def eliminar_comentario(id_comentario: int, db: Session = Depends(get_db)):
    eliminada = crud.delete_comentario(db, id_comentario)

    if eliminada is None:
        raise HTTPException(status_code=404, detail="Comentario no encontrado")
    return JSONResponse(content=eliminada, status_code=201)