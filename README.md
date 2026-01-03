# Laravel Docker Boilerplate (Unix Socket)

Минималистичный базовый проект для Laravel на стеке PHP-FPM + Nginx (через Unix-сокет) + PostgreSQL + pgAdmin.

## Структура проекта
- `src/` — исходный код Laravel (монтируется в `/var/www/laravel`)
- `config/` — конфигурация Nginx и PHP
- `docker/` — Dockerfile для образов
- `.env.docker` — переменные окружения для Docker-контейнеров

## Быстрый старт

1. **Настройка окружения:**
   Скопируйте пример файла окружения:
   ```bash
   cp .env.docker.example .env.docker
   ```

2. **Создание нового проекта Laravel:**
   > **Важно:** Для создания нового проекта папка `src/` не должна существовать или должна быть пустой.
   ```bash
   make laravel-install
   ```
   Эта команда поднимет контейнеры и установит свежий Laravel в директорию `src/`.

3. **Если проект уже создан (есть папка src):**
   ```bash
   make up
   ```

4. **Доступ к сервисам:**
    - Web App: [http://localhost](http://localhost)
    - pgAdmin: [http://localhost:8080](http://localhost:8080) (email: `admin@example.com`, pass: `admin`)
    - PostgreSQL: `localhost:5432`

## Основные команды (Makefile)

- `make up` — запуск контейнеров
- `make down` — остановка контейнеров
- `make restart` — перезапуск контейнеров
- `make build` — сборка образов
- `make rebuild` — пересборка образов без кэша
- `make laravel-install` — установка чистого Laravel в `src/`
- `make xdebug-up` — запуск с включенным Xdebug
- `make artisan CMD="migrate"` — выполнение команд artisan
- `make composer CMD="install"` — выполнение команд composer
- `make migrate` — выполнение миграций
- `make rollback` — откат миграций
- `make fresh` — пересоздание БД и запуск сидов
- `make tinker` — запуск Laravel Tinker
- `make test-php` — запуск тестов (PHPUnit)
- `make permissions` — исправление прав на storage/cache
- `make shell-php` — вход в консоль PHP-контейнера
- `make shell-postgres` — вход в консоль PostgreSQL
- `make logs` — просмотр логов всех контейнеров
- `make clean` — удаление контейнеров и томов (очистка БД)

## Особенности
- Связь Nginx и PHP через **Unix-сокет** (`/var/run/php/php-fpm.sock`).
- DocumentRoot Nginx настроен на `src/public`.
- Весь проект Laravel находится в подпапке `src/`, что позволяет держать конфигурацию Docker отдельно от кода приложения.
- PostgreSQL 17.
- Готовый Dockerfile со всеми необходимыми расширениями для Laravel (pdo_pgsql, gd, intl, zip, opcache, xdebug и др.).