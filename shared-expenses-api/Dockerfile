# ———————————————————————
# 1) Builder: instalar Poetry y deps en system Python
# ———————————————————————
FROM python:3.12-slim AS builder

# Variables de entorno para control de Poetry y pip
ENV POETRY_NO_INTERACTION=1 \
    POETRY_VIRTUALENVS_CREATE=false \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=off \
    PIP_DISABLE_PIP_VERSION_CHECK=on

# Instalar Poetry con pip
RUN pip install --no-cache-dir "poetry==2.1.3"

WORKDIR /app

# Copiar lockfiles para cachear layer de deps
COPY pyproject.toml poetry.lock ./

# Instalar sólo deps de producción en el site-packages del sistema
RUN poetry install --no-root --no-interaction --no-ansi

# ———————————————————————
# 2) Runtime: copiar deps + código
# ———————————————————————
FROM python:3.12-slim AS runtime

# Optimizar Python en contenedor
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1

WORKDIR /app

# 1) Copiar dependencias instaladas en builder al Python del sistema
COPY --from=builder /usr/local/lib/python3.12/site-packages /usr/local/lib/python3.12/site-packages
COPY --from=builder /usr/local/bin/poetry /usr/local/bin/poetry

# 2) Copiar el resto de tu aplicación
COPY . .

# 3) Exponer puerto y arrancar con Uvicorn
EXPOSE 80
CMD ["python", "-m", "uvicorn", "main:app", "--host", "0.0.0.0", "--port", "80"]
