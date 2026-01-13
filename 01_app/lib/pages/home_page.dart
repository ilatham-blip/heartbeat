import 'package:flutter/material.dart';
import 'package:heartbeat/pages/user_login_page.dart';

import 'package:heartbeat/test_connection.dart';
import 'tracker_page.dart';
import 'symptom_page.dart';

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
        page = UserLoginPage();
      case 1:
        page = TrackerPage();
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                const SizedBox(width: 10),
                const Text("Heartbeat Monitor"),

                const SizedBox(width: 20),

                // The "Developer Tools" Button
                IconButton(
                  icon: const Icon(Icons.build), // Wrench icon
                  tooltip: "Test Connection",
                  onPressed: () {
                    // Navigate to the Test Screen you created earlier
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TestConnectionScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

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
                  child: page,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}