# دليل إعداد الصلاحيات 🔐

## نظرة عامة

التطبيق يحتاج إلى صلاحيات معينة لـ:
- 💾 حفظ الملفات على الجهاز
- 📤 مشاركة الملفات
- 🖨️ الطباعة
- 📱 الوصول لتطبيقات أخرى

---

## Android Setup 🤖

### الخطوة 1️⃣: تحديث `AndroidManifest.xml`

**الملف:** `android/app/src/main/AndroidManifest.xml`

```xml
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.example.weight_scale_app">

    <!-- الصلاحيات المطلوبة -->
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" 
        android:maxSdkVersion="32" />
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />

    <!-- صلاحية الطباعة -->
    <uses-permission android:name="android.permission.LOCAL_ONLY_PRINTING" />

    <!-- صلاحية الشبكة المحلية للطابعات -->
    <uses-permission android:name="android.permission.INTERNET" />

    <application
        android:label="فاتورة الأوزان"
        android:icon="@mipmap/ic_launcher">

        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:theme="@style/LaunchTheme"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
            android:hardwareAccelerated="true"
            android:windowSoftInputMode="adjustResize">

            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>

        <activity
            android:name="android.app.PrintActivity"
            android:exported="true" />

    </application>
</manifest>
```

### الخطوة 2️⃣: تحديث `build.gradle`

**الملف:** `android/app/build.gradle`

```gradle
android {
    compileSdkVersion 34  // استخدم SDK 34 أو أحدث

    defaultConfig {
        applicationId "com.example.weight_scale_app"
        minSdkVersion 21      // الحد الأدنى
        targetSdkVersion 34   // الحد الأقصى الموصى به
        versionCode 1
        versionName "2.0.0"
    }

    buildFeatures {
        viewBinding false
    }
}

dependencies {
    // مكتبات إضافية إذا لزم الحال
}
```

### الخطوة 3️⃣: طلب الصلاحيات في وقت التشغيل

**على Android 6.0+ تحتاج لطلب الصلاحيات في وقت التشغيل:**

أضف إلى `pubspec.yaml`:

```yaml
dependencies:
  permission_handler: ^11.4.0
```

ثم في الكود:

```dart
import 'package:permission_handler/permission_handler.dart';

Future<void> requestStoragePermission() async {
  final status = await Permission.storage.request();
  
  if (status.isDenied) {
    print('تم رفض الصلاحية');
  } else if (status.isGranted) {
    print('تم منح الصلاحية');
  } else if (status.isDenied) {
    openAppSettings();
  }
}
```

### الخطوة 4️⃣: إعدادات إضافية

**ملف:** `android/app/src/main/AndroidManifest.xml`

إضافة قابلية البحث عن الطابعات:

```xml
<application>
    <!-- البحث عن الطابعات على الشبكة المحلية -->
    <service android:name="android.printservice.PrintService" />
    
    <!-- البحث عن الأجهزة -->
    <meta-data
        android:name="com.google.android.gms.version"
        android:value="@integer/google_play_services_version" />
</application>
```

---

## iOS Setup 🍎

### الخطوة 1️⃣: تحديث `Info.plist`

**الملف:** `ios/Runner/Info.plist`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <!-- الصلاحيات المطلوبة -->
    
    <!-- الوصول للصور -->
    <key>NSPhotoLibraryUsageDescription</key>
    <string>يريد التطبيق الوصول لحفظ الفواتير كصور</string>

    <key>NSPhotoLibraryAddUsageDescription</key>
    <string>يريد التطبيق إضافة الفواتير للصور</string>

    <!-- الوصول للملفات -->
    <key>NSDocumentsFolderUsageDescription</key>
    <string>يريد التطبيق الوصول لحفظ الملفات</string>

    <!-- الطباعة -->
    <key>NSLocalNetworkUsageDescription</key>
    <string>يريد التطبيق البحث عن طابعات على الشبكة المحلية</string>

    <key>NSBonjourServices</key>
    <array>
        <string>_ipp._tcp</string>
        <string>_ipps._tcp</string>
        <string>_printer._tcp</string>
    </array>

    <!-- مشاركة الملفات -->
    <key>NSShareSheetUsageDescription</key>
    <string>يريد التطبيق مشاركة الفواتير</string>

    <!-- الملفات المدعومة -->
    <key>CFBundleDocumentTypes</key>
    <array>
        <dict>
            <key>CFBundleTypeName</key>
            <string>PDF Document</string>
            <key>CFBundleTypeRole</key>
            <string>Viewer</string>
            <key>LSHandlerRank</key>
            <string>Alternate</string>
            <key>LSItemContentTypes</key>
            <array>
                <string>com.adobe.pdf</string>
            </array>
        </dict>
    </array>

    <!-- إعدادات التطبيق الأخرى -->
    <key>UIApplicationSceneManifest</key>
    <dict>
        <key>UIApplicationSupportsMultipleScenes</key>
        <false/>
        <key>UISceneConfigurations</key>
        <dict>
            <key>UIWindowSceneSessionRoleApplication</key>
            <array>
                <dict>
                    <key>UISceneConfigurationName</key>
                    <string>Default Configuration</string>
                    <key>UISceneDelegateClassName</key>
                    <string>$(PRODUCT_MODULE_NAME).SceneDelegate</string>
                </dict>
            </array>
        </dict>
    </dict>
