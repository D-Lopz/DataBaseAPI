# 📘 API de Análisis de Comentarios Docentes

¡Bienvenido a la API de Análisis de Comentarios Docentes! Esta API está construida con ❤️ usando **FastAPI** y **PostgreSQL**, con magia NLP incluida 🧠✨. Aquí podrás gestionar usuarios, evaluaciones, comentarios y mucho más.

---

## 🚀 Características principales

- CRUD completo para usuarios, asignaturas, evaluaciones, comentarios, análisis de sentimientos y reportes.
- Procedimientos almacenados en PostgreSQL para lógica de negocio robusta.
- Separación de responsabilidades (controladores, modelos, etc.).
- Contenerizada con **Podman** para despliegue fácil.
- Análisis de sentimientos automático con técnicas NLP.

---

## 📦 Instalación

1. Clona el repositorio:
```bash
git clone https://github.com/tu_usuario/nombre_del_repo.git
cd nombre_del_repo
```

2. Instala dependencias:
```bash
pip install -r requirements.txt
```

3. Configura tu base de datos PostgreSQL en `.env` o `config.py`.

4. Ejecuta el servidor:
```bash
uvicorn main:app --reload
```

---

## 🛠️ Estructura del Proyecto

```
📁 api-docentes
├── main.py             # Punto de entrada de la API
├── crud.py             # Lógica de base de datos / procedimientos
├── models.py           # Definiciones Pydantic
├── controllers/        # Separación de lógica
├── database/           # Conexión a PostgreSQL
├── nlp/                # Análisis de sentimientos y más
└── README.md           # Este archivo épico
```

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

¡Toda ayuda es bienvenida! Abre un issue, manda un pull request, o simplemente comparte esta API con tus compas 💬💻.

---

## 📜 Licencia

MIT. Usa, modifica y vuela libre 🕊️.

---

Hecho con cariño por [David López] 💡