import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:heartbeat/app_state.dart';
import 'package:heartbeat/widgets/custom_slider.dart';

class EveningQuiz extends StatelessWidget{
  List symptoms = ["Fatigue"];

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<MyAppState>(context, listen: true);

    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        for (var symptom in symptoms)
          CustomSlider(
            text: symptom,

            value: appState.eveningScores[symptom] ?? 0.0,
            // Send the new value to Provider
            onChanged: (newValue) {
              appState.updateEveningScore(symptom, newValue);
            },
          ),
      ],
    );
  }
}