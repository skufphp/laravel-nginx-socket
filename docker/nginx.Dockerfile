# Базовый образ - официальный Nginx на Alpine Linux
FROM nginx:stable-alpine

# Добавляем пользователя nginx в группу www-data
# Это нужно для доступа к Unix-сокету, который создается PHP-FPM
RUN addgroup nginx www-data

EXPOSE 80