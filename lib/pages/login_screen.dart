import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            "assets/images/redit.png",
            width: mediaQuery.size.width * 0.25,
            height: mediaQuery.size.width * 0.25,
          ),
          SizedBox(height: mediaQuery.size.height * 0.02),
          Text(
            "Log in to Reddit",
            style: TextStyle(
              color: Colors.white,
              fontSize: mediaQuery.size.width * 0.06,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: mediaQuery.size.height * 0.02),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(30),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: mediaQuery.size.width * 0.1,
              vertical: mediaQuery.size.height * 0.015,
            ),
            child: GestureDetector(
              onTap: () {},
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.phone, color: Colors.white),
                  SizedBox(width: mediaQuery.size.width * 0.02),
                  Text(
                    "Continue with phone number",
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: mediaQuery.size.height * 0.01),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(30),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: mediaQuery.size.width * 0.1,
              vertical: mediaQuery.size.height * 0.015,
            ),
            child: GestureDetector(
              onTap: () {},
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.email, color: Colors.white),
                  SizedBox(width: mediaQuery.size.width * 0.02),
                  Text(
                    "Continue with Google",
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: mediaQuery.size.height * 0.01),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(30),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: mediaQuery.size.width * 0.1,
              vertical: mediaQuery.size.height * 0.015,
            ),
            child: GestureDetector(
              onTap: () {},
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.person, color: Colors.white),
                  SizedBox(width: mediaQuery.size.width * 0.02),
                  Text(
                    "Use email or username",
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: mediaQuery.size.height * 0.02),
          Text(
            "By continuing, you agree to our User Agreement and acknowledge that you understand the Privacy Policy.",
            style: TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: mediaQuery.size.height * 0.01),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Checkbox(value: false, onChanged: (value) {}),
              Text(
                "I agree to receive emails about cool stuff on Reddit.",
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
          SizedBox(height: mediaQuery.size.height * 0.02),
          TextButton(
            onPressed: () {},
            child: Text(
              "Don't have an account? Sign up",
              style: TextStyle(color: Colors.blue),
            ),
          ),
        ],
      ),
    );
  }
}
