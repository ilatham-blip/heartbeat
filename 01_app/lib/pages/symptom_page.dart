import 'package:flutter/material.dart';
import 'package:heartbeat/app_theme.dart';
import 'package:heartbeat/app_state.dart';
import 'package:heartbeat/pages/quizzes/episode.dart' ;
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
   if(DateTime.now().hour<17){
          dailyWidget = MorningQuiz();
        } else{
          dailyWidget = EveningQuiz();
        }

    final tabIndex = appState.symptomTabIndex;
    // Reset after consuming so it doesn't stick
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (appState.symptomTabIndex != 0) {
        appState.symptomTabIndex = 0;
      }
    });

    return DefaultTabController(
      length: 3,
      initialIndex: tabIndex,
      child: Scaffold(
        backgroundColor: kBackgroundColor,
        appBar: AppBar(
          backgroundColor: kBrandBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            'Symptom Logging',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(icon: Icon(Icons.sunny)),
              Tab(icon: Icon(Icons.monitor_heart)),
              Tab(icon: Icon(Icons.apple)),
            ],
          ),
        ),
        body: TabBarView(children: [
          dailyWidget,
          EpisodeQuiz(),
          LifestyleQuiz()
        ]),
      ),
    );
  }
}
