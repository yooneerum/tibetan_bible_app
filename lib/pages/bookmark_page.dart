import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tibetan_bible_app/bottomsheets/bookmark_bottom.dart';
import 'package:tibetan_bible_app/providers/bookmark_provider.dart';

class BookmarksPage extends StatefulWidget {
  const BookmarksPage({super.key});

  @override
  State<BookmarksPage> createState() => _BookmarksPageState();
}

class _BookmarksPageState extends State<BookmarksPage> {
  int selected = 0; // 0 북마크, 1 하이라이트
  final Set<String> expandedGroups = {};

  @override
  void initState() {
    super.initState();
    context.read<BookmarksProvider>().loadAll();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BookmarksProvider>();

    // ✨ 이 테마는 BookmarkPage에서만 적용됨!
    Theme.of(context).copyWith(
      textTheme: Theme.of(context).textTheme.apply(
        // 딱 고정값!
        fontSizeFactor: 1.0,
        bodyColor: Colors.black87,
        displayColor: Colors.black87,
      ),
    );

    return Scaffold(
      appBar: AppBar(title: const Text("Bookmarks")),
      body: Column(
        children: [
          _topTabs(),
          Expanded(child: _buildContent(provider)),
        ],
      ),
    );
  }

  Widget _deleteBackground() {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 24),
      color: Colors.red,
      child: const Icon(Icons.delete, color: Colors.white, size: 25),
    );
  }

  Widget _topTabs() {
    const tabs = ["Bookmark", "Highlight"];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(tabs.length, (i) {
        final active = selected == i;
        return GestureDetector(
          onTap: () => setState(() => selected = i),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              border: active
                  ? const Border(bottom: BorderSide(width: 2))
                  : null,
            ),
            child: Text(
              tabs[i],
              style: TextStyle(
                fontSize: 19,
                fontWeight: active ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildContent(BookmarksProvider provider) {
    switch (selected) {
      case 0:
        return _bookmarkBuildGroupedList(
          provider.bookmarksByBook,
          onDelete: provider.removeBookmark,
        );
      case 1:
        return _highlightBuildGroupedList(
          provider.highlightsByColor.map((k, v) => MapEntry(k.toString(), v)),
          onDelete: provider.removeHighlight,
          showColorDot: true,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _bookmarkBuildGroupedList(
    Map<String, List<Map<String, dynamic>>> data, {
    required Function(int) onDelete,
    bool showColorDot = false,
  }) {
    return ListView(
      children: data.entries.map((entry) {
        final group = entry.key;
        final verses = entry.value;
        final isOpen = expandedGroups.contains(group);

        return Column(
          children: [
            ListTile(
              leading: showColorDot
                  ? CircleAvatar(
                      radius: 8,
                      backgroundColor: Color(int.parse(group)),
                    )
                  : null,
              title: Text(group, style: TextStyle(fontSize: 23)),
              trailing: Text(
                "${verses.length}",
                style: TextStyle(fontSize: 18),
              ),
              onTap: () {
                setState(() {
                  isOpen
                      ? expandedGroups.remove(group)
                      : expandedGroups.add(group);
                });
              },
            ),

            if (isOpen)
              ...verses.map(
                (v) => Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Dismissible(
                    key: ValueKey(v['verse_id']),
                    direction: DismissDirection.endToStart,
                    background: _deleteBackground(),
                    onDismissed: (_) => onDelete(v['verse_id']),
                    child: ListTile(
                      title: Text(
                        "${v['chapter']} : ${v['verse']}",
                        style: TextStyle(fontSize: 18),
                      ),
                      subtitle: Text(v['text'], style: TextStyle(fontSize: 23)),
                      onTap: () {
                        Navigator.pop(context, {
                          "book": v['book_id'],
                          "chapter": v['chapter'],
                          "verse": v['verse'],
                        });
                      },
                    ),
                  ),
                ),
              ),
          ],
        );
      }).toList(),
    );
  }

  Widget _highlightBuildGroupedList(
    Map<String, List<Map<String, dynamic>>> data, {
    required Function(int) onDelete,
    bool showColorDot = false,
  }) {
    return ListView(
      children: data.entries.map((entry) {
        final colorCode = int.parse(entry.key);
        final group = entry.key; // String "1"
        final verses = entry.value;
        final isOpen = expandedGroups.contains(group);

        return Column(
          children: [
            ListTile(
              leading: showColorDot
                  ? CircleAvatar(
                      radius: 8,
                      backgroundColor: highlightTextColor(colorCode),
                    )
                  : null,
              trailing: Text(
                "${verses.length}",
                style: TextStyle(fontSize: 18),
              ),
              onTap: () {
                setState(() {
                  isOpen
                      ? expandedGroups.remove(group)
                      : expandedGroups.add(group);
                });
              },
            ),

            if (isOpen)
              ...verses.map(
                (v) => Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Dismissible(
                    key: ValueKey(v['verse_id']),
                    direction: DismissDirection.endToStart,
                    background: _deleteBackground(),
                    onDismissed: (_) => onDelete(v['verse_id']),
                    child: ListTile(
                      title: Text(
                        "${v['book']} ${v['chapter']} : ${v['verse']}",
                        style: TextStyle(fontSize: 20),
                      ),
                      subtitle: Text(v['text'], style: TextStyle(fontSize: 23)),
                      onTap: () {
                        Navigator.pop(context, {
                          "book": v['book_id'],
                          "chapter": v['chapter'],
                          "verse": v['verse'],
                        });
                      },
                    ),
                  ),
                ),
              ),
          ],
        );
      }).toList(),
    );
  }
}
