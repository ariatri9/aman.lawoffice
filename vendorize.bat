@echo off
setlocal enabledelayedexpansion
set APP_NAME=amanlaw_office
set DIST_DIR=%cd%\dist
set WORK_DIR=%cd%\.build_legalpro
set OVERLAY_DIR=%cd%

if exist "%WORK_DIR%" rmdir /s /q "%WORK_DIR%"
if exist "%DIST_DIR%" rmdir /s /q "%DIST_DIR%"
mkdir "%WORK_DIR%"
mkdir "%DIST_DIR%"

cd /d "%WORK_DIR%"
echo Creating fresh Laravel...
composer create-project laravel/laravel "%APP_NAME%" ^11.0 --no-interaction
cd /d "%APP_NAME%"

echo Installing packages...
composer require laravel/breeze spatie/laravel-permission:^6.0 barryvdh/laravel-dompdf:^2.0 --no-interaction
php artisan breeze:install blade

echo Copying overlay...
robocopy "%OVERLAY_DIR%\overlay" "." /E

echo Publishing Spatie Permission...
php artisan vendor:publish --provider="Spatie\Permission\PermissionServiceProvider"

copy .env .env.example.backup
powershell -Command "(Get-Content .env) -replace 'APP_NAME=Laravel','APP_NAME=LegalPro' | Set-Content .env"
powershell -Command "(Get-Content .env) -replace '^QUEUE_CONNECTION=.*','QUEUE_CONNECTION=database' | Set-Content .env"

php artisan key:generate
php artisan migrate --force
php artisan db:seed --class=DemoSeeder --force

cd ..
powershell -Command "Compress-Archive -Path '%APP_NAME%' -DestinationPath '..\dist\amanlaw_office_full_vendorized.zip'"
echo Done! dist\amanlaw_office_full_vendorized.zip
