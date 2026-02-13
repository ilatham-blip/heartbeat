import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:heartbeat/app_state.dart';
import 'package:heartbeat/widgets/quiz_bottom_bar.dart';
import 'package:heartbeat/widgets/quiz_next_button.dart';

/// Morning quiz: landing page (embedded in tabs) + full-screen paged survey.
class MorningQuiz extends StatefulWidget {
  const MorningQuiz({super.key});
  @override
  State<MorningQuiz> createState() => _MorningQuizState();
}

class _MorningQuizState extends State<MorningQuiz> {
  void _startSurvey() {
    final appState = Provider.of<MyAppState>(context, listen: false);
    appState.clearMorningDraft();
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const _MorningSurveyScreen()),
    );
  }

  void _continueSurvey() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const _MorningSurveyScreen()),
    );
  }

  void _restartSurvey() {
    final appState = Provider.of<MyAppState>(context, listen: false);
    appState.clearMorningDraft();
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const _MorningSurveyScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<MyAppState>(context);
    final draft = appState.morningDraft;
    final hasDraft = draft != null;
    final now = DateTime.now();
    final timeStr = _formatTime(TimeOfDay.now());
    final dateStr =
        '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header banner ──
            _InfoBanner(
              title: 'Morning Time Log',
              subtitle: 'Complete your morning check-in (5am - 5pm)',
              icon: Icons.wb_sunny_outlined,
            ),
            const SizedBox(height: 12),

            // ── Date & Time ──
            _SectionCard(
              title: 'Date & Time',
              leadingIcon: Icons.calendar_today,
              child: Row(
                children: [
                  const Icon(Icons.calendar_today,
                      size: 18, color: Colors.black54),
                  const SizedBox(width: 8),
                  Text(dateStr, style: const TextStyle(fontSize: 15)),
                  const Spacer(),
                  const Icon(Icons.access_time,
                      size: 18, color: Colors.black54),
                  const SizedBox(width: 8),
                  Text(timeStr, style: const TextStyle(fontSize: 15)),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Action buttons ──
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: hasDraft ? _continueSurvey : _startSurvey,
                icon: Icon(
                    hasDraft ? Icons.play_arrow : Icons.play_arrow_rounded),
                label: Text(hasDraft ? 'Continue Survey' : 'Start Survey'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F7CFF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  textStyle: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            if (hasDraft) ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _restartSurvey,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Restart Survey'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF4F7CFF),
                    side: const BorderSide(color: Color(0xFF4F7CFF)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    textStyle: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),

            // ── Recent entries ──
            _SectionCard(
              title: 'Recent Entries',
              leadingIcon: Icons.history,
              child: appState.morningEntries.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text('No entries yet',
                          style: TextStyle(color: Colors.black45)),
                    )
                  : Column(
                      children: appState.morningEntries
                          .take(5)
                          .map((e) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: _MorningEntryTile(entry: e),
                              ))
                          .toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  static String _formatTime(TimeOfDay t) {
    final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final m = t.minute.toString().padLeft(2, '0');
    final suffix = t.period == DayPeriod.am ? 'am' : 'pm';
    return '$h:$m $suffix';
  }
}

// ═══════════════════════════════════════════════════════════
// Full-screen survey route
// ═══════════════════════════════════════════════════════════

class _MorningSurveyScreen extends StatefulWidget {
  const _MorningSurveyScreen();
  @override
  State<_MorningSurveyScreen> createState() => _MorningSurveyScreenState();
}

class _MorningSurveyScreenState extends State<_MorningSurveyScreen> {
  int _currentPage = 0;
  static const int _totalPages = 4;

  DateTime _date = DateTime.now();
  TimeOfDay _time = TimeOfDay.now();
  final TextEditingController _hrCtrl = TextEditingController();
  final TextEditingController _hrvCtrl = TextEditingController();
  SleepQuality _sleep = SleepQuality.fair;
  Severity _fatigue = Severity.none;
  Severity _dizziness = Severity.none;
  Severity _tachycardia = Severity.none;
  final TextEditingController _notesCtrl = TextEditingController();
  final PageController _pageCtrl = PageController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appState = Provider.of<MyAppState>(context, listen: false);
      final draft = appState.morningDraft;
      if (draft != null) {
        setState(() {
          _currentPage = draft.currentPage;
          _date = draft.date;
          _time = draft.time;
          _hrCtrl.text = draft.heartRateBpm?.toString() ?? '';
          _hrvCtrl.text = draft.hrvMs?.toString() ?? '';
          _sleep = draft.sleep;
          _fatigue = draft.fatigue;
          _dizziness = draft.dizziness;
          _tachycardia = draft.tachycardia;
          _notesCtrl.text = draft.notes;
        });
        if (_pageCtrl.hasClients) {
          _pageCtrl.jumpToPage(_currentPage);
        }
      }
    });
  }

  @override
  void dispose() {
    _hrCtrl.dispose();
    _hrvCtrl.dispose();
    _notesCtrl.dispose();
    _pageCtrl.dispose();
    super.dispose();
  }

  // ─── Helpers ──────────────────────────────────────────────

  MorningDraft _buildDraft() => MorningDraft(
        currentPage: _currentPage,
        date: _date,
        time: _time,
        heartRateBpm: int.tryParse(_hrCtrl.text),
        hrvMs: int.tryParse(_hrvCtrl.text),
        sleep: _sleep,
        fatigue: _fatigue,
        dizziness: _dizziness,
        tachycardia: _tachycardia,
        notes: _notesCtrl.text,
      );

  void _pauseSurvey() {
    final appState = Provider.of<MyAppState>(context, listen: false);
    appState.pauseMorningCheckIn(_buildDraft());
    Navigator.of(context).pop();
  }

  void _stopSurvey() async {
    final appState = Provider.of<MyAppState>(context, listen: false);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Stop survey?'),
        content: const Text('Your progress will be lost.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Stop',
                  style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirmed == true) {
      appState.clearMorningDraft();
      if (mounted) Navigator.of(context).pop();
    }
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageCtrl.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut);
      setState(() => _currentPage++);
    }
  }

  void _prevPage() {
    if (_currentPage > 0) {
      _pageCtrl.previousPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut);
      setState(() => _currentPage--);
    }
  }

  void _saveLog() async {
    final appState = Provider.of<MyAppState>(context, listen: false);
    try {
      await appState.saveMorningCheckIn(
        date: _date,
        time: _time,
        sleepQuality: _sleep,
        fatigue: _fatigue,
        dizzinessStanding: _dizziness,
        tachycardia: _tachycardia,
        notes: _notesCtrl.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Morning log saved ✓')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving log: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // ─── Build ────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Morning Log'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── Progress bar ──
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Step ${_currentPage + 1} of $_totalPages',
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: (_currentPage + 1) / _totalPages,
                      minHeight: 8,
                      backgroundColor: const Color(0xFFE0E7FF),
                      valueColor: const AlwaysStoppedAnimation(
                          Color(0xFF4F7CFF)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // ── Pages ──
            Expanded(
              child: PageView(
                controller: _pageCtrl,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _currentPage = i),
                children: [
                  _buildHRVPage(),
                  _buildSleepPage(),
                  _buildSymptomsPage(),
                  _buildNotesPage(),
                ],
              ),
            ),

            // ── Bottom controls ──
            QuizBottomBar(
              onPause: _pauseSurvey,
              onStop: _stopSurvey,
              onBack: _currentPage > 0 ? _prevPage : null,
            ),
          ],
        ),
      ),
    );
  }

  // ── Page 1: HRV ───────────────────────────────────────────

  Widget _buildHRVPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _SectionCard(
            title: 'Heart Rate & HRV',
            leadingIcon: Icons.monitor_heart,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Heart Rate (bpm)',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 8),
                TextField(
                  controller: _hrCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    hintText: 'e.g. 72',
                    border: OutlineInputBorder(),
                    prefixIcon:
                        Icon(Icons.favorite, color: Color(0xFFE53935)),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('HRV (ms)',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 8),
                TextField(
                  controller: _hrvCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    hintText: 'e.g. 50',
                    border: OutlineInputBorder(),
                    prefixIcon:
                        Icon(Icons.timeline, color: Color(0xFF4F7CFF)),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                'PLUX HeartBIT connection coming soon')),
                      );
                    },
                    icon: const Icon(Icons.bluetooth),
                    label: const Text('Connect to PLUX HeartBIT'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF4F7CFF),
                      side: const BorderSide(color: Color(0xFF4F7CFF)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          QuizNextButton(onPressed: _nextPage),
        ],
      ),
    );
  }

  // ── Page 2: Sleep Quality ─────────────────────────────────

  Widget _buildSleepPage() {
    const labels = ['Awful', 'Bad', 'Fair', 'Good'];
    const values = [
      SleepQuality.awful,
      SleepQuality.bad,
      SleepQuality.fair,
      SleepQuality.good,
    ];
    const icons = [
      Icons.sentiment_very_dissatisfied,
      Icons.sentiment_dissatisfied,
      Icons.sentiment_satisfied,
      Icons.sentiment_very_satisfied,
    ];
    const colors = [
      Color(0xFFE53935),
      Color(0xFFFB8C00),
      Color(0xFFFBC02D),
      Color(0xFF43A047),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _SectionCard(
            title: 'Sleep Quality',
            leadingIcon: Icons.bedtime_outlined,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('How would you rate your sleep quality?',
                    style: TextStyle(fontSize: 15)),
                const SizedBox(height: 16),
                ...List.generate(4, (i) {
                  final selected = _sleep == values[i];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => setState(() => _sleep = values[i]),
                        icon: Icon(icons[i],
                            color: selected ? Colors.white : colors[i]),
                        label: Text(labels[i]),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: selected ? colors[i] : Colors.white,
                          foregroundColor:
                              selected ? Colors.white : Colors.black87,
                          side: BorderSide(
                              color: selected ? colors[i] : Colors.black26),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          textStyle: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 16),
          QuizNextButton(onPressed: _nextPage),
        ],
      ),
    );
  }

  // ── Page 3: Fatigue / Dizziness / Tachycardia ─────────────

  Widget _buildSymptomsPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _SectionCard(
            title: 'Abnormal Fatigue',
            leadingIcon: Icons.battery_alert_outlined,
            child: _SeveritySelector(
              value: _fatigue,
              onChanged: (v) => setState(() => _fatigue = v),
            ),
          ),
          const SizedBox(height: 12),
          _SectionCard(
            title: 'Dizziness Standing',
            leadingIcon: Icons.swap_vert_outlined,
            child: _SeveritySelector(
              value: _dizziness,
              onChanged: (v) => setState(() => _dizziness = v),
            ),
          ),
          const SizedBox(height: 12),
          _SectionCard(
            title: 'Tachycardia',
            leadingIcon: Icons.favorite_outline,
            child: _SeveritySelector(
              value: _tachycardia,
              onChanged: (v) => setState(() => _tachycardia = v),
            ),
          ),
          const SizedBox(height: 16),
          QuizNextButton(onPressed: _nextPage),
        ],
      ),
    );
  }

  // ── Page 4: Notes ─────────────────────────────────────────

  Widget _buildNotesPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _SectionCard(
            title: 'Additional Notes',
            leadingIcon: Icons.edit_note,
            child: TextField(
              controller: _notesCtrl,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'Any other observations...',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          QuizNextButton(
            onPressed: _saveLog,
            label: 'Save Log',
            icon: Icons.check,
          ),
        ],
      ),
    );
  }
}

