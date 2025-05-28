# API de Gastos Compartidos

## Configuración del Entorno de Desarrollo

### Requisitos Previos
- Python 3.8 o superior
- Gestor de paquetes uv

### Pasos para Ejecutar el Proyecto

1. **Instalar uv** (si aún no lo tienes instalado)
   ```bash
   curl -LsSf https://astral.sh/uv/install.sh | sh
   ```
   Asegúrate de que el directorio de instalación esté en tu variable de entorno PATH.

2. **Ejecutar el Servidor de Desarrollo**
   ```bash
   uv run fastapi dev
   ```
   La aplicación estará disponible en http://127.0.0.1:8000/
