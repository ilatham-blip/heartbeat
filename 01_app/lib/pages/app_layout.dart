import 'package:flutter/material.dart';
import 'package:heartbeat/app_state.dart';
import 'package:heartbeat/pages/home_page.dart';
import 'package:heartbeat/pages/symptom_page.dart';

import 'package:provider/provider.dart';
import 'tracker_page.dart';

class AppLayout extends StatefulWidget {
  @override
  State<AppLayout> createState() => _AppLayoutState();
}

class _AppLayoutState extends State<AppLayout> {

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<MyAppState>(context, listen: true);
    var selectedIndex = appState.pageindex;

    Widget page;
    switch (selectedIndex) {
      case 0:
        page = HomePage();
      case 1:
        page = SymptomPage();
      case 2:
        page = TrackerPage();
      case 3:
        page = Placeholder();
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          bottomNavigationBar: DefaultTabController(length: 4, child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                onPressed: (){appState.changeIndex(0);}, 
                tooltip: "Home",
                icon: Icon(Icons.home)),
              IconButton(
                onPressed: (){appState.changeIndex(1);}, 
                tooltip: "Logging",
                icon: Icon(Icons.monitor_heart)),
              IconButton(
                onPressed: (){appState.changeIndex(2);}, 
                tooltip: "Insights",
                icon: Icon(Icons.analytics)),
              IconButton(
                onPressed: (){appState.changeIndex(3);}, 
                tooltip: "More",
                icon: Icon(Icons.line_style)),
          ],)),
          body: page,
        );
      },
    );
  }
}