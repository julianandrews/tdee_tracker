import 'dart:collection';

import 'package:flutter/widgets.dart';

import 'date.dart';
import 'database.dart';
import 'models.dart';

class EntryList extends ChangeNotifier {
  List<Entry> _entries = [];

  EntryList() {
    CalorieTrackerDatabase().listEntries().then((entries) {
      _entries = entries;
      notifyListeners();
    });
  }


  UnmodifiableListView<Entry> forDate(Date date) {
    return UnmodifiableListView(_entries.where((entry) => entry.date == date).toList());
  }

  int totalCalories(Date date) {
    return forDate(date).fold(0, (total, entry) => total + entry.calories);
  }

  void add(Entry entry) async {
    _entries.add(entry);
    await CalorieTrackerDatabase().insertEntry(entry);
    notifyListeners();
  }
}
