import 'package:flutter/material.dart';


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
    this.showLabel = true,      // NEW: show/hide the label above the slider
    this.decimalPlaces = 1,     // NEW: control value formatting (e.g., minutes = 0)
  });
// NEW
  final bool showLabel;
  final int decimalPlaces;

  String _formatValue(double v) {
    if (decimalPlaces <= 0) {
      return v.round().toString();
    }
    return v.toStringAsFixed(decimalPlaces);
  }
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