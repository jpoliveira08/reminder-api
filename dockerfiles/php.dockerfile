FROM php:8.4-fpm-alpine

ARG UID
ARG GID
ARG PROJECT_NAME

ENV UID=${UID}
ENV GID=${GID}
ENV PROJECT_NAME=${PROJECT_NAME}

RUN mkdir -p /var/www/html

WORKDIR /var/www/html

COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer

# MacOS staff group's
RUN delgroup dialout

RUN addgroup -g ${GID} --system ${PROJECT_NAME}
RUN adduser -G ${PROJECT_NAME} --system -D -s /bin/sh -u ${UID} ${PROJECT_NAME}

RUN sed -i "s/user = www-data/user = ${PROJECT_NAME}/g" /usr/local/etc/php-fpm.d/www.conf
RUN sed -i "s/group = www-data/group = ${PROJECT_NAME}/g" /usr/local/etc/php-fpm.d/www.conf
RUN echo "php_admin_flag[log_errors] = on" >> /usr/local/etc/php-fpm.d/www.conf


RUN apk add --no-cache \
    git \
    curl \
    libxml2-dev \
    php-soap \
    libzip-dev \
    unzip \
    zip \
    libpng \
    libpng-dev \
    jpeg-dev \
    oniguruma-dev \
    curl-dev \
    freetype-dev \
    libpq-dev

RUN docker-php-ext-install pgsql pdo pdo_mysql pdo_pgsql mbstring exif zip soap pcntl bcmath curl zip opcache

RUN docker-php-ext-configure gd --enable-gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd

RUN mkdir -p /usr/src/php/ext/redis \
    && curl -L https://github.com/phpredis/phpredis/archive/6.1.0.tar.gz | tar xvz -C /usr/src/php/ext/redis --strip 1 \
    && echo 'redis' >> /usr/src/php-available-exts \
    && docker-php-ext-install redis

# Uncomment to add xDebug
#RUN apk add --no-cache --virtual .build-deps $PHPIZE_DEPS
#RUN apk add --update linux-headers
#RUN pecl install xdebug-3.3.0
#RUN docker-php-ext-enable xdebug
#RUN apk del -f .build-deps

USER ${PROJECT_NAME}

CMD ["php-fpm", "-y", "/usr/local/etc/php-fpm.conf", "-R"]
