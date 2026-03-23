import 'package:flutter/material.dart';
import 'package:heartbeat/pages/app_layout.dart';
import 'package:heartbeat/pages/user_login_page.dart';
import 'package:heartbeat/services/database_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Shared enums for morning page
enum SleepQuality { awful, bad, fair, good }
enum Severity { none, slight, moderate, severe }
class EveningEntry {
  EveningEntry({
    required this.dateTime,
    required this.heartRateBpm,
    required this.hrvMs,
    required this.fatigueScore,
    required this.baselineSymptoms,
    required this.notes,
  });

  final DateTime dateTime;
  final int heartRateBpm;
  final int hrvMs;
  final int fatigueScore; // 0=None,1=Slight,2=Moderate,3=Severe
  final List<String> baselineSymptoms;
  final String notes;
}

/// In-memory draft for a paused evening survey.
class EveningDraft {
  int currentPage;
  DateTime date;
  TimeOfDay time;
  int? heartRateBpm;
  int? hrvMs;
  int? fatigueScore;   // 0=None,1=Slight,2=Moderate,3=Severe
  Set<String> selectedSymptoms;
  String notes;

  EveningDraft({
    this.currentPage = 0,
    DateTime? date,
    TimeOfDay? time,
    this.heartRateBpm,
    this.hrvMs,
    this.fatigueScore,
    Set<String>? selectedSymptoms,
    this.notes = '',
  })  : date = date ?? DateTime.now(),
        time = time ?? TimeOfDay.now(),
        selectedSymptoms = selectedSymptoms ?? {};
}
class MorningEntry {
  MorningEntry({
    required this.dateTime,
    required this.sleepQuality,
    required this.fatigue,
    required this.dizzinessStanding,
    required this.tachycardia,
    required this.notes,
  });

  final DateTime dateTime;
  final SleepQuality sleepQuality;
  final Severity fatigue;
  final Severity dizzinessStanding;
  final Severity tachycardia;
  final String notes;
}

class EpisodeEntry {
  EpisodeEntry({
    required this.dateTime,
    required this.scores,
    required this.notes,
  });

  final DateTime dateTime;
  final Map<String, double> scores;
  final String notes;
}

class LifestyleEntry {
  LifestyleEntry({
    required this.date,
    required this.hotPlace,
    required this.refinedCarbs,
    required this.standingMins,
    required this.carbsGrams,
    required this.waterLitres,
    required this.alcoholUnits,
    required this.restTooMuch,
    required this.exMildMins,
    required this.exModerateMins,
    required this.exIntenseMins,
    required this.onPeriod,
    required this.stressLevel,
    required this.notes,
  });

  final DateTime date;
  final bool hotPlace;
  final bool refinedCarbs;
  final int standingMins;
  final int carbsGrams;
  final double waterLitres;
  final int alcoholUnits;
  final bool restTooMuch;
  final int exMildMins;
  final int exModerateMins;
  final int exIntenseMins;
  final bool onPeriod;
  final int stressLevel;
  final String notes;
}

/// In-memory draft for a paused morning survey.
class MorningDraft {
  int currentPage;
  DateTime date;
  TimeOfDay time;
  int? heartRateBpm;
  int? hrvMs;
  SleepQuality sleep;
  Severity fatigue;
  Severity dizziness;
  Severity tachycardia;
  String notes;

  MorningDraft({
    this.currentPage = 0,
    DateTime? date,
    TimeOfDay? time,
    this.heartRateBpm,
    this.hrvMs,
    this.sleep = SleepQuality.fair,
    this.fatigue = Severity.none,
    this.dizziness = Severity.none,
    this.tachycardia = Severity.none,
    this.notes = '',
  })  : date = date ?? DateTime.now(),
        time = time ?? TimeOfDay.now();
}

/// In-memory draft for a paused POTS episode survey.
class EpisodeDraft {
  int currentPage;
  DateTime date;
  TimeOfDay time;
  Map<String, double> symptomScores;
  String notes;

  EpisodeDraft({
    this.currentPage = 0,
    DateTime? date,
    TimeOfDay? time,
    Map<String, double>? symptomScores,
    this.notes = '',
  })  : date = date ?? DateTime.now(),
        time = time ?? TimeOfDay.now(),
        symptomScores = symptomScores ?? {};
}

/// In-memory draft for a paused Lifestyle survey.
class LifestyleDraft {
  int currentPage;
  DateTime date;
  bool hotPlace;
  bool refinedCarbs;
  double standingMins;
  double carbsGrams;
  double waterLitres;
  double alcoholUnits;
  bool restTooMuch;
  double exMild;
  double exModerate;
  double exIntense;
  bool onPeriod;
  double stressLevel;
  String notes;

