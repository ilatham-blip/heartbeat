import 'package:flutter/material.dart';
import '../services/plux_service.dart';

class PluxTestScreen extends StatefulWidget {
  const PluxTestScreen({super.key});

  @override
  State<PluxTestScreen> createState() => _PluxTestScreenState();
}

class _PluxTestScreenState extends State<PluxTestScreen> {
  final PluxService _pluxService = PluxService();
  String _result = 'Press button to test';

  Future<void> _testConnection() async {
    final result = await _pluxService.testConnection();
    setState(() {
      _result = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PLUX Test'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _result,
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _testConnection,
              child: const Text('Test Java Connection'),
            ),
          ],
        ),
      ),
    );
  }
}