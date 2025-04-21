import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:lets_brew/constants/theme_constants.dart';
import 'package:lets_brew/screens/splash_screen.dart';
import 'package:lets_brew/services/auth_service.dart';
import 'package:lets_brew/services/coffee_service.dart';
import 'package:lets_brew/services/timer_service.dart';
import 'package:lets_brew/services/admin_service.dart';
import 'package:lets_brew/services/user_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with real configuration
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: "AIzaSyBEFu4Aza8rXYzVpLiMUaVLEAunBDl_UIg",
          authDomain: "letsbrewapp.firebaseapp.com",
          projectId: "letsbrewapp",
          storageBucket: "letsbrewapp.firebasestorage.app",
          messagingSenderId: "387419706730",
          appId: "1:387419706730:web:38f72ad9a678f1d3944113",
          measurementId: "G-BP9SRQE75B",
        ),
      );
      print('Firebase initialized successfully');
    }
  } catch (e) {
    print('Failed to initialize Firebase: $e');
    // Continue without Firebase for development
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => AuthService()),
        ChangeNotifierProvider<CoffeeService>(create: (_) => CoffeeService()),
        ChangeNotifierProvider<BrewTimerService>(
          create: (_) => BrewTimerService(),
        ),
        Provider<AdminService>(create: (_) => AdminService()),
        ChangeNotifierProvider(create: (_) => UserService()),
        StreamProvider(
          create: (context) => context.read<AuthService>().authStateChanges,
          initialData: null,
        ),
      ],
      child: MaterialApp(
        title: 'Let\'s Brew',
        theme: ThemeData(
          scaffoldBackgroundColor: ThemeConstants.darkBackground,
          brightness: Brightness.dark,
          primaryColor: ThemeConstants.brown,
          colorScheme: ColorScheme.dark(
            primary: ThemeConstants.brown,
            secondary: ThemeConstants.lightBrown,
            surface: ThemeConstants.darkBackground,
          ),
          appBarTheme: AppBarTheme(
            backgroundColor: ThemeConstants.darkBackground,
            elevation: 0,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeConstants.brown,
              foregroundColor: ThemeConstants.cream,
            ),
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: ThemeConstants.lightBrown,
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: ThemeConstants.darkGrey,
            labelStyle: TextStyle(color: ThemeConstants.lightBrown),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: ThemeConstants.lightPurple),
            ),
          ),
        ),
        debugShowCheckedModeBanner: false,
        home: const SplashScreen(),
      ),
    );
  }
}
