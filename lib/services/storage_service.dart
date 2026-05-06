import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

class StorageService {
  static const String _settingsBoxName = 'settings';
  static const String _themeKey = 'isDarkMode';
  static const String _budgetKey = 'monthlyBudget';
  static const String _timeFilterKey = 'timeFilter';

  static Future<void> init() async {
    await Hive.openBox(_settingsBoxName);
  }

  // Theme Logic
  static bool isDarkMode() {
    final box = Hive.box(_settingsBoxName);
    return box.get(_themeKey, defaultValue: false);
  }

  static Future<void> toggleTheme(bool value) async {
    final box = Hive.box(_settingsBoxName);
    await box.put(_themeKey, value);
  }

  // Budget Logic
  static double getBudget() {
    final box = Hive.box(_settingsBoxName);
    return box.get(_budgetKey, defaultValue: 0.0);
  }

  static Future<void> setBudget(double value) async {
    final box = Hive.box(_settingsBoxName);
    await box.put(_budgetKey, value);
  }

  // Time Filter Logic
  static String getTimeFilter() {
    final box = Hive.box(_settingsBoxName);
    return box.get(_timeFilterKey, defaultValue: 'month');
  }

  static Future<void> setTimeFilter(String value) async {
    final box = Hive.box(_settingsBoxName);
    await box.put(_timeFilterKey, value);
  }

  static ValueListenable<Box> getSettingsListenable() {
    return Hive.box(_settingsBoxName).listenable();
  }
}
