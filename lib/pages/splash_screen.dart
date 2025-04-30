import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reddit/pages/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 30), () {
      Get.to(() => LoginScreen(), transition: Transition.fadeIn);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.black,
        child: Center(
          child: Image.asset(
            "assets/images/redit.png",
            color: Colors.white,
            width: 100,
            height: 100,
          ),
        ),
      ),
    );
  }
}
