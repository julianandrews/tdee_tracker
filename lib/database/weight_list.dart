import 'dart:collection';

import 'package:flutter/widgets.dart';

import 'database.dart';
import 'models.dart';

class WeightList extends ChangeNotifier {
  static final WeightList _singleton = new WeightList._internal();
  List<Weight> _weights = [];

  WeightList._internal() {
    CalorieTrackerDatabase().listWeights().then((weights) {
      _weights = weights;
      notifyListeners();
    });
  }

  factory WeightList() {
    return _singleton;
  }

  UnmodifiableListView<Weight> get list {
    return UnmodifiableListView(_weights);
  }

  void add(Weight entry) async {
    assert(entry.id == null);
    _weights.add(entry);
    entry.id = await CalorieTrackerDatabase().insertWeight(entry);
    notifyListeners();
  }

  void update(Weight entry) async {
    assert(entry.id != null);
    var index = _weights.indexWhere((e) => e.id == entry.id);
    _weights[index] = entry;
    await CalorieTrackerDatabase().updateWeight(entry);
    notifyListeners();
  }

  void delete(Weight entry) async {
    assert(entry.id != null);
    _weights.removeWhere((e) => e.id == entry.id);
    await CalorieTrackerDatabase().deleteWeight(entry);
    notifyListeners();
  }
}
