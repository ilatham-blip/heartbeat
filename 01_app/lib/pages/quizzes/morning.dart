import 'package:flutter/material.dart';
import 'package:heartbeat/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:heartbeat/app_state.dart';


/// Morning page
class MorningQuiz extends StatefulWidget {
  const MorningQuiz({super.key});
  @override
  State<MorningQuiz> createState() => _MorningQuizState();
}

class _MorningQuizState extends State<MorningQuiz> {
  DateTime _date = DateTime.now();
  TimeOfDay _time = TimeOfDay.now();

  SleepQuality _sleep = SleepQuality.fair;
  Severity _fatigue = Severity.none;
  Severity _dizziness = Severity.none;
  Severity _tachycardia = Severity.none;

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

  void _save() {
    final appState = context.read<MyAppState>();
    appState.saveMorningCheckIn(
      date: _date,
      time: _time,
      sleepQuality: _sleep,
      fatigue: _fatigue,
      dizzinessStanding: _dizziness,
      tachycardia: _tachycardia,
      notes: _notesCtrl.text.trim(),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Morning check-in saved')),
    );
    setState(() {
      _notesCtrl.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<MyAppState>();

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info banner
            _InfoBanner(
              title: 'Morning Time (5am - 5pm)',
              subtitle: 'Complete your morning check-in',
              icon: Icons.wb_sunny_outlined,
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

            // Sleep Quality card
            _SectionCard(
              title: 'Sleep Quality',
              leadingIcon: Icons.bedtime_outlined,
              child: _LabeledChipGroup<SleepQuality>(
                label: 'Sleep Quality:',
                value: _sleep,
                items: const [
                  (SleepQuality.awful, 'Awful'),
                  (SleepQuality.bad, 'Bad'),
                  (SleepQuality.fair, 'Fair'),
                  (SleepQuality.good, 'Good'),
                ],
                onChanged: (v) => setState(() => _sleep = v),
              ),
            ),
            const SizedBox(height: 12),

            // Abnormal Fatigue card
            _SectionCard(
              title: 'Abnormal Fatigue',
              leadingIcon: Icons.battery_alert_outlined,
              child: _LabeledChipGroup<Severity>(
                label: 'Abnormal Fatigue:',
                value: _fatigue,
                items: const [
                  (Severity.none, 'None'),
                  (Severity.slight, 'Slight'),
                  (Severity.moderate, 'Moderate'),
                  (Severity.severe, 'Severe'),
                ],
                onChanged: (v) => setState(() => _fatigue = v),
              ),
            ),
            const SizedBox(height: 12),

            // Dizziness Standing card
            _SectionCard(
              title: 'Dizziness Standing',
              leadingIcon: Icons.swap_vert_outlined,
              child: _LabeledChipGroup<Severity>(
                label: 'Dizziness Standing:',
                value: _dizziness,
                items: const [
                  (Severity.none, 'None'),
                  (Severity.slight, 'Slight'),
                  (Severity.moderate, 'Moderate'),
                  (Severity.severe, 'Severe'),
                ],
                onChanged: (v) => setState(() => _dizziness = v),
              ),
            ),
            const SizedBox(height: 12),

            // Tachycardia card
            _SectionCard(
              title: 'Tachycardia',
              leadingIcon: Icons.favorite_outline,
              child: _LabeledChipGroup<Severity>(
                label: 'Tachycardia:',
                value: _tachycardia,
                items: const [
                  (Severity.none, 'None'),
                  (Severity.slight, 'Slight'),
                  (Severity.moderate, 'Moderate'),
                  (Severity.severe, 'Severe'),
                ],
                onChanged: (v) => setState(() => _tachycardia = v),
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
                  hintText: 'Any other observations...',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Save button (outside any card)
            HeartbeatButton(
              label: 'Save Morning Check-in',
              onPressed: _save,
            ),
            const SizedBox(height: 16),

            // Recent Entries
            _SectionCard(
              title: 'Recent Entries',
              leadingIcon: Icons.history,
              child: Column(
                children: [
                  for (final e in appState.morningEntries.take(10))
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _MorningEntryTile(entry: e),
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
                        fontSize: 16, fontWeight: FontWeight.w700)),
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

class _LabeledChipGroup<T> extends StatelessWidget {
  const _LabeledChipGroup({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final T value;
  final List<(T, String)> items;
  final ValueChanged<T> onChanged;

  static const _severityColors = {
    'None': (Color(0xFFE8F5E9), Color(0xFF2E7D32)),
    'Slight': (Color(0xFFFFF8E1), Color(0xFFF9A825)),
    'Moderate': (Color(0xFFFFF3E0), Color(0xFFE65100)),
    'Severe': (Color(0xFFFFEBEE), Color(0xFFC62828)),
    'Awful': (Color(0xFFFFEBEE), Color(0xFFC62828)),
    'Bad': (Color(0xFFFFF3E0), Color(0xFFE65100)),
    'Fair': (Color(0xFFFFF8E1), Color(0xFFF9A825)),
    'Good': (Color(0xFFE8F5E9), Color(0xFF2E7D32)),
  };

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items.map((it) {
        final selected = it.$1 == value;
        final colors = _severityColors[it.$2];
        return ChoiceChip(
          label: Text(it.$2),
          selected: selected,
          pressElevation: 0,
          onSelected: (_) => onChanged(it.$1),
          selectedColor: colors?.$1,
          labelStyle: TextStyle(
            color: selected ? colors?.$2 : Colors.black87,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        );
      }).toList(),
    );
  }
}

/* ---------------------- Recent entry tile ---------------------- */

class _MorningEntryTile extends StatelessWidget {
  const _MorningEntryTile({required this.entry});
  final MorningEntry entry; // Define in MyAppState

  @override
  Widget build(BuildContext context) {
    final dt = entry.dateTime;
    final dateLabel =
        '${dt.month}/${dt.day}/${dt.year}'; // e.g., 1/25/2026
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
            _kv('Sleep Quality', _labelSleep(entry.sleepQuality)),
            _kv('Fatigue', _labelSeverity(entry.fatigue)),
            _kv('Dizziness', _labelSeverity(entry.dizzinessStanding)),
            _kv('Tachycardia', _labelSeverity(entry.tachycardia)),
          ],
        ),
      ),
    );
  }

  static String _format(DateTime dt) {
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final suffix = dt.hour < 12 ? 'am' : 'pm';
    return '$h:$m $suffix';
  }

  static String _labelSleep(SleepQuality s) {
    switch (s) {
      case SleepQuality.awful:
        return 'Awful';
      case SleepQuality.bad:
        return 'Bad';
      case SleepQuality.fair:
        return 'Fair';
      case SleepQuality.good:
        return 'Good';
    }
  }

  static String _labelSeverity(Severity s) {
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