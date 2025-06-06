import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:get/get.dart';
import 'package:reddit/pages/OnetTimePages/splash_screen.dart';
import 'package:reddit/pages/HomePages/Navigation_screen.dart';
import 'package:reddit/widgets/loading_screen.dart';
import 'package:reddit/services/shared_preferences_service.dart';
import 'package:reddit/controller/profile_controller.dart';
import 'package:reddit/controller/feed_controller.dart';
import 'package:reddit/controller/community_controller.dart';
import 'package:reddit/controller/search_history_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'AIzaSyDbrW97zekwMdtZBAQLC55lC7pcuV6jIJ0',
        appId: '1:469269709724:android:f066f7a8e74b84c1b8fe59',
        messagingSenderId: '469269709724',
        projectId: 'redit-clone-8fd14',
        storageBucket: 'redit-clone-8fd14.firebasestorage.app',
      ),
    );

    // Initialize shared preferences
    final prefs = SharedPreferencesService();
    await prefs.init();

    Gemini.init(apiKey: "AIzaSyBYJqwzAtH9soEotD9DryVPkZgTc0godXs");

    // Initialize Controllers
    Get.put(ProfileController());
    Get.put(FeedController());
    Get.put(CommunityController());
    Get.put(SearchHistoryController());
  } catch (e) {
    debugPrint('Error during initialization: $e');
    // Show error dialog or handle the error appropriately
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Error initializing app: $e'),
          ),
        ),
      ),
    );
    return;
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Reddit Clone',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.black,
        brightness: Brightness.dark,
        textTheme: Typography.whiteMountainView,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          elevation: 0,
        ),
        // Add more theme customization for a consistent look
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ),

      // You can switch back to the main app logic by uncommenting below
      // home: const DemoCommentScreenPage(),

      home: FutureBuilder<bool>(
        future: _checkOnboardingStatus(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            log("Loading");
            return const LoadingScreen();
          }

          if (snapshot.hasData && snapshot.data == true) {
            log("Onboarding");
            return const NavigationScreen();
          }

          return const SplashScreen();
        },
      ),
    );
  }

  Future<bool> _checkOnboardingStatus() async {
    try {
      final prefs = SharedPreferencesService();
      final userId = prefs.getUserId();

      if (userId == null) return false;

      final profileController = Get.find<ProfileController>();
      await profileController.loadUserData();

      return profileController.hasCompletedOnboarding.value;
    } catch (e) {
      print('Error checking onboarding status: $e');
      return false;
    }
  }
}
