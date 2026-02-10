import 'package:flutter/material.dart';
import 'package:heartbeat/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:heartbeat/app_state.dart';
import 'package:heartbeat/widgets/custom_slider.dart';

class LifestyleQuiz extends StatefulWidget {
  const LifestyleQuiz({super.key});
  @override
  State<LifestyleQuiz> createState() => _LifestyleQuizState();
}

class _LifestyleQuizState extends State<LifestyleQuiz> {
  // Date
  DateTime _date = DateTime.now();

  // Checkboxes (toggles)
  bool _hotPlace = false;
  bool _refinedCarbs = false;
  bool _restTooMuch = false;
  bool _onPeriod = false;

  // Sliders (local mirrors to render green labels immediately)
  double _standingMins = 0;      // 0..240
  double _carbsGrams = 0;        // 0..400
  double _waterLitres = 0;       // 0..5, step 0.25
  double _alcoholUnits = 0;      // 0..20
  double _exMild = 0;            // 0..180
  double _exModerate = 0;        // 0..180
  double _exIntense = 0;         // 0..180
  double _stressLevel = 0;       // 0..3

  final TextEditingController _notesCtrl = TextEditingController();

  @override
  void dispose() {
    _notesCtrl.dispose();
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

  double get _totalExercise => _exMild + _exModerate + _exIntense;

  void _save() {
    final app = context.read<MyAppState>();
    app.saveLifestyleEntry(
      date: _date,
      hotPlace: _hotPlace,
      refinedCarbs: _refinedCarbs,
      standingMins: _standingMins.round(),
      carbsGrams: _carbsGrams.round(),
      waterLitres: double.parse(_waterLitres.toStringAsFixed(2)),
      alcoholUnits: _alcoholUnits.round(),
      restTooMuch: _restTooMuch,
      exMildMins: _exMild.round(),
      exModerateMins: _exModerate.round(),
      exIntenseMins: _exIntense.round(),
      onPeriod: _onPeriod,
      stressLevel: _stressLevel.round(),
      notes: _notesCtrl.text.trim(),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Lifestyle entry saved')),
    );
    setState(() => _notesCtrl.clear());
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<MyAppState>();

    // Pull initial values from app_state (first render only)
    _standingMins = app.lifestyleScores['standing_mins'] ?? 0;
    _carbsGrams   = app.lifestyleScores['carbs_grams']   ?? 0;
    _waterLitres  = app.lifestyleScores['water_litres']  ?? 0;
    _alcoholUnits = app.lifestyleScores['alcohol_units'] ?? 0;
    _exMild       = app.lifestyleScores['exercise_mild'] ?? 0;
    _exModerate   = app.lifestyleScores['exercise_moderate'] ?? 0;
    _exIntense    = app.lifestyleScores['exercise_intense'] ?? 0;
    _stressLevel  = app.lifestyleScores['stress_level']  ?? 0;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info header
            _InfoBanner(
              title: 'Daily Lifestyle Log',
              subtitle: 'Track things that can make your symptoms worse (NHS guidelines)',
              icon: Icons.eco_outlined,
            ),
            const SizedBox(height: 12),

            // Date picker
            _SectionCard(
              title: 'Date',
              leadingIcon: Icons.calendar_month,
              child: _PickerTile(
                label: 'Date',
                value:
                    '${_date.month.toString().padLeft(2, '0')}/${_date.day.toString().padLeft(2, '0')}/${_date.year}',
                icon: Icons.calendar_today,
                onTap: _pickDate,
              ),
            ),
            const SizedBox(height: 12),

            // Being in hot place
            _SectionCard(
              title: 'Being in a hot place',
              leadingIcon: Icons.sunny,
              child: CheckboxListTile(
                value: _hotPlace,
                onChanged: (v) => setState(() => _hotPlace = v ?? false),
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.trailing,
                title: const Text(''),
              ),
            ),
            const SizedBox(height: 12),

            // Standing or sitting upright for long periods
            Container(
                margin: const EdgeInsets.only(bottom: 12), // adds the gap
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
                          children: const [
                            Icon(Icons.access_time, color: Color(0xFF4F7CFF)),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Standing or sitting upright for long periods',
                                softWrap: true,
                                maxLines: 3,
                                overflow: TextOverflow.fade,
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Duration: ${_standingMins.round()} minutes',
                          style: const TextStyle(color: Colors.green),
                        ),
                        const SizedBox(height: 6),
                        CustomSlider(
                            text: 'Standing/Sitting Mins',
                            value: _standingMins,
                            max: 240,
                            divisions: 240,       // 1-min steps
                            showLabel: false,     // hide “standing_mins: 0.0”
                            decimalPlaces: 0,     // minutes → no decimals
                            onChanged: (v) {
                              setState(() => _standingMins = v);
                              app.updateLifestyleScores('standing_mins', v);
                            },
                          ),
                    
                      ],
                    ),
                  ),
                ),
              ),
            // Eating refined carbohydrates (white bread, etc.)
            Material(
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
                    // Header with wrapped title
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Icon(Icons.bakery_dining, color: Color(0xFF4F7CFF)),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Eating refined carbohydrates (white bread, etc.)',
                            softWrap: true,
                            maxLines: 3,
                            overflow: TextOverflow.fade,
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Checkbox
                    CheckboxListTile(
                      value: _refinedCarbs,
                      onChanged: (v) => setState(() => _refinedCarbs = v ?? false),
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.trailing,
                      title: const Text(''),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Not drinking enough fluids
            _SectionCard(
              title: 'Not drinking enough fluids',
              leadingIcon: Icons.water_drop_outlined,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Water today: ${_waterLitres.toStringAsFixed(2)} litres',
                    style: const TextStyle(color: Colors.green),
                  ),
                  const SizedBox(height: 6),
                  CustomSlider(
                      text: 'Water (Litres)',
                      value: _waterLitres,
                      max: 5,
                      divisions: 20,        // 0.25 L steps
                      showLabel: false,     // hide “Water (Litres): 3.5”
                      decimalPlaces: 2,     // internal value formatting if you ever show the label
                      onChanged: (v) {
                        setState(() => _waterLitres = v);
                        app.updateLifestyleScores('water_litres', v);
                      },
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Drinking alcohol
            _SectionCard(
              title: 'Drinking alcohol',
              leadingIcon: Icons.local_bar_outlined,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Units of alcohol: ${_alcoholUnits.round()}',
                    style: const TextStyle(color: Colors.green),
                  ),
                  const SizedBox(height: 6),
                  CustomSlider(
                    text: 'Alcohol Units',
                    value: _alcoholUnits,
                    max: 20,
                    divisions: 20,        // 1-unit steps
                    showLabel: false,     // hide the extra line
                    decimalPlaces: 0,     // units → whole number
                    onChanged: (v) {
                      setState(() => _alcoholUnits = v);
                      app.updateLifestyleScores('alcohol_units', v);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Resting too much
            _SectionCard(
              title: 'Resting too much',
              leadingIcon: Icons.hotel_outlined,
              child: CheckboxListTile(
                value: _restTooMuch,
                onChanged: (v) => setState(() => _restTooMuch = v ?? false),
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.trailing,
                title: const Text(''),
              ),
            ),
            const SizedBox(height: 12),

            // Exercise section
            _SectionCard(
              title: 'Exercise',
              leadingIcon: Icons.fitness_center_outlined,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Mild
                  Text('Mild (can talk): ${_exMild.round()} mins',
                      style: const TextStyle(color: Colors.green)),
                  const SizedBox(height: 6),
                  CustomSlider(
                    text: 'Exercise Mild',
                    value: _exMild,
                    max: 180,
                    divisions: 180,
                    showLabel: false,
                    decimalPlaces: 0,     // minutes → whole number
                    onChanged: (v) {
                      setState(() => _exMild = v);
                      app.updateLifestyleScores('exercise_mild', v);
                    },
                  ),
                  const SizedBox(height: 12),

                  // Moderate
                  Text('Moderate (just about talk): ${_exModerate.round()} mins',
                      style: const TextStyle(color: Colors.green)),
                  const SizedBox(height: 6),
                  CustomSlider(
                    text: 'Exercise Moderate',
                    value: _exModerate,
                    max: 180,
                    divisions: 180,
                    showLabel: false,
                    decimalPlaces: 0,
                    onChanged: (v) {
                      setState(() => _exModerate = v);
                      app.updateLifestyleScores('exercise_moderate', v);
                    },
                  ),
                  const SizedBox(height: 12),

                  // Intense
                  Text('Intense: ${_exIntense.round()} mins',
                      style: const TextStyle(color: Colors.green)),
                  const SizedBox(height: 6),
                  CustomSlider(
                    text: 'Exercise Intense',
                    value: _exIntense,
                    max: 180,
                    divisions: 180,
                    showLabel: false,
                    decimalPlaces: 0,
                    onChanged: (v) {
                      setState(() => _exIntense = v);
                      app.updateLifestyleScores('exercise_intense', v);
                    },
                  ),
                  const SizedBox(height: 12),

                  // Total
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF7E9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Total: ${_totalExercise.round()} mins (${(_totalExercise / 60).toStringAsFixed(1)} hrs)',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Being on your period
            _SectionCard(
              title: 'Being on your period',
              leadingIcon: Icons.bloodtype_outlined,
              child: CheckboxListTile(
                value: _onPeriod,
                onChanged: (v) => setState(() => _onPeriod = v ?? false),
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.trailing,
                title: const Text(''),
              ),
            ),
            const SizedBox(height: 12),

            // Stress
            _SectionCard(
              title: 'Stress',
              leadingIcon: Icons.sentiment_very_dissatisfied_outlined,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Stress Level: ${_stressLevel.round()} (0–3)',
                      style: const TextStyle(color: Colors.green)),
                  const SizedBox(height: 6),
                  CustomSlider(
                    text: 'Stress Level (0–3)',
                    value: _stressLevel,
                    max: 3,
                    divisions: 3,
                    showLabel: false,
                    decimalPlaces: 0,
                    onChanged: (v) {
                      setState(() => _stressLevel = v);
                      app.updateLifestyleScores('stress_level', v);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Notes
            _SectionCard(
              title: 'Personal notes for tracking',
              leadingIcon: Icons.notes_outlined,
              child: TextField(
                controller: _notesCtrl,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Any other observations about your day...',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Save button
            HeartbeatButton(
              label: 'Save Lifestyle Entry',
              gradientColors: const [Color(0xFF16A34A), Color(0xFF4ADE80)],
              onPressed: _save,
            ),
            const SizedBox(height: 16),

            // Recent entries (simple placeholder – bind to appState if you have a list)
            _SectionCard(
              title: 'Recent Entries',
              leadingIcon: Icons.history,
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 6),
                child: Text(
                  'No lifestyle entries yet. Start logging your daily habits!',
                  style: TextStyle(color: Colors.black54),
                ),
              ),
            ),
          ],
        ),
      ),
    );
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