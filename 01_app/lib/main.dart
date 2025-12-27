import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:heartbeat/symptomChart.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Heartbeat App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  final dizziness = <double>[];
  final nausea = <double>[];
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = SymptomPage();
      case 1:
        page = TrackerPage();
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          body: Row(
            children: [
              SafeArea(
                child: NavigationRail(
                  extended: constraints.maxWidth >= 600,
                  destinations: [
                    NavigationRailDestination(
                      icon: Icon(Icons.home),
                      label: Text('Home'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.analytics),
                      label: Text('Analytics'),
                    ),
                  ],
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (value) {
                    setState(() {
                      selectedIndex = value;
                    });
                  },
                ),
              ),
              Expanded(
                child: Container(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: page,  // ← Here.
                ),
              ),
            ],
          ),
        );
      }
    );
  }
}

class SymptomPage extends StatefulWidget{
  const SymptomPage({ super.key });

  @override
  State<SymptomPage> createState() => _SymptomPage();
}

class _SymptomPage extends State<SymptomPage>{
  double _dizziness = 0.0;
  double _nausea = 0.0;

  @override
  Widget build(BuildContext context){
    var appState = context.watch<MyAppState>();

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Slider(
          value: _dizziness, 
          label: _dizziness.toString(),
          max: 7,
          divisions: 7,
          onChanged: (double value){
            setState(() {
              _dizziness = value;
            });
          }
          ),
        Text("Dizziness intensity"),
        SizedBox(height:10),
        Slider(
          value: _nausea, 
          label: _nausea.toString(),
          max: 7,
          divisions: 7,
          onChanged: (double value){
            setState(() {
              _nausea = value;
            });
          }
          ),
          Text("Nausea intensity"),
          SizedBox(height:10),
          ElevatedButton(
            onPressed: (){
              setState((){
                appState.nausea.add(_nausea);
                appState.dizziness.add(_dizziness);
              });
            }, 
            child: Text("Record symptoms"))
      ],
    );
  }
}

class TrackerPage extends StatefulWidget{
  const TrackerPage({ super.key });

  @override
  State<TrackerPage> createState() => _TrackerPage();
}

class _TrackerPage extends State<TrackerPage>{
  @override
  Widget build(BuildContext context){
    var appState  = context.watch<MyAppState>();
    return Column(
      children: [
        Text("Dizziness:"),
        symptomChart(appState.dizziness),
        Text("Nausea:"),
        symptomChart(appState.nausea)
      ],
    );
  }
}