import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _db;

  //본문 수정 시 bible.db 업데이트_user.db는 업데이트 되지 않음
  static const int bibleDbVersion = 12;

  DatabaseHelper._internal();

  factory DatabaseHelper() => instance;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final prefs = await SharedPreferences.getInstance();

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'bible.db');

    final savedVersion = prefs.getInt('bible_db_version') ?? 0;

    if (savedVersion < bibleDbVersion) {
      await deleteDatabase(path);

      await _copyDatabase(path);

      await prefs.setInt('bible_db_version', bibleDbVersion);
    }

    return await openDatabase(path);
  }

  Future<void> _copyDatabase(String path) async {
    ByteData data = await rootBundle.load('assets/bible.db');
    List<int> bytes = data.buffer.asUint8List(
      data.offsetInBytes,
      data.lengthInBytes,
    );

    await File(path).writeAsBytes(bytes, flush: true);
  }

  Future<List<Map<String, dynamic>>> getChapter({
    required int bookId,
    required int chapter,
  }) async {
    final db = await database;

    return await db.rawQuery(
      '''
    SELECT
      v_id,
      book_id,
      chapter,
      verse,
      content
    FROM t_bible
    WHERE book_id = ?
      AND chapter = ?
    ORDER BY verse
    ''',
      [bookId, chapter],
    );
  }
}
