import 'package:flutter/material.dart';
import 'package:tibetan_bible_app/database_helper.dart';
import 'package:tibetan_bible_app/repositories/bible_repo.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();
  final repo = BibleRepository(db: DatabaseHelper());

  List<Map<String, dynamic>> bookResults = [];
  Map<int, List<Map<String, dynamic>>> verseResults = {}; // bookId → verses
  Set<int> expandedBooks = {}; // 펼쳐진 책 목록

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> runSearch() async {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      setState(() {
        bookResults = [];
        verseResults = {};
        expandedBooks = {};
      });
      return;
    }

    final grouped = await repo.searchGroupedByBook(text);
    final books = await repo.getBooks();

    final merged = grouped.map((row) {
      final book = books.firstWhere((b) => b['id'] == row['book_id']);
      return {
        'book_id': row['book_id'],
        'name': book['name'],
        'count': row['count'],
      };
    }).toList();

    setState(() {
      bookResults = merged;
      verseResults = {};
      expandedBooks = {};
    });
  }

  Future<void> toggleBook(int bookId) async {
    if (expandedBooks.contains(bookId)) {
      setState(() {
        expandedBooks.remove(bookId);
      });
      return;
    }

    // 안 펼쳐져 있으면 절 목록 로드
    final verses = await repo.searchVerses(bookId, _controller.text);

    setState(() {
      verseResults[bookId] = verses;
      expandedBooks.add(bookId);
    });
  }

  // 검색어와 일치하는 구간만 하이라이트 스타일을 입힌 TextSpan 리스트 생성
  List<TextSpan> _highlightText(String text, String query) {
    if (query.isEmpty) {
      return [TextSpan(text: text)];
    }

    final List<TextSpan> spans = [];
    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();

    int start = 0;
    int index;

    while ((index = lowerText.indexOf(lowerQuery, start)) != -1) {
      if (index > start) {
        spans.add(TextSpan(text: text.substring(start, index)));
      }
      spans.add(
        TextSpan(
          text: text.substring(index, index + query.length),
          style: TextStyle(
            backgroundColor: Colors.yellow.withOpacity(0.3),
            fontWeight: FontWeight.bold,
          ),
        ),
      );
      start = index + query.length;
    }

    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start)));
    }

    return spans;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Search")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Enter the word...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onSubmitted: (_) => runSearch(),
            ),
          ),

          Expanded(
            child: ListView(
              children: bookResults.map((b) {
                final bookId = b['book_id'];
                final isOpen = expandedBooks.contains(bookId);
                final verses = verseResults[bookId] ?? [];

                return Column(
                  children: [
                    ListTile(
                      title: Text("${b['name']}"),
                      trailing: Text("${b['count']}"),
                      onTap: () => toggleBook(bookId),
                    ),
                    if (isOpen)
                      ...verses.map((v) {
                        return Padding(
                          padding: const EdgeInsets.only(left: 20),
                          child: ListTile(
                            title: Text("${v['chapter']} : ${v['verse']}"),
                            subtitle: Text.rich(
                              TextSpan(
                                children: _highlightText(
                                  v['content'],
                                  _controller.text,
                                ),
                              ),
                            ),
                            onTap: () {
                              Navigator.pop(context, {
                                "book": bookId,
                                "chapter": v['chapter'],
                                "verse": v['verse'],
                              });
                            },
                          ),
                        );
                      }),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
