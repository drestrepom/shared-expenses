# Proyecto de Gastos Compartidos

Este proyecto consiste en una aplicación frontend en Angular y un servicio backend API.

## Ejecución con Docker Compose

### Requisitos Previos
- Docker
- Docker Compose

### Pasos para Ejecutar

1. Clonar el repositorio:
```bash
git clone <repository-url>
cd project
```

2. Iniciar los servicios:
```bash
docker-compose up
```

Esto iniciará tanto el frontend como el backend:
- El frontend estará disponible en: http://localhost:4200
- La API del backend estará disponible en: http://localhost:8000

### Comandos Adicionales de Docker Compose

- Para ejecutar en modo detached (en segundo plano):
```bash
docker-compose up -d
```

- Para detener los servicios:
```bash
docker-compose down
```

- Para reconstruir los contenedores:
```bash
docker-compose up --build
```

- Para ver los logs:
```bash
docker-compose logs -f
```

### Servicios

El proyecto consta de dos servicios principales:

1. **Frontend (Angular)**
   - Puerto: 4200
   - Desarrollado con Angular
   - Servido usando Nginx

2. **Backend (API)**
   - Puerto: 8000
   - Entorno de desarrollo
   - Hot-reload habilitado para desarrollo
