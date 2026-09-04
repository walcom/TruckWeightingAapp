/// أمثلة متقدمة لحفظ وتصدير وتشارك ملفات PDF
/// 
/// هذا الملف يحتوي على أمثلة إضافية وميزات متقدمة

// ==========================================
// 1. مثال: حفظ مع تشفير الملفات
// ==========================================

import 'package:encrypt/encrypt.dart' as encrypt;
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class SecurePDFManager {
  /// حفظ ملف PDF مشفّر
  static Future<void> savePDFEncrypted(File pdfFile) async {
    try {
      // إنشاء مفتاح التشفير
      final key = encrypt.Key.fromSecureRandom(32);
      final iv = encrypt.IV.fromSecureRandom(16);
      final encrypter = encrypt.Encrypter(encrypt.AES(key));

      // قراءة محتوى الملف
      final fileBytes = await pdfFile.readAsBytes();

      // تشفير المحتوى
      final encrypted = encrypter.encryptBytes(fileBytes, iv: iv);

      // حفظ الملف المشفّر
      final directory = await getApplicationDocumentsDirectory();
      final encryptedFile = File(
        '${directory.path}/invoices/encrypted_${pdfFile.path.split('/').last}',
      );
      await encryptedFile.writeAsBytes(encrypted.bytes);

      print('تم حفظ الملف المشفّر: ${encryptedFile.path}');
    } catch (e) {
      print('خطأ في التشفير: $e');
    }
  }
}

// ==========================================
// 2. مثال: إنشاء مجلد احتياطي للملفات
// ==========================================

class BackupManager {
  /// إنشاء نسخة احتياطية من الملفات
  static Future<void> createBackup() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final invoiceDir = Directory('${directory.path}/invoices');
      
      // إنشاء مجلد النسخة الاحتياطية
      final backupDir = Directory(
        '${directory.path}/invoices/backup_${DateTime.now().toIso8601String().replaceAll(':', '-')}',
      );
      await backupDir.create(recursive: true);

      // نسخ جميع الملفات
      final files = invoiceDir.listSync();
      for (var file in files) {
        if (file is File && file.path.endsWith('.pdf')) {
          final fileName = file.path.split('/').last;
          final newFile = File('${backupDir.path}/$fileName');
          await file.copy(newFile.path);
        }
      }

      print('تم إنشاء نسخة احتياطية: ${backupDir.path}');
    } catch (e) {
      print('خطأ في إنشاء النسخة الاحتياطية: $e');
    }
  }

  /// استعادة النسخة الاحتياطية
  static Future<void> restoreBackup(String backupPath) async {
    try {
      final backupDir = Directory(backupPath);
      final directory = await getApplicationDocumentsDirectory();
      final invoiceDir = Directory('${directory.path}/invoices');

      // نسخ الملفات من النسخة الاحتياطية
      final files = backupDir.listSync();
      for (var file in files) {
        if (file is File && file.path.endsWith('.pdf')) {
          final fileName = file.path.split('/').last;
          final newFile = File('${invoiceDir.path}/$fileName');
          await file.copy(newFile.path);
        }
      }

      print('تم استعادة النسخة الاحتياطية');
    } catch (e) {
      print('خطأ في استعادة النسخة الاحتياطية: $e');
    }
  }
}

// ==========================================
// 3. مثال: دمج عدة فواتير في ملف PDF واحد
// ==========================================

import 'package:pdf/widgets.dart' as pw;

class MultiInvoicePDF {
  /// دمج عدة فواتير
  static Future<void> mergeInvoices(List<InvoiceData> invoices) async {
    final pdf = pw.Document();

    for (var invoice in invoices) {
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          textDirection: pw.TextDirection.rtl,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text('فاتورة رقم: ${invoice.shipmentId}'),
                pw.SizedBox(height: 20),
                pw.Text('الوزن الصافي: ${invoice.netWeight} كجم'),
                pw.Divider(),
              ],
            );
          },
        ),
      );
    }

    // حفظ الملف المدمج
    final directory = await getApplicationDocumentsDirectory();
    final file = File(
      '${directory.path}/invoices/merged_invoices_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
    await file.writeAsBytes(await pdf.save());

    print('تم دمج الفواتير: ${file.path}');
  }
}

class InvoiceData {
  final String shipmentId;
  final double netWeight;
  final String description;

  InvoiceData({
    required this.shipmentId,
    required this.netWeight,
    required this.description,
  });
}

