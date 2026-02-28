@echo off
echo ========================================
echo تنظيف وإعادة بناء المشروع
echo ========================================

echo.
echo [1/5] تنظيف Flutter...
call flutter clean

echo.
echo [2/5] حذف ملفات البناء...
if exist build rmdir /s /q build
if exist android\.gradle rmdir /s /q android\.gradle
if exist android\app\build rmdir /s /q android\app\build

echo.
echo [3/5] الحصول على الحزم...
call flutter pub get

echo.
echo [4/5] إعادة بناء المشروع...
cd android
call gradlew clean
cd ..

echo.
echo [5/5] تشغيل التطبيق...
call flutter run

echo.
echo ========================================
echo تم الانتهاء!
echo ========================================
pause