  LifestyleDraft({
    this.currentPage = 0,
    DateTime? date,
    this.hotPlace = false,
    this.refinedCarbs = false,
    this.standingMins = 0,
    this.carbsGrams = 0,
    this.waterLitres = 0,
    this.alcoholUnits = 0,
    this.restTooMuch = false,
    this.exMild = 0,
    this.exModerate = 0,
    this.exIntense = 0,
    this.onPeriod = false,
    this.stressLevel = 0,
    this.notes = '',
  }) : date = date ?? DateTime.now();
}

class MyAppState extends ChangeNotifier{
  final DatabaseService _databaseService = DatabaseService();

  String _dateOnly(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  String _timeWithSeconds(TimeOfDay time) {
    final second = DateTime.now().second.toString().padLeft(2, '0');
    final hh = time.hour.toString().padLeft(2, '0');
    final mm = time.minute.toString().padLeft(2, '0');
    return '$hh:$mm:$second';
  }

  User _requireCurrentUser() {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      throw StateError('No authenticated user session. Please sign in again.');
    }
    return user;
  }

  final dizziness = <double>[];
  final nausea = <double>[];
  final users = ["iris", "peter"];
  int pageindex = 0;


  Map<String, double> episodeScores = {
    "Dizziness when standing": 0,
    "Heart racing and palpitations": 0,
    "Chest pain": 0,
    "Headache": 0, 
    "Difficulty concentrating": 0,
    "Muscle pain": 0, 
    "Difficulty breathing": 0
    
  };
    // ---- helpers ----
  double _avg(List<double> xs) {
    if (xs.isEmpty) return 0;
    return xs.reduce((a, b) => a + b) / xs.length;
  }

  // ---- averages for the tracker page ----
  double get dizzinessAvg => _avg(dizziness);

  // if you start filling the nausea list, this will work automatically
  double get nauseaAvg => _avg(nausea);

  // reuse some episodeScores as “summary” metrics
  double get fatigueAvg =>
      episodeScores["Difficulty concentrating"] ?? 0;

  double get hydrationAvg =>
      episodeScores["Difficulty breathing"] ?? 0;

  // More robust averages that consider morning/evening/lifestyle inputs
  double get combinedDizzinessAvg {
    final List<double> vals = [];
    final listAvg = _avg(dizziness);
    if (listAvg > 0) vals.add(listAvg);
    final morningVal = morningScores["Dizziness when standing"] ?? 0;
    if (morningVal > 0) vals.add(morningVal);
    final episodeVal = episodeScores["Dizziness when standing"] ?? 0;
    if (episodeVal > 0) vals.add(episodeVal);
    if (vals.isEmpty) return 0;
    return _avg(vals);
  }

  double get combinedFatigueAvg {
    final List<double> vals = [];
    final episodeVal = episodeScores["Difficulty concentrating"] ?? 0;
    if (episodeVal > 0) vals.add(episodeVal);
    final morningVal = morningScores["Fatigue"] ?? 0;
    if (morningVal > 0) vals.add(morningVal);
    final eveningVal = eveningScores["Abnormal Fatigue after rest"] ?? 0;
    if (eveningVal > 0) vals.add(eveningVal);
    if (vals.isEmpty) return 0;
    return _avg(vals);
  }

  double get combinedHydrationAvg {
    final List<double> vals = [];
    final episodeVal = episodeScores["Difficulty breathing"] ?? 0;
    if (episodeVal > 0) vals.add(episodeVal);
    final water = lifestyleScores["water_litres"] ?? 0;
    if (water > 0) {
      // scale 0..5 litres to 0..10
      vals.add((water / 5.0) * 10.0);
    }
    if (vals.isEmpty) return 0;
    return _avg(vals);
  }

  // ---- simple series for the multi‑symptom chart ----
  List<double> get fatigueSeries =>
      dizziness.isNotEmpty ? List<double>.filled(dizziness.length, combinedFatigueAvg) : [combinedFatigueAvg];

  List<double> get hydrationSeries =>
      hydration.isNotEmpty ? hydration : [(lifestyleScores["water_litres"] ?? 0) / 5.0 * 10.0];

  void updateEpisodeScore(String symptom, double newValue) {
    episodeScores[symptom] = newValue;
    notifyListeners(); 
  }

  void updateMorningScore(String symptom, double newValue) {
    morningScores[symptom] = newValue;
    // mirror into episode summary for tracker use
    if (symptom == 'Dizziness when standing') {
      updateEpisodeScore('Dizziness when standing', newValue);
      try {
        dizziness.add(newValue);
      } catch (_) {}
    }
    if (symptom == 'Fatigue') {
      updateEpisodeScore('Difficulty concentrating', newValue);
    }
    notifyListeners();
  }

