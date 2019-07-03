import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'settings.dart';
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
        // TODO: Don't show this snackbar on navigate back
        Scaffold.of(context)
            .showSnackBar(SnackBar(content: Text('Weight Saved')));
        break;
      case _WeightAction.Delete:
        await weightList.delete(weight);
        // TODO: Don't show this snackbar on navigate back
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
    return Consumer<Settings>(builder: (context, settings, child) {
      String formattedDate =
          DateFormat("E, M/d/y").add_jm().format(weight.time.toLocal());
      String unitName = WeightUnitsHelper.unitNameShort(settings.units);
      double convertedWeight =
          WeightUnitsHelper.weightInUnits(weight, settings.units);
      return Row(children: [
        Expanded(child: Text(formattedDate)),
        Text("${convertedWeight} ${unitName}"),
      ]);
    });
  }
}

class AddWeightScreen extends StatelessWidget {
  static const routeName = '/weight/add';

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now().toUtc();
    final Weight initialValue = Weight(
        time: DateTime(now.year, now.month, now.day, now.hour, now.minute));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add weight'),
      ),
      body: Consumer<Settings>(builder: (context, settings, child) {
        return _WeightForm(initialValue: initialValue, units: settings.units);
      }),
    );
  }
}

class EditWeightScreen extends StatelessWidget {
  static const routeName = '/weight/edit';

  @override
  Widget build(BuildContext context) {
    final Weight initialValue = ModalRoute.of(context).settings.arguments;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit weight'),
      ),
      body: Consumer<Settings>(builder: (context, settings, child) {
        return _WeightForm(initialValue: initialValue, units: settings.units);
      }),
    );
  }
}

class _WeightForm extends StatefulWidget {
  final Weight initialValue;
  final WeightUnits units;

  _WeightForm({this.initialValue, this.units});

  @override
  _WeightFormState createState() => _WeightFormState();
}

class _WeightFormState extends State<_WeightForm> {
  TextEditingController _weightController;
  DateTime _selectedTime;
  bool _saveEnabled = false;

  @override
  initState() {
    var weight = widget.initialValue.weight == null
        ? null
        : WeightUnitsHelper.weightInUnits(widget.initialValue, widget.units);
    _weightController = TextEditingController(text: weight?.toString());
    _saveEnabled = !_weightController.text.isEmpty;
    _selectedTime = widget.initialValue.time;
  }

  _submitForm(context, weightList) async {
    var weight = WeightUnitsHelper.kilosFromUnits(
        double.parse(_weightController.text), widget.units);
    if (widget.initialValue.id == null) {
      await weightList.add(Weight(
        weight: weight,
        time: _selectedTime,
      ));
    } else {
      await weightList.update(Weight(
        id: widget.initialValue.id,
        weight: weight,
        time: _selectedTime,
      ));
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Replace the text input for weight with a spinner like the gFit app.
    int decimalRange = widget.units == WeightUnits.Pounds ? 1 : 2;
    return Column(
      children: <Widget>[
        TextField(
          controller: _weightController,
          decoration: InputDecoration(
            hintText:
                'Weight (${WeightUnitsHelper.unitNameShort(widget.units)})',
          ),
          inputFormatters: [
            PositiveDecimalTextInputFormatter(decimalRange: decimalRange)
          ],
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
