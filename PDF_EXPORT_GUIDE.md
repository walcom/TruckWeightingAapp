# دليل حفظ وتصدير ملفات PDF 📄

## نظرة عامة ✨

التطبيق الآن يدعم **4 ميزات رئيسية** لإدارة الفواتير كملفات PDF:

| الميزة | الوصف |
|-------|--------|
| 💾 **حفظ PDF** | حفظ الفاتورة كملف PDF على جهاز الهاتف |
| 🖨️ **الطباعة** | طباعة الفاتورة مباشرة من الهاتف |
| 📤 **المشاركة** | مشاركة الفاتورة عبر البريد أو التطبيقات |
| 📁 **إدارة الملفات** | عرض وحذف الملفات المحفوظة |

---

## 1. حفظ الفاتورة كـ PDF 💾

### الميزات:
- ✅ حفظ تلقائي للملفات على الجهاز
- ✅ تنسيق اسم ملف احترافي: `فاتورة_SHP001_20240828_143022.pdf`
- ✅ دعم كامل للعربية
- ✅ تنسيق احترافي مع حدود وتفاصيل واضحة

### كيفية الاستخدام:

**من تبويب "فاتورة جديدة":**
```
1. أدخل رقم الحمولة
2. أدخل الوزن الأول والثاني
3. اضغط "حساب صافي الوزن"
4. اضغط الزر الأخضر "💾 حفظ PDF"
```

**من تبويب "السجل":**
```
1. اختر فاتورة من السجل
2. اضغط على الفاتورة
3. اختر "حفظ PDF" من القائمة
```

### الملفات المحفوظة:
- **المسار:** `/Documents/invoices/`
- **الصيغة:** PDF احترافي بصفحة A4
- **الاتجاه:** مدعوم كاملاً للعربية (RTL)

### الكود المسؤول:

```dart
Future<File> _generatePDFFile(InvoiceModel invoice) async {
  final pdf = pw.Document();
  
  // إضافة صفحة PDF بصيغة A4
  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      textDirection: pw.TextDirection.rtl,  // دعم العربية
      build: (pw.Context context) {
        // محتوى الفاتورة
        return pw.Column(...);
      },
    ),
  );
  
  // حفظ الملف
  final directory = await getApplicationDocumentsDirectory();
  final invoiceDir = Directory('${directory.path}/invoices');
  await invoiceDir.create(recursive: true);
  
  final fileName = 'فاتورة_${invoice.shipmentId}_${DateFormat('yyyyMMdd_HHmmss').format(invoice.date)}.pdf';
  final file = File('${invoiceDir.path}/$fileName');
  await file.writeAsBytes(await pdf.save());
  
  return file;
}
```

---

## 2. طباعة الفاتورة 🖨️

### الميزات:
- ✅ معاينة قبل الطباعة
- ✅ اختيار الطابعة
- ✅ تحديد حجم الورقة (A4, A5, إلخ)
- ✅ طباعة مباشرة من الهاتف

### كيفية الاستخدام:

**من النتيجة:**
```
1. بعد حساب صافي الوزن
2. اضغط الزر الأزرق "🖨️ طباعة"
3. ستفتح نافذة المعاينة
4. اختر الطابعة والإعدادات
5. اضغط طباعة
```

**من السجل:**
```
1. انقر على فاتورة في السجل
2. اختر "طباعة"
3. اختر الطابعة
4. أكمل الطباعة
```

### المتطلبات:
- طابعة متصلة بالشبكة نفسها
- أو: طابعة محلية متصلة بالجهاز

---

## 3. مشاركة الفاتورة 📤

### الميزات:
- ✅ مشاركة عبر البريد الإلكتروني
- ✅ مشاركة عبر الواتس آب
- ✅ مشاركة عبر تطبيقات المراسلة
- ✅ حفظ في السحابة (Google Drive, OneDrive)

### كيفية الاستخدام:

**من النتيجة:**
```
1. بعد حساب صافي الوزن
2. اضغط الزر البرتقالي "📤 مشاركة الفاتورة"
3. اختر التطبيق المطلوب
4. أضف رسالة إن أردت
5. أرسل
```

**من السجل:**
```
1. انقر على فاتورة في السجل
2. اختر "مشاركة"
3. اختر التطبيق
4. أرسل الملف
```

### التطبيقات المدعومة:
- 📧 Gmail و Outlook
- 💬 WhatsApp و Telegram
- ☁️ Google Drive و OneDrive
- 📱 وأي تطبيق آخر يدعم الملفات

---

## 4. إدارة الملفات المحفوظة 📁

### تبويب "الملفات المحفوظة":

هذا التبويب يعرض:
- ✅ جميع ملفات PDF المحفوظة
- ✅ حجم كل ملف
- ✅ تاريخ الإنشاء
- ✅ خيارات المشاركة والحذف

### الميزات:

**عرض التفاصيل:**
```
- اسم الملف
- الحجم (بالـ KB أو MB)
- التاريخ والوقت
- أيقونة PDF حمراء
```

**الإجراءات:**
```
1. مشاركة الملف
2. حذف الملف
3. تحديث القائمة (Swipe Down)
```

### مثال على الملفات:
```
📄 فاتورة_SHP001_20240828_143022.pdf
   الحجم: 45.32 KB
   تم الإنشاء: 2024-08-28 14:30

📄 فاتورة_SHP002_20240828_150515.pdf
   الحجم: 42.15 KB
   تم الإنشاء: 2024-08-28 15:05
```

### الكود:

