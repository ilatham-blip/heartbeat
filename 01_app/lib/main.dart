import 'package:flutter/material.dart';
import 'package:heartbeat/pages/placeholder_page.dart';
import 'package:heartbeat/supabase_keys.dart';
import 'package:provider/provider.dart';

import 'package:heartbeat/app_state.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // initizling the supabase setup
  await Supabase.initialize(
    url: SupabaseKeys.url,
    anonKey: SupabaseKeys.anonKey,
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
        home: PlaceholderPage(),
      ),
    );
  }
}