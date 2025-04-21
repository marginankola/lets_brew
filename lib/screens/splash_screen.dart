import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:lets_brew/constants/theme_constants.dart';
import 'package:lets_brew/screens/home_screen.dart';
import 'package:lets_brew/screens/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lets_brew/services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Navigate to the appropriate screen after a delay
    Timer(const Duration(seconds: 3), () => _checkAuthAndNavigate());
  }

  // Check authentication state and navigate accordingly
  void _checkAuthAndNavigate() {
    final authState = Provider.of<User?>(context, listen: false);
    final authService = Provider.of<AuthService>(context, listen: false);

    // If using mock authentication, always go to login screen first
    if (authService.isMockAuth) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
      return;
    }

    // Using real Firebase authentication
    if (authState != null) {
      // User is logged in, navigate to home screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else {
      // User is not logged in, navigate to login screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeConstants.darkGrey,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App logo or icon
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: ThemeConstants.darkPurple.withOpacity(0.8),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: ThemeConstants.brown.withOpacity(0.6),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  Icons.coffee,
                  size: 80,
                  color: ThemeConstants.cream,
                ),
              ),
            ),
            const SizedBox(height: 40),
            // App name
            Text(
              "Let's Brew",
              style: TextStyle(
                color: ThemeConstants.cream,
                fontSize: 36,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            // Tagline
            Text(
              "Perfect Coffee, Every Time",
              style: TextStyle(
                color: ThemeConstants.lightBrown,
                fontSize: 18,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 60),
            // Loading indicator
            SpinKitDoubleBounce(color: ThemeConstants.brown, size: 50.0),
          ],
        ),
      ),
    );
  }
}
