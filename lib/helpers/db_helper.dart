import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  static Database? _database;

  factory DBHelper() => _instance;

  DBHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'toko_buku.db');
    return await openDatabase(
      path,
      version: 3, // Version dinaikkan ke 3 agar mendeteksi perubahan
      onCreate: (db, version) async {
        // 1. Buat Tabel Users
        await db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT NOT NULL,
            password TEXT NOT NULL
          )
        ''');

        // 2. Buat Tabel Barang
        await db.execute('''
          CREATE TABLE barang (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nama TEXT NOT NULL,
            harga INTEGER NOT NULL,
            stok INTEGER NOT NULL
          )
        ''');

        // 3. Buat Tabel Transaksi
        await db.execute('''
          CREATE TABLE transaksi (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nama_barang TEXT NOT NULL,
            jumlah INTEGER NOT NULL,
            total_harga INTEGER NOT NULL,
            uang_bayar INTEGER NOT NULL,
            kembalian INTEGER NOT NULL,
            tanggal TEXT NOT NULL
          )
        ''');

        // Insert Default User untuk Login
        await db.insert('users', {'username': 'mila123', 'password': '123'});

        // Insert Default Barang
        await db.insert('barang', {'nama': 'Buku Tulis Sidu 38L', 'harga': 4000, 'stok': 50});
        await db.insert('barang', {'nama': 'Novel / Komik', 'harga': 45000, 'stok': 20});
        await db.insert('barang', {'nama': 'Pulpen Pilot Black', 'harga': 3500, 'stok': 30});
        await db.insert('barang', {'nama': 'Pensil 2B Castell', 'harga': 2500, 'stok': 40});
        await db.insert('barang', {'nama': 'Penghapus Joyko', 'harga': 2000, 'stok': 25});
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS transaksi (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              nama_barang TEXT NOT NULL,
              jumlah INTEGER NOT NULL,
              total_harga INTEGER NOT NULL,
              uang_bayar INTEGER NOT NULL,
              kembalian INTEGER NOT NULL,
              tanggal TEXT NOT NULL
            )
          ''');
        }
        if (oldVersion < 3) {
          // Buat tabel users jika melakukan upgrade dari versi lama
          await db.execute('''
            CREATE TABLE IF NOT EXISTS users (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              username TEXT NOT NULL,
              password TEXT NOT NULL
            )
          ''');
          // Masukkan user default mila123 / 123
          await db.insert('users', {'username': 'mila123', 'password': '123'});
        }
      },
    );
  }

  // Tambahkan fungsi untuk Login
  Future<Map<String, dynamic>?> login(String username, String password) async {
    Database db = await database;
    List<Map<String, dynamic>> result = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );
    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> getBarang() async {
    Database db = await database;
    return await db.query('barang');
  }

  Future<int> updateStok(int id, int stokBaru) async {
    Database db = await database;
    return await db.update(
      'barang',
      {'stok': stokBaru},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Menambah transaksi baru ke database
  Future<int> insertTransaksi(Map<String, dynamic> data) async {
    Database db = await database;
    return await db.insert('transaksi', data);
  }

  // Mengambil seluruh data riwayat transaksi (diurutkan terbaru)
  Future<List<Map<String, dynamic>>> getTransaksi() async {
    Database db = await database;
    return await db.query('transaksi', orderBy: 'id DESC');
  }

  // Menghapus semua riwayat transaksi
  Future<int> clearTransaksi() async {
    Database db = await database;
    return await db.delete('transaksi');
  }
}