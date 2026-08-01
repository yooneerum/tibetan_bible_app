import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tibetan_bible_app/bottomsheets/setting_bottom.dart';
import 'package:tibetan_bible_app/database_helper.dart';
import 'package:tibetan_bible_app/pages/booklist_page.dart';
import 'package:tibetan_bible_app/providers/bookmark_provider.dart';
import 'package:tibetan_bible_app/repositories/bible_repo.dart';
import 'package:tibetan_bible_app/repositories/history_repo.dart';
import 'package:tibetan_bible_app/themes/app_font.dart';
import 'package:tibetan_bible_app/tiles/verse_tile.dart';
import '../controllers/scroll_controller.dart';
import '../user_database_helper.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    required void Function(AppSettings newSettings) onSettingsChanged,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

AppSettings settings = AppSettings.instance;

class _HomePageState extends State<HomePage> {
  final bibleRepo = BibleRepository(db: DatabaseHelper());
  final scrollController = HomeScrollController();
  final _listController = ScrollController();

  final Map<String, double> _verseHeights = {};

  final historyRepo = HistoryRepository(
    db: DatabaseHelper(),
    bibleRepo: BibleRepository(db: DatabaseHelper()),
    userDb: UserDatabaseHelper(),
  );

  BookmarksProvider get bookmarkProvider => context.watch<BookmarksProvider>();

  // 👉 현재 선택된 책/장 저장하는 state 변수!
  int _currentBook = 1;
  int _currentChapter = 1;
  String _currentBookName = "";

  int? _highlightedVerseIndex;

  void onSettingsChanged(AppSettings newSettings) {
    setState(() {
      settings = newSettings;
    });
  }

