import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(const WeightScaleApp());
}

class WeightScaleApp extends StatelessWidget {
  const WeightScaleApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'فاتورة الأوزان',
      locale: const Locale('ar', 'SA'),
      supportedLocales: const [
        Locale('ar', 'SA'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.cyan),
        scaffoldBackgroundColor: Colors.lightBlueAccent,
        useMaterial3: true,
      ),
      home: const WeightScalePage(),
    );
  }
}

class WeightScalePage extends StatefulWidget {
  const WeightScalePage({Key? key}) : super(key: key);

  @override
  State<WeightScalePage> createState() => _WeightScalePageState();
}

class _WeightScalePageState extends State<WeightScalePage> {
  final TextEditingController shipmentIdController = TextEditingController();
  final TextEditingController weight1Controller = TextEditingController();
  final TextEditingController weight2Controller = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController searchController = TextEditingController();

  double netWeight = 0;
  bool hasCalculated = false;
  String searchQuery = "";

  List<InvoiceModel> invoices = [];
  List<File> savedPDFFiles = [];

  @override
  void initState() {
    super.initState();
    _loadSavedPDFs();
  }

  @override
  void dispose() {
    shipmentIdController.dispose();
    weight1Controller.dispose();
    weight2Controller.dispose();
    descriptionController.dispose();
    searchController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedPDFs() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final pdfDir = Directory('${directory.path}/invoices');

      if (await pdfDir.exists()) {
        final files = pdfDir.listSync();
        setState(() {
          savedPDFFiles = files
              .where((file) => file.path.endsWith('.pdf'))
              .cast<File>()
              .toList();
        });
      } else {
        await pdfDir.create(recursive: true);
      }
    } catch (e) {
      _showError('خطأ في تحميل الملفات المحفوظة: $e');
    }
  }

  void calculateNetWeight() {
    final shipmentId = shipmentIdController.text.trim();
    final weight1 = double.tryParse(weight1Controller.text) ?? 0;
    final weight2 = double.tryParse(weight2Controller.text) ?? 0;
    final description = descriptionController.text.trim();

    if (shipmentId.isEmpty) {
      _showError('يرجى إدخال رقم الحمولة');
      return;
    }

    if (weight1 < 0 || weight2 < 0) {
      _showError('الأوزان يجب أن تكون موجبة');
      return;
    }

    setState(() {
      netWeight = (weight1 - weight2).abs();
      hasCalculated = true;
    });

    final invoice = InvoiceModel(
      shipmentId: shipmentId,
      weight1: weight1,
      weight2: weight2,
      netWeight: netWeight,
      description: description,
      date: DateTime.now(),
    );

    setState(() {
      invoices.insert(0, invoice);
    });

    _showSuccess('تم حساب صافي الوزن بنجاح');
  }

  void resetForm() {
    shipmentIdController.clear();
    weight1Controller.clear();
    weight2Controller.clear();
    descriptionController.clear();
    setState(() {
      hasCalculated = false;
      netWeight = 0;
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<File> _generatePDFFile(InvoiceModel invoice) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        textDirection: pw.TextDirection.rtl,
        build: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(40),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(
                  'فاتورة شحنة',
                  style: pw.TextStyle(
                    fontSize: 28,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Container(
                  padding: const pw.EdgeInsets.all(20),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      _buildInvoiceRow(
                        'رقم الحمولة',
                        invoice.shipmentId,
                      ),
                      pw.SizedBox(height: 15),
                      _buildInvoiceRow(
                        'التاريخ والوقت',
                        DateFormat('yyyy-MM-dd HH:mm', 'ar_SA')
                            .format(invoice.date),
                      ),
                      pw.SizedBox(height: 15),
                      _buildInvoiceRow(
                        'الوزن الأول (كجم)',
                        invoice.weight1.toStringAsFixed(2),
                      ),
                      pw.SizedBox(height: 15),
                      _buildInvoiceRow(
                        'الوزن الثاني (كجم)',
                        invoice.weight2.toStringAsFixed(2),
                      ),
                      if (invoice.description.isNotEmpty) ... [
                        pw.SizedBox(height: 15),
                        _buildInvoiceRow(
                          'الوصف',
                          invoice.description,
                        ),
                      ],
                    ],
                  ),
                ),
                pw.SizedBox(height: 30),
                pw.Container(
                  padding: const pw.EdgeInsets.all(30),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(width: 2),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Text(
                        'صافي الوزن',
                        style: const pw.TextStyle(fontSize: 16),
                      ),
                      pw.SizedBox(height: 10),
                      pw.Text(
                        '${invoice.netWeight.toStringAsFixed(2)} كجم',
                        style: pw.TextStyle(
                          fontSize: 40,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 40),
                pw.Divider(),
                pw.SizedBox(height: 10),
                pw.Text(
                  'تم إنشاء هذه الفاتورة بواسطة تطبيق فاتورة الأوزان',
                  style: const pw.TextStyle(fontSize: 10),
                ),
              ],
            ),
          );
        },
      ),
    );

    final directory = await getApplicationDocumentsDirectory();
    final invoiceDir = Directory('${directory.path}/invoices');
    if (!await invoiceDir.exists()) {
      await invoiceDir.create(recursive: true);
    }

    final fileName =
        'فاتورة_${invoice.shipmentId}_${DateFormat('yyyyMMdd_HHmmss').format(invoice.date)}.pdf';
    final file = File('${invoiceDir.path}/$fileName');
    await file.writeAsBytes(await pdf.save());

    return file;
  }

  Future<void> _savePDF(InvoiceModel invoice) async {
    try {
      _showSuccess('جاري حفظ الفاتورة...');

      final file = await _generatePDFFile(invoice);

      setState(() {
        savedPDFFiles.add(file);
      });

      _showSuccess('تم حفظ الفاتورة بنجاح!\nالمسار: ${file.path}');
    } catch (e) {
      _showError('خطأ في حفظ الفاتورة: $e');
    }
  }

  Future<void> _printInvoice(InvoiceModel invoice) async {
    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          textDirection: pw.TextDirection.rtl,
          build: (pw.Context context) {
            return pw.Container(
              padding: const pw.EdgeInsets.all(40),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(
                    'فاتورة شحنة',
                    style: pw.TextStyle(
                      fontSize: 28,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 20),
                  pw.Container(
                    padding: const pw.EdgeInsets.all(20),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        _buildInvoiceRow(
                          'رقم الحمولة',
                          invoice.shipmentId,
                        ),
                        pw.SizedBox(height: 15),
                        _buildInvoiceRow(
                          'التاريخ والوقت',
                          DateFormat('yyyy-MM-dd HH:mm', 'ar_SA')
                              .format(invoice.date),
                        ),
                        pw.SizedBox(height: 15),
                        _buildInvoiceRow(
                          'الوزن الأول (كجم)',
                          invoice.weight1.toStringAsFixed(2),
                        ),
                        pw.SizedBox(height: 15),
                        _buildInvoiceRow(
                          'الوزن الثاني (كجم)',
                          invoice.weight2.toStringAsFixed(2),
                        ),
                        if (invoice.description.isNotEmpty) ... [
                          pw.SizedBox(height: 15),
                          _buildInvoiceRow(
                            'الوصف',
                            invoice.description,
                          ),
                        ],
                      ],
                    ),
                  ),
                  pw.SizedBox(height: 30),
                  pw.Container(
                    padding: const pw.EdgeInsets.all(30),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(width: 2),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        pw.Text(
                          'صافي الوزن',
                          style: const pw.TextStyle(fontSize: 16),
                        ),
                        pw.SizedBox(height: 10),
                        pw.Text(
                          '${invoice.netWeight.toStringAsFixed(2)} كجم',
                          style: pw.TextStyle(
                            fontSize: 40,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name: 'فاتورة_${invoice.shipmentId}.pdf',
      );
    } catch (e) {
      _showError('خطأ في الطباعة: $e');
    }
  }

  Future<void> _shareInvoice(InvoiceModel invoice) async {
    try {
      final file = await _generatePDFFile(invoice);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'فاتورة الشحنة رقم: ${invoice.shipmentId}',
        subject: 'فاتورة_${invoice.shipmentId}',
      );
    } catch (e) {
      _showError('خطأ في المشاركة: $e');
    }
  }

  Future<void> _deletePDFFile(File file) async {
    try {
      if (await file.exists()) {
        await file.delete();
        setState(() {
          savedPDFFiles.remove(file);
        });
        _showSuccess('تم حذف الملف بنجاح');
      }
    } catch (e) {
      _showError('خطأ في حذف الملف: $e');
    }
  }

  pw.Widget _buildInvoiceRow(String label, String value) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          value,
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
        ),
        pw.Text(label),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('⚖️ فاتورة الأوزان'),
          elevation: 0,
          bottom: const TabBar(
            tabs: [
              Tab(
                icon: Icon(Icons.add_circle),
                text: 'فاتورة جديدة',
              ),
              Tab(
                icon: Icon(Icons.history),
                text: 'السجل',
              ),
              Tab(
                icon: Icon(Icons.file_download),
                text: 'الملفات المحفوظة',
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildNewInvoiceTab(),
            _buildHistoryTab(),
            _buildSavedFilesTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildNewInvoiceTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: shipmentIdController,
            decoration: InputDecoration(
              labelText: 'رقم الحمولة / الشحنة',
              hintText: 'مثال: SHP001',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.numbers),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: weight1Controller,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: 'الوزن الأول (كجم)',
                    hintText: '0.00',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.scale),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: weight2Controller,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: 'الوزن الثاني (كجم)',
                    hintText: '0.00',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.scale),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: descriptionController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'الوصف (اختياري)',
              hintText: 'مثال: حديد، اسمنت،... الخ',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.description),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: calculateNetWeight,
                  icon: const Icon(Icons.calculate),
                  label: const Text('حساب صافي الوزن'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: resetForm,
                  icon: const Icon(Icons.refresh),
                  label: const Text('إعادة تعيين'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
          if (hasCalculated) ... [
            const SizedBox(height: 32),
            Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [
                      Colors.blue.shade50,
                      Colors.blue.shade100,
                    ],
                  ),
                ),
                child: Column(
                  children: [
                    const Text(
                      'صافي الوزن',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${netWeight.toStringAsFixed(2)} كجم',
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              final invoice = InvoiceModel(
                                shipmentId: shipmentIdController.text,
                                weight1: double.parse(weight1Controller.text),
                                weight2: double.parse(weight2Controller.text),
                                netWeight: netWeight,
                                description: descriptionController.text,
                                date: DateTime.now(),
                              );
                              _savePDF(invoice);
                            },
                            icon: const Icon(Icons.save),
                            label: const Text('حفظ PDF'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              final invoice = InvoiceModel(
                                shipmentId: shipmentIdController.text,
                                weight1: double.parse(weight1Controller.text),
                                weight2: double.parse(weight2Controller.text),
                                netWeight: netWeight,
                                description: descriptionController.text,
                                date: DateTime.now(),
                              );
                              _printInvoice(invoice);
                            },
                            icon: const Icon(Icons.print),
                            label: const Text('طباعة'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          final invoice = InvoiceModel(
                            shipmentId: shipmentIdController.text,
                            weight1: double.parse(weight1Controller.text),
                            weight2: double.parse(weight2Controller.text),
                            netWeight: netWeight,
                            description: descriptionController.text,
                            date: DateTime.now(),
                          );
                          _shareInvoice(invoice);
                        },
                        icon: const Icon(Icons.share),
                        label: const Text('مشاركة الفاتورة'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    final filteredInvoices = invoices.where((invoice) {
      final truckMatch =
          invoice.shipmentId.toLowerCase().contains(searchQuery.toLowerCase());
      final dateMatch = DateFormat('yyyy-MM-dd', 'ar_SA')
          .format(invoice.date)
          .contains(searchQuery);
      return truckMatch || dateMatch;
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            controller: searchController,
            onChanged: (value) {
              setState(() {
                searchQuery = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'البحث برقم الحمولة أو التاريخ...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        searchController.clear();
                        setState(() {
                          searchQuery = "";
                        });
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.white70,
            ),
          ),
        ),
        Expanded(
          child: filteredInvoices.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        searchQuery.isEmpty ? Icons.history : Icons.search_off,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        searchQuery.isEmpty
                            ? 'لا توجد فواتير محفوظة'
                            : 'لم يتم العثور على نتائج لـ "$searchQuery"',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: filteredInvoices.length,
                  itemBuilder: (context, index) {
                    final invoice = filteredInvoices[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        title: Text(
                          invoice.shipmentId,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            Text(
                              'صافي: ${invoice.netWeight.toStringAsFixed(2)} كجم',
                              style: TextStyle(
                                color: Colors.blue.shade600,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat('yyyy-MM-dd HH:mm', 'ar_SA')
                                  .format(invoice.date),
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                        trailing: PopupMenuButton(
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              child: const Text('حفظ PDF'),
                              onTap: () => _savePDF(invoice),
                            ),
                            PopupMenuItem(
                              child: const Text('طباعة'),
                              onTap: () => _printInvoice(invoice),
                            ),
                            PopupMenuItem(
                              child: const Text('مشاركة'),
                              onTap: () => _shareInvoice(invoice),
                            ),
                            PopupMenuItem(
                              child: const Text('حذف'),
                              onTap: () {
                                setState(() {
                                  invoices.remove(invoice);
                                });
                                _showSuccess('تم حذف الفاتورة');
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildSavedFilesTab() {
    return savedPDFFiles.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.folder_open,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'لا توجد ملفات محفوظة',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'احفظ فاتورة من السجل أو أنشئ واحدة جديدة',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          )
        : RefreshIndicator(
            onRefresh: _loadSavedPDFs,
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: savedPDFFiles.length,
              itemBuilder: (context, index) {
                final file = savedPDFFiles[index];
                final fileName = file.path.split('/').last;
                final fileSize = file.lengthSync();
                final fileSizeString = _formatFileSize(fileSize);

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: const Icon(
                      Icons.picture_as_pdf,
                      color: Colors.red,
                      size: 40,
                    ),
                    title: Text(
                      fileName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Text(
                          'الحجم: $fileSizeString',
                          style: const TextStyle(fontSize: 12),
                        ),
                        Text(
                          'تم الإنشاء: ${DateFormat('yyyy-MM-dd HH:mm', 'ar_SA').format(file.statSync().modified)}',
                          style: const TextStyle(fontSize: 11),
                        ),
                      ],
                    ),
                    trailing: PopupMenuButton(
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          child: const Text('مشاركة'),
                          onTap: () {
                            Share.shareXFiles([XFile(file.path)]);
                          },
                        ),
                        PopupMenuItem(
                          child: const Text('حذف'),
                          onTap: () => _deletePDFFile(file),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(2)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
  }
}

class InvoiceModel {
  final String shipmentId;
  final double weight1;
  final double weight2;
  final double netWeight;
  final String description;
  final DateTime date;

  InvoiceModel({
    required this.shipmentId,
    required this.weight1,
    required this.weight2,
    required this.netWeight,
    required this.description,
    required this.date,
  });
}
