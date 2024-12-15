# web-lemp-alpine
Автоматизированное развертывание LEMP-стека (Nginx, MariaDB и REDIS, PHP) с использованием Docker на базе образа Alpine Linux.

# Проект Docker для PHP 8.3, Nginx, MariaDB и Redis

## Описание
Данный репозиторий предоставляет окружение для разработки на основе Docker, включающее четыре контейнера:
- **PHP 8.3**: для выполнения PHP-приложений.
- **Nginx**: веб-сервер для обслуживания приложений.
- **MariaDB 11.4**: реляционная база данных.
- **Redis**: система кэширования и брокер сообщений.

Каждый контейнер имеет собственную директорию с файлами конфигурации, которые можно настроить под свои нужды.

---

## Структура проекта

```
/
|-- docker/
|   |-- php/
|   |   |-- Dockerfile-php
|   |   |-- www.conf
|   |-- nginx/
|   |   |-- conf.d/
|   |   |   |-- default.conf
|   |   |-- nginx.conf
|   |   |-- Dockerfile-nginx
|   |-- mariadb/
|   |   |-- my.cnf
|   |   |-- run.sh
|   |   |-- Dockerfile-mysql
|-- docker-compose.yml
|-- .env
```

### Файлы и директории:
1. **`docker/php/`**: содержит настройки для контейнера с PHP 8.3:
   - `Dockerfile-php`: описание сборки контейнера PHP.
   - `www.conf`: конфигурационный файл PHP-FPM.

2. **`docker/nginx/`**: включает настройки для контейнера Nginx:
   - `nginx.conf`: конфигурационный файл веб-сервера Nginx.
   - `Dockerfile-nginx`: описание сборки контейнера Nginx.
   - `conf.d`: Директория для хостов Nginx.
   - `conf.d/default`: Файл настройки для хоста по умолчанию.
   
3. **`docker/mysql/`**: предоставляет настройки для базы данных MariaDB:
   - `my.cnf`: конфигурационный файл MariaDB.
   - `Dockerfile-mysql`: описание сборки контейнера MariaDB.

5. **`docker-compose.yml`**: главный файл для запуска и управления всеми контейнерами.
   
6. **`.env`**: главный файл для для переменных окружения.

---

## Использование

### Предварительные требования
Убедитесь, что у вас установлены следующие инструменты:
- [Docker](https://www.docker.com/)
- [Docker Compose](https://docs.docker.com/compose/)


### Установка Docker и Docker Compose

1. Установите Docker:
   - Для Linux (Ubuntu/Debian):
     ```bash
     sudo apt update
     sudo apt install docker.io
     sudo systemctl start docker
     sudo systemctl enable docker
     ```
   - Для других ОС следуйте [официальной инструкции](https://docs.docker.com/get-docker/).

2. Установите Docker Compose:
   ```bash
   sudo curl -L "https://github.com/docker/compose/releases/download/$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep -Po '"tag_name": "\K[^"]*')/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
   sudo chmod +x /usr/local/bin/docker-compose
   ```

3. Проверьте корректность установки:
   ```bash
   docker --version
   docker-compose --version
   ```


### Запуск проекта
1. Клонируйте репозиторий:
   ```bash
   git clone https://github.com/dikamenchanel/web-lemp-alpine.git
   ```
   ИЛИ

   ```bash
   git clone git@github.com:dikamenchanel/web-lemp-alpine.git
   ```

   ```bash
   cd web-lemp-alpine
   ```

2. Запустите контейнеры:
   ```bash
   docker-compose up -d
   ```

3. Откройте браузер и перейдите по адресу [http://localhost:8787](http://localhost:8787).

### Настройка конфигураций
Вы можете изменить настройки для каждого контейнера в соответствующих конфигурационных файлах. После внесения изменений необходимо перезапустить контейнеры:
```bash
docker-compose down && docker-compose up -d
```

---

## Полезные команды

- **Остановка контейнеров:**
  ```bash
  docker-compose down
  ```

- **Перезапуск контейнеров:**
  ```bash
  docker-compose restart
  ```

- **Просмотр логов:**
  ```bash
  docker-compose logs -f
  ```

---

## Лицензия
Этот проект распространяется под лицензией MIT. Подробнее см. файл `LICENSE`.


