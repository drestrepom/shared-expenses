# Proyecto de Gastos Compartidos

Este proyecto consiste en una aplicación frontend en Angular y un servicio backend API.

## Ejecución con Docker Compose

### Requisitos Previos
- Docker
- Docker Compose

### Pasos para Ejecutar

1. Clonar el repositorio:
```bash
git clone https://github.com/drestrepom/shared-expenses.git
cd shared-expenses
```

2. Iniciar los servicios:
```bash
docker-compose up --build -d
```

Esto iniciará tanto el frontend como el backend y la base de datos:
- El frontend estará disponible en: http://localhost:4200
- La API del backend estará disponible en: http://localhost:8000
- La base de datos PostgreSQL estará disponible en el puerto: 5432 (generalmente no se accede directamente desde el host en desarrollo).

### Verificar la Conexión a la Base de Datos

Una vez que los servicios estén en funcionamiento, puedes verificar que el backend se conecta correctamente a la base de datos accediendo a la siguiente URL en tu navegador o usando una herramienta como curl:

[http://localhost:8000/db-check](http://localhost:8000/db-check)

Si la conexión es exitosa, deberías ver un mensaje como: `{"message":"Database connection successful!"}`.

### Comandos Adicionales de Docker Compose

- Para ver los logs en tiempo real:
```bash
docker-compose logs -f
```

- Para detener los servicios:
```bash
docker-compose down
```

- Si solo quieres reconstruir y reiniciar los contenedores sin el modo detached:
```bash
docker-compose up --build
```

### Servicios

El proyecto consta de tres servicios principales:

1. **Base de Datos (PostgreSQL)**
   - Imagen: `postgres:15-alpine`
   - Puerto expuesto (host): 5432
   - Persistencia de datos: volumen `postgres_data`

2. **Backend (API)**
   - Puerto: 8000
   - Entorno de desarrollo
   - Conectado a la base de datos PostgreSQL.
   - Hot-reload habilitado para desarrollo (si está configurado en el Dockerfile/proyecto).

3. **Frontend (Angular)**
   - Puerto: 4200
   - Desarrollado con Angular
   - Servido usando Nginx (asumiendo una configuración típica de producción para Angular en Docker).
   - Depende del servicio backend.
