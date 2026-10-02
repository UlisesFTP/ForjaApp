import 'package:flutter/foundation.dart';

enum AppPage { today, plan, progress, exercises, more, cardio, nutrition }

class ShellViewModel extends ChangeNotifier {
  AppPage page = AppPage.today;
  int get navIndex => page.index < 5 ? page.index : 4;
  void select(int index) => open(AppPage.values[index]);
  void open(AppPage value) {
    page = value;
    notifyListeners();
  }
}
