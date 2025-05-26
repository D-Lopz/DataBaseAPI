from models import User, Asignatura, Comentario, Reporte
from schemas import UserUpdate, ComentarioUpdate, ComentarioCreate, ComentarioResponse
from passlib.context import CryptContext
from sqlalchemy.exc import DBAPIError
from sqlalchemy.orm import Session
from typing import List, Dict, Any
from fastapi import HTTPException
from chat.chat import chat_bot
from sqlalchemy import text
from database import Base
import schemas
import re

# --------------------- Docentes por estudiante --------------------- #


def obtener_docentes_por_estudiante(db: Session, id_estudiante: int) -> Dict[str, Any]:
    result = db.execute(text("CALL docentes_por_estudiantes(:id_estudiante)"), {"id_estudiante": id_estudiante})
    filas = result.mappings().all()

    if not filas:
        return {}

    respuesta = {
        "id_estudiante": id_estudiante,
        "docentes": []
    }

    docentes_map = {}

    for fila in filas:
        id_docente = fila["id_docente"]
        if id_docente not in docentes_map:
            docentes_map[id_docente] = {
                "id_docente": id_docente,
                "nombre_docente": fila["nombre_docente"],
                "asignaturas": []
            }
            respuesta["docentes"].append(docentes_map[id_docente])

        docentes_map[id_docente]["asignaturas"].append({
            "id_asignatura": fila["id_asignatura"],
            "nombre_asignatura": fila["nombre_asignatura"]
        })

    return respuesta


# --------------------- Sentimientos por docente --------------------- #


def get_user_by_email(db: Session, email: str):

    result = db.execute(
        text("CALL obtener_usuario_por_email(:email)"),
        {"email": email}
    )
    return result.mappings().fetchone()


# --------------------- Sentimientos por administrador --------------------- #


def obtener_resumen_sentimientos(db):
    try:
        resultados = db.execute(text("CALL resumen_sentimientos_global()")).fetchall()
        return [
            {"sentimiento": r[0], "total": r[1], "porcentaje": float(r[2])}
            for r in resultados
        ]
    except Exception as e:
        raise Exception(f"Error al obtener resumen de sentimientos: {str(e)}")


# --------------------- Sentimientos por docente --------------------- #


def obtener_resumen_sentimientos_por_nombre(db: Session, nombre_docente: str):

    result = db.execute(
        text("CALL resumen_sentimientos_por_nombre_docente(:nombre_docente)"),
        {"nombre_docente": nombre_docente}
    ).fetchall()

    resumen = []
    for row in result:
        resumen.append({
            "id_docente": row[0],
            "nombre_docente": row[1],
            "id_asignatura": row[2],
            "nombre_asignatura": row[3],
            "total_comentarios": row[4],
            "positivos": row[5],
            "neutrales": row[6],
            "negativos": row[7],
        })
    
    return resumen


# --------------------- Usuarios --------------------- #


def get_user(db: Session, user_id: int):

    result = db.execute(text("CALL LeerUsuario(:id)"), {"id": user_id})
    return result.fetchone()


def create_user(db: Session, user):
    try:
        db.execute(text("""
            CALL CrearUsuario(:nombre, :email, :rol, :contrasena)
        """), {
            "nombre": user.nombre,
            "email": user.email,
            "rol": user.rol,
            "contrasena": user.contrasena
        })
        db.commit()
        return {"message": "Usuario creado con éxito"}
    except DBAPIError as e:
        # Aquí capturamos el error de la base (trigger o cualquier fallo)
        # Sacamos el mensaje original del error para pasarlo arriba
        error_msg = str(e.orig) if hasattr(e, 'orig') else str(e)
        return {"error": error_msg}
    

def update_user(db: Session, user_id: int, user_update: UserUpdate):
    try:
        db.execute(text("""
            CALL ActualizarUsuario(:id_usuario, :nombre, :email, :rol, :contrasena)
        """), {
            "id_usuario": user_id,
            "nombre": user_update.nombre,
            "email": user_update.email,
            "rol": user_update.rol,
            "contrasena": user_update.contrasena
        })
        db.commit()

        result = db.execute(text("CALL LeerUsuario(:id)"), {"id": user_id})
        return result.fetchone()

    except Exception as e:
        db.rollback()
        error_msg = str(e)

        # Extraer el mensaje personalizado del error SQL (entre comillas simples después del código 1644)
        match = re.search(r"1644, '(.+?)'", error_msg)
        if match:
            clean_msg = match.group(1)
        else:
            clean_msg = error_msg  # Si no se encuentra, mostrar el error completo

        print(f"Error al actualizar usuario: {clean_msg}")
        raise HTTPException(status_code=400, detail=clean_msg)



def delete_user(db, user_id: int):
    try:
        # Llamar al procedimiento almacenado
        db.execute(text("CALL EliminarUsuario(:id)"), {"id": user_id})
        db.commit()
        return {"message": f"Usuario con ID {user_id} eliminado correctamente."}
    
    except Exception as e:
        error_message = str(e)
        # Buscar mensaje entre 'RaiseException:' y 'CONTEXT:' (o fin de línea)
        match = re.search(r'RaiseException:\s*(.*?)\s*CONTEXT:', error_message, re.DOTALL)
        user_friendly_message = match.group(1).strip() if match else "No se puede eliminar el usuario porque tiene comentarios relacionados."

        raise HTTPException(status_code=400, detail=f"ERROR:  {user_friendly_message}")

# --------------------- Asignaturas --------------------- #

# Obtener todas las asignaturas
def get_asignatura(db: Session, asignatura_id: int):
    
    result = db.execute(text("CALL LeerAsignatura(:id)"), {"id": asignatura_id})
    return result.fetchone()


# Crear una asignatura
def create_asignatura(db: Session, asignatura):

    db.execute(text("""
        CALL CrearAsignatura(:nombre_asignatura, :id_docente)
    """), {
        "nombre_asignatura": asignatura.nombre_asignatura,
        "id_docente": asignatura.id_docente
    })
    db.commit()
    return {"message": "Asignatura creada con éxito"}


# Actualizar una asignatura
def update_asignatura(db: Session, asignatura_id: int, asignatura_update):

    db.execute(text("""
        CALL ActualizarAsignatura(:id_asignatura, :nombre_asignatura, :id_docente)
    """), {
        "id_asignatura": asignatura_id,
        "nombre_asignatura": asignatura_update.nombre_asignatura,
        "id_docente": asignatura_update.docente_id
    })
    db.commit()
    return {"message": "Asignatura actualizada con éxito"}

# Eliminar una asignatura
def delete_asignatura(db: Session, asignatura_id: int):

    db.execute(text("CALL EliminarAsignatura(:id_asignatura)"), {"id_asignatura": asignatura_id})
    db.commit()
    return {"message": "Asignatura eliminada con éxito"}


# --------------------- Evaluaciones --------------------- #

# Obtener todas las evaluaciones
def get_evaluacion(db: Session, evaluacion_id: int):

    result = db.execute(text("CALL LeerEvaluacion(:id)"), {"id": evaluacion_id})
    return result.fetchone()

# Crear una evaluación

def create_evaluacion(db: Session, evaluacion):
    try:
        db.execute(text("""
            CALL CrearEvaluacion(:fecha_inicio, :fecha_fin, :estado, :descripcion)
        """), {
            "fecha_inicio": evaluacion.fecha_inicio,
            "fecha_fin": evaluacion.fecha_fin,
            "estado": evaluacion.estado,
            "descripcion": evaluacion.descripcion
        })
        db.commit()
        return {"message": "Evaluación creada con éxito"}
    
    except DBAPIError as e:
        db.rollback()
        error_msg = str(e.orig) if hasattr(e, 'orig') else str(e)
        raise HTTPException(status_code=400, detail=error_msg)


# Actualizar una evaluación
def update_evaluacion(db: Session, evaluacion_id: int, evaluacion_update):
    db.execute(text("""
        CALL ActualizarEvaluacion(:id_evaluacion, :fecha_inicio, :fecha_fin, :estado, :descripcion)
    """), {
        "id_evaluacion": evaluacion_id,
        "fecha_inicio": evaluacion_update.fech_inicio,
        "fecha_fin": evaluacion_update.fech_fin,
        "estado": evaluacion_update.estado_e,
        "descripcion": evaluacion_update.descripcion_e
    })
    db.commit()
    return {"message": "Evaluación actualizada con éxito"}

# Eliminar una evaluación
def delete_evaluacion(db: Session, evaluacion_id: int):
    db.execute(text("CALL EliminarEvaluacion(:id_evaluacion)"), {"id_evaluacion": evaluacion_id})
    db.commit()
    return {"message": "Evaluación eliminada con éxito"}


# --------------------- Comentarios --------------------- #

# Obtener todos los comentarios de una evaluación
def get_comentario(db: Session, comentario_id: int):
    result = db.execute(text("CALL LeerComentario(:id_comentario)"), {"id_comentario": comentario_id})
    row = result.fetchone()
    if row is None:
        return None
    return {
        "id_comentario": row.id_comentario,
        "id_estudiante": row.id_estudiante,
        "id_docente": row.id_docente,
        "id_asignatura": row.id_asignatura,
        "id_evaluacion": row.id_evaluacion,
        "comentario": row.comentario,
        "fecha_creacion": row.fecha_creacion,
        "sentimiento": row.sentimiento if row.sentimiento is not None else "No analizado"
    }


# Listar docentes

def get_docentes(db: Session):
    result = db.execute(text("""
        SELECT u.id_usuario AS id_docente, u.nombre 
        FROM Usuarios u
        JOIN Docente d ON u.id_usuario = d.id_docente;
    """))
    return result.fetchall()

# Listar usuarios


def get_todos_los_usuarios(db: Session):
    result = db.execute(text("CALL usuarios_sin_contraseña();"))
    usuarios = result.fetchall()
    usuarios_list = [
        {
            "id_usuario": row[0],
            "nombre": row[1],
            "email": row[2],
            "rol": row[3],
            "fecha_creacion": row[4].isoformat() if row[4] else None  # formato ISO para fechas
        }
        for row in usuarios
    ]
    return usuarios_list


# Listar asignaturas


def get_asignaturas_con_docentes(db):
    result = db.execute(text("CALL ObtenerAsignaturasConDocentes();"))
    # Esto trae todos los resultados del procedimiento
    asignaturas = result.fetchall()
    # Opcional: convertir a lista de dicts para que sea más fácil manejar
    asignaturas_list = [
        {
            "id_asignatura": row[0],
            "nombre_asignatura": row[1],
            "creditos": row[2],
            "id_docente": row[3],
            "nombre_docente": row[4]
        }
        for row in asignaturas
    ]
    return asignaturas_list


# Comentarios por docente

def get_comentarios_por_docente(db: Session, nombre_docente: str):
    query = text("""
        SELECT asignatura, comentario, fecha_creacion, sentimiento
        FROM VistaComentariosPorDocente
        WHERE nombre_docente = :nombre_docente
    """)
    result = db.execute(query, {"nombre_docente": nombre_docente})
    rows = result.fetchall()

    comentarios = []
    for row in rows:
        comentarios.append({
            "asignatura": row.asignatura,
            "comentario": row.comentario,
            "fecha_creacion": row.fecha_creacion,
            "sentimiento": row.sentimiento
        })
    return comentarios


# Crear un comentario
def create_comentario(db: Session, comentario):
    try:
        # Analiza el sentimiento antes de la inserción
        sentimiento = chat_bot(comentario.comentario, comentario.promedio)

        db.execute(text("""
            CALL InsertarComentario(:idEst, :idDoc, :idAsig, :comentario, :sentimiento, :promedio)
        """), {
            "idEst": comentario.id_estudiante,
            "idDoc": comentario.id_docente,
            "idAsig": comentario.id_asignatura,
            "comentario": comentario.comentario,
            "sentimiento": sentimiento,
            "promedio": comentario.promedio
        })
        db.commit()

        return {
            "id_estudiante": comentario.id_estudiante,
            "id_docente": comentario.id_docente,
            "id_asignatura": comentario.id_asignatura,
            "comentario": comentario.comentario,
            "sentimiento": sentimiento,
            "promedio": comentario.promedio
        }

    except DBAPIError as e:
        db.rollback()
        error_msg = str(e.orig) if hasattr(e, 'orig') else str(e)
        raise HTTPException(status_code=400, detail=error_msg)


def update_comentario(db: Session, comentario_id: int, comentario_update: ComentarioUpdate):

    sentimiento = chat_bot(comentario_update.comentario)

    db.execute(text("""
        CALL ActualizarComentario(:id, :id_est, :id_doc, :id_asig, :id_eval, :comentario)
    """), {
        "id": comentario_id,
        "id_est": comentario_update.id_estudiante,
        "id_doc": comentario_update.id_docente,
        "id_asig": comentario_update.id_asignatura,
        "id_eval": comentario_update.id_evaluacion,
        "comentario": comentario_update.comentario,
        "sentimiento": sentimiento
    })
    db.commit()
    return {"message": "Comentario actualizado con éxito"}


# Eliminar un comentario
def delete_comentario(db: Session, comentario_id: int):
    db.execute(text("CALL EliminarComentario(:id_comentario)"), {"id_comentario": comentario_id})
    db.commit()
    return {"message": "Comentario eliminado con éxito"}