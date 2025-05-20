from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from sqlalchemy import create_engine
from dotenv import load_dotenv
import os

# Cargar variables desde .env
load_dotenv()

# Usar la cadena de conexión del entorno
DB_URL = os.getenv("DATABASE_URL")
print("DATABASE_URL cargada:", DB_URL)


# Crear el motor de la base de datos
engine = create_engine(DB_URL)

# Sesión de SQLAlchemy
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# Base declarativa para modelos
Base = declarative_base()
