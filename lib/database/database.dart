import 'dart:async';
import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'models.dart';

class CalorieTrackerDatabase {
  static const _filename = 'tdee-tracker.db';
  static final _singleton = CalorieTrackerDatabase._internal();
  static Database _database;

  factory CalorieTrackerDatabase() {
    return _singleton;
  }

  CalorieTrackerDatabase._internal() {}

  Future<Database> get database async {
    if (_database == null) {
      _database = await _initializeDatabase();
    }

    return _database;
  }

  insertEntry(Entry entry) async {
    final db = await database;
    await db.insert('entries', {
      'date': entry.date.isoFormat,
      'name': entry.name,
      'calories': entry.calories,
    });
  }

  updateEntry(Entry entry) async {
    final db = await database;
    await db.update(
        'entries',
        {
          'date': entry.date.isoFormat,
          'name': entry.name,
          'calories': entry.calories,
        },
        where: 'id = ?',
        whereArgs: [entry.id]);
  }

  deleteEntry(Entry entry) async {
    final db = await database;
    await db.delete('entries', where: 'id = ?', whereArgs: [entry.id]);
  }

  Future<List<Entry>> listEntries() async {
    final db = await database;
    final results = await db.query('entries');
    return results.isNotEmpty
        ? results
            .map((row) => Entry(
                  id: row['id'],
                  name: row['name'],
                  calories: row['calories'],
                  date: Date.parse(row['date']),
                ))
            .toList()
        : [];
  }

  insertWeight(Weight weight) async {
    final db = await database;
    await db.insert('weights', {
      'timestamp': weight.time.millisecondsSinceEpoch,
      'weight': weight.weight
    });
  }

  updateWeight(Weight weight) async {
    final db = await database;
    await db.update(
        'weights',
        {
          'timestamp': weight.time.millisecondsSinceEpoch,
          'weight': weight.weight
        },
        where: 'id = ?',
        whereArgs: [weight.id]);
  }

  deleteWeight(Weight weight) async {
    final db = await database;
    await db.delete('weights', where: 'id = ?', whereArgs: [weight.id]);
  }

  Future<List<Weight>> listWeights() async {
    final db = await database;
    final results = await db.query('weights');
    return results.isNotEmpty
        ? results
            .map((row) => Weight(
                  id: row['id'],
                  time: DateTime.fromMillisecondsSinceEpoch(row['timestamp']),
                  weight: row['weight'],
                ))
            .toList()
        : [];
  }

  insertGoal(Goal goal) async {
    final db = await database;
    await db.insert('goals', {
      'date': goal.date.isoFormat,
      'tdee': goal.tdee,
      'goal': goal.goal,
    });
  }

  updateGoal(Goal goal) async {
    final db = await database;
    await db.update(
      'goals',
      {
        'date': goal.date.isoFormat,
        'tdee': goal.tdee,
        'goal': goal.goal,
      },
      where: 'id = ?',
      whereArgs: [goal.id],
    );
  }

  Future<List<Goal>> listGoals() async {
    final db = await database;
    final results = await db.query('goals');
    return results.isNotEmpty
        ? results
            .map((row) => Goal(
                  id: row['id'],
                  date: Date.parse(row['date']),
                  tdee: row['tdee'],
                  goal: row['goal'],
                ))
            .toList()
        : [];
  }

  _initializeDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, _filename);

    final exists = await databaseExists(path);
    if (!exists) {
      try {
        await Directory(dirname(path)).create(recursive: true);
      } catch (_) {}
    }

    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  _onCreate(Database database, int version) async {
    await database.execute('''
        CREATE TABLE weights(
          id INTEGER PRIMARY KEY,
          timestamp INTEGER NOT NULL,
          weight REAL NOT NULL
          )
        ''');
    await database.execute('''
        CREATE TABLE entries(
            id INTEGER PRIMARY KEY,
            date TEXT NOT NULL,
            name TEXT NOT NULL,
            calories INTEGER NOT NULL
            )
        ''');
    await database.execute('''
        CREATE TABLE goals(
            id INTEGER PRIMARY KEY,
            date TEXT NOT NULL UNIQUE,
            tdee INTEGER NOT NULL,
            goal INTEGER NOT NULL
            )
        ''');
  }
}
