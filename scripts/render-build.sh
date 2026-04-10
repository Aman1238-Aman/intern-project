#!/usr/bin/env bash
set -euo pipefail

echo "Installing PHP dependencies..."
composer install --no-interaction --no-dev --prefer-dist --optimize-autoloader

echo "Preparing Laravel runtime directories..."
mkdir -p bootstrap/cache storage/framework/{cache,sessions,views} storage/logs
chmod -R ug+rwx storage bootstrap/cache

echo "Running migrations..."
php artisan migrate --force

echo "Seeding demo data (safe if already present)..."
php artisan db:seed --class=QuizDemoSeeder --force

echo "Caching config/routes/views..."
php artisan config:cache
php artisan route:cache
php artisan view:cache
