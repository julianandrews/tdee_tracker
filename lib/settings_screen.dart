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
            SwitchListTile(
              title: Text('Use Pounds'),
              value: settings.units == WeightUnits.Pounds,
              onChanged: (value) {
                settings.setUnits(
                    value ? WeightUnits.Pounds : WeightUnits.Kilograms);
              },
            ),
          ],
        ),
      );
    });
  }
}
