{
  description = "Entorno de desarrollo con Python, Node.js y bases de datos";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        
        # Python con un entorno virtual más robusto
        python = pkgs.python3;
        
        # Entorno Python personalizado con dependencias básicas
        pythonEnv = python.withPackages (ps: with ps; [
          pip
          uvicorn
          fastapi
          psycopg2
          sqlalchemy
          python-dotenv
          requests
          pydantic
        ]);

      in {
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            # Control de versiones
            git
            
            # Compiladores y herramientas de desarrollo
            gcc
            gnumake
            
            # Python
            pythonEnv
            
            # Node.js con gestor de paquetes
            nodejs
            # Los paquetes de node ahora están en el nivel superior
            pnpm
            
            # Bases de datos
            mariadb
            postgresql_16
            
            # Editores
            neovim
            
            # Herramientas útiles
            curl
            wget
            jq
            
            # SSL
            openssl
            
            # LibreOffice (comentado por ser pesado)
            # libreoffice
          ];

          shellHook = ''
            echo "🚀 Entorno de desarrollo activado"
            echo ""
            
            # Configuración de directorios del proyecto
            export PROJECT_ROOT="$(pwd)"
            export DATA_DIR="$PROJECT_ROOT/.devenv"
            mkdir -p "$DATA_DIR"
            
            # === MariaDB ===
            export MYSQL_HOME="$DATA_DIR/mariadb"
            export MYSQL_DATADIR="$MYSQL_HOME/data"
            export MYSQL_UNIX_PORT="$MYSQL_HOME/mysql.sock"
            export MYSQL_PID_FILE="$MYSQL_HOME/mysql.pid"
            
            if [ ! -d "$MYSQL_DATADIR" ]; then
              echo "📦 Inicializando MariaDB..."
              mkdir -p "$MYSQL_DATADIR"
              ${pkgs.mariadb}/bin/mysql_install_db \
                --datadir="$MYSQL_DATADIR" \
                --basedir=${pkgs.mariadb} \
                --auth-root-authentication-method=normal
              echo "✓ MariaDB inicializado"
            fi
            
            # === PostgreSQL ===
            export PGDATA="$DATA_DIR/postgres"
            export PGHOST="$DATA_DIR/postgres"
            export PGDATABASE="devdb"
            
            if [ ! -d "$PGDATA" ]; then
              echo "📦 Inicializando PostgreSQL..."
              ${pkgs.postgresql_16}/bin/initdb -D "$PGDATA" --no-locale --encoding=UTF8
              echo "✓ PostgreSQL inicializado"
            fi
            
            # === Python Virtual Environment ===
            export VENV_DIR="$DATA_DIR/venv"
            if [ ! -d "$VENV_DIR" ]; then
              echo "🐍 Creando entorno virtual de Python..."
              ${pythonEnv}/bin/python -m venv "$VENV_DIR"
              echo "✓ Entorno virtual creado"
            fi
            
            # Aliases útiles
            alias start-mysql="${pkgs.mariadb}/bin/mysqld --datadir=$MYSQL_DATADIR --socket=$MYSQL_UNIX_PORT --pid-file=$MYSQL_PID_FILE --port=3306 &"
            alias stop-mysql="${pkgs.mariadb}/bin/mysqladmin -S $MYSQL_UNIX_PORT shutdown"
            alias mysql="${pkgs.mariadb}/bin/mysql -S $MYSQL_UNIX_PORT"
            
            alias start-postgres="${pkgs.postgresql_16}/bin/pg_ctl -D $PGDATA -l $DATA_DIR/postgres/logfile start"
            alias stop-postgres="${pkgs.postgresql_16}/bin/pg_ctl -D $PGDATA stop"
            alias psql="${pkgs.postgresql_16}/bin/psql -h $PGHOST"
            
            # Activar venv automáticamente
            source "$VENV_DIR/bin/activate"
            
            echo ""
            echo "📋 Comandos disponibles:"
            echo "  MariaDB:"
            echo "    start-mysql  → Iniciar servidor"
            echo "    stop-mysql   → Detener servidor"
            echo "    mysql        → Cliente MySQL"
            echo ""
            echo "  PostgreSQL:"
            echo "    start-postgres → Iniciar servidor"
            echo "    stop-postgres  → Detener servidor"
            echo "    psql           → Cliente PostgreSQL"
            echo ""
            echo "  Python: entorno virtual activado en $VENV_DIR"
            echo "  Node.js: $(node --version)"
            echo "  pnpm: $(pnpm --version)"
            echo "  Datos del proyecto: $DATA_DIR"
            echo ""
          '';

          # Variables de entorno adicionales
          env = {
            # SSL certificates
            SSL_CERT_FILE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
            
            # Python
            PYTHONPATH = "$PWD";
            
            # Node.js
            NODE_ENV = "development";
          };
        };
      }
    );
}
