import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'settings.dart';

class SettingsScreen extends StatelessWidget {
  static const routeName = '/settings';

  @override
  Widget build(BuildContext context) {
    return Consumer<Settings>(builder: (context, settings, child) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('TDEE Tracker Settings'),
        ),
        body: Column(
          children: <Widget>[
            Center(
              child: DropdownButton<WeightUnits>(
                value: settings.units,
                onChanged: settings.setUnits,
                items: WeightUnits.values.map((WeightUnits value) {
                  return DropdownMenuItem<WeightUnits>(
                    value: value,
                    child: Text(WeightUnitsHelper.unitName(value)),
                  );
                }).toList(),
              ),
            ),
            Slider(
                value: settings.goal.toDouble(),
                onChanged: (value) => settings.setGoal(value.round()),
                min: -1000,
                max: 1000,
                divisions: 200,
                label: settings.goal.toString(),
            ),
          ],
        ),
      );
    });
  }
}
