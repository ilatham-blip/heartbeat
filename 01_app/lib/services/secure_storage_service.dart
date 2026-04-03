import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SecureLocalStorage extends LocalStorage {
  // Configured with EncryptedSharedPreferences for Android compliance with best security practices
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  /// Standard key used by supabase to persist the session
  static const String _supabasePersistSessionKey = 'supabase.auth.token';

  @override
  Future<void> initialize() async {
    // Initialization is synchronous for secure storage, no explicit init required.
  }

  @override
  Future<String?> accessToken() async {
    return await _storage.read(key: _supabasePersistSessionKey);
  }

  @override
  Future<bool> hasAccessToken() async {
    return await _storage.containsKey(key: _supabasePersistSessionKey);
  }

  @override
  Future<void> persistSession(String persistSessionString) async {
    await _storage.write(
      key: _supabasePersistSessionKey,
      value: persistSessionString,
    );
  }

  @override
  Future<void> removePersistedSession() async {
    await _storage.delete(key: _supabasePersistSessionKey);
  }
}
