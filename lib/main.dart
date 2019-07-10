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
import 'utils/input_formatters.dart';

final String appTitle = 'TDEE Tracker';

void main() => runApp(MultiProvider(
      providers: [
        ChangeNotifierProvider(builder: (context) => Settings()),
        ChangeNotifierProvider(builder: (context) => Entries()),
        ChangeNotifierProvider(builder: (context) => Weights()),
        ChangeNotifierProvider(builder: (context) => Goals()),
      ],
      child: TDEETrackerApp(),
    ));

class TDEETrackerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appTitle,
      routes: <String, WidgetBuilder>{
        Navigator.defaultRouteName: (context) => Root(),
        SettingsScreen.routeName: (context) => SettingsScreen(),
        AddEntryScreen.routeName: (context) => AddEntryScreen(),
        EditEntryScreen.routeName: (context) => EditEntryScreen(),
        AddWeightScreen.routeName: (context) => AddWeightScreen(),
        EditWeightScreen.routeName: (context) => EditWeightScreen(),
      },
    );
  }
}

class Root extends StatefulWidget {
  @override
  _RootState createState() => _RootState();
}

class _RootState extends State<Root> {
  Settings _settings;

  _setInitialTdee(int initialTdee) async {
    await _settings.setInitialTdee(initialTdee);
    setState((){});
  }

  @override
  initState() {
    Settings.initialize().then((settings) {
      setState(() => _settings = settings);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_settings == null) {
      return _LoadingScreen();
    } else if (_settings.initialTdee == null) {
      return _FirstRunScreen(onSubmit: _setInitialTdee);
    } else {
      return HomeScreen();
    }
  }
}

class _LoadingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Loading...')),
      body: const Text('Fetching settings'),
    );
  }
}

class _FirstRunScreen extends StatefulWidget {
  final onSubmit;

  _FirstRunScreen({Key key, this.onSubmit}) : super(key: key);

  @override
  _FirstRunScreenState createState() => _FirstRunScreenState();
}

class _FirstRunScreenState extends State<_FirstRunScreen> {
  TextEditingController _tdeeController = TextEditingController();
  bool _saveEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Enter TDEE')),
        body: Column(children: <Widget>[
          TextField(
            controller: _tdeeController,
            decoration: const InputDecoration(
              hintText: 'Best estimate of current TDEE',
            ),
            keyboardType:
                TextInputType.numberWithOptions(decimal: false, signed: false),
            onChanged: (value) => setState(() => _saveEnabled = !value.isEmpty),
          ),
          RaisedButton(
            onPressed: _saveEnabled
            ? () => widget.onSubmit(int.parse(_tdeeController.text))
            : null,
            child: const Text('Save'),
          ),
        ]));
  }
}
