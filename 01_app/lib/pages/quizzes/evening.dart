import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:heartbeat/app_state.dart';
import 'package:heartbeat/widgets/quiz_bottom_bar.dart';
import 'package:heartbeat/widgets/quiz_next_button.dart';

/// Evening quiz: landing page (embedded in tabs) + full-screen paged survey.
class EveningQuiz extends StatefulWidget {
  const EveningQuiz({super.key});
  @override
  State<EveningQuiz> createState() => _EveningQuizState();
}

class _EveningQuizState extends State<EveningQuiz> {
  void _startSurvey() {
    final appState = Provider.of<MyAppState>(context, listen: false);
    appState.clearEveningDraft();
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const _EveningSurveyScreen()),
    );
  }

  void _continueSurvey() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const _EveningSurveyScreen()),
    );
  }

  void _restartSurvey() {
    final appState = Provider.of<MyAppState>(context, listen: false);
    appState.clearEveningDraft();
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const _EveningSurveyScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<MyAppState>(context);
    final draft = appState.eveningDraft;
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
              title: 'Evening Time Log',
              subtitle: 'Review your day (5pm - 5am)',
              icon: Icons.nightlight_round,
            ),
            const SizedBox(height: 12),

            // ── Date & Time ──
            _SectionCard(
              title: 'Date & Time',
              leadingIcon: Icons.calendar_today,
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, size: 18, color: Colors.black54),
                  const SizedBox(width: 8),
                  Text(dateStr, style: const TextStyle(fontSize: 15)),
                  const Spacer(),
                  const Icon(Icons.access_time, size: 18, color: Colors.black54),
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
                icon: Icon(hasDraft ? Icons.play_arrow : Icons.play_arrow_rounded),
                label: Text(hasDraft ? 'Continue Survey' : 'Start Survey'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F7CFF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),

            // ── Recent entries ──
            _SectionCard(
              title: 'Recent Entries',
              leadingIcon: Icons.history,
              child: appState.eveningEntries.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text('No entries yet', style: TextStyle(color: Colors.black45)),
                    )
                  : Column(
                      children: appState.eveningEntries
                          .take(5)
                          .map((e) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: _RecentEntryTile(
                                  dateLabel:
                                      '${e.dateTime.day.toString().padLeft(2, '0')}/${e.dateTime.month.toString().padLeft(2, '0')}/${e.dateTime.year}',
                                  timeLabel:
                                      '${e.dateTime.hour.toString().padLeft(2, '0')}:${e.dateTime.minute.toString().padLeft(2, '0')}',
                                  heartRate: '${e.heartRateBpm} bpm',
                                  hrv: '${e.hrvMs} ms',
                                  fatigue: _fatigueLabelFromScore(e.fatigueScore),
                                ),
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

  static String _fatigueLabelFromScore(int v) {
    switch (v) {
      case 0: return 'None';
      case 1: return 'Slight';
      case 2: return 'Moderate';
      case 3: return 'Severe';
      default: return 'Unknown';
    }
  }
}

// ═══════════════════════════════════════════════════════════
// Full-screen survey route — hides bottom nav & tab bar
// ═══════════════════════════════════════════════════════════

class _EveningSurveyScreen extends StatefulWidget {
  const _EveningSurveyScreen();
  @override
  State<_EveningSurveyScreen> createState() => _EveningSurveyScreenState();
}

class _EveningSurveyScreenState extends State<_EveningSurveyScreen> {
  int _currentPage = 0;
  static const int _totalPages = 4;

  DateTime _date = DateTime.now();
  TimeOfDay _time = TimeOfDay.now();
  final TextEditingController _hrCtrl = TextEditingController();
  final TextEditingController _hrvCtrl = TextEditingController();
  int? _fatigueScore;
  final Set<String> _selectedSymptoms = {};
  final TextEditingController _notesCtrl = TextEditingController();
  final PageController _pageCtrl = PageController();

  final List<String> _symptomOptions = const [
    'Muscle pain',
    'Nausea',
    'Gastrointestinal problems (stomach-ache, diarrhoea, constipation)',
    'Difficulties in concentration',
    'Difficult breathing/dyspnoea, both at effort and rest',
    'Temperature Changes (feeling abnormally hot or cold)',
    'Dizziness, feeling that you are going to faint after being upright',
    'Palpitations, high pulse, or feeling heart beating irregularly',
  ];

  @override
  void initState() {
    super.initState();
    // If a draft exists, restore it
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appState = Provider.of<MyAppState>(context, listen: false);
      final draft = appState.eveningDraft;
      if (draft != null) {
        setState(() {
          _currentPage = draft.currentPage;
          _date = draft.date;
          _time = draft.time;
          _hrCtrl.text = draft.heartRateBpm?.toString() ?? '';
          _hrvCtrl.text = draft.hrvMs?.toString() ?? '';
          _fatigueScore = draft.fatigueScore;
          _selectedSymptoms
            ..clear()
            ..addAll(draft.selectedSymptoms);
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

  // ─── Helpers ───────────────────────────────────────────────

  EveningDraft _buildDraft() => EveningDraft(
        currentPage: _currentPage,
        date: _date,
        time: _time,
        heartRateBpm: int.tryParse(_hrCtrl.text),
        hrvMs: int.tryParse(_hrvCtrl.text),
        fatigueScore: _fatigueScore,
        selectedSymptoms: Set.of(_selectedSymptoms),
        notes: _notesCtrl.text,
      );

  void _pauseSurvey() {
    final appState = Provider.of<MyAppState>(context, listen: false);
    appState.pauseEveningReview(_buildDraft());
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
              child: const Text('Stop', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirmed == true) {
      appState.clearEveningDraft();
      if (mounted) Navigator.of(context).pop();
    }
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageCtrl.nextPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      setState(() => _currentPage++);
    }
  }

  void _prevPage() {
    if (_currentPage > 0) {
      _pageCtrl.previousPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      setState(() => _currentPage--);
    }
  }

  void _saveLog() async {
    final hr = int.tryParse(_hrCtrl.text) ?? 0;
    final hrv = int.tryParse(_hrvCtrl.text) ?? 0;

    final appState = Provider.of<MyAppState>(context, listen: false);
    try {
      await appState.saveEveningReview(
        date: _date,
        time: _time,
        heartRateBpm: hr,
        hrvMs: hrv,
        fatigueScore: _fatigueScore ?? 0,
        baselineSymptoms: _selectedSymptoms.toList(),
        notes: _notesCtrl.text.trim(),
      );

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  // ─── Build ─────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        automaticallyImplyLeading: false, // we handle our own nav
        title: const Text('Evening Log'),
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
                  _buildFatiguePage(),
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

  // ── Page 1: HRV ────────────────────────────────────────────

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
                    prefixIcon: Icon(Icons.favorite, color: Color(0xFFE53935)),
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
                    prefixIcon: Icon(Icons.timeline, color: Color(0xFF4F7CFF)),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content:
                                Text('Polar Heartbeat integration coming soon')),
                      );
                    },
                    icon: const Icon(Icons.bluetooth),
                    label: const Text('Connect to Polar Heartbeat'),
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

  // ── Page 2: Fatigue ────────────────────────────────────────

  Widget _buildFatiguePage() {
    const labels = ['None', 'Slight', 'Moderate', 'Severe'];
    const icons = [
      Icons.sentiment_very_satisfied,
      Icons.sentiment_satisfied,
      Icons.sentiment_dissatisfied,
      Icons.sentiment_very_dissatisfied,
    ];
    const colors = [
      Color(0xFF43A047),
      Color(0xFFFBC02D),
      Color(0xFFFB8C00),
      Color(0xFFE53935),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _SectionCard(
            title: 'Abnormal Fatigue',
            leadingIcon: Icons.battery_alert,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('How would you rate your abnormal fatigue today?',
                    style: TextStyle(fontSize: 15)),
                const SizedBox(height: 16),
                ...List.generate(4, (i) {
                  final selected = _fatigueScore == i;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => setState(() => _fatigueScore = i),
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

  // ── Page 3: Symptoms ───────────────────────────────────────

  Widget _buildSymptomsPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _SectionCard(
            title: 'Baseline Symptoms',
            leadingIcon: Icons.checklist,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Select any symptoms you experienced today:',
                    style: TextStyle(fontSize: 15)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _symptomOptions.map((label) {
                    final selected = _selectedSymptoms.contains(label);
                    return FilterChip(
                      label: Text(label),
                      selected: selected,
                      selectedColor: const Color(0xFFD6E4FF),
                      checkmarkColor: const Color(0xFF4F7CFF),
                      onSelected: (isSel) {
                        setState(() {
                          if (isSel) {
                            _selectedSymptoms.add(label);
                          } else {
                            _selectedSymptoms.remove(label);
                          }
                        });
                      },
                    );
                  }).toList(),
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

  // ── Page 4: Notes ──────────────────────────────────────────

  Widget _buildNotesPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _SectionCard(
            title: 'Additional Notes',
            leadingIcon: Icons.edit_note,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _notesCtrl,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    hintText: 'How was your day overall?',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
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
                    style:
                        const TextStyle(color: Colors.black54, fontSize: 13)),
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
      {required this.title, required this.child, required this.leadingIcon});

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