// ==========================================
// 4. مثال: تحميل الفواتير إلى السحابة (Firebase)
// ==========================================

import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_core/firebase_core.dart';

class CloudPDFManager {
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  /// تحميل الملف إلى Firebase Storage
  static Future<void> uploadToCloud(File pdfFile) async {
    try {
      final fileName = pdfFile.path.split('/').last;
      final ref = _storage.ref().child('invoices/$fileName');

      // تحميل الملف
      await ref.putFile(pdfFile);
      print('تم التحميل: invoices/$fileName');

      // الحصول على رابط التحميل
      final downloadUrl = await ref.getDownloadURL();
      print('رابط التحميل: $downloadUrl');
    } catch (e) {
      print('خطأ في التحميل: $e');
    }
  }

  /// تحميل جميع الملفات المحفوظة
  static Future<void> uploadAllInvoices() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final invoiceDir = Directory('${directory.path}/invoices');

      if (!await invoiceDir.exists()) return;

      final files = invoiceDir.listSync();
      for (var file in files) {
        if (file is File && file.path.endsWith('.pdf')) {
          await uploadToCloud(file);
        }
      }

      print('تم تحميل جميع الملفات');
    } catch (e) {
      print('خطأ في التحميل: $e');
    }
  }
}

// ==========================================
// 5. مثال: إدارة تخزين الملفات
// ==========================================

class StorageManager {
  /// حساب حجم مجلد الفواتير
  static Future<int> calculateFolderSize() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final invoiceDir = Directory('${directory.path}/invoices');

      if (!await invoiceDir.exists()) return 0;

      int totalSize = 0;
      final files = invoiceDir.listSync();
      for (var file in files) {
        if (file is File) {
          totalSize += await file.length();
        }
      }

      return totalSize;
    } catch (e) {
      print('خطأ في حساب الحجم: $e');
      return 0;
    }
  }

  /// تنسيق حجم الملف
  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(2)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
    }
  }

  /// حذف الملفات القديمة
  static Future<void> deleteOldFiles({required int daysOld}) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final invoiceDir = Directory('${directory.path}/invoices');

      if (!await invoiceDir.exists()) return;

      final cutoffDate = DateTime.now().subtract(Duration(days: daysOld));
      int deletedCount = 0;

      final files = invoiceDir.listSync();
      for (var file in files) {
        if (file is File) {
          final lastModified = await file.lastModified();
          if (lastModified.isBefore(cutoffDate)) {
            await file.delete();
            deletedCount++;
          }
        }
      }

      print('تم حذف $deletedCount ملف');
    } catch (e) {
      print('خطأ في حذف الملفات: $e');
    }
  }

  /// عرض إحصائيات الملفات
  static Future<Map<String, dynamic>> getStatistics() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final invoiceDir = Directory('${directory.path}/invoices');

      if (!await invoiceDir.exists()) {
        return {
          'totalFiles': 0,
          'totalSize': 0,
          'formattedSize': '0 B',
        };
      }

      int totalSize = 0;
      int fileCount = 0;
      DateTime? oldestDate;
      DateTime? newestDate;

      final files = invoiceDir.listSync();
      for (var file in files) {
        if (file is File && file.path.endsWith('.pdf')) {
          fileCount++;
          totalSize += await file.length();
          
          final lastModified = await file.lastModified();
          if (oldestDate == null || lastModified.isBefore(oldestDate)) {
            oldestDate = lastModified;
          }
          if (newestDate == null || lastModified.isAfter(newestDate)) {
            newestDate = lastModified;
          }
        }
      }

      return {
        'totalFiles': fileCount,
        'totalSize': totalSize,
        'formattedSize': formatFileSize(totalSize),
        'oldestFile': oldestDate?.toString() ?? 'N/A',
        'newestFile': newestDate?.toString() ?? 'N/A',
      };
    } catch (e) {
      print('خطأ في الحصول على الإحصائيات: $e');
      return {};
    }
  }
}

// ==========================================
// 6. مثال: البحث والتصفية المتقدم
// ==========================================

class FileSearchManager {
  /// البحث عن ملفات
  static Future<List<File>> searchFiles(String query) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final invoiceDir = Directory('${directory.path}/invoices');

      if (!await invoiceDir.exists()) return [];

      final List<File> results = [];
      final files = invoiceDir.listSync();

      for (var file in files) {
        if (file is File) {
          final fileName = file.path.toLowerCase();
          if (fileName.contains(query.toLowerCase())) {
            results.add(file);
          }
        }
      }

