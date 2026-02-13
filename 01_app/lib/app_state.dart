import 'package:flutter/material.dart';
import 'package:heartbeat/pages/app_layout.dart';
import 'package:heartbeat/pages/user_login_page.dart';

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
class MyAppState extends ChangeNotifier{
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

  void updateEpisodeScore(String symptom, double newValue) {
    episodeScores[symptom] = newValue;
    notifyListeners(); 
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

  void updateMorningScore(String symptom, double newValue) {
    morningScores[symptom] = newValue;
    notifyListeners(); 
  }


  Map<String, double> eveningScores = {
    "Abnormal Fatigue after rest": 0

  };

  void updateEveningScore(String symptom, double newValue) {
    eveningScores[symptom] = newValue;
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

  void saveEveningReview({
    required DateTime date,
    required TimeOfDay time,
    required int heartRateBpm,
    required int hrvMs,
    required int fatigueScore,
    required List<String> baselineSymptoms,
    required String notes,
  }) {
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
    notifyListeners();
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

  // Save method used by MorningQuiz
  void saveMorningCheckIn({
    required DateTime date,
    required TimeOfDay time,
    required SleepQuality sleepQuality,
    required Severity fatigue,
    required Severity dizzinessStanding,
    required Severity tachycardia,
    required String notes,
  }) {
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
    notifyListeners();
  }

  void pauseMorningCheckIn(MorningDraft draft) {
    morningDraft = draft;
    notifyListeners();
  }

  void clearMorningDraft() {
    morningDraft = null;
    notifyListeners();
  }
    final List<LifestyleEntry> _lifestyleEntries = [];
    List<LifestyleEntry> get lifestyleEntries => List.unmodifiable(_lifestyleEntries);
    LifestyleDraft? lifestyleDraft;

    void pauseLifestyleSurvey(LifestyleDraft draft) {
      lifestyleDraft = draft;
      notifyListeners();
    }

    void clearLifestyleDraft() {
      lifestyleDraft = null;
      notifyListeners();
    }

    void saveLifestyleEntry({
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
    }) {
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
      notifyListeners();
    }
}