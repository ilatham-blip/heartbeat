import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:heartbeat/app_state.dart';

class EveningQuiz extends StatefulWidget {
  const EveningQuiz({super.key});
  @override
  State<EveningQuiz> createState() => _EveningQuizState();
}

class _EveningQuizState extends State<EveningQuiz> {
  DateTime _date = DateTime.now();
  TimeOfDay _time = TimeOfDay.now();

  double _heartRate = 70; // bpm
  double _hrv = 50;       // ms
  double _fatigue = 0;    // 0..100 (None..Severe)

  final TextEditingController _notesCtrl = TextEditingController();

  final List<String> _baselineOptions = const [
    'Muscle pain',
    'Nausea',
    'Gastrointestinal problems (stomach-ache, diarrhoea, constipation)',
    'Difficulties in concentration',
    'Difficult breathing/dyspnoea, both at effort and rest',
    'Temperature Changes (feeling abnormally hot or cold)',
    'Dizziness, feeling that you are going to faint after being upright',
    'Palpitations, high pulse, or feeling heart beating irregularly',
  ];
  final Set<String> _selectedBaseline = {};

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _date = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time,
    );
    if (picked != null) {
      setState(() => _time = picked);
    }
  }

  void _save() {
    final appState = Provider.of<MyAppState>(context, listen: false);

    // Adjust to your app_state API; example:
    appState.saveEveningReview(
      date: _date,
      time: _time,
      heartRateBpm: _heartRate.round(),
      hrvMs: _hrv.round(),
      fatigueScore: _fatigue.round(),
      baselineSymptoms: _selectedBaseline.toList(),
      notes: _notesCtrl.text.trim(),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Evening review saved')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Monitor'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info banner
              _InfoBanner(
                title: 'Evening Time (5pm - 5am)',
                subtitle: 'Review your day',
                icon: Icons.nightlight_round,
              ),
              const SizedBox(height: 12),

              // Evening Review card
              _SectionCard(
                title: 'Evening Review',
                leadingIcon: Icons.nightlight,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date & Time pickers
                    Row(
                      children: [
                        Expanded(
                          child: _PickerTile(
                            label: 'Date',
                            value:
                                '${_date.month.toString().padLeft(2, '0')}/${_date.day.toString().padLeft(2, '0')}/${_date.year}',
                            icon: Icons.calendar_today,
                            onTap: _pickDate,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _PickerTile(
                            label: 'Time',
                            value: _formatTime(_time),
                            icon: Icons.access_time,
                            onTap: _pickTime,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),



                  
                    // Fatigue
                    _LabeledSlider(
                      label: 'Abnormal Fatigue: ${_fatigueLabel(_fatigue)}',
                      value: _fatigue,
                      min: 0,
                      max: 100,
                      onChanged: (v) => setState(() => _fatigue = v),
                      minLabel: 'None',
                      maxLabel: 'Severe',
                    ),
                    const SizedBox(height: 16),

                    // Baseline symptoms
                    Text('Baseline Symptoms',
                        style: textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _baselineOptions.map((label) {
                        final selected = _selectedBaseline.contains(label);
                        return FilterChip(
                          label: Text(label),
                          selected: selected,
                          onSelected: (isSel) {
                            setState(() {
                              if (isSel) {
                                _selectedBaseline.add(label);
                              } else {
                                _selectedBaseline.remove(label);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    // Additional notes
                    Text('Additional Notes',
                        style: textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _notesCtrl,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: 'How was your day overall?',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Save button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _save,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: const Color(0xFF4F7CFF),
                        ),
                        child: const Text(
                          'Save Evening Review',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Recent entries placeholder (you can bind to Provider data)
              _SectionCard(
                title: 'Recent Entries',
                leadingIcon: Icons.history,
                child: Column(
                  children: [
                    _RecentEntryTile(
                      dateLabel: '1/17/2026',
                      timeLabel: '20:00',
                      heartRate: '70 bpm',
                      hrv: '50 ms',
                      fatigue: 'None',
                    ),
                    const SizedBox(height: 12),
                    _RecentEntryTile(
                      dateLabel: '1/16/2026',
                      timeLabel: '20:05',
                      heartRate: '68 bpm',
                      hrv: '48 ms',
                      fatigue: 'Mild',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(TimeOfDay t) {
    final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final m = t.minute.toString().padLeft(2, '0');
    final suffix = t.period == DayPeriod.am ? 'am' : 'pm';
    return '$h:$m $suffix';
  }

  String _fatigueLabel(double v) {
    if (v < 20) return 'None';
    if (v < 40) return 'Mild';
    if (v < 60) return 'Moderate';
    if (v < 80) return 'High';
    return 'Severe';
  }
}

/* ---------------------- UI helpers ---------------------- */

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F6FF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFDCE7FF)),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF4F7CFF)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 16)),
                const SizedBox(height: 4),
                Text(subtitle,
                    style: const TextStyle(
                        color: Colors.black54, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.child,
    required this.leadingIcon,
  });

  final String title;
  final Widget child;
  final IconData leadingIcon;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.black12.withOpacity(0.06)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(leadingIcon, color: const Color(0xFF4F7CFF)),
                const SizedBox(width: 8),
                Text(title,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _PickerTile extends StatelessWidget {
  const _PickerTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.black12.withOpacity(0.06)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              Icon(icon, color: Colors.black54, size: 18),
              const SizedBox(width: 8),
              Text(label,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 13)),
              const Spacer(),
              Text(value, style: const TextStyle(fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }
}

class _LabeledSlider extends StatelessWidget {
  const _LabeledSlider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.minLabel,
    this.maxLabel,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;
  final String? minLabel;
  final String? maxLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style:
                const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        Slider(
          value: value,
          min: min,
          max: max,
          activeColor: const Color(0xFF4F7CFF),
          onChanged: onChanged,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(minLabel ?? '$min',
                style: const TextStyle(color: Colors.black54, fontSize: 12)),
            Text(maxLabel ?? '$max',
                style: const TextStyle(color: Colors.black54, fontSize: 12)),
          ],
        ),
      ],
    );
  }
}

class _RecentEntryTile extends StatelessWidget {
  const _RecentEntryTile({
    required this.dateLabel,
    required this.timeLabel,
    required this.heartRate,
    required this.hrv,
    required this.fatigue,
  });

  final String dateLabel;
  final String timeLabel;
  final String heartRate;
  final String hrv;
  final String fatigue;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.black12.withOpacity(0.06)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Text(dateLabel,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 14)),
                const Spacer(),
                Text(timeLabel, style: const TextStyle(color: Colors.black54)),
              ],
            ),
            const SizedBox(height: 8),
            _kv('Heart Rate', heartRate),
            _kv('HRV', hrv),
            _kv('Fatigue', fatigue),
          ],
        ),
      ),
    );
  }

  Widget _kv(String k, String v) {
    return Row(
      children: [
        Text(k, style: const TextStyle(color: Colors.black87)),
        const Spacer(),
        Text(v,
            style: const TextStyle(
                color: Color(0xFF4F7CFF), fontWeight: FontWeight.w600)),
      ],
    );
  }
}