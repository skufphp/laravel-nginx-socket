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

help: ## Показать справку
	@echo "$(YELLOW)Laravel Docker Boilerplate (Unix Socket)$(NC)"
	@echo "======================================"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "$(GREEN)%-20s$(NC) %s\n", $$1, $$2}'

up: ## Запустить контейнеры
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

logs: ## Показать логи
	docker compose logs -f

status: ## Статус контейнеров
	docker compose ps

shell-php: ## Войти в контейнер PHP
	docker compose exec $(PHP_CONTAINER) sh

# --- Laravel команды ---

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

test: ## Запустить тесты
	docker compose exec $(PHP_CONTAINER) php artisan test

permissions: ## Исправить права доступа для Laravel (storage/cache)
	@echo "$(YELLOW)Исправление прав доступа...$(NC)"
	docker compose exec $(PHP_CONTAINER) sh -c "chown -R www-data:www-data storage bootstrap/cache && chmod -R ug+rwX storage bootstrap/cache"
	@echo "$(GREEN)✓ Права доступа исправлены$(NC)"

clean: ## Удалить контейнеры и тома
	docker compose down -v
	@echo "$(RED)! Контейнеры и данные БД удалены$(NC)"

.DEFAULT_GOAL := help