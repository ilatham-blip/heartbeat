import 'package:flutter/material.dart';
import 'package:heartbeat/app_state.dart';
import 'package:heartbeat/widgets/chart.dart';
import 'package:provider/provider.dart';

class TrackerPage extends StatefulWidget {
  const TrackerPage({super.key});

  @override
  State<TrackerPage> createState() => _TrackerPage();
}

class _TrackerPage extends State<TrackerPage> {
  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<MyAppState>(context, listen: true);
        
      return LayoutBuilder(
          builder: (context, constraints) {
            return Column(children: [
              Text("Dizziness:"),
              GeneralPlot(
                width: constraints.maxWidth*0.9,
                height: constraints.maxHeight/3,
                vals: appState.dizziness,
                xlabel: "",
                ylabel: "",
                timeint: 1,
              ),
              Text("Nausea:"),
              GeneralPlot(
                width: constraints.maxWidth*0.9,
                height: constraints.maxHeight/3,
                vals: appState.nausea,
                xlabel: "",
                ylabel: "",
                timeint: 1,
              )
            ],)
            ;
          },
        );
  }
}