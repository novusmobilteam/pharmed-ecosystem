import 'package:flutter/material.dart';

class StationSetupNotifier extends ChangeNotifier {
  int _activeIndex = 0;
  int get activeIndex => _activeIndex;

  set activeIndex(int index) {
    if (_activeIndex == index) return;
    _activeIndex = index;
    notifyListeners();
  }
}
