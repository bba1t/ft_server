#!/bin/bash

# Определяю какой конфиг для nginx server использовать
# Поскольку я вставляю настройки в default, нет необходимости создавать для него симлинк, потому что он уже существует.
if [ "$AUTOINDEX" = "off" ]; then
    cp /tmp/nginx_auto_off.conf /etc/nginx/sites-available/default
else
    cp /tmp/nginx.conf /etc/nginx/sites-available/default
fi


echo "🚀 Starting MySQL..."
mysqld_safe --user=mysql &
sleep 10

echo "📝 Configuring MySQL..."
# Скрипт инициализации бд, -u root: подключение как root, < /tmp/init.sql: перенаправление содержимого в mysql
mysql -u root < /tmp/init.sql


# Запускаю в фоне
echo "🚀 Starting PHP-FPM..."
php-fpm7.3 --daemonize


# Запускаю nginx в FOREGROUND режиме, как главный процесс, чтобы контейнер не упал
echo "🚀 Starting Nginx..."
nginx -g 'daemon off;'