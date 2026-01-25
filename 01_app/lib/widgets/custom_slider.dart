import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class CustomSlider extends StatelessWidget {
  final String text;
  final double value;
  final double max;
  final int divisions;
  final ValueChanged<double> onChanged;

  const CustomSlider({
    super.key,
    required this.text,
    required this.value,
    this.max = 3.0,
    this.divisions = 3,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Text("$text: ${value.toStringAsFixed(1)}"),
        ),
        Slider(
          value: value,
          max: max,
          divisions: divisions,
          label: value.toString(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}