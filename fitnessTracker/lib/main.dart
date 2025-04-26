// Import necessary packages at the top of the file
import 'screens/home/journal/journal.dart';
import 'screens/home/qna_page/qna_page.dart';
import 'screens/navbar/chatbot/chatbot.dart';
import 'screens/navbar/games/chill_farm.dart';
import 'screens/navbar/games/flower_bloom.dart';

import 'screens/navbar/games/games.dart';
import 'screens/navbar/games/snake_game.dart';

import 'screens/navbar/music/music.dart';
import 'screens/navbar/profile/profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:async';
import 'screens/login/login.dart'; // Import the login screen
// Import the signup screen
import 'screens/home/home.dart';
import 'screens/navbar/games/bubble_pop.dart'; // Import BubbleWrapScreen file
import 'backend/backend.dart';
import 'backend/permissions.dart';
import 'backend/record_display_logic.dart';
import './screens/home/analyze.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
  startDataSync();
}

void startDataSync() {
  // final dataService = RecordDisplayLogic();

  // Schedule the sync every 5 minutes (300,000 milliseconds)
  // Timer.periodic(const Duration(minutes: 5), (timer) async {
  // print("Starting data sync...");
  // await dataService.sendAllDataToServer();
  // });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StressLens',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFFBFFFFE),
        scaffoldBackgroundColor: const Color(0xFFF3FFFF),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0B3534),
          foregroundColor: Colors.white,
        ),
      ),
      initialRoute: '/',
      routes: <String, WidgetBuilder>{
        '/': (context) => const AuthWrapper(),
        '/home': (context) => const HomeScreen(),
        '/permissions': (context) => const Permissions(),
        '/analysis': (context) => StressAnalysisPage(),
        '/chatbot': (context) => const ChatbotScreen(),
        '/music': (context) => const MusicScreen(),
        '/games': (context) => const GamesScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/qna': (context) => QnaPage(), // Ensure const constructors
        '/journal': (context) => JournalPage(), // Ensure const constructors
        '/games': (context) => const GamesScreen(),
        '/flower_bloom': (context) => FlowerBloomScreen(),
        '/chill_farm': (context) =>
            ChillFarmScreen(), // Route to Chill Farm screen
        '/bubble_pop': (context) => const BubbleWrapScreen(),

        '/demo': (context) => const Backend(),
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      // Ensure User import is correct
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          User? user = snapshot.data;
          if (user == null) {
            return const LoginScreen(); // Add const
          } else {
            return const Permissions(); // Add const
          }
        }
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }

  Future<User?> _checkAuthStatus() async {
    // Set persistence to LOCAL (this keeps the user logged in across app restarts)
    await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);

    // Get the current user (if any)
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // If we have a user, verify the token to ensure it's still valid
      try {
        await user.getIdToken(true);
      } catch (e) {
        // If token refresh fails, sign out the user
        await FirebaseAuth.instance.signOut();
        user = null;
      }
    }

    return user;
  }
}

// Your other classes remain unchanged
