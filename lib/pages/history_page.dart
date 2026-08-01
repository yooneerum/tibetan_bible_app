import 'package:flutter/material.dart';
import 'package:tibetan_bible_app/database_helper.dart';
import 'package:tibetan_bible_app/repositories/bible_repo.dart';
import 'package:tibetan_bible_app/repositories/history_repo.dart';
import 'package:tibetan_bible_app/tiles/history_item.dart';
import 'package:tibetan_bible_app/tiles/history_tile.dart';
import '../user_database_helper.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late final HistoryRepository historyRepo;

  @override
  void initState() {
    super.initState();
    historyRepo = HistoryRepository(
      db: DatabaseHelper(),
      bibleRepo: BibleRepository(db: DatabaseHelper()),
      userDb: UserDatabaseHelper(),
    );
  }

  IconData iconFromAction(String action) {
    switch (action) {
      case "search":
        return Icons.search;
      case "chapter_move":
        return Icons.auto_stories_outlined;
      case "bookmark":
        return Icons.bookmark;
      case "select":
        return Icons.list;
      case "history":
        return Icons.history;
      default:
        return Icons.more_horiz;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text("History"), centerTitle: true),
      body: FutureBuilder<List<HistoryItem>>(
        future: historyRepo.getAll(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final items = snap.data!;
          if (items.isEmpty) {
            return Center(
              child: Text(
                "No history",
                style: TextStyle(fontSize: 16, color: colors.outline),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final h = items[i];

              return HistoryTile(
                item: h,
                icon: iconFromAction(h.action_type),
                onTap: () {
                  Navigator.pop(context, {
                    "book": h.bookId,
                    "chapter": h.chapter,
                    "verse": h.verse,
                  });
                },
              );
            },
          );
        },
      ),
    );
  }
}
