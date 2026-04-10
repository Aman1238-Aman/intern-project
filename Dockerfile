FROM composer:2 AS vendor
WORKDIR /app
COPY composer.json composer.lock ./
RUN composer install --no-dev --no-interaction --prefer-dist --optimize-autoloader --no-scripts

FROM php:8.2-cli

# ✅ FIXED dependencies (IMPORTANT)
RUN apt-get update && apt-get install -y --no-install-recommends \
    git unzip libpq-dev libzip-dev libicu-dev libonig-dev pkg-config \
    && docker-php-ext-install pdo pdo_pgsql mbstring zip intl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /var/www/html

COPY . .
COPY --from=vendor /app/vendor ./vendor

# ✅ Storage + cache permissions
RUN mkdir -p storage/framework/{cache,sessions,views} storage/logs bootstrap/cache \
    && chmod -R 775 storage bootstrap/cache

# ✅ SQLite create (VERY IMPORTANT)
RUN touch storage/database.sqlite

# ✅ Laravel cache clear
RUN php artisan config:clear && php artisan cache:clear

EXPOSE 10000

# ✅ FINAL START COMMAND
CMD php artisan serve --host=0.0.0.0 --port=10000
