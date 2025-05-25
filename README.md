# 📘 API de Análisis de Comentarios

¡Bienvenido a la API de Análisis de Comentarios para Evaluaciones Docentes! Esta API está construida con dedicación usando **FastAPI** y **MySQL**, con magia NLP incluida 🧠✨. Aquí podrás gestionar usuarios, evaluaciones, comentarios y mucho más.

---

## 🚀 Características principales

- CRUD completo para usuarios, asignaturas, evaluaciones, comentarios, análisis de sentimientos y reportes.
- Procedimientos almacenados en MySQL para lógica de negocio robusta.
- Separación de responsabilidades (controladores, modelos, etc.).
- Contenerizada con **Podman** para despliegue fácil.
- Análisis de sentimientos automático con técnicas NLP.

---

## 📦 Instalación

1. Clona el repositorio:
```bash
git clone [https://github.com/tu_usuario/nombre_del_repo.git](https://github.com/D-Lopz/DataBaseAPI.git)
cd DataBaseAPI
```

2. Instala dependencias:
```bash
pip install -r requirements.txt
```

3. Configura tu base de datos MySQL en `.env` o `config.py`.

4. Ejecuta el servidor:
```bash
python -m uvicorn main:app --reload
```

---

## 🛠️ Estructura del Proyecto

```
.
├── app/
│ ├── main.py           # Punto de entrada de la API
│ ├── database.py       # Conexión a PostgreSQL
│ ├── models/           # Modelos SQLAlchemy
│ ├── schemas/          # Pydantic schemas
│ ├── crud.py           # Procedimientos almacenados y lógica de negocio
│ ├── auth.py           # Lógica de autenticación y JWT
│ ├── routes/           # Rutas organizadas por entidad
│ ├── utils/            # Funciones de análisis de sentimiento y helpers
│ └── config.py         # Variables de entorno y configuración
├── requirements.txt    # Instalación de dependencias
├── README.md           # Archivo actual
└── podman-compose.yml  # Configuración para contenerización
```

## 🚀 Tecnologías utilizadas

- [FastAPI](https://fastapi.tiangolo.com/) – Framework web moderno, rápido y eficiente.
- [PostgreSQL](https://www.postgresql.org/) – Base de datos relacional robusta.
- [SQLAlchemy](https://www.sqlalchemy.org/) – ORM para la gestión de modelos y queries.
- [Pydantic](https://docs.pydantic.dev/) – Validación de datos y modelos.
- [JWT](https://jwt.io/) – Autenticación segura basada en tokens.
- [spaCy / TextBlob / Transformers (opcional)] – Librerías para análisis de sentimiento.
- [Podman](https://podman.io/) – Contenerización sin Docker daemon.
---

## 📚 Endpoints

| Método | Ruta              | Descripción                      |
|--------|-------------------|----------------------------------|
| GET    | /usuarios/        | Lista todos los usuarios         |
| POST   | /usuarios/        | Crea un nuevo usuario            |
| DELETE | /usuarios/{id}    | Elimina un usuario               |
| GET    | /comentarios/     | Lista comentarios registrados    |
| POST   | /comentarios/     | Añade un comentario              |
| ...    | ...               | Y muchos más...                  |

Documentación interactiva en: `http://localhost:8000/docs`
---

## 📌 Notas importantes

- Los procedimientos almacenados y triggers están definidos directamente en MySQL (usando CREATE PROCEDURE y AFTER INSERT).
- Se recomienda ejecutar los scripts SQL de estructura antes de levantar la API por primera vez.
- Puedes extender el análisis de sentimientos integrando modelos más complejos como BERT o GPT-4 vía API externa.
---

## 🧪 Pruebas

Puedes usar herramientas como **Postman** o **cURL**, pero la magia real vive en:
```
http://localhost:8000/docs
```

---

## 🐳 Docker / Podman (opcional)

```bash
podman build -t api-docentes .
podman run -p 8000:8000 api-docentes
```

---

## 🤝 Contribuciones

¡Toda ayuda es bienvenida! Abre un issue, manda un pull request, o simplemente comparte esta API con tu equipo 💬💻.

---

## 📜 Licencia

Este proyecto está licenciado bajo los términos del MIT License.

---

Hecho con cariño por [David López] 💡