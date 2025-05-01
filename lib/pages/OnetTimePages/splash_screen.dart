import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:reddit/pages/AuthPages/login_screen.dart';
import 'package:reddit/pages/home_screen.dart';
import 'package:reddit/service/shared_preferences_service.dart';
import 'package:reddit/service/firestore_service.dart';
import 'package:reddit/pages/OnetTimePages/create_username_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  final _prefs = SharedPreferencesService();
  final _firestore = FirestoreService();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _controller.forward();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    await _prefs.init();
    await Future.delayed(const Duration(seconds: 2));

    if (_prefs.isLoggedIn()) {
      final userId = _prefs.getUserId();
      if (userId != null) {
        final userData = await _firestore.getUserData(userId);
        final hasCompletedOnboarding =
            userData?['hasCompletedOnboarding'] ?? false;

        if (!hasCompletedOnboarding) {
          Get.offAll(() => CreateUsernameScreen(uid: userId));
        } else {
          Get.offAll(() => HomeScreen());
        }
      } else {
        Get.offAll(() => LoginScreen());
      }
    } else {
      Get.offAll(() => LoginScreen());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: FadeTransition(
          opacity: _animation,
          child: Image.asset(
            'assets/images/redit.png',
            width: size.width * 0.25,
            height: size.width * 0.25,
            color: const Color(0xFFFF4500),
          ),
        ),
      ),
    );
  }
}
