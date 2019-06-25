import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

import 'date.dart';
import 'database.dart';
import 'entry_list.dart';
import 'models.dart';

class AddEntryPage extends StatelessWidget {
  final Date date;

  AddEntryPage({Key key, Date this.date}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add entry for ${date.display}'),
      ),
      body: _EntryForm(Entry(date: date)),
    );
  }
}

class EditEntryPage extends StatelessWidget {
  final Entry entry;

  EditEntryPage({Key key, Entry this.entry}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit entry'),
      ),
      body: _EntryForm(entry),
    );
  }
}

class _EntryForm extends StatefulWidget {
  final Entry entry;

  _EntryForm(this.entry);

  @override
  _EntryFormState createState() => _EntryFormState();
}

class _EntryFormState extends State<_EntryForm> {
  TextEditingController _descriptionController;
  TextEditingController _caloriesController;
  bool _saveEnabled;

  @override
  initState() {
    _descriptionController = TextEditingController(text: widget.entry.name);
    _caloriesController =
        TextEditingController(text: widget.entry.calories?.toString());
    _saveEnabled = !_descriptionController.text.isEmpty;
  }

  _submitForm(context, entryList) async {
    if (widget.entry.id == null) {
      await entryList.add(Entry(
        name: _descriptionController.text,
        calories: int.parse(_caloriesController.text),
        date: widget.entry.date,
      ));
    } else {
      await entryList.update(Entry(
        id: widget.entry.id,
        name: _descriptionController.text,
        calories: int.parse(_caloriesController.text),
        date: widget.entry.date,
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
