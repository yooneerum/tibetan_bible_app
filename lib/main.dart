import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tibetan_bible_app/database_helper.dart';
import 'package:tibetan_bible_app/providers/bookmark_provider.dart';
import 'package:tibetan_bible_app/repositories/bookmark_repo.dart';
import 'package:tibetan_bible_app/services/foreign_words.dart';
import 'package:tibetan_bible_app/themes/app_font.dart';
import 'app.dart';
import '../user_database_helper.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppSettings.instance.load();
  await ForeignWords.load();

  final bibleDb = await DatabaseHelper().database;
  final userDb = await UserDatabaseHelper().database;

  runApp(
    MultiProvider(
      providers: [
        Provider<BookmarkRepo>.value(
          value: BookmarkRepo(bibleDb: bibleDb, userDb: userDb),
        ),
        ChangeNotifierProvider(
          create: (context) => BookmarksProvider(context.read<BookmarkRepo>()),
        ),
      ],
      child: const TibetanBibleApp(),
    ),
  );
}
