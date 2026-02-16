import 'package:flutter/material.dart';
import 'package:heartbeat/app_theme.dart';
import 'package:heartbeat/app_state.dart';
import 'package:heartbeat/widgets/chart.dart'; // where GeneralPlot / bar chart live
import 'package:provider/provider.dart';

class TrackerPage extends StatefulWidget {
  const TrackerPage({super.key});

  @override
  State<TrackerPage> createState() => _TrackerPage();
}

class _TrackerPage extends State<TrackerPage> {
  bool _showDizziness = true;
  bool _showFatigue = true;
  bool _showHydration = true;
  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<MyAppState>(context, listen: true);
    // helper to compute trend direction from a numeric series
    Map<String, dynamic> computeTrend(List<double> series) {
      if (series.isEmpty) {
        return {
          'text': 'No data',
          'icon': Icons.remove,
          'color': Colors.grey,
        };
      }

      // use last 3 vs previous 3 where possible
      int n = series.length;
      double recentAvg;
      double prevAvg;
      if (n < 2) {
        recentAvg = series.last;
        prevAvg = series.first;
      } else if (n < 4) {
        recentAvg = series.sublist(n - 1).reduce((a, b) => a + b) / (n - (n - 1));
        prevAvg = series.sublist(0, n - 1).reduce((a, b) => a + b) / (n - 1);
      } else {
        final recentSlice = series.sublist(n - 3, n);
        final prevSlice = series.sublist(n - 6, n - 3);
        recentAvg = recentSlice.reduce((a, b) => a + b) / recentSlice.length;
        prevAvg = prevSlice.reduce((a, b) => a + b) / prevSlice.length;
      }

      final diff = recentAvg - prevAvg;
      if (diff.abs() < 0.5) {
        return {'text': 'Stable', 'icon': Icons.trending_flat, 'color': Colors.blue};
      } else if (diff > 0) {
        return {'text': 'Increasing trend', 'icon': Icons.trending_up, 'color': Colors.red};
      } else {
        return {'text': 'Decreasing trend', 'icon': Icons.trending_down, 'color': Colors.green};
      }
    }

    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: kBrandBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Health Insights',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth * 0.9;
          final height = constraints.maxHeight;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  

                  // Vital Measurements
                  _SectionCard(
                    width: width,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Vital Measurements',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'No vital measurements recorded yet.',
                          style: TextStyle(color: Colors.black54),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Health Insights alert
                  _SectionCard(
                    width: width,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Health Insights',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF3E0),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Icon(Icons.error_outline,
                                  color: Colors.orange),
                              SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Frequent Dizziness',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'You\'re experiencing elevated dizziness levels. Please discuss this with your doctor.',
                                      style: TextStyle(
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Symptom trends cards (Fatigue, Dizziness, Hydration)
                  _SectionCard(
                    width: width,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Symptom Trends',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Builder(builder: (ctx) {
                          final t = computeTrend(appState.fatigueSeries);
                          return _SymptomTrendTile(
                            title: 'Fatigue',
                            averageText: 'Avg: ${appState.combinedFatigueAvg.toStringAsFixed(1)}/10',
                            trendText: t['text'] as String,
                            icon: t['icon'] as IconData,
                            iconColor: t['color'] as Color,
                          );
                        }),
                        const SizedBox(height: 8),
                        Builder(builder: (ctx) {
                          final t = computeTrend(appState.dizziness);
                          return _SymptomTrendTile(
                            title: 'Dizziness',
                            averageText: 'Avg: ${appState.combinedDizzinessAvg.toStringAsFixed(1)}/10',
                            trendText: t['text'] as String,
                            icon: t['icon'] as IconData,
                            iconColor: t['color'] as Color,
                          );
                        }),
                        const SizedBox(height: 8),
                        Builder(builder: (ctx) {
                          final t = computeTrend(appState.hydrationSeries);
                          return _SymptomTrendTile(
                            title: 'Hydration',
                            averageText: 'Avg: ${appState.combinedHydrationAvg.toStringAsFixed(1)}/10',
                            trendText: t['text'] as String,
                            icon: t['icon'] as IconData,
                            iconColor: t['color'] as Color,
                          );
                        }),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Average Symptom Comparison bar chart
                  _SectionCard(
                    width: width,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Average Symptom Comparison',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: width,
                          height: height / 3,
                          child: GeneralBarChart(
                             width: width,
                      height: height / 3,    
                            // implement this in chart.dart similar to GeneralPlot
                            vals: [
                              appState.fatigueAvg,
                              appState.dizzinessAvg,
                              appState.hydrationAvg,
                            ],
                            labels: const ['Fatigue', 'Dizziness', 'Hydration'],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Symptom levels over time (multi-line chart)
                  _SectionCard(
                    width: width,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Symptom Levels Over Time',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          children: [
                            ChoiceChip(
                              label: const Text('Dizziness'),
                              selected: _showDizziness,
                              avatar: const CircleAvatar(backgroundColor: Colors.purple, radius: 6),
                              onSelected: (v) => setState(() => _showDizziness = v),
                            ),
                            ChoiceChip(
                              label: const Text('Fatigue'),
                              selected: _showFatigue,
                              avatar: const CircleAvatar(backgroundColor: Colors.orange, radius: 6),
                              onSelected: (v) => setState(() => _showFatigue = v),
                            ),
                            ChoiceChip(
                              label: const Text('Hydration'),
                              selected: _showHydration,
                              avatar: const CircleAvatar(backgroundColor: Colors.blue, radius: 6),
                              onSelected: (v) => setState(() => _showHydration = v),
                            ),
                            TextButton(
                              onPressed: () => setState(() { _showDizziness = true; _showFatigue = true; _showHydration = true; }),
                              child: const Text('All'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: width,
                          height: height / 3,
                          child: MultiSymptomPlot(
                                width: constraints.maxWidth * 0.9,
                                height: constraints.maxHeight / 3,
                                dizziness: _showDizziness ? appState.dizziness : const [],
                                fatigue: _showFatigue ? appState.fatigueSeries : const [],
                                hydration: _showHydration ? appState.hydrationSeries : const [],
                              ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Generic card container used throughout the page
class _SectionCard extends StatelessWidget {
  final double width;
  final Widget child;

  const _SectionCard({
    required this.width,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: width,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}

class _SymptomTrendTile extends StatelessWidget {
  final String title;
  final String averageText;
  final String trendText;
  final IconData icon;
  final Color iconColor;

  const _SymptomTrendTile({
    required this.title,
    required this.averageText,
    required this.trendText,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  averageText,
                  style: const TextStyle(color: Colors.black87),
                ),
                const SizedBox(height: 2),
                Text(
                  trendText,
                  style: const TextStyle(color: Colors.black54),
                ),
              ],
            ),
          ),
          Icon(
            icon,
            color: iconColor,
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}
