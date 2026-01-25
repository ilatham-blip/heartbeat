import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:heartbeat/app_state.dart';
import 'package:heartbeat/widgets/custom_slider.dart';

class EpisodeQuiz extends StatelessWidget{
  List symptoms = ["Dizziness when standing", "Heart racing and palpitations", "Chest pain", "Headache", "Difficulty concentrating","Muscle pain", "Difficulty breathing"];

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<MyAppState>(context, listen: true);
    double dummy = 0;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        for(var val in symptoms)
          CustomSlider(text: val, variable: dummy)

      ]
    );
  }
}