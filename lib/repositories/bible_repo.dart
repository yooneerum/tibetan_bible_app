import '../../database_helper.dart';

class BibleRepository {
  final DatabaseHelper db;
  BibleRepository({required this.db});

  Future<String?> getBookName(int bookId) async {
    final database = await db.database;
    final result = await database.query(
      't_books',
      where: 'id = ?',
      whereArgs: [bookId],
      limit: 1,
    );

    if (result.isNotEmpty) {
      return result.first['name'] as String;
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> getBooks() async {
    final database = await db.database;
    return await database.rawQuery('SELECT id, name FROM t_books ORDER BY id');
  }

  Future<List<int>> getChapters(int bookId) async {
    final database = await db.database;
    final rows = await database.rawQuery(
      'SELECT DISTINCT chapter FROM t_bible WHERE book_id = ? ORDER BY chapter',
      [bookId],
    );
    return rows.map((e) => e['chapter'] as int).toList();
  }

  Future<List<int>> getVerses(int bookId, int chapter) async {
    final database = await db.database;
    final rows = await database.rawQuery(
      'SELECT v_id, verse FROM t_bible WHERE book_id = ? AND chapter = ? ORDER BY verse',
      [bookId, chapter],
    );
    return rows.map((e) => e['verse'] as int).toList();
  }

  Future<List<Map<String, dynamic>>> getChapter(int bookId, int chapter) {
    return db.getChapter(bookId: bookId, chapter: chapter);
  }

  Future<List<Map<String, dynamic>>> searchGroupedByBook(String query) async {
    final dbConn = await db.database;

    final words = query.trim().split(RegExp(r'\s+'));

    final likeConditions = words
        .map((w) => "content LIKE '%$w%'")
        .join(' AND ');

    final sql =
        '''
    SELECT book_id, COUNT(*) AS count
    FROM t_bible
    WHERE $likeConditions
    GROUP BY book_id
    ORDER BY book_id
  ''';

    return await dbConn.rawQuery(sql);
  }

  Future<List<Map<String, dynamic>>> searchVerses(
    int bookId,
    String query,
  ) async {
    final dbConn = await db.database;

    final words = query.trim().split(RegExp(r'\s+'));
    final likeConditions = words
        .map((w) => "content LIKE '%$w%'")
        .join(' AND ');

    final sql =
        '''
    SELECT book_id, chapter, verse, content
    FROM t_bible
    WHERE book_id = ?
      AND $likeConditions
    ORDER BY chapter, verse
  ''';

    return await dbConn.rawQuery(sql, [bookId]);
  }

  Future<String?> getVerseContent(int bookId, int chapter, int verse) async {
    final database = await db.database;
    final result = await database.query(
      't_bible',
      where: 'book_id = ? AND chapter = ? AND verse = ?',
      whereArgs: [bookId, chapter, verse],
      limit: 1,
    );

    if (result.isNotEmpty) {
      return result.first['content'] as String;
    }
    return null;
  }
}
