import 'package:flutter/services.dart';

class PluxService {
  static const platform = MethodChannel('com.example.heartbeat/plux');

  // NEW: The "Radio Antenna" to listen to continuous data
  static const dataStream = EventChannel('com.example.heartbeat/plux/data');

  Future<String> testConnection() async {
    try {
      final String result = await platform.invokeMethod('testConnection');
      return result;
    } on PlatformException catch (e) {
      return "Failed: ${e.message}";
    }
  }
  // Tells the physical hardware to wake up and start flashing/measuring
  Future<void> startRecording() async {
    try {
      await platform.invokeMethod('start');
    } on PlatformException catch (e) {
      print("Failed to start: ${e.message}");
    }
  }

  // Tells the physical hardware to go back to sleep to save battery
  Future<void> stopRecording() async {
    try {
      await platform.invokeMethod('stop');
    } on PlatformException catch (e) {
      print("Failed to stop: ${e.message}");
    }
  }
  // Tells the physical hardware to completely disconnect Bluetooth
  Future<void> disconnect() async {
    try {
      await platform.invokeMethod('disconnect');
    } on PlatformException catch (e) {
      print("Failed to disconnect: ${e.message}");
    }
  }
  Future<void> scanDevices() async {
    try {
      await platform.invokeMethod('scanDevices');
    } on PlatformException catch (e) {
      print("Scan failed: ${e.message}");
    }
  }

  // NEW: The function your UI will call to listen to the data
  // NEW: Listen for a List of doubles instead of a single double
  Stream<List<double>> get heartDataStream {
    return dataStream.receiveBroadcastStream().map((dynamic event) {
      if (event is List) {
        // Convert the incoming Java array into a Dart List<double>
        return event.map((e) => double.tryParse(e.toString()) ?? 0.0).toList();
      }
      return <double>[];
    });
  }
}