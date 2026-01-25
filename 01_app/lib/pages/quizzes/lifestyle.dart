import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:heartbeat/app_state.dart';
import 'package:heartbeat/widgets/chart.dart';
import 'package:heartbeat/widgets/custom_slider.dart';

class LifestyleQuiz extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<MyAppState>(context);

    return ListView(
      padding: EdgeInsets.all(16),
      children: [

        // Minutes standing, 0->240
        CustomSlider(
          text: "standing_mins",
          value: appState.lifestyleScores["standing_mins"]!,
          max: 240,
          divisions: 24,
          onChanged: (v) => appState.updateLifestyleScores("standing_mins", v),
        ),

        // Large Range Slider for Carbs, 0->400 Grams
        CustomSlider(
          text: "Carbohydrates (grams)",
          value: appState.lifestyleScores["carbs_grams"]!,
          max: 500,
          divisions: 50,
          onChanged: (v) => appState.updateLifestyleScores("carbs_grams", v),
        ),

        // Water Intake, 0->5 Liters
        CustomSlider(
          text: "Water (Litres)",
          value: appState.lifestyleScores["water_litres"]!,
          max: 5,
          divisions: 10, // Allows 0.5L increments
          onChanged: (v) => appState.updateLifestyleScores("water_litres", v),
        ),

        // Alcohol Unit intake, 0->15 units
        CustomSlider(
          text: "Alcohol Units",
          value: appState.lifestyleScores["alcohol_units"]!,
          max: 15,
          divisions: 15, // Allows 0.5L increments
          onChanged: (v) => appState.updateLifestyleScores("alcohol_units", v),
        ),


        // Exercises Mins, 0->180 min
        CustomSlider(
          text: "Exercise Mins",
          value: appState.lifestyleScores["exercise_mild"]!,
          max: 180,
          divisions: 12, // Allows 0.5L increments
          onChanged: (v) => appState.updateLifestyleScores("exercise_mild", v),
        ),

        // 0-3 Scale Slider for Stress
        CustomSlider(
          text: "Stress Level (0-3)",
          value: appState.lifestyleScores["stress_level"]!,
          max: 3,
          divisions: 3,
          onChanged: (v) => appState.updateLifestyleScores("stress_level", v),
        ),


      ],
    );
  }
}
