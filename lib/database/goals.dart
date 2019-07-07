import 'package:flutter/widgets.dart';

import 'database.dart';
import 'entries.dart';
import 'models.dart';
import 'tdee_calculator.dart';
import 'weights.dart';
import '../settings.dart';

class Goals extends ChangeNotifier {
  static final Goals _singleton = Goals._internal();
  Map<Date, Goal> _goals = Map();
  bool _initialized = false;

  Goals._internal() {
    CalorieTrackerDatabase().listGoals().then((goals) {
      for (final goal in goals) {
        _goals[goal.date] = goal;
      }
      _initialized = true;
      Settings().addListener(_updateToday);
      Entries().addListener(_updateToday);
      Weights().addListener(_updateToday);
      notifyListeners();
    });
  }

  factory Goals() {
    return _singleton;
  }

  Goal forDate(Date date) {
    if (_initialized &&
        !_goals.containsKey(date) &&
        Date.fromDateTime(DateTime.now()).difference(date) >= 0) {
      _updateDate(date);
    }
    return _goals[date];
  }

  void add(Goal goal) async {
    assert(_initialized && goal.id == null);
    _goals[goal.date] = goal;
    goal.id = await CalorieTrackerDatabase().insertGoal(goal);
    notifyListeners();
  }

  void update(Goal goal) async {
    assert(_initialized && goal.id != null);
    _goals[goal.date] = goal;
    await CalorieTrackerDatabase().updateGoal(goal);
    notifyListeners();
  }

  void _updateDate(Date date) async {
    var goal = _goals[date] ?? Goal(date: date);
    goal.goal = Settings().goal;
    goal.tdee = calculateTdee(date);
    await goal.id == null ? add(goal) : update(goal);
  }

  void _updateToday() async {
    _updateDate(Date.fromDateTime(DateTime.now()));
  }
}
