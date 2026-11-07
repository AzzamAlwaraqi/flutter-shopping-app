import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'pages/profile_page.dart';

/// ----------------------------------------------------------------------------
/// MAIN ENTRY POINT
/// ----------------------------------------------------------------------------
/// This is the starting point of the application. 
/// It initializes Firebase and sets up the root [MaterialApp] with basic 
/// configuration like theming and initial routing.
void main() async {
  // Ensures that widget binding is initialized before calling Firebase.initializeApp
  WidgetsFlutterBinding.ensureInitialized();

  // Android reads its Firebase config from android/app/google-services.json,
  // so it must be initialized WITHOUT options (passing placeholder options
  // overrode that file and broke Firestore).
  // The web has no config file, so its values come from --dart-define:
  //   flutter run -d chrome --dart-define=FIREBASE_API_KEY=... (see webOptions below)
  await Firebase.initializeApp(options: kIsWeb ? webOptions : null);

  runApp(const FlutterProject());
}

/// Firebase web app settings, taken from the Firebase console
/// (Project settings > Your apps > Web app). Nothing secret is stored in the code.
const webOptions = FirebaseOptions(
  apiKey: String.fromEnvironment('FIREBASE_API_KEY'),
  appId: String.fromEnvironment('FIREBASE_APP_ID'),
  messagingSenderId: String.fromEnvironment('FIREBASE_SENDER_ID'),
  projectId: String.fromEnvironment('FIREBASE_PROJECT_ID', defaultValue: 'flutter-project-3987f'),
  storageBucket: String.fromEnvironment('FIREBASE_STORAGE_BUCKET'),
);

/// ----------------------------------------------------------------------------
/// MAIN APP WIDGET
/// ----------------------------------------------------------------------------
/// The [FlutterProject] widget is the root of your application.
/// It configures the app's global appearance (ThemeData) and navigation (Routes).
class FlutterProject extends StatelessWidget {
  const FlutterProject({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Hides the "Debug" banner in the top-right corner.
      debugShowCheckedModeBanner: false,
      
      title: 'Address App',
      
      // Global Theme Configuration
      theme: ThemeData(
        primarySwatch: Colors.green,
        // Sets a light grey background for all scaffolds by default.
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        useMaterial3: true, // Opting into Material 3 for modern look
      ),
      
      // Initial Route Configuration
      initialRoute: '/',
      routes: {
        '/': (context) => const ProfilePage(name: "Azzam Alwaraqi")
      },
    );
  }
}
