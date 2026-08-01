import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tibetan_bible_app/providers/bookmark_provider.dart';

class VerseBottomSheet extends StatelessWidget {
  final String bookName;
  final int chapter;
  final int verseNumber; // 표시용
  final int verseId; // 실제 DB key
  final String verseContent;

  const VerseBottomSheet({
    super.key,
    required this.bookName,
    required this.chapter,
    required this.verseNumber,
    required this.verseId,
    required this.verseContent,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BookmarksProvider>();

    final selectedColor = provider.getHighlightColor(verseId);
    final isBookmarked = provider.bookmarksByBook.values
        .expand((e) => e)
        .any((v) => v['verse_id'] == verseId);

    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        40 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ------------------ 선택된 절 표시 ------------------
          Text(
            "$bookName $chapter : $verseNumber",
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color.fromARGB(221, 36, 36, 36),
            ),
          ),

          const SizedBox(height: 15),

          // ------------------ 하이라이트 6색 ------------------
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(6, (index) {
              final colorCode = index + 1;
              final isSelected = selectedColor == colorCode;

              return GestureDetector(
                onTap: () async {
                  if (isSelected) {
                    await provider.setHighlight(verseId, null); // 삭제
                  } else {
                    await provider.setHighlight(verseId, colorCode);
                  }

                  Navigator.pop(context);
                },

                child: _ColorDot(
                  color: highlightTextColor(colorCode),
                  selected: isSelected,
                ),
              );
            }),
          ),

          const SizedBox(height: 25),

          // ------------------ 아이콘 2개(메모기능 취소)) ------------------
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                iconSize: 32,
                icon: Icon(
                  isBookmarked ? Icons.favorite : Icons.favorite_border,
                  color: isBookmarked
                      ? Colors.red
                      : const Color.fromARGB(221, 36, 36, 36),
                ),
                onPressed: () async {
                  if (isBookmarked) {
                    await provider.removeBookmark(verseId);
                  } else {
                    await provider.addBookmark(verseId);
                  }
                  Navigator.pop(context); // 저장 후 닫기
                },
              ),
              IconButton(
                icon: const Icon(Icons.copy, size: 30),
                onPressed: () {
                  final copyText =
                      '''
$verseContent
[$bookName $chapter:$verseNumber]
''';

                  Clipboard.setData(ClipboardData(text: copyText));

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text(
                        "Copied!",
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                      backgroundColor: Colors.black87,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      duration: const Duration(seconds: 1),
                    ),
                  );

                  Navigator.pop(context); // 원하면 유지, 싫으면 제거
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// --------------------------------------------------
// ● 컬러 버튼 공통 위젯 (테두리 표시 포함)
// --------------------------------------------------
class _ColorDot extends StatelessWidget {
  final Color? color;
  final bool selected;

  const _ColorDot({required this.color, this.selected = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        border: selected ? Border.all(width: 2, color: Colors.black) : null,
      ),
    );
  }
}

// --------------------------------------------------
// ● 색상 매핑 (1~6)
// --------------------------------------------------
Color? highlightTextColor(int? code) {
  if (code == null) return null;
  switch (code) {
    case 1:
      return Colors.pink.withOpacity(0.4);
    case 2:
      return Colors.orange.withOpacity(0.4);
    case 3:
      return Colors.yellow.withOpacity(0.4);
    case 4:
      return Colors.green.withOpacity(0.4);
    case 5:
      return Colors.blue.withOpacity(0.4);
    case 6:
      return Colors.purple.withOpacity(0.4);
  }
  return null;
}
