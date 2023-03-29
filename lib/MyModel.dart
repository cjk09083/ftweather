import 'package:flutter/foundation.dart';

class MyModel extends ChangeNotifier {
  int _count = 0;

  int get count => _count;

  void incrementCount() {
    _count++;
    notifyListeners();
  }
}
