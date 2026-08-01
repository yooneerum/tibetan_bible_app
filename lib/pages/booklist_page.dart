import 'package:flutter/material.dart';
import 'package:tibetan_bible_app/database_helper.dart';
import 'package:tibetan_bible_app/repositories/bible_repo.dart';

class BookListPage extends StatefulWidget {
  final int? initialBook;
  final int? initialChapter;

  const BookListPage({super.key, this.initialBook, this.initialChapter});

  @override
  State<BookListPage> createState() => _BookListPageState();
}

class _BookListPageState extends State<BookListPage> {
  final bibleRepo = BibleRepository(db: DatabaseHelper());

  List<Map<String, dynamic>> books = [];
  List<int> chapters = [];
  List<int> verses = [];

  int? selectedBook;
  int? selectedChapter;

  // 각 열의 ScrollController (현재 선택 항목으로 자동 스크롤)
  final _bookScrollController = ScrollController();
  final _chapterScrollController = ScrollController();
  final _verseScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadInitial();
  }

  @override
  void dispose() {
    _bookScrollController.dispose();
    _chapterScrollController.dispose();
    _verseScrollController.dispose();
    super.dispose();
  }

  Future<void> _loadInitial() async {
    await _loadBooks();

    if (widget.initialBook != null) {
      await _selectBook(widget.initialBook!, autoScroll: true);

      if (widget.initialChapter != null) {
        await _selectChapter(widget.initialChapter!, autoScroll: true);
      }
    }
  }

  Future<void> _loadBooks() async {
    final rows = await bibleRepo.getBooks();
    setState(() {
      books = rows;
    });
  }

  Future<void> _selectBook(int bookId, {bool autoScroll = false}) async {
    final chapterList = await bibleRepo.getChapters(bookId);
    setState(() {
      selectedBook = bookId;
      chapters = chapterList;
      selectedChapter = null;
      verses = [];
    });

    if (autoScroll) {
      _scrollToSelected(
        controller: _bookScrollController,
        index: books.indexWhere((b) => b['id'] == bookId),
      );
    }
  }

  Future<void> _selectChapter(int chapter, {bool autoScroll = false}) async {
    final verseList = await bibleRepo.getVerses(selectedBook!, chapter);
    setState(() {
      selectedChapter = chapter;
      verses = verseList;
    });

    if (autoScroll) {
      _scrollToSelected(
        controller: _chapterScrollController,
        index: chapters.indexOf(chapter),
      );
    }
  }

  void _scrollToSelected({
    required ScrollController controller,
    required int index,
  }) {
    if (index < 0) return;
    // ListTile 기본 높이 56 기준
    const itemHeight = 56.0;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!controller.hasClients) return;
      final offset = (index * itemHeight) - 100; // 살짝 위에서 보이도록
      controller.animateTo(
        offset.clamp(0.0, controller.position.maxScrollExtent),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("New Testament")),
      body: Row(
        children: [
          // ── 책 목록 ──
          Expanded(
            child: ListView.builder(
              controller: _bookScrollController,
              itemCount: books.length,
              itemBuilder: (context, i) {
                final book = books[i];
                final isSelected = book['id'] == selectedBook;
                return ListTile(
                  selected: isSelected,
                  selectedTileColor: Theme.of(
                    context,
                  ).colorScheme.primary.withOpacity(0.12),
                  title: Text(
                    book['name'],
                    style: TextStyle(
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  onTap: () => _selectBook(book['id']),
                );
              },
            ),
          ),

          // ── 장 목록 ──
          if (selectedBook != null) ...[
            const VerticalDivider(width: 1),
            Expanded(
              child: ListView.builder(
                controller: _chapterScrollController,
                itemCount: chapters.length,
                itemBuilder: (context, i) {
                  final c = chapters[i];
                  final isSelected = c == selectedChapter;
                  return ListTile(
                    selected: isSelected,
                    selectedTileColor: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.12),
                    title: Text(
                      "$c",
                      style: TextStyle(
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    onTap: () => _selectChapter(c),
                  );
                },
              ),
            ),
          ],

          // ── 절 목록 ──
          if (selectedChapter != null) ...[
            const VerticalDivider(width: 1),
            Expanded(
              child: ListView.builder(
                controller: _verseScrollController,
                itemCount: verses.length,
                itemBuilder: (context, i) {
                  final v = verses[i];
                  return ListTile(
                    title: Text("$v"),
                    onTap: () {
                      Navigator.pop(context, {
                        "book": selectedBook,
                        "chapter": selectedChapter,
                        "verse": v,
                      });
                    },
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}
