# Laravel Docker Boilerplate (Unix Socket)

A minimalist base project for Laravel using the PHP-FPM + Nginx stack (via Unix socket) + PostgreSQL + pgAdmin.

## Project Structure
- `src/` — Laravel source code (mounted to `/var/www/laravel`)
- `config/` — Nginx and PHP configuration
- `docker/` — Dockerfiles for images
- `.env.docker` — environment variables for Docker containers

## Quick Start

1. **Environment Setup:**
   Copy the example environment file:
   ```bash
   cp .env.docker.example .env.docker
   ```

2. **Creating a New Laravel Project:**
   > **Important:** To create a new project, the `src/` folder must not exist or must be empty.
   ```bash
   make laravel-install
   ```
   This command will start the containers and install a fresh Laravel instance into the `src/` directory.

3. **If the project is already created (src folder exists):**
   ```bash
   make up
   ```

4. **Accessing Services:**
    - Web App: [http://localhost](http://localhost)
    - pgAdmin: [http://localhost:8080](http://localhost:8080) (email: `admin@example.com`, pass: `admin`)
    - PostgreSQL: `localhost:5432`

## Key Commands (Makefile)

- `make up` — start containers
- `make down` — stop containers
- `make restart` — restart containers
- `make build` — build images
- `make rebuild` — rebuild images without cache
- `make laravel-install` — install fresh Laravel in `src/`
- `make xdebug-up` — start with Xdebug enabled
- `make artisan CMD="migrate"` — run artisan commands
- `make composer CMD="install"` — run composer commands
- `make migrate` — run migrations
- `make rollback` — rollback migrations
- `make fresh` — recreate DB and run seeds
- `make tinker` — run Laravel Tinker
- `make test-php` — run tests (PHPUnit)
- `make permissions` — fix storage/cache permissions
- `make shell-php` — enter PHP container shell
- `make shell-postgres` — enter PostgreSQL shell
- `make logs` — view logs of all containers
- `make clean` — remove containers and volumes (clear DB)

## Features
- Nginx and PHP communication via **Unix socket** (`/var/run/php/php-fpm.sock`).
- Nginx DocumentRoot configured to `src/public`.
- The entire Laravel project is located in the `src/` subfolder, keeping Docker configuration separate from application code.
- PostgreSQL 17.
- Ready-to-use Dockerfile with all necessary extensions for Laravel (pdo_pgsql, gd, intl, zip, opcache, xdebug, etc.).
