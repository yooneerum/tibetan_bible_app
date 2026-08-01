import 'package:sqflite/sqflite.dart';
import 'package:tibetan_bible_app/database_helper.dart';
import 'package:tibetan_bible_app/repositories/bible_repo.dart';
import 'package:tibetan_bible_app/tiles/history_item.dart';
import '../user_database_helper.dart';

class HistoryRepository {
  final DatabaseHelper db;
  final BibleRepository bibleRepo;
  final UserDatabaseHelper userDb;

  HistoryRepository({
    required this.db,
    required this.bibleRepo,
    required this.userDb,
  });

  Future<List<HistoryItem>> getAll() async {
    final database = await userDb.database;

    final rows = await database.query("history", orderBy: "timestamp DESC");

    List<HistoryItem> items = [];

    for (final m in rows) {
      // 기본 생성
      final item = HistoryItem.fromMap(m);

      // 여기서 bookName 채우기
      final bookName = await bibleRepo.getBookName(item.bookId);

      items.add(
        HistoryItem(
          id: item.id,
          bookId: item.bookId,
          chapter: item.chapter,
          verse: item.verse,
          bookName: bookName ?? "Unknown",
          content: item.content,
          timestamp: item.timestamp,
          action_type: item.action_type,
        ),
      );
    }

    return items;
  }

  Future<void> addHistory({
    required int bookId,
    required int chapter,
    required int verse,
    required String action,
  }) async {
    final database = await userDb.database;

    // 책 이름과 본문 가져오기
    final content = await bibleRepo.getVerseContent(bookId, chapter, verse);

    await database.insert('history', {
      "bookId": bookId,
      "chapter": chapter,
      "verse": verse,
      "content": content,
      "timestamp": DateTime.now().millisecondsSinceEpoch,
      "action_type": action,
    }, conflictAlgorithm: ConflictAlgorithm.replace);

    // ⭐ 30개 초과 시 오래된 기록 삭제
    await database.execute('''
    DELETE FROM history
    WHERE id NOT IN (
      SELECT id FROM history ORDER BY timestamp DESC LIMIT 30
    )
  ''');
  }

  Future<Map<String, int>?> getLastChapter() async {
    final database = await userDb.database;

    final result = await database.rawQuery('''
    SELECT bookId, chapter
    FROM history
    ORDER BY timestamp DESC
    LIMIT 1
  ''');

    if (result.isEmpty) return null;

    return {
      'book': result.first['bookId'] as int,
      'chapter': result.first['chapter'] as int,
    };
  }
}
