#!/bin/bash

# Correr tu app con uvicorn, usando el puerto que Railway asigna
uvicorn main:app --host 0.0.0.0 --port ${PORT:-8000}
