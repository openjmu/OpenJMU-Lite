import 'package:flutter/cupertino.dart';

class Courses with ChangeNotifier {
    int _count = 0;
    int get value => _count;

    void increment() {
        _count++;
        notifyListeners();
    }
}
