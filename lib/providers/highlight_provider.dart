import 'package:flutter/material.dart';

class HighlightProvider extends ChangeNotifier {
  final Map<int, int> _highlighted = {};
  // key = verseId(int), value = colorCode(int)

  int? getColor(int verseId) {
    return _highlighted[verseId];
  }

  void setColor(int verseId, int? colorCode) {
    if (colorCode == null) {
      _highlighted.remove(verseId);
    } else {
      _highlighted[verseId] = colorCode;
    }
    notifyListeners();
  }

  /// DB에서 로드할 때 전체 넣기
  void loadFromDB(Map<int, int> initial) {
    _highlighted.clear();
    _highlighted.addAll(initial);
    notifyListeners();
  }
}
