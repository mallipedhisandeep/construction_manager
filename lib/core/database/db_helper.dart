import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  DBHelper._internal();
  static final DBHelper instance = DBHelper._internal();
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'construction_manager.db');

    return await openDatabase(
      path,
      version: 6, // 🔥 INCREMENT VERSION
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // ---------- WORKERS ----------
    await db.execute('''
    CREATE TABLE workers (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      phone TEXT NOT NULL,
      gender TEXT NOT NULL,
      state TEXT NOT NULL,
      role TEXT NOT NULL,
      work_type TEXT NOT NULL,
      rate_6_6 REAL NOT NULL,
      rate_10_6 REAL NOT NULL,
      rate_6_10 REAL NOT NULL,
      rate_6_2 REAL NOT NULL,
      rate_10_2 REAL NOT NULL,
      rate_2_6 REAL NOT NULL,
      notes TEXT
    )
    ''');

    // ---------- SITES ----------
    await db.execute('''
    CREATE TABLE sites (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      site_name TEXT NOT NULL,
      location TEXT,
      owner_name TEXT,
      owner_phone TEXT,
      start_date TEXT,
      budget REAL NOT NULL,
      floors_count INTEGER NOT NULL,
      status TEXT NOT NULL,
      notes TEXT
    )
    ''');

    // ---------- ATTENDANCE ----------
    await db.execute('''
    CREATE TABLE attendance (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      worker_id INTEGER NOT NULL,
      site_id INTEGER,
      date TEXT NOT NULL,
      attendance_type TEXT NOT NULL,
      wage REAL NOT NULL,
      advance REAL NOT NULL,
      payment_mode TEXT NOT NULL,
      payment_ref TEXT,
      balance_after REAL NOT NULL,
      UNIQUE(worker_id, date)
    )
    ''');

    // ---------- SITE AGREEMENTS ----------
    await db.execute('''
    CREATE TABLE site_agreements (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      site_id INTEGER NOT NULL,
      title TEXT NOT NULL,
      file_path TEXT NOT NULL,
      created_at TEXT NOT NULL
    )
    ''');

    //----------  SITE FLOORS  ----------
    await db.execute('''
    CREATE TABLE site_floor_files (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      site_id INTEGER NOT NULL,
      floor_no INTEGER NOT NULL,
      file_name TEXT NOT NULL,
      file_path TEXT NOT NULL,
      uploaded_at TEXT NOT NULL
    )
    ''');

    //----------- SITE ELEVATIONS -----------
    await db.execute('''
    CREATE TABLE site_elevations (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      site_id INTEGER NOT NULL,
      file_name TEXT NOT NULL,
      file_path TEXT NOT NULL,
      created_at TEXT NOT NULL
    )
    ''');


    // ================= PRIVATE WORKERS =================
    await db.execute('''
    CREATE TABLE private_workers (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT,
      work_type TEXT,
      phone TEXT,
      notes TEXT
    )
  ''');

    // ================= PRIVATE WORK =================
    await db.execute('''
    CREATE TABLE private_work (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      worker_id INTEGER,
      worker_name TEXT,
      work_type TEXT,
      site_name TEXT,
      work_date TEXT,
      price_charged REAL,
      amount_paid REAL,
      status TEXT,
      notes TEXT
    )
  ''');

    // ================= PRIVATE WORKER PAYMENTS =================
    await db.execute('''
    CREATE TABLE private_worker_payments (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      worker_id INTEGER,
      amount REAL,
      direction TEXT,
      mode TEXT,
      date TEXT,
      source TEXT,
      notes TEXT
    )
  ''');
  }
    
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 6) {

      await db.execute(
        "ALTER TABLE sites ADD COLUMN owner_phone TEXT",
      );

      await db.execute('''
      CREATE TABLE site_agreements (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        site_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        file_path TEXT NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (site_id) REFERENCES sites(id) ON DELETE CASCADE
      ) 
      ''');

      await db.execute('''
      CREATE TABLE site_floor_files (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        site_id INTEGER NOT NULL,
        floor_no INTEGER NOT NULL,
        file_name TEXT NOT NULL,
        file_path TEXT NOT NULL,
        uploaded_at TEXT NOT NULL
      )
      ''');

      await db.execute('''
      CREATE TABLE site_elevations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        site_id INTEGER NOT NULL,
        file_name TEXT NOT NULL,
        file_path TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
      ''');


    }
  }
}