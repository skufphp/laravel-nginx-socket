# ==========================================
# Laravel PHP-FPM Nginx Socket (Boilerplate)
# ==========================================

.PHONY: help up down restart build rebuild logs status shell-php shell-nginx shell-postgres clean setup artisan migrate laravel-install

# Цвета для вывода
YELLOW=\033[0;33m
GREEN=\033[0;32m
RED=\033[0;31m
NC=\033[0m

# Сервисы
PHP_CONTAINER=laravel-php-nginx-socket
NGINX_CONTAINER=laravel-nginx-socket
POSTGRES_CONTAINER=laravel-postgres-nginx-socket
PGADMIN_CONTAINER=laravel-pgadmin-nginx-socket

# Файл переменных окружения
ENV_FILE=.env.docker

help: ## Показать справку
	@echo "$(YELLOW)Laravel Docker Boilerplate (Unix Socket)$(NC)"
	@echo "======================================"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "$(GREEN)%-20s$(NC) %s\n", $$1, $$2}'

check-files: ## Проверить наличие всех необходимых файлов
	@echo "$(YELLOW)Проверка файлов конфигурации...$(NC)"
	@test -f docker-compose.yml || (echo "$(RED)✗ docker-compose.yml не найден$(NC)" && exit 1)
	@test -f docker-compose.xdebug.yml || (echo "$(RED)✗ docker-compose.xdebug.yml не найден$(NC)" && exit 1)
	@test -f $(ENV_FILE) || (echo "$(RED)✗ $(ENV_FILE) не найден$(NC)" && exit 1)
	@test -f docker/php.Dockerfile || (echo "$(RED)✗ docker/php.Dockerfile не найден$(NC)" && exit 1)
	@test -f docker/nginx.Dockerfile || (echo "$(RED)✗ docker/nginx.Dockerfile не найден$(NC)" && exit 1)
	@test -f config/nginx/conf.d/default.conf || (echo "$(RED)✗ config/nginx/conf.d/default.conf не найден$(NC)" && exit 1)
	@test -f config/php/php.ini || (echo "$(RED)✗ config/php/php.ini не найден$(NC)" && exit 1)
	@test -f config/php/www.conf || (echo "$(RED)✗ config/php/www.conf не найден$(NC)" && exit 1)
	@echo "$(GREEN)✓ Все файлы на месте$(NC)"

setup: ## Настройка окружения (копирование .env если нет)
	@if [ ! -f .env.docker ]; then \
		cp .env.docker.example .env.docker; \
		echo "$(GREEN)✓ Создан .env.docker из примера$(NC)"; \
	fi

up: check-files ## Запустить контейнеры
	@mkdir -p src
	$(MAKE) setup
	docker compose up -d
	@echo "$(GREEN)✓ Проект запущен на http://localhost$(NC)"

down: ## Остановить контейнеры
	docker compose down

restart: ## Перезапустить контейнеры
	docker compose restart

build: ## Собрать образы
	docker compose build

rebuild: ## Пересобрать образы без кэша
	docker compose build --no-cache

xdebug-up: check-files ## Запуск с включенным Xdebug (через docker-compose.xdebug.yml)
	@echo "$(YELLOW)Запуск с Xdebug...$(NC)"
	docker compose -f docker-compose.yml -f docker-compose.xdebug.yml up -d
	@echo "$(GREEN)✓ Сервисы с Xdebug запущены$(NC)"
	@echo "$(YELLOW)Доступные URL:$(NC)"
	@echo "  Web Server:  http://localhost"
	@echo "  pgAdmin:     http://localhost:8080"

xdebug-down: ## Остановить стек, запущенный с Xdebug
	@echo "$(YELLOW)Остановка сервисов с Xdebug...$(NC)"
	docker compose -f docker-compose.yml -f docker-compose.xdebug.yml down
	@echo "$(GREEN)✓ Сервисы с Xdebug остановлены$(NC)"

logs: ## Показать логи
	docker compose logs -f

logs-php: ## Просмотр логов PHP-FPM
	docker compose logs -f $(PHP_CONTAINER)

logs-nginx: ## Просмотр логов Nginx
	docker compose logs -f $(NGINX_CONTAINER)

logs-postgres: ## Просмотр логов PostgreSQL
	docker compose logs -f $(POSTGRES_CONTAINER)

logs-pgadmin: ## Просмотр логов pgAdmin
	docker compose logs -f $(PGADMIN_CONTAINER)

status: ## Статус контейнеров
	docker compose ps

shell-php: ## Войти в контейнер PHP
	docker compose exec $(PHP_CONTAINER) sh

shell-nginx: ## Подключиться к контейнеру Nginx
	docker compose exec $(NGINX_CONTAINER) sh

shell-postgres: ## Подключиться к PostgreSQL CLI
	docker compose exec $(POSTGRES_CONTAINER) psql -U $$(grep POSTGRES_USER $(ENV_FILE) | cut -d '=' -f 2) -d $$(grep POSTGRES_DB $(ENV_FILE) | cut -d '=' -f 2)

# --- Команды Laravel ---

laravel-install: up ## Создать новый проект Laravel в ./src
	@if [ -f src/artisan ]; then \
		echo "$(RED)Ошибка: Директория ./src уже содержит Laravel проект.$(NC)"; \
		exit 1; \
	fi
	@echo "$(YELLOW)Установка Laravel...$(NC)"
	docker compose exec $(PHP_CONTAINER) composer create-project laravel/laravel .
	docker compose exec $(PHP_CONTAINER) php artisan key:generate
	$(MAKE) permissions
	@echo "$(GREEN)✓ Laravel успешно установлен в ./src$(NC)"

artisan: ## Запустить команду artisan (make artisan CMD="migrate")
	docker compose exec $(PHP_CONTAINER) php artisan $(CMD)

composer: ## Запустить команду composer (make composer CMD="install")
	docker compose exec $(PHP_CONTAINER) composer $(CMD)

migrate: ## Запустить миграции
	docker compose exec $(PHP_CONTAINER) php artisan migrate

rollback: ## Откатить миграции
	docker compose exec $(PHP_CONTAINER) php artisan migrate:rollback

fresh: ## Пересоздать базу и запустить сиды
	docker compose exec $(PHP_CONTAINER) php artisan migrate:fresh --seed

tinker: ## Запустить Laravel Tinker
	docker compose exec $(PHP_CONTAINER) php artisan tinker

test-php: ## Запустить тесты PHP (PHPUnit)
	docker compose exec $(PHP_CONTAINER) php artisan test

permissions: ## Исправить права доступа для Laravel (storage/cache)
	@echo "$(YELLOW)Исправление прав доступа...$(NC)"
	docker compose exec $(PHP_CONTAINER) sh -c "if [ -d storage ]; then chown -R www-data:www-data storage bootstrap/cache && chmod -R ug+rwX storage bootstrap/cache; fi"
	@echo "$(GREEN)✓ Права доступа исправлены$(NC)"

info: ## Показать информацию о проекте
	@echo "$(YELLOW)Laravel-Nginx-Socket Development Environment$(NC)"
	@echo "======================================"
	@echo "$(GREEN)Сервисы:$(NC)"
	@echo "  • PHP-FPM 8.4 (Alpine)"
	@echo "  • Nginx"
	@echo "  • PostgreSQL 17"
	@echo "  • pgAdmin 4"
	@echo ""
	@echo "$(GREEN)Структура:$(NC)"
	@echo "  • src/              - исходный код Laravel"
	@echo "  • config/nginx/     - конфигурация Nginx"
	@echo "  • config/php/       - конфигурация PHP (php.ini)"
	@echo "  • .env.docker       - переменные окружения"
	@echo ""
	@echo "$(GREEN)Порты:$(NC)"
	@echo "  • 80   - Nginx (Web Server)"
	@echo "  • 5432 - PostgreSQL (Database)"
	@echo "  • 8080 - pgAdmin (DB Admin Interface)"
	@echo "  • Unix Socket - Связь PHP-FPM <-> Nginx"

validate: ## Проверить доступность сервисов по HTTP
	@echo "$(YELLOW)Проверка работы сервисов...$(NC)"
	@echo -n "Nginx (http://localhost): "
	@curl -s -o /dev/null -w "%{http_code}" http://localhost && echo " $(GREEN)✓$(NC)" || echo " $(RED)✗$(NC)"
	@echo -n "pgAdmin (http://localhost:8080): "
	@curl -s -o /dev/null -w "%{http_code}" http://localhost:8080 && echo " $(GREEN)✓$(NC)" || echo " $(RED)✗$(NC)"
	@echo "$(YELLOW)Статус контейнеров:$(NC)"
	@docker compose ps --format "table {{.Name}}\t{{.Status}}\t{{.Ports}}"


clean: ## Удалить контейнеры и тома
	docker compose down -v
	@echo "$(RED)! Контейнеры и данные БД удалены$(NC)"

clean-all: ## Полная очистка (контейнеры, образы, тома)
	@echo "$(YELLOW)Полная очистка...$(NC)"
	docker compose down -v --rmi all
	@echo "$(GREEN)✓ Выполнена полная очистка$(NC)"

dev-reset: clean-all build up ## Сброс среды разработки
	@echo "$(GREEN)✓ Среда разработки сброшена и перезапущена!$(NC)"

# --- Команды Composer ---
composer-install: ## Установить зависимости через Composer
	docker compose exec $(PHP_CONTAINER) composer install

composer-update: ## Обновить зависимости через Composer
	docker compose exec $(PHP_CONTAINER) composer update

composer-require: ## Установить пакет через Composer (make composer-require PACKAGE=vendor/package)
	docker compose exec $(PHP_CONTAINER) composer require $(PACKAGE)

.DEFAULT_GOAL := help