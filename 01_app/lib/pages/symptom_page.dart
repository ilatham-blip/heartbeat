import 'package:flutter/material.dart';
import 'package:heartbeat/app_state.dart';
import 'package:heartbeat/pages/quizzes/episode.dart';
import 'package:heartbeat/pages/quizzes/evening.dart';
import 'package:heartbeat/pages/quizzes/lifestyle.dart';
import 'package:heartbeat/pages/quizzes/morning.dart';
import 'package:provider/provider.dart';

class SymptomPage extends StatefulWidget {
  const SymptomPage({super.key});

  @override
  State<SymptomPage> createState() => _SymptomPage();
}

class _SymptomPage extends State<SymptomPage> {

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<MyAppState>(context, listen: true);
    Widget dailyWidget;
   if(DateTime.now().hour<15){
          dailyWidget = MorningQuiz();
        } else{
          dailyWidget = EveningQuiz();
        }

    return DefaultTabController(length: 3, child: 
    Scaffold(
      appBar: AppBar(
        title: Text("Symptom Logging"),
        bottom: TabBar(tabs: [
          Icon(Icons.sunny),
          Icon(Icons.monitor_heart),
          Icon(Icons.apple)
            ],
              ),
      ),
      body: TabBarView(children: [
        dailyWidget,
        EpisodeQuiz(),
        LifestyleQuiz()
      ])
    ));
  }
}
