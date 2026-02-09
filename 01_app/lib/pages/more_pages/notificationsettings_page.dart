import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const kBrandBlue = Color(0xFF1E40AF);
const kBackgroundWhite = Color(0xFFFAFAFA);

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() => _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  bool _isLoading = true;

  // Notification toggles
  bool _morningReminder = true;
  bool _eveningReminder = true;
  bool _measurementReminder = true;
  bool _weeklyReport = true;
  bool _studyUpdates = false;

  // Reminder times
  TimeOfDay _morningTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _eveningTime = const TimeOfDay(hour: 20, minute: 0);

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _morningReminder = prefs.getBool('notif_morning') ?? true;
      _eveningReminder = prefs.getBool('notif_evening') ?? true;
      _measurementReminder = prefs.getBool('notif_measurement') ?? true;
      _weeklyReport = prefs.getBool('notif_weekly') ?? true;
      _studyUpdates = prefs.getBool('notif_study') ?? false;

      final morningHour = prefs.getInt('morning_hour') ?? 8;
      final morningMinute = prefs.getInt('morning_minute') ?? 0;
      _morningTime = TimeOfDay(hour: morningHour, minute: morningMinute);

      final eveningHour = prefs.getInt('evening_hour') ?? 20;
      final eveningMinute = prefs.getInt('evening_minute') ?? 0;
      _eveningTime = TimeOfDay(hour: eveningHour, minute: eveningMinute);

      _isLoading = false;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notif_morning', _morningReminder);
    await prefs.setBool('notif_evening', _eveningReminder);
    await prefs.setBool('notif_measurement', _measurementReminder);
    await prefs.setBool('notif_weekly', _weeklyReport);
    await prefs.setBool('notif_study', _studyUpdates);

    await prefs.setInt('morning_hour', _morningTime.hour);
    await prefs.setInt('morning_minute', _morningTime.minute);
    await prefs.setInt('evening_hour', _eveningTime.hour);
    await prefs.setInt('evening_minute', _eveningTime.minute);
  }

  Future<void> _pickTime(bool isMorning) async {
    final initialTime = isMorning ? _morningTime : _eveningTime;
    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
    if (picked != null) {
      setState(() {
        if (isMorning) {
          _morningTime = picked;
        } else {
          _eveningTime = picked;
        }
      });
      _saveSettings();
    }
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundWhite,
      appBar: AppBar(
        title: const Text(
          "Notification Settings",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Daily Check-in Reminders
                  _buildSection(
                    title: 'Daily Check-in Reminders',
                    icon: Icons.alarm,
                    iconColor: kBrandBlue,
                    children: [
                      _buildReminderTile(
                        title: 'Morning Check-in',
                        subtitle: 'Log your sleep quality and morning symptoms',
                        value: _morningReminder,
                        time: _morningTime,
                        onChanged: (val) {
                          setState(() => _morningReminder = val);
                          _saveSettings();
                        },
                        onTimeTap: () => _pickTime(true),
                      ),
                      const Divider(height: 1),
                      _buildReminderTile(
                        title: 'Evening Check-in',
                        subtitle: 'Record your daily symptoms and activities',
                        value: _eveningReminder,
                        time: _eveningTime,
                        onChanged: (val) {
                          setState(() => _eveningReminder = val);
                          _saveSettings();
                        },
                        onTimeTap: () => _pickTime(false),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Measurement Reminders
                  _buildSection(
                    title: 'Measurement Reminders',
                    icon: Icons.favorite,
                    iconColor: Colors.red,
                    children: [
                      _buildToggleTile(
                        title: 'Heart Rate Measurement',
                        subtitle: 'Reminder to take your daily HRV measurement',
                        value: _measurementReminder,
                        onChanged: (val) {
                          setState(() => _measurementReminder = val);
                          _saveSettings();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Reports & Updates
                  _buildSection(
                    title: 'Reports & Updates',
                    icon: Icons.insights,
                    iconColor: Colors.purple,
                    children: [
                      _buildToggleTile(
                        title: 'Weekly Summary',
                        subtitle: 'Get a weekly report of your health trends',
                        value: _weeklyReport,
                        onChanged: (val) {
                          setState(() => _weeklyReport = val);
                          _saveSettings();
                        },
                      ),
                      const Divider(height: 1),
                      _buildToggleTile(
                        title: 'Study Updates',
                        subtitle: 'News from the research team',
                        value: _studyUpdates,
                        onChanged: (val) {
                          setState(() => _studyUpdates = val);
                          _saveSettings();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Info Box
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue.shade700),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Notifications help you stay consistent with your health tracking, which improves data quality for research.',
                            style: TextStyle(
                              color: Colors.blue.shade700,
                              fontSize: 13,
                            ),
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
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor.withAlpha(26),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ...children,
        ],
      ),
    );
  }

  Widget _buildReminderTile({
    required String title,
    required String subtitle,
    required bool value,
    required TimeOfDay time,
    required ValueChanged<bool> onChanged,
    required VoidCallback onTimeTap,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 12,
                  ),
                ),
                if (value) ...[
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: onTimeTap,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: kBrandBlue.withAlpha(26),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.access_time, size: 16, color: kBrandBlue),
                          const SizedBox(width: 6),
                          Text(
                            _formatTime(time),
                            style: TextStyle(
                              color: kBrandBlue,
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(Icons.edit, size: 14, color: kBrandBlue),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: kBrandBlue,
          ),
        ],
      ),
    );
  }

  Widget _buildToggleTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: kBrandBlue,
          ),
        ],
      ),
    );
  }
}