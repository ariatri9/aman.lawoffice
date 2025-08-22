#!/usr/bin/env bash
set -e

APP_NAME="amanlaw_office"
DIST_DIR="./dist"
OVERLAY_DIR="$(pwd)"
WORK_DIR="$(pwd)/.build_legalpro"
LARAVEL_VERSION="^11.0" # set to ^12 when released; code is forward-compatible

echo "==> Preparing work dir..."
rm -rf "$WORK_DIR" "$DIST_DIR"
mkdir -p "$WORK_DIR" "$DIST_DIR"

cd "$WORK_DIR"
echo "==> Creating fresh Laravel..."
composer create-project laravel/laravel "$APP_NAME" "$LARAVEL_VERSION" --no-interaction
cd "$APP_NAME"

echo "==> Installing packages..."
composer require laravel/breeze spatie/laravel-permission:"^6.0" barryvdh/laravel-dompdf:"^2.0" --no-interaction
php artisan breeze:install blade

echo "==> NPM build (optional, will skip if npm not installed)"
if command -v npm >/dev/null 2>&1; then
  npm install
  npm run build || true
else
  echo "npm not found, skipping frontend build."
fi

echo "==> Copying overlay app files..."
rsync -a "$OVERLAY_DIR/overlay/" "./"

echo "==> Publishing Spatie Permission config & migrations"
php artisan vendor:publish --provider="Spatie\Permission\PermissionServiceProvider"

echo "==> Adjusting .env"
cp .env .env.example.backup
php -r "file_put_contents('.env', str_replace('APP_NAME=Laravel','APP_NAME=LegalPro', file_get_contents('.env')));"
php -r "file_put_contents('.env', preg_replace('/^QUEUE_CONNECTION=.*/m','QUEUE_CONNECTION=database', file_get_contents('.env')));"

echo "==> Generating app key"
php artisan key:generate

echo "==> Running migrations & seeders"
php artisan migrate --force
php artisan db:seed --class=DemoSeeder --force

echo "==> Packaging vendorized ZIP"
cd ..
zip -rq "../dist/amanlaw_office_full_vendorized.zip" "$APP_NAME"

echo "==> Done! Find your ZIP at: dist/amanlaw_office_full_vendorized.zip"
