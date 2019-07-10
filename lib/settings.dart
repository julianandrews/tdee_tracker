import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'database/models.dart';

enum WeightUnits {
  Pounds,
  Kilograms,
}

class WeightUnitsHelper {
  static String unitName(WeightUnits units) {
    switch (units) {
      case WeightUnits.Pounds:
        return "Pounds";
      case WeightUnits.Kilograms:
        return "Kilograms";
    }
  }

  static String unitNameShort(WeightUnits units) {
    switch (units) {
      case WeightUnits.Pounds:
        return "lb";
      case WeightUnits.Kilograms:
        return "kg";
    }
  }

  static double weightInUnits(Weight weight, WeightUnits units) {
    switch (units) {
      case WeightUnits.Pounds:
        return num.parse((weight.weight * 2.20462).toStringAsFixed(1));
      case WeightUnits.Kilograms:
        return weight.weight;
    }
  }

  static double kilosFromUnits(double weight, WeightUnits units) {
    switch (units) {
      case WeightUnits.Pounds:
        return num.parse((weight * 0.453592).toStringAsFixed(2));
      case WeightUnits.Kilograms:
        return weight;
    }
  }
}

class Settings extends ChangeNotifier {
  static final Settings _singleton = Settings._internal();
  WeightUnits _units;
  int _goal;
  int _initialTdee;

  Settings._internal() {}

  factory Settings() => _singleton;

  static Future<Settings> initialize() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _singleton._units = WeightUnits.values[prefs.getInt('weight-units') ?? 0];
    _singleton._goal = prefs.getInt('goal') ?? 0;
    _singleton._initialTdee = prefs.getInt('initialTdee');
    return _singleton;
  }

  WeightUnits get units => _units;

  setUnits(WeightUnits units) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('weight-units', units.index);
    _singleton._units = units;
    notifyListeners();
  }

  int get goal => _goal;

  setGoal(int goal) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('goal', goal);
    _singleton._goal = goal;
    notifyListeners();
  }

  int get initialTdee => _initialTdee;

  setInitialTdee(int tdee) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('initialTdee', tdee);
    _singleton._initialTdee = tdee;
    notifyListeners();
  }
}
