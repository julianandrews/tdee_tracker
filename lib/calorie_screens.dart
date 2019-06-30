import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

import 'database/entry_list.dart';
import 'database/models.dart';

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
    Navigator.pushNamed(context, AddEntryScreen.routeName, arguments: date);
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

enum _EntryAction {
  Delete,
  Edit,
}

class _EntriesForDate extends StatelessWidget {
  final Date date;

  _EntriesForDate({Key key, this.date}) : super(key: key);

  _showActions(BuildContext context, EntryList entryList, Entry entry) async {
    switch (await showDialog<_EntryAction>(
      context: context,
      builder: (BuildContext context) => SimpleDialog(
            title: const Text('Action'),
            children: <Widget>[
              SimpleDialogOption(
                onPressed: () => Navigator.pop(context, _EntryAction.Edit),
                child: const Text('Edit'),
              ),
              SimpleDialogOption(
                onPressed: () => Navigator.pop(context, _EntryAction.Delete),
                child: const Text('Delete'),
              ),
            ],
          ),
    )) {
      case _EntryAction.Edit:
        Navigator.pushNamed(context, EditEntryScreen.routeName, arguments: entry);
        Scaffold.of(context)
            .showSnackBar(SnackBar(content: Text('Entry Saved')));
        break;
      case _EntryAction.Delete:
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
class AddEntryScreen extends StatelessWidget {
  static const routeName = '/entry/add';

  @override
  Widget build(BuildContext context) {
    final Date date = ModalRoute.of(context).settings.arguments;

    return Scaffold(
      appBar: AppBar(
        title: Text('Add entry for ${date.display}'),
      ),
      body: _EntryForm(Entry(date: date)),
    );
  }
}

class EditEntryScreen extends StatelessWidget {
  static const routeName = '/entry/edit';

  @override
  Widget build(BuildContext context) {
    final Entry entry = ModalRoute.of(context).settings.arguments;

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit entry'),
      ),
      body: _EntryForm(entry),
    );
  }
}

class _EntryForm extends StatefulWidget {
  final Entry initialValue;

  _EntryForm(this.initialValue);

  @override
  _EntryFormState createState() => _EntryFormState();
}

class _EntryFormState extends State<_EntryForm> {
  TextEditingController _descriptionController;
  TextEditingController _caloriesController;
  bool _saveEnabled;

  @override
  initState() {
    _descriptionController = TextEditingController(text: widget.initialValue.name);
    _caloriesController =
        TextEditingController(text: widget.initialValue.calories?.toString());
    _saveEnabled = !_descriptionController.text.isEmpty;
  }

  _submitForm(context, entryList) async {
    if (widget.initialValue.id == null) {
      await entryList.add(Entry(
        name: _descriptionController.text,
        calories: int.parse(_caloriesController.text),
        date: widget.initialValue.date,
      ));
    } else {
      await entryList.update(Entry(
        id: widget.initialValue.id,
        name: _descriptionController.text,
        calories: int.parse(_caloriesController.text),
        date: widget.initialValue.date,
      ));
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
        return Column(
          children: <Widget>[
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                hintText: 'Description of food',
              ),
              onChanged: (value) => setState(() => _saveEnabled = !value.isEmpty),
            ),
            TextField(
              controller: _caloriesController,
              decoration: const InputDecoration(
                hintText: 'Calories',
              ),
              inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
              keyboardType: TextInputType.number,
            ),
            Consumer<EntryList>(
                builder: (context, entryList, child) => RaisedButton(
                      onPressed: _saveEnabled
                          ? () => _submitForm(context, entryList)
                          : null,
                      child: Text('Save'),
                    )),
          ],
        );
  }
}
