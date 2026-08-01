import 'package:sqflite/sqflite.dart';

class BookmarkRepo {
  final Database bibleDb;
  final Database userDb;

  BookmarkRepo({required this.bibleDb, required this.userDb});

  Future<void> setHighlight(int verseId, int? colorCode) async {
    final exists = await userDb.query(
      'bookmark',
      where: 'verse_id = ?',
      whereArgs: [verseId],
      limit: 1,
    );

    if (exists.isEmpty) {
      // row 자체가 없을 때만 insert
      await userDb.insert('bookmark', {
        'verse_id': verseId,
        'highlight': colorCode,
      });
    } else {
      // 있으면 update
      await userDb.update(
        'bookmark',
        {'highlight': colorCode},
        where: 'verse_id = ?',
        whereArgs: [verseId],
      );
    }
  }

  Future<int?> getHighlight(int v_id) async {
    final result = await userDb.query(
      'bookmark',
      where: 'verse_id = ?',
      whereArgs: [v_id],
    );

    if (result.isEmpty) return null;
    return result.first['highlight'] as int?;
  }

  Future<void> setBookmark(int verseId, bool isBookmarked) async {
    final exists = await userDb.query(
      'bookmark',
      where: 'verse_id = ?',
      whereArgs: [verseId],
      limit: 1,
    );

    if (exists.isEmpty) {
      await userDb.insert('bookmark', {
        'verse_id': verseId,
        'bookmark': isBookmarked ? 1 : null,
      });
    } else {
      await userDb.update(
        'bookmark',
        {'bookmark': isBookmarked ? 1 : null},
        where: 'verse_id = ?',
        whereArgs: [verseId],
      );
    }
  }

  Future<bool> isBookmarked(int verseId) async {
    final result = await userDb.query(
      'bookmark',
      columns: ['bookmark'],
      where: 'verse_id = ? AND bookmark = 1',
      whereArgs: [verseId],
      limit: 1,
    );

    return result.isNotEmpty;
  }

  Future<Map<String, List<Map<String, dynamic>>>> getGroupedBookmarks() async {
    final bookmarkRows = await userDb.query('bookmark', where: 'bookmark = 1');

    Map<String, List<Map<String, dynamic>>> grouped = {};

    for (final row in bookmarkRows) {
      final verseId = row['verse_id'];

      final verseRows = await bibleDb.rawQuery(
        '''
      SELECT
        k.book_id,
        bk.name AS book,
        k.chapter,
        k.verse,
        k.content AS text,
        k.v_id AS verse_id
      FROM t_bible k
      JOIN t_books bk ON bk.id = k.book_id
      WHERE k.v_id = ?
    ''',
        [verseId],
      );

      if (verseRows.isEmpty) continue;

      final verseInfo = verseRows.first;

      final book = verseInfo['book'] as String;

      grouped.putIfAbsent(book, () => []);

      grouped[book]!.add(verseInfo);
    }

    return grouped;
  }

  Future<Map<int, List<Map<String, dynamic>>>> getGroupedHighlights() async {
    final highlightRows = await userDb.query(
      'bookmark',
      where: 'highlight IS NOT NULL',
    );

    final Map<int, List<Map<String, dynamic>>> grouped = {};

    for (final row in highlightRows) {
      final verseId = row['verse_id'];
      final color = row['highlight'] as int;

      final verseRows = await bibleDb.rawQuery(
        '''
      SELECT
        k.book_id,
        bk.name AS book,
        k.chapter,
        k.verse,
        k.content AS text,
        k.v_id AS verse_id
      FROM t_bible k
      JOIN t_books bk ON bk.id = k.book_id
      WHERE k.v_id = ?
    ''',
        [verseId],
      );

      if (verseRows.isEmpty) continue;

      grouped.putIfAbsent(color, () => []);

      grouped[color]!.add({'highlight': color, ...verseRows.first});
    }

    return grouped;
  }

  Future<Map<int, int>> getAllHighlights() async {
    final result = await userDb.query(
      'bookmark', // 테이블 이름 맞춰줘!
      columns: ['verse_id', 'highlight'],
      where: 'highlight IS NOT NULL',
    );

    return {
      for (var row in result) row['verse_id'] as int: row['highlight'] as int,
    };
  }
}
