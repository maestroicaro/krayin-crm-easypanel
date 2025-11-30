# Stage 1: Composer Dependencies
FROM composer:2.7 AS composer

WORKDIR /app

COPY composer.json composer.lock ./
COPY packages ./packages

RUN composer install \
    --no-dev \
    --no-scripts \
    --no-autoloader \
    --prefer-dist \
    --ignore-platform-reqs

COPY . .

RUN composer dump-autoload --optimize --no-dev

# Stage 2: Node.js Assets
FROM node:20-alpine AS node

WORKDIR /app

COPY package.json ./
COPY vite.config.js ./

RUN npm install

COPY resources ./resources
COPY public ./public

RUN npm run build

# Stage 3: Production Image
FROM php:8.2-fpm-alpine

LABEL maintainer="Krayin CRM"
LABEL description="Krayin CRM - Open Source Laravel CRM optimized for EasyPanel"

# Install system dependencies
RUN apk add --no-cache \
    nginx \
    supervisor \
    mysql-client \
    freetype \
    libjpeg-turbo \
    libpng \
    libzip \
    icu \
    oniguruma \
    libxml2 \
    curl \
    bash \
    git

# Install PHP extensions build dependencies
RUN apk add --no-cache --virtual .build-deps \
    freetype-dev \
    libjpeg-turbo-dev \
    libpng-dev \
    libzip-dev \
    icu-dev \
    oniguruma-dev \
    libxml2-dev \
    curl-dev \
    $PHPIZE_DEPS

# Install PHP extensions
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
    pdo_mysql \
    mbstring \
    xml \
    curl \
    gd \
    zip \
    opcache \
    intl \
    bcmath \
    && pecl install redis \
    && docker-php-ext-enable redis

# Remove build dependencies
RUN apk del .build-deps

# Configure PHP for production
RUN { \
    echo 'opcache.enable=1'; \
    echo 'opcache.memory_consumption=256'; \
    echo 'opcache.interned_strings_buffer=16'; \
    echo 'opcache.max_accelerated_files=10000'; \
    echo 'opcache.revalidate_freq=2'; \
    echo 'opcache.fast_shutdown=1'; \
    echo 'opcache.validate_timestamps=0'; \
    } > /usr/local/etc/php/conf.d/opcache.ini

RUN { \
    echo 'memory_limit=512M'; \
    echo 'upload_max_filesize=100M'; \
    echo 'post_max_size=100M'; \
    echo 'max_execution_time=300'; \
    echo 'max_input_time=300'; \
    echo 'expose_php=Off'; \
    } > /usr/local/etc/php/conf.d/custom.ini

# Set working directory
WORKDIR /var/www/html

# Copy application files
COPY --chown=www-data:www-data . .
COPY --from=composer --chown=www-data:www-data /app/vendor ./vendor
COPY --from=node --chown=www-data:www-data /app/public/build ./public/build

# Create necessary directories and set permissions
RUN mkdir -p \
    storage/framework/cache/data \
    storage/framework/sessions \
    storage/framework/views \
    storage/logs \
    bootstrap/cache \
    && chown -R www-data:www-data storage bootstrap/cache \
    && chmod -R 775 storage bootstrap/cache

# Copy entrypoint script
COPY --chmod=755 entrypoint.sh /usr/local/bin/entrypoint.sh

# Configure Nginx
COPY easypanel/nginx.conf /etc/nginx/http.d/default.conf

# Create supervisor directories and configure
RUN mkdir -p /etc/supervisor/conf.d /var/log/supervisor

# Configure Supervisor
RUN { \
    echo '[supervisord]'; \
    echo 'nodaemon=true'; \
    echo 'user=root'; \
    echo 'logfile=/var/log/supervisor/supervisord.log'; \
    echo 'pidfile=/var/run/supervisord.pid'; \
    echo ''; \
    echo '[program:php-fpm]'; \
    echo 'command=php-fpm -F'; \
    echo 'autostart=true'; \
    echo 'autorestart=true'; \
    echo 'stdout_logfile=/dev/stdout'; \
    echo 'stdout_logfile_maxbytes=0'; \
    echo 'stderr_logfile=/dev/stderr'; \
    echo 'stderr_logfile_maxbytes=0'; \
    echo ''; \
    echo '[program:nginx]'; \
    echo 'command=nginx -g "daemon off;"'; \
    echo 'autostart=true'; \
    echo 'autorestart=true'; \
    echo 'stdout_logfile=/dev/stdout'; \
    echo 'stdout_logfile_maxbytes=0'; \
    echo 'stderr_logfile=/dev/stderr'; \
    echo 'stderr_logfile_maxbytes=0'; \
    } > /etc/supervisor/conf.d/supervisord.conf

# Healthcheck
HEALTHCHECK --interval=30s --timeout=3s --start-period=60s --retries=3 \
    CMD php artisan tinker --execute="echo 'OK';" || exit 1

# Expose port
EXPOSE 80

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

# Start supervisor
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
