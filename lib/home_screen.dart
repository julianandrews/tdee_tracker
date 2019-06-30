import 'package:flutter/material.dart';

import 'calorie_screens.dart';
import 'entry_list.dart';
import 'settings_screen.dart';
import 'weight_list.dart';
import 'weight_screens.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
          appBar: AppBar(
            title: const Text('TDEE Tracker'),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.settings),
                onPressed: () =>
                    Navigator.pushNamed(context, SettingsScreen.routeName),
              ),
            ],
            bottom: TabBar(
              isScrollable: false,
              tabs: [
                Tab(text: 'Calorie Tracker'),
                Tab(text: 'Weight Tracker'),
              ],
            ),
          ),
          body: TabBarView(
            physics: NeverScrollableScrollPhysics(),
            children: [
              CalorieTracker(),
              WeightTracker(),
            ],
          )),
    );
  }
}
