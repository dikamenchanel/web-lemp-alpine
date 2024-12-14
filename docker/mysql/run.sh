#!/bin/sh

# Создание директории для сокета
if [ ! -d /var/run/mysqld ]; then
    echo "[i] Создаём директорию для сокета..."
    mkdir -p /var/run/mysqld
    chown -R mysql:mysql /var/run/mysqld
fi

# Удаление старого сокета
if [ -e /var/run/mysqld/mysqld.sock ]; then
    echo "[i] Удаляем старый файл сокета..."
    rm -f /var/run/mysqld/mysqld.sock
fi

# Проверка переменных окружения
if [ -z "$MYSQL_ROOT_PASSWORD" ]; then
    echo "[!] Ошибка: MYSQL_ROOT_PASSWORD не задан!"
    exit 1
fi

# Инициализация базы данных
if [ ! -d /var/lib/mysql ]; then
    echo "[i] Инициализация MariaDB..."
    # mariadb-install-db --user=root --password="$MYSQL_ROOT_PASSWORD" --datadir=/var/lib/mysql > /dev/null

    echo "[i] Создаём начальную конфигурацию..."
    tfile=$(mktemp)
    cat << EOF > $tfile
USE mysql;
FLUSH PRIVILEGES;
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test_%';
FLUSH PRIVILEGES;
EOF



    mariadbd --user=root --bootstrap --password="$MYSQL_ROOT_PASSWORD" --verbose=0 < $tfile
    rm -f $tfile


    if [ -n "$MYSQL_DATABASE" ]; then
        echo "[i] Создаём базу данных ..."
        echo "CREATE DATABASE IF NOT EXISTS \`$MYSQL_DATABASE\` CHARACTER SET utf8 COLLATE utf8_general_ci;" | mariadb --user=root --password="$MYSQL_ROOT_PASSWORD"
    fi

    if [ -n "$MYSQL_USER" ] && [ -n "$MYSQL_PASSWORD" ]; then
        echo "[i] Создаём кастомного пользователя и наделяем его правами ..."
        echo "CREATE USER '$MYSQL_USER'@'$MYSQL_USER_HOST' IDENTIFIED BY '$MYSQL_PASSWORD';" | mariadb --user=root --password="$MYSQL_ROOT_PASSWORD"
        echo "GRANT ALL PRIVILEGES ON \`$MYSQL_DATABASE\`.* TO '$MYSQL_USER'@'$MYSQL_USER_HOST';" | mariadb --user=root --password="$MYSQL_ROOT_PASSWORD"
        echo "FLUSH PRIVILEGES;" | mariadb --user=root --password="$MYSQL_ROOT_PASSWORD"
    fi

fi

# Запуск MariaDB
echo "[i] Запуск MariaDB..."
exec mariadbd-safe --console --datadir=/var/lib/mysql --user=mysql "$@"

