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
