import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'date.dart';
import 'entry_form.dart';
import 'entry_list.dart';
import 'models.dart';

class CalorieTracker extends StatefulWidget {
  @override
  _CalorieTrackerState createState() => _CalorieTrackerState();
}

class _CalorieTrackerState extends State<CalorieTracker> {
  // PageView requires a first page - so this is it!
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

enum EntryAction {
  Delete,
  Edit,
}

class _EntriesForDate extends StatelessWidget {
  final Date date;

  _EntriesForDate({Key key, this.date}) : super(key: key);

  _showActions(
      BuildContext context, EntryList entryList, Entry entry) async {
    switch (await showDialog<EntryAction>(
      context: context,
      builder: (BuildContext context) => SimpleDialog(
            title: const Text('Action'),
            children: <Widget>[
              SimpleDialogOption(
                onPressed: () => Navigator.pop(context, EntryAction.Edit),
                child: const Text('Edit'),
              ),
              SimpleDialogOption(
                onPressed: () => Navigator.pop(context, EntryAction.Delete),
                child: const Text('Delete'),
              ),
            ],
          ),
    )) {
      case EntryAction.Edit:
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => EditEntryPage(entry: entry)));
        Scaffold.of(context)
            .showSnackBar(SnackBar(content: Text('Entry Saved')));
        break;
      case EntryAction.Delete:
        await entryList.delete(entry);
        Scaffold.of(context)
            .showSnackBar(SnackBar(content: Text('Entry Deleted')));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Handle the empty entry list with a nice indicator.
    return Consumer<EntryList>(builder: (context, entryList, child) {
      var entryRows = entryList
          .forDate(date)
          .map((entry) => InkWell(
                onTap: () => _showActions(context, entryList, entry),
                child: _EntryRow(entry: entry),
              ))
          .toList();
      return Column(children: <Widget>[
        Padding(
            padding: EdgeInsets.all(8.0),
            child: _EntriesHeader(
                date: date, totalCalories: entryList.totalCalories(date))),
        Expanded(
            child: Scrollbar(
                child: ListView.separated(
          itemBuilder: (context, index) => entryRows[index],
          itemCount: entryRows.length,
          separatorBuilder: (BuildContext context, int index) =>
              const Divider(),
        ))),
      ]);
    });
  }
}

class _EntriesHeader extends StatelessWidget {
  final Date date;
  final int totalCalories;

  _EntriesHeader({Key key, this.date, this.totalCalories}) : super(key: key);

  // TODO: Make this attractive, and add in a progress bar once we have a goal set.
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
