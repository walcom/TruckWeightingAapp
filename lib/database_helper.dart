import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'main.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'invoices_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE invoices(id INTEGER PRIMARY KEY AUTOINCREMENT, shipmentId TEXT, weight1 REAL, weight2 REAL, netWeight REAL, description TEXT, date TEXT)',
        );
      },
    );
  }

  Future<void> insertInvoice(InvoiceModel invoice) async {
    final db = await database;
    await db.insert(
      'invoices',
      invoice.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<InvoiceModel>> getInvoices() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('invoices', orderBy: 'date DESC');

    return List.generate(maps.length, (i) {
      return InvoiceModel(
        shipmentId: maps[i]['shipmentId'],
        weight1: maps[i]['weight1'],
        weight2: maps[i]['weight2'],
        netWeight: maps[i]['netWeight'],
        description: maps[i]['description'],
        date: DateTime.parse(maps[i]['date']),
      );
    });
  }

  Future<void> deleteInvoice(String shipmentId, String date) async {
    final db = await database;
    await db.delete(
      'invoices',
      where: 'shipmentId = ? AND date = ?',
      whereArgs: [shipmentId, date],
    );
  }
}
