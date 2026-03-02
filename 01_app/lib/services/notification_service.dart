import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:flutter/material.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  // Notification IDs
  static const int morningCheckInId = 1;
  static const int eveningCheckInId = 2;
  static const int measurementReminderId = 3;

  // Channel IDs
  static const String checkInChannelId = 'checkin_reminders';
  static const String measurementChannelId = 'measurement_reminders';

  Future<void> initialize() async {
    if (_initialized) return;

    // Initialize timezone
    tz_data.initializeTimeZones();

    // Android settings
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    const initSettings = InitializationSettings(android: androidSettings);

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create notification channels for Android
    await _createNotificationChannels();

    _initialized = true;
  }

  Future<void> _createNotificationChannels() async {
    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      // Check-in reminders channel
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          checkInChannelId,
          'Check-in Reminders',
          description: 'Daily morning and evening check-in reminders',
          importance: Importance.high,
        ),
      );

      // Measurement reminders channel
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          measurementChannelId,
          'Measurement Reminders',
          description: 'Heart rate measurement reminders',
          importance: Importance.defaultImportance,
        ),
      );
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap - could navigate to specific page
    debugPrint('Notification tapped: ${response.payload}');
  }

  Future<bool> requestPermissions() async {
    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      final granted = await androidPlugin.requestNotificationsPermission();
      return granted ?? false;
    }
    return false;
  }

  Future<void> scheduleAllNotifications() async {
    final prefs = await SharedPreferences.getInstance();

    // Morning check-in
    final morningEnabled = prefs.getBool('notif_morning') ?? true;
    if (morningEnabled) {
      final hour = prefs.getInt('morning_hour') ?? 8;
      final minute = prefs.getInt('morning_minute') ?? 0;
      await scheduleDailyNotification(
        id: morningCheckInId,
        title: '🌅 Morning Check-in',
        body: 'How did you sleep? Log your morning symptoms now.',
        hour: hour,
        minute: minute,
        channelId: checkInChannelId,
        payload: 'morning_checkin',
      );
    } else {
      await cancelNotification(morningCheckInId);
    }

    // Evening check-in
    final eveningEnabled = prefs.getBool('notif_evening') ?? true;
    if (eveningEnabled) {
      final hour = prefs.getInt('evening_hour') ?? 20;
      final minute = prefs.getInt('evening_minute') ?? 0;
      await scheduleDailyNotification(
        id: eveningCheckInId,
        title: '🌙 Evening Check-in',
        body: 'How was your day? Log your evening symptoms now.',
        hour: hour,
        minute: minute,
        channelId: checkInChannelId,
        payload: 'evening_checkin',
      );
    } else {
      await cancelNotification(eveningCheckInId);
    }

    // Measurement reminder (default: 10 AM)
    final measurementEnabled = prefs.getBool('notif_measurement') ?? true;
    if (measurementEnabled) {
      await scheduleDailyNotification(
        id: measurementReminderId,
        title: '❤️ Time for HRV Measurement',
        body: 'Take a moment to record your heart rate variability.',
        hour: 10,
        minute: 0,
        channelId: measurementChannelId,
        payload: 'measurement',
      );
    } else {
      await cancelNotification(measurementReminderId);
    }
  }

  Future<void> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    required String channelId,
    String? payload,
  }) async {
    // Cancel existing notification with this ID first
    await cancelNotification(id);

    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // If the time has already passed today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelId == checkInChannelId ? 'Check-in Reminders' : 'Measurement Reminders',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    final notificationDetails = NotificationDetails(android: androidDetails);

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // Repeat daily at this time
      payload: payload,
    );

    debugPrint('Scheduled notification $id for ${scheduledDate.toString()}');
  }

  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  // Show an immediate test notification
  Future<void> showTestNotification() async {
    const androidDetails = AndroidNotificationDetails(
      'test_channel',
      'Test Notifications',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    await _notifications.show(
      999,
      '✅ Notifications Working!',
      'HeartBIT notifications are set up correctly.',
      notificationDetails,
    );
  }

  // Get pending notifications (for debugging)
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }
}
