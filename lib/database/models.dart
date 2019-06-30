import 'package:intl/intl.dart';

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

class Date {
  final int year;
  final int month;
  final int day;

  const Date({
    this.year,
    this.month,
    this.day,
  });

  factory Date.fromDateTime(DateTime datetime) {
    return Date(year: datetime.year, month: datetime.month, day: datetime.day);
  }

  factory Date.parse(String isoString) {
    return Date.fromDateTime(DateTime.parse(isoString));
  }

  DateTime toDateTime() {
    return DateTime.utc(year, month, day);
  }

  Date add(int days) {
    return Date.fromDateTime(toDateTime().add(Duration(days: days)));
  }

  int difference(Date date) {
    return toDateTime().difference(date.toDateTime()).inDays;
  }

  String get isoFormat {
    return DateFormat("yyyy-MM-dd").format(toDateTime());
  }

  String get display {
    return DateFormat.yMMMEd().format(toDateTime());
  }

  @override
  bool operator ==(other) {
    return other.year == year && other.month == month && other.day == day;
  }

  @override
  String toString() {
    return "Date[year=${year}, month=${month}, day=${day}]";
  }
}