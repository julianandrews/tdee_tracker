import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'calorie_tracker.dart';
import 'entry_list.dart';

void main() => runApp(
    ChangeNotifierProvider(builder: (context) => EntryList(), child: MyApp()));

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'TDEE Tracker',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: CalorieTracker());
  }
}
