import 'package:flutter/material.dart';
import 'package:heartbeat/app_state.dart';
import 'package:provider/provider.dart';

class SymptomPage extends StatefulWidget {
  const SymptomPage({super.key});

  @override
  State<SymptomPage> createState() => _SymptomPage();
}

class _SymptomPage extends State<SymptomPage> {
  double _dizziness = 0.0;
  double _nausea = 0.0;

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<MyAppState>(context, listen: true);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Slider(
          value: _dizziness,
          label: _dizziness.toString(),
          max: 7,
          divisions: 7,
          onChanged: (double value) {
            setState(() {
              _dizziness = value;
            });
          },
        ),
        Text("Dizziness intensity"),
        SizedBox(height: 10),
        Slider(
          value: _nausea,
          label: _nausea.toString(),
          max: 7,
          divisions: 7,
          onChanged: (double value) {
            setState(() {
              _nausea = value;
            });
          },
        ),
        Text("Nausea intensity"),
        SizedBox(height: 10),
        ElevatedButton(
          onPressed: () {
              appState.add(appState.nausea, _nausea);
              appState.add(appState.dizziness, _dizziness);
          },
          child: Text("Record symptoms"),
        ),
      ],
    );
  }
}
