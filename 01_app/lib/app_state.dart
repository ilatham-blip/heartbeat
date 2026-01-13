import 'package:flutter/material.dart';

class MyAppState extends ChangeNotifier{
  final dizziness = <double>[];
  final nausea = <double>[];
  final users = ["iris", "peter"];

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
      return true;
    } else {return false;}
  }
}