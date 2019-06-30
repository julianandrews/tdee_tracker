import 'package:flutter/material.dart';

import 'settings.dart';

class SettingsScreen extends StatelessWidget {
  static const routeName = '/settings';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: const Text('TDEE Tracker Settings'),
        ),
        body: Text("Foo"),
    );
  }
}
