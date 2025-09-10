# Stage 1: Распаковка ядра Bitrix
FROM alpine:3.18 AS bitrix-core-unpack

WORKDIR /bitrix-core

COPY ./bitrix-core/*.tar.gz /bitrix-core/bitrix-core.tar.gz
RUN tar -xzvf bitrix-core.tar.gz && rm bitrix-core.tar.gz

# Stage 2: Финальный образ с PHP 7.4 и Apache
FROM php:7.4-apache

# Установка зависимостей, расширений PHP, PECL, настройка Apache, установка прав и очистка кэша в одном RUN
RUN apt-get update && apt-get install -y \
    libpng-dev libjpeg-dev libfreetype6-dev libzip-dev libbz2-dev libxml2-dev \
    libonig-dev libicu-dev libmemcached-dev libpspell-dev libldap2-dev \
    libgeoip-dev librrd-dev libssl-dev libcurl4-openssl-dev libgettextpo-dev \
    libsasl2-dev libc-client2007e-dev libkrb5-dev unzip wget nginx cron supervisor nano \
    poppler-utils catdoc libreoffice\
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-configure imap --with-kerberos --with-imap-ssl \
    && docker-php-ext-install gd bz2 calendar curl exif fileinfo gettext iconv intl mbstring mysqli opcache pdo pdo_mysql soap sockets zip xml bcmath pcntl imap \
    && pecl channel-update pecl.php.net \
    && pecl install apcu rrd \
    && docker-php-ext-enable apcu rrd \
    && a2enmod rewrite \
    && rm -rf /var/lib/apt/lists/*

# Пользователь и группа всех каталогов в ВМ - bitrix с UID/GID 600
RUN groupadd -g 600 bitrix && useradd -u 600 -g bitrix -m bitrix

# Копируем все необходимые файлы одним COPY
COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer
COPY --from=bitrix-core-unpack /bitrix-core /var/www/html/bitrix

COPY ./docker/php/bitrix.ini /usr/local/etc/php/conf.d/bitrix.ini
COPY ./docker/cron/bitrix-crontab /etc/cron.d/bitrix-crontab
COPY ./docker/supervisor/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Копируем entrypoint.sh для запуска nginx через supervisor
COPY ./docker/nginx/nginx-entrypoint.sh /usr/local/bin/nginx-entrypoint.sh

# Выставляем права на Bitrix и crontab одним RUN
RUN chown bitrix:bitrix /var/www/html/bitrix && chmod u+w /var/www/html/bitrix \
    && chmod 0644 /etc/cron.d/bitrix-crontab \
    && chmod +x /usr/local/bin/nginx-entrypoint.sh

WORKDIR /var/www/html