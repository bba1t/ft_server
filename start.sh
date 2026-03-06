#!/bin/bash

# Определяю какой конфиг для nginx server использовать.
# Поскольку я вставляю настройки в default, нет необходимости создавать для него симлинк, потому что он уже существует.
if [ "$AUTOINDEX" = "off" ]; then
    cp /tmp/nginx_auto_off.conf /etc/nginx/sites-available/default
    echo "Автоинтексация отключена"
else
    cp /tmp/nginx.conf /etc/nginx/sites-available/default
    echo "Автоинтексация включена"
fi


echo "Стартую Mysql"
service mysql start
sleep 30

echo "Инициализирую пользователей бд"
# Скрипт инициализации бд, -u root: подключение как root, < /tmp/init.sql: перенаправление содержимого в mysql
# Используем сокет для подключения
mysql -u root -S /var/run/mysqld/mysqld.sock < /tmp/init.sql
# mysql -u root < /tmp/init.sql


# Запускаю в фоне
echo "Запускаю PHP-FPM"
php-fpm7.3 --daemonize

# Запускаю nginx в FOREGROUND режиме, как главный процесс, чтобы контейнер не упал
echo "Запускаю Nginx"
nginx -g 'daemon off;'