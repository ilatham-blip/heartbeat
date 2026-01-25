import 'package:flutter/material.dart';
import 'package:heartbeat/widgets/custom_slider.dart';
import 'package:provider/provider.dart';
import 'package:heartbeat/app_state.dart';

class MorningQuiz extends StatelessWidget{

  List symptoms = ["Sleep Quality", "Fatigue", "Dizziness when standing", "Heart racing and palpitations"];

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