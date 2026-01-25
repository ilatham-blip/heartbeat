import 'package:flutter/material.dart';
import 'package:heartbeat/pages/app_layout.dart';
import 'package:heartbeat/pages/user_login_page.dart';

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
}