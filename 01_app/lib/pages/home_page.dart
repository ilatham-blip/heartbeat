import 'package:flutter/material.dart';
import 'package:heartbeat/app_state.dart';
import 'package:heartbeat/test_connection.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePage();
}

class _HomePage extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
            title: Row(
              children: [
                //const SizedBox(width: 10),
                const Text("Heartbeat Monitor"),

                //const SizedBox(width: 20),

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
          body: Column(children: [Text("Home Page")],),
    );
  }
}