import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'calorie_tracker.dart';
import 'entry_list.dart';
import 'weight_list.dart';
import 'weight_tracker.dart';

void main() => runApp(
    ChangeNotifierProvider(builder: (context) => EntryList(),
        child: ChangeNotifierProvider(
            builder: (context) => WeightList(),
            child: MyApp())));

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'TDEE Tracker',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('TDEE Tracker'),
              bottom: TabBar(
                isScrollable: false,
                tabs: [
                  Tab(text: 'Calorie Tracker'),
                  Tab(text: 'Weighings'),
                ],
              ),
            ),
            body: TabBarView(
              physics: NeverScrollableScrollPhysics(),
              children: [
                CalorieTracker(),
                WeightTracker(),
              ],
            ),
          ),
        ));
  }
}
