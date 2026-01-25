import 'package:flutter/material.dart';
import 'package:heartbeat/widgets/custom_slider.dart';
import 'package:provider/provider.dart';
import 'package:heartbeat/app_state.dart';

class MorningQuiz extends StatelessWidget{

  List symptoms = ["Sleep Quality", "Fatigue", "Dizziness when standing", "Heart racing and palpitations"];

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<MyAppState>(context, listen: true);

    return ListView(
      padding: EdgeInsets.all(16),
      
      children: [
        
        for (var symptom in symptoms)
        
          CustomSlider(
            text: symptom,
            // Get the current value from Provider
            value: appState.morningScores[symptom] ?? 0.0,
            // Send the new value to Provider
            onChanged: (newValue) {
              appState.updateMorningScore(symptom, newValue);
            },
          ),
      ],
    );
  }
}