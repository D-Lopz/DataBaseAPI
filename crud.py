from models import User, Asignatura, Comentario, Reporte
from sqlalchemy.orm import Session
from schemas import UserUpdate
from sqlalchemy import text
import schemas

# --------------------- Usuarios --------------------- #


def get_user(db: Session, user_id: int):

    result = db.execute(text("SELECT * FROM LeerUsuario(:id)"), {"id": user_id})
    return result.fetchone()


def create_user(db: Session, user):
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

from sqlalchemy import text
from sqlalchemy.orm import Session

def update_user(db: Session, user_id: int, user_update: UserUpdate):
    try:
        # Ejecutar el procedimiento almacenado
        db.execute(text("""
            CALL ActualizarUsuario(:id_usuario, :nombre, :email, :rol, :contrasena)
        """), {
            "id_usuario": user_id,
            "nombre": user_update.nombre,
            "email": user_update.email,
            "rol": user_update.rol,
            "contrasena": user_update.contrasena
        })
        
        # Realizar commit para guardar los cambios en la base de datos
        db.commit()

        # Consultar el usuario actualizado para devolverlo
        usuario_actualizado = db.query(models.User).filter(models.User.id_usuario == user_id).first()

        # Verificar si el usuario existe
        if usuario_actualizado:
            return usuario_actualizado
        else:
            return {"error": "Usuario no encontrado"}

    except Exception as e:
        # Si ocurre un error, realizar rollback de la transacción
        db.rollback()
        # Log del error
        print(f"Error al actualizar usuario: {e}")
        return {"error": str(e)}



def delete_user(db: Session, user_id: int):

    db.execute(text("CALL EliminarUsuario(:id)"), {"id": user_id})
    db.commit()
    return {"message": "Usuario eliminado con éxito"}


# --------------------- Asignaturas --------------------- #

# Obtener todas las asignaturas
def get_asignatura(db: Session, asignatura_id: int):
    
    result = db.execute(text("SELECT * FROM LeerAsignatura(:id)"), {"id": asignatura_id})
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
        "id_docente": asignatura_update.id_docente
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

    result = db.execute(text("SELECT * FROM LeerEvaluacion(:id)"), {"id": evaluacion_id})
    return result.fetchone()

# Crear una evaluación
def create_evaluacion(db: Session, evaluacion):
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

# Actualizar una evaluación
def update_evaluacion(db: Session, evaluacion_id: int, evaluacion_update):
    db.execute(text("""
        CALL ActualizarEvaluacion(:id_evaluacion, :fecha_inicio, :fecha_fin, :estado, :descripcion)
    """), {
        "id_evaluacion": evaluacion_id,
        "fecha_inicio": evaluacion_update.fecha_inicio,
        "fecha_fin": evaluacion_update.fecha_fin,
        "estado": evaluacion_update.estado,
        "descripcion": evaluacion_update.descripcion
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
    result = db.execute(text("SELECT * FROM LeerComentario(:id_comentario)"), {"id_comentario": comentario_id})
    return result.fetchone()

# Crear un comentario
def create_comentario(db: Session, comentario):

    db.execute(text("""
        CALL InsertarComentario(:idEst, :idDoc, :idAsig, :idEval, :comentarioTexto)
    """), {
        "idEst": comentario.id_estudiante,
        "idDoc": comentario.id_docente,
        "idAsig": comentario.id_asignatura,
        "idEval": comentario.id_evaluacion,
        "comentarioTexto": comentario.contenido
    })
    db.commit()
    return {"message": "Comentario creado con éxito"}

# Eliminar un comentario
def delete_comentario(db: Session, comentario_id: int):
    db.execute(text("CALL EliminarComentario(:id_comentario)"), {"id_comentario": comentario_id})
    db.commit()
    return {"message": "Comentario eliminado con éxito"}