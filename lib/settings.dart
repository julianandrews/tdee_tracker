import 'package:shared_preferences/shared_preferences.dart';

enum WeightUnit {
  Pounds,
  Kilograms,
}

Future<WeightUnit> getUnit() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return WeightUnit.values[prefs.getInt('weight-unit') ?? 0];
}

setUnit(WeightUnit unit) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setInt('weight-unit', unit.index);
}
