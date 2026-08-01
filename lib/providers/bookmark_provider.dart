import 'package:flutter/material.dart';
import 'package:tibetan_bible_app/repositories/bookmark_repo.dart';

class BookmarksProvider extends ChangeNotifier {
  final BookmarkRepo repo;

  Map<String, List<Map<String, dynamic>>> bookmarksByBook = {};
  Map<int, List<Map<String, dynamic>>> highlightsByColor = {};

  BookmarksProvider(this.repo) {
    loadAll();
  }

  Future<void> loadAll() async {
    bookmarksByBook = await repo.getGroupedBookmarks();
    highlightsByColor = await repo.getGroupedHighlights();
    notifyListeners();
  }

  Future<void> setHighlight(int verseId, int? color) async {
    await repo.setHighlight(verseId, color);
    await loadAll(); // 🔥 이거 필수
  }

  int? getHighlightColor(int verseId) {
    for (final entry in highlightsByColor.entries) {
      if (entry.value.any((v) => v['verse_id'] == verseId)) {
        return entry.key;
      }
    }
    return null;
  }

  Future<void> addBookmark(int verseId) async {
    await repo.setBookmark(verseId, true);
    await loadAll();
  }

  Future<void> removeBookmark(int verseId) async {
    await repo.setBookmark(verseId, false);
    await loadAll();
  }

  Future<void> removeHighlight(int verseId) async {
    await repo.setHighlight(verseId, null); // 하이라이트 제거
    await loadAll();
  }
}
