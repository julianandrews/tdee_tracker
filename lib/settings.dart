import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum WeightUnits {
  Pounds,
  Kilograms,
}

class Settings extends ChangeNotifier {
  static final Settings _singleton = Settings._internal();
  WeightUnits _units;

  Settings._internal() {}

  factory Settings() => _singleton;

  static Future<Settings> initialize() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _singleton._units = WeightUnits.values[prefs.getInt('weight-units') ?? 0];
    return _singleton;
  }

  WeightUnits get units => _units;

  setUnits(WeightUnits units) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('weight-units', units.index);
    _singleton._units = units;
    notifyListeners();
  }
}

