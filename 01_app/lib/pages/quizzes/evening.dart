import 'package:flutter/material.dart';
import 'package:heartbeat/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:heartbeat/app_state.dart'; // for MyAppState and Severity enum

class EveningQuiz extends StatefulWidget {
  const EveningQuiz({super.key});
  @override
  State<EveningQuiz> createState() => _EveningQuizState();
}

class _EveningQuizState extends State<EveningQuiz> {
  // Date & time
  DateTime _date = DateTime.now();
  TimeOfDay _time = TimeOfDay.now();

  // Abnormal fatigue (chips)
  Severity _fatigue = Severity.none;

  // Baseline symptoms
  final Set<String> _selectedBaseline = <String>{};

  final List<String> _baselineOptions = const [
    'Dizziness, feeling that you are going to faint after being upright',
    'Palpitations, high pulse, or feeling heart beating irregularly',
    'Chest pain',
    'Headache',
    'Concentration difficulties and/or problems with thinking',
    'Muscle pain',
    'Nausea',
    'Gastrointestinal problems (stomach-ache, diarrhoea, constipation)',
    'Difficulties in concentration',
    'Difficult breathing/dyspnoea, both at effort and rest',
    'Temperature Changes (feeling abnormally hot or cold)',
  ];

  final TextEditingController _notesCtrl = TextEditingController();
  final TextEditingController _hrCtrl = TextEditingController();
  final TextEditingController _hrvCtrl = TextEditingController();

  @override
  void dispose() {
    _notesCtrl.dispose();
    _hrCtrl.dispose();
    _hrvCtrl.dispose();
    super.dispose();
  }

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
  int fatigueToScore(Severity s) {
    switch (s) {
      case Severity.none:
        return 0;
      case Severity.slight:
        return 25;
      case Severity.moderate:
        return 50;
      case Severity.severe:
        return 75; // or 100 if you prefer a 0–100 scale
    }
  }
  // Optional: add "Abnormal Fatigue" to baseline if level > None
  List<String> _finalBaseline() {
    final list = _selectedBaseline.toList();
    if (_fatigue != Severity.none && !list.contains('Abnormal Fatigue')) {
      list.add('Abnormal Fatigue');
    } else if (_fatigue == Severity.none) {
      list.remove('Abnormal Fatigue');
    }
    return list;
  }

  void _save() {
    final app = context.read<MyAppState>();

    // If your saveEveningReview still requires HR and HRV, keep these 0s.
    // If you removed them from MyAppState, delete heartRateBpm/hrvMs below.
    app.saveEveningReview(
      date: _date,
      time: _time,
      heartRateBpm: 0, // remove if not required
      hrvMs: 0,        // remove if not required
      fatigueScore: fatigueToScore(_fatigue), // Convert enum to 0, 25, 50, 75
      baselineSymptoms: _finalBaseline(),
      notes: _notesCtrl.text.trim(),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Evening review saved')),
    );
    setState(() {
      _notesCtrl.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<MyAppState>(); // used for recent entries

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top tabs live elsewhere; we render the body only
            _InfoBanner(
              title: 'Evening Time Log (5pm - 5am)',
              subtitle: 'Review your day',
              icon: Icons.nightlight_round,
            ),
            const SizedBox(height: 12),

            // Date & Time card
            _SectionCard(
              title: 'Date & Time',
              leadingIcon: Icons.calendar_month,
              child: Row(
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
            ),
            const SizedBox(height: 12),

            // HR & HRV card
            _SectionCard(
              title: 'HR & HRV',
              leadingIcon: Icons.monitor_heart_outlined,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _hrCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Heart Rate (bpm)',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _hrvCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'HRV (ms)',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('PLUX HeartBIT connection coming soon')),
                        );
                      },
                      icon: const Icon(Icons.bluetooth),
                      label: const Text('Connect to PLUX HeartBIT'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF4F7CFF),
                        side: const BorderSide(color: Color(0xFF4F7CFF)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Abnormal Fatigue card
            _SectionCard(
              title: 'Abnormal Fatigue',
              leadingIcon: Icons.battery_alert_outlined,
              child: _SeverityChips(
                value: _fatigue,
                onChanged: (s) => setState(() => _fatigue = s),
              ),
            ),
            const SizedBox(height: 12),

            // Baseline Symptoms card
            _SectionCard(
              title: 'Baseline Symptoms',
              leadingIcon: Icons.checklist_outlined,
              child: Column(
                children: _baselineOptions.map((label) {
                  final selected = _selectedBaseline.contains(label);
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          if (selected) {
                            _selectedBaseline.remove(label);
                          } else {
                            _selectedBaseline.add(label);
                          }
                        });
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selected
                                ? const Color(0xFF3A66FF)
                                : Colors.black12,
                            width: selected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                label,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),

            // Additional Notes card
            _SectionCard(
              title: 'Additional Notes',
              leadingIcon: Icons.notes_outlined,
              child: TextField(
                controller: _notesCtrl,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'How was your day overall?',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Save button (outside any card)
            HeartbeatButton(
              label: 'Save Evening Review',
              onPressed: _save,
            ),
            const SizedBox(height: 12),

            // Recent Entries (simple)
            _SectionCard(
              title: 'Recent Entries',
              leadingIcon: Icons.history,
              child: (app.eveningEntries.isEmpty)
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 6),
                      child: Text(
                        'No evening entries yet. Start logging!',
                        style: TextStyle(color: Colors.black54),
                      ),
                    )
                  : Column(
                      children: [
                        for (final e in app.eveningEntries.take(3))
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _RecentEveningTile(entry: e),
                          ),
                      ],
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

  String _fatigueLabel(Severity s) {
    switch (s) {
      case Severity.none:
        return 'None';
      case Severity.slight:
        return 'Slight';
      case Severity.moderate:
        return 'Moderate';
      case Severity.severe:
        return 'Severe';
    }
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
                        fontWeight: FontWeight.w700, fontSize: 30)),
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

class _SeverityChips extends StatelessWidget {
  const _SeverityChips({
    required this.value,
    required this.onChanged,
  });

  final Severity value;
  final ValueChanged<Severity> onChanged;

  static Color _chipBg(Severity s) {
    switch (s) {
      case Severity.none:
        return const Color(0xFFE8F5E9);
      case Severity.slight:
        return const Color(0xFFFFF8E1);
      case Severity.moderate:
        return const Color(0xFFFFF3E0);
      case Severity.severe:
        return const Color(0xFFFFEBEE);
    }
  }

  static Color _chipFg(Severity s) {
    switch (s) {
      case Severity.none:
        return const Color(0xFF2E7D32);
      case Severity.slight:
        return const Color(0xFFF9A825);
      case Severity.moderate:
        return const Color(0xFFE65100);
      case Severity.severe:
        return const Color(0xFFC62828);
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = const [
      (Severity.none, 'None'),
      (Severity.slight, 'Slight'),
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

class _RecentEveningTile extends StatelessWidget {
  const _RecentEveningTile({required this.entry});
  final EveningEntry entry;

  @override
  Widget build(BuildContext context) {
    final dt = entry.dateTime;
    final dateLabel = '${dt.month}/${dt.day}/${dt.year}';
    final timeLabel = _format(dt);
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
            Row(
              children: [
                const Text('Symptoms', style: TextStyle(color: Colors.black87)),
                const Spacer(),
                Text(
                  '${entry.baselineSymptoms.length} selected',
                  style: const TextStyle(
                      color: Color(0xFF3A66FF), fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static String _format(DateTime dt) {
    final h12 = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final suffix = dt.hour < 12 ? 'am' : 'pm';
    return '$h12:$m $suffix';
  }
}