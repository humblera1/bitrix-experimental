
# Инструкция по созданию и публикации Docker-образа с ядром Битрикс

Данный гайд поможет вам собрать и опубликовать собственный базовый Docker-образ, который содержит ядро Битрикс и все необходимые системные и PHP-зависимости. Такой образ удобно использовать как базу для приложений.

---

## 1. Структура

```
bitrix-core-image/
├── Dockerfile
└── bitrix_core/     # Здесь архив с ядром Битрикс   
```

- В папке `bitrix_core` должно находиться ядро Битрикс нужной версии.

---

## 2. Dockerfile

```dockerfile
FROM php:8.4-apache

# Установка системных зависимостей
RUN apt-get update && apt-get install -y \
    libpng-dev libjpeg-dev libfreetype6-dev libzip-dev libbz2-dev \
    libxml2-dev libonig-dev libicu-dev libmemcached-dev libpspell-dev \
    libldap2-dev libgeoip-dev librrd-dev libssl-dev libcurl4-openssl-dev \
    libgettextpo-dev libsasl2-dev libc-client2007e-dev libkrb5-dev \
    unzip wget && rm -rf /var/lib/apt/lists/*

# Установка PHP-расширений
RUN docker-php-ext-install gd bz2 calendar curl exif fileinfo gettext iconv intl mbstring mysqli opcache pdo pdo_mysql soap sockets zip xml bcmath pcntl

# PECL расширения
RUN pecl channel-update pecl.php.net && \
    pecl install apcu rrd && \
    docker-php-ext-enable apcu rrd

# Включение mod_rewrite для Apache
RUN a2enmod rewrite

# Копируем Composer из официального образа
COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer

# Копируем ядро Bitrix в нужное место
COPY ./bitrix_core/bitrix /var/www/html/bitrix

# Меняем владельца и права на запись для ядра
RUN chown -R www-data:www-data /var/www/html/bitrix && chmod -R u+w /var/www/html/bitrix

WORKDIR /var/www/html

CMD ["apache2-foreground"]
```

---

## 3. Сборка образа

Выполните команду:

```sh
docker build -t <your-dockerhub-username>/bitrix-core:<bitrix-version> .
```

**Пример:**
```sh
docker build -t maximniistrom/bitrix:25.100.400 .
```

---

## 4. Аутентификация в DockerHub

Если вы ещё не залогинены в DockerHub, выполните:

```sh
docker login
```

---

## 5. Публикация (push) образа в DockerHub

```sh
docker push <your-dockerhub-username>/bitrix-core:<bitrix-version>
```

**Пример:**
```sh
docker push maximniistrom/bitrix:25.100.400
```

---

## 6. Использование образа в вашем приложении

В вашем проекте в Dockerfile укажите базовый образ:

```dockerfile
FROM mydockeruser/bitrix-core:25.100.400

# Далее копируйте только свой код, модули, настройки
COPY . /var/www/html
```

---

**Теперь вы можно быстро и удобно разворачивать проекты на Битрикс, используя собственный базовый Docker-образ!**
