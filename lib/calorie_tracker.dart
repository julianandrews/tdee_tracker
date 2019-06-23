import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'add_entry_form.dart';
import 'date.dart';
import 'entry_list.dart';
import 'models.dart';

class CalorieTracker extends StatefulWidget {
  @override
  _CalorieTrackerState createState() => _CalorieTrackerState();
}

class _CalorieTrackerState extends State<CalorieTracker> {
  // The earliest date you can swipe back to.
  static const earliestDate = Date(day: 1, month: 1, year: 1900);
  final initialPage =
      Date.fromDateTime(DateTime.now()).difference(earliestDate);
  Date date = Date.fromDateTime(DateTime.now());

  onCreateEntryPressed() {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => AddEntryPage(date: date)));
  }

  static Date dateFromPageIndex(int index) {
    return earliestDate.add(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Calorie Tracker')),
      body: PageView.builder(
        controller: PageController(initialPage: initialPage),
        itemBuilder: (context, position) =>
            _EntriesForDate(date: dateFromPageIndex(position)),
        onPageChanged: (value) => date = dateFromPageIndex(value),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: onCreateEntryPressed,
        tooltip: 'Create Entry',
        child: Icon(Icons.add),
      ),
    );
  }
}

class _EntriesForDate extends StatelessWidget {
  final Date date;

  _EntriesForDate({Key key, this.date}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: Handle the empty entry list with a nice indicator.
    return Consumer<EntryList>(
        builder: (context, entryList, child) {
          var entries = entryList.forDate(date)
                    .map((entry) => _EntryRow(entry: entry))
                    .toList();
          return Column(children: <Widget>[
              Padding(
                  padding: EdgeInsets.all(8.0),
                  child: _EntriesHeader(
                      date: date,
                      totalCalories: entryList.totalCalories(date))),
              Expanded(
                  child: ListView.separated(
                      itemBuilder: (context, index) => entries[index],
                      itemCount: entries.length,
                    separatorBuilder: (BuildContext context, int index) => const Divider(),
              )),
            ]);
        });
  }
}

class _EntriesHeader extends StatelessWidget {
  final Date date;
  final int totalCalories;

  _EntriesHeader({Key key, this.date, this.totalCalories}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(child: Text(date.display)),
      Text("${totalCalories}")
    ]);
  }
}

class _EntryRow extends StatelessWidget {
  final Entry entry;

  _EntryRow({Key key, this.entry}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(8.0),
        child: Row(children: [
          Expanded(
              child: Text(
            entry.name,
            overflow: TextOverflow.ellipsis,
          )),
          Text("${entry.calories}"),
        ]));
  }
}
