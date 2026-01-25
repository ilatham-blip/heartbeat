import 'package:flutter/material.dart';
import 'package:heartbeat/pages/more_page.dart';
import 'package:heartbeat/supabase_keys.dart';
import 'package:provider/provider.dart';

import 'package:heartbeat/app_state.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'pages/app_layout.dart';
import 'pages/user_login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // initizling the supabase setup
  await Supabase.initialize(
    url: SupabaseKeys.url,
    anonKey: SupabaseKeys.anonKey,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MyAppState()),
      ],
      child: MaterialApp(
        title: 'Heartbeat',
        home: AuthGate(), // <--- Point 'home' to the Gatekeeper
      ),
    ),
  );
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
        home: MorePage(),
      ),
    );
  }
}


class AuthGate extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // StreamBuilder listens to login/logout events live
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        // If we are waiting for a connection, show a loader
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        // If we have a valid session, show the App
        final session = snapshot.data?.session;
        if (session != null) {
          return AppLayout(); 
        } else {
          // Otherwise, show the Login Page
          return const UserLoginPage();
        }
      },
    );
  }
}