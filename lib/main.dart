import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'home_screen.dart';
import 'calorie_screens.dart';
import 'settings.dart';
import 'settings_screen.dart';
import 'weight_screens.dart';
import 'database/entry_list.dart';
import 'database/weight_list.dart';

void main() => runApp(ChangeNotifierProvider(
    builder: (context) => Settings(),
    child: ChangeNotifierProvider(
        builder: (context) => EntryList(),
        child: ChangeNotifierProvider(
            builder: (context) => WeightList(), child: TDEETrackerApp()))));

class TDEETrackerApp extends StatefulWidget {
  @override
  _TDEETrackerAppState createState() => _TDEETrackerAppState();
}

class _TDEETrackerAppState extends State<TDEETrackerApp> {
  Settings _settings;

  @override
  initState() {
    Settings.initialize().then((settings) {
      setState(() => _settings = settings);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_settings == null) {
      return PlaceholderApp();
    }
    return MaterialApp(
      title: 'TDEE Tracker',
      routes: <String, WidgetBuilder>{
        Navigator.defaultRouteName: (context) => HomeScreen(),
        SettingsScreen.routeName: (context) => SettingsScreen(),
        AddEntryScreen.routeName: (context) => AddEntryScreen(),
        EditEntryScreen.routeName: (context) => EditEntryScreen(),
        AddWeightScreen.routeName: (context) =>
            AddWeightScreen(units: _settings.units),
        EditWeightScreen.routeName: (context) =>
            EditWeightScreen(units: _settings.units),
      },
    );
  }
}

class PlaceholderApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TDEE Tracker',
      home: Scaffold(
        body: const Text('Fetching settings'),
      ),
    );
  }
}