  Future<void> saveEpisode({
    required DateTime date,
    required TimeOfDay time,
    required Map<String, double> scores,
    required String notes,
  }) async {
    // Update in-memory episode summary so tracker shows recent values.
    scores.forEach((k, v) {
      episodeScores[k] = v;
    });

    // If the episode included a dizziness value, add it to the trend list
    // so the charts update over time.
    final dizzinessKey = 'Dizziness when standing';
    if (scores.containsKey(dizzinessKey)) {
      try {
        final val = scores[dizzinessKey] ?? 0;
        dizziness.add(val);
      } catch (_) {}
    }

    episodeEntries.insert(0, EpisodeEntry(
      dateTime: DateTime(date.year, date.month, date.day, time.hour, time.minute),
      scores: scores,
      notes: notes,
    ));

    notifyListeners();

    final user = _requireCurrentUser();
    await _databaseService.saveEpisode({
      'user_id': user.id,
      'date': _dateOnly(date),
      'time': '${time.hour}:${time.minute}',
      'scores': scores,
      'notes': notes,
    });
  }

  EpisodeDraft? episodeDraft;

  void pauseEpisodeSurvey(EpisodeDraft draft) {
    episodeDraft = draft;
    notifyListeners();
  }

  void clearEpisodeDraft() {
    episodeDraft = null;
    notifyListeners();
  }

  Map<String, double> morningScores = {
    "Sleep Quality": 0,
    "Fatigue": 0,
    "Dizziness when standing": 0,
    "Heart racing and palpitations": 0, 
  };



  Map<String, double> eveningScores = {
    "Abnormal Fatigue after rest": 0

  };

  void updateEveningScore(String symptom, double newValue) {
    eveningScores[symptom] = newValue;
    if (symptom == 'Abnormal Fatigue after rest') {
      updateEpisodeScore('Difficulty concentrating', newValue);
    }
    notifyListeners(); 
  }

  Map<String, double> lifestyleScores= {
    "standing_mins": 0, // in minutes 0->240, int
    "carbs_grams": 50, // 0->400, int
    "water_litres": 0, // 0->5, double
    "alcohol_units": 0, // 0->15, int
    "exercise_mild": 0, // 0->180
    "period_day": 0, // 0->1
    "stress_level": 0, // This uses your 0-3 scale
  };

  void updateLifestyleScores(String key, double value) {
    lifestyleScores[key] = value;
    if (key == 'water_litres') {
      // update hydration episode metric scaled to 0..10
      final scaled = (value / 5.0) * 10.0;
      updateEpisodeScore('Difficulty breathing', scaled);
    }
    notifyListeners();
  }



  Widget home_page = UserLoginPage();

  int symptomTabIndex = 0;

  void changeIndex(int value, {int symptomTab = 0}){
    pageindex = value;
    symptomTabIndex = symptomTab;
    notifyListeners();
  }

  void add(var variable, var value){
    try{
      variable.add(value);
      //printToConsole(variable.toString());
    }
    catch(error){
      //print(error.toString());
    }
  }

  bool verify(String value){
    if(users.contains(value)){
      home_page = AppLayout();
      notifyListeners();
      return true;
    } else {return false;}
  }
  final List<EveningEntry> eveningEntries = [];
  EveningDraft? eveningDraft;

