//외래어 색상 변환을 빠르게 하기 위한 메모리 기반 사전

import 'dart:convert';
import 'package:flutter/services.dart';

class ForeignWords {
  static final Set<String> words = {};

  static Future<void> load() async {
    final jsonString = await rootBundle.loadString('assets/foreign_words.json');

    final List<dynamic> list = json.decode(jsonString);

    words
      ..clear()
      ..addAll(list.cast<String>());
  }

  static bool isForeignWord(String word) {
    return words.contains(word);
  }
}
