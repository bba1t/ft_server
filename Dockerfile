FROM debian:buster

# Переменная окружения для автоиндекса
ENV AUTOINDEX=on

# Заменяю sources.list на корректный для архивного репозитория
RUN echo "deb http://archive.debian.org/debian/ buster main" > /etc/apt/sources.list && \
    echo "deb http://archive.debian.org/debian-security buster/updates main" >> /etc/apt/sources.list

# Устанавливаю все необходимые пакеты
RUN apt-get update && apt-get install -y \
    nginx \
    php php-fpm php-mysql php-mbstring \
    mariadb-server mariadb-client \
    wget

# Удаляю стандартную папку для сайта
RUN rm -rf /var/www/html/


# NGINX
# nginx.conf - конфиг для nginx, конфига два разница только в автоиндексации
COPY src/nginx/nginx.conf /tmp/
COPY src/nginx/nginx_auto_off.conf /tmp/


# PHP
# /run/php и для сокета и пида
RUN mkdir -p /run/php


# MySQL
# /run/mysqld/ для сокета и пида
# my.cnf - главный конфиг для бд с базовыми настройками сервера: имя пользователя, путь к сокету, путь к lib путь к сокету, путь к lib
# init.sql - дает руту новый пароль и создает пользователя для вордпресса
RUN mkdir -p /run/mysqld && \
    chown -R mysql:mysql /var/run/mysqld
COPY src/mysql/my.cnf /etc/mysql/my.cnf
COPY src/mysql/init.sql /tmp/init.sql


# WORDPRESS 
# Скачиваю и распаковываю в /var/www/
# wp-config.php - конфиг для подключения wp к бд: имя бд, имя пользователя, пароль
RUN wget -O /tmp/wordpress.tar.gz https://wordpress.org/latest.tar.gz && \
    tar -xzf /tmp/wordpress.tar.gz -C /var/www/ && \
    rm /tmp/wordpress.tar.gz
COPY src/wordpress/wp-config.php /var/www/wordpress/wp-config.php


# PHPMYADMIN
# Скачиваю и распаковываю в /var/www/
# config.inc.php - главный конфигурационный файл phpmyadmin
RUN wget -O /tmp/phpmyadmin.tar.gz https://files.phpmyadmin.net/phpMyAdmin/5.0.4/phpMyAdmin-5.0.4-all-languages.tar.gz && \
    tar -xzf /tmp/phpmyadmin.tar.gz -C /var/www/ && \
    mv /var/www/phpMyAdmin-5.0.4-all-languages /var/www/phpmyadmin && \
    rm /tmp/phpmyadmin.tar.gz
COPY src/phpmyadmin/config.inc.php /var/www/phpmyadmin/config.inc.php


# Права для WORDPRESS и PHPMYADMIN
RUN chown -R www-data:www-data /var/www/* && \
    chmod -R 755 /var/www/*


# SSL - генерирую ключ
RUN mkdir ~/mkcert && cd ~/mkcert && \
	wget https://github.com/FiloSottile/mkcert/releases/download/v1.4.1/mkcert-v1.4.1-linux-amd64 && \
	mv mkcert-v1.4.1-linux-amd64 mkcert && chmod +x mkcert && \
	./mkcert -install && ./mkcert localhost


COPY /start.sh /start.sh
RUN chmod +x /start.sh
CMD ["./start.sh"]