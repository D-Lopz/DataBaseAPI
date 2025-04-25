# 🎯 API de Gestión de Usuarios y Comentarios – FastAPI + PostgreSQL

¡Bienvenido! Esta API está diseñada para gestionar usuarios, evaluaciones y análisis de comentarios con técnicas de NLP, todo servido con FastAPI y respaldado por una base de datos PostgreSQL.

---

## 🚀 Tecnologías

- **FastAPI** – Backend rápido y moderno.
- **PostgreSQL** – Base de datos poderosa y robusta.
- **SQLAlchemy** – ORM para manejar las queries con elegancia.
- **psycopg2** – Conector PostgreSQL para Python.
- **Docker + Podman** – Contenerización y despliegue seguro.

---

## 📦 Estructura del proyecto

```bash
API2/
├── main.py                # Archivo principal de FastAPI
├── crud.py                # Funciones CRUD y lógica de DB
├── models/                # Modelos de datos SQLAlchemy
├── database.py            # Conexión y configuración DB
├── requirements.txt       # Dependencias del proyecto
└── README.md              # Este archivo hermoso que estás leyendo
🔧 Configuración rápida
Clona el repositorio:

bash
Copy
Edit
git clone https://github.com/tu_usuario/api-gestion.git
cd api-gestion
Crea un entorno virtual y activa:

bash
Copy
Edit
python -m venv venv
source venv/bin/activate  # En Windows: venv\Scripts\activate
Instala las dependencias:

bash
Copy
Edit
pip install -r requirements.txt
Ejecuta la API:

bash
Copy
Edit
uvicorn main:app --reload
Visita la docs:

arduino
Copy
Edit
http://127.0.0.1:8000/docs
🛠 Funcionalidades
Usuarios

Crear, consultar, actualizar, eliminar

Evaluaciones

Relación con usuarios

Comentarios

Registro y análisis de sentimientos

❌ Manejo de errores
Esta API detecta y retorna errores personalizados. Ejemplo: si intentas borrar un usuario con comentarios relacionados, se recibe un mensaje claro y entendible.

🐳 Docker
¿Quieres correrlo en un contenedor? Usa:

bash
Copy
Edit
docker build -t api-users .
docker run -p 8000:8000 api-users
❤️ Autor
Creado con pasión por David
Inspirado por ritmos latinos y líneas de código 🕺💻