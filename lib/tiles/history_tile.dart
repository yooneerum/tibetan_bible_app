import 'package:flutter/material.dart';
import 'package:tibetan_bible_app/tiles/history_item.dart';

class HistoryTile extends StatelessWidget {
  final HistoryItem item;
  final VoidCallback? onTap;
  final IconData icon;

  const HistoryTile({
    super.key,
    required this.item,
    required this.icon,
    this.onTap,
  });

  String _formatTs(int ts) {
    final date = DateTime.fromMillisecondsSinceEpoch(ts);
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 60) return "${diff.inMinutes} mins";
    if (diff.inHours < 24) return "${diff.inHours} hours";
    if (diff.inDays == 1) return "Yesterday ${date.hour}o'clock";
    return "${date.month}month ${date.day}day";
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: colors.shadow.withOpacity(0.1),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: colors.primaryContainer,
              child: Icon(icon, color: colors.onPrimaryContainer, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${item.bookName} ${item.chapter}:${item.verse}",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: colors.primary,
                      fontSize: 19,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.content,
                    style: TextStyle(
                      height: 1.4,
                      fontSize: 23,
                      color: colors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _formatTs(item.timestamp),
                    style: TextStyle(color: colors.outline, fontSize: 15),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