</dict>
</plist>
```

### الخطوة 2️⃣: تحديث `Podfile`

**الملف:** `ios/Podfile`

```ruby
post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
    target.build_configurations.each do |config|
      config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= [
        '$(inherited)',
        'PERMISSION_PHOTOS=1',
        'PERMISSION_DOCUMENTS=1',
      ]
    end
  end
end
```

### الخطوة 3️⃣: تحديث `Capability`

**في Xcode:**

1. افتح `ios/Runner.xcworkspace`
2. اختر `Runner` من الـ Project Navigator
3. اختر `Signing & Capabilities`
4. أضف Capabilities:
   - `App Sandbox` (للوصول للملفات)
   - `Printing Support`

---

## Windows Setup 🪟

### الخطوة 1️⃣: تحديث `windows/runner/main.cpp`

لا تحتاج تعديلات خاصة، لكن تأكد من وجود:

```cpp
#include <windows.h>
#include <shellapi.h>
```

### الخطوة 2️⃣: إعدادات الطابعات

**Windows يدعم الطابعات محلياً بدون تكوين إضافي.**

---

## Linux Setup 🐧

### المكتبات المطلوبة:

```bash
# قد تحتاج لتثبيت:
sudo apt-get install libcups2-dev
sudo apt-get install libpulse-dev
```

---

## اختبار الصلاحيات ✅

### اختبار على Android:

```dart
void testAndroidPermissions() async {
  // التحقق من صلاحية الكتابة
  final status = await Permission.storage.request();
  
  if (status.isGranted) {
    print('✓ صلاحية الكتابة مفعلة');
  } else if (status.isDenied) {
    print('✗ صلاحية الكتابة مرفوضة');
  }
}
```

### اختبار على iOS:

```dart
void testIOSPermissions() async {
  // iOS يدير الصلاحيات تلقائياً
  print('✓ صلاحيات iOS معدة');
}
```

---

## حل المشاكل الشائعة 🛠️

### المشكلة 1: "لا يمكن حفظ الملفات"

**الحل:**
```bash
# 1. تحقق من الصلاحيات في AndroidManifest.xml
# 2. اطلب الصلاحية في وقت التشغيل
# 3. أعد تشغيل التطبيق
flutter run
```

### المشكلة 2: "لا يمكن العثور على طابعة"

**الحل:**
- تأكد من أن الطابعة على نفس الشبكة
- تأكد من تفعيل الشبكة المحلية في `Info.plist`
- أعد تشغيل الطابعة والهاتف

### المشكلة 3: "فشل المشاركة"

**الحل:**
```dart
// تأكد من وجود صلاحية المشاركة
final status = await Permission.storage.request();
if (status.isGranted) {
  await Share.shareXFiles([XFile(filePath)]);
}
```

### المشكلة 4: "الملفات لا تُحفظ بالمسار الصحيح"

**الحل:**
```dart
// استخدم getApplicationDocumentsDirectory
final directory = await getApplicationDocumentsDirectory();
print('المسار: ${directory.path}');

// تأكد من وجود المجلد
final invoiceDir = Directory('${directory.path}/invoices');
if (!await invoiceDir.exists()) {
  await invoiceDir.create(recursive: true);
}
```

---

## قائمة التحقق النهائية ✓

### Android:
- [ ] تحديث `AndroidManifest.xml` بالصلاحيات
- [ ] تحديث `build.gradle` بـ compileSdkVersion 34
- [ ] تثبيت `permission_handler`
- [ ] اختبار على جهاز حقيقي
- [ ] التحقق من صلاحيات التطبيق في الإعدادات

### iOS:
- [ ] تحديث `Info.plist` بالوصفات
- [ ] تحديث `Podfile`
- [ ] إضافة Capabilities في Xcode
- [ ] اختبار على جهاز حقيقي
- [ ] التحقق من الصلاحيات في إعدادات الخصوصية

### Windows/Linux:
- [ ] تثبيت المكتبات المطلوبة
- [ ] اختبار الطباعة
- [ ] اختبار حفظ الملفات

---

## أوامر مفيدة 🔧

```bash
# تنظيف التطبيق
flutter clean

# إعادة بناء المشروع
flutter pub get

# بناء على Android
flutter build apk --release

# بناء على iOS
flutter build ios --release

# تشغيل بنمط Debug مع Verbose
flutter run -v
```

---

## الموارد الإضافية 📚

- [توثيق Android Permissions](https://developer.android.com/training/permissions)
- [توثيق iOS Privacy](https://developer.apple.com/privacy/)
- [permission_handler Package](https://pub.dev/packages/permission_handler)
- [Flutter Path Provider](https://pub.dev/packages/path_provider)
- [Flutter Share Plus](https://pub.dev/packages/share_plus)

---

**آخر تحديث:** 2024
**تم الاختبار على:** Android 12+, iOS 14+