  Future<void> saveEveningReview({
    required DateTime date,
    required TimeOfDay time,
    required int heartRateBpm,
    required int hrvMs,
    required int fatigueScore,
    required List<String> baselineSymptoms,
    required String notes,
    required List<double> ppgData,
    required List<double> ecgData,
  }) async {
    final dt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    eveningEntries.insert(0, EveningEntry(
      dateTime: dt,
      heartRateBpm: heartRateBpm,
      hrvMs: hrvMs,
      fatigueScore: fatigueScore,
      baselineSymptoms: baselineSymptoms,
      notes: notes,
    ));
    eveningDraft = null;
    // Map the evening fatigue score (0-3) to a 0-10 scale and update
    // the episode summary so tracker widgets reflect this input.
    try {
      final scaledFatigue = (fatigueScore / 3.0) * 10.0;
      updateEpisodeScore('Difficulty concentrating', scaledFatigue);
    } catch (_) {}

    notifyListeners();

    final user = _requireCurrentUser();
    await _databaseService.saveEveningCheckIn({
      'user_id': user.id,
      'date': DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
        DateTime.now().second,
      ).toIso8601String(),
      'time': _timeWithSeconds(time),
      'heart_rate': heartRateBpm,
      'hrv': hrvMs,
      'fatigue_score': fatigueScore,
      'symptoms': baselineSymptoms,
      'notes': notes,
      'ppg_data': ppgData,
      'ecg_data': ecgData,
    });
  }

  void pauseEveningReview(EveningDraft draft) {
    eveningDraft = draft;
    notifyListeners();
  }

  void clearEveningDraft() {
    eveningDraft = null;
    notifyListeners();
  }
  // Morning entries storage
  final List<MorningEntry> _morningEntries = [];
  List<MorningEntry> get morningEntries => List.unmodifiable(_morningEntries);
  MorningDraft? morningDraft;

  // Episode entries storage
  final List<EpisodeEntry> episodeEntries = [];

  // Lifestyle entries storage
  final List<LifestyleEntry> _lifestyleEntries = [];
  final List<double> hydration = [];
  List<LifestyleEntry> get lifestyleEntries => List.unmodifiable(_lifestyleEntries);
  LifestyleDraft? lifestyleDraft;

  // Save method used by MorningQuiz
  Future<void> saveMorningCheckIn({
    required DateTime date,
    required TimeOfDay time,
    required SleepQuality sleepQuality,
    required Severity fatigue,
    required Severity dizzinessStanding,
    required Severity tachycardia,
    required String notes,
    required List<double> ppgData,
    required List<double> ecgData,
  }) async {
    final dt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    _morningEntries.insert(
      0,
      MorningEntry(
        dateTime: dt,
        sleepQuality: sleepQuality,
        fatigue: fatigue,
        dizzinessStanding: dizzinessStanding,
        tachycardia: tachycardia,
        notes: notes,
      ),
    );
    morningDraft = null;
    // Convert severity (0..3) into a 0..10 scale for the tracker and
    // update episode summary values and trend lists.
    try {
      final fatigueVal = (fatigue.index / 3.0) * 10.0;
      final dizzinessVal = (dizzinessStanding.index / 3.0) * 10.0;
      updateEpisodeScore('Difficulty concentrating', fatigueVal);
      updateEpisodeScore('Dizziness when standing', dizzinessVal);
      dizziness.add(dizzinessVal);
    } catch (_) {}

    notifyListeners();

    final user = _requireCurrentUser();
    await _databaseService.saveMorningCheckIn({
      'user_id': user.id,
      'date': _dateOnly(date),
      'time': '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
      'sleep_quality': sleepQuality.index,
      'fatigue': fatigue.index,
      'dizziness': dizzinessStanding.index,
      'tachycardia': tachycardia.index,
      'notes': notes,
      'ppg_data': ppgData,
      'ecg_data': ecgData,
    });
  }

  void pauseMorningCheckIn(MorningDraft draft) {
    morningDraft = draft;
    notifyListeners();
  }

  void clearMorningDraft() {
    morningDraft = null;
    notifyListeners();
  }

    void pauseLifestyleSurvey(LifestyleDraft draft) {
      lifestyleDraft = draft;
      notifyListeners();
    }

    void clearLifestyleDraft() {
      lifestyleDraft = null;
      notifyListeners();
    }

    Future<void> saveLifestyleEntry({
      required DateTime date,
      required bool hotPlace,
      required bool refinedCarbs,
      required int standingMins,
      required int carbsGrams,
      required double waterLitres,
      required int alcoholUnits,
      required bool restTooMuch,
      required int exMildMins,
      required int exModerateMins,
      required int exIntenseMins,
      required bool onPeriod,
      required int stressLevel,
      required String notes,
    }) async {
      _lifestyleEntries.insert(
        0,
        LifestyleEntry(
          date: date,
          hotPlace: hotPlace,
          refinedCarbs: refinedCarbs,
          standingMins: standingMins,
          carbsGrams: carbsGrams,
          waterLitres: waterLitres,
          alcoholUnits: alcoholUnits,
          restTooMuch: restTooMuch,
          exMildMins: exMildMins,
          exModerateMins: exModerateMins,
          exIntenseMins: exIntenseMins,
          onPeriod: onPeriod,
          stressLevel: stressLevel,
          notes: notes,
        ),
      );
      lifestyleDraft = null;
      hydration.insert(0, (waterLitres / 5.0) * 10.0 );
      notifyListeners();

      final user = _requireCurrentUser();
      await _databaseService.saveLifestyleLog({
        'user_id': user.id,
        'date': _dateOnly(date),
        'hot_place': hotPlace,
        'refined_carbs': refinedCarbs,
        'standing_mins': standingMins,
        'carbs_grams': carbsGrams,
        'water_litres': waterLitres,
        'alcohol_units': alcoholUnits,
        'rest_too_much': restTooMuch,
        'ex_mild': exMildMins,
        'ex_moderate': exModerateMins,
        'ex_intense': exIntenseMins,
        'on_period': onPeriod,
        'stress_level': stressLevel,
        'notes': notes,
      });
    }
}
 