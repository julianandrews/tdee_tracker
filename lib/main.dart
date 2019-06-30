import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'home_screen.dart';
import 'entry_form.dart';
import 'entry_list.dart';
import 'settings_screen.dart';
import 'weight_form.dart';
import 'weight_list.dart';

void main() => runApp(ChangeNotifierProvider(
    builder: (context) => EntryList(),
    child: ChangeNotifierProvider(
        builder: (context) => WeightList(), child: MyApp())));

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
