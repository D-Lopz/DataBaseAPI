🎓 API REST de Análisis de Comentarios Docentes — FastAPI + PostgreSQL
Bienvenido a la API de análisis de comentarios de evaluación docente, creada con el poder de FastAPI, la firmeza de PostgreSQL, y el ritmo fluido de un backend moderno. Esta API está diseñada para manejar usuarios, asignaturas, comentarios, análisis de sentimientos y reportes de manera eficiente, clara y segura.

📚 Características principales
🔐 Gestión de usuarios: CRUD completo de usuarios.

🏫 Gestión académica: manejo de asignaturas y evaluaciones.

💬 Comentarios y NLP: análisis automático de sentimientos.

📊 Reportes: generación de reportes por usuario, materia o periodo.

🔁 Procedimientos almacenados: lógica encapsulada en PostgreSQL para mayor eficiencia.

🐳 Contenerización: integración con Podman (Docker compatible) para despliegue ágil.

🚀 Tecnologías usadas

Tecnología	Descripción
FastAPI	Framework principal de la API
PostgreSQL	Motor de base de datos
SQLAlchemy	ORM para manejo de datos
psycopg2	Conector PostgreSQL para Python
Uvicorn	Servidor ASGI rápido
Podman	Contenedores para desarrollo
🛠️ Estructura del proyecto
bash
Copy
Edit
📁 API/
├── 📄 main.py              # Punto de entrada de la API
├── 📄 crud.py              # Lógica de base de datos y llamadas a procedimientos
├── 📄 models.py            # Esquemas de datos con Pydantic
├── 📄 database.py          # Conexión a PostgreSQL
├── 📄 schemas.sql          # Estructura de la base de datos
├── 📄 procedures.sql       # Procedimientos almacenados
├── 📁 tests/               # Pruebas automatizadas
└── 📄 README.md            # Este archivo
🔄 Endpoints principales

Método	Endpoint	Descripción
GET	/usuarios/	Listar todos los usuarios
POST	/usuarios/	Crear un nuevo usuario
PUT	/usuarios/{id}	Actualizar datos de un usuario
DELETE	/usuarios/{id}	Eliminar un usuario
GET	/comentarios/	Obtener comentarios
POST	/analizar/	Analizar comentario con NLP
GET	/reportes/	Ver reportes de evaluación
🧪 Cómo correr la API
Clona el repositorio:

bash
Copy
Edit
git clone https://github.com/tuusuario/tu-repo-api.git
cd tu-repo-api
Crea tu entorno virtual e instala dependencias:

bash
Copy
Edit
python -m venv venv
source venv/bin/activate  # o venv\Scripts\activate en Windows
pip install -r requirements.txt
Configura tu base de datos PostgreSQL y carga los archivos .sql.

Ejecuta la API:

bash
Copy
Edit
uvicorn main:app --reload
🐳 Usando Podman (opcional)
Puedes contenerizar la API para desarrollo o producción:

bash
Copy
Edit
podman build -t api-docentes .
podman run -d -p 8000:8000 api-docentes
⚠️ Consideraciones
La eliminación de usuarios está restringida si tienen comentarios asociados (por integridad referencial).

Todos los análisis de sentimientos deben pasarse por la función analizar/ antes de guardarse.

✨ Créditos
Creado por David López