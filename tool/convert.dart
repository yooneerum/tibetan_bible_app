import 'dart:convert';
import 'dart:io';

Future<void> main() async {
  final input = await File('assets/words.txt').readAsLines();

  final words = input.map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

  final json = const JsonEncoder.withIndent('  ').convert(words);

  await File('assets/foreign_words.json').writeAsString(json);

  print('완료!');
}

//외래어 추가 시 assets/words.text에 단어 넣고 터미널에 dart run tool/convert.dart 실행하면 assets에 foreign_words.json 파일 생성됨
//flutter clean
//flutter pub get
//flutter build apk
