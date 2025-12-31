// CAN CREATE A 

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TestConnectionScreen extends StatefulWidget {
  const TestConnectionScreen({super.key});

  @override
  State<TestConnectionScreen> createState() => _TestConnectionScreenState();
}

class _TestConnectionScreenState extends State<TestConnectionScreen> {
  String _log = "Waiting for action...";

  // Helper to add text to our log screen
  void _addToLog(String message) {
    setState(() {
      _log = "$message\n\n$_log";
    });
  }

  // STEP 1: LOGIN (Using the user you made in Python)
  Future<void> _loginTestUser() async {
    _addToLog("⏳ Attempting Login...");
    String email = 'patient12345@imperial.ac.uk';
    String password = 'password123';


    try {
      // We use the same credentials defined in your 'create_test_user.py'
      await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      _addToLog(
        "✅ Login Successful!\nUser ID: ${Supabase.instance.client.auth.currentUser?.id}\nEmail: $email Password: $password",
      );
    } catch (e) {
      _addToLog("❌ Login Failed: $e");
    }
  }

  // STEP 2: WRITE (Insert a random log)
  Future<void> _writeTestLog() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      _addToLog("⚠️ Error: You must login first!");
      return;
    }

    _addToLog("⏳ Sending Data...");
    try {
      // Create random values so we can distinguish this specific log
      final randomLevel = Random().nextInt(3); // 0, 1, or 2

      await Supabase.instance.client.from('daily_checkins').upsert({
        'user_id': user.id,
        'date': DateTime.now().toIso8601String().split(
          'T',
        )[0], // Today's date (YYYY-MM-DD)
        'checkin_type': 'MORNING', // Testing the Evening slot
        'fatigue_level': randomLevel,
        'dizziness_level': 1,
      });

      _addToLog("✅ Write Successful! (Fatigue Level set to $randomLevel)");
    } catch (e) {
      _addToLog("❌ Write Failed: $e");
    }
  }

  // STEP 3: READ (Fetch the data back)
  Future<void> _readTestLog() async {
    _addToLog("⏳ Reading Database...");
    try {
      final response = await Supabase.instance.client
          .from('daily_checkins')
          .select()
          .eq(
            'date',
            DateTime.now().toIso8601String().split('T')[0],
          ); // Filter for Today
          

      
      _addToLog("✅ Read Successful!\nData: ${response.toString()}");

    } catch (e) {
      _addToLog("❌ Read Failed: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Read/Write Test")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // --- THE BUTTONS ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _loginTestUser,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("1. Login"),
                ),
                ElevatedButton(
                  onPressed: _writeTestLog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("2. Write"),
                ),
                ElevatedButton(
                  onPressed: _readTestLog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("3. Read"),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              "Activity Log:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Divider(),

            // --- THE LOG SCREEN ---
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                color: Colors.grey[200],
                child: SingleChildScrollView(
                  child: Text(
                    _log,
                    style: const TextStyle(fontFamily: 'Courier'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
