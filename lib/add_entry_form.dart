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
      body: _AddEntryForm(date: date),
    );
  }
}

class _AddEntryForm extends StatefulWidget {
  Date date;

  _AddEntryForm({this.date});

  @override
  _AddEntryFormState createState() => _AddEntryFormState();
}

class _AddEntryFormState extends State<_AddEntryForm> {
  final _formKey = GlobalKey<FormState>();
  final descriptionController = TextEditingController();
  final caloriesController = TextEditingController();

  _submitForm(context, entryList) async {
    if (_formKey.currentState.validate()) {
      var entry = Entry(
        name: descriptionController.text,
        calories: int.parse(caloriesController.text),
        date: widget.date,
      );
      await entryList.add(entry);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            TextFormField(
              controller: descriptionController,
              decoration: const InputDecoration(
                hintText: 'Description of food',
              ),
              validator: (value) {
                if (value.isEmpty) {
                  return 'Please enter some text';
                }
              },
            ),
            TextFormField(
              controller: caloriesController,
              decoration: const InputDecoration(
                hintText: 'Calories',
              ),
              inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value.isEmpty) {
                  return 'Please enter a value';
                }
              },
            ),
            Consumer<EntryList>(
                builder: (context, entryList, child) => RaisedButton(
              onPressed: () => _submitForm(context, entryList),
              child: Text('Submit'),
            )),
          ],
        ));
  }
}