/* ====================== Shared UI Helpers ====================== */

class _SeveritySelector extends StatelessWidget {
  const _SeveritySelector({required this.value, required this.onChanged});

  final Severity value;
  final ValueChanged<Severity> onChanged;

  static const _labels = ['None', 'Slight', 'Moderate', 'Severe'];
  static const _values = [
    Severity.none,
    Severity.slight,
    Severity.moderate,
    Severity.severe,
  ];
  static const _icons = [
    Icons.sentiment_very_satisfied,
    Icons.sentiment_satisfied,
    Icons.sentiment_dissatisfied,
    Icons.sentiment_very_dissatisfied,
  ];
  static const _colors = [
    Color(0xFF43A047),
    Color(0xFFFBC02D),
    Color(0xFFFB8C00),
    Color(0xFFE53935),
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(4, (i) {
        final selected = value == _values[i];
        return ChoiceChip(
          avatar: Icon(_icons[i],
              size: 18, color: selected ? Colors.white : _colors[i]),
          label: Text(_labels[i]),
          selected: selected,
          pressElevation: 0,
          onSelected: (_) => onChanged(_values[i]),
          selectedColor: _colors[i],
          labelStyle: TextStyle(
            color: selected ? Colors.white : Colors.black87,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        );
      }),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner(
      {required this.title, required this.subtitle, required this.icon});

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
                        fontWeight: FontWeight.w700, fontSize: 22)),
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
  const _SectionCard(
      {required this.title,
      required this.child,
      required this.leadingIcon});

  final String title;
  final Widget child;
  final IconData leadingIcon;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.black12.withValues(alpha: 0.06)),
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





class _MorningEntryTile extends StatelessWidget {
  const _MorningEntryTile({required this.entry});
  final MorningEntry entry;

  @override
  Widget build(BuildContext context) {
    final dt = entry.dateTime;
    final dateLabel =
        '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
    final timeLabel = _format(dt);

    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.black12.withValues(alpha: 0.06)),
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
                Text(timeLabel,
                    style: const TextStyle(color: Colors.black54)),
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