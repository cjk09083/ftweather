import 'package:flutter/foundation.dart';

class MyModel extends ChangeNotifier {
  int _count = 0;

  int get count => _count;

  void addMarker() {
    _count++;
    notifyListeners();
  }
}
