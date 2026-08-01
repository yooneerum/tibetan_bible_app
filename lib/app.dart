import 'package:flutter/material.dart';
import 'package:tibetan_bible_app/pages/booklist_page.dart';
import 'package:tibetan_bible_app/pages/bookmark_page.dart';
import 'package:tibetan_bible_app/pages/history_page.dart';
import 'package:tibetan_bible_app/pages/home_page.dart';
import 'package:tibetan_bible_app/pages/search_page.dart';
import 'package:tibetan_bible_app/themes/app_font.dart';
import 'package:tibetan_bible_app/themes/app_theme.dart';
import 'package:tibetan_bible_app/pages/information_page.dart';

class TibetanBibleApp extends StatelessWidget {
  const TibetanBibleApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = AppSettings.instance;

    return AnimatedBuilder(
      animation: settings,
      builder: (context, _) {
        return MaterialApp(
          title: 'Tibetan Bible',
          debugShowCheckedModeBanner: false,

          theme: AppTheme.light(settings.fontSize),
          darkTheme: AppTheme.dark(settings.fontSize),
          themeMode: settings.themeMode,

          initialRoute: '/',
          routes: {
            '/': (context) =>
                HomePage(onSettingsChanged: (AppSettings newSettings) {}),
            '/booklist': (context) => const BookListPage(),
            '/bookmark': (context) => const BookmarksPage(),
            '/history': (context) => HistoryPage(),
            '/search': (context) => const SearchPage(),
            '/info': (context) => const InformationPage(),
          },
        );
      },
    );
  }
}
