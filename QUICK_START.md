# 🚀 دليل البدء السريع

**By Laith Abo Assaf**

## المشكلة الحالية
```
Failed to load FirebaseOptions from resource
```

## ✅ الحل السريع

### الخطوة 1: تنظيف المشروع
```bash
flutter clean
```

### الخطوة 2: حذف ملفات البناء
```bash
# على Windows
rmdir /s /q build
rmdir /s /q android\.gradle
rmdir /s /q android\app\build
```

### الخطوة 3: الحصول على الحزم
```bash
flutter pub get
```

### الخطوة 4: تنظيف Gradle
```bash
cd android
gradlew clean
cd ..
```

### الخطوة 5: تشغيل التطبيق
```bash
flutter run
```

## 🎯 أو استخدم السكريبت الجاهز

### على Windows:
```bash
rebuild.bat
```

## 📋 التحقق من الإعداد

تأكد من:
- ✅ وجود `android/app/google-services.json`
- ✅ تحديث `android/build.gradle.kts`
- ✅ تحديث `android/app/build.gradle.kts`
- ✅ تفعيل Authentication في Firebase Console
- ✅ إنشاء Firestore Database
- ✅ نشر قواعد Firestore

## 🔍 إذا استمرت المشكلة

1. تأكد من أن Firebase Console يحتوي على:
   - ✅ مشروع باسم "preview-basket"
   - ✅ تطبيق Android بـ package name: `com.previewbasket.app`
   - ✅ Authentication مفعل (Email/Password)
   - ✅ Firestore Database مُنشأ

2. أعد تنزيل `google-services.json`:
   - اذهب إلى Firebase Console
   - Project Settings → Your apps
   - انقر على أيقونة Android
   - Download google-services.json
   - استبدل الملف في `android/app/`

3. تأكد من اتصال الإنترنت

## 📚 ملفات التوثيق

- `FIREBASE_SETUP.md` - دليل شامل لإعداد Firebase
- `FIREBASE_ANDROID_SETUP.md` - خطوات إعداد Android بالتفصيل
- `BLOC_FIXES.md` - إصلاحات البلوك
- `firestore.rules` - قواعد أمان Firestore

## 🎉 بعد الحل

جرب:
1. إنشاء حساب جديد
2. تسجيل الدخول
3. إنشاء مجموعة
4. إضافة روابط
5. المزامنة مع السحابة
6. تسجيل الخروج

---

**نصيحة:** احتفظ بنافذة Firebase Console مفتوحة لمراقبة:
- Authentication → Users (المستخدمين الجدد)
- Firestore Database → Data (البيانات المحفوظة)