      return results;
    } catch (e) {
      print('خطأ في البحث: $e');
      return [];
    }
  }

  /// تصفية الملفات حسب التاريخ
  static Future<List<File>> filterByDate({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final invoiceDir = Directory('${directory.path}/invoices');

      if (!await invoiceDir.exists()) return [];

      final List<File> results = [];
      final files = invoiceDir.listSync();

      for (var file in files) {
        if (file is File) {
          final lastModified = await file.lastModified();
          if (lastModified.isAfter(startDate) && lastModified.isBefore(endDate)) {
            results.add(file);
          }
        }
      }

      return results;
    } catch (e) {
      print('خطأ في التصفية: $e');
      return [];
    }
  }

  /// تصفية الملفات حسب الحجم
  static Future<List<File>> filterBySize({
    required int minSize,
    required int maxSize,
  }) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final invoiceDir = Directory('${directory.path}/invoices');

      if (!await invoiceDir.exists()) return [];

      final List<File> results = [];
      final files = invoiceDir.listSync();

      for (var file in files) {
        if (file is File) {
          final size = await file.length();
          if (size >= minSize && size <= maxSize) {
            results.add(file);
          }
        }
      }

      return results;
    } catch (e) {
      print('خطأ في التصفية: $e');
      return [];
    }
  }
}

// ==========================================
// 7. مثال: تطبيق كامل للإدارة
// ==========================================

class InvoiceFileManager {
  /// حفظ الفاتورة مع جميع الميزات
  static Future<void> saveWithAllFeatures(
    File pdfFile, {
    bool backup = true,
    bool uploadToCloud = false,
  }) async {
    try {
      // 1. حفظ الملف الأساسي
      print('جاري حفظ الملف...');

      // 2. إنشاء نسخة احتياطية
      if (backup) {
        print('جاري إنشاء نسخة احتياطية...');
        await BackupManager.createBackup();
      }

      // 3. تحميل إلى السحابة
      if (uploadToCloud) {
        print('جاري التحميل إلى السحابة...');
        await CloudPDFManager.uploadToCloud(pdfFile);
      }

      // 4. عرض الإحصائيات
      final stats = await StorageManager.getStatistics();
      print('إجمالي الملفات: ${stats['totalFiles']}');
      print('حجم التخزين: ${stats['formattedSize']}');

      print('✓ تم حفظ الفاتورة بنجاح');
    } catch (e) {
      print('✗ خطأ في الحفظ: $e');
    }
  }

  /// عرض جميع معلومات الملفات
  static Future<void> showAllFileInfo() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final invoiceDir = Directory('${directory.path}/invoices');

      if (!await invoiceDir.exists()) {
        print('لا توجد ملفات');
        return;
      }

      print('\n╔═══════════════════════════════╗');
      print('║    معلومات ملفات الفواتير     ║');
      print('╚═══════════════════════════════╝\n');

      final files = invoiceDir.listSync();
      int index = 1;

      for (var file in files) {
        if (file is File && file.path.endsWith('.pdf')) {
          final fileName = file.path.split('/').last;
          final size = await file.length();
          final modified = await file.lastModified();

          print('$index. $fileName');
          print('   الحجم: ${StorageManager.formatFileSize(size)}');
          print('   التاريخ: $modified\n');

          index++;
        }
      }
    } catch (e) {
      print('خطأ: $e');
    }
  }
}

// ==========================================
// 8. مثال: الاستخدام
// ==========================================

/*
Future<void> main() async {
  // 1. حفظ مع نسخة احتياطية
  await InvoiceFileManager.saveWithAllFeatures(
    pdfFile,
    backup: true,
    uploadToCloud: false,
  );

  // 2. البحث عن ملف
  final searchResults = await FileSearchManager.searchFiles('SHP001');
  print('نتائج البحث: $searchResults');

  // 3. تصفية حسب التاريخ
  final recentFiles = await FileSearchManager.filterByDate(
    startDate: DateTime.now().subtract(Duration(days: 7)),
    endDate: DateTime.now(),
  );
  print('الملفات الحديثة: $recentFiles');

  // 4. عرض الإحصائيات
  final stats = await StorageManager.getStatistics();
  print('الإحصائيات: $stats');

  // 5. حذف الملفات القديمة
  await StorageManager.deleteOldFiles(daysOld: 90);

  // 6. عرض جميع الملفات
  await InvoiceFileManager.showAllFileInfo();
}
*/
