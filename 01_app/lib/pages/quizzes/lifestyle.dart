import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:heartbeat/app_state.dart';
import 'package:heartbeat/widgets/chart.dart';

class LifestyleQuiz extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<MyAppState>(context, listen: true);
    
    return Column(
      children: [
        Text("Lifestyle"),
      ]
    );
  }
}