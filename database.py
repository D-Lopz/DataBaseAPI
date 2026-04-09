from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from sqlalchemy import create_engine
from dotenv import load_dotenv
import os

# Cargar variables desde .env
load_dotenv()

# Usar la cadena de conexión del entorno
DB_URL = os.getenv("DATABASE_URL")
if DB_URL.startswith("mysql://"):
    DB_URL = DB_URL.replace("mysql://", "mysql+pymysql://", 1)
print("DATABASE_URL cargada:", DB_URL)


# Crear el motor de la base de datos
engine = create_engine(
    DB_URL,
    connect_args={
        "ssl": {
            "check_hostname": False,
            "ssl_mode": "REQUIRED",
            # Esto desactiva la verificación estricta que está fallando
            "fake_user_agent": "Mozilla/5.0" # A veces ayuda con proxies
        }
    }
)

# Sesión de SQLAlchemy
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# Base declarativa para modelos
Base = declarative_base()
