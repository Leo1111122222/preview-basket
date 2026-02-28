@echo off
echo ========================================
echo تنظيف كامل وإعادة بناء التطبيق
echo ========================================
echo.

echo [1/5] تنظيف المشروع...
call flutter clean
echo.

echo [2/5] حذف ملفات Hive القديمة من الجهاز...
call flutter run --uninstall-only
echo.

echo [3/5] تحميل المكتبات...
call flutter pub get
echo.

echo [4/5] بناء التطبيق...
call flutter build apk --debug
echo.

echo [5/5] تثبيت التطبيق...
call flutter install
echo.

echo ========================================
echo تم بنجاح! التطبيق الآن بدون Hive
echo ========================================
pause
