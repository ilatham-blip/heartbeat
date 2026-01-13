import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:heartbeat/app_state.dart';
import 'package:heartbeat/pages/home_page.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // initizling the supabase setup
  await Supabase.initialize(
    url: 'https://lxagctltenlyhoyfpegd.supabase.co',//SupabaseKeys.url,
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imx4YWdjdGx0ZW5seWhveWZwZWdkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjY4OTgyMDUsImV4cCI6MjA4MjQ3NDIwNX0.kOEkPT3AHZLvifuFa3yanx6dfBQkcR7SnqpuM64-YTs', //SupabaseKeys.anonKey,
  );

  runApp(const MyApp());
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