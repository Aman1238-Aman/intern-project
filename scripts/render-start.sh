#!/usr/bin/env bash
set -euo pipefail

mkdir -p storage/framework/{cache,sessions,views} storage/logs bootstrap/cache
chmod -R ug+rwx storage bootstrap/cache

# Keep link command safe if symlink already exists.
php artisan storage:link || true

exec php artisan serve --host=0.0.0.0 --port="${PORT:-10000}"
