import 'package:flutter/material.dart';
import 'package:heartbeat/app_state.dart';
import 'package:heartbeat/app_theme.dart';
import 'package:heartbeat/pages/home_page.dart';
import 'package:heartbeat/pages/more_page.dart';
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
        page = MorePage();
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          backgroundColor: kBackgroundColor,
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: BottomNavigationBar(
              currentIndex: selectedIndex,
              onTap: (index) => appState.changeIndex(index),
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.white,
              selectedItemColor: kBrandBlue,
              unselectedItemColor: Colors.grey.shade400,
              selectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 12,
              ),
              elevation: 0,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.monitor_heart_outlined),
                  activeIcon: Icon(Icons.monitor_heart),
                  label: 'Logging',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.analytics_outlined),
                  activeIcon: Icon(Icons.analytics),
                  label: 'Insights',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.menu_outlined),
                  activeIcon: Icon(Icons.menu),
                  label: 'More',
                ),
              ],
            ),
          ),
          body: page,
        );
      },
    );
  }
}