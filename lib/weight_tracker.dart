import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'weight_form.dart';
import 'weight_list.dart';
import 'models.dart';

class WeightTracker extends StatelessWidget {
  _onCreateWeightPressed(context) {
    Navigator.pushNamed(context, AddWeightScreen.routeName);
  }

  _showActions(
      BuildContext context, WeightList weightList, Weight weight) async {
    switch (await showDialog<WeightAction>(
      context: context,
      builder: (BuildContext context) => SimpleDialog(
            title: const Text('Action'),
            children: <Widget>[
              SimpleDialogOption(
                onPressed: () => Navigator.pop(context, WeightAction.Edit),
                child: const Text('Edit'),
              ),
              SimpleDialogOption(
                onPressed: () => Navigator.pop(context, WeightAction.Delete),
                child: const Text('Delete'),
              ),
            ],
          ),
    )) {
      case WeightAction.Edit:
        Navigator.pushNamed(context, EditWeightScreen.routeName,
            arguments: weight);
        Scaffold.of(context)
            .showSnackBar(SnackBar(content: Text('Weight Saved')));
        break;
      case WeightAction.Delete:
        await weightList.delete(weight);
        Scaffold.of(context)
            .showSnackBar(SnackBar(content: Text('Weight Deleted')));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WeightList>(builder: (context, weightList, child) {
      var sortedWeights = weightList.list.toList()
        ..sort((a, b) => b.time.compareTo(a.time));
      var weightRows = sortedWeights
          .map((weight) => InkWell(
                onTap: () => _showActions(context, weightList, weight),
                child: _WeightRow(weight: weight),
              ))
          .toList();
      var body;
      if (weightRows.length == 0) {
        body = Text("No data");
      } else {
        body = ListView.separated(
          itemBuilder: (context, index) => weightRows[index],
          itemCount: weightRows.length,
          separatorBuilder: (BuildContext context, int index) =>
              const Divider(),
        );
      }
      return Scaffold(
        body: body,
        floatingActionButton: FloatingActionButton(
          onPressed: () => _onCreateWeightPressed(context),
          tooltip: 'Add Weight',
          child: Icon(Icons.add),
        ),
      );
    });
  }
}

enum WeightAction {
  Delete,
  Edit,
}

class _WeightRow extends StatelessWidget {
  final Weight weight;

  _WeightRow({Key key, this.weight}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(
          child:
              Text(DateFormat.yMMMEd().add_jm().format(weight.time.toLocal()))),
      Text('${weight.weight}'),
    ]);
  }
}
