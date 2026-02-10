import 'package:flutter/material.dart';
import 'package:heartbeat/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:heartbeat/app_state.dart'; // uses Severity enum and MyAppState

class EpisodeQuiz extends StatefulWidget {
  const EpisodeQuiz({super.key});
  @override
  State<EpisodeQuiz> createState() => _EpisodeQuizState();
}

class _EpisodeQuizState extends State<EpisodeQuiz> {
  // Date & time
  DateTime _date = DateTime.now();
  TimeOfDay _time = TimeOfDay.now();

  final TextEditingController _notesCtrl = TextEditingController();

  // MAPS symptoms (12 items → max score 36)
  final List<String> _symptoms = const [
    'Dizziness in upright position or while standing up',
    'Dizziness, feeling that you are going to faint',
    'Palpitations, high pulse, or feeling heart beating irregularly',
    'Difficult breathing/dyspnoea, both at effort and rest',
    'Chest pain',
    'Headache',
    'Concentration difficulties and/or problems with thinking',
    'Muscle pain',
    'Nausea',
    'Gastrointestinal problems (stomach-ache, diarrhoea, constipation)',
    'Tremulousness',
    'Blurred vision',
  ];

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time,
    );
    if (picked != null) setState(() => _time = picked);
  }

  int _totalScore(MyAppState app) {
    int sum = 0;
    for (final s in _symptoms) {
      final v = app.episodeScores[s] ?? 0.0;
      sum += v.round().clamp(0, 3);
    }
    return sum;
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<MyAppState>();
    final maxScore = _symptoms.length * 3;
    final total = _totalScore(app);
    final percent = maxScore == 0 ? 0.0 : (total / maxScore) * 100.0;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _EPHeaderBanner(),
            const SizedBox(height: 12),

            _EPSectionCard(
              title: 'Log POTS Episode',
              leadingIcon: Icons.monitor_heart_outlined,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info box
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3F0),
                      border: Border.all(color: const Color(0xFFFFD6CD)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'Log as often as you need. Skip irrelevant questions by leaving them at 0.',
                      style: TextStyle(color: Colors.black87),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Date & Time pickers
                  Row(
                    children: [
                      Expanded(
                        child: _EPPickerTile(
                          label: 'Date',
                          value:
                              '${_date.month.toString().padLeft(2, '0')}/${_date.day.toString().padLeft(2, '0')}/${_date.year}',
                          icon: Icons.calendar_today,
                          onTap: _pickDate,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _EPPickerTile(
                          label: 'Time',
                          value: _formatTime(_time),
                          icon: Icons.access_time,
                          onTap: _pickTime,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

           

            // Symptom cards with chips
            for (final symptom in _symptoms)...[
              _EPSectionCard(
                title: symptom,
                leadingIcon: Icons.circle_outlined,
                child: _SeverityChipsRow(
                  value: _severityFromValue(app.episodeScores[symptom] ?? 0),
                  onChanged: (sev) {
                    // Map Severity → 0..3 and store via provider
                    app.updateEpisodeScore(symptom, _severityToValue(sev).toDouble());
                  },
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Notes
            _EPSectionCard(
              title: 'Additional Notes',
              leadingIcon: Icons.notes_outlined,
              child: TextField(
                controller: _notesCtrl,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Triggers, context, or any other observations...',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Save button
            HeartbeatButton(
              label: 'Log POTS Episode',
              gradientColors: const [Color(0xFFCC2B2B), Color(0xFFEF4444)],
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('POTS episode logged')),
                );
              },
            ),
            const SizedBox(height: 16),

            // Recent episodes placeholder (wire to your data source if available)
            _EPSectionCard(
              title: 'Recent Episodes',
              leadingIcon: Icons.history,
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 6),
                child: Text(
                  'No recent episodes yet. Start logging!',
                  style: TextStyle(color: Colors.black54),
                ),
              ),
            ),
          ],
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

  // Severity ↔ integer value helpers (None=0, Mild=1, Moderate=2, Severe=3)
  static int _severityToValue(Severity s) {
    switch (s) {
      case Severity.none:
        return 0;
      case Severity.slight:
        return 1; // "Mild"
      case Severity.moderate:
        return 2;
      case Severity.severe:
        return 3;
    }
  }

  static Severity _severityFromValue(double v) {
    final i = v.round().clamp(0, 3);
    switch (i) {
      case 0:
        return Severity.none;
      case 1:
        return Severity.slight;
      case 2:
        return Severity.moderate;
      case 3:
      default:
        return Severity.severe;
    }
  }
}

/* ---------------------- UI helpers (local to this file) ---------------------- */

class _EPHeaderBanner extends StatelessWidget {
  const _EPHeaderBanner();

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
        children: const [
          Icon(Icons.monitor_heart_outlined, color: Color(0xFF4F7CFF)),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'POTS Episode',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}

class _EPSectionCard extends StatelessWidget {
  const _EPSectionCard({
    required this.title,
    required this.child,
    required this.leadingIcon,
  });

  final String title;
  final Widget child;
  final IconData leadingIcon;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(leadingIcon, color: const Color(0xFF4F7CFF)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      softWrap: true,
                      maxLines: 3,
                      overflow: TextOverflow.fade,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

class _EPPickerTile extends StatelessWidget {
  const _EPPickerTile({
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

class _SeverityChipsRow extends StatelessWidget {
  const _SeverityChipsRow({
    required this.value,
    required this.onChanged,
  });

  final Severity value;
  final ValueChanged<Severity> onChanged;

  static Color _chipBg(Severity s) {
    switch (s) {
      case Severity.none:
        return const Color(0xFFE8F5E9); // green tint
      case Severity.slight:
        return const Color(0xFFFFF8E1); // amber tint
      case Severity.moderate:
        return const Color(0xFFFFF3E0); // orange tint
      case Severity.severe:
        return const Color(0xFFFFEBEE); // red tint
    }
  }

  static Color _chipFg(Severity s) {
    switch (s) {
      case Severity.none:
        return const Color(0xFF2E7D32); // green
      case Severity.slight:
        return const Color(0xFFF9A825); // amber
      case Severity.moderate:
        return const Color(0xFFE65100); // orange
      case Severity.severe:
        return const Color(0xFFC62828); // red
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = const [
      (Severity.none, 'None'),
      (Severity.slight, 'Mild'),
      (Severity.moderate, 'Moderate'),
      (Severity.severe, 'Severe'),
    ];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items.map((it) {
        final selected = it.$1 == value;
        return ChoiceChip(
          label: Text(it.$2),
          selected: selected,
          onSelected: (_) => onChanged(it.$1),
          selectedColor: _chipBg(it.$1),
          labelStyle: TextStyle(
            color: selected ? _chipFg(it.$1) : Colors.black87,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        );
      }).toList(),
    );
  }
}
