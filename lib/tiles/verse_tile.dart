import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tibetan_bible_app/bottomsheets/bookmark_bottom.dart';
import 'package:tibetan_bible_app/providers/bookmark_provider.dart';
import 'package:tibetan_bible_app/themes/app_font.dart';
import 'package:tibetan_bible_app/services/foreign_words.dart';

class VerseTile extends StatelessWidget {
  final int v_id;
  final String bookName;
  final int chapter;
  final int verse;
  final String content;

  // 임시 하이라이트(2초 효과)
  final bool highlighted;

  // DB 하이라이트 컬러코드 (0~5)
  final int? highlightColorCode;

  const VerseTile({
    super.key,
    required this.v_id,
    required this.bookName,
    required this.chapter,
    required this.verse,
    required this.content,
    this.highlighted = false,
    required this.highlightColorCode,
  });

  @override
  Widget build(BuildContext context) {
    final settings = AppSettings.instance;

    final defaultStyle = DefaultTextStyle.of(context).style;

    final highlightProvider = context.watch<BookmarksProvider>();
    final int? colorCode = highlightProvider.getHighlightColor(v_id);

    final Color? highlightPaintColor = highlightTextColor(colorCode);

    return AnimatedBuilder(
      animation: settings,
      builder: (_, _) {
        return ListTile(
          tileColor: highlighted
              // ignore: deprecated_member_use
              ? Colors.yellow.withOpacity(0.3)
              : Colors.transparent,

          title: RichText(
            text: TextSpan(
              style: defaultStyle,
              children: [
                TextSpan(
                  text: "$verse  ",
                  style: defaultStyle.copyWith(
                    fontSize: settings.fontSize - 8,
                    height: 1.6,
                  ),
                ),
                ...buildVerseSpans(
                  context,
                  content,
                  highlightPaintColor, // null이면 배경 없음, 색상이면 형광펜
                  settings.fontSize,
                ),
              ],
            ),
            strutStyle: StrutStyle(
              fontSize: settings.fontSize,
              height: 1.6,
              forceStrutHeight: true,
            ),
          ),
          onTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              builder: (context) {
                return Theme(
                  data: ThemeData.light(),
                  child: VerseBottomSheet(
                    bookName: bookName,
                    chapter: chapter,
                    verseNumber: verse,
                    verseId: v_id,
                    verseContent: content,
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

List<InlineSpan> buildVerseSpans(
  BuildContext context,
  String text,
  Color? highlightColor,
  double fontSize,
) {
  final spans = <InlineSpan>[];
  final baseStyle = DefaultTextStyle.of(context).style;
  final regex = RegExp(r'[\u0F00-\u0FFF]+');

  int last = 0;

  for (final match in regex.allMatches(text)) {
    // 티벳어가 아닌 부분
    if (match.start > last) {
      spans.add(
        TextSpan(
          text: text.substring(last, match.start),
          style: baseStyle.copyWith(fontSize: fontSize, height: 1.5),
        ),
      );
    }

    final word = match.group(0)!;
    spans.addAll(
      buildWordSpans(
        word,
        baseStyle.copyWith(fontSize: fontSize, height: 1.5),
        highlightColor,
      ),
    );

    last = match.end;
  }

  // 남은 부분
  if (last < text.length) {
    spans.add(
      TextSpan(
        text: text.substring(last),
        style: baseStyle.copyWith(fontSize: fontSize, height: 1.5),
      ),
    );
  }

  return spans;
}

List<InlineSpan> buildWordSpans(
  String word,
  TextStyle baseStyle,
  Color? highlightColor,
) {
  final spans = <InlineSpan>[];

  final paint = highlightColor == null
      ? null
      : (Paint()
          ..color = highlightColor
          ..style = PaintingStyle.fill);

  int index = 0;

  while (index < word.length) {
    String? matched;

    // 가장 긴 단어부터 찾는다
    for (final foreign in ForeignWords.words) {
      if (word.startsWith(foreign, index)) {
        if (matched == null || foreign.length > matched.length) {
          matched = foreign;
        }
      }
    }

    if (matched != null) {
      spans.add(
        // 외래어 매칭된 부분
        TextSpan(
          text: matched,
          style: baseStyle.copyWith(
            color: const Color.fromARGB(255, 220, 91, 52), // 👈
            background: paint,
          ),
        ),
      );

      index += matched.length;
    } else {
      spans.add(
        TextSpan(
          text: word[index],
          style: baseStyle.copyWith(background: paint),
        ),
      );

      index++;
    }
  }

  return spans;
}
