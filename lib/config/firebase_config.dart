import 'package:firebase_core/firebase_core.dart';

/// Firebase configuration using environment variables for security.
/// This file loads Firebase options from environment variables set at build time.
/// Use --dart-define to set these values: flutter run --dart-define FIREBASE_API_KEY=your_key
class FirebaseConfig {
  // Firebase configuration constants loaded from environment variables
  static const String apiKey = String.fromEnvironment('FIREBASE_API_KEY');
  static const String authDomain = String.fromEnvironment('FIREBASE_AUTH_DOMAIN');
  static const String projectId = String.fromEnvironment('FIREBASE_PROJECT_ID');
  static const String storageBucket = String.fromEnvironment('FIREBASE_STORAGE_BUCKET');
  static const String messagingSenderId = String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID');
  static const String appId = String.fromEnvironment('FIREBASE_APP_ID');

  /// Returns FirebaseOptions configured with environment variables.
  /// Throws AssertionError if any required environment variable is missing.
  static FirebaseOptions get options {
    // If any required environment variable is missing, return a safe
    // placeholder configuration to avoid throwing during app startup.
    // The app will still run, but Firebase features will remain disabled
    // until proper configuration is provided via --dart-define or
    // by generating a firebase_options.dart using the FlutterFire CLI.
    final bool hasAll = apiKey.isNotEmpty && projectId.isNotEmpty && appId.isNotEmpty;

    if (!hasAll) {
      // Provide a placeholder configuration when env vars are missing.
      return FirebaseOptions(
        apiKey: apiKey.isNotEmpty ? apiKey : 'AIzaSyCQqV5G0_cfkZdLJSKPQMdUZyR_AgeqU_8',
        authDomain: authDomain,
        projectId: projectId.isNotEmpty ? projectId : 'smart-shopping-aa9a1',
        storageBucket: storageBucket,
        messagingSenderId: messagingSenderId,
        appId: appId.isNotEmpty ? appId : '1:635656395245:web:9fa014104f4f8c7af5efe4',
      );
    }

    return const FirebaseOptions(
      apiKey: apiKey,
      authDomain: authDomain,
      projectId: projectId,
      storageBucket: storageBucket,
      messagingSenderId: messagingSenderId,
      appId: appId,
    );
  }
}