from jose import jwt, JWTError  
from passlib.context import CryptContext
from fastapi.security import OAuth2PasswordBearer
from dotenv import load_dotenv
import os

# Carga las variables del archivo .env
load_dotenv()

# 🔐 Seguridad
SECRET_KEY = os.getenv("SECRET_KEY", "BACKUP_KEY")
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 60

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="login")
