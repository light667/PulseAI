import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'providers/theme_provider.dart';
import 'core/theme/app_theme.dart';
import 'providers/locale_provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:pulseai/l10n/generated/app_localizations.dart';
import 'l10n/l10n_utils.dart';

import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/main_layout.dart';
import 'screens/chat_screen.dart';
import 'screens/diagnosis_screen.dart';
import 'screens/diagnosis_result_screen.dart';
import 'screens/hospital_map_screen.dart';
import 'screens/scan_screen.dart';
import 'screens/scan_result_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/edit_profile_screen.dart';
import 'screens/diagnosis_history_screen.dart';
import 'screens/chat_history_screen.dart';


import 'dart:async'; // Import nécessaire pour runZonedGuarded

// Initialisation centralisée avec gestion d'erreur pour éviter écran blanc.
void main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    
    FlutterError.onError = (FlutterErrorDetails details) {
      debugPrint('Flutter framework error: ${details.exceptionAsString()}');
    };
    
    Object? initError;
    try {
      // Null-safe Firebase initialization
      final firebaseOptions = DefaultFirebaseOptions.currentPlatform;
      await Firebase.initializeApp(
        options: firebaseOptions,
      );
          
      // Web-specific Firestore configuration to avoid connection issues
      if (kIsWeb) {
        try {
          FirebaseFirestore.instance.settings = const Settings(
            persistenceEnabled: true,
            sslEnabled: true,
          );
        } catch (e) {
          debugPrint('Error configuring Firestore settings: $e');
        }
      }
    } catch (e, st) {
      initError = e;
      debugPrint('Erreur Firebase init: $e');
      debugPrint(st.toString());
    }
    
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ],
        child: MyRoot(initError: initError),
      ),
    );
  }, (error, stackTrace) {
    debugPrint('Erreur non gérée: $error');
    debugPrint('Stack trace: $stackTrace');
    // Ici vous pourriez envoyer l'erreur à Crashlytics ou Sentry
  });
}

class MyRoot extends StatelessWidget {
  final Object? initError;
  const MyRoot({super.key, this.initError});

  @override
  Widget build(BuildContext context) {
    if (initError != null) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.redAccent),
                  const SizedBox(height: 16),
                  const Text(
                    'Erreur d\'initialisation',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    initError.toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => _retryFirebase(context),
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    return const MyApp();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, LocaleProvider>(
      builder: (context, themeProvider, localeProvider, child) {
        return MaterialApp(
          title: 'PulseAI',
          debugShowCheckedModeBanner: false,
          themeMode: themeProvider.themeMode,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          locale: localeProvider.locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            FallbackMaterialLocalizationsDelegate(),
            FallbackCupertinoLocalizationsDelegate(),
          ],
          supportedLocales: const [
            Locale('fr'), // Français
            Locale('en'), // English
            Locale('ee'), // Ewe
            Locale('kbp'), // Kabye
            Locale('tem'), // Kotokoli
            Locale('fon'), // Fon
            Locale('yo'), // Yoruba
            Locale('ln'), // Lingala
          ],
          initialRoute: '/',
          routes: {
            '/': (context) => const SplashScreen(),
            '/onboarding': (context) => const OnboardingScreen(),
            '/login': (context) => const LoginScreen(),
            '/signup': (context) => const SignupScreen(),
            '/home': (context) => const MainLayout(),
            '/chat': (context) => const ChatScreen(),
            '/diagnosis': (context) => const DiagnosisScreen(),
            '/diagnosis_result': (context) => const DiagnosisResultScreen(),
            '/hospital_map': (context) => const HospitalMapScreen(),
            '/scan': (context) => const ScanScreen(),
            '/scan_result': (context) => const ScanResultScreen(),
            '/profile': (context) => const ProfileScreen(),
            '/edit_profile': (context) => const EditProfileScreen(),
            '/diagnosis_history': (context) => const DiagnosisHistoryScreen(),
            '/chat_history': (context) => const ChatHistoryScreen(),
          },
        );
      },
    );
  }
}

Future<void> _retryFirebase(BuildContext context) async {
  Object? retryError;
  try {
    final firebaseOptions = DefaultFirebaseOptions.currentPlatform;
    await Firebase.initializeApp(
      options: firebaseOptions,
    );
    } catch (e) {
    retryError = e;
  }
  if (!context.mounted) return;
  if (retryError == null) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MyApp()),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Échec: ${retryError.toString()}')),
    );
  }
}