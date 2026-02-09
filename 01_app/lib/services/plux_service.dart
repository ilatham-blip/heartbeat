import 'package:flutter/services.dart';

class PluxService {
  static const platform = MethodChannel('com.example.heartbeat/plux');

  Future<String> testConnection() async {
    try {
      final String result = await platform.invokeMethod('testConnection');
      return result;
    } on PlatformException catch (e) {
      return "Failed: ${e.message}";
    }
  }

  Future<void> scanDevices() async {
    try {
      await platform.invokeMethod('scanDevices');
    } on PlatformException catch (e) {
      print("Scan failed: ${e.message}");
    }
  }
}