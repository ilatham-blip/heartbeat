import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CustomSlider extends StatefulWidget{
  final String text;
  final variable;

  const CustomSlider({super.key, required this.text, required this.variable});

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
          value: widget.variable,
          label: widget.variable.toString(),
          max: 3,
          divisions: 3,
          onChanged: (double value) {
            ();
          },
        ),
      ],
    );
  }
}