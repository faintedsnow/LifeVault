import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'schema.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() => _instance;

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'lifevault.db');

    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onConfigure: _onConfigure,
    );
  }

  /// Fresh install — create both tables at the current schema version.
  Future<void> _onCreate(Database db, int version) async {
    await db.execute(DatabaseSchema.createRecordsTable);
    await db.execute(DatabaseSchema.createDocumentVersionsTable);
    await db.execute(DatabaseSchema.createVersionRecordIndex);
  }

  /// Migrate from v1 → v2:
  /// 1. Create `document_versions` table
  /// 2. Copy expiry_at + notes from records into version rows
  /// 3. Rebuild records table without expiry_at / notes columns
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(DatabaseSchema.createDocumentVersionsTable);
      await db.execute(DatabaseSchema.createVersionRecordIndex);
      await db.execute(DatabaseSchema.migrateExpiryToVersions);
      await db.execute(DatabaseSchema.createRecordsTableTemp);
      await db.execute(DatabaseSchema.copyRecordsToNew);
      await db.execute(DatabaseSchema.dropOldRecordsTable);
      await db.execute(DatabaseSchema.renameNewRecordsTable);
    }
  }

  Future<void> _onConfigure(Database db) async {
    // Enable foreign keys
    await db.execute('PRAGMA foreign_keys = ON');
  }

  // Helper method to close the database (useful for disposal)
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
