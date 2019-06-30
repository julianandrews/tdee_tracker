import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

import 'date_time_picker.dart';
import 'models.dart';
import 'weight_list.dart';

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
  final Weight weight;

  _WeightForm(this.weight);

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
        TextEditingController(text: widget.weight.weight?.toString());
    _saveEnabled = !_weightController.text.isEmpty;
    _selectedTime = widget.weight.time;
  }

  _submitForm(context, weightList) async {
    if (widget.weight.id == null) {
      await weightList.add(Weight(
        weight: double.parse(_weightController.text),
        time: _selectedTime,
      ));
    } else {
      await weightList.update(Weight(
        id: widget.weight.id,
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

class PositiveDecimalTextInputFormatter extends TextInputFormatter {
  PositiveDecimalTextInputFormatter({decimalRange})
      : assert(decimalRange != null && decimalRange > 0),
        pattern = RegExp('^\\d*\\.?\\d{0,${decimalRange}}\$');

  final RegExp pattern;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue, // unused.
    TextEditingValue newValue,
  ) {
    TextSelection newSelection = newValue.selection;
    String truncated = newValue.text;

    String value = newValue.text;

    if (!pattern.hasMatch(value)) {
      truncated = oldValue.text;
      newSelection = oldValue.selection;
    } else if (value == ".") {
      truncated = "0.";

      newSelection = newValue.selection.copyWith(
        baseOffset: math.min(truncated.length, truncated.length + 1),
        extentOffset: math.min(truncated.length, truncated.length + 1),
      );
    }

    return TextEditingValue(
      text: truncated,
      selection: newSelection,
      composing: TextRange.empty,
    );
    return newValue;
  }
}
