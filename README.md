# Entorno de Desarrollo con Nix

Entorno de desarrollo reproducible usando Nix Flakes con Python, Node.js, MariaDB y PostgreSQL.

## Características

- **Python 3** con FastAPI, SQLAlchemy, Uvicorn y más
- **Node.js** con pnpm para gestión de paquetes
- **MariaDB** y **PostgreSQL** aislados por proyecto
- **Neovim** como editor
- **Entornos aislados** - cada proyecto tiene sus propias bases de datos
- **Reproducible** - funciona igual en cualquier máquina con Nix

## Prerrequisitos

- [NixOS](https://nixos.org/) o Nix instalado con flakes habilitados
- Git

### Habilitar Flakes en Nix

Si aún no tienes flakes habilitados, agrega esto a tu `~/.config/nix/nix.conf` o `/etc/nix/nix.conf`:

```conf
experimental-features = nix-command flakes
```

## Inicio Rápido

### 1. Clonar el repositorio

```bash
git clone git@github.com:Andreco1/dev-env-nixOS-Flake.git
cd dev-env
```

### 2. Entrar al entorno de desarrollo

```bash
nix develop
```

La primera vez tomará unos minutos mientras descarga y configura todo. Las siguientes veces será instantáneo.

### 3. Iniciar las bases de datos

```bash
# MariaDB
start-mysql

# PostgreSQL
start-postgres
```

## Herramientas Incluidas

### Lenguajes y Runtimes
- Python 3 con paquetes: FastAPI, SQLAlchemy, Uvicorn, Psycopg2, Pydantic, Requests
- Node.js (última versión LTS)
- pnpm (gestor de paquetes rápido para Node.js)

### Bases de Datos
- MariaDB 
- PostgreSQL 16

### Desarrollo
- GCC (compilador C/C++)
- Git
- Neovim
- OpenSSL
- Make

### Utilidades
- curl
- wget
- jq

## Comandos Disponibles

### MariaDB
```bash
start-mysql   # Iniciar servidor MariaDB
stop-mysql    # Detener servidor MariaDB
mysql         # Cliente MySQL
```

### PostgreSQL
```bash
start-postgres  # Iniciar servidor PostgreSQL
stop-postgres   # Detener servidor PostgreSQL
psql            # Cliente PostgreSQL
```

### Python
El entorno virtual de Python se activa automáticamente al entrar con `nix develop`.

```bash
pip install <paquete>    # Instalar paquetes adicionales
python script.py         # Ejecutar scripts
uvicorn main:app --reload  # Iniciar FastAPI
```

### Node.js
```bash
pnpm install    # Instalar dependencias
pnpm run dev    # Ejecutar scripts de desarrollo
node app.js     # Ejecutar aplicaciones Node.js
```

## Estructura de Directorios

```
.
├── flake.nix           # Configuración del entorno Nix
├── flake.lock          # Versiones bloqueadas de dependencias
├── .devenv/            # Datos del entorno (ignorado en git)
│   ├── mariadb/        # Datos de MariaDB
│   ├── postgres/       # Datos de PostgreSQL
│   └── venv/           # Entorno virtual de Python
└── README.md           # Este archivo
```

## Personalización

### Agregar Paquetes Python

Edita `flake.nix` en la sección `pythonEnv`:

```nix
pythonEnv = python.withPackages (ps: with ps; [
  # ... paquetes existentes ...
  numpy
  pandas
  # tus paquetes aquí
]);
```

### Agregar Herramientas del Sistema

Edita `flake.nix` en la sección `packages`:

```nix
packages = with pkgs; [
  # ... paquetes existentes ...
  redis
  docker
  # tus herramientas aquí
];
```

Después de editar, ejecuta:

```bash
nix flake update  # Actualizar dependencias
nix develop       # Reconstruir el entorno
```

## Gestión de Bases de Datos

### MariaDB

Las bases de datos se guardan en `.devenv/mariadb/data/`

```bash
# Conectar a MariaDB
mysql

# Crear base de datos
mysql -e "CREATE DATABASE miapp;"

# Importar datos
mysql miapp < backup.sql
```

### PostgreSQL

Las bases de datos se guardan en `.devenv/postgres/`

```bash
# Conectar a PostgreSQL
psql

# Crear base de datos
createdb miapp

# Importar datos
psql miapp < backup.sql
```

## Solución de Problemas

### Error: "address already in use"
Otro servicio está usando el puerto. Para MariaDB (puerto 3306) o PostgreSQL (puerto 5432):

```bash
# Ver qué está usando el puerto
sudo lsof -i :3306
sudo lsof -i :5432
```

### Resetear las bases de datos

```bash
# Detener servidores
stop-mysql
stop-postgres

# Eliminar datos (¡cuidado!)
rm -rf .devenv/mariadb
rm -rf .devenv/postgres

# Reiniciar el entorno
exit
nix develop
```

### Actualizar Nix Flakes

```bash
nix flake update
```

## Contribuir

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/amazing`)
3. Commit tus cambios (`git commit -m 'Add amazing feature'`)
4. Push a la rama (`git push origin feature/amazing`)
5. Abre un Pull Request

## Licencia

[MIT License](LICENSE)

## Enlaces Útiles

- [Nix Flakes](https://nixos.wiki/wiki/Flakes)
- [NixOS Packages Search](https://search.nixos.org/)
- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [MariaDB Documentation](https://mariadb.org/documentation/)

## Tips

- Usa `direnv` para activar automáticamente el entorno al entrar al directorio
- Los datos de las bases de datos persisten entre sesiones
- Puedes tener múltiples proyectos con sus propias bases de datos aisladas
- El entorno es reproducible: comparte `flake.nix` y `flake.lock` para que otros tengan exactamente el mismo entorno

---

**¿Preguntas?** Abre un issue en el repositorio.
