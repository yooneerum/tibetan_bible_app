import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class UserDatabaseHelper {
  static final UserDatabaseHelper instance = UserDatabaseHelper._internal();

  static Database? _db;

  UserDatabaseHelper._internal();

  factory UserDatabaseHelper() => instance;

  Future<Database> get database async {
    if (_db != null) return _db!;

    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'user.db');

    return openDatabase(
      path,
      // DB 스키마 버전. 테이블/컬럼 구조를 변경하면 version을 올리고
      // onUpgrade에서 마이그레이션을 수행한다. (예: version 1 → 2, memo 컬럼 추가)
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
        CREATE TABLE bookmark (
          verse_id INTEGER PRIMARY KEY,
          bookmark INTEGER,
          highlight INTEGER
        )
        ''');

        await db.execute('''
        CREATE TABLE history (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          bookId INTEGER NOT NULL,
          chapter INTEGER NOT NULL,
          verse INTEGER NOT NULL,
          content TEXT NOT NULL,
          timestamp INTEGER NOT NULL,
          action_type TEXT NOT NULL
        )
        ''');
      },
    );
  }
}
