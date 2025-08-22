Auth Patch for LegalPro
=======================

Files in auth_patch are meant to be merged into the Laravel project root.
Steps to apply:
1. Copy files under auth_patch/ into your project (merge paths).
2. Add the routes from routes/auth_snippet.php into routes/web.php (or include it).
3. Ensure User model exists and 'password' fillable; run composer require laravel/ui or breeze if you prefer full scaffolding.
4. php artisan migrate && php artisan db:seed (Demo users already included in amanlaw_demo.sql).

Demo credentials after import SQL:
- admin@amanlaw.test / password
- staff@amanlaw.test / password
# aman_lawoffice
