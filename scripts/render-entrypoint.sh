#!/usr/bin/env sh
set -e

mkdir -p storage/framework/cache storage/framework/sessions storage/framework/views storage/logs bootstrap/cache
chmod -R ug+rwx storage bootstrap/cache || true

if [ -z "${APP_KEY:-}" ]; then
  echo "APP_KEY is missing. Set APP_KEY in Render environment variables."
  exit 1
fi

php artisan config:clear
php artisan migrate --force
php artisan db:seed --class=QuizDemoSeeder --force || true
php artisan storage:link || true
php artisan config:cache
php artisan route:cache
php artisan view:cache

exec php artisan serve --host=0.0.0.0 --port="${PORT:-10000}"
