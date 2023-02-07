FROM composer:2 as base-composer

FROM base-composer as vendor-build
WORKDIR /tmp
COPY composer.* ./

RUN composer install --ignore-platform-reqs --no-scripts --no-autoloader


FROM php:8.1-apache

RUN a2enmod rewrite \
    headers

RUN apt-get update && apt-get install -y --no-install-recommends \
    jq \
    unzip \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libonig-dev \
    libzip-dev \
    vim \
    # https://github.com/docker-library/php/issues/931
    && docker-php-ext-configure gd --with-jpeg=/usr/include/ --with-freetype=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd iconv mbstring mysqli opcache pdo pdo_mysql \
    && pecl install zip \
    && docker-php-ext-enable zip \
    && rm -rf /var/lib/apt/lists/*

RUN docker-php-ext-install gettext

WORKDIR /var/www/
COPY  --from=vendor-build /usr/bin/composer /usr/bin/composer

COPY . .
COPY --from=vendor-build /tmp/vendor/ ./vendor/
RUN composer dump-autoload

COPY ./etc /etc/
ENV APP_CACHE_DIR=/tmp/ses/cache
ENV APP_LOG_DIR=/tmp/ses/log

CMD ["apache2-foreground"]
