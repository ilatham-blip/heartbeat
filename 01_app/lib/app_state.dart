import 'package:flutter/material.dart';
import 'package:heartbeat/pages/app_layout.dart';
import 'package:heartbeat/pages/user_login_page.dart';
import 'package:flutter/material.dart';

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
  final int fatigueScore;            // 0..100
  final List<String> baselineSymptoms;
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

  void changeIndex(int value){
    pageindex = value;
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
    eveningEntries.add(EveningEntry(
      dateTime: dt,
      heartRateBpm: heartRateBpm,
      hrvMs: hrvMs,
      fatigueScore: fatigueScore,
      baselineSymptoms: baselineSymptoms,
      notes: notes,
    ));
    notifyListeners();
  }
}