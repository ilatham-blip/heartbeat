import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class GeneralPlot extends StatelessWidget {
  final double height;
  final double width;
  final int timeint;
  final String ylabel;
  final String xlabel;
  final List<num> vals;

  const GeneralPlot({
    super.key,
    required this.width,
    required this.height,
    required this.vals,
    required this.ylabel,
    required this.xlabel,
    required this.timeint,
  });
 
  @override
  Widget build(BuildContext context) {
    if (vals.isEmpty) {
      return SizedBox(
        width: width,
        height: height,
        child: const Center(child: Text('No data')),
      );
    } else {
      return SizedBox(
        width: width,
        height: height,
        child: LineChart(LineChartData(
          titlesData: FlTitlesData(
            show: true,
            topTitles: AxisTitles(axisNameWidget: Text("")),
            rightTitles: AxisTitles(axisNameWidget: Text("")),
            bottomTitles: AxisTitles(axisNameWidget: Text(xlabel), sideTitles: SideTitles(showTitles: true, reservedSize: 30.0), axisNameSize: 30.0),
            leftTitles: AxisTitles(axisNameWidget: Text(ylabel), sideTitles: SideTitles(showTitles: true, reservedSize: 30.0), axisNameSize: 30.0)
          ),
          gridData: FlGridData(show: true),
          borderData: FlBorderData(show: true),
          lineBarsData: [
            LineChartBarData(
              spots: [
                for(var (index, val) in vals.indexed)
                  FlSpot(index.toDouble()*timeint, val.toDouble()),
              ],
              isCurved: true,
              barWidth: 4,
              color: Colors.blue,
            ),
          ],
        )
      ),
    );
  }}
}
class GeneralBarChart extends StatelessWidget {
  final List<double> vals;
  final List<String> labels;
  final double width;
  final double height;

  const GeneralBarChart({
    super.key,
    required this.vals,
    required this.labels,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    if (vals.isEmpty || labels.isEmpty) {
      return SizedBox(
        width: width,
        height: height,
        child: const Center(child: Text('No data')),
      );
    }

    // create bars from vals and labels
    final List<BarChartGroupData> barGroups = [];
    final colors = [Colors.orange, Colors.purple, Colors.blue];
    for (int i = 0; i < vals.length && i < labels.length; i++) {
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: vals[i],
              color: i < colors.length ? colors[i] : Colors.grey,
              width: 30,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      width: width,
      height: height,
      child: BarChart(
        BarChartData(
          maxY: 10,
          minY: 0,
          barGroups: barGroups,
          titlesData: FlTitlesData(
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx >= 0 && idx < labels.length) {
                    return Text(labels[idx], style: const TextStyle(fontSize: 12));
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 2,
                reservedSize: 40,
              ),
            ),
          ),
          gridData: FlGridData(
            show: true,
            horizontalInterval: 2,
            drawHorizontalLine: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey.withOpacity(0.3),
                strokeWidth: 0.8,
              );
            },
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: Colors.black, width: 1),
          ),
        ),
      ),
    );
  }
}

class MultiSymptomPlot extends StatelessWidget {
  final List<MapEntry<DateTime, double>> dizziness;
  final List<MapEntry<DateTime, double>> fatigue;
  final List<MapEntry<DateTime, double>> hydration;
  final String timeRange;
  final double width;
  final double height;

  const MultiSymptomPlot({
    super.key,
    required this.dizziness,
    required this.fatigue,
    required this.hydration,
    required this.timeRange,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    final List<LineChartBarData> lines = [];

    LineChartBarData makeLine(List<MapEntry<DateTime, double>> vals, Color color) {
      return LineChartBarData(
        spots: [for (var p in vals) FlSpot(p.key.millisecondsSinceEpoch.toDouble(), p.value)],
        isCurved: false,
        preventCurveOverShooting: true,
        color: color,
        barWidth: 3,
        dotData: FlDotData(show: true),
      );
    }

    if (dizziness.isNotEmpty) {
      lines.add(makeLine(dizziness, Colors.purple));
    }
    if (fatigue.isNotEmpty) {
      lines.add(makeLine(fatigue, Colors.orange));
    }
    if (hydration.isNotEmpty) {
      lines.add(makeLine(hydration, Colors.blue));
    }

    if (lines.isEmpty) {
      return SizedBox(
        width: width,
        height: height,
        child: const Center(child: Text('No data')),
      );
    }

    final now = DateTime.now().millisecondsSinceEpoch.toDouble();
    double minX = now;
    if (timeRange == 'Day') {
      minX = now - (24 * 60 * 60 * 1000);
    } else if (timeRange == 'Week') {
      minX = now - (7 * 24 * 60 * 60 * 1000);
    } else if (timeRange == 'Month') {
      minX = now - (30 * 24 * 60 * 60 * 1000);
    }
    double maxX = now;

    // Add padding to prevent points and edge labels from overlapping the axis
    final range = maxX - minX;
    minX -= range * 0.10;
    maxX += range * 0.10;

    return SizedBox(
      width: width,
      height: height,
      child: LineChart(
        LineChartData(
          minX: minX,
          maxX: maxX,
          minY: 0,
          maxY: 10,
          gridData: FlGridData(show: true),
          borderData: FlBorderData(show: true),
          titlesData: FlTitlesData(
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              axisNameWidget: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(timeRange == 'Day' ? 'Time of Day' : 'Time (Date)', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
              ),
              axisNameSize: 24,
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  if (value == meta.min || value == meta.max) {
                    return const SizedBox.shrink();
                  }
                  final dt = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                  final String label = timeRange == 'Day' 
                      ? '${dt.hour}:${dt.minute.toString().padLeft(2, '0')}' 
                      : '${dt.month}/${dt.day}';
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(label, style: const TextStyle(fontSize: 10)),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              axisNameWidget: const Text('Severity', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
              axisNameSize: 20,
              sideTitles: SideTitles(
                showTitles: true,
                interval: 2,
                reservedSize: 30,
              ),
            ),
          ),
          lineBarsData: lines,
        ),
      ),
    );
  }
}
