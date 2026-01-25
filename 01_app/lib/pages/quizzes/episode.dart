import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:heartbeat/app_state.dart';
import 'package:heartbeat/widgets/custom_slider.dart';

class EpisodeQuiz extends StatelessWidget {
  List symptoms = [
    "Dizziness when standing",
    "Heart racing and palpitations",
    "Chest pain",
    "Headache",
    "Difficulty concentrating",
    "Muscle pain",
    "Difficulty breathing",
  ];

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
            value: appState.episodeScores[symptom] ?? 0.0,
            // Send the new value to Provider
            onChanged: (newValue) {
              appState.updateEpisodeScore(symptom, newValue);
            },
          ),
      ],
    );
  }
}
