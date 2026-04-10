#!/usr/bin/env sh
set -e

mkdir -p storage/framework/cache storage/framework/sessions storage/framework/views storage/logs bootstrap/cache
chmod -R ug+rwx storage bootstrap/cache || true

if [ -z "${APP_KEY:-}" ]; then
  echo "APP_KEY is missing. Generating a runtime key..."
  export APP_KEY="$(php artisan key:generate --show --no-interaction)"
fi

php artisan config:clear

attempt=1
max_attempts=20
until php artisan migrate --force; do
  if [ "$attempt" -ge "$max_attempts" ]; then
    echo "Migration failed after ${max_attempts} attempts."
    exit 1
  fi
  echo "Migration attempt ${attempt} failed. Retrying in 3 seconds..."
  attempt=$((attempt + 1))
  sleep 3
done

php artisan db:seed --class=QuizDemoSeeder --force || true
php artisan storage:link || true
php artisan config:cache
php artisan view:cache

exec php artisan serve --host=0.0.0.0 --port="${PORT:-10000}"