  void _scrollToVerse(int verse) {
    final index = verse - 1;
    final book = _currentBook;
    final chapter = _currentChapter;

    setState(() {
      _highlightedVerseIndex = index;
    });

    _waitAndScroll(book, chapter, index, 0);

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _highlightedVerseIndex = null);
    });
  }

  void _waitAndScroll(int book, int chapter, int index, int attempt) {
    if (!mounted || attempt >= 40) return;

    final measuredUpToIndex = List.generate(
      index + 1,
      (i) => i,
    ).every((i) => _verseHeights.containsKey("$book-$chapter-$i"));

    if (!measuredUpToIndex) {
      // 처음 한 번만: 대략적인 위치로 jumpTo해서 해당 절이 빌드되게 유도

      Future.delayed(const Duration(milliseconds: 50), () {
        _waitAndScroll(book, chapter, index, attempt + 1);
      });
      return;
    }

    // 측정 완료 → 정확한 위치로 이동
    double offset = 0;
    for (int i = 0; i < index; i++) {
      offset += _verseHeights["$book-$chapter-$i"]!;
    }
    final tileHeight = _verseHeights["$book-$chapter-$index"]!;
    final screenHeight = MediaQuery.of(context).size.height;
    final targetOffset = offset - (screenHeight / 2) + (tileHeight / 2);

    print("✅ 스크롤: index=$index, offset=$targetOffset");

    _listController.animateTo(
      targetOffset.clamp(0.0, _listController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
    );
  }

  void _onSettingsChanged() {
    if (_highlightedVerseIndex == null) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final index = _highlightedVerseIndex!;
    });
  }

  List<Map<String, dynamic>> verses = [];

  Future<void> _loadChapter({required int book, required int chapter}) async {
    final data = await bibleRepo.getChapter(book, chapter);
    final name = await bibleRepo.getBookName(book);

    // 👇 장 바뀔 때 맨 위로 리셋
    if (_listController.hasClients) {
      _listController.jumpTo(0);
    }

    setState(() {
      verses = data;
      _currentBook = book;
      _currentChapter = chapter;
      _currentBookName = name ?? "$book";
    });
  }

  Future<void> _goToPreviousChapter() async {
    // 현재 책의 chapter 목록
    final chapters = await bibleRepo.getChapters(_currentBook);

    if (_currentChapter > chapters.first) {
      // 같은 책에서 이전 장
      await _loadChapter(book: _currentBook, chapter: _currentChapter - 1);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToVerse(1);
      });
      await historyRepo.addHistory(
        bookId: _currentBook,
        chapter: _currentChapter,
        verse: 1,
        action: "chapter_move",
      );
      return;
    }

    // 여기 도달 → 현재 1장이었음 → 이전 책으로 이동
    final prevBook = _currentBook == 1 ? 27 : _currentBook - 1;
    final prevBookChapters = await bibleRepo.getChapters(prevBook);

    await _loadChapter(book: prevBook, chapter: prevBookChapters.last);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToVerse(1);
    });
    await historyRepo.addHistory(
      bookId: prevBook,
      chapter: prevBookChapters.last,
      verse: 1,
      action: "chapter_move",
    );
  }

  Future<void> _goToNextChapter() async {
    final chapters = await bibleRepo.getChapters(_currentBook);

    if (_currentChapter < chapters.last) {
      // 같은 책에서 다음 장
      await _loadChapter(book: _currentBook, chapter: _currentChapter + 1);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToVerse(1);
      });
      await historyRepo.addHistory(
        bookId: _currentBook,
        chapter: _currentChapter,
        verse: 1,
        action: "chapter_move",
      );
      return;
    }

    // 마지막 장이었다 → 다음 책의 1장
    final nextBook = _currentBook == 27 ? 1 : _currentBook + 1;
    await _loadChapter(book: nextBook, chapter: 1);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToVerse(1);
    });
    await historyRepo.addHistory(
      bookId: nextBook,
      chapter: 1,
      verse: 1,
      action: "chapter_move",
    );
  }

  int bottomIndex = 0;

  Future<void> _onBottomTap(int index) async {
    setState(() => bottomIndex = index);

    switch (index) {
      case 0:
        // 북마크 동작: 예시 - 화면 이동
        final result = await Navigator.pushNamed(context, '/bookmark');
        if (result != null && mounted) {
          final map = result as Map<String, dynamic>;
          final book = map['book'];
          final chapter = map['chapter'];
          final verse = map['verse'];

          await _loadChapter(book: book, chapter: chapter);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollToVerse(verse);
          });

          await historyRepo.addHistory(
            bookId: book,
            chapter: chapter,
            verse: verse,
            action: "bookmark",
          );
        }
        break;
      case 1:
        final result = await Navigator.pushNamed(context, '/history');

        if (result != null && mounted) {
          final map = result as Map<String, dynamic>;
          final book = map['book'];
          final chapter = map['chapter'];
          final verse = map['verse'];

          await _loadChapter(book: book, chapter: chapter);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollToVerse(verse);
          });

          await historyRepo.addHistory(
            bookId: book,
            chapter: chapter,
            verse: verse,
            action: "history",
          );
        }
        break;
      case 2:
        final result = await Navigator.pushNamed(context, '/search');

        if (result != null && mounted) {
          final map = result as Map<String, dynamic>;
          final book = map['book'];
          final chapter = map['chapter'];
          final verse = map['verse'];

          await _loadChapter(book: book, chapter: chapter);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollToVerse(verse);
          });

          await historyRepo.addHistory(
            bookId: book,
            chapter: chapter,
            verse: verse,
            action: "search",
          );
        }
        break;
      case 3:
        showSettingSheet(context, settings, onSettingsChanged);
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    _restoreLastChapter();

    settings.addListener(_onSettingsChanged);
  }

  @override
  void dispose() {
    settings.removeListener(_onSettingsChanged);
    super.dispose();
  }

  Future<void> _restoreLastChapter() async {
    final last = await historyRepo.getLastChapter();

    if (last == null) {
      await _loadChapter(book: 1, chapter: 1);
      return;
    }

    await _loadChapter(book: last['book']!, chapter: last['chapter']!);
  }

  Widget _buildBottomBar() {
    return AnimatedSlide(
      duration: const Duration(milliseconds: 200),
      offset: scrollController.showBottomBar ? Offset.zero : const Offset(0, 1),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 150),
        opacity: scrollController.showBottomBar ? 1 : 0,
        child: BottomNavigationBar(
          currentIndex: bottomIndex,
          onTap: _onBottomTap,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.bookmark_border),
              label: 'Bookmarks',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              label: 'History',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        // dragVelocity가 0보다 크면 → 오른쪽으로 휙.
        if (details.primaryVelocity! > 0) {
          // 이전 장
          _goToPreviousChapter();
        } else if (details.primaryVelocity! < 0) {
          // 다음 장
          _goToNextChapter();
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            NotificationListener<ScrollNotification>(
              onNotification: (scroll) {
                scrollController.onScroll(scroll, () {
                  if (mounted) setState(() {});
                });
                return false;
              },

              child: CustomScrollView(
                controller: _listController,
                slivers: [
                  SliverAppBar(
                    floating: true,
                    snap: true,
                    title: GestureDetector(
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BookListPage(
                              initialBook: _currentBook,
                              initialChapter: _currentChapter,
                            ),
                          ),
                        );

                        if (result != null && mounted) {
                          final map = result as Map<String, dynamic>;
                          final book = map['book'];
                          final chapter = map['chapter'];
                          final verse = map['verse'];

                          await _loadChapter(book: book, chapter: chapter);
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            _scrollToVerse(verse);
                          });

                          await historyRepo.addHistory(
                            bookId: book,
                            chapter: chapter,
                            verse: verse,
                            action: "select",
                          );
                        }
                      },
                      child: Text("$_currentBookName $_currentChapter"),
                    ),
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.info_outline),
                        padding: const EdgeInsets.only(right: 16),
                        onPressed: () {
                          Navigator.pushNamed(context, '/info');
                        },
                      ),
                    ],
                  ),

                  SliverToBoxAdapter(
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.only(top: 12),
                      itemCount: verses.length,
                      itemBuilder: (context, index) {
                        final row = verses[index];
                        return MeasureSize(
                          onChange: (size) {
                            _verseHeights["$_currentBook-$_currentChapter-$index"] =
                                size.height;
                          },
                          child: VerseTile(
                            v_id: row['v_id'],
                            bookName: _currentBookName,
                            chapter: _currentChapter,
                            verse: row['verse'],
                            content: row['content'],
                            highlighted: index == _highlightedVerseIndex,
                            highlightColorCode: bookmarkProvider
                                .getHighlightColor(row['v_id']),
                          ),
                        );
                      },
                    ),
                  ),

                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 30, bottom: 100),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          TextButton(
                            onPressed: () {
                              _goToPreviousChapter();
                            },
                            child: Text('< Previous'),
                          ),
                          TextButton(
                            onPressed: () {
                              _goToNextChapter();
                            },
                            child: Text('Next >'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(left: 0, right: 0, bottom: 0, child: _buildBottomBar()),
          ],
        ),
      ),
    );
  }
}

typedef OnWidgetSizeChange = void Function(Size size);

class MeasureSize extends StatefulWidget {
  final Widget child;
  final OnWidgetSizeChange onChange;
  const MeasureSize({super.key, required this.onChange, required this.child});

  @override
  State<MeasureSize> createState() => _MeasureSizeState();
}

class _MeasureSizeState extends State<MeasureSize> {
  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return; // 👈 이 줄 추가
      final box = context.findRenderObject() as RenderBox?;
      if (box != null) widget.onChange(box.size);
    });
    return widget.child;
  }
}
