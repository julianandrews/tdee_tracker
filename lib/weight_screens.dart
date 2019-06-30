import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'utils/date_time_picker.dart';
import 'utils/input_formatters.dart';
import 'database/models.dart';
import 'database/weight_list.dart';

class WeightTracker extends StatelessWidget {
  _onCreateWeightPressed(context) {
    Navigator.pushNamed(context, AddWeightScreen.routeName);
  }

  _showActions(
      BuildContext context, WeightList weightList, Weight weight) async {
    switch (await showDialog<_WeightAction>(
      context: context,
      builder: (BuildContext context) => SimpleDialog(
            title: const Text('Action'),
            children: <Widget>[
              SimpleDialogOption(
                onPressed: () => Navigator.pop(context, _WeightAction.Edit),
                child: const Text('Edit'),
              ),
              SimpleDialogOption(
                onPressed: () => Navigator.pop(context, _WeightAction.Delete),
                child: const Text('Delete'),
              ),
            ],
          ),
    )) {
      case _WeightAction.Edit:
        Navigator.pushNamed(context, EditWeightScreen.routeName,
            arguments: weight);
        // TODO: Don't show this snackboard on navigate back
        Scaffold.of(context)
            .showSnackBar(SnackBar(content: Text('Weight Saved')));
        break;
      case _WeightAction.Delete:
        await weightList.delete(weight);
        // TODO: Don't show this snackboard on navigate back
        Scaffold.of(context)
            .showSnackBar(SnackBar(content: Text('Weight Deleted')));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WeightList>(builder: (context, weightList, child) {
      var sortedWeights = weightList.list.toList()
        ..sort((a, b) => b.time.compareTo(a.time));
      var weightRows = sortedWeights
          .map((weight) => InkWell(
                onTap: () => _showActions(context, weightList, weight),
                child: _WeightRow(weight: weight),
              ))
          .toList();
      var body;
      if (weightRows.length == 0) {
        body = Text("No data");
      } else {
        body = ListView.separated(
          itemBuilder: (context, index) => weightRows[index],
          itemCount: weightRows.length,
          separatorBuilder: (BuildContext context, int index) =>
              const Divider(),
        );
      }
      return Scaffold(
        body: body,
        floatingActionButton: FloatingActionButton(
          onPressed: () => _onCreateWeightPressed(context),
          tooltip: 'Add Weight',
          child: Icon(Icons.add),
        ),
      );
    });
  }
}

enum _WeightAction {
  Delete,
  Edit,
}

class _WeightRow extends StatelessWidget {
  final Weight weight;

  _WeightRow({Key key, this.weight}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(
          child:
              Text(DateFormat.yMMMEd().add_jm().format(weight.time.toLocal()))),
      Text('${weight.weight}'),
    ]);
  }
}

class AddWeightScreen extends StatelessWidget {
  static const routeName = '/weight/add';

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now().toUtc();
    return Scaffold(
      appBar: AppBar(
        title: Text('Add weight'),
      ),
      body: _WeightForm(Weight(
          time: DateTime(
        now.year,
        now.month,
        now.day,
        now.hour,
        now.minute,
      ))),
    );
  }
}

class EditWeightScreen extends StatelessWidget {
  static const routeName = '/weight/edit';

  @override
  Widget build(BuildContext context) {
    final Weight weight = ModalRoute.of(context).settings.arguments;

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit weight'),
      ),
      body: _WeightForm(weight),
    );
  }
}

class _WeightForm extends StatefulWidget {
  final Weight initialValue;

  _WeightForm(this.initialValue);

  @override
  _WeightFormState createState() => _WeightFormState();
}

class _WeightFormState extends State<_WeightForm> {
  TextEditingController _weightController;
  DateTime _selectedTime;
  bool _saveEnabled = false;

  @override
  initState() {
    _weightController =
        TextEditingController(text: widget.initialValue.weight?.toString());
    _saveEnabled = !_weightController.text.isEmpty;
    _selectedTime = widget.initialValue.time;
  }

  _submitForm(context, weightList) async {
    if (widget.initialValue.id == null) {
      await weightList.add(Weight(
        weight: double.parse(_weightController.text),
        time: _selectedTime,
      ));
    } else {
      await weightList.update(Weight(
        id: widget.initialValue.id,
        weight: double.parse(_weightController.text),
        time: _selectedTime,
      ));
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        TextField(
          controller: _weightController,
          decoration: const InputDecoration(
            hintText: 'Weight',
          ),
          inputFormatters: [PositiveDecimalTextInputFormatter(decimalRange: 2)],
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          onChanged: (value) => setState(() => _saveEnabled = !value.isEmpty),
        ),
        DateTimePicker(
          selectedDate: _selectedTime,
          selectedTime: TimeOfDay.fromDateTime(_selectedTime),
          selectDate: (date) {
            setState(() {
              _selectedTime = DateTime(
                date.year,
                date.month,
                date.day,
                _selectedTime.hour,
                _selectedTime.minute,
              );
            });
          },
          selectTime: (time) {
            setState(() {
              _selectedTime = DateTime(
                _selectedTime.year,
                _selectedTime.month,
                _selectedTime.day,
                time.hour,
                time.minute,
              );
            });
          },
        ),
        Consumer<WeightList>(
            builder: (context, weightList, child) => RaisedButton(
                  onPressed: _saveEnabled
                      ? () => _submitForm(context, weightList)
                      : null,
                  child: Text('Save'),
                )),
      ],
    );
  }
}
