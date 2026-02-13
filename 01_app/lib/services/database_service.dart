import 'package:supabase_flutter/supabase_flutter.dart';

class DatabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  // ---------------------------------------------------------------------------
  // MORNING CHECK-IN
  // ---------------------------------------------------------------------------
  Future<void> saveMorningCheckIn(Map<String, dynamic> data) async {
    // data should correspond to columns in 'morning_checkins' table
    // e.g. user_id, date, sleep_quality, fatigue, dizziness, tachycardia, notes
    await _client.from('morning_checkins').insert(data);
  }

  // ---------------------------------------------------------------------------
  // EVENING CHECK-IN
  // ---------------------------------------------------------------------------
  Future<void> saveEveningCheckIn(Map<String, dynamic> data) async {
    // data should correspond to columns in 'evening_checkins' table
    await _client.from('evening_checkins').insert(data);
  }

  // ---------------------------------------------------------------------------
  // LIFESTYLE LOG
  // ---------------------------------------------------------------------------
  Future<void> saveLifestyleLog(Map<String, dynamic> data) async {
    // data should correspond to columns in 'lifestyle_logs' table
    await _client.from('lifestyle_logs').insert(data);
  }

  // ---------------------------------------------------------------------------
  // POTS EPISODE
  // ---------------------------------------------------------------------------
  Future<void> saveEpisode(Map<String, dynamic> data) async {
    // data should correspond to columns in 'episodes' table
    await _client.from('episodes').insert(data);
  }
}
