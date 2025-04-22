from sqlalchemy.orm import Session
from sqlalchemy import text
from utils import hash_password

# --------------------- Usuarios --------------------- #


def get_user(db: Session, user_id: int):

    result = db.execute(text("SELECT * FROM LeerUsuario(:uid)"), {"uid": user_id})
    return result.fetchone()


def get_users(db: Session, skip: int = 0, limit: int = 10):

    result = db.execute(text("SELECT * FROM LeerUsuario(:skip, :limit)"), {"skip": skip, "limit": limit})
    return result.fetchall()


def create_user(db: Session, user):

    hashed_password = hash_password(user.password)
    db.execute(text("""
        CALL CrearUsuario(:nombre, :email, :rol, :contrasena)
    """), {
        "nombre": user.nombre,
        "email": user.email,
        "rol": user.rol,
        "contrasena": hashed_password
    })
    db.commit()
    return {"message": "Usuario creado con éxito"}


def update_user(db: Session, user_id: int, user_update):

    db.execute(text("""
        CALL ActualizarUsuario(:id_usuario, :nombre, :email, :rol, :contrasena)
    """), {
        "id_usuario": user_id,
        "nombre": user_update.nombre,
        "email": user_update.email,
        "rol": user_update.rol,
        "contrasena": hash_password(user_update.password) if user_update.password else None
    })
    db.commit()
    return {"message": "Usuario actualizado con éxito"}


def delete_user(db: Session, user_id: int):

    db.execute(text("CALL EliminarUsuario(:id_usuario)"), {"id_usuario": user_id})
    db.commit()
    return {"message": "Usuario eliminado con éxito"}


# --------------------- Asignaturas --------------------- #

# Obtener todas las asignaturas
def get_asignaturas(db: Session, skip: int = 0, limit: int = 10):

    result = db.execute(text("SELECT * FROM LeerAsignatura(:skip, :limit)"), {"skip": skip, "limit": limit})
    return result.fetchall()


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
def get_evaluaciones(db: Session, skip: int = 0, limit: int = 10):
    result = db.execute(text("SELECT * FROM LeerEvaluacion(:skip, :limit)"), {"skip": skip, "limit": limit})
    return result.fetchall()

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
def get_comentarios(db: Session, evaluacion_id: int):
    result = db.execute(text("SELECT * FROM LeerComentario(:id_evaluacion)"), {"id_evaluacion": evaluacion_id})
    return result.fetchall()

# Crear un comentario
def create_comentario(db: Session, comentario):
    db.execute(text("""
        CALL InsertarComentario(:id_estudiante, :id_docente, :id_asignatura, :id_evaluacion, :comentario)
    """), {
        "id_estudiante": comentario.id_estudiante,
        "id_docente": comentario.id_docente,
        "id_asignatura": comentario.id_asignatura,
        "id_evaluacion": comentario.id_evaluacion,
        "comentario": comentario.comentario
    })
    db.commit()
    return {"message": "Comentario creado con éxito"}

# Eliminar un comentario
def delete_comentario(db: Session, comentario_id: int):
    db.execute(text("CALL EliminarComentario(:id_comentario)"), {"id_comentario": comentario_id})
    db.commit()
    return {"message": "Comentario eliminado con éxito"}