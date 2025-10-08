-- 🗃️ НАСТРОЙКА БАЗ ДАННЫХ И ПОЛЬЗОВАТЕЛЕЙ

-- Меняем пароль пользователя root на 'rootpassword'
ALTER USER 'root'@'localhost' IDENTIFIED BY 'rootpassword';


-- Удаляем всех пользователей с пустым именем
DELETE FROM mysql.user WHERE User='';


-- Удаляем стандартную тестовую базу, которая может быть уязвима
-- Удаляем привилегии для тестовой базы
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';


-- Создаем базу данных с именем 'wordpress', если она еще не существует
-- CHARACTER SET utf8mb4 поддерживает все символы (включая эмодзи)
-- COLLATE utf8mb4_unicode_ci обеспечивает правильную сортировку
CREATE DATABASE IF NOT EXISTS wordpress 
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;


-- Создаем пользователя 'wpuser' для подключения с localhost
-- Создаем того же пользователя для подключения с 127.0.0.1
-- Некоторые приложения используют IP вместо localhost
CREATE USER IF NOT EXISTS 'wpuser'@'localhost' IDENTIFIED BY 'wppassword';
CREATE USER IF NOT EXISTS 'wpuser'@'127.0.0.1' IDENTIFIED BY 'wppassword';


-- Даем пользователю wpuser ВСЕ привилегии на базу wordpress
-- @'localhost' - только для подключений с локальной машины
-- @'127.0.0.1' - только для подключений через IP localhost
GRANT ALL PRIVILEGES ON wordpress.* TO 'wpuser'@'localhost';
GRANT ALL PRIVILEGES ON wordpress.* TO 'wpuser'@'127.0.0.1';


-- Создаем отдельную базу для phpMyAdmin (опционально)
CREATE DATABASE IF NOT EXISTS phpmyadmin 
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;


-- Применяем все изменения прав пользователей
-- Без этой команды изменения не вступят в силу!
FLUSH PRIVILEGES;