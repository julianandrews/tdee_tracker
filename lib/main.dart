import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'home_screen.dart';
import 'calorie_screens.dart';
import 'settings.dart';
import 'settings_screen.dart';
import 'weight_screens.dart';
import 'database/entries.dart';
import 'database/goals.dart';
import 'database/weights.dart';

void main() => runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(builder: (context) => Settings()),
        ChangeNotifierProvider(builder: (context) => Entries()),
        ChangeNotifierProvider(builder: (context) => Weights()),
        ChangeNotifierProvider(builder: (context) => Goals()),
      ],
      child: TDEETrackerApp(),
    )
  );

class TDEETrackerApp extends StatefulWidget {
  @override
  _TDEETrackerAppState createState() => _TDEETrackerAppState();
}

class _TDEETrackerAppState extends State<TDEETrackerApp> {
  bool _initialized = false;

  @override
  initState() {
    Settings.initialize().then((settings) {
      setState(() => _initialized = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return PlaceholderApp();
    }
    return MaterialApp(
      title: 'TDEE Tracker',
      routes: <String, WidgetBuilder>{
        Navigator.defaultRouteName: (context) => HomeScreen(),
        SettingsScreen.routeName: (context) => SettingsScreen(),
        AddEntryScreen.routeName: (context) => AddEntryScreen(),
        EditEntryScreen.routeName: (context) => EditEntryScreen(),
        AddWeightScreen.routeName: (context) => AddWeightScreen(),
        EditWeightScreen.routeName: (context) => EditWeightScreen(),
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
