import 'date.dart';

class Entry {
  int id;
  String name;
  int calories;
  Date date;

  Entry({
    this.id,
    this.name,
    this.calories,
    this.date,
  });

  @override
  String toString() {
    return "Entry[id=${id}, name=${name}, calories=${calories}, date=${date}]";
  }
}

class Weight {
  int id;
  DateTime time;
  double weight;

  Weight({
    this.id,
    this.time,
    this.weight,
  });

  @override
  String toString() {
    return "Weight[id=${id}, time=${time}, weight=${weight}]";
  }
}
