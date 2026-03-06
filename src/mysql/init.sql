-- НАСТРОЙКА БАЗ ДАННЫХ И ПОЛЬЗОВАТЕЛЕЙ

-- Меняю пароль root на 'rootpassword'
ALTER USER 'root'@'localhost' IDENTIFIED BY 'rootpassword';

-- Удаляю всех пользователей с пустым именем
DELETE FROM mysql.user WHERE User='';

-- Удаляю стандартную тестовую базу и ее привилегии
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';


-- Создаю базу данных WordPress
CREATE DATABASE IF NOT EXISTS wordpress 
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;

-- Создаю пользователя для WordPress, который может подключаться с localhost и по ip
-- Некоторые приложения используют IP вместо localhost
CREATE USER IF NOT EXISTS 'wpuser'@'localhost' IDENTIFIED BY 'wppassword';
CREATE USER IF NOT EXISTS 'wpuser'@'127.0.0.1' IDENTIFIED BY 'wppassword';

-- Даю пользователю wpuser ВСЕ привилегии на базу wordpress
GRANT ALL PRIVILEGES ON wordpress.* TO 'wpuser'@'localhost';
GRANT ALL PRIVILEGES ON wordpress.* TO 'wpuser'@'127.0.0.1';

-- Создаю базу для phpMyAdmin
CREATE DATABASE IF NOT EXISTS phpmyadmin 
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;


-- Создаю пользователя для МОНИТРОРИНГА с любого хоста и даю минимальные необходимые права для сбора метрик
CREATE USER IF NOT EXISTS 'exporter'@'%' IDENTIFIED BY 'exportpassword';
GRANT PROCESS, REPLICATION CLIENT, SELECT ON *.* TO 'exporter'@'%';

-- Применение всех изменений
FLUSH PRIVILEGES;