import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CustomSlider extends StatefulWidget{
  final String text;
  final double value;
  final ValueChanged<double> onChanged;

  const CustomSlider({
    super.key, 
    required this.text, 
    required this.value, 
    required this.onChanged,
  });

  @override
  State<CustomSlider> createState() => _CustomSlider();
}

class _CustomSlider extends State<CustomSlider>{

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(widget.text),
        Slider(
          value: widget.value,
          label: widget.value.round().toString(),
          max: 3,
          divisions: 3,
          onChanged: widget.onChanged,
        ),
      ],
    );
  }
}