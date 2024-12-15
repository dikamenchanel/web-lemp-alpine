#!/bin/sh

# Создание директории для сокета
if [ -d /var/run/mysqld ]; then
    echo "[i] gift right directory ..."
    chown -R mysql:mysql /var/run/mysqld
else
    echo "[i] mysqld not found, creating...."
    mkdir -p /run/mysqld
    chown -R mysql:mysql /run/mysqld
fi

# Удаление старого сокета
if [ -e /var/run/mysqld/mysqld.sock ]; then
    echo "[i] Удаляем старый файл сокета..."
    rm -f /var/run/mysqld/mysqld.sock
fi

# Проверка переменных окружения
if [ -z "$MYSQL_ROOT_PASSWORD" ]; then
    MYSQL_ROOT_PASSWORD=$(pwgen 16 1)
    echo "[i] MySQL root Password: $MYSQL_ROOT_PASSWORD"
fi

# Инициализация базы данных
if [ -d /var/lib/mysql ]; then
    echo "[i] MySQL directory already present, skipping creation"
    chown -R mysql:mysql /var/lib/mysql
else

    echo "[i] MySQL data directory not found, creating initial DBs"
    chown -R mysql:mysql /var/lib/mysql

    echo "[i] Инициализация MariaDB..."
    mariadb-install-db --user=mysql --datadir=/var/lib/mysql > /dev/null

    echo "[i] Создаём начальную конфигурацию..."

    tfile=$(mktemp)
    cat << EOF > $tfile
USE mysql;
FLUSH PRIVILEGES ;
GRANT ALL ON *.* TO 'root'@'%' identified by '$MYSQL_ROOT_PASSWORD' WITH GRANT OPTION ;
GRANT ALL ON *.* TO 'root'@'localhost' identified by '$MYSQL_ROOT_PASSWORD' WITH GRANT OPTION ;
SET PASSWORD FOR 'root'@'localhost'=PASSWORD('${MYSQL_ROOT_PASSWORD}') ;
DROP DATABASE IF EXISTS test ;
FLUSH PRIVILEGES
EOF

    if [ -n "$MYSQL_DATABASE" ]; then
        echo "[i] Создаём базу данных ..."
        echo "CREATE DATABASE IF NOT EXISTS \`$MYSQL_DATABASE\` CHARACTER SET utf8 COLLATE utf8_general_ci;" >> $tfile
    fi

    if [ -n "$MYSQL_USER" ] && [ -n "$MYSQL_PASSWORD" ]; then
        echo "[i] Создаём кастомного пользователя и наделяем его правами ..."
        echo "CREATE USER '$MYSQL_USER'@'$MYSQL_USER_HOST' IDENTIFIED BY '$MYSQL_PASSWORD';" >> $tfile
        echo "GRANT ALL PRIVILEGES ON \`$MYSQL_DATABASE\`.* TO '$MYSQL_USER'@'$MYSQL_USER_HOST';" >> $tfile
        echo "FLUSH PRIVILEGES;" >> $tfile
    fi
    
    mariadbd --user=mysql --bootstrap --verbose=0 --skip-name-resolve --skip-networking=0 < $tfile
    rm -f $tfile
fi

# Запуск MariaDB
echo "[i] Запуск MariaDB..."
exec mariadbd --user=mysql --console --skip-name-resolve --skip-networking=0 $@

