import 'dart:collection';

import 'package:flutter/widgets.dart';

import 'date.dart';
import 'database.dart';
import 'models.dart';

class EntryList extends ChangeNotifier {
  static final EntryList _singleton = new EntryList._internal();
  List<Entry> _entries = [];

  EntryList._internal() {
    CalorieTrackerDatabase().listEntries().then((entries) {
      _entries = entries;
      notifyListeners();
    });
  }

  factory EntryList() {
    return _singleton;
  }

  UnmodifiableListView<Entry> forDate(Date date) {
    return UnmodifiableListView(_entries.where((entry) => entry.date == date).toList());
  }

  int totalCalories(Date date) {
    return forDate(date).fold(0, (total, entry) => total + entry.calories);
  }

  void add(Entry entry) async {
    assert(entry.id == null);
    _entries.add(entry);
    entry.id = await CalorieTrackerDatabase().insertEntry(entry);
    notifyListeners();
  }

  void update(Entry entry) async {
    assert(entry.id != null);
    var index = _entries.indexWhere((e) => e.id == entry.id);
    _entries[index] = entry;
    await CalorieTrackerDatabase().updateEntry(entry);
    notifyListeners();
  }

  void delete(Entry entry) async {
    assert(entry.id != null);
    _entries.removeWhere((e) => e.id == entry.id);
    await CalorieTrackerDatabase().deleteEntry(entry);
    notifyListeners();
  }
}