```dart
Widget _buildSavedFilesTab() {
  return RefreshIndicator(
    onRefresh: _loadSavedPDFs,
    child: ListView.builder(
      itemCount: savedPDFFiles.length,
      itemBuilder: (context, index) {
        final file = savedPDFFiles[index];
        final fileName = file.path.split('/').last;
        final fileSize = file.lengthSync();
        
        return ListTile(
          leading: Icon(Icons.picture_as_pdf, color: Colors.red),
          title: Text(fileName),
          subtitle: Text('الحجم: ${_formatFileSize(fileSize)}'),
          trailing: PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                child: Text('مشاركة'),
                onTap: () => Share.shareXFiles([XFile(file.path)]),
              ),
              PopupMenuItem(
                child: Text('حذف'),
                onTap: () => _deletePDFFile(file),
              ),
            ],
          ),
        );
      },
    ),
  );
}
```

---

## محتوى الفاتورة PDF 📋

كل فاتورة PDF تحتوي على:

```
╔════════════════════════════════╗
║        فاتورة شحنة              ║
╚════════════════════════════════╝

┌────────────────────────────────┐
│ رقم الحمولة     SHP001         │
│ التاريخ والوقت   2024-08-28    │
│ الوزن الأول     500.00 كجم     │
│ الوزن الثاني     450.00 كجم     │
│ الوصف           خضروات طازة    │
└────────────────────────────────┘

╔════════════════════════════════╗
║  صافي الوزن: 50.00 كجم        ║
╚════════════════════════════════╝

تم إنشاء هذه الفاتورة بواسطة
تطبيق فاتورة الأوزان
```

---

## إعدادات الصلاحيات 🔐

### على نظام Android:

أضف إلى `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
```

### على نظام iOS:

أضف إلى `ios/Runner/Info.plist`:

```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>يريد التطبيق الوصول إلى مكتبة الصور لحفظ الفواتير</string>

<key>NSPhotoLibraryAddUsageDescription</key>
<string>يريد التطبيق حفظ الفواتير في الصور</string>

<key>NSLocalNetworkUsageDescription</key>
<string>يريد التطبيق البحث عن طابعات على الشبكة</string>

<key>NSBonjourServices</key>
<array>
    <string>_ipp._tcp</string>
</array>
```

---

## معالجة الأخطاء 🛡️

### أخطاء شائعة وحلولها:

**الخطأ:** "فشل حفظ الفاتورة"
```
السبب: عدم وجود صلاحيات الكتابة
الحل: تفعيل صلاحية الكتابة من إعدادات التطبيق
```

**الخطأ:** "لا توجد طابعة متاحة"
```
السبب: عدم وجود طابعة على الشبكة
الحل: تأكد من اتصال الطابعة بالشبكة نفسها
```

**الخطأ:** "فشل في المشاركة"
```
السبب: عدم تثبيت تطبيق المراسلة
الحل: ثبّت تطبيق البريد أو الواتس آب
```

### الكود المسؤول عن معالجة الأخطاء:

```dart
Future<void> _savePDF(InvoiceModel invoice) async {
  try {
    _showSuccess('جاري حفظ الفاتورة...');
    final file = await _generatePDFFile(invoice);
    
    setState(() {
      savedPDFFiles.add(file);
    });
    
    _showSuccess('تم حفظ الفاتورة بنجاح!');
  } catch (e) {
    _showError('خطأ في حفظ الفاتورة: $e');
  }
}
```

---

## نصائح الأداء ⚡

### لتحسين الأداء:

1. **حفظ الملفات القديمة:**
   ```dart
   // احذف الملفات الأقدم من 3 شهور
   if (fileModified.isBefore(DateTime.now().subtract(Duration(days: 90)))) {
     await file.delete();
   }
   ```

2. **ضغط ملفات PDF:**
   ```dart
   pdf.pageFormat = PdfPageFormat.a4;
   // الملفات الصغيرة تُحفظ بسرعة أكبر
   ```

3. **تحميل الملفات بكفاءة:**
   ```dart
   Future<void> _loadSavedPDFs() async {
     // تحميل متزامن للملفات
   }
   ```

---

## مثال عملي شامل 📚

### سيناريو: حفظ ومشاركة فاتورة

```dart
// 1. حساب صافي الوزن
void calculateNetWeight() {
  netWeight = 500 - 450;  // 50 كجم
  setState(() { hasCalculated = true; });
}

// 2. إنشاء نموذج الفاتورة
final invoice = InvoiceModel(
  shipmentId: 'SHP001',
  weight1: 500.0,
  weight2: 450.0,
  netWeight: 50.0,
  description: 'خضروات طازة',
  date: DateTime.now(),
);

// 3. حفظ الملف
final file = await _generatePDFFile(invoice);
// النتيجة: /Documents/invoices/فاتورة_SHP001_20240828_143022.pdf

// 4. مشاركة الملف
await Share.shareXFiles([XFile(file.path)]);

// 5. اختيار التطبيق
// المستخدم يختار Gmail أو WhatsApp

// 6. إرسال الملف
// يتم إرسال الملف مباشرة
```

---

## المميزات القادمة 🚀

- [ ] توقيع رقمي على الفواتير
- [ ] قالب فواتير قابل للتخصيص
- [ ] حفظ تلقائي في السحابة
- [ ] تشفير الملفات
- [ ] تحويل إلى صيغ أخرى (Word, Excel)
- [ ] إضافة شعار الشركة

---

## الدعم والمساعدة 📞

إذا واجهت مشكلة:

1. **تحقق من الصلاحيات** — تأكد من الأذونات
2. **فعّل المكتبات** — `flutter pub get`
3. **نظّف المشروع** — `flutter clean`
4. **أعد التشغيل** — `flutter run`

---

**آخر تحديث:** 2026
**الإصدار:** 2.0.0
**المكتبات المستخدمة:** pdf, printing, path_provider, share_plus
