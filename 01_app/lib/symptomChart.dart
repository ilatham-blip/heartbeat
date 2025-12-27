import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class symptomChart extends StatelessWidget{
  final List vals;

  const symptomChart(this.vals, {Key? key})
    : super(key: key);
  
 @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 3,
      child: LineChart(
        LineChartData(
            lineBarsData: [
              LineChartBarData(
                spots: [
                  for(var (index, val) in vals.indexed)
                    FlSpot(index.toDouble(), val),
                ],
                isCurved: false,
              ),
            ],
          ),
      ),
    );
  }
}