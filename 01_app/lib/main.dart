import 'package:flutter/material.dart';
import 'package:heartbeat/pages/more_page.dart';
import 'package:heartbeat/supabase_keys.dart';
import 'package:provider/provider.dart';

import 'package:heartbeat/app_state.dart';
import 'package:heartbeat/services/notification_service.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'pages/app_layout.dart';
import 'pages/user_login_page.dart';
import 'pages/create_profile_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize the supabase setup
  await Supabase.initialize(
    url: SupabaseKeys.url,
    anonKey: SupabaseKeys.anonKey,
  );

  // Initialize notification service
  await NotificationService().initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MyAppState()),
      ],
      child: MaterialApp(
        title: 'Heartbeat',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1E40AF),
            surface: const Color(0xFFFAFAFA),
          ),
          scaffoldBackgroundColor: const Color(0xFFFAFAFA),
        ),
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
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1E40AF),
            surface: const Color(0xFFFAFAFA),
          ),
          scaffoldBackgroundColor: const Color(0xFFFAFAFA),
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

        // If we have a valid session, check if profile exists
        final session = snapshot.data?.session;
        if (session != null) {
          return FutureBuilder<Map<String, dynamic>?>(
            future: Supabase.instance.client
                .from('user_profiles')
                .select()
                .eq('id', session.user.id)
                .maybeSingle(),
            builder: (context, profileSnapshot) {
              if (profileSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(body: Center(child: CircularProgressIndicator()));
              }
              
              // If no profile exists, redirect to create profile
              if (profileSnapshot.data == null) {
                return const CreateProfilePage();
              }
              
              return AppLayout();
            },
          );
        } else {
          // Otherwise, show the Login Page
          return const UserLoginPage();
        }
      },
    );
  }
}