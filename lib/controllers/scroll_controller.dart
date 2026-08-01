import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class HomeScrollController extends ChangeNotifier {
  bool showBottomBar = true;

  void onScroll(ScrollNotification scroll, VoidCallback onChanged) {
    if (scroll is UserScrollNotification) {
      if (scroll.direction == ScrollDirection.reverse) {
        if (showBottomBar) {
          showBottomBar = false;
          onChanged(); // <-- setState 호출
        }
      } else if (scroll.direction == ScrollDirection.forward) {
        if (!showBottomBar) {
          showBottomBar = true;
          onChanged(); // <-- setState 호출
        }
      }
    }
  }
}
