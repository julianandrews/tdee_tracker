import 'dart:collection';

import 'package:flutter/widgets.dart';

import 'database.dart';
import 'models.dart';

class Weights extends ChangeNotifier {
  static final Weights _singleton = new Weights._internal();
  List<Weight> _weights = [];

  Weights._internal() {
    CalorieTrackerDatabase().listWeights().then((weights) {
      _weights = weights;
      notifyListeners();
    });
  }

  factory Weights() {
    return _singleton;
  }

  UnmodifiableListView<Weight> get list {
    return UnmodifiableListView(_weights);
  }

  void add(Weight weight) async {
    assert(weight.id == null);
    _weights.add(weight);
    weight.id = await CalorieTrackerDatabase().insertWeight(weight);
    notifyListeners();
  }

  void update(Weight weight) async {
    assert(weight.id != null);
    var index = _weights.indexWhere((e) => e.id == weight.id);
    _weights[index] = weight;
    await CalorieTrackerDatabase().updateWeight(weight);
    notifyListeners();
  }

  void delete(Weight weight) async {
    assert(weight.id != null);
    _weights.removeWhere((e) => e.id == weight.id);
    await CalorieTrackerDatabase().deleteWeight(weight);
    notifyListeners();
  }
}
