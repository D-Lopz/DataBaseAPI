from fastapi import FastAPI, HTTPException, Depends
from fastapi.responses import JSONResponse
from sqlalchemy.orm import Session
from database import SessionLocal
from schemas import UserLogin
from utils import verify_password
import uuid

app = FastAPI()

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@app.post("/login")
def login(user: UserLogin, db: Session = Depends(get_db)):
    result = db.execute("SELECT * FROM login_usuario(:email)", {'email': user.email})
    row = result.fetchone()
    if not row:
        raise HTTPException(status_code=401, detail="Credenciales inválidas")
    user_data = dict(row._mapping)
    if not verify_password(user.password, user_data["password_hash"]):
        raise HTTPException(status_code=401, detail="Credenciales inválidas")
    return JSONResponse(content={"message": "Inicio de sesión exitoso", "user_id": user_data["id"], "rol": user_data["rol"]})